-- продажи по сотрудникам
SELECT
    CAST(YEAR(dater) * 100 + MONTH(dater) AS int) AS month_code,
    CASE
        WHEN ISNUMERIC(loginid) = 1 THEN CAST(loginid AS int)
    END AS personnel_external_id,
    SUM(amount) AS sales_revenue,
    COUNT(DISTINCT receiptn) AS sales_receipts
FROM journal
WHERE transtype = 101
  AND dater IS NOT NULL
GROUP BY
    YEAR(dater) * 100 + MONTH(dater),
    CASE
        WHEN ISNUMERIC(loginid) = 1 THEN CAST(loginid AS int)
    END;
