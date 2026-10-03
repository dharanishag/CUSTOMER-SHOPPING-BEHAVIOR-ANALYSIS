import pandas as pd

df = pd.read_csv("customer_shopping_behavior.csv")

df['Review Rating'] = df.groupby('Category')['Review Rating'].transform(
    lambda x: x.fillna(x.median())
)

df.columns = df.columns.str.lower()
df.columns = df.columns.str.replace(' ', '_')

df = df.rename(columns={
    'purchase_amount_(usd)': 'purchase_amount'
})

labels = ['young adult', 'adult', 'middle aged', 'senior']

df['age_group'] = pd.qcut(
    df['age'],
    q=4,
    labels=labels
)

frequency_mapping = {
    'Fortnightly': 14,
    'Weekly': 7,
    'Monthly': 30,
    'Quarterly': 90,
    'Bi-Weekly': 14,
    'Annually': 365,
    'Every 3 Months': 90
}

df['purchase_frequency_days'] = (
    df['frequency_of_purchases'].map(frequency_mapping)
)

df = df.drop('promo_code_used', axis=1)

df.to_csv(
    "customer_shopping_behavior_cleaned.csv",
    index=False
)
