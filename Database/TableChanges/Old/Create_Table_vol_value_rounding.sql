/****** Object:  Table [dbo].[vol_value_rounding]    Script Date: 09/15/2011 15:55:33 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[vol_value_rounding]') AND type in (N'U'))
DROP TABLE [dbo].[vol_value_rounding]
GO

/****** Object:  Table [dbo].[vol_value_rounding]    Script Date: 09/15/2011 15:55:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[vol_value_rounding](
	[contract_id] [int] NOT NULL,
	[item_type] [char](1) NOT NULL,
	[field_id] [int] NOT NULL,
	[rounding] [int] NOT NULL,
 CONSTRAINT [PK_vol_value_rounding] PRIMARY KEY CLUSTERED 
(
	[contract_id] ASC,
	[item_type] ASC,
	[field_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


