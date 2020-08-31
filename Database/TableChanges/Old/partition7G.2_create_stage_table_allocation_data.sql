-- ===============================================================================================================
-- Create date: 2012-03-01
-- Description:	This script will create partitioned stage table source_price_curve
-- ===============================================================================================================


----Creating stage table for mv90_data_mins

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stage_mv90_data_mins]') AND type in (N'U'))

CREATE TABLE [dbo].[stage_mv90_data_mins](
	[recid] [int] IDENTITY(1,1) NOT NULL,
	[meter_data_id] [int] NOT NULL,
	[prod_date] [datetime] NULL,
	[Hr1_15] [float] NULL,
	[Hr1_30] [float] NULL,
	[Hr1_45] [float] NULL,
	[Hr1_60] [float] NULL,
	[Hr2_15] [float] NULL,
	[Hr2_30] [float] NULL,
	[Hr2_45] [float] NULL,
	[Hr2_60] [float] NULL,
	[Hr3_15] [float] NULL,
	[Hr3_30] [float] NULL,
	[Hr3_45] [float] NULL,
	[Hr3_60] [float] NULL,
	[Hr4_15] [float] NULL,
	[Hr4_30] [float] NULL,
	[Hr4_45] [float] NULL,
	[Hr4_60] [float] NULL,
	[Hr5_15] [float] NULL,
	[Hr5_30] [float] NULL,
	[Hr5_45] [float] NULL,
	[Hr5_60] [float] NULL,
	[Hr6_15] [float] NULL,
	[Hr6_30] [float] NULL,
	[Hr6_45] [float] NULL,
	[Hr6_60] [float] NULL,
	[Hr7_15] [float] NULL,
	[Hr7_30] [float] NULL,
	[Hr7_45] [float] NULL,
	[Hr7_60] [float] NULL,
	[Hr8_15] [float] NULL,
	[Hr8_30] [float] NULL,
	[Hr8_45] [float] NULL,
	[Hr8_60] [float] NULL,
	[Hr9_15] [float] NULL,
	[Hr9_30] [float] NULL,
	[Hr9_45] [float] NULL,
	[Hr9_60] [float] NULL,
	[Hr10_15] [float] NULL,
	[Hr10_30] [float] NULL,
	[Hr10_45] [float] NULL,
	[Hr10_60] [float] NULL,
	[Hr11_15] [float] NULL,
	[Hr11_30] [float] NULL,
	[Hr11_45] [float] NULL,
	[Hr11_60] [float] NULL,
	[Hr12_15] [float] NULL,
	[Hr12_30] [float] NULL,
	[Hr12_45] [float] NULL,
	[Hr12_60] [float] NULL,
	[Hr13_15] [float] NULL,
	[Hr13_30] [float] NULL,
	[Hr13_45] [float] NULL,
	[Hr13_60] [float] NULL,
	[Hr14_15] [float] NULL,
	[Hr14_30] [float] NULL,
	[Hr14_45] [float] NULL,
	[Hr14_60] [float] NULL,
	[Hr15_15] [float] NULL,
	[Hr15_30] [float] NULL,
	[Hr15_45] [float] NULL,
	[Hr15_60] [float] NULL,
	[Hr16_15] [float] NULL,
	[Hr16_30] [float] NULL,
	[Hr16_45] [float] NULL,
	[Hr16_60] [float] NULL,
	[Hr17_15] [float] NULL,
	[Hr17_30] [float] NULL,
	[Hr17_45] [float] NULL,
	[Hr17_60] [float] NULL,
	[Hr18_15] [float] NULL,
	[Hr18_30] [float] NULL,
	[Hr18_45] [float] NULL,
	[Hr18_60] [float] NULL,
	[Hr19_15] [float] NULL,
	[Hr19_30] [float] NULL,
	[Hr19_45] [float] NULL,
	[Hr19_60] [float] NULL,
	[Hr20_15] [float] NULL,
	[Hr20_30] [float] NULL,
	[Hr20_45] [float] NULL,
	[Hr20_60] [float] NULL,
	[Hr21_15] [float] NULL,
	[Hr21_30] [float] NULL,
	[Hr21_45] [float] NULL,
	[Hr21_60] [float] NULL,
	[Hr22_15] [float] NULL,
	[Hr22_30] [float] NULL,
	[Hr22_45] [float] NULL,
	[Hr22_60] [float] NULL,
	[Hr23_15] [float] NULL,
	[Hr23_30] [float] NULL,
	[Hr23_45] [float] NULL,
	[Hr23_60] [float] NULL,
	[Hr24_15] [float] NULL,
	[Hr24_30] [float] NULL,
	[Hr24_45] [float] NULL,
	[Hr24_60] [float] NULL,
	[uom_id] [int] NULL,
	[data_missing] [char](1) NULL,
	[proxy_date] [datetime] NULL,
	[source_deal_header_id] [int] NULL,
	[Hr25_15] [float] NULL,
	[Hr25_30] [float] NULL,
	[Hr25_45] [float] NULL,
	[Hr25_60] [float] NULL
) ON  PS_allocation_mins(prod_date)

