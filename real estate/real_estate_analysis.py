
# ═══════════════════════════════════════════════════════════════════
#  REAL ESTATE MARKET ANALYSIS — BENGALURU (2000 Records)
#  Python EDA + Visualisations
# ═══════════════════════════════════════════════════════════════════

# ── STEP 1: Import libraries ────────────────────────────────────────
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.ticker as mticker
import seaborn as sns
import warnings
warnings.filterwarnings('ignore')

sns.set_theme(style="whitegrid", palette="muted")
plt.rcParams['figure.figsize'] = (11, 5)
plt.rcParams['axes.titlesize']  = 14
plt.rcParams['axes.titleweight'] = 'bold'


# ── STEP 2: Load dataset ────────────────────────────────────────────
df = pd.read_csv('real_estate_cleaned.csv', parse_dates=['date_listed', 'date_sold'])

print("Dataset shape:", df.shape)
print("\nColumns:", df.columns.tolist())
print("\nFirst 5 rows:")
print(df.head())
print("\nData types:")
print(df.dtypes)


# ── STEP 3: Data validation & cleaning ─────────────────────────────
print("\n--- MISSING VALUES ---")
print(df.isnull().sum())

# Drop duplicate property IDs (safety check)
before = len(df)
df.drop_duplicates(subset='property_id', inplace=True)
print(f"\nDropped {before - len(df)} duplicate rows. Remaining: {len(df)}")

# Verify price_per_sqft is correct (₹/sqft)
# price_lakhs * 100,000 / area_sqft  →  ₹ per sqft
df['price_per_sqft'] = ((df['price_lakhs'] * 100_000) / df['area_sqft']).round(2)

# Derived columns (re-compute to be safe)
df['property_age']    = 2024 - df['year_built']
df['listing_month']   = df['date_listed'].dt.month
df['listing_quarter'] = df['date_listed'].dt.quarter
df['listing_year']    = df['date_listed'].dt.year
df['days_on_market']  = (df['date_sold'] - df['date_listed']).dt.days  # NaN for unsold

print("\nCleaned dataset shape:", df.shape)
print("\nSummary statistics:")
print(df[['price_lakhs', 'area_sqft', 'price_per_sqft',
          'bedrooms', 'days_on_market']].describe().round(2))


# ── STEP 4: CHART 1 — Price distributions ──────────────────────────
fig, axes = plt.subplots(1, 2, figsize=(14, 5))

axes[0].hist(df['price_lakhs'], bins=40, color='steelblue', edgecolor='white')
axes[0].set_title('Price Distribution (₹ Lakhs)')
axes[0].set_xlabel('Price (₹ Lakhs)')
axes[0].set_ylabel('Count')

axes[1].hist(df['price_per_sqft'], bins=40, color='teal', edgecolor='white')
axes[1].set_title('Price per Sqft Distribution (₹/sqft)')
axes[1].set_xlabel('₹ per sqft')
axes[1].set_ylabel('Count')
axes[1].xaxis.set_major_formatter(mticker.FuncFormatter(lambda x, _: f'₹{int(x):,}'))

plt.tight_layout()
plt.savefig('01_price_distribution.png', dpi=150)
plt.show()
print("Saved: 01_price_distribution.png")


# ── STEP 5: CHART 2 — Avg price by location ────────────────────────
avg_price_loc = (df.groupby('location')['price_lakhs']
                   .mean()
                   .sort_values(ascending=False))

plt.figure(figsize=(12, 5))
bars = plt.bar(avg_price_loc.index, avg_price_loc.values,
               color=sns.color_palette("Blues_d", len(avg_price_loc)))
plt.title('Average Property Price by Location (₹ Lakhs)')
plt.xlabel('Location')
plt.ylabel('Avg Price (₹ Lakhs)')
plt.xticks(rotation=30, ha='right')
for bar, val in zip(bars, avg_price_loc.values):
    plt.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.5,
             f'₹{val:.0f}L', ha='center', fontsize=9)
