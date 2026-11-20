-- загрузка

CREATE TABLE IF NOT EXISTS stg.ranges (
    external_id bigint,
    name text,
    factor numeric(12, 3)
);

CREATE TABLE IF NOT EXISTS stg.categories (
    external_id bigint,
    name text
);

CREATE TABLE IF NOT EXISTS stg.products (
    external_id bigint,
    name text,
    category_external_id bigint,
    range_external_id bigint
);

CREATE TABLE IF NOT EXISTS stg.vendors (
    external_id bigint,
    name text
);

CREATE TABLE IF NOT EXISTS stg.storages (
    external_id bigint,
    name text
);

CREATE TABLE IF NOT EXISTS stg.personnel (
    external_id bigint,
    full_name text
);

CREATE TABLE IF NOT EXISTS stg.document_types (
    external_id bigint,
    name text
);

CREATE TABLE IF NOT EXISTS stg.purchase_month (
    month_code integer,
    product_external_id bigint,
    vendor_external_id bigint,
    storage_external_id bigint,
    document_type_external_id bigint,
    range_external_id bigint,
    quantity numeric(18, 4),
    amount numeric(18, 2)
);

CREATE TABLE IF NOT EXISTS stg.sales_month (
    month_code integer,
    product_external_id bigint,
    category_external_id bigint,
    personnel_external_id bigint,
    storage_external_id bigint,
    range_external_id bigint,
    quantity numeric(18, 4),
    revenue numeric(18, 2)
);

CREATE TABLE IF NOT EXISTS stg.personnel_sessions (
    month_code integer,
    personnel_external_id bigint,
    sessions_count integer,
    error_count integer
);

CREATE TABLE IF NOT EXISTS stg.personnel_bonus (
    month_code integer,
    personnel_external_id bigint,
    bonus_count integer,
    bonus_amount numeric(18, 2)
);

CREATE TABLE IF NOT EXISTS stg.personnel_sales (
    month_code integer,
    personnel_external_id bigint,
    sales_revenue numeric(18, 2),
    sales_receipts integer
);

CREATE TABLE IF NOT EXISTS stg.stock_movement_month (
    month_code integer,
    product_external_id bigint,
    storage_external_id bigint,
    range_external_id bigint,
    quantity_in numeric(18, 4),
    quantity_out numeric(18, 4)
);

TRUNCATE TABLE
    stg.ranges, stg.categories, stg.products, stg.vendors, stg.storages,
    stg.personnel, stg.document_types, stg.purchase_month, stg.sales_month,
    stg.personnel_sessions, stg.personnel_bonus, stg.personnel_sales,
    stg.stock_movement_month;

COPY stg.ranges FROM '/backup/olap/ranges.csv' DELIMITER '|' NULL '';
COPY stg.categories FROM '/backup/olap/categories.csv' DELIMITER '|' NULL '';
COPY stg.products FROM '/backup/olap/products.csv' DELIMITER '|' NULL '';
COPY stg.vendors FROM '/backup/olap/vendors.csv' DELIMITER '|' NULL '';
COPY stg.storages FROM '/backup/olap/storages.csv' DELIMITER '|' NULL '';
COPY stg.personnel FROM '/backup/olap/personnel.csv' DELIMITER '|' NULL '';
COPY stg.document_types FROM '/backup/olap/document_types.csv' DELIMITER '|' NULL '';
COPY stg.purchase_month FROM '/backup/olap/purchase_month.csv' DELIMITER '|' NULL '';
COPY stg.sales_month FROM '/backup/olap/sales_month.csv' DELIMITER '|' NULL '';
COPY stg.personnel_sessions FROM '/backup/olap/personnel_sessions.csv' DELIMITER '|' NULL '';
COPY stg.personnel_bonus FROM '/backup/olap/personnel_bonus.csv' DELIMITER '|' NULL '';
COPY stg.personnel_sales FROM '/backup/olap/personnel_sales.csv' DELIMITER '|' NULL '';
COPY stg.stock_movement_month FROM '/backup/olap/stock_movement_month.csv' DELIMITER '|' NULL '';

BEGIN;

