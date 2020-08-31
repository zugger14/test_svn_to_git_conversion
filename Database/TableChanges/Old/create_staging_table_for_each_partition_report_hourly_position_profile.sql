/*
* Test code to create staging table for deal_detail_hour data loading from SSIS
*/
--drop view vwHourly_position_profile_AllFilter_stage_140
--drop view vwHourly_position_profile_AllFilter_stage_006


DECLARE @partition_no SMALLINT
DECLARE @partition_count SMALLINT
DECLARE @sql VARCHAR(5000)
DECLARE @staging_table_name VARCHAR(150),@staging_view_name  VARCHAR(150)
DECLARE @file_group VARCHAR(50)

SET @partition_count = 150
SET @partition_no = 1

WHILE @partition_no <= @partition_count
BEGIN

	SET @staging_table_name = 'stage_report_hourly_position_profile_' + RIGHT('000' + CAST(@partition_no AS VARCHAR(5)), 3)
	SET @staging_view_name = 'vwHourly_position_profile_AllFilter_stage_' + RIGHT('000' + CAST(@partition_no AS VARCHAR(5)), 3)
	SET @file_group = 'FG_Farrms_' + RIGHT('000' + CAST(@partition_no AS VARCHAR(5)), 3)
	
	SET @sql = '
		IF OBJECT_ID(''' + @staging_view_name + ''') IS NOT NULL 
			DROP view ' + @staging_view_name  
	
	PRINT @sql
	EXEC (@sql)
	

	SET @sql = '
		IF OBJECT_ID(''' + @staging_table_name + ''') IS NOT NULL 
			DROP TABLE ' + @staging_table_name 
			
	PRINT @sql
	EXEC (@sql)			
			

	SET @sql = '
	CREATE TABLE ' + @staging_table_name + ' (
	[partition_value] [int] NOT NULL,
	[source_deal_header_id] [int] NULL,
	[curve_id] [int] NULL,
	[location_id] [int] NULL,
	[term_start] [datetime] NULL,
	[deal_date] [datetime] NULL,
	[commodity_id] [int] NULL,
	[counterparty_id] [int] NULL,
	[fas_book_id] [int] NULL,
	[source_system_book_id1] [int] NULL,
	[source_system_book_id2] [int] NULL,
	[source_system_book_id3] [int] NULL,
	[source_system_book_id4] [int] NULL,
	[deal_volume_uom_id] [int] NULL,
	[physical_financial_flag] [varchar](1) NULL,
	[hr1] [float] NULL,
	[hr2] [float] NULL,
	[hr3] [float] NULL,
	[hr4] [float] NULL,
	[hr5] [float] NULL,
	[hr6] [float] NULL,
	[hr7] [float] NULL,
	[hr8] [float] NULL,
	[hr9] [float] NULL,
	[hr10] [float] NULL,
	[hr11] [float] NULL,
	[hr12] [float] NULL,
	[hr13] [float] NULL,
	[hr14] [float] NULL,
	[hr15] [float] NULL,
	[hr16] [float] NULL,
	[hr17] [float] NULL,
	[hr18] [float] NULL,
	[hr19] [float] NULL,
	[hr20] [float] NULL,
	[hr21] [float] NULL,
	[hr22] [float] NULL,
	[hr23] [float] NULL,
	[hr24] [float] NULL,
	[hr25] [float] NULL,
	[create_ts] [datetime] NULL,
	[create_usr] [varchar](30) NULL,expiration_date datetime null
				) ON [' + @file_group + ']
				
			'
	
	PRINT @sql
	EXEC (@sql)
	
	SET @sql = '
		CREATE VIEW [dbo].[vwHourly_position_profile_AllFilter_stage_'+RIGHT('000' + CAST(@partition_no AS VARCHAR(5)), 3) +'] WITH schemabinding 	AS
		SELECT PARTITION_value, location_id,COUNT_BIG(*) cnt,curve_id, term_start,deal_date,
		commodity_id,counterparty_id,fas_book_id,source_system_book_id1,source_system_book_id2,
		source_system_book_id3,	source_system_book_id4,deal_volume_uom_id,physical_financial_flag,
		SUM(ISNULL(HR1,0)) HR1,SUM(ISNULL(HR2,0)) HR2,SUM(ISNULL(HR3,0)) HR3,SUM(ISNULL(HR4,0)) HR4,
		SUM(ISNULL(HR5,0)) HR5,SUM(ISNULL(HR6,0)) HR6,SUM(ISNULL(HR7,0)) HR7,SUM(ISNULL(HR8,0)) HR8,
		SUM(ISNULL(HR9,0)) HR9,SUM(ISNULL(HR10,0)) HR10,SUM(ISNULL(HR11,0)) HR11,SUM(ISNULL(HR12,0)) HR12,
		SUM(ISNULL(HR13,0)) HR13,SUM(ISNULL(HR14,0)) HR14,SUM(ISNULL(HR15,0)) HR15,SUM(ISNULL(HR16,0)) HR16,
		SUM(ISNULL(HR17,0)) HR17,SUM(ISNULL(HR18,0)) HR18,SUM(ISNULL(HR19,0)) HR19,SUM(ISNULL(HR20,0)) HR20,
		SUM(ISNULL(HR21,0)) HR21,SUM(ISNULL(HR22,0)) HR22,SUM(ISNULL(HR23,0)) HR23,SUM(ISNULL(HR24,0)) HR24,SUM(ISNULL(HR25,0)) HR25,expiration_date
		FROM dbo.stage_report_hourly_position_profile_'+ RIGHT('000' + CAST(@partition_no AS VARCHAR(5)), 3) +'
		GROUP BY PARTITION_value,location_id,curve_id,term_start,deal_date,commodity_id,counterparty_id,fas_book_id,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4
		,deal_volume_uom_id,physical_financial_flag,expiration_date'
	
	PRINT @sql
	EXEC (@sql)

	SET @partition_no = @partition_no + 1	
END
