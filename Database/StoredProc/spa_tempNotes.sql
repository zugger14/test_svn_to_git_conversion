IF  EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_tempNotes]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_tempNotes]

GO 

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

Create PROC [dbo].[spa_tempNotes]
@send_to VARCHAR(3000) = null,
@send_cc VARCHAR(3000) = null,
@send_bcc VARCHAR(3000) = null,
@message VARCHAR(max),
@internal_type_value_id INT = null,
@file_attachment_path VARCHAR(5000) = null,
@subject VARCHAR(5000),
@user_ids VARCHAR(2000) = null,
@file_attachment_name varchar(2000) = null,
@email_type CHAR(1) = 'o',
@user_category INT = NULL,
@admin_email_configuration_id INT = NULL,
@notes_object_id INT = null,
@notes_id varchar(1000) = null
AS
SET NOCOUNT ON
/*

declare @send_to VARCHAR(100) = null,
@send_cc VARCHAR(100) = null,
@send_bcc VARCHAR(100) = null,
@message VARCHAR(1000),
@internal_type_value_id INT = null,
@file_attachment_path VARCHAR(2000) = null,
@subject VARCHAR(1000),
@user_ids VARCHAR(2000) = null,
@file_attachment_name varchar(300) = null,
@email_type char(1) = 'o',
@user_category int = NULL,
@admin_email_configuration_id INT = NULL

select @send_cc=NULL, @send_bcc=NULL, @internal_type_value_id=NULL, @send_to='', @subject='test', @message='<p>test ggg<br data-mce-bogus="1"></p>', @file_attachment_name='D:\Farrms\TRMTracker_New_Framework_Trunk\FARRMS\trm\adiha.php.scripts\dev\shared_docs\attach_docs\deal\rio_doc.doc', @user_category=NULL, @user_ids='pl', @admin_email_configuration_id=0
--*/

BEGIN try
	DECLARE @sql VARCHAR(max)
	DECLARE @sql1 varchar(max)
	DECLARE @email_add varchar(8000)
	DECLARE @non_sys_users varchar(2000) = NULLIF(@send_to,'')
	declare @err_msg varchar(2000) = ''

--This is to check whether the email is to be send to internal users or not.

