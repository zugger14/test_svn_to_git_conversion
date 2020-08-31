
/****** Object:  Table [dbo].[rate_schedule]    Script Date: 04/02/2009 12:55:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[rate_schedule](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[description] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[rate_schedule_type_id] [int] NULL,
 CONSTRAINT [PK_rate_schedule] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF