-- ixp_source_counterparty_template 
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_source_counterparty_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_source_counterparty_template'
        )
WHERE  o.[name] = 'source_counterparty' AND ic.ixp_columns_id IS NULL

---ixp_location_template
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_location_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_location_template'
        )
WHERE  o.[name] = 'source_minor_location' AND ic.ixp_columns_id IS NULL

--ixp_contract_template
DELETE 
FROM   ixp_columns
WHERE  ixp_table_id = (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_contract_template'
)
AND header_detail = 'd'

INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_contract_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_contract_template'
        )
WHERE  o.[name] = 'contract_group' AND ic.ixp_columns_id IS NULL


INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_contract_detail_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_contract_detail_template'
    )
WHERE  o.[name] = 'contract_group_detail' AND ic.ixp_columns_id IS NULL

--ixp_source_book_template
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_source_book_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_source_book_template'
        )
WHERE  o.[name] = 'source_book' AND ic.ixp_columns_id IS NULL

---ixp_source_commodity_template
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_source_commodity_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_source_commodity_template'
        )
WHERE  o.[name] = 'source_commodity' AND ic.ixp_columns_id IS NULL

--ixp_source_currency_template
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_source_currency_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_source_currency_template'
        )
WHERE  o.[name] = 'source_currency' AND ic.ixp_columns_id IS NULL

--ixp_source_deal_type_template
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_source_deal_type_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_source_deal_type_template'
        )
WHERE  o.[name] = 'source_deal_type' AND ic.ixp_columns_id IS NULL

--ixp_source_trader_template
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_source_trader_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_source_trader_template'
        )
WHERE  o.[name] = 'source_traders' AND ic.ixp_columns_id IS NULL

--ixp_source_price_curve_def_template
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_source_price_curve_def_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_source_price_curve_def_template'
        )
WHERE  o.[name] = 'source_price_curve_def' AND ic.ixp_columns_id IS NULL

--ixp_source_uom_template
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_source_uom_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_source_uom_template'
        )
WHERE  o.[name] = 'source_uom' AND ic.ixp_columns_id IS NULL

--ixp_index_fees_breakdown_settlement_template
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_index_fees_breakdown_settlement_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_index_fees_breakdown_settlement_template'
        )
WHERE  o.[name] = 'index_fees_breakdown_settlement' AND ic.ixp_columns_id IS NULL

--ixp_source_deal_settlement_template
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_source_deal_settlement_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_source_deal_settlement_template'
        )
WHERE  o.[name] = 'source_deal_settlement' AND ic.ixp_columns_id IS NULL


--ixp_source_deal_template for deal header
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_source_deal_template'
       ) table_id,
       c.name,
       0,
       'h'
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_source_deal_template'
    )
    AND ic.header_detail = 'h'
WHERE  o.[name] = 'source_deal_header' AND ic.ixp_columns_id IS NULL

--ixp_source_deal_template for deal details
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_source_deal_template'
       ) table_id,
       c.name,
       0,
       'd'
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_source_deal_template'
    )
	AND ic.header_detail = 'd'
WHERE  o.[name] = 'source_deal_detail' AND ic.ixp_columns_id IS NULL AND c.name <> 'physical_financial_flag'

IF NOT EXISTS (
       SELECT *
       FROM   ixp_columns ic
       INNER JOIN ixp_tables it ON it.ixp_tables_id = ic.ixp_table_id
       WHERE  ic.ixp_columns_name = 'physical_financial_flag_detail'
              AND it.ixp_tables_name = 'ixp_source_deal_template'
   )
BEGIN
    INSERT INTO ixp_columns (
        ixp_table_id,
        ixp_columns_name,
        column_datatype,
        is_major,
        header_detail
      )
    SELECT it.ixp_tables_id,
           'physical_financial_flag_detail',
           'VARCHAR(600)',
           '0',
           'd'
    FROM   ixp_tables it
    WHERE  it.ixp_tables_name = 'ixp_source_deal_template'
END

-- ixp_15mins_allocation_data_template starts
DECLARE @ixp_15mins_allocation_data_template_id INT	
SELECT @ixp_15mins_allocation_data_template_id = it.ixp_tables_id FROM   ixp_tables it WHERE  it.ixp_tables_name = 'ixp_15mins_allocation_data_template'

