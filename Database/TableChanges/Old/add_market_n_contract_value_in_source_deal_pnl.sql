IF COL_LENGTH('source_Deal_pnl', 'market_value') IS NULL
BEGIN
    ALTER TABLE source_Deal_pnl ADD market_value FLOAT, contract_value FLOAT
END

IF OBJECT_ID('source_Deal_pnl_arch1') IS NOT NULL
BEGIN
    IF COL_LENGTH('source_Deal_pnl_arch1', 'market_value') IS NULL
        ALTER TABLE source_Deal_pnl_arch1 ADD market_value FLOAT ,contract_value FLOAT
END

IF OBJECT_ID('source_Deal_pnl_arch2') IS NOT NULL
BEGIN
    IF COL_LENGTH('source_Deal_pnl_arch2', 'market_value') IS NULL
        ALTER TABLE source_Deal_pnl_arch2 ADD market_value FLOAT ,contract_value FLOAT
END

--SELECT * FROM process_table_archive_policy
UPDATE process_table_archive_policy
SET    fieldlist = 
       '[source_deal_pnl_id],[source_deal_header_id],[term_start],[term_end],[Leg],[pnl_as_of_date],[und_pnl],[und_intrinsic_pnl],[und_extrinsic_pnl]   ,[dis_pnl],[dis_intrinsic_pnl],[dis_extrinisic_pnl],[pnl_source_value_id],[pnl_currency_id],[pnl_conversion_factor]   ,[pnl_adjustment_value],[deal_volume],[create_user],[create_ts],[update_user],[update_ts],und_pnl_set, market_value,contract_value'
WHERE  tbl_name LIKE 'source_Deal_pnl%'
	 

IF OBJECT_ID('source_Deal_pnl_arch1') IS NOT NULL
BEGIN
    IF COL_LENGTH('source_Deal_pnl_arch1', 'dis_market_value') IS NULL
        ALTER TABLE source_Deal_pnl_arch1 ADD dis_market_value FLOAT ,dis_contract_value FLOAT
END

IF OBJECT_ID('source_Deal_pnl_arch2') IS NOT NULL
BEGIN
    IF COL_LENGTH('source_Deal_pnl_arch2', 'dis_market_value') IS NULL
        ALTER TABLE source_Deal_pnl_arch2 ADD dis_market_value FLOAT ,dis_contract_value FLOAT
END
