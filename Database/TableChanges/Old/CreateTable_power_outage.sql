IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_power_outage_source_generator]') AND parent_object_id = OBJECT_ID(N'[dbo].[power_outage]'))
ALTER TABLE [dbo].[power_outage] DROP CONSTRAINT [FK_power_outage_source_generator]
GO

/****** Object:  Table [dbo].[power_outage]    Script Date: 05/21/2009 20:07:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[power_outage]') AND type in (N'U'))
DROP TABLE [dbo].[power_outage]
/****** Object:  Table [dbo].[power_outage]    Script Date: 05/21/2009 20:07:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[power_outage](
	[power_outage_id] [int] IDENTITY(1,1) NOT NULL,
	[source_generator_id] [int] NOT NULL,
	[planned_start] [datetime] NULL,
	[planned_end] [datetime] NULL,
	[actual_start] [datetime] NULL,
	[actual_end] [datetime] NULL,
	[granularity] [int] NULL,
	[status] [char](1) NOT NULL,
	[request_type] [char](1) NOT NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_power_outage] PRIMARY KEY CLUSTERED 
(
	[power_outage_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[power_outage]  WITH CHECK ADD  CONSTRAINT [FK_power_outage_source_generator] FOREIGN KEY([source_generator_id])
REFERENCES [dbo].[source_generator] ([source_generator_id])
GO
ALTER TABLE [dbo].[power_outage] CHECK CONSTRAINT [FK_power_outage_source_generator]