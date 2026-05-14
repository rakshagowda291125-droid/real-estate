IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'RealEstateDB')
BEGIN
    CREATE DATABASE RealEstateDB;
    PRINT 'Database RealEstateDB created successfully.';
END
ELSE
BEGIN
    PRINT 'Database RealEstateDB already exists. Skipping creation.';
END
GO

USE RealEstateDB;
GO

IF OBJECT_ID('dbo.RealEstate', 'U') IS NOT NULL
    DROP TABLE dbo.RealEstate;
GO

CREATE TABLE dbo.RealEstate
(
    PropertyID      INT IDENTITY(1,1) PRIMARY KEY,  -- Auto-increment unique ID
    Price_Lakhs     DECIMAL(10, 2)  NOT NULL,        -- Price in Indian Lakhs (₹)
    Area_SqFt       INT             NOT NULL,        -- Property area in sq. ft.
    Bedrooms        TINYINT         NOT NULL,        -- Number of bedrooms
    Bathrooms       TINYINT         NOT NULL,        -- Number of bathrooms
    Location        VARCHAR(100)    NOT NULL,        -- Locality / Sub-area
    Property_Type   VARCHAR(50)     NOT NULL,        -- Villa / Apartment / Independent House
    Furnishing      VARCHAR(30)     NOT NULL,        -- Furnished / Semi-Furnished / Unfurnished
    Parking         TINYINT         NOT NULL DEFAULT 0, -- Number of parking spots
    Year_Built      SMALLINT        NOT NULL,        -- Year the property was constructed
    City            VARCHAR(50)     NOT NULL DEFAULT 'Bangalore', -- City name
    Price_Per_SqFt  AS (CAST(Price_Lakhs * 100000.0 / Area_SqFt AS DECIMAL(10, 2))),
                                                     -- Computed column (auto-calculated)
    InsertedAt      DATETIME        NOT NULL DEFAULT GETDATE() -- Audit timestamp
);
GO

PRINT 'Table dbo.RealEstate created successfully.';
GO

ALTER TABLE dbo.RealEstate
    ADD CONSTRAINT CK_Price_Positive
    CHECK (Price_Lakhs > 0);

ALTER TABLE dbo.RealEstate
    ADD CONSTRAINT CK_Area_Valid
    CHECK (Area_SqFt BETWEEN 100 AND 100000);

ALTER TABLE dbo.RealEstate
    ADD CONSTRAINT CK_Bedrooms_Valid
    CHECK (Bedrooms BETWEEN 1 AND 20);

ALTER TABLE dbo.RealEstate
    ADD CONSTRAINT CK_Bathrooms_Valid
    CHECK (Bathrooms BETWEEN 1 AND 20);

ALTER TABLE dbo.RealEstate
    ADD CONSTRAINT CK_Year_Built_Valid
    CHECK (Year_Built BETWEEN 1950 AND YEAR(GETDATE()));

ALTER TABLE dbo.RealEstate
    ADD CONSTRAINT CK_Property_Type_Valid
    CHECK (Property_Type IN ('Villa', 'Apartment', 'Independent House'));

ALTER TABLE dbo.RealEstate
    ADD CONSTRAINT CK_Furnishing_Valid
    CHECK (Furnishing IN ('Furnished', 'Semi-Furnished', 'Unfurnished'));

PRINT 'All constraints added successfully.';
GO

INSERT INTO dbo.RealEstate (Price_Lakhs, Area_SqFt, Bedrooms, Bathrooms, Location, Property_Type, Furnishing, Parking, Year_Built, City)
VALUES
-- Villas
(97.42,  1905, 2, 2, 'Yelahanka',    'Villa',              'Unfurnished',    2, 2008, 'Bangalore'),
(101.19, 2361, 4, 2, 'Whitefield',   'Independent House',  'Unfurnished',    1, 2008, 'Bangalore'),
(145.00, 3200, 4, 3, 'Koramangala',  'Villa',              'Furnished',      2, 2015, 'Bangalore'),
(178.50, 3900, 4, 4, 'Jayanagar',    'Villa',              'Semi-Furnished', 2, 2018, 'Bangalore'),
(155.75, 3500, 3, 3, 'HSR Layout',   'Villa',              'Furnished',      2, 2019, 'Bangalore'),


