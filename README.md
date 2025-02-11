# Commission Calculation Database View

## Overview

This project provides a SQL-based solution for calculating monthly commission rates for sales representatives based on their sales performance. The commission structure includes a base commission rate and a bonus for exceeding the sales quota.

## Commission Structure

- Sales representatives have a monthly quota of $10,000 in sales.
- They earn a 5% commission on all sales up to the quota.
- Any sales exceeding the $10,000 quota earn an additional 5% (total 10%) commission.

### Example Calculations

#### Example 1:

- Salesperson 1 sells $1,000 in January → Earns $50 commission.
- Sells $2,000 in February → Earns $100 commission.

#### Example 2:

- Salesperson 2 sells $8,000 in January → Earns $400 commission.
- Sells $4,000 in February → Earns $200 (for first $2,000) + $100 bonus (for exceeding $10,000), totaling $300.

## Database Schema

The project assumes the following database tables:

### Customers Table

| Column           | Type    | Description                            |
|------------------|---------|----------------------------------------|
| `customer`       | INT     | Unique customer ID                     |
| `customer_name`  | TEXT    | Customer name                          |
| `employee_id`    | INT | Assigned Sales Representative ID           |

### Invoices Table

| Column           | Type    | Description                            |
|------------------|---------|----------------------------------------|
| `invoice_id`     | INT     | Unique invoice ID                      |
| `date`           | DATE    | Transaction date                       |
| `customer_id`    | INT     | Customer ID (Foreign Key)              |
| `amount`         | DECIMAL | Invoice amount                         |

### Employees Table

| Column           | Type    | Description                            |
|------------------|---------|----------------------------------------|
| `employee_id`    | INT     | Unique employee ID                     |
| `employee_name`  | TEXT    | Employee name                          |
| `location`       | TEXT    | Employee's location                    |

## SQL Query Implementation

The SQL query calculates monthly commission rates based on sales performance.

```sql
WITH running_sales AS (
    SELECT
        i.invoice_id,
        i.customer_id,
        e.employee_id,
        i.amount,
        SUM(i.amount) OVER (
            PARTITION BY e.employee_id
            ORDER BY i.invoice_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS running_total
    FROM
        public."Invoices" i
        INNER JOIN public."Customers" c ON i.customer_id = c.customer_id
        INNER JOIN public."Employees" e ON c.employee_id = e.employee_id
    ORDER BY
        i.invoice_id
)
SELECT
    invoice_id,
    customer_id,
    employee_id,
    amount,
    running_total,
    CASE
        WHEN running_total <= 10000 THEN amount * 0.05
        ELSE (10000 - (running_total - amount)) * 0.05 + (amount - (10000 - (running_total - amount))) * 0.1
    END AS commission
FROM
    running_sales
ORDER BY
    invoice_id;
```

## Report Validation

To validate the commission calculations, the following test cases should pass:

1. Company ABC should have total cumulative sales of $12,000.
2. John Smith should have a total cumulative commission of $700.
3. John Smith should have a monthly commission of $300 in February.
4. Jane Doe should have a total cumulative commission of $300.
