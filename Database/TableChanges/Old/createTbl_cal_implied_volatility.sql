drop table [calc_implied_volatility]
/****** Object:  Table [dbo].[cal_volatility_implied volatility]    Script Date: 01/08/2009 12:58:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[calc_implied_volatility](
	[calc_implied_volatility_id] [int] IDENTITY(1,1) NOT NULL,
	[option_type] [char](1) NULL,
	[exercise_type] [char](1) NULL,
	[commodity_id] [int] NULL,
	[curve_id] [int] NULL,
	[term] [datetime] NULL,
	[expiration] [datetime] NULL,
	[strike] [float] NULL,
	[premium] [float] NULL,
 CONSTRAINT [PK_calc_volatility_implied volatility] PRIMARY KEY CLUSTERED 
(
	[calc_implied_volatility_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[calc_implied_volatility]  WITH CHECK ADD  CONSTRAINT [FK_calc_volatility_implied_volatility_source_commodity] FOREIGN KEY([commodity_id])
REFERENCES [dbo].[source_commodity] ([source_commodity_id])
GO
ALTER TABLE [dbo].[calc_implied_volatility] CHECK CONSTRAINT [FK_calc_volatility_implied_volatility_source_commodity]
GO
ALTER TABLE [dbo].[calc_implied_volatility]  WITH CHECK ADD  CONSTRAINT [FK_calc_volatility_implied_volatility_source_price_curve_def] FOREIGN KEY([curve_id])
REFERENCES [dbo].[source_price_curve_def] ([source_curve_def_id])
GO
ALTER TABLE [dbo].[calc_implied_volatility] CHECK CONSTRAINT [FK_calc_volatility_implied_volatility_source_price_curve_def]