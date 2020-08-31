GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_power_outage_detail_power_outage]') AND parent_object_id = OBJECT_ID(N'[dbo].[power_outage_detail]'))
ALTER TABLE [dbo].[power_outage_detail] DROP CONSTRAINT [FK_power_outage_detail_power_outage]

GO
/****** Object:  Table [dbo].[power_outage_detail]    Script Date: 05/21/2009 20:09:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[power_outage_detail]') AND type in (N'U'))
DROP TABLE [dbo].[power_outage_detail]
/****** Object:  Table [dbo].[power_outage_detail]    Script Date: 05/21/2009 20:09:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[power_outage_detail](
	[power_outage_detail_id] [int] IDENTITY(1,1) NOT NULL,
	[power_outage_id] [int] NOT NULL,
	[outage_date] [datetime] NOT NULL,
	[outage_min] [int] NOT NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_power_outage_detail] PRIMARY KEY CLUSTERED 
(
	[power_outage_detail_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[power_outage_detail]  WITH CHECK ADD  CONSTRAINT [FK_power_outage_detail_power_outage] FOREIGN KEY([power_outage_id])
REFERENCES [dbo].[power_outage] ([power_outage_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[power_outage_detail] CHECK CONSTRAINT [FK_power_outage_detail_power_outage]