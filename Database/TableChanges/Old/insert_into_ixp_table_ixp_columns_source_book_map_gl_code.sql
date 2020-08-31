IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag) SELECT 'ixp_source_book_gl_codes_import', 'Source Book and GL codes', 'i' END

--TABLE: ixp_source_book_gl_codes_import  
     
DECLARE @temp_ixp_tables_id INT

SET @temp_ixp_tables_id = (SELECT it.ixp_tables_id FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_source_book_gl_codes_import')
     
--COLUMN:[Source_System_ID]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'source_system_id' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'source_system_id', 'VARCHAR(10)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:source_system_id ALREADY EXISTS.'
END

---COLUMN:[Subsidiary_Name]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'subsidiary_name' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'subsidiary_name', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:subsidiary_name ALREADY EXISTS.'
END

---COLUMN:[strategy_name]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'strategy_name' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'strategy_name', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:strategy_name ALREADY EXISTS.'
END

---COLUMN:[book_name]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'book_name' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'book_name', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:book_name ALREADY EXISTS.'
END

---COLUMN:[book_identifier1]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'book_identifier1' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'book_identifier1', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:book_identifier1 ALREADY EXISTS.'
END

---COLUMN:[book_identifier_id1]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'book_identifier_id1' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'book_identifier_id1', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:book_identifier_id1 ALREADY EXISTS.'
END

---COLUMN:[book_identifier2]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'book_identifier2' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'book_identifier2', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:book_identifier2 ALREADY EXISTS.'
END

---COLUMN:[book_identifier_id2]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'book_identifier_id2' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'book_identifier_id2', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:book_identifier_id2 ALREADY EXISTS.'
END

---COLUMN:[book_identifier3]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'book_identifier3' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'book_identifier3', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:book_identifier3 ALREADY EXISTS.'
END
				
---COLUMN:[book_identifier_id3]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'book_identifier_id3' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'book_identifier_id3', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:book_identifier_id3 ALREADY EXISTS.'
END
		
---COLUMN:[book_identifier4]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'book_identifier4' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'book_identifier4', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:book_identifier4 ALREADY EXISTS.'
END
			
---COLUMN:[book_identifier_id4]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'book_identifier_id4' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'book_identifier_id4', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:book_identifier_id4 ALREADY EXISTS.'
END
					
---COLUMN:[accounting_treatment]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'accounting_treatment' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'accounting_treatment', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:accounting_treatment ALREADY EXISTS.'
END		
	
---COLUMN:[hedge_st_asset]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'hedge_st_asset' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'hedge_st_asset', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:hedge_st_asset ALREADY EXISTS.'
END	

---COLUMN:[hedge_lt_asset]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'hedge_lt_asset' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'hedge_lt_asset', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:hedge_lt_asset ALREADY EXISTS.'
END			
	
---COLUMN:[hedge_st_liab]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'hedge_st_liab' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'hedge_st_liab', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:hedge_st_liab ALREADY EXISTS.'
END		

---COLUMN:[hedge_lt_liab]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'hedge_lt_liab' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'hedge_lt_liab', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:hedge_lt_liab ALREADY EXISTS.'
END		
			
---COLUMN:[item_st_asset]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'item_st_asset' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'item_st_asset', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:item_st_asset ALREADY EXISTS.'
END				
			
---COLUMN:[item_st_liab]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'item_st_liab' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'item_st_liab', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:item_st_liab ALREADY EXISTS.'
END	

---COLUMN:[item_lt_asset]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'item_lt_asset' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'item_lt_asset', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:item_lt_asset ALREADY EXISTS.'
END		
		
---COLUMN:[item_lt_liab]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'item_lt_liab' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'item_lt_liab', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:item_lt_liab ALREADY EXISTS.'
END				
						
---COLUMN:[AOCI/Hedge_Reserve]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'AOCI/Hedge_Reserve' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'AOCI/Hedge_Reserve', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:AOCI/Hedge_Reserve ALREADY EXISTS.'
END		

---COLUMN:[unrealized_earnings]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'unrealized_earnings' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'unrealized_earnings', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:unrealized_earnings ALREADY EXISTS.'
END		
			
---COLUMN:[earnings]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'earnings' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'earnings', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:earnings ALREADY EXISTS.'
END		
			
---COLUMN:[cash]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'cash' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'cash', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:cash ALREADY EXISTS.'
END				
		
---COLUMN:[inventory]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'inventory' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'inventory', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:inventory ALREADY EXISTS.'
END				
		
--COLUMN:[expense]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'expense' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'expense', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:expense ALREADY EXISTS.'
END
		
--COLUMN:[gross_settlement]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'gross_settlement' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'gross_settlement', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:gross_settlement ALREADY EXISTS.'
END

--COLUMN:[amortization]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'amortization' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'amortization', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:amortization ALREADY EXISTS.'
END

--COLUMN:[interest]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'interest' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'interest', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:interest ALREADY EXISTS.'
END

--COLUMN:[first_day_pnl]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'first_day_pnl' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'first_day_pnl', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:first_day_pnl ALREADY EXISTS.'
END

--COLUMN:[st_tax_asset]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'st_tax_asset' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'st_tax_asset', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:st_tax_asset ALREADY EXISTS.'
END

--COLUMN:[st_tax_liab]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'st_tax_liab' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'st_tax_liab', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:st_tax_liab ALREADY EXISTS.'
END

--COLUMN:[lt_tax_asset]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'lt_tax_asset' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'lt_tax_asset', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:lt_tax_asset ALREADY EXISTS.'
END

--COLUMN:[lt_tax_liab]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'lt_tax_liab' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'lt_tax_liab', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:lt_tax_liab ALREADY EXISTS.'
END

--COLUMN:[tax_reserve]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'tax_reserve' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'tax_reserve', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:tax_reserve ALREADY EXISTS.'
END

--COLUMN:[unhedged_st_asset]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'unhedged_st_asset' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'unhedged_st_asset', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:unhedged_st_asset ALREADY EXISTS.'
END

--COLUMN:[unhedged_lt_asset]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'unhedged_lt_asset' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'unhedged_lt_asset', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:unhedged_lt_asset ALREADY EXISTS.'
END

--COLUMN:[unhedged_st_liab]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'unhedged_st_liab' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'unhedged_st_liab', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:unhedged_st_liab ALREADY EXISTS.'
END

--COLUMN:[unhedged_lt_liab]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'unhedged_lt_liab' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'unhedged_lt_liab', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:unhedged_lt_liab ALREADY EXISTS.'
END

--COLUMN:[A/C_Description1]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'A/C_Description1' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'A/C_Description1', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:A/C_Description1 ALREADY EXISTS.'
END

--COLUMN:[A/C_Description2]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'A/C_Description2' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'A/C_Description2', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:A/C_Description2 ALREADY EXISTS.'
END

--COLUMN:[table_code]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'table_code' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'table_code', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:table_code ALREADY EXISTS.'
END

--COLUMN:[logical_name]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'logical_name' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'logical_name', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:logical_name ALREADY EXISTS.'
END

--COLUMN:[level]
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'level' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'level', 'VARCHAR(300)', 0)
END
ELSE
BEGIN
    PRINT 'COLUMN:level ALREADY EXISTS.'
END