IF @ixp_15mins_allocation_data_template_id IS NOT NULL
BEGIN
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'meter_id' AND ixp_table_id = @ixp_15mins_allocation_data_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_15mins_allocation_data_template_id, 'meter_id', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'date' AND ixp_table_id = @ixp_15mins_allocation_data_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_15mins_allocation_data_template_id, 'date', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'hour' AND ixp_table_id = @ixp_15mins_allocation_data_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_15mins_allocation_data_template_id, 'hour', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'value' AND ixp_table_id = @ixp_15mins_allocation_data_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_15mins_allocation_data_template_id, 'value', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'channel' AND ixp_table_id = @ixp_15mins_allocation_data_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_15mins_allocation_data_template_id, 'channel', 0, NULL END
END
ELSE
BEGIN
	SELECT 'ixp_15mins_allocation_data_template not present in ixp_tables'
END
-- ixp_15mins_allocation_data_template END

-- ixp_10mins_allocation_data_template starts
DECLARE @ixp_10mins_allocation_data_template_id INT	
SELECT @ixp_10mins_allocation_data_template_id = it.ixp_tables_id FROM   ixp_tables it WHERE  it.ixp_tables_name = 'ixp_10mins_allocation_data_template'

IF @ixp_10mins_allocation_data_template_id IS NOT NULL
BEGIN
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'meter_id' AND ixp_table_id = @ixp_10mins_allocation_data_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_10mins_allocation_data_template_id, 'meter_id', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'date' AND ixp_table_id = @ixp_10mins_allocation_data_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_10mins_allocation_data_template_id, 'date', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'hour' AND ixp_table_id = @ixp_10mins_allocation_data_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_10mins_allocation_data_template_id, 'hour', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'value' AND ixp_table_id = @ixp_10mins_allocation_data_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_10mins_allocation_data_template_id, 'value', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'channel' AND ixp_table_id = @ixp_10mins_allocation_data_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_10mins_allocation_data_template_id, 'channel', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'period' AND ixp_table_id = @ixp_10mins_allocation_data_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_10mins_allocation_data_template_id, 'period', 0, NULL END
END
ELSE
BEGIN
	SELECT 'ixp_10mins_allocation_data_template not present in ixp_tables'
END
-- ixp_10mins_allocation_data_template END

-- ixp_hourly_allocation_data_template starts
DECLARE @ixp_hourly_allocation_data_template_id INT	
SELECT @ixp_hourly_allocation_data_template_id = it.ixp_tables_id FROM   ixp_tables it WHERE  it.ixp_tables_name = 'ixp_hourly_allocation_data_template'

IF @ixp_hourly_allocation_data_template_id IS NOT NULL
BEGIN
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'meter_id' AND ixp_table_id = @ixp_hourly_allocation_data_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_hourly_allocation_data_template_id, 'meter_id', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'date' AND ixp_table_id = @ixp_hourly_allocation_data_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_hourly_allocation_data_template_id, 'date', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'hour' AND ixp_table_id = @ixp_hourly_allocation_data_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_hourly_allocation_data_template_id, 'hour', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'value' AND ixp_table_id = @ixp_hourly_allocation_data_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_hourly_allocation_data_template_id, 'value', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'channel' AND ixp_table_id = @ixp_hourly_allocation_data_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_hourly_allocation_data_template_id, 'channel', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'period' AND ixp_table_id = @ixp_hourly_allocation_data_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_hourly_allocation_data_template_id, 'period', 0, NULL END
END
ELSE
BEGIN
	SELECT 'ixp_hourly_allocation_data_template not present in ixp_tables'
END
-- ixp_hourly_allocation_data_template END

-- ixp_source_price_curve_template 
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_source_price_curve_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_source_price_curve_template'
        )
WHERE  o.[name] = 'source_price_curve' AND ic.ixp_columns_id IS NULL

-- ixp_source_price_curve_template starts
DECLARE @ixp_source_price_curve_template_id INT	
SELECT @ixp_source_price_curve_template_id = it.ixp_tables_id FROM   ixp_tables it WHERE  it.ixp_tables_name = 'ixp_source_price_curve_template'

IF @ixp_source_price_curve_template_id IS NOT NULL
BEGIN
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'source_system_id' AND ixp_table_id = @ixp_source_price_curve_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_source_price_curve_template_id, 'source_system_id', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'hour' AND ixp_table_id = @ixp_source_price_curve_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_source_price_curve_template_id, 'hour', 0, NULL END
END
ELSE
BEGIN
	SELECT 'ixp_source_price_curve_template not present in ixp_tables'
