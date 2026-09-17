import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

DATA_PATH = "data/credit_risk_dataset.csv"
OUTPUT_DIR = "outputs"
CHART_DIR = os.path.join(OUTPUT_DIR, "charts")

os.makedirs(OUTPUT_DIR, exist_ok=True)
os.makedirs(CHART_DIR, exist_ok=True)


def load_data():
    return pd.read_csv(DATA_PATH)


def clean_data(df):
    df = df.copy()
    df.columns = df.columns.str.strip()
    df = df.drop_duplicates()

    numeric_cols = [
        "Age", "Annual_Income", "Credit_Score", "Total_Debt",
        "Debt_to_Income_Ratio", "Credit_Card_Limit",
        "Credit_Utilization_Rate", "Late_Payments_30_Days",
        "Late_Payments_90_Days", "Default_Status"
    ]

    for col in numeric_cols:
        df[col] = pd.to_numeric(df[col], errors="coerce")

    return df


def add_features(df):
    df = df.copy()

    df["Credit_Score_Bucket"] = pd.cut(
        df["Credit_Score"],
        bins=[0, 599, 699, 799, np.inf],
        labels=["Poor", "Fair", "Good", "Excellent"]
    )

    df["Income_Bracket"] = pd.cut(
        df["Annual_Income"],
        bins=[0, 45000, 85000, 150000, np.inf],
        labels=["<45K", "45K-85K", "85K-150K", "150K+"]
    )

    df["DTI_Band"] = pd.cut(
        df["Debt_to_Income_Ratio"],
        bins=[-np.inf, 0.20, 0.35, 0.45, np.inf],
        labels=["<20%", "20-35%", "35-45%", ">45%"]
    )

    df["Utilization_Band"] = pd.cut(
        df["Credit_Utilization_Rate"],
        bins=[-np.inf, 0.30, 0.50, 0.75, 1.00, np.inf],
        labels=["<30%", "30-50%", "50-75%", "75-100%", ">100%"]
    )

    df["Default_Label"] = np.where(
        df["Default_Status"] == 1, "Defaulted", "Current"
    )

    return df


def quality_audit(df):
    audit = pd.DataFrame({
        "Metric": [
            "Rows", "Columns", "Duplicate Rows", "Duplicate Customer IDs",
            "Missing Values", "Invalid Credit Scores", "Invalid Income",
            "Invalid Debt", "Invalid DTI", "Invalid Utilization",
            "Invalid Default Status"
        ],
        "Value": [
            len(df),
            len(df.columns),
            int(df.duplicated().sum()),
            int(df["Customer_ID"].duplicated().sum()),
            int(df.isna().sum().sum()),
            int(((df["Credit_Score"] < 300) | (df["Credit_Score"] > 850)).sum()),
            int((df["Annual_Income"] <= 0).sum()),
            int((df["Total_Debt"] < 0).sum()),
            int(((df["Debt_to_Income_Ratio"] < 0) | (df["Debt_to_Income_Ratio"] > 1)).sum()),
            int((df["Credit_Utilization_Rate"] < 0).sum()),
            int((~df["Default_Status"].isin([0, 1])).sum())
        ]
    })
    audit.to_csv(os.path.join(OUTPUT_DIR, "data_quality_audit.csv"), index=False)
    return audit


def summary_table(df, group_col, output_name):
    result = (
        df.groupby(group_col, observed=False)
        .agg(
            Customers=("Customer_ID", "count"),
            Defaults=("Default_Status", "sum"),
            Default_Rate=("Default_Status", "mean"),
            Total_Debt=("Total_Debt", "sum"),
            Avg_Credit_Score=("Credit_Score", "mean"),
            Avg_DTI=("Debt_to_Income_Ratio", "mean"),
            Avg_Utilization=("Credit_Utilization_Rate", "mean")
        )
        .reset_index()
    )
    result["Default_Rate"] = result["Default_Rate"] * 100
    result.to_csv(os.path.join(OUTPUT_DIR, output_name), index=False)
    return result


