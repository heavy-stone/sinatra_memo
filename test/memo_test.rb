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
    File.delete(TEST_DB_PATH) if File.exist?(TEST_DB_PATH)
    memos = {
      "a90cc4d4-8a66-4fc6-8609-a02f7fe0cf96": {
        "public_id": 'a90cc4d4-8a66-4fc6-8609-a02f7fe0cf96',
        "title": '買い物リスト',
        "content": 'トマトジュース\nティッシュペーパー'
      },
      "b716320e-99d4-4050-bbf7-3c9b26a64665": {
        "public_id": 'b716320e-99d4-4050-bbf7-3c9b26a64665',
        "title": 'スクラム本',
        "content": 'SCRUM BOOT CAMP\nアジャイルプラクティスガイドブック'
      }
    }
    write_memos(memos)
  end

  def test_index
    get '/memos'
    assert last_response.status, 200
    assert last_response.body.include?('買い物リスト')
    assert last_response.body.include?('スクラム本')
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
    assert last_response.body.include?('スクラム本')
    assert last_response.body.include?('SCRUM BOOT CAMP\nアジャイルプラクティスガイドブック')
    assert last_response.body.include?('変更')
    assert last_response.body.include?('削除')
  end

  def test_edit
    get '/memos/a90cc4d4-8a66-4fc6-8609-a02f7fe0cf96/edit'
    assert last_response.body.include?('買い物リスト')
    assert last_response.body.include?('トマトジュース\nティッシュペーパー')
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
    expected_before = {
      "a90cc4d4-8a66-4fc6-8609-a02f7fe0cf96": {
        "public_id": 'a90cc4d4-8a66-4fc6-8609-a02f7fe0cf96',
        "title": '買い物リスト',
        "content": 'トマトジュース\nティッシュペーパー'
      },
      "b716320e-99d4-4050-bbf7-3c9b26a64665": {
        "public_id": 'b716320e-99d4-4050-bbf7-3c9b26a64665',
        "title": 'スクラム本',
        "content": 'SCRUM BOOT CAMP\nアジャイルプラクティスガイドブック'
      }
    }
    expected_after = {
      "a90cc4d4-8a66-4fc6-8609-a02f7fe0cf96": {
        "public_id": 'a90cc4d4-8a66-4fc6-8609-a02f7fe0cf96',
        "title": '買い物リスト',
        "content": 'トマトジュース\nティッシュペーパー'
      },
      "b716320e-99d4-4050-bbf7-3c9b26a64665": {
        "public_id": 'b716320e-99d4-4050-bbf7-3c9b26a64665',
        "title": 'スクラム本',
        "content": 'SCRUM BOOT CAMP\nアジャイルプラクティスガイドブック'
      },
      "c1e3e3e3-8a66-4fc6-8609-a02f7fe0cf96": {
        "public_id": 'c1e3e3e3-8a66-4fc6-8609-a02f7fe0cf96',
        "title": '紅茶',
        "content": 'アールグレイ\nダージリン'
      }
    }
    assert_equal expected_before, read_memos
    SecureRandom.stub(:uuid, 'c1e3e3e3-8a66-4fc6-8609-a02f7fe0cf96') do
      post '/memos', { title: '紅茶', content: 'アールグレイ\nダージリン' }
      assert_equal expected_after, read_memos
      assert last_response.status, 302
    end
  end

  def test_update
    expected_before = {
      "a90cc4d4-8a66-4fc6-8609-a02f7fe0cf96": {
        "public_id": 'a90cc4d4-8a66-4fc6-8609-a02f7fe0cf96',
        "title": '買い物リスト',
        "content": 'トマトジュース\nティッシュペーパー'
      },
      "b716320e-99d4-4050-bbf7-3c9b26a64665": {
        "public_id": 'b716320e-99d4-4050-bbf7-3c9b26a64665',
        "title": 'スクラム本',
        "content": 'SCRUM BOOT CAMP\nアジャイルプラクティスガイドブック'
      }
    }
    expected_after = {
      "a90cc4d4-8a66-4fc6-8609-a02f7fe0cf96": {
        "public_id": 'a90cc4d4-8a66-4fc6-8609-a02f7fe0cf96',
        "title": '買い物一覧',
        "content": '焼きそばパン\nトマトジュース\nティッシュペーパー'
      },
      "b716320e-99d4-4050-bbf7-3c9b26a64665": {
        "public_id": 'b716320e-99d4-4050-bbf7-3c9b26a64665',
        "title": 'スクラム本',
        "content": 'SCRUM BOOT CAMP\nアジャイルプラクティスガイドブック'
      }
    }
    assert_equal expected_before, read_memos
    patch '/memos/a90cc4d4-8a66-4fc6-8609-a02f7fe0cf96', { title: '買い物一覧', content: '焼きそばパン\nトマトジュース\nティッシュペーパー' }
    assert_equal expected_after, read_memos
    assert last_response.status, 302
  end

  def test_delete
    expected_before = {
      "a90cc4d4-8a66-4fc6-8609-a02f7fe0cf96": {
        "public_id": 'a90cc4d4-8a66-4fc6-8609-a02f7fe0cf96',
        "title": '買い物リスト',
        "content": 'トマトジュース\nティッシュペーパー'
      },
      "b716320e-99d4-4050-bbf7-3c9b26a64665": {
        "public_id": 'b716320e-99d4-4050-bbf7-3c9b26a64665',
        "title": 'スクラム本',
        "content": 'SCRUM BOOT CAMP\nアジャイルプラクティスガイドブック'
      }
    }
    expected_after = {
      "b716320e-99d4-4050-bbf7-3c9b26a64665": {
        "public_id": 'b716320e-99d4-4050-bbf7-3c9b26a64665',
        "title": 'スクラム本',
        "content": 'SCRUM BOOT CAMP\nアジャイルプラクティスガイドブック'
      }
    }
    assert_equal expected_before, read_memos
    delete '/memos/a90cc4d4-8a66-4fc6-8609-a02f7fe0cf96'
    assert_equal expected_after, read_memos
    assert last_response.status, 302
  end
end
