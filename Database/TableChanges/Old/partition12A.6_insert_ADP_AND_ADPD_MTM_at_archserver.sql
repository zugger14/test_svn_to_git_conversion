-- ===============================================================================================================
-- Create date: 2012 - 06-22
--  Description:	Script to Insert value in archive_data_policy & Archive_data_policy_detail table for source_deal_pnl
-- ===============================================================================================================
DECLARE @ident_archive_data_policy INT 

IF NOT EXISTS(SELECT 1 FROM archive_data_policy WHERE archive_type_value_id  = 2163 AND main_table_name = 'source_deal_pnl')
BEGIN
	--SET IDENTITY_INSERT archive_data_policy ON
	INSERT INTO archive_data_policy (archive_type_value_id, main_table_name, staging_table_name, sequence, where_field, archive_frequency, existence_check_fields)
	SELECT 2163 archive_type_value_id, 'source_deal_pnl' main_table_name, 'stage_source_deal_pnl' staging_table_name, 1 sequence, 'pnl_as_of_date' where_field, 'd' archive_frequency, 'source_deal_header_id, term_start, term_end, Leg, pnl_as_of_date, pnl_source_value_id' existence_check_fields	
	PRINT 'Inserted Archive_data_policy  2163 - source_deal_pnl.'
	--SET IDENTITY_INSERT archive_data_policy OFF
END
ELSE
BEGIN
	PRINT 'Policy ID  2163 - source_deal_pnl already EXISTS.'
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
	SELECT @ident_archive_data_policy archive_data_policy_id, 'source_deal_pnl' table_name, 0 is_arch_table, 1 sequence, 'FARRMSMAIN.TRMTracker_essent'  archive_db, '*' field_list, 1 retention_period
	PRINT 'Inserted Archive_data_policy_id ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 1  - source_deal_pnl.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF

END
ELSE
BEGIN
--	SET IDENTITY_INSERT archive_data_policy_detail OFF
	PRINT 'Policy ID ' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 1  - source_deal_pnl already EXISTS.'
END
--
IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 2)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'source_deal_pnl_arch1', 1, 2,NULL , '*', 4
	PRINT 'Inserted Archive_data_policy_id  :' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 2  - source_deal_pnl_arch1.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF
END
ELSE
BEGIN
	PRINT 'Policy ID ' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 2  - source_deal_pnl_arch1 already EXISTS.'
END
--

IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 3)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'source_deal_pnl_arch2', 1, 3, NULL , '*', -1
	PRINT 'Inserted Archive_data_policy_id  ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 3  - source_deal_pnl_arch2.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF
END
ELSE
BEGIN
	PRINT 'Policy ID ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + '  with sequence 3  - source_deal_pnl_arch2 already EXISTS.'
END
--

-- ===============================================================================================================
-- Create date: 2012 - 06-22
--  Description:	Script to Insert value in archive_data_policy & Archive_data_policy_detail table for source_deal_pnl_detail
-- ===============================================================================================================
GO
DECLARE @ident_archive_data_policy INT 

IF NOT EXISTS(SELECT 1 FROM archive_data_policy WHERE archive_type_value_id  = 2163 AND main_table_name = 'source_deal_pnl_detail')
BEGIN
	--SET IDENTITY_INSERT archive_data_policy ON
	INSERT INTO archive_data_policy (archive_type_value_id, main_table_name, staging_table_name, sequence, where_field, archive_frequency, existence_check_fields)
	SELECT 2163 archive_type_value_id, 'source_deal_pnl_detail' main_table_name, 'stage_source_deal_pnl_detail' staging_table_name, 1 sequence, 'pnl_as_of_date' where_field, 'd' archive_frequency, 'source_deal_header_id, term_start, term_end, Leg, pnl_as_of_date, pnl_source_value_id' existence_check_fields	
	PRINT 'Inserted Archive_data_policy  2163 - source_deal_pnl_detail.'
	--SET IDENTITY_INSERT archive_data_policy OFF
