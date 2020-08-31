/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
--BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON


select Has_Perms_By_Name(N'dbo.source_deal_pnl_detail_options', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.source_deal_pnl_detail_options', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.source_deal_pnl_detail_options', 'Object', 'CONTROL') as Contr_Per 
GO
CREATE TABLE [dbo].[tmp_source_deal_pnl_detail_options](
	[as_of_date] [datetime] NOT NULL,
	[source_deal_header_id] [int] NOT NULL,
	[term_start] [datetime] NOT NULL,
	[curve_1] [int] NULL,
	[curve_2] [int] NULL,
	[option_premium] [float] NULL,
	[strike_price] [float] NULL,
	[spot_price_1] [float] NULL,
	[days_expiry] [float] NULL,
	[volatility_1] [float] NULL,
	[discount_rate] [float] NULL,
	[option_type] [char](1) NULL,
	[excercise_type] [char](1) NULL,
	[source_deal_type_id] [int] NULL,
	[deal_sub_type_type_id] [int] NULL,
	[internal_deal_type_value_id] [varchar](50) NULL,
	[internal_deal_subtype_value_id] [varchar](50) NULL,
	[deal_volume] [float] NULL,
	[deal_volume_frequency] [char](1) NULL,
	[deal_volume_uom_id] [int] NULL,
	[correlation] [float] NULL,
	[volatility_2] [float] NULL,
	[spot_price_2] [float] NULL,
	[deal_volume2] [float] NULL,
	[PREMIUM] [float] NULL,
	[DELTA] [float] NULL,
	[GAMMA] [float] NULL,
	[VEGA] [float] NULL,
	[THETA] [float] NULL,
	[RHO] [float] NULL,
	[DELTA2] [float] NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[pnl_source_value_id] [int] NOT NULL,
 CONSTRAINT [PK_source_deal_pnl_detail_option1] PRIMARY KEY CLUSTERED 
(
	[as_of_date] ASC,
	[source_deal_header_id] ASC,
	[term_start] ASC,
	[pnl_source_value_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].source_deal_pnl_detail_options') AND type in (N'U'))
	IF EXISTS(SELECT * FROM dbo.source_deal_pnl_detail_options)
		 EXEC('INSERT INTO dbo.Tmp_source_deal_pnl_detail_options
			SELECT * FROM source_deal_pnl_detail_options WITH (HOLDLOCK TABLOCKX)')
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].source_deal_pnl_detail_options') AND type in (N'U'))
	DROP TABLE dbo.source_deal_pnl_detail_options

GO
EXECUTE sp_rename N'dbo.tmp_source_deal_pnl_detail_options', N'source_deal_pnl_detail_options', 'OBJECT' 
GO


ALTER TABLE [dbo].[source_deal_pnl_detail_options]  WITH CHECK ADD  CONSTRAINT [FK_source_deal_pnl_detail_options_static_data_value] FOREIGN KEY([pnl_source_value_id])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
ALTER TABLE [dbo].[source_deal_pnl_detail_options] CHECK CONSTRAINT [FK_source_deal_pnl_detail_options_static_data_value]
	
GO
--COMMIT TRANSACTION
select Has_Perms_By_Name(N'dbo.source_deal_pnl_detail_options', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.source_deal_pnl_detail_options', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.source_deal_pnl_detail_options', 'Object', 'CONTROL') as Contr_Per 


