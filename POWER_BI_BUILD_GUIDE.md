# Power BI Dashboard Build Guide

The PBIX file is intentionally not fabricated. Build and save the report in Power BI Desktop using the supplied CSVs or MySQL database.

## Data model
- `customers[customer_id]` 1-to-many `transactions[customer_id]`
- `transactions[transaction_id]` 1-to-many `installments[transaction_id]`
- `transactions[transaction_id]` 1-to-1 `payment_plans[transaction_id]`

Use single-direction filtering from dimensions to facts where possible.

## Suggested report pages
### 1. Portfolio Overview
Cards: Due Installments, Paid Installments, Late Installments, Defaulted Installments, Default Rate, Flagged Amount.
Visuals: monthly status trend; status distribution; provider comparison.

### 2. Customer Risk
Visuals: default rate by income band; default rate by credit-score band; customer risk segment distribution; top repeat defaulters table.

### 3. Repayment Behaviour
Visuals: paid/late/defaulted trend by due month; average days late; status by installment number; plan type comparison.

### 4. Provider & Merchant
Visuals: provider default rate; merchant category late/default counts; provider x merchant matrix.

## Suggested DAX measures
```DAX
Due Installments =
CALCULATE(
    COUNTROWS(installments),
    installments[payment_status] IN {"Paid", "Late", "Defaulted"}
)

Paid Installments =
CALCULATE(
    COUNTROWS(installments),
    installments[payment_status] = "Paid"
)

Late Installments =
CALCULATE(
    COUNTROWS(installments),
    installments[payment_status] = "Late"
)

Defaulted Installments =
CALCULATE(
    COUNTROWS(installments),
    installments[payment_status] = "Defaulted"
)

Default Rate =
DIVIDE([Defaulted Installments], [Due Installments], 0)

Late Rate =
DIVIDE([Late Installments], [Due Installments], 0)

Flagged Amount =
CALCULATE(
    SUM(installments[installment_amount]),
    installments[payment_status] IN {"Late", "Defaulted"}
)
```

Use INR formatting for amount measures. Label the dashboard clearly as synthetic portfolio analysis.
