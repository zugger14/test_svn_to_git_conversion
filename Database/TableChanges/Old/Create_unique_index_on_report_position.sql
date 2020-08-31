

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[report_hourly_position_breakdown]') AND name = N'unique_indx_report_hourly_position_breakdown')
DROP INDEX unique_indx_report_hourly_position_breakdown ON [dbo].[report_hourly_position_breakdown] WITH ( ONLINE = OFF )
GO

/****** Object:  Index [indx_report_hourly_position_breakdown_term]    Script Date: 06/30/2011 12:20:59 ******/
CREATE unique NONCLUSTERED INDEX [unique_indx_report_hourly_position_breakdown] ON [dbo].[report_hourly_position_breakdown] 
(
	[source_deal_header_id],
	[curve_id],
	[term_start],
	[term_end]
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[report_hourly_position_breakdown]') AND name = N'indx_report_hourly_position_breakdown_term')
DROP INDEX indx_report_hourly_position_breakdown_term ON [dbo].[report_hourly_position_breakdown] WITH ( ONLINE = OFF )
GO


IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[report_hourly_position_breakdown]') AND name = N'indx_report_hourly_position_breakdown_curve')
DROP INDEX [indx_report_hourly_position_breakdown_curve] ON [dbo].[report_hourly_position_breakdown] WITH ( ONLINE = OFF )
GO

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[report_hourly_position_breakdown]') AND name = N'indx_report_hourly_position_breakdown_curve')
DROP INDEX [indx_report_hourly_position_breakdown_curve] ON [dbo].[report_hourly_position_breakdown] WITH ( ONLINE = OFF )
GO





IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[report_hourly_position_profile]') AND name = N'indx_report_hourly_position_profile_deal_id')
DROP INDEX [indx_report_hourly_position_profile_deal_id] ON [dbo].[report_hourly_position_profile] WITH ( ONLINE = OFF )
GO

/****** Object:  Index [indx_report_hourly_position_profile_deal_id]    Script Date: 06/30/2011 12:19:45 ******/
CREATE UNIQUE NONCLUSTERED INDEX [indx_report_hourly_position_profile_deal_id] ON [dbo].[report_hourly_position_profile] 
(
partition_value ASC,
[source_deal_header_id] ASC
,curve_id ASC
,location_id ASC
,term_start ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)
GO




IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[report_hourly_position_deal]') AND name = N'indx_report_hourly_position_deal_deal_id')
DROP INDEX [indx_report_hourly_position_deal_deal_id] ON [dbo].[report_hourly_position_deal] WITH ( ONLINE = OFF )
GO
/****** Object:  Index [indx_report_hourly_position_deal_deal_id]    Script Date: 06/30/2011 12:17:51 ******/
CREATE UNIQUE NONCLUSTERED INDEX [indx_report_hourly_position_deal_deal_id] ON [dbo].[report_hourly_position_deal] 
(
[source_deal_header_id] ASC
,curve_id ASC
,location_id ASC
,term_start ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
