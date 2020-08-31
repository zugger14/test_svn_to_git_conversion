
/****** Object:  Table [dbo].[curve_correlation]    Script Date: 12/26/2008 15:51:04 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[curve_correlation]') AND type in (N'U'))
DROP TABLE [dbo].[curve_correlation]
GO
/****** Object:  Table [dbo].[curve_volatility]    Script Date: 12/26/2008 15:51:04 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[curve_volatility]') AND type in (N'U'))
DROP TABLE [dbo].[curve_volatility]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_default_recovery_rate_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[default_recovery_rate]'))
ALTER TABLE [dbo].[default_recovery_rate] DROP CONSTRAINT [FK_default_recovery_rate_static_data_value]
GO

/****** Object:  Table [dbo].[default_recovery_rate]    Script Date: 12/26/2008 16:00:38 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[default_recovery_rate]') AND type in (N'U'))
DROP TABLE [dbo].[default_recovery_rate]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_vol_cor_header_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[vol_cor_header]'))
ALTER TABLE [dbo].[vol_cor_header] DROP CONSTRAINT [FK_vol_cor_header_static_data_value]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_vol_cor_header_static_data_value1]') AND parent_object_id = OBJECT_ID(N'[dbo].[vol_cor_header]'))
ALTER TABLE [dbo].[vol_cor_header] DROP CONSTRAINT [FK_vol_cor_header_static_data_value1]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_vol_cor_header_var_measurement_criteria_detail]') AND parent_object_id = OBJECT_ID(N'[dbo].[vol_cor_header]'))
ALTER TABLE [dbo].[vol_cor_header] DROP CONSTRAINT [FK_vol_cor_header_var_measurement_criteria_detail]
GO
/****** Object:  Table [dbo].[vol_cor_header]    Script Date: 12/26/2008 15:59:11 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[vol_cor_header]') AND type in (N'U'))
DROP TABLE [dbo].[vol_cor_header]
GO

/****** Object:  Table [dbo].[default_recovery_rate]    Script Date: 12/26/2008 16:00:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[default_recovery_rate](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[effective_date] [datetime] NOT NULL,
	[debt_rating] [int] NOT NULL,
	[recovery] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[months] [int] NULL,
	[rate] [float] NULL,
	[create_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_default_recovery_rate] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [IX_default_recovery_rate] UNIQUE NONCLUSTERED 
(
	[effective_date] ASC,
	[debt_rating] ASC,
	[recovery] ASC,
	[months] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[default_recovery_rate]  WITH CHECK ADD  CONSTRAINT [FK_default_recovery_rate_static_data_value] FOREIGN KEY([debt_rating])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
ALTER TABLE [dbo].[default_recovery_rate] CHECK CONSTRAINT [FK_default_recovery_rate_static_data_value]
/****** Object:  Table [dbo].[vol_cor_header]    Script Date: 12/26/2008 15:59:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[vol_cor_header](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[as_of_date] [datetime] NOT NULL,
	[var_criteria_id] [int] NOT NULL,
	[data_points] [int] NOT NULL,
	[curve_source_value_id] [int] NOT NULL,
	[daily_return_data_series] [int] NOT NULL,
	[vol_calc] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[cor_calc] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_vol_cor_header] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[vol_cor_header]  WITH CHECK ADD  CONSTRAINT [FK_vol_cor_header_static_data_value] FOREIGN KEY([curve_source_value_id])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
ALTER TABLE [dbo].[vol_cor_header] CHECK CONSTRAINT [FK_vol_cor_header_static_data_value]
GO
ALTER TABLE [dbo].[vol_cor_header]  WITH CHECK ADD  CONSTRAINT [FK_vol_cor_header_static_data_value1] FOREIGN KEY([daily_return_data_series])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
ALTER TABLE [dbo].[vol_cor_header] CHECK CONSTRAINT [FK_vol_cor_header_static_data_value1]
GO
ALTER TABLE [dbo].[vol_cor_header]  WITH CHECK ADD  CONSTRAINT [FK_vol_cor_header_var_measurement_criteria_detail] FOREIGN KEY([var_criteria_id])
REFERENCES [dbo].[var_measurement_criteria_detail] ([id])
GO
ALTER TABLE [dbo].[vol_cor_header] CHECK CONSTRAINT [FK_vol_cor_header_var_measurement_criteria_detail]
GO
/****** Object:  Table [dbo].[curve_correlation]    Script Date: 12/26/2008 15:58:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[curve_correlation](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[vol_cor_header_id] [int] NOT NULL,
	[as_of_date] [datetime] NOT NULL,
	[curve_id_from] [int] NOT NULL,
	[curve_id_to] [int] NOT NULL,
	[term1] [datetime] NOT NULL,
	[term2] [datetime] NOT NULL,
	[curve_source_value_id] [int] NOT NULL,
	[value] [float] NOT NULL,
	[create_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_curve_correlation] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[curve_volatility]    Script Date: 12/26/2008 15:58:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[curve_volatility](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[vol_cor_header_id] [int] NULL,
	[as_of_date] [datetime] NULL,
	[curve_id] [int] NULL,
	[curve_source_value_id] [int] NULL,
	[term] [datetime] NULL,
	[value] [float] NULL,
	[create_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_Volatility] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[curve_correlation]  WITH CHECK ADD  CONSTRAINT [FK_curve_correlation_source_price_curve_def] FOREIGN KEY([curve_id_from])
REFERENCES [dbo].[source_price_curve_def] ([source_curve_def_id])
GO
ALTER TABLE [dbo].[curve_correlation] CHECK CONSTRAINT [FK_curve_correlation_source_price_curve_def]
GO
ALTER TABLE [dbo].[curve_correlation]  WITH CHECK ADD  CONSTRAINT [FK_curve_correlation_source_price_curve_def1] FOREIGN KEY([curve_id_to])
REFERENCES [dbo].[source_price_curve_def] ([source_curve_def_id])
GO
ALTER TABLE [dbo].[curve_correlation] CHECK CONSTRAINT [FK_curve_correlation_source_price_curve_def1]
GO
ALTER TABLE [dbo].[curve_correlation]  WITH CHECK ADD  CONSTRAINT [FK_curve_correlation_static_data_value] FOREIGN KEY([curve_source_value_id])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
ALTER TABLE [dbo].[curve_correlation] CHECK CONSTRAINT [FK_curve_correlation_static_data_value]
GO
ALTER TABLE [dbo].[curve_correlation]  WITH CHECK ADD  CONSTRAINT [FK_curve_correlation_vol_cor_header] FOREIGN KEY([vol_cor_header_id])
REFERENCES [dbo].[vol_cor_header] ([id])
GO
ALTER TABLE [dbo].[curve_correlation] CHECK CONSTRAINT [FK_curve_correlation_vol_cor_header]
GO
ALTER TABLE [dbo].[curve_volatility]  WITH CHECK ADD  CONSTRAINT [FK_curve_volatility_source_price_curve_def] FOREIGN KEY([curve_id])
REFERENCES [dbo].[source_price_curve_def] ([source_curve_def_id])
GO
ALTER TABLE [dbo].[curve_volatility] CHECK CONSTRAINT [FK_curve_volatility_source_price_curve_def]
GO
ALTER TABLE [dbo].[curve_volatility]  WITH CHECK ADD  CONSTRAINT [FK_curve_volatility_static_data_value] FOREIGN KEY([curve_source_value_id])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
ALTER TABLE [dbo].[curve_volatility] CHECK CONSTRAINT [FK_curve_volatility_static_data_value]
GO
ALTER TABLE [dbo].[curve_volatility]  WITH CHECK ADD  CONSTRAINT [FK_curve_volatility_vol_cor_header] FOREIGN KEY([vol_cor_header_id])
REFERENCES [dbo].[vol_cor_header] ([id])
GO
ALTER TABLE [dbo].[curve_volatility] CHECK CONSTRAINT [FK_curve_volatility_vol_cor_header]

GO

/****** Object:  Table [dbo].[default_probability]    Script Date: 12/28/2008 19:52:15 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[default_probability]') AND type in (N'U'))
DROP TABLE [dbo].[default_probability]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[default_probability](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[effective_date] [datetime] NOT NULL,
	[debt_rating] [int] NOT NULL,
	[recovery] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[months] [int] NULL,
	[probability] [float] NULL,
	[create_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_default_probability] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF