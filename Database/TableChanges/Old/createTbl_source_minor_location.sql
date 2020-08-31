/****** Object:  Table [dbo].[source_major_location]    Script Date: 01/07/2009 12:40:58 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[source_minor_location]') AND type in (N'U'))
DROP TABLE [dbo].[source_minor_location]
go
/****** Object:  Table [dbo].[source_minor_location]    Script Date: 01/07/2009 12:39:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[source_minor_location](
	[source_minor_location_id] [int] IDENTITY(1,1) NOT NULL,
	[source_system_id] [int] NOT NULL,
	[minor_location_id] [varchar](100) NOT NULL,
	[Major_Location_Id] [int] NULL,
	[Location_Name] [varchar](100) NOT NULL,
	[Location_Description] [varchar](25) NULL,
	[Meter_ID] [varchar](100) NULL,
	[Pricing_Index] [int] NULL,
	[Commodity_id] [int] NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_source_minor_location] PRIMARY KEY CLUSTERED 
(
	[source_minor_location_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[source_minor_location]  WITH CHECK ADD  CONSTRAINT [FK_source_minor_location_source_major_location] FOREIGN KEY([Major_Location_Id])
REFERENCES [dbo].[source_major_location] ([source_major_location_ID])
GO
ALTER TABLE [dbo].[source_minor_location] CHECK CONSTRAINT [FK_source_minor_location_source_major_location]