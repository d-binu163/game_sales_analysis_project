-- Create table to import csv file

CREATE TABLE IF NOT EXISTS raw_video_game_sales (
    Name TEXT,
    Platform TEXT,
    Publisher TEXT,
    Critic_Score NUMERIC(3,1),
    User_Score NUMERIC(3,1),
    NA_Sales NUMERIC(6,2),
    PAL_Sales NUMERIC(6,2),
    JP_Sales NUMERIC(6,2),
    Other_Sales NUMERIC(6,2),
    Global_Sales NUMERIC(6,2),
    Year INT,
    Genre TEXT
);

-- Manually import data into dataset after creating table.
-- Run the next file afterwards