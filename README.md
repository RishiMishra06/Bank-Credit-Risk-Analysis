# Bank Credit Card & Loan Default Risk Analysis
### Enterprise Credit Risk Intelligence, Basel III Loss Forecasting & Underwriting Policy Optimization

[![SQL-PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL_14+-blue.svg?logo=postgresql&logoColor=white)](#part-2-production-grade-sql-pipeline)
[![Power-BI](https://img.shields.io/badge/BI-Power_BI_DAX-F2C811.svg?logo=powerbi&logoColor=black)](#part-3-power-bi-dax-measures--visual-architecture)
[![Python-Engine](https://img.shields.io/badge/Analytics-Python_3.10-3776AB.svg?logo=python&logoColor=white)](#part-1-dataset-generation-engine)
[![Risk-Standard](https://img.shields.io/badge/Standard-Basel_III_CECL-darkgreen.svg)](#part-4-executive-summary--cro-recommendations)

---

## 1. Project Overview & Business Problem Statement

Retail lending institutions face an ongoing challenge: how to maximize credit card and personal loan origination volumes while controlling default rates and mitigating provisions under Basel III and CECL guidelines. 

This enterprise analytics portfolio project models, diagnoses, and remediates credit default vulnerability across a retail banking portfolio of **1,500 active customer credit facilities** representing **$26,166,271.90 ($26.17M) in total drawn credit exposure**.

### Business Objectives:
1. **Identify Primary Risk Drivers:** Isolate the quantitative determinants of retail default risk across credit bureau scores, debt-to-income (DTI) ratios, revolving utilization, and historical delinquencies.
2. **Quantify Exposure at Default (EAD) & Expected Loss (ECL):** Implement regulatory loss modeling (`EAD * PD * LGD`) assuming a benchmark 65% Loss Given Default for unsecured retail debt.
3. **Formulate Rules-Based Policy Interventions:** Design actionable underwriting policy knockouts and line-management guardrails to reduce net charge-offs without impairing profitable credit expansion.

---

## 2. Tech Stack & Analytics Architecture

```
+-------------------------------------------------------------------------------------------------+
|                                 ENTERPRISE ANALYTICS PIPELINE                                   |
+-------------------------------------------------------------------------------------------------+
|  [Layer 1: Data Engineering]    -->  [Layer 2: SQL Analytics]      -->  [Layer 3: Power BI BI]  |
|  - Python 3.10 (Pandas, NumPy)       - PostgreSQL 14+ / ANSI SQL        - Power BI Desktop / DAX|
|  - Basel III Logistic Calibration    - Quality Assurance CTEs           - 2-Page Executive Canvas |
|  - FICO & DTI Synthetic Generator    - Regulatory Risk Tiering Views    - Dynamic Global Slicers  |
|  - Empirical Delinquency Seeds       - Window Function Cohort Ranks     - Surveillance Drill-down |
+-------------------------------------------------------------------------------------------------+
```

| Technology | Purpose | Key Artifacts |
| :--- | :--- | :--- |
| **Python 3.10** | Synthetic portfolio generation, Basel III logistic risk calibration | `generate_dataset.py`, `credit_risk_dataset.csv` |
| **PostgreSQL 14+** | Data sanitization, feature engineering, window functions, ECL modeling | `sql/credit_risk_analysis.sql` |
| **Power BI / DAX** | Executive portfolio health dashboard, risk migration, drill-down matrix | `power_bi/dashboard_specs.md` |
| **Executive Governance** | CRO credit memo, underwriting knockout criteria, ROI scenario model | `docs/executive_summary.md` |

---

## 3. Data Schema & Dictionary

The primary entity table `credit_risk_dataset` models 1,500 credit facility records:

| Column Name | Data Type | Constraint | Business Description |
| :--- | :--- | :--- | :--- |
| `Customer_ID` | `VARCHAR(16)` | `PRIMARY KEY` | Unique customer account identifier (e.g. `CUST-1001`) |
| `Age` | `INTEGER` | `21 - 65` | Age of primary accountholder |
| `Gender` | `VARCHAR(10)` | `Male / Female` | Demographic segmentation |
| `Annual_Income` | `NUMERIC(12,2)` | `$25k - $250k` | Verified gross annual personal income |
| `Employment_Status` | `VARCHAR(20)` | `Enum` | `Employed`, `Self-Employed`, `Unemployed`, `Student` |
| `Credit_Score` | `INTEGER` | `300 - 850` | Standard credit bureau score (FICO scale) |
| `Total_Debt` | `NUMERIC(12,2)` | `$0 - $100k` | Current aggregate outstanding drawn obligations |
| `Debt_to_Income_Ratio` | `NUMERIC(6,4)` | `0.05 - 0.75` | Monthly debt service ratio against monthly income |
| `Credit_Card_Limit` | `NUMERIC(12,2)` | `$1k - $50k` | Total revolving line of credit facility assigned |
| `Credit_Utilization_Rate` | `NUMERIC(6,4)` | `0.0 - 1.0` | Proportion of assigned revolving line drawn |
| `Late_Payments_30_Days` | `INTEGER` | `0 - 6` | Number of 30-day past-due events in trailing 12M |
| `Late_Payments_90_Days` | `INTEGER` | `0 - 3` | Number of 90-day past-due events (severe delinquency) |
| `Default_Status` | `SMALLINT` | `0 or 1` | `1` = Charge-off / default; `0` = Current / performing |
| `Loan_Purpose` | `VARCHAR(40)` | `Enum` | `Debt Consolidation`, `Home Improvement`, `Personal`, etc. |

---

## 4. Key Analytical Insights

```
+-------------------------------------------------------------------------------------------------+
| AUDITED PORTFOLIO BENCHMARK METRICS                                                             |
+------------------------------------+----------------------------+-------------------------------+
| Metric                             | Value                      | Benchmark Comparison          |
+------------------------------------+----------------------------+-------------------------------+
| Total Customer Base                | 1,500 Accounts             | Baseline active portfolio     |
| Portfolio Defaults                 | 215 Defaults (14.33%)      | Target threshold: < 12.00%    |
| Aggregate Drawn Exposure           | $26,166,271.90             | Average balance: $17,444.18   |
| Gross Defaulted Balances           | $4,247,575.94              | 16.23% of total loan balance  |
| Net Credit Loss (65% LGD)          | $2,760,924.36              | 10.55% net portfolio loss     |
| Average Net Loss per Default       | $12,841.51                 | Per defaulted account         |
+------------------------------------+----------------------------+-------------------------------+
```

1. **The 600-FICO Cliff:** Borrowers with credit scores below 600 represent **34.80% of accounts** but generate **90.70% of all defaults (195/215)**, producing an acute **37.36% default rate**.
2. **The Severe High-Risk Tail (Score < 600 & DTI > 45%):** A focused cohort of 76 accounts registered a **68.42% default rate**, accounting for **$1.64M** of defaulted balances.
3. **Employment Volatility Impact:** Unemployed accountholders recorded a **47.66% default rate**, vs. 11.86% for regularly employed borrowers.
4. **Refinancing Distress in Debt Consolidation:** Debt consolidation loans exhibited the highest default incidence (**18.37%**), proving that consolidation without revolving line closure triggers debt-stacking traps.

---

## 5. Strategic Recommendations & Underwriting Impact

```
+-------------------------------------------------------------------------------------------------+
| PROJECTED ANNUAL BUSINESS IMPACT (SIMULATION MODEL)                                             |
+----------------------------------------+-------------------+-------------------+----------------+
| Metric                                 | Baseline          | Post-Reform       | Net Variance   |
+----------------------------------------+-------------------+-------------------+----------------+
| Total Active Accounts                  | 1,500 Borrowers   | 1,424 Borrowers   | -76 (-5.07%)   |
| Total Defaults                         | 215 Defaults      | 163 Defaults      | -52 (-24.19%)  |
| Portfolio Default Rate (%)             | 14.33%            | 11.45%            | -288 bps       |
| Net Credit Loss / Charge-Offs (65% LGD)| $2,760,924.36     | $1,692,394.30     | +$1,068,530.06 |
| Less: Forgone Net Margin (24 accounts) | --                | --                | -$76,800.00    |
| NET ECONOMIC BENEFIT TO TIER-1 CAPITAL | --                | --                | +$991,730.06   |
+----------------------------------------+-------------------+-------------------+----------------+
```

### Core Policy Reforms Proposed to Credit Committee:
1. **DTI Hard-Cap at 45% for Subprime Borrowers:** Automatic underwriting rejection for any applicant with `DTI > 0.45` and `Credit_Score < 650`.
2. **Automated Knockout on Sub-580 Bureau Scores with Delinquencies:** Mandatory knockout for any applicant with score `< 580` possessing any trailing 30+ day delinquency.
3. **Dynamic Revolving Line Compression:** Implement proactive 20% limit reductions when revolving utilization exceeds 75% for 2 consecutive cycles coupled with credit score deterioration.

---

## 6. How to Run & Reproduce

### 1. Generate Synthetic Dataset (Python)
```bash
# Clone repository
git clone https://github.com/your-org/bank-credit-risk-analytics.git
cd bank-credit-risk-analytics

# Run generator (generates 1,500 calibrated records)
python3 generate_dataset.py 1500
```
This writes `credit_risk_dataset.csv` directly into the working directory.

### 2. Execute SQL Analytics Pipeline (PostgreSQL)
```bash
# Connect to PostgreSQL and execute the complete analytics script
psql -U postgres -d credit_risk_db -f sql/credit_risk_analysis.sql
```
The script will:
- Execute data sanitization audits.
- Create feature engineering view `vw_credit_risk_engineered`.
- Output default stratifications by employment, score bucket, and loan purpose.
- Run window function rankings (`AVG() OVER()`, `NTILE(4)`, `DENSE_RANK()`).
- Compute Basel III expected loss provisions.

### 3. Load DAX Measures in Power BI
1. Launch Power BI Desktop and import `credit_risk_dataset.csv`.
2. Open `power_bi/dashboard_specs.md` and copy the DAX measure formulas into your Power BI Data Model.
3. Follow the 2-Page Visual Architecture Plan to construct Page 1 (Executive Health) and Page 2 (Deep-Dive Analytics).

---

## 7. Repository Structure

```
.
â”œâ”€â”€ README.md                      # Recruiter-ready executive project documentation
â”œâ”€â”€ generate_dataset.py            # Python dataset generation engine
â”œâ”€â”€ credit_risk_dataset.csv        # 1,500-record production credit portfolio dataset
â”œâ”€â”€ sql/
â”‚   â””â”€â”€ credit_risk_analysis.sql   # PostgreSQL production data pipeline & queries
â”œâ”€â”€ power_bi/
â”‚   â””â”€â”€ dashboard_specs.md         # Ready-to-copy DAX measures & 2-page dashboard layout
â””â”€â”€ docs/
    â””â”€â”€ executive_summary.md       # Chief Risk Officer (CRO) strategic memo & ROI model
```

---
*Author: Rishi Mishra *