END
ELSE
BEGIN
	PRINT 'Policy ID  2163 - source_deal_pnl_detail already EXISTS.'
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
	SELECT @ident_archive_data_policy archive_data_policy_id, 'source_deal_pnl_detail' table_name, 0 is_arch_table, 1 sequence, 'FARRMSMAIN.TRMTracker_essent'  archive_db, '*' field_list, 1 retention_period
	PRINT 'Inserted Archive_data_policy_id ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 1  - source_deal_pnl_detail.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF

END
ELSE
BEGIN
--	SET IDENTITY_INSERT archive_data_policy_detail OFF
	PRINT 'Policy ID ' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 1  - source_deal_pnl_detail already EXISTS.'
END
--
IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 2)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'source_deal_pnl_detail_arch1', 1, 2,NULL , '*', 4
	PRINT 'Inserted Archive_data_policy_id  :' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 2  - source_deal_pnl_detail_arch1.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF
END
ELSE
BEGIN
	PRINT 'Policy ID ' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 2  - source_deal_pnl_detail_arch1 already EXISTS.'
END
--

IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 3)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'source_deal_pnl_detail_arch2', 1, 3, NULL , '*', -1
	PRINT 'Inserted Archive_data_policy_id  ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 3  - source_deal_pnl_detail_arch2.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF
END
ELSE
BEGIN
	PRINT 'Policy ID ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + '  with sequence 3  - source_deal_pnl_detail_arch2 already EXISTS.'
END
--

GO

-- ===============================================================================================================
-- Create date: 2012 - 06-22
--  Description:	Script to Insert value in archive_data_policy & Archive_data_policy_detail table for source_deal_pnl_detail
-- ===============================================================================================================
GO
DECLARE @ident_archive_data_policy INT 

IF NOT EXISTS(SELECT 1 FROM archive_data_policy WHERE archive_type_value_id  = 2163 AND main_table_name = 'Index_fees_breakdown')
BEGIN
	--SET IDENTITY_INSERT archive_data_policy ON
	INSERT INTO archive_data_policy (archive_type_value_id, main_table_name, staging_table_name, sequence, where_field, archive_frequency, existence_check_fields)
	SELECT 2163 archive_type_value_id, 'Index_fees_breakdown_detail' main_table_name, 'stage_Index_fees_breakdown' staging_table_name, 1 sequence, 'as_of_date' where_field, 'd' archive_frequency, 'as_of_date, source_deal_header_id, term_start, field_id, leg' existence_check_fields	
	PRINT 'Inserted Archive_data_policy  2163 - Index_fees_breakdown.'
	--SET IDENTITY_INSERT archive_data_policy OFF
END
ELSE
BEGIN
	PRINT 'Policy ID  2163 - Index_fees_breakdown already EXISTS.'
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
	SELECT @ident_archive_data_policy archive_data_policy_id, 'Index_fees_breakdown' table_name, 0 is_arch_table, 1 sequence, 'FARRMSMAIN.TRMTracker_essent'  archive_db, '*' field_list, 1 retention_period
	PRINT 'Inserted Archive_data_policy_id ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 1  - Index_fees_breakdown.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF

END
ELSE
BEGIN
--	SET IDENTITY_INSERT archive_data_policy_detail OFF
	PRINT 'Policy ID ' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 1  - Index_fees_breakdown already EXISTS.'
END
--
IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 2)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'Index_fees_breakdown_arch1', 1, 2,NULL , '*', 4
	PRINT 'Inserted Archive_data_policy_id  :' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 2  - Index_fees_breakdown_arch1.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF
END
ELSE
BEGIN
	PRINT 'Policy ID ' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 2  - Index_fees_breakdown_arch1 already EXISTS.'
END
--

IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 3)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'Index_fees_breakdown_arch2', 1, 3, NULL , '*', -1
	PRINT 'Inserted Archive_data_policy_id  ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 3  - Index_fees_breakdown_arch2.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF
END
ELSE
BEGIN
	PRINT 'Policy ID ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + '  with sequence 3  - Index_fees_breakdown_arch2 already EXISTS.'
END
--
