-- ============================================================
-- REAL ESTATE PROJECT — SQL QUERIES
-- Database : real_estate_db
-- Table    : real_estate
-- Dataset  : 2000 records — Bengaluru property market
-- ============================================================

-- ── CREATE TABLE ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS real_estate (
    property_id      INT PRIMARY KEY,
    location         VARCHAR(100),
    property_type    VARCHAR(50),
    bedrooms         INT,
    bathrooms        INT,
    area_sqft        INT,
    price_lakhs      DECIMAL(10,2),
    price_per_sqft   DECIMAL(10,2),   -- ₹ per sqft (price_lakhs*100000/area_sqft)
    year_built       INT,
    property_age     INT,             -- 2024 - year_built
    status           VARCHAR(30),     -- Sold / Available / Under Negotiation
    furnishing       VARCHAR(30),     -- Furnished / Semi-Furnished / Unfurnished
    parking          INT,             -- 0, 1, or 2 parking slots
    city             VARCHAR(50),
    date_listed      DATE,
    date_sold        DATE,            -- NULL for unsold properties
    days_on_market   INT,             -- NULL for unsold properties
    listing_month    INT,
    listing_quarter  INT,
    listing_year     INT
);

-- ── BASIC EXPLORATION ───────────────────────────────────────────────

-- Total records
SELECT COUNT(*) AS total_properties FROM real_estate;

-- Records by status with percentage
SELECT
    status,
    COUNT(*)  AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct
FROM real_estate
GROUP BY status
ORDER BY count DESC;

-- Property type distribution
SELECT
    property_type,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct
FROM real_estate
GROUP BY property_type
ORDER BY count DESC;

-- Furnishing breakdown
SELECT furnishing, COUNT(*) AS count
FROM real_estate
GROUP BY furnishing
ORDER BY count DESC;


-- ── PRICE ANALYSIS ──────────────────────────────────────────────────

-- Overall price stats (price in ₹ Lakhs; price_per_sqft in ₹/sqft)
SELECT
    ROUND(AVG(price_lakhs), 2)                AS avg_price_lakhs,
    MIN(price_lakhs)                          AS min_price_lakhs,
    MAX(price_lakhs)                          AS max_price_lakhs,
    ROUND(AVG(price_per_sqft), 0)             AS avg_price_per_sqft
FROM real_estate;

-- Average price by location (highest first)
SELECT
    location,
    COUNT(*)                              AS total_listings,
    ROUND(AVG(price_lakhs), 2)            AS avg_price_lakhs,
    ROUND(AVG(price_per_sqft), 0)         AS avg_price_per_sqft,
    MIN(price_lakhs)                      AS min_price_lakhs,
    MAX(price_lakhs)                      AS max_price_lakhs
FROM real_estate
GROUP BY location
ORDER BY avg_price_lakhs DESC;

-- Top 10 most expensive properties
SELECT
    property_id, location, property_type, bedrooms,
    area_sqft, price_lakhs, price_per_sqft
FROM real_estate
ORDER BY price_lakhs DESC
LIMIT 10;

-- Price ranking within each location (window function)
SELECT
    property_id,
    location,
    price_lakhs,
    price_per_sqft,
    RANK() OVER (PARTITION BY location ORDER BY price_lakhs DESC) AS price_rank_in_area
FROM real_estate;

-- Price bucket segmentation (in ₹ Lakhs)
SELECT
    CASE
        WHEN price_lakhs < 50   THEN 'Under 50L'
        WHEN price_lakhs < 100  THEN '50L – 1Cr'
        WHEN price_lakhs < 150  THEN '1Cr – 1.5Cr'
        WHEN price_lakhs < 200  THEN '1.5Cr – 2Cr'
        ELSE                         'Above 2Cr'
    END              AS price_bucket,
    COUNT(*)         AS count,
    ROUND(AVG(price_per_sqft), 0) AS avg_ppsf
FROM real_estate
GROUP BY price_bucket
ORDER BY MIN(price_lakhs);


-- ── LOCATION ANALYSIS ───────────────────────────────────────────────

-- Top 5 locations by number of listings
SELECT location, COUNT(*) AS listings
FROM real_estate
GROUP BY location
ORDER BY listings DESC
LIMIT 5;

-- Best-value locations (lowest avg price per sqft)
SELECT
    location,
    ROUND(AVG(price_per_sqft), 0) AS avg_price_per_sqft
FROM real_estate
GROUP BY location
ORDER BY avg_price_per_sqft ASC;

-- Location × property type breakdown
SELECT
    location, property_type, COUNT(*) AS count
FROM real_estate
GROUP BY location, property_type
ORDER BY location, count DESC;

-- Premium vs affordable segments per location
SELECT
    location,
    COUNT(CASE WHEN price_lakhs >= 150 THEN 1 END) AS luxury_count,
    COUNT(CASE WHEN price_lakhs < 75   THEN 1 END) AS affordable_count
FROM real_estate
GROUP BY location
ORDER BY luxury_count DESC;


-- ── BEDROOM & PROPERTY ANALYSIS ─────────────────────────────────────

-- Average price and size by bedroom count
SELECT
    bedrooms,
    COUNT(*)                       AS total,
    ROUND(AVG(price_lakhs), 2)     AS avg_price_lakhs,
    ROUND(AVG(price_per_sqft), 0)  AS avg_price_per_sqft,
    ROUND(AVG(area_sqft), 0)       AS avg_area_sqft
