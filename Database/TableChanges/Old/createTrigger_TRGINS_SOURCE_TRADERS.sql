SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGINS_SOURCE_TRADERS]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGINS_SOURCE_TRADERS]
GO

CREATE TRIGGER [dbo].[TRGINS_SOURCE_TRADERS]
ON [dbo].[source_traders]
FOR  INSERT
AS

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
		ISNULL(create_user, dbo.FNADBUser()),
		ISNULL(create_ts, GETDATE()),
		update_user,
		update_ts,
		user_login_id,
		'insert' 
	FROM   INSERTED


