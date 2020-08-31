-- ===============================================================================================================
-- Create date: 2012 - 05-10
--  Description:	Script to Insert value in archive_data_policy & Archive_data_policy_detail table for Position
-- ===============================================================================================================
DECLARE @ident_archive_data_policy INT 

IF NOT EXISTS(SELECT 1 FROM archive_data_policy WHERE archive_type_value_id  = 2160 AND main_table_name = 'report_hourly_position_deal')
BEGIN
	--SET IDENTITY_INSERT archive_data_policy ON
	INSERT INTO archive_data_policy (archive_type_value_id, main_table_name, staging_table_name, sequence, where_field, archive_frequency, existence_check_fields)
	SELECT 2160 archive_type_value_id, 'report_hourly_position_deal' main_table_name, 'stage_report_hourly_position_deal' staging_table_name, 1 sequence, 'term_start' where_field, 'm' archive_frequency, 'source_deal_header_id , curve_id , location_id , term_start' existence_check_fields	
	PRINT 'Inserted Archive_data_policy  2160 - Position - report_hourly_position_deal.'
	--SET IDENTITY_INSERT archive_data_policy OFF
END
ELSE
BEGIN
	PRINT 'Policy ID  2160 - position - report_hourly_position_deal already EXISTS.'
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
	SELECT @ident_archive_data_policy archive_data_policy_id, 'report_hourly_position_deal' table_name, 0 is_arch_table, 1 sequence, 'FARRMSMAIN.TRMTracker_essent'  archive_db, '*' field_list, 1 retention_period
	PRINT 'Inserted Archive_data_policy_id ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 1  - report_hourly_position_deal.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF

END
ELSE
BEGIN
--	SET IDENTITY_INSERT archive_data_policy_detail OFF
	PRINT 'Policy ID ' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 1  - report_hourly_position_deal already EXISTS.'
END
--
IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 2)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'report_hourly_position_deal_arch1', 1, 2,NULL , '*', 15
	PRINT 'Inserted Archive_data_policy_id  :' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 2  - report_hourly_position_deal_arch1.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF
END
ELSE
BEGIN
	PRINT 'Policy ID ' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 2  - report_hourly_position_deal_arch1 already EXISTS.'
END
--

IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 3)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'report_hourly_position_deal_arch2', 1, 3, NULL, '*', -1
	PRINT 'Inserted Archive_data_policy_id  ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 3  - report_hourly_position_deal_arch2.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF
END
ELSE
BEGIN
	PRINT 'Policy ID ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + '  with sequence 3  - report_hourly_position_deal_arch2 already EXISTS.'
END
--

-----------------------------INSERT REPORT HOURLY_POSITION_PROFILE
GO
DECLARE @ident_archive_data_policy INT 

IF NOT EXISTS(SELECT 1 FROM archive_data_policy WHERE archive_type_value_id  = 2159 AND main_table_name = 'report_hourly_position_profile')
BEGIN
	--SET IDENTITY_INSERT archive_data_policy ON
	INSERT INTO archive_data_policy (archive_type_value_id, main_table_name, staging_table_name, sequence, where_field, archive_frequency, existence_check_fields)
	SELECT 2159 archive_type_value_id, 'report_hourly_position_profile' main_table_name, 'stage_report_hourly_position_profile' staging_table_name, 1 sequence, 'term_start' where_field, 'm' archive_frequency, 'source_deal_header_id , curve_id , location_id , term_start' existence_check_fields	
	PRINT 'Inserted Archive_data_policy  2159 - Position - report_hourly_position_profile.'
	--SET IDENTITY_INSERT archive_data_policy OFF
END
ELSE
BEGIN
	PRINT 'Policy ID  2159 - position - report_hourly_position_profile already EXISTS.'
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
	SELECT @ident_archive_data_policy archive_data_policy_id, 'report_hourly_position_profile' table_name, 0 is_arch_table, 1 sequence, 'FARRMSMAIN.TRMTracker_essent'  archive_db, '*' field_list, 1 retention_period
	PRINT 'Inserted Archive_data_policy_id ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 1  - report_hourly_position_profile.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF

END
ELSE
BEGIN
--	SET IDENTITY_INSERT archive_data_policy_detail OFF
	PRINT 'Policy ID ' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 1  - report_hourly_position_profile already EXISTS.'
