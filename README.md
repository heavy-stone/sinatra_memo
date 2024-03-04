# sinatra_memo
Sinatraで作成したシンプルなメモアプリ

# インストール
リポジトリをクローンし、プロジェクトディレクトリに入り、memoブランチに切り替える
```
$ git clone https://github.com/heavy-stone/sinatra_memo.git
$ cd sinatra_memo
$ git checkout memo
```
Bundlerで必要なgemをインストールする
```
$ bundle install
```
Sinatraアプリを起動する
```
$ bundle exec ruby memo.rb
```
http://localhost:4567/memos にアクセスして動作を確認する

# ツールの実行方法
rubocopの実行方法
```
$ rubocop
```
ERB Lintの実行方法
```
$ bundle exec erblint --lint-all
```
テストの実行方法
```
$ rake # 一括テスト
$ bundle exec ruby test/memo_test.rb # ファイル毎のテスト
$ bundle exec ruby test/memo_test.rb -n test_index # testメソッド毎のテスト
```
