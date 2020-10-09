/****** Object:  StoredProcedure [dbo].[spa_NotificationUserByRole]    Script Date: 12/09/2011 22:16:09 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_NotificationUserByRole]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_NotificationUserByRole]
GO

/****** Object:  StoredProcedure [dbo].[spa_NotificationUserByRole]    Script Date: 12/09/2011 22:16:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--EXEC spa_NotificationUserByRole 5,'xxxxx','Tray-Port','Test1 xy','e','Tray-Port Import'  
create PROC [dbo].[spa_NotificationUserByRole]    
@role_type_value_id INT,    
@process_id VARCHAR(150),    
@source VARCHAR(50),    
@description VARCHAR(8000),    
@errorcode VARCHAR(20),    
@job_name varchar(MAX) = NULL,
@include_self BIT = 0, --to include the dbo.FNADBUser() that triggered the import manaully when value is set to 1 .
@email_enable BIT = 0,
@role_ids VARCHAR(MAX) = NULL
AS     

/*-----------------------------------------Test Script--------------------------------------------------------*/
/*
DECLARE @role_type_value_id INT,    
	@process_id VARCHAR(150),    
	@source VARCHAR(50),    
	@description VARCHAR(255),    
	@errorcode VARCHAR(20),    
	@job_name varchar(MAX) ,
	@include_self BIT
	
SET @role_type_value_id = 2    
SET	@process_id = '123112121'  
SET	@source = 'test'   
SET	@description = 'test123'
SET	@errorcode = 'e' 
SET	@job_name = 'job1'
SET	@include_self = 1
--*/
/*-----------------------------------------End Test Script--------------------------------------------------------*/ 
    
DECLARE @as_of_date datetime   
	, @sql VARCHAR(8000)
	, @user VARCHAR(50) 
	, @email_description VARCHAR(8000)

IF @role_type_value_id=5  --------- Notify by Email    
 SET @email_enable=1   
 
set @as_of_date=GETDATE()
SELECT  @email_description = dbo.FNAStripAnchor(@description)

SET @sql = '
	DECLARE list_user CURSOR FOR     
	SELECT application_users.user_login_id
	FROM dbo.application_role_user 
	INNER JOIN dbo.application_security_role ON dbo.application_role_user.role_id = dbo.application_security_role.role_id     
	INNER JOIN dbo.application_users ON dbo.application_role_user.user_login_id = dbo.application_users.user_login_id
	' + CASE WHEN @role_ids IS NOT NULL THEN '
	INNER JOIN dbo.SplitCommaSeperatedValues(''' + @role_ids + ''') a ON a.item = dbo.application_security_role.role_id
	' ELSE '' END + '    
	WHERE (dbo.application_users.user_active = ''y'') AND (dbo.application_security_role.role_type_value_id = ' + cast(@role_type_value_id AS VARCHAR(10)) +') 
	GROUP BY dbo.application_users.user_login_id, dbo.application_users.user_emal_add ' + 
	CASE WHEN @include_self = 1 THEN 'UNION SELECT dbo.FNADBUser() user_login_id ' ELSE '' END  
	
	
EXEC spa_print @sql
EXEC(@sql)            
            
OPEN list_user    
FETCH NEXT FROM list_user INTO @user    
WHILE @@FETCH_STATUS = 0    
BEGIN     
	IF @source = 'ImportData'
	BEGIN
		--EXEC spa_message_board 'u', @user, NULL, @source, @description, '', '', @errorcode, @job_name, @as_of_date, @process_id
		IF NOT EXISTS(SELECT 1 FROM message_board WHERE user_login_id = @user AND process_id = @process_id AND type = 'e')
		INSERT INTO message_board(user_login_id, source, [description], url_desc, url, TYPE, job_name, as_of_date,process_id)
		SELECT @user, @source, ISNULL(@description, 'Description is not available.'), '', '', @errorcode, ISNULL(@job_name,@process_id), @as_of_date,@process_id


 	    IF @email_enable = 1
		BEGIN
			INSERT INTO email_notes
			  (
				[send_status],
				[active_flag],
				[notes_subject],
				[notes_text],
				[send_from],
				[send_to],
				[process_id],
				[notes_description]
			  )
			SELECT DISTINCT
				   'n',
				   'y',
				   @source + ' Notification',
				   ISNULL(@email_description , 'Description is not available.'),
				   'noreply@pioneersolutionsglobal.com',
				   user_emal_add,
				   @process_id,
				   ISNULL(@email_description , 'Description is not available.')
			FROM application_users au
			LEFT JOIN email_notes en ON [send_from] = au.user_emal_add AND en.process_id = @process_id
			WHERE au.user_login_id = @user
		END
	END  
	ELSE
		BEGIN         
		INSERT INTO message_board(user_login_id, source, [description], url_desc, url, TYPE, job_name, as_of_date,process_id)
		--TODO: Sometimes, description becomes NULL while importing from Trayport, which triggers error as description is not NULLABLE column in message_board
		--So for now, it is set a default value.                	
		SELECT 
		@user, @source, ISNULL(@description, 'Description is not available.'), '', '', @errorcode, @process_id, @as_of_date,@process_id       
	END
	FETCH NEXT FROM list_user INTO      @user    
END    
CLOSE list_user    
DEALLOCATE list_user      
GO


