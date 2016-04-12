require 'rubygems'
require 'json'
require 'sinatra'
require 'sinatra/cross_origin'

require File.join(File.expand_path(File.dirname(__FILE__)), './centreon2elatic/GetData')

before do
    content_type 'application/json'
end

configure do
        enable :cross_origin
        set :allow_origin, :any
        set :allow_methods, [:get, :post, :put, :delete]
end

set :port, 8280
set :bind, '0.0.0.0'

get '/v1/cpu' do

        ob = {}
        ob["type"] = "CPU"
        GetData.get(ob).to_json
end

get '/v1/swap' do

        ob = {}
        ob["type"] = "Memoria_Swap"
        GetData.get(ob).to_json
end

