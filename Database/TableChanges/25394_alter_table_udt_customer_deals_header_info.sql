IF COL_LENGTH('udt_customer_deals_header_info', 'hub') IS NOT NULL
BEGIN
    ALTER TABLE udt_customer_deals_header_info ALTER COLUMN hub VARCHAR(200) NULL
END
