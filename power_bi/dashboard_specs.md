# Power BI DAX Measures & Dashboard Architecture Specifications
**Project:** Bank Credit Card & Loan Default Risk Analysis  
**Target Platform:** Power BI Desktop / Power BI Service (Enterprise Premium)  
**Author:** Senior Risk Analytics Engineer  
**Division:** Global Consumer Credit Risk & Portfolio Governance  

---

## 1. Core DAX Measure Catalog (Ready-to-Copy)

All measures are written adhering to enterprise DAX formatting standards: explicit table references for columns, bracketed notation for existing measures, and safe error handling via `DIVIDE()` to prevent divide-by-zero exceptions.

```dax
/* ==============================================================================
   SECTION 1.1: VOLUME & PORTFOLIO EXPOSURE MEASURES
   ============================================================================== */

// 1. Total Active Accounts
Total Customers = 
COUNT(credit_risk_dataset[Customer_ID])


// 2. Total Exposure Amount ($) - Outstanding Portfolio Debt
Total Exposure Amount ($) = 
SUM(credit_risk_dataset[Total_Debt])


// 3. Total Credit Facility Limits
Total Credit Limit ($) = 
SUM(credit_risk_dataset[Credit_Card_Limit])


// 4. Regulatory Exposure at Default (EAD)
// Outstanding Drawn Debt + 50% Credit Conversion Factor (CCF) on Undrawn Revolving Lines
Exposure at Default EAD ($) = 
SUMX(
    credit_risk_dataset,
    credit_risk_dataset[Total_Debt] + (
        0.50 * MAX(0, credit_risk_dataset[Credit_Card_Limit] - (credit_risk_dataset[Credit_Card_Limit] * credit_risk_dataset[Credit_Utilization_Rate]))
    )
)


/* ==============================================================================
   SECTION 1.2: DEFAULT & DELINQUENCY RATES
   ============================================================================== */

// 5. Total Defaulted Borrower Count
Defaulted Customers = 
CALCULATE(
    COUNTROWS(credit_risk_dataset),
    credit_risk_dataset[Default_Status] = 1
)


// 6. Total Default Rate %
Total Default Rate % = 
DIVIDE(
    [Defaulted Customers],
    [Total Customers],
    0
)


// 7. High Risk Customer Count
// Borrowers with Credit Score < 600 AND Debt-to-Income (DTI) > 0.45
High Risk Customer Count = 
CALCULATE(
    COUNTROWS(credit_risk_dataset),
    FILTER(
        credit_risk_dataset,
        credit_risk_dataset[Credit_Score] < 600 && 
        credit_risk_dataset[Debt_to_Income_Ratio] > 0.45
    )
)


// 8. High Risk Cohort Share %
High Risk Share % = 
DIVIDE(
    [High Risk Customer Count],
    [Total Customers],
    0
)


// 9. Severe Delinquency Count (90+ Days Past Due)
Borrowers 90D Past Due = 
CALCULATE(
    COUNTROWS(credit_risk_dataset),
    credit_risk_dataset[Late_Payments_90_Days] > 0
)


// 10. Delinquency Rate (90+ Days) %
Delinquency Rate 90D % = 
DIVIDE(
    [Borrowers 90D Past Due],
    [Total Customers],
    0
)


/* ==============================================================================
   SECTION 1.3: RISK-WEIGHTED LOSS PROVISIONS & RECOVERY
   ============================================================================== */

// 11. Gross Defaulted Balance ($)
Gross Defaulted Exposure ($) = 
CALCULATE(
    SUM(credit_risk_dataset[Total_Debt]),
    credit_risk_dataset[Default_Status] = 1
)


// 12. Net Charge-Off / Expected Credit Loss ($)
// Loss Given Default (LGD) benchmark calibrated at 65% for unsecured retail facilities
Expected Credit Loss ECL ($) = 
[Gross Defaulted Exposure ($)] * 0.65


// 13. Average Loss Per Defaulted Customer ($)
Average Loss per Default ($) = 
DIVIDE(
    [Expected Credit Loss ECL ($)],
    [Defaulted Customers],
    0
)


// 14. Portfolio Net Loss Rate %
Portfolio Net Loss Rate % = 
DIVIDE(
    [Expected Credit Loss ECL ($)],
    [Total Exposure Amount ($)],
    0
)


/* ==============================================================================
   SECTION 1.4: TIME INTELLIGENCE & MOM VARIANCE
   (Requires Standard Dim_Date Table with [Date] and [MonthOffset])
   ============================================================================== */

// 15. Prior Month Default Rate %
Prior Month Default Rate % = 
CALCULATE(
    [Total Default Rate %],
    DATEADD('Dim_Date'[Date], -1, MONTH)
)


// 16. MoM Default Rate Variance % (Basis Point Variance)
MoM Default Rate Variance % = 
VAR CurrentRate = [Total Default Rate %]
VAR PriorRate = [Prior Month Default Rate %]
RETURN
    IF(
        NOT ISBLANK(PriorRate),
        CurrentRate - PriorRate,
        BLANK()
    )


// 17. MoM Exposure Growth %
MoM Exposure Growth % = 
VAR CurrentExp = [Total Exposure Amount ($)]
VAR PriorExp = CALCULATE([Total Exposure Amount ($)], DATEADD('Dim_Date'[Date], -1, MONTH))
RETURN
    DIVIDE(CurrentExp - PriorExp, PriorExp, 0)


/* ==============================================================================
   SECTION 1.5: WEIGHTED UNDERWRITING METRICS
   ============================================================================== */

// 18. Weighted Average Credit Score (Weighted by Total Debt)
Weighted Avg Credit Score = 
DIVIDE(
    SUMX(credit_risk_dataset, credit_risk_dataset[Credit_Score] * credit_risk_dataset[Total_Debt]),
    [Total Exposure Amount ($)],
    0
)


// 19. Weighted Average DTI Ratio
Weighted Avg DTI = 
DIVIDE(
    SUMX(credit_risk_dataset, credit_risk_dataset[Debt_to_Income_Ratio] * credit_risk_dataset[Total_Debt]),
    [Total Exposure Amount ($)],
    0
)


// 20. Weighted Average Revolving Credit Utilization
Weighted Avg Utilization = 
DIVIDE(
    SUMX(credit_risk_dataset, credit_risk_dataset[Credit_Utilization_Rate] * credit_risk_dataset[Credit_Card_Limit]),
    [Total Credit Limit ($)],
    0
)
```

