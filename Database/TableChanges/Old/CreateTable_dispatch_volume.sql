
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_dispatch_volume_source_minor_location]') AND parent_object_id = OBJECT_ID(N'[dbo].[dispatch_volume]'))
ALTER TABLE [dbo].[dispatch_volume] DROP CONSTRAINT [FK_dispatch_volume_source_minor_location]
GO

GO
/****** Object:  Table [dbo].[dispatch_volume]    Script Date: 06/02/2009 09:27:20 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dispatch_volume]') AND type in (N'U'))
DROP TABLE [dbo].[dispatch_volume]
/****** Object:  Table [dbo].[dispatch_volume]    Script Date: 06/02/2009 09:27:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[dispatch_volume](
	[dispatch_volume_id] [int] IDENTITY(1,1) NOT NULL,
	[location_id] [int] NOT NULL,
	[dispatch_date] [datetime] NOT NULL,
	[dispatch_hour] [int] NOT NULL,
	[dispatch_volume] [float] NOT NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_dispatch_volume] PRIMARY KEY CLUSTERED 
(
	[dispatch_volume_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[dispatch_volume]  WITH CHECK ADD  CONSTRAINT [FK_dispatch_volume_source_minor_location] FOREIGN KEY([location_id])
REFERENCES [dbo].[source_minor_location] ([source_minor_location_id])
GO
ALTER TABLE [dbo].[dispatch_volume] CHECK CONSTRAINT [FK_dispatch_volume_source_minor_location]