-- ==============================================================================
-- ENTERPRISE CREDIT RISK & DEFAULT ANALYTICS PIPELINE
-- Dialect: PostgreSQL 14+ / ANSI SQL Compliant
-- Author: Senior Risk Analytics Engineer
-- Domain: Retail Lending & Unsecured Card Portfolio Risk Analysis
-- Target Table: credit_risk_dataset
-- ==============================================================================

-- TABLE DDL DEFINITION (For Environment Setup / Migration)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS credit_risk_dataset (
    customer_id             VARCHAR(16) PRIMARY KEY,
    age                     INTEGER NOT NULL CHECK (age BETWEEN 18 AND 100),
    gender                  VARCHAR(10) NOT NULL CHECK (gender IN ('Male', 'Female')),
    annual_income           NUMERIC(12, 2) NOT NULL CHECK (annual_income > 0),
    employment_status       VARCHAR(20) NOT NULL CHECK (employment_status IN ('Employed', 'Self-Employed', 'Unemployed', 'Student')),
    credit_score            INTEGER NOT NULL CHECK (credit_score BETWEEN 300 AND 850),
    total_debt              NUMERIC(12, 2) NOT NULL CHECK (total_debt >= 0),
    debt_to_income_ratio    NUMERIC(6, 4) NOT NULL CHECK (debt_to_income_ratio >= 0),
    credit_card_limit       NUMERIC(12, 2) NOT NULL CHECK (credit_card_limit > 0),
    credit_utilization_rate NUMERIC(6, 4) NOT NULL CHECK (credit_utilization_rate BETWEEN 0 AND 1.5),
    late_payments_30_days   INTEGER NOT NULL DEFAULT 0 CHECK (late_payments_30_days >= 0),
    late_payments_90_days   INTEGER NOT NULL DEFAULT 0 CHECK (late_payments_90_days >= 0),
    default_status          SMALLINT NOT NULL CHECK (default_status IN (0, 1)),
    loan_purpose            VARCHAR(40) NOT NULL
);


-- ==============================================================================
-- SECTION 1: DATA SANITIZATION & QUALITY ASSURANCE AUDIT
-- Business Purpose: Ensure dataset integrity prior to portfolio stress testing.
-- Detects null values, out-of-boundary credit bureau scores, negative balances,
-- and severe DTI ratio anomalies that would distort provisioning models.
-- ==============================================================================

WITH data_quality_audit AS (
    SELECT
        COUNT(*) AS total_records,
        -- Primary Key Integrity
        COUNT(*) - COUNT(customer_id) AS missing_customer_ids,
        COUNT(customer_id) - COUNT(DISTINCT customer_id) AS duplicate_customer_ids,
        
        -- Boundary Validations
        COUNT(CASE WHEN credit_score < 300 OR credit_score > 850 THEN 1 END) AS invalid_credit_scores,
        COUNT(CASE WHEN annual_income <= 0 OR annual_income IS NULL THEN 1 END) AS invalid_incomes,
        COUNT(CASE WHEN total_debt < 0 OR total_debt IS NULL THEN 1 END) AS negative_debt_records,
        COUNT(CASE WHEN debt_to_income_ratio < 0.0 OR debt_to_income_ratio > 1.0 THEN 1 END) AS outlier_dti_records,
        COUNT(CASE WHEN credit_utilization_rate < 0.0 OR credit_utilization_rate > 1.20 THEN 1 END) AS anomalous_utilization_records,
        COUNT(CASE WHEN late_payments_90_days > late_payments_30_days AND late_payments_30_days = 0 THEN 1 END) AS delinquent_logic_conflicts,
        COUNT(CASE WHEN default_status NOT IN (0, 1) OR default_status IS NULL THEN 1 END) AS corrupted_default_flags
    FROM credit_risk_dataset
)
SELECT
    total_records,
    missing_customer_ids,
    duplicate_customer_ids,
    invalid_credit_scores,
    invalid_incomes,
    negative_debt_records,
    outlier_dti_records,
    anomalous_utilization_records,
    delinquent_logic_conflicts,
    corrupted_default_flags,
    CASE 
        WHEN (missing_customer_ids + duplicate_customer_ids + invalid_credit_scores + 
              invalid_incomes + negative_debt_records + outlier_dti_records + 
              corrupted_default_flags) = 0 THEN 'DATASET PASSES PRODUCTION AUDIT'
        ELSE 'DATA INTEGRITY VIOLATION DETECTED'
    END AS qa_validation_status
