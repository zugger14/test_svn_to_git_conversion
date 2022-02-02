IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_email_notes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_email_notes]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================================================================
-- Create date: 2011-03-04
-- Description:	Wrapper sp to handle interaction with email_notes table
-- Params:
--	@flag - 
--		'b' - bulk insert, insert a record for each user which is under any role of type @role_type_id		
--	@notes_id - PK of email_notes table
--	@role_type_value_id - role type id, all users under this role type will be emailed
--	@email_module_type_value_id - email module type, subject and body are defined for each module type in admin_email_configuration table.
--	@attachment_file_name - filename or table name to attach
--	@send_to - to address
--	@send_cc - cc address
--	@send_bcc - bcc address
--	@send_status - 'n' while inserting
--	@active_flag - 'y' while inserting
--	@template_params - name:value collection in xml format for templating subject & body
--	@internal_type_value_id - used for manage doc only
--	@category_value_id - used for manage doc only
--	@notes_object_id - used for manage doc only
--	@notes_object_name - used for manage doc only
-- ===============================================================================================================


----------------------PROC MODIFICATION DETAIL-----------------------
--- Modification Date : 23rd Jan 2012
----Modified By: Santosh Gupta 
----Purpose: To Allow sending Individual Mail 
----Issue ID : 5784

--===================================================================
CREATE PROCEDURE [dbo].[spa_email_notes]
	@flag CHAR(1) = 0,
	@notes_id varchar(100) = NULL,
	@role_type_value_id INT = NULL,
	@email_module_type_value_id INT = NULL,
	@attachment_file_name VARCHAR(5000) = NULL,
	@send_to VARCHAR(5000) = NULL,
	@send_cc VARCHAR(5000) = NULL,
	@send_bcc VARCHAR(5000) = NULL,
	@send_status varchar(1) = 'n',
	@active_flag CHAR(1) = 'y',
	@template_params VARCHAR(MAX) = NULL,
	@internal_type_value_id INT = NULL,
	@category_value_id INT = NULL,
	@notes_object_id VARCHAR(50) = NULL,
	@notes_object_name VARCHAR(50) = NULL,
	@search_result_table varchar(200) = null,
	@notes_text varchar(max) = null,
	@send_from varchar(1000) = null,
	@email_type char(1) = 'o',
	@process_id varchar(500) = null,
	@email_subject varchar(2000) = null,
	@return_output CHAR(1) =  NULL,
	@subject VARCHAR(2000) = NULL,
	@role_ids VARCHAR(1024) = NULL
	
AS
set nocount on

