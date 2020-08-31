IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_holiday_block_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[holiday_block]'))
ALTER TABLE [dbo].[holiday_block] DROP CONSTRAINT [FK_holiday_block_static_data_value]
GO
/****** Object:  Table [dbo].[holiday_block]    Script Date: 06/23/2010 15:19:51 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[holiday_block]') AND type in (N'U'))
DROP TABLE [dbo].[holiday_block]
GO
/****** Object:  Table [dbo].[holiday_block]    Script Date: 06/23/2010 15:14:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[holiday_block](
	[holiday_block_id] [int] IDENTITY(1,1) NOT NULL,
	[block_value_id] [int] NOT NULL, -- FK to static data value
	Onpeak_offpeak CHAR(1),
	[Hr1] [int] NOT NULL,
	[Hr2] [int] NOT NULL,
	[Hr3] [int] NOT NULL,
	[Hr4] [int] NOT NULL,
	[Hr5] [int] NOT NULL,
	[Hr6] [int] NOT NULL,
	[Hr7] [int] NOT NULL,
	[Hr8] [int] NOT NULL,
	[Hr9] [int] NOT NULL,
	[Hr10] [int] NOT NULL,
	[Hr11] [int] NOT NULL,
	[Hr12] [int] NOT NULL,
	[Hr13] [int] NOT NULL,
	[Hr14] [int] NOT NULL,
	[Hr15] [int] NOT NULL,
	[Hr16] [int] NOT NULL,
	[Hr17] [int] NOT NULL,
	[Hr18] [int] NOT NULL,
	[Hr19] [int] NOT NULL,
	[Hr20] [int] NOT NULL,
	[Hr21] [int] NOT NULL,
	[Hr22] [int] NOT NULL,
	[Hr23] [int] NOT NULL,
	[Hr24] [int] NOT NULL,
	[create_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[create_ts] [datetime] NOT NULL,
	[update_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[update_ts] [datetime] NOT NULL,
 CONSTRAINT [PK_holiday_block] PRIMARY KEY CLUSTERED 
(
	[holiday_block_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[holiday_block]  WITH NOCHECK ADD  CONSTRAINT [FK_holiday_block_static_data_value] FOREIGN KEY([block_value_id])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
ALTER TABLE [dbo].[holiday_block] CHECK CONSTRAINT [FK_holiday_block_static_data_value]