plt.tight_layout()
plt.savefig('02_avg_price_by_location.png', dpi=150)
plt.show()
print("Saved: 02_avg_price_by_location.png")


# ── STEP 6: CHART 3 — Price vs area (scatter) ──────────────────────
plt.figure(figsize=(10, 6))
scatter = plt.scatter(df['area_sqft'], df['price_lakhs'],
                      c=df['bedrooms'], cmap='viridis', alpha=0.5, s=15)
plt.colorbar(scatter, label='Bedrooms')
plt.title('Price vs Area (coloured by Bedrooms)')
plt.xlabel('Area (sqft)')
plt.ylabel('Price (₹ Lakhs)')
plt.tight_layout()
plt.savefig('03_price_vs_size.png', dpi=150)
plt.show()
print("Saved: 03_price_vs_size.png")


# ── STEP 7: CHART 4 — Avg price by bedrooms ────────────────────────
avg_price_bed = df.groupby('bedrooms')['price_lakhs'].mean()

plt.figure(figsize=(8, 5))
plt.plot(avg_price_bed.index, avg_price_bed.values,
         marker='o', color='coral', linewidth=2)
plt.title('Average Price by Number of Bedrooms')
plt.xlabel('Bedrooms')
plt.ylabel('Avg Price (₹ Lakhs)')
plt.xticks(avg_price_bed.index)
for x, y in zip(avg_price_bed.index, avg_price_bed.values):
    plt.annotate(f'₹{y:.0f}L', (x, y),
                 textcoords="offset points", xytext=(0, 8),
                 ha='center', fontsize=9)
plt.tight_layout()
plt.savefig('04_bedrooms_vs_price.png', dpi=150)
plt.show()
print("Saved: 04_bedrooms_vs_price.png")


# ── STEP 8: CHART 5 — Property type distribution ───────────────────
type_counts = df['property_type'].value_counts()
colors = sns.color_palette("pastel")
plt.figure(figsize=(7, 7))
plt.pie(type_counts.values, labels=type_counts.index,
        autopct='%1.1f%%', colors=colors, startangle=140)
plt.title('Property Type Distribution')
plt.tight_layout()
plt.savefig('05_property_type_pie.png', dpi=150)
plt.show()
print("Saved: 05_property_type_pie.png")


# ── STEP 9: CHART 6 — Correlation heatmap ──────────────────────────
plt.figure(figsize=(10, 7))
corr_cols = ['price_lakhs', 'area_sqft', 'bedrooms', 'bathrooms',
             'price_per_sqft', 'property_age', 'days_on_market', 'parking']
corr_df = df[corr_cols].dropna()
mask = np.triu(np.ones_like(corr_df.corr(), dtype=bool))
sns.heatmap(corr_df.corr(), annot=True, fmt='.2f', cmap='coolwarm',
            mask=mask, linewidths=0.5)
plt.title('Correlation Matrix')
plt.tight_layout()
plt.savefig('06_correlation_heatmap.png', dpi=150)
plt.show()
print("Saved: 06_correlation_heatmap.png")


# ── STEP 10: CHART 7 — Seasonal listing trends ─────────────────────
monthly = df.groupby('listing_month').size().reset_index(name='count')
month_names = ['Jan','Feb','Mar','Apr','May','Jun',
               'Jul','Aug','Sep','Oct','Nov','Dec']
monthly['month_name'] = monthly['listing_month'].apply(lambda x: month_names[x-1])

plt.figure(figsize=(12, 5))
plt.bar(monthly['month_name'], monthly['count'], color='mediumpurple')
plt.title('Property Listings by Month (Seasonal Trends)')
plt.xlabel('Month')
plt.ylabel('Number of Listings')
plt.tight_layout()
plt.savefig('07_seasonal_trends.png', dpi=150)
plt.show()
print("Saved: 07_seasonal_trends.png")


