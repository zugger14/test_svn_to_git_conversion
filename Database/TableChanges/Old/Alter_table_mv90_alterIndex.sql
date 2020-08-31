

IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[mv90_data_hour]') AND name = N'indx_mv90_data_hour')
	DROP Index [indx_mv90_data_hour] ON [dbo].[mv90_data_hour] 

CREATE UNIQUE CLUSTERED INDEX [indx_mv90_data_hour] ON [dbo].[mv90_data_hour] 
(
	[meter_data_id] ASC,
	[prod_date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[mv90_data]') AND name = N'indx_mv90_data1')
	DROP Index [indx_mv90_data1] ON [dbo].[mv90_data] 

CREATE UNIQUE CLUSTERED INDEX [indx_mv90_data1] ON [dbo].[mv90_data] 
(
	[meter_id] ASC,
	[from_date] ASC,
	[channel] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO


IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[mv90_data]') AND name = N'indx_mv90_data2')
	DROP Index [indx_mv90_data2] ON [dbo].[mv90_data] 

IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[mv90_data]') AND name = N'indx_mv90_data3')
	DROP Index [indx_mv90_data3] ON [dbo].[mv90_data] 