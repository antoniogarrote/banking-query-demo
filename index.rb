require 'sinatra'
require 'sinatra/cross_origin'
require 'mongoid'
require './models'

configure do
  enable :cross_origin
end

get '/customers' do
  if (params[:skip])
    CustomerData
      .skip(params[:skip].to_i)
      .limit(params[:count].to_i)
      .to_json(except: :_id)
  else
    CustomerData.all.to_json(except: :_id)
  end
end

get '/customers/:customer_id' do
  begin
    CustomerData
      .where(customer_id: params[:customer_id].to_i)
      .first
      .to_json(except: :_id)
  rescue Mongoid::Errors::DocumentNotFound
    nil
  end
end


get '/customers/:customer_id/address' do
  begin
    AddressData
      .where(customer_id: params[:customer_id].to_i)
      .first
      .to_json(except: :_id)
  rescue Mongoid::Errors::DocumentNotFound
    nil
  end
end


get '/customers/:customer_id/accounts' do
  begin
    accounts = BankAccountData.where(customer_id: params[:customer_id].to_i)
    accounts = accounts.skip(params[:skip].to_i).limit(params[:count].to_i) if(params[:skip])
    accounts.all.to_json(except: :_id)
  rescue Mongoid::Errors::DocumentNotFound
    nil
  end
end

get '/customers/:customer_id/accounts/:account_id' do
  begin
    BankAccountData
      .where(customer_id: params[:customer_id].to_i,
             account_id: params[:account_id].to_i)
      .first
      .to_json(except: :_id)
  rescue Mongoid::Errors::DocumentNotFound
    nil
  end
end
