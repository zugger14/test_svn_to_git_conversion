
exec ('
IF OBJECT_ID(''[dbo].[delta_report_hourly_position_breakdown_old1000]'') IS  NULL
BEGIN
	EXEC sp_rename ''delta_report_hourly_position_breakdown'', ''delta_report_hourly_position_breakdown_old1000''
END
IF OBJECT_ID(''[dbo].[delta_report_hourly_position_old1000]'') IS  NULL
BEGIN
	EXEC sp_rename ''delta_report_hourly_position'', ''delta_report_hourly_position_old1000''
END
IF OBJECT_ID(''[dbo].[delta_report_hourly_position_financial_old1000]'') IS  NULL
BEGIN
	EXEC sp_rename ''delta_report_hourly_position_financial'', ''delta_report_hourly_position_financial_old1000''
END
IF OBJECT_ID(''[dbo].[report_hourly_position_deal_old1000]'') IS  NULL
BEGIN
	EXEC sp_rename ''report_hourly_position_deal'', ''report_hourly_position_deal_old1000''
END
IF OBJECT_ID(''[dbo].[report_hourly_position_profile_old1000]'') IS  NULL
BEGIN
	EXEC sp_rename ''report_hourly_position_profile'', ''report_hourly_position_profile_old1000''
END
IF OBJECT_ID(''[dbo].[report_hourly_position_fixed_old1000]'') IS  NULL
BEGIN
	EXEC sp_rename ''report_hourly_position_fixed'', ''report_hourly_position_fixed_old1000''
END
IF OBJECT_ID(''[dbo].[report_hourly_position_financial_old1000]'') IS  NULL
BEGIN
	EXEC sp_rename ''report_hourly_position_financial'', ''report_hourly_position_financial_old1000''
END
IF OBJECT_ID(''[dbo].[report_hourly_position_breakdown_old1000]'') IS  NULL
BEGIN
	EXEC sp_rename ''report_hourly_position_breakdown'', ''report_hourly_position_breakdown_old1000''
END
')


