IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[source_price_simulation_delta]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[source_price_simulation_delta](
		[run_date] [date] NULL,
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
		[create_user] [varchar](50) NULL,
		[create_ts] [datetime] NULL
	) ON [PRIMARY]

END
ELSE
BEGIN
	PRINT 'Table Already Exist'	
END

