SET NOCOUNT ON

IF OBJECT_ID(N'[putils].spa_object_documentation', N'P ') IS NOT NULL 
	DROP PROCEDURE [putils].spa_object_documentation
GO
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/**
	Main script to update extended properties of function, procedures, views or table and their parameters.

	Parameters
	@flag	:	'iu' flag is used for inserting the extended properties, 'a' flag for selecting extended properties of a particular object, 's' flag is used for selecting extended properties of all the objects 
	@json_string	:	JSON that contains the description of the object and their parameters.
	@object_type	:	Type of the object. Possible values : 'PROCEDURE','FUNCTION','TABLE','VIEW'
	@object_name	:	Name of the object.
	@table_name	:	Name of the table if extended properties needed to be updated once through excel file. Is used if @json_string is NULL 
*/

CREATE PROCEDURE putils.[spa_object_documentation] 
	@flag			CHAR(50) = 'iu',
	@json_string	NVARCHAR(MAX) = NULL,
	@object_type	NVARCHAR(MAX) = NULL,
	@object_name	NVARCHAR(MAX) = NULL,
	@table_name		NVARCHAR(MAX) = NULL
		
AS
/*----------Debug code starts here--------------------------
	DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
	SET CONTEXT_INFO @contextinfo
	EXEC spa_print 'Use spa_print instead of PRINT statement in debug mode.'

	DECLARE	@flag			CHAR(50) = 'iu',
			@json_string	NVARCHAR(MAX) = NULL,
			@object_type	NVARCHAR(MAX) = NULL,
			@object_name	NVARCHAR(MAX) = NULL,
			@table_name		NVARCHAR(MAX) = NULL
	
	SELECT @json_string = 
						N'						
						{
							"object_type" : "PROCEDURE", "object_name" : "spa_object_documentation",
							"parameter" : [
												{"name" : "", "desc" : "Main script to update extended properties of function, procedures, views or table and their parameters."},
												{"name" : "@flag", "desc" : "''iu'' flag is used for inserting the extended properties, ''a'' flag for selecting extended properties of a particular object, ''s'' flag is used for selecting extended properties of all the objects "},
												{"name" : "@json_string", "desc" : "JSON that contains the description of the object and their parameters."},
												{"name" : "@object_type", "desc" : "Type of the object. Possible values : ''PROCEDURE'',''FUNCTION'',''TABLE'',''VIEW''"},
												{"name" : "@object_name", "desc" : "Name of the object."},
												{"name" : "@table_name", "desc" : "Name of the table if extended properties needed to be updated once through excel file. Is used if @json_string is NULL "}
												
											]
						}'

	--SELECT  @flag = 'a', @object_type = 'PROCEDURE', @object_name = 'spa_object_documentation'


	--DROP all temp tables created i this scope.
	EXEC spa_drop_all_temp_table
----------------------Debug code ends here-------------**/