END
--
IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 2)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'report_hourly_position_profile_arch1', 1, 2, NULL, '*', 15
	PRINT 'Inserted Archive_data_policy_id  :' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 2  - report_hourly_position_profile_arch1.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF
END
ELSE
BEGIN
	PRINT 'Policy ID ' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 2  - report_hourly_position_profile_arch1 already EXISTS.'
END
--

IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 3)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'report_hourly_position_profile_arch2', 1, 3, NULL, '*', -1
	PRINT 'Inserted Archive_data_policy_id  ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 3  - report_hourly_position_profile_arch2.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF
END
ELSE
BEGIN
	PRINT 'Policy ID ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + '  with sequence 3  - report_hourly_position_profile_arch2 already EXISTS.'
END
--

-----------------------------INSERT report_hourly_position_breakdown
GO
DECLARE @ident_archive_data_policy INT 

IF NOT EXISTS(SELECT 1 FROM archive_data_policy WHERE archive_type_value_id  = 2159 AND main_table_name = 'report_hourly_position_breakdown')
BEGIN
	--SET IDENTITY_INSERT archive_data_policy ON
	INSERT INTO archive_data_policy (archive_type_value_id, main_table_name, staging_table_name, sequence, where_field, archive_frequency, existence_check_fields)
	SELECT 2159 archive_type_value_id, 'report_hourly_position_breakdown' main_table_name, 'stage_report_hourly_position_breakdown' staging_table_name, 1 sequence, 'term_start' where_field, 'm' archive_frequency, 'source_deal_header_id, curve_id, term_start, term_end' existence_check_fields	
	PRINT 'Inserted Archive_data_policy  2158 - Position - report_hourly_position_breakdown.'
	--SET IDENTITY_INSERT archive_data_policy OFF
END
ELSE
BEGIN
	PRINT 'Policy ID  2159 - position - report_hourly_position_breakdown already EXISTS.'
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
	SELECT @ident_archive_data_policy archive_data_policy_id, 'report_hourly_position_breakdown' table_name, 0 is_arch_table, 1 sequence, 'FARRMSMAIN.TRMTracker_essent'  archive_db, '*' field_list, 1 retention_period
	PRINT 'Inserted Archive_data_policy_id ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 1  - report_hourly_position_breakdown.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF

END
ELSE
BEGIN
--	SET IDENTITY_INSERT archive_data_policy_detail OFF
	PRINT 'Policy ID ' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 1  - report_hourly_position_profile already EXISTS.'
END
--
IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 2)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'report_hourly_position_breakdown_arch1', 1, 2, NULL, '*', 15
	PRINT 'Inserted Archive_data_policy_id  :' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 2  - report_hourly_position_breakdown_arch1.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF
END
ELSE
BEGIN
	PRINT 'Policy ID ' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 2  - report_hourly_position_breakdown_arch1 already EXISTS.'
END
--

IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 3)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'report_hourly_position_breakdown_arch2', 1, 3, NULL, '*', -1
	PRINT 'Inserted Archive_data_policy_id  ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 3  - report_hourly_position_breakdown_arch2.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF
END
ELSE
BEGIN
	PRINT 'Policy ID ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + '  with sequence 3  - report_hourly_position_breakdown_arch2 already EXISTS.'
END
--


-----------------------------INSERT delta_report_hourly_position
GO
DECLARE @ident_archive_data_policy INT 

IF NOT EXISTS(SELECT 1 FROM archive_data_policy WHERE archive_type_value_id  = 2160 AND main_table_name = 'delta_report_hourly_position')
BEGIN
	--SET IDENTITY_INSERT archive_data_policy ON
	INSERT INTO archive_data_policy (archive_type_value_id, main_table_name, staging_table_name, sequence, where_field, archive_frequency, existence_check_fields)
	SELECT 2160 archive_type_value_id, 'delta_report_hourly_position' main_table_name, 'stage_delta_report_hourly_position' staging_table_name, 1 sequence, 'term_start' where_field, 'm' archive_frequency, 'as_of_date, source_deal_header_id, curve_id, location_id, term_start' existence_check_fields	
	PRINT 'Inserted Archive_data_policy  2160 - Position - delta_report_hourly_position.'
	--SET IDENTITY_INSERT archive_data_policy OFF
