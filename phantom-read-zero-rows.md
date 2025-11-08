# ファントムリード検証: 0行→1行パターン

## 検証の目的
「複数行のある集合」という表現を文字通り解釈すると、最初のクエリ結果が複数行である必要があるように聞こえる。
しかし、最初のクエリ結果が**0行**の場合でも、INSERTによって行が出現すればファントムリードと呼べるのかを確認する。

## 実験シナリオ
存在しない形状（'unknown'）のUFO目撃情報を検索する。
最初は0件だが、別のトランザクションがINSERTすることで1件になる。

## 実行手順

### ステップ1: ターミナル1を開いてPostgreSQLに接続
```bash
docker exec -it phantom-read-postgres psql -U postgres -d phantom_read_db
```

```sql
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- ステップ1: unknown型UFOを検索（0件のはず）
SELECT * FROM ufo_sightings WHERE shape = 'unknown' ORDER BY sighting_date;
```

**結果:** 0行（空の結果）

### ステップ2: ターミナル2を開いてPostgreSQLに接続
```bash
docker exec -it phantom-read-postgres psql -U postgres -d phantom_read_db
```

```sql
BEGIN;

-- 新しいunknown型UFOを挿入
INSERT INTO ufo_sightings (sighting_date, location, shape, color, duration_minutes, witness_count, credibility_score)
VALUES ('2024-05-01', 'Denver, Colorado', 'unknown', 'flickering', 2, 1, 0.30);

COMMIT;
```

### ステップ3: ターミナル1で同じクエリを再実行
```sql
-- 同じ検索条件で再度問い合わせ
SELECT * FROM ufo_sightings WHERE shape = 'unknown' ORDER BY sighting_date;
```

**結果:** 1行（ファントムリード発生！0行→1行）
```
 id | sighting_date |      location       | shape   |    color    | duration_minutes | witness_count | credibility_score
----+---------------+---------------------+---------+-------------+------------------+---------------+-------------------
  7 | 2024-05-01    | Denver, Colorado    | unknown | flickering  |                2 |             1 |              0.30
```

```sql
COMMIT;
```

## 実験結果

**✓ 確認できた:** READ COMMITTEDレベルでは、0行→1行のパターンでもファントムリードが発生する。

### 観察
- 最初のクエリ結果が0行の場合でも、ファントムリードは発生する
- 「複数行のある集合」は、WHERE句で定義される条件にマッチする**行の集合**を指す
- この集合は、0行、1行、複数行のいずれの状態も取りうる
- ファントムリードは、この集合のメンバーシップが変化する現象

## クリーンアップ
```sql
DELETE FROM ufo_sightings WHERE shape = 'unknown';
```
