# frozen_string_literal: true

ENV['APP_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/stub_any_instance'
require 'rack/test'
require_relative '../memo'

DB_PATH_METHOD = :db_path
TEST_DB_PATH = './db/memos_test.json'

class XssTest < Minitest::Test
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
        "title": '&lt;script&gt;alert(&#39;title&#39;)&lt;/script&gt;',
        "content": '&lt;script&gt;alert(&#39;content&#39;)&lt;/script&gt;'
      }
    }
    app.stub_any_instance(DB_PATH_METHOD, TEST_DB_PATH) do
      SecureRandom.stub(:uuid, 'c1e3e3e3-8a66-4fc6-8609-a02f7fe0cf96') do
        xss_title = '<script>alert(\'title\')</script>'
        xss_content = '<script>alert(\'content\')</script>'
        post '/memos', { title: xss_title, content: xss_content }
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
        "title": '&lt;script&gt;alert(&#39;title&#39;)&lt;/script&gt;',
        "content": '&lt;script&gt;alert(&#39;content&#39;)&lt;/script&gt;'
      },
      "b716320e-99d4-4050-bbf7-3c9b26a64665": {
        "public_id": 'b716320e-99d4-4050-bbf7-3c9b26a64665',
        "title": 'test b title',
        "content": 'test b content'
      }
    }
    app.stub_any_instance(DB_PATH_METHOD, TEST_DB_PATH) do
      xss_title = '<script>alert(\'title\')</script>'
      xss_content = '<script>alert(\'content\')</script>'
      patch '/memos/a90cc4d4-8a66-4fc6-8609-a02f7fe0cf96', { title: xss_title, content: xss_content }
      self.class.stub_any_instance(DB_PATH_METHOD, TEST_DB_PATH) do
        actual = read_memos_table
        assert_equal expected, actual
        assert last_response.status, 302
      end
    end
  end
end