(81.54,  3991, 2, 3, 'Indiranagar',  'Independent House',  'Semi-Furnished', 0, 2022, 'Bangalore'),
(65.00,  2200, 3, 2, 'Rajajinagar',  'Independent House',  'Unfurnished',    1, 2005, 'Bangalore'),
(90.00,  2800, 4, 3, 'Banashankari', 'Independent House',  'Furnished',      2, 2012, 'Bangalore'),
(72.30,  2500, 3, 2, 'Malleshwaram', 'Independent House',  'Semi-Furnished', 1, 2010, 'Bangalore'),
(110.00, 3100, 4, 3, 'Sadashivanagar','Independent House', 'Furnished',      2, 2016, 'Bangalore'),

-- Apartments
(45.00,   900, 2, 1, 'Electronic City', 'Apartment',       'Semi-Furnished', 1, 2017, 'Bangalore'),
(38.50,   750, 1, 1, 'Marathahalli',    'Apartment',       'Furnished',      0, 2020, 'Bangalore'),
(62.00,  1350, 3, 2, 'Hebbal',          'Apartment',       'Unfurnished',    1, 2014, 'Bangalore'),
(55.00,  1100, 2, 2, 'Bellandur',       'Apartment',       'Semi-Furnished', 1, 2018, 'Bangalore'),
(25.00,   603, 1, 1, 'Yelahanka New Town','Apartment',     'Unfurnished',    0, 1995, 'Bangalore'),
(181.32, 3993, 4, 4, 'MG Road',         'Apartment',       'Furnished',      2, 2023, 'Bangalore'),
(78.00,  1800, 3, 2, 'JP Nagar',        'Apartment',       'Furnished',      1, 2016, 'Bangalore'),
(95.00,  2100, 3, 2, 'Sarjapur Road',   'Apartment',       'Semi-Furnished', 2, 2019, 'Bangalore'),
(42.00,   850, 2, 1, 'Hennur',          'Apartment',       'Unfurnished',    1, 2021, 'Bangalore'),
(130.00, 2700, 4, 3, 'Cunningham Road', 'Apartment',       'Furnished',      2, 2020, 'Bangalore');

PRINT '20 sample rows inserted successfully.';
GO


SELECT
    SUM(CASE WHEN Price_Lakhs   IS NULL THEN 1 ELSE 0 END) AS Null_Price,
    SUM(CASE WHEN Area_SqFt     IS NULL THEN 1 ELSE 0 END) AS Null_Area,
    SUM(CASE WHEN Bedrooms      IS NULL THEN 1 ELSE 0 END) AS Null_Bedrooms,
    SUM(CASE WHEN Location      IS NULL THEN 1 ELSE 0 END) AS Null_Location,
    SUM(CASE WHEN Property_Type IS NULL THEN 1 ELSE 0 END) AS Null_PropertyType,
    SUM(CASE WHEN Furnishing    IS NULL THEN 1 ELSE 0 END) AS Null_Furnishing
FROM dbo.RealEstate;
GO


SELECT
    Price_Lakhs, Area_SqFt, Location, Year_Built,
    COUNT(*) AS Duplicate_Count
FROM dbo.RealEstate
GROUP BY Price_Lakhs, Area_SqFt, Location, Year_Built
HAVING COUNT(*) > 1;
GO

SELECT *
FROM dbo.RealEstate
WHERE Price_Lakhs < 10 OR Price_Lakhs > 500;
GO

SELECT PropertyID, Bedrooms, Bathrooms, Location, Property_Type
FROM dbo.RealEstate
WHERE Bathrooms > Bedrooms + 2;
GO

SELECT
    COUNT(*)                                    AS Total_Records,
    COUNT(DISTINCT Location)                    AS Unique_Locations,
    COUNT(DISTINCT Property_Type)               AS Property_Types,
    MIN(Price_Lakhs)                            AS Min_Price_Lakhs,
    MAX(Price_Lakhs)                            AS Max_Price_Lakhs,
    MIN(Year_Built)                             AS Oldest_Property,
    MAX(Year_Built)                             AS Newest_Property
FROM dbo.RealEstate;
GO



SELECT
    COUNT(*)                            AS Total_Properties,
    ROUND(AVG(Price_Lakhs), 2)          AS Avg_Price_Lakhs,
    ROUND(MIN(Price_Lakhs), 2)          AS Min_Price_Lakhs,
    ROUND(MAX(Price_Lakhs), 2)          AS Max_Price_Lakhs,
    ROUND(STDEV(Price_Lakhs), 2)        AS StdDev_Price,
    ROUND(AVG(Area_SqFt), 0)            AS Avg_Area_SqFt
FROM dbo.RealEstate;
GO

