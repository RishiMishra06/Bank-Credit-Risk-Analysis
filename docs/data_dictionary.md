# Credit Risk Dataset — Data Dictionary

The project uses a synthetic customer-level credit-risk dataset stored at `data/credit_risk_dataset.csv`.

| Column | Description |
|---|---|
| `Customer_ID` | Unique customer identifier |
| `Age` | Customer age |
| `Gender` | Customer gender category |
| `Annual_Income` | Annual customer income |
| `Employment_Status` | Employment category |
| `Credit_Score` | Credit score used for risk segmentation |
| `Total_Debt` | Current total debt |
| `Debt_to_Income_Ratio` | Debt relative to income |
| `Credit_Card_Limit` | Assigned revolving credit limit |
| `Credit_Utilization_Rate` | Portion of available credit currently utilized |
| `Late_Payments_30_Days` | Count of 30-day late-payment events |
| `Late_Payments_90_Days` | Count of 90-day late-payment events |
| `Default_Status` | Default indicator: 1 = default, 0 = non-default |
| `Loan_Purpose` | Stated purpose/category of the loan |

## Analytical fields created by the project

The Python and SQL layers derive additional analytical fields such as:

- Credit Score Bucket
- Income Bracket
- DTI Band
- Utilization Band
- Risk Tier
- Default Label

These derived fields are used for segmentation, KPI analysis and dashboard visuals.

## Data-quality considerations

The analysis checks for missing values, duplicate records, invalid numeric ranges and unexpected categorical values before using the data for downstream analysis.

## Data-use note

This is a portfolio/learning dataset. It is synthetic and should not be treated as real customer data or as a production credit-risk model.