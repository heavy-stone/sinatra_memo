# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader' if development?
require 'json'
require 'securerandom'

get '/memos' do
  @memos = read_memos

  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  memos = read_memos
  public_id = SecureRandom.uuid
  memos[public_id] = { public_id:, title: params[:title], content: params[:content] }
  write_memos(memos)

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
  memos = read_memos
  memos[params[:public_id]] = params.slice(:public_id, :title, :content)
  write_memos(memos)

  redirect "/memos/#{params[:public_id]}"
end

delete '/memos/:public_id' do
  memos = read_memos
  memos.delete(params[:public_id])
  write_memos(memos)

  redirect '/memos'
end

not_found do
  '404 Not Found のページです'
end

def read_memos
  File.open(db_path) do |file|
    JSON.parse(file.read)
  end
end

def find_memo(public_id)
  memos = read_memos
  memos[public_id] or not_found
end

def write_memos(memos)
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

init_db_file if $PROGRAM_NAME == __FILE__
