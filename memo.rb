# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'

get '/memos' do
  @memos = read_memos_table

  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  @memos = read_memos_table
  public_id = SecureRandom.uuid
  @memos[public_id] = { public_id:, title: params[:title], content: params[:content] }
  write_memos_table(@memos)

  redirect "/memos/#{public_id}"
  erb :show
end

get '/memos/:public_id' do
  @memo = find_memo(params[:public_id])

  erb :show
end

get '/memos/:public_id/edit' do
  @memo = find_memo(params[:public_id])

  erb :edit
end

patch '/memos/:public_id' do
  @memos = read_memos_table
  @memos[params[:public_id].to_sym] = { public_id: params[:public_id].to_sym, title: params[:title], content: params[:content] }
  write_memos_table(@memos)

  redirect "/memos/#{params[:public_id]}"
  erb :show
end

delete '/memos/:public_id' do
  @memos = read_memos_table
  @memos.delete(params[:public_id].to_sym)
  write_memos_table(@memos)

  redirect '/memos'
  erb :index
end

not_found do
  '404 Not Found のページです'
end

def read_memos_table
  File.open('./db/memos.json') do |file|
    JSON.parse(file.read, symbolize_names: true)
  end
end

def find_memo(public_id)
  memos = read_memos_table
  return not_found if memos[public_id.to_sym].nil?

  memos[public_id.to_sym]
end

def write_memos_table(memos)
  File.open('./db/memos.json', 'w') do |file|
    JSON.dump(memos, file)
  end
end