FROM real_estate
GROUP BY bedrooms
ORDER BY bedrooms;

-- Most common bedroom + location combination
SELECT location, bedrooms, COUNT(*) AS count
FROM real_estate
GROUP BY location, bedrooms
ORDER BY count DESC
LIMIT 10;

-- Furnishing impact on price per sqft
SELECT
    furnishing,
    COUNT(*)                      AS count,
    ROUND(AVG(price_lakhs), 2)    AS avg_price_lakhs,
    ROUND(AVG(price_per_sqft), 0) AS avg_price_per_sqft
FROM real_estate
GROUP BY furnishing
ORDER BY avg_price_per_sqft DESC;

-- Parking vs price
SELECT
    parking,
    COUNT(*)                      AS count,
    ROUND(AVG(price_lakhs), 2)    AS avg_price_lakhs
FROM real_estate
GROUP BY parking
ORDER BY parking;


-- ── MARKET & DAYS-ON-MARKET ANALYSIS ────────────────────────────────

-- Days on market for sold properties by location
SELECT
    location,
    ROUND(AVG(days_on_market), 0)  AS avg_days_on_market,
    MIN(days_on_market)            AS fastest_sale,
    MAX(days_on_market)            AS slowest_sale
FROM real_estate
WHERE status = 'Sold'
  AND days_on_market IS NOT NULL
GROUP BY location
ORDER BY avg_days_on_market ASC;

-- Fastest-selling property type
SELECT
    property_type,
    ROUND(AVG(days_on_market), 0) AS avg_days_to_sell
FROM real_estate
WHERE status = 'Sold'
  AND days_on_market IS NOT NULL
GROUP BY property_type
ORDER BY avg_days_to_sell ASC;

-- Properties sold within 90 days (percentage)
SELECT
    ROUND(
        SUM(CASE WHEN days_on_market <= 90 THEN 1 ELSE 0 END) * 100.0
        / COUNT(*), 1
    ) AS pct_sold_within_90_days
FROM real_estate
WHERE status = 'Sold'
  AND days_on_market IS NOT NULL;


-- ── SEASONAL TRENDS ─────────────────────────────────────────────────

-- Listings by month
SELECT
    listing_month                       AS month_num,
    MONTHNAME(date_listed)              AS month_name,
    COUNT(*)                            AS listings,
    ROUND(AVG(price_lakhs), 2)          AS avg_price_lakhs
FROM real_estate
GROUP BY listing_month, MONTHNAME(date_listed)
ORDER BY month_num;

-- Listings by quarter
SELECT
    listing_quarter  AS quarter,
    COUNT(*)         AS listings,
    ROUND(AVG(price_lakhs), 2) AS avg_price_lakhs
FROM real_estate
GROUP BY listing_quarter
ORDER BY quarter;

-- Year-over-year listing volume
SELECT
    listing_year                AS year,
    COUNT(*)                    AS total_listings,
    ROUND(AVG(price_lakhs), 2)  AS avg_price_lakhs
FROM real_estate
GROUP BY listing_year
ORDER BY year;


-- ── ADVANCED / WINDOW FUNCTION QUERIES ──────────────────────────────

-- Properties priced above their area's average
SELECT
    r.property_id,
    r.location,
    r.price_lakhs,
    ROUND(loc_avg.avg_loc_price, 2) AS area_avg_price_lakhs,
    ROUND(r.price_lakhs - loc_avg.avg_loc_price, 2) AS premium_over_avg
FROM real_estate r
JOIN (
    SELECT location, AVG(price_lakhs) AS avg_loc_price
    FROM real_estate
    GROUP BY location
) loc_avg ON r.location = loc_avg.location
WHERE r.price_lakhs > loc_avg.avg_loc_price
ORDER BY r.location, r.price_lakhs DESC;

-- Running total of listings by month
SELECT
    listing_year   AS year,
    listing_month  AS month,
    COUNT(*)       AS monthly_listings,
    SUM(COUNT(*)) OVER (
        ORDER BY listing_year, listing_month
    )              AS running_total
FROM real_estate
GROUP BY listing_year, listing_month;

-- Price quartile per location using NTILE
SELECT
    property_id,
    location,
    price_lakhs,
    price_per_sqft,
    NTILE(4) OVER (PARTITION BY location ORDER BY price_lakhs) AS price_quartile
FROM real_estate;

-- Avg price per sqft by property age decade
SELECT
    CONCAT(FLOOR(property_age / 10) * 10, 's') AS age_decade,
    COUNT(*)                                    AS count,
    ROUND(AVG(price_per_sqft), 0)               AS avg_price_per_sqft,
    ROUND(AVG(price_lakhs), 2)                  AS avg_price_lakhs
FROM real_estate
GROUP BY FLOOR(property_age / 10)
ORDER BY FLOOR(property_age / 10);

-- New (post-2015) vs older property price premium
SELECT
    CASE WHEN year_built >= 2015 THEN 'Post-2015' ELSE 'Pre-2015' END AS era,
    COUNT(*)                              AS count,
    ROUND(AVG(price_per_sqft), 0)         AS avg_price_per_sqft,
    ROUND(AVG(price_lakhs), 2)            AS avg_price_lakhs
FROM real_estate
GROUP BY era
ORDER BY era DESC;
