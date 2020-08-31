IF not EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[delta_report_hourly_position_breakdown]') AND name = N'indx_delta_report_hourly_position_breakdown')
	create index indx_delta_report_hourly_position_breakdown on dbo.delta_report_hourly_position_breakdown (as_of_date,source_deal_header_id,curve_id,term_start)

go
IF not EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[delta_report_hourly_position_financial]') AND name = N'indx_delta_report_hourly_position_financial')
	create index indx_delta_report_hourly_position_financial on dbo.delta_report_hourly_position_financial (as_of_date,source_deal_header_id,curve_id,location_id,term_start)

go
IF not EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[hour_block_term]') AND name = N'indx_hour_block_term_11')
	CREATE NONCLUSTERED INDEX [indx_hour_block_term_11] ON [dbo].[hour_block_term] ([block_define_id],[block_type],[term_date]) INCLUDE ([volume_mult])