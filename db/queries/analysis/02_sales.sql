-- 1. 5 категорий по выручке
SELECT TOP (5) c.description AS [Категория],
       SUM(j.amount) AS [Выручка]
FROM journal j
JOIN category c ON j.categoryid = c.id
WHERE j.transtype = 101
GROUP BY c.description
ORDER BY [Выручка] DESC;

-- 2. Кто пробивал продажи
SELECT j.loginid AS [Логин],
       COUNT(*) AS [Строк],
       SUM(j.amount) AS [Выручка]
FROM journal j
WHERE j.transtype = 101
GROUP BY j.loginid
ORDER BY [Выручка] DESC;

-- 3. Пример состава продажи: товар и потраченные ингредиенты.
SELECT TOP (5) j.description AS [Товар],
       p.description AS [Ингредиент],
       SUM(d.Count) AS [Количество]
FROM journal j
JOIN bm_Journal_Details d ON j.transnumber = d.SourceID
JOIN product p ON d.ProductID = p.id
WHERE j.transtype = 101
GROUP BY j.description, p.description
ORDER BY [Количество] DESC;
