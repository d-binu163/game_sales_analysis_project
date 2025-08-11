-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_sales_game_id ON sales(game_id);
CREATE INDEX IF NOT EXISTS idx_sales_platform_id ON sales(platform_id);
CREATE INDEX IF NOT EXISTS idx_sales_publisher_id ON sales(publisher_id);

-- Create composite index for when you use all columns together
CREATE INDEX IF NOT EXISTS idx_sales_game_platform_publisher
ON sales (game_id, platform_id, publisher_id);




-- Create new cleaned publisher names column for analysis
ALTER TABLE publishers ADD COLUMN publisher_name_clean TEXT;

UPDATE publishers
SET publisher_name_clean = REGEXP_REPLACE(
    REGEXP_REPLACE(LOWER(TRIM(publisher_name)), '[[:punct:]]', '', 'g'),
    '\s+', ' ', 'g'
);



-- Add another column regional_sum as the sum of all regions to compare with global_sales to check for missing data
ALTER TABLE sales ADD COLUMN regional_sum NUMERIC(6,2);

UPDATE sales
SET regional_sum = COALESCE(na_sales,0) + COALESCE(pal_sales,0) +
                   COALESCE(jp_sales,0) + COALESCE(other_sales,0);



-- Remove duplicate sales from the dataset (Removed the data with the lower global_sales)
DELETE FROM sales s
USING (
    SELECT sale_id,
           ROW_NUMBER() OVER (
               PARTITION BY game_id, platform_id, publisher_id
               ORDER BY global_sales DESC NULLS LAST, sale_id
           ) AS rn
    FROM sales
) ranked
WHERE s.sale_id = ranked.sale_id
  AND ranked.rn > 1;


-- Add Constraint for unique IDs
ALTER TABLE sales ADD CONSTRAINT uq_sales_unique
    UNIQUE (game_id, platform_id, publisher_id);



-- Create a final view to combine all the final cleaned data
CREATE VIEW game_sales_view AS
SELECT 
    g.name AS game_name,
    g.genre,
    g.release_year,
    p.platform_name,
    pub.publisher_name,
    s.na_sales,
    s.pal_sales,
    s.jp_sales,
    s.other_sales,
    s.global_sales
FROM sales s
JOIN games g ON s.game_id = g.game_id
JOIN platforms p ON s.platform_id = p.platform_id
JOIN publishers pub ON s.publisher_id = pub.publisher_id;