END
ELSE
BEGIN
	PRINT 'Policy ID  2160 - position - delta_report_hourly_position already EXISTS.'
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
	SELECT @ident_archive_data_policy archive_data_policy_id, 'delta_report_hourly_position' table_name, 0 is_arch_table, 1 sequence, 'FARRMSMAIN.TRMTracker_essent'  archive_db, '*' field_list, 1 retention_period
	PRINT 'Inserted Archive_data_policy_id ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 1  - delta_report_hourly_position.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF

END
ELSE
BEGIN
--	SET IDENTITY_INSERT archive_data_policy_detail OFF
	PRINT 'Policy ID ' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 1  - delta_report_hourly_position already EXISTS.'
END
--
IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 2)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'delta_report_hourly_position_arch1', 1, 2, NULL, '*', 15
	PRINT 'Inserted Archive_data_policy_id  :' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 2  - delta_report_hourly_position_arch1.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF
END
ELSE
BEGIN
	PRINT 'Policy ID ' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 2  - delta_report_hourly_position_arch1 already EXISTS.'
END
--

IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 3)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'delta_report_hourly_position_arch2', 1, 3, NULL, '*', -1
	PRINT 'Inserted Archive_data_policy_id  ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 3  - delta_report_hourly_position_arch2.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF
END
ELSE
BEGIN
	PRINT 'Policy ID ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + '  with sequence 3  - delta_report_hourly_position_arch2 already EXISTS.'
END
--

-----------------------------INSERT report_hourly_position_fixed
GO
DECLARE @ident_archive_data_policy INT 

IF NOT EXISTS(SELECT 1 FROM archive_data_policy WHERE archive_type_value_id  = 2160 AND main_table_name = 'report_hourly_position_fixed')
BEGIN
	--SET IDENTITY_INSERT archive_data_policy ON
	INSERT INTO archive_data_policy (archive_type_value_id, main_table_name, staging_table_name, sequence, where_field, archive_frequency, existence_check_fields)
	SELECT 2160 archive_type_value_id, 'report_hourly_position_fixed' main_table_name, 'stage_report_hourly_position_fixed' staging_table_name, 1 sequence, 'term_start' where_field, 'm' archive_frequency, ' source_deal_header_id, curve_id, location_id, term_start' existence_check_fields	
	PRINT 'Inserted Archive_data_policy  2160 - Position - report_hourly_position_fixed.'
	--SET IDENTITY_INSERT archive_data_policy OFF
END
ELSE
BEGIN
	PRINT 'Policy ID  2160 - position - report_hourly_position_fixed already EXISTS.'
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
	SELECT @ident_archive_data_policy archive_data_policy_id, 'report_hourly_position_fixed' table_name, 0 is_arch_table, 1 sequence, 'FARRMSMAIN.TRMTracker_essent'  archive_db, '*' field_list, 1 retention_period
	PRINT 'Inserted Archive_data_policy_id ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 1  - report_hourly_position_fixed.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF

END
ELSE
BEGIN
--	SET IDENTITY_INSERT archive_data_policy_detail OFF
	PRINT 'Policy ID ' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 1  - report_hourly_position_fixed already EXISTS.'
END
--
IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 2)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'report_hourly_position_fixed_arch1', 1, 2, NULL, '*', 15
	PRINT 'Inserted Archive_data_policy_id  :' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 2  - report_hourly_position_fixed_arch1.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF
END
ELSE
BEGIN
	PRINT 'Policy ID ' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 2  - report_hourly_position_fixed_arch1 already EXISTS.'
END
--

IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 3)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'report_hourly_position_fixed_arch2', 1, 3, NULL , '*', -1
	PRINT 'Inserted Archive_data_policy_id  ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 3  - report_hourly_position_fixed_arch2.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF
END
ELSE
BEGIN
	PRINT 'Policy ID ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + '  with sequence 3  - report_hourly_position_fixed_arch2 already EXISTS.'
END
--


-----------------------------INSERT deal_position_break_down
GO
DECLARE @ident_archive_data_policy INT 

IF NOT EXISTS(SELECT 1 FROM archive_data_policy WHERE archive_type_value_id  = 2160 AND main_table_name = 'deal_position_break_down')
BEGIN
	--SET IDENTITY_INSERT archive_data_policy ON
	INSERT INTO archive_data_policy (archive_type_value_id, main_table_name, staging_table_name, sequence, where_field, archive_frequency, existence_check_fields)
	SELECT 2160 archive_type_value_id, 'deal_position_break_down' main_table_name, 'stage_deal_position_break_down' staging_table_name, 1 sequence, 'del_term_start' where_field, 'm' archive_frequency, 'breakdown_id' existence_check_fields	
	PRINT 'Inserted Archive_data_policy  2160 - Position - deal_position_break_down.'
	--SET IDENTITY_INSERT archive_data_policy OFF
