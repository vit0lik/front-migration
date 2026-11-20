-- категории
SELECT
    id AS external_id,
    NULLIF(description, '') AS name
FROM category;
