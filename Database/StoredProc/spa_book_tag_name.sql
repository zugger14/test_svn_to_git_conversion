IF OBJECT_ID(N'[dbo].[spa_book_tag_name]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_book_tag_name]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
/**
	Select/Update/Insert operation on menu Setup Book Tag Mapping which is used to denote tag names.

	Parameters:
		@flag	:	Operation flag that defines the action to be performed. 's' flag to select values from table source_book_mapping_clm  'i' flag to update/insert values on table source_book_mapping_clm
		@xml	:	Book Tag Names data provided in XML format.
*/

CREATE PROCEDURE [dbo].[spa_book_tag_name]
	@flag CHAR(1),
	@xml VARCHAR(MAX) = NULL
AS

SET NOCOUNT ON

/* ---- DEGUB ----
DECLARE @flag CHAR(1),
	@xml VARCHAR(MAX)

SELECT @flag = 'i', @xml = '<Root function_id="20010500" ><FormXML tag1="Tag 1" tag2 = "Tag 2" tag3 = "Tag 3" tag4 = "Tag 4" reporting_group1="Reporting Group1" reporting_group2 = "Reporting Group2" reporting_group3 = "Reporting Group3" reporting_group4 = "Reporting Group4" reporting_group5 = "Reporting Group10"></FormXML></Root>'
--*/
DECLARE @SQL VARCHAR(MAX)
DECLARE @doc_handle INT
DECLARE @tag1 VARCHAR(100) = NULL 
DECLARE @tag2 VARCHAR(100) = NULL 
DECLARE @tag3 VARCHAR(100) = NULL 
DECLARE @tag4 VARCHAR(100) = NULL 
DECLARE @reporting_group1 VARCHAR(1000) = NULL
DECLARE @reporting_group2 VARCHAR(1000) = NULL
DECLARE @reporting_group3 VARCHAR(1000) = NULL
DECLARE @reporting_group4 VARCHAR(1000) = NULL
DECLARE @reporting_group5 VARCHAR(1000) = NULL

IF @flag = 's'
BEGIN
	SELECT group1 tag1, group2 tag2, group3 tag3, group4 tag4
		, reporting_group1 
		, reporting_group2 
		, reporting_group3 
		, reporting_group4 
		, reporting_group5 
	FROM source_book_mapping_clm
END
ELSE IF @flag = 'i'
BEGIN
	EXEC sp_xml_preparedocument @doc_handle OUTPUT, @xml
	
	SELECT	@tag1 = ISNULL(tag1, ''),
			@tag2 = ISNULL(tag2, ''),
			@tag3 = ISNULL(tag3, ''),
			@tag4 = ISNULL(tag4, ''), 
			@reporting_group1 = ISNULL(reporting_group1, ''), 
		    @reporting_group2 = ISNULL(reporting_group2, ''), 
		    @reporting_group3 = ISNULL(reporting_group3, ''), 
		    @reporting_group4 = ISNULL(reporting_group4, ''),  
		    @reporting_group5 = ISNULL(reporting_group5, '')
	FROM OPENXML (@doc_handle, '/Root/FormXML', 2)
	WITH (       
		tag1 VARCHAR(100) '@tag1',
		tag2 VARCHAR(100) '@tag2',
		tag3 VARCHAR(100) '@tag3',
		tag4 VARCHAR(100) '@tag4',
		reporting_group1 VARCHAR(1000) '@reporting_group1',
		reporting_group2 VARCHAR(1000) '@reporting_group2',
		reporting_group3 VARCHAR(1000) '@reporting_group3',
		reporting_group4 VARCHAR(1000) '@reporting_group4',
		reporting_group5 VARCHAR(1000) '@reporting_group5'
	)
	EXEC sp_xml_removedocument @doc_handle

	IF @tag1 = ''
		SET @tag1 = 'Tag 1'
	IF @tag2 = ''
		SET @tag2 = 'Tag 2'
	IF @tag3 = ''
		SET @tag3 = 'Tag 3'
	IF @tag4 = ''
		SET @tag4 = 'Tag 4'

	IF @reporting_group1 = ''
		SET @reporting_group1 = 'Reporting Group1'
	IF @reporting_group2 = ''
		SET @reporting_group2 = 'Reporting Group2'
	IF @reporting_group3 = ''
		SET @reporting_group3 = 'Reporting Group3'
	IF @reporting_group4 = ''
		SET @reporting_group4 = 'Reporting Group4'
	IF @reporting_group5 = ''
		SET @reporting_group5 = 'Reporting Group5'
	
	IF EXISTS(SELECT 1 FROM maintain_field_deal WHERE default_label IN (@tag1, @tag2, @tag3, @tag4) AND header_detail = 'h')
	BEGIN
		DECLARE @err_val VARCHAR(200)

		SELECT TOP 1 @err_val = 
			STUFF(
					(
						SELECT ', ' + mfd.default_label + '' FROM maintain_field_deal mfd
						WHERE mfd.default_label IN (@tag1, @tag2, @tag3, @tag4) AND mfd.header_detail = 'h'
						FOR XML Path('')
					), 1, 1, ''
				)
		FROM maintain_field_deal b
		WHERE b.default_label IN (@tag1, @tag2, @tag3, @tag4) AND b.header_detail = 'h'

		DECLARE @msg VARCHAR(MAX) = '<strong>' + @err_val + '</strong> already used as field label in Deal Fields for Tag. Please use another name.'
		EXEC spa_ErrorHandler -1
			, 'Setup Book Tag Name'
			, 'spa_book_tag_name'
			, 'Error'
			, @msg
			, ''

		RETURN
	END
	
	 --SELECT @tag1, @tag2, @tag3, @tag4,@reporting_group1 , @reporting_group2 , @reporting_group3 , @reporting_group4 , @reporting_group5
	 --RETURN

	IF (SELECT 1 FROM source_book_mapping_clm) IS NULL
	BEGIN
		INSERT INTO source_book_mapping_clm (group1, group2, group3, group4
											, reporting_group1 , reporting_group2 , reporting_group3 , reporting_group4 , reporting_group5)
		VALUES (@tag1, @tag2, @tag3, @tag4, @reporting_group1 , @reporting_group2 , @reporting_group3 , @reporting_group4 , @reporting_group5)
	END
	ELSE
	BEGIN
		UPDATE source_book_mapping_clm
		SET group1 = @tag1,
			group2 = @tag2,
			group3 = @tag3,
			group4 = @tag4,
			reporting_group1 = @reporting_group1, 
			reporting_group2 = @reporting_group2, 
			reporting_group3 = @reporting_group3, 
			reporting_group4 = @reporting_group4, 
			reporting_group5 = @reporting_group5
	END	

	EXEC spa_ErrorHandler 0 
		, 'Setup Book Tag Name'
		, 'spa_book_tag_name'
		, 'Success'
		, 'Changes have been saved successfully.'
		, ''
END
ELSE IF @flag = 'x'
BEGIN
	DECLARE @disable_tagging BIT

	SELECT @disable_tagging = var_value
	FROM adiha_default_codes_values
	WHERE default_code_id = 104
		AND var_value = 0

	SET @disable_tagging = ISNULL(@disable_tagging, 1)

	SELECT @disable_tagging disable_tagging
END
GO