# ファントムリードの再現実験

## 目的
「複数行のある集合」に対してINSERTが行われることで、同じクエリを実行しても異なる結果を得る（ファントムリード）を確認する。

## テーマ: UFO目撃情報データベース
円盤型（disk）UFOの目撃情報を検索している間に、別のトランザクションが新しい目撃情報を追加することで、幽霊のように新しいデータが出現する様子を観察します。

## 前提条件
- Dockerがインストールされている
- `docker-compose.yml`と`setup.sql`が準備されている

## セットアップ
```bash
# PostgreSQLコンテナを起動
docker-compose up -d
```

## 実験: READ COMMITTEDレベルでのファントムリード

2つのターミナル（セッション）を開いて、以下の手順を**順番通りに**実行してください。

### ステップ1: トランザクション1を開始（ターミナル1）
```bash
# ターミナル1でPostgreSQLに接続
docker exec -it phantom-read-postgres psql -U postgres -d phantom_read_db
```

```sql
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- 現在の円盤型UFOの目撃情報を確認
SELECT * FROM ufo_sightings WHERE shape = 'disk' ORDER BY sighting_date;
```

**結果:** 3件の目撃情報が返される
```
 id | sighting_date |       location        | shape |     color      | duration_minutes | witness_count | credibility_score
----+---------------+-----------------------+-------+----------------+------------------+---------------+-------------------
  1 | 2024-01-15    | Roswell, New Mexico   | disk  | silver         |                5 |             3 |              0.75
  2 | 2024-02-03    | Area 51, Nevada       | disk  | metallic       |               12 |             7 |              0.82
  3 | 2024-03-22    | Phoenix, Arizona      | disk  | glowing-white  |                8 |             2 |              0.65
```

### ステップ2: トランザクション2で新しいUFO目撃情報を追加（ターミナル2）
```bash
# ターミナル2でPostgreSQLに接続
docker exec -it phantom-read-postgres psql -U postgres -d phantom_read_db
```

```sql
BEGIN;

-- 新しい円盤型UFOの目撃情報を追加
INSERT INTO ufo_sightings (sighting_date, location, shape, color, duration_minutes, witness_count, credibility_score)
VALUES ('2024-04-05', 'Los Angeles, California', 'disk', 'bright-red', 25, 15, 0.91);

COMMIT;
```

### ステップ3: トランザクション1で再度同じクエリを実行（ターミナル1）
```sql
-- 同じ検索条件で再度問い合わせ
SELECT * FROM ufo_sightings WHERE shape = 'disk' ORDER BY sighting_date;
```

**結果:** 4件に増えている（ファントムリードが発生！幽霊UFOが出現！）
```
 id | sighting_date |         location          | shape |     color      | duration_minutes | witness_count | credibility_score
----+---------------+---------------------------+-------+----------------+------------------+---------------+-------------------
  1 | 2024-01-15    | Roswell, New Mexico       | disk  | silver         |                5 |             3 |              0.75
  2 | 2024-02-03    | Area 51, Nevada           | disk  | metallic       |               12 |             7 |              0.82
  3 | 2024-03-22    | Phoenix, Arizona          | disk  | glowing-white  |                8 |             2 |              0.65
  7 | 2024-04-05    | Los Angeles, California   | disk  | bright-red     |               25 |            15 |              0.91  ← 幽霊UFOが出現！
```

### ステップ4: トランザクション1を終了（ターミナル1）
```sql
COMMIT;
```

## 観察結果

### 何が起きたか
1. トランザクション1が最初にクエリを実行した時は**3件**の円盤型UFO目撃情報
2. トランザクション2が新しい目撃情報をINSERTしてCOMMIT
3. トランザクション1が同じクエリを再実行すると**4件**に増えている

### これがファントムリード
- **同じ検索条件**（`WHERE shape = 'disk'`）で問い合わせを実行
- **トランザクション内**で2回実行しているのに**結果が異なる**
- 「複数行のある集合」（円盤型UFOの目撃情報の集まり）に**新しい行が出現**
- まるで幽霊（phantom）UFOのように行が現れるため「ファントムリード」
- UFOの幽霊が出現する現象を観察できた！

### READ COMMITTEDの特性
- 各クエリは**実行時点でコミット済みのデータ**を見る
- トランザクション開始時のスナップショットではない
- そのため、他のトランザクションのCOMMITが即座に見える

## クリーンアップ
```sql
-- データをリセットしたい場合
DELETE FROM ufo_sightings WHERE id > 6;
```

```bash
# コンテナを停止
docker-compose down

# データも削除する場合
docker-compose down -v
```

## 次のステップ
- DELETEによるファントムリード（行が消える）を試す
- REPEATABLE READレベルで同じ実験を行い、ファントムリードが防がれることを確認する
