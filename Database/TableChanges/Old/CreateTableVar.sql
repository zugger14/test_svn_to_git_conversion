
/****** Object:  Table [dbo].[marginal_var]    Script Date: 12/16/2008 20:19:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[marginal_var]') AND type in (N'U'))
DROP TABLE [dbo].[marginal_var]
GO
/****** Object:  Table [dbo].[var_results]    Script Date: 12/16/2008 20:19:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[var_results]') AND type in (N'U'))
DROP TABLE [dbo].[var_results]
GO
/****** Object:  Table [dbo].[curve_correlation]    Script Date: 12/16/2008 20:19:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[curve_correlation]') AND type in (N'U'))
DROP TABLE [dbo].[curve_correlation]
GO
/****** Object:  Table [dbo].[curve_volatility]    Script Date: 12/16/2008 20:19:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[curve_volatility]') AND type in (N'U'))
DROP TABLE [dbo].[curve_volatility]
GO

/****** Object:  Table [dbo].[marginal_var]    Script Date: 12/16/2008 20:20:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[marginal_var](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[var_criteria_id] [int] NULL,
	[as_of_date] [datetime] NULL,
	[curve_id] [int] NULL,
	[term] [datetime] NULL,
	[MVaR] [float] NULL,
	[create_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_ts] [nchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_marginal_var] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[var_results]    Script Date: 12/16/2008 20:20:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[var_results](
	[id] [int] NULL,
	[as_of_date] [datetime] NULL,
	[var_criteria_id] [int] NULL,
	[VaR] [float] NULL,
	[VaRC] [float] NULL,
	[VaRI] [float] NULL,
	[RAROC1] [float] NULL,
	[RAROC2] [float] NULL,
	[create_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_ts] [nchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[curve_correlation]    Script Date: 12/16/2008 20:20:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[curve_correlation](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[as_of_date] [datetime] NULL,
	[curve_id_from] [int] NULL,
	[curve_id_to] [int] NULL,
	[term] [datetime] NULL,
	[curve_source_value_id] [int] NULL,
	[value] [float] NULL,
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
/****** Object:  Table [dbo].[curve_volatility]    Script Date: 12/16/2008 20:20:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[curve_volatility](
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
 CONSTRAINT [PK_Volatility] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF