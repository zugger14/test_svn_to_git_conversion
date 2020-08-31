IF OBJECT_ID(N'[dbo].[spa_resolve_workflow_message_tag]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_resolve_workflow_message_tag]
GO
   
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 /**
	Resolves the workflow message tag

	Parameters :
	@flag : Not in Use
	@message_input : Message text to be resolved
	@source_id : Value of the primary column of the workflow module
	@module_id :static_data_values - type_id = 20600
	@message_output : output message after the tag is resolved
 */

CREATE PROCEDURE [dbo].[spa_resolve_workflow_message_tag]
	@flag CHAR(1) = NULL,
	@message_input NVARCHAR(MAX) = NULL,
	@source_id INT = NULL,
	@module_id INT = NULL,
	@event_message_id INT = NULL,
	@message_output NVARCHAR(MAX) OUTPUT
AS

SET NOCOUNT ON

/*
	DECLARE @flag CHAR(1) = NULL,
	@message_input NVARCHAR(MAX) = NULL,
	@source_id INT = NULL,
	@module_id INT = NULL,
	@message_output NVARCHAR(MAX) = NULL

	SELECT @message_input = 'IF 5 < 10 <#COUNTERPARTY><COUNTERPARTY><COUNTERPARTY#> Counterparty credit file has been updated of contract <CONTRACT>.'
		,@source_id = 8948
		,@module_id = 20602
--*/



SET NOCOUNT ON
DECLARE @workflow_message_tag NVARCHAR(MAX)
	   ,@workflow_tag_query NVARCHAR(MAX)
	   ,@tag_value NVARCHAR(3000)
	   ,@replace_variable NVARCHAR(3000)
	   ,@notes_category INT
	   ,@workflow_message_tag_id INT
	   ,@function_id INT
	   ,@function_id_query NVARCHAR(MAX)
	   ,@tag_id NVARCHAR(100)

SELECT @message_input = dbo.FNADecodeXML(@message_input)

IF @module_id = 20603
BEGIN
	SET @notes_category = 40 
END
ELSE IF @module_id = 20601
BEGIN
	SET @notes_category = 33
END
ELSE IF @module_id = 20602
BEGIN
	SET @notes_category = 37
END


IF OBJECT_ID('tempdb..#temp_hyperlink_data') IS NOT NULL
			DROP TABLE #temp_hyperlink_data
CREATE TABLE #temp_hyperlink_data(
	hyperlink_tag NVARCHAR(100) COLLATE DATABASE_DEFAULT,
	param1 NVARCHAR(100) COLLATE DATABASE_DEFAULT,
	param2 NVARCHAR(100) COLLATE DATABASE_DEFAULT,
	param3 NVARCHAR(100) COLLATE DATABASE_DEFAULT,
	param4 NVARCHAR(100) COLLATE DATABASE_DEFAULT,
	param5 NVARCHAR(100) COLLATE DATABASE_DEFAULT,
	param6 NVARCHAR(100) COLLATE DATABASE_DEFAULT,
	param7 NVARCHAR(100) COLLATE DATABASE_DEFAULT
)

IF OBJECT_ID('tempdb..#temp_manual_function_id') IS NOT NULL
			DROP TABLE #temp_manual_function_id
CREATE TABLE #temp_manual_function_id(
	workflow_message_tag_id INT,
	function_id NVARCHAR(100) COLLATE DATABASE_DEFAULT,
	function_id_query NVARCHAR(MAX) COLLATE DATABASE_DEFAULT
)

IF OBJECT_ID('tempdb..#temp_function_id_value') IS NOT NULL
			DROP TABLE #temp_function_id_value
CREATE TABLE #temp_function_id_value(
	[value] NVARCHAR(MAX) COLLATE DATABASE_DEFAULT
)


INSERT INTO #temp_manual_function_id(workflow_message_tag_id,function_id,function_id_query)
SELECT wmt.workflow_message_tag_id,NULL,application_function_id
FROM workflow_message_tag wmt
WHERE wmt.module_id = @module_id
AND wmt.is_hyperlink = 1
AND ISNUMERIC(wmt.application_function_id) = 0
AND NULLIF(wmt.application_function_id,'') IS NOT NULL

DECLARE cursor_function_id_query CURSOR FOR
SELECT workflow_message_tag_id,function_id,function_id_query
FROM #temp_manual_function_id
OPEN cursor_function_id_query
	FETCH NEXT FROM cursor_function_id_query INTO @workflow_message_tag_id,@function_id,@function_id_query
	WHILE @@FETCH_STATUS = 0
	BEGIN	
		
		SELECT @function_id_query = REPLACE(@function_id_query,'@_source_id',@source_id)
		INSERT INTO #temp_function_id_value
		EXEC(@function_id_query)

		SELECT @function_id = [value]
		FROM #temp_function_id_value

		UPDATE #temp_manual_function_id
		SET function_id = ISNULL(@function_id,-11111) --random number
		WHERE workflow_message_tag_id = @workflow_message_tag_id

		TRUNCATE TABLE #temp_function_id_value

	FETCH NEXT FROM cursor_function_id_query INTO @workflow_message_tag_id,@function_id,@function_id_query
	END
CLOSE cursor_function_id_query
DEALLOCATE cursor_function_id_query