# ── STEP 11: CHART 8 — Days on market boxplot ──────────────────────
sold_df = df[df['status'] == 'Sold'].dropna(subset=['days_on_market'])
plt.figure(figsize=(12, 5))
sns.boxplot(data=sold_df, x='location', y='days_on_market', palette='Set2')
plt.title('Days on Market by Location (Sold Properties)')
plt.xlabel('Location')
plt.ylabel('Days on Market')
plt.xticks(rotation=30, ha='right')
plt.tight_layout()
plt.savefig('08_days_on_market.png', dpi=150)
plt.show()
print("Saved: 08_days_on_market.png")


# ── STEP 12: CHART 9 — Price per sqft by property type ─────────────
plt.figure(figsize=(9, 5))
sns.violinplot(data=df, x='property_type', y='price_per_sqft', palette='muted')
plt.title('Price per Sqft by Property Type (₹/sqft)')
plt.xlabel('Property Type')
plt.ylabel('₹ per sqft')
plt.gca().yaxis.set_major_formatter(mticker.FuncFormatter(lambda x, _: f'₹{int(x):,}'))
plt.tight_layout()
plt.savefig('09_price_per_sqft_type.png', dpi=150)
plt.show()
print("Saved: 09_price_per_sqft_type.png")


# ── STEP 13: CHART 10 — Status breakdown ───────────────────────────
status_counts = df['status'].value_counts()
plt.figure(figsize=(7, 4))
plt.barh(status_counts.index, status_counts.values,
         color=['#4CAF50', '#2196F3', '#FF9800'])
plt.title('Property Status Breakdown')
plt.xlabel('Count')
plt.tight_layout()
plt.savefig('10_status_breakdown.png', dpi=150)
plt.show()
print("Saved: 10_status_breakdown.png")


# ── STEP 14: KEY INSIGHTS ──────────────────────────────────────────
print("\n" + "="*60)
print("KEY INSIGHTS FROM THE DATASET")
print("="*60)

print(f"\n1. Most expensive area   : {avg_price_loc.idxmax()} "
      f"(avg ₹{avg_price_loc.max():.0f}L)")

print(f"\n2. Most affordable area  : {avg_price_loc.idxmin()} "
      f"(avg ₹{avg_price_loc.min():.0f}L)")

print(f"\n3. Avg price per sqft    : ₹{df['price_per_sqft'].mean():,.0f}")

print(f"\n4. Most common type      : {df['property_type'].value_counts().idxmax()}")

print(f"\n5. Avg days on market    : {sold_df['days_on_market'].mean():.0f} days")

fastest = sold_df.groupby('location')['days_on_market'].mean().idxmin()
print(f"\n6. Fastest selling area  : {fastest}")

corr_val = df['price_lakhs'].corr(df['area_sqft'])
print(f"\n7. Correlation price-size: {corr_val:.2f}")

pct_sold = (df['status'] == 'Sold').mean() * 100
print(f"\n8. % properties sold     : {pct_sold:.1f}%")

peak_month = monthly.loc[monthly['count'].idxmax(), 'month_name']
print(f"\n9. Peak listing month    : {peak_month}")

print(f"\n10. Most common bedrooms : {df['bedrooms'].value_counts().idxmax()} BHK")

# New post-2015 vs older premium
new_avg = df[df['year_built'] >= 2015]['price_per_sqft'].mean()
old_avg = df[df['year_built'] <  2015]['price_per_sqft'].mean()
premium = (new_avg - old_avg) / old_avg * 100
print(f"\n11. Post-2015 price premium: +{premium:.1f}% vs older properties")

# ── STEP 15: Export cleaned CSV ────────────────────────────────────
df.to_csv('real_estate_cleaned.csv', index=False)
print("\nCleaned data exported to: real_estate_cleaned.csv")
print("Use this CSV in Power BI, Tableau, or SQL.")
print("\nProject complete! ✓")
