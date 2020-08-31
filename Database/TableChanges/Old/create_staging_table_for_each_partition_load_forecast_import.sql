/*
* Test code to create staging table for deal_detail_hour data loading from SSIS
*/

DECLARE @partition_no SMALLINT
DECLARE @partition_count SMALLINT
DECLARE @sql VARCHAR(5000)
DECLARE @staging_table_name VARCHAR(150)
DECLARE @file_group VARCHAR(50)

SET @partition_count = 150
SET @partition_no = 1

WHILE @partition_no <= @partition_count
BEGIN

	SET @staging_table_name = 'stage_deal_detail_hour_' + RIGHT('000' + CAST(@partition_no AS VARCHAR(5)), 3)
	SET @file_group = 'FG_Farrms_' + RIGHT('000' + CAST(@partition_no AS VARCHAR(5)), 3)
	
	SET @sql = '
				IF OBJECT_ID(''' + @staging_table_name + ''') IS NOT NULL 
					DROP TABLE ' + @staging_table_name + '
				
				CREATE TABLE ' + @staging_table_name + ' (
					term_date DATETIME NOT NULL,
					profile_id INT NULL,
					Hr1 FLOAT NULL,
					Hr2 FLOAT NULL,
					Hr3 FLOAT NULL,
					Hr4 FLOAT NULL,
					Hr5 FLOAT NULL,
					Hr6 FLOAT NULL,
					Hr7 FLOAT NULL,
					Hr8 FLOAT NULL,
					Hr9 FLOAT NULL,
					Hr10 FLOAT NULL,
					Hr11 FLOAT NULL,
					Hr12 FLOAT NULL,
					Hr13 FLOAT NULL,
					Hr14 FLOAT NULL,
					Hr15 FLOAT NULL,
					Hr16 FLOAT NULL,
					Hr17 FLOAT NULL,
					Hr18 FLOAT NULL,
					Hr19 FLOAT NULL,
					Hr20 FLOAT NULL,
					Hr21 FLOAT NULL,
					Hr22 FLOAT NULL,
					Hr23 FLOAT NULL,
					Hr24 FLOAT NULL,
					Hr25 FLOAT NULL,
					partition_value INT NULL,
					file_name VARCHAR(200) NULL
				) ON ' + @file_group + '				
			'
	
	PRINT @sql
	EXEC (@sql)
	SET @partition_no = @partition_no + 1	
END
