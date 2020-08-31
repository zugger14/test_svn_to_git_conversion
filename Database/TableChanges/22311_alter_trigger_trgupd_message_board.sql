/****** Object:  Trigger [dbo].[TRGUPD_message_board]    Script Date: 3/12/2018 6:06:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER TRIGGER [dbo].[TRGUPD_message_board]
ON [dbo].[message_board]
FOR UPDATE
AS                                     
    
    DECLARE @update_user  VARCHAR(200)
    DECLARE @update_ts    DATETIME

	SET @update_user = dbo.FNADBUser()
	SET @update_ts = GETDATE()
	--Below code is added to bypass audit and update ts logic when is_read and/or update ts is updated. If any other column is updated then detail should be logged in audit table. 
	IF EXISTS(SELECT 1
		FROM INSERTED i
		INNER JOIN DELETED d ON d.message_id = i.message_id
		WHERE 
		CHECKSUM(
			ISNULL(i.message_id,'')
			,ISNULL(i.user_login_id,'')
			,ISNULL(i.source,'')
			,ISNULL(i.description,'')
			,ISNULL(i.url_desc,'')
			,ISNULL(i.url,'')
			,ISNULL(i.type,'')
			,ISNULL(i.job_name,'')
			,ISNULL(i.as_of_date,'')
			,ISNULL(i.create_ts,'')
			,ISNULL(i.create_user,'')
			,ISNULL(i.process_id,'')
			,ISNULL(i.process_type,'')
			,ISNULL(i.reminderDate,'')
			,ISNULL(i.source_id,'')
			,ISNULL(i.delActive,'')
			,ISNULL(i.message_attachment,'')
			,ISNULL(i.is_alert,'')
			,ISNULL(i.is_alert_processed,'')
			,ISNULL(i.additional_message,'')
			,ISNULL(i.workflow_activity_id,'')
		) <>  
			CHECKSUM(
		   ISNULL(d.message_id,'')
			,ISNULL(d.user_login_id,'')
			,ISNULL(d.source,'')
			,ISNULL(d.description,'')
			,ISNULL(d.url_desc,'')
			,ISNULL(d.url,'')
			,ISNULL(d.type,'')
			,ISNULL(d.job_name,'')
			,ISNULL(d.as_of_date,'')
			,ISNULL(d.create_ts,'')
			,ISNULL(d.create_user,'')
			,ISNULL(d.process_id,'')
			,ISNULL(d.process_type,'')
			,ISNULL(d.reminderDate,'')
			,ISNULL(d.source_id,'')
			,ISNULL(d.delActive,'')
			,ISNULL(d.message_attachment,'')
			,ISNULL(d.is_alert,'')
			,ISNULL(d.is_alert_processed,'')
			,ISNULL(d.additional_message,'')
			,ISNULL(d.workflow_activity_id,'')
		))
	BEGIN
		UPDATE dbo.message_board
		   SET update_user = @update_user,
			   update_ts = @update_ts
		FROM dbo.message_board sc
		  INNER JOIN DELETED u ON sc.message_id = u.message_id  
	    

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
			update_user,
			update_ts,
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
			@update_user,
			GETDATE(),
			process_id,
			process_type,
			reminderDate,
			source_id,
			delActive,
			message_attachment,
			is_alert,
			is_alert_processed,
			'update'
		FROM INSERTED

	END
	
	DECLARE	@memcache_key VARCHAR(MAX)
		
	IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
	BEGIN
		--Check if data of reminderdate,is_read is updated.
		IF (UPDATE(reminderdate) OR UPDATE(is_read) OR UPDATE([description]) OR UPDATE(additional_message))
		--(SUBSTRING(COLUMNS_UPDATED(),3,1) & 64 = 64)
		BEGIN			
			SELECT    @memcache_key = COALESCE(@memcache_key + ',' , '') + db_name() +'_MB_'  + i.user_login_id + '_c'
				+ ',' + db_name() +'_MB_'  + i.user_login_id + '_v'
			FROM INSERTED i
			INNER JOIN DELETED d ON d.message_id = i.message_id
			WHERE CHECKSUM(i.is_read,ISNULL(i.reminderdate,''),ISNULL(i.[description],''),ISNULL(i.additional_message,'')) <>  
				CHECKSUM(d.is_read,ISNULL(d.reminderdate,''),ISNULL(d.[description],''),ISNULL(d.additional_message,''))
			GROUP BY i.user_login_id
			
			IF @memcache_key IS NOT NULL
			BEGIN
				EXEC [spa_manage_memcache] @flag = 'd', @key_prefix = @memcache_key, @source_object='TRGUPD_message_board'
			END
		END 
	END