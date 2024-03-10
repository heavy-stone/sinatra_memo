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
  @memos[params[:public_id].to_sym] = { public_id: params[:public_id], title: params[:title], content: params[:content] }
  write_memos_table(@memos)

  redirect "/memos/#{params[:public_id]}"
end

delete '/memos/:public_id' do
  @memos = read_memos_table
  @memos.delete(params[:public_id].to_sym)
  write_memos_table(@memos)

  redirect '/memos'
end

not_found do
  '404 Not Found のページです'
end

def read_memos_table
  init_db_file
  File.open(db_path) do |file|
    JSON.parse(file.read, symbolize_names: true)
  end
end

def find_memo(public_id)
  memos = read_memos_table
  memo = memos[public_id.to_sym]
  return not_found if memo.nil?

  memo
end

def write_memos_table(memos)
  init_db_file
  File.open(db_path, 'w') do |file|
    JSON.dump(memos, file)
  end
end

def db_path
  db_file = ENV['APP_ENV'] == 'test' ? 'memos_test.json' : 'memos.json'
  "./db/#{db_file}"
end

def init_db_file
  return if File.exist?(db_path)

  File.open(db_path, 'w') do |file|
    JSON.dump({}, file)
  end
end

helpers do
  def nl2br(str)
    str.gsub(/\R/, '<br>')
  end

  def h(str)
    CGI.escapeHTML(str)
  end

  def simple_format(str)
    nl2br(h(str))
  end
end
