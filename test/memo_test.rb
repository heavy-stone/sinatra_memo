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
    DB.exec('DELETE FROM memos;')
    DB.exec("SELECT SETVAL ('memos_id_seq', 1, false);")
    memo1 = { public_id: 'test-uuid-1', title: '買い物リスト', content: "トマトジュース\nティッシュペーパー" }
    memo2 = { public_id: 'test-uuid-2', title: 'スクラム本', content: "SCRUM BOOT CAMP\nアジャイルプラクティスガイドブック" }
    create_memo(memo1)
    create_memo(memo2)
  end

  def test_index
    get '/memos'
    assert last_response.status, 200
    assert_includes last_response.body, '買い物リスト'
    assert_includes last_response.body, 'スクラム本'
    assert_includes last_response.body, '追加'
  end

  def test_new
    get '/memos/new'
    assert last_response.status, 200
    assert_includes last_response.body, '保存'
  end

  def test_show
    get '/memos/test-uuid-2'
    assert last_response.status, 200
    assert_includes last_response.body, 'スクラム本'
    assert_includes last_response.body, 'SCRUM BOOT CAMP<br>アジャイルプラクティスガイドブック'
    assert_includes last_response.body, '変更'
    assert_includes last_response.body, '削除'
  end

  def test_edit
    get '/memos/test-uuid-1/edit'
    assert_includes last_response.body, '買い物リスト'
    assert_includes last_response.body, "トマトジュース\nティッシュペーパー"
    assert_includes last_response.body, '変更'
  end

  def test_not_found
    get '/'
    assert_includes last_response.body, '404 Not Found のページです'
    get '/memos/aaa'
    get '/not_found'
    assert_includes last_response.body, '404 Not Found のページです'
    get '/memos/aaa/edit'
    assert_includes last_response.body, '404 Not Found のページです'
  end

  def test_create
    expected_before = [
      {
        'id' => 1,
        'public_id' => 'test-uuid-1',
        'title' => '買い物リスト',
        'content' => "トマトジュース\nティッシュペーパー"
      },
      {
        'id' => 2,
        'public_id' => 'test-uuid-2',
        'title' => 'スクラム本',
        'content' => "SCRUM BOOT CAMP\nアジャイルプラクティスガイドブック"
      }
    ]
    expected_after = [
      {
        'id' => 1,
        'public_id' => 'test-uuid-1',
        'title' => '買い物リスト',
        'content' => "トマトジュース\nティッシュペーパー"
      },
      {
        'id' => 2,
        'public_id' => 'test-uuid-2',
        'title' => 'スクラム本',
        'content' => "SCRUM BOOT CAMP\nアジャイルプラクティスガイドブック"
      },
      {
        'id' => 3,
        'public_id' => 'new-uuid',
        'title' => '紅茶',
        'content' => 'アールグレイ\nダージリン'
      }
    ]
    assert_equal expected_before, read_memos.entries
    SecureRandom.stub(:uuid, 'new-uuid') do
      post '/memos', { title: '紅茶', content: 'アールグレイ\nダージリン' }
      assert_equal expected_after, read_memos.entries
      assert last_response.status, 302
    end
  end

  def test_update
    expected_before = [
      {
        'id' => 1,
        'public_id' => 'test-uuid-1',
        'title' => '買い物リスト',
        'content' => "トマトジュース\nティッシュペーパー"
      },
      {
        'id' => 2,
        'public_id' => 'test-uuid-2',
        'title' => 'スクラム本',
        'content' => "SCRUM BOOT CAMP\nアジャイルプラクティスガイドブック"
      }
    ]
    expected_after = [
      {
        'id' => 1,
        'public_id' => 'test-uuid-1',
        'title' => '買い物一覧',
        'content' => "焼きそばパン\nトマトジュース\nティッシュペーパー"
      },
      {
        'id' => 2,
        'public_id' => 'test-uuid-2',
        'title' => 'スクラム本',
        'content' => "SCRUM BOOT CAMP\nアジャイルプラクティスガイドブック"
      }
    ]
    assert_equal expected_before, read_memos.entries
    patch '/memos/test-uuid-1', { title: '買い物一覧', content: "焼きそばパン\nトマトジュース\nティッシュペーパー" }
    assert_equal expected_after, read_memos.entries
    assert last_response.status, 302
  end

  def test_delete
    expected_before = [
      {
        'id' => 1,
        'public_id' => 'test-uuid-1',
        'title' => '買い物リスト',
        'content' => "トマトジュース\nティッシュペーパー"
      },
      {
        'id' => 2,
        'public_id' => 'test-uuid-2',
        'title' => 'スクラム本',
        'content' => "SCRUM BOOT CAMP\nアジャイルプラクティスガイドブック"
      }
    ]
    expected_after = [
      {
        'id' => 2,
        'public_id' => 'test-uuid-2',
        'title' => 'スクラム本',
        'content' => "SCRUM BOOT CAMP\nアジャイルプラクティスガイドブック"
      }
    ]
    assert_equal expected_before, read_memos.entries
    delete '/memos/test-uuid-1'
    assert_equal expected_after, read_memos.entries
    assert last_response.status, 302
  end
end
