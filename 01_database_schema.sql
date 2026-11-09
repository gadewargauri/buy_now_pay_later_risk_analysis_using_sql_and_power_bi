-- BNPL Credit Risk & Repayment Behaviour Analysis
-- MySQL 8.0+
CREATE DATABASE IF NOT EXISTS bnpl_risk;
USE bnpl_risk;

DROP TABLE IF EXISTS installments;
DROP TABLE IF EXISTS payment_plans;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id VARCHAR(10) PRIMARY KEY,
    age INT NOT NULL,
    annual_income DECIMAL(12,2),
    employment_type VARCHAR(30),
    city VARCHAR(50),
    credit_score INT
);

CREATE TABLE transactions (
    transaction_id VARCHAR(12) PRIMARY KEY,
    customer_id VARCHAR(10) NOT NULL,
    purchase_date DATE NOT NULL,
    purchase_amount DECIMAL(12,2) NOT NULL,
    merchant_category VARCHAR(40),
    provider VARCHAR(40),
    CONSTRAINT fk_txn_customer FOREIGN KEY (customer_id)
      REFERENCES customers(customer_id)
);

CREATE TABLE payment_plans (
    plan_id VARCHAR(12) PRIMARY KEY,
    transaction_id VARCHAR(12) NOT NULL UNIQUE,
    plan_type VARCHAR(30),
    total_installments INT,
    interest_rate DECIMAL(5,2),
    CONSTRAINT fk_plan_txn FOREIGN KEY (transaction_id)
      REFERENCES transactions(transaction_id)
);

CREATE TABLE installments (
    installment_id VARCHAR(12) PRIMARY KEY,
    transaction_id VARCHAR(12) NOT NULL,
    installment_number INT,
    due_date DATE NOT NULL,
    payment_date DATE NULL,
    installment_amount DECIMAL(12,2) NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    CONSTRAINT fk_inst_txn FOREIGN KEY (transaction_id)
      REFERENCES transactions(transaction_id)
);

-- Load CSV files using MySQL Workbench Table Data Import Wizard
-- Import in this order: customers, transactions, payment_plans, installments.
