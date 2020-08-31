
/****** Object:  Table [dbo].[curve_volatility_imp]    Script Date: 01/07/2009 10:31:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[curve_volatility_imp](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[as_of_date] [datetime] NULL,
	[curve_id] [int] NULL,
	[curve_source_value_id] [int] NULL,
	[term] [datetime] NULL,
	[value] [float] NULL,
	[create_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_Volatility_Imp] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY],

 CONSTRAINT [PK_Volatility_Imp_Unq] UNIQUE  
(
	[as_of_date] ASC,
	[curve_id] ASC,
	[term] ASC,
	[curve_source_value_id] ASC

)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[curve_volatility_imp]  WITH CHECK ADD  CONSTRAINT [FK_curve_volatility_imp_source_price_curve_def] FOREIGN KEY([curve_id])
REFERENCES [dbo].[source_price_curve_def] ([source_curve_def_id])
GO
ALTER TABLE [dbo].[curve_volatility_imp]  WITH CHECK ADD  CONSTRAINT [FK_curve_volatility_imp_static_data_value] FOREIGN KEY([curve_source_value_id])
REFERENCES [dbo].[static_data_value] ([value_id])
