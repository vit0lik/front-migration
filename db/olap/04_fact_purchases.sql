DO $$
BEGIN
    BEGIN
        CREATE SEQUENCE IF NOT EXISTS olap.seq_fact_purchases;

        CREATE TABLE IF NOT EXISTS olap.fact_purchases (
            id bigint NOT NULL DEFAULT nextval('olap.seq_fact_purchases') PRIMARY KEY,
            product_id bigint NOT NULL,
            range_id bigint NOT NULL,
            category_id bigint NOT NULL,
            vendor_id bigint NOT NULL,
            quantity numeric(18, 4) NOT NULL,
            amount numeric(18, 2) NOT NULL,
            date_add timestamp NOT NULL DEFAULT now(),
            time_id bigint NOT NULL
        );

        ALTER SEQUENCE olap.seq_fact_purchases OWNED BY olap.fact_purchases.id;

        COMMENT ON TABLE olap.fact_purchases IS 'Факты: закупки';
        COMMENT ON COLUMN olap.fact_purchases.id IS 'Уникальный код';
        COMMENT ON COLUMN olap.fact_purchases.product_id IS 'Код номенклатуры';
        COMMENT ON COLUMN olap.fact_purchases.range_id IS 'Код единицы измерения';
        COMMENT ON COLUMN olap.fact_purchases.category_id IS 'Код группы номенклатуры';
        COMMENT ON COLUMN olap.fact_purchases.vendor_id IS 'Код поставщика';
        COMMENT ON COLUMN olap.fact_purchases.quantity IS 'Количество';
        COMMENT ON COLUMN olap.fact_purchases.amount IS 'Сумма';
        COMMENT ON COLUMN olap.fact_purchases.date_add IS 'Дата вставки';
        COMMENT ON COLUMN olap.fact_purchases.time_id IS 'Код временного отрезка';
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Ошибка при создании талицы фактов закупок: %', sqlerrm;
            RAISE;
    END;

    BEGIN
        ALTER TABLE olap.fact_purchases
            ADD CONSTRAINT fk_fact_purchases_product FOREIGN KEY (product_id) REFERENCES olap.dim_products (id),
            ADD CONSTRAINT fk_fact_purchases_range FOREIGN KEY (range_id) REFERENCES olap.dim_ranges (id),
            ADD CONSTRAINT fk_fact_purchases_category FOREIGN KEY (category_id) REFERENCES olap.dim_categories (id),
            ADD CONSTRAINT fk_fact_purchases_vendor FOREIGN KEY (vendor_id) REFERENCES olap.dim_vendors (id),
            ADD CONSTRAINT fk_fact_purchases_time FOREIGN KEY (time_id) REFERENCES olap.dim_time (id);
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Ошибка при создании связей: %', sqlerrm;
            RAISE;
    END;
END $$;
