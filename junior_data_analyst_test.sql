
--- SQL Data Normalization with CTE's and creating a view of the 5 tables combined,
--- there were many transformations neeeded for each table, but none could alter the orginal table,
--- therefore the use of CTE's before finnaly creating a view.

------ **** IMPORTANT: At the foot of this file you will find the queries used to create the
------				   tables and populate them with the dummy data provided.

CREATE VIEW results_table AS
	WITH max_dates AS (
    SELECT ad_id, MAX(date) as max_date
    FROM table_3
    GROUP BY ad_id
), ad_name_table AS (
    SELECT
    t3.ad_id,
    t3.final_url,
    CONCAT(t3.headline1, ' | ', t3.headline2, ' | ', t3.headline3) AS ad_name,
    t3.date
    FROM table_3 t3 JOIN max_dates md ON t3.ad_id = md.ad_id AND t3.date = md.max_date
), table_1_cte AS (
    SELECT 
    MIN(table_1.date) AS campaign_start_date,
    MAX(table_1.date) AS campaign_end_date
    FROM table_1
), table_1_full AS (
    SELECT
    table_1.date,
    'Platform 1' AS provider,
    'channel 1' AS network,
    table_1.account_id,
    SUBSTRING_INDEX(SUBSTRING_INDEX(table_1.campaign_name, '_CN|', -1), '_BR|', 1) AS campaign_name_short,
    table_1_cte.campaign_start_date,
    table_1_cte.campaign_end_date,
    SUBSTRING_INDEX(SUBSTRING_INDEX(table_1.campaign_name, '_BR|', -1), '_FF|', 1) AS brand,
    SUBSTRING_INDEX(SUBSTRING_INDEX(table_1.campaign_name, '_FF|', -1), '_CN|', 1) AS free_field,
    table_1.adset_name,
    table_1.ad_id,
    SUBSTRING_INDEX(SUBSTRING_INDEX(table_1.adset_name, ' | ', 1), ' | ', -1) AS adset_group,
    table_1.ad_type,
    table_1.device,
    table_1.spend,
    table_1.clicks,
    table_1.imps,
    table_1.conversions
    FROM table_1 INNER JOIN table_1_cte
), cte_1 AS(
    SELECT
    table_1_full.date,
    table_1_full.provider,
    table_1_full.network,
    table_1_full.account_id,
    table_1_full.campaign_name_short,
    table_1_full.campaign_start_date,
    table_1_full.campaign_end_date,
    table_1_full.brand,
    table_1_full.adset_name,
    table_1_full.ad_id,
    table_1_full.free_field,
    table_1_full.adset_group,
    ad_name_table.ad_name,
    SUBSTRING_INDEX(SUBSTRING_INDEX(ad_name_table.final_url, 'https://', -1), '/', 1) as display_path,
    table_1_full.ad_type,
    table_1_full.device,
    table_1_full.spend,
    table_1_full.clicks,
    table_1_full.imps as impressions,
    table_1_full.conversions
    FROM table_1_full LEFT JOIN ad_name_table ON table_1_full.ad_id = ad_name_table.ad_id
), table_4_date AS (
    SELECT
    DISTINCT table_4.ad_id,
    table_4.headline1,
    table_4.headline2,
    table_2.date,
    table_4.account_id,
    table_4.campaign_id,
    table_4.text,
    table_4.destination_url
    FROM table_4 LEFT JOIN table_2 ON table_4.ad_id = table_2.ad_id ORDER BY table_2.date
), max_dates_2 AS (
    SELECT 
    t4d.ad_id,
    MAX(t4d.date) AS max_date
    FROM table_4_date AS t4d
    GROUP BY ad_id
), ad_name_table_2 AS (
    SELECT
    t4d.ad_id,
    t4d.destination_url,
    CONCAT(t4d.headline1, ' | ', t4d.headline2) AS ad_name,
    t4d.date
FROM table_4_date AS t4d INNER JOIN max_dates_2 AS md2 ON t4d.ad_id = md2.ad_id AND t4d.date = md2.max_date
), table_2_cte AS (
    SELECT 
    MIN(table_2.date) AS campaign_start_date,
    MAX(table_2.date) AS campaign_end_date
    FROM table_2
), table_2_full AS (
    SELECT
    table_2.date,
    'Platform 2' AS provider,
    'channel 2' AS network,
    table_2.account_id,
    SUBSTRING_INDEX(SUBSTRING_INDEX(table_2.campaign_name, '_CN|', -1), '_BR|', 1) AS campaign_name_short,
    table_2_cte.campaign_start_date,
    table_2_cte.campaign_end_date,
    SUBSTRING_INDEX(SUBSTRING_INDEX(table_2.campaign_name, '_BR|', -1), '_FF|', 1) AS brand,
    SUBSTRING_INDEX(SUBSTRING_INDEX(table_2.campaign_name, '_FF|', -1), '_CN|', 1) AS free_field,
    table_2.adset_name,
    SUBSTRING_INDEX(SUBSTRING_INDEX(table_2.adset_name, ' | ', 1), ' | ', -1) AS adset_group,
    table_2.ad_id,
    table_2.ad_type,
    table_2.device,
    table_2.spend,
    table_2.clicks,
    table_2.imps,
    table_2.conversions
    FROM table_2 INNER JOIN table_2_cte
), cte_2 AS (
    SELECT
    t2f.date,
    t2f.provider,
    t2f.network,
    t2f.account_id,
    t2f.campaign_name_short,
    t2f.campaign_start_date,
    t2f.campaign_end_date,
    t2f.brand,
    t2f.adset_name,
    t2f.free_field,
    ad_name_table_2.ad_name,
    SUBSTRING_INDEX(SUBSTRING_INDEX(ad_name_table_2.destination_url, 'https://', -1), '/', 1) as display_path,
    t2f.adset_group,
    t2f.ad_type,
    t2f.device,
    t2f.spend,
    t2f.clicks,
    t2f.imps as impressions,
    t2f.conversions
    FROM table_2_full AS t2f LEFT JOIN ad_name_table_2 ON t2f.ad_id = ad_name_table_2.ad_id
), union_1 AS (
	SELECT 
	ut.date, 
	ut.provider, 
	ut.network,
	ut.account_id,
	ut.campaign_name_short, 
	ut.campaign_start_date,
	ut.campaign_end_date,
	ut.brand,
	ut.free_field,
	ut.adset_name,
	ut.adset_group,
	ut.ad_name,
	ut.display_path,
	ut.ad_type,
	ut.device,
	SUM(ut.spend) as spend, 
	SUM(ut.clicks) as clicks, 
	SUM(ut.impressions) as impressions, 
	SUM(ut.conversions) as conversions, 
	SUM(table_5.sessions) as sessions, 
	SUM(table_5.users) as users, 
	SUM(table_5.new_users) as new_users, 
	SUM(table_5.page_views) as page_views
	FROM cte_1 AS ut
	LEFT JOIN table_5
	ON ut.date = table_5.date
	AND ut.provider = table_5.utm_source
	AND LOWER(ut.campaign_name_short) = table_5.campaign
	GROUP BY 
	ut.date, 
	ut.provider, 
	ut.network,
	ut.account_id,
	ut.campaign_name_short, 
	ut.campaign_start_date,
	ut.campaign_end_date,
	ut.brand,
	ut.free_field,
	ut.adset_name,
	ut.adset_group,
	ut.ad_name,
	ut.display_path,
	ut.ad_type,
	ut.device
	ORDER BY ut.date
) , union_2 AS (
	SELECT 
	ut.date, 
	ut.provider, 
	ut.network,
	ut.account_id,
	ut.campaign_name_short, 
	ut.campaign_start_date,
	ut.campaign_end_date,
	ut.brand,
	ut.free_field,
	ut.adset_name,
	ut.adset_group,
	ut.ad_name,
	ut.display_path,
	ut.ad_type,
	ut.device,
	SUM(ut.spend) as spend, 
	SUM(ut.clicks) as clicks, 
	SUM(ut.impressions) as impressions, 
	SUM(ut.conversions) as conversions, 
	SUM(table_5.sessions) as sessions, 
	SUM(table_5.users) as users, 
	SUM(table_5.new_users) as new_users, 
	SUM(table_5.page_views) as page_views
	FROM cte_2 AS ut
	LEFT JOIN table_5
	ON ut.date = table_5.date
	AND ut.provider = table_5.utm_source
	AND LOWER(ut.campaign_name_short) = table_5.campaign
	GROUP BY 
	ut.date, 
	ut.provider, 
	ut.network,
	ut.account_id,
	ut.campaign_name_short, 
	ut.campaign_start_date,
	ut.campaign_end_date,
	ut.brand,
	ut.free_field,
	ut.adset_name,
	ut.adset_group,
	ut.ad_name,
	ut.display_path,
	ut.ad_type,
	ut.device
	ORDER BY ut.date
) SELECT * FROM union_1 UNION SELECT * FROM union_2;

SELECT * FROM `results_table`;



---
---
---
---



--- QUERIES TO CREATE TABLES AND POPULATE WITH DATA:



--1

CREATE TABLE table_1 (
  date DATE,
  account_id VARCHAR(255),
  campaign_id VARCHAR(255),
  campaign_name VARCHAR(255),
  adset_id VARCHAR(255),
  adset_name VARCHAR(255),
  ad_id VARCHAR(255),
  ad_name VARCHAR(255),
  ad_type VARCHAR(255),
  device VARCHAR(255),
  spend DECIMAL(10,2),
  clicks INTEGER,
  imps INTEGER,
  conversions INTEGER
);
INSERT INTO table_1 VALUES ('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','WdqrRfjE6OxPxhj8FaTOVw==','Broad | adset 1','hciXX5R5KeNA8r24eZze1A==',NULL,'Expanded text ad','Mobile devices with full browsers',13.09,1,197,2),
	('2021-10-03 00:00:00','DLH2GuJt0uJopHspKxKPmg==','5sBpEPxhFpM3r9YFp+jRMw==','_CN|FIRESHOW_BR|FIRE_FF|WALLMART','VTsjn6S0H+TyElwtpL4mpQ==','Broad | adset 2','jIs3JOubI4GY5TAFE/iqmg==',NULL,'Expanded text ad','Mobile devices with full browsers',7.78,1,183,0),
	('2021-10-03 00:00:00','DLH2GuJt0uJopHspKxKPmg==','5sBpEPxhFpM3r9YFp+jRMw==','_CN|FIRESHOW_BR|FIRE_FF|WALLMART','apL4KKdaexR4N+/her73pg==','Broad | adset 3','VOrY2Y6ZrWgLe2fQ2ngU7Q==',NULL,'Expanded text ad','Mobile devices with full browsers',11.87,1,186,1),
	('2021-10-03 00:00:00','mAm0RQx8X+Ik8LZcWCrRGw==','w6OZRofbxqN+dRzQXdBZyA==','_CN|CINEMA_BR|DOLBY_FF|WALLMART','34yhys44D78+unwde0GDpQ==','adset 4','QHlgnt4yUYebup82hgSBOQ==',NULL,'Expanded text ad','Mobile devices with full browsers',13.87,1,232,0),
	('2021-10-03 00:00:00','mAm0RQx8X+Ik8LZcWCrRGw==','w6OZRofbxqN+dRzQXdBZyA==','_CN|CINEMA_BR|DOLBY_FF|WALLMART','34yhys44D78+unwde0GDpQ==','adset 4','QHlgnt4yUYebup82hgSBOQ==',NULL,'Expanded text ad','Mobile devices with full browsers',14.06,1,299,0),
	('2021-10-03 00:00:00','mAm0RQx8X+Ik8LZcWCrRGw==','w6OZRofbxqN+dRzQXdBZyA==','_CN|CINEMA_BR|DOLBY_FF|WALLMART','HnkqcqBSCSIuRuNgFQ+c3A==','adset 5','eT0XqEP6O+VscwdAPJDWCg==',NULL,'Expanded text ad','Mobile devices with full browsers',40.82,3,18,1),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','WdqrRfjE6OxPxhj8FaTOVw==','Broad | adset 1','XO++0deJgsVjEYvgp3kmqg==',NULL,'Expanded text ad','Mobile devices with full browsers',0,7,148,0),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','WdqrRfjE6OxPxhj8FaTOVw==','Broad | adset 1','XO++0deJgsVjEYvgp3kmqg==',NULL,'Expanded text ad','Mobile devices with full browsers',0,8,89,2),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','WdqrRfjE6OxPxhj8FaTOVw==','Broad | adset 1','8029qFKKNE0U6woeCgajig==',NULL,'Expanded text ad','Mobile devices with full browsers',0,4,205,0),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','WdqrRfjE6OxPxhj8FaTOVw==','Broad | adset 1','hciXX5R5KeNA8r24eZze1A==',NULL,'Expanded text ad','Computers',13,7,133,0),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','WdqrRfjE6OxPxhj8FaTOVw==','Broad | adset 1','hciXX5R5KeNA8r24eZze1A==',NULL,'Expanded text ad','Mobile devices with full browsers',0,4,95,0),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','WdqrRfjE6OxPxhj8FaTOVw==','Broad | adset 1','hciXX5R5KeNA8r24eZze1A==',NULL,'Expanded text ad','Mobile devices with full browsers',15,6,79,1),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','WdqrRfjE6OxPxhj8FaTOVw==','Broad | adset 1','hciXX5R5KeNA8r24eZze1A==',NULL,'Expanded text ad','Tablets with full browsers',0,5,44,1),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','WdqrRfjE6OxPxhj8FaTOVw==','Broad | adset 1','hciXX5R5KeNA8r24eZze1A==',NULL,'Expanded text ad','Tablets with full browsers',0,0,323,0),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','WdqrRfjE6OxPxhj8FaTOVw==','Broad | adset 1','hciXX5R5KeNA8r24eZze1A==',NULL,'Expanded text ad','Mobile devices with full browsers',0,4,210,0),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','WdqrRfjE6OxPxhj8FaTOVw==','Broad | adset 1','hciXX5R5KeNA8r24eZze1A==',NULL,'Expanded text ad','Computers',214,1,150,2),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','WdqrRfjE6OxPxhj8FaTOVw==','Broad | adset 1','hciXX5R5KeNA8r24eZze1A==',NULL,'Expanded text ad','Mobile devices with full browsers',0,0,308,1),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','ZL0YVbSXYLURSDDM6ryBrQ==','Broad | adset 6','MoxRtRI7drqhD3dHXHxGDA==',NULL,'Expanded text ad','Mobile devices with full browsers',0,1,100,2),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','ZL0YVbSXYLURSDDM6ryBrQ==','Broad | adset 6','fK2TcdDvP9KaOrlB3WtGOQ==',NULL,'Expanded text ad','Mobile devices with full browsers',24,0,97,2),
	('2021-10-03 00:00:00','DLH2GuJt0uJopHspKxKPmg==','5sBpEPxhFpM3r9YFp+jRMw==','_CN|FIRESHOW_BR|FIRE_FF|WALLMART','VTsjn6S0H+TyElwtpL4mpQ==','Broad | adset 2','HQVHkCT1YtqrektOPewIpQ==',NULL,'Expanded text ad','Computers',9,6,23,1),
	('2021-10-03 00:00:00','DLH2GuJt0uJopHspKxKPmg==','5sBpEPxhFpM3r9YFp+jRMw==','_CN|FIRESHOW_BR|FIRE_FF|WALLMART','VTsjn6S0H+TyElwtpL4mpQ==','Broad | adset 2','HQVHkCT1YtqrektOPewIpQ==',NULL,'Expanded text ad','Mobile devices with full browsers',7,7,290,1),
	('2021-10-03 00:00:00','DLH2GuJt0uJopHspKxKPmg==','5sBpEPxhFpM3r9YFp+jRMw==','_CN|FIRESHOW_BR|FIRE_FF|WALLMART','apL4KKdaexR4N+/her73pg==','Broad | adset 3','sn6vGvGsZHTo9GDs/2JAZg==',NULL,'Expanded text ad','Computers',25,5,150,0),
	('2021-10-03 00:00:00','DLH2GuJt0uJopHspKxKPmg==','5sBpEPxhFpM3r9YFp+jRMw==','_CN|FIRESHOW_BR|FIRE_FF|WALLMART','apL4KKdaexR4N+/her73pg==','Broad | adset 3','VOrY2Y6ZrWgLe2fQ2ngU7Q==',NULL,'Expanded text ad','Mobile devices with full browsers',1,4,340,2),
	('2021-10-03 00:00:00','mAm0RQx8X+Ik8LZcWCrRGw==','w6OZRofbxqN+dRzQXdBZyA==','_CN|CINEMA_BR|DOLBY_FF|WALLMART','34yhys44D78+unwde0GDpQ==','adset 4','QHlgnt4yUYebup82hgSBOQ==',NULL,'Expanded text ad','Tablets with full browsers',10,7,40,2),
	('2021-10-03 00:00:00','mAm0RQx8X+Ik8LZcWCrRGw==','w6OZRofbxqN+dRzQXdBZyA==','_CN|CINEMA_BR|DOLBY_FF|WALLMART','34yhys44D78+unwde0GDpQ==','adset 4','QHlgnt4yUYebup82hgSBOQ==',NULL,'Expanded text ad','Mobile devices with full browsers',17,0,94,0),
	('2021-10-03 00:00:00','mAm0RQx8X+Ik8LZcWCrRGw==','w6OZRofbxqN+dRzQXdBZyA==','_CN|CINEMA_BR|DOLBY_FF|WALLMART','HnkqcqBSCSIuRuNgFQ+c3A==','adset 5','eT0XqEP6O+VscwdAPJDWCg==',NULL,'Expanded text ad','Mobile devices with full browsers',79,2,132,0),
	('2021-10-03 00:00:00','mAm0RQx8X+Ik8LZcWCrRGw==','w6OZRofbxqN+dRzQXdBZyA==','_CN|CINEMA_BR|DOLBY_FF|WALLMART','HnkqcqBSCSIuRuNgFQ+c3A==','adset 5','eT0XqEP6O+VscwdAPJDWCg==',NULL,'Expanded text ad','Mobile devices with full browsers',72,2,274,0),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','WdqrRfjE6OxPxhj8FaTOVw==','Broad | adset 1','8029qFKKNE0U6woeCgajig==',NULL,'Expanded text ad','Mobile devices with full browsers',9.38,1,115,1),
	('2021-10-02 00:00:00','DLH2GuJt0uJopHspKxKPmg==','5sBpEPxhFpM3r9YFp+jRMw==','_CN|FIRESHOW_BR|FIRE_FF|WALLMART','VTsjn6S0H+TyElwtpL4mpQ==','Broad | adset 2','HQVHkCT1YtqrektOPewIpQ==',NULL,'Expanded text ad','Mobile devices with full browsers',5.83,1,200,0),
	('2021-10-02 00:00:00','DLH2GuJt0uJopHspKxKPmg==','5sBpEPxhFpM3r9YFp+jRMw==','_CN|FIRESHOW_BR|FIRE_FF|WALLMART','apL4KKdaexR4N+/her73pg==','Broad | adset 3','VOrY2Y6ZrWgLe2fQ2ngU7Q==',NULL,'Expanded text ad','Mobile devices with full browsers',11.71,1,85,1),
	('2021-10-02 00:00:00','mAm0RQx8X+Ik8LZcWCrRGw==','w6OZRofbxqN+dRzQXdBZyA==','_CN|CINEMA_BR|DOLBY_FF|WALLMART','34yhys44D78+unwde0GDpQ==','adset 4','QHlgnt4yUYebup82hgSBOQ==',NULL,'Expanded text ad','Mobile devices with full browsers',18.32,1,131,2),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','WdqrRfjE6OxPxhj8FaTOVw==','Broad | adset 1','XO++0deJgsVjEYvgp3kmqg==',NULL,'Expanded text ad','Mobile devices with full browsers',23,4,285,1),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','WdqrRfjE6OxPxhj8FaTOVw==','Broad | adset 1','8029qFKKNE0U6woeCgajig==',NULL,'Expanded text ad','Mobile devices with full browsers',84,6,343,1),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','WdqrRfjE6OxPxhj8FaTOVw==','Broad | adset 1','8029qFKKNE0U6woeCgajig==',NULL,'Expanded text ad','Mobile devices with full browsers',75,8,263,2),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','WdqrRfjE6OxPxhj8FaTOVw==','Broad | adset 1','8029qFKKNE0U6woeCgajig==',NULL,'Expanded text ad','Mobile devices with full browsers',79,3,283,2),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','WdqrRfjE6OxPxhj8FaTOVw==','Broad | adset 1','hciXX5R5KeNA8r24eZze1A==',NULL,'Expanded text ad','Mobile devices with full browsers',90,2,323,1),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','WdqrRfjE6OxPxhj8FaTOVw==','Broad | adset 1','hciXX5R5KeNA8r24eZze1A==',NULL,'Expanded text ad','Mobile devices with full browsers',41,2,135,2),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','WdqrRfjE6OxPxhj8FaTOVw==','Broad | adset 1','hciXX5R5KeNA8r24eZze1A==',NULL,'Expanded text ad','Mobile devices with full browsers',59,8,326,1),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','WdqrRfjE6OxPxhj8FaTOVw==','Broad | adset 1','hciXX5R5KeNA8r24eZze1A==',NULL,'Expanded text ad','Mobile devices with full browsers',9,2,109,2),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','WdqrRfjE6OxPxhj8FaTOVw==','Broad | adset 1','hciXX5R5KeNA8r24eZze1A==',NULL,'Expanded text ad','Tablets with full browsers',87,3,166,0),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','WdqrRfjE6OxPxhj8FaTOVw==','Broad | adset 1','hciXX5R5KeNA8r24eZze1A==',NULL,'Expanded text ad','Computers',13,6,135,2),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','WdqrRfjE6OxPxhj8FaTOVw==','Broad | adset 1','hciXX5R5KeNA8r24eZze1A==',NULL,'Expanded text ad','Mobile devices with full browsers',70,1,292,2),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','WdqrRfjE6OxPxhj8FaTOVw==','Broad | adset 1','hciXX5R5KeNA8r24eZze1A==',NULL,'Expanded text ad','Mobile devices with full browsers',0,1,78,2),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','ZL0YVbSXYLURSDDM6ryBrQ==','Broad | adset 6','sXUrZmYCIh0n1jZ0pvBpPQ==',NULL,'Expanded text ad','Computers',24,7,205,2),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','ZL0YVbSXYLURSDDM6ryBrQ==','Broad | adset 6','MoxRtRI7drqhD3dHXHxGDA==',NULL,'Expanded text ad','Mobile devices with full browsers',0,8,261,2),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','ZL0YVbSXYLURSDDM6ryBrQ==','Broad | adset 6','MoxRtRI7drqhD3dHXHxGDA==',NULL,'Expanded text ad','Mobile devices with full browsers',0,0,329,0),
	('2021-10-02 00:00:00','DLH2GuJt0uJopHspKxKPmg==','5sBpEPxhFpM3r9YFp+jRMw==','_CN|FIRESHOW_BR|FIRE_FF|WALLMART','VTsjn6S0H+TyElwtpL4mpQ==','Broad | adset 2','HQVHkCT1YtqrektOPewIpQ==',NULL,'Expanded text ad','Computers',0,4,118,1),
	('2021-10-02 00:00:00','DLH2GuJt0uJopHspKxKPmg==','5sBpEPxhFpM3r9YFp+jRMw==','_CN|FIRESHOW_BR|FIRE_FF|WALLMART','VTsjn6S0H+TyElwtpL4mpQ==','Broad | adset 2','jIs3JOubI4GY5TAFE/iqmg==',NULL,'Expanded text ad','Mobile devices with full browsers',0,1,83,2),
	('2021-10-02 00:00:00','DLH2GuJt0uJopHspKxKPmg==','5sBpEPxhFpM3r9YFp+jRMw==','_CN|FIRESHOW_BR|FIRE_FF|WALLMART','apL4KKdaexR4N+/her73pg==','Broad | adset 3','sn6vGvGsZHTo9GDs/2JAZg==',NULL,'Expanded text ad','Mobile devices with full browsers',64,2,317,2),
	('2021-10-02 00:00:00','DLH2GuJt0uJopHspKxKPmg==','5sBpEPxhFpM3r9YFp+jRMw==','_CN|FIRESHOW_BR|FIRE_FF|WALLMART','apL4KKdaexR4N+/her73pg==','Broad | adset 3','VOrY2Y6ZrWgLe2fQ2ngU7Q==',NULL,'Expanded text ad','Mobile devices with full browsers',72,0,268,1),
	('2021-10-02 00:00:00','mAm0RQx8X+Ik8LZcWCrRGw==','w6OZRofbxqN+dRzQXdBZyA==','_CN|CINEMA_BR|DOLBY_FF|WALLMART','34yhys44D78+unwde0GDpQ==','adset 4','QHlgnt4yUYebup82hgSBOQ==',NULL,'Expanded text ad','Mobile devices with full browsers',71,2,11,0),
	('2021-10-02 00:00:00','mAm0RQx8X+Ik8LZcWCrRGw==','w6OZRofbxqN+dRzQXdBZyA==','_CN|CINEMA_BR|DOLBY_FF|WALLMART','34yhys44D78+unwde0GDpQ==','adset 4','QHlgnt4yUYebup82hgSBOQ==',NULL,'Expanded text ad','Mobile devices with full browsers',7,3,219,2),
	('2021-10-02 00:00:00','mAm0RQx8X+Ik8LZcWCrRGw==','w6OZRofbxqN+dRzQXdBZyA==','_CN|CINEMA_BR|DOLBY_FF|WALLMART','34yhys44D78+unwde0GDpQ==','adset 4','QHlgnt4yUYebup82hgSBOQ==',NULL,'Expanded text ad','Mobile devices with full browsers',54,6,35,1),
	('2021-10-02 00:00:00','mAm0RQx8X+Ik8LZcWCrRGw==','w6OZRofbxqN+dRzQXdBZyA==','_CN|CINEMA_BR|DOLBY_FF|WALLMART','HnkqcqBSCSIuRuNgFQ+c3A==','adset 5','eT0XqEP6O+VscwdAPJDWCg==',NULL,'Expanded text ad','Mobile devices with full browsers',34,7,226,0),
	('2021-10-02 00:00:00','mAm0RQx8X+Ik8LZcWCrRGw==','w6OZRofbxqN+dRzQXdBZyA==','_CN|CINEMA_BR|DOLBY_FF|WALLMART','HnkqcqBSCSIuRuNgFQ+c3A==','adset 5','eT0XqEP6O+VscwdAPJDWCg==',NULL,'Expanded text ad','Mobile devices with full browsers',84,0,198,1),
	('2021-10-02 00:00:00','mAm0RQx8X+Ik8LZcWCrRGw==','w6OZRofbxqN+dRzQXdBZyA==','_CN|CINEMA_BR|DOLBY_FF|WALLMART','HnkqcqBSCSIuRuNgFQ+c3A==','adset 5','eT0XqEP6O+VscwdAPJDWCg==',NULL,'Expanded text ad','Mobile devices with full browsers',12,3,202,1),
	('2021-10-01 00:00:00','mAm0RQx8X+Ik8LZcWCrRGw==','w6OZRofbxqN+dRzQXdBZyA==','_CN|CINEMA_BR|DOLBY_FF|WALLMART','34yhys44D78+unwde0GDpQ==','adset 4','QHlgnt4yUYebup82hgSBOQ==',NULL,'Expanded text ad','Mobile devices with full browsers',11.79,1,64,2),
	('2021-10-01 00:00:00','mAm0RQx8X+Ik8LZcWCrRGw==','w6OZRofbxqN+dRzQXdBZyA==','_CN|CINEMA_BR|DOLBY_FF|WALLMART','HnkqcqBSCSIuRuNgFQ+c3A==','adset 5','eT0XqEP6O+VscwdAPJDWCg==',NULL,'Expanded text ad','Mobile devices with full browsers',18.2,1,311,2),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','WdqrRfjE6OxPxhj8FaTOVw==','Broad | adset 1','8029qFKKNE0U6woeCgajig==',NULL,'Expanded text ad','Mobile devices with full browsers',35,0,55,0),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','WdqrRfjE6OxPxhj8FaTOVw==','Broad | adset 1','8029qFKKNE0U6woeCgajig==',NULL,'Expanded text ad','Computers',7,1,334,1),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','WdqrRfjE6OxPxhj8FaTOVw==','Broad | adset 1','hciXX5R5KeNA8r24eZze1A==',NULL,'Expanded text ad','Mobile devices with full browsers',24,3,51,2),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','WdqrRfjE6OxPxhj8FaTOVw==','Broad | adset 1','hciXX5R5KeNA8r24eZze1A==',NULL,'Expanded text ad','Computers',60,2,232,0),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','WdqrRfjE6OxPxhj8FaTOVw==','Broad | adset 1','hciXX5R5KeNA8r24eZze1A==',NULL,'Expanded text ad','Mobile devices with full browsers',14,2,204,1),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','WdqrRfjE6OxPxhj8FaTOVw==','Broad | adset 1','hciXX5R5KeNA8r24eZze1A==',NULL,'Expanded text ad','Mobile devices with full browsers',16,4,244,1),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','WdqrRfjE6OxPxhj8FaTOVw==','Broad | adset 1','hciXX5R5KeNA8r24eZze1A==',NULL,'Expanded text ad','Computers',46,6,41,2),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','WdqrRfjE6OxPxhj8FaTOVw==','Broad | adset 1','hciXX5R5KeNA8r24eZze1A==',NULL,'Expanded text ad','Mobile devices with full browsers',24,0,258,0),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','WdqrRfjE6OxPxhj8FaTOVw==','Broad | adset 1','hciXX5R5KeNA8r24eZze1A==',NULL,'Expanded text ad','Tablets with full browsers',13,7,62,2),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','ZL0YVbSXYLURSDDM6ryBrQ==','Broad | adset 6','sXUrZmYCIh0n1jZ0pvBpPQ==',NULL,'Expanded text ad','Mobile devices with full browsers',23,0,121,2),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','ZL0YVbSXYLURSDDM6ryBrQ==','Broad | adset 6','MoxRtRI7drqhD3dHXHxGDA==',NULL,'Expanded text ad','Computers',35,2,154,0),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','_CN|STRANGEADVENTURE_BR|EXPEDITION_FF|WALLMART','ZL0YVbSXYLURSDDM6ryBrQ==','Broad | adset 6','fK2TcdDvP9KaOrlB3WtGOQ==',NULL,'Expanded text ad','Computers',0,2,307,0),
	('2021-10-01 00:00:00','DLH2GuJt0uJopHspKxKPmg==','5sBpEPxhFpM3r9YFp+jRMw==','_CN|FIRESHOW_BR|FIRE_FF|WALLMART','VTsjn6S0H+TyElwtpL4mpQ==','Broad | adset 2','HQVHkCT1YtqrektOPewIpQ==',NULL,'Expanded text ad','Mobile devices with full browsers',0,5,166,2),
	('2021-10-01 00:00:00','DLH2GuJt0uJopHspKxKPmg==','5sBpEPxhFpM3r9YFp+jRMw==','_CN|FIRESHOW_BR|FIRE_FF|WALLMART','VTsjn6S0H+TyElwtpL4mpQ==','Broad | adset 2','HQVHkCT1YtqrektOPewIpQ==',NULL,'Expanded text ad','Computers',76,5,73,2),
	('2021-10-01 00:00:00','DLH2GuJt0uJopHspKxKPmg==','5sBpEPxhFpM3r9YFp+jRMw==','_CN|FIRESHOW_BR|FIRE_FF|WALLMART','VTsjn6S0H+TyElwtpL4mpQ==','Broad | adset 2','jIs3JOubI4GY5TAFE/iqmg==',NULL,'Expanded text ad','Mobile devices with full browsers',0,5,97,0),
	('2021-10-01 00:00:00','DLH2GuJt0uJopHspKxKPmg==','5sBpEPxhFpM3r9YFp+jRMw==','_CN|FIRESHOW_BR|FIRE_FF|WALLMART','apL4KKdaexR4N+/her73pg==','Broad | adset 3','sn6vGvGsZHTo9GDs/2JAZg==',NULL,'Expanded text ad','Mobile devices with full browsers',0,3,23,0),
	('2021-10-01 00:00:00','DLH2GuJt0uJopHspKxKPmg==','5sBpEPxhFpM3r9YFp+jRMw==','_CN|FIRESHOW_BR|FIRE_FF|WALLMART','apL4KKdaexR4N+/her73pg==','Broad | adset 3','VOrY2Y6ZrWgLe2fQ2ngU7Q==',NULL,'Expanded text ad','Mobile devices with full browsers',0,0,291,0),
	('2021-10-01 00:00:00','mAm0RQx8X+Ik8LZcWCrRGw==','w6OZRofbxqN+dRzQXdBZyA==','_CN|CINEMA_BR|DOLBY_FF|WALLMART','34yhys44D78+unwde0GDpQ==','adset 4','QHlgnt4yUYebup82hgSBOQ==',NULL,'Expanded text ad','Mobile devices with full browsers',34,5,30,2),
	('2021-10-01 00:00:00','mAm0RQx8X+Ik8LZcWCrRGw==','w6OZRofbxqN+dRzQXdBZyA==','_CN|CINEMA_BR|DOLBY_FF|WALLMART','34yhys44D78+unwde0GDpQ==','adset 4','QHlgnt4yUYebup82hgSBOQ==',NULL,'Expanded text ad','Mobile devices with full browsers',0,1,60,0),
	('2021-10-01 00:00:00','mAm0RQx8X+Ik8LZcWCrRGw==','w6OZRofbxqN+dRzQXdBZyA==','_CN|CINEMA_BR|DOLBY_FF|WALLMART','34yhys44D78+unwde0GDpQ==','adset 4','QHlgnt4yUYebup82hgSBOQ==',NULL,'Expanded text ad','Mobile devices with full browsers',0,8,334,2),
	('2021-10-01 00:00:00','mAm0RQx8X+Ik8LZcWCrRGw==','w6OZRofbxqN+dRzQXdBZyA==','_CN|CINEMA_BR|DOLBY_FF|WALLMART','HnkqcqBSCSIuRuNgFQ+c3A==','adset 5','eT0XqEP6O+VscwdAPJDWCg==',NULL,'Expanded text ad','Tablets with full browsers',0,5,279,1),
	('2021-10-01 00:00:00','mAm0RQx8X+Ik8LZcWCrRGw==','w6OZRofbxqN+dRzQXdBZyA==','_CN|CINEMA_BR|DOLBY_FF|WALLMART','HnkqcqBSCSIuRuNgFQ+c3A==','adset 5','eT0XqEP6O+VscwdAPJDWCg==',NULL,'Expanded text ad','Mobile devices with full browsers',0,3,119,2),
	('2021-10-01 00:00:00','mAm0RQx8X+Ik8LZcWCrRGw==','w6OZRofbxqN+dRzQXdBZyA==','_CN|CINEMA_BR|DOLBY_FF|WALLMART','HnkqcqBSCSIuRuNgFQ+c3A==','adset 5','eT0XqEP6O+VscwdAPJDWCg==',NULL,'Expanded text ad','Computers',0,5,273,0);

