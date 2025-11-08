-- ファントムリード検証用のテーブルセットアップ

-- 既存のテーブルを削除
DROP TABLE IF EXISTS ufo_sightings;

-- UFO目撃情報テーブル
CREATE TABLE ufo_sightings (
    id SERIAL PRIMARY KEY,
    sighting_date DATE,
    location VARCHAR(100),
    shape VARCHAR(50), -- 'disk', 'cigar', 'triangle', 'sphere', 'unknown'
    color VARCHAR(50),
    duration_minutes INT,
    witness_count INT,
    credibility_score DECIMAL(3, 2) -- 0.00 to 1.00
);

-- 初期データ: 円盤型(disk)の目撃情報が3件
INSERT INTO ufo_sightings (sighting_date, location, shape, color, duration_minutes, witness_count, credibility_score) VALUES
    ('2024-01-15', 'Roswell, New Mexico', 'disk', 'silver', 5, 3, 0.75),
    ('2024-02-03', 'Area 51, Nevada', 'disk', 'metallic', 12, 7, 0.82),
    ('2024-03-22', 'Phoenix, Arizona', 'disk', 'glowing-white', 8, 2, 0.65),
    ('2024-01-28', 'Seattle, Washington', 'triangle', 'black', 3, 1, 0.45),
    ('2024-02-14', 'Portland, Oregon', 'cigar', 'orange', 15, 5, 0.78),
    ('2024-03-10', 'Austin, Texas', 'sphere', 'blue', 20, 12, 0.88);

-- 確認
SELECT * FROM ufo_sightings ORDER BY shape, sighting_date;
