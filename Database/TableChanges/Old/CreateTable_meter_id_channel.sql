/****** Object:  Table [dbo].[meter_id_channel]    Script Date: 03/28/2011 21:49:48 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[meter_id_channel]') AND type in (N'U'))
DROP TABLE [dbo].[meter_id_channel]
GO
/****** Object:  Table [dbo].[meter_id_channel]    Script Date: 03/28/2011 21:49:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[meter_id_channel](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[meter_id] [varchar](100) NOT NULL,
	[channel] [int] NULL,
	[channel_description] [varchar](100) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


