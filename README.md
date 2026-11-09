# BNPL Credit Risk & Repayment Behaviour Analysis

**FinTech | Data Analytics | MySQL 8.0 | Power BI**

A portfolio-ready SQL project that explores Buy Now Pay Later (BNPL) customer repayment behaviour, late installments, repeat defaults, overdue exposure and customer segments.

> **Important:** The included data is entirely synthetic and generated for learning/demo purposes. It does not represent real customers, a real BNPL provider, or actual credit decisions. Risk segments are illustrative analytical labels, not lending recommendations.

## Project highlights
- 1,000 synthetic customers
- 4,583 synthetic transactions
- 17,734 installment-level records
- Four related CSV tables
- MySQL schema and 24 business-analysis SQL queries
- Window functions (`LAG`, `DENSE_RANK`), CTEs, joins, aggregations, CASE expressions and date analysis

## Repository structure
```text
BNPL-Credit-Risk-Analysis/
├── Dataset/
│   ├── customers.csv
│   ├── transactions.csv
│   ├── installments.csv
│   └── payment_plans.csv
├── SQL/
│   ├── 01_database_schema.sql
│   └── 02_business_analysis_queries.sql
├── Dashboard/
│   └── POWER_BI_BUILD_GUIDE.md
├── Documentation/
│   └── DATA_DICTIONARY.md
└── README.md
```

## How to run in MySQL Workbench
1. Install MySQL 8.0+ and open MySQL Workbench.
2. Run `SQL/01_database_schema.sql` to create the database and tables.
3. Import the four CSV files using **Table Data Import Wizard**.
4. Import in this order: `customers`, `transactions`, `payment_plans`, `installments`.
5. Open and run `SQL/02_business_analysis_queries.sql`.
6. Review the result sets and record your own verified findings.

## Suggested Power BI workflow
1. Connect Power BI Desktop to the `bnpl_risk` MySQL database.
2. Load the four tables and confirm the relationships.
3. Use the dashboard guide in `Dashboard/POWER_BI_BUILD_GUIDE.md`.
4. Save your finished report as `Dashboard/BNPL_Risk_Dashboard.pbix`.
5. Add screenshots of your own report to `Dashboard/Dashboard_Screenshots/`.

## Suggested KPIs
- Due installments
- On-time payment rate
- Late installment rate
- Defaulted installment rate
- Flagged installment amount (late + defaulted)
- Repeat defaulter count
- Average days late

**Metric note:** Rates in the SQL scripts use installments with statuses `Paid`, `Late`, or `Defaulted` as the due-installment denominator. `Upcoming` installments are excluded. The generated data labels late payments separately from defaults; no universal regulatory definition of default is asserted.

## Dataset and limitations
The synthetic dataset covers purchase dates from January 2025 through October 2026. Payment outcomes are simulated. Some installment due dates fall after the simulation cutoff and are labelled `Upcoming`. For this reason, results are suitable for SQL practice and dashboard development, not real-world credit underwriting.


**BNPL Credit Risk & Repayment Behaviour Analysis | MySQL, SQL, Power BI**
- Designed a relational database to analyze BNPL customer, transaction, payment-plan and installment data.
- Used SQL joins, CTEs, subqueries and window functions to examine late payments, repeat defaults and repayment trends.
- Compared repayment outcomes across customer income bands, credit-score groups, providers and merchant categories.
- Developed a Power BI dashboard to monitor repayment performance and customer risk segments.