SELECT * FROM table_1; --81 rows


CREATE TABLE table_2 (
    date DATE,
    account_id VARCHAR(255),
    campaign_id VARCHAR(255),
    campaign_name VARCHAR(255),
    adset_id VARCHAR(255),
    adset_name VARCHAR(255),
    ad_id VARCHAR(255),
    ad_type VARCHAR(255),
    device VARCHAR(255),
    spend DECIMAL(10, 2),
    clicks INT,
    imps INT,
    conversions INT
);
INSERT INTO table_2 VALUES ('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','WgdYr5llR6HwSxu/YrR2Gg==','_CN|AMACRM_BR|AMA_FF|WALLMART','5aUmMIQksGGZui1ig/d29A==','Broad Tr | text 1','hkuO+yW3LdbLXvZqR2ZoGg==','Expanded text ad','Mobile devices with full browsers',58.17,1,321,3),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Mobile devices with full browsers',18.41,3,246,0),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Mobile devices with full browsers',75.91,8,269,0),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Mobile devices with full browsers',83.06,9,174,3),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Mobile devices with full browsers',47.34,5,230,1),
	('2021-10-01 00:00:00','DLH2GuJt0uJopHspKxKPmg==','zRRwAzE/dzRIBehvyZL69Q==','_CN|STUDENT_BR|UNIVERSITY_FF|WALLMART','7nm3jfcXpm7aPCoRss7G7A==','Broad Tr | text 5','Ty59S+/w94UtsCgY6KB2pg==','Expanded text ad','Mobile devices with full browsers',31.39,2,186,0),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','WgdYr5llR6HwSxu/YrR2Gg==','_CN|AMACRM_BR|AMA_FF|WALLMART','5aUmMIQksGGZui1ig/d29A==','Broad Tr | text 1','hkuO+yW3LdbLXvZqR2ZoGg==','Expanded text ad','Mobile devices with full browsers',55.00,5,67,1),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','WgdYr5llR6HwSxu/YrR2Gg==','_CN|AMACRM_BR|AMA_FF|WALLMART','5aUmMIQksGGZui1ig/d29A==','Broad Tr | text 1','hkuO+yW3LdbLXvZqR2ZoGg==','Expanded text ad','Mobile devices with full browsers',6.00,2,157,1),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','WgdYr5llR6HwSxu/YrR2Gg==','_CN|AMACRM_BR|AMA_FF|WALLMART','5XiFHJ5g9LD2/hBLYZSAyQ==','Broad Tr | text 3','t3BEZU93Oe7vyvrSCidOAQ==','Expanded text ad','Computers',13.00,1,94,3),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','WgdYr5llR6HwSxu/YrR2Gg==','_CN|AMACRM_BR|AMA_FF|WALLMART','5XiFHJ5g9LD2/hBLYZSAyQ==','Broad Tr | text 3','t3BEZU93Oe7vyvrSCidOAQ==','Expanded text ad','Mobile devices with full browsers',25.00,1,68,3),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','WgdYr5llR6HwSxu/YrR2Gg==','_CN|AMACRM_BR|AMA_FF|WALLMART','5XiFHJ5g9LD2/hBLYZSAyQ==','Broad Tr | text 3','crlBfPCm+Z1/EQAzBqpkrA==','Expanded text ad','Mobile devices with full browsers',69.00,1,223,0),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','1p9+1rIZ7gcDvkZ8bvmkGw==','text 4','zcq+nOHEuvBE8froYA1cvg==','Expanded text ad','Mobile devices with full browsers',86.00,1,321,1),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','1p9+1rIZ7gcDvkZ8bvmkGw==','text 4','zcq+nOHEuvBE8froYA1cvg==','Expanded text ad','Computers',78.00,3,102,3),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','1p9+1rIZ7gcDvkZ8bvmkGw==','text 4','zcq+nOHEuvBE8froYA1cvg==','Expanded text ad','Mobile devices with full browsers',45.00,2,193,2),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','1p9+1rIZ7gcDvkZ8bvmkGw==','text 4','zcq+nOHEuvBE8froYA1cvg==','Expanded text ad','Computers',52.00,0,29,2),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Mobile devices with full browsers',77.00,0,156,2),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Tablets with full browsers',73.00,0,74,3),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Computers',19.00,3,70,1),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Computers',5.00,4,57,2),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Tablets with full browsers',9.00,4,316,2),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Computers',90.00,2,82,0),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Computers',7.00,2,345,2),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Computers',11.00,4,210,2),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Tablets with full browsers',67.00,0,264,2),
	('2021-10-01 00:00:00','DLH2GuJt0uJopHspKxKPmg==','zRRwAzE/dzRIBehvyZL69Q==','_CN|STUDENT_BR|UNIVERSITY_FF|WALLMART','7nm3jfcXpm7aPCoRss7G7A==','Broad Tr | text 5','Ho2WLS1iu63beefdncf2nQ==','Expanded text ad','Tablets with full browsers',3.00,5,67,1),
	('2021-10-01 00:00:00','DLH2GuJt0uJopHspKxKPmg==','zRRwAzE/dzRIBehvyZL69Q==','_CN|STUDENT_BR|UNIVERSITY_FF|WALLMART','7nm3jfcXpm7aPCoRss7G7A==','Broad Tr | text 5','Ho2WLS1iu63beefdncf2nQ==','Expanded text ad','Computers',75.00,0,93,2),
	('2021-10-01 00:00:00','DLH2GuJt0uJopHspKxKPmg==','zRRwAzE/dzRIBehvyZL69Q==','_CN|STUDENT_BR|UNIVERSITY_FF|WALLMART','7nm3jfcXpm7aPCoRss7G7A==','Broad Tr | text 5','Ty59S+/w94UtsCgY6KB2pg==','Expanded text ad','Mobile devices with full browsers',0.00,5,4,3),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','WgdYr5llR6HwSxu/YrR2Gg==','_CN|AMACRM_BR|AMA_FF|WALLMART','5aUmMIQksGGZui1ig/d29A==','Broad Tr | text 1','hkuO+yW3LdbLXvZqR2ZoGg==','Expanded text ad','Tablets with full browsers',57.00,0,106,1),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','WgdYr5llR6HwSxu/YrR2Gg==','_CN|AMACRM_BR|AMA_FF|WALLMART','5aUmMIQksGGZui1ig/d29A==','Broad Tr | text 1','hkuO+yW3LdbLXvZqR2ZoGg==','Expanded text ad','Mobile devices with full browsers',70.12,3,290,0),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Mobile devices with full browsers',80.79,2,327,3),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Mobile devices with full browsers',8.45,2,80,0),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Mobile devices with full browsers',15.53,3,26,1),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Mobile devices with full browsers',62.79,4,242,3),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Mobile devices with full browsers',30.54,5,301,1),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','WgdYr5llR6HwSxu/YrR2Gg==','_CN|AMACRM_BR|AMA_FF|WALLMART','5aUmMIQksGGZui1ig/d29A==','Broad Tr | text 1','wxzDYKZo11WXMR8Kch8YAw==','Expanded text ad','Mobile devices with full browsers',0.00,4,340,0),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','WgdYr5llR6HwSxu/YrR2Gg==','_CN|AMACRM_BR|AMA_FF|WALLMART','5aUmMIQksGGZui1ig/d29A==','Broad Tr | text 1','hkuO+yW3LdbLXvZqR2ZoGg==','Expanded text ad','Mobile devices with full browsers',49.00,1,22,0),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','WgdYr5llR6HwSxu/YrR2Gg==','_CN|AMACRM_BR|AMA_FF|WALLMART','5aUmMIQksGGZui1ig/d29A==','Broad Tr | text 1','hkuO+yW3LdbLXvZqR2ZoGg==','Expanded text ad','Computers',65.00,4,317,0),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','WgdYr5llR6HwSxu/YrR2Gg==','_CN|AMACRM_BR|AMA_FF|WALLMART','5aUmMIQksGGZui1ig/d29A==','Broad Tr | text 1','hkuO+yW3LdbLXvZqR2ZoGg==','Expanded text ad','Computers',24.00,2,296,3),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','WgdYr5llR6HwSxu/YrR2Gg==','_CN|AMACRM_BR|AMA_FF|WALLMART','5XiFHJ5g9LD2/hBLYZSAyQ==','Broad Tr | text 3','t3BEZU93Oe7vyvrSCidOAQ==','Expanded text ad','Mobile devices with full browsers',17.00,1,60,1),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','WgdYr5llR6HwSxu/YrR2Gg==','_CN|AMACRM_BR|AMA_FF|WALLMART','5XiFHJ5g9LD2/hBLYZSAyQ==','Broad Tr | text 3','t3BEZU93Oe7vyvrSCidOAQ==','Expanded text ad','Computers',48.00,0,212,2),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','WgdYr5llR6HwSxu/YrR2Gg==','_CN|AMACRM_BR|AMA_FF|WALLMART','5XiFHJ5g9LD2/hBLYZSAyQ==','Broad Tr | text 3','t3BEZU93Oe7vyvrSCidOAQ==','Expanded text ad','Mobile devices with full browsers',36.00,2,336,0),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','WgdYr5llR6HwSxu/YrR2Gg==','_CN|AMACRM_BR|AMA_FF|WALLMART','5XiFHJ5g9LD2/hBLYZSAyQ==','Broad Tr | text 3','crlBfPCm+Z1/EQAzBqpkrA==','Expanded text ad','Mobile devices with full browsers',71.00,0,123,0),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','WgdYr5llR6HwSxu/YrR2Gg==','_CN|AMACRM_BR|AMA_FF|WALLMART','5XiFHJ5g9LD2/hBLYZSAyQ==','Broad Tr | text 3','crlBfPCm+Z1/EQAzBqpkrA==','Expanded text ad','Computers',8.00,0,64,2),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','1p9+1rIZ7gcDvkZ8bvmkGw==','text 4','zcq+nOHEuvBE8froYA1cvg==','Expanded text ad','Mobile devices with full browsers',63.00,2,223,0),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','1p9+1rIZ7gcDvkZ8bvmkGw==','text 4','zcq+nOHEuvBE8froYA1cvg==','Expanded text ad','Mobile devices with full browsers',55.00,2,302,3),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','1p9+1rIZ7gcDvkZ8bvmkGw==','text 4','zcq+nOHEuvBE8froYA1cvg==','Expanded text ad','Mobile devices with full browsers',74.00,5,38,3),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Computers',44.00,5,132,1),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Tablets with full browsers',39.00,2,283,3),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Tablets with full browsers',6.00,4,332,2),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Computers',5.00,3,232,3),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Computers',11.00,3,282,3),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Computers',41.00,2,143,2),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Tablets with full browsers',42.00,5,273,1),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Tablets with full browsers',17.00,0,51,3),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Computers',45.00,2,320,1),
	('2021-10-02 00:00:00','DLH2GuJt0uJopHspKxKPmg==','zRRwAzE/dzRIBehvyZL69Q==','_CN|STUDENT_BR|UNIVERSITY_FF|WALLMART','7nm3jfcXpm7aPCoRss7G7A==','Broad Tr | text 5','Ho2WLS1iu63beefdncf2nQ==','Expanded text ad','Mobile devices with full browsers',1.00,5,116,3),
	('2021-10-02 00:00:00','DLH2GuJt0uJopHspKxKPmg==','zRRwAzE/dzRIBehvyZL69Q==','_CN|STUDENT_BR|UNIVERSITY_FF|WALLMART','7nm3jfcXpm7aPCoRss7G7A==','Broad Tr | text 5','Ty59S+/w94UtsCgY6KB2pg==','Expanded text ad','Mobile devices with full browsers',23.00,5,261,2),
	('2021-10-02 00:00:00','DLH2GuJt0uJopHspKxKPmg==','zRRwAzE/dzRIBehvyZL69Q==','_CN|STUDENT_BR|UNIVERSITY_FF|WALLMART','7nm3jfcXpm7aPCoRss7G7A==','Broad Tr | text 5','Ty59S+/w94UtsCgY6KB2pg==','Expanded text ad','Mobile devices with full browsers',53.00,5,71,2),
	('2021-10-02 00:00:00','DLH2GuJt0uJopHspKxKPmg==','zRRwAzE/dzRIBehvyZL69Q==','_CN|STUDENT_BR|UNIVERSITY_FF|WALLMART','7nm3jfcXpm7aPCoRss7G7A==','Broad Tr | text 5','Ty59S+/w94UtsCgY6KB2pg==','Expanded text ad','Computers',78.00,0,153,0),
	('2021-10-02 00:00:00','DLH2GuJt0uJopHspKxKPmg==','zRRwAzE/dzRIBehvyZL69Q==','_CN|STUDENT_BR|UNIVERSITY_FF|WALLMART','Zb13hGO/0AhGBYiIa7yvHg==','Broad Tr | text 6','W4EQNCKbJRywJyw3FVroKg==','Expanded text ad','Mobile devices with full browsers',12.00,4,152,2),
	('2021-10-02 00:00:00','DLH2GuJt0uJopHspKxKPmg==','zRRwAzE/dzRIBehvyZL69Q==','_CN|STUDENT_BR|UNIVERSITY_FF|WALLMART','Zb13hGO/0AhGBYiIa7yvHg==','Broad Tr | text 6','Wu3cRoOQSjxQfQdIozxt6Q==','Expanded text ad','Mobile devices with full browsers',0.00,2,11,2),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','WgdYr5llR6HwSxu/YrR2Gg==','_CN|AMACRM_BR|AMA_FF|WALLMART','5aUmMIQksGGZui1ig/d29A==','Broad Tr | text 1','hkuO+yW3LdbLXvZqR2ZoGg==','Expanded text ad','Mobile devices with full browsers',58.68,2,243,1),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','WgdYr5llR6HwSxu/YrR2Gg==','_CN|AMACRM_BR|AMA_FF|WALLMART','5aUmMIQksGGZui1ig/d29A==','Broad Tr | text 1','zwOUkfJe8cNMwq1FB6CJtA==','Expanded text ad','Mobile devices with full browsers',30.06,2,39,0),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Mobile devices with full browsers',45.27,2,136,1),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Mobile devices with full browsers',7.53,0,346,3),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Mobile devices with full browsers',30.23,0,13,1),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Mobile devices with full browsers',34.73,1,318,1),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','WgdYr5llR6HwSxu/YrR2Gg==','_CN|AMACRM_BR|AMA_FF|WALLMART','5aUmMIQksGGZui1ig/d29A==','Broad Tr | text 1','hkuO+yW3LdbLXvZqR2ZoGg==','Expanded text ad','Mobile devices with full browsers',82.00,2,304,0),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','WgdYr5llR6HwSxu/YrR2Gg==','_CN|AMACRM_BR|AMA_FF|WALLMART','5aUmMIQksGGZui1ig/d29A==','Broad Tr | text 1','hkuO+yW3LdbLXvZqR2ZoGg==','Expanded text ad','Mobile devices with full browsers',74.00,2,331,3),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','WgdYr5llR6HwSxu/YrR2Gg==','_CN|AMACRM_BR|AMA_FF|WALLMART','5XiFHJ5g9LD2/hBLYZSAyQ==','Broad Tr | text 3','t3BEZU93Oe7vyvrSCidOAQ==','Expanded text ad','Computers',27.00,4,134,1),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','WgdYr5llR6HwSxu/YrR2Gg==','_CN|AMACRM_BR|AMA_FF|WALLMART','5XiFHJ5g9LD2/hBLYZSAyQ==','Broad Tr | text 3','t3BEZU93Oe7vyvrSCidOAQ==','Expanded text ad','Mobile devices with full browsers',44.00,2,62,2),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','WgdYr5llR6HwSxu/YrR2Gg==','_CN|AMACRM_BR|AMA_FF|WALLMART','5XiFHJ5g9LD2/hBLYZSAyQ==','Broad Tr | text 3','t3BEZU93Oe7vyvrSCidOAQ==','Expanded text ad','Mobile devices with full browsers',47.00,3,68,2),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','WgdYr5llR6HwSxu/YrR2Gg==','_CN|AMACRM_BR|AMA_FF|WALLMART','5XiFHJ5g9LD2/hBLYZSAyQ==','Broad Tr | text 3','t3BEZU93Oe7vyvrSCidOAQ==','Expanded text ad','Computers',19.00,3,0,0),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','1p9+1rIZ7gcDvkZ8bvmkGw==','text 4','zcq+nOHEuvBE8froYA1cvg==','Expanded text ad','Computers',1.00,5,153,2),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','1p9+1rIZ7gcDvkZ8bvmkGw==','text 4','zcq+nOHEuvBE8froYA1cvg==','Expanded text ad','Mobile devices with full browsers',24.00,0,65,0),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Tablets with full browsers',52.00,0,308,3),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Tablets with full browsers',2.00,2,147,2),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Computers',64.00,3,304,3),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Computers',59.00,0,68,3),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Computers',57.00,3,121,3),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Tablets with full browsers',15.00,2,245,2),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Tablets with full browsers',55.00,4,76,2),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Mobile devices with full browsers',10.00,4,187,3),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','_CN|FIGHTER_BR|AMA_FF|SITE','WSWd6aAlECGsa5IDiMDh2g==','text 2','AmrRspIz7ExFVRYh2Uz02A==','Expanded text ad','Computers',46.00,3,349,2),
	('2021-10-03 00:00:00','DLH2GuJt0uJopHspKxKPmg==','zRRwAzE/dzRIBehvyZL69Q==','_CN|STUDENT_BR|UNIVERSITY_FF|WALLMART','7nm3jfcXpm7aPCoRss7G7A==','Broad Tr | text 5','Ho2WLS1iu63beefdncf2nQ==','Expanded text ad','Mobile devices with full browsers',60.00,3,236,3),
	('2021-10-03 00:00:00','DLH2GuJt0uJopHspKxKPmg==','zRRwAzE/dzRIBehvyZL69Q==','_CN|STUDENT_BR|UNIVERSITY_FF|WALLMART','7nm3jfcXpm7aPCoRss7G7A==','Broad Tr | text 5','Ty59S+/w94UtsCgY6KB2pg==','Expanded text ad','Mobile devices with full browsers',0.00,2,14,2);