/*
declare @flag CHAR(1) = 0,
	@notes_id INT = NULL,
	@role_type_value_id INT = NULL,
	@email_module_type_value_id INT = NULL,
	@attachment_file_name VARCHAR(5000) = NULL,
	@send_to VARCHAR(5000) = NULL,
	@send_cc VARCHAR(5000) = NULL,
	@send_bcc VARCHAR(5000) = NULL,
	@send_status varchar(1) = 'n',
	@active_flag CHAR(1) = 'y',
	@template_params VARCHAR(MAX) = NULL,
	@internal_type_value_id INT = NULL,
	@category_value_id INT = NULL,
	@notes_object_id VARCHAR(50) = NULL,
	@notes_object_name VARCHAR(50) = NULL

select @flag='g',@internal_type_value_id=NULL,@category_value_id='',@notes_object_id='0'

--*/
BEGIN
	SET NOCOUNT ON;
	--DECLARE @subject VARCHAR(2000)
	DECLARE @body VARCHAR(MAX)
	DECLARE @emailid VARCHAR(500)
	DECLARE @tot_size VARCHAR(100)
	DECLARE @free_size VARCHAR(100)
	DECLARE @sql VARCHAR(MAX), 
	@filtered_send_to varchar(5000),
	@filtered_send_bcc varchar(5000), 
	@filtered_send_cc varchar(5000)

	/*Added to filter send_to, send_cc, send_bcc
	* If email dose not exists in application_users, email_id is accepted
	* If email exists in application_users and user is active, email_id is accepted
	* If email exists in application_users and user is NOT active, email_id is NOT accepted
	*/
	
	IF CHARINDEX(';', @send_to) > 0 OR CHARINDEX(',', @send_to) > 0 
	BEGIN
		SET @send_to = REPLACE(@send_to, ';', ',')
		SELECT @filtered_send_to = COALESCE(@filtered_send_to + ';', '') + b.item
		FROM (
		SELECT a.item FROM SplitCommaSeperatedValues(@send_to) a
		LEFT JOIN application_users au on au.user_emal_add = a.item
		WHERE user_login_id IS NULL
		UNION ALL
		SELECT a.item FROM SplitCommaSeperatedValues(@send_to) a
		INNER JOIN application_users au on au.user_emal_add = a.item AND user_active = 'y') b
	END
	ELSE
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM application_users au WHERE au.user_emal_add = @send_to )
		BEGIN
			SET @filtered_send_to = @send_to
		END
		ELSE IF EXISTS (SELECT 1 FROM application_users au WHERE au.user_emal_add = @send_to AND user_active = 'y')
		BEGIN 
			SET @filtered_send_to = @send_to
		END
		ELSE
		BEGIN
			SET @filtered_send_to = NULL
		END
	END
	SET @send_to = @filtered_send_to

	IF CHARINDEX(';', @send_cc) > 0 OR CHARINDEX(',', @send_cc) >0 
	BEGIN
		SET @send_cc = REPLACE(@send_cc, ';', ',')
		SELECT @filtered_send_cc = COALESCE(@filtered_send_cc + ';' , '') + b.item
		FROM (
		SELECT a.item FROM SplitCommaSeperatedValues(@send_cc) a
		LEFT JOIN application_users au on au.user_emal_add = a.item
		WHERE user_login_id IS NULL
		UNION ALL
		SELECT a.item FROM SplitCommaSeperatedValues(@send_cc) a
		INNER JOIN application_users au on au.user_emal_add = a.item AND user_active = 'y') b
	END
	ELSE
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM application_users au WHERE au.user_emal_add = @send_cc )
		BEGIN
			SET @filtered_send_cc = @send_cc
		END
		ELSE IF EXISTS (SELECT 1 FROM application_users au WHERE au.user_emal_add = @send_cc AND user_active = 'y')
		BEGIN 
			SET @filtered_send_cc = @send_cc
		END
		ELSE
		BEGIN
			SET @filtered_send_cc = NULL
		END
	END
	SET @send_cc = @filtered_send_cc

	IF CHARINDEX(';', @send_bcc) > 0 OR CHARINDEX(',', @send_bcc) >0 
	BEGIN
		SET @send_bcc = REPLACE(@send_bcc, ';', ',')
		SELECT @filtered_send_bcc = COALESCE(@filtered_send_bcc + ';' , '') + b.item
		FROM (
		SELECT a.item FROM SplitCommaSeperatedValues(@send_bcc) a
		LEFT JOIN application_users au on au.user_emal_add = a.item
		WHERE user_login_id IS NULL
		UNION ALL
		SELECT a.item FROM SplitCommaSeperatedValues(@send_bcc) a
		INNER JOIN application_users au on au.user_emal_add = a.item AND user_active = 'y') b
	END
	ELSE
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM application_users au WHERE au.user_emal_add = @send_bcc )
		BEGIN
			SET @filtered_send_bcc = @send_bcc
		END
		ELSE IF EXISTS (SELECT 1 FROM application_users au WHERE au.user_emal_add = @send_bcc AND user_active = 'y')
		BEGIN 
			SET @filtered_send_bcc = @send_bcc
		END
		ELSE
		BEGIN
			SET @filtered_send_bcc = NULL
		END
	END
	SET @send_bcc = @filtered_send_bcc
	/*END filter send_to, send_cc, send_bcc*/

	IF @flag in ('b','i')
	BEGIN

		SELECT @subject = CASE WHEN @subject IS NULL THEN email_subject ELSE dbo.FNAReplaceEmailTemplateParams(email_subject, @subject) END, @body = email_body	
		FROM admin_email_configuration
		WHERE module_type = @email_module_type_value_id
	END
	IF @flag = 'b' 
	BEGIN
		INSERT INTO email_notes
			(
				internal_type_value_id,
				category_value_id,
				notes_object_id,		
				notes_object_name,
				notes_subject,
				notes_text,
				attachment_file_name,
				send_to,
				send_cc,
				send_bcc,
				send_status,
				active_flag
			)		
		SELECT @internal_type_value_id, @category_value_id, @notes_object_id, @notes_object_name
			, dbo.FNAReplaceEmailTemplateParams(@subject, dbo.FNABuildNameValueXML(dbo.FNABuildNameValueXML(@template_params, '<TRM_USER_LAST_NAME>', MAX(au.user_l_name)), '<TRM_DATE>', dbo.FNAUserDateTimeFormat(GETDATE(), 1, au.user_login_id)))
			, dbo.FNAReplaceEmailTemplateParams(@body, dbo.FNABuildNameValueXML(dbo.FNABuildNameValueXML(@template_params, '<TRM_USER_LAST_NAME>', MAX(au.user_l_name)), '<TRM_DATE>', dbo.FNAUserDateTimeFormat(GETDATE(), 1, au.user_login_id)))
			, @attachment_file_name
			, au.user_emal_add, NULL, NULL, @send_status, @active_flag
		FROM 
			(SELECT asr_inner.role_id FROM application_security_role asr_inner 
				LEFT JOIN dbo.FNASplit(@role_ids, ',') rs ON  asr_inner.role_id = rs.item
				WHERE asr_inner.role_id = rs.item OR asr_inner.role_type_value_id = @role_type_value_id
			) t
		INNER JOIN dbo.application_security_role asr ON t.role_id = asr.role_id 
		INNER JOIN application_role_user aru ON t.role_id = aru.role_id
		INNER JOIN dbo.application_users au ON aru.user_login_id = au.user_login_id
		WHERE (au.user_active = 'y')
		AND au.user_emal_add IS NOT NULL
		GROUP BY au.user_login_id, au.user_emal_add
	
