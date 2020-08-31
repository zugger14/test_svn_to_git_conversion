
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGUPD_DELIVERY_STATUS]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_DELIVERY_STATUS]
GO

CREATE TRIGGER [dbo].[TRGUPD_DELIVERY_STATUS]
ON [dbo].[delivery_status]
FOR  UPDATE
AS
	UPDATE delivery_status
	SET    update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	WHERE  delivery_status.Id IN (SELECT Id
	                              FROM   DELETED)




