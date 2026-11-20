-- сотрудники
SELECT
    personid AS external_id,
    NULLIF(
        LTRIM(RTRIM(ISNULL(lastname, '') + ' ' + ISNULL(firstname, ''))),
        ''
    ) AS full_name
FROM personnel;
