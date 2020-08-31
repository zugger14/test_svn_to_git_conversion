IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[deal_detail_hour]') AND name = N'IX_deal_detail_hour')
DROP INDEX [IX_deal_detail_hour] ON [dbo].[deal_detail_hour] WITH ( ONLINE = OFF )
go

CREATE UNIQUE NONCLUSTERED INDEX [IX_deal_detail_hour] ON [dbo].[deal_detail_hour] 
(
	[source_deal_detail_id] ASC,
	[term_date] ASC,
	[profile_id] ASC,
	[location_id] ASC 
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
[Hr24]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]