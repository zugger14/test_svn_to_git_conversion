/****** Object:  Table [dbo].[RWEST_Detail]    Script Date: 07/18/2011 23:30:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RWEST_Detail]') AND type in (N'U'))
DROP TABLE [dbo].[RWEST_Detail]
GO
/****** Object:  Table [dbo].[RWEST_Detail]    Script Date: 07/18/2011 23:30:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[RWEST_Detail](
	[Trade_Id] [varchar](50) NULL,
	[Energy_Vol] [varchar](50) NULL,
	[Price] [varchar](50) NULL,
	[Start_Date] [varchar](50) NULL,
	[End_Date] [varchar](50) NULL,
	[Index 1] [varchar](50) NULL,
	[Weight 1] [varchar](50) NULL,
	[Currency Index 1] [varchar](50) NULL,
	[Lagging 1] [varchar](50) NULL,
	[Index 2] [varchar](50) NULL,
	[Weight 2] [varchar](50) NULL,
	[Currency Index 2] [varchar](50) NULL,
	[Lagging 2] [varchar](50) NULL,
	[Index 3] [varchar](50) NULL,
	[Weight 3] [varchar](50) NULL,
	[Currency Index 3] [varchar](50) NULL,
	[Lagging 3] [varchar](50) NULL,
	[Index 4] [varchar](50) NULL,
	[Weight 4] [varchar](50) NULL,
	[Currency Index 4] [varchar](50) NULL,
	[Lagging 4] [varchar](50) NULL,
	[Adder] [varchar](50) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


