-- Create date: 2012 - 03-19
--  Description:	Script to Insert value in archive_data_policy & Archive_data_policy_detail table for mv90_data
-- ===============================================================================================================
--DECLARE @ident_archive_data_policy INT
-----------------------------------------Insert ADP & ADPD for mv90_data_mins --------------------------------
-- Create date: 2012 - 03-19
--  Description:	Script to Insert value in archive_data_policy & Archive_data_policy_detail table for mv90_data_mins
-- ===============================================================================================================
DECLARE @ident_archive_data_policy INT 

IF NOT EXISTS(SELECT 1 FROM archive_data_policy WHERE archive_type_value_id  = 2154 AND main_table_name = 'mv90_data_mins')
BEGIN
	--SET IDENTITY_INSERT archive_data_policy ON	
	INSERT INTO archive_data_policy (archive_type_value_id, main_table_name, staging_table_name, sequence, where_field, archive_frequency, existence_check_fields)
	SELECT 2154, 'mv90_data_mins', 'stage_mv90_data_mins', 1, 'prod_date', 'd', 'meter_data_id, prod_date'	
	PRINT 'Inserted Archive_data_policy  2154 - mv90_data_mins.'
	--SET IDENTITY_INSERT archive_data_policy OFF
END
ELSE
BEGIN
	PRINT 'Policy ID  2154 - mv90_data_mins already EXISTS.'
END


BEGIN
SELECT @ident_archive_data_policy =  IDENT_CURRENT('archive_data_policy')	
END
 PRINT @ident_archive_data_policy
 

IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 1)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'mv90_data_mins', 0, 1, NULL, '*', 1
	PRINT 'Inserted Archive_data_policy_id   ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + '  with sequence 1  - mv90_data_mins.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF
END
ELSE
BEGIN
	PRINT 'Policy ID  ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 1  - mv90_data_mins already EXISTS.'
END
--


IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 2)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'mv90_data_mins_arch1', 1, 2, 'FARRMSARCH.TRMTracker', '*', 30
	PRINT 'Inserted Archive_data_policy_id ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 2  - mv90_data_mins_arch1.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF

END
ELSE
BEGIN
	PRINT 'Policy ID  ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 2  - mv90_data_mins-arch1 already EXISTS.'
END
--
IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 3)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'mv90_data_mins_arch2', 1, 3, 'FARRMSARCH.TRMTracker', '*', -1
	PRINT 'Inserted Archive_data_policy_id ' + CAST(@ident_archive_data_policy AS VARCHAR(10))+ ' with sequence 3  - mv90_data_mins_arch2.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF
END
ELSE
BEGIN
	PRINT 'Policy ID ' + CAST(@ident_archive_data_policy AS VARCHAR(10))+ ' with sequence 3  - mv90_data_mins-arch2 already EXISTS.'
END
--------------------------------------Inserting ADP & ADPD for mv90_data_hour--------------------
-- Create date: 2012 - 03-19
--  Description:	Script to Insert value in archive_data_policy & Archive_data_policy_detail table for mv90_data_hour
-- ===============================================================================================================
GO
DECLARE @ident_archive_data_policy INT 

IF NOT EXISTS(SELECT 1 FROM archive_data_policy WHERE archive_type_value_id  = 2154 AND main_table_name = 'mv90_data_hour')
BEGIN
	--SET IDENTITY_INSERT archive_data_policy ON	
	INSERT INTO archive_data_policy (archive_type_value_id, main_table_name, staging_table_name, sequence, where_field, archive_frequency, existence_check_fields)
	SELECT 2154, 'mv90_data_hour', 'stage_mv90_data_hour', 2, 'prod_date', 'd', 'meter_data_id, prod_date'	
	PRINT 'Inserted Archive_data_policy  2154 - mv90_data_hour.'
	--SET IDENTITY_INSERT archive_data_policy OFF
END
ELSE
BEGIN
	PRINT 'Policy ID  2154 - mv90_data_hour already EXISTS.'
END

BEGIN
SELECT @ident_archive_data_policy =  IDENT_CURRENT('archive_data_policy')	
END


IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 1)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'mv90_data_hour', 0, 1, NULL, '*', 1
	PRINT 'Inserted Archive_data_policy_id ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 1  - mv90_data_hour.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF

END
ELSE
BEGIN
	PRINT 'Policy ID  ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + '  with sequence 1  - mv90_data_hour already EXISTS.'
END
--


IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 2)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'mv90_data_hour_arch1', 1, 2, 'FARRMSARCH.TRMTracker', '*', 30
	PRINT 'Inserted Archive_data_policy_id  ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 2  - mv90_data_hour_arch1.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF

END
ELSE
BEGIN
	PRINT 'Policy ID  ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + '  with sequence 2  - mv90_data_hour_arch1 already EXISTS.'
END
--
IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 3)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'mv90_data_hour_arch2', 1, 3, 'FARRMSARCH.TRMTracker', '*', -1
	PRINT 'Inserted Archive_data_policy_id   ' + CAST( @ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 3  - mv90_data_hour_arch2.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF

END
ELSE
BEGIN
	PRINT 'Policy ID ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + '  with sequence 3  - mv90_data_hour_arch2 already EXISTS.'
END
-------------------------------------inserting value for mv90_data-------------
GO
DECLARE @ident_archive_data_policy INT 

IF NOT EXISTS(SELECT 1 FROM archive_data_policy WHERE archive_type_value_id  = 2154 AND main_table_name = 'mv90_data')
BEGIN
	--SET IDENTITY_INSERT archive_data_policy ON	
	INSERT INTO archive_data_policy (archive_type_value_id, main_table_name, staging_table_name, sequence, where_field, archive_frequency, existence_check_fields)
	SELECT 2154, 'mv90_data', 'stage_mv90_data', 3, 'prod_date', 'd', 'meter_id, gen_date, from_date, to_date, channel'	
	PRINT 'Inserted Archive_data_policy  2154 - mv90_data.'
	--SET IDENTITY_INSERT archive_data_policy OFF
END
ELSE
BEGIN
	PRINT 'Policy ID  2154 - mv90_data already EXISTS.'
END 

BEGIN
SELECT @ident_archive_data_policy =  IDENT_CURRENT('archive_data_policy')	
END

IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 1)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'mv90_data', 0, 1, NULL, '*', 1
	PRINT 'Inserted Archive_data_policy_id   ' + CAST(@ident_archive_data_policy AS VARCHAR(10))+ ' with sequence 1  - mv90_data.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF

END
ELSE
BEGIN
	PRINT 'Policy ID ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 1  - mv90_data already EXISTS.'
END
--


IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 2)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'mv90_data_arch1', 1, 2, 'FARRMSARCH.TRMTracker', '*', 30
 	PRINT 'Inserted Archive_data_policy_id '+ CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 2  - mv90_data_arch1.'
 	--SET IDENTITY_INSERT archive_data_policy_detail OFF

END
ELSE
BEGIN
	PRINT 'Policy ID  ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + ' with sequence 2  - mv90_data_arch1 already EXISTS.'
END
--
IF NOT EXISTS(SELECT 1 FROM archive_data_policy_detail WHERE archive_data_policy_id  = @ident_archive_data_policy AND sequence = 3)
BEGIN
	--SET IDENTITY_INSERT archive_data_policy_detail ON
	INSERT INTO archive_data_policy_detail (archive_data_policy_id, table_name, is_arch_table, sequence, archive_db, field_list, retention_period)
	SELECT @ident_archive_data_policy, 'mv90_data_arch2', 1, 3, 'FARRMSARCH.TRMTracker', '*', -1
	PRINT 'Inserted Archive_data_policy_id ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) +  ' with sequence 3  - mv90_data_arch2.'
	--SET IDENTITY_INSERT archive_data_policy_detail OFF

END
ELSE
BEGIN
	PRINT 'Policy ID  ' + CAST(@ident_archive_data_policy AS VARCHAR(10)) + '  with sequence 3  - mv90_data_hour_arch2 already EXISTS.'
END
--
