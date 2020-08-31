-- ===============================================================================================================
-- Create date: 2012 - 03-19
--  Description:	Script to Insert value in archive_data_policy & Archive_data_policy_detail table for Source_price_curve
-- ===============================================================================================================
DECLARE @ident_archive_data_policy INT 

IF NOT EXISTS(SELECT 1 FROM archive_data_policy WHERE archive_type_value_id  = 2155 AND main_table_name = 'source_price_curve')
BEGIN
	--SET IDENTITY_INSERT archive_data_policy ON
	INSERT INTO archive_data_policy (archive_type_value_id, main_table_name, staging_table_name, sequence, where_field, archive_frequency, existence_check_fields)
	SELECT 2155 archive_type_value_id, 'source_price_curve' main_table_name, 'stage_source_price_curve' staging_table_name, 1 sequence, 'as_of_date' where_field, 'd' archive_frequency, 'source_curve_def_id, as_of_date, assessment_curve_type_value_id, curve_source_value_id, maturity_date, is_dst' existence_check_fields	
	PRINT 'Inserted Archive_data_policy  2155 - Source_price_curve.'
	--SET IDENTITY_INSERT archive_data_policy OFF
END
ELSE
BEGIN
	PRINT 'Policy ID  2155 - Source_price_curve already EXISTS.'
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
	SELECT @ident_archive_data_policy archive_data_policy_id, 'source_price_curve' table_name, 0 is_arch_table, 1 sequence, 'FARRMSMAIN.TRMTracker'  archive_db, '*' field_list, 1 retention_period
	PRINT 'Inserted Archive_data_policy_id ' + CAST( @ident_archive_data_policy AS VARCHAR(10))+ ' with sequence 1  - source_price_curve.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF

END
ELSE
BEGIN
--	SET IDENTITY_INSERT archive_data_policy_detail OFF
	PRINT 'Policy ID ' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 1  - source_price_curve already EXISTS.'
END
--
IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 2)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'source_price_curve_arch1', 1, 2,NULL, '*', 90
	PRINT 'Inserted Archive_data_policy_id  :' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 2  - source_price_curve_arch1.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF
END
ELSE
BEGIN
	PRINT 'Policy ID ' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 2  - source_price_curve_arch1 already EXISTS.'
END
--

IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 3)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'source_price_curve_arch2', 1, 3, NULL, '*', -1
	PRINT 'Inserted Archive_data_policy_id  ' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 3  - source_price_curve_arch2.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF
END
ELSE
BEGIN
	PRINT 'Policy ID ' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + '  with sequence 3  - source_price_curve_arch2 already EXISTS.'
END
--

GO

-- ===============================================================================================================
-- Create date: 2012 - 06-15
--  Description:	Script to Insert value in archive_data_policy & Archive_data_policy_detail table for cached_curves_value
-- ===============================================================================================================
DECLARE @ident_archive_data_policy INT 

IF NOT EXISTS(SELECT 1 FROM archive_data_policy WHERE archive_type_value_id  = 2155 AND main_table_name = 'cached_curves_value')
BEGIN
	--SET IDENTITY_INSERT archive_data_policy ON
	INSERT INTO archive_data_policy (archive_type_value_id, main_table_name, staging_table_name, sequence, where_field, archive_frequency, existence_check_fields)
	SELECT 2155 archive_type_value_id, 'cached_curves_value' main_table_name, 'stage_cached_curves_value' staging_table_name, 1 sequence, 'as_of_date' where_field, 'd' archive_frequency, 'Master_ROWID, as_of_date, term, pricing_option, curve_source_id' existence_check_fields	
	PRINT 'Inserted Archive_data_policy  2155 - cached_curves_value.'
	--SET IDENTITY_INSERT archive_data_policy OFF
END
ELSE
BEGIN
	PRINT 'Policy ID  2155 - cached_curves_value already EXISTS.'
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
	SELECT @ident_archive_data_policy archive_data_policy_id, 'cached_curves_value' table_name, 0 is_arch_table, 1 sequence, 'FARRMSMAIN.TRMTracker'  archive_db, '*' field_list, 1 retention_period
	PRINT 'Inserted Archive_data_policy_id ' + CAST( @ident_archive_data_policy AS VARCHAR(10))+ ' with sequence 1  - cached_curves_value.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF

END
ELSE
BEGIN
--	SET IDENTITY_INSERT archive_data_policy_detail OFF
	PRINT 'Policy ID ' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 1  - source_price_curve already EXISTS.'
END
--
IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 2)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'cached_curves_value_arch1', 1, 2,NULL, '*', 90
	PRINT 'Inserted Archive_data_policy_id  :' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 2  - cached_curves_value_arch1.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF
END
ELSE
BEGIN
	PRINT 'Policy ID ' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 2  - cached_curves_value_arch1 already EXISTS.'
END
--

IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 3)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'cached_curves_value_arch2', 1, 3, NULL, '*', -1
	PRINT 'Inserted Archive_data_policy_id  ' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 3  - cached_curves_value_arch2.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF
END
ELSE
BEGIN
	PRINT 'Policy ID ' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + '  with sequence 3  - cached_curves_value_arch2 already EXISTS.'
END
--