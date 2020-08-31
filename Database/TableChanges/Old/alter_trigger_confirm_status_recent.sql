IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGUPD_CONFIRM_STATUS_RECENT]'))
DROP TRIGGER [dbo].[TRGUPD_CONFIRM_STATUS_RECENT]
GO

CREATE TRIGGER [TRGUPD_CONFIRM_STATUS_RECENT]
ON [dbo].[confirm_status_recent]
FOR UPDATE
AS
UPDATE CONFIRM_STATUS_RECENT SET update_user = dbo.FNADBUser(), update_ts = getdate() 
where  CONFIRM_STATUS_RECENT.confirm_status_id in (select confirm_status_id from deleted)
GO


IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGINS_CONFIRM_STATUS_RECENT]'))
DROP TRIGGER [dbo].[TRGINS_CONFIRM_STATUS_RECENT]
GO

CREATE TRIGGER [TRGINS_CONFIRM_STATUS_RECENT]
ON [dbo].[confirm_status_recent]
FOR INSERT
AS
UPDATE CONFIRM_STATUS_RECENT SET create_user = dbo.FNADBUser(), create_ts = getdate() where  CONFIRM_STATUS_RECENT.confirm_status_id in (select confirm_status_id from inserted)

GO

