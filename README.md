# Bank Credit Risk Analysis

### End-to-End Data Analytics Project using Python, SQL & Power BI

## Project Overview

Bank Credit Risk Analysis is an end-to-end Data Analyst portfolio project that analyzes customer credit, debt, utilization, delinquency and default information to identify segments with different observed risk levels.

```text
Raw CSV Data
     ↓
Python Data Cleaning & EDA
     ↓
PostgreSQL SQL Analysis
     ↓
Power BI Dashboard
     ↓
Business Insights
```

### Business Questions

- What is the overall default rate?
- How do default rates vary across credit-score groups?
- How are DTI and credit utilization associated with default status?
- Do employment groups and loan purposes show different default patterns?
- Which customers fall into the high-risk segment based on the analytical rules used in this project?

> **Note:** This repository uses a synthetic dataset for portfolio and learning purposes. It does not contain real bank customer information. Risk tiers and any loss assumptions are analytical examples, not production or regulatory credit models.

## Tools & Technologies

| Tool | Purpose |
|---|---|
| Python | Data cleaning, validation, feature engineering, EDA and charts |
| Pandas / NumPy | Data manipulation and analytical calculations |
| Matplotlib | Data visualization |
| PostgreSQL / SQL | Data quality checks, segmentation and analysis |
| Power BI | Interactive dashboard and reporting |
| DAX | KPI measures and calculated analytics |
| GitHub | Version control and documentation |

## Dataset

Main dataset:

`data/credit_risk_dataset.csv`

The dataset contains customer ID, demographics, income, employment status, credit score, debt, DTI, credit-card utilization, late payments, default status and loan purpose.

See `docs/data_dictionary.md` for field definitions.

## Python Analysis

Script:

`python/bank_credit_risk_eda.py`

The script performs:

- Data loading and column cleanup
- Duplicate and missing-value checks
- Numeric validation
- Credit-score, income, DTI and utilization bucketing
- Risk-tier classification
- Portfolio KPI calculation
- Segment-level summaries
- High-risk customer identification
- Analytical chart generation

Running the script creates the `outputs/` directory with summary CSV files and charts.

## SQL Analysis

SQL file:

`sql/credit_risk_analysis.sql`

It covers:

- Data-quality checks
- Feature engineering
- Risk-tier classification
- Portfolio KPIs
- Default analysis by credit score, employment and loan purpose
- DTI and utilization analysis
- Window functions
- High-risk customer analysis
- Delinquency analysis
- Business summary by risk tier

## Power BI Dashboard

The dashboard specification is available in:

`power_bi/dashboard_specs.md`

### Page 1 — Executive Overview

- Total Customers
- Total Exposure
- Defaulted Customers
- Default Rate
- Default Rate by Risk Tier
- Default Rate by Credit Score
- Exposure by Loan Purpose
- Default Rate by Employment Status
- Credit Score vs Credit Utilization

### Page 2 — Risk Analysis

- Employment Status slicer
- Credit Score Bucket slicer
- Loan Purpose slicer
- Risk Tier slicer
- DTI analysis
- Utilization analysis
- Delinquency analysis
- High-risk customer table

## Risk-Tier Logic

The same simple analytical rules are used in Python and SQL:

- **High:** credit score below 600, or DTI above 45%, or utilization above 80%, or at least one 90-day late payment.
- **Medium:** otherwise, credit score below 700, or DTI above 35%, or utilization above 50%.
- **Low:** all remaining customers.

These thresholds are created for this portfolio exercise and should not be treated as actual lending policy.

## Analytical Interpretation

The project focuses on observed relationships in the dataset. For example, it compares default rates across score, DTI, utilization, employment and delinquency groups. These comparisons are descriptive and do not establish causation.

## Repository Structure

```text
Bank-Credit-Risk-Analysis/
│
├── data/
│   └── credit_risk_dataset.csv
│
├── python/
│   └── bank_credit_risk_eda.py
│
├── sql/
│   └── credit_risk_analysis.sql
│
├── power_bi/
│   ├── Bank_Credit_Risk_Analysis.pbix
│   └── dashboard_specs.md
│
├── docs/
│   ├── data_dictionary.md
│   └── executive_summary.md
│
├── outputs/
│   └── generated analytical files
│
├── README.md
└── requirements.txt
```

## How to Run

### 1. Clone the repository

```bash
git clone https://github.com/RishiMishra06/Bank-Credit-Risk-Analysis.git
cd Bank-Credit-Risk-Analysis
```

### 2. Install dependencies

```bash
pip install -r requirements.txt
```

### 3. Run Python analysis

```bash
python python/bank_credit_risk_eda.py
```

### 4. Run SQL analysis

Load the CSV into PostgreSQL and run `sql/credit_risk_analysis.sql`.

### 5. Build the Power BI dashboard

Use the documented data model, DAX measures and visual plan in `power_bi/dashboard_specs.md`.

## Project Limitations

- The dataset is synthetic and is not representative of a real bank's population.
- There is no real transaction history or time-series account behavior.
- Observed relationships do not prove causation.
- Risk thresholds are analytical examples created for this project.
- Production credit decisions would require additional data, validation, governance and domain review.

## Portfolio Value

This project demonstrates an end-to-end Data Analyst workflow:

**Python → SQL → Power BI → Business Insights**

It showcases data cleaning, exploratory analysis, SQL querying, segmentation, KPI development, dashboard design and communicating analytical findings.

## Author

**Rishi Mishra**

Data Analytics | SQL | Python | Excel | Power BI
