IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_deal_detail_hour_source_deal_detail]') AND parent_object_id = OBJECT_ID(N'[dbo].[deal_detail_hour]'))
ALTER TABLE [dbo].[deal_detail_hour] DROP CONSTRAINT [FK_deal_detail_hour_source_deal_detail]
GO

/****** Object:  Table [dbo].[deal_detail_hour]    Script Date: 12/01/2010 12:11:36 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[deal_detail_hour]') AND type in (N'U'))
DROP TABLE [dbo].[deal_detail_hour]
GO

/****** Object:  Table [dbo].[deal_detail_hour]    Script Date: 12/01/2010 12:08:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[deal_detail_hour](
	[deal_detail_hour_id] [int] IDENTITY(1,1) NOT NULL,
	[term_date] [datetime] NOT NULL,
	[source_deal_detail_id] [int] NULL,
	[profile_id] [int] NULL,
	[location_id] [int] NULL,
	[Hr1] [float] NULL,
	[Hr2] [float] NULL,
	[Hr3] [float] NULL,
	[Hr4] [float] NULL,
	[Hr5] [float] NULL,
	[Hr6] [float] NULL,
	[Hr7] [float] NULL,
	[Hr8] [float] NULL,
	[Hr9] [float] NULL,
	[Hr10] [float] NULL,
	[Hr11] [float] NULL,
	[Hr12] [float] NULL,
	[Hr13] [float] NULL,
	[Hr14] [float] NULL,
	[Hr15] [float] NULL,
	[Hr16] [float] NULL,
	[Hr17] [float] NULL,
	[Hr18] [float] NULL,
	[Hr19] [float] NULL,
	[Hr20] [float] NULL,
	[Hr21] [float] NULL,
	[Hr22] [float] NULL,
	[Hr23] [float] NULL,
	[Hr24] [float] NULL,
 CONSTRAINT [PK_deal_detail_hour] PRIMARY KEY NONCLUSTERED 
(
	[deal_detail_hour_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

/****** Object:  Index [IX_deal_detail_hour]    Script Date: 12/01/2010 12:08:07 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_deal_detail_hour] ON [dbo].[deal_detail_hour] 
(
	[source_deal_detail_id] ASC,
	[term_date] ASC
)
INCLUDE ( [Hr1],
[Hr2],
[Hr3],
[Hr4],
[Hr5],
[Hr6],
[Hr7],
[Hr8],
[Hr9],
[Hr10],
[Hr11],
[Hr12],
[Hr13],
[Hr14],
[Hr15],
[Hr16],
[Hr17],
[Hr18],
[Hr19],
[Hr20],
[Hr21],
[Hr22],
[Hr23],
[Hr24]
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[deal_detail_hour]  WITH CHECK ADD  CONSTRAINT [FK_deal_detail_hour_source_deal_detail] FOREIGN KEY([source_deal_detail_id])
REFERENCES [dbo].[source_deal_detail] ([source_deal_detail_id])
GO
ALTER TABLE [dbo].[deal_detail_hour] CHECK CONSTRAINT [FK_deal_detail_hour_source_deal_detail]