IF @user_ids IS NOT NULL
BEGIN
	SET @subject = ''''+ @subject + ''''
	SET @message = '''' + @message+ ''''

		IF NULLIF(@send_to,'') IS NOT NULL
			SET @send_to = '''' + @send_to + '''' + '+ ' + '''' + ';' + '''' + '+ '+ '(email_add)'
		ELSE
			SET @send_to = '(email_add)'

	--Step 1 Insert into Temp table 2 
	SET @sql= 'SELECT user_emal_add INTO #t2 FROM application_users where user_login_id IN ( ' +
		'SELECT * FROM dbo.FNAsplit(' + '''' + @user_ids + '''' + ',' + ''',''' + ') )' + ' AND user_emal_add IS NOT NULL AND user_active = ''y'''
		
		
	-- Step 2 Insert in to Temp table 3 after in comma separated format.
	--SET @sql = @sql+ ' SELECT * INTO #t3 FROM (SELECT STUFF((SELECT DISTINCT COALESCE(user_emal_add + '';'', '''') + user_emal_add FROM #t2 FOR XML PATH (' + '''' + '''' + ')),1,1,' + '''' + '''' + ') email_add FROM #t2) t'
	SET @sql = @sql+ ' SELECT * INTO #t3 FROM 
		(SELECT STUFF(
			(SELECT distinct '';''  + user_emal_add
				from #t2
				FOR XML PATH(''''))
			, 1, 1, '''') email_add
	) t'
	--SET @sql = @sql + ' Declare @email_add varchar(800);Select @email_add =email_add From #t3;select @email_add'
	
	if @notes_id is null --insert mode
	begin
		set @err_msg = 'Email sent successfully.'
		SET @sql=@sql+ ' 
		INSERT INTO email_notes(category_value_id,notes_object_name,notes_object_id,send_status,active_flag,send_to,send_cc,send_bcc,notes_text,internal_type_value_id,notes_subject,send_from,attachment_file_name, email_type, user_category, sys_users, non_sys_users,admin_email_configuration_id)
		'
		SET @sql = @sql + 'SELECT NULL,NULL,' + 
								ISNULL(CAST(@notes_object_id AS VARCHAR(10)),'NULL') +
								',''n''' + 
								',''y'','+ 
								@send_to + ',' + 
								COALESCE(@send_cc, 'NULL')+ ',' + 
								COALESCE(@send_bcc,'NULL') + ',' + 
								COALESCE(@message,'NULL') + ',' + 
								COALESCE(CAST(@internal_type_value_id AS VARCHAR(40)),'NULL') + ',' + 
								COALESCE(@subject,'n/a') + 
								',''noreply@pioneersolutionsglobal.com'',' + 
								ISNULL('''' + NULLIF(@file_attachment_name, '') + '''', 'NULL') + ', ''' + 
								@email_type + '''' + ', ' + 
								ISNULL(CAST(@user_category AS VARCHAR(10)),'NULL') + ', ''' + 
								@user_ids + ''', ' + 
								ISNULL('''' + @non_sys_users + '''', 'NULL') + ', ' + 
								ISNULL(CAST(@admin_email_configuration_id AS VARCHAR(10)),'NULL') +
			' FROM #t3'
	end
	else
	begin
		set @err_msg = 'Data saved successfully.'
		set @sql = '
		update email_notes
		set notes_subject = ' + COALESCE(@subject,'n/a') + ', notes_text=' + COALESCE(@message,'NULL') + ', user_category=' + ISNULL(CAST(@user_category AS VARCHAR(10)),'NULL') + ', admin_email_configuration_id=' + ISNULL(CAST(@admin_email_configuration_id AS VARCHAR(10)),'NULL') + '
		where notes_id = ' + @notes_id + '
		'
	end 
	--PRINT(@sql)
		
	EXEC (@sql)
END
ELSE
begin
	
	--This is to send email when there is no email to be sent to internal users 
	set @err_msg = 'Data saved successfully.'
	if @notes_id is null --insert mode
	begin
		
		INSERT INTO email_notes
			(
				category_value_id,
				notes_object_name,
				notes_object_id,
				send_status,
				active_flag,
				send_to,
				send_cc,
				send_bcc,
				notes_text,
				internal_type_value_id,
				notes_subject,
				send_from,
				attachment_file_name,
				email_type,
				user_category,
				non_sys_users,
				admin_email_configuration_id
			) 
		VALUES
			(
				null,
				null,
			@notes_object_id,
				'n',
				'y'
				,@send_to,
				@send_cc,
				@send_bcc,
				@message,
				@internal_type_value_id,
				'TRM Email',
				'noreply@pioneersolutionsglobal.com',
						NULLIF(@file_attachment_name,''),
				@email_type,
					NULLIF(@user_category, ''),
				@non_sys_users,
				@admin_email_configuration_id
			)
	END
	else
	begin
		set @sql = '
		update email_notes
		set notes_subject = ''' + COALESCE(@subject,'n/a') + ''', notes_text=' + COALESCE('''' + replace(@message,'''','''''') + '''','NULL') + ', user_category=' + ISNULL(CAST(@user_category AS VARCHAR(10)),'NULL') + ', admin_email_configuration_id=' + ISNULL(CAST(@admin_email_configuration_id AS VARCHAR(10)),'NULL') + '
		where notes_id = ' + @notes_id + '
		'
		--print (@sql)
		EXEC (@sql)
	end
	--EXEC spa_sendemail
	
end
EXEC spa_ErrorHandler 0
	, 'spa_tempNotes' 
	, 'email_notes'
	, 'email_notes'
	, @err_msg
	, ''
END try
begin catch
	set @err_msg = ERROR_MESSAGE()
	EXEC spa_ErrorHandler 1
	, 'spa_tempNotes' 
	, 'email_notes'
	, 'email_notes'
	, @err_msg
	, ''
end catch

