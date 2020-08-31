SET NOCOUNT ON

IF OBJECT_ID(N'[dbo].FNAReplaceEmailTemplateParams', N'FN') IS NOT NULL 
	DROP FUNCTION [dbo].FNAReplaceEmailTemplateParams
GO

/**
	Replaces template params in email string by name-value pair. Supported format is xml and json.

	Parameters
	@email_string	:	String which consists of the template or any template type string whose place holder is replaced according to according to @template_params.
	@template_params	:	Name:Value collection based on which @email_string is repplaced.
*/

CREATE FUNCTION dbo.FNAReplaceEmailTemplateParams 
(
	@email_string NVARCHAR(MAX),
	@template_params NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	/*
	--TEST SCRIPT START
	DECLARE @email_string NVARCHAR(MAX)
	DECLARE @template_params NVARCHAR(MAX)
	
	--XML data format processing sample
	SET @email_string = '<body>     <p>Dear &lt;TRM_USER_LAST_NAME&gt;,</p>     <p>Following error has occured while running job &quot;&lt;TRM_JOB_NAME&gt;&quot;:</p>     <p>&lt;TRM_ERROR&gt;</p>     <p>Generated on: &lt;TRM_DATE&gt;</p>     <p>SENT AUTOMATICALLY BY TRMTRACKER. PLEASE DO NOT REPLY TO THIS EMAIL. </p>     </body>'
	SET @template_params = '<Root><PSRecordset name="&lt;TRM_JOB_NAME&gt;" value="Archive Data Job" /><PSRecordset name="&lt;TRM_ERROR&gt;" value="Invalid object name &apos;dbo.source_price_curve_archXXX&apos;." /><PSRecordset name="&lt;TRM_USER_LAST_NAME&gt;" value="Bista" /></Root>'
	
	----JSON data format processing sample
	SET @email_string = 'Data error for <column_name> : <column_value>(<column_name> : <column_value> for <column_name1>: <column_value1> is not mapped).'
	SET @template_params = '{
				"column_name": "counterparty",
				"column_value": "ABC XYZ",
				"column_name1":"location",
				"column_value1":"aaa"
			}'
	select dbo.FNAReplaceEmailTemplateParams(@email_string,@template_params)

	--TEST SCRIPT END************************/
	
	IF ISNULL(@template_params, '') = ''
	RETURN @email_string

	DECLARE @tbl_params AS TABLE (
			name NVARCHAR(250),
			value NVARCHAR(MAX)
		)
	DECLARE @final_err_msg NVARCHAR(MAX)
	
	IF CHARINDEX('<Root>', @template_params) > 0 
	BEGIN
		DECLARE @template_params_xml XML
		DECLARE @email_string_modified NVARCHAR(MAX)
				
		SET @template_params_xml = CAST(@template_params AS XML)
	
		INSERT INTO @tbl_params(name, value)
		SELECT T.c.value('@name', 'NVARCHAR(250)') AS name, T.c.value('@value', 'NVARCHAR(MAX)') AS value
		FROM @template_params_xml.nodes('Root/PSRecordset') T(c)
	
		--SELECT * FROM @tbl_params
	
		SELECT @email_string_modified = dbo.FNAEncodeXML(@email_string)


		select @email_string_modified = dbo.FNAURLDecode(@email_string_modified)

		--'<' if encoded becomes &lt;, futher encoding gives &amp;lt;, so need to combine this two literals to one
		SET @email_string_modified = REPLACE(REPLACE(@email_string_modified, '&amp;lt;', '&lt;'), '&amp;gt;', '&gt;')
	
		SELECT @email_string_modified = REPLACE(@email_string_modified, dbo.FNAEncodeXML(name), dbo.FNAEncodeXML(value)) 
		FROM @tbl_params

		SELECT @email_string_modified = REPLACE(@email_string_modified, dbo.FNAURLDecode(name), dbo.FNAURLDecode(value)) 
		FROM @tbl_params
	
		--SELECT dbo.FNADecodeXML(@email_string_modified)
	 
		SELECT @final_err_msg = dbo.FNADecodeXML(@email_string_modified)
	END
	ELSE
	BEGIN	
		SET @final_err_msg = @email_string

		INSERT INTO @tbl_params(name, value)
		SELECT '<' + LTRIM(RTRIM([key])) + '>', [value] 
		FROM OPENJSON(@template_params)

		SELECT @final_err_msg = REPLACE(@final_err_msg, [name], [value]) 
		FROM @tbl_params
	END

	RETURN @final_err_msg
END





GO