def create_kpis(df):
    total_customers = len(df)
    defaults = int(df["Default_Status"].sum())
    total_exposure = df["Total_Debt"].sum()
    defaulted_exposure = df.loc[df["Default_Status"] == 1, "Total_Debt"].sum()

    kpis = pd.DataFrame({
        "Metric": [
            "Total Customers", "Defaulted Customers", "Default Rate (%)",
            "Total Exposure", "Defaulted Exposure", "Average Credit Score",
            "Average DTI (%)", "Average Utilization (%)"
        ],
        "Value": [
            total_customers,
            defaults,
            round(defaults / total_customers * 100, 2) if total_customers else 0,
            round(total_exposure, 2),
            round(defaulted_exposure, 2),
            round(df["Credit_Score"].mean(), 2),
            round(df["Debt_to_Income_Ratio"].mean() * 100, 2),
            round(df["Credit_Utilization_Rate"].mean() * 100, 2)
        ]
    })
    kpis.to_csv(os.path.join(OUTPUT_DIR, "portfolio_kpis.csv"), index=False)
    return kpis


def create_charts(df):
    counts = df["Default_Label"].value_counts()
    counts.plot(kind="bar")
    plt.title("Current vs Defaulted Customers")
    plt.xlabel("Status")
    plt.ylabel("Customers")
    plt.tight_layout()
    plt.savefig(os.path.join(CHART_DIR, "default_status.png"), dpi=150)
    plt.close()

    score_summary = (
        df.groupby("Credit_Score_Bucket", observed=False)["Default_Status"]
        .mean()
        .mul(100)
    )
    score_summary.plot(kind="bar")
    plt.title("Default Rate by Credit Score Bucket")
    plt.xlabel("Credit Score Bucket")
    plt.ylabel("Default Rate (%)")
    plt.tight_layout()
    plt.savefig(os.path.join(CHART_DIR, "default_rate_credit_score.png"), dpi=150)
    plt.close()

    employment_summary = (
        df.groupby("Employment_Status")["Default_Status"]
        .mean()
        .mul(100)
        .sort_values(ascending=False)
    )
    employment_summary.plot(kind="bar")
    plt.title("Default Rate by Employment Status")
    plt.xlabel("Employment Status")
    plt.ylabel("Default Rate (%)")
    plt.tight_layout()
    plt.savefig(os.path.join(CHART_DIR, "default_rate_employment.png"), dpi=150)
    plt.close()

    for status, label in [(0, "Current"), (1, "Defaulted")]:
        subset = df[df["Default_Status"] == status]
        plt.scatter(
            subset["Credit_Score"],
            subset["Credit_Utilization_Rate"].mul(100),
            alpha=0.45,
            label=label
        )
    plt.title("Credit Score vs Credit Utilization")
    plt.xlabel("Credit Score")
    plt.ylabel("Utilization (%)")
    plt.legend()
    plt.tight_layout()
    plt.savefig(os.path.join(CHART_DIR, "credit_score_vs_utilization.png"), dpi=150)
    plt.close()


def main():
    df = load_data()
    df = clean_data(df)
    quality_audit(df)
    df = add_features(df)

    create_kpis(df)
    summary_table(df, "Credit_Score_Bucket", "credit_score_summary.csv")
    summary_table(df, "Employment_Status", "employment_summary.csv")
    summary_table(df, "Loan_Purpose", "loan_purpose_summary.csv")
    summary_table(df, "DTI_Band", "dti_summary.csv")
    summary_table(df, "Utilization_Band", "utilization_summary.csv")

    risk = df.copy()
    risk["Risk_Tier"] = np.select(
        [
            (risk["Credit_Score"] < 600) | (risk["Debt_to_Income_Ratio"] > 0.45),
            (risk["Credit_Score"] < 700) | (risk["Debt_to_Income_Ratio"] > 0.35)
        ],
        ["High", "Medium"],
        default="Low"
    )
    summary_table(risk, "Risk_Tier", "risk_tier_summary.csv")

    high_risk = risk[risk["Risk_Tier"] == "High"].copy()
    high_risk = high_risk.sort_values(
        ["Default_Status", "Debt_to_Income_Ratio", "Credit_Utilization_Rate"],
        ascending=[False, False, False]
    )
    high_risk.to_csv(os.path.join(OUTPUT_DIR, "high_risk_customers.csv"), index=False)

    df.to_csv(os.path.join(OUTPUT_DIR, "credit_risk_analysis_ready.csv"), index=False)
    create_charts(df)

    print("Credit risk EDA completed successfully.")
    print(f"Rows: {len(df):,}")
    print(f"Default rate: {df['Default_Status'].mean() * 100:.2f}%")
    print(f"Outputs saved in: {OUTPUT_DIR}/")


if __name__ == "__main__":
    main()
