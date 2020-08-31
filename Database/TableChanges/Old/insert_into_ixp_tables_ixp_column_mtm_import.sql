IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_source_deal_pnl') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag) SELECT 'ixp_source_deal_pnl', 'MTM', 'i' END

--TABLE: ixp_source_deal_pnl 
     
DECLARE @temp_ixp_tables_id INT

SET @temp_ixp_tables_id = (SELECT it.ixp_tables_id FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_source_deal_pnl')
     
--COLUMN:[source_deal_header_id]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'source_deal_header_id' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'source_deal_header_id', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:source_deal_header_id ALREADY EXISTS.'
END

---COLUMN:[term_start]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'term_start' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'term_start', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:term_start ALREADY EXISTS.'
END

---COLUMN:[term_end]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'term_end' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'term_end', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:term_end ALREADY EXISTS.'
END

---COLUMN:[Leg]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'leg' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'leg', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:leg ALREADY EXISTS.'
END

---COLUMN:[pnl_as_of_date]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'pnl_as_of_date' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'pnl_as_of_date', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:pnl_as_of_date ALREADY EXISTS.'
END

---COLUMN:[und_pnl]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'und_pnl' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'und_pnl', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:und_pnl ALREADY EXISTS.'
END

---COLUMN:[und_intrinsic_pnl]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'und_intrinsic_pnl' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'und_intrinsic_pnl', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:und_intrinsic_pnl ALREADY EXISTS.'
END

---COLUMN:[und_extrinsic_pnl]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'und_extrinsic_pnl' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'und_extrinsic_pnl', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:und_extrinsic_pnl ALREADY EXISTS.'
END

---COLUMN:[dis_pnl]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'dis_pnl' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'dis_pnl', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:dis_pnl ALREADY EXISTS.'
END
				
---COLUMN:[dis_intrinsic_pnl]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'dis_intrinsic_pnl' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'dis_intrinsic_pnl', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:dis_intrinsic_pnl ALREADY EXISTS.'
END
		
---COLUMN:[dis_extrinisic_pnl]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'dis_extrinisic_pnl' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'dis_extrinisic_pnl', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:dis_extrinisic_pnl ALREADY EXISTS.'
END
			
---COLUMN:[pnl_source_value_id]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'pnl_source_value_id' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'pnl_source_value_id', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:pnl_source_value_id ALREADY EXISTS.'
END
					
---COLUMN:[pnl_currency_id]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'pnl_currency_id' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'pnl_currency_id', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:pnl_currency_id ALREADY EXISTS.'
END		
	
---COLUMN:[pnl_conversion_factor]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'pnl_conversion_factor' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'pnl_conversion_factor', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:pnl_conversion_factor ALREADY EXISTS.'
END	

---COLUMN:[pnl_adjustment_value]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'pnl_adjustment_value' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'pnl_adjustment_value', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:pnl_adjustment_value ALREADY EXISTS.'
END			
	
---COLUMN:[deal_volume]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'deal_volume' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'deal_volume', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:deal_volume ALREADY EXISTS.'
END		

---COLUMN:[create_user]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'create_user' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'create_user', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:create_user ALREADY EXISTS.'
END		
			
---COLUMN:[create_ts]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'create_ts' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'create_ts', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:create_ts ALREADY EXISTS.'
END				
			
---COLUMN:[update_user]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'update_user' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'update_user', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:update_user ALREADY EXISTS.'
END	

---COLUMN:[update_ts]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'update_ts' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'update_ts', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:update_ts ALREADY EXISTS.'
END		
		
---COLUMN:[source_deal_pnl_id]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'source_deal_pnl_id' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'source_deal_pnl_id', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:source_deal_pnl_id ALREADY EXISTS.'
END				
						
---COLUMN:[und_pnl_set]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'und_pnl_set' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'und_pnl_set', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:und_pnl_set ALREADY EXISTS.'
END		

---COLUMN:[market_value]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'market_value' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'market_value', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:market_value ALREADY EXISTS.'
END		
			
---COLUMN:[contract_value]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'contract_value' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'contract_value', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:contract_value ALREADY EXISTS.'
END		
			
---COLUMN:[dis_market_value]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'dis_market_value' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'dis_market_value', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:dis_market_value ALREADY EXISTS.'
END				
		
---COLUMN:[dis_contract_value]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'dis_contract_value' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'dis_contract_value', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:dis_contract_value ALREADY EXISTS.'
END				
		
--COLUMN:[pnl_currency]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'pnl_currency' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'pnl_currency', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:pnl_currency ALREADY EXISTS.'
END
		
--COLUMN:[reference_id]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'reference_id' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'reference_id', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:reference_id ALREADY EXISTS.'
END

--COLUMN:[discount_factor]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'discount_factor' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'discount_factor', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:discount_factor ALREADY EXISTS.'
END

--COLUMN:[discount_rate]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'discount_rate' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'discount_rate', 'VARCHAR(600)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:discount_rate ALREADY EXISTS.'
END