-- 6.2 Distribution by property type
SELECT
    Property_Type,
    COUNT(*)                            AS Total_Count,
    ROUND(AVG(Price_Lakhs), 2)          AS Avg_Price_Lakhs,
    ROUND(MIN(Price_Lakhs), 2)          AS Min_Price,
    ROUND(MAX(Price_Lakhs), 2)          AS Max_Price,
    ROUND(AVG(CAST(Area_SqFt AS FLOAT)), 0) AS Avg_Area_SqFt
FROM dbo.RealEstate
GROUP BY Property_Type
ORDER BY Avg_Price_Lakhs DESC;
GO

-- 6.3 Price breakdown by number of bedrooms
SELECT
    Bedrooms,
    COUNT(*)                            AS Total_Properties,
    ROUND(AVG(Price_Lakhs), 2)          AS Avg_Price_Lakhs,
    ROUND(MIN(Price_Lakhs), 2)          AS Min_Price,
    ROUND(MAX(Price_Lakhs), 2)          AS Max_Price
FROM dbo.RealEstate
GROUP BY Bedrooms
ORDER BY Bedrooms;
GO

-- 6.4 Furnishing status distribution
SELECT
    Furnishing,
    COUNT(*)                            AS Total_Properties,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Percentage,
    ROUND(AVG(Price_Lakhs), 2)          AS Avg_Price_Lakhs
FROM dbo.RealEstate
GROUP BY Furnishing
ORDER BY Total_Properties DESC;
GO

-- 6.5 Properties built per decade
SELECT
    (Year_Built / 10) * 10              AS Decade,
    COUNT(*)                            AS Properties_Built,
    ROUND(AVG(Price_Lakhs), 2)          AS Avg_Price_Lakhs
FROM dbo.RealEstate
GROUP BY (Year_Built / 10) * 10
ORDER BY Decade;
GO

-- 6.6 Top 10 locations by number of listings
SELECT TOP 10
    Location,
    COUNT(*)                            AS Total_Listings,
    ROUND(AVG(Price_Lakhs), 2)          AS Avg_Price_Lakhs,
    ROUND(AVG(Price_Per_SqFt), 2)       AS Avg_Price_Per_SqFt
FROM dbo.RealEstate
GROUP BY Location
ORDER BY Total_Listings DESC;
GO


-- 7.1 Most expensive locations (top 5 by average price)
SELECT TOP 5
    Location,
    ROUND(AVG(Price_Lakhs), 2)          AS Avg_Price_Lakhs,
    COUNT(*)                            AS Total_Properties
FROM dbo.RealEstate
GROUP BY Location
ORDER BY Avg_Price_Lakhs DESC;
GO

-- 7.2 Best value properties — high area, low price per sq. ft.
SELECT TOP 10
    PropertyID,
    Location,
    Property_Type,
    Bedrooms,
    Area_SqFt,
    Price_Lakhs,
    Price_Per_SqFt
FROM dbo.RealEstate
ORDER BY Price_Per_SqFt ASC;
GO

-- 7.3 Price segmentation — Affordable / Mid-range / Premium / Luxury
SELECT
    CASE
        WHEN Price_Lakhs < 50             THEN 'Affordable   (< 50L)'
        WHEN Price_Lakhs BETWEEN 50 AND 100 THEN 'Mid-Range  (50L – 1Cr)'
        WHEN Price_Lakhs BETWEEN 100 AND 150 THEN 'Premium  (1Cr – 1.5Cr)'
        ELSE                                   'Luxury     (> 1.5Cr)'
    END AS Price_Segment,
    COUNT(*)                            AS Total_Properties,
    ROUND(AVG(Price_Lakhs), 2)          AS Avg_Price_Lakhs,
    ROUND(AVG(Price_Per_SqFt), 2)       AS Avg_Price_Per_SqFt
FROM dbo.RealEstate
GROUP BY
    CASE
        WHEN Price_Lakhs < 50             THEN 'Affordable   (< 50L)'
        WHEN Price_Lakhs BETWEEN 50 AND 100 THEN 'Mid-Range  (50L – 1Cr)'
        WHEN Price_Lakhs BETWEEN 100 AND 150 THEN 'Premium  (1Cr – 1.5Cr)'
        ELSE                                   'Luxury     (> 1.5Cr)'
    END
ORDER BY Avg_Price_Lakhs;
GO


SELECT
    Parking                             AS Parking_Spots,
    COUNT(*)                            AS Total_Properties,
    ROUND(AVG(Price_Lakhs), 2)          AS Avg_Price_Lakhs,
    ROUND(AVG(Area_SqFt), 0)            AS Avg_Area_SqFt
FROM dbo.RealEstate
GROUP BY Parking
ORDER BY Parking;
GO


