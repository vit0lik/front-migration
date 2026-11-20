-- 1. Сколько поставщиков в каждой группе
SELECT vg.description AS [Группа],
       COUNT(*) AS [Поставщиков]
FROM vendors v
LEFT JOIN vendorgroup vg ON v.clientgroup = vg.vendorgroupid
GROUP BY vg.description
ORDER BY [Поставщиков] DESC;

-- 2. Сколько поставщиков реально используется в закупках
SELECT COUNT(o.VendorID) AS [Активных_поставщиков]
FROM bm_StorageOperations o
WHERE o.OperationID = 1
  AND o.VendorID > 0;

-- 3. Сколько договоров заведено
SELECT COUNT(*) AS [Договоров]
FROM bm_Contracts;

-- 4. 5 поставщиков по сумме закупок
SELECT TOP (5) v.firstname AS [Поставщик],
       COUNT(o.DocumentID) AS [Поставок],
       SUM(o.Amount) AS [Сумма]
FROM bm_StorageOperations o
JOIN vendors v ON o.VendorID = v.id
WHERE o.OperationID = 1
GROUP BY v.firstname
ORDER BY [Сумма] DESC;
