-- 1. Общий остаток по движениям.
SELECT SUM(o.Count) AS [Остаток_по_движениям]
FROM bm_StorageOperations o
WHERE o.OperationID IN (1, 2);

-- 2. 5 товаров с самым большим минусом
SELECT TOP (5) p.description AS [Товар],
       SUM(o.Count) AS [Остаток]
FROM bm_StorageOperations o
JOIN product p ON o.ProductID = p.id
WHERE o.OperationID IN (1, 2)
GROUP BY p.description
ORDER BY [Остаток] ASC;

-- 3. Сколько товаров ушло в минус
SELECT COUNT(*) AS [Товаров_с_минусом]
FROM (
    SELECT o.ProductID
    FROM bm_StorageOperations o
    WHERE o.OperationID IN (1, 2)
    GROUP BY o.ProductID
    HAVING SUM(o.Count) < 0
) t;

-- 4. Проверка таблиц остатков
SELECT 'closingcount' AS [Таблица], COUNT(*) AS [Записей]
FROM closingcount
UNION ALL
SELECT 'stockperiod', COUNT(*)
FROM stockperiod;
