-- Типы документов
SET NOCOUNT ON;

SELECT 'insert into olap.dim_document_types (external_id, name) values ('
    + CAST(ID AS varchar(20)) + ', '''
    + REPLACE(ISNULL(Description, ''), '''', '''''') + ''');' AS [sql]
FROM [Front].[dbo].[bm_JournalTypeDocuments]
ORDER BY ID;
