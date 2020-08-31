/****** Object:  Table [dbo].[fx_correction_values]    Script Date: 11/21/2012 13:50:08 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fx_correction_values]') AND type in (N'U'))
DROP TABLE [dbo].[fx_correction_values]
GO

/****** Object:  Table [dbo].[fx_correction_values]    Script Date: 11/20/2012 15:57:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[fx_correction_values](
	[as_of_date] datetime NOT NULL,
	[cor_link_id] [int] NOT NULL,
	[cor_term_start] datetime NOT NULL,
	[cor_hedge_item] [varchar](1) NOT NULL,
	[u_correction_value] [float] NULL,
	[d_correction_value] [float] NULL,
 CONSTRAINT [PK_fx_correction_values_1] PRIMARY KEY CLUSTERED 
(
	[as_of_date] ASC,
	[cor_link_id] ASC,
	[cor_term_start] ASC,
	[cor_hedge_item] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


