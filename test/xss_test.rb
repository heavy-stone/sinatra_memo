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
      'test-uuid-1' => {
        'public_id' => 'test-uuid-1',
        'title' => '<script>alert(\'タイトル\')</script>',
        'content' => '<script>alert(\'内容\')</script>'
      }
    }
    write_memos(memos)
  end

  def test_index
    get '/memos'
    assert last_response.status, 200
    assert_includes last_response.body, '&lt;script&gt;alert(&#39;タイトル&#39;)&lt;/script&gt;'
    assert_includes last_response.body, '追加'
  end

  def test_show
    get '/memos/test-uuid-1'
    assert last_response.status, 200
    assert_includes last_response.body, '&lt;script&gt;alert(&#39;タイトル&#39;)&lt;/script&gt;'
    assert_includes last_response.body, '&lt;script&gt;alert(&#39;内容&#39;)&lt;/script&gt;'
    assert_includes last_response.body, '変更'
    assert_includes last_response.body, '削除'
  end

  def test_edit
    get '/memos/test-uuid-1/edit'
    assert_includes last_response.body, '<script>alert(\'タイトル\')</script>'
    assert_includes last_response.body, '<script>alert(\'内容\')</script>'
    assert_includes last_response.body, '変更'
  end
end
