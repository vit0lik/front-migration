-- схема
DO $$
BEGIN
    CREATE SCHEMA IF NOT EXISTS olap;
    CREATE SCHEMA IF NOT EXISTS stg;
    CREATE SCHEMA IF NOT EXISTS etl;

    -- счётчики
    CREATE SEQUENCE IF NOT EXISTS olap.dim_month_seq START WITH 1;
    CREATE SEQUENCE IF NOT EXISTS olap.dim_ranges_seq START WITH 1;
    CREATE SEQUENCE IF NOT EXISTS olap.dim_categories_seq START WITH 1;
    CREATE SEQUENCE IF NOT EXISTS olap.dim_products_seq START WITH 1;
    CREATE SEQUENCE IF NOT EXISTS olap.dim_vendors_seq START WITH 1;
    CREATE SEQUENCE IF NOT EXISTS olap.dim_storages_seq START WITH 1;
    CREATE SEQUENCE IF NOT EXISTS olap.dim_personnel_seq START WITH 1;
    CREATE SEQUENCE IF NOT EXISTS olap.dim_document_types_seq START WITH 1;
    CREATE SEQUENCE IF NOT EXISTS olap.fact_purchase_month_seq START WITH 1;
    CREATE SEQUENCE IF NOT EXISTS olap.fact_sales_month_seq START WITH 1;
    CREATE SEQUENCE IF NOT EXISTS olap.fact_personnel_month_seq START WITH 1;
    CREATE SEQUENCE IF NOT EXISTS olap.fact_stock_month_seq START WITH 1;

    -- таблицы
    CREATE TABLE IF NOT EXISTS olap.dim_month (
        id bigint NOT NULL DEFAULT nextval('olap.dim_month_seq') PRIMARY KEY,
        month_code integer NOT NULL,
        month_start date NOT NULL,
        month_end date NOT NULL,
        month_name varchar(20) NOT NULL,
        year smallint NOT NULL,
        quarter_no smallint NOT NULL,
        quarter_name varchar(20) NOT NULL
    );

    CREATE TABLE IF NOT EXISTS olap.dim_ranges (
        id bigint NOT NULL DEFAULT nextval('olap.dim_ranges_seq') PRIMARY KEY,
        external_id bigint NOT NULL,
        name text NOT NULL,
        factor numeric(12, 3) NOT NULL
    );

    CREATE TABLE IF NOT EXISTS olap.dim_categories (
        id bigint NOT NULL DEFAULT nextval('olap.dim_categories_seq') PRIMARY KEY,
        external_id bigint NOT NULL,
        name text NOT NULL
    );

    CREATE TABLE IF NOT EXISTS olap.dim_products (
        id bigint NOT NULL DEFAULT nextval('olap.dim_products_seq') PRIMARY KEY,
        external_id bigint NOT NULL,
        name text NOT NULL,
        category_id bigint,
        range_id bigint
    );

    CREATE TABLE IF NOT EXISTS olap.dim_vendors (
        id bigint NOT NULL DEFAULT nextval('olap.dim_vendors_seq') PRIMARY KEY,
        external_id bigint NOT NULL,
        name text NOT NULL
    );

    CREATE TABLE IF NOT EXISTS olap.dim_storages (
        id bigint NOT NULL DEFAULT nextval('olap.dim_storages_seq') PRIMARY KEY,
        external_id bigint NOT NULL,
        name text NOT NULL
    );

    CREATE TABLE IF NOT EXISTS olap.dim_personnel (
        id bigint NOT NULL DEFAULT nextval('olap.dim_personnel_seq') PRIMARY KEY,
        external_id bigint NOT NULL,
        full_name text NOT NULL
    );

    CREATE TABLE IF NOT EXISTS olap.dim_document_types (
        id bigint NOT NULL DEFAULT nextval('olap.dim_document_types_seq') PRIMARY KEY,
        external_id bigint NOT NULL,
        name text NOT NULL
    );

    CREATE TABLE IF NOT EXISTS olap.fact_purchase_month (
        id bigint NOT NULL DEFAULT nextval('olap.fact_purchase_month_seq') PRIMARY KEY,
        month_id bigint NOT NULL,
        product_id bigint,
        vendor_id bigint,
        storage_id bigint,
        document_type_id bigint,
        range_id bigint,
        quantity numeric(18, 4) NOT NULL DEFAULT 0,
        amount numeric(18, 2) NOT NULL DEFAULT 0
    );

    CREATE TABLE IF NOT EXISTS olap.fact_sales_month (
        id bigint NOT NULL DEFAULT nextval('olap.fact_sales_month_seq') PRIMARY KEY,
        month_id bigint NOT NULL,
        product_id bigint,
        category_id bigint,
        personnel_id bigint,
        storage_id bigint,
        range_id bigint,
        quantity numeric(18, 4) NOT NULL DEFAULT 0,
        revenue numeric(18, 2) NOT NULL DEFAULT 0
    );

    CREATE TABLE IF NOT EXISTS olap.fact_personnel_month (
        id bigint NOT NULL DEFAULT nextval('olap.fact_personnel_month_seq') PRIMARY KEY,
        month_id bigint NOT NULL,
        personnel_id bigint,
        sessions_count integer NOT NULL DEFAULT 0,
        error_count integer NOT NULL DEFAULT 0,
        bonus_count integer NOT NULL DEFAULT 0,
        bonus_amount numeric(18, 2) NOT NULL DEFAULT 0,
        sales_revenue numeric(18, 2) NOT NULL DEFAULT 0,
        sales_receipts integer NOT NULL DEFAULT 0
    );

    CREATE TABLE IF NOT EXISTS olap.fact_stock_month (
        id bigint NOT NULL DEFAULT nextval('olap.fact_stock_month_seq') PRIMARY KEY,
        month_id bigint NOT NULL,
        product_id bigint,
        storage_id bigint,
        range_id bigint,
        quantity_open numeric(18, 4) NOT NULL DEFAULT 0,
        quantity_in numeric(18, 4) NOT NULL DEFAULT 0,
        quantity_out numeric(18, 4) NOT NULL DEFAULT 0,
        quantity_close numeric(18, 4) NOT NULL DEFAULT 0
    );

    -- ключи
    ALTER SEQUENCE olap.dim_month_seq OWNED BY olap.dim_month.id;
    ALTER SEQUENCE olap.dim_ranges_seq OWNED BY olap.dim_ranges.id;
    ALTER SEQUENCE olap.dim_categories_seq OWNED BY olap.dim_categories.id;
    ALTER SEQUENCE olap.dim_products_seq OWNED BY olap.dim_products.id;
    ALTER SEQUENCE olap.dim_vendors_seq OWNED BY olap.dim_vendors.id;
    ALTER SEQUENCE olap.dim_storages_seq OWNED BY olap.dim_storages.id;
    ALTER SEQUENCE olap.dim_personnel_seq OWNED BY olap.dim_personnel.id;
    ALTER SEQUENCE olap.dim_document_types_seq OWNED BY olap.dim_document_types.id;
    ALTER SEQUENCE olap.fact_purchase_month_seq OWNED BY olap.fact_purchase_month.id;
    ALTER SEQUENCE olap.fact_sales_month_seq OWNED BY olap.fact_sales_month.id;
    ALTER SEQUENCE olap.fact_personnel_month_seq OWNED BY olap.fact_personnel_month.id;
    ALTER SEQUENCE olap.fact_stock_month_seq OWNED BY olap.fact_stock_month.id;

    ALTER TABLE olap.dim_month ADD CONSTRAINT uq_dim_month_code UNIQUE (month_code);
    ALTER TABLE olap.dim_ranges ADD CONSTRAINT uq_dim_ranges_external_id UNIQUE (external_id);
    ALTER TABLE olap.dim_categories ADD CONSTRAINT uq_dim_categories_external_id UNIQUE (external_id);
    ALTER TABLE olap.dim_products ADD CONSTRAINT uq_dim_products_external_id UNIQUE (external_id);
    ALTER TABLE olap.dim_vendors ADD CONSTRAINT uq_dim_vendors_external_id UNIQUE (external_id);
    ALTER TABLE olap.dim_storages ADD CONSTRAINT uq_dim_storages_external_id UNIQUE (external_id);
    ALTER TABLE olap.dim_personnel ADD CONSTRAINT uq_dim_personnel_external_id UNIQUE (external_id);
    ALTER TABLE olap.dim_document_types ADD CONSTRAINT uq_dim_document_types_external_id UNIQUE (external_id);

    ALTER TABLE olap.dim_products
        ADD CONSTRAINT fk_dim_products_category FOREIGN KEY (category_id) REFERENCES olap.dim_categories (id);
    ALTER TABLE olap.dim_products
        ADD CONSTRAINT fk_dim_products_range FOREIGN KEY (range_id) REFERENCES olap.dim_ranges (id);

    ALTER TABLE olap.fact_purchase_month
        ADD CONSTRAINT fk_fact_purchase_month_month FOREIGN KEY (month_id) REFERENCES olap.dim_month (id);
    ALTER TABLE olap.fact_purchase_month
        ADD CONSTRAINT fk_fact_purchase_month_product FOREIGN KEY (product_id) REFERENCES olap.dim_products (id);
    ALTER TABLE olap.fact_purchase_month
        ADD CONSTRAINT fk_fact_purchase_month_vendor FOREIGN KEY (vendor_id) REFERENCES olap.dim_vendors (id);
    ALTER TABLE olap.fact_purchase_month
        ADD CONSTRAINT fk_fact_purchase_month_storage FOREIGN KEY (storage_id) REFERENCES olap.dim_storages (id);
    ALTER TABLE olap.fact_purchase_month
        ADD CONSTRAINT fk_fact_purchase_month_document_type FOREIGN KEY (document_type_id) REFERENCES olap.dim_document_types (id);
    ALTER TABLE olap.fact_purchase_month
        ADD CONSTRAINT fk_fact_purchase_month_range FOREIGN KEY (range_id) REFERENCES olap.dim_ranges (id);

    ALTER TABLE olap.fact_sales_month
        ADD CONSTRAINT fk_fact_sales_month_month FOREIGN KEY (month_id) REFERENCES olap.dim_month (id);
    ALTER TABLE olap.fact_sales_month
        ADD CONSTRAINT fk_fact_sales_month_product FOREIGN KEY (product_id) REFERENCES olap.dim_products (id);
    ALTER TABLE olap.fact_sales_month
        ADD CONSTRAINT fk_fact_sales_month_category FOREIGN KEY (category_id) REFERENCES olap.dim_categories (id);
    ALTER TABLE olap.fact_sales_month
        ADD CONSTRAINT fk_fact_sales_month_personnel FOREIGN KEY (personnel_id) REFERENCES olap.dim_personnel (id);
    ALTER TABLE olap.fact_sales_month
        ADD CONSTRAINT fk_fact_sales_month_storage FOREIGN KEY (storage_id) REFERENCES olap.dim_storages (id);
    ALTER TABLE olap.fact_sales_month
        ADD CONSTRAINT fk_fact_sales_month_range FOREIGN KEY (range_id) REFERENCES olap.dim_ranges (id);

    ALTER TABLE olap.fact_personnel_month
        ADD CONSTRAINT fk_fact_personnel_month_month FOREIGN KEY (month_id) REFERENCES olap.dim_month (id);
    ALTER TABLE olap.fact_personnel_month
        ADD CONSTRAINT fk_fact_personnel_month_personnel FOREIGN KEY (personnel_id) REFERENCES olap.dim_personnel (id);

    ALTER TABLE olap.fact_stock_month
        ADD CONSTRAINT fk_fact_stock_month_month FOREIGN KEY (month_id) REFERENCES olap.dim_month (id);
    ALTER TABLE olap.fact_stock_month
        ADD CONSTRAINT fk_fact_stock_month_product FOREIGN KEY (product_id) REFERENCES olap.dim_products (id);
    ALTER TABLE olap.fact_stock_month
        ADD CONSTRAINT fk_fact_stock_month_storage FOREIGN KEY (storage_id) REFERENCES olap.dim_storages (id);
    ALTER TABLE olap.fact_stock_month
        ADD CONSTRAINT fk_fact_stock_month_range FOREIGN KEY (range_id) REFERENCES olap.dim_ranges (id);

    -- комментарии
    COMMENT ON TABLE olap.dim_month IS 'Ресурс Время: месяцы';
    COMMENT ON TABLE olap.dim_ranges IS 'Размеры и порции';
    COMMENT ON TABLE olap.dim_categories IS 'Категории товаров';
    COMMENT ON TABLE olap.dim_products IS 'Товары';
    COMMENT ON TABLE olap.dim_vendors IS 'Поставщики';
    COMMENT ON TABLE olap.dim_storages IS 'Склады';
    COMMENT ON TABLE olap.dim_personnel IS 'Сотрудники';
    COMMENT ON TABLE olap.dim_document_types IS 'Типы документов';
    COMMENT ON TABLE olap.fact_purchase_month IS 'Закупки по месяцам';
    COMMENT ON TABLE olap.fact_sales_month IS 'Продажи по месяцам';
    COMMENT ON TABLE olap.fact_personnel_month IS 'Работа персонала по месяцам';
    COMMENT ON TABLE olap.fact_stock_month IS 'Остатки по месяцам';

    COMMIT;
END $$;
