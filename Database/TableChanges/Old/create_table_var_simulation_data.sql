IF OBJECT_ID('[var_simulation_data]') IS NOT NULL
BEGIN
	PRINT 'Table Already Exists'
END
ELSE
BEGIN	
	CREATE TABLE [dbo].[var_simulation_data](
		[run_date] [datetime] NOT NULL,
		[source_deal_header_id] [int] NOT NULL,
		[term_start] [datetime] NOT NULL,
		[term_end] [datetime] NOT NULL,
		[Leg] [int] NOT NULL,
		[pnl_as_of_date] [datetime] NOT NULL,
		[und_pnl] [float] NOT NULL,
		[und_intrinsic_pnl] [float] NOT NULL,
		[und_extrinsic_pnl] [float] NOT NULL,
		[dis_pnl] [float] NOT NULL,
		[dis_intrinsic_pnl] [float] NOT NULL,
		[dis_extrinisic_pnl] [float] NOT NULL,
		[pnl_source_value_id] [int] NOT NULL,
		[pnl_currency_id] [int] NULL,
		[pnl_conversion_factor] [float] NOT NULL,
		[pnl_adjustment_value] [float] NULL,
		[deal_volume] [float] NULL,
		[create_user] [varchar](50) NULL,
		[create_ts] [datetime] NULL,
		[update_user] [varchar](50) NULL,
		[update_ts] [datetime] NULL,
		[und_pnl_set] [float] NULL,
		[market_value] [float] NULL,
		[contract_value] [float] NULL,
		[dis_market_value] [float] NULL,
		[dis_contract_value] [float] NULL
	)

	ALTER TABLE [dbo].[var_simulation_data]  WITH NOCHECK ADD  CONSTRAINT [FK_var_simulation_data_source_currency] FOREIGN KEY([pnl_currency_id])
	REFERENCES [dbo].[source_currency] ([source_currency_id])
	
	ALTER TABLE [dbo].[var_simulation_data] CHECK CONSTRAINT [FK_var_simulation_data_source_currency]
	
	ALTER TABLE [dbo].[var_simulation_data]  WITH NOCHECK ADD  CONSTRAINT [FK_var_simulation_data_static_data_value] FOREIGN KEY([pnl_source_value_id])
	REFERENCES [dbo].[static_data_value] ([value_id])
	
	ALTER TABLE [dbo].[var_simulation_data] CHECK CONSTRAINT [FK_var_simulation_data_static_data_value]

END	

GO
