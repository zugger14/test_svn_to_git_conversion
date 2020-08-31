/*
* Setup archive data for Load Forecast Data (deal_detail_hour).
* Step 2: Setup static data and policy tables.
*/

--add static data
--2176 - deal_detail_hour
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 2176)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
    VALUES (2176, 2175, 'deal_detail_hour', 'Load Forecast Data', 'farrms_admin', GETDATE()) 
      
	PRINT 'Inserted static data value 2176 - deal_detail_hour'
END
ELSE
BEGIN
	PRINT 'Static data value 2176 - deal_detail_hour already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

--define archive policy
IF NOT EXISTS (SELECT 1 FROM process_table_archive_policy ptap WHERE ptap.tbl_name = 'deal_detail_hour' AND ISNULL(ptap.prefix_location_table, '') = '')
BEGIN
	INSERT INTO process_table_archive_policy(tbl_name, prefix_location_table, upto, dbase_name, fieldlist, wherefield, frequency_type) 
	VALUES('deal_detail_hour', '', 1, NULL, '*', 'term_date', 'd')
END
ELSE
BEGIN
	UPDATE process_table_archive_policy SET upto = 1, frequency_type = 'd', dbase_name = NULL, fieldlist = '*', wherefield = 'term_date'
	WHERE tbl_name = 'deal_detail_hour' AND ISNULL(prefix_location_table, '') = ''
END

IF NOT EXISTS (SELECT 1 FROM process_table_archive_policy ptap WHERE ptap.tbl_name = 'deal_detail_hour' AND ptap.prefix_location_table = '_arch1')
BEGIN
	INSERT INTO process_table_archive_policy(tbl_name, prefix_location_table, upto, dbase_name, fieldlist, wherefield, frequency_type) 
	VALUES('deal_detail_hour', '_arch1', 30, 'FarrmsData.adiha_process', '*', 'term_date', 'd')
END
ELSE
BEGIN
	UPDATE process_table_archive_policy SET upto = 30, frequency_type = 'd', dbase_name = 'FarrmsData.adiha_process', fieldlist = '*', wherefield = 'term_date'
	WHERE tbl_name = 'deal_detail_hour' AND prefix_location_table = '_arch1'
END

IF NOT EXISTS (SELECT 1 FROM process_table_archive_policy ptap WHERE ptap.tbl_name = 'deal_detail_hour' AND ptap.prefix_location_table = '_arch2')
BEGIN
	INSERT INTO process_table_archive_policy(tbl_name, prefix_location_table, upto, dbase_name, fieldlist, wherefield, frequency_type) 
	VALUES('deal_detail_hour', '_arch2', -1, 'FarrmsData.adiha_process', '*', 'term_date', 'd')
END
ELSE
BEGIN
	UPDATE process_table_archive_policy SET upto = -1, frequency_type = 'd', dbase_name = 'FarrmsData.adiha_process', fieldlist = '*', wherefield = 'term_date'
	WHERE tbl_name = 'deal_detail_hour' AND prefix_location_table = '_arch2'
END

GO