SELECT * FROM table_2; --86 rows

-- Join keys: date, account_id, campaign_id, adset_id, ad_id.
CREATE TABLE table_3 (
    date DATE,
    account_id VARCHAR(255),
    campaign_id VARCHAR(255),
    adset_id VARCHAR(255),
    ad_id VARCHAR(255),
    headline1 VARCHAR(255),
    headline2 VARCHAR(255),
    headline3 VARCHAR(255),
    description VARCHAR(255),
    final_url VARCHAR(1000),
    path1 VARCHAR(255),
    path2 VARCHAR(255)
);
INSERT INTO table_3 VALUES ('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','WdqrRfjE6OxPxhj8FaTOVw==','XO++0deJgsVjEYvgp3kmqg==','GyklXyqLs+X58idmnipQLA==','nooZCXrrniLjba8brIDdvA==','L2xLfMOQtVfGLNscF2lwlw==','Qw/khFX8t6maQg2CSJgyog==','https://www.walmart.com/product/strangestory/?_bctx=CAYQo_AD&asb=F%252FbSShNEC3crWU19goaHGoP%252BcMYjDDKauI9o0TgdYYc%253D&asb2=Oaexb6LUBCoEwwCZjWwjcXZ1-EV2vvIHPW8XFIEv-SM','zNwbVNv+6Wzm8qpln071bQ==',NULL),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','ZL0YVbSXYLURSDDM6ryBrQ==','MoxRtRI7drqhD3dHXHxGDA==','QdJfvxSJeSJoENaWwiOffA==','umSH0KgpE5d1hk7z89WRYg==','L2xLfMOQtVfGLNscF2lwlw==','dn84s7odRbP1BF4bn96sbQ==','https://www.walmart.com/product/strangestory/?_bctx=CAYQo_AD&asb=F%252FbSShNEC3crWU19goaHGoP%252BcMYjDDKauI9o0TgdYYc%253D&asb2=Oaexb6LUBCoEwwCZjWwjcXZ1-EV2vvIHPW8XFIEv-SM','zNwbVNv+6Wzm8qpln071bQ==',NULL),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','ZL0YVbSXYLURSDDM6ryBrQ==','fK2TcdDvP9KaOrlB3WtGOQ==','QdJfvxSJeSJoENaWwiOffA==','umSH0KgpE5d1hk7z89WRYg==','L2xLfMOQtVfGLNscF2lwlw==','boGxXJbs8ATuANDZafecjA==','https://www.walmart.com/product/strangestory/?_bctx=CAYQo_AD&asb=F%252FbSShNEC3crWU19goaHGoP%252BcMYjDDKauI9o0TgdYYc%253D&asb2=Oaexb6LUBCoEwwCZjWwjcXZ1-EV2vvIHPW8XFIEv-SM','zNwbVNv+6Wzm8qpln071bQ==',NULL),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','WdqrRfjE6OxPxhj8FaTOVw==','8029qFKKNE0U6woeCgajig==','GyklXyfkdfkdedmnipQLA==','q9wKnBCOfg2UHGZSeDSwQw==','z5B9C8/Z5VLRNLQMKZB02g==','vhHxrpeMtQlY4ydg7EHxFQ==','https://www.walmart.com/product/strangestory/?_bctx=CAYQo_AD&asb=F%252FbSShNEC3crWU19goaHGoP%252BcMYjDDKauI9o0TgdYYc%253D&asb2=Oaexb6LUBCoEwwCZjWwjcXZ1-EV2vvIHPW8XFIEv-SM','zNwbVNv+6Wzm8qpln071bQ==',NULL),
	('2021-10-03 00:00:00','DLH2GuJt0uJopHspKxKPmg==','5sBpEPxhFpM3r9YFp+jRMw==','VTsjn6S0H+TyElwtpL4mpQ==','HQVHkCT1YtqrektOPewIpQ==','SowCbCM9exuZ+X63iu8LjQ==','Mx8qJTEumedTsWDPtslNUg==','SnxP7UR9LpnuNQsc4hjQWQ==','KZdb5r04K53Agf679a92Hg==','https://www.walmart.com/highlight/fire-24903240/','20eeOER9H5uao3snTZcYQg==',NULL),
	('2021-10-03 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','WdqrRfjE6OxPxhj8FaTOVw==','hciXX5R5KeNA8r24eZze1A==','GyklXyqLs+X58idmnipQLA==','umSH0Kgpkfkesfme9WRYg==','L2xLfMOQtVfGLNscF2lwlw==','boGxXJbs8ATuANDZafecjA==','https://www.walmart.com/product/strangestory/?_bctx=CAYQo_AD&asb=F%252FbSShNEC3crWU19goaHGoP%252BcMYjDDKauI9o0TgdYYc%253D&asb2=Oaexb6LUBCoEwwCZjWwjcXZ1-EV2vvIHPW8XFIEv-SM','zNwbVNv+6Wzm8qpln071bQ==',NULL),
	('2021-10-03 00:00:00','DLH2GuJt0uJopHspKxKPmg==','5sBpEPxhFpM3r9YFp+jRMw==','VTsjn6S0H+TyElwtpL4mpQ==','jIs3JOubI4GY5TAFE/iqmg==','SowCbCM9exuZ+X63iu8LjQ==','Mx8qJTEumedTsWDPtslNUg==','SnxP7UR9LpnuNQsc4hjQWQ==','ahHZEVRZF0E7ju245uVAfA==','https://www.walmart.com/highlight/fire-24903240/','20eeOER9H5uao3snTZcYQg==',NULL),
	('2021-10-03 00:00:00','DLH2GuJt0uJopHspKxKPmg==','5sBpEPxhFpM3r9YFp+jRMw==','apL4KKdaexR4N+/her73pg==','sn6vGvGsZHTo9GDs/2JAZg==','UPJnHCZFxbNIdWJJhQsaow==','PedHCrxoloJCT27vOsKTtw==','SnxP7UR9LpnuNQsc4hjQWQ==','ahHZEVRZF0E7ju245uVAfA==','https://www.walmart.com/highlight/fire-24903240/','u7bSLghhEOsb5t992QsnTQ==',NULL),
	('2021-10-03 00:00:00','DLH2GuJt0uJopHspKxKPmg==','5sBpEPxhFpM3r9YFp+jRMw==','apL4KKdaexR4N+/her73pg==','VOrY2Y6ZrWgLe2fQ2ngU7Q==','UPJnHCZFxbNIdWJJhQsaow==','PedHCrxoloJCT27vOsKTtw==','SnxP7UR9LpnuNQsc4hjQWQ==','JxJQmJrlhsZqjVAgcvqGyw==','https://www.walmart.com/highlight/fire-24903240/','u7bSLghhEOsb5t992QsnTQ==',NULL),
	('2021-10-03 00:00:00','mAm0RQx8X+Ik8LZcWCrRGw==','w6OZRofbxqN+dRzQXdBZyA==','34yhys44D78+unwde0GDpQ==','QHlgnt4yUYebup82hgSBOQ==','acfgTJol4UMLE7ZHv0QW/w==','bZ+rrt6wXYg/mMlPRefMYQ==','v1uajNhKz8ZqV7ikkD+zUw==','DtL3SHQTx86ZJpBsoJpyug==','https://www.walmart.com/highlight/expedition-24em2lkrmo/','AK/V/FgjmBOq14Kaq+dbBA==',NULL),
	('2021-10-03 00:00:00','mAm0RQx8X+Ik8LZcWCrRGw==','w6OZRofbxqN+dRzQXdBZyA==','HnkqcqBSCSIuRuNgFQ+c3A==','eT0XqEP6O+VscwdAPJDWCg==','acfgTJol4UMLE7ZHv0QW/w==','hUiItm0I9kR01VZNoN32kg==','v1uajNhKz8ZqV7ikkD+zUw==','DtL3SHQTx86ZJpBsoJpyug==','https://www.walmart.com/highlight/expedition-24em2lkrmo/','AK/V/FgjmBOq14Kaq+dbBA==',NULL),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','WdqrRfjE6OxPxhj8FaTOVw==','8029qFKKNE0U6woeCgajig==','GyklXyqLs+X58idmnipQLA==','q9wKnBCOfg2UHGZSeDSwQw==','z5B9C8/Z5VLRNLQMKZB02g==','vhHxrpeMtQlY4ydg7EHxFQ==','https://www.walmart.com/product/strangestory/?_bctx=CAYQo_AD&asb=F%252FbSShNEC3crWU19goaHGoP%252BcMYjDDKauI9o0TgdYYc%253D&asb2=Oaexb6LUBCoEwwCZjWwjcXZ1-EV2vvIHPW8XFIEv-SM','zNwbVNv+6Wzm8qpln071bQ==',NULL),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','WdqrRfjE6OxPxhj8FaTOVw==','hciXX5R5KeNA8r24eZze1A==','GyklXyqLs+X58idmnipQLA==','umSH0KgpE5d1hk7z89WRYg==','L2xLfMOQtVfGLNscF2lwlw==','boGxXJbs8ATuANDZafecjA==','https://www.walmart.com/product/strangestory/?_bctx=CAYQo_AD&asb=F%252FbSShNEC3crWU19goaHGoP%252BcMYjDDKauI9o0TgdYYc%253D&asb2=Oaexb6LUBCoEwwCZjWwjcXZ1-EV2vvIHPW8XFIEv-SM','zNwbVNv+6Wzm8qpln071bQ==',NULL),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','ZL0YVbSXYLURSDDM6ryBrQ==','sXUrZmYCIh0n1jZ0pvBpPQ==','QdJfvxSJeSJoENaWwiOffA==','umSH0KgpE5d1hk7z89WRYg==','z5B9C8/Z5VLRNLQMKZB02g==','Qw/khFX8t6maQg2CSJgyog==','https://www.walmart.com/product/strangestory/?_bctx=CAYQo_AD&asb=F%252FbSShNEC3crWU19goaHGoP%252BcMYjDDKauI9o0TgdYYc%253D&asb2=Oaexb6LUBCoEwwCZjWwjcXZ1-EV2vvIHPW8XFIEv-SM','zNwbVNv+6Wzm8qpln071bQ==',NULL),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','ZL0YVbSXYLURSDDM6ryBrQ==','MoxRtRI7drqhD3dHXHxGDA==','QdJfvxSJeSJoENaWwiOffA==','umSH0KgpE5d1hk7z89WRYg==','L2xLfMOQtVfGLNscF2lwlw==','dn84s7odRbP1BF4bn96sbQ==','https://www.walmart.com/product/strangestory/?_bctx=CAYQo_AD&asb=F%252FbSShNEC3crWU19goaHGoP%252BcMYjDDKauI9o0TgdYYc%253D&asb2=Oaexb6LUBCoEwwCZjWwjcXZ1-EV2vvIHPW8XFIEv-SM','zNwbVNv+6Wzm8qpln071bQ==',NULL),
	('2021-10-01 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','ZL0YVbSXYLURSDDM6ryBrQ==','fK2TcdDvP9KaOrlB3WtGOQ==','QdJfvxSJeSJoENaWwiOffA==','umSH0KgpE5d1hk7z89WRYg==','L2xLfMOQtVfGLNscF2lwlw==','boGxXJbs8ATuANDZafecjA==','https://www.walmart.com/product/strangestory/?_bctx=CAYQo_AD&asb=F%252FbSShNEC3crWU19goaHGoP%252BcMYjDDKauI9o0TgdYYc%253D&asb2=Oaexb6LUBCoEwwCZjWwjcXZ1-EV2vvIHPW8XFIEv-SM','zNwbVNv+6Wzm8qpln071bQ==',NULL),
	('2021-10-01 00:00:00','DLH2GuJt0uJopHspKxKPmg==','5sBpEPxhFpM3r9YFp+jRMw==','VTsjn6S0H+TyElwtpL4mpQ==','HQVHkCT1YtqrektOPewIpQ==','SowCbCM9exuZ+X63iu8LjQ==','Mx8qJTEumedTsWDPtslNUg==','SnxP7UR9LpnuNQsc4hjQWQ==','KZdb5r04K53Agf679a92Hg==','https://www.walmart.com/highlight/fire-24903240/','20eeOER9H5uao3snTZcYQg==',NULL),
	('2021-10-01 00:00:00','DLH2GuJt0uJopHspKxKPmg==','5sBpEPxhFpM3r9YFp+jRMw==','VTsjn6S0H+TyElwtpL4mpQ==','jIs3JOubI4GY5TAFE/iqmg==','SowCbCM9exuZ+X63iu8LjQ==','Mx8qJTEumedTsWDPtslNUg==','SnxP7UR9LpnuNQsc4hjQWQ==','ahHZEVRZF0E7ju245uVAfA==','https://www.walmart.com/highlight/fire-24903240/','20eeOER9H5uao3snTZcYQg==',NULL),
	('2021-10-01 00:00:00','DLH2GuJt0uJopHspKxKPmg==','5sBpEPxhFpM3r9YFp+jRMw==','apL4KKdaexR4N+/her73pg==','sn6vGvGsZHTo9GDs/2JAZg==','UPJnHCZFxbNIdWJJhQsaow==','PedHCrxoloJCT27vOsKTtw==','SnxP7UR9LpnuNQsc4hjQWQ==','ahHZEVRZF0E7ju245uVAfA==','https://www.walmart.com/highlight/fire-24903240/','u7bSLghhEOsb5t992QsnTQ==',NULL),
	('2021-10-01 00:00:00','DLH2GuJt0uJopHspKxKPmg==','5sBpEPxhFpM3r9YFp+jRMw==','apL4KKdaexR4N+/her73pg==','VOrY2Y6ZrWgLe2fQ2ngU7Q==','UPJnHCZFxbNIdWJJhQsaow==','PedHCrxoloJCT27vOsKTtw==','SnxP7UR9LpnuNQsc4hjQWQ==','JxJQmJrlhsZqjVAgcvqGyw==','https://www.walmart.com/highlight/fire-24903240/','u7bSLghhEOsb5t992QsnTQ==',NULL),
	('2021-10-01 00:00:00','mAm0RQx8X+Ik8LZcWCrRGw==','w6OZRofbxqN+dRzQXdBZyA==','34yhys44D78+unwde0GDpQ==','QHlgnt4yUYebup82hgSBOQ==','acfgTJol4UMLE7ZHv0QW/w==','bZ+rrt6wXYg/mMlPRefMYQ==','v1uajNhKz8ZqV7ikkD+zUw==','DtL3SHQTx86ZJpBsoJpyug==','https://www.walmart.com/highlight/expedition-24em2lkrmo/','AK/V/FgjmBOq14Kaq+dbBA==',NULL),
	('2021-10-01 00:00:00','mAm0RQx8X+Ik8LZcWCrRGw==','w6OZRofbxqN+dRzQXdBZyA==','HnkqcqBSCSIuRuNgFQ+c3A==','eT0XqEP6O+VscwdAPJDWCg==','acfgTJol4UMLE7ZHv0QW/w==','hUiItm0I9kR01VZNoN32kg==','v1uajNhKz8ZqV7ikkD+zUw==','DtL3SHQTx86ZJpBsoJpyug==','https://www.walmart.com/highlight/expedition-24em2lkrmo/','AK/V/FgjmBOq14Kaq+dbBA==',NULL),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','WdqrRfjE6OxPxhj8FaTOVw==','XO++0deJgsVjEYvgp3kmqg==','GyklXyqLs+X58idmnipQLA==','nooZCXrrniLjba8brIDdvA==','L2xLfMOQtVfGLNscF2lwlw==','Qw/khFX8t6maQg2CSJgyog==','https://www.walmart.com/product/strangestory/?_bctx=CAYQo_AD&asb=F%252FbSShNEC3crWU19goaHGoP%252BcMYjDDKauI9o0TgdYYc%253D&asb2=Oaexb6LUBCoEwwCZjWwjcXZ1-EV2vvIHPW8XFIEv-SM','zNwbVNv+6Wzm8qpln071bQ==',NULL),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','WdqrRfjE6OxPxhj8FaTOVw==','8029qFKKNE0U6woeCgajig==','GyklXyqLs+X58idmnipQLA==','q9wKnBCOfg2UHGZSeDSwQw==','z5B9C8/Z5VLRNLQMKZB02g==','vhHxrpeMtQlY4ydg7EHxFQ==','https://www.walmart.com/product/strangestory/?_bctx=CAYQo_AD&asb=F%252FbSShNEC3crWU19goaHGoP%252BcMYjDDKauI9o0TgdYYc%253D&asb2=Oaexb6LUBCoEwwCZjWwjcXZ1-EV2vvIHPW8XFIEv-SM','zNwbVNv+6Wzm8qpln071bQ==',NULL),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','WdqrRfjE6OxPxhj8FaTOVw==','hciXX5R5KeNA8r24eZze1A==','GyklXyqLs+X58idmnipQLA==','umSH0KgpE5d1hk7z89WRYg==','L2xLfMOQtVfGLNscF2lwlw==','boGxXJbs8ATuANDZafecjA==','https://www.walmart.com/product/strangestory/?_bctx=CAYQo_AD&asb=F%252FbSShNEC3crWU19goaHGoP%252BcMYjDDKauI9o0TgdYYc%253D&asb2=Oaexb6LUBCoEwwCZjWwjcXZ1-EV2vvIHPW8XFIEv-SM','zNwbVNv+6Wzm8qpln071bQ==',NULL),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','ZL0YVbSXYLURSDDM6ryBrQ==','sXUrZmYCIh0n1jZ0pvBpPQ==','QdJfvxSJeSJoENaWwiOffA==','umSH0KgpE5d1hk7z89WRYg==','z5B9C8/Z5VLRNLQMKZB02g==','Qw/khFX8t6maQg2CSJgyog==','https://www.walmart.com/product/strangestory/?_bctx=CAYQo_AD&asb=F%252FbSShNEC3crWU19goaHGoP%252BcMYjDDKauI9o0TgdYYc%253D&asb2=Oaexb6LUBCoEwwCZjWwjcXZ1-EV2vvIHPW8XFIEv-SM','zNwbVNv+6Wzm8qpln071bQ==',NULL),
	('2021-10-02 00:00:00','KvHZHCUnRS1G2k25DBXWig==','0FQ1OC8NxA+PWYxF/oTl0A==','ZL0YVbSXYLURSDDM6ryBrQ==','MoxRtRI7drqhD3dHXHxGDA==','QdJfvxSJeSJoENaWwiOffA==','umSH0KgpE5d1hk7z89WRYg==','L2xLfMOQtVfGLNscF2lwlw==','dn84s7odRbP1BF4bn96sbQ==','https://www.walmart.com/product/strangestory/?_bctx=CAYQo_AD&asb=F%252FbSShNEC3crWU19goaHGoP%252BcMYjDDKauI9o0TgdYYc%253D&asb2=Oaexb6LUBCoEwwCZjWwjcXZ1-EV2vvIHPW8XFIEv-SM','zNwbVNv+6Wzm8qpln071bQ==',NULL),
	('2021-10-02 00:00:00','DLH2GuJt0uJopHspKxKPmg==','5sBpEPxhFpM3r9YFp+jRMw==','VTsjn6S0H+TyElwtpL4mpQ==','HQVHkCT1YtqrektOPewIpQ==','SowCbCM9exuZ+X63iu8LjQ==','Mx8qJTEumedTsWDPtslNUg==','SnxP7UR9LpnuNQsc4hjQWQ==','KZdb5r04K53Agf679a92Hg==','https://www.walmart.com/highlight/fire-24903240/','20eeOER9H5uao3snTZcYQg==',NULL),
	('2021-10-02 00:00:00','DLH2GuJt0uJopHspKxKPmg==','5sBpEPxhFpM3r9YFp+jRMw==','VTsjn6S0H+TyElwtpL4mpQ==','jIs3JOubI4GY5TAFE/iqmg==','SowCbCM9exuZ+X63iu8LjQ==','Mx8qJTEumedTsWDPtslNUg==','SnxP7UR9LpnuNQsc4hjQWQ==','ahHZEVRZF0E7ju245uVAfA==','https://www.walmart.com/highlight/fire-24903240/','20eeOER9H5uao3snTZcYQg==',NULL),
	('2021-10-02 00:00:00','DLH2GuJt0uJopHspKxKPmg==','5sBpEPxhFpM3r9YFp+jRMw==','apL4KKdaexR4N+/her73pg==','sn6vGvGsZHTo9GDs/2JAZg==','UPJnHCZFxbNIdWJJhQsaow==','PedHCrxoloJCT27vOsKTtw==','SnxP7UR9LpnuNQsc4hjQWQ==','ahHZEVRZF0E7ju245uVAfA==','https://www.walmart.com/highlight/fire-24903240/','u7bSLghhEOsb5t992QsnTQ==',NULL),
	('2021-10-02 00:00:00','DLH2GuJt0uJopHspKxKPmg==','5sBpEPxhFpM3r9YFp+jRMw==','apL4KKdaexR4N+/her73pg==','VOrY2Y6ZrWgLe2fQ2ngU7Q==','UPJnHCZFxbNIdWJJhQsaow==','PedHCrxoloJCT27vOsKTtw==','SnxP7UR9LpnuNQsc4hjQWQ==','JxJQmJrlhsZqjVAgcvqGyw==','https://www.walmart.com/highlight/fire-24903240/','u7bSLghhEOsb5t992QsnTQ==',NULL),
	('2021-10-02 00:00:00','mAm0RQx8X+Ik8LZcWCrRGw==','w6OZRofbxqN+dRzQXdBZyA==','34yhys44D78+unwde0GDpQ==','QHlgnt4yUYebup82hgSBOQ==','acfgTJol4UMLE7ZHv0QW/w==','bZ+rrt6wXYg/mMlPRefMYQ==','v1uajNhKz8ZqV7ikkD+zUw==','DtL3SHQTx86ZJpBsoJpyug==','https://www.walmart.com/highlight/expedition-24em2lkrmo/','AK/V/FgjmBOq14Kaq+dbBA==',NULL),
	('2021-10-02 00:00:00','mAm0RQx8X+Ik8LZcWCrRGw==','w6OZRofbxqN+dRzQXdBZyA==','HnkqcqBSCSIuRuNgFQ+c3A==','eT0XqEP6O+VscwdAPJDWCg==','acfgTJol4UMLE7ZHv0QW/w==','hUiItm0I9kR01VZNoN32kg==','v1uajNhKz8ZqV7ikkD+zUw==','DtL3SHQTx86ZJpBsoJpyug==','https://www.walmart.com/highlight/expedition-24em2lkrmo/','AK/V/FgjmBOq14Kaq+dbBA==',NULL);

