/*
* Setup archive data for Load Forecast Data (deal_detail_hour).
* Step 2: Setup static data and policy tables.
*/

--add static data
--2176 - source_price_curve
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 2175)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
    VALUES (2175, 2175, 'source_price_curve', 'Source Price Curve', 'farrms_admin', GETDATE()) 
      
	PRINT 'Inserted static data value 2175 - source_price_curve'
END
ELSE
BEGIN
	PRINT 'Static data value 2175 - source_price_curve already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

--define archive policy
IF NOT EXISTS (SELECT 1 FROM process_table_archive_policy ptap WHERE ptap.tbl_name = 'source_price_curve' AND ISNULL(ptap.prefix_location_table, '') = '')
BEGIN
	INSERT INTO process_table_archive_policy(tbl_name, prefix_location_table, upto, dbase_name, fieldlist, wherefield, frequency_type) 
	VALUES('source_price_curve', '', 1, NULL, '*', 'as_of_date', 'd')
END
ELSE
BEGIN
	UPDATE process_table_archive_policy SET upto = 1, frequency_type = 'd', dbase_name = NULL, fieldlist = '*', wherefield = 'as_of_date'
	WHERE tbl_name = 'source_price_curve' AND ISNULL(prefix_location_table, '') = ''
END

IF NOT EXISTS (SELECT 1 FROM process_table_archive_policy ptap WHERE ptap.tbl_name = 'source_price_curve' AND ptap.prefix_location_table = '_arch1')
BEGIN
	INSERT INTO process_table_archive_policy(tbl_name, prefix_location_table, upto, dbase_name, fieldlist, wherefield, frequency_type) 
	VALUES('source_price_curve', '_arch1', 90, 'FarrmsData.adiha_process', '*', 'as_of_date', 'd')
END
ELSE
BEGIN
	UPDATE process_table_archive_policy SET upto = 90, frequency_type = 'd', dbase_name = 'FarrmsData.adiha_process', fieldlist = '*', wherefield = 'as_of_date'
	WHERE tbl_name = 'source_price_curve' AND prefix_location_table = '_arch1'
END

IF NOT EXISTS (SELECT 1 FROM process_table_archive_policy ptap WHERE ptap.tbl_name = 'source_price_curve' AND ptap.prefix_location_table = '_arch2')
BEGIN
	INSERT INTO process_table_archive_policy(tbl_name, prefix_location_table, upto, dbase_name, fieldlist, wherefield, frequency_type) 
	VALUES('source_price_curve', '_arch2', -1, 'FarrmsData.adiha_process', '*', 'as_of_date', 'd')
END
ELSE
BEGIN
	UPDATE process_table_archive_policy SET upto = -1, frequency_type = 'd', dbase_name = 'FarrmsData.adiha_process', fieldlist = '*', wherefield = 'as_of_date'
	WHERE tbl_name = 'source_price_curve' AND prefix_location_table = '_arch2'
END