END
	ELSE IF @flag = 'i' 
	BEGIN					
		
		IF NULLIF(@send_to, '') IS NOT NULL
		BEGIN
			INSERT INTO email_notes
				(
					internal_type_value_id,
					category_value_id,
					notes_object_id,		
					notes_object_name,
					notes_subject,
					notes_text,
					attachment_file_name,
					send_to,
					send_cc,
					send_bcc,
					send_status,
					active_flag
				)		
			SELECT @internal_type_value_id,
				@category_value_id,
				@notes_object_id,
				@notes_object_name,
				dbo.FNAReplaceEmailTemplateParams(@subject, @template_params),
				dbo.FNAReplaceEmailTemplateParams(@body, @template_params),
				@attachment_file_name,
				@send_to,
				NULL,
				NULL,
				@send_status,
				@active_flag
		END
		
	END
	else if @flag = 'g'
	begin
		SET @sql = 'SELECT case en.email_type when ''o'' then ''Outgoing'' else ''Incoming'' end [email_type],
						isnull(sdv_cat.code, ''General'') [category],
						isnull(sdv_sub_cat.code, ''General'') [sub_category],
						en.notes_subject,
						en.attachment_file_name + ''^javascript:fx_download_file("'' + en.notes_attachment + ''")^_self'' [notes_attachment],
						case en.send_status when ''y'' then ''Sent'' else ''Not Sent'' end email_status,
						null user_category,
						null url,
						dbo.FNADateFormat(en.create_ts) create_ts,
						en.create_user,
						en.attachment_file_name,
						null notes_share_email_enable
						,en.notes_id,en.category_value_id [sub_category_id], ''none'' [search_criteria], sdv_cat.value_id [category_id]
						,en.notes_object_id [notes_object_id]

					FROM email_notes en
					left join static_data_value sdv_cat on sdv_cat.value_id = en.internal_type_value_id
					left join static_data_value sdv_sub_cat on sdv_sub_cat.value_id = en.category_value_id
					--left join static_data_value sdv_user_cat on sdv_user_cat.value_id = en.user_category
					WHERE 1=1 '
		IF @internal_type_value_id IS NOT NULL
		BEGIN
			SET @sql = @sql + ' AND en.internal_type_value_id IN ( ' + CAST(@internal_type_value_id  AS VARCHAR) + ')'
		END
		IF @notes_object_id > 0
		BEGIN
			SET @sql = @sql + ' AND (en.notes_object_id = ' + CAST(@notes_object_id AS VARCHAR) + '
									OR isnull(en.parent_object_id, -1) = ' + CAST(@notes_object_id AS VARCHAR) + '
								)'
								
		END
		IF nullif(@category_value_id, '') IS NOT NULL
		BEGIN
			SET @sql = @sql + ' AND category_value_id = ' + CAST(@category_value_id AS VARCHAR) + '
							
			'
		END

		SET @sql = @sql + ' order by notes_id'
		exec spa_print @sql
		EXEC(@sql)

	end
	ELSE IF @flag = 'd'
	BEGIN
		SET @sql = 'DELETE email_notes WHERE notes_id in (' + @notes_id + ')';
		EXEC(@sql)

		IF @@ERROR <> 0
		BEGIN
			EXEC spa_ErrorHandler @@ERROR, 'Email Notes', 
					'spa_email_notes', 'DB Error', 
					'Delete email data failed.', ''
		END
		ELSE
			EXEC spa_ErrorHandler 0, 'Email Notes', 
					'spa_email_notes', 'Success', 
					'Email data deleted successfully.', ''

	END 
	ELSE IF @flag = 'e' --called from clr to dump incoming email
	BEGIN
		IF @send_to IS NOT NULL OR @send_cc IS NOT NULL OR @send_bcc IS NOT NULL
		BEGIN
			INSERT INTO email_notes
				(
					notes_subject,
					notes_text,
					send_from,
					send_to,
					send_cc,
					send_bcc,
					send_status,
					active_flag,
					email_type,
					process_id,
					attachment_file_name
				)		
			SELECT @email_subject,
				@notes_text,
				@send_from,
				@send_to,
				@send_cc,
				@send_bcc,
				@send_status,
				@active_flag,
				@email_type,
				@process_id,
				@attachment_file_name

			IF isnull(nullif(@return_output,''),'y') = 'y'
			BEGIN
				DECLARE @output_value VARCHAR(MAX) 
				SELECT @output_value = CAST(SCOPE_IDENTITY() AS VARCHAR(10))
				RETURN @output_value
			END
		END	
	END
END
GO
