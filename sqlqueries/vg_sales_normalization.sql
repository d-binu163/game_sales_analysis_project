-- Delete the years 2019 and 2020 since they have low amount of collected data.
DELETE FROM raw_video_game_sales
WHERE Year IN (2019, 2020);




-- Create tables that have to be normalized

CREATE TABLE IF NOT EXISTS games (
    game_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    genre TEXT,
    release_year INT,
    CONSTRAINT uq_games UNIQUE (name, genre, release_year) -- Constraint make sure the given values are unique when together
);

CREATE TABLE IF NOT EXISTS platforms (
    platform_id SERIAL PRIMARY KEY,
    platform_name TEXT NOT NULL,
    CONSTRAINT uq_platforms UNIQUE (platform_name)
);


CREATE TABLE IF NOT EXISTS publishers (
    publisher_id SERIAL PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    CONSTRAINT uq_publishers UNIQUE (publisher_name)
);


CREATE TABLE IF NOT EXISTS sales (
    sale_id SERIAL PRIMARY KEY,
    game_id INT REFERENCES games(game_id),
    platform_id INT REFERENCES platforms(platform_id),
    publisher_id INT REFERENCES publishers(publisher_id),
    na_sales NUMERIC(6,2),
    pal_sales NUMERIC(6,2),
    jp_sales NUMERIC(6,2),
    other_sales NUMERIC(6,2),
    global_sales NUMERIC(6,2)
);



-- Insert the data from raw dataset.

INSERT INTO games (name, genre, release_year)
SELECT DISTINCT Name, Genre, Year
FROM raw_video_game_sales
ON CONFLICT ON CONSTRAINT uq_games DO NOTHING;;  -- The constraint is used to check if the values already exist in the table. If so, nothing is done.


INSERT INTO platforms (platform_name)
SELECT DISTINCT Platform
FROM raw_video_game_sales
ON CONFLICT ON CONSTRAINT uq_platforms DO NOTHING;


INSERT INTO publishers (publisher_name)
SELECT DISTINCT Publisher
FROM raw_video_game_sales
ON CONFLICT ON CONSTRAINT uq_publishers DO NOTHING;


INSERT INTO sales (
    game_id, platform_id, publisher_id,
    na_sales, pal_sales, jp_sales, other_sales, global_sales
)
SELECT
    g.game_id,
    p.platform_id,
    pub.publisher_id,
    v.NA_Sales,
    v.PAL_Sales,
    v.JP_Sales,
    v.Other_Sales,
    v.Global_Sales
FROM raw_video_game_sales v
JOIN games g
    ON v.Name = g.name
   AND v.Genre = g.genre
   AND v.Year = g.release_year
JOIN platforms p
    ON v.Platform = p.platform_name
JOIN publishers pub
    ON v.Publisher = pub.publisher_name;
