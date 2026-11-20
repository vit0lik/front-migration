-- типы документов
SELECT
    ID AS external_id,
    NULLIF(Description, '') AS name
FROM bm_JournalTypeDocuments;
