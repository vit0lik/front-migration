-- продажи
WITH sales AS (
    SELECT
        CAST(YEAR(j.dater) * 100 + MONTH(j.dater) AS int) AS month_code,
        p.id AS product_external_id,
        c.id AS category_external_id,
        per.personid AS personnel_external_id,
        j.storeid AS storage_external_id,
        CASE
            WHEN ISNUMERIC(j.sizeid) = 1 THEN CAST(j.sizeid AS bigint)
        END AS range_external_id,
        j.quantity,
        j.amount
    FROM journal j
    JOIN product p
        ON p.productid = j.id
    LEFT JOIN category c
        ON c.id = CASE
            WHEN ISNUMERIC(j.categoryid) = 1 THEN CAST(j.categoryid AS bigint)
        END
    LEFT JOIN personnel per
        ON per.personid = CASE
            WHEN ISNUMERIC(j.loginid) = 1 THEN CAST(j.loginid AS int)
        END
    WHERE j.transtype = 101
      AND j.dater IS NOT NULL
)
SELECT
    month_code,
    product_external_id,
    category_external_id,
    personnel_external_id,
    storage_external_id,
    range_external_id,
    SUM(quantity) AS quantity,
    SUM(amount) AS revenue
FROM sales
GROUP BY
    month_code,
    product_external_id,
    category_external_id,
    personnel_external_id,
    storage_external_id,
    range_external_id;
