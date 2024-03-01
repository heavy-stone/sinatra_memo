# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'

get '/memos' do
  read_memos_table

  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  read_memos_table
  public_id = SecureRandom.uuid
  @memos[public_id] = { public_id:, title: params[:title], content: params[:content] }
  write_memos_table

  redirect "/memos/#{public_id}"
  erb :show
end

get '/memos/:public_id' do
  read_memos_table
  @memo = @memos[params[:public_id].to_sym]

  erb :show
end

get '/memos/:public_id/edit' do
  read_memos_table
  @memo = @memos[params[:public_id].to_sym]

  erb :edit
end

patch '/memos/:public_id' do
  read_memos_table
  @memos[params[:public_id].to_sym] = { public_id: params[:public_id].to_sym, title: params[:title], content: params[:content] }
  write_memos_table

  redirect "/memos/#{params[:public_id]}"
  erb :show
end

delete '/memos/:public_id' do
  read_memos_table
  @memos.delete(params[:public_id].to_sym)
  write_memos_table

  redirect '/memos'
  erb :index
end

def read_memos_table
  File.open('./db/memos.json') do |file|
    @memos = JSON.parse(file.read, symbolize_names: true)
  end
end

def write_memos_table
  File.open('./db/memos.json', 'w') do |file|
    JSON.dump(@memos, file)
  end
end
