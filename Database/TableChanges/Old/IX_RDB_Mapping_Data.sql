
/****** Object:  Index [IX_RDB_Mapping_Data]    Script Date: 09/13/2011 19:54:05 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[RDB_Mapping_Data]') AND name = N'IX_RDB_Mapping_Data')
DROP INDEX [IX_RDB_Mapping_Data] ON [dbo].[RDB_Mapping_Data] WITH ( ONLINE = OFF )
GO

/****** Object:  Index [IX_RDB_Mapping_Data]    Script Date: 09/13/2011 19:54:05 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_RDB_Mapping_Data] ON [dbo].[RDB_Mapping_Data] 
(
	[map_value_id] ASC,
	[map_value_type] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO


