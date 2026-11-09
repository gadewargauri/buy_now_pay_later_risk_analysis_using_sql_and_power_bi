USE bnpl_risk;

-- 1. Dataset volume and basic validation
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'transactions', COUNT(*) FROM transactions
UNION ALL SELECT 'payment_plans', COUNT(*) FROM payment_plans
UNION ALL SELECT 'installments', COUNT(*) FROM installments;

-- 2. Overall installment repayment status
SELECT payment_status, COUNT(*) AS installments,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM installments), 2) AS pct
FROM installments GROUP BY payment_status ORDER BY installments DESC;

-- 3. Late payment rate among installments that are due
SELECT ROUND(100.0 * SUM(payment_status = 'Late') /
       NULLIF(SUM(payment_status IN ('Paid','Late','Defaulted')),0),2) AS late_rate_pct
FROM installments;

-- 4. Default rate among installments that are due
SELECT ROUND(100.0 * SUM(payment_status = 'Defaulted') /
       NULLIF(SUM(payment_status IN ('Paid','Late','Defaulted')),0),2) AS default_rate_pct
FROM installments;

-- 5. Total unpaid overdue exposure (late + defaulted; illustrative status-based measure)
SELECT ROUND(SUM(installment_amount),2) AS overdue_exposure
FROM installments WHERE payment_status IN ('Late','Defaulted');

-- 6. Repeat defaulters: customers with 2+ defaulted installments
SELECT t.customer_id, COUNT(*) AS defaulted_installments,
       ROUND(SUM(i.installment_amount),2) AS defaulted_installment_value
FROM transactions t JOIN installments i ON t.transaction_id=i.transaction_id
WHERE i.payment_status='Defaulted'
GROUP BY t.customer_id HAVING COUNT(*) >= 2
ORDER BY defaulted_installments DESC, defaulted_installment_value DESC;

-- 7. Repayment status by income band
SELECT CASE WHEN c.annual_income < 300000 THEN 'Low'
            WHEN c.annual_income < 700000 THEN 'Medium'
            ELSE 'High' END AS income_band,
       COUNT(*) AS due_installments,
       SUM(i.payment_status='Defaulted') AS defaults,
       ROUND(100.0*SUM(i.payment_status='Defaulted')/
         NULLIF(COUNT(*),0),2) AS default_rate_pct
FROM customers c
JOIN transactions t ON c.customer_id=t.customer_id
JOIN installments i ON t.transaction_id=i.transaction_id
WHERE i.payment_status IN ('Paid','Late','Defaulted')
GROUP BY income_band ORDER BY default_rate_pct DESC;

-- 8. Repayment behaviour by credit-score band
SELECT CASE WHEN c.credit_score < 600 THEN '520-599'
            WHEN c.credit_score < 680 THEN '600-679'
            WHEN c.credit_score < 760 THEN '680-759'
            ELSE '760-850' END AS score_band,
       COUNT(*) AS due_installments,
       SUM(i.payment_status='Defaulted') AS defaults,
       ROUND(100.0*SUM(i.payment_status='Defaulted')/COUNT(*),2) AS default_rate_pct
FROM customers c JOIN transactions t ON c.customer_id=t.customer_id
JOIN installments i ON t.transaction_id=i.transaction_id
WHERE i.payment_status IN ('Paid','Late','Defaulted')
GROUP BY score_band ORDER BY default_rate_pct DESC;

-- 9. Provider-wise default rate
SELECT t.provider, COUNT(*) AS due_installments,
       SUM(i.payment_status='Defaulted') AS defaults,
       ROUND(100.0*SUM(i.payment_status='Defaulted')/COUNT(*),2) AS default_rate_pct
FROM transactions t JOIN installments i ON t.transaction_id=i.transaction_id
WHERE i.payment_status IN ('Paid','Late','Defaulted')
GROUP BY t.provider ORDER BY default_rate_pct DESC;

-- 10. Merchant-category repayment risk
SELECT t.merchant_category, COUNT(*) AS due_installments,
       SUM(i.payment_status='Late') AS late_count,
       SUM(i.payment_status='Defaulted') AS default_count
FROM transactions t JOIN installments i ON t.transaction_id=i.transaction_id
WHERE i.payment_status IN ('Paid','Late','Defaulted')
GROUP BY t.merchant_category ORDER BY default_count DESC;

-- 11. Average days late for installments paid after due date
SELECT ROUND(AVG(DATEDIFF(payment_date,due_date)),2) AS avg_days_late,
       MAX(DATEDIFF(payment_date,due_date)) AS max_days_late
FROM installments WHERE payment_status='Late' AND payment_date IS NOT NULL;

-- 12. Monthly repayment status trend (by due month)
SELECT DATE_FORMAT(due_date,'%Y-%m') AS due_month,
       COUNT(*) AS due_installments,
       SUM(payment_status='Paid') AS paid,
       SUM(payment_status='Late') AS late,
       SUM(payment_status='Defaulted') AS defaulted
FROM installments
WHERE payment_status IN ('Paid','Late','Defaulted')
GROUP BY due_month ORDER BY due_month;

-- 13. Installment number with highest default count
SELECT installment_number, COUNT(*) AS due_count,
       SUM(payment_status='Defaulted') AS default_count
FROM installments WHERE payment_status IN ('Paid','Late','Defaulted')
GROUP BY installment_number ORDER BY default_count DESC;

-- 14. Top 10 customers by overdue/defaulted amount
SELECT t.customer_id, ROUND(SUM(i.installment_amount),2) AS exposure
FROM transactions t JOIN installments i ON t.transaction_id=i.transaction_id
WHERE i.payment_status IN ('Late','Defaulted')
GROUP BY t.customer_id ORDER BY exposure DESC LIMIT 10;

-- 15. Transaction purchase amount vs default occurrence
SELECT CASE WHEN t.purchase_amount < 2000 THEN 'Below 2K'
            WHEN t.purchase_amount < 10000 THEN '2K-10K'
            ELSE '10K+' END AS purchase_band,
       COUNT(*) AS due_installments,
       SUM(i.payment_status='Defaulted') AS defaults,
       ROUND(100.0*SUM(i.payment_status='Defaulted')/COUNT(*),2) AS default_rate_pct
FROM transactions t JOIN installments i ON t.transaction_id=i.transaction_id
WHERE i.payment_status IN ('Paid','Late','Defaulted')
GROUP BY purchase_band ORDER BY default_rate_pct DESC;

-- 16. Customer repayment trend using LAG (chronological installment status)
WITH customer_history AS (
    SELECT t.customer_id, i.due_date, i.payment_status,
           LAG(i.payment_status) OVER (
             PARTITION BY t.customer_id ORDER BY i.due_date, i.installment_id
           ) AS previous_status
    FROM transactions t JOIN installments i ON t.transaction_id=i.transaction_id
    WHERE i.payment_status IN ('Paid','Late','Defaulted')
)
SELECT customer_id, due_date, previous_status, payment_status
FROM customer_history
WHERE previous_status IS NOT NULL
  AND previous_status <> payment_status
ORDER BY customer_id, due_date;

-- 17. Rank providers by default rate
WITH provider_metrics AS (
    SELECT t.provider,
           ROUND(100.0*SUM(i.payment_status='Defaulted')/COUNT(*),2) AS default_rate_pct
    FROM transactions t JOIN installments i ON t.transaction_id=i.transaction_id
    WHERE i.payment_status IN ('Paid','Late','Defaulted')
    GROUP BY t.provider
)
SELECT provider, default_rate_pct,
       DENSE_RANK() OVER (ORDER BY default_rate_pct DESC) AS risk_rank
FROM provider_metrics;

-- 18. Customer risk segment (illustrative rule-based segmentation)
WITH customer_metrics AS (
    SELECT t.customer_id,
           SUM(i.payment_status='Defaulted') AS default_count,
           SUM(i.payment_status='Late') AS late_count,
           COUNT(*) AS due_installments
    FROM transactions t JOIN installments i ON t.transaction_id=i.transaction_id
    WHERE i.payment_status IN ('Paid','Late','Defaulted')
    GROUP BY t.customer_id
)
SELECT customer_id, default_count, late_count, due_installments,
       CASE WHEN default_count >= 3 THEN 'Critical'
            WHEN default_count >= 1 OR late_count >= 3 THEN 'High'
            WHEN late_count >= 1 THEN 'Medium'
            ELSE 'Low' END AS risk_segment
FROM customer_metrics;

-- 19. Customers with no defaulted installments (among customers with due installments)
SELECT t.customer_id, COUNT(*) AS due_installments
FROM transactions t JOIN installments i ON t.transaction_id=i.transaction_id
WHERE i.payment_status IN ('Paid','Late','Defaulted')
GROUP BY t.customer_id
HAVING SUM(i.payment_status='Defaulted')=0;

-- 20. Payment plan comparison
SELECT p.plan_type, COUNT(*) AS due_installments,
       SUM(i.payment_status='Defaulted') AS defaults,
       ROUND(100.0*SUM(i.payment_status='Defaulted')/COUNT(*),2) AS default_rate_pct
FROM payment_plans p JOIN installments i ON p.transaction_id=i.transaction_id
WHERE i.payment_status IN ('Paid','Late','Defaulted')
GROUP BY p.plan_type ORDER BY default_rate_pct DESC;

-- 21. Employment type risk comparison
SELECT c.employment_type, COUNT(*) AS due_installments,
       SUM(i.payment_status='Defaulted') AS defaults,
       ROUND(100.0*SUM(i.payment_status='Defaulted')/COUNT(*),2) AS default_rate_pct
FROM customers c JOIN transactions t ON c.customer_id=t.customer_id
JOIN installments i ON t.transaction_id=i.transaction_id
WHERE i.payment_status IN ('Paid','Late','Defaulted')
GROUP BY c.employment_type ORDER BY default_rate_pct DESC;

-- 22. Monthly customer activity and default count
SELECT DATE_FORMAT(i.due_date,'%Y-%m') AS due_month,
       COUNT(DISTINCT t.customer_id) AS active_customers,
       COUNT(*) AS installments_due,
       SUM(i.payment_status='Defaulted') AS defaults
FROM transactions t JOIN installments i ON t.transaction_id=i.transaction_id
WHERE i.payment_status IN ('Paid','Late','Defaulted')
GROUP BY due_month ORDER BY due_month;

-- 23. View: customer repayment summary
CREATE OR REPLACE VIEW vw_customer_repayment_summary AS
SELECT t.customer_id,
       COUNT(*) AS due_installments,
       SUM(i.payment_status='Paid') AS paid_installments,
       SUM(i.payment_status='Late') AS late_installments,
       SUM(i.payment_status='Defaulted') AS defaulted_installments,
       ROUND(SUM(CASE WHEN i.payment_status IN ('Late','Defaulted')
                      THEN i.installment_amount ELSE 0 END),2) AS flagged_amount
FROM transactions t JOIN installments i ON t.transaction_id=i.transaction_id
WHERE i.payment_status IN ('Paid','Late','Defaulted')
GROUP BY t.customer_id;

-- 24. Query the view
SELECT * FROM vw_customer_repayment_summary
ORDER BY defaulted_installments DESC, flagged_amount DESC;