END
-- ixp_source_price_curve_template END

-- ixp_voided_deals_template starts
DECLARE @ixp_voided_deals_template_id INT	
SELECT @ixp_voided_deals_template_id = it.ixp_tables_id FROM   ixp_tables it WHERE  it.ixp_tables_name = 'ixp_voided_deals_template'

IF @ixp_voided_deals_template_id IS NOT NULL
BEGIN
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'deal_id' AND ixp_table_id = @ixp_voided_deals_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_voided_deals_template_id, 'deal_id', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'as_of_date' AND ixp_table_id = @ixp_voided_deals_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_voided_deals_template_id, 'as_of_date', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'book' AND ixp_table_id = @ixp_voided_deals_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_voided_deals_template_id, 'book', 0, NULL END
END
ELSE
BEGIN
	SELECT 'ixp_voided_deals_template not present in ixp_tables'
END
-- ixp_voided_deals_template END


-- ixp_holiday_calendar 
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_holiday_calendar_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_holiday_calendar_template'
        )
WHERE  o.[name] = 'holiday_group' AND ic.ixp_columns_id IS NULL


-- start ixp_source_deal_detail_hour_template 
DECLARE @ixp_source_deal_detail_hour_template_id INT	
SELECT @ixp_source_deal_detail_hour_template_id = it.ixp_tables_id FROM   ixp_tables it WHERE  it.ixp_tables_name = 'ixp_source_deal_detail_hour_template'

IF @ixp_source_deal_detail_hour_template_id IS NOT NULL
BEGIN
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'deal_id' AND ixp_table_id = @ixp_source_deal_detail_hour_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_source_deal_detail_hour_template_id, 'deal_id', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'term_date' AND ixp_table_id = @ixp_source_deal_detail_hour_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_source_deal_detail_hour_template_id, 'term_date', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'hr' AND ixp_table_id = @ixp_source_deal_detail_hour_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_source_deal_detail_hour_template_id, 'hr', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'is_dst' AND ixp_table_id = @ixp_source_deal_detail_hour_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_source_deal_detail_hour_template_id, 'is_dst', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'volume' AND ixp_table_id = @ixp_source_deal_detail_hour_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_source_deal_detail_hour_template_id, 'volume', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'price' AND ixp_table_id = @ixp_source_deal_detail_hour_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_source_deal_detail_hour_template_id, 'price', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'formula_id' AND ixp_table_id = @ixp_source_deal_detail_hour_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_source_deal_detail_hour_template_id, 'formula_id', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'granularity' AND ixp_table_id = @ixp_source_deal_detail_hour_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_source_deal_detail_hour_template_id, 'granularity', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'leg' AND ixp_table_id = @ixp_source_deal_detail_hour_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_source_deal_detail_hour_template_id, 'leg', 0, NULL END
	
END
ELSE
BEGIN
	SELECT 'ixp_source_deal_detail_hour_template not present in ixp_tables'
END
-- end ixp_source_deal_detail_hour_template 

--start ixp_source_deal_detail_15min_template 
DECLARE @ixp_source_deal_detail_15min_template_id INT	
SELECT @ixp_source_deal_detail_15min_template_id = it.ixp_tables_id FROM   ixp_tables it WHERE  it.ixp_tables_name = 'ixp_source_deal_detail_15min_template'

IF @ixp_source_deal_detail_15min_template_id IS NOT NULL
BEGIN
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'deal_id' AND ixp_table_id = @ixp_source_deal_detail_15min_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_source_deal_detail_15min_template_id, 'deal_id', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'term_date' AND ixp_table_id = @ixp_source_deal_detail_15min_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_source_deal_detail_15min_template_id, 'term_date', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'hr' AND ixp_table_id = @ixp_source_deal_detail_15min_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_source_deal_detail_15min_template_id, 'hr', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'is_dst' AND ixp_table_id = @ixp_source_deal_detail_15min_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_source_deal_detail_15min_template_id, 'is_dst', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'volume' AND ixp_table_id = @ixp_source_deal_detail_15min_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_source_deal_detail_15min_template_id, 'volume', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'price' AND ixp_table_id = @ixp_source_deal_detail_15min_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_source_deal_detail_15min_template_id, 'price', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'formula_id' AND ixp_table_id = @ixp_source_deal_detail_15min_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_source_deal_detail_15min_template_id, 'formula_id', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'granularity' AND ixp_table_id = @ixp_source_deal_detail_15min_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_source_deal_detail_15min_template_id, 'granularity', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'leg' AND ixp_table_id = @ixp_source_deal_detail_15min_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_source_deal_detail_15min_template_id, 'leg', 0, NULL END
	
