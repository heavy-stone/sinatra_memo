# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader' if development?
require 'securerandom'
require 'pg'

preparing_db = PG.connect(dbname: ENV['APP_ENV'] == 'test' ? 'test' : 'development')
preparing_db.type_map_for_results = PG::BasicTypeMapForResults.new preparing_db
preparing_db.type_map_for_queries = PG::BasicTypeMapForQueries.new preparing_db
DB = preparing_db

get '/memos' do
  @memos = read_memos

  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  public_id = SecureRandom.uuid
  memo = { public_id:, title: params[:title], content: params[:content] }
  create_memo(memo)

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
  memo = params.slice(:public_id, :title, :content)
  update_memo(memo)

  redirect "/memos/#{params[:public_id]}"
end

delete '/memos/:public_id' do
  destroy_memo(params[:public_id])

  redirect '/memos'
end

not_found do
  '404 Not Found のページです'
end

def read_memos
  DB.exec('SELECT * FROM memos ORDER BY id')
end

def find_memo(public_id)
  DB.exec_prepared('find_memo', [public_id]).first or not_found
end

def create_memo(memo)
  DB.exec_prepared('create_memo', [memo[:public_id], memo[:title], memo[:content]])
end

def update_memo(memo)
  DB.exec_prepared('update_memo', [memo[:title], memo[:content], memo[:public_id]])
end

def destroy_memo(public_id)
  DB.exec_prepared('destroy_memo', [public_id])
end

def prepare_statements
  DB.prepare('find_memo', 'SELECT * FROM memos WHERE public_id = $1')
  DB.prepare('create_memo', 'INSERT INTO memos (public_id, title, content) VALUES ($1, $2, $3)')
  DB.prepare('update_memo', 'UPDATE memos SET title = $1, content = $2 WHERE public_id = $3')
  DB.prepare('destroy_memo', 'DELETE FROM memos WHERE public_id = $1')
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

prepare_statements
