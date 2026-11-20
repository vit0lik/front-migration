-- календарь месяцев
DO $$
BEGIN
    TRUNCATE TABLE olap.dim_month RESTART IDENTITY CASCADE;

    INSERT INTO olap.dim_month (
        month_code,
        month_start,
        month_end,
        month_name,
        year,
        quarter_no,
        quarter_name
    )
    SELECT
        TO_CHAR(d, 'YYYYMM')::integer,
        d::date,
        (d + INTERVAL '1 month - 1 day')::date,
        (ARRAY[
            'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
            'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
        ])[EXTRACT(MONTH FROM d)::integer],
        EXTRACT(YEAR FROM d)::smallint,
        EXTRACT(QUARTER FROM d)::smallint,
        CONCAT(EXTRACT(QUARTER FROM d)::integer, ' квартал')
    FROM generate_series(
        '2010-01-01'::date,
        '2025-12-01'::date,
        INTERVAL '1 month'
    ) AS d;

    COMMIT;
END $$;