END
ELSE
BEGIN
	SELECT 'ixp_source_deal_detail_15min_template_id not present in ixp_tables'
END
-- end ixp_source_deal_detail_15min_template_id 

--ixp_monthly_allocation_data_template
DECLARE @ixp_monthly_allocation_data_template_id INT	
SELECT @ixp_monthly_allocation_data_template_id = it.ixp_tables_id FROM   ixp_tables it WHERE  it.ixp_tables_name = 'ixp_monthly_allocation_data_template'

IF @ixp_monthly_allocation_data_template_id IS NOT NULL
BEGIN
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'meter_id' AND ixp_table_id = @ixp_monthly_allocation_data_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_monthly_allocation_data_template_id, 'meter_id', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'date' AND ixp_table_id = @ixp_monthly_allocation_data_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_monthly_allocation_data_template_id, 'date', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'hour' AND ixp_table_id = @ixp_monthly_allocation_data_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_monthly_allocation_data_template_id, 'hour', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'value' AND ixp_table_id = @ixp_monthly_allocation_data_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_monthly_allocation_data_template_id, 'value', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'channel' AND ixp_table_id = @ixp_monthly_allocation_data_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_monthly_allocation_data_template_id, 'channel', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'period' AND ixp_table_id = @ixp_monthly_allocation_data_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_monthly_allocation_data_template_id, 'period', 0, NULL END
END
ELSE
BEGIN
	SELECT 'ixp_monthly_allocation_data_template not present in ixp_tables'
END
-- ixp_10mins_allocation_data_template END

-- ixp_curve_volatility_template 
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_curve_volatility_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_curve_volatility_template'
        )
WHERE  o.[name] = 'curve_volatility' AND ic.ixp_columns_id IS NULL

-- ixp_curve_correlation_template 
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_curve_correlation_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_curve_correlation_template'
        )
WHERE  o.[name] = 'curve_correlation' AND ic.ixp_columns_id IS NULL

-- ixp_static_data_value_template 
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_static_data_value_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_static_data_value_template'
        )
WHERE  o.[name] = 'static_data_value' AND ic.ixp_columns_id IS NULL

--ixp_delivery_path table

INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_delivery_path_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_delivery_path_template'
        )
WHERE  o.[name] = 'delivery_path' AND ic.ixp_columns_id IS NULL



-- ixp_counterparty_credit_info_template 
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
        )
WHERE  o.[name] = 'counterparty_credit_info' AND ic.ixp_columns_id IS NULL

-- ixp_process_risk_controls
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_process_risk_controls_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_process_risk_controls_template'
        )
WHERE  o.[name] = 'process_risk_controls' AND ic.ixp_columns_id IS NULL
-- ixp_process_risk_controls END

-- ixp_alert_sql
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_alert_sql_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_alert_sql_template'
        )
WHERE  o.[name] = 'alert_sql' AND ic.ixp_columns_id IS NULL
-- ixp_alert_sql

-- ixp_alert_rule_table
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_alert_rule_table_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_alert_rule_table_template'
        )
WHERE  o.[name] = 'alert_rule_table' AND ic.ixp_columns_id IS NULL
-- ixp_alert_rule_table END

-- ixp_alert_table_relation
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_alert_table_relation_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_alert_table_relation_template'
        )
WHERE  o.[name] = 'alert_table_relation' AND ic.ixp_columns_id IS NULL
-- ixp_alert_table_relation END

-- ixp_alert_table_where_clause
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_alert_table_where_clause_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_alert_table_where_clause_template'
        )
WHERE  o.[name] = 'alert_table_where_clause' AND ic.ixp_columns_id IS NULL
-- ixp_alert_table_where_clause END

-- ixp_alert_conditions
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_alert_conditions_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_alert_conditions_template'
        )
