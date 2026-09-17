-- Bank Credit Risk Analysis
-- SQL analysis using PostgreSQL
-- Dataset: synthetic credit risk customer data

-- ============================================================
-- 1. TABLE SETUP
-- ============================================================

CREATE TABLE IF NOT EXISTS credit_risk_dataset (
    customer_id VARCHAR(16) PRIMARY KEY,
    age INTEGER,
    gender VARCHAR(10),
    annual_income NUMERIC(12,2),
    employment_status VARCHAR(20),
    credit_score INTEGER,
    total_debt NUMERIC(12,2),
    debt_to_income_ratio NUMERIC(6,4),
    credit_card_limit NUMERIC(12,2),
    credit_utilization_rate NUMERIC(6,4),
    late_payments_30_days INTEGER,
    late_payments_90_days INTEGER,
    default_status SMALLINT,
    loan_purpose VARCHAR(40)
);

-- ============================================================
-- 2. DATA QUALITY CHECKS
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(customer_id) AS missing_customer_ids,
    COUNT(customer_id) - COUNT(DISTINCT customer_id) AS duplicate_customer_ids,
    COUNT(*) FILTER (WHERE credit_score NOT BETWEEN 300 AND 850) AS invalid_credit_scores,
    COUNT(*) FILTER (WHERE annual_income <= 0) AS invalid_income,
    COUNT(*) FILTER (WHERE total_debt < 0) AS invalid_debt,
    COUNT(*) FILTER (WHERE debt_to_income_ratio < 0 OR debt_to_income_ratio > 1) AS invalid_dti,
    COUNT(*) FILTER (WHERE credit_utilization_rate < 0) AS invalid_utilization,
    COUNT(*) FILTER (WHERE default_status NOT IN (0,1)) AS invalid_default_status
FROM credit_risk_dataset;

-- Check for duplicate customer IDs
SELECT customer_id, COUNT(*) AS customer_count
FROM credit_risk_dataset
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- ============================================================
-- 3. FEATURE ENGINEERING
-- ============================================================

CREATE OR REPLACE VIEW vw_credit_risk_engineered AS
SELECT
    *,
    CASE
        WHEN credit_score < 600 THEN 'Poor'
        WHEN credit_score < 700 THEN 'Fair'
        WHEN credit_score < 800 THEN 'Good'
        ELSE 'Excellent'
    END AS credit_score_bucket,

    CASE
        WHEN annual_income < 45000 THEN '<45K'
        WHEN annual_income < 85000 THEN '45K-85K'
        WHEN annual_income < 150000 THEN '85K-150K'
        ELSE '150K+'
    END AS income_bracket,

    CASE
        WHEN debt_to_income_ratio < 0.20 THEN '<20%'
        WHEN debt_to_income_ratio < 0.35 THEN '20-35%'
        WHEN debt_to_income_ratio < 0.45 THEN '35-45%'
        ELSE '>45%'
    END AS dti_band,

    CASE
        WHEN credit_utilization_rate < 0.30 THEN '<30%'
        WHEN credit_utilization_rate < 0.50 THEN '30-50%'
        WHEN credit_utilization_rate < 0.75 THEN '50-75%'
        WHEN credit_utilization_rate <= 1.00 THEN '75-100%'
        ELSE '>100%'
    END AS utilization_band,

    CASE
        WHEN credit_score < 600 OR debt_to_income_ratio > 0.45
             OR credit_utilization_rate > 0.80
             OR late_payments_90_days > 0 THEN 'High'
        WHEN credit_score < 700 OR debt_to_income_ratio > 0.35
             OR credit_utilization_rate > 0.50 THEN 'Medium'
        ELSE 'Low'
    END AS risk_tier
FROM credit_risk_dataset;

-- ============================================================
-- 4. BASIC PORTFOLIO KPIs
-- ============================================================

