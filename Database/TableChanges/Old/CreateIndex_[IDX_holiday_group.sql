IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[holiday_group]') AND name = N'IDX_holiday_group')
DROP INDEX [IDX_holiday_group] ON [dbo].[holiday_group] 

GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[holiday_group]') AND name = N'IDX_holiday_group')
CREATE UNIQUE NONCLUSTERED INDEX [IDX_holiday_group] ON [dbo].[holiday_group] 
(
	[hol_group_value_id] ASC,
	[hol_date] ASC,
	[exp_date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO