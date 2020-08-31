IF OBJECT_ID(N'[dbo].[spa_parse_json]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_parse_json]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

-- =============================================================================================================================
-- Author: bmaharjan@pioneersolutionsglobal.com
-- Create date: 2019-03-14
-- Description: Parse XML and stored values to prosecc table
 
-- Params:
-- @flag CHAR(1)        - 'parse' - Parse the JSON data and save in process table
-- @json_full_path		VARCHAR(2000) - Full path of JSON file.
-- @json_script			VARCHAR(MAX) - JSON script
-- @process_table_name	VARCHAR(500) - process table name to store JSON data. 
-- =============================================================================================================================


CREATE PROCEDURE [dbo].[spa_parse_json]
    @flag					VARCHAR(100),
    @json_full_path			VARCHAR(2000) = NULL,
    @json_string			VARCHAR(MAX) = NULL,
    @output_process_table	VARCHAR(500) = NULL,
	@input_process_table	VARCHAR(500) = NULL,
	@return_output			INT = 1,
	@filter_tag				VARCHAR(1000) = NULL    
AS
   
SET NOCOUNT ON

/*
 * @ssms_version - 10.8 -> SQL2008
 * @ssms_version - 10.5 -> SQL2008 R2
 * @ssms_version - 11 -> SQL2012
 * @ssms_version - 12 -> SQL2014
 * @ssms_version - 13 -> SQL2016
 * @ssms_version - 14 -> SQL2017
 */ 	
DECLARE @ssms_version VARCHAR(100)
DECLARE @compatibility_level INT
SELECT @ssms_version = SUBSTRING(CAST(SERVERPROPERTY ('productversion') AS VARCHAR),0,CHARINDEX('.',CAST(SERVERPROPERTY ('productversion') AS VARCHAR)))
SELECT @compatibility_level = [compatibility_level] FROM sys.databases WHERE name = DB_NAME()

DECLARE @sql VARCHAR(MAX)
DECLARE @process_id VARCHAR(100) = dbo.FNAGetNewID()


/*
 * [Read the JSON and list out all the nodes maintaining relationship]
 */
IF @flag IN ('parse','simple_parse')
BEGIN

	IF @json_full_path IS NOT NULL
	BEGIN
		SET @json_string = dbo.FNAReadFileContents(@json_full_path);
	END
	SET @json_string = REPLACE(REPLACE(@json_string, CHAR(13), ''), CHAR(10), ' ')

	IF OBJECT_ID('tempdb..#json_parse_nodes') IS NOT NULL
		DROP TABLE #json_parse_nodes
	/*
	 * [value_type]
	 * 0 -> NULL	
	 * 1 -> String	
	 * 2 -> Numeric
	 * 3 -> Boolean
	 * 4 -> Array
	 * 5 -> Object
	 */
	CREATE TABLE #json_parse_nodes (
		[key_index]			VARCHAR(200)	COLLATE DATABASE_DEFAULT,
		[parent_key_index]	VARCHAR(200)	COLLATE DATABASE_DEFAULT,
		[key]				VARCHAR(2000)	COLLATE DATABASE_DEFAULT,
		[value_data]		VARCHAR(MAX)	COLLATE DATABASE_DEFAULT,
		[value_type]		INT,
		[reference_level]	INT,
		[Group]				VARCHAR(2000)	COLLATE DATABASE_DEFAULT
	)
		
	DECLARE @reference_count INT = 1
	/*
	 * Parse JSON directly from SQL Server, only support for greater than SQL2016
	 */
	IF @ssms_version >= 13 AND @compatibility_level >=130
	BEGIN
		DECLARE @random_index VARCHAR(100) = dbo.FNAGetNewID()

		IF OBJECT_ID('tempdb..#tmp_json') IS NOT NULL
			DROP TABLE #tmp_json

		CREATE TABLE #tmp_json (
			[key_index]			VARCHAR(200)	COLLATE DATABASE_DEFAULT,
			[value]				VARCHAR(MAX)	COLLATE DATABASE_DEFAULT,
			[value_type]		INT,
			[value_type_pre]	INT,
			[key_pre]			VARCHAR(2000)	COLLATE DATABASE_DEFAULT,
			[parent_ind]		VARCHAR(2000)	COLLATE DATABASE_DEFAULT,
			[Group]				VARCHAR(2000)	COLLATE DATABASE_DEFAULT
		)

		IF OBJECT_ID('tempdb..#tmp_json_new') IS NOT NULL
			DROP TABLE #tmp_json_new

		CREATE TABLE #tmp_json_new (
			[key_index]			VARCHAR(200)	COLLATE DATABASE_DEFAULT,
			[value]				VARCHAR(MAX)	COLLATE DATABASE_DEFAULT,
			[value_type]		INT,
			[value_type_pre]	INT,
			[key_pre]			VARCHAR(2000)	COLLATE DATABASE_DEFAULT,
			[parent_ind]		VARCHAR(2000)	COLLATE DATABASE_DEFAULT,
			[Group]				VARCHAR(2000)	COLLATE DATABASE_DEFAULT
		)

		INSERT INTO #tmp_json ([key_index],[value],[value_type],[parent_ind])
		SELECT @random_index + [key],[value],[type],[key] FROM OPENJSON(@json_string) jsn
		WHERE [key] = ISNULL(@filter_tag,[key])

		
		WHILE (SELECT COUNT(key_index) FROM #tmp_json) > 0
		BEGIN  
			SET @random_index = dbo.FNAGetNewID()
			
			INSERT INTO #json_parse_nodes (
				[key_index],
				[parent_key_index],
				[key],
				[value_data],
				[value_type],
				[reference_level],
				[Group]
				)
			SELECT	@random_index +jsn.[parent_ind],
					CASE WHEN jsn.value_type_pre IN (4) THEN jsn.[key_pre] WHEN jsn.key_pre IS NOT NULL THEN jsn.key_index  ELSE NULL END,
					jsn_n.[key],
					jsn_n.[value],
					jsn_n.[type],
					@reference_count,
					COALESCE(jsn.[Group],@filter_tag,'Header')
			FROM #tmp_json jsn
			OUTER APPLY (SELECT * FROM OPENJSON(jsn.value)) jsn_n 
			WHERE jsn_n.[type] IN (1,2,3,0)

			DELETE FROM #tmp_json_new
			INSERT INTO #tmp_json_new (
				[key_index],
				[value],
				[value_type],
				[value_type_pre],
				[key_pre],
				[parent_ind],
				[Group]
			)
			SELECT	@random_index + jsn.[parent_ind],
					jsn_n.[value],
					jsn_n.[type], 
					jsn.[value_type], 
					jsn.[key_index],
					jsn.[parent_ind] + jsn_n.[key],
					CASE WHEN jsn.[value_type] = 5 THEN jsn_n.[key] ELSE jsn.[Group] END
			FROM #tmp_json jsn
			OUTER APPLY (SELECT * FROM OPENJSON(jsn.value)) jsn_n 
			WHERE jsn_n.[type] IN (4,5)

			DELETE FROM #tmp_json
			INSERT INTO #tmp_json
			SELECT * FROM #tmp_json_new
			SET @reference_count = @reference_count+1
		END
	END
	/*
	 * Parse JSON for SQL less than 2016
	 */
	ELSE
	BEGIN
		IF OBJECT_ID('tempdb..#parseJSON_result') IS NOT NULL
			DROP TABLE #parseJSON_result

		CREATE TABLE #parseJSON_result(
			element_id INT,
			sequenceNo INT,
			parent_ID INT,
			Object_ID INT,
			NAME NVARCHAR(2000),
			StringValue NVARCHAR(MAX),
			ValueType VARCHAR(10)
		)

		IF @input_process_table IS NOT NULL
		BEGIN
			EXEC('
				INSERT INTO #parseJSON_result
		SELECT * 
				FROM '+ @input_process_table +'
			')
		END
		ELSE
		BEGIN
			INSERT INTO #parseJSON_result
			SELECT *
			FROM dbo.FNAParseJSON(@json_string)
		END
		

		INSERT INTO #json_parse_nodes (
				[key_index],
				[parent_key_index],
				[key],
				[value_data],
				[value_type],
				[reference_level],
				[Group]
		)
		SELECT	tmp.[parent_id] [Key_Index],
				tmp_arr.[parent_ID] [Parent_Key_Index],
				tmp.[Name] [Key],
				tmp.StringValue	[value],
				1	[valueType],
				NULL,
				CASE WHEN ISNULL(tmp_arr.[Name],'-') = '-' THEN 'Header' ELSE tmp_arr.[Name] END [Group]
		FROM #parseJSON_result tmp
		LEFT JOIN #parseJSON_result tmp_obj ON tmp.parent_ID = tmp_obj.[Object_ID]
		LEFT JOIN #parseJSON_result tmp_arr ON tmp_obj.parent_ID = tmp_arr.[Object_ID]
		WHERE tmp.[Object_ID] IS NULL
			AND ISNULL(tmp_arr.[Name],'-') = COALESCE(@filter_tag,tmp_arr.[Name],'-')
		
		UPDATE jsn 
		SET jsn.[reference_level] = a.[reference_level]
		FROM #json_parse_nodes jsn
		OUTER APPLY (
			SELECT * FROM (
				SELECT [Group], ROW_NUMBER() OVER (ORDER BY ind DESC) [reference_level] FROM 
					(SELECT [Group], MAX(CAST(key_index AS INT)) [ind] FROM #json_parse_nodes GROUP BY [Group]) a) b
			WHERE jsn.[Group] = b.[Group]
		) a

	END
	

	/*
	 * [Dump the data into process table]
	 */
	IF OBJECT_ID('tempdb..#json_parse_key_group') IS NOT NULL
		DROP TABLE #json_parse_key_group

	CREATE TABLE #json_parse_key_group (
		[Key]				VARCHAR(1000),
		[Reference_Level]	INT,
		[Group]				VARCHAR(1000)
	)

	SET @sql = 'INSERT INTO #json_parse_key_group ([Key],[Group],[Reference_Level])
				SELECT DISTINCT [Key], [Group], MAX([Reference_Level]) [Reference_Level] 
				FROM #json_parse_nodes
				GROUP BY [Group],[Key]'
	EXEC(@sql)

 
	DECLARE @pvt_process_table VARCHAR(1000) = 'adiha_process.dbo.json_parse_pivot_' + @process_id
	DECLARE @all_columns_list VARCHAR(MAX)
	SELECT @all_columns_list = ISNULL(@all_columns_list + '],[','') + ISNULL([key],'') FROM (SELECT DISTINCT [key] FROM #json_parse_key_group) a
	SET @all_columns_list = '[' + @all_columns_list + ']'
	
 
	UPDATE  #json_parse_nodes SET [value_data] = NULL WHERE [value_data] = ''
	SET @sql = '
		SELECT	[parent_key_index], 
				[key_index],' + @all_columns_list + '
		INTO ' + @pvt_process_table + '
		FROM  
		(
			SELECT  [parent_key_index], 
					[key_index],
					[key],
					[value_data] 
			FROM #json_parse_nodes
		) AS SourceTable  
		PIVOT  
		(  
			MAX([value_data])
			FOR [key] IN (' + @all_columns_list + ')  
		) AS PivotTable;' 		
	EXEC(@sql)

	--EXEC('select * from ' + @pvt_process_table)

	IF @output_process_table IS NULL
		SET @output_process_table = 'adiha_process.dbo.json_parse_data_' + @process_id + '_output'
	IF OBJECT_ID(@output_process_table) IS NOT NULL
		EXEC('DROP TABLE ' + @output_process_table)

	IF @flag = 'parse'
	BEGIN
		SET @sql = '
		DECLARE @final_query VARCHAR(MAX) = ''''

		SELECT @final_query = @final_query + '' '' +a.[qry]  FROM (
			SELECT	a.[group],
					MAX(a.reference_level) [reference_level],
					CASE 
						WHEN MAX(a.reference_level) = 1 OR MAX(a.reference_level) = -31 THEN 
						''SELECT '' + STUFF((SELECT DISTINCT '','' + [group] + ''.['' + [key] + '']'' FROM #json_parse_key_group b FOR XML PATH('''')), 1, 1, '''') +
						'' INTO ' + @output_process_table + ' FROM ' + @pvt_process_table + ' '' + a.[group] 
						ELSE '' LEFT JOIN ' + @pvt_process_table + ' '' + a.[group] + '' ON '' + a.[group] + ''.parent_key_index = '' + MAX(grp.[group]) + ''.key_index ''  
					END [qry]
			FROM #json_parse_key_group a
			OUTER APPLY (SELECT MAX(reference_level) [reference_level] FROM #json_parse_key_group ref WHERE ref.reference_level < a.reference_level) ref
			OUTER APPLY (SELECT [group] FROM #json_parse_key_group iref WHERE iref.reference_level = ref.reference_level) grp
			GROUP BY a.[group]
		) a
		ORDER BY [reference_level]
		
		SET @final_query = @final_query + '' WHERE header.parent_key_index IS NULL''
		
		EXEC(@final_query)'
	
	END
	ELSE IF @flag = 'simple_parse'
	BEGIN
		SELECT @sql = STUFF((SELECT DISTINCT ',[' + [key] + ']' FROM #json_parse_key_group b FOR XML PATH('')), 1, 1, '')
		SET @sql = 'SELECT ' + @sql + ' INTO ' + @output_process_table + ' FROM ' + @pvt_process_table
	END
	EXEC(@sql)
	
	IF @return_output = 1
		SELECT @output_process_table
END