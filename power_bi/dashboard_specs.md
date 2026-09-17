# Power BI Dashboard Specification

**Project:** Bank Credit Risk Analysis  
**Tool:** Power BI  
**Focus:** Portfolio exposure, default patterns, borrower risk segmentation

## 1. Data Model

Use `credit_risk_dataset` as the main table. The Python analysis creates matching fields such as:

- Credit_Score_Bucket
- Income_Bracket
- DTI_Band
- Utilization_Band
- Risk_Tier
- Exposure_at_Default

The dataset has no date column, so time-intelligence measures such as MoM or YTD should not be added to this version of the dashboard.

## 2. Core DAX Measures

```dax
Total Customers =
COUNTROWS(credit_risk_dataset)

Total Exposure =
SUM(credit_risk_dataset[Total_Debt])

Defaulted Customers =
CALCULATE(
    COUNTROWS(credit_risk_dataset),
    credit_risk_dataset[Default_Status] = 1
)

Default Rate % =
DIVIDE([Defaulted Customers], [Total Customers], 0)

Defaulted Exposure =
CALCULATE(
    SUM(credit_risk_dataset[Total_Debt]),
    credit_risk_dataset[Default_Status] = 1
)

Average Credit Score =
AVERAGE(credit_risk_dataset[Credit_Score])

Average DTI % =
AVERAGE(credit_risk_dataset[Debt_to_Income_Ratio])

Average Utilization % =
AVERAGE(credit_risk_dataset[Credit_Utilization_Rate])

Total EAD =
SUM(credit_risk_dataset[Exposure_at_Default])

Illustrative Loss Estimate =
[Defaulted Exposure] * 0.65

Average Loss per Default =
DIVIDE([Illustrative Loss Estimate], [Defaulted Customers], 0)
```

The 65% loss assumption is only an illustrative portfolio-analysis assumption. It should not be presented as an actual bank regulatory provision or a real institution's LGD model.

## 3. Page 1 - Executive Overview

### KPI Cards

1. Total Customers
2. Total Exposure
3. Default Rate %
4. Defaulted Customers
5. Illustrative Loss Estimate

### Visuals

**1. Default Rate by Risk Tier**  
- Axis: `Risk_Tier`
- Values: `Default Rate %`

**2. Default Rate by Credit Score Bucket**  
- Axis: `Credit_Score_Bucket`
- Values: `Default Rate %`

**3. Exposure by Loan Purpose**  
- Axis: `Loan_Purpose`
- Values: `Total Exposure`

**4. Default Rate by Employment Status**  
- Axis: `Employment_Status`
- Values: `Default Rate %`

**5. Credit Score vs Utilization**  
- X-axis: `Credit_Score`
- Y-axis: `Credit_Utilization_Rate`
- Legend: `Default_Status`
- Size: `Total_Debt`

## 4. Page 2 - Risk Analysis

### Slicers

- Employment Status
- Credit Score Bucket
- Risk Tier
- Loan Purpose
- DTI Band
- Utilization Band

### Visuals

**1. Default Rate by DTI Band**  
Shows how observed default rates differ across DTI ranges.

**2. Default Rate by Utilization Band**  
Shows observed default rates across utilization ranges.

**3. Income Bracket × Loan Purpose Matrix**  
- Rows: `Income_Bracket`
- Columns: `Loan_Purpose`
- Values: `Default Rate %`

**4. High-Risk Customer Table**  
Include:
- Customer_ID
- Credit_Score
- Debt_to_Income_Ratio
- Credit_Utilization_Rate
- Late_Payments_30_Days
- Late_Payments_90_Days
- Total_Debt
- Risk_Tier
- Default_Status

Sort by 90-day late payments, DTI and utilization.

## 5. Suggested Formatting

- Keep the dashboard clean and simple.
- Use consistent number formatting for currency and percentages.
- Use a small number of colors and reserve stronger colors for risk indicators.
- Keep slicers in one area so the main visuals remain easy to read.
- Avoid unnecessary gauges and decorative visuals.
- Use clear titles such as `Default Rate by Credit Score` instead of technical names.

## 6. Business Questions Answered

The dashboard should help answer:

1. What is the overall default rate?
2. Which credit score groups have higher observed default rates?
3. Which employment groups show different default patterns?
4. Which loan purposes have higher observed default rates?
5. How do DTI and utilization relate to observed defaults?
6. Which borrowers fall into the defined high-risk tiers?
7. Where is the portfolio exposure concentrated?

## 7. Important Interpretation Note

This project uses a synthetic dataset for portfolio analysis. Dashboard findings describe patterns and associations in the dataset. They should not be interpreted as causal conclusions, actual bank policy recommendations, or regulatory capital calculations.
