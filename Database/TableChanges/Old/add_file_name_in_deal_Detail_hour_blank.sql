--add file_name in deal_detail_hour to store source file name
IF COL_LENGTH('deal_detail_hour_blank', 'file_name') IS NULL 
	ALTER TABLE deal_detail_hour_blank ADD FILE_NAME VARCHAR(200) NULL
