-- размеры и порции
SELECT
    ID AS external_id,
    NULLIF(sizeid, '') AS name,
    portionrate AS factor
FROM size;
