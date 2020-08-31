
/****** Object:  Trigger [TRGINS_METER_ID]    Script Date: 02/20/2012 18:40:18 ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGINS_METER_ID]'))
DROP TRIGGER [dbo].[TRGINS_METER_ID]
GO

/****** Object:  Trigger [dbo].[TRGINS_METER_ID]    Script Date: 02/20/2012 18:40:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE TRIGGER [dbo].[TRGINS_METER_ID]
ON [dbo].[meter_id]
FOR INSERT
AS
UPDATE meter_id SET create_user =dbo.FNADBUser(), create_ts = getdate() where  meter_id.meter_id in (select meter_id from inserted)



GO

/****** Object:  Trigger [TRGUPD_METER_ID]    Script Date: 02/20/2012 18:43:58 ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGUPD_METER_ID]'))
DROP TRIGGER [dbo].[TRGUPD_METER_ID]
GO

/****** Object:  Trigger [dbo].[TRGUPD_METER_ID]    Script Date: 02/20/2012 18:44:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE TRIGGER [dbo].[TRGUPD_METER_ID]
ON [dbo].[meter_id]
FOR UPDATE
AS
UPDATE meter_id SET update_user =dbo.FNADBUser(), update_ts = getdate() where  meter_id.meter_id in (select meter_id from deleted)



GO


/****** Object:  Trigger [TRGINS_mv90_data]    Script Date: 02/20/2012 18:40:18 ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGINS_mv90_data]'))
DROP TRIGGER [dbo].[TRGINS_mv90_data]
GO

/****** Object:  Trigger [dbo].[TRGINS_mv90_data]    Script Date: 02/20/2012 18:40:25 ******/
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


/****** Object:  Trigger [TRGUPD_mv90_data]    Script Date: 02/20/2012 18:43:58 ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGUPD_mv90_data]'))
DROP TRIGGER [dbo].[TRGUPD_mv90_data]
GO

/****** Object:  Trigger [dbo].[TRGUPD_mv90_data]    Script Date: 02/20/2012 18:44:04 ******/
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