SELECT
    CASE
        WHEN YEAR(GETDATE()) - Year_Built <= 5  THEN '0-5 Years (New)'
        WHEN YEAR(GETDATE()) - Year_Built <= 10 THEN '6-10 Years'
        WHEN YEAR(GETDATE()) - Year_Built <= 20 THEN '11-20 Years'
        ELSE                                        '20+ Years (Old)'
    END AS Property_Age,
    COUNT(*)                            AS Total_Properties,
    ROUND(AVG(Price_Lakhs), 2)          AS Avg_Price_Lakhs,
    ROUND(AVG(Price_Per_SqFt), 2)       AS Avg_Price_Per_SqFt
FROM dbo.RealEstate
GROUP BY
    CASE
        WHEN YEAR(GETDATE()) - Year_Built <= 5  THEN '0-5 Years (New)'
        WHEN YEAR(GETDATE()) - Year_Built <= 10 THEN '6-10 Years'
        WHEN YEAR(GETDATE()) - Year_Built <= 20 THEN '11-20 Years'
        ELSE                                        '20+ Years (Old)'
    END
ORDER BY Avg_Price_Lakhs DESC;
GO

SELECT
    CAST(Bedrooms AS VARCHAR) + 'BHK'   AS BHK_Config,
    COUNT(*)                            AS Total_Properties,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS Market_Share_Pct,
    ROUND(AVG(Price_Lakhs), 2)          AS Avg_Price_Lakhs
FROM dbo.RealEstate
GROUP BY Bedrooms
ORDER BY Bedrooms;
GO


SELECT
    PropertyID,
    Location,
    Property_Type,
    Bedrooms,
    Price_Lakhs,
    RANK() OVER (PARTITION BY Property_Type ORDER BY Price_Lakhs DESC) AS Rank_In_Type,
    ROUND(AVG(Price_Lakhs) OVER (PARTITION BY Property_Type), 2)      AS Avg_Type_Price,
    ROUND(Price_Lakhs - AVG(Price_Lakhs) OVER (PARTITION BY Property_Type), 2)
                                                                       AS Diff_From_Avg
FROM dbo.RealEstate
ORDER BY Property_Type, Rank_In_Type;
GO

SELECT
    Year_Built,
    COUNT(*)                            AS New_Listings,
    SUM(COUNT(*)) OVER (ORDER BY Year_Built ROWS UNBOUNDED PRECEDING)
                                        AS Cumulative_Listings
FROM dbo.RealEstate
GROUP BY Year_Built
ORDER BY Year_Built;
GO


SELECT
    PropertyID,
    Location,
    Price_Lakhs,
    NTILE(4) OVER (ORDER BY Price_Lakhs) AS Price_Quartile  -- 1=Lowest, 4=Highest
FROM dbo.RealEstate
ORDER BY Price_Lakhs;
GO


CREATE OR ALTER VIEW vw_PropertySummary AS
SELECT
    PropertyID,
    Location,
    City,
    Property_Type,
    Bedrooms,
    Bathrooms,
    Area_SqFt,
    Furnishing,
    Parking,
    Year_Built,
    YEAR(GETDATE()) - Year_Built        AS Property_Age_Years,
    Price_Lakhs,
    Price_Per_SqFt,
    CASE
        WHEN Price_Lakhs < 50             THEN 'Affordable'
        WHEN Price_Lakhs BETWEEN 50 AND 100 THEN 'Mid-Range'
        WHEN Price_Lakhs BETWEEN 100 AND 150 THEN 'Premium'
        ELSE                                   'Luxury'
    END AS Price_Segment
FROM dbo.RealEstate;
GO

-- View 2: Location-level aggregated stats (useful for map visuals)
CREATE OR ALTER VIEW vw_LocationStats AS
SELECT
    Location,
    City,
    COUNT(*)                            AS Total_Properties,
    ROUND(AVG(Price_Lakhs), 2)          AS Avg_Price_Lakhs,
    ROUND(MIN(Price_Lakhs), 2)          AS Min_Price,
    ROUND(MAX(Price_Lakhs), 2)          AS Max_Price,
    ROUND(AVG(Price_Per_SqFt), 2)       AS Avg_Price_Per_SqFt,
    ROUND(AVG(CAST(Area_SqFt AS FLOAT)), 0) AS Avg_Area_SqFt,
    ROUND(AVG(CAST(Bedrooms AS FLOAT)), 1)  AS Avg_Bedrooms
FROM dbo.RealEstate
GROUP BY Location, City;
GO

