/****** Object:  Table [dbo].[source_minor_location]    Script Date: 01/08/2009 18:37:53 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[source_minor_location]') AND type in (N'U'))
DROP TABLE [dbo].[source_minor_location]

go
/****** Object:  Table [dbo].[source_minor_location]    Script Date: 01/08/2009 18:33:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[source_minor_location](
	[source_minor_location_id] [int] IDENTITY(1,1) NOT NULL,
	[source_system_id] [int] NOT NULL,
	[source_major_location_ID] [int] NULL,
	[Location_Name] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Location_Description] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Meter_ID] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Pricing_Index] [int] NULL,
	[Commodity_id] [int] NULL,
	[create_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_source_minor_location] PRIMARY KEY CLUSTERED 
(
	[source_minor_location_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF

GO
ALTER TABLE [dbo].[source_minor_location]  WITH CHECK ADD  CONSTRAINT [FK_source_minor_location_source_major_location] FOREIGN KEY([source_major_location_ID])
REFERENCES [dbo].[source_major_location] ([source_major_location_ID])