GO

SET ANSI_PADDING OFF
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
---- creating stage table for mv90_data_hour
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stage_mv90_data_hour]') AND type in (N'U'))

CREATE TABLE [dbo].[stage_mv90_data_hour](
	[recid] [int] IDENTITY(1,1) NOT NULL,
	[meter_data_id] [int] NOT NULL,
	[prod_date] [datetime] NULL,
	[Hr1] [float] NULL,
	[Hr2] [float] NULL,
	[Hr3] [float] NULL,
	[Hr4] [float] NULL,
	[Hr5] [float] NULL,
	[Hr6] [float] NULL,
	[Hr7] [float] NULL,
	[Hr8] [float] NULL,
	[Hr9] [float] NULL,
	[Hr10] [float] NULL,
	[Hr11] [float] NULL,
	[Hr12] [float] NULL,
	[Hr13] [float] NULL,
	[Hr14] [float] NULL,
	[Hr15] [float] NULL,
	[Hr16] [float] NULL,
	[Hr17] [float] NULL,
	[Hr18] [float] NULL,
	[Hr19] [float] NULL,
	[Hr20] [float] NULL,
	[Hr21] [float] NULL,
	[Hr22] [float] NULL,
	[Hr23] [float] NULL,
	[Hr24] [float] NULL,
	[uom_id] [int] NULL,
	[data_missing] [char](1) NULL,
	[proxy_date] [datetime] NULL,
	[source_deal_header_id] [int] NULL,
	[Hr25] [float] NULL
) ON ps_allocation_hour(prod_date)

GO

SET ANSI_PADDING OFF
GO


/****** Object:  Index [indx_stage_mv90_data_hour]    Script Date: 03/20/2012 15:23:38 ******/
CREATE NONCLUSTERED INDEX [indx_stage_mv90_data_hour] ON [dbo].[stage_mv90_data_hour] 
(
	[meter_data_id] ASC,
	[prod_date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON ps_allocation_hour(prod_date)
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
--- creating stage table for mv90_data 
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stage_mv90_data]') AND type in (N'U'))

CREATE TABLE [dbo].[stage_mv90_data](
	[meter_data_id] [int] IDENTITY(1,1) NOT NULL,
	[meter_id] [int] NOT NULL,
	[gen_date] [datetime] NOT NULL,
	[from_date] [datetime] NOT NULL,
	[to_date] [datetime] NOT NULL,
	[channel] [int] NOT NULL,
	[volume] [float]  NOT NULL,
	[uom_id] [int] NULL,
	[descriptions] [varchar](500) NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL
) ON ps_allocation_data(gen_date)

GO

SET ANSI_PADDING OFF
GO


/****** Object:  Index [indx_mv90_data1]    Script Date: 03/20/2012 15:21:26 ******/
CREATE NONCLUSTERED INDEX [indx_mv90_data1stage] ON [dbo].[stage_mv90_data] 
(
	[meter_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON ps_allocation_data(gen_date)
GO


/****** Object:  Index [indx_mv90_data2]    Script Date: 03/20/2012 15:21:26 ******/
CREATE NONCLUSTERED INDEX [indx_mv90_data2stage] ON [dbo].[stage_mv90_data] 
(
	[gen_date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON ps_allocation_data(gen_date)
GO


/****** Object:  Index [indx_mv90_data3]    Script Date: 03/20/2012 15:21:26 ******/
CREATE NONCLUSTERED INDEX [indx_mv90_data3stage] ON [dbo].[stage_mv90_data] 
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





CREATE TRIGGER [dbo].[TRGINS_stage_mv90_data]
ON [dbo].[stage_mv90_data]
FOR INSERT
AS
UPDATE mv90_data SET create_user =dbo.FNADBUser(), create_ts = getdate() where  mv90_data.meter_data_id in (select meter_data_id from inserted)




GO


/****** Object:  Trigger [dbo].[TRGUPD_mv90_data]    Script Date: 03/20/2012 15:21:26 ******/
SET ANSI_NULLS ON
GO


SET QUOTED_IDENTIFIER ON
GO





CREATE TRIGGER [dbo].[TRGUPD_stage_mv90_data]
ON [dbo].[stage_mv90_data]
FOR UPDATE
AS
UPDATE mv90_data SET update_user =dbo.FNADBUser(), update_ts = getdate() where  mv90_data.meter_data_id in (select meter_data_id from deleted)




GO