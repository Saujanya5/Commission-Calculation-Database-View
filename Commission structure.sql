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

