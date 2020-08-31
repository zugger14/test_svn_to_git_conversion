IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGUPD_source_remit_standard]'))
DROP TRIGGER [dbo].TRGUPD_source_remit_standard
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[TRGUPD_source_remit_standard]
ON [dbo].[source_remit_standard]
FOR UPDATE
AS
UPDATE source_remit_standard SET update_user =dbo.FNADBUser(), update_ts = getdate() where  source_remit_standard.id in (select id from deleted)

GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGUPD_source_remit_non_standard]'))
DROP TRIGGER [dbo].TRGUPD_source_remit_non_standard
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].TRGUPD_source_remit_non_standard
ON [dbo].[source_remit_non_standard]
FOR UPDATE
AS
UPDATE source_remit_non_standard SET update_user =dbo.FNADBUser(), update_ts = getdate() where  source_remit_non_standard.id in (select id from deleted)

GO
