IF OBJECT_ID(N'[dbo].[spa_post_template]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].spa_post_template
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	Something

	Parameters
	@flag: Operation flag
	@internal_type_value_id : Internal document type
	@notes_object_id : Note Object ID
	@notes_subject : Note Subject
	@notes_text : Note text
	@doc_type : Document type
	@doc_file_unique_name : Document unique file name
	@doc_file_name : Document file name
	@source_system : Source System
	@notes_id : Note ID
	@notes_share_email_enable : Email share enabled
	@url : URL
	@category_value_id : Category ID
	@process_id	: Process ID
	@category_based_id : Category base ID
	@document_type : Document Type
	@user_category : User category
	@workflow_process_id : Workflow process ID
	@workflow_message_id : Workflow message ID
	@parent_object_id : Parent object ID
	@workflow_deal_id : Workflow deal ID
*/
CREATE PROCEDURE [dbo].spa_post_template
    @flag CHAR(1),
    @internal_type_value_id		INT = NULL, 
    @notes_object_id			INT = NULL, 
    @notes_subject				NVARCHAR(500) = NULL, 
    @notes_text					NVARCHAR(MAX) = NULL, 
    @doc_type					VARCHAR(500) = NULL, 
    @doc_file_unique_name		NVARCHAR(MAX) = NULL, 
    @doc_file_name				NVARCHAR(MAX) = NULL, 
    @source_system				INT = NULL,
    @notes_id					VARCHAR(50) = NULL,
    @notes_share_email_enable	BIT = NULL,
	@url						NVARCHAR(100) = NULL,
	@category_value_id			INT = NULL,
	@process_id					VARCHAR(200) = NULL,
	@category_based_id			INT = NULL,
	@document_type				INT = NULL,
	@user_category				INT = NULL,
	@workflow_process_id		VARCHAR(200) = NULL,
	@workflow_message_id		INT = NULL,
	@parent_object_id			INT = NULL,
	@workflow_deal_id			INT = NULL
AS

DECLARE @sql NVARCHAR(MAX)
DECLARE @deal_required_doc_table VARCHAR(300)
DECLARE @user_name VARCHAR(100) = dbo.FNADBUser()	
DECLARE @err VARCHAR(MAX)
DECLARE @sqln NVARCHAR(max)

IF OBJECT_ID('tempdb..#document_present') IS NOT NULL
	DROP TABLE #document_present
CREATE TABLE #document_present(is_present INT)


set nocount on
declare @sub_folder varchar(200)

select @sub_folder = sdv.code
from static_data_value sdv where sdv.value_id = @internal_type_value_id

IF @flag = 'i'
BEGIN
	BEGIN TRY
	BEGIN TRAN 	

		IF EXISTS(SELECT 1 FROM application_notes WHERE internal_type_value_id = 10000132 AND notes_object_id = @notes_object_id AND user_category = -43000 AND @user_category = -43000)
		BEGIN
			EXEC spa_ErrorHandler -1
				,'spa_post_template' 
				, 'application_notes'
				, 'application_notes'
				, 'This user already contain signature.'
				, ''
			RETURN
		END
		ELSE IF EXISTS(SELECT 1 FROM application_notes WHERE internal_type_value_id = 40 AND notes_object_id = @notes_object_id AND user_category = -43001 AND @user_category = -43001)
		BEGIN
			EXEC spa_ErrorHandler -1
				,'spa_post_template' 
				, 'application_notes'
				, 'application_notes'
				, 'Template already uploaded for this contract.'
				, ''
			RETURN
		END
		
		INSERT INTO application_notes (internal_type_value_id, notes_object_id, notes_subject, notes_text, content_type, attachment_file_name, source_system_id, notes_share_email_enable, url, category_value_id, user_category, workflow_process_id, workflow_message_id, parent_object_id, attachment_folder, document_type) 
		select @internal_type_value_id, @notes_object_id, @notes_subject, @notes_text, @doc_type, @doc_file_unique_name, @source_system, @notes_share_email_enable, @url, @category_value_id, @user_category, @workflow_process_id, @workflow_message_id, @parent_object_id, @sub_folder, @document_type

		
	COMMIT 
		EXEC spa_ErrorHandler 0
			, 'spa_post_template' 
			, 'application_notes'
			, 'application_notes'
			, 'Changes have been saved successfully.'
			, ''
	END TRY 
	BEGIN CATCH
		EXEC spa_ErrorHandler -1
			,'spa_post_template' 
			, 'application_notes'
			, 'application_notes'
			, 'Failed adding template'
			, ''
		ROLLBACK 
	END CATCH
END

ELSE IF @flag = 'u'
BEGIN
	BEGIN TRY
	BEGIN TRAN
		IF EXISTS(SELECT 1 FROM application_notes WHERE internal_type_value_id = 40 AND notes_object_id = @notes_object_id AND user_category = -43001 AND @user_category = -43001 AND notes_id <> @notes_id)
		BEGIN
			EXEC spa_ErrorHandler -1
				,'spa_post_template' 
				, 'application_notes'
				, 'application_notes'
				, 'Template already uploaded for this contract.'
				, ''
			RETURN
		END

		IF(@doc_file_name IS NULL OR @doc_file_name = '')
	    	BEGIN
	    		UPDATE application_notes
	    		SET    internal_type_value_id = @internal_type_value_id,
					   notes_object_id =
					   CASE
						  WHEN @notes_object_id > 0 THEN @notes_object_id
	    				  ELSE notes_object_id
					   END,
	    			   notes_subject = @notes_subject,
	    			   notes_text = @notes_text,
	    			   source_system_id = @source_system,
	    			   notes_share_email_enable = @notes_share_email_enable,
					   url = @url,
					   category_value_id = @category_value_id,
					   user_category = @user_category,
					   workflow_process_id = @workflow_process_id,
					   workflow_message_id = @workflow_message_id,
					   parent_object_id = @parent_object_id,
					   attachment_folder = @sub_folder,
					   document_type = @document_type
	    		WHERE  notes_id = @notes_id
	    	END
	    	ELSE
	    	BEGIN
    			UPDATE application_notes
    			SET    internal_type_value_id = @internal_type_value_id,
    				   notes_object_id = 
					   CASE
						  WHEN @notes_object_id > 0 THEN @notes_object_id
	    				  ELSE notes_object_id
					   END,
    				   notes_subject = @notes_subject,
    				   notes_text = @notes_text,
    				   attachment_file_name = @doc_file_unique_name,
    				   --notes_attachment = @doc_file_name,
    				   content_type = @doc_type,
    				   source_system_id = @source_system,
    				   notes_share_email_enable = @notes_share_email_enable,
					   url = @url,
					   category_value_id = @category_value_id,
					   user_category = @user_category,
					   workflow_process_id = @workflow_process_id,
					   workflow_message_id = @workflow_message_id,
					   parent_object_id = @parent_object_id,
					   attachment_folder = @sub_folder,
					   document_type = @document_type
					   
    			WHERE  notes_id = @notes_id
    		END
	    	COMMIT 
		EXEC spa_ErrorHandler 0
			, 'spa_post_template' 
			, 'application_notes'
			, 'application_notes'
			, 'Changes have been saved successfully.'
			, ''
	END TRY 
	BEGIN CATCH
		SET @err = @@ERROR
		EXEC spa_ErrorHandler -1
			,'spa_post_template' 
			, 'application_notes'
			, 'application_notes'
			, 'Failed updating template'
			, @err
		ROLLBACK 
	END CATCH
END
--SELECT  *
--FROM  application_notes  

-- list the users
IF @flag = 's'
BEGIN
	SELECT DISTINCT create_user AS users
		FROM application_notes
		WHERE source_system_id = @source_system
	UNION
	SELECT DISTINCT update_user AS users
		FROM application_notes
		WHERE source_system_id = @source_system
	ORDER BY users	
END

IF @flag = 'x'
BEGIN
	BEGIN TRY	
		SET @deal_required_doc_table = dbo.FNAProcessTableName('deal_required_doc', @user_name, @process_id)
		
		SET @sql = 'INSERT INTO #document_present
					SELECT 1 FROM ' + @deal_required_doc_table + '
					WHERE document_type = ' + CAST(@document_type AS VARCHAR(20))
		--PRINT(@sql)
		EXEC(@sql)
		
		IF EXISTS (SELECT 1 FROM #document_present)
		BEGIN
			EXEC spa_ErrorHandler -1
				,'spa_post_template' 
				, 'application_notes'
				, 'application_notes'
				, 'Selected document already exists for deal.'
				, ''
			RETURN
		END
		
		SET @sql = 'INSERT INTO ' + @deal_required_doc_table + '(notes_id,internal_type_value_id,category_value_id,notes_subject,notes_text,content_type,attachment_file_name,notes_attachment,source_system_id,notes_share_email_enable,url,document_type,user_category)
					SELECT ''' + @notes_id + ''',
						   ' + CAST(@internal_type_value_id AS VARCHAR(10)) + ',
					       ' + ISNULL(CAST(@category_value_id AS VARCHAR(10)), 'NULL') + ',
					       ' + ISNULL(NULLIF('''' + @notes_subject + '''', ''), 'NULL') + ',
					       ' + ISNULL(NULLIF('''' + @notes_text + '''', ''), 'NULL') + ',
					       ' + ISNULL(NULLIF('''' + @doc_type + '''', ''), 'NULL') + ',
					       ' + ISNULL(NULLIF('''' + @doc_file_unique_name + '''', ''), 'NULL') + ',
					       ' + ISNULL(NULLIF('''' + @doc_file_name + '''', ''), 'NULL') + ',
					       ' + ISNULL(CAST(@source_system AS VARCHAR(10)), 'NULL') + ',
					       ' + ISNULL(CAST(@notes_share_email_enable AS VARCHAR(10)), 'NULL') + ',
					       ' + ISNULL(NULLIF('''' + @url + '''', ''), 'NULL') + ',
					       ' + CAST(@document_type AS VARCHAR(10)) + ',
					       ' + ISNULL(cast(@user_category as varchar(10)), 'NULL')
					
		--PRINT(@sql)
		EXEC(@sql)
		
		EXEC spa_ErrorHandler 0
			, 'spa_post_template' 
			, 'application_notes'
			, 'application_notes'
			, 'Change have been saved successfully.'
			, ''
	END TRY 
	BEGIN CATCH
		EXEC spa_ErrorHandler -1
			,'spa_post_template' 
			, 'application_notes'
			, 'application_notes'
			, 'Failed adding template'
			, '' 
	END CATCH
END
ELSE IF @flag = 'y'
BEGIN
	BEGIN TRY
		SET @deal_required_doc_table = dbo.FNAProcessTableName('deal_required_doc', @user_name, @process_id)
		
		SET @sql = 'INSERT INTO #document_present
					SELECT 1 FROM ' + @deal_required_doc_table + '
					WHERE document_type = ' + CAST(@document_type AS VARCHAR(20)) + '
					AND notes_id <> ''' + @notes_id + ''''
		--PRINT(@sql)
		EXEC(@sql)
		
		IF EXISTS (SELECT 1 FROM #document_present)
		BEGIN
			EXEC spa_ErrorHandler -1
				,'spa_post_template' 
				, 'application_notes'
				, 'application_notes'
				, 'Selected document already exists for deal.'
				, ''
			RETURN
		END
	
		SET @sql = 'UPDATE ' + @deal_required_doc_table + '
	    			SET notes_subject = ' + ISNULL(NULLIF('''' + @notes_subject + '''', ''), 'NULL') + ',
	    				notes_text = ' + ISNULL(NULLIF('''' + @notes_text + '''', ''), 'NULL') + ',
	    				notes_share_email_enable = ' + ISNULL(CAST(@notes_share_email_enable AS VARCHAR(10)), 'NULL') + ',
						url = ' + ISNULL(NULLIF('''' + @url + '''', ''), 'NULL') + ',
						is_updated = CASE WHEN deal_required_document_id IS NULL THEN ''n'' ELSE ''y'' END
	    			WHERE  notes_id = ''' + @notes_id + ''''
	    EXEC(@sql)
	    	
	    	
		IF(NULLIF(@doc_file_name, '') IS NOT NULL)
	    BEGIN
	    	SET @sql = 'UPDATE ' + @deal_required_doc_table + '
	    				SET notes_attachment = ' + ISNULL(NULLIF('''' + @doc_file_name + '''', ''), 'NULL') + ',
	    					attachment_file_name = ' + ISNULL(NULLIF('''' + @doc_file_unique_name + '''', ''), 'NULL') + ',
	    					is_file_changed = CASE WHEN deal_required_document_id IS NULL THEN ''n'' ELSE ''y'' END
	    				WHERE  notes_id = ''' + @notes_id + ''''
			EXEC(@sql)
	    END
	    
	    
		EXEC spa_ErrorHandler 0
			, 'spa_post_template' 
			, 'application_notes'
			, 'application_notes'
			, 'Change have been saved successfully.'
			, ''
	END TRY 
	BEGIN CATCH
		SET @err = @@ERROR
		EXEC spa_ErrorHandler -1
			,'spa_post_template' 
			, 'application_notes'
			, 'application_notes'
			, 'Failed updating template'
			, @err
	END CATCH
END
ELSE IF @flag = 'z'
BEGIN
	SET @deal_required_doc_table = dbo.FNAProcessTableName('deal_required_doc', @user_name, @process_id)
	
	SET @sql = 'SELECT notes_id,
	                   internal_type_value_id,
	                   notes_object_id,
	                   notes_subject,
	                   notes_text,
	                   notes_attachment,
	                   content_type,
	                   attachment_file_name,
	                   notes_share_email_enable,
	                   source_system_id,
	                   url,
	                   document_type,
					   user_category
	            FROM ' + @deal_required_doc_table + '
	            WHERE notes_id = ''' + @notes_id + '''
			'
	EXEC(@sql)	
END
ELSE IF @flag = 'w'
BEGIN
	SET @deal_required_doc_table = dbo.FNAProcessTableName('deal_required_doc', @user_name, @process_id)
	
	SET @sql = 'DELETE 
	            FROM ' + @deal_required_doc_table + '
	            WHERE notes_id = ''' + @notes_id + '''
			'
	EXEC(@sql)	
END