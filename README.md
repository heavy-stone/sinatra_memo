# sinatra_memo
Sinatraで作成したシンプルなメモアプリ

# インストール
## git clone
リポジトリをクローンし、プロジェクトディレクトリに入り、memoブランチに切り替える
```
$ git clone https://github.com/heavy-stone/sinatra_memo.git
$ cd sinatra_memo
$ git checkout memo
```
## gemインストール
Bundlerで必要なgemをインストールする
```
$ bundle install
```

## データベースの初期設定
PostgreSQLのデータベースを作成してテーブルとインデックスを作成する
データベースを作成する
```
$ createdb development
```
データベースに接続する
```
$ psql -d development
```
テーブルを作成する
```
development=# CREATE TABLE memos
(
  id SERIAL NOT NULL,
  public_id VARCHAR(255) NOT NULL,
  title VARCHAR(255),
  content TEXT,
  PRIMARY KEY (id)
);
```
インデックスを作成する
```
development=# CREATE INDEX index_public_id ON memos(public_id);
```
テーブルとインデックスの作成を確認する
```
development=# \d memos
```
問題なければデータベースから抜ける
```
development=# exit
```

## アプリの起動と確認
Sinatraアプリを起動する
```
$ bundle exec ruby memo.rb
```
http://localhost:4567/memos にアクセスして動作を確認する

# ツールの実行方法
## Rubocop
Rubocopの実行方法
```
$ rubocop
```
## ERB Lint
ERB Lintの実行方法
```
$ bundle exec erblint --lint-all
```
## テスト
テスト用のデータベースを作成してテーブルとインデックスを作成する
データベースを作成する
```
$ createdb test
```
データベースに接続する
```
$ psql -d test
```
テーブルを作成する
```
test=# CREATE TABLE memos
(
  id SERIAL NOT NULL,
  public_id VARCHAR(255) NOT NULL,
  title VARCHAR(255),
  content TEXT,
  PRIMARY KEY (id)
);
```
インデックスを作成する
```
test=# CREATE INDEX index_public_id ON memos(public_id);
```
テーブルとインデックスの作成を確認する
```
test=# \d memos
```
問題なければデータベースから抜ける
```
test=# exit
```
テストの実行方法
```
$ bundle exec rake # 一括テスト
$ bundle exec ruby test/memo_test.rb # ファイル毎のテスト
$ bundle exec ruby test/memo_test.rb -n test_index # testメソッド毎のテスト
```
