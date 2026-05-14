# Real Estate Market Analysis — Bengaluru (2,000 Records)

A complete end-to-end data analysis project on a 2,000-record real estate dataset
using Python, SQL, Excel, and Power BI.

> **Dataset note:** The dataset is synthetically generated using realistic
> Bengaluru market distributions (location premiums, price ranges, property
> age effects) with `numpy.random.seed(42)` for reproducibility. All findings
> below are computed from this dataset and are clearly labelled as illustrative.

---

## Tools used

| Tool | Purpose |
|------|---------|
| **Python** (Pandas, Matplotlib, Seaborn) | EDA, feature engineering, 10 visualisations |
| **SQL — MySQL** (`real_estate_queries.sql`) | 28 queries: aggregations, window functions, seasonal trends |
| **SQL — SQL Server** (`RealEstate_SQL_Project.sql`) | DDL, views, stored procedures, indexes |
| **Excel** | Pivot tables, VLOOKUP, conditional formatting |
| **Power BI** | Interactive 6-page dashboard with slicers and KPI cards |
| **Jupyter Notebook** | Full EDA notebook + advanced ML notebook (XGBoost) |

---

## Project structure

```
real-estate-analysis/
├── real_estate_analysis.py          # Main Python EDA + 10 charts
├── real_estate_queries.sql          # 28 MySQL queries
├── RealEstate_SQL_Project.sql       # SQL Server DDL, views, stored procs
├── RealEstate_Analysis.ipynb        # Jupyter EDA notebook
├── RealEstate_Advanced_ML.ipynb     # ML notebook (4 models, 5 cities)
├── real_estate_cleaned.csv          # Cleaned 2,000-row dataset (20 columns)
├── RealEstate_PowerBI_Pack.xlsx     # Excel data for Power BI
├── dashboard/
│   └── real_final_done.pbix         # Power BI dashboard file
├── charts/
│   ├── 01_price_distribution.png
│   ├── 02_avg_price_by_location.png
│   ├── 03_price_vs_size.png
│   ├── 04_bedrooms_vs_price.png
│   ├── 05_property_type_pie.png
│   ├── 06_correlation_heatmap.png
│   ├── 07_seasonal_trends.png
│   ├── 08_days_on_market.png
│   ├── 09_price_per_sqft_type.png
│   └── 10_status_breakdown.png
└── README.md
```

---

## Key findings

All figures are computed directly from the dataset by `real_estate_analysis.py`.

1. **Koramangala** is the most expensive area — avg ₹193L vs ₹109L in BTM Layout
2. **BTM Layout** has the highest listing volume (227 properties), making it the most active market
3. Correlation between property size and price: **r = 0.70** — strong positive relationship
4. **Plots** sell fastest on average (93 days); Villas take longest (100 days) — a 6% difference
5. **4 BHK** configurations offer the best price-per-sqft value in the mid-range (₹50L–₹100L) segment
6. **Q3 (Jul–Sep)** sees the highest number of new listings — peak season for the market
7. Properties built **post-2015** command a ~3% price-per-sqft premium over older builds
8. **60%** of listed properties were sold; avg time on market for sold properties is **96 days**
9. **46.6%** of sold properties were sold within 90 days of listing
10. Overall avg price per sqft across Bengaluru: **₹6,480** (computed, not assumed)

---

## How to run

```bash
git clone https://github.com/rakshagowda291125-droid/real-estate-analysis.git
cd real-estate-analysis
pip install pandas numpy matplotlib seaborn jupyter
python real_estate_analysis.py
```

To open the notebooks:
```bash
jupyter notebook RealEstate_Analysis.ipynb
jupyter notebook RealEstate_Advanced_ML.ipynb
```

To run the SQL queries, import `real_estate_cleaned.csv` into a MySQL database
and execute `real_estate_queries.sql`. For the advanced SQL project (views,
stored procedures, indexes), use SQL Server and run `RealEstate_SQL_Project.sql`.

---

## Resume bullet points (copy-paste ready)

- Analysed 2,000 real estate records using Python (Pandas) to identify pricing
  trends, seasonal patterns, and location-based market insights across Bengaluru
- Built 10 Matplotlib/Seaborn visualisations including correlation heatmaps,
  price distribution charts, scatter plots, and violin plots
- Wrote 28 MySQL queries using window functions (RANK, NTILE, running totals)
  for price ranking, segmentation, days-on-market, and seasonal trend analysis
- Built an advanced SQL Server project with DDL constraints, 3 views, 2 stored
  procedures, and 3 performance indexes on a structured real estate schema
- Designed a 6-page interactive Power BI dashboard with slicers, KPI cards,
  and drill-through filters for executive-level market reporting
- Trained and compared 4 ML models (Linear Regression, Ridge, Random Forest,
  XGBoost) on a 2,000-record multi-city dataset with 14 engineered features
