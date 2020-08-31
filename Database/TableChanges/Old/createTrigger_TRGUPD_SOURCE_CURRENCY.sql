SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID('[dbo].[TRGUPD_SOURCE_CURRENCY]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_SOURCE_CURRENCY]
GO

CREATE TRIGGER [dbo].[TRGUPD_SOURCE_CURRENCY]
ON [dbo].[source_currency]
FOR  UPDATE
AS
	DECLARE @update_user  VARCHAR(200)
	DECLARE @update_ts    DATETIME
	
	SET @update_user = dbo.FNADBUser()
	SET @update_ts = GETDATE()
	
	UPDATE dbo.source_currency
	SET    update_user = @update_user,
	       update_ts = @update_ts
	FROM   dbo.source_currency sc
	INNER JOIN DELETED u ON  sc.source_currency_id = u.source_currency_id  
	
	INSERT INTO source_currency_audit
	  (
	    [source_currency_id],
	    [source_system_id],
	    [currency_id],
	    [currency_name],
	    [currency_desc],
	    [currency_id_to],
	    [factor],
	    [create_user],
	    [create_ts],
	    [update_user],
	    [update_ts],
	    [user_action]
	  )
	SELECT [source_currency_id],
	       [source_system_id],
	       [currency_id],
	       [currency_name],
	       [currency_desc],
	       [currency_id_to],
	       [factor],
	       [create_user],
	       [create_ts],
	       @update_user,
	       @update_ts,
	       'update' [user_action]
	FROM   INSERTED