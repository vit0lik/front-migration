-- бонусы
SELECT
    CAST(YEAR(Period) * 100 + MONTH(Period) AS int) AS month_code,
    PersonID AS personnel_external_id,
    COUNT(*) AS bonus_count,
    SUM(ISNULL(BonusValue, 0)) AS bonus_amount
FROM bm_BonusHistory
WHERE Period IS NOT NULL
GROUP BY
    YEAR(Period) * 100 + MONTH(Period),
    PersonID;
