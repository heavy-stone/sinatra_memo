# frozen_string_literal: true

ENV['APP_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/stub_any_instance'
require 'rack/test'
require_relative '../memo'

DB_PATH_METHOD = :db_path
TEST_DB_PATH = './db/memos_test.json'

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
    self.class.stub_any_instance(DB_PATH_METHOD, TEST_DB_PATH) do
      write_memos_table(memos)
    end
  end

  def test_index
    app.stub_any_instance(DB_PATH_METHOD, TEST_DB_PATH) do
      get '/memos'
      assert last_response.ok?
      assert last_response.body.include?('test a title')
      assert last_response.body.include?('test b title')
      assert last_response.body.include?('追加')
    end
  end

  def test_new
    app.stub_any_instance(DB_PATH_METHOD, TEST_DB_PATH) do
      get '/memos/new', name: 'Frank'
      assert last_response.status, 200
      assert last_response.body.include?('保存')
    end
  end

  def test_show
    app.stub_any_instance(DB_PATH_METHOD, TEST_DB_PATH) do
      get '/memos/b716320e-99d4-4050-bbf7-3c9b26a64665'
      assert last_response.status, 200
      assert last_response.body.include?('test b title')
      assert last_response.body.include?('test b content')
      assert last_response.body.include?('変更')
      assert last_response.body.include?('削除')
    end
  end

  def test_edit
    app.stub_any_instance(DB_PATH_METHOD, TEST_DB_PATH) do
      get '/memos/a90cc4d4-8a66-4fc6-8609-a02f7fe0cf96/edit'
      assert last_response.body.include?('test a title')
      assert last_response.body.include?('test a content')
      assert last_response.body.include?('変更')
    end
  end

  def test_not_found
    app.stub_any_instance(DB_PATH_METHOD, TEST_DB_PATH) do
      get '/'
      assert last_response.body.include?('404 Not Found のページです')
      get '/memos/aaa'
      get '/not_found'
      assert last_response.body.include?('404 Not Found のページです')
      get '/memos/aaa/edit'
      assert last_response.body.include?('404 Not Found のページです')
    end
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
    app.stub_any_instance(DB_PATH_METHOD, TEST_DB_PATH) do
      SecureRandom.stub(:uuid, 'c1e3e3e3-8a66-4fc6-8609-a02f7fe0cf96') do
        post '/memos', { title: 'test c title', content: 'test c content' }
        self.class.stub_any_instance(DB_PATH_METHOD, TEST_DB_PATH) do
          actual = read_memos_table
          assert_equal expected, actual
          assert last_response.status, 302
        end
      end
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
    app.stub_any_instance(DB_PATH_METHOD, TEST_DB_PATH) do
      patch '/memos/a90cc4d4-8a66-4fc6-8609-a02f7fe0cf96', { title: 'updated test a title', content: 'updated test a content' }
      self.class.stub_any_instance(DB_PATH_METHOD, TEST_DB_PATH) do
        actual = read_memos_table
        assert_equal expected, actual
        assert last_response.status, 302
      end
    end
  end

  def test_delete
    expected = {
      "b716320e-99d4-4050-bbf7-3c9b26a64665": {
        "public_id": 'b716320e-99d4-4050-bbf7-3c9b26a64665',
        "title": 'test b title',
        "content": 'test b content'
      }
    }
    app.stub_any_instance(DB_PATH_METHOD, TEST_DB_PATH) do
      delete '/memos/a90cc4d4-8a66-4fc6-8609-a02f7fe0cf96'
      self.class.stub_any_instance(DB_PATH_METHOD, TEST_DB_PATH) do
        actual = read_memos_table
        assert_equal expected, actual
        assert last_response.status, 302
      end
    end
  end
end
