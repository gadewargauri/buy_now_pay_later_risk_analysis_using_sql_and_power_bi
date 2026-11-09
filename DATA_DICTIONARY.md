# Data Dictionary

All records are synthetic. Amounts are in Indian rupees (INR).

## customers.csv
| Column | Description |
|---|---|
| customer_id | Unique synthetic customer identifier |
| age | Customer age |
| annual_income | Simulated annual income in INR |
| employment_type | Simulated employment category |
| city | Simulated city |
| credit_score | Simulated credit score (520–850) |

## transactions.csv
| Column | Description |
|---|---|
| transaction_id | Unique transaction identifier |
| customer_id | Customer who made the purchase |
| purchase_date | Purchase date |
| purchase_amount | Purchase amount in INR |
| merchant_category | Merchant's broad business category |
| provider | Simulated BNPL provider |

## payment_plans.csv
| Column | Description |
|---|---|
| plan_id | Unique plan identifier |
| transaction_id | Related transaction |
| plan_type | Pay in 3, Pay in 4, or Pay in 6 |
| total_installments | Number of scheduled installments |
| interest_rate | Simulated plan interest rate (%) |

## installments.csv
| Column | Description |
|---|---|
| installment_id | Unique installment identifier |
| transaction_id | Related transaction |
| installment_number | Installment sequence number |
| due_date | Scheduled due date |
| payment_date | Actual payment date; NULL if unpaid at cutoff |
| installment_amount | Scheduled installment amount in INR |
| payment_status | Paid, Late, Defaulted, or Upcoming |

## Important analytical assumptions
- Dataset is synthetic, generated for portfolio practice.
- `Late` means paid after due date in this simulation.
- `Defaulted` means unpaid and classified as defaulted by the simulation at the observation cutoff; it is not a regulatory definition.
- `Upcoming` means the installment due date is after the simulation cutoff.
- `Late` and `Defaulted` are kept separate so analysts can compare late payment and default behaviour.
- The project uses installment-level outcomes; do not confuse an installment default rate with a customer default rate.
