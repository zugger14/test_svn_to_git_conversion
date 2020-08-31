IF EXISTS(SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_price_simulation_delta_whatif]') AND TYPE IN (N'U'))
BEGIN
    PRINT 'Table Already Exists'
END
ELSE
BEGIN
	CREATE TABLE [dbo].[source_price_simulation_delta_whatif](
		[criteria_id] [int] NOT NULL,
		[run_date] [date] NOT NULL,
		[source_curve_def_id] [int] NOT NULL,
		[as_of_date] [date] NOT NULL,
		[Assessment_curve_type_value_id] [int] NOT NULL,
		[curve_source_value_id] [int] NOT NULL,
		[maturity_date] [datetime] NOT NULL,
		[is_dst] [tinyint] NOT NULL,
		[curve_value_main] [float] NOT NULL,
		[curve_value_sim] [float] NOT NULL,
		[curve_value_avg] [float] NOT NULL,
		[curve_value_delta] [float] NOT NULL,
		[curve_value_avg_delta] [float] NOT NULL,
		[create_user] [varchar](50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts] [datetime] NULL DEFAULT GETDATE()
	)
END