# frozen_string_literal: true

require 'minitest/autorun'
require 'rack/test'
require_relative 'constants'
require_relative '../memo'

class XssTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    File.delete(TEST_DB_PATH) if File.exist?(TEST_DB_PATH)
    memos = {
      "c1e3e3e3-8a66-4fc6-8609-a02f7fe0cf96": {
        "public_id": 'c1e3e3e3-8a66-4fc6-8609-a02f7fe0cf96',
        "title": '<script>alert(\'タイトル\')</script>',
        "content": '<script>alert(\'内容\')</script>'
      }
    }
    write_memos(memos)
  end

  def test_index
    get '/memos'
    assert last_response.status, 200
    assert last_response.body.include?('&lt;script&gt;alert(&#39;タイトル&#39;)&lt;/script&gt;')
    assert last_response.body.include?('追加')
  end

  def test_show
    get '/memos/c1e3e3e3-8a66-4fc6-8609-a02f7fe0cf96'
    assert last_response.status, 200
    assert last_response.body.include?('&lt;script&gt;alert(&#39;タイトル&#39;)&lt;/script&gt;')
    assert last_response.body.include?('&lt;script&gt;alert(&#39;内容&#39;)&lt;/script&gt;')
    assert last_response.body.include?('変更')
    assert last_response.body.include?('削除')
  end

  def test_edit
    get '/memos/c1e3e3e3-8a66-4fc6-8609-a02f7fe0cf96/edit'
    assert last_response.body.include?('<script>alert(\'タイトル\')</script>')
    assert last_response.body.include?('<script>alert(\'内容\')</script>')
    assert last_response.body.include?('変更')
  end
end
