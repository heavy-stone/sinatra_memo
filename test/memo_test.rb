# frozen_string_literal: true

require 'minitest/autorun'
require 'rack/test'
require_relative 'constants'
require_relative '../memo'

class MemoTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    File.exist?('./db/memos_test.json') && File.delete('./db/memos_test.json')
    memos = {
      "a90cc4d4-8a66-4fc6-8609-a02f7fe0cf96": {
        "public_id": 'a90cc4d4-8a66-4fc6-8609-a02f7fe0cf96',
        "title": 'test a title',
        "content": 'test a content'
      },
      "b716320e-99d4-4050-bbf7-3c9b26a64665": {
        "public_id": 'b716320e-99d4-4050-bbf7-3c9b26a64665',
        "title": 'test b title',
        "content": 'test b content'
      }
    }
    write_memos_table(memos)
  end

  def test_index
    get '/memos'
    assert last_response.ok?
    assert last_response.body.include?('test a title')
    assert last_response.body.include?('test b title')
    assert last_response.body.include?('追加')
  end

  def test_new
    get '/memos/new', name: 'Frank'
    assert last_response.status, 200
    assert last_response.body.include?('保存')
  end

  def test_show
    get '/memos/b716320e-99d4-4050-bbf7-3c9b26a64665'
    assert last_response.status, 200
    assert last_response.body.include?('test b title')
    assert last_response.body.include?('test b content')
    assert last_response.body.include?('変更')
    assert last_response.body.include?('削除')
  end

  def test_edit
    get '/memos/a90cc4d4-8a66-4fc6-8609-a02f7fe0cf96/edit'
    assert last_response.body.include?('test a title')
    assert last_response.body.include?('test a content')
    assert last_response.body.include?('変更')
  end

  def test_not_found
    get '/'
    assert last_response.body.include?('404 Not Found のページです')
    get '/memos/aaa'
    get '/not_found'
    assert last_response.body.include?('404 Not Found のページです')
    get '/memos/aaa/edit'
    assert last_response.body.include?('404 Not Found のページです')
  end

  def test_create
    expected = {
      "a90cc4d4-8a66-4fc6-8609-a02f7fe0cf96": {
        "public_id": 'a90cc4d4-8a66-4fc6-8609-a02f7fe0cf96',
        "title": 'test a title',
        "content": 'test a content'
      },
      "b716320e-99d4-4050-bbf7-3c9b26a64665": {
        "public_id": 'b716320e-99d4-4050-bbf7-3c9b26a64665',
        "title": 'test b title',
        "content": 'test b content'
      },
      "c1e3e3e3-8a66-4fc6-8609-a02f7fe0cf96": {
        "public_id": 'c1e3e3e3-8a66-4fc6-8609-a02f7fe0cf96',
        "title": 'test c title',
        "content": 'test c content'
      }
    }
    SecureRandom.stub(:uuid, 'c1e3e3e3-8a66-4fc6-8609-a02f7fe0cf96') do
      post '/memos', { title: 'test c title', content: 'test c content' }
      actual = read_memos_table
      assert_equal expected, actual
      assert last_response.status, 302
    end
  end

  def test_update
    expected = {
      "a90cc4d4-8a66-4fc6-8609-a02f7fe0cf96": {
        "public_id": 'a90cc4d4-8a66-4fc6-8609-a02f7fe0cf96',
        "title": 'updated test a title',
        "content": 'updated test a content'
      },
      "b716320e-99d4-4050-bbf7-3c9b26a64665": {
        "public_id": 'b716320e-99d4-4050-bbf7-3c9b26a64665',
        "title": 'test b title',
        "content": 'test b content'
      }
    }
    patch '/memos/a90cc4d4-8a66-4fc6-8609-a02f7fe0cf96', { title: 'updated test a title', content: 'updated test a content' }
    actual = read_memos_table
    assert_equal expected, actual
    assert last_response.status, 302
  end

  def test_delete
    expected = {
      "b716320e-99d4-4050-bbf7-3c9b26a64665": {
        "public_id": 'b716320e-99d4-4050-bbf7-3c9b26a64665',
        "title": 'test b title',
        "content": 'test b content'
      }
    }
    delete '/memos/a90cc4d4-8a66-4fc6-8609-a02f7fe0cf96'
    actual = read_memos_table
    assert_equal expected, actual
    assert last_response.status, 302
  end
end
