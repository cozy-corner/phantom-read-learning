# ファントムリード検証: 主キー検索での0行→1行パターン

## 検証の目的
主キーによる特定の行の検索（WHERE id = 999）でも、0行→1行のファントムリードが発生するかを確認する。

## 実験シナリオ
まだ存在しないID（999）を検索する。
最初は0件だが、別のトランザクションがそのIDでINSERTすることで1件になる。

## 実行手順

### ステップ1: ターミナル1を開いてPostgreSQLに接続
```bash
docker exec -it phantom-read-postgres psql -U postgres -d phantom_read_db
```

```sql
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- ステップ1: 存在しないID 999を検索（0件のはず）
SELECT * FROM ufo_sightings WHERE id = 999;
```

**結果:** 0行（空の結果）

### ステップ2: ターミナル2を開いてPostgreSQLに接続
```bash
docker exec -it phantom-read-postgres psql -U postgres -d phantom_read_db
```

```sql
BEGIN;

-- ID 999の新しいUFO目撃情報を挿入
INSERT INTO ufo_sightings (id, sighting_date, location, shape, color, duration_minutes, witness_count, credibility_score)
VALUES (999, '2024-06-01', 'New York, New York', 'disk', 'silver', 30, 20, 0.95);

COMMIT;
```

### ステップ3: ターミナル1で同じクエリを再実行
```sql
-- 同じ検索条件で再度問い合わせ
SELECT * FROM ufo_sightings WHERE id = 999;
```

**予想:** 1行が返される（ファントムリード発生）

```sql
COMMIT;
```

## 検証ポイント
主キー検索は「特定の1行」を取得するクエリだが、0行→1行の遷移は起きる。
したがって、主キー検索でもファントムリードは発生しうる。

## クリーンアップ
```sql
DELETE FROM ufo_sightings WHERE id = 999;
```
