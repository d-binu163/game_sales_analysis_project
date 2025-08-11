-- Check for sales referencing non-existent games
SELECT DISTINCT game_id FROM sales
WHERE game_id NOT IN (SELECT game_id FROM games);


-- Check for sales referencing non-existent platforms
SELECT DISTINCT platform_id FROM sales
WHERE platform_id NOT IN (SELECT platform_id FROM platforms);


-- Check for sales referencing non-existent publishers
SELECT DISTINCT publisher_id FROM sales
WHERE publisher_id NOT IN (SELECT publisher_id FROM publishers);



-- Check if there are any duplicate sales
-- First find duplicate keys
WITH duplicates AS (
    SELECT game_id, platform_id, publisher_id
    FROM sales
    GROUP BY game_id, platform_id, publisher_id
    HAVING COUNT(*) > 1
)
-- Then show full data for those keys
SELECT s.*
FROM sales s
JOIN duplicates d
  ON s.game_id = d.game_id
 AND s.platform_id = d.platform_id
 AND s.publisher_id = d.publisher_id
ORDER BY s.game_id, s.platform_id, s.publisher_id;
