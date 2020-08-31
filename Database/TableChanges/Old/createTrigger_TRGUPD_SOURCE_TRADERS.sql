SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID('[dbo].[TRGUPD_SOURCE_TRADERS]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_SOURCE_TRADERS]
GO

CREATE TRIGGER [dbo].[TRGUPD_SOURCE_TRADERS]
ON [dbo].[source_traders]
FOR UPDATE
AS                                     
    
    DECLARE @update_user  VARCHAR(200)
    DECLARE @update_ts    DATETIME

	SET @update_user = dbo.FNADBUser()
	SET @update_ts = GETDATE()
	
	UPDATE dbo.source_traders
       SET update_user = @update_user,
           update_ts = @update_ts
    FROM dbo.source_traders st
      INNER JOIN DELETED u ON st.source_trader_id = u.source_trader_id  
    
	INSERT INTO source_traders_audit
	(
		source_trader_id,
		source_system_id,
		trader_id,
		trader_name,
		trader_desc,
		create_user,
		create_ts,
		update_user,
		update_ts,
		user_login_id,
		user_action
	)
	SELECT 
		source_trader_id,
		source_system_id,
		trader_id,
		trader_name,
		trader_desc,
		create_user,
		create_ts,
		@update_user,
		@update_ts,
		user_login_id,
		'update' [user_action] 
	FROM INSERTED