WHERE  o.[name] = 'alert_conditions' AND ic.ixp_columns_id IS NULL
-- ixp_alert_conditions END

-- ixp_alert_actions
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_alert_actions_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_alert_actions_template'
        )
WHERE  o.[name] = 'alert_actions' AND ic.ixp_columns_id IS NULL
-- ixp_alert_actions END

-- ixp_alert_actions_events
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_alert_actions_events_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_alert_actions_events_template'
        )
WHERE  o.[name] = 'alert_actions_events' AND ic.ixp_columns_id IS NULL
-- ixp_alert_actions_events END

-- ixp_alert_workflows
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_alert_workflows_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_alert_workflows_template'
        )
WHERE  o.[name] = 'alert_workflows' AND ic.ixp_columns_id IS NULL
-- ixp_alert_workflows END

-- ixp_alert_reports
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_alert_reports_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_alert_reports_template'
        )
WHERE  o.[name] = 'alert_reports' AND ic.ixp_columns_id IS NULL
-- ixp_alert_reports END

-- ixp_alert_users
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_alert_users_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_alert_users_template'
        )
WHERE  o.[name] = 'alert_users' AND ic.ixp_columns_id IS NULL
-- ixp_alert_users END

-- ixp_portfolio_hierarchy
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_portfolio_hierarchy_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_portfolio_hierarchy_template'
        )
WHERE  o.[name] = 'portfolio_hierarchy' AND ic.ixp_columns_id IS NULL
-- ixp_portfolio_hierarchy END

-- ixp_process_requirement_revision
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_process_requirement_revision_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_process_requirement_revision_template'
        )
WHERE  o.[name] = 'process_requirement_revision' AND ic.ixp_columns_id IS NULL
-- ixp_process_requirement_revision END


-- ixp_alert_table_definition
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_alert_table_definition_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_alert_table_definition_template'
        )
WHERE  o.[name] = 'alert_table_definition' AND ic.ixp_columns_id IS NULL
-- ixp_alert_table_definition END

-- ixp_alert_columns_definition
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_alert_columns_definition_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_alert_columns_definition_template'
        )
WHERE  o.[name] = 'alert_columns_definition' AND ic.ixp_columns_id IS NULL
-- ixp_alert_columns_definition END

--ixp_user_defined_fields_template_template
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_user_defined_fields_template_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_user_defined_fields_template_template'
        )
WHERE  o.[name] = 'user_defined_fields_template' AND ic.ixp_columns_id IS NULL


--ixp_maintain_field_template_detail_template
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_maintain_field_template_detail_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_maintain_field_template_detail_template'
        )
WHERE  o.[name] = 'maintain_field_template_detail' AND ic.ixp_columns_id IS NULL

--ixp_maintain_field_template_template
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_maintain_field_template_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_maintain_field_template_template'
        )
WHERE  o.[name] = 'maintain_field_template' AND ic.ixp_columns_id IS NULL

--ixp_maintain_field_template_group_template
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_maintain_field_template_group_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_maintain_field_template_group_template'
        )
WHERE  o.[name] = 'maintain_field_template_group' AND ic.ixp_columns_id IS NULL

--ixp_maintain_field_deal_template
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_maintain_field_deal_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_maintain_field_deal_template'
        )
WHERE  o.[name] = 'maintain_field_deal' AND ic.ixp_columns_id IS NULL
-- ixp_alert_columns_definition END


-- ixp_application_users 
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_application_users_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_application_users_template'
        )
WHERE  o.[name] = 'application_users' AND ic.ixp_columns_id IS NULL

--ixp_source_deal_header_template_template
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_source_deal_header_template_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_source_deal_header_template_template'
        )
WHERE  o.[name] = 'source_deal_header_template' AND ic.ixp_columns_id IS NULL

-- ixp_source_deal_detail_template_template 
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_source_deal_detail_template_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_source_deal_detail_template_template'
        )
WHERE  o.[name] = 'source_deal_detail_template' AND ic.ixp_columns_id IS NULL

-- ixp_time_zones 
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_time_zones_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_time_zones_template'
        )
WHERE  o.[name] = 'time_zones' AND ic.ixp_columns_id IS NULL

-- ixp_region
INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_region_template'
       ) table_id,
       c.name,
       0
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_region_template'
        )
WHERE  o.[name] = 'region' AND ic.ixp_columns_id IS NULL


