# ファントムリード検証: DELETEによる1行→0行パターン

## 検証の目的
DELETEによって行が消える場合もファントムリードが発生するかを確認する。
主キー検索で1行→0行のパターンを検証。

## 実験シナリオ
既存のUFO目撃情報（id = 1）を検索する。
最初は1件存在するが、別のトランザクションがDELETEすることで0件になる。

## 実行手順

### ステップ1: ターミナル1を開いてPostgreSQLに接続
```bash
docker exec -it phantom-read-postgres psql -U postgres -d phantom_read_db
```

```sql
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- ステップ1: id = 1を検索（1件のはず）
SELECT * FROM ufo_sightings WHERE id = 1;
```

**結果:** 1行
```
 id | sighting_date |       location      | shape | color  | duration_minutes | witness_count | credibility_score
----+---------------+---------------------+-------+--------+------------------+---------------+-------------------
  1 | 2024-01-15    | Roswell, New Mexico | disk  | silver |                5 |             3 |              0.75
```

### ステップ2: ターミナル2を開いてPostgreSQLに接続
```bash
docker exec -it phantom-read-postgres psql -U postgres -d phantom_read_db
```

```sql
BEGIN;

-- id = 1のUFO目撃情報を削除
DELETE FROM ufo_sightings WHERE id = 1;

COMMIT;
```

### ステップ3: ターミナル1で同じクエリを再実行
```sql
-- 同じ検索条件で再度問い合わせ
SELECT * FROM ufo_sightings WHERE id = 1;
```

**予想:** 0行（ファントムリード発生 - 行が消えた）

```sql
COMMIT;
```

## 観察ポイント
- INSERTで行が出現するのがファントムリードなら、DELETEで行が消えるのもファントムリード
- 「幽霊のように現れる」だけでなく「幽霊のように消える」パターン

## 後片付け
```sql
-- データを元に戻す場合
INSERT INTO ufo_sightings (id, sighting_date, location, shape, color, duration_minutes, witness_count, credibility_score)
VALUES (1, '2024-01-15', 'Roswell, New Mexico', 'disk', 'silver', 5, 3, 0.75);
```

または、初期状態に戻す：
```bash
docker-compose down -v
docker-compose up -d
```
