# Bank Credit Risk Analysis

### End-to-End Data Analytics Project using Python, SQL & Power BI

[![Python](https://img.shields.io/badge/Python-Pandas%20%7C%20NumPy-3776AB?logo=python&logoColor=white)](#1-python-data-cleaning--eda)
[![SQL](https://img.shields.io/badge/SQL-PostgreSQL-336791?logo=postgresql&logoColor=white)](#2-sql-analysis)
[![Power BI](https://img.shields.io/badge/Power%20BI-DAX-F2C811?logo=powerbi&logoColor=black)](#3-power-bi-dashboard)
[![Status](https://img.shields.io/badge/Project-Portfolio%20Ready-success)](#project-overview)

---

## Project Overview

**Bank Credit Risk Analysis** is an end-to-end Data Analyst portfolio project that analyzes customer credit, debt, utilization, delinquency and default information to identify high-risk customer segments and support data-driven credit-risk decisions.

The project follows a practical analytics workflow:

```text
Raw CSV Data
     ↓
Python Data Cleaning & EDA
     ↓
PostgreSQL SQL Analysis
     ↓
Power BI Dashboard
     ↓
Business Insights & Recommendations
```

### Business Problem

A lending business needs to understand which customer characteristics and credit behaviors are associated with higher default risk. The analysis focuses on questions such as:

- What is the overall default rate?
- Which credit-score segments show higher default rates?
- How does debt-to-income ratio relate to default?
- Does higher credit utilization correspond with higher risk?
- Which employment groups and loan purposes show different default patterns?
- Which customers or segments should be prioritized for risk monitoring?

> **Important:** This repository uses a **synthetic dataset** for portfolio and learning purposes. It does not contain real bank customer information. Any loss, LGD, PD, ECL or policy assumptions used in the analysis are illustrative analytical assumptions and are not an actual bank's regulatory model.

---

## Tools & Technologies

| Tool | Purpose |
|---|---|
| **Python** | Data cleaning, validation, feature engineering, EDA and charts |
| **Pandas / NumPy** | Data manipulation and analytical calculations |
| **Matplotlib** | Data visualization |
| **PostgreSQL / SQL** | Data quality checks, segmentation, aggregations and advanced analysis |
| **Power BI** | Interactive dashboard and business reporting |
| **DAX** | KPI measures and calculated analytics |
| **GitHub** | Version control and portfolio documentation |

---

## Dataset

The main dataset is available at:

`data/credit_risk_dataset.csv`

The dataset contains customer-level fields covering:

- Customer ID and demographic information
- Annual income and employment status
- Credit score
- Total debt
- Debt-to-income ratio
- Credit-card limit and utilization
- 30-day and 90-day late-payment counts
- Default status
- Loan purpose

See the detailed [data dictionary](docs/data_dictionary.md).

---

# 1. Python Data Cleaning & EDA

The Python analysis script is available at:

`python/bank_credit_risk_eda.py`

### Data preparation includes

- Loading the raw CSV dataset
- Standardizing column names
- Checking missing values
- Checking duplicate records
- Validating important numeric ranges
- Creating analytical buckets for credit score, income, DTI and utilization
- Creating risk-oriented customer segments
- Calculating portfolio KPIs
- Producing segment-level summary tables
- Identifying high-risk customers
- Generating business-focused charts

### Main outputs

The script creates an `outputs/` directory containing analytical CSV files and charts when it is executed locally.

---

# 2. SQL Analysis

The SQL layer is used to move beyond basic aggregation and answer business questions using PostgreSQL.

### SQL analysis covers

- Data-quality auditing
- Feature engineering
- Risk-tier classification
- Default-rate analysis
- Credit-score segmentation
- Employment and loan-purpose analysis
- DTI and utilization analysis
- Delinquency analysis
- Customer ranking and segmentation
- Window functions
- Exposure and loss calculations

The SQL scripts are stored in the `sql/` directory.

---

# 3. Power BI Dashboard

The Power BI layer converts the analytical results into an interactive business dashboard.

### Page 1 — Executive Overview

Recommended KPIs and visuals include:

- Total Customers
- Total Exposure / Debt
- Defaulted Customers
- Default Rate
- Expected Credit Loss under illustrative assumptions
- Default Rate by Risk Tier
- Default Rate by Credit Score
- Exposure by Loan Purpose
- Default Rate by Employment Status
- Credit Score vs Credit Utilization

### Page 2 — Risk Analysis

The detailed risk page focuses on:

- Employment Status slicer
- Credit Score Bucket slicer
- Loan Purpose slicer
- Risk Tier slicer
- DTI vs Default analysis
- Utilization vs Default analysis
- 30-day and 90-day delinquency analysis
- High-risk customer table

Power BI design specifications and DAX measures are available in `power_bi/`.

---

# Key Analytical Areas

### 1. Credit Score Risk

Compare default rates across credit-score buckets to identify whether lower-score customers show different default behavior.

### 2. Debt-to-Income Risk

Segment customers by DTI bands and compare default rates and exposure across those groups.

### 3. Credit Utilization

Analyze whether customers using a larger proportion of their available credit have different observed default rates.

### 4. Delinquency

Compare 30-day and 90-day late-payment behavior with default status to identify potentially important risk signals.

### 5. Customer Segmentation

Combine multiple indicators such as credit score, DTI, utilization and delinquency to create practical risk segments for monitoring.

> These relationships are observational. The analysis should not be interpreted as proving that a particular variable directly causes default.

---

# Business Recommendations Framework

Based on the observed patterns in the final analysis, a lending team could consider:

1. **Risk-based monitoring** for segments showing consistently higher observed default rates.
2. **Early-warning indicators** using delinquency, utilization and DTI signals.
3. **Credit-line review** for customers showing sustained high utilization together with other risk indicators.
4. **Segment-specific review** rather than applying the same intervention to every customer.
5. **Dashboard-driven monitoring** so risk teams can track portfolio changes over time.

These are analytical recommendations for the portfolio exercise, not production underwriting rules.

---

# Repository Structure

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
│   ├── 01_data_quality.sql
│   ├── 02_data_cleaning.sql
│   ├── 03_basic_analysis.sql
│   ├── 04_credit_risk_analysis.sql
│   ├── 05_customer_segmentation.sql
│   ├── 06_advanced_analysis.sql
│   └── 07_business_kpis.sql
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
│   └── generated after running the Python analysis
│
├── README.md
└── requirements.txt
```

> The structure above describes the intended portfolio layout. Files are added to the repository as the corresponding analysis artifacts are completed.

---

# How to Run

## Step 1 — Clone the repository

```bash
git clone https://github.com/RishiMishra06/Bank-Credit-Risk-Analysis.git
cd Bank-Credit-Risk-Analysis
```

## Step 2 — Install Python dependencies

```bash
pip install -r requirements.txt
```

## Step 3 — Run Python EDA

```bash
python python/bank_credit_risk_eda.py
```

This reads:

`data/credit_risk_dataset.csv`

and generates analytical outputs under:

`outputs/`

## Step 4 — Run SQL Analysis

Load the dataset into PostgreSQL and execute the SQL scripts in the `sql/` directory according to their numbered order.

## Step 5 — Open Power BI

Open the Power BI file/specification in `power_bi/`, connect the model to the prepared data, and build the dashboard using the documented DAX measures and visual plan.

---

# Project Limitations

- The dataset is synthetic and is not representative of a real bank's customer population.
- The project does not include real transaction history, bureau history or time-series account behavior.
- Observed relationships are not proof of causation.
- Any PD, LGD, EAD or ECL assumptions are illustrative for analytics practice.
- Production credit decisions would require model validation, governance, regulatory review, fairness testing and additional customer-level data.

---

# Portfolio Value

This project demonstrates an end-to-end Data Analyst workflow rather than only a dashboard:

**Python → SQL → Power BI → Business Insights**

It showcases skills in data cleaning, exploratory analysis, SQL querying, segmentation, KPI development, dashboard design and communicating analytical findings to business stakeholders.

---

## Author

**Rishi Mishra**

Data Analytics | SQL | Python | Excel | Power BI
