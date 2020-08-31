SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER TRIGGER [dbo].[TRGDEL_message_board]
ON [dbo].[message_board]
FOR  DELETE
AS
	INSERT INTO message_board_audit (
	    message_id,
		user_login_id,
		source,
		description,
		url_desc,
		url,
		type,
		job_name,
		as_of_date,
		create_ts,
		create_user,
		update_ts,
		update_user,
		process_id,
		process_type,
		reminderDate,
		source_id,
		delActive,
		message_attachment,
		is_alert,
		is_alert_processed,
		user_action
	  )
	SELECT message_id,
			user_login_id,
			source,
			REPLACE(description,'./dev', '.'),
			url_desc,
			url,
			type,
			job_name,
			as_of_date,
			create_ts,
			create_user,
			update_ts,
			update_user,
			process_id,
			process_type,
			reminderDate,
			source_id,
			delActive,
			message_attachment,
			is_alert,
			is_alert_processed,
	       'delete'
	FROM   DELETED

	DECLARE	@memcache_key			VARCHAR(MAX)	
	 
	IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
	BEGIN
		SELECT  @memcache_key = COALESCE(@memcache_key + ',' , '') + db_name() +'_MB_'  + user_login_id
		FROM DELETED
		GROUP BY user_login_id
		
		IF @memcache_key IS NOT NULL
		EXEC [spa_manage_memcache] @flag = 'd', @key_prefix = @memcache_key
		
	END
	