# PostgreSQLファントムリード学習プロジェクト

## 概要
PostgreSQLのトランザクション分離レベルにおける「ファントムリード」現象を実際に再現して理解するためのプロジェクトです。

## ファントムリードとは
トランザクションが、複数行のある集合を返す検索条件で問い合わせを再実行した時、別のトランザクションがコミットしてしまったために、同じ検索条件で問い合わせを実行しても異なる結果を得てしまう現象。

詳細は `phantom-read-explanation.md` を参照してください。

## ファイル構成
- `README.md` - このファイル
- `phantom-read-explanation.md` - ファントムリードの概念説明
- `docker-compose.yml` - PostgreSQL環境のDocker設定
- `setup.sql` - データベーススキーマとサンプルデータ
- `phantom-read-demo.md` - 実験手順の詳細説明
- `transaction1.sql` - トランザクション1のSQL（観察側）
- `transaction2.sql` - トランザクション2のSQL（挿入側）

## セットアップと実行

### 1. PostgreSQLコンテナを起動
```bash
docker-compose up -d
```

### 2. ファントムリードの再現

**ターミナル1を開く:**
```bash
docker exec -it phantom-read-postgres psql -U postgres -d phantom_read_db
```

**ターミナル2を開く:**
```bash
docker exec -it phantom-read-postgres psql -U postgres -d phantom_read_db
```

**実行順序:**
1. ターミナル1で以下を実行:
   ```sql
   \i transaction1.sql
   ```
   ステップ1が完了したら一時停止

2. ターミナル2で以下を実行:
   ```sql
   \i transaction2.sql
   ```

3. ターミナル1で残りを実行（ENTERを押して続行）

詳細な手順は `phantom-read-demo.md` を参照してください。

## 接続情報
- ホスト: localhost
- ポート: 15432
- データベース: phantom_read_db
- ユーザー: postgres
- パスワード: postgres

## クリーンアップ
```bash
# コンテナを停止・削除
docker-compose down

# データも削除する場合
docker-compose down -v
```

## 学習のポイント

### 「複数行のある集合」の理解
- `WHERE shape = 'disk'` という検索条件にマッチする**行の集まり**
- 単一の行ではなく、条件を満たす**複数行のセット**（円盤型UFO目撃情報の集合）
- この集合に幽霊UFOのように**行が出現・消失**する

### READ COMMITTEDの動作
- 各クエリは実行時点でコミット済みのデータを見る
- トランザクション開始時のスナップショットではない
- そのため、ファントムリードが発生する

### なぜUFOデータを使うのか
- 「幽霊（phantom）」という概念とUFOの神秘的なイメージが一致
- データベースの学習を楽しく、記憶に残りやすくする

## 次のステップ
- [ ] DELETEによるファントムリード（行が消える）を試す
- [ ] REPEATABLE READレベルで同じ実験を行う
- [ ] COUNT(*)を使った集計でのファントムリードを確認
- [ ] SERIALIZABLEレベルでの動作を確認

## 参考文献
- [PostgreSQL 9.4 ドキュメント - トランザクションの分離](https://www.postgresql.jp/docs/9.4/transaction-iso.html)
