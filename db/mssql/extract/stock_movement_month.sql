-- движения склада
SELECT
    CAST(YEAR(DateAdd) * 100 + MONTH(DateAdd) AS int) AS month_code,
    ProductID AS product_external_id,
    StorageID AS storage_external_id,
    RangeID AS range_external_id,
    SUM(CASE WHEN Count > 0 THEN Count ELSE 0 END) AS quantity_in,
    SUM(CASE WHEN Count < 0 THEN -Count ELSE 0 END) AS quantity_out
FROM bm_StorageOperations
WHERE OperationID IN (1, 2)
  AND DateAdd IS NOT NULL
GROUP BY
    YEAR(DateAdd) * 100 + MONTH(DateAdd),
    ProductID,
    StorageID,
    RangeID;
