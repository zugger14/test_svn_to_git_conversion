-- ===============================================================================================================
-- Create date: 2012 - 06-16
--  Description:	Script to Insert value in archive_data_policy & Archive_data_policy_detail table for source_deal_settlement
-- ===============================================================================================================
DECLARE @ident_archive_data_policy INT 

IF NOT EXISTS(SELECT 1 FROM archive_data_policy WHERE archive_type_value_id  = 2161 AND main_table_name = 'source_deal_settlement')
BEGIN
	--SET IDENTITY_INSERT archive_data_policy ON
	INSERT INTO archive_data_policy (archive_type_value_id, main_table_name, staging_table_name, sequence, where_field, archive_frequency, existence_check_fields)
	SELECT 2161 archive_type_value_id, 'source_deal_settlement' main_table_name, 'stage_source_deal_settlement' staging_table_name, 1 sequence, 'as_of_date' where_field, 'd' archive_frequency, 'source_deal_header_id,as_of_date,term_start' existence_check_fields	
	PRINT 'Inserted Archive_data_policy  2161 - source_deal_settlement.'
	--SET IDENTITY_INSERT archive_data_policy OFF
END
ELSE
BEGIN
	PRINT 'Policy ID  2161 - source_deal_settlement already EXISTS.'
END

BEGIN
SELECT @ident_archive_data_policy =  IDENT_CURRENT('archive_data_policy')	
END
 PRINT @ident_archive_data_policy


--SET IDENTITY_INSERT archive_data_policy_detail OFF
IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 1)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy archive_data_policy_id, 'source_deal_settlement' table_name, 0 is_arch_table, 1 sequence, NULL  archive_db, '*' field_list, 1 retention_period
	PRINT 'Inserted Archive_data_policy_id ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 1  - source_deal_settlement.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF

END
ELSE
BEGIN
--	SET IDENTITY_INSERT archive_data_policy_detail OFF
	PRINT 'Policy ID ' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 1  - source_deal_settlement already EXISTS.'
END
--
IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 2)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'source_deal_settlement_arch1', 1, 2,'FARRMSARCH.TRMTracker_essent', '*', 820
	PRINT 'Inserted Archive_data_policy_id  :' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 2  - source_deal_settlement_arch1.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF
END
ELSE
BEGIN
	PRINT 'Policy ID ' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 2  - source_deal_settlement_arch1 already EXISTS.'
END
--

IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 3)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'source_deal_settlement_arch2', 1, 3, 'FARRMSARCH.TRMTracker_essent', '*', -1
	PRINT 'Inserted Archive_data_policy_id  ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 3  - source_deal_settlement_arch2.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF
END
ELSE
BEGIN
	PRINT 'Policy ID ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + '  with sequence 3  - source_deal_settlement_arch2 already EXISTS.'
END
--

-- ===============================================================================================================
-- Create date: 2012 - 06-15
--  Description:	Script to Insert value in archive_data_policy & Archive_data_policy_detail table for Calc_formula_value
-- ===============================================================================================================
GO
DECLARE @ident_archive_data_policy INT 

IF NOT EXISTS(SELECT 1 FROM archive_data_policy WHERE archive_type_value_id  = 2161 AND main_table_name = 'Calc_formula_value')
BEGIN
	--SET IDENTITY_INSERT archive_data_policy ON
	INSERT INTO archive_data_policy (archive_type_value_id, main_table_name, staging_table_name, sequence, where_field, archive_frequency, existence_check_fields)
	SELECT 2161 archive_type_value_id, 'Calc_formula_value' main_table_name, 'stage_Calc_formula_value' staging_table_name, 1 sequence, 'prod_date' where_field, 'd' archive_frequency, 'source_deal_header_id,prod_date' existence_check_fields	
	PRINT 'Inserted Archive_data_policy  2161 - Calc_formula_value.'
	--SET IDENTITY_INSERT archive_data_policy OFF
END
ELSE
BEGIN
	PRINT 'Policy ID  2161 - Calc_formula_value already EXISTS.'
END

BEGIN
SELECT @ident_archive_data_policy =  IDENT_CURRENT('archive_data_policy')	
END
 PRINT @ident_archive_data_policy


