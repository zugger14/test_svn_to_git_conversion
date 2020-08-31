--Update archieve_type_id
IF EXISTS(	SELECT 1 
			FROM INFORMATION_SCHEMA.COLUMNS
			WHERE table_name = 'process_table_archive_policy'            
            AND column_name = 'archieve_type_id'
)
BEGIN
	UPDATE process_table_archive_policy SET archieve_type_id = 2150
	PRINT '''archieve_type_id'' updated successfully.'
END
ELSE 
	PRINT 'Column ''archieve_type_id'' doesnot exists in the table ''process_table_archive_policy''.'

--Update fieldlist for source_deal_pnl

IF EXISTS(	SELECT 1 
			FROM INFORMATION_SCHEMA.COLUMNS
			WHERE table_name = 'process_table_archive_policy'            
            AND column_name = 'fieldlist'
)
BEGIN
	UPDATE process_table_archive_policy 
	SET fieldlist = '[source_deal_header_id],[term_start],[term_end],[Leg],[pnl_as_of_date],[und_pnl],[und_intrinsic_pnl],[und_extrinsic_pnl]   ,[dis_pnl],[dis_intrinsic_pnl],[dis_extrinisic_pnl],[pnl_source_value_id],[pnl_currency_id],[pnl_conversion_factor]   ,[pnl_adjustment_value],[deal_volume],[create_user],[create_ts],[update_user],[update_ts],und_pnl_set, market_value,contract_value'
	WHERE tbl_name = 'source_deal_pnl' 
		AND prefix_location_table = ''

	UPDATE process_table_archive_policy 
	SET fieldlist = '[source_deal_header_id],[term_start],[term_end],[Leg],[pnl_as_of_date],[und_pnl],[und_intrinsic_pnl],[und_extrinsic_pnl]   ,[dis_pnl],[dis_intrinsic_pnl],[dis_extrinisic_pnl],[pnl_source_value_id],[pnl_currency_id],[pnl_conversion_factor]   ,[pnl_adjustment_value],[deal_volume],[create_user],[create_ts],[update_user],[update_ts],und_pnl_set, market_value,contract_value'
	WHERE tbl_name = 'source_deal_pnl' 
		AND prefix_location_table = '_arch1'

	PRINT '''fieldlist'' updated successfully.'
END
ELSE 
	PRINT 'Column ''fieldlist'' doesnot exists in the table ''process_table_archive_policy''.'

--Update wherefield
IF EXISTS(	SELECT 1 
			FROM INFORMATION_SCHEMA.COLUMNS
			WHERE table_name = 'process_table_archive_policy'            
            AND column_name = 'wherefield'
)
BEGIN
	UPDATE   process_table_archive_policy SET wherefield = 'as_of_date' WHERE tbl_name <> 'source_deal_pnl'
	UPDATE process_table_archive_policy SET wherefield = 'pnl_as_of_date' WHERE tbl_name = 'source_deal_pnl'
		
	PRINT '''wherefield'' updated successfully.'
END
ELSE 
	PRINT 'Column ''wherefield'' doesnot exists in the table ''process_table_archive_policy''.'

--Update upto
IF EXISTS(	SELECT 1 
			FROM INFORMATION_SCHEMA.COLUMNS
			WHERE table_name = 'process_table_archive_policy'            
            AND column_name = 'upto'
)
BEGIN
	UPDATE process_table_archive_policy SET upto = 1 WHERE prefix_location_table = '_arch1'
	UPDATE process_table_archive_policy SET upto = 0 WHERE prefix_location_table = ''

	PRINT '''upto'' updated successfully.'
END
ELSE 
	PRINT 'Column ''upto'' doesnot exists in the table ''process_table_archive_policy''.'


--Update frequency_type
IF EXISTS(	SELECT 1 
			FROM INFORMATION_SCHEMA.COLUMNS
			WHERE table_name = 'process_table_archive_policy'            
            AND column_name = 'frequency_type'
)
BEGIN
	UPDATE process_table_archive_policy 
	SET frequency_type = 'm' 
	WHERE tbl_name IN ( 'report_measurement_values', 
						'source_deal_pnl' 
					  )
	PRINT '''frequency_type'' updated successfully.'
END
ELSE 
	PRINT 'Column ''frequency_type'' doesnot exists in the table ''process_table_archive_policy''.'


--Update partition_status
IF EXISTS(	SELECT 1 
			FROM INFORMATION_SCHEMA.COLUMNS
			WHERE table_name = 'process_table_archive_policy'            
            AND column_name = 'partition_status'
)
BEGIN
	UPDATE process_table_archive_policy SET partition_status = 0
	
	PRINT '''partition_status'' updated successfully.'
END
ELSE 
	PRINT 'Column ''partition_status'' doesnot exists in the table ''process_table_archive_policy''.'


--Update no_month_pnl
IF EXISTS(	SELECT 1 
			FROM INFORMATION_SCHEMA.COLUMNS
			WHERE table_name = 'run_measurement_param'            
            AND column_name = 'no_month_pnl'
)
BEGIN
	UPDATE run_measurement_param SET no_month_pnl = 0

	PRINT '''no_month_pnl'' updated successfully.'
END
ELSE 
	PRINT 'Column ''no_month_pnl'' doesnot exists in the table ''run_measurement_param''.'
