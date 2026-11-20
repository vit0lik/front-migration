-- закупки
WITH purchase AS (
    SELECT
        CAST(
            YEAR(COALESCE(d.Period, o.DateAdd)) * 100
            + MONTH(COALESCE(d.Period, o.DateAdd)) AS int
        ) AS month_code,
        o.ProductID AS product_external_id,
        o.VendorID AS vendor_external_id,
        o.StorageID AS storage_external_id,
        d.DocumentTypeID AS document_type_external_id,
        o.RangeID AS range_external_id,
        o.Count AS quantity,
        o.Amount AS amount
    FROM bm_StorageOperations o
    JOIN bm_JournalBarnetDocs d
        ON d.ID = o.DocumentID
    WHERE o.OperationID = 1
      AND COALESCE(d.Period, o.DateAdd) IS NOT NULL
)
SELECT
    month_code,
    product_external_id,
    vendor_external_id,
    storage_external_id,
    document_type_external_id,
    range_external_id,
    SUM(quantity) AS quantity,
    SUM(amount) AS amount
FROM purchase
GROUP BY
    month_code,
    product_external_id,
    vendor_external_id,
    storage_external_id,
    document_type_external_id,
    range_external_id;
