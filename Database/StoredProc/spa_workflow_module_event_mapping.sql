IF OBJECT_ID(N'[dbo].[spa_workflow_module_event_mapping]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_workflow_module_event_mapping]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

 /**
	CRUD operation for module event mapping

	Parameters
	@flag : Operational flag
			'a'-- Get Events in the mapping
			'b'-- Get rule tables in the mapping
			'c'-- Get options for email dropdown
			'g'-- Get options for dropdown
			'i'-- Insert Update Mapping
			'r'-- Get Table definition for dropdown
			's'-- Get Message Tag
			'u'-- Get Data Source
			'e'-- Create workflow module mapping for UDT 
	@module_id : static_data_values - type_id = 20600.
	@event_id : static_data_values - type_id = 20500.
	@xml : form and grid values stored in xml form.
	@show_system_defined : 
 */

CREATE PROCEDURE [dbo].[spa_workflow_module_event_mapping]
	@flag NCHAR(1),
    @module_id INT = NULL,
    @event_id INT = NULL,
	@xml text = NULL,
	@show_system_defined NCHAR(1) = NULL
AS

/*
DECLARE
	@flag CHAR(1),
    @module_id INT = NULL,
    @event_id INT = NULL,
	@xml xml = NULL,
	@show_system_defined CHAR(1) = NULL

	select @flag= 'i',
	@module_id= 20609,
	@xml= '<Root><GridXMLEvent><GridRow  mapping_id="25" event_id="20524" is_active="1"></GridRow><GridRow  mapping_id="130" event_id="20570" is_active="1"></GridRow><GridRow  mapping_id="131" event_id="20577" is_active="1"></GridRow></GridXMLEvent><GridXMLRule><GridRow  mapping_id="30" rule_table_id="27" is_active="1" data_source_id="5051" is_action_view="1" primary_column="counterparty_credit_limit_id"></GridRow></GridXMLRule><GridXMLTag><GridRow  workflow_message_tag_id="41" workflow_message_tag_name="Credit" workflow_message_tag="&amp;lt;CREDIT&amp;gt;" workflow_tag_query="SELECT ccl.counterparty_id, ''''''''Credit File''''''''
	FROM counterparty_credit_limits ccl
	WHERE ccl.counterparty_credit_limit_id = @_source_id" is_hyperlink="1" application_function_id="10101122" system_defined="0"></GridRow><GridRow  workflow_message_tag_id="44" workflow_message_tag_name="Counterparty" workflow_message_tag="&amp;lt;COUNTERPARTY&amp;gt;" workflow_tag_query="SELECT sc.source_counterparty_id, sc.counterparty_name 
	FROM counterparty_credit_limits ccl
	inner join source_counterparty sc 
		ON sc.source_counterparty_id = ccl. counterparty_id 
	WHERE ccl.counterparty_credit_limit_id = @_source_id" is_hyperlink="1" application_function_id="10105800" system_defined="0"></GridRow></GridXMLTag><GridXMLEmail></GridXMLEmail><GridXMLEventDel></GridXMLEventDel><GridXMLRuleDel></GridXMLRuleDel><GridXMLTagDel></GridXMLTagDel><GridXMLEmailDel></GridXMLEmailDel></Root>'
--*/

SET NOCOUNT ON

DECLARE @sql NVARCHAR(MAX),
        @idoc int
DECLARE @err_msg NVARCHAR(4000)

IF @flag = 'a'
BEGIN
	SELECT mapping_id, event_id, is_active
	FROM workflow_module_event_mapping
	WHERE module_id = @module_id
END

ELSE IF @flag = 'b'
BEGIN
	SELECT wmrtm.mapping_id
		  ,wmrtm.rule_table_id
		  ,wmrtm.is_active
		  ,NULLIF(atd.data_source_id,0) data_source_id
		  ,IIF(ISNULL(NULLIF(atd.is_action_view,''),'n') = 'n','0','1') is_action_view
		  ,NULLIF(atd.primary_column,'NULL') primary_column
	FROM workflow_module_rule_table_mapping wmrtm
	INNER JOIN alert_table_definition atd
		ON atd.alert_table_definition_id = wmrtm.rule_table_id
	WHERE wmrtm.module_id = @module_id
	AND wmrtm.rule_table_id IS NOT NULL
END

ELSE IF @flag = 'c'
BEGIN
	SELECT 'e' [value], 'Email' [code] UNION
	SELECT 'c', 'CC' UNION
	SELECT 'b', 'BCC'
END

ELSE IF @flag = 'e'
BEGIN
	SELECT workflow_contacts_id
		  ,email_group
		  ,email_group_query
		  ,group_type
		  ,email_address_query
	FROM workflow_contacts
	WHERE module_id = @module_id
END

ELSE IF @flag = 'g'
BEGIN
	SELECT value_id,code 
	FROM static_data_value
	WHERE type_id = 20600
	UNION ALL
	SELECT DISTINCT module_id, 'UDT - ' + udt_name [code]
	FROM 
	workflow_module_event_mapping mp
	INNER JOIN user_defined_tables udt ON ABS(mp.module_id) = udt_id
	WHERE mp.module_id < -1 AND mp.is_active = 1
	ORDER BY code
END

ELSE IF @flag = 'i'
BEGIN
	BEGIN TRY
	EXEC sp_xml_preparedocument @idoc OUTPUT,
                                @xml

	IF OBJECT_ID('tempdb..#temp_event_mapping') IS NOT NULL
      DROP TABLE #temp_event_mapping

	IF OBJECT_ID('tempdb..#temp_event_mapping_delete') IS NOT NULL
      DROP TABLE #temp_event_mapping_delete

	IF OBJECT_ID('tempdb..#temp_rule_table_mapping') IS NOT NULL
      DROP TABLE #temp_rule_table_mapping

	  IF OBJECT_ID('tempdb..#temp_rule_table_mapping_delete') IS NOT NULL
      DROP TABLE #temp_rule_table_mapping_delete

	IF OBJECT_ID('tempdb..#temp_worflow_message_tag') IS NOT NULL
      DROP TABLE #temp_worflow_message_tag

	IF OBJECT_ID('tempdb..#temp_worflow_message_tag_delete') IS NOT NULL
      DROP TABLE #temp_worflow_message_tag_delete

	IF OBJECT_ID('tempdb..#temp_worflow_message_email') IS NOT NULL
      DROP TABLE #temp_worflow_message_email

	IF OBJECT_ID('tempdb..#temp_worflow_message_email_delete') IS NOT NULL
      DROP TABLE #temp_worflow_message_email_delete

	SELECT
      mapping_id [mapping_id],
      event_id [event_id],
      is_active [is_active] 
	INTO #temp_event_mapping
    FROM OPENXML(@idoc, '/Root/GridXMLEvent/GridRow', 1)
    WITH (
    mapping_id NVARCHAR(10),
    event_id NVARCHAR(10),
    is_active NVARCHAR(10)
    )

	SELECT
      mapping_id [mapping_id],
      event_id [event_id],
      is_active [is_active] 
	INTO #temp_event_mapping_delete
    FROM OPENXML(@idoc, '/Root/GridXMLEventDel/GridRow', 1)
    WITH (
    mapping_id NVARCHAR(10),
    event_id NVARCHAR(10),
    is_active NVARCHAR(10)
    )

	SELECT
      mapping_id [mapping_id],
      rule_table_id [rule_table_id],
      is_active [is_active],
	  data_source_id [data_source_id],
	  is_action_view [is_action_view],
	  primary_column [primary_column] 
	INTO #temp_rule_table_mapping
    FROM OPENXML(@idoc, '/Root/GridXMLRule/GridRow', 1)
    WITH (
    mapping_id NVARCHAR(10),
    rule_table_id NVARCHAR(10),
    is_active NVARCHAR(10),
	data_source_id NVARCHAR(10),
	is_action_view NCHAR(1),
	primary_column NVARCHAR(100)
	)

	SELECT
      mapping_id [mapping_id],
      rule_table_id [rule_table_id],
      is_active [is_active],
	  data_source_id [data_source_id],
	  is_action_view [is_action_view],
	  primary_column [primary_column]  
	INTO #temp_rule_table_mapping_delete
    FROM OPENXML(@idoc, '/Root/GridXMLRuleDel/GridRow', 1)
    WITH (
    mapping_id NVARCHAR(10),
    rule_table_id NVARCHAR(10),
    is_active NVARCHAR(10),
	data_source_id NVARCHAR(10),
	is_action_view NCHAR(1),
	primary_column NVARCHAR(100)
    )

	SELECT
      workflow_message_tag_id [workflow_message_tag_id],
      workflow_message_tag_name [workflow_message_tag_name],
      workflow_message_tag [workflow_message_tag],
	  workflow_tag_query [workflow_tag_query],
	  is_hyperlink		 [is_hyperlink],
	  system_defined [system_defined] ,
	  application_function_id [application_function_id]
	INTO #temp_worflow_message_tag
    FROM OPENXML(@idoc, '/Root/GridXMLTag/GridRow', 1)
    WITH (
    workflow_message_tag_id NVARCHAR(10),
    workflow_message_tag_name NVARCHAR(500),
    workflow_message_tag NVARCHAR(500),
	workflow_tag_query NVARCHAR(max),
	is_hyperlink NCHAR(1),
	system_defined NCHAR(1),
	application_function_id NVARCHAR(1000)
    )

	SELECT
      workflow_message_tag_id [workflow_message_tag_id],
      workflow_message_tag_name [workflow_message_tag_name],
      workflow_message_tag [workflow_message_tag], 
	  workflow_tag_query [workflow_tag_query],
	  is_hyperlink	[is_hyperlink],
	  system_defined [system_defined],
	  application_function_id [application_function_id] 
	INTO #temp_worflow_message_tag_delete
    FROM OPENXML(@idoc, '/Root/GridXMLTagDel/GridRow', 1)
    WITH (
    workflow_message_tag_id NVARCHAR(10),
    workflow_message_tag_name NVARCHAR(500),
    workflow_message_tag NVARCHAR(500),
	workflow_tag_query NVARCHAR(max),
	is_hyperlink NCHAR(1),
	system_defined NCHAR(1),
	application_function_id NVARCHAR(1000)
    )

	SELECT
      workflow_contacts_id [workflow_contacts_id],
      email_group [email_group],
      email_group_query [email_group_query],
	  group_type [group_type],
	  email_address_query		 [email_address_query]
	INTO #temp_worflow_message_email
    FROM OPENXML(@idoc, '/Root/GridXMLEmail/GridRow', 1)
    WITH (
    workflow_contacts_id NVARCHAR(10),
    email_group NVARCHAR(500),
    email_group_query NVARCHAR(MAX),
	group_type CHAR(1),
	email_address_query NVARCHAR(MAX)
    )

	SELECT
     workflow_contacts_id [workflow_contacts_id],
      email_group [email_group],
      email_group_query [email_group_query],
	  group_type [group_type],
	  email_address_query [email_address_query]
	INTO #temp_worflow_message_email_delete
    FROM OPENXML(@idoc, '/Root/GridXMLEmailDel/GridRow', 1)
    WITH (
    workflow_contacts_id NVARCHAR(10),
    email_group NVARCHAR(500),
    email_group_query NVARCHAR(MAX),
	group_type NCHAR(1),
	email_address_query NVARCHAR(MAX)
    )
    /*
	select * from #temp_event_mapping
	select * from #temp_event_mapping_delete
	select * from #temp_rule_table_mapping
	select * from #temp_rule_table_mapping_delete
	select * from #temp_worflow_message_tag
	select * from #temp_worflow_message_tag_delete
	select * from #temp_worflow_message_email
	select * from #temp_worflow_message_email_delete
	return
	*/

	/* Validation for Grid :- Event Mapping */

	IF EXISTS(SELECT 1
			FROM #temp_event_mapping
			GROUP BY event_id
			HAVING COUNT(*) > 1
	)
	BEGIN
		EXEC spa_ErrorHandler -1,
							  'spa_workflow_module_event_mapping',
							  'spa_workflow_module_event_mapping',
							  'DB Error',
							  'Duplicate data in (<b>Event</b>) column in <b>Event Mapping</b> grid.',
							  ''
	END
	/* End of validation for Grid :- Event Mapping*/

	/* Validation for Grid :- Rule table mapping */
	IF EXISTS(SELECT 1 
			  FROM #temp_rule_table_mapping
			  GROUP BY rule_table_id
			  HAVING COUNT(*) > 1
			  )
	BEGIN
		EXEC spa_ErrorHandler -1,
							  'spa_workflow_module_event_mapping',
							  'spa_workflow_module_event_mapping',
							  'DB Error',
							  'Duplicate data in (<b>Table</b>) column in <b>Rule Table Mapping</b> grid.',
							  ''
		RETURN
	END

	IF EXISTS(SELECT 1 
			  FROM #temp_rule_table_mapping
			  WHERe is_action_view = '1'
			  GROUP BY is_action_view
			  HAVING COUNT(*) > 1
			  )
	BEGIN
		EXEC spa_ErrorHandler -1,
							  'spa_workflow_module_event_mapping',
							  'spa_workflow_module_event_mapping',
							  'DB Error',
							  'Mulitple action view cannot exist.',
							  ''
		RETURN
	END

	IF EXISTS(SELECT 1 
			  FROM #temp_rule_table_mapping
			  WHERe is_action_view = '1' AND NULLIF(primary_column,'') IS NULL
			  )
	BEGIN
		EXEC spa_ErrorHandler -1,
							  'spa_workflow_module_event_mapping',
							  'spa_workflow_module_event_mapping',
							  'DB Error',
							  'Primary column cannot be null for action view.',
							  ''
		RETURN
	END

	/* End of validation for Grid :- Rule table mapping*/

	BEGIN TRAN
	UPDATE wmem
		SET wmem.event_id = tem.event_id,
		    wmem.is_active =  tem.is_active
	FROM #temp_event_mapping tem
	LEFT JOIN workflow_module_event_mapping wmem
		ON wmem.mapping_id = tem.mapping_id
	WHERE wmem.mapping_id IS NOT NULL
	AND wmem.module_id = @module_id

	INSERT INTO workflow_module_event_mapping(module_id,event_id,is_active)
	SELECT @module_id, tem.event_id, tem.is_active
	FROM #temp_event_mapping tem
	LEFT JOIN workflow_module_event_mapping wmem
		ON wmem.mapping_id = tem.mapping_id
	WHERE wmem.mapping_id IS NULL


	DELETE wmem
	FROM #temp_event_mapping_delete temd
	INNER JOIN workflow_module_event_mapping wmem
		ON wmem.mapping_id = temd.mapping_id
	WHERE wmem.mapping_id IS NOT NULL


	UPDATE wmrtm
		SET wmrtm.rule_table_id = trtm.rule_table_id,
		    wmrtm.is_active =  trtm.is_active
	FROM #temp_rule_table_mapping trtm
	LEFT JOIN workflow_module_rule_table_mapping wmrtm
		ON wmrtm.mapping_id = trtm.mapping_id
	WHERE wmrtm.mapping_id IS NOT NULL
	AND wmrtm.module_id = @module_id

	INSERT INTO workflow_module_rule_table_mapping(module_id,rule_table_id,is_active)
	SELECT @module_id, trtm.rule_table_id, trtm.is_active
	FROM #temp_rule_table_mapping trtm
	LEFT JOIN workflow_module_rule_table_mapping wmrtm
		ON wmrtm.mapping_id = trtm.mapping_id
	WHERE wmrtm.mapping_id IS NULL

	UPDATE atd
		SET atd.data_source_id = trtm.data_source_id,
			atd.is_action_view = IIF(ISNULL(NULLIF(trtm.is_action_view,''),'0') = '0','n','y'),
			atd.primary_column = trtm.primary_column
	FROM #temp_rule_table_mapping trtm
	INNER JOIN workflow_module_rule_table_mapping wmrtm
		ON wmrtm.mapping_id = trtm.mapping_id
	INNER JOIN alert_table_definition atd
		ON atd.alert_table_definition_id = wmrtm.rule_table_id
	AND wmrtm.module_id = @module_id


	DELETE wmrtm
	FROM #temp_rule_table_mapping_delete trtmd
	INNER JOIN workflow_module_rule_table_mapping wmrtm
		ON wmrtm.mapping_id = trtmd.mapping_id
	WHERE wmrtm.mapping_id IS NOT NULL



	UPDATE wmt
		SET wmt.workflow_message_tag_name = twmt.workflow_message_tag_name,
		    wmt.workflow_message_tag =  dbo.FNADecodeXML(twmt.workflow_message_tag),
			wmt.workflow_tag_query =  dbo.FNADecodeXML(twmt.workflow_tag_query),
			wmt.is_hyperlink = twmt.is_hyperlink,
			wmt.system_defined = twmt.system_defined,
			wmt.application_function_id = dbo.FNADecodeXML(twmt.application_function_id)
	FROM #temp_worflow_message_tag twmt
	LEFT JOIN workflow_message_tag wmt
		ON wmt.workflow_message_tag_id = twmt.workflow_message_tag_id
	WHERE wmt.workflow_message_tag_id IS NOT NULL
	AND wmt.module_id = @module_id

	INSERT INTO workflow_message_tag(module_id,workflow_message_tag_name,workflow_message_tag,workflow_tag_query,is_hyperlink , system_defined, application_function_id)
	SELECT @module_id, twmt.workflow_message_tag_name, dbo.FNADecodeXML(twmt.workflow_message_tag),dbo.FNADecodeXML(twmt.workflow_tag_query),twmt.is_hyperlink, twmt.system_defined, dbo.FNADecodeXML(twmt.application_function_id)
	FROM #temp_worflow_message_tag twmt
	LEFT JOIN workflow_message_tag wmt
		ON wmt.workflow_message_tag_id = twmt.workflow_message_tag_id
	WHERE wmt.workflow_message_tag_id IS NULL


	DELETE wmt
	FROM #temp_worflow_message_tag_delete twmtd
	INNER JOIN workflow_message_tag wmt
		ON wmt.workflow_message_tag_id = twmtd.workflow_message_tag_id
	WHERE wmt.workflow_message_tag_id IS NOT NULL

	

	UPDATE wc
		SET wc.email_group = twme.email_group,
		    wc.email_group_query = dbo.FNADecodeXML(twme.email_group_query),
			wc.group_type =  twme.group_type,
			wc.email_address_query = dbo.FNADecodeXML(twme.email_address_query)
	FROM #temp_worflow_message_email twme
	LEFT JOIN workflow_contacts wc
		ON wc.workflow_contacts_id = twme.workflow_contacts_id
	WHERE wc.workflow_contacts_id IS NOT NULL
	AND wc.module_id = @module_id

	INSERT INTO workflow_contacts(module_id,email_group,email_group_query,group_type,email_address_query)
	SELECT @module_id, twme.email_group, dbo.FNADecodeXML(twme.email_group_query), twme.group_type, dbo.FNADecodeXML(twme.email_address_query)
	FROM #temp_worflow_message_email twme
	LEFT JOIN workflow_contacts wc
		ON wc.workflow_contacts_id = twme.workflow_contacts_id
	WHERE wc.workflow_contacts_id IS NULL


	DELETE wc
	FROM #temp_worflow_message_email_delete twme
	LEFT JOIN workflow_contacts wc
		ON wc.workflow_contacts_id = twme.workflow_contacts_id
	WHERE wc.workflow_contacts_id IS NOT NULL

	COMMIT TRAN
	EXEC spa_ErrorHandler 0,
                          'spa_workflow_module_event_mapping',
                          'spa_workflow_module_event_mapping',
                          'Success',
                          'Changes have been saved successfully.',
                          ''
	  END TRY
	  BEGIN CATCH
		IF @@TRANCOUNT > 0
		  ROLLBACK
		--PRINT error_message()
		EXEC spa_ErrorHandler -1,
							  'spa_workflow_module_event_mapping',
							  'spa_workflow_module_event_mapping',
							  'DB Error',
							  'Error while updating.',
							  ''
	  END CATCH
END

ELSE IF @flag = 'r'
BEGIN
	SELECT alert_table_definition_id, logical_table_name
	FROM alert_table_definition
	ORDER BY logical_table_name
END

ELSE IF @flag = 's'
BEGIN
	SET @sql = '
		SELECT workflow_message_tag_id,workflow_message_tag_name,workflow_message_tag, workflow_tag_query, ISNULL(NULLIF(is_hyperlink,''''),0) is_hyperlink, application_function_id, ISNULL(NULLIF(system_defined,''''),0) system_defined 
		FROM workflow_message_tag
		WHERE module_id = ' + CAST(@module_id AS NVARCHAR(10)) + ''
		+ CASE WHEN ISNULL(@show_system_defined,0) = 0 THEN ' AND ISNULL(NULLIF(system_defined,''''),0) = 0'
		  ELSE  '' END
	EXEC(@sql)

END


ELSE IF @flag = 'u'
BEGIN
	SELECT  data_source_id, [name]
	FROM [data_source]
	where category IN (106502,106503)
	ORDER BY [name]
END

ELSE IF @flag = 'z'
BEGIN
	BEGIN TRY
		BEGIN TRAN
			IF @module_id < -1
			BEGIN
				EXEC spa_user_defined_tables @flag = 'v', @udt_id = @module_id

				DELETE FROM workflow_module_event_mapping WHERE module_id = @module_id
				DELETE FROM workflow_module_rule_table_mapping WHERE module_id = @module_id

				INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
				SELECT @module_id, 10000331, 1

				DECLARE @udt_table_name NVARCHAR(500), @rule_table_id INT
				SELECT @udt_table_name = 'udt_' + udt_name FROM user_defined_tables WHERE udt_id = ABS(@module_id)
				SELECT @rule_table_id = alert_table_definition_id FROM alert_table_definition WHERE physical_table_name = @udt_table_name

				INSERT INTO workflow_module_rule_table_mapping (module_id, rule_table_id, is_active)
				SELECT @module_id, @rule_table_id, 1
			END
		COMMIT

		EXEC spa_ErrorHandler 0,
			'spa_workflow_module_event_mapping',
			'spa_workflow_module_event_mapping',
			'Success',
			'Changes has been successfully saved.',
				''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
		SET @err_msg = error_message()
		EXEC spa_ErrorHandler -1,
			'spa_workflow_module_event_mapping',
			'spa_workflow_module_event_mapping',
			'Error',
			@err_msg,
			''
	END CATCH
END