--SET IDENTITY_INSERT archive_data_policy_detail OFF
IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 1)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy archive_data_policy_id, 'Calc_formula_value' table_name, 0 is_arch_table, 1 sequence, NULL  archive_db, '*' field_list, 1 retention_period
	PRINT 'Inserted Archive_data_policy_id ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 1  - Calc_formula_value.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF

END
ELSE
BEGIN
--	SET IDENTITY_INSERT archive_data_policy_detail OFF
	PRINT 'Policy ID ' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 1  - Calc_formula_value already EXISTS.'
END
--
IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 2)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'Calc_formula_value_arch1', 1, 2,'FARRMSARCH.TRMTracker_essent', '*', 820
	PRINT 'Inserted Archive_data_policy_id  :' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 2  - Calc_formula_value_arch1.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF
END
ELSE
BEGIN
	PRINT 'Policy ID ' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 2  - Calc_formula_value_arch1 already EXISTS.'
END
--

IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 3)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'Calc_formula_value_arch2', 1, 3, 'FARRMSARCH.TRMTracker_essent', '*', -1
	PRINT 'Inserted Archive_data_policy_id  ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 3  - Calc_formula_value_arch2.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF
END
ELSE
BEGIN
	PRINT 'Policy ID ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + '  with sequence 3  - Calc_formula_value_arch2 already EXISTS.'
END
--
-- ===============================================================================================================
-- Create date: 2012 - 06-16
--  Description:	Script to Insert value in archive_data_policy & Archive_data_policy_detail table for index_fees_breakdown_settlement
-- ===============================================================================================================
GO
DECLARE @ident_archive_data_policy INT 

IF NOT EXISTS(SELECT 1 FROM archive_data_policy WHERE archive_type_value_id  = 2161 AND main_table_name = 'index_fees_breakdown_settlement')
BEGIN
	--SET IDENTITY_INSERT archive_data_policy ON
	INSERT INTO archive_data_policy (archive_type_value_id, main_table_name, staging_table_name, sequence, where_field, archive_frequency, existence_check_fields)
	SELECT 2161 archive_type_value_id, 'index_fees_breakdown_settlement' main_table_name, 'stage_index_fees_breakdown_settlement' staging_table_name, 1 sequence, 'as_of_date' where_field, 'd' archive_frequency, 'source_deal_header_id,as_of_date,term_start' existence_check_fields	
	PRINT 'Inserted Archive_data_policy  2161 - index_fees_breakdown_settlement.'
	--SET IDENTITY_INSERT archive_data_policy OFF
END
ELSE
BEGIN
	PRINT 'Policy ID  2161 - index_fees_breakdown_settlement already EXISTS.'
END

BEGIN
SELECT @ident_archive_data_policy =  IDENT_CURRENT('archive_data_policy')	
END
 PRINT @ident_archive_data_policy


--SET IDENTITY_INSERT archive_data_policy_detail OFF
IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 1)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy archive_data_policy_id, 'index_fees_breakdown_settlement' table_name, 0 is_arch_table, 1 sequence, NULL  archive_db, '*' field_list, 1 retention_period
	PRINT 'Inserted Archive_data_policy_id ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 1  - index_fees_breakdown_settlement.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF

END
ELSE
BEGIN
--	SET IDENTITY_INSERT archive_data_policy_detail OFF
	PRINT 'Policy ID ' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 1  - index_fees_breakdown_settlement already EXISTS.'
END
--
IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 2)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'index_fees_breakdown_settlement_arch1', 1, 2,'FARRMSARCH.TRMTracker_essent', '*', 820
	PRINT 'Inserted Archive_data_policy_id  :' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 2  - index_fees_breakdown_settlement_arch1.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF
END
ELSE
BEGIN
	PRINT 'Policy ID ' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 2  - index_fees_breakdown_settlement_arch1 already EXISTS.'
END
--

IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 3)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'index_fees_breakdown_settlement_arch2', 1, 3, 'FARRMSARCH.TRMTracker_essent', '*', -1
	PRINT 'Inserted Archive_data_policy_id  ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 3  - index_fees_breakdown_settlement_arch2.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF
END
ELSE
BEGIN
	PRINT 'Policy ID ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + '  with sequence 3  - index_fees_breakdown_settlement_arch2 already EXISTS.'
END
--