---

## 2. Power BI 2-Page Dashboard Visual Architecture Plan

### Design Specifications & Global Theme
- **Target Resolution:** 16:9 Landscape (`1920 x 1080 px` or `1280 x 720 px`)
- **Typography:** Display Header: `Plus Jakarta Sans / Segoe UI Bold`, Values: `DIN / Segoe UI Semibold`
- **Color Palette (Institutional Risk Standards):**
  - Prime / Low Risk: `#10B981` (Emerald Green)
  - Moderate Risk: `#3B82F6` (Cobalt Blue)
  - High Risk: `#F59E0B` (Amber Orange)
  - Severe / Critical Risk: `#EF4444` (Crimson Red)
  - Canvas Background: `#0F172A` (Slate 900) or `#F8FAFC` (Slate 50)
  - Card Container: Surface Neutral with `#E2E8F0` / `#1E293B` Border

---

### Page 1: Executive Portfolio Health

**Target Audience:** Chief Risk Officer (CRO), Head of Retail Credit Underwriting, Chief Financial Officer.  
**Objective:** High-level strategic monitoring of credit losses, portfolio exposure, and risk migration.

```
+---------------------------------------------------------------------------------------------------+
| HEADER: Retail Credit Risk & Portfolio Health Monitor             [Period: YTD] [Currency: USD]   |
+---------------------------------------------------------------------------------------------------+
| [KPI 1]            | [KPI 2]            | [KPI 3]            | [KPI 4]            | [KPI 5]       |
| Total Exposure     | Total Accounts     | Portfolio Def Rate | High Risk Accounts | Expected Loss |
| $26.17M            | 1,500 Borrowers    | 14.33%             | 76 Customers       | $2.76M (LGD65)|
| (+3.2% vs Plan)    | (Active)           | (Target: <12.0%)   | (68.4% Def Rate)   | Net Charge-off|
+--------------------+--------------------+--------------------+--------------------+---------------+
| VISUAL 1: Default Rate by Risk Tier     | VISUAL 2: Credit Score vs Revolving Utilization Scatter |
| Horizontal Stacked Bar Chart            | Scatter Plot (Colored by Default Status 0 vs 1)         |
| - Severe Risk:   68.4% Default Rate     | X-Axis: Credit Score (300 - 850)                        |
| - High Risk:     32.5% Default Rate     | Y-Axis: Credit Utilization Rate (0% - 100%)             |
| - Moderate Risk:  4.8% Default Rate     | Bubble Size: Total Debt ($)                             |
| - Prime Risk:     0.8% Default Rate     | Trendline: Clear inflection at Score < 600 & Util > 75% |
+-----------------------------------------+---------------------------------------------------------+
| VISUAL 3: Portfolio Exposure by Loan Purpose  | VISUAL 4: Delinquency Migration Matrix            |
| Clustered Column & Line Chart                 | 100% Stacked Bar Chart                            |
| - Bar: Total Drawn Exposure ($)               | Clean / 30D Late / 90D Delinquent Breakdown       |
| - Line: Default Rate % (Debt Consol = 18.4%)  | by Employment Class (Unemployed: 47.7% Default)   |
+-----------------------------------------------+---------------------------------------------------+
```

