
GO
/****** Object:  Table [dbo].[group_meter_mapping]    Script Date: 12/14/2011 13:33:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[group_meter_mapping]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[group_meter_mapping](
	[group_meter_mapping_id] [int] IDENTITY(1,1) NOT NULL,
	[counterparty_id] [int] NULL,
	[region_id] [int] NULL,
	[grid_id] [int] NULL,
	[category_id] [int] NULL,
	[pv_party_id] [int] NULL,
	[meter_id] [int] NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Trigger [TRGUPD_group_meter_mapping]    Script Date: 12/14/2011 13:33:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGUPD_group_meter_mapping]'))
EXEC dbo.sp_executesql @statement = N'



CREATE TRIGGER [dbo].[TRGUPD_group_meter_mapping]
ON [dbo].[group_meter_mapping]
FOR UPDATE
AS
UPDATE group_meter_mapping SET update_user = dbo.FNADBUser(), update_ts = getdate() where  group_meter_mapping.group_meter_mapping_id in (select group_meter_mapping_id from deleted)




'
GO
/****** Object:  Trigger [TRGINS_group_meter_mapping]    Script Date: 12/14/2011 13:33:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGINS_group_meter_mapping]'))
EXEC dbo.sp_executesql @statement = N'




CREATE TRIGGER [dbo].[TRGINS_group_meter_mapping]
ON [dbo].[group_meter_mapping]
FOR INSERT
AS
UPDATE group_meter_mapping SET create_user =dbo.FNADBUser(), create_ts = getdate() where  group_meter_mapping.group_meter_mapping_id in (select group_meter_mapping_id from inserted)





'
GO
