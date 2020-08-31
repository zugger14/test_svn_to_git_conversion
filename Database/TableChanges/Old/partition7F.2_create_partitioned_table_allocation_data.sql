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
GO
--SP_RENAME mv90_data_mins , mv90_data_mins_non_part
GO
--SP_RENAME mv90_data_hour , mv90_data_hour_non_part
GO
--SP_RENAME mv90_data , mv90_data_non_part
GO

IF OBJECT_ID(N'[dbo].[mv90_data_mins]', N'U') IS NULL

CREATE TABLE [dbo].[mv90_data_mins](
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
) ON  ps_allocation_mins(prod_date)

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
IF OBJECT_ID(N'[dbo].[mv90_data_hour]', N'U') IS NULL
CREATE TABLE [dbo].[mv90_data_hour](
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
) ON ps_allocation_hour(prod_date)

GO

SET ANSI_PADDING OFF
GO


/****** Object:  Index [indx_mv90_data_hour]    Script Date: 03/20/2012 15:23:38 ******/
CREATE NONCLUSTERED INDEX [indx_mv90_data_hour1] ON [dbo].[mv90_data_hour] 
(
	[meter_data_id] ASC,
	[prod_date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON ps_allocation_hour(prod_date)
GO


------------------Creating partitioned table mv90_data

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[mv90_data]', N'U') IS NULL

CREATE TABLE [dbo].[mv90_data](
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
) ON ps_allocation_data(gen_date)

GO

SET ANSI_PADDING OFF
GO


/****** Object:  Index [indx_mv90_data1]    Script Date: 03/20/2012 15:21:26 ******/
CREATE NONCLUSTERED INDEX [indx_mv90_data11] ON [dbo].[mv90_data] 
(
	[meter_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON ps_allocation_data(gen_date)
GO


/****** Object:  Index [indx_mv90_data2]    Script Date: 03/20/2012 15:21:26 ******/
CREATE NONCLUSTERED INDEX [indx_mv90_data21] ON [dbo].[mv90_data] 
(
	[gen_date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON ps_allocation_data(gen_date)
GO


/****** Object:  Index [indx_mv90_data3]    Script Date: 03/20/2012 15:21:26 ******/
CREATE NONCLUSTERED INDEX [indx_mv90_data31] ON [dbo].[mv90_data] 
(
	[from_date] ASC,
	[to_date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON ps_allocation_data(gen_date)
GO


/****** Object:  Trigger [dbo].[TRGINS_mv90_data]    Script Date: 03/20/2012 15:21:26 ******/
SET ANSI_NULLS ON
GO


SET QUOTED_IDENTIFIER ON
GO





CREATE TRIGGER [dbo].[TRGINS_mv90_data]
ON [dbo].[mv90_data]
FOR INSERT
AS
UPDATE mv90_data SET create_user =dbo.FNADBUser(), create_ts = getdate() where  mv90_data.meter_data_id in (select meter_data_id from inserted)




GO


/****** Object:  Trigger [dbo].[TRGUPD_mv90_data]    Script Date: 03/20/2012 15:21:26 ******/
SET ANSI_NULLS ON
GO


SET QUOTED_IDENTIFIER ON
GO





CREATE TRIGGER [dbo].[TRGUPD_mv90_data]
ON [dbo].[mv90_data]
FOR UPDATE
AS
UPDATE mv90_data SET update_user =dbo.FNADBUser(), update_ts = getdate() where  mv90_data.meter_data_id in (select meter_data_id from deleted)




GO

---------Importing Data from non partitioned table to partitioned table 

SET IDENTITY_INSERT mv90_data_mins ON
INSERT INTO mv90_data_mins (recid, meter_data_id, prod_date, Hr1_15, Hr1_30, Hr1_45, Hr1_60, Hr2_15, Hr2_30, Hr2_45, Hr2_60, Hr3_15, Hr3_30, Hr3_45, Hr3_60, Hr4_15, Hr4_30, Hr4_45, Hr4_60, Hr5_15, Hr5_30, Hr5_45, Hr5_60, Hr6_15, Hr6_30, Hr6_45, Hr6_60, Hr7_15, Hr7_30, Hr7_45, Hr7_60, Hr8_15, Hr8_30, Hr8_45, Hr8_60, Hr9_15, Hr9_30, Hr9_45, Hr9_60, Hr10_15, Hr10_30, Hr10_45, Hr10_60, Hr11_15, Hr11_30, Hr11_45, Hr11_60, Hr12_15, Hr12_30, Hr12_45, Hr12_60, Hr13_15, Hr13_30, Hr13_45, Hr13_60, Hr14_15, Hr14_30, Hr14_45, Hr14_60, Hr15_15, Hr15_30, Hr15_45, Hr15_60, Hr16_15, Hr16_30, Hr16_45, Hr16_60, Hr17_15, Hr17_30, Hr17_45, Hr17_60, Hr18_15, Hr18_30, Hr18_45, Hr18_60, Hr19_15, Hr19_30, Hr19_45, Hr19_60, Hr20_15, Hr20_30, Hr20_45, Hr20_60, Hr21_15, Hr21_30, Hr21_45, Hr21_60, Hr22_15, Hr22_30, Hr22_45, Hr22_60, Hr23_15, Hr23_30, Hr23_45, Hr23_60, Hr24_15, Hr24_30, Hr24_45, Hr24_60, uom_id, data_missing, proxy_date, source_deal_header_id, Hr25_15, Hr25_30, Hr25_45, Hr25_60)
SELECT recid, meter_data_id, prod_date, Hr1_15, Hr1_30, Hr1_45, Hr1_60, Hr2_15, Hr2_30, Hr2_45, Hr2_60, Hr3_15, Hr3_30, Hr3_45, Hr3_60, Hr4_15, Hr4_30, Hr4_45, Hr4_60, Hr5_15, Hr5_30, Hr5_45, Hr5_60, Hr6_15, Hr6_30, Hr6_45, Hr6_60, Hr7_15, Hr7_30, Hr7_45, Hr7_60, Hr8_15, Hr8_30, Hr8_45, Hr8_60, Hr9_15, Hr9_30, Hr9_45, Hr9_60, Hr10_15, Hr10_30, Hr10_45, Hr10_60, Hr11_15, Hr11_30, Hr11_45, Hr11_60, Hr12_15, Hr12_30, Hr12_45, Hr12_60, Hr13_15, Hr13_30, Hr13_45, Hr13_60, Hr14_15, Hr14_30, Hr14_45, Hr14_60, Hr15_15, Hr15_30, Hr15_45, Hr15_60, Hr16_15, Hr16_30, Hr16_45, Hr16_60, Hr17_15, Hr17_30, Hr17_45, Hr17_60, Hr18_15, Hr18_30, Hr18_45, Hr18_60, Hr19_15, Hr19_30, Hr19_45, Hr19_60, Hr20_15, Hr20_30, Hr20_45, Hr20_60, Hr21_15, Hr21_30, Hr21_45, Hr21_60, Hr22_15, Hr22_30, Hr22_45, Hr22_60, Hr23_15, Hr23_30, Hr23_45, Hr23_60, Hr24_15, Hr24_30, Hr24_45, Hr24_60, uom_id, data_missing, proxy_date, source_deal_header_id, Hr25_15, Hr25_30, Hr25_45, Hr25_60 
FROM mv90_data_mins_non_part
SET IDENTITY_INSERT mv90_data_mins OFF
 
GO
SET IDENTITY_INSERT mv90_data_hour ON 
INSERT INTO mv90_data_hour (recid, meter_data_id, prod_date, Hr1, Hr2, Hr3, Hr4, Hr5, Hr6, Hr7, Hr8, Hr9, Hr10, Hr11, Hr12, Hr13, Hr14, Hr15, Hr16, Hr17, Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, uom_id, data_missing, proxy_date, source_deal_header_id, Hr25)
SELECT recid, meter_data_id, prod_date, Hr1, Hr2, Hr3, Hr4, Hr5, Hr6, Hr7, Hr8, Hr9, Hr10, Hr11, Hr12, Hr13, Hr14, Hr15, Hr16, Hr17, Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, uom_id, data_missing, proxy_date, source_deal_header_id, Hr25
 FROM mv90_data_hour_non_part
SET IDENTITY_INSERT mv90_data_hour OFF
GO
SET IDENTITY_INSERT mv90_data ON
INSERT INTO mv90_data (meter_data_id, meter_id, gen_date, from_date, to_date, channel, volume, uom_id, descriptions, create_user, create_ts, update_user, update_ts)
SELECT meter_data_id, meter_id, gen_date, from_date, to_date, channel, volume, uom_id, descriptions, create_user, create_ts, update_user, update_ts 
FROM mv90_data_non_part
SET IDENTITY_INSERT mv90_data OFF 

SET ANSI_PADDING OFF
GO