-- ixp_counterparty_contract_address column definiation
INSERT INTO ixp_columns (ixp_table_id,ixp_columns_name,is_major)
SELECT (
			SELECT it.ixp_tables_id
			FROM ixp_tables it
			WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
		) table_id,
		c.name,
		0
FROM sys.columns c
INNER JOIN sys.objects o ON c.object_id = o.object_id
LEFT JOIN ixp_columns ic
	ON ic.ixp_columns_name = c.name
	AND ic.ixp_table_id = (
		SELECT it.ixp_tables_id
		FROM ixp_tables it
		WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
	)
WHERE o.name = 'counterparty_contract_address' and ic.ixp_columns_id is null


-- Counterparty epa account
INSERT INTO ixp_columns (ixp_table_id,ixp_columns_name,is_major)
SELECT (
			SELECT it.ixp_tables_id
			FROM ixp_tables it
			WHERE it.ixp_tables_name = 'ixp_counterparty_epa_account_template'
		) table_id,
		c.name,
		0
FROM sys.columns c
INNER JOIN sys.objects o ON c.object_id = o.object_id
LEFT JOIN ixp_columns ic
	ON ic.ixp_columns_name = c.name
	AND ic.ixp_table_id = (
		SELECT it.ixp_tables_id
		FROM ixp_tables it
		WHERE it.ixp_tables_name = 'ixp_counterparty_epa_account_template'
	)
WHERE o.name = 'counterparty_epa_account' and ic.ixp_columns_id is null


--counterparty credit info

INSERT INTO ixp_columns (ixp_table_id,ixp_columns_name,is_major)
SELECT (
			SELECT it.ixp_tables_id
			FROM ixp_tables it
			WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
		) table_id,
		c.name,
		0
FROM sys.columns c
INNER JOIN sys.objects o ON c.object_id = o.object_id
LEFT JOIN ixp_columns ic
	ON ic.ixp_columns_name = c.name
	AND ic.ixp_table_id = (
		SELECT it.ixp_tables_id
		FROM ixp_tables it
		WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template'
	)
WHERE o.name = 'counterparty_credit_info' and ic.ixp_columns_id is null


--counterparty_bank_info
INSERT INTO ixp_columns (ixp_table_id,ixp_columns_name,is_major)
SELECT (
			SELECT it.ixp_tables_id
			FROM ixp_tables it
			WHERE it.ixp_tables_name = 'ixp_counterparty_bank_info_template'
		) table_id,
		c.name,
		0
FROM sys.columns c
INNER JOIN sys.objects o ON c.object_id = o.object_id
LEFT JOIN ixp_columns ic
	ON ic.ixp_columns_name = c.name
	AND ic.ixp_table_id = (
		SELECT it.ixp_tables_id
		FROM ixp_tables it
		WHERE it.ixp_tables_name = 'ixp_counterparty_bank_info_template'
	)
WHERE o.name = 'counterparty_bank_info' and ic.ixp_columns_id is null



--counterparty_limits
INSERT INTO ixp_columns (ixp_table_id,ixp_columns_name,is_major)
SELECT (
			SELECT it.ixp_tables_id
			FROM ixp_tables it
			WHERE it.ixp_tables_name = 'ixp_counterparty_limits_template'
		) table_id,
		c.name,
		0
FROM sys.columns c
INNER JOIN sys.objects o ON c.object_id = o.object_id
LEFT JOIN ixp_columns ic
	ON ic.ixp_columns_name = c.name
	AND ic.ixp_table_id = (
		SELECT it.ixp_tables_id
		FROM ixp_tables it
		WHERE it.ixp_tables_name = 'ixp_counterparty_limits_template'
	)
WHERE o.name = 'counterparty_limits' and ic.ixp_columns_id is null

--counterparty confirm info template
INSERT INTO ixp_columns (ixp_table_id,ixp_columns_name,is_major)
SELECT (
			SELECT it.ixp_tables_id
			FROM ixp_tables it
			WHERE it.ixp_tables_name = 'ixp_counterparty_confirm_info_template'
		) table_id,
		c.name,
		0
FROM sys.columns c
INNER JOIN sys.objects o ON c.object_id = o.object_id
LEFT JOIN ixp_columns ic
	ON ic.ixp_columns_name = c.name
	AND ic.ixp_table_id = (
		SELECT it.ixp_tables_id
		FROM ixp_tables it
		WHERE it.ixp_tables_name = 'ixp_counterparty_confirm_info_template'
	)
