IF EXISTS (SELECT * FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[forecast_profile]') AND name = N'IX_forecast_profile')
	DROP INDEX [IX_forecast_profile] ON [dbo].[forecast_profile] 
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[forecast_profile]') AND name = N'IX_forecast_profile')
CREATE UNIQUE NONCLUSTERED INDEX [IX_forecast_profile] ON [dbo].[forecast_profile] 
(
	[external_id] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