FROM data_quality_audit;


-- ==============================================================================
-- SECTION 2: FEATURE ENGINEERING & REGULATORY RISK TIERING
-- Business Purpose: Segment portfolio into credit scoring bands, income tiers,
-- and Basel III risk classes to enable differentiated loss provisioning.
-- ==============================================================================

CREATE OR REPLACE VIEW vw_credit_risk_engineered AS
SELECT
    customer_id,
    age,
    gender,
    annual_income,
    employment_status,
    credit_score,
    total_debt,
    debt_to_income_ratio,
    credit_card_limit,
    credit_utilization_rate,
    late_payments_30_days,
    late_payments_90_days,
    default_status,
    loan_purpose,

    -- Standard Credit Bureau Score Classification (FICO Standard)
    CASE
        WHEN credit_score < 600 THEN 'Poor (<600)'
        WHEN credit_score BETWEEN 600 AND 699 THEN 'Fair (600-699)'
        WHEN credit_score BETWEEN 700 AND 799 THEN 'Good (700-799)'
        WHEN credit_score >= 800 THEN 'Excellent (800+)'
        ELSE 'Unrated'
    END AS credit_score_bucket,

    -- Annual Household Income Classification
    CASE
        WHEN annual_income < 45000 THEN 'Low Income (<$45k)'
        WHEN annual_income BETWEEN 45000 AND 84999.99 THEN 'Middle Income ($45k-$85k)'
        WHEN annual_income BETWEEN 85000 AND 149999.99 THEN 'Upper Middle ($85k-$150k)'
        WHEN annual_income >= 150000 THEN 'Affluent ($150k+)'
        ELSE 'Unclassified'
    END AS income_bracket,

    -- Multi-Factor Holistic Risk Tiering Matrix
    -- Combines Credit Score, DTI, Revolving Utilization, and Delinquency History
    CASE
        WHEN credit_score < 600 AND (debt_to_income_ratio > 0.45 OR late_payments_90_days >= 1) THEN 'Severe / Critical Risk'
        WHEN credit_score < 650 OR debt_to_income_ratio > 0.48 OR credit_utilization_rate > 0.80 THEN 'High Risk'
        WHEN credit_score BETWEEN 650 AND 719 AND debt_to_income_ratio <= 0.48 THEN 'Moderate Risk'
        WHEN credit_score >= 720 AND debt_to_income_ratio <= 0.36 AND late_payments_30_days = 0 THEN 'Prime / Low Risk'
        ELSE 'Moderate Risk'
    END AS risk_tier,

    -- Regulatory Exposure at Default (EAD): Outstanding Debt plus 50% undrawn credit line
    ROUND(
        total_debt + (0.50 * GREATEST(0.0, credit_card_limit - (credit_card_limit * credit_utilization_rate))),
        2
    ) AS exposure_at_default
FROM credit_risk_dataset;


-- ==============================================================================
-- SECTION 3: DEFAULT RATE STRATIFICATION & DELINQUENCY BREAKDOWNS
-- Business Purpose: Quantify default density across underwriting parameters.
-- Identifies vulnerable demographic and employment segments for policy adjustments.
-- ==============================================================================

-- 3A. OVERALL PORTFOLIO DEFAULT RATE
SELECT
    COUNT(*) AS total_portfolio_accounts,
    SUM(default_status) AS total_defaulted_accounts,
    ROUND(100.0 * SUM(default_status) / COUNT(*), 2) AS overall_default_rate_pct,
    ROUND(SUM(total_debt), 2) AS total_portfolio_debt,
    ROUND(SUM(CASE WHEN default_status = 1 THEN total_debt ELSE 0 END), 2) AS defaulted_debt_exposure,
    ROUND(100.0 * SUM(CASE WHEN default_status = 1 THEN total_debt ELSE 0 END) / NULLIF(SUM(total_debt), 0), 2) AS defaulted_debt_share_pct
FROM credit_risk_dataset;

-- 3B. DEFAULT RATE BY EMPLOYMENT STATUS
SELECT
    employment_status,
    COUNT(*) AS total_borrowers,
    SUM(default_status) AS defaulted_borrowers,
    ROUND(100.0 * SUM(default_status) / COUNT(*), 2) AS default_rate_pct,
    ROUND(AVG(credit_score), 1) AS avg_credit_score,
    ROUND(AVG(debt_to_income_ratio) * 100.0, 2) AS avg_dti_pct,
    ROUND(AVG(credit_utilization_rate) * 100.0, 2) AS avg_revolving_util_pct,
    ROUND(SUM(total_debt), 2) AS total_debt_exposure,
    ROUND(AVG(total_debt), 2) AS avg_borrower_debt
FROM credit_risk_dataset
GROUP BY employment_status
ORDER BY default_rate_pct DESC;

-- 3C. DEFAULT RATE BY CREDIT SCORE BUCKET
SELECT
    credit_score_bucket,
    COUNT(*) AS total_accounts,
    SUM(default_status) AS defaulted_accounts,
    ROUND(100.0 * SUM(default_status) / COUNT(*), 2) AS default_rate_pct,
    ROUND(100.0 * SUM(default_status) / SUM(SUM(default_status)) OVER(), 2) AS share_of_all_defaults_pct,
    ROUND(AVG(annual_income), 2) AS avg_annual_income,
    ROUND(AVG(debt_to_income_ratio), 4) AS avg_dti_ratio,
    ROUND(SUM(total_debt), 2) AS aggregate_exposure
FROM vw_credit_risk_engineered
GROUP BY credit_score_bucket
ORDER BY 
    CASE credit_score_bucket
        WHEN 'Poor (<600)' THEN 1
        WHEN 'Fair (600-699)' THEN 2
        WHEN 'Good (700-799)' THEN 3
        WHEN 'Excellent (800+)' THEN 4
        ELSE 5
    END;

-- 3D. DEFAULT RATE BY LOAN PURPOSE
SELECT
    loan_purpose,
    COUNT(*) AS loan_count,
    SUM(default_status) AS defaults,
    ROUND(100.0 * SUM(default_status) / COUNT(*), 2) AS default_rate_pct,
    ROUND(SUM(total_debt), 2) AS total_exposure_amount,
    ROUND(AVG(total_debt), 2) AS avg_loan_balance,
    ROUND(AVG(debt_to_income_ratio) * 100.0, 2) AS avg_dti_pct
FROM credit_risk_dataset
GROUP BY loan_purpose
ORDER BY default_rate_pct DESC;


-- ==============================================================================
-- SECTION 4: ADVANCED COHORT ANALYSIS VIA WINDOW FUNCTIONS
-- Business Purpose: Benchmark individual borrower risk profile against cohort
-- averages using AVG() OVER(), segment into quartiles via NTILE(4), and isolate
-- the top 10% highest-risk borrowers using DENSE_RANK() / PERCENT_RANK().
-- ==============================================================================

WITH cohort_benchmarked AS (
    SELECT
        customer_id,
        employment_status,
        loan_purpose,
        credit_score,
        debt_to_income_ratio,
        credit_utilization_rate,
        late_payments_30_days,
        late_payments_90_days,
        total_debt,
        default_status,

        -- 1. WINDOW FUNCTION: Average DTI and Utilization partitioned by Employment Status
        ROUND(AVG(debt_to_income_ratio) OVER(PARTITION BY employment_status), 4) AS peer_avg_dti,
        ROUND(AVG(credit_utilization_rate) OVER(PARTITION BY employment_status), 4) AS peer_avg_utilization,

        -- 2. WINDOW FUNCTION: Quartile Segmentation on DTI across entire portfolio
        NTILE(4) OVER(ORDER BY debt_to_income_ratio DESC) AS dti_quartile,

        -- 3. Composite Stress Scoring Metric:
        -- Penalizes 90-day delinquency heavily, DTI excesses, and sub-600 scores
        (
            (debt_to_income_ratio * 40.0) +
            (credit_utilization_rate * 25.0) +
            (late_payments_90_days * 35.0) +
            (late_payments_30_days * 10.0) +
            (CASE WHEN credit_score < 600 THEN 30.0 ELSE 0.0 END)
        ) AS composite_risk_score,

        -- 4. WINDOW FUNCTION: Dense Rank and Percentile Rank based on Composite Risk
        DENSE_RANK() OVER(ORDER BY 
            (debt_to_income_ratio * 40.0 + late_payments_90_days * 35.0 + late_payments_30_days * 10.0) DESC
        ) AS risk_rank,
        PERCENT_RANK() OVER(ORDER BY 
            (debt_to_income_ratio * 40.0 + late_payments_90_days * 35.0 + late_payments_30_days * 10.0) DESC
        ) AS risk_percentile
    FROM credit_risk_dataset
)
-- Isolate Top 10% Highest-Risk Tail
SELECT
    risk_rank,
    ROUND((risk_percentile * 100.0)::NUMERIC, 2) AS top_percentile_pct,
    customer_id,
    employment_status,
    loan_purpose,
    credit_score,
    debt_to_income_ratio,
    peer_avg_dti,
    ROUND((debt_to_income_ratio - peer_avg_dti)::NUMERIC, 4) AS dti_variance_from_peer,
    late_payments_30_days,
    late_payments_90_days,
    total_debt,
    default_status,
    dti_quartile
