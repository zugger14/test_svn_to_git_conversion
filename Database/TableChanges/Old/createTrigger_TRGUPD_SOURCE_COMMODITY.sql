SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID('[dbo].[TRGUPD_SOURCE_COMMODITY]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_SOURCE_COMMODITY]
GO

CREATE TRIGGER [dbo].[TRGUPD_SOURCE_COMMODITY]
ON [dbo].[source_commodity]
FOR  UPDATE
AS
	DECLARE @update_user  VARCHAR(200)
	DECLARE @update_ts    DATETIME
	
	SET @update_user = dbo.FNADBUser()
	SET @update_ts = GETDATE()
	
	UPDATE dbo.source_commodity
	SET    update_user = @update_user,
	       update_ts = @update_ts
	FROM   dbo.source_commodity sc
	       INNER JOIN DELETED u ON  sc.source_commodity_id = u.source_commodity_id  
	
	INSERT INTO source_commodity_audit
	  (
	    [source_commodity_id],
	    [source_system_id],
	    [commodity_id],
	    [commodity_name],
	    [commodity_desc],
	    [create_user],
	    [create_ts],
	    [update_user],
	    [update_ts],
	    [user_action]
	  )
	SELECT [source_commodity_id],
	       [source_system_id],
	       [commodity_id],
	       [commodity_name],
	       [commodity_desc],
	       [create_user],
	       [create_ts],
	       @update_user,
	       @update_ts,
	       'update' [user_action]
	FROM   INSERTED