
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[broker_fees]') AND type in (N'U'))
DROP TABLE [dbo].[broker_fees]
GO 


/****** Object:  Table [dbo].[broker_fees]    Script Date: 09/18/2009 17:09:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[broker_fees](
	[broker_fees_id] [int] IDENTITY(1,1) NOT NULL,
	[effective_date] [datetime] NULL,
	[deal_type] [int] NULL,
	[commodity] [int] NULL,
	[product] [int] NULL,
	[unit_price] [float] NULL,
	[fixed_price] [float] NULL,
	[currency] [int] NULL,
 CONSTRAINT [PK_broker_fees] PRIMARY KEY CLUSTERED 
(
	[broker_fees_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[broker_fees]  WITH CHECK ADD  CONSTRAINT [FK_broker_fees_source_commodity] FOREIGN KEY([commodity])
REFERENCES [dbo].[source_commodity] ([source_commodity_id])
GO
ALTER TABLE [dbo].[broker_fees]  WITH CHECK ADD  CONSTRAINT [FK_broker_fees_source_currency] FOREIGN KEY([currency])
REFERENCES [dbo].[source_currency] ([source_currency_id])
GO
ALTER TABLE [dbo].[broker_fees]  WITH CHECK ADD  CONSTRAINT [FK_broker_fees_source_deal_type] FOREIGN KEY([deal_type])
REFERENCES [dbo].[source_deal_type] ([source_deal_type_id])
GO
ALTER TABLE [dbo].[broker_fees]  WITH CHECK ADD  CONSTRAINT [FK_broker_fees_source_price_curve_def] FOREIGN KEY([product])
REFERENCES [dbo].[source_price_curve_def] ([source_curve_def_id])