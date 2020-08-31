-- ===============================================================================================================
-- Create date:2012-03-01
-- Description:	This script will rename existing all tables of allocation data  to allocation-data_non_part.
--  It will then create partitioned table and insert data from non_partitioned table
-- ===============================================================================================================

/****** Object:  Table [dbo].[source_price_curve]    Script Date: 02/10/2012 11:08:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON

IF OBJECT_ID(N'[dbo].[mv90_data_mins_arch1]', N'U') IS NULL

CREATE TABLE [dbo].[mv90_data_mins_arch1](
	[recid]					INT  IDENTITY(1,1)	NOT NULL,
	[meter_data_id]			INT					NOT NULL,
	[prod_date]				DATETIME			NULL,
	[Hr1_15]				FLOAT				NULL,
	[Hr1_30]				FLOAT				NULL,
	[Hr1_45]				FLOAT				NULL,
	[Hr1_60]				FLOAT				NULL,
	[Hr2_15]				FLOAT				NULL,
	[Hr2_30]				FLOAT				NULL,
	[Hr2_45]				FLOAT				NULL,
	[Hr2_60]				FLOAT				NULL,
	[Hr3_15]				FLOAT				NULL,
	[Hr3_30]				FLOAT				NULL,
	[Hr3_45]				FLOAT				NULL,
	[Hr3_60]				FLOAT				NULL,
	[Hr4_15]				FLOAT				NULL,
	[Hr4_30]				FLOAT				NULL,
	[Hr4_45]				FLOAT				NULL,
	[Hr4_60]				FLOAT				NULL,
	[Hr5_15]				FLOAT				NULL,
	[Hr5_30]				FLOAT				NULL,
	[Hr5_45]				FLOAT				NULL,
	[Hr5_60]				FLOAT				NULL,
	[Hr6_15]				FLOAT				NULL,
	[Hr6_30]				FLOAT				NULL,
	[Hr6_45]				FLOAT				NULL,
	[Hr6_60]				FLOAT				NULL,
	[Hr7_15]				FLOAT				NULL,
	[Hr7_30]				FLOAT				NULL,
	[Hr7_45]				FLOAT				NULL,
	[Hr7_60]				FLOAT				NULL,
	[Hr8_15]				FLOAT				NULL,
	[Hr8_30]				FLOAT				NULL,
	[Hr8_45]				FLOAT				NULL,
	[Hr8_60]				FLOAT				NULL,
	[Hr9_15]				FLOAT				NULL,
	[Hr9_30]				FLOAT				NULL,
	[Hr9_45]				FLOAT				NULL,
	[Hr9_60]				FLOAT				NULL,
	[Hr10_15]				FLOAT				NULL,
	[Hr10_30]				FLOAT				NULL,
	[Hr10_45]				FLOAT				NULL,
	[Hr10_60]				FLOAT				NULL,
	[Hr11_15]				FLOAT				NULL,
	[Hr11_30]				FLOAT				NULL,
	[Hr11_45]				FLOAT				NULL,
	[Hr11_60]				FLOAT				NULL,
	[Hr12_15]				FLOAT				NULL,
	[Hr12_30]				FLOAT				NULL,
	[Hr12_45]				FLOAT				NULL,
	[Hr12_60]				FLOAT				NULL,
	[Hr13_15]				FLOAT				NULL,
	[Hr13_30]				FLOAT				NULL,
	[Hr13_45]				FLOAT				NULL,
	[Hr13_60]				FLOAT				NULL,
	[Hr14_15]				FLOAT				NULL,
	[Hr14_30]				FLOAT				NULL,
	[Hr14_45]				FLOAT				NULL,
	[Hr14_60]				FLOAT				NULL,
	[Hr15_15]				FLOAT				NULL,
	[Hr15_30]				FLOAT				NULL,
	[Hr15_45]				FLOAT				NULL,
	[Hr15_60]				FLOAT				NULL,
	[Hr16_15]				FLOAT				NULL,
	[Hr16_30]				FLOAT				NULL,
	[Hr16_45]				FLOAT				NULL,
	[Hr16_60]				FLOAT				NULL,
	[Hr17_15]				FLOAT				NULL,
	[Hr17_30]				FLOAT				NULL,
	[Hr17_45]				FLOAT				NULL,
	[Hr17_60]				FLOAT				NULL,
	[Hr18_15]				FLOAT				NULL,
	[Hr18_30]				FLOAT				NULL,
	[Hr18_45]				FLOAT				NULL,
	[Hr18_60]				FLOAT				NULL,
	[Hr19_15]				FLOAT				NULL,
	[Hr19_30]				FLOAT				NULL,
	[Hr19_45]				FLOAT				NULL,
	[Hr19_60]				FLOAT				NULL,
	[Hr20_15]				FLOAT				NULL,
	[Hr20_30]				FLOAT				NULL,
	[Hr20_45]				FLOAT				NULL,
	[Hr20_60]				FLOAT				NULL,
	[Hr21_15]				FLOAT				NULL,
	[Hr21_30]				FLOAT				NULL,
	[Hr21_45]				FLOAT				NULL,
	[Hr21_60]				FLOAT				NULL,
	[Hr22_15]				FLOAT				NULL,
	[Hr22_30]				FLOAT				NULL,
	[Hr22_45]				FLOAT				NULL,
	[Hr22_60]				FLOAT				NULL,
	[Hr23_15]				FLOAT				NULL,
	[Hr23_30]				FLOAT				NULL,
	[Hr23_45]				FLOAT				NULL,
	[Hr23_60]				FLOAT				NULL,
	[Hr24_15]				FLOAT				NULL,
	[Hr24_30]				FLOAT				NULL,
	[Hr24_45]				FLOAT				NULL,
	[Hr24_60]				FLOAT				NULL,
	[uom_id]				INT					NULL,
	[data_missing]			CHAR(1)				NULL,
	[proxy_date]			DATETIME			NULL,
	[source_deal_header_id] INT					NULL,
	[Hr25_15]				FLOAT				NULL,
	[Hr25_30]				FLOAT				NULL,
	[Hr25_45]				FLOAT				NULL,
	[Hr25_60]				FLOAT				NULL
) 

GO

SET ANSI_PADDING OFF
GO
IF OBJECT_ID(N'[dbo].[mv90_data_mins_arch2]', N'U') IS NULL

CREATE TABLE [dbo].[mv90_data_mins_arch2](
	[recid]					INT  IDENTITY(1,1)	NOT NULL,
	[meter_data_id]			INT					NOT NULL,
	[prod_date]				DATETIME			NULL,
	[Hr1_15]				FLOAT				NULL,
	[Hr1_30]				FLOAT				NULL,
	[Hr1_45]				FLOAT				NULL,
	[Hr1_60]				FLOAT				NULL,
	[Hr2_15]				FLOAT				NULL,
	[Hr2_30]				FLOAT				NULL,
	[Hr2_45]				FLOAT				NULL,
	[Hr2_60]				FLOAT				NULL,
	[Hr3_15]				FLOAT				NULL,
	[Hr3_30]				FLOAT				NULL,
	[Hr3_45]				FLOAT				NULL,
	[Hr3_60]				FLOAT				NULL,
	[Hr4_15]				FLOAT				NULL,
	[Hr4_30]				FLOAT				NULL,
	[Hr4_45]				FLOAT				NULL,
	[Hr4_60]				FLOAT				NULL,
	[Hr5_15]				FLOAT				NULL,
	[Hr5_30]				FLOAT				NULL,
	[Hr5_45]				FLOAT				NULL,
	[Hr5_60]				FLOAT				NULL,
	[Hr6_15]				FLOAT				NULL,
	[Hr6_30]				FLOAT				NULL,
	[Hr6_45]				FLOAT				NULL,
	[Hr6_60]				FLOAT				NULL,
	[Hr7_15]				FLOAT				NULL,
	[Hr7_30]				FLOAT				NULL,
	[Hr7_45]				FLOAT				NULL,
	[Hr7_60]				FLOAT				NULL,
	[Hr8_15]				FLOAT				NULL,
	[Hr8_30]				FLOAT				NULL,
	[Hr8_45]				FLOAT				NULL,
	[Hr8_60]				FLOAT				NULL,
	[Hr9_15]				FLOAT				NULL,
	[Hr9_30]				FLOAT				NULL,
	[Hr9_45]				FLOAT				NULL,
	[Hr9_60]				FLOAT				NULL,
	[Hr10_15]				FLOAT				NULL,
	[Hr10_30]				FLOAT				NULL,
	[Hr10_45]				FLOAT				NULL,
	[Hr10_60]				FLOAT				NULL,
	[Hr11_15]				FLOAT				NULL,
	[Hr11_30]				FLOAT				NULL,
	[Hr11_45]				FLOAT				NULL,
	[Hr11_60]				FLOAT				NULL,
	[Hr12_15]				FLOAT				NULL,
	[Hr12_30]				FLOAT				NULL,
	[Hr12_45]				FLOAT				NULL,
	[Hr12_60]				FLOAT				NULL,
	[Hr13_15]				FLOAT				NULL,
	[Hr13_30]				FLOAT				NULL,
	[Hr13_45]				FLOAT				NULL,
	[Hr13_60]				FLOAT				NULL,
	[Hr14_15]				FLOAT				NULL,
	[Hr14_30]				FLOAT				NULL,
	[Hr14_45]				FLOAT				NULL,
	[Hr14_60]				FLOAT				NULL,
	[Hr15_15]				FLOAT				NULL,
	[Hr15_30]				FLOAT				NULL,
	[Hr15_45]				FLOAT				NULL,
	[Hr15_60]				FLOAT				NULL,
	[Hr16_15]				FLOAT				NULL,
	[Hr16_30]				FLOAT				NULL,
	[Hr16_45]				FLOAT				NULL,
	[Hr16_60]				FLOAT				NULL,
	[Hr17_15]				FLOAT				NULL,
	[Hr17_30]				FLOAT				NULL,
	[Hr17_45]				FLOAT				NULL,
	[Hr17_60]				FLOAT				NULL,
	[Hr18_15]				FLOAT				NULL,
	[Hr18_30]				FLOAT				NULL,
	[Hr18_45]				FLOAT				NULL,
	[Hr18_60]				FLOAT				NULL,
	[Hr19_15]				FLOAT				NULL,
	[Hr19_30]				FLOAT				NULL,
	[Hr19_45]				FLOAT				NULL,
	[Hr19_60]				FLOAT				NULL,
	[Hr20_15]				FLOAT				NULL,
	[Hr20_30]				FLOAT				NULL,
	[Hr20_45]				FLOAT				NULL,
	[Hr20_60]				FLOAT				NULL,
	[Hr21_15]				FLOAT				NULL,
	[Hr21_30]				FLOAT				NULL,
	[Hr21_45]				FLOAT				NULL,
	[Hr21_60]				FLOAT				NULL,
	[Hr22_15]				FLOAT				NULL,
	[Hr22_30]				FLOAT				NULL,
	[Hr22_45]				FLOAT				NULL,
	[Hr22_60]				FLOAT				NULL,
	[Hr23_15]				FLOAT				NULL,
	[Hr23_30]				FLOAT				NULL,
	[Hr23_45]				FLOAT				NULL,
	[Hr23_60]				FLOAT				NULL,
	[Hr24_15]				FLOAT				NULL,
	[Hr24_30]				FLOAT				NULL,
	[Hr24_45]				FLOAT				NULL,
	[Hr24_60]				FLOAT				NULL,
	[uom_id]				INT					NULL,
	[data_missing]			CHAR(1)				NULL,
	[proxy_date]			DATETIME			NULL,
	[source_deal_header_id] INT					NULL,
	[Hr25_15]				FLOAT				NULL,
	[Hr25_30]				FLOAT				NULL,
	[Hr25_45]				FLOAT				NULL,
	[Hr25_60]				FLOAT				NULL
) 

GO

SET ANSI_PADDING OFF
GO


--------------Creating Partitioned table mv90_data_hour
/****** Object:  Table [dbo].[mv90_data_hour]    Script Date: 03/20/2012 15:23:38 ******/


