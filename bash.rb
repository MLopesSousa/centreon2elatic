#!/usr/local/bin/ruby
require File.join(File.expand_path(File.dirname(__FILE__)), 'lib/centreon2elatic/GetData')

types_arr = ["CPU", "Memoria_Swap"]

types_arr.each do |_t|
        ob = {}
        ob["bash"] = true
        ob["out_file"] = "/tmp/output.txt"
        ob["type"] = _t

        GetData.get(ob)

end

