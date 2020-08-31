
IF object_id('delta_report_hourly_position') IS  NULL
BEGIN 
	CREATE TABLE [dbo].[delta_report_hourly_position](
		[as_of_date] [datetime] NULL,
		[partition_value] [int]  NULL,
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
		[hr1] [numeric](38, 20) NULL,
		[hr2] [numeric](38, 20) NULL,
		[hr3] [numeric](38, 20) NULL,
		[hr4] [numeric](38, 20) NULL,
		[hr5] [numeric](38, 20) NULL,
		[hr6] [numeric](38, 20) NULL,
		[hr7] [numeric](38, 20) NULL,
		[hr8] [numeric](38, 20) NULL,
		[hr9] [numeric](38, 20) NULL,
		[hr10] [numeric](38, 20) NULL,
		[hr11] [numeric](38, 20) NULL,
		[hr12] [numeric](38, 20) NULL,
		[hr13] [numeric](38, 20) NULL,
		[hr14] [numeric](38, 20) NULL,
		[hr15] [numeric](38, 20) NULL,
		[hr16] [numeric](38, 20) NULL,
		[hr17] [numeric](38, 20) NULL,
		[hr18] [numeric](38, 20) NULL,
		[hr19] [numeric](38, 20) NULL,
		[hr20] [numeric](38, 20) NULL,
		[hr21] [numeric](38, 20) NULL,
		[hr22] [numeric](38, 20) NULL,
		[hr23] [numeric](38, 20) NULL,
		[hr24] [numeric](38, 20) NULL,
		[hr25] [numeric](38, 20) NULL,
		[create_ts] [datetime] NULL,
		[create_usr] [varchar](30) NULL,
		[delta_type] [int] NULL,
		[expiration_date] [datetime] NULL,
		[deal_status_id] [int] NULL
	)


	ALTER TABLE [dbo].[delta_report_hourly_position_profile] SET (LOCK_ESCALATION = AUTO)


	IF object_id('delta_report_hourly_position') IS NOT NULL
	BEGIN 
		INSERT INTO delta_report_hourly_position
		SELECT * 
		FROM delta_report_hourly_position_profile
		
		DROP TABLE dbo.delta_report_hourly_position_profile

	END 

	IF object_id('delta_report_hourly_position_deal') IS NOT NULL
	BEGIN 
		INSERT INTO delta_report_hourly_position
		SELECT 
			as_of_date,
			-1 PARTITION_value,
			source_deal_header_id,
			curve_id,
			location_id,
			term_start,
			deal_date,
			commodity_id,
			counterparty_id,
			fas_book_id,
			source_system_book_id1,
			source_system_book_id2,
			source_system_book_id3,
			source_system_book_id4,
			deal_volume_uom_id,
			physical_financial_flag,
			hr1,
			hr2,
			hr3,
			hr4,
			hr5,
			hr6,
			hr7,
			hr8,
			hr9,
			hr10,
			hr11,
			hr12,
			hr13,
			hr14,
			hr15,
			hr16,
			hr17,
			hr18,
			hr19,
			hr20,
			hr21,
			hr22,
			hr23,
			hr24,
			hr25,
			create_ts,
			create_usr,
			delta_type,
			expiration_date,
			deal_status_id
		FROM delta_report_hourly_position_deal
		
		DROP TABLE dbo.delta_report_hourly_position_deal

	END 

	CREATE INDEX indx_delta_report_hourly_position_id ON   dbo.delta_report_hourly_position (source_deal_header_id, curve_id, location_id, term_start)
	CREATE INDEX indx_delta_report_hourly_position_as_of_date ON   dbo.delta_report_hourly_position (as_of_date)
	CREATE INDEX indx_delta_report_hourly_position_delta_type ON   dbo.delta_report_hourly_position (delta_type)
	
END 