SET NOCOUNT ON
IF @flag = 'iu'
BEGIN	
	SET @json_string = '{"levels" :[' + @json_string + ']}'
	
	IF OBJECT_ID(N'tempdb..#temp_documentation') IS NOT NULL 
			DROP TABLE #temp_documentation

	CREATE TABLE #temp_documentation
	(
		s_no					INT IDENTITY NOT NULL,
		[schema_name]			SYSNAME COLLATE DATABASE_DEFAULT,
		object_type				NVARCHAR(20) COLLATE DATABASE_DEFAULT NOT NULL,
		[object_name]			SYSNAME COLLATE DATABASE_DEFAULT,
		[name]					SYSNAME COLLATE DATABASE_DEFAULT,
 		[desc]					NVARCHAR(4000) COLLATE DATABASE_DEFAULT
	);

	IF @json_string IS NOT NULL
	BEGIN
		INSERT INTO #temp_documentation ([schema_name],object_type, [object_name],[name], [desc])
		SELECT 		
			ISNULL(JSON_VALUE(C.[value],'$.schema_name'),'') AS [schema_name]
			, JSON_VALUE(C.[value],'$.object_type') AS object_type 
			, JSON_VALUE(C.[value],'$.object_name') AS [object_name]  
			, JSON_VALUE(P.[value],'$.name') AS [name]
			, JSON_VALUE(P.[value],'$.desc') AS [desc]
		FROM
		OpenJSON(@json_string, '$.levels') AS C
		CROSS APPLY OPENJSON(C.value, '$.parameter') AS P 
	END

	ELSE
	BEGIN
		DECLARE @sql VARCHAR(500),@sql1 VARCHAR(500)
		SET @sql =   'INSERT INTO #temp_documentation ([schema_name],object_type, [object_name],[name], [desc])
						SELECT [Schema],[Type],[Object Name], ISNULL([Child Object Name],''''), [Description] FROM ' + @table_name + ' WHERE NULLIF([Description],'''') IS NOT NULL'
		EXEC (@sql)
									
	END

	--Auto resolve schema name from object name if not passed.
	UPDATE rs
	SET [schema_name] = SCHEMA_NAME(ob.schema_id)
	FROM #temp_documentation rs
	INNER JOIN sys.objects ob ON ob.name = rs.[object_name] 
	AND ob.type <> 'SN'
		AND NULLIF(rs.[schema_name],'') IS NULL

	--declare the various local variables that we need

	DECLARE @param_type NVARCHAR(20)
		, @name SYSNAME
		, @desc NVARCHAR(4000)
		, @schema_name	SYSNAME = 'dbo'

	DECLARE @num_of_SP INT 
	SELECT @num_of_SP = MAX(s_no) FROM #temp_documentation
							 
	WHILE @num_of_SP >= 1
	BEGIN
		SELECT @schema_name = rs.[schema_name]
			, @object_type = rs.object_type
			, @object_name = rs.[object_name]
			, @name = rs.[name]
			, @desc = rs.[desc]
		FROM #temp_documentation rs
		WHERE rs.s_no = @num_of_SP
		
		SELECT @param_type = CASE WHEN @object_type IN ('PROCEDURE','FUNCTION') THEN 'parameter' 						  
						 WHEN @object_type IN ('TABLE','VIEW') THEN 'column'
						 END
					
--		/** If the EXCEL data entry contains dbo.sp_name then this code is good.
--		However, if EXCEL data entry contains only sp_name without schema in front then
--		we must append it as follows: IF Object_Id(@schema + '.' + */

		IF OBJECT_ID(@schema_name + '.' + @object_name) IS NOT NULL
		BEGIN	
			IF NULLIF(@name, '') IS NULL	
			SELECT @name = NULL, @param_type = NULL
			
			IF NOT EXISTS (
				SELECT 1
				FROM sys.fn_listextendedproperty(
				N'MS_Description', N'SCHEMA', @schema_name, @object_type,
				@object_name, @param_type, @name )) --if the extended property doesn't exist
			BEGIN			
				EXEC sys.sp_addextendedproperty
					@name = N'MS_Description',
					@value = @desc,
					@level0type = N'SCHEMA',  @level0name = @schema_name,
					@level1type = @object_type, @level1name =  @object_name,
					@level2type = @param_type, @level2name = @name		
			END

			ELSE
			BEGIN	
				EXEC sys.sp_updateextendedproperty
				@name =  N'MS_Description',
				@value = @desc,
				@level0type = N'SCHEMA',  @level0name = @schema_name,
				@level1type = @object_type, @level1name = @object_name,
				@level2type = @param_type, @level2name = @name;
				
			END	
			
		END	
		
		SELECT @num_of_SP = @num_of_SP - 1; 
	END --end of while loop							
END

ELSE IF @flag = 'a'
BEGIN

	DECLARE @type NVARCHAR(100), @child_object_type NVARCHAR(50), @schema_id INT 
			
	SELECT @type = CASE WHEN @object_type = 'PROCEDURE' THEN 'P,PC' 
						WHEN @object_type = 'VIEW' THEN 'V'
						WHEN @object_type = 'FUNCTION' THEN 'FN,FT,FS,IF,TF'
						ELSE 'U' 
					END

	SELECT @schema_id = ob.schema_id FROM sys.objects ob
	INNER JOIN dbo.SplitCommaSeperatedValues(@type) i ON i.item COLLATE Latin1_General_CI_AS = ob.type COLLATE Latin1_General_CI_AS
	WHERE name = @object_name

	SELECT @child_object_type = CASE WHEN @object_type IN ('FUNCTION','PROCEDURE') THEN 'PARAMETER' ELSE 'COLUMN' END
			
	IF @child_object_type = 'PARAMETER'
	BEGIN
		SELECT 1 [level],@object_type [Object Type],ob.name [Name], ep.value [Description],0 seq
		INTO #ext_property_value
		FROM sys.objects ob 
		INNER JOIN dbo.SplitCommaSeperatedValues(@type) i ON i.item COLLATE Latin1_General_CI_AS = ob.type COLLATE Latin1_General_CI_AS
		LEFT JOIN sys.extended_properties ep  ON ep.major_id=ob.OBJECT_ID AND ep.class = 1
		WHERE 1 = 1 
			AND ob.is_ms_shipped = 0 AND ob.schema_id = @schema_id 		
			AND ob.name = @object_name
		
		UNION
		SELECT 2 ,@child_object_type, par.name [Name], ep.value [Description], par.parameter_id  
		FROM sys.objects ob 
		INNER JOIN dbo.SplitCommaSeperatedValues(@type) i ON i.item COLLATE Latin1_General_CI_AS = ob.type COLLATE Latin1_General_CI_AS
		INNER JOIN sys.parameters par  ON par.OBJECT_ID = ob.OBJECT_ID
		LEFT JOIN sys.extended_properties ep  ON ep.major_id=ob.OBJECT_ID 
			AND ep.minor_id=par.parameter_id AND ep.class = 2
		WHERE 1 = 1 AND ob.is_ms_shipped = 0 AND ob.schema_id = @schema_id 
			AND ob.name = @object_name
			AND par.parameter_id > 0 

			SELECT  [Object Type], [Name], CAST([Description] as VARCHAR(MAX)) [Description] FROM #ext_property_value ORDER BY [level],seq
	END

	ELSE
	BEGIN
		SELECT 1 [level],@object_type [Object Type],ob.name [Name], ep.value [Description],0 seq
		INTO #extd_property_value
		FROM sys.objects ob 
		INNER JOIN dbo.SplitCommaSeperatedValues(@type) i ON i.item COLLATE Latin1_General_CI_AS = ob.type COLLATE Latin1_General_CI_AS
		LEFT JOIN sys.extended_properties ep  ON ep.major_id=ob.OBJECT_ID AND ep.class = 1 AND ep.minor_id = 0
		WHERE 1 = 1 
			AND ob.is_ms_shipped = 0 AND ob.schema_id = @schema_id  		
			AND ob.name = @object_name
		UNION
		SELECT 2 ,@child_object_type, col.name [Name], ep.value [Description], col.column_id
		FROM sys.objects ob 
		INNER JOIN dbo.SplitCommaSeperatedValues(@type) i ON i.item COLLATE Latin1_General_CI_AS = ob.type COLLATE Latin1_General_CI_AS
		INNER JOIN sys.columns col  ON col.OBJECT_ID = ob.OBJECT_ID
		LEFT JOIN sys.extended_properties ep  ON ep.major_id=ob.OBJECT_ID 
			AND ep.minor_id=col.column_id AND ep.class = 1
		WHERE 1 = 1 AND ob.is_ms_shipped = 0 AND ob.schema_id = @schema_id 
			AND ob.name = @object_name
			AND col.column_id > 0

		SELECT  [Object Type], [Name], CAST([Description] as VARCHAR(MAX)) [Description] FROM #extd_property_value ORDER BY [level],seq
	END
END
ELSE IF @flag = 's'
BEGIN
	
	IF OBJECT_ID(N'tempdb..#temp1_ext_property_value') IS NOT NULL 
			DROP TABLE #temp1_ext_property_value

	SELECT IIF(ob.type IN ('P','PC'),'Procedure','Function') [object_type]
		, SCHEMA_NAME(ob.schema_id) [schema_name]
        , ob.name [object_name]
        , '' [child_object_name]
        , ep.name [extended_property_name]
        , ep.value [extended_property_value]
		, 0 seq
	INTO #temp1_ext_property_value
	FROM sys.objects ob 
	LEFT JOIN sys.extended_properties ep  ON ep.major_id=ob.OBJECT_ID AND ep.class = 1
		WHERE 1 = 1 AND  ob.type IN ('FN','FT','FS','IF','TF','P','PC')
			AND ob.is_ms_shipped = 0 		
	UNION
	SELECT IIF(ob.type IN ('P','PC'),'Procedure','Function') [object_type]
		, SCHEMA_NAME(ob.schema_id) [schema_name]
		, ob.name [object_name]
		, par.name [child_object_name]
		, ep.name [extended_property_name]
		, ep.value [extended_property_value]
		, par.parameter_id 
	FROM sys.objects ob 
	LEFT JOIN sys.parameters par  ON par.OBJECT_ID = ob.OBJECT_ID
	LEFT JOIN sys.extended_properties ep  ON ep.major_id=ob.OBJECT_ID 
		AND ep.minor_id=par.parameter_id AND ep.class = 2
			WHERE ob.type IN ('FN','FT','FS','IF','TF','P','PC') AND ob.is_ms_shipped = 0 AND ob.schema_id = 1	
	UNION			
	SELECT IIF(ob.type IN ('U'),'Table','View') [object_type]
		, SCHEMA_NAME(ob.schema_id) [schema_name]
		, ob.name [object_name]
		, '' [child_object_name]
		, ep.name [extended_property_name]
		, ep.value [extended_property_value]
		, 0 seq
	FROM sys.objects ob 
	LEFT JOIN sys.extended_properties ep  ON ep.major_id=ob.OBJECT_ID AND ep.class = 2
		WHERE 1 = 1 and ob.type IN ('V','U') AND ob.is_ms_shipped = 0  
	UNION
	SELECT IIF(ob.type IN ('U'),'Table','View') [object_type]
		, SCHEMA_NAME(ob.schema_id) [schema_name]
		, ob.name [object_name]
		, clmns.name [child_object_name]
		, p.name [extended_property_name]
		, p.value [extended_property_value]
		, clmns.column_id child_object_id
	FROM sys.objects AS ob
	INNER JOIN sys.all_columns AS clmns ON clmns.object_id = ob.object_id
	LEFT JOIN sys.extended_properties AS p  ON p.major_id = ob.object_id
		AND p.minor_id = clmns.column_id
		AND p.class = 1
	WHERE ob.type IN ('V','U') 

	SELECT  [object_type] AS [Type]
		, [schema_name] AS [Schema]
		, [object_name] AS [Object Name]
		, [child_object_name] AS [Child Object Name]
		, [extended_property_name] AS [Extended Property Name]
		, [extended_property_value] AS [Extended Property Value]
	FROM #temp1_ext_property_value a1 ORDER BY [object_type], [object_name], seq
			
END

GO