-- View 3: Property type comparison
CREATE OR ALTER VIEW vw_PropertyTypeComparison AS
SELECT
    Property_Type,
    Furnishing,
    Bedrooms,
    COUNT(*)                            AS Total_Properties,
    ROUND(AVG(Price_Lakhs), 2)          AS Avg_Price,
    ROUND(AVG(Area_SqFt), 0)            AS Avg_Area,
    ROUND(AVG(Price_Per_SqFt), 2)       AS Avg_Price_Per_SqFt
FROM dbo.RealEstate
GROUP BY Property_Type, Furnishing, Bedrooms;
GO

PRINT 'All views created successfully.';
GO



-- SP 1: Search properties by filters (simulates a property search portal)
CREATE OR ALTER PROCEDURE sp_SearchProperties
    @MinPrice       DECIMAL(10,2) = 0,
    @MaxPrice       DECIMAL(10,2) = 9999999,
    @MinBedrooms    TINYINT       = 1,
    @PropertyType   VARCHAR(50)   = NULL,
    @Furnishing     VARCHAR(30)   = NULL,
    @Location       VARCHAR(100)  = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        PropertyID,
        Location,
        Property_Type,
        Bedrooms,
        Bathrooms,
        Area_SqFt,
        Furnishing,
        Parking,
        Year_Built,
        Price_Lakhs,
        Price_Per_SqFt,
        Price_Segment
    FROM vw_PropertySummary
    WHERE
        Price_Lakhs   BETWEEN @MinPrice AND @MaxPrice
        AND Bedrooms  >= @MinBedrooms
        AND (@PropertyType IS NULL OR Property_Type = @PropertyType)
        AND (@Furnishing   IS NULL OR Furnishing    = @Furnishing)
        AND (@Location     IS NULL OR Location LIKE '%' + @Location + '%')
    ORDER BY Price_Lakhs ASC;
END;
GO


CREATE OR ALTER PROCEDURE sp_LocationReport
    @Location VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.RealEstate WHERE Location LIKE '%' + @Location + '%')
    BEGIN
        PRINT 'No properties found for the given location.';
        RETURN;
    END

    SELECT
        Location,
        COUNT(*)                        AS Total_Properties,
        ROUND(AVG(Price_Lakhs), 2)      AS Avg_Price_Lakhs,
        ROUND(MIN(Price_Lakhs), 2)      AS Cheapest_Property,
        ROUND(MAX(Price_Lakhs), 2)      AS Most_Expensive,
        ROUND(AVG(Price_Per_SqFt), 2)   AS Avg_Price_Per_SqFt,
        ROUND(AVG(CAST(Area_SqFt AS FLOAT)), 0) AS Avg_Area_SqFt,
        ROUND(AVG(CAST(Bedrooms AS FLOAT)), 1)  AS Avg_Bedrooms
    FROM dbo.RealEstate
    WHERE Location LIKE '%' + @Location + '%'
    GROUP BY Location;
END;
GO

PRINT 'Stored procedures created successfully.';
GO


CREATE NONCLUSTERED INDEX IX_RealEstate_Location
    ON dbo.RealEstate (Location)
    INCLUDE (Price_Lakhs, Area_SqFt, Bedrooms);

CREATE NONCLUSTERED INDEX IX_RealEstate_PropertyType
    ON dbo.RealEstate (Property_Type)
    INCLUDE (Price_Lakhs, Furnishing, Bedrooms);


CREATE NONCLUSTERED INDEX IX_RealEstate_Price
    ON dbo.RealEstate (Price_Lakhs ASC);

PRINT 'Indexes created successfully.';
GO


SELECT TOP 5 * FROM dbo.RealEstate;
GO


SELECT TOP 5 * FROM vw_PropertySummary;
GO

SELECT TOP 5 * FROM vw_LocationStats ORDER BY Total_Properties DESC;
GO


EXEC sp_SearchProperties
    @MinPrice     = 0,
    @MaxPrice     = 60,
    @MinBedrooms  = 2,
    @PropertyType = 'Apartment';
GO


EXEC sp_LocationReport @Location = 'Koramangala';
GO

PRINT '============================================================';
PRINT ' Real Estate SQL Project setup is COMPLETE!';
PRINT ' Database  : RealEstateDB';
PRINT ' Table     : dbo.RealEstate';
PRINT ' Views     : vw_PropertySummary, vw_LocationStats,';
PRINT '             vw_PropertyTypeComparison';
PRINT ' Procedures: sp_SearchProperties, sp_LocationReport';
PRINT ' Indexes   : 3 performance indexes applied';
PRINT '============================================================';
GO
