IF EXISTS(SELECT 1 FROM sys.indexes WHERE [name]='indx_report_hourly_position_profile_blank')
	DROP INDEX  indx_report_hourly_position_profile_blank ON  [dbo].[report_hourly_position_profile_blank] 
go
/****** Object:  Index [indx_report_hourly_position_profile]    Script Date: 05/10/2011 19:22:18 ******/
CREATE CLUSTERED INDEX [indx_report_hourly_position_profile_blank] ON [dbo].[report_hourly_position_profile_blank] 
(
	[partition_value] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)
GO


