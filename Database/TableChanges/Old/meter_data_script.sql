
select * into zzz_meter_id from meter_id
GO
/****** Object:  ForeignKey [FK_meter_id_allocation_meter_id]    Script Date: 03/25/2011 11:37:07 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_meter_id_allocation_meter_id]') AND parent_object_id = OBJECT_ID(N'[dbo].[meter_id_allocation]'))
ALTER TABLE [dbo].[meter_id_allocation] DROP CONSTRAINT [FK_meter_id_allocation_meter_id]
GO
/****** Object:  Table [dbo].[meter_id_allocation]    Script Date: 03/25/2011 11:37:07 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_meter_id_allocation_meter_id]') AND parent_object_id = OBJECT_ID(N'[dbo].[meter_id_allocation]'))
ALTER TABLE [dbo].[meter_id_allocation] DROP CONSTRAINT [FK_meter_id_allocation_meter_id]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[meter_id_allocation]') AND type in (N'U'))
DROP TABLE [dbo].[meter_id_allocation]
GO
/****** Object:  Table [dbo].[meter_id_allocation]    Script Date: 03/25/2011 11:37:07 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Calc_Invoice_Volume_meter_idaaa]') AND parent_object_id = OBJECT_ID(N'[dbo].[Calc_Invoice_Volume_variance_arch2]'))
ALTER TABLE [dbo].[Calc_Invoice_Volume_variance_arch2] DROP CONSTRAINT [FK_Calc_Invoice_Volume_meter_idaaa]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Calc_Invoice_Volume_meter_idbb]') AND parent_object_id = OBJECT_ID(N'[dbo].[Calc_Invoice_Volume_variance_arch1]'))
ALTER TABLE [dbo].[Calc_Invoice_Volume_variance_arch1] DROP CONSTRAINT [FK_Calc_Invoice_Volume_meter_idbb]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_meter_id_channel_meter_id]') AND parent_object_id = OBJECT_ID(N'[dbo].[meter_id_channel]'))
ALTER TABLE [dbo].[meter_id_channel] DROP CONSTRAINT [FK_meter_id_channel_meter_id]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Calc_Invoice_Volume_meter_id]') AND parent_object_id = OBJECT_ID(N'[dbo].[Calc_Invoice_Volume_variance]'))
ALTER TABLE [dbo].[Calc_Invoice_Volume_variance] DROP CONSTRAINT [FK_Calc_Invoice_Volume_meter_id]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_recorder_generator_map_meter_id]') AND parent_object_id = OBJECT_ID(N'[dbo].[recorder_generator_map]'))
ALTER TABLE [dbo].[recorder_generator_map] DROP CONSTRAINT [FK_recorder_generator_map_meter_id]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_recorder_properties_meter_id]') AND parent_object_id = OBJECT_ID(N'[dbo].[recorder_properties]'))
ALTER TABLE [dbo].[recorder_properties] DROP CONSTRAINT [FK_recorder_properties_meter_id]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_recorder_calc_invoice_volume_recorder]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_recorder]'))
ALTER TABLE [dbo].[calc_invoice_volume_recorder] DROP CONSTRAINT [FK_calc_invoice_volume_recorder_calc_invoice_volume_recorder]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_recorder_estimates_calc_invoice_volume_recorder_estimates ]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_recorder_estimates]'))
ALTER TABLE [dbo].[calc_invoice_volume_recorder_estimates] DROP CONSTRAINT [FK_calc_invoice_volume_recorder_estimates_calc_invoice_volume_recorder_estimates ]
GO

/****** Object:  Table [dbo].[meter_id]    Script Date: 03/25/2011 11:37:07 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[meter_id]') AND type in (N'U'))
DROP TABLE [dbo].[meter_id]
GO
/****** Object:  Table [dbo].[meter_id]    Script Date: 03/25/2011 11:37:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[meter_id]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[meter_id](
	[meter_id] [int] IDENTITY(1,1) NOT NULL,
	[recorderid] [varchar](100) NOT NULL,
	[description] [varchar](255) NULL,
	[meter_manufacturer] [varchar](100) NULL,
	[meter_type] [varchar](100) NULL,
	[meter_serial_number] [varchar](100) NULL,
	[meter_certification] [datetime] NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_meter_id] PRIMARY KEY NONCLUSTERED 
(
	[meter_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY],
 CONSTRAINT [IX_meter_id] UNIQUE CLUSTERED 
(
	[recorderid] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[meter_id_allocation]    Script Date: 03/25/2011 11:37:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[meter_id_allocation]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[meter_id_allocation](
	[allocation_id] [int] IDENTITY(1,1) NOT NULL,
	[meter_id] [int] NOT NULL,
	[gre_per] [float] NULL,
	[production_month] [datetime] NULL,
	[gre_volume] [float] NULL,
	[create_user] [char](10) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [char](10) NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_meter_id_allocation] PRIMARY KEY CLUSTERED 
(
	[allocation_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [IX_meter_id_allocation] UNIQUE NONCLUSTERED 
(
	[meter_id] ASC,
	[production_month] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  ForeignKey [FK_meter_id_allocation_meter_id]    Script Date: 03/25/2011 11:37:07 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_meter_id_allocation_meter_id]') AND parent_object_id = OBJECT_ID(N'[dbo].[meter_id_allocation]'))
ALTER TABLE [dbo].[meter_id_allocation]  WITH NOCHECK ADD  CONSTRAINT [FK_meter_id_allocation_meter_id] FOREIGN KEY([meter_id])
REFERENCES [dbo].[meter_id] ([meter_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_meter_id_allocation_meter_id]') AND parent_object_id = OBJECT_ID(N'[dbo].[meter_id_allocation]'))
ALTER TABLE [dbo].[meter_id_allocation] CHECK CONSTRAINT [FK_meter_id_allocation_meter_id]
GO

SET IDENTITY_INSERT meter_id ON
INSERT INTO meter_id(meter_id,recorderid)
SELECT meter_id,recorderid FROM zzz_meter_id
SET IDENTITY_INSERT meter_id OFF
GO
DROP TABLE zzz_meter_id


/****** Object:  Table [dbo].[mv90_data_15mins]    Script Date: 02/23/2011 17:20:53 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[mv90_data_15mins]') AND type in (N'U'))
DROP TABLE [dbo].[mv90_data_15mins]
GO
/****** Object:  Table [dbo].[mv90_data_arch1]    Script Date: 02/23/2011 17:20:53 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[mv90_data_arch1]') AND type in (N'U'))
DROP TABLE [dbo].[mv90_data_arch1]
GO
/****** Object:  Table [dbo].[mv90_data_arch2]    Script Date: 02/23/2011 17:20:53 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[mv90_data_arch2]') AND type in (N'U'))
DROP TABLE [dbo].[mv90_data_arch2]
GO
/****** Object:  Table [dbo].[mv90_data_hour_arch1]    Script Date: 02/23/2011 17:20:53 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[mv90_data_hour_arch1]') AND type in (N'U'))
DROP TABLE [dbo].[mv90_data_hour_arch1]
GO
/****** Object:  Table [dbo].[mv90_data_hour_arch2]    Script Date: 02/23/2011 17:20:53 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[mv90_data_hour_arch2]') AND type in (N'U'))
DROP TABLE [dbo].[mv90_data_hour_arch2]
GO
/****** Object:  Table [dbo].[mv90_data_hour_price]    Script Date: 02/23/2011 17:20:53 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[mv90_data_hour_price]') AND type in (N'U'))
DROP TABLE [dbo].[mv90_data_hour_price]
GO
/****** Object:  Table [dbo].[mv90_data_mins_arch1]    Script Date: 02/23/2011 17:20:53 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[mv90_data_mins_arch1]') AND type in (N'U'))
DROP TABLE [dbo].[mv90_data_mins_arch1]
GO
/****** Object:  Table [dbo].[mv90_data_mins_arch2]    Script Date: 02/23/2011 17:20:53 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[mv90_data_mins_arch2]') AND type in (N'U'))
DROP TABLE [dbo].[mv90_data_mins_arch2]
GO
/****** Object:  Table [dbo].[mv90_data_mins_price]    Script Date: 02/23/2011 17:20:53 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[mv90_data_mins_price]') AND type in (N'U'))
DROP TABLE [dbo].[mv90_data_mins_price]
GO
/****** Object:  Table [dbo].[mv90_data_raw]    Script Date: 02/23/2011 17:21:58 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[mv90_data_raw]') AND type in (N'U'))
DROP TABLE [dbo].[mv90_data_raw]
GO
select * into zzz_mv90_data from mv90_Data

GO
/****** Object:  Table [dbo].[mv90_data]    Script Date: 02/23/2011 17:23:54 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[mv90_data]') AND type in (N'U'))
DROP TABLE [dbo].[mv90_data]
GO
GO
/****** Object:  Table [dbo].[mv90_data]    Script Date: 02/23/2011 17:24:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[mv90_data](
	[meter_data_id][int] identity(1,1),
	[meter_id] [int] NOT NULL,
	[gen_date] [datetime] NOT NULL,
	[from_date] [datetime] NOT NULL,
	[to_date] [datetime] NOT NULL,
	[channel] [int] NOT NULL,
	[volume] [float] NOT NULL,
	[uom_id] [int] NULL,
	[descriptions] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_user] VARCHAR(50),
	[create_ts] DATETIME,
	[update_user] VARCHAR(50),
	[update_ts] DATETIME
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
--INSERT INTO mv90_data(meter_id,[gen_date],[from_date],[to_date],[channel],[volume],[uom_id],[descriptions])
--select md.meter_id,[gen_date],[from_date],[to_date],[channel],[volume],[uom_id],[descriptions] FROM zzz_mv90_data mv LEFT JOIN meter_id md ON mv.recorderid=md.recorderid WHERE md.meter_id IS NOT NULL
GO
DROP TABLE zzz_mv90_data
GO
select * into zzz_mv90_data_hour from mv90_Data_hour

GO
/****** Object:  Table [dbo].[mv90_data_hour]    Script Date: 02/23/2011 17:30:41 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[mv90_data_hour]') AND type in (N'U'))
DROP TABLE [dbo].[mv90_data_hour]
GO
GO
/****** Object:  Table [dbo].[mv90_data_hour]    Script Date: 02/23/2011 17:30:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[mv90_data_hour](
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
	[data_missing] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[proxy_date] [datetime] NULL,
	[source_deal_header_id] [int] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
--INSERT INTO mv90_data_hour(meter_data_id,prod_date,Hr1,Hr2,Hr3,Hr4,Hr5,Hr6,Hr7,Hr8,Hr9,Hr10,Hr11,Hr12,Hr13,Hr14,Hr15,Hr16,Hr17,Hr18,Hr19,Hr20,Hr21,Hr22,Hr23,Hr24,uom_id,data_missing,proxy_date,source_deal_header_id)
--select mv1.meter_data_id,prod_date,Hr1,Hr2,Hr3,Hr4,Hr5,Hr6,Hr7,Hr8,Hr9,Hr10,Hr11,Hr12,Hr13,Hr14,Hr15,Hr16,Hr17,Hr18,Hr19,Hr20,Hr21,Hr22,Hr23,Hr24,mv.uom_id,data_missing,proxy_date,source_deal_header_id FROM zzz_mv90_data_hour mv left join meter_id md on md.recorderid=mv.recorderid left join mv90_data mv1 on md.meter_id=mv1.meter_id and mv.channel=mv1.channel and dbo.fnagetcontractmonth(mv.prod_date)=mv1.from_date WHERE mv1.meter_data_id IS NOT NULL

Go
DROP TABLE zzz_mv90_data_hour
Go
select * into zzz_mv90_data_mins from mv90_Data_mins

/****** Object:  Table [dbo].[mv90_data_mins]    Script Date: 02/23/2011 17:39:34 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[mv90_data_mins]') AND type in (N'U'))
DROP TABLE [dbo].[mv90_data_mins]
GO
/****** Object:  Table [dbo].[mv90_data_mins]    Script Date: 02/23/2011 17:39:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[mv90_data_mins](
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
	[data_missing] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[proxy_date] [datetime] NULL,
	[source_deal_header_id] [int] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF

INSERT INTO mv90_data(meter_id,[gen_date],[from_date],[to_date],[channel],[volume],[uom_id],[descriptions])
select 4,[gen_date],[from_date],[to_date],[channel],[volume],[uom_id],[descriptions] from mv90_data where meter_id=1


--INSERT INTO mv90_data_mins(meter_data_id,prod_date,Hr1_15,Hr1_30,Hr1_45,Hr1_60,Hr2_15,Hr2_30,Hr2_45,Hr2_60,Hr3_15,Hr3_30,Hr3_45,Hr3_60,Hr4_15,Hr4_30,Hr4_45,Hr4_60,Hr5_15,Hr5_30,Hr5_45,Hr5_60,Hr6_15,Hr6_30,Hr6_45,Hr6_60,Hr7_15,Hr7_30,Hr7_45,Hr7_60,Hr8_15,Hr8_30,Hr8_45,Hr8_60,Hr9_15,Hr9_30,Hr9_45,Hr9_60,Hr10_15,Hr10_30,Hr10_45,Hr10_60,Hr11_15,Hr11_30,Hr11_45,Hr11_60,Hr12_15,Hr12_30,Hr12_45,Hr12_60,Hr13_15,Hr13_30,Hr13_45,Hr13_60,Hr14_15,Hr14_30,Hr14_45,Hr14_60,Hr15_15,Hr15_30,Hr15_45,Hr15_60,Hr16_15,Hr16_30,Hr16_45,Hr16_60,Hr17_15,Hr17_30,Hr17_45,Hr17_60,Hr18_15,Hr18_30,Hr18_45,Hr18_60,Hr19_15,Hr19_30,Hr19_45,Hr19_60,Hr20_15,Hr20_30,Hr20_45,Hr20_60,Hr21_15,Hr21_30,Hr21_45,Hr21_60,Hr22_15,Hr22_30,Hr22_45,Hr22_60,Hr23_15,Hr23_30,Hr23_45,Hr23_60,Hr24_15,Hr24_30,Hr24_45,Hr24_60,uom_id,data_missing,proxy_date,source_deal_header_id)
--select mv1.meter_data_id,prod_date,Hr1_15,Hr1_30,Hr1_45,Hr1_60,Hr2_15,Hr2_30,Hr2_45,Hr2_60,Hr3_15,Hr3_30,Hr3_45,Hr3_60,Hr4_15,Hr4_30,Hr4_45,Hr4_60,Hr5_15,Hr5_30,Hr5_45,Hr5_60,Hr6_15,Hr6_30,Hr6_45,Hr6_60,Hr7_15,Hr7_30,Hr7_45,Hr7_60,Hr8_15,Hr8_30,Hr8_45,Hr8_60,Hr9_15,Hr9_30,Hr9_45,Hr9_60,Hr10_15,Hr10_30,Hr10_45,Hr10_60,Hr11_15,Hr11_30,Hr11_45,Hr11_60,Hr12_15,Hr12_30,Hr12_45,Hr12_60,Hr13_15,Hr13_30,Hr13_45,Hr13_60,Hr14_15,Hr14_30,Hr14_45,Hr14_60,Hr15_15,Hr15_30,Hr15_45,Hr15_60,Hr16_15,Hr16_30,Hr16_45,Hr16_60,Hr17_15,Hr17_30,Hr17_45,Hr17_60,Hr18_15,Hr18_30,Hr18_45,Hr18_60,Hr19_15,Hr19_30,Hr19_45,Hr19_60,Hr20_15,Hr20_30,Hr20_45,Hr20_60,Hr21_15,Hr21_30,Hr21_45,Hr21_60,Hr22_15,Hr22_30,Hr22_45,Hr22_60,Hr23_15,Hr23_30,Hr23_45,Hr23_60,Hr24_15,Hr24_30,Hr24_45,Hr24_60,mv.uom_id,data_missing,proxy_date,source_deal_header_id FROM zzz_mv90_data_mins mv left join meter_id md on md.recorderid=mv.recorderid inner join mv90_data mv1 on md.meter_id=mv1.meter_id and mv.channel=mv1.channel and dbo.fnagetcontractmonth(mv.prod_date)=mv1.from_date WHERE mv1.meter_data_id IS NOT NULL
GO
DROP TABLE zzz_mv90_data_mins

GO

/****** Object:  Table [dbo].[mv90_data_proxy]    Script Date: 02/24/2011 17:46:22 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[mv90_data_proxy]') AND type in (N'U'))
DROP TABLE [dbo].[mv90_data_proxy]
/****** Object:  Table [dbo].[mv90_data_proxy]    Script Date: 02/24/2011 17:46:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[mv90_data_proxy](
	[rec_id] [INT] IDENTITY(1,1),
	[meter_data_id] [INT] NOT NULL,
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
	[data_missing] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[proxy_date] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[mv90_data_proxy_mins]    Script Date: 02/24/2011 17:48:24 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[mv90_data_proxy_mins]') AND type in (N'U'))
DROP TABLE [dbo].[mv90_data_proxy_mins]
/****** Object:  Table [dbo].[mv90_data_proxy_mins]    Script Date: 02/24/2011 17:48:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[mv90_data_proxy_mins](
	[recid] [INT] IDENTITY(1,1),
	[meter_data_id] INT NOT  NULL,
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
	[data_missing] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[proxy_date] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO

IF EXISTS(
SELECT 1 FROM sys.columns c
	INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]
	WHERE t.name = 'mv90_DST'
		AND c.name = 'hour'
)
	ALTER TABLE mv90_DST ALTER COLUMN hour tinyint

GO
-- drop settlement archive tables
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calc_formula_value_arch1]') AND type in (N'U'))
DROP TABLE [dbo].[calc_formula_value_arch1]

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calc_formula_value_arch2]') AND type in (N'U'))
DROP TABLE [dbo].[calc_formula_value_arch2]

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calc_formula_value_hour]') AND type in (N'U'))
DROP TABLE [dbo].[calc_formula_value_hour]

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calc_invoice_summary_arch1]') AND type in (N'U'))
DROP TABLE [dbo].[calc_invoice_summary_arch1]

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calc_invoice_summary_arch2]') AND type in (N'U'))
DROP TABLE [dbo].[calc_invoice_summary_arch2]

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calc_invoice_summary]') AND type in (N'U'))
DROP TABLE [dbo].[calc_invoice_summary]

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_arch1]') AND type in (N'U'))
DROP TABLE [dbo].[calc_invoice_volume_arch1]

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_arch2]') AND type in (N'U'))
DROP TABLE [dbo].[calc_invoice_volume_arch2]

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_detail_arch1]') AND type in (N'U'))
DROP TABLE [dbo].[calc_invoice_volume_detail_arch1]

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_detail_arch2]') AND type in (N'U'))
DROP TABLE [dbo].[calc_invoice_volume_detail_arch2]

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_detail]') AND type in (N'U'))
DROP TABLE [dbo].[calc_invoice_volume_detail]

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_recorder_arch1]') AND type in (N'U'))
DROP TABLE [dbo].[calc_invoice_volume_recorder_arch1]



GO


/****** Object:  ForeignKey [FK_calc_formula_value_formula_editor]    Script Date: 03/25/2011 11:16:15 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_formula_value_formula_editor]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_formula_value]'))
ALTER TABLE [dbo].[calc_formula_value] DROP CONSTRAINT [FK_calc_formula_value_formula_editor]
GO
/****** Object:  ForeignKey [FK_calc_formula_value_rec_generator]    Script Date: 03/25/2011 11:16:15 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_formula_value_rec_generator]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_formula_value]'))
ALTER TABLE [dbo].[calc_formula_value] DROP CONSTRAINT [FK_calc_formula_value_rec_generator]
GO
/****** Object:  ForeignKey [FK_calc_formula_value_static_data_value]    Script Date: 03/25/2011 11:16:15 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_formula_value_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_formula_value]'))
ALTER TABLE [dbo].[calc_formula_value] DROP CONSTRAINT [FK_calc_formula_value_static_data_value]
GO
/****** Object:  ForeignKey [FK_calc_formula_value_estimates_formula_editor]    Script Date: 03/25/2011 11:16:15 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_formula_value_estimates_formula_editor]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_formula_value_estimates]'))
ALTER TABLE [dbo].[calc_formula_value_estimates] DROP CONSTRAINT [FK_calc_formula_value_estimates_formula_editor]
GO
/****** Object:  ForeignKey [FK_calc_formula_value_estimates_rec_generator]    Script Date: 03/25/2011 11:16:15 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_formula_value_estimates_rec_generator]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_formula_value_estimates]'))
ALTER TABLE [dbo].[calc_formula_value_estimates] DROP CONSTRAINT [FK_calc_formula_value_estimates_rec_generator]
GO
/****** Object:  ForeignKey [FK_calc_formula_value_estimates_static_data_value]    Script Date: 03/25/2011 11:16:15 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_formula_value_estimates_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_formula_value_estimates]'))
ALTER TABLE [dbo].[calc_formula_value_estimates] DROP CONSTRAINT [FK_calc_formula_value_estimates_static_data_value]
GO
/****** Object:  ForeignKey [FK_calc_invoice_volume_Calc_Invoice_Volume_variance]    Script Date: 03/25/2011 11:16:15 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_Calc_Invoice_Volume_variance]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume]'))
ALTER TABLE [dbo].[calc_invoice_volume] DROP CONSTRAINT [FK_calc_invoice_volume_Calc_Invoice_Volume_variance]
GO
/****** Object:  ForeignKey [FK_calc_invoice_volume_source_uom]    Script Date: 03/25/2011 11:16:15 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_source_uom]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume]'))
ALTER TABLE [dbo].[calc_invoice_volume] DROP CONSTRAINT [FK_calc_invoice_volume_source_uom]
GO
/****** Object:  ForeignKey [FK_calc_invoice_volume_static_data_value]    Script Date: 03/25/2011 11:16:15 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume]'))
ALTER TABLE [dbo].[calc_invoice_volume] DROP CONSTRAINT [FK_calc_invoice_volume_static_data_value]
GO
/****** Object:  ForeignKey [FK_calc_invoice_volume_estimates_calc_invoice_volume_variance_estimates]    Script Date: 03/25/2011 11:16:15 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_estimates_calc_invoice_volume_variance_estimates]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_estimates]'))
ALTER TABLE [dbo].[calc_invoice_volume_estimates] DROP CONSTRAINT [FK_calc_invoice_volume_estimates_calc_invoice_volume_variance_estimates]
GO
/****** Object:  ForeignKey [FK_calc_invoice_volume_estimates_source_uom]    Script Date: 03/25/2011 11:16:15 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_estimates_source_uom]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_estimates]'))
ALTER TABLE [dbo].[calc_invoice_volume_estimates] DROP CONSTRAINT [FK_calc_invoice_volume_estimates_source_uom]
GO
/****** Object:  ForeignKey [FK_calc_invoice_volume_estimates_static_data_value]    Script Date: 03/25/2011 11:16:15 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_estimates_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_estimates]'))
ALTER TABLE [dbo].[calc_invoice_volume_estimates] DROP CONSTRAINT [FK_calc_invoice_volume_estimates_static_data_value]
GO
/****** Object:  ForeignKey [FK_calc_invoice_volume_recorder_calc_invoice_volume_recorder]    Script Date: 03/25/2011 11:16:15 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_recorder_calc_invoice_volume_recorder]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_recorder]'))
ALTER TABLE [dbo].[calc_invoice_volume_recorder] DROP CONSTRAINT [FK_calc_invoice_volume_recorder_calc_invoice_volume_recorder]
GO
/****** Object:  ForeignKey [FK_calc_invoice_volume_recorder_Calc_Invoice_Volume_variance]    Script Date: 03/25/2011 11:16:15 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_recorder_Calc_Invoice_Volume_variance]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_recorder]'))
ALTER TABLE [dbo].[calc_invoice_volume_recorder] DROP CONSTRAINT [FK_calc_invoice_volume_recorder_Calc_Invoice_Volume_variance]
GO
/****** Object:  ForeignKey [FK_calc_invoice_volume_recorder_estimates_calc_invoice_volume_recorder_estimates]    Script Date: 03/25/2011 11:16:16 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_recorder_estimates_calc_invoice_volume_recorder_estimates]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_recorder_estimates]'))
ALTER TABLE [dbo].[calc_invoice_volume_recorder_estimates] DROP CONSTRAINT [FK_calc_invoice_volume_recorder_estimates_calc_invoice_volume_recorder_estimates]
GO
/****** Object:  ForeignKey [FK_calc_invoice_volume_recorder_estimates_calc_invoice_volume_variance_estimates]    Script Date: 03/25/2011 11:16:16 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_recorder_estimates_calc_invoice_volume_variance_estimates]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_recorder_estimates]'))
ALTER TABLE [dbo].[calc_invoice_volume_recorder_estimates] DROP CONSTRAINT [FK_calc_invoice_volume_recorder_estimates_calc_invoice_volume_variance_estimates]
GO
/****** Object:  ForeignKey [FK_Calc_Invoice_Volume_rec_generator]    Script Date: 03/25/2011 11:16:16 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Calc_Invoice_Volume_rec_generator]') AND parent_object_id = OBJECT_ID(N'[dbo].[Calc_invoice_Volume_variance]'))
ALTER TABLE [dbo].[Calc_invoice_Volume_variance] DROP CONSTRAINT [FK_Calc_Invoice_Volume_rec_generator]
GO
/****** Object:  ForeignKey [FK_Calc_invoice_Volume_variance_contract_group]    Script Date: 03/25/2011 11:16:16 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Calc_invoice_Volume_variance_contract_group]') AND parent_object_id = OBJECT_ID(N'[dbo].[Calc_invoice_Volume_variance]'))
ALTER TABLE [dbo].[Calc_invoice_Volume_variance] DROP CONSTRAINT [FK_Calc_invoice_Volume_variance_contract_group]
GO
/****** Object:  ForeignKey [FK_Calc_invoice_Volume_variance_source_counterparty]    Script Date: 03/25/2011 11:16:16 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Calc_invoice_Volume_variance_source_counterparty]') AND parent_object_id = OBJECT_ID(N'[dbo].[Calc_invoice_Volume_variance]'))
ALTER TABLE [dbo].[Calc_invoice_Volume_variance] DROP CONSTRAINT [FK_Calc_invoice_Volume_variance_source_counterparty]
GO
/****** Object:  ForeignKey [FK_Calc_Invoice_Volume_variance_source_deal_detail]    Script Date: 03/25/2011 11:16:16 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Calc_Invoice_Volume_variance_source_deal_detail]') AND parent_object_id = OBJECT_ID(N'[dbo].[Calc_invoice_Volume_variance]'))
ALTER TABLE [dbo].[Calc_invoice_Volume_variance] DROP CONSTRAINT [FK_Calc_Invoice_Volume_variance_source_deal_detail]
GO
/****** Object:  ForeignKey [FK_calc_invoice_volume_estimates_rec_generator]    Script Date: 03/25/2011 11:16:16 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_estimates_rec_generator]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_variance_estimates]'))
ALTER TABLE [dbo].[calc_invoice_volume_variance_estimates] DROP CONSTRAINT [FK_calc_invoice_volume_estimates_rec_generator]
GO
/****** Object:  ForeignKey [FK_calc_invoice_volume_variance_estimates_contract_group]    Script Date: 03/25/2011 11:16:16 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_variance_estimates_contract_group]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_variance_estimates]'))
ALTER TABLE [dbo].[calc_invoice_volume_variance_estimates] DROP CONSTRAINT [FK_calc_invoice_volume_variance_estimates_contract_group]
GO
/****** Object:  ForeignKey [FK_calc_invoice_volume_variance_estimates_source_counterparty]    Script Date: 03/25/2011 11:16:16 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_variance_estimates_source_counterparty]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_variance_estimates]'))
ALTER TABLE [dbo].[calc_invoice_volume_variance_estimates] DROP CONSTRAINT [FK_calc_invoice_volume_variance_estimates_source_counterparty]
GO
/****** Object:  ForeignKey [FK_calc_invoice_volume_variance_estimates_source_deal_detail]    Script Date: 03/25/2011 11:16:16 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_variance_estimates_source_deal_detail]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_variance_estimates]'))
ALTER TABLE [dbo].[calc_invoice_volume_variance_estimates] DROP CONSTRAINT [FK_calc_invoice_volume_variance_estimates_source_deal_detail]
GO
/****** Object:  ForeignKey [FK_source_minor_location_meter_source_minor_location_meter]    Script Date: 03/25/2011 11:16:16 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_source_minor_location_meter_source_minor_location_meter]') AND parent_object_id = OBJECT_ID(N'[dbo].[source_minor_location_meter]'))
ALTER TABLE [dbo].[source_minor_location_meter] DROP CONSTRAINT [FK_source_minor_location_meter_source_minor_location_meter]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_delivery_path_source_minor_location_meter_from]') AND parent_object_id = OBJECT_ID(N'[dbo].[delivery_path]'))
ALTER TABLE [dbo].[delivery_path] DROP CONSTRAINT [FK_delivery_path_source_minor_location_meter_from]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_delivery_path_source_minor_location_meter_to]') AND parent_object_id = OBJECT_ID(N'[dbo].[delivery_path]'))
ALTER TABLE [dbo].[delivery_path] DROP CONSTRAINT [FK_delivery_path_source_minor_location_meter_to]
GO

/****** Object:  ForeignKey [FK_recorder_generator_map_meter_id]    Script Date: 03/25/2011 11:16:16 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_recorder_generator_map_meter_id]') AND parent_object_id = OBJECT_ID(N'[dbo].[recorder_generator_map]'))
ALTER TABLE [dbo].[recorder_generator_map] DROP CONSTRAINT [FK_recorder_generator_map_meter_id]
GO
/****** Object:  ForeignKey [FK_recorder_properties_meter_id]    Script Date: 03/25/2011 11:16:16 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_recorder_properties_meter_id]') AND parent_object_id = OBJECT_ID(N'[dbo].[recorder_properties]'))
ALTER TABLE [dbo].[recorder_properties] DROP CONSTRAINT [FK_recorder_properties_meter_id]
GO
/****** Object:  Table [dbo].[recorder_generator_map]    Script Date: 03/25/2011 11:16:16 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_recorder_generator_map_meter_id]') AND parent_object_id = OBJECT_ID(N'[dbo].[recorder_generator_map]'))
ALTER TABLE [dbo].[recorder_generator_map] DROP CONSTRAINT [FK_recorder_generator_map_meter_id]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[recorder_generator_map]') AND type in (N'U'))
DROP TABLE [dbo].[recorder_generator_map]
GO
/****** Object:  Table [dbo].[recorder_properties]    Script Date: 03/25/2011 11:16:16 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_recorder_properties_meter_id]') AND parent_object_id = OBJECT_ID(N'[dbo].[recorder_properties]'))
ALTER TABLE [dbo].[recorder_properties] DROP CONSTRAINT [FK_recorder_properties_meter_id]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[recorder_properties]') AND type in (N'U'))
DROP TABLE [dbo].[recorder_properties]
GO
/****** Object:  Table [dbo].[source_minor_location_meter]    Script Date: 03/25/2011 11:16:16 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_source_minor_location_meter_source_minor_location_meter]') AND parent_object_id = OBJECT_ID(N'[dbo].[source_minor_location_meter]'))
ALTER TABLE [dbo].[source_minor_location_meter] DROP CONSTRAINT [FK_source_minor_location_meter_source_minor_location_meter]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[source_minor_location_meter]') AND type in (N'U'))
DROP TABLE [dbo].[source_minor_location_meter]
GO
/****** Object:  Table [dbo].[calc_invoice_volume_recorder_estimates]    Script Date: 03/25/2011 11:16:16 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_recorder_estimates_calc_invoice_volume_recorder_estimates]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_recorder_estimates]'))
ALTER TABLE [dbo].[calc_invoice_volume_recorder_estimates] DROP CONSTRAINT [FK_calc_invoice_volume_recorder_estimates_calc_invoice_volume_recorder_estimates]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_recorder_estimates_calc_invoice_volume_variance_estimates]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_recorder_estimates]'))
ALTER TABLE [dbo].[calc_invoice_volume_recorder_estimates] DROP CONSTRAINT [FK_calc_invoice_volume_recorder_estimates_calc_invoice_volume_variance_estimates]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_recorder_estimates]') AND type in (N'U'))
DROP TABLE [dbo].[calc_invoice_volume_recorder_estimates]
GO
/****** Object:  Table [dbo].[calc_invoice_volume_recorder]    Script Date: 03/25/2011 11:16:15 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_recorder_calc_invoice_volume_recorder]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_recorder]'))
ALTER TABLE [dbo].[calc_invoice_volume_recorder] DROP CONSTRAINT [FK_calc_invoice_volume_recorder_calc_invoice_volume_recorder]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_recorder_Calc_Invoice_Volume_variance]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_recorder]'))
ALTER TABLE [dbo].[calc_invoice_volume_recorder] DROP CONSTRAINT [FK_calc_invoice_volume_recorder_Calc_Invoice_Volume_variance]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_recorder]') AND type in (N'U'))
DROP TABLE [dbo].[calc_invoice_volume_recorder]
GO
/****** Object:  Table [dbo].[calc_invoice_volume]    Script Date: 03/25/2011 11:16:15 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_Calc_Invoice_Volume_variance]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume]'))
ALTER TABLE [dbo].[calc_invoice_volume] DROP CONSTRAINT [FK_calc_invoice_volume_Calc_Invoice_Volume_variance]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_source_uom]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume]'))
ALTER TABLE [dbo].[calc_invoice_volume] DROP CONSTRAINT [FK_calc_invoice_volume_source_uom]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume]'))
ALTER TABLE [dbo].[calc_invoice_volume] DROP CONSTRAINT [FK_calc_invoice_volume_static_data_value]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume]') AND type in (N'U'))
DROP TABLE [dbo].[calc_invoice_volume]
GO
/****** Object:  Table [dbo].[calc_invoice_volume_estimates]    Script Date: 03/25/2011 11:16:15 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_estimates_calc_invoice_volume_variance_estimates]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_estimates]'))
ALTER TABLE [dbo].[calc_invoice_volume_estimates] DROP CONSTRAINT [FK_calc_invoice_volume_estimates_calc_invoice_volume_variance_estimates]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_estimates_source_uom]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_estimates]'))
ALTER TABLE [dbo].[calc_invoice_volume_estimates] DROP CONSTRAINT [FK_calc_invoice_volume_estimates_source_uom]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_estimates_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_estimates]'))
ALTER TABLE [dbo].[calc_invoice_volume_estimates] DROP CONSTRAINT [FK_calc_invoice_volume_estimates_static_data_value]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_estimates]') AND type in (N'U'))
DROP TABLE [dbo].[calc_invoice_volume_estimates]
GO
/****** Object:  Table [dbo].[calc_formula_value_estimates]    Script Date: 03/25/2011 11:16:15 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_formula_value_estimates_formula_editor]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_formula_value_estimates]'))
ALTER TABLE [dbo].[calc_formula_value_estimates] DROP CONSTRAINT [FK_calc_formula_value_estimates_formula_editor]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_formula_value_estimates_rec_generator]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_formula_value_estimates]'))
ALTER TABLE [dbo].[calc_formula_value_estimates] DROP CONSTRAINT [FK_calc_formula_value_estimates_rec_generator]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_formula_value_estimates_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_formula_value_estimates]'))
ALTER TABLE [dbo].[calc_formula_value_estimates] DROP CONSTRAINT [FK_calc_formula_value_estimates_static_data_value]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calc_formula_value_estimates]') AND type in (N'U'))
DROP TABLE [dbo].[calc_formula_value_estimates]
GO
/****** Object:  Table [dbo].[calc_invoice_volume_variance_estimates]    Script Date: 03/25/2011 11:16:16 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_estimates_rec_generator]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_variance_estimates]'))
ALTER TABLE [dbo].[calc_invoice_volume_variance_estimates] DROP CONSTRAINT [FK_calc_invoice_volume_estimates_rec_generator]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_variance_estimates_contract_group]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_variance_estimates]'))
ALTER TABLE [dbo].[calc_invoice_volume_variance_estimates] DROP CONSTRAINT [FK_calc_invoice_volume_variance_estimates_contract_group]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_variance_estimates_source_counterparty]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_variance_estimates]'))
ALTER TABLE [dbo].[calc_invoice_volume_variance_estimates] DROP CONSTRAINT [FK_calc_invoice_volume_variance_estimates_source_counterparty]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_variance_estimates_source_deal_detail]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_variance_estimates]'))
ALTER TABLE [dbo].[calc_invoice_volume_variance_estimates] DROP CONSTRAINT [FK_calc_invoice_volume_variance_estimates_source_deal_detail]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_variance_estimates]') AND type in (N'U'))
DROP TABLE [dbo].[calc_invoice_volume_variance_estimates]
GO
/****** Object:  Table [dbo].[calc_formula_value]    Script Date: 03/25/2011 11:16:15 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_formula_value_formula_editor]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_formula_value]'))
ALTER TABLE [dbo].[calc_formula_value] DROP CONSTRAINT [FK_calc_formula_value_formula_editor]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_formula_value_rec_generator]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_formula_value]'))
ALTER TABLE [dbo].[calc_formula_value] DROP CONSTRAINT [FK_calc_formula_value_rec_generator]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_formula_value_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_formula_value]'))
ALTER TABLE [dbo].[calc_formula_value] DROP CONSTRAINT [FK_calc_formula_value_static_data_value]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calc_formula_value]') AND type in (N'U'))
DROP TABLE [dbo].[calc_formula_value]
GO
/****** Object:  Table [dbo].[Calc_invoice_Volume_variance]    Script Date: 03/25/2011 11:16:16 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Calc_Invoice_Volume_rec_generator]') AND parent_object_id = OBJECT_ID(N'[dbo].[Calc_invoice_Volume_variance]'))
ALTER TABLE [dbo].[Calc_invoice_Volume_variance] DROP CONSTRAINT [FK_Calc_Invoice_Volume_rec_generator]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Calc_invoice_Volume_variance_contract_group]') AND parent_object_id = OBJECT_ID(N'[dbo].[Calc_invoice_Volume_variance]'))
ALTER TABLE [dbo].[Calc_invoice_Volume_variance] DROP CONSTRAINT [FK_Calc_invoice_Volume_variance_contract_group]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Calc_invoice_Volume_variance_source_counterparty]') AND parent_object_id = OBJECT_ID(N'[dbo].[Calc_invoice_Volume_variance]'))
ALTER TABLE [dbo].[Calc_invoice_Volume_variance] DROP CONSTRAINT [FK_Calc_invoice_Volume_variance_source_counterparty]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Calc_Invoice_Volume_variance_source_deal_detail]') AND parent_object_id = OBJECT_ID(N'[dbo].[Calc_invoice_Volume_variance]'))
ALTER TABLE [dbo].[Calc_invoice_Volume_variance] DROP CONSTRAINT [FK_Calc_Invoice_Volume_variance_source_deal_detail]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Calc_invoice_Volume_variance]') AND type in (N'U'))
DROP TABLE [dbo].[Calc_invoice_Volume_variance]
GO
/****** Object:  Table [dbo].[recorder_generator_map_submeter]    Script Date: 03/25/2011 11:16:16 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[recorder_generator_map_submeter]') AND type in (N'U'))
DROP TABLE [dbo].[recorder_generator_map_submeter]
GO
/****** Object:  Table [dbo].[recorder_generator_map_submeter]    Script Date: 03/25/2011 11:16:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[recorder_generator_map_submeter]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[recorder_generator_map_submeter](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[generator_id] [int] NOT NULL,
	[meter_id] [int] NOT NULL,
	[allocation_per] [float] NULL,
	[from_vol] [float] NULL,
	[to_vol] [float] NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_recorder_generator_map_submeter] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Calc_invoice_Volume_variance]    Script Date: 03/25/2011 11:16:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Calc_invoice_Volume_variance]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Calc_invoice_Volume_variance](
	[calc_id] [int] IDENTITY(1,1) NOT NULL,
	[as_of_date] [datetime] NOT NULL,
	[counterparty_id] [int] NOT NULL,
	[generator_id] [int] NULL,
	[contract_id] [int] NOT NULL,
	[prod_date] [datetime] NOT NULL,
	[metervolume] [float] NULL,
	[invoicevolume] [float] NULL,
	[allocationvolume] [float] NULL,
	[variance] [float] NULL,
	[onpeak_volume] [float] NULL,
	[offpeak_volume] [float] NULL,
	[uom] [int] NULL,
	[actualVolume] [char](1) NULL,
	[book_entries] [char](1) NULL,
	[finalized] [char](1) NULL,
	[invoice_id] [int] NULL,
	[deal_id] [int] NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
	[estimated] [char](1) NULL,
	[calculation_time] [float] NULL,
	[book_id] [int] NULL,
	[sub_id] [int] NULL,
	[process_id] [varchar](100) NULL,
 CONSTRAINT [PK_Calc_Invoice_Volume_variance] PRIMARY KEY NONCLUSTERED 
(
	[calc_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Calc_invoice_Volume_variance]') AND name = N'IX_Calc_invoice_Volume_variance')
CREATE CLUSTERED INDEX [IX_Calc_invoice_Volume_variance] ON [dbo].[Calc_invoice_Volume_variance] 
(
	[as_of_date] ASC,
	[counterparty_id] ASC,
	[contract_id] ASC,
	[prod_date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[calc_formula_value]    Script Date: 03/25/2011 11:16:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calc_formula_value]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[calc_formula_value](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[invoice_line_item_id] [int] NULL,
	[seq_number] [int] NOT NULL,
	[prod_date] [datetime] NOT NULL,
	[value] [float] NULL,
	[contract_id] [int] NULL,
	[counterparty_id] [int] NULL,
	[formula_id] [int] NOT NULL,
	[calc_id] [int] NULL,
	[hour] [int] NULL,
	[formula_str] [varchar](2000) NULL,
	[qtr] [int] NULL,
	[half] [int] NULL,
	[deal_type_id] [int] NULL,
	[generator_id] [int] NULL,
	[ems_generator_id] [int] NULL,
	[deal_id] [int] NULL,
	[volume] [float] NULL,
	[formula_str_eval] [varchar](2000) NULL,
 CONSTRAINT [PK_calc_formula_value] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[calc_invoice_volume_variance_estimates]    Script Date: 03/25/2011 11:16:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_variance_estimates]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[calc_invoice_volume_variance_estimates](
	[calc_id] [int] IDENTITY(1,1) NOT NULL,
	[as_of_date] [datetime] NOT NULL,
	[counterparty_id] [int] NOT NULL,
	[generator_id] [int] NULL,
	[contract_id] [int] NOT NULL,
	[prod_date] [datetime] NOT NULL,
	[metervolume] [float] NULL,
	[invoicevolume] [float] NULL,
	[allocationvolume] [float] NULL,
	[variance] [float] NULL,
	[onpeak_volume] [float] NULL,
	[offpeak_volume] [float] NULL,
	[uom] [int] NULL,
	[actualVolume] [char](1) NULL,
	[book_entries] [char](1) NULL,
	[finalized] [char](1) NULL,
	[invoice_id] [int] NULL,
	[deal_id] [int] NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
	[estimated] [char](1) NULL,
	[calculation_time] [float] NULL,
	[book_id] [int] NULL,
	[sub_id] [int] NULL,
	[process_id] [varchar](100) NULL,
 CONSTRAINT [PK_calc_invoice_volume_variance_estimates] PRIMARY KEY NONCLUSTERED 
(
	[calc_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_variance_estimates]') AND name = N'IX_calc_invoice_volume_variance_estimates')
CREATE CLUSTERED INDEX [IX_calc_invoice_volume_variance_estimates] ON [dbo].[calc_invoice_volume_variance_estimates] 
(
	[as_of_date] ASC,
	[counterparty_id] ASC,
	[contract_id] ASC,
	[prod_date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[calc_formula_value_estimates]    Script Date: 03/25/2011 11:16:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calc_formula_value_estimates]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[calc_formula_value_estimates](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[invoice_line_item_id] [int] NULL,
	[seq_number] [int] NOT NULL,
	[prod_date] [datetime] NOT NULL,
	[value] [float] NULL,
	[counterparty_id] [int] NULL,
	[contract_id] [int] NULL,
	[formula_id] [int] NOT NULL,
	[calc_id] [int] NULL,
	[hour] [int] NULL,
	[formula_str] [varchar](2000) NULL,
	[qtr] [int] NULL,
	[half] [int] NULL,
	[deal_type_id] [int] NULL,
	[generator_id] [int] NULL,
	[ems_generator_id] [int] NULL,
	[deal_id] [int] NULL,
	[volume] [float] NULL,
	[formula_str_eval] [varchar](2000) NULL,
 CONSTRAINT [PK_calc_formula_value_estimates] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[calc_invoice_volume_estimates]    Script Date: 03/25/2011 11:16:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_estimates]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[calc_invoice_volume_estimates](
	[calc_detail_id] [int] IDENTITY(1,1) NOT NULL,
	[calc_id] [int] NOT NULL,
	[invoice_line_item_id] [int] NOT NULL,
	[prod_date] [datetime] NOT NULL,
	[Value] [float] NULL,
	[Volume] [float] NULL,
	[manual_input] [char](1) NULL,
	[default_gl_id] [int] NULL,
	[uom_id] [int] NULL,
	[price_or_formula] [char](1) NULL,
	[onpeak_offpeak] [char](1) NULL,
	[remarks] [varchar](100) NULL,
	[finalized] [char](1) NULL,
	[finalized_id] [int] NULL,
	[inv_prod_date] [datetime] NULL,
	[include_volume] [char](1) NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
	[default_gl_id_estimate] [int] NULL,
	[status] [char](1) NULL,
	[deal_type_id] [int] NULL,
	[inventory] [char](1) NULL,
 CONSTRAINT [PK_calc_invoice_volume_estimates] PRIMARY KEY NONCLUSTERED 
(
	[calc_detail_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_estimates]') AND name = N'IX_calc_invoice_volume_estimates')
CREATE CLUSTERED INDEX [IX_calc_invoice_volume_estimates] ON [dbo].[calc_invoice_volume_estimates] 
(
	[calc_id] ASC,
	[prod_date] ASC,
	[invoice_line_item_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[calc_invoice_volume]    Script Date: 03/25/2011 11:16:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[calc_invoice_volume](
	[calc_detail_id] [int] IDENTITY(1,1) NOT NULL,
	[calc_id] [int] NOT NULL,
	[invoice_line_item_id] [int] NOT NULL,
	[prod_date] [datetime] NOT NULL,
	[Value] [float] NULL,
	[Volume] [float] NULL,
	[manual_input] [char](1) NULL,
	[default_gl_id] [int] NULL,
	[uom_id] [int] NULL,
	[price_or_formula] [char](1) NULL,
	[onpeak_offpeak] [char](1) NULL,
	[remarks] [varchar](100) NULL,
	[finalized] [char](1) NULL,
	[finalized_id] [int] NULL,
	[inv_prod_date] [datetime] NULL,
	[include_volume] [char](1) NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
	[default_gl_id_estimate] [int] NULL,
	[status] [char](1) NULL,
	[deal_type_id] [int] NULL,
	[inventory] [char](1) NULL,
 CONSTRAINT [PK_calc_invoice_volume] PRIMARY KEY NONCLUSTERED 
(
	[calc_detail_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume]') AND name = N'IX_calc_invoice_volume')
CREATE CLUSTERED INDEX [IX_calc_invoice_volume] ON [dbo].[calc_invoice_volume] 
(
	[calc_id] ASC,
	[prod_date] ASC,
	[invoice_line_item_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[calc_invoice_volume_recorder]    Script Date: 03/25/2011 11:16:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_recorder]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[calc_invoice_volume_recorder](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[calc_id] [int] NOT NULL,
	[meter_id] [int] NULL,
	[metervolume] [float] NULL,
	[invoicevolume] [float] NULL,
	[allocationvolume] [float] NULL,
	[variance] [float] NULL,
 CONSTRAINT [PK_calc_invoice_volume_recorder] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_recorder]') AND name = N'IX_calc_invoice_volume_recorder')
CREATE NONCLUSTERED INDEX [IX_calc_invoice_volume_recorder] ON [dbo].[calc_invoice_volume_recorder] 
(
	[calc_id] ASC,
	[meter_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[calc_invoice_volume_recorder_estimates]    Script Date: 03/25/2011 11:16:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_recorder_estimates]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[calc_invoice_volume_recorder_estimates](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[calc_id] [int] NOT NULL,
	[meter_id] [int] NULL,
	[metervolume] [float] NULL,
	[invoicevolume] [float] NULL,
	[allocationvolume] [float] NULL,
	[variance] [float] NULL,
 CONSTRAINT [PK_calc_invoice_volume_recorder_estimates] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_recorder_estimates]') AND name = N'IX_calc_invoice_volume_recorder_estimates')
CREATE NONCLUSTERED INDEX [IX_calc_invoice_volume_recorder_estimates] ON [dbo].[calc_invoice_volume_recorder_estimates] 
(
	[calc_id] ASC,
	[meter_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[source_minor_location_meter]    Script Date: 03/25/2011 11:16:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[source_minor_location_meter]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[source_minor_location_meter](
	[location_meter_id] [int] IDENTITY(1,1) NOT NULL,
	[meter_id] [int] NOT NULL,
	[source_minor_location_id] [int] NOT NULL,
	[imbalance_applied] [char](1) NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_source_minor_location_meter] PRIMARY KEY NONCLUSTERED 
(
	[location_meter_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[source_minor_location_meter]') AND name = N'IX_source_minor_location_meter')
CREATE UNIQUE CLUSTERED INDEX [IX_source_minor_location_meter] ON [dbo].[source_minor_location_meter] 
(
	[meter_id] ASC,
	[source_minor_location_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[recorder_properties]    Script Date: 03/25/2011 11:16:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[recorder_properties]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[recorder_properties](
	[meter_id] [int] NOT NULL,
	[channel] [int] NOT NULL,
	[mult_factor] [int] NOT NULL,
	[uom_id] [int] NOT NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_recorder_properties] PRIMARY KEY CLUSTERED 
(
	[meter_id] ASC,
	[channel] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[recorder_generator_map]    Script Date: 03/25/2011 11:16:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[recorder_generator_map]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[recorder_generator_map](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[generator_id] [int] NOT NULL,
	[meter_id] [int] NOT NULL,
	[allocation_per] [float] NULL,
	[from_vol] [float] NULL,
	[to_vol] [float] NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_recorder_generator_map] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [IX_recorder_generator_map] UNIQUE NONCLUSTERED 
(
	[generator_id] ASC,
	[meter_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Trigger [TRGINS_source_minor_location_meter]    Script Date: 03/25/2011 11:16:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGINS_source_minor_location_meter]'))
EXEC dbo.sp_executesql @statement = N'CREATE TRIGGER [dbo].[TRGINS_source_minor_location_meter]
ON [dbo].[source_minor_location_meter]
FOR INSERT
AS
UPDATE source_minor_location_meter SET create_user =  dbo.FNADBUser(), create_ts = getdate() 
FROM source_minor_location_meter s INNER JOIN inserted i ON s.location_meter_id=i.location_meter_id
'
GO
/****** Object:  Trigger [TRGUPD_source_minor_location_meter]    Script Date: 03/25/2011 11:16:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGUPD_source_minor_location_meter]'))
EXEC dbo.sp_executesql @statement = N'CREATE TRIGGER [dbo].[TRGUPD_source_minor_location_meter]
ON [dbo].[source_minor_location_meter]
FOR UPDATE
AS
UPDATE source_minor_location_meter SET update_user =dbo.FNADBUser(), update_ts = getdate() where  source_minor_location_meter.location_meter_id in (select location_meter_id from deleted)
'
GO
/****** Object:  Trigger [TRGINS_Calc_invoice_Volume_variance]    Script Date: 03/25/2011 11:16:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGINS_Calc_invoice_Volume_variance]'))
EXEC dbo.sp_executesql @statement = N'

CREATE TRIGGER [dbo].[TRGINS_Calc_invoice_Volume_variance]
ON [dbo].[Calc_invoice_Volume_variance]
FOR INSERT
AS
UPDATE [Calc_invoice_Volume_variance] SET create_user =dbo.FNADBUser(), create_ts = getdate() where  [Calc_invoice_Volume_variance].calc_id in (select calc_id from inserted)

'
GO
/****** Object:  Trigger [TRGUPD_Calc_invoice_Volume_variance]    Script Date: 03/25/2011 11:16:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGUPD_Calc_invoice_Volume_variance]'))
EXEC dbo.sp_executesql @statement = N'

CREATE TRIGGER [dbo].[TRGUPD_Calc_invoice_Volume_variance]
ON [dbo].[Calc_invoice_Volume_variance]
FOR UPDATE
AS
UPDATE [Calc_invoice_Volume_variance] SET create_user =dbo.FNADBUser(), create_ts = getdate() where  [Calc_invoice_Volume_variance].calc_id in (select calc_id from deleted)

'
GO
/****** Object:  Trigger [TRGUPD_calc_invoice_volume_variance_estimates]    Script Date: 03/25/2011 11:16:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGUPD_calc_invoice_volume_variance_estimates]'))
EXEC dbo.sp_executesql @statement = N'


CREATE TRIGGER [dbo].[TRGUPD_calc_invoice_volume_variance_estimates]
ON [dbo].[calc_invoice_volume_variance_estimates]
FOR UPDATE
AS
UPDATE [calc_invoice_volume_variance_estimates] SET create_user =dbo.FNADBUser(), create_ts = getdate() where  [calc_invoice_volume_variance_estimates].calc_id in (select calc_id from deleted)


'
GO
/****** Object:  Trigger [TRGINS_calc_invoice_volume_variance_estimates]    Script Date: 03/25/2011 11:16:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGINS_calc_invoice_volume_variance_estimates]'))
EXEC dbo.sp_executesql @statement = N'


CREATE TRIGGER [dbo].[TRGINS_calc_invoice_volume_variance_estimates]
ON [dbo].[calc_invoice_volume_variance_estimates]
FOR INSERT
AS
UPDATE [calc_invoice_volume_variance_estimates] SET create_user =dbo.FNADBUser(), create_ts = getdate() where  [calc_invoice_volume_variance_estimates].calc_id in (select calc_id from inserted)


'
GO
/****** Object:  Trigger [TRGINS_calc_invoice_volume_estimates]    Script Date: 03/25/2011 11:16:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGINS_calc_invoice_volume_estimates]'))
EXEC dbo.sp_executesql @statement = N'
CREATE TRIGGER [dbo].[TRGINS_calc_invoice_volume_estimates]
ON [dbo].[calc_invoice_volume_estimates]
FOR INSERT
AS
UPDATE [calc_invoice_volume_estimates] SET create_user =dbo.FNADBUser(), create_ts = getdate() where  [calc_invoice_volume_estimates].calc_detail_id in (select calc_detail_id from inserted)

'
GO
/****** Object:  Trigger [TRGUPD_calc_invoice_volume_estimates]    Script Date: 03/25/2011 11:16:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGUPD_calc_invoice_volume_estimates]'))
EXEC dbo.sp_executesql @statement = N'
CREATE TRIGGER [dbo].[TRGUPD_calc_invoice_volume_estimates]
ON [dbo].[calc_invoice_volume_estimates]
FOR UPDATE
AS
UPDATE [calc_invoice_volume_estimates] SET create_user =dbo.FNADBUser(), create_ts = getdate() where  [calc_invoice_volume_estimates].calc_detail_id in (select calc_detail_id from deleted)

'
GO
/****** Object:  Trigger [TRGUPD_calc_invoice_volume]    Script Date: 03/25/2011 11:16:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGUPD_calc_invoice_volume]'))
EXEC dbo.sp_executesql @statement = N'CREATE TRIGGER [dbo].[TRGUPD_calc_invoice_volume]
ON [dbo].[calc_invoice_volume]
FOR UPDATE
AS
UPDATE [calc_invoice_volume] SET create_user =dbo.FNADBUser(), create_ts = getdate() where  [calc_invoice_volume].calc_detail_id in (select calc_detail_id from deleted)
'
GO
/****** Object:  Trigger [TRGINS_calc_invoice_volume]    Script Date: 03/25/2011 11:16:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGINS_calc_invoice_volume]'))
EXEC dbo.sp_executesql @statement = N'CREATE TRIGGER [dbo].[TRGINS_calc_invoice_volume]
ON [dbo].[calc_invoice_volume]
FOR INSERT
AS
UPDATE [calc_invoice_volume] SET create_user =dbo.FNADBUser(), create_ts = getdate() where  [calc_invoice_volume].calc_detail_id in (select calc_detail_id from inserted)
'
GO
/****** Object:  ForeignKey [FK_calc_formula_value_formula_editor]    Script Date: 03/25/2011 11:16:15 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_formula_value_formula_editor]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_formula_value]'))
ALTER TABLE [dbo].[calc_formula_value]  WITH NOCHECK ADD  CONSTRAINT [FK_calc_formula_value_formula_editor] FOREIGN KEY([formula_id])
REFERENCES [dbo].[formula_editor] ([formula_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_formula_value_formula_editor]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_formula_value]'))
ALTER TABLE [dbo].[calc_formula_value] CHECK CONSTRAINT [FK_calc_formula_value_formula_editor]
GO
/****** Object:  ForeignKey [FK_calc_formula_value_rec_generator]    Script Date: 03/25/2011 11:16:15 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_formula_value_rec_generator]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_formula_value]'))
ALTER TABLE [dbo].[calc_formula_value]  WITH NOCHECK ADD  CONSTRAINT [FK_calc_formula_value_rec_generator] FOREIGN KEY([generator_id])
REFERENCES [dbo].[rec_generator] ([generator_id])
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_formula_value_rec_generator]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_formula_value]'))
ALTER TABLE [dbo].[calc_formula_value] CHECK CONSTRAINT [FK_calc_formula_value_rec_generator]
GO
/****** Object:  ForeignKey [FK_calc_formula_value_static_data_value]    Script Date: 03/25/2011 11:16:15 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_formula_value_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_formula_value]'))
ALTER TABLE [dbo].[calc_formula_value]  WITH NOCHECK ADD  CONSTRAINT [FK_calc_formula_value_static_data_value] FOREIGN KEY([invoice_line_item_id])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_formula_value_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_formula_value]'))
ALTER TABLE [dbo].[calc_formula_value] CHECK CONSTRAINT [FK_calc_formula_value_static_data_value]
GO
/****** Object:  ForeignKey [FK_calc_formula_value_estimates_formula_editor]    Script Date: 03/25/2011 11:16:15 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_formula_value_estimates_formula_editor]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_formula_value_estimates]'))
ALTER TABLE [dbo].[calc_formula_value_estimates]  WITH NOCHECK ADD  CONSTRAINT [FK_calc_formula_value_estimates_formula_editor] FOREIGN KEY([formula_id])
REFERENCES [dbo].[formula_editor] ([formula_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_formula_value_estimates_formula_editor]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_formula_value_estimates]'))
ALTER TABLE [dbo].[calc_formula_value_estimates] CHECK CONSTRAINT [FK_calc_formula_value_estimates_formula_editor]
GO
/****** Object:  ForeignKey [FK_calc_formula_value_estimates_rec_generator]    Script Date: 03/25/2011 11:16:15 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_formula_value_estimates_rec_generator]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_formula_value_estimates]'))
ALTER TABLE [dbo].[calc_formula_value_estimates]  WITH NOCHECK ADD  CONSTRAINT [FK_calc_formula_value_estimates_rec_generator] FOREIGN KEY([generator_id])
REFERENCES [dbo].[rec_generator] ([generator_id])
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_formula_value_estimates_rec_generator]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_formula_value_estimates]'))
ALTER TABLE [dbo].[calc_formula_value_estimates] CHECK CONSTRAINT [FK_calc_formula_value_estimates_rec_generator]
GO
/****** Object:  ForeignKey [FK_calc_formula_value_estimates_static_data_value]    Script Date: 03/25/2011 11:16:15 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_formula_value_estimates_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_formula_value_estimates]'))
ALTER TABLE [dbo].[calc_formula_value_estimates]  WITH NOCHECK ADD  CONSTRAINT [FK_calc_formula_value_estimates_static_data_value] FOREIGN KEY([invoice_line_item_id])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_formula_value_estimates_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_formula_value_estimates]'))
ALTER TABLE [dbo].[calc_formula_value_estimates] CHECK CONSTRAINT [FK_calc_formula_value_estimates_static_data_value]
GO
/****** Object:  ForeignKey [FK_calc_invoice_volume_Calc_Invoice_Volume_variance]    Script Date: 03/25/2011 11:16:15 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_Calc_Invoice_Volume_variance]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume]'))
ALTER TABLE [dbo].[calc_invoice_volume]  WITH NOCHECK ADD  CONSTRAINT [FK_calc_invoice_volume_Calc_Invoice_Volume_variance] FOREIGN KEY([calc_id])
REFERENCES [dbo].[Calc_invoice_Volume_variance] ([calc_id])
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_Calc_Invoice_Volume_variance]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume]'))
ALTER TABLE [dbo].[calc_invoice_volume] CHECK CONSTRAINT [FK_calc_invoice_volume_Calc_Invoice_Volume_variance]
GO
/****** Object:  ForeignKey [FK_calc_invoice_volume_source_uom]    Script Date: 03/25/2011 11:16:15 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_source_uom]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume]'))
ALTER TABLE [dbo].[calc_invoice_volume]  WITH NOCHECK ADD  CONSTRAINT [FK_calc_invoice_volume_source_uom] FOREIGN KEY([uom_id])
REFERENCES [dbo].[source_uom] ([source_uom_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_source_uom]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume]'))
ALTER TABLE [dbo].[calc_invoice_volume] CHECK CONSTRAINT [FK_calc_invoice_volume_source_uom]
GO
/****** Object:  ForeignKey [FK_calc_invoice_volume_static_data_value]    Script Date: 03/25/2011 11:16:15 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume]'))
ALTER TABLE [dbo].[calc_invoice_volume]  WITH NOCHECK ADD  CONSTRAINT [FK_calc_invoice_volume_static_data_value] FOREIGN KEY([invoice_line_item_id])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume]'))
ALTER TABLE [dbo].[calc_invoice_volume] CHECK CONSTRAINT [FK_calc_invoice_volume_static_data_value]
GO
/****** Object:  ForeignKey [FK_calc_invoice_volume_estimates_calc_invoice_volume_variance_estimates]    Script Date: 03/25/2011 11:16:15 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_estimates_calc_invoice_volume_variance_estimates]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_estimates]'))
ALTER TABLE [dbo].[calc_invoice_volume_estimates]  WITH NOCHECK ADD  CONSTRAINT [FK_calc_invoice_volume_estimates_calc_invoice_volume_variance_estimates] FOREIGN KEY([calc_id])
REFERENCES [dbo].[calc_invoice_volume_variance_estimates] ([calc_id])
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_estimates_calc_invoice_volume_variance_estimates]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_estimates]'))
ALTER TABLE [dbo].[calc_invoice_volume_estimates] CHECK CONSTRAINT [FK_calc_invoice_volume_estimates_calc_invoice_volume_variance_estimates]
GO
/****** Object:  ForeignKey [FK_calc_invoice_volume_estimates_source_uom]    Script Date: 03/25/2011 11:16:15 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_estimates_source_uom]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_estimates]'))
ALTER TABLE [dbo].[calc_invoice_volume_estimates]  WITH NOCHECK ADD  CONSTRAINT [FK_calc_invoice_volume_estimates_source_uom] FOREIGN KEY([uom_id])
REFERENCES [dbo].[source_uom] ([source_uom_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_estimates_source_uom]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_estimates]'))
ALTER TABLE [dbo].[calc_invoice_volume_estimates] CHECK CONSTRAINT [FK_calc_invoice_volume_estimates_source_uom]
GO
/****** Object:  ForeignKey [FK_calc_invoice_volume_estimates_static_data_value]    Script Date: 03/25/2011 11:16:15 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_estimates_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_estimates]'))
ALTER TABLE [dbo].[calc_invoice_volume_estimates]  WITH NOCHECK ADD  CONSTRAINT [FK_calc_invoice_volume_estimates_static_data_value] FOREIGN KEY([invoice_line_item_id])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_estimates_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_estimates]'))
ALTER TABLE [dbo].[calc_invoice_volume_estimates] CHECK CONSTRAINT [FK_calc_invoice_volume_estimates_static_data_value]
GO
/****** Object:  ForeignKey [FK_calc_invoice_volume_recorder_calc_invoice_volume_recorder]    Script Date: 03/25/2011 11:16:15 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_recorder_calc_invoice_volume_recorder]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_recorder]'))
ALTER TABLE [dbo].[calc_invoice_volume_recorder]  WITH NOCHECK ADD  CONSTRAINT [FK_calc_invoice_volume_recorder_calc_invoice_volume_recorder] FOREIGN KEY([meter_id])
REFERENCES [dbo].[meter_id] ([meter_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_recorder_calc_invoice_volume_recorder]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_recorder]'))
ALTER TABLE [dbo].[calc_invoice_volume_recorder] CHECK CONSTRAINT [FK_calc_invoice_volume_recorder_calc_invoice_volume_recorder]
GO
/****** Object:  ForeignKey [FK_calc_invoice_volume_recorder_Calc_Invoice_Volume_variance]    Script Date: 03/25/2011 11:16:15 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_recorder_Calc_Invoice_Volume_variance]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_recorder]'))
ALTER TABLE [dbo].[calc_invoice_volume_recorder]  WITH NOCHECK ADD  CONSTRAINT [FK_calc_invoice_volume_recorder_Calc_Invoice_Volume_variance] FOREIGN KEY([calc_id])
REFERENCES [dbo].[Calc_invoice_Volume_variance] ([calc_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_recorder_Calc_Invoice_Volume_variance]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_recorder]'))
ALTER TABLE [dbo].[calc_invoice_volume_recorder] CHECK CONSTRAINT [FK_calc_invoice_volume_recorder_Calc_Invoice_Volume_variance]
GO
/****** Object:  ForeignKey [FK_calc_invoice_volume_recorder_estimates_calc_invoice_volume_recorder_estimates]    Script Date: 03/25/2011 11:16:16 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_recorder_estimates_calc_invoice_volume_recorder_estimates]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_recorder_estimates]'))
ALTER TABLE [dbo].[calc_invoice_volume_recorder_estimates]  WITH NOCHECK ADD  CONSTRAINT [FK_calc_invoice_volume_recorder_estimates_calc_invoice_volume_recorder_estimates] FOREIGN KEY([meter_id])
REFERENCES [dbo].[meter_id] ([meter_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_recorder_estimates_calc_invoice_volume_recorder_estimates]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_recorder_estimates]'))
ALTER TABLE [dbo].[calc_invoice_volume_recorder_estimates] CHECK CONSTRAINT [FK_calc_invoice_volume_recorder_estimates_calc_invoice_volume_recorder_estimates]
GO
/****** Object:  ForeignKey [FK_calc_invoice_volume_recorder_estimates_calc_invoice_volume_variance_estimates]    Script Date: 03/25/2011 11:16:16 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_recorder_estimates_calc_invoice_volume_variance_estimates]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_recorder_estimates]'))
ALTER TABLE [dbo].[calc_invoice_volume_recorder_estimates]  WITH NOCHECK ADD  CONSTRAINT [FK_calc_invoice_volume_recorder_estimates_calc_invoice_volume_variance_estimates] FOREIGN KEY([calc_id])
REFERENCES [dbo].[calc_invoice_volume_variance_estimates] ([calc_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_recorder_estimates_calc_invoice_volume_variance_estimates]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_recorder_estimates]'))
ALTER TABLE [dbo].[calc_invoice_volume_recorder_estimates] CHECK CONSTRAINT [FK_calc_invoice_volume_recorder_estimates_calc_invoice_volume_variance_estimates]
GO
/****** Object:  ForeignKey [FK_Calc_Invoice_Volume_rec_generator]    Script Date: 03/25/2011 11:16:16 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Calc_Invoice_Volume_rec_generator]') AND parent_object_id = OBJECT_ID(N'[dbo].[Calc_invoice_Volume_variance]'))
ALTER TABLE [dbo].[Calc_invoice_Volume_variance]  WITH NOCHECK ADD  CONSTRAINT [FK_Calc_Invoice_Volume_rec_generator] FOREIGN KEY([generator_id])
REFERENCES [dbo].[rec_generator] ([generator_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Calc_Invoice_Volume_rec_generator]') AND parent_object_id = OBJECT_ID(N'[dbo].[Calc_invoice_Volume_variance]'))
ALTER TABLE [dbo].[Calc_invoice_Volume_variance] CHECK CONSTRAINT [FK_Calc_Invoice_Volume_rec_generator]
GO
/****** Object:  ForeignKey [FK_Calc_invoice_Volume_variance_contract_group]    Script Date: 03/25/2011 11:16:16 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Calc_invoice_Volume_variance_contract_group]') AND parent_object_id = OBJECT_ID(N'[dbo].[Calc_invoice_Volume_variance]'))
ALTER TABLE [dbo].[Calc_invoice_Volume_variance]  WITH NOCHECK ADD  CONSTRAINT [FK_Calc_invoice_Volume_variance_contract_group] FOREIGN KEY([contract_id])
REFERENCES [dbo].[contract_group] ([contract_id])
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Calc_invoice_Volume_variance_contract_group]') AND parent_object_id = OBJECT_ID(N'[dbo].[Calc_invoice_Volume_variance]'))
ALTER TABLE [dbo].[Calc_invoice_Volume_variance] CHECK CONSTRAINT [FK_Calc_invoice_Volume_variance_contract_group]
GO
/****** Object:  ForeignKey [FK_Calc_invoice_Volume_variance_source_counterparty]    Script Date: 03/25/2011 11:16:16 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Calc_invoice_Volume_variance_source_counterparty]') AND parent_object_id = OBJECT_ID(N'[dbo].[Calc_invoice_Volume_variance]'))
ALTER TABLE [dbo].[Calc_invoice_Volume_variance]  WITH NOCHECK ADD  CONSTRAINT [FK_Calc_invoice_Volume_variance_source_counterparty] FOREIGN KEY([counterparty_id])
REFERENCES [dbo].[source_counterparty] ([source_counterparty_id])
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Calc_invoice_Volume_variance_source_counterparty]') AND parent_object_id = OBJECT_ID(N'[dbo].[Calc_invoice_Volume_variance]'))
ALTER TABLE [dbo].[Calc_invoice_Volume_variance] CHECK CONSTRAINT [FK_Calc_invoice_Volume_variance_source_counterparty]
GO
/****** Object:  ForeignKey [FK_Calc_Invoice_Volume_variance_source_deal_detail]    Script Date: 03/25/2011 11:16:16 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Calc_Invoice_Volume_variance_source_deal_detail]') AND parent_object_id = OBJECT_ID(N'[dbo].[Calc_invoice_Volume_variance]'))
ALTER TABLE [dbo].[Calc_invoice_Volume_variance]  WITH NOCHECK ADD  CONSTRAINT [FK_Calc_Invoice_Volume_variance_source_deal_detail] FOREIGN KEY([deal_id])
REFERENCES [dbo].[source_deal_detail] ([source_deal_detail_id])
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Calc_Invoice_Volume_variance_source_deal_detail]') AND parent_object_id = OBJECT_ID(N'[dbo].[Calc_invoice_Volume_variance]'))
ALTER TABLE [dbo].[Calc_invoice_Volume_variance] CHECK CONSTRAINT [FK_Calc_Invoice_Volume_variance_source_deal_detail]
GO
/****** Object:  ForeignKey [FK_calc_invoice_volume_estimates_rec_generator]    Script Date: 03/25/2011 11:16:16 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_estimates_rec_generator]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_variance_estimates]'))
ALTER TABLE [dbo].[calc_invoice_volume_variance_estimates]  WITH NOCHECK ADD  CONSTRAINT [FK_calc_invoice_volume_estimates_rec_generator] FOREIGN KEY([generator_id])
REFERENCES [dbo].[rec_generator] ([generator_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_estimates_rec_generator]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_variance_estimates]'))
ALTER TABLE [dbo].[calc_invoice_volume_variance_estimates] CHECK CONSTRAINT [FK_calc_invoice_volume_estimates_rec_generator]
GO
/****** Object:  ForeignKey [FK_calc_invoice_volume_variance_estimates_contract_group]    Script Date: 03/25/2011 11:16:16 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_variance_estimates_contract_group]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_variance_estimates]'))
ALTER TABLE [dbo].[calc_invoice_volume_variance_estimates]  WITH NOCHECK ADD  CONSTRAINT [FK_calc_invoice_volume_variance_estimates_contract_group] FOREIGN KEY([contract_id])
REFERENCES [dbo].[contract_group] ([contract_id])
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_variance_estimates_contract_group]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_variance_estimates]'))
ALTER TABLE [dbo].[calc_invoice_volume_variance_estimates] CHECK CONSTRAINT [FK_calc_invoice_volume_variance_estimates_contract_group]
GO
/****** Object:  ForeignKey [FK_calc_invoice_volume_variance_estimates_source_counterparty]    Script Date: 03/25/2011 11:16:16 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_variance_estimates_source_counterparty]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_variance_estimates]'))
ALTER TABLE [dbo].[calc_invoice_volume_variance_estimates]  WITH NOCHECK ADD  CONSTRAINT [FK_calc_invoice_volume_variance_estimates_source_counterparty] FOREIGN KEY([counterparty_id])
REFERENCES [dbo].[source_counterparty] ([source_counterparty_id])
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_variance_estimates_source_counterparty]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_variance_estimates]'))
ALTER TABLE [dbo].[calc_invoice_volume_variance_estimates] CHECK CONSTRAINT [FK_calc_invoice_volume_variance_estimates_source_counterparty]
GO
/****** Object:  ForeignKey [FK_calc_invoice_volume_variance_estimates_source_deal_detail]    Script Date: 03/25/2011 11:16:16 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_variance_estimates_source_deal_detail]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_variance_estimates]'))
ALTER TABLE [dbo].[calc_invoice_volume_variance_estimates]  WITH NOCHECK ADD  CONSTRAINT [FK_calc_invoice_volume_variance_estimates_source_deal_detail] FOREIGN KEY([deal_id])
REFERENCES [dbo].[source_deal_detail] ([source_deal_detail_id])
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_variance_estimates_source_deal_detail]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_variance_estimates]'))
ALTER TABLE [dbo].[calc_invoice_volume_variance_estimates] CHECK CONSTRAINT [FK_calc_invoice_volume_variance_estimates_source_deal_detail]
GO
/****** Object:  ForeignKey [FK_source_minor_location_meter_source_minor_location_meter]    Script Date: 03/25/2011 11:16:16 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_source_minor_location_meter_source_minor_location_meter]') AND parent_object_id = OBJECT_ID(N'[dbo].[source_minor_location_meter]'))
ALTER TABLE [dbo].[source_minor_location_meter]  WITH NOCHECK ADD  CONSTRAINT [FK_source_minor_location_meter_source_minor_location_meter] FOREIGN KEY([source_minor_location_id])
REFERENCES [dbo].[source_minor_location] ([source_minor_location_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_source_minor_location_meter_source_minor_location_meter]') AND parent_object_id = OBJECT_ID(N'[dbo].[source_minor_location_meter]'))
ALTER TABLE [dbo].[source_minor_location_meter] CHECK CONSTRAINT [FK_source_minor_location_meter_source_minor_location_meter]
GO
/****** Object:  ForeignKey [FK_recorder_generator_map_meter_id]    Script Date: 03/25/2011 11:16:16 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_recorder_generator_map_meter_id]') AND parent_object_id = OBJECT_ID(N'[dbo].[recorder_generator_map]'))
ALTER TABLE [dbo].[recorder_generator_map]  WITH NOCHECK ADD  CONSTRAINT [FK_recorder_generator_map_meter_id] FOREIGN KEY([meter_id])
REFERENCES [dbo].[meter_id] ([meter_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_recorder_generator_map_meter_id]') AND parent_object_id = OBJECT_ID(N'[dbo].[recorder_generator_map]'))
ALTER TABLE [dbo].[recorder_generator_map] CHECK CONSTRAINT [FK_recorder_generator_map_meter_id]
GO
/****** Object:  ForeignKey [FK_recorder_properties_meter_id]    Script Date: 03/25/2011 11:16:16 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_recorder_properties_meter_id]') AND parent_object_id = OBJECT_ID(N'[dbo].[recorder_properties]'))
ALTER TABLE [dbo].[recorder_properties]  WITH NOCHECK ADD  CONSTRAINT [FK_recorder_properties_meter_id] FOREIGN KEY([meter_id])
REFERENCES [dbo].[meter_id] ([meter_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_recorder_properties_meter_id]') AND parent_object_id = OBJECT_ID(N'[dbo].[recorder_properties]'))
ALTER TABLE [dbo].[recorder_properties] CHECK CONSTRAINT [FK_recorder_properties_meter_id]
GO
SET IDENTITY_INSERT [dbo].[mv90_data_hour] ON
INSERT [dbo].[mv90_data_hour] ([recid], [meter_data_id], [prod_date], [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24], [uom_id], [data_missing], [proxy_date], [source_deal_header_id]) VALUES (1, 10, CAST(0x00009E5E00000000 AS DateTime), 4099.721808, 3364.1040160000002, 4119.412752, 3000.810176, 3247.4565759999996, 3355.328704, 3238.487616, 4624.222512, 4545.7441119999994, 4230.1590240000005, 2551.679312, 4337.8578880000005, 4009.5429919999997, 4742.4089440000007, 6048.676816, 3596.287968, 3690.5333920000003, 5272.280832, 4366.81336, 4325.209616, 2608.051264, 3800.0668160000005, 4547.955776, 3137.8518079999994, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data_hour] ([recid], [meter_data_id], [prod_date], [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24], [uom_id], [data_missing], [proxy_date], [source_deal_header_id]) VALUES (2, 10, CAST(0x00009E5F00000000 AS DateTime), 5698.5612320000009, 2356.329248, 6717.618544, 4307.7711039999995, 3327.89184, 3694.0904, 4951.1207200000008, 4309.33048, 1113.863296, 3662.016176, 5755.086064, 2385.916624, 870.284688, 6033.4397760000011, 5196.5848479999995, 2685.112976, 3784.2794079999994, 5744.374272, 3908.7950720000008, 5332.138448, 3380.8698560000003, 4943.099616, 3546.7242720000004, 3922.921184, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data_hour] ([recid], [meter_data_id], [prod_date], [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24], [uom_id], [data_missing], [proxy_date], [source_deal_header_id]) VALUES (3, 10, CAST(0x00009E6000000000 AS DateTime), 4416.244560000001, 3299.333856, 5267.133872, 4193.233408, 3219.5610720000004, 2892.601712, 3014.579568, 3508.0864, 3381.50176, 6481.011264, 4146.136176, 3693.417728, 5729.606064, 4568.492656, 6206.26552, 5136.686464, 3014.885328, 4380.11392, 4623.7638719999995, 2943.408832, 5429.451664, 4871.867728, 5261.56904, 4277.154336, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data_hour] ([recid], [meter_data_id], [prod_date], [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24], [uom_id], [data_missing], [proxy_date], [source_deal_header_id]) VALUES (4, 10, CAST(0x00009E6100000000 AS DateTime), 4740.818992, 5067.0037600000005, 2724.260448, 5016.0437600000005, 3840.1825279999994, 2444.2148640000005, 3636.1896480000005, 2917.3376959999996, 4257.942416, 4609.3625759999995, 4060.3806879999993, 2319.587088, 5448.266096, 2920.7724, 4255.1498079999992, 4427.618832, 3818.463376, 2755.009712, 3124.7347039999995, 2969.724576, 2719.877888, 5539.994096, 4659.772208, 2370.781504, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data_hour] ([recid], [meter_data_id], [prod_date], [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24], [uom_id], [data_missing], [proxy_date], [source_deal_header_id]) VALUES (5, 10, CAST(0x00009E6200000000 AS DateTime), 5043.908688, 2873.817856, 4252.5304639999995, 6359.053792, 6512.5758879999994, 6839.127567999999, 3857.488544, 4518.398976, 6546.67832, 2694.3775040000005, 6526.3045120000006, 2907.9814400000005, 2870.770448, 3510.389792, 4846.44888, 4038.162128, 5603.327184, 3130.3301120000006, 3354.9312160000004, 4762.048928, 6005.22832, 3664.94128, 3057.4267360000003, 5064.547488, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data_hour] ([recid], [meter_data_id], [prod_date], [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24], [uom_id], [data_missing], [proxy_date], [source_deal_header_id]) VALUES (6, 10, CAST(0x00009E6300000000 AS DateTime), 3730.9548640000003, 2554.7776799999997, 4418.140272, 3708.0534400000006, 2911.334608, 4089.7234560000006, 4626.0876480000006, 4502.998864, 3363.115392, 5220.8316159999995, 5109.9936160000007, 3410.2432000000003, 2625.031136, 4344.013856, 3582.212816, 3444.0194880000004, 1829.086896, 6621.3449120000005, 5257.533008, 3605.379232, 3716.940864, 3438.72984, 2611.220976, 2381.3098400000003, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data_hour] ([recid], [meter_data_id], [prod_date], [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24], [uom_id], [data_missing], [proxy_date], [source_deal_header_id]) VALUES (7, 10, CAST(0x00009E6400000000 AS DateTime), 4992.846768, 1917.747104, 2755.121824, 3090.530352, 3403.2311039999995, 5019.193088, 3245.672976, 4632.06016, 3981.790176, 4881.4889760000005, 2291.6915839999997, 1941.3313920000003, 3188.3837439999998, 6388.2742560000006, 3033.822064, 3860.005968, 4433.0104, 4434.3455520000007, 5229.8107680000012, 3409.723408, 5320.5195680000006, 2294.382272, 5923.48848, 4127.321744, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data_hour] ([recid], [meter_data_id], [prod_date], [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24], [uom_id], [data_missing], [proxy_date], [source_deal_header_id]) VALUES (8, 10, CAST(0x00009E6500000000 AS DateTime), 4141.5599680000005, 5298.00544, 3527.359472, 4987.0679039999995, 3506.771632, 6177.0450560000008, 4733.4094079999995, 3744.33696, 2820.360816, 3271.68296, 4025.5342400000004, 1412.3462079999997, 3807.32352, 4879.9194080000007, 5550.705888, 5268.051152, 3517.330544, 2927.060864, 2902.6816, 5481.8691199999994, 3057.2127039999996, 6836.559184, 4204.006352, 3534.402144, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data_hour] ([recid], [meter_data_id], [prod_date], [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24], [uom_id], [data_missing], [proxy_date], [source_deal_header_id]) VALUES (9, 10, CAST(0x00009E6600000000 AS DateTime), 2417.6239360000004, 6409.575536, 4964.82896, 4991.63392, 4916.702336, 3302.0755040000004, 4890.926768, 4961.0579199999993, 3658.693584, 5994.455376, 4840.771936, 5331.89384, 4323.3240959999994, 3278.379104, 3688.7090239999998, 3345.228432, 5556.586672, 5861.82688, 3683.307264, 4744.467728, 5695.7482400000008, 6300.23576, 4268.429984, 3626.813008, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data_hour] ([recid], [meter_data_id], [prod_date], [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24], [uom_id], [data_missing], [proxy_date], [source_deal_header_id]) VALUES (10, 10, CAST(0x00009E6700000000 AS DateTime), 4802.816928, 4846.418304, 3233.0858559999997, 4514.077568, 4325.9536320000007, 4932.36744, 6204.48192, 3055.96928, 2195.876592, 2650.908624, 4128.4428640000006, 1971.9685440000003, 4222.7596319999993, 4457.3081280000006, 5522.463856, 3839.795232, 2347.023952, 2943.357872, 5847.384816, 4550.697424, 3736.1527840000003, 5292.114464, 5505.10688, 3620.167824, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data_hour] ([recid], [meter_data_id], [prod_date], [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24], [uom_id], [data_missing], [proxy_date], [source_deal_header_id]) VALUES (11, 10, CAST(0x00009E6800000000 AS DateTime), 4517.216704, 2822.409408, 1927.10336, 5175.008384, 5833.707151999999, 3189.1787200000003, 3763.29408, 4103.034208, 1681.1296320000001, 2820.401584, 4382.631344, 3757.647712, 4527.632928, 4261.978448, 3833.3946560000004, 3458.55328, 4093.076624, 4231.4534079999994, 3642.92656, 4947.573904, 2678.875472, 4472.04576, 5164.877536, 6138.4377600000007, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data_hour] ([recid], [meter_data_id], [prod_date], [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24], [uom_id], [data_missing], [proxy_date], [source_deal_header_id]) VALUES (12, 10, CAST(0x00009E6900000000 AS DateTime), 4003.6112479999997, 3999.6465599999997, 3514.4258240000004, 4032.943824, 1314.931072, 2168.725104, 3855.317648, 5512.4349280000006, 5473.2364959999995, 4351.1788320000005, 3726.4398079999992, 4034.207632, 4857.894496, 5990.694528, 2811.6976160000004, 3067.394512, 3422.3003360000002, 3650.336144, 5974.14272, 1779.961456, 4290.159328, 4193.080528, 4121.196352, 2456.7204479999996, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data_hour] ([recid], [meter_data_id], [prod_date], [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24], [uom_id], [data_missing], [proxy_date], [source_deal_header_id]) VALUES (13, 10, CAST(0x00009E6A00000000 AS DateTime), 2657.0951680000003, 5834.848656, 3466.7782240000006, 3760.28744, 3825.404128, 5695.839968, 3313.01152, 2874.082848, 4425.611008, 4877.3510240000005, 4913.97088, 3172.942864, 4615.8650720000005, 1963.9780160000003, 6808.653487999999, 3633.09128, 2784.851888, 3303.7979520000004, 4110.138032, 3985.53064, 5915.090272, 5876.666432, 2653.7012320000003, 3096.9105440000003, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data_hour] ([recid], [meter_data_id], [prod_date], [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24], [uom_id], [data_missing], [proxy_date], [source_deal_header_id]) VALUES (14, 10, CAST(0x00009E6B00000000 AS DateTime), 4752.32576, 2419.845792, 5593.57344, 4747.759744, 4524.269568, 5625.1380640000007, 4221.312368, 3539.3146880000004, 5056.934064, 4509.9396160000006, 5150.782, 4139.613296, 6176.8514079999995, 2771.7857440000002, 2575.7120480000003, 3458.1557920000005, 3293.08616, 2890.267744, 4465.3088480000006, 3667.937728, 5697.134352, 1118.133744, 4924.295376, 3876.608736, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data_hour] ([recid], [meter_data_id], [prod_date], [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24], [uom_id], [data_missing], [proxy_date], [source_deal_header_id]) VALUES (15, 10, CAST(0x00009E6C00000000 AS DateTime), 5059.390336, 3490.128096, 1873.4220959999998, 5239.360672, 3450.511792, 4899.8549600000006, 4357.018848, 3134.111344, 2490.955376, 1408.809584, 4221.821968, 4060.044352, 2517.3016960000004, 3492.268416, 5868.1459200000008, 4019.969408, 5711.871984, 4008.401488, 3728.936848, 5137.0228, 3658.4897440000004, 4456.2685440000005, 3126.508112, 5344.562496, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data_hour] ([recid], [meter_data_id], [prod_date], [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24], [uom_id], [data_missing], [proxy_date], [source_deal_header_id]) VALUES (16, 10, CAST(0x00009E6D00000000 AS DateTime), 4226.296256, 3997.465472, 3013.3157600000004, 3916.907904, 4898.723648, 4298.710416, 3533.10776, 4195.7610239999995, 4706.655408, 2904.4550080000004, 3166.7461279999998, 3502.37888, 2340.6335680000007, 4898.591152, 4449.786432, 3863.1756800000003, 2932.6562719999997, 5511.93552, 4693.51792, 5102.003088, 2250.8726239999996, 5463.197376000001, 4174.296672, 3386.475456, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data_hour] ([recid], [meter_data_id], [prod_date], [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24], [uom_id], [data_missing], [proxy_date], [source_deal_header_id]) VALUES (17, 10, CAST(0x00009E6E00000000 AS DateTime), 3109.5282399999996, 4933.763744, 6676.8505440000008, 4511.804752, 4504.690736, 3704.84296, 5620.949152, 3189.555824, 2163.1806560000005, 1195.0935359999999, 2147.4951680000004, 3706.585792, 5534.3171520000005, 4908.151248, 3694.029248, 4950.9066879999991, 2907.31896, 1719.808272, 2871.453312, 4261.305776, 2092.0914559999997, 3831.0606880000005, 3495.978304, 4883.29296, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data_hour] ([recid], [meter_data_id], [prod_date], [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24], [uom_id], [data_missing], [proxy_date], [source_deal_header_id]) VALUES (18, 10, CAST(0x00009E7700000000 AS DateTime), 1976.5549440000002, 5071.18248, 2648.105824, 6417.9024, 2324.8971199999996, 4495.986768, 5813.149888, 1815.9697919999999, 4365.355904, 4116.426496, 3297.224112, 3750.0037119999997, 4438.25928, 6172.448464, 4006.27136, 5860.328656, 2248.569232, 6314.3007199999993, 4137.85008, 5255.443648, 3496.9363519999997, 4498.514384, 3273.5379040000003, 4481.911616, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data_hour] ([recid], [meter_data_id], [prod_date], [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24], [uom_id], [data_missing], [proxy_date], [source_deal_header_id]) VALUES (19, 10, CAST(0x00009E7800000000 AS DateTime), 3885.944608, 4836.929552, 3489.2515839999996, 3080.7664160000004, 5403.890128, 4658.5491680000005, 3388.0552159999997, 4231.636864, 3726.6130719999996, 7402.8674720000008, 1386.8865919999998, 3529.764784, 4804.794176, 3543.340528, 3033.281888, 4443.875072, 4195.190272, 2096.015376, 4220.537776, 4126.373888, 1860.529216, 5005.8517600000005, 4807.596976, 4003.122032, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data_hour] ([recid], [meter_data_id], [prod_date], [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24], [uom_id], [data_missing], [proxy_date], [source_deal_header_id]) VALUES (20, 10, CAST(0x00009E7900000000 AS DateTime), 4006.1898240000005, 2356.584048, 4402.679008, 4375.201376, 4436.496064, 3196.170432, 5285.866768, 4679.187968, 3768.89968, 2502.03408, 2852.94464, 5124.33376, 4372.052048, 5298.20928, 3158.592528, 1842.204, 5825.064336, 4780.1804960000009, 4554.417504, 1684.238192, 4058.1588319999996, 3345.860336, 4217.021536, 2435.082832, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data_hour] ([recid], [meter_data_id], [prod_date], [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24], [uom_id], [data_missing], [proxy_date], [source_deal_header_id]) VALUES (21, 10, CAST(0x00009E7A00000000 AS DateTime), 2711.7956320000003, 3983.9406879999997, 3449.9512320000003, 2773.732416, 3254.7642400000004, 2576.2929919999997, 5595.143008, 2584.069488, 4595.134544, 3976.439376, 3957.1051519999996, 4027.52168, 4259.277568, 3843.2401280000004, 3090.295936, 2205.834176, 4175.05088, 5912.3384320000005, 3991.2075839999993, 2151.806384, 5697.776448, 2953.804672, 2432.8100160000004, 2739.283456, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data_hour] ([recid], [meter_data_id], [prod_date], [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24], [uom_id], [data_missing], [proxy_date], [source_deal_header_id]) VALUES (22, 10, CAST(0x00009E7B00000000 AS DateTime), 4097.775136, 5592.6153920000006, 5640.4974079999993, 3023.7727520000003, 3565.090256, 6326.001136, 4315.038, 2931.4128480000008, 5311.71368, 3869.0870400000003, 3641.897168, 4862.95992, 2451.8690559999995, 3562.144768, 3797.69208, 5561.9680480000006, 5364.294208, 4105.612784, 4318.065024, 3621.1870240000003, 2850.0704960000003, 5725.906368, 5907.986448, 4286.90808, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data_hour] ([recid], [meter_data_id], [prod_date], [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24], [uom_id], [data_missing], [proxy_date], [source_deal_header_id]) VALUES (23, 10, CAST(0x00009E7C00000000 AS DateTime), 5169.749312, 4960.0285280000007, 3121.1776960000007, 4080.224512, 4379.512592, 5380.96832, 3965.8193120000005, 3043.1579359999996, 4640.346256, 3635.2417920000003, 4288.7630240000008, 4302.685296, 4113.715424, 4325.352304, 2852.221008, 4287.529792, 4642.802528, 2759.7388, 4045.235376, 5123.141296, 3857.2745119999995, 5301.745904, 5652.7481920000009, 5004.975248, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data_hour] ([recid], [meter_data_id], [prod_date], [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24], [uom_id], [data_missing], [proxy_date], [source_deal_header_id]) VALUES (24, 10, CAST(0x00009E6F00000000 AS DateTime), 5239.40144, 4173.715728, 4833.698688, 4568.910528, 5599.719216, 3042.9744800000003, 2800.211232, 3569.870304, 3098.06224, 5153.768256, 3193.05168, 4963.2084319999994, 2474.7297120000003, 4288.610144, 4082.5686720000003, 3837.0943520000005, 691.190864, 1831.1049119999998, 3085.32224, 5481.20664, 5955.022528, 3392.4989279999995, 2882.205872, 2497.631136, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data_hour] ([recid], [meter_data_id], [prod_date], [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24], [uom_id], [data_missing], [proxy_date], [source_deal_header_id]) VALUES (25, 10, CAST(0x00009E7000000000 AS DateTime), 3781.5581440000005, 2797.673424000001, 4258.288944, 1087.69024, 3150.3777760000003, 4204.464992, 3907.51088, 3876.62912, 4148.60264, 4611.67616, 6522.054447999999, 3137.8008480000003, 5290.2799040000009, 2456.1191200000003, 4455.371648, 4752.2238400000006, 2820.5952319999997, 1985.340448, 2715.138608, 4005.7617600000003, 2331.2976960000005, 5655.214656, 2591.560608, 3328.564512, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data_hour] ([recid], [meter_data_id], [prod_date], [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24], [uom_id], [data_missing], [proxy_date], [source_deal_header_id]) VALUES (26, 10, CAST(0x00009E7100000000 AS DateTime), 5040.0153439999995, 3474.1572319999996, 2375.378096, 3840.3557920000003, 3758.24904, 3820.501776, 3880.379776, 3374.224672, 3878.10696, 2678.844896, 4214.147392, 5382.925184, 5903.338896, 5000.633456, 2329.452944, 2388.1894400000006, 4428.7603359999994, 5799.492608, 4990.380304, 3925.214384, 4120.737712, 4849.822432, 4904.370016, 5272.464288, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data_hour] ([recid], [meter_data_id], [prod_date], [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24], [uom_id], [data_missing], [proxy_date], [source_deal_header_id]) VALUES (27, 10, CAST(0x00009E7200000000 AS DateTime), 3182.258352, 5599.148464, 4279.223312, 5440.8463200000006, 4876.2299040000007, 5063.966544, 7085.8351200000006, 3243.3797759999998, 2666.339312, 5124.323568, 3931.686304, 3956.1063360000007, 6952.1364639999993, 4867.4443999999994, 2150.2775840000004, 4392.1914400000005, 3881.4601279999997, 4261.744032, 4404.126272, 6317.592736, 2834.59904, 4590.2321919999995, 4946.5139359999994, 4090.080176, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data_hour] ([recid], [meter_data_id], [prod_date], [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24], [uom_id], [data_missing], [proxy_date], [source_deal_header_id]) VALUES (28, 10, CAST(0x00009E7300000000 AS DateTime), 5796.2107840000008, 3229.253664, 4283.605872, 3111.536064, 5418.362768, 1896.5069760000001, 5210.935184, 3753.1530399999997, 4379.053952, 4150.8856479999995, 4052.3392, 1411.367776, 3467.21648, 3249.3115199999997, 6011.200832, 4751.061952, 4648.408128, 1300.387088, 3853.0448319999996, 2733.4638239999995, 2352.843584, 2865.970016, 4772.6588, 3707.44192, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data_hour] ([recid], [meter_data_id], [prod_date], [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24], [uom_id], [data_missing], [proxy_date], [source_deal_header_id]) VALUES (29, 10, CAST(0x00009E7400000000 AS DateTime), 2267.842304, 4899.4982400000008, 4002.19456, 5108.342512, 2535.290576, 4352.524176, 4447.1263199999994, 3860.953824, 3135.079584, 5627.2885760000008, 6097.231504, 4305.55944, 5810.91784, 5158.792912, 5067.992384, 3125.0506560000003, 3361.3827520000004, 5216.1331040000005, 5784.174032, 5513.841424, 3697.779904, 5458.6313599999994, 3007.3738240000002, 3497.0892320000003, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data_hour] ([recid], [meter_data_id], [prod_date], [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24], [uom_id], [data_missing], [proxy_date], [source_deal_header_id]) VALUES (30, 10, CAST(0x00009E7500000000 AS DateTime), 3757.912704, 5532.452016, 3893.079008, 4326.075936, 2847.298272, 4381.08216, 4157.704096, 6549.2467039999992, 5452.3021279999994, 3193.86704, 5539.871792, 4091.415328, 5834.92, 7220.0433760000005, 2059.079568, 3786.042624, 5002.64128, 2654.5675520000004, 3766.1886080000004, 5451.007744, 7074.562768, 4819.817184, 2895.078368, 4416.998768, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data_hour] ([recid], [meter_data_id], [prod_date], [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24], [uom_id], [data_missing], [proxy_date], [source_deal_header_id]) VALUES (31, 10, CAST(0x00009E7600000000 AS DateTime), 5787.792192, 3448.6976160000004, 4558.412768, 5343.390416, 4099.5281600000008, 4062.2254399999997, 5086.052608, 4607.0082239999992, 3751.287904, 5756.023728, 4965.104144, 4836.878592, 4006.2204, 5517.2761279999995, 3814.091008, 3655.5850240000004, 6337.3856, 5037.080048, 3171.210224, 3358.457648, 3862.4826239999998, 3812.297216, 5662.787312, 3243.9709119999998, NULL, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[mv90_data_hour] OFF
Go
SET IDENTITY_INSERT [dbo].[mv90_data] ON
INSERT [dbo].[mv90_data] ([meter_data_id], [meter_id], [gen_date], [from_date], [to_date], [channel], [volume], [uom_id], [descriptions], [create_user], [create_ts], [update_user], [update_ts]) VALUES (1, 1, CAST(0x00009E5E00000000 AS DateTime), CAST(0x00009E5E00000000 AS DateTime), CAST(0x00009E7C00000000 AS DateTime), 1, 1646649.9636467707, 0, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data] ([meter_data_id], [meter_id], [gen_date], [from_date], [to_date], [channel], [volume], [uom_id], [descriptions], [create_user], [create_ts], [update_user], [update_ts]) VALUES (2, 1, CAST(0x00009E7D00000000 AS DateTime), CAST(0x00009E7D00000000 AS DateTime), CAST(0x00009E9800000000 AS DateTime), 1, 1429977.745350709, 0, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data] ([meter_data_id], [meter_id], [gen_date], [from_date], [to_date], [channel], [volume], [uom_id], [descriptions], [create_user], [create_ts], [update_user], [update_ts]) VALUES (3, 1, CAST(0x00009E9900000000 AS DateTime), CAST(0x00009E9900000000 AS DateTime), CAST(0x00009EB700000000 AS DateTime), 1, 1423075.3927569427, 0, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data] ([meter_data_id], [meter_id], [gen_date], [from_date], [to_date], [channel], [volume], [uom_id], [descriptions], [create_user], [create_ts], [update_user], [update_ts]) VALUES (4, 2, CAST(0x00009E5E00000000 AS DateTime), CAST(0x00009E5E00000000 AS DateTime), CAST(0x00009E7C00000000 AS DateTime), 1, 3552594.6888588406, 0, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data] ([meter_data_id], [meter_id], [gen_date], [from_date], [to_date], [channel], [volume], [uom_id], [descriptions], [create_user], [create_ts], [update_user], [update_ts]) VALUES (5, 2, CAST(0x00009E7D00000000 AS DateTime), CAST(0x00009E7D00000000 AS DateTime), CAST(0x00009E9800000000 AS DateTime), 1, 2863641.075316383, 0, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data] ([meter_data_id], [meter_id], [gen_date], [from_date], [to_date], [channel], [volume], [uom_id], [descriptions], [create_user], [create_ts], [update_user], [update_ts]) VALUES (6, 2, CAST(0x00009E9900000000 AS DateTime), CAST(0x00009E9900000000 AS DateTime), CAST(0x00009EB700000000 AS DateTime), 1, 2040762.7067010754, 0, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data] ([meter_data_id], [meter_id], [gen_date], [from_date], [to_date], [channel], [volume], [uom_id], [descriptions], [create_user], [create_ts], [update_user], [update_ts]) VALUES (7, 3, CAST(0x00009E5E00000000 AS DateTime), CAST(0x00009E5E00000000 AS DateTime), CAST(0x00009E7C00000000 AS DateTime), 1, 7105189.37771768, 0, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data] ([meter_data_id], [meter_id], [gen_date], [from_date], [to_date], [channel], [volume], [uom_id], [descriptions], [create_user], [create_ts], [update_user], [update_ts]) VALUES (8, 3, CAST(0x00009E7D00000000 AS DateTime), CAST(0x00009E7D00000000 AS DateTime), CAST(0x00009E9800000000 AS DateTime), 1, 5727282.1506327651, 0, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data] ([meter_data_id], [meter_id], [gen_date], [from_date], [to_date], [channel], [volume], [uom_id], [descriptions], [create_user], [create_ts], [update_user], [update_ts]) VALUES (9, 3, CAST(0x00009E9900000000 AS DateTime), CAST(0x00009E9900000000 AS DateTime), CAST(0x00009EB700000000 AS DateTime), 1, 4081525.4134021509, 0, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data] ([meter_data_id], [meter_id], [gen_date], [from_date], [to_date], [channel], [volume], [uom_id], [descriptions], [create_user], [create_ts], [update_user], [update_ts]) VALUES (10, 4, CAST(0x00009E5E00000000 AS DateTime), CAST(0x00009E5E00000000 AS DateTime), CAST(0x00009E7C00000000 AS DateTime), 1, 1646649.9636467707, 0, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data] ([meter_data_id], [meter_id], [gen_date], [from_date], [to_date], [channel], [volume], [uom_id], [descriptions], [create_user], [create_ts], [update_user], [update_ts]) VALUES (11, 4, CAST(0x00009E7D00000000 AS DateTime), CAST(0x00009E7D00000000 AS DateTime), CAST(0x00009E9800000000 AS DateTime), 1, 1429977.745350709, 0, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[mv90_data] ([meter_data_id], [meter_id], [gen_date], [from_date], [to_date], [channel], [volume], [uom_id], [descriptions], [create_user], [create_ts], [update_user], [update_ts]) VALUES (12, 4, CAST(0x00009E9900000000 AS DateTime), CAST(0x00009E9900000000 AS DateTime), CAST(0x00009EB700000000 AS DateTime), 1, 1423075.3927569427, 0, NULL, NULL, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[mv90_data] OFF
