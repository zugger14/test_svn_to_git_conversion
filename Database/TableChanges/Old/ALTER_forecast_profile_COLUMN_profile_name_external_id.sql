DELETE FROM forecast_profile WHERE profile_name IS NULL OR external_id IS NULL 
ALTER TABLE forecast_profile ALTER COLUMN external_id VARCHAR(50) NOT NULL 
ALTER TABLE forecast_profile ALTER COLUMN profile_name VARCHAR(50) NOT NULL 

IF NOT EXISTS (SELECT * FROM sys.indexes i WHERE NAME LIKE 'IX_forecast_profile')
CREATE UNIQUE NONCLUSTERED INDEX [IX_forecast_profile] ON [dbo].[forecast_profile] 
(
	[external_id] ASC,
	[profile_type] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

