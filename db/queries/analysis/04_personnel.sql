-- 1. Сколько всего сотрудников
SELECT COUNT(*) AS [Всего_сотрудников]
FROM personnel;

-- 2. 5 сотрудников по количеству сессий
SELECT TOP (5) p.personid AS [Код],
       p.firstname AS [Сотрудник],
       COUNT(s.ID) AS [Сессий]
FROM personnel p
LEFT JOIN bm_JournalSessions s ON p.personid = s.PersonID
GROUP BY p.personid, p.firstname
ORDER BY [Сессий] DESC;

-- 3. 5 сотрудников по количеству бонусов
SELECT TOP (5) p.personid AS [Код],
       p.firstname AS [Сотрудник],
       COUNT(b.ID) AS [Бонусов]
FROM personnel p
LEFT JOIN bm_BonusHistory b ON p.personid = b.PersonID
GROUP BY p.personid, p.firstname
ORDER BY [Бонусов] DESC;

-- 4. Проверка учета рабочего времени
SELECT 'bm_WorkHours' AS [Таблица], COUNT(*) AS [Записей]
FROM bm_WorkHours
UNION ALL
SELECT 'bm_ShiftsOperations', COUNT(*)
FROM bm_ShiftsOperations;