SELECT
    COUNT(*) AS total_customers,
    SUM(default_status) AS defaulted_customers,
    ROUND(100.0 * SUM(default_status) / COUNT(*), 2) AS default_rate_pct,
    ROUND(SUM(total_debt), 2) AS total_exposure,
    ROUND(SUM(CASE WHEN default_status = 1 THEN total_debt ELSE 0 END), 2) AS defaulted_exposure,
    ROUND(AVG(credit_score), 2) AS avg_credit_score,
    ROUND(AVG(debt_to_income_ratio) * 100, 2) AS avg_dti_pct,
    ROUND(AVG(credit_utilization_rate) * 100, 2) AS avg_utilization_pct
FROM credit_risk_dataset;

-- ============================================================
-- 5. DEFAULT RATE BY CREDIT SCORE
-- ============================================================

SELECT
    credit_score_bucket,
    COUNT(*) AS customers,
    SUM(default_status) AS defaults,
    ROUND(100.0 * SUM(default_status) / COUNT(*), 2) AS default_rate_pct,
    ROUND(AVG(credit_score), 1) AS avg_credit_score,
    ROUND(SUM(total_debt), 2) AS total_exposure
FROM vw_credit_risk_engineered
GROUP BY credit_score_bucket
ORDER BY
    CASE credit_score_bucket
        WHEN 'Poor' THEN 1
        WHEN 'Fair' THEN 2
        WHEN 'Good' THEN 3
        WHEN 'Excellent' THEN 4
    END;

-- ============================================================
-- 6. DEFAULT RATE BY EMPLOYMENT STATUS
-- ============================================================

SELECT
    employment_status,
    COUNT(*) AS customers,
    SUM(default_status) AS defaults,
    ROUND(100.0 * SUM(default_status) / COUNT(*), 2) AS default_rate_pct,
    ROUND(AVG(credit_score), 1) AS avg_credit_score,
    ROUND(AVG(debt_to_income_ratio) * 100, 2) AS avg_dti_pct,
    ROUND(AVG(credit_utilization_rate) * 100, 2) AS avg_utilization_pct
FROM credit_risk_dataset
GROUP BY employment_status
ORDER BY default_rate_pct DESC;

-- ============================================================
-- 7. DEFAULT RATE BY LOAN PURPOSE
-- ============================================================

SELECT
    loan_purpose,
    COUNT(*) AS customers,
    SUM(default_status) AS defaults,
    ROUND(100.0 * SUM(default_status) / COUNT(*), 2) AS default_rate_pct,
    ROUND(SUM(total_debt), 2) AS total_exposure
FROM credit_risk_dataset
GROUP BY loan_purpose
ORDER BY default_rate_pct DESC;

-- ============================================================
-- 8. DTI AND UTILIZATION ANALYSIS
-- ============================================================

SELECT
    dti_band,
    COUNT(*) AS customers,
    SUM(default_status) AS defaults,
    ROUND(100.0 * SUM(default_status) / COUNT(*), 2) AS default_rate_pct,
    ROUND(AVG(debt_to_income_ratio) * 100, 2) AS avg_dti_pct
FROM vw_credit_risk_engineered
GROUP BY dti_band
ORDER BY
    CASE dti_band
        WHEN '<20%' THEN 1
        WHEN '20-35%' THEN 2
        WHEN '35-45%' THEN 3
        WHEN '>45%' THEN 4
    END;

SELECT
    utilization_band,
    COUNT(*) AS customers,
    SUM(default_status) AS defaults,
    ROUND(100.0 * SUM(default_status) / COUNT(*), 2) AS default_rate_pct,
    ROUND(AVG(credit_utilization_rate) * 100, 2) AS avg_utilization_pct
FROM vw_credit_risk_engineered
GROUP BY utilization_band
ORDER BY
    CASE utilization_band
        WHEN '<30%' THEN 1
        WHEN '30-50%' THEN 2
        WHEN '50-75%' THEN 3
        WHEN '75-100%' THEN 4
        WHEN '>100%' THEN 5
    END;

