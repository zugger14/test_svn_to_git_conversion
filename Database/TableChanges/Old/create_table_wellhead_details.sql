

GO
/****** Object:  Table [dbo].[wellhead_details]    Script Date: 04/08/2010 16:30:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[wellhead_details]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[wellhead_details](
	[short_id] [varchar](20) NOT NULL,
	[name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[description] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[meter_number] [int] NULL,
	[facility_group] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[gathering_contract] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[gathering_company] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_wellhead_details] PRIMARY KEY CLUSTERED 
(
	[short_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

/****** Object:  Index [PK_wellhead_details]    Script Date: 04/08/2010 17:40:36 ******/

END
GO
SET ANSI_PADDING OFF