WHERE o.name = 'counterparty_confirm_info' and ic.ixp_columns_id is null

--counterparty invoice info template

INSERT INTO ixp_columns (ixp_table_id,ixp_columns_name,is_major)
SELECT (
			SELECT it.ixp_tables_id
			FROM ixp_tables it
			WHERE it.ixp_tables_name = 'ixp_counterparty_invoice_info_template'
		) table_id,
		c.name,
		0
FROM sys.columns c
INNER JOIN sys.objects o ON c.object_id = o.object_id
LEFT JOIN ixp_columns ic
	ON ic.ixp_columns_name = c.name
	AND ic.ixp_table_id = (
		SELECT it.ixp_tables_id
		FROM ixp_tables it
		WHERE it.ixp_tables_name = 'ixp_counterparty_invoice_info_template'
	)
WHERE o.name = 'counterparty_invoice_info' and ic.ixp_columns_id is NULL

--ixp_source_deal_settlement_breakdown_template
INSERT INTO ixp_columns (ixp_table_id,ixp_columns_name,is_major)
SELECT (
			SELECT it.ixp_tables_id
			FROM ixp_tables it
			WHERE it.ixp_tables_name = 'ixp_source_deal_settlement_breakdown_template'
		) table_id,
		c.name,
		0
FROM sys.columns c
INNER JOIN sys.objects o ON c.object_id = o.object_id
LEFT JOIN ixp_columns ic
	ON ic.ixp_columns_name = c.name
	AND ic.ixp_table_id = (
		SELECT it.ixp_tables_id
		FROM ixp_tables it
		WHERE it.ixp_tables_name = 'ixp_source_deal_settlement_breakdown_template'
	)
WHERE o.name = 'source_deal_settlement_breakdown' and ic.ixp_columns_id is NULL


--ixp_counterparty_credit_enhancements_template
INSERT INTO ixp_columns (ixp_table_id,ixp_columns_name,is_major)
SELECT (
			SELECT it.ixp_tables_id
			FROM ixp_tables it
			WHERE it.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'
		) table_id,
		c.name,
		0
FROM sys.columns c
INNER JOIN sys.objects o ON c.object_id = o.object_id
LEFT JOIN ixp_columns ic
	ON ic.ixp_columns_name = c.name
	AND ic.ixp_table_id = (
		SELECT it.ixp_tables_id
		FROM ixp_tables it
		WHERE it.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template'
	)
WHERE o.name = 'counterparty_credit_enhancements' and ic.ixp_columns_id is NULL

--ixp_formula_editor_template
INSERT INTO ixp_columns (ixp_table_id,ixp_columns_name,is_major)
SELECT (
			SELECT it.ixp_tables_id
			FROM ixp_tables it
			WHERE it.ixp_tables_name = 'ixp_formula_editor_template'
		) table_id,
		c.name,
		0
FROM sys.columns c
INNER JOIN sys.objects o ON c.object_id = o.object_id
LEFT JOIN ixp_columns ic
	ON ic.ixp_columns_name = c.name
	AND ic.ixp_table_id = (
		SELECT it.ixp_tables_id
		FROM ixp_tables it
		WHERE it.ixp_tables_name = 'ixp_formula_editor_template'
	)
WHERE o.name = 'formula_editor' and ic.ixp_columns_id is NULL

--ixp_source_system_description_template
INSERT INTO ixp_columns (ixp_table_id,ixp_columns_name,is_major)
SELECT (
			SELECT it.ixp_tables_id
			FROM ixp_tables it
			WHERE it.ixp_tables_name = 'ixp_source_system_description_template'
		) table_id,
		c.name,
		0
FROM sys.columns c
INNER JOIN sys.objects o ON c.object_id = o.object_id
LEFT JOIN ixp_columns ic
	ON ic.ixp_columns_name = c.name
	AND ic.ixp_table_id = (
		SELECT it.ixp_tables_id
		FROM ixp_tables it
		WHERE it.ixp_tables_name = 'ixp_source_system_description_template'
	)
WHERE o.name = 'source_system_description' and ic.ixp_columns_id is NULL

