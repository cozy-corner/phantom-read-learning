# ファントムリード検証: 1行→2行パターン

## 検証の目的
「複数行のある集合」という表現を文字通り解釈すると、最初のクエリ結果が複数行である必要があるように聞こえる。
しかし、最初のクエリ結果が**1行**の場合でも、INSERTによって行が増えればファントムリードと呼べるのかを確認する。

## 実験シナリオ
triangle型のUFO目撃情報を検索する。
最初は1件だが、別のトランザクションがINSERTすることで2件になる。

## 実行手順

### ステップ1: ターミナル1を開いてPostgreSQLに接続
```bash
docker exec -it phantom-read-postgres psql -U postgres -d phantom_read_db
```

```sql
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- ステップ1: triangle型UFOを検索（1件のはず）
SELECT * FROM ufo_sightings WHERE shape = 'triangle' ORDER BY sighting_date;
```

**結果:** 1行
```
 id | sighting_date |       location      | shape    | color | duration_minutes | witness_count | credibility_score
----+---------------+---------------------+----------+-------+------------------+---------------+-------------------
  4 | 2024-01-28    | Seattle, Washington | triangle | black |                3 |             1 |              0.45
```

### ステップ2: ターミナル2を開いてPostgreSQLに接続
```bash
docker exec -it phantom-read-postgres psql -U postgres -d phantom_read_db
```

```sql
BEGIN;

-- 新しいtriangle型UFOを挿入
INSERT INTO ufo_sightings (sighting_date, location, shape, color, duration_minutes, witness_count, credibility_score)
VALUES ('2024-05-15', 'Chicago, Illinois', 'triangle', 'dark-gray', 10, 4, 0.67);

COMMIT;
```

### ステップ3: ターミナル1で同じクエリを再実行
```sql
-- 同じ検索条件で再度問い合わせ
SELECT * FROM ufo_sightings WHERE shape = 'triangle' ORDER BY sighting_date;
```

**結果:** 2行（ファントムリード発生！1行→2行）
```
 id | sighting_date |       location      | shape    |   color   | duration_minutes | witness_count | credibility_score
----+---------------+---------------------+----------+-----------+------------------+---------------+-------------------
  4 | 2024-01-28    | Seattle, Washington | triangle | black     |                3 |             1 |              0.45
  7 | 2024-05-15    | Chicago, Illinois   | triangle | dark-gray |               10 |             4 |              0.67
```

```sql
COMMIT;
```

## 実験結果

**✓ 確認できた:** READ COMMITTEDレベルでは、1行→2行のパターンでもファントムリードが発生する。

### 観察
- 最初のクエリ結果が1行の場合でも、ファントムリードは発生する
- 0行→1行、1行→2行、3行→4行のいずれのパターンでも同じ現象が起きる
- 「複数行のある集合」は、結果の行数に関わらず、WHERE句で定義される行の集合を指す

## クリーンアップ
```sql
DELETE FROM ufo_sightings WHERE id > 6;
```