SELECT * FROM table_3; --33 rows


CREATE TABLE table_4 (
    account_id VARCHAR(255),
    campaign_id VARCHAR(255),
    adset_id VARCHAR(255),
    ad_id VARCHAR(255),
    headline1 VARCHAR(255),
    headline2 VARCHAR(255),
    text VARCHAR(255),
    destination_url VARCHAR(1000)
);
INSERT INTO table_4 VALUES ('KvHZHCUnRS1G2k25DBXWig==','WgdYr5llR6HwSxu/YrR2Gg==','5aUmMIQksGGZui1ig/d29A==','hkuO+yW3LdbLXvZqR2ZoGg==','YqeNG+/UId+kO2KLjzKxBg==','12CHLK78S8wvbxj70aCyoA==','gdK7H7wgWpRvZgSzsZIuPQ==','https://www.walmart.com/product/university-high-school/?_bctx=CAYQo_AD&asb=1EN9BBz05Tsb3TGmK9Yjaz8aAW11xeaj6qCmeMYi55s%253D&asb2=6gvu8CGzKkDoKsar76hjWYxjE_OHp9xUVN0XwJLRfgY'),
	('KvHZHCUnRS1G2k25DBXWig==','WgdYr5llR6HwSxu/YrR2Gg==','5XiFHJ5g9LD2/hBLYZSAyQ==','t3BEZU93Oe7vyvrSCidOAQ==','x/NX0dIXDXJ5O2JeVUj0hg==','mRLvPGX0fBcYn83RRfMbYw==','4xEmOgC/TcprWGgJew3qUQ==','https://www.walmart.com/product/university-high-school/?_bctx=CAYQo_AD&asb=1EN9BBz05Tsb3TGmK9Yjaz8aAW11xeaj6qCmeMYi55s%253D&asb2=6gvu8CGzKkDoKsar76hjWYxjE_OHp9xUVN0XwJLRfgY'),
	('KvHZHCUnRS1G2k25DBXWig==','WgdYr5llR6HwSxu/YrR2Gg==','5XiFHJ5g9LD2/hBLYZSAyQ==','crlBfPCm+Z1/EQAzBqpkrA==','x/NX0dIXDXJ5O2JeVUj0hg==','mRLvPGX0fBcYn83RRfMbYw==','gdK7H7wgWpRvZgSzsZIuPQ==','https://www.walmart.com/product/university-high-school/?_bctx=CAYQo_AD&asb=1EN9BBz05Tsb3TGmK9Yjaz8aAW11xeaj6qCmeMYi55s%253D&asb2=6gvu8CGzKkDoKsar76hjWYxjE_OHp9xUVN0XwJLRfgY'),
	('KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','1p9+1rIZ7gcDvkZ8bvmkGw==','zcq+nOHEuvBE8froYA1cvg==','AOCxKJicyxXiji5QJtFJuA==','umSH0KgpE5d1hk7z89WRYg==','wV4vJwLAB5K+uW/k0jm/qw==','https://www.site.ru/'),
	('KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','WSWd6aAlECGsa5IDiMDh2g==','AmrRspIz7ExFVRYh2Uz02A==','Zd+2skv6YeFpQm3rmXiBNQ==','umSH0KgpE5d1hk7z89WRYg==','slTQIAltcJZgSfaVvbYWjg==','https://www.site.ru/'),
	('DLH2GuJt0uJopHspKxKPmg==','zRRwAzE/dzRIBehvyZL69Q==','7nm3jfcXpm7aPCoRss7G7A==','Ho2WLS1iu63beefdncf2nQ==','IU5a2+QIPHTDpAUH69SJmw==','fLFwmpZpCje4FV/syLYS8g==','s+codZFzfzqJgLEAY9wlqA==','https://www.walmart.com/highlight/fighter-03403459032/'),
	('DLH2GuJt0uJopHspKxKPmg==','zRRwAzE/dzRIBehvyZL69Q==','7nm3jfcXpm7aPCoRss7G7A==','Ty59S+/w94UtsCgY6KB2pg==','IU5a2+QIPHTDpAUH69SJmw==','S2YGN4JApQtan9HGz/89Xw==','vBBXyC2j6766AC6tMaZErw==','https://www.walmart.com/highlight/fighter-03403459032/'),
	('KvHZHCUnRS1G2k25DBXWig==','WgdYr5llR6HwSxu/YrR2Gg==','5aUmMIQksGGZui1ig/d29A==','wxzDYKZo11WXMR8Kch8YAw==','YqeNG+/UId+kO2KLjzKxBg==','12CHLK78S8wvbxj70aCyoA==','QGKdSAnd6F6+tMxZMi3LVA==','https://www.walmart.com/product/university-high-school/?_bctx=CAYQo_AD&asb=1EN9BBz05Tsb3TGmK9Yjaz8aAW11xeaj6qCmeMYi55s%253D&asb2=6gvu8CGzKkDoKsar76hjWYxjE_OHp9xUVN0XwJLRfgY'),
	('KvHZHCUnRS1G2k25DBXWig==','WgdYr5llR6HwSxu/YrR2Gg==','5aUmMIQksGGZui1ig/d29A==','hkuO+yW3LdbLXvZqR2ZoGg==','YqeNG+/UId+kO2KLjzKxBg==','12CHLK78S8wvbxj70aCyoA==','gdK7H7wgWpRvZgSzsZIuPQ==','https://www.walmart.com/product/university-high-school/?_bctx=CAYQo_AD&asb=1EN9BBz05Tsb3TGmK9Yjaz8aAW11xeaj6qCmeMYi55s%253D&asb2=6gvu8CGzKkDoKsar76hjWYxjE_OHp9xUVN0XwJLRfgY'),
	('KvHZHCUnRS1G2k25DBXWig==','WgdYr5llR6HwSxu/YrR2Gg==','5XiFHJ5g9LD2/hBLYZSAyQ==','t3BEZU93Oe7vyvrSCidOAQ==','x/NX0dIXDXJ5O2JeVUj0hg==','mRLvPGX0fBcYn83RRfMbYw==','4xEmOgC/TcprWGgJew3qUQ==','https://www.walmart.com/product/university-high-school/?_bctx=CAYQo_AD&asb=1EN9BBz05Tsb3TGmK9Yjaz8aAW11xeaj6qCmeMYi55s%253D&asb2=6gvu8CGzKkDoKsar76hjWYxjE_OHp9xUVN0XwJLRfgY'),
	('KvHZHCUnRS1G2k25DBXWig==','WgdYr5llR6HwSxu/YrR2Gg==','5XiFHJ5g9LD2/hBLYZSAyQ==','crlBfPCm+Z1/EQAzBqpkrA==','x/NX0dIXDXJ5O2JeVUj0hg==','mRLvPGX0fBcYn83RRfMbYw==','gdK7H7wgWpRvZgSzsZIuPQ==','https://www.walmart.com/product/university-high-school/?_bctx=CAYQo_AD&asb=1EN9BBz05Tsb3TGmK9Yjaz8aAW11xeaj6qCmeMYi55s%253D&asb2=6gvu8CGzKkDoKsar76hjWYxjE_OHp9xUVN0XwJLRfgY'),
	('KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','1p9+1rIZ7gcDvkZ8bvmkGw==','zcq+nOHEuvBE8froYA1cvg==','AOCxKJicyxXiji5QJtFJuA==','umSH0KgpE5d1hk7z89WRYg==','wV4vJwLAB5K+uW/k0jm/qw==','https://www.site.ru/'),
	('KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','WSWd6aAlECGsa5IDiMDh2g==','AmrRspIz7ExFVRYh2Uz02A==','Zd+2skv6YeFpQm3rmXiBNQ==','umSH0KgpE5d1hk7z89WRYg==','slTQIAltcJZgSfaVvbYWjg==','https://www.site.ru/'),
	('DLH2GuJt0uJopHspKxKPmg==','zRRwAzE/dzRIBehvyZL69Q==','7nm3jfcXpm7aPCoRss7G7A==','Ho2WLS1iu63beefdncf2nQ==','IU5a2+QIPHTDpAUH69SJmw==','fLFwmpZpCje4FV/syLYS8g==','s+codZFzfzqJgLEAY9wlqA==','https://www.walmart.com/highlight/fighter-03403459032/'),
	('DLH2GuJt0uJopHspKxKPmg==','zRRwAzE/dzRIBehvyZL69Q==','7nm3jfcXpm7aPCoRss7G7A==','Ty59S+/w94UtsCgY6KB2pg==','IU5a2+QIPHTDpAUH69SJmw==','S2YGN4JApQtan9HGz/89Xw==','vBBXyC2j6766AC6tMaZErw==','https://www.walmart.com/highlight/fighter-03403459032/'),
	('DLH2GuJt0uJopHspKxKPmg==','zRRwAzE/dzRIBehvyZL69Q==','Zb13hGO/0AhGBYiIa7yvHg==','W4EQNCKbJRywJyw3FVroKg==','47jjpDqTQZoLDfFlKARLFw==','Hqk/VLPHz41FvsXyyXvRPQ==','s+codZFzfzqJgLEAY9wlqA==','https://www.walmart.com/highlight/fighter-03403459032/'),
	('DLH2GuJt0uJopHspKxKPmg==','zRRwAzE/dzRIBehvyZL69Q==','Zb13hGO/0AhGBYiIa7yvHg==','Wu3cRoOQSjxQfQdIozxt6Q==','47jjpDqTQZoLDfFlKARLFw==','Hqk/VLPHz41FvsXyyXvRPQ==','tygSj1MGTyDFqETuo5/u2w==','https://www.walmart.com/highlight/fighter-03403459032/'),
	('KvHZHCUnRS1G2k25DBXWig==','WgdYr5llR6HwSxu/YrR2Gg==','5aUmMIQksGGZui1ig/d29A==','hkuO+yW3LdbLXvZqR2ZoGg==','YqeNG+/UId+kO2KLjzKxBg==','12CHLK78S8wvbxj70aCyoA==','gdK7H7wgWpRvZgSzsZIuPQ==','https://www.walmart.com/product/university-high-school/?_bctx=CAYQo_AD&asb=1EN9BBz05Tsb3TGmK9Yjaz8aAW11xeaj6qCmeMYi55s%253D&asb2=6gvu8CGzKkDoKsar76hjWYxjE_OHp9xUVN0XwJLRfgY'),
	('KvHZHCUnRS1G2k25DBXWig==','WgdYr5llR6HwSxu/YrR2Gg==','5aUmMIQksGGZui1ig/d29A==','zwOUkfJe8cNMwq1FB6CJtA==','YqeNG+/UId+kO2KLjzKxBg==','12CHLK78S8wvbxj70aCyoA==','aIuBxgGEYRFmdenulFPOug==','https://www.walmart.com/product/university-high-school/?_bctx=CAYQo_AD&asb=1EN9BBz05Tsb3TGmK9Yjaz8aAW11xeaj6qCmeMYi55s%253D&asb2=6gvu8CGzKkDoKsar76hjWYxjE_OHp9xUVN0XwJLRfgY'),
	('KvHZHCUnRS1G2k25DBXWig==','WgdYr5llR6HwSxu/YrR2Gg==','5XiFHJ5g9LD2/hBLYZSAyQ==','t3BEZU93Oe7vyvrSCidOAQ==','x/NX0dIXDXJ5O2JeVUj0hg==','mRLvPGX0fBcYn83RRfMbYw==','4xEmOgC/TcprWGgJew3qUQ==','https://www.walmart.com/product/university-high-school/?_bctx=CAYQo_AD&asb=1EN9BBz05Tsb3TGmK9Yjaz8aAW11xeaj6qCmeMYi55s%253D&asb2=6gvu8CGzKkDoKsar76hjWYxjE_OHp9xUVN0XwJLRfgY'),
	('KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','1p9+1rIZ7gcDvkZ8bvmkGw==','zcq+nOHEuvBE8froYA1cvg==','AOCxKJicyxXiji5QJtFJuA==','umSH0KgpE5d1hk7z89WRYg==','wV4vJwLAB5K+uW/k0jm/qw==','https://www.site.ru/'),
	('KvHZHCUnRS1G2k25DBXWig==','GMDa0jHMb/kAPNjZ8sv90A==','WSWd6aAlECGsa5IDiMDh2g==','AmrRspIz7ExFVRYh2Uz02A==','Zd+2skv6YeFpQm3rmXiBNQ==','umSH0KgpE5d1hk7z89WRYg==','slTQIAltcJZgSfaVvbYWjg==','https://www.site.ru/'),
	('DLH2GuJt0uJopHspKxKPmg==','zRRwAzE/dzRIBehvyZL69Q==','7nm3jfcXpm7aPCoRss7G7A==','Ho2WLS1iu63beefdncf2nQ==','IU5a2+QIPHTDpAUH69SJmw==','fLFwmpZpCje4FV/syLYS8g==','s+codZFzfzqJgLEAY9wlqA==','https://www.walmart.com/highlight/fighter-03403459032/'),
	('DLH2GuJt0uJopHspKxKPmg==','zRRwAzE/dzRIBehvyZL69Q==','7nm3jfcXpm7aPCoRss7G7A==','Ty59S+/w94UtsCgY6KB2pg==','IU5a2+QIPHTDpAUH69SJmw==','S2YGN4JApQtan9HGz/89Xw==','vBBXyC2j6766AC6tMaZErw==','https://www.walmart.com/highlight/fighter-03403459032/');

