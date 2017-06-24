require 'sinatra'
require 'sinatra/cross_origin'
require 'mongoid'
require './models'

configure do
  enable :cross_origin
end

get '/customers' do
  CustomerData.all.to_json
end

get '/customers/:customer_id' do
  begin
    CustomerData.find(params[:customer_id].to_i).to_json
  rescue Mongoid::Errors::DocumentNotFound
    nil
  end
end


get '/customers/:customer_id/address' do
  begin
    AddressData.where(:customer_id => params[:customer_id].to_i)[0].to_json
  rescue Mongoid::Errors::DocumentNotFound
    nil
  end
end


get '/customers/:customer_id/accounts' do
  begin
    BankAccountData.where(:customer_id => params[:customer_id].to_i).to_json
  rescue Mongoid::Errors::DocumentNotFound
    nil
  end
end

get '/customers/:customer_id/accounts/:account_id' do
  begin
    BankAccountData.where(:customer_id => params[:customer_id].to_i, :id => params[:account_id].to_i)[0].to_json
  rescue Mongoid::Errors::DocumentNotFound
    nil
  end
end
