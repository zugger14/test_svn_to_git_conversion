

/****** Object:  Table [dbo].[source_deal_settlement]    Script Date: 06/18/2012 16:53:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
SP_RENAME source_deal_settlement , source_deal_settlement_non_part
CREATE TABLE [dbo].[source_deal_settlement](
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

GO
INSERT INTO source_deal_settlement SELECT * FROM source_deal_settlement_non_part 
SET ANSI_PADDING OFF
GO


------- calc_formula_value 

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_formula_value_formula_editor1]') AND parent_object_id = OBJECT_ID(N'[dbo].[formula_editor]'))
ALTER TABLE calc_formula_value DROP CONSTRAINT [FK_calc_formula_value_formula_editor1]
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_formula_value_rec_generator1]') AND parent_object_id = OBJECT_ID(N'[dbo].[rec_generator]'))
ALTER TABLE calc_formula_value DROP CONSTRAINT [FK_calc_formula_value_rec_generator1]
GO
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_formula_value_static_data_value1]') AND parent_object_id = OBJECT_ID(N'[dbo].[static_data_value]'))
ALTER TABLE calc_formula_value DROP CONSTRAINT [FK_calc_formula_value_static_data_value1]
GO


SP_RENAME calc_formula_value , calc_formula_value_non_part

CREATE TABLE [dbo].[calc_formula_value](
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

GO

SET ANSI_PADDING OFF
GO
--ALTER TABLE [dbo].[calc_formula_value] ADD  CONSTRAINT [PK_calc_formula_value1] PRIMARY KEY CLUSTERED
--([ID] ASC) ON ps_calc_settlement(prod_date)


ALTER TABLE [dbo].[calc_formula_value]  WITH NOCHECK ADD  CONSTRAINT [FK_calc_formula_value_formula_editor1] FOREIGN KEY([formula_id])
REFERENCES [dbo].[formula_editor] ([formula_id])
GO

ALTER TABLE [dbo].[calc_formula_value] CHECK CONSTRAINT [FK_calc_formula_value_formula_editor1]
GO

ALTER TABLE [dbo].[calc_formula_value]  WITH NOCHECK ADD  CONSTRAINT [FK_calc_formula_value_rec_generator1] FOREIGN KEY([generator_id])
REFERENCES [dbo].[rec_generator] ([generator_id])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[calc_formula_value] CHECK CONSTRAINT [FK_calc_formula_value_rec_generator1]
GO

ALTER TABLE [dbo].[calc_formula_value]  WITH NOCHECK ADD  CONSTRAINT [FK_calc_formula_value_static_data_value1] FOREIGN KEY([invoice_line_item_id])
REFERENCES [dbo].[static_data_value] ([value_id])
GO

ALTER TABLE [dbo].[calc_formula_value] CHECK CONSTRAINT [FK_calc_formula_value_static_data_value1]
GO

SET IDENTITY_INSERT calc_formula_value ON 
INSERT INTO calc_formula_value(ID,invoice_line_item_id,seq_number,prod_date,value,contract_id,counterparty_id,formula_id,calc_id,hour,formula_str,qtr,half,deal_type_id,generator_id,ems_generator_id,deal_id,volume,formula_str_eval,commodity_id,granularity,is_final_result,is_dst,source_deal_header_id,allocation_volume
) SELECT ID,invoice_line_item_id,seq_number,prod_date,value,contract_id,counterparty_id,formula_id,calc_id,hour,formula_str,qtr,half,deal_type_id,generator_id,ems_generator_id,deal_id,volume,formula_str_eval,commodity_id,granularity,is_final_result,is_dst,source_deal_header_id,allocation_volume
 FROM calc_formula_value_non_part
  
SET IDENTITY_INSERT calc_formula_value OFF 
------ index_fees_breakdown_settlement
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
SP_RENAME index_fees_breakdown_settlement , index_fees_breakdown_settlement_non_part
CREATE TABLE [dbo].[index_fees_breakdown_settlement](
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

GO

--,
-- CONSTRAINT [PK_index_fees_breakdown_settlement] PRIMARY KEY CLUSTERED 
--(
--	[index_fees_id] ASC
--)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON ps_index_settlement(as_of_date)
SET IDENTITY_INSERT index_fees_breakdown_settlement ON
INSERT INTO index_fees_breakdown_settlement(index_fees_id,as_of_date,source_deal_header_id,leg,term_start,term_end,field_id,field_name,price,total_price,volume,value,contract_value,internal_type,tab_group_name,udf_group_name,sequence,fee_currency_id,currency_id,create_user,create_ts,set_type,contract_mkt_flag
)
 SELECT index_fees_id,as_of_date,source_deal_header_id,leg,term_start,term_end,field_id,field_name,price,total_price,volume,value,contract_value,internal_type,tab_group_name,udf_group_name,sequence,fee_currency_id,currency_id,create_user,create_ts,set_type,contract_mkt_flag
 FROM index_fees_breakdown_settlement_non_part 
SET IDENTITY_INSERT index_fees_breakdown_settlement OFF

SET ANSI_PADDING OFF
GO
