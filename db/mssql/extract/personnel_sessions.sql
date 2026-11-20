-- сессии
SELECT
    CAST(YEAR(DateAdd) * 100 + MONTH(DateAdd) AS int) AS month_code,
    PersonID AS personnel_external_id,
    COUNT(*) AS sessions_count,
    SUM(CASE WHEN IsError = 1 THEN 1 ELSE 0 END) AS error_count
FROM bm_JournalSessions
WHERE DateAdd IS NOT NULL
GROUP BY
    YEAR(DateAdd) * 100 + MONTH(DateAdd),
    PersonID;
