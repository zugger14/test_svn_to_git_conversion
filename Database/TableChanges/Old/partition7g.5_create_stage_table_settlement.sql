

/****** Object:  Table [dbo].[source_deal_settlement]    Script Date: 06/18/2012 16:53:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[stage_source_deal_settlement]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[stage_source_deal_settlement](
	[as_of_date] [datetime] NULL,
	[settlement_date] [datetime] NULL,
	[payment_date] [datetime] NULL,
	[source_deal_header_id] [int] NULL,
	[term_start] [datetime] NULL,
	[term_end] [datetime] NULL,
	[volume] [float] NULL,
	[net_price] [float] NULL,
	[settlement_amount] [float] NULL,
	[settlement_currency_id] [int] NULL,
	[create_ts] [datetime] NULL,
	[create_user] [varchar](50) NULL,
	[volume_uom] [int] NULL,
	[fin_volume] [float] NULL,
	[fin_volume_uom] [int] NULL,
	[float_Price] [float] NULL,
	[deal_Price] [float] NULL,
	[price_currency] [int] NULL,
	[leg] [int] NULL,
	[market_value] [float] NULL,
	[contract_value] [float] NULL,
	[set_type] [char](1) NULL,
	[allocation_volume] [float] NULL
) ON  ps_source_settlement(as_of_date)

END 
ELSE 
BEGIN
    PRINT 'Table stage_source_deal_settlement EXISTS'
END	
GO
SET ANSI_PADDING OFF
GO


------- calc_formula_value 

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[stage_calc_formula_value]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[stage_calc_formula_value](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[invoice_line_item_id] [int] NULL,
	[seq_number] [int] NOT NULL,
	[prod_date] [datetime] NOT NULL,
	[value] [float] NULL,
	[contract_id] [int] NULL,
	[counterparty_id] [int] NULL,
	[formula_id] [int] NULL,
	[calc_id] [int] NULL,
	[hour] [int] NULL,
	[formula_str] [varchar](2000) NULL,
	[qtr] [int] NULL,
	[half] [int] NULL,
	[deal_type_id] [int] NULL,
	[generator_id] [int] NULL,
	[ems_generator_id] [int] NULL,
	[deal_id] [int] NULL,
	[volume] [float] NULL,
	[formula_str_eval] [varchar](2000) NULL,
	[commodity_id] [int] NULL,
	[granularity] [int] NULL,
	[is_final_result] [char](1) NULL,
	[is_dst] [int] NULL,
	[source_deal_header_id] [int] NULL,
	[allocation_volume] [float] NULL
) ON ps_calc_settlement(prod_date)
END 
ELSE 
BEGIN
    PRINT 'Table sstage_calc_formula_value EXISTS'
END	
GO

SET ANSI_PADDING OFF
GO
--ALTER TABLE [dbo].[calc_formula_value] ADD  CONSTRAINT [PK_calc_formula_value1] PRIMARY KEY CLUSTERED
--([ID] ASC) ON ps_calc_settlement(prod_date)


--ALTER TABLE [dbo].[calc_formula_value]  WITH NOCHECK ADD  CONSTRAINT [FK_calc_formula_value_formula_editorstg] FOREIGN KEY([formula_id])
--REFERENCES [dbo].[formula_editor] ([formula_id])
--GO

--ALTER TABLE [dbo].[calc_formula_value] CHECK CONSTRAINT [FK_calc_formula_value_formula_editorstg]
--GO

--ALTER TABLE [dbo].[calc_formula_value]  WITH NOCHECK ADD  CONSTRAINT [FK_calc_formula_value_rec_generatorstg] FOREIGN KEY([generator_id])
--REFERENCES [dbo].[rec_generator] ([generator_id])
--ON DELETE CASCADE
--GO

--ALTER TABLE [dbo].[calc_formula_value] CHECK CONSTRAINT [FK_calc_formula_value_rec_generatorstg]
--GO

--ALTER TABLE [dbo].[calc_formula_value]  WITH NOCHECK ADD  CONSTRAINT [FK_calc_formula_value_static_data_valuestg] FOREIGN KEY([invoice_line_item_id])
--REFERENCES [dbo].[static_data_value] ([value_id])
--GO

--ALTER TABLE [dbo].[calc_formula_value] CHECK CONSTRAINT [FK_calc_formula_value_static_data_valuestg]
--GO


------ index_fees_breakdown_settlement
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[stage_index_fees_breakdown_settlement]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[stage_index_fees_breakdown_settlement](
	[index_fees_id] [int] IDENTITY(1,1) NOT NULL,
	[as_of_date] [datetime] NULL,
	[source_deal_header_id] [int] NULL,
	[leg] [int] NULL,
	[term_start] [datetime] NULL,
	[term_end] [datetime] NULL,
	[field_id] [int] NULL,
	[field_name] [varchar](100) NULL,
	[price] [float] NULL,
	[total_price] [float] NULL,
	[volume] [float] NULL,
	[value] [float] NULL,
	[contract_value] [float] NULL,
	[internal_type] [int] NULL,
	[tab_group_name] [int] NULL,
	[udf_group_name] [int] NULL,
	[sequence] [int] NULL,
	[fee_currency_id] [int] NULL,
	[currency_id] [int] NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[set_type] [char](1) NULL,
	[contract_mkt_flag] [char](1) NULL
) ON ps_index_settlement(as_of_date)
END 
ELSE 
BEGIN
    PRINT 'Table stage_index_fees_breakdown_settlement EXISTS'
END	
GO

--,
-- CONSTRAINT [PK_index_fees_breakdown_settlement] PRIMARY KEY CLUSTERED 
--(
--	[index_fees_id] ASC
--)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON ps_index_settlement(as_of_date)

SET ANSI_PADDING OFF
GO