END
ELSE
BEGIN
	PRINT 'Policy ID  2160 - position - deal_position_break_down already EXISTS.'
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
	SELECT @ident_archive_data_policy archive_data_policy_id, 'deal_position_break_down' table_name, 0 is_arch_table, 1 sequence, 'FARRMSMAIN.TRMTracker_essent'  archive_db, '*' field_list, 1 retention_period
	PRINT 'Inserted Archive_data_policy_id ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 1  - deal_position_break_down.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF

END
ELSE
BEGIN
--	SET IDENTITY_INSERT archive_data_policy_detail OFF
	PRINT 'Policy ID ' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 1  - deal_position_break_down already EXISTS.'
END
--
IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 2)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'deal_position_break_down_arch1', 1, 2, NULL, '*', 15
	PRINT 'Inserted Archive_data_policy_id  :' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 2  - deal_position_break_down_arch1.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF
END
ELSE
BEGIN
	PRINT 'Policy ID ' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 2  - deal_position_break_down_arch1 already EXISTS.'
END
--

IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 3)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'deal_position_break_down_arch2', 1, 3, NULL, '*', -1
	PRINT 'Inserted Archive_data_policy_id  ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 3  - deal_position_break_down_arch2.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF
END
ELSE
BEGIN
	PRINT 'Policy ID ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + '  with sequence 3  - deal_position_break_down_arch2 already EXISTS.'
END
--



-----------------------------INSERT delta_report_hourly_position_breakdown
GO
DECLARE @ident_archive_data_policy INT 

IF NOT EXISTS(SELECT 1 FROM archive_data_policy WHERE archive_type_value_id  = 2159 AND main_table_name = 'delta_report_hourly_position_breakdown')
BEGIN
	--SET IDENTITY_INSERT archive_data_policy ON
	INSERT INTO archive_data_policy (archive_type_value_id, main_table_name, staging_table_name, sequence, where_field, archive_frequency, existence_check_fields)
	SELECT 2159 archive_type_value_id, 'delta_report_hourly_position_breakdown' main_table_name, 'stage_delta_report_hourly_position_breakdown' staging_table_name, 1 sequence, 'term_start' where_field, 'm' archive_frequency, 'as_of_date, source_deal_header_id, curve_id,  term_start' existence_check_fields	
	PRINT 'Inserted Archive_data_policy  2159 - Position - delta_report_hourly_position_breakdown.'
	--SET IDENTITY_INSERT archive_data_policy OFF
END
ELSE
BEGIN
	PRINT 'Policy ID  2159 - position - delta_report_hourly_position_breakdown already EXISTS.'
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
	SELECT @ident_archive_data_policy archive_data_policy_id, 'delta_report_hourly_position_breakdown' table_name, 0 is_arch_table, 1 sequence, 'FARRMSMAIN.TRMTracker_essent'  archive_db, '*' field_list, 1 retention_period
	PRINT 'Inserted Archive_data_policy_id ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 1  - delta_report_hourly_position_breakdown.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF

END
ELSE
BEGIN
--	SET IDENTITY_INSERT archive_data_policy_detail OFF
	PRINT 'Policy ID ' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 1  - delta_report_hourly_position_breakdown already EXISTS.'
END
--
IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 2)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'delta_report_hourly_position_breakdown_arch1', 1, 2, NULL, '*', 15
	PRINT 'Inserted Archive_data_policy_id  :' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 2  - delta_report_hourly_position_breakdown_arch1.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF
END
ELSE
BEGIN
	PRINT 'Policy ID ' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 2  - delta_report_hourly_position_breakdown_arch1 already EXISTS.'
END
--

IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 3)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'delta_report_hourly_position_breakdown_arch2', 1, 3, NULL, '*', -1
	PRINT 'Inserted Archive_data_policy_id  ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 3  - delta_report_hourly_position_breakdown_arch2.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF
END
ELSE
BEGIN
	PRINT 'Policy ID ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + '  with sequence 3  - delta_report_hourly_position_breakdown_arch2 already EXISTS.'
END
--