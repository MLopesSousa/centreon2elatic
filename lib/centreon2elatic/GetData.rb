require 'rubygems'
require 'mysql'
require 'json'

class GetData
        def self.get_cpu(row)
                _host = row[0]

                begin
                        _status = row[1].split('-')[0].rstrip
                        _metric = row[1].split('-')[1].split(':')[1].split(',')[0]

                rescue
                         _status = 'FAIL'
                        _metric = 0

                end

                if _status =~ /(OK|WARNING|CRITICAL)/
                        log("#{@timestamp} HOST-CPU #{_host} - #{_status} - #{_metric}") if @bash

                        ob = {}
                        ob[_host] = {"status" =>  _status, "cpu_used" => _metric.to_f }
                        return ob
                end
        end

        def self.get_swap(row)
                _host = row[0]

                begin
                        _status = row[1].split('-')[0].split.join
                        _payload = row[1].split('-')[1]
                        _metric = 100 - _payload.split('%')[0].to_i 
                        _max = _payload.split('(')[1].split(' ')[0]

                rescue
                        _status = 'FAIL'
                        _metric = 0
                        _max = 0

                end

                if _status =~ /^SWAP/
                        log("#{@timestamp} HOST-SWAP #{_host} - #{_status} - #{_max} - #{_metric}") if @bash

                        ob = {}
                        ob[_host] = {"status" =>  _status, "swap" => _max.to_i , "swap_used" => _metric.to_i }
                        return ob
                end
        end

        def self.build_timestamp
                _t = Time.now.getutc.to_s
                return _t.sub(" ","T").sub(" UTC","-0300")

        end

        def self.log(str)
                File.open(@file, "a") do |f|
                        f.puts(str)

                end
        end

        def self.get(ob ={})
                ob_returned = []
                @timestamp = build_timestamp()

                @bash ||= ob["bash"] || false
                @file ||= ob["out_file"] || 'out.txt'

                mysql_address ||= ENV['SC_MYSQL_ADDRESS'] || '127.0.0.1'
                mysql_user ||= ENV['SC_MYSQL_USER'] || 'username'
                mysql_pass ||= ENV['SC_MYSQL_PASS'] || 'pass'
                mysql_db ||= ENV['SC_MYSQL_DB'] || 'centreon_storage'

                query_host ||= ob["host"] || 'sd2%' # your server's patern 
                query_type ||= ob["type"] || 'CPU'

                return_ob = {}

                begin
                        query = "select h.name, s.output from services s inner join hosts h on s.host_id=h.host_id where s.description = '#{query_type}' order by h.name"
                        con = Mysql.new mysql_address, mysql_user, mysql_pass, mysql_db
                        rs = con.query(query)

                        rs.each do |row|
                                case query_type
                                when 'CPU'
                                        ob_returned << get_cpu(row)

                                when 'Memoria_Swap'
                                        ob_returned << get_swap(row)
                                end

                        end

                rescue Mysql::Error => e
                        puts e.errno
                        puts e.error

                ensure
                        con.close if con
                end

                return ob_returned.reject(&:nil?)
        end
end