#### Detailed Page 1 Component Configurations:
1. **Executive KPI Cards (Top Banner, Y: 20px, Height: 110px):**
   - **Card 1 (Exposure):** Metric `[Total Exposure Amount ($)]`, formatting `$#,##0.00`, dynamic status chip.
   - **Card 2 (Accounts):** Metric `[Total Customers]`, sub-label `Active Borrowers`.
   - **Card 3 (Default Rate):** Metric `[Total Default Rate %]`, conditional formatting (`< 10%` Green, `10-14%` Amber, `> 14%` Red).
   - **Card 4 (High Risk Tail):** Metric `[High Risk Customer Count]`, badge `Score < 600 & DTI > 45%`.
   - **Card 5 (ECL Provision):** Metric `[Expected Credit Loss ECL ($)]`, subtitle `65% LGD Regulatory Provision`.
2. **Visual 1 (Horizontal Clustered Bar):**
   - **Axis:** `vw_credit_risk_engineered[risk_tier]`
   - **Values:** `[Total Default Rate %]`, Tooltips: `[Total Exposure Amount ($)]`, `[Defaulted Customers]`
3. **Visual 2 (Risk Frontier Scatter Plot):**
   - **X-Axis:** `credit_risk_dataset[Credit_Score]`
   - **Y-Axis:** `credit_risk_dataset[Credit_Utilization_Rate]` (format: `0.0%`)
   - **Legend:** `credit_risk_dataset[Default_Status]` (0 = Current: `#3B82F6`, 1 = Default: `#EF4444`)
   - **Size:** `credit_risk_dataset[Total_Debt]`
4. **Visual 3 (Exposure & Default by Purpose):**
   - **X-Axis:** `credit_risk_dataset[Loan_Purpose]`
   - **Column Y-Axis:** `[Total Exposure Amount ($)]`
   - **Line Y-Axis:** `[Total Default Rate %]`

---

### Page 2: Deep-Dive Risk Analytics & Borrower Drill-Down

**Target Audience:** Credit Risk Underwriters, Credit Policy Managers, Loss Forecasting Analysts.  
**Objective:** Granular cohort cross-filtering, multi-factor concentration heatmaps, and account-level risk remediation.