SELECT * FROM table_4; --24 rows


CREATE TABLE table_5 (
    date DATE,
    utm_source VARCHAR(50),
    campaign VARCHAR(50),
    sessions INTEGER,
    users INTEGER,
    new_users INTEGER,
    page_views INTEGER
);
INSERT INTO table_5 VALUES ('2021-10-01 00:00:00','Platform 1','fireshow',23,51,18,120),
	('2021-10-01 00:00:00','Platform 1','fireshow',42,31,17,25),
	('2021-10-01 00:00:00','Platform 1','fireshow',43,67,0,35),
	('2021-10-01 00:00:00','Platform 1','strangeadventure',13,33,3,61),
	('2021-10-01 00:00:00','Platform 1','strangeadventure',42,19,2,108),
	('2021-10-01 00:00:00','Platform 1','strangeadventure',8,41,9,98),
	('2021-10-01 00:00:00','Platform 1','cinema',14,64,2,115),
	('2021-10-01 00:00:00','Platform 1','cinema',38,11,20,22),
	('2021-10-01 00:00:00','Platform 1','cinema',24,31,14,14),
	('2021-10-01 00:00:00','Platform 1','cinema',1,31,6,28),
	('2021-10-01 00:00:00','Platform 2','amacrm',1,17,8,83),
	('2021-10-01 00:00:00','Platform 2','amacrm',56,1,3,100),
	('2021-10-01 00:00:00','Platform 2','amacrm',67,26,20,30),
	('2021-10-01 00:00:00','Platform 2','amacrm',64,60,18,71),
	('2021-10-01 00:00:00','Platform 2','fighter',4,29,15,81),
	('2021-10-01 00:00:00','Platform 2','fighter',12,32,20,2),
	('2021-10-01 00:00:00','Platform 2','fighter',23,15,15,68),
	('2021-10-01 00:00:00','Platform 2','fighter',66,7,8,93),
	('2021-10-01 00:00:00','Platform 2','fighter',59,53,0,32),
	('2021-10-01 00:00:00','Platform 2','student',19,43,6,62),
	('2021-10-01 00:00:00','Platform 2','student',29,46,0,107),
	('2021-10-01 00:00:00','Platform 2','student',12,56,14,21),
	('2021-10-01 00:00:00','Platform 2','student',49,24,5,109),
	('2021-10-01 00:00:00','Platform 2','student',9,20,2,52),
	('2021-10-01 00:00:00','Platform 2','student',45,59,12,23),
	('2021-10-02 00:00:00','Platform 1','fireshow',61,2,13,73),
	('2021-10-02 00:00:00','Platform 1','fireshow',42,43,16,106),
	('2021-10-02 00:00:00','Platform 1','fireshow',70,39,4,65),
	('2021-10-02 00:00:00','Platform 1','strangeadventure',66,8,1,35),
	('2021-10-02 00:00:00','Platform 1','strangeadventure',53,15,10,32),
	('2021-10-02 00:00:00','Platform 1','strangeadventure',15,55,10,15),
	('2021-10-02 00:00:00','Platform 1','cinema',37,49,2,62),
	('2021-10-02 00:00:00','Platform 1','cinema',33,46,19,47),
	('2021-10-02 00:00:00','Platform 1','cinema',64,59,9,92),
	('2021-10-02 00:00:00','Platform 2','amacrm',70,66,19,17),
	('2021-10-02 00:00:00','Platform 2','amacrm',34,5,8,92),
	('2021-10-02 00:00:00','Platform 2','amacrm',25,66,3,51),
	('2021-10-02 00:00:00','Platform 2','fighter',38,42,14,1),
	('2021-10-02 00:00:00','Platform 2','fighter',12,60,14,69),
	('2021-10-02 00:00:00','Platform 2','student',48,50,1,87),
	('2021-10-02 00:00:00','Platform 2','student',19,17,11,90),
	('2021-10-02 00:00:00','Platform 2','student',40,11,12,82),
	('2021-10-02 00:00:00','Platform 2','amacrm',35,23,6,34),
	('2021-10-02 00:00:00','Platform 2','amacrm',0,70,17,92),
	('2021-10-03 00:00:00','Platform 1','fireshow',69,47,20,115),
	('2021-10-03 00:00:00','Platform 1','fireshow',60,50,13,22),
	('2021-10-03 00:00:00','Platform 1','fireshow',57,42,13,118),
	('2021-10-03 00:00:00','Platform 1','strangeadventure',27,14,2,102),
	('2021-10-03 00:00:00','Platform 1','strangeadventure',38,54,16,38),
	('2021-10-03 00:00:00','Platform 1','strangeadventure',21,19,0,57),
	('2021-10-03 00:00:00','Platform 1','cinema',66,13,0,106),
	('2021-10-03 00:00:00','Platform 1','cinema',24,10,19,114),
	('2021-10-03 00:00:00','Platform 1','cinema',37,28,0,57),
	('2021-10-03 00:00:00','Platform 2','amacrm',18,44,4,11),
	('2021-10-03 00:00:00','Platform 2','amacrm',12,49,17,28),
	('2021-10-03 00:00:00','Platform 2','amacrm',6,70,17,57),
	('2021-10-03 00:00:00','Platform 2','fighter',44,68,14,112),
	('2021-10-03 00:00:00','Platform 2','fighter',7,21,3,60),
	('2021-10-03 00:00:00','Platform 2','fighter',13,30,2,5),
	('2021-10-03 00:00:00','Platform 2','fighter',0,16,6,86),
	('2021-10-03 00:00:00','Platform 2','fighter',4,20,9,18),
	('2021-10-03 00:00:00','Platform 2','student',69,70,0,55),
	('2021-10-03 00:00:00','Platform 2','student',39,34,19,59),
	('2021-10-03 00:00:00','Platform 2','student',49,50,6,3);

SELECT * FROM table_5; --64 rows
