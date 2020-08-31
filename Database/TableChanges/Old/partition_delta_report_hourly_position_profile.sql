

if OBJECT_ID('delta_report_hourly_position_profile') is not null
drop table  [dbo].[delta_report_hourly_position_profile]

GO
IF   CHARINDEX('Microsoft SQL Server 2005',@@VERSION,1)<1
begin
	CREATE TABLE [dbo].[delta_report_hourly_position_profile](
		[as_of_date] [datetime] NULL,
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
		[create_usr] [varchar](30) NULL,
		[delta_type] [int] NULL
	) ON ps_farrms([partition_value])
	
	ALTER TABLE [dbo].[delta_report_hourly_position_profile] SET (LOCK_ESCALATION = AUTO)

end
ELSE
BEGIN
	CREATE TABLE [dbo].[delta_report_hourly_position_profile](
		[as_of_date] [datetime] NULL,
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
		[create_usr] [varchar](30) NULL,
		[delta_type] [int] NULL
	) 
END	
GO



