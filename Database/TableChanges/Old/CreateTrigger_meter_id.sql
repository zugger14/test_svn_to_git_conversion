/****** Object:  Trigger [TRGUPD_meter_id]    Script Date: 12/14/2011 14:10:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGUPD_meter_id]'))
EXEC dbo.sp_executesql @statement = N'



CREATE TRIGGER [dbo].[TRGUPD_meter_id]
ON [dbo].[meter_id]
FOR UPDATE
AS
UPDATE meter_id SET update_user = dbo.FNADBUser(), update_ts = getdate() where  meter_id.meter_id in (select meter_id from deleted)




'
GO
/****** Object:  Trigger [TRGINS_meter_id]    Script Date: 12/14/2011 14:10:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGINS_meter_id]'))
EXEC dbo.sp_executesql @statement = N'




CREATE TRIGGER [dbo].[TRGINS_meter_id]
ON [dbo].[meter_id]
FOR INSERT
AS
UPDATE meter_id SET create_user =dbo.FNADBUser(), create_ts = getdate() where  meter_id.meter_id in (select meter_id from inserted)





'
GO
