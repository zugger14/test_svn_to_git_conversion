
/****** Object:  Table [dbo].[pratos_nominator_request_log]    Script Date: 06/05/2012 21:07:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pratos_nominator_request_log]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[pratos_nominator_request_log](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[source_deal_header_id] [int] NULL,
	[location_id] [int] NULL,
	[profile_id] [int] NULL,
	[file_name] [varchar](200) NULL,
	[create_ts] [datetime] NULL,
 CONSTRAINT [PK_pratos_nominator_request_log] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
