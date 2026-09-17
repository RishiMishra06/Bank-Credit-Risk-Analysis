# Executive Summary — Bank Credit Risk Analysis

## Objective

This project analyzes customer-level credit information to identify patterns associated with default risk and convert those findings into practical business reporting.

## Portfolio Analytics Approach

The analysis follows an end-to-end Data Analyst workflow:

1. **Python** — data cleaning, validation, feature engineering and exploratory analysis.
2. **SQL** — segmentation, aggregations, rankings, risk-tier analysis and advanced business questions.
3. **Power BI** — interactive KPI reporting, risk analysis and customer-level drill-downs.
4. **Business Interpretation** — translate observed portfolio patterns into monitoring and risk-management recommendations.

## Core Business Questions

- What is the overall default rate?
- Which credit-score segments show higher observed default rates?
- How does DTI vary between defaulted and non-defaulted customers?
- How does credit utilization relate to default status?
- Which employment and loan-purpose segments show different default patterns?
- How do 30-day and 90-day delinquency indicators differ by default status?
- Which customer segments should receive closer monitoring?

## Recommended KPI Set

- Total Customers
- Total Debt / Exposure
- Defaulted Customers
- Default Rate
- Average Credit Score
- Average DTI
- Average Credit Utilization
- Delinquency Counts
- Expected Loss under clearly stated illustrative assumptions

## Interpretation Guidance

The project is designed for portfolio analytics practice. Segment differences should be described as **observed associations**, not causal effects. Recommendations are analytical suggestions and should not be treated as production underwriting rules without additional validation.

## Risk Analysis Framework

The project evaluates multiple signals together rather than relying on a single variable:

- Credit score
- Debt-to-income ratio
- Credit utilization
- 30-day delinquency
- 90-day delinquency
- Employment status
- Loan purpose

This supports customer segmentation and helps demonstrate how a Data Analyst can convert raw customer data into business-focused risk insights.

## Loss Modeling Note

Where the project calculates EAD, PD, LGD or ECL, the assumptions are illustrative and intended to demonstrate analytical concepts. They are **not** an actual bank's regulatory capital, CECL or Basel III model.

## Limitations

- The dataset is synthetic and does not represent an actual bank portfolio.
- The project does not contain real customer information.
- There is no real transaction-level history, bureau history or longitudinal account-performance data.
- Observed relationships do not establish causation.
- Production credit decisions require model validation, governance, regulatory review, fairness testing and additional data.

## Intended Portfolio Outcome

The final deliverable demonstrates the complete path from raw customer data to decision-support reporting:

**Python → SQL → Power BI → Business Insights**

This makes the project suitable as a Data Analyst portfolio project and interview discussion piece.