# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/stub_any_instance'
require 'rack/test'
require_relative 'constants'
require_relative '../memo'

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
    write_memos_table(memos)
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
        "title": '<script>alert(\'title\')</script>',
        "content": '<script>alert(\'content\')</script>'
      }
    }
    SecureRandom.stub(:uuid, 'c1e3e3e3-8a66-4fc6-8609-a02f7fe0cf96') do
      xss_title = '<script>alert(\'title\')</script>'
      xss_content = '<script>alert(\'content\')</script>'
      post '/memos', { title: xss_title, content: xss_content }
      actual = read_memos_table
      assert_equal expected, actual
      assert last_response.status, 302
    end
  end

  def test_update
    expected = {
      "a90cc4d4-8a66-4fc6-8609-a02f7fe0cf96": {
        "public_id": 'a90cc4d4-8a66-4fc6-8609-a02f7fe0cf96',
        "title": '<script>alert(\'title\')</script>',
        "content": '<script>alert(\'content\')</script>'
      },
      "b716320e-99d4-4050-bbf7-3c9b26a64665": {
        "public_id": 'b716320e-99d4-4050-bbf7-3c9b26a64665',
        "title": 'test b title',
        "content": 'test b content'
      }
    }
    xss_title = '<script>alert(\'title\')</script>'
    xss_content = '<script>alert(\'content\')</script>'
    patch '/memos/a90cc4d4-8a66-4fc6-8609-a02f7fe0cf96', { title: xss_title, content: xss_content }
    actual = read_memos_table
    assert_equal expected, actual
    assert last_response.status, 302
  end
end
