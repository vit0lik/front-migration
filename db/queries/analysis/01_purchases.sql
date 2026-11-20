-- 1. Общие итоги по закупкам: сколько документов, строк и какая сумма
SELECT COUNT(d.ID) AS [Документов],
       COUNT(*) AS [Строк],
       SUM(o.Amount) AS [Сумма_закупок]
FROM bm_JournalBarnetDocs d
JOIN bm_StorageOperations o ON d.ID = o.DocumentID
WHERE o.OperationID = 1;

-- 2. Какие типы документов используются для закупки
SELECT d.DocumentTypeID AS [Тип_документа],
       dt.Description AS [Название],
       COUNT(d.ID) AS [Документов],
       COUNT(*) AS [Строк],
       SUM(o.Amount) AS [Сумма]
FROM bm_JournalBarnetDocs d
JOIN bm_StorageOperations o ON d.ID = o.DocumentID
JOIN bm_JournalTypeDocuments dt ON d.DocumentTypeID = dt.ID
WHERE o.OperationID = 1
GROUP BY d.DocumentTypeID, dt.Description
ORDER BY [Документов] DESC;

-- 3. 5 поставщиков по сумме закупок
SELECT TOP (5) v.firstname AS [Поставщик],
       SUM(o.Amount) AS [Сумма_закупок]
FROM bm_StorageOperations o
JOIN vendors v ON o.VendorID = v.id
WHERE o.OperationID = 1
GROUP BY v.firstname
ORDER BY [Сумма_закупок] DESC;

-- 4. 5 товаров по количеству закупок
SELECT TOP (5) p.description AS [Товар],
       SUM(o.Count) AS [Количество]
FROM bm_StorageOperations o
JOIN product p ON o.ProductID = p.id
WHERE o.OperationID = 1
GROUP BY p.description
ORDER BY [Количество] DESC;