```
+---------------------------------------------------------------------------------------------------+
| HEADER: Granular Risk Analytics & Account Surveillance Workbench                                  |
+---------------------------------------------------------------------------------------------------+
| LEFT FILTER PANEL (Width: 260px)   | MAIN ANALYTICS WORKSPACE (Width: 1620px)                     |
|                                    |                                                              |
| [Slicer 1: Employment Status]      | VISUAL 5: Concentration Heatmap / Matrix                     |
| [x] All  [ ] Employed [ ] Unempl   | Rows: Income Bracket (<$45k, $45k-$85k, $85k-$150k, $150k+)  |
|                                    | Columns: Loan Purpose (Consolidation, Small Biz, Auto, etc.) |
| [Slicer 2: Credit Score Bucket]    | Values: [Total Default Rate %] with Conditional Color Scales |
| [ ] Poor (<600)  [ ] Fair (600-699)| Deepest Red in Low Income x Debt Consolidation (>28%)        |
| [ ] Good (700-799) [ ] Prime (800+)|                                                              |
|                                    +--------------------------------------------------------------+
| [Slicer 3: DTI Slider]             | VISUAL 6: Top At-Risk Borrower Surveillance Drill-down Table |
| [===O=================] (0 - 0.75) | (Top 10% Risk Rank based on SQL Window Function Model)       |
|                                    | Customer ID | Score | DTI   | Util% | 30D | 90D | Debt   | Stat|
| [Slicer 4: Loan Purpose]           | CUST-1042   | 485   | 0.62  | 92.4% | 3   | 2   | $48.2k | DEF |
| Multi-select dropdown              | CUST-1118   | 512   | 0.58  | 88.1% | 2   | 1   | $54.0k | DEF |
|                                    | CUST-1205   | 530   | 0.51  | 84.6% | 4   | 2   | $41.8k | DEF |
| [Button: Reset All Filters]        | CUST-1349   | 544   | 0.49  | 79.2% | 2   | 1   | $37.5k | DEF |
+------------------------------------+--------------------------------------------------------------+
```

#### Detailed Page 2 Component Configurations:
1. **Interactive Global Slicers (Left Rail):**
   - Employment Type tile slicer with multi-select enabled.
   - Credit Score Bucket vertical list slicer.
   - DTI Ratio numeric range slider (`0.05` to `0.75`).
   - Loan Purpose checkbox selector.
2. **Visual 5 (Income vs Purpose Default Risk Heatmap):**
   - **Matrix Visual:** Rows = `vw_credit_risk_engineered[income_bracket]`, Columns = `credit_risk_dataset[Loan_Purpose]`.
   - **Values:** `[Total Default Rate %]` formatted as `0.0%`.
   - **Conditional Formatting:** 3-color gradient (Minimum `#10B981` at 0%, Midpoint `#F59E0B` at 12%, Maximum `#EF4444` at 35%+).
3. **Visual 6 (Surveillance Drill-Down Table):**
   - **Columns:** `Customer_ID`, `Credit_Score`, `Debt_to_Income_Ratio` (format `0.0%`), `Credit_Utilization_Rate` (format `0.0%`), `Late_Payments_30_Days`, `Late_Payments_90_Days`, `Total_Debt` (format `$#,##0`), `Default_Status` (Icon indicator: Green check vs Red alert).
   - **Sort Order:** `Late_Payments_90_Days` DESC, `Debt_to_Income_Ratio` DESC.
   - **Page Size / Virtual Scrolling:** Smooth virtual scroll for all 1,500 accounts.

---

## 3. Power BI Modeling & Relationship Schema

```
+-------------------------------------+          +-------------------------------------+
|              Dim_Date               |          |       vw_credit_risk_engineered     |
+-------------------------------------+          +-------------------------------------+
| Date [PK]                           | 1        | customer_id [PK]                    |
| Year                                |   \      | credit_score_bucket                 |
| Month                               |    \     | income_bracket                      |
| MonthName                           |     \ *  | risk_tier                           |
| MonthOffset                         |      --->| exposure_at_default                 |
+-------------------------------------+          +-------------------------------------+
                                                           ^
                                                           | 1:1 Relationship (Active)
                                                           |
                                                 +-------------------------------------+
                                                 |         credit_risk_dataset         |
                                                 +-------------------------------------+
                                                 | Customer_ID [PK]                    |
                                                 | Age                                 |
                                                 | Annual_Income                       |
                                                 | Employment_Status                   |
                                                 | Credit_Score                        |
                                                 | Total_Debt                          |
                                                 | Debt_to_Income_Ratio                |
                                                 | Credit_Card_Limit                   |
                                                 | Credit_Utilization_Rate             |
                                                 | Late_Payments_30_Days               |
                                                 | Late_Payments_90_Days               |
                                                 | Default_Status                      |
                                                 | Loan_Purpose                        |
                                                 +-------------------------------------+
```