/****** Object:  Table [dbo].[mv90_data_hour]    Script Date: 03/20/2012 15:23:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[mv90_data_hour_arch1]', N'U') IS NULL
CREATE TABLE [dbo].[mv90_data_hour_arch1](
	[recid]					INT	IDENTITY(1,1)	NOT NULL,
	[meter_data_id]			INT					NOT NULL,
	[prod_date]				DATETIME			NULL,
	[Hr1]					FLOAT				NULL,
	[Hr2]					FLOAT				NULL,
	[Hr3]					FLOAT				NULL,
	[Hr4]					FLOAT				NULL,
	[Hr5]					FLOAT				NULL,
	[Hr6]					FLOAT				NULL,
	[Hr7]					FLOAT				NULL,
	[Hr8]					FLOAT				NULL,
	[Hr9]					FLOAT				NULL,
	[Hr10]					FLOAT				NULL,
	[Hr11]					FLOAT				NULL,
	[Hr12]					FLOAT				NULL,
	[Hr13]					FLOAT				NULL,
	[Hr14]					FLOAT				NULL,
	[Hr15]					FLOAT				NULL,
	[Hr16]					FLOAT				NULL,
	[Hr17]					FLOAT				NULL,
	[Hr18]					FLOAT				NULL,
	[Hr19]					FLOAT				NULL,
	[Hr20]					FLOAT				NULL,
	[Hr21]					FLOAT				NULL,
	[Hr22]					FLOAT				NULL,
	[Hr23]					FLOAT				NULL,
	[Hr24]					FLOAT				NULL,
	[uom_id]				INT					NULL,
	[data_missing]			CHAR(1)				NULL,
	[proxy_date]			DATETIME			NULL,
	[source_deal_header_id] INT				NULL,
	[Hr25]					FLOAT			NULL
) 

GO

SET ANSI_PADDING OFF
GO


/****** Object:  Index [indx_mv90_data_hour]    Script Date: 03/20/2012 15:23:38 ******/
CREATE NONCLUSTERED INDEX [indx_mv90_data_hour1_arch1] ON [dbo].[mv90_data_hour_arch1] 
(
	[meter_data_id] ASC,
	[prod_date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90)
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[mv90_data_hour_arch2]', N'U') IS NULL
CREATE TABLE [dbo].[mv90_data_hour_arch2](
	[recid]					INT	IDENTITY(1,1)	NOT NULL,
	[meter_data_id]			INT					NOT NULL,
	[prod_date]				DATETIME			NULL,
	[Hr1]					FLOAT				NULL,
	[Hr2]					FLOAT				NULL,
	[Hr3]					FLOAT				NULL,
	[Hr4]					FLOAT				NULL,
	[Hr5]					FLOAT				NULL,
	[Hr6]					FLOAT				NULL,
	[Hr7]					FLOAT				NULL,
	[Hr8]					FLOAT				NULL,
	[Hr9]					FLOAT				NULL,
	[Hr10]					FLOAT				NULL,
	[Hr11]					FLOAT				NULL,
	[Hr12]					FLOAT				NULL,
	[Hr13]					FLOAT				NULL,
	[Hr14]					FLOAT				NULL,
	[Hr15]					FLOAT				NULL,
	[Hr16]					FLOAT				NULL,
	[Hr17]					FLOAT				NULL,
	[Hr18]					FLOAT				NULL,
	[Hr19]					FLOAT				NULL,
	[Hr20]					FLOAT				NULL,
	[Hr21]					FLOAT				NULL,
	[Hr22]					FLOAT				NULL,
	[Hr23]					FLOAT				NULL,
	[Hr24]					FLOAT				NULL,
	[uom_id]				INT					NULL,
	[data_missing]			CHAR(1)				NULL,
	[proxy_date]			DATETIME			NULL,
	[source_deal_header_id] INT					NULL,
	[Hr25]					FLOAT				NULL
) 

GO

SET ANSI_PADDING OFF
GO


/****** Object:  Index [indx_mv90_data_hour]    Script Date: 03/20/2012 15:23:38 ******/
CREATE NONCLUSTERED INDEX [indx_mv90_data_hour1_arch2] ON [dbo].[mv90_data_hour_arch2] 
(
	[meter_data_id] ASC,
	[prod_date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) 
GO


------------------Creating partitioned table mv90_data

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[mv90_data_arch1]', N'U') IS NULL

CREATE TABLE [dbo].[mv90_data_arch1](
	[meter_data_id]		INT		IDENTITY(1,1)	NOT NULL,
	[meter_id]			INT						NOT NULL,
	[gen_date]			DATETIME				NOT NULL,
	[from_date]			DATETIME				NOT NULL,
	[to_date]			DATETIME				NOT NULL,
	[channel]			INT						NOT NULL,
	[volume]			FLOAT					NOT NULL,
	[uom_id]			INT						NULL,
	[descriptions]		VARCHAR(500)			NULL,
	[create_user]		VARCHAR(50)				NULL,
	[create_ts]			DATETIME				NULL,
	[update_user]		VARCHAR(50)				NULL,
	[update_ts]			DATETIME				NULL
) 

GO

SET ANSI_PADDING OFF
GO


/****** Object:  Index [indx_mv90_data1]    Script Date: 03/20/2012 15:21:26 ******/
CREATE NONCLUSTERED INDEX [indx_mv90_data11_arch1] ON [dbo].[mv90_data_arch1] 
(
	[meter_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) 
GO


/****** Object:  Index [indx_mv90_data2]    Script Date: 03/20/2012 15:21:26 ******/
CREATE NONCLUSTERED INDEX [indx_mv90_data21_arch1] ON [dbo].[mv90_data_arch1] 
(
	[gen_date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) 
GO


/****** Object:  Index [indx_mv90_data3]    Script Date: 03/20/2012 15:21:26 ******/
CREATE NONCLUSTERED INDEX [indx_mv90_data31_arch1] ON [dbo].[mv90_data_arch1] 
(
	[from_date] ASC,
	[to_date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) 
GO


/****** Object:  Trigger [dbo].[TRGINS_mv90_data]    Script Date: 03/20/2012 15:21:26 ******/
SET ANSI_NULLS ON
GO


SET QUOTED_IDENTIFIER ON
GO





CREATE TRIGGER [dbo].[TRGINS_mv90_data_arch1]
ON [dbo].[mv90_data_arch1]
FOR INSERT
AS
UPDATE mv90_data_arch1 SET create_user =dbo.FNADBUser(), create_ts = getdate() where  mv90_data_arch1.meter_data_id in (select meter_data_id from inserted)




GO


/****** Object:  Trigger [dbo].[TRGUPD_mv90_data]    Script Date: 03/20/2012 15:21:26 ******/
SET ANSI_NULLS ON
GO


SET QUOTED_IDENTIFIER ON
GO





CREATE TRIGGER [dbo].[TRGUPD_mv90_data_arch1]
ON [dbo].[mv90_data_arch1]
FOR UPDATE
AS
UPDATE mv90_data_arch1 SET update_user =dbo.FNADBUser(), update_ts = getdate() where  mv90_data_arch1.meter_data_id in (select meter_data_id from deleted)

GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[mv90_data_arch2]', N'U') IS NULL

CREATE TABLE [dbo].[mv90_data_arch2](
	[meter_data_id]		INT		IDENTITY(1,1)	NOT NULL,
	[meter_id]			INT						NOT NULL,
	[gen_date]			DATETIME				NOT NULL,
	[from_date]			DATETIME				NOT NULL,
	[to_date]			DATETIME				NOT NULL,
	[channel]			INT						NOT NULL,
	[volume]			FLOAT					NOT NULL,
	[uom_id]			INT						NULL,
	[descriptions]		VARCHAR(500)			NULL,
	[create_user]		VARCHAR(50)				NULL,
	[create_ts]			DATETIME				NULL,
	[update_user]		VARCHAR(50)				NULL,
	[update_ts]			DATETIME				NULL
) 

GO

SET ANSI_PADDING OFF
GO


/****** Object:  Index [indx_mv90_data1]    Script Date: 03/20/2012 15:21:26 ******/
CREATE NONCLUSTERED INDEX [indx_mv90_data11_arch2] ON [dbo].[mv90_data_arch2] 
(
	[meter_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) 
GO


/****** Object:  Index [indx_mv90_data2]    Script Date: 03/20/2012 15:21:26 ******/
CREATE NONCLUSTERED INDEX [indx_mv90_data21_arch2] ON [dbo].[mv90_data_arch2] 
(
	[gen_date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) 
GO


/****** Object:  Index [indx_mv90_data3]    Script Date: 03/20/2012 15:21:26 ******/
CREATE NONCLUSTERED INDEX [indx_mv90_data31_arch2] ON [dbo].[mv90_data_arch2] 
(
	[from_date] ASC,
	[to_date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) 
GO


/****** Object:  Trigger [dbo].[TRGINS_mv90_data]    Script Date: 03/20/2012 15:21:26 ******/
SET ANSI_NULLS ON
GO


SET QUOTED_IDENTIFIER ON
GO





CREATE TRIGGER [dbo].[TRGINS_mv90_data_arch2]
ON [dbo].[mv90_data_arch2]
FOR INSERT
AS
UPDATE mv90_data_arch2 SET create_user =dbo.FNADBUser(), create_ts = getdate() where  mv90_data_arch2.meter_data_id in (select meter_data_id from inserted)




GO


/****** Object:  Trigger [dbo].[TRGUPD_mv90_data]    Script Date: 03/20/2012 15:21:26 ******/
SET ANSI_NULLS ON
GO


SET QUOTED_IDENTIFIER ON
GO





CREATE TRIGGER [dbo].[TRGUPD_mv90_data_arch2]
ON [dbo].[mv90_data_arch2]
FOR UPDATE
AS
UPDATE mv90_data_arch2 SET update_user =dbo.FNADBUser(), update_ts = getdate() where  mv90_data_arch2.meter_data_id in (select meter_data_id from deleted)




GO

SET ANSI_PADDING OFF
GO