-- ============================================================
-- 9. RISK TIER ANALYSIS
-- ============================================================

SELECT
    risk_tier,
    COUNT(*) AS customers,
    SUM(default_status) AS defaults,
    ROUND(100.0 * SUM(default_status) / COUNT(*), 2) AS default_rate_pct,
    ROUND(SUM(total_debt), 2) AS total_exposure,
    ROUND(AVG(credit_score), 1) AS avg_credit_score,
    ROUND(AVG(debt_to_income_ratio) * 100, 2) AS avg_dti_pct
FROM vw_credit_risk_engineered
GROUP BY risk_tier
ORDER BY
    CASE risk_tier
        WHEN 'High' THEN 1
        WHEN 'Medium' THEN 2
        WHEN 'Low' THEN 3
    END;

-- ============================================================
-- 10. WINDOW FUNCTIONS
-- Compare customers with their employment-group averages
-- ============================================================

WITH customer_benchmark AS (
    SELECT
        customer_id,
        employment_status,
        credit_score,
        debt_to_income_ratio,
        credit_utilization_rate,
        total_debt,
        default_status,
        ROUND(AVG(debt_to_income_ratio) OVER (
            PARTITION BY employment_status
        ) * 100, 2) AS peer_avg_dti_pct,
        ROUND(AVG(credit_utilization_rate) OVER (
            PARTITION BY employment_status
        ) * 100, 2) AS peer_avg_utilization_pct,
        NTILE(4) OVER (
            ORDER BY debt_to_income_ratio DESC
        ) AS dti_quartile,
        RANK() OVER (
            ORDER BY debt_to_income_ratio DESC, credit_utilization_rate DESC
        ) AS risk_rank
    FROM credit_risk_dataset
)
SELECT *
FROM customer_benchmark
WHERE dti_quartile = 1
ORDER BY risk_rank
LIMIT 50;

-- ============================================================
-- 11. HIGH-RISK CUSTOMER LIST
-- ============================================================

SELECT
    customer_id,
    credit_score,
    debt_to_income_ratio,
    credit_utilization_rate,
    late_payments_30_days,
    late_payments_90_days,
    total_debt,
    default_status
FROM vw_credit_risk_engineered
WHERE risk_tier = 'High'
ORDER BY
    default_status DESC,
    late_payments_90_days DESC,
    debt_to_income_ratio DESC,
    credit_utilization_rate DESC
LIMIT 50;

-- ============================================================
-- 12. DELINQUENCY ANALYSIS
-- ============================================================

SELECT
    CASE
        WHEN late_payments_90_days > 0 THEN '90+ Days Late'
        WHEN late_payments_30_days > 0 THEN '30 Days Late'
        ELSE 'No Recorded Late Payment'
    END AS delinquency_status,
    COUNT(*) AS customers,
    SUM(default_status) AS defaults,
    ROUND(100.0 * SUM(default_status) / COUNT(*), 2) AS default_rate_pct
FROM credit_risk_dataset
GROUP BY 1
ORDER BY default_rate_pct DESC;

-- ============================================================
-- 13. BUSINESS SUMMARY BY RISK TIER
-- ============================================================

SELECT
    risk_tier,
    COUNT(*) AS customers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS customer_share_pct,
    SUM(default_status) AS defaults,
    ROUND(100.0 * SUM(default_status) / COUNT(*), 2) AS default_rate_pct,
    ROUND(SUM(total_debt), 2) AS total_exposure,
    ROUND(SUM(CASE WHEN default_status = 1 THEN total_debt ELSE 0 END), 2) AS defaulted_exposure
FROM vw_credit_risk_engineered
GROUP BY risk_tier
ORDER BY default_rate_pct DESC;

-- Note:
-- This project uses synthetic data. Risk tiers and any loss assumptions
-- are analytical examples and should not be treated as real bank policy
-- or regulatory calculations.
