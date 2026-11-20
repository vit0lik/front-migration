-- поставщики
SELECT
    id AS external_id,
    NULLIF(firstname, '') AS name
FROM vendors;
