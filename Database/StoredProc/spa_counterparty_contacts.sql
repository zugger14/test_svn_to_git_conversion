IF OBJECT_ID(N'[dbo].[spa_counterparty_contacts]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_counterparty_contacts]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
 /**
	CRUD operations for table counterparty_contacts

	parameters
	@flag : Operation flag
 */

CREATE PROCEDURE [dbo].[spa_counterparty_contacts]
  @flag CHAR(1),
	@counterparty_contact_id INT = NULL,
	@counterparty_id NVARCHAR(1000) = NULL, 	
	@contact_type INT = NULL,		
	@title NVARCHAR(200) = NULL,						
	@name NVARCHAR(100) = NULL,						
	@id	NVARCHAR(100) = NULL,					
	@address1 NVARCHAR(1000) = NULL,                
	@address2 NVARCHAR(1000) = NULL,               
	@city NVARCHAR(100) = NULL,						
	@state INT = NULL,                  
	@zip NVARCHAR(100) = NULL,                     
	@telephone NVARCHAR(20) = NULL,              
	@fax NVARCHAR(50) = NULL,                     
	@email NVARCHAR(50) = NULL,						
	@country INT = NULL,					
	@region INT = NULL,					
	@comment NVARCHAR(500) = NULL,					
	@is_active CHAR(1)	= NULL,			
	@is_primary CHAR(1)	= NULL,	
	@xml	NVARCHAR(MAX) = NULL,
	@application_field_id INT = NULL,
	@filter_value  NVARCHAR(MAX) = NULL

AS
SET NOCOUNT ON
DECLARE @sql_select NVARCHAR(MAX)
SELECT @filter_value = NULLIF(NULLIF(@filter_value, '<FILTER_VALUE>'), '')

IF @flag = 's'
BEGIN
	SELECT counterparty_contact_id,
	       sdv.code [contact_type],
	       title [title],
	       name [name],
	       id [ID],
	       address1,
	       address2,
	       city,
	       sdv_state.code [state],
	       zip,
		   telephone phone_no,
		   cell_no,
	       fax,
	       dbo.FNAEmailHyperlink(email) [email],
		   dbo.FNAEmailHyperlink(email_cc) [email_cc],
		   dbo.FNAEmailHyperlink(email_bcc) [email_bcc],
	       sdv_country.code [country],
	       sdv_region.code [region],
	       comment [comment],
	       CASE 
	            WHEN is_active = 'y' THEN 'Yes'
	            ELSE 'No'
	       END [is_active],
	       CASE 
	            WHEN is_primary = 'y' THEN 'Yes'
	            ELSE 'No'
	       END [is_primary]
	FROM counterparty_contacts cc
	LEFT JOIN static_data_value sdv ON  sdv.value_id = cc.contact_type
	LEFT JOIN static_data_value sdv_state ON  sdv_state.value_id = cc.[state]
	LEFT JOIN static_data_value sdv_country ON  sdv_country.value_id = cc.country
	LEFT JOIN static_data_value sdv_region ON  sdv_region.value_id = cc.region
	WHERE counterparty_id = @counterparty_id
	ORDER BY cc.is_primary DESC
END

IF @flag = 'a'
BEGIN
	SELECT contact_type, title, name, id, address1, address2, city, [state], zip, telephone, fax, email, country, region, comment, is_active, is_primary FROM counterparty_contacts WHERE counterparty_contact_id = @counterparty_contact_id
END 

IF @flag = 'b'
BEGIN
	SELECT title, name, id, address1, address2, city, [state], zip, telephone, fax, REPLACE(email, '@', '1_replace') email, country, region, is_active FROM counterparty_contacts WHERE counterparty_id = @counterparty_id AND is_primary = 'y' -- ajax replaced @ to blank so used 1_replace and replaced in front end
END 

IF @flag = 'i' 
BEGIN
	IF EXISTS (SELECT 1 FROM counterparty_contacts WHERE counterparty_id = @counterparty_id AND is_primary = 'y' AND @is_primary = 'y')
	BEGIN
		EXEC spa_ErrorHandler -1,
		'counterparty_contacts',
		'spa_counterparty_contacts',
		'Error',
		'Primary Contact has already been defined for this Counterparty.',
		''		
		RETURN
	END
	
	INSERT INTO counterparty_contacts (counterparty_id, contact_type, title, name, id, address1, address2, city, [state], zip, telephone, fax, email, country, region, comment, is_active, is_primary)
	VALUES (@counterparty_id, @contact_type, @title, @name, @id, @address1, @address2, @city, @state, @zip, @telephone, @fax, @email, @country, @region, @comment, @is_active, @is_primary)
	
	EXEC spa_ErrorHandler 0,
		'counterparty_contacts',
		'spa_counterparty_contacts',
		'Success',
		'Changes have been saved successfully.',
		''
END

IF @flag = 'd' 
BEGIN
	DELETE FROM counterparty_contacts WHERE counterparty_contact_id = @counterparty_contact_id
	
	EXEC spa_ErrorHandler 0,
		'counterparty_contacts',
		'spa_counterparty_contacts',
		'Success',
		'Changes have been saved successfully.',
		''
END

IF @flag = 'u' 
BEGIN
	IF EXISTS (SELECT 1 FROM counterparty_contacts WHERE counterparty_id = @counterparty_id AND is_primary = 'y' AND @is_primary = 'y' AND counterparty_contact_id <> @counterparty_contact_id)
	BEGIN
		EXEC spa_ErrorHandler -1,
		'counterparty_contacts',
		'spa_counterparty_contacts',
		'Error',
		'Primary Contact has already been defined for this Counterparty.',
		''		
		RETURN
	END
	
	UPDATE counterparty_contacts 
	SET contact_type = @contact_type, 
		title = @title, 
		name = @name, 
		id = @id, 
		address1 = @address1, 
		address2 = @address2, 
		city = @city, 
		[state] = @state, 
		zip = @zip, 
		telephone = @telephone, 
		fax = @fax, 
		email = @email, 
		country = @country, 
		region = @region, 
		comment = @comment, 
		is_active = @is_active, 
		is_primary = @is_primary
	WHERE counterparty_contact_id = @counterparty_contact_id
	
	EXEC spa_ErrorHandler 0,
		'counterparty_contacts',
		'spa_counterparty_contacts',
		'Success',
		'Changes have been saved successfully.',
		''
END
ELSE IF(@flag='v')
BEGIN
DECLARE @idoc int
		EXEC sp_xml_preparedocument @idoc OUTPUT,
									@xml
		
		IF OBJECT_ID('tempdb..#temp_delete_detail') IS NOT NULL
		  DROP TABLE #temp_delete_detail
		  SELECT
		  grid_id
		INTO #temp_delete_detail
		FROM OPENXML(@idoc, '/Root/GridDelete', 1)
		WITH (
			grid_id INT
		)
		--DELETE FROM counterparty_contacts WHERE counterparty_contact_id = @counterparty_contact_id
		DELETE cc
		FROM master_view_counterparty_contacts cc
		INNER JOIN #temp_delete_detail tdd ON cc.counterparty_contact_id = tdd.grid_id

		
		DELETE cc
		FROM counterparty_contacts cc
		INNER JOIN #temp_delete_detail tdd ON cc.counterparty_contact_id = tdd.grid_id
	
	EXEC spa_ErrorHandler 0,
		'counterparty_contacts',
		'spa_counterparty_contacts',
		'Success',
		'Changes have been saved successfully.',
		''

END
ELSE IF @flag = 'w' OR @flag = 'y' OR @flag = 'z'
BEGIN
	SELECT counterparty_contact_id,
	       name [name],
		   sdv.code [contact_type],
	       title [title],
	       id [ID],
	       address1,
	       address2,
	       city,
	       sdv_state.code [state],
	       zip,
		   telephone phone_no,
		   cell_no,
	       fax,
	       dbo.FNAEmailHyperlink(email) [email],
		   dbo.FNAEmailHyperlink(email_cc) [email_cc],
		   dbo.FNAEmailHyperlink(email_bcc) [email_bcc],
	       sdv_country.code [country],
	       sdv_region.code [region],
	       comment [comment],
	       CASE 
	            WHEN is_active = 'y' THEN 'Yes'
	            ELSE 'No'
	       END [is_active],
	       CASE 
	            WHEN is_primary = 'y' THEN 'Yes'
	            ELSE 'No'
	       END [is_primary]
	FROM counterparty_contacts cc
	LEFT JOIN static_data_value sdv ON  sdv.value_id = cc.contact_type
	LEFT JOIN static_data_value sdv_state ON  sdv_state.value_id = cc.[state]
	LEFT JOIN static_data_value sdv_country ON  sdv_country.value_id = cc.country
	LEFT JOIN static_data_value sdv_region ON  sdv_region.value_id = cc.region
	WHERE counterparty_id = ISNULL(@counterparty_id, counterparty_id)
		AND cc.contact_type = CASE WHEN @flag = 'w' THEN -32202 --Accountant (Payables)
								  WHEN @flag = 'y' THEN -32203	--Accountant (Receivables)
							ELSE -32204 END						--Confirmation
	ORDER BY cc.is_primary DESC
END 
ELSE IF @flag ='p'
BEGIN
DECLARE @field_id NVARCHAR(100),@credit_contact_type_value_id INT
	SELECT @field_id = autd.field_id FROM application_ui_template_fields autf
		 INNER JOIN application_ui_template_definition autd ON
				autd.application_ui_field_id = autf.application_ui_field_id
			WHERE application_field_id = @application_field_id

	/* Added to get external value_id of credit (Contact Type) */
	SELECT @credit_contact_type_value_id = value_id
	FROM static_data_value
	WHERE [type_id] = 32200 
	AND code = 'Credit'
	/* End of getting value id */

	 SET @sql_select = 'SELECT counterparty_contact_id,
	        id [ID],
		   name [name],
		   sdv.code [contact_type],
	       title [title],
	       address1,
	       address2,
	       city,
	       sdv_state.code [state],
	       zip,
		   telephone phone_no,
		   cell_no,
	       fax,
	       dbo.FNAEmailHyperlink(email) [email],
		   dbo.FNAEmailHyperlink(email_cc) [email_cc],
		   dbo.FNAEmailHyperlink(email_bcc) [email_bcc],
	       sdv_country.code [country],
	       sdv_region.code [region],
	       comment [comment],
	       CASE 
	            WHEN is_active = ''y'' THEN ''Yes''
	            ELSE ''No''
	       END [is_active],
	       CASE 
	            WHEN is_primary = ''y'' THEN ''Yes''
	            ELSE ''No''
	       END [is_primary],
		   cc.counterparty_id
	FROM counterparty_contacts cc
	LEFT JOIN static_data_value sdv ON  sdv.value_id = cc.contact_type
	LEFT JOIN static_data_value sdv_state ON  sdv_state.value_id = cc.[state]
	LEFT JOIN static_data_value sdv_country ON  sdv_country.value_id = cc.country
	LEFT JOIN static_data_value sdv_region ON  sdv_region.value_id = cc.region'

	IF @filter_value IS NOT NULL AND @filter_value <> '-1'
	BEGIN
		SET @sql_select += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @filter_value + ''') s ON s.item = counterparty_contact_id 
		 '
	END

	IF NULLIF(ISNULL(@counterparty_id,NULL), '') IS NOT NULL
	BEGIN
		SET @sql_select += ' WHERE 1 = 1  AND  counterparty_id = ' + Cast(@counterparty_id as NVARCHAR(200))  + ''
	END

	IF @counterparty_id IS NULL
	BEGIN
		SET @sql_select += ' WHERE 1 = 1  AND  counterparty_id = counterparty_id '
	END

	IF @field_id IS NOT NULL
	BEGIN
	SET @sql_select += 'AND cc.contact_type = CASE 
					WHEN ''' + ISNULL(@field_id, '') +''' IS NULL OR  ''' + ISNULL(@field_id, '') +''' = ''netting'' THEN cc.contact_type
					WHEN ''' + ISNULL(@field_id, '') +''' = ''payables'' THEN -32202 --Accountant (Payables)
					WHEN ''' + ISNULL(@field_id, '') +''' = ''receivables'' THEN -32203	--Accountant (Receivables)
					WHEN ''' + ISNULL(@field_id, '') +''' = ''credit'' THEN ' + CAST (@credit_contact_type_value_id AS NVARCHAR(20))	+ '--Accountant (Receivables)
			ELSE -32204 END'
	END

	EXEC (@sql_select)
END 