CREATE OR REPLACE PROCEDURE etl.load_all()
LANGUAGE plpgsql
AS $proc$
BEGIN
    TRUNCATE TABLE
        olap.fact_purchase_month, olap.fact_sales_month, olap.fact_personnel_month,
        olap.fact_stock_month, olap.dim_ranges, olap.dim_categories, olap.dim_products,
        olap.dim_vendors, olap.dim_storages, olap.dim_personnel, olap.dim_document_types
    RESTART IDENTITY;

    -- измерения
    INSERT INTO olap.dim_ranges (external_id, name, factor)
    SELECT external_id, COALESCE(NULLIF(name, ''), 'Неизвестно'), COALESCE(factor, 1)
    FROM stg.ranges;

    INSERT INTO olap.dim_categories (external_id, name)
    SELECT external_id, COALESCE(NULLIF(name, ''), 'Неизвестно')
    FROM stg.categories;

    INSERT INTO olap.dim_vendors (external_id, name)
    SELECT external_id, COALESCE(NULLIF(name, ''), 'Неизвестно')
    FROM stg.vendors;

    INSERT INTO olap.dim_storages (external_id, name)
    SELECT external_id, COALESCE(NULLIF(name, ''), 'Неизвестно')
    FROM stg.storages;

    INSERT INTO olap.dim_personnel (external_id, full_name)
    SELECT external_id, COALESCE(NULLIF(full_name, ''), 'Неизвестно')
    FROM stg.personnel;

    INSERT INTO olap.dim_document_types (external_id, name)
    SELECT external_id, COALESCE(NULLIF(name, ''), 'Неизвестно')
    FROM stg.document_types;

    INSERT INTO olap.dim_products (external_id, name, category_id, range_id)
    SELECT
        p.external_id,
        COALESCE(NULLIF(p.name, ''), 'Неизвестно'),
        c.id,
        r.id
    FROM stg.products p
    LEFT JOIN olap.dim_categories c ON c.external_id = p.category_external_id
    LEFT JOIN olap.dim_ranges r ON r.external_id = p.range_external_id;

    -- закупки
    INSERT INTO olap.fact_purchase_month (
        month_id, product_id, vendor_id, storage_id, document_type_id, range_id,
        quantity, amount
    )
    SELECT
        m.id,
        p.id,
        v.id,
        st.id,
        dt.id,
        r.id,
        SUM(COALESCE(s.quantity, 0)),
        SUM(COALESCE(s.amount, 0))
    FROM stg.purchase_month s
    JOIN olap.dim_month m ON m.month_code = s.month_code
    LEFT JOIN olap.dim_products p ON p.external_id = s.product_external_id
    LEFT JOIN olap.dim_vendors v ON v.external_id = s.vendor_external_id
    LEFT JOIN olap.dim_storages st ON st.external_id = s.storage_external_id
    LEFT JOIN olap.dim_document_types dt ON dt.external_id = s.document_type_external_id
    LEFT JOIN olap.dim_ranges r ON r.external_id = s.range_external_id
    GROUP BY m.id, p.id, v.id, st.id, dt.id, r.id;

    -- продажи
    INSERT INTO olap.fact_sales_month (
        month_id, product_id, category_id, personnel_id, storage_id, range_id,
        quantity, revenue
    )
    SELECT
        m.id,
        p.id,
        c.id,
        per.id,
        st.id,
        r.id,
        SUM(COALESCE(s.quantity, 0)),
        SUM(COALESCE(s.revenue, 0))
    FROM stg.sales_month s
    JOIN olap.dim_month m ON m.month_code = s.month_code
    LEFT JOIN olap.dim_products p ON p.external_id = s.product_external_id
    LEFT JOIN olap.dim_categories c ON c.external_id = s.category_external_id
    LEFT JOIN olap.dim_personnel per ON per.external_id = s.personnel_external_id
    LEFT JOIN olap.dim_storages st ON st.external_id = s.storage_external_id
    LEFT JOIN olap.dim_ranges r ON r.external_id = s.range_external_id
    GROUP BY m.id, p.id, c.id, per.id, st.id, r.id;

    -- персонал
    INSERT INTO olap.fact_personnel_month (
        month_id, personnel_id, sessions_count, error_count,
        bonus_count, bonus_amount, sales_revenue, sales_receipts
    )
    WITH persons AS (
        SELECT month_code, personnel_external_id FROM stg.personnel_sessions
        UNION
        SELECT month_code, personnel_external_id FROM stg.personnel_bonus
        UNION
        SELECT month_code, personnel_external_id FROM stg.personnel_sales
    )
    SELECT
        m.id,
        p.id,
        COALESCE(ss.sessions_count, 0),
        COALESCE(ss.error_count, 0),
        COALESCE(b.bonus_count, 0),
        COALESCE(b.bonus_amount, 0),
        COALESCE(sa.sales_revenue, 0),
        COALESCE(sa.sales_receipts, 0)
    FROM persons x
    JOIN olap.dim_month m ON m.month_code = x.month_code
    LEFT JOIN olap.dim_personnel p ON p.external_id = x.personnel_external_id
    LEFT JOIN stg.personnel_sessions ss
        ON ss.month_code = x.month_code
       AND ss.personnel_external_id = x.personnel_external_id
    LEFT JOIN stg.personnel_bonus b
        ON b.month_code = x.month_code
       AND b.personnel_external_id = x.personnel_external_id
    LEFT JOIN stg.personnel_sales sa
        ON sa.month_code = x.month_code
       AND sa.personnel_external_id = x.personnel_external_id;

    -- остатки
    WITH movement AS (
        SELECT
            m.id AS month_id,
            m.month_code,
            p.id AS product_id,
            st.id AS storage_id,
            r.id AS range_id,
            SUM(COALESCE(s.quantity_in, 0)) AS quantity_in,
            SUM(COALESCE(s.quantity_out, 0)) AS quantity_out
        FROM stg.stock_movement_month s
        JOIN olap.dim_month m ON m.month_code = s.month_code
        LEFT JOIN olap.dim_products p ON p.external_id = s.product_external_id
        LEFT JOIN olap.dim_storages st ON st.external_id = s.storage_external_id
        LEFT JOIN olap.dim_ranges r ON r.external_id = s.range_external_id
        GROUP BY m.id, m.month_code, p.id, st.id, r.id
    ),
    combos AS (
        SELECT DISTINCT product_id, storage_id, range_id
        FROM movement
    ),
    months AS (
        SELECT id AS month_id, month_code
        FROM olap.dim_month
        WHERE month_code BETWEEN
            (SELECT MIN(month_code) FROM movement)
            AND (SELECT MAX(month_code) FROM movement)
    ),
    grid AS (
        SELECT m.month_id, m.month_code, c.product_id, c.storage_id, c.range_id
        FROM months m
        CROSS JOIN combos c
    ),
    stock AS (
        SELECT
            g.month_id,
            g.month_code,
            g.product_id,
            g.storage_id,
            g.range_id,
            COALESCE(mv.quantity_in, 0) AS quantity_in,
            COALESCE(mv.quantity_out, 0) AS quantity_out,
            SUM(COALESCE(mv.quantity_in, 0) - COALESCE(mv.quantity_out, 0)) OVER (
                PARTITION BY g.product_id, g.storage_id, g.range_id
                ORDER BY g.month_code
            ) AS quantity_close
        FROM grid g
        LEFT JOIN movement mv
            ON mv.month_id = g.month_id
           AND COALESCE(mv.product_id, -1) = COALESCE(g.product_id, -1)
           AND COALESCE(mv.storage_id, -1) = COALESCE(g.storage_id, -1)
           AND COALESCE(mv.range_id, -1) = COALESCE(g.range_id, -1)
    )
    INSERT INTO olap.fact_stock_month (
        month_id, product_id, storage_id, range_id,
        quantity_open, quantity_in, quantity_out, quantity_close
    )
    SELECT
        month_id,
        product_id,
        storage_id,
        range_id,
        COALESCE(LAG(quantity_close) OVER (
            PARTITION BY product_id, storage_id, range_id
            ORDER BY month_code
        ), 0),
        quantity_in,
        quantity_out,
        quantity_close
    FROM stock;
END;
$proc$;

COMMENT ON PROCEDURE etl.load_all() IS 'Загрузка всех измерений и фактов из staging';

CALL etl.load_all();

COMMIT;