INSERT INTO #temp_hyperlink_data(hyperlink_tag,param1,param2,param3,param4,param5,param6,param7)
SELECT REPLACE(workflow_message_tag,'<','<#')
	  ,COALESCE(function_id,application_function_id)
	  ,'@_source_id'
	  ,CASE WHEN @module_id = -11111 THEN CAST(@source_id AS NVARCHAR(20)) --conditon needs to be updated for manage document
			ELSE 'n'
	   END
	  ,CASE WHEN @module_id = -11111 THEN CAST(@notes_category AS NVARCHAR(20)) --conditon needs to be updated for manage document
			ELSE 'NULL'
END
	  ,CASE WHEN @module_id = -11111 THEN 'workflow' --conditon needs to be updated for manage document
			ELSE 'NULL'
END
	  , 'NULL'
	  ,''
FROM workflow_message_tag wmt
LEFT JOIN #temp_manual_function_id tmfi
	ON tmfi.workflow_message_tag_id = wmt.workflow_message_tag_id
WHERE wmt.module_id = @module_id
AND wmt.is_hyperlink = 1

IF OBJECT_ID('tempdb..#temp_workflow_message_tag') IS NOT NULL
			DROP TABLE #temp_workflow_message_tag
CREATE TABLE #temp_workflow_message_tag(
	workflow_message_tag NVARCHAR(1000) COLLATE DATABASE_DEFAULT,
	[value] NVARCHAR(MAX) COLLATE DATABASE_DEFAULT,
	[type] INT, --0 -> normal tag,1 -> hyperlink begin tag, 2-> hyperlink end tag
	workflow_tag_query NVARCHAR(MAX) COLLATE DATABASE_DEFAULT
)

IF OBJECT_ID('tempdb..#temp_tag_value') IS NOT NULL
			DROP TABLE #temp_tag_value
CREATE TABLE #temp_tag_value(
	[value] NVARCHAR(100) COLLATE DATABASE_DEFAULT,
	[code] NVARCHAR(MAX) COLLATE DATABASE_DEFAULT
)

DECLARE @modules_event_id INT, @source_column NVARCHAR(100)
SELECT TOP 1 @modules_event_id = et.modules_event_id, @source_column = atd.primary_column 
FROM workflow_event_message wem
INNER JOIN event_trigger et ON wem.event_trigger_id = et.event_trigger_id
INNER JOIN module_events me ON et.modules_event_id = me.module_events_id
INNER JOIN alert_table_definition atd ON atd.alert_table_definition_id = me.rule_table_id
WHERE wem.event_message_id = @event_message_id

UPDATE #temp_hyperlink_data
SET param3 = @source_column,
    param4 = @module_id,
    param5 =  '' + @source_column + ':@_source_id',
    param6 = @modules_event_id
WHERE param1 = '10106612' 

INSERT INTO #temp_workflow_message_tag(workflow_message_tag,[value],[type],workflow_tag_query)
SELECT workflow_message_tag,NULL,0,workflow_tag_query 
FROM workflow_message_tag
WHERE module_id = @module_id
UNION 
SELECT hyperlink_tag
	  ,'<span style="cursor:pointer" onClick= "' + 'TRMWinHyperlink(' +param1 + ',''' + param2 + ''',''' + param3 + ''',''' + param4 + ''',''' + param5 + ''',''' + param6 + ''',''' + param7 + ''')' + '"><font color=#0000ff><u><l>'
	  ,1
	  , NULL 
FROM #temp_hyperlink_data
UNION 
SELECT REPLACE(workflow_message_tag,'>','#>'),'<l></u></font></span>',2 , NULL 
FROM workflow_message_tag
WHERE module_id = @module_id
AND is_hyperlink = 1

DECLARE cursor_workflow_message_tag CURSOR FOR
SELECT workflow_message_tag,workflow_tag_query
FROM #temp_workflow_message_tag
WHERE [type] = 0
OPEN cursor_workflow_message_tag
	FETCH NEXT FROM cursor_workflow_message_tag INTO @workflow_message_tag, @workflow_tag_query
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF CHARINDEX(@workflow_message_tag,@message_input) <> 0
		BEGIN
			SELECT @workflow_tag_query = REPLACE(@workflow_tag_query,'@_source_id',@source_id)

			INSERT INTO #temp_tag_value([value],[code])
			EXEC(@workflow_tag_query)

			SELECT @tag_id = [value]
				  ,@tag_value = [code]
			FROM  #temp_tag_value

			UPDATE #temp_workflow_message_tag
			SET  [value] = REPLACE([value],'@_source_id',ISNULL(@tag_id,@source_id))
			WHERE workflow_message_tag = REPLACE(@workflow_message_tag,'<','<#')
			AND [type] = 1

			UPDATE #temp_workflow_message_tag
			SET  [value] = @tag_value
			WHERE workflow_message_tag = @workflow_message_tag
			AND [type] = 0
		END
		TRUNCATE TABLE #temp_tag_value
		
	FETCH NEXT FROM cursor_workflow_message_tag INTO @workflow_message_tag, @workflow_tag_query
	END
CLOSE cursor_workflow_message_tag
DEALLOCATE cursor_workflow_message_tag


SELECT @message_input = REPLACE(@message_input,workflow_message_tag,ISNULL(NULLIF([value],''),workflow_message_tag)) 
FROM #temp_workflow_message_tag

SELECT @message_output = @message_input
