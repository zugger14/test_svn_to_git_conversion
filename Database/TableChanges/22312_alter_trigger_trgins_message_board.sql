/****** Object:  Trigger [dbo].[TRGINS_message_board]    Script Date: 3/12/2018 5:16:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER TRIGGER [dbo].[TRGINS_message_board]
ON [dbo].[message_board]
FOR  INSERT
AS
	INSERT INTO message_board_audit
	  (
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
		'insert'
	FROM   INSERTED


	DECLARE	@memcache_key			VARCHAR(MAX)	
	 
	IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
	BEGIN
		SELECT  @memcache_key = COALESCE(@memcache_key + ',' , '') + db_name() +'_MB_'  + user_login_id + '_c'
	+ ',' + db_name() +'_MB_'  + user_login_id + '_v'
		FROM INSERTED
		GROUP BY user_login_id
		
		IF @memcache_key IS NOT NULL
		EXEC [spa_manage_memcache] @flag = 'd', @key_prefix = @memcache_key, @source_object='TRGINS_message_board'
		
	END
	