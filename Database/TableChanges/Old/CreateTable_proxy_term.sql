/****** Object:  Table [dbo].[proxy_term]    Script Date: 05/23/2011 14:43:10 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[proxy_term]') AND type in (N'U'))
DROP TABLE [dbo].[proxy_term]

GO
/****** Object:  Table [dbo].[proxy_term]    Script Date: 05/23/2011 14:42:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[proxy_term](
	[id] INT IDENTITY(1,1),
	[commodity_id] [int] NULL,
	[term_start] [datetime] NULL,
	[hour] [int] NULL,
	[proxy_term_start] [datetime] NULL,
	[proxy_hour] [int] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_proxy_term] ON [dbo].[proxy_term] 
(
	[commodity_id] ASC,
	[term_start] ASC,
	[hour] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
INSERT INTO proxy_term SELECT * FROM [dbo].[FNAGetProxy_term](NULL,982,'2000-01-01','2020-01-01')
