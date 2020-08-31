-- ===============================================================================================================
-- Create date: 2012 - 05-23
--  Description:	Script to Insert value in archive_data_policy & Archive_data_policy_detail table for fx_exposure
-- ===============================================================================================================
DECLARE @ident_archive_data_policy INT 

IF NOT EXISTS(SELECT 1 FROM archive_data_policy WHERE archive_type_value_id  = 2162 AND main_table_name = 'fx_exposure')
BEGIN
	--SET IDENTITY_INSERT archive_data_policy ON
	INSERT INTO archive_data_policy (archive_type_value_id, main_table_name, staging_table_name, sequence, where_field, archive_frequency, existence_check_fields)
	SELECT 2162 archive_type_value_id, 'fx_exposure' main_table_name, 'stage_fx_exposure' staging_table_name, 1 sequence, 'as_of_date' where_field, 'd' archive_frequency, 'as_of_date, source_deal_header_id, exp_side, phy_fin, curve_id, monthly_term, currency_id' existence_check_fields	
	PRINT 'Inserted Archive_data_policy  2162 - fx_exposure.'
	--SET IDENTITY_INSERT archive_data_policy OFF
END
ELSE
BEGIN
	PRINT 'Policy ID  2162 - fx_exposure already EXISTS.'
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
	SELECT @ident_archive_data_policy archive_data_policy_id, 'fx_exposure' table_name, 0 is_arch_table, 1 sequence, NULL  archive_db, '*' field_list, 1 retention_period
	PRINT 'Inserted Archive_data_policy_id ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 1  - fx_exposure.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF

END
ELSE
BEGIN
--	SET IDENTITY_INSERT archive_data_policy_detail OFF
	PRINT 'Policy ID ' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 1  - fx_exposure already EXISTS.'
END
--
IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 2)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'fx_exposure_arch1', 1, 2,'FARRMSARCH.TRMTracker_essent', '*', 9
	PRINT 'Inserted Archive_data_policy_id  :' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 2  - fx_exposure_arch1.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF
END
ELSE
BEGIN
	PRINT 'Policy ID ' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 2  - fx_exposure_arch1 already EXISTS.'
END
--

IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 3)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'fx_exposure_arch2', 1, 3, 'FARRMSARCH.TRMTracker_essent', '*', -1
	PRINT 'Inserted Archive_data_policy_id  ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 3  - fx_exposure_arch2.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF
END
ELSE
BEGIN
	PRINT 'Policy ID ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + '  with sequence 3  - fx_exposure_arch2 already EXISTS.'
END
--