FROM cohort_benchmarked
WHERE risk_percentile <= 0.10  -- Strict Top 10% Highest-Risk Tail
ORDER BY risk_rank ASC
LIMIT 50;


-- ==============================================================================
-- SECTION 5: FINANCIAL RISK METRICS & EXPECTED DEFAULT LOSS MODELING
-- Business Purpose: Calculate regulatory provisions under IFRS 9 / CECL / Basel III.
-- Expected Loss ($) = Exposure at Default (EAD) * Probability of Default (PD) * Loss Given Default (LGD)
-- Benchmark Assumptions:
-- LGD (Loss Given Default) = 65% (Empirical unsecured credit card / personal loan recovery standard)
-- ==============================================================================

WITH portfolio_risk_metrics AS (
    SELECT
        risk_tier,
        COUNT(*) AS borrower_count,
        SUM(default_status) AS actual_defaults,
        
        -- Historical Observed Default Probability (PD)
        ROUND(AVG(default_status)::NUMERIC, 4) AS observed_pd,

        -- Total Outstanding Debt Exposure
        ROUND(SUM(total_debt), 2) AS total_drawn_debt,

        -- Regulatory Exposure at Default (EAD)
        ROUND(SUM(exposure_at_default), 2) AS total_ead,

        -- Benchmark Loss Given Default (LGD): 65% for unsecured retail credit
        0.65 AS benchmark_lgd,

        -- Expected Default Loss ($) = SUM(EAD * PD * LGD)
        ROUND(
            SUM(exposure_at_default * (
                CASE 
                    WHEN risk_tier = 'Severe / Critical Risk' THEN 0.684
                    WHEN risk_tier = 'High Risk' THEN 0.325
                    WHEN risk_tier = 'Moderate Risk' THEN 0.048
                    ELSE 0.008
                END
            ) * 0.65), 
            2
        ) AS modeled_expected_loss_usd,

        -- Actual Realized Default Loss ($) Assuming 65% Net Charge-off on Defaulted Accounts
        ROUND(SUM(CASE WHEN default_status = 1 THEN total_debt * 0.65 ELSE 0 END), 2) AS realized_net_loss_usd
    FROM vw_credit_risk_engineered
    GROUP BY risk_tier
)
SELECT
    risk_tier,
    borrower_count,
    actual_defaults,
    ROUND((actual_defaults::NUMERIC / borrower_count * 100.0), 2) AS actual_default_rate_pct,
    total_drawn_debt,
    total_ead,
    modeled_expected_loss_usd,
    realized_net_loss_usd,
    -- Average Loss per Defaulted Customer
    ROUND(
        CASE 
            WHEN actual_defaults > 0 THEN realized_net_loss_usd / actual_defaults 
            ELSE 0.0 
        END, 
        2
    ) AS avg_loss_per_defaulted_borrower
FROM portfolio_risk_metrics
ORDER BY realized_net_loss_usd DESC;

-- 5B. PORTFOLIO-WIDE RISK EXECUTIVE SUMMARY METRICS
SELECT
    COUNT(*) AS total_portfolio_customers,
    ROUND(SUM(total_debt), 2) AS total_drawn_exposure_usd,
    ROUND(SUM(exposure_at_default), 2) AS total_regulatory_ead_usd,
    ROUND(SUM(CASE WHEN default_status = 1 THEN total_debt ELSE 0 END), 2) AS gross_defaulted_balance_usd,
    ROUND(SUM(CASE WHEN default_status = 1 THEN total_debt * 0.65 ELSE 0 END), 2) AS net_credit_loss_usd,
    ROUND(
        SUM(CASE WHEN default_status = 1 THEN total_debt * 0.65 ELSE 0 END) / NULLIF(SUM(default_status), 0),
        2
    ) AS avg_net_loss_per_default_usd,
    ROUND(
        100.0 * SUM(CASE WHEN default_status = 1 THEN total_debt * 0.65 ELSE 0 END) / SUM(total_debt),
        2
    ) AS portfolio_net_loss_rate_pct
FROM vw_credit_risk_engineered;