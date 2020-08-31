IF object_id('explain_position_header') IS NOT NULL
DROP TABLE dbo.explain_position_header
go
CREATE TABLE [dbo].[explain_position_header](
	[rowid] [bigint] IDENTITY(1,1) NOT NULL,
	[as_of_date_from] [datetime] NULL,
	[as_of_date_to] [datetime] NULL,
	[source_deal_header_id] [int] NULL,
	[curve_id] [int] NULL,
	[location_id] [int] NULL,
	[term_start] [datetime] NULL,
	[term_end] [datetime] NULL,
	[OB_Volume] [numeric](38, 20) NULL,
	[delta1] [numeric](38, 20) NULL,
	[delta2] [numeric](38, 20) NULL,
	[delta3] [numeric](38, 20) NULL,
	[delta4] [numeric](38, 20) NULL,
	[delta5] [numeric](38, 20) NULL,
	[CB_Volume] [numeric](38, 20) NULL,
 CONSTRAINT [PK_explain_position_header] PRIMARY KEY CLUSTERED 
(
	[rowid] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


/****** Object:  Index [indx_explain_position_header_111]    Script Date: 06/20/2011 09:19:56 ******/
CREATE NONCLUSTERED INDEX [indx_explain_position_header_111] ON [dbo].[explain_position_header] 
(
	[as_of_date_from] ASC,
	[as_of_date_to] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
 
 
IF object_id('explain_position_detail') IS NOT NULL
DROP TABLE dbo.explain_position_detail
go

CREATE TABLE [dbo].[explain_position_detail](
	[rowid] [bigint] NULL,
	[master_rowid] [bigint] NULL,
	[term_date] [datetime] NULL,
	[expiration_date] [datetime] NULL,
	[Hr] [tinyint] NULL,
	[OB_Volume] [numeric](38, 20) NULL,
	[delta1] [numeric](38, 20) NULL,
	[delta2] [numeric](38, 20) NULL,
	[delta3] [numeric](38, 20) NULL,
	[delta4] [numeric](38, 20) NULL,
	[delta5] [numeric](38, 20) NULL,
	[CB_Volume] [numeric](38, 20) NULL
) ON [PRIMARY]

GO


/****** Object:  Index [IX_explain_position_detail]    Script Date: 06/20/2011 09:20:05 ******/
CREATE UNIQUE CLUSTERED INDEX [IX_explain_position_detail] ON [dbo].[explain_position_detail] 
(
	[master_rowid] ASC,
	[term_date] ASC,
	[Hr] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
 