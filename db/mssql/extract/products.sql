-- товары
SELECT
    id AS external_id,
    NULLIF(description, '') AS name,
    CategoryID AS category_external_id,
    SizeID AS range_external_id
FROM product;