--ixp_contract_report_template_template
INSERT INTO ixp_columns (ixp_table_id,ixp_columns_name,is_major)
SELECT (
			SELECT it.ixp_tables_id
			FROM ixp_tables it
			WHERE it.ixp_tables_name = 'ixp_contract_report_template_template'
		) table_id,
		c.name,
		0
FROM sys.columns c
INNER JOIN sys.objects o ON c.object_id = o.object_id
LEFT JOIN ixp_columns ic
	ON ic.ixp_columns_name = c.name
	AND ic.ixp_table_id = (
		SELECT it.ixp_tables_id
		FROM ixp_tables it
		WHERE it.ixp_tables_name = 'ixp_contract_report_template_template'
	)
WHERE o.name = 'Contract_report_template' and ic.ixp_columns_id is NULL

--ixp_contract_charge_type_template
INSERT INTO ixp_columns (ixp_table_id,ixp_columns_name,is_major)
SELECT (
			SELECT it.ixp_tables_id
			FROM ixp_tables it
			WHERE it.ixp_tables_name = 'ixp_contract_charge_type_template'
		) table_id,
		c.name,
		0
FROM sys.columns c
INNER JOIN sys.objects o ON c.object_id = o.object_id
LEFT JOIN ixp_columns ic
	ON ic.ixp_columns_name = c.name
	AND ic.ixp_table_id = (
		SELECT it.ixp_tables_id
		FROM ixp_tables it
		WHERE it.ixp_tables_name = 'ixp_contract_charge_type_template'
	)
WHERE o.name = 'contract_charge_type' and ic.ixp_columns_id is NULL

--ixp_contract_charge_type_detail_template
INSERT INTO ixp_columns (ixp_table_id,ixp_columns_name,is_major)
SELECT (
			SELECT it.ixp_tables_id
			FROM ixp_tables it
			WHERE it.ixp_tables_name = 'ixp_contract_charge_type_detail_template'
		) table_id,
		c.name,
		0
FROM sys.columns c
INNER JOIN sys.objects o ON c.object_id = o.object_id
LEFT JOIN ixp_columns ic
	ON ic.ixp_columns_name = c.name
	AND ic.ixp_table_id = (
		SELECT it.ixp_tables_id
		FROM ixp_tables it
		WHERE it.ixp_tables_name = 'ixp_contract_charge_type_detail_template'
	)
WHERE o.name = 'contract_charge_type_detail' and ic.ixp_columns_id is NULL

--ixp_adjustment_default_gl_codes_template
INSERT INTO ixp_columns (ixp_table_id,ixp_columns_name,is_major)
SELECT (
			SELECT it.ixp_tables_id
			FROM ixp_tables it
			WHERE it.ixp_tables_name = 'ixp_adjustment_default_gl_codes_template'
		) table_id,
		c.name,
		0
FROM sys.columns c
INNER JOIN sys.objects o ON c.object_id = o.object_id
LEFT JOIN ixp_columns ic
	ON ic.ixp_columns_name = c.name
	AND ic.ixp_table_id = (
		SELECT it.ixp_tables_id
		FROM ixp_tables it
		WHERE it.ixp_tables_name = 'ixp_adjustment_default_gl_codes_template'
	)
WHERE o.name = 'adjustment_default_gl_codes' and ic.ixp_columns_id is NULL

-- ixp_deal_detail_hour_template starts
DECLARE @ixp_deal_detail_hour_template_id INT	
SELECT @ixp_deal_detail_hour_template_id = it.ixp_tables_id FROM   ixp_tables it WHERE  it.ixp_tables_name = 'ixp_deal_detail_hour_template'

IF @ixp_deal_detail_hour_template_id IS NOT NULL
BEGIN
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'profile' AND ixp_table_id = @ixp_deal_detail_hour_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_deal_detail_hour_template_id, 'profile', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'term_date' AND ixp_table_id = @ixp_deal_detail_hour_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_deal_detail_hour_template_id, 'term_date', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'Hour' AND ixp_table_id = @ixp_deal_detail_hour_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_deal_detail_hour_template_id, 'Hour', 0, NULL END
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'volume' AND ixp_table_id = @ixp_deal_detail_hour_template_id) BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) SELECT @ixp_deal_detail_hour_template_id, 'volume', 0, NULL END
END
ELSE
BEGIN
	SELECT 'ixp_deal_detail_hour_template not present in ixp_tables'
END