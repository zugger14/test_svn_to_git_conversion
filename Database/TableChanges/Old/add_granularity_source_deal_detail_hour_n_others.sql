
IF COL_LENGTH('source_deal_detail_hour', 'granularity') IS NULL
BEGIN

	IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[source_deal_detail_hour]') AND name = N'ucindx_source_deal_detail_hour')
	DROP INDEX [ucindx_source_deal_detail_hour] ON [dbo].[source_deal_detail_hour] WITH ( ONLINE = OFF )


	alter table source_deal_detail_hour alter column hr varchar(5)
	alter table source_deal_detail_hour add granularity int

	alter table report_hourly_position_deal add period tinyint
	alter table report_hourly_position_deal add granularity int

	alter table report_hourly_position_fixed add period tinyint
	alter table report_hourly_position_fixed add granularity int

	alter table report_hourly_position_profile add period tinyint
	alter table report_hourly_position_profile add granularity int
	
	alter table delta_report_hourly_position add period tinyint
	alter table delta_report_hourly_position add granularity int


	update source_deal_detail_hour set hr =right('0'+hr,2)+':00'

	update source_deal_header_template set hourly_position_breakdown='9' where hourly_position_breakdown='y'
	update source_deal_header_template set hourly_position_breakdown=null where hourly_position_breakdown='n'

	Alter table  source_deal_header_template alter column hourly_position_breakdown int

	/****** Object:  Index [ucindx_source_deal_detail_hour]    Script Date: 08/07/2012 07:25:27 ******/
	CREATE UNIQUE CLUSTERED INDEX [ucindx_source_deal_detail_hour] ON [dbo].[source_deal_detail_hour] 
	(
		[source_deal_detail_id] ASC,
		[term_date] ASC,
		[hr] ASC,
		[is_dst] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
	


	
	PRINT 'Columns added.'
END
ELSE
BEGIN
	PRINT 'Column source_deal_detail_hour.granularity already exists.'
END
GO




/****** Object:  Index [indx_report_hourly_position_deal_deal_id]    Script Date: 08/07/2012 16:00:35 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[report_hourly_position_deal]') AND name = N'indx_report_hourly_position_deal_deal_id')
DROP INDEX [indx_report_hourly_position_deal_deal_id] ON [dbo].[report_hourly_position_deal] WITH ( ONLINE = OFF )
GO



/****** Object:  Index [indx_report_hourly_position_deal_deal_id]    Script Date: 08/07/2012 16:00:35 ******/
CREATE UNIQUE NONCLUSTERED INDEX [indx_report_hourly_position_deal_deal_id] ON [dbo].[report_hourly_position_deal] 
(
	[source_deal_header_id] ASC,
	[curve_id] ASC,
	[location_id] ASC,
	[term_start] ASC,
	[period] asc
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO



/****** Object:  Index [indx_report_hourly_position_profile_deal_id]    Script Date: 08/07/2012 16:02:34 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[report_hourly_position_profile]') AND name = N'indx_report_hourly_position_profile_deal_id')
DROP INDEX [indx_report_hourly_position_profile_deal_id] ON [dbo].[report_hourly_position_profile] WITH ( ONLINE = OFF )
GO

/****** Object:  Index [indx_report_hourly_position_profile_deal_id]    Script Date: 08/07/2012 16:02:34 ******/
CREATE UNIQUE NONCLUSTERED INDEX [indx_report_hourly_position_profile_deal_id] ON [dbo].[report_hourly_position_profile] 
(
	[partition_value] ASC,
	[source_deal_header_id] ASC,
	[curve_id] ASC,
	[location_id] ASC,
	[term_start] ASC,
	period asc
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)
GO

update source_deal_header_template set hourly_position_breakdown=982 where hourly_position_breakdown=9

update delta_report_hourly_position set granularity=982 where granularity is null
update delta_report_hourly_position set period=0 where period is null

update source_deal_detail_hour set granularity=982 where granularity is null

update report_hourly_position_deal set granularity=982 where granularity is null
update report_hourly_position_deal set period=0 where period is null

update report_hourly_position_profile set granularity=982 where granularity is null
update report_hourly_position_profile set period=0 where period is null

update report_hourly_position_fixed set granularity=982 where granularity is null
update report_hourly_position_fixed set period=0 where period is null