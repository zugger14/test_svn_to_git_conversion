IF OBJECT_ID(N'[dbo].[spa_parse_xml_file]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_parse_xml_file]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
/**
	Parse XML and stored values to process table.
	
	Parameters:
		@flag				:	Operation flag that decides the action to be performed.
		@xml_file_full_path	:	Full path of XML file.
		@xml_script			:	XML script containing data.
		@process_table_name	:	Process table name to store xml data. It is necessary that this table is not created.	
*/

CREATE PROCEDURE [dbo].[spa_parse_xml_file]
    @flag CHAR(1),
    @xml_file_full_path VARCHAR(2000) = NULL,
    @xml_script XML = NULL,
    @process_table_name VARCHAR(500) = NULL    
AS
SET NOCOUNT ON

/** Debug Section
DECLARE @flag CHAR(1),
    @xml_file_full_path VARCHAR(2000) = NULL,
    @xml_script XML = NULL,
    @process_table_name VARCHAR(500) = NULL 

-- Sample Use = EXEC spa_parse_xml_file 'b', 'D:\FARRMS\GLEN_to_ACES_sample.XML', NULL
-- SELECT * FROM adiha_process.dbo.xml_data_table_sa_C99DCD4C_2E9C_4317_BDB3_EA9DF8F1C7FD
--*/

IF OBJECT_ID('tempdb..#temp_data_from_cte') IS NOT NULL
    DROP TABLE #temp_data_from_cte

IF OBJECT_ID('tempdb..#nodes') IS NOT NULL
    DROP TABLE #nodes

IF OBJECT_ID('tempdb..#temp_xml') IS NOT NULL
    DROP TABLE #temp_xml
 
DECLARE @xml XML
DECLARE @xml_file  VARCHAR(100)
DECLARE @root NVARCHAR(500)
DECLARE @columns NVARCHAR(MAX)
DECLARE @cs_query_node NVARCHAR(MAX)
DECLARE @final_query NVARCHAR(MAX)
DECLARE @user_name VARCHAR(100)
DECLARE @xml_process_table VARCHAR(500)
DECLARE @process_id VARCHAR(200)
DECLARE @cols AS Nvarchar(max), @query AS Nvarchar(max), @cols_select NVARCHAR(MAX)

IF @process_table_name IS NULL
BEGIN
	SET @process_id = dbo.FNAGetNewID()
	SET @user_name = dbo.FNADBUser() 
	SET @xml_process_table = dbo.FNAProcessTableName('xml_data_table', @user_name, @process_id)
END
ELSE
BEGIN
	SET @xml_process_table = @process_table_name
END

IF OBJECT_ID(@xml_process_table) IS NOT NULL
BEGIN
	EXEC('DROP TABLE ' + @xml_process_table)
END

IF @xml_file_full_path IS NOT NULL
BEGIN
	CREATE TABLE #temp_linear_xml (bulk_culumn XML)
	EXEC('INSERT INTO #temp_linear_xml
	      SELECT BulkColumn
	      FROM   OPENROWSET(BULK ''' + @xml_file_full_path + ''', SINGLE_CLOB) AS x'
	);
	
	SELECT @xml = bulk_culumn FROM #temp_linear_xml	
END 
ELSE IF @xml_script IS NOT NULL
BEGIN
	SELECT @xml = @xml_script
END
ELSE
BEGIN
	EXEC spa_ErrorHandler 0, 
		'Import/Export FX', 
		'spa_ixp_rules', 
		'Error', 
	    'XML file or XML statement should passed.', 
	    ''
	RETURN
END
   
IF EXISTS (SELECT TOP 1
      x.y.value('local-name(.)', 'VARCHAR(50)') AS ColName,
      x.y.value('.', 'VARCHAR(50)') AS ColValue
    FROM @xml.nodes('/Root/PSRecordset/*') x (y))

  BEGIN
  
	SELECT  DISTINCT
		x.y.value('local-name(.)', 'VARCHAR(50)') AS ColName 
	INTO 
		#temp_colname
    FROM 
		@xml.nodes('/Root/PSRecordset/*') x (y)

	SELECT
      @cols = STUFF((SELECT DISTINCT ',' + ColName+' VARCHAR(100) '+''''+ColName+''''
    FROM 
		#temp_colname
    ORDER BY ',' + ColName+' VARCHAR(100) '+''''+ColName+''''
    FOR xml PATH (''), TYPE).value('.', 'VARCHAR(MAX)'), 1, 1, '')


	
	SET @final_query=' 
	DECLARE @idoc                   INT
	DECLARE @doc                    VARCHAR(1000)

	EXEC sp_xml_preparedocument @idoc OUTPUT, '''+REPLACE(CAST(@xml AS VARCHAR(MAX)),'''','')+''';

	SELECT * INTO ' + @xml_process_table + '
	FROM   OPENXML (@idoc, ''/Root/PSRecordset'',2)
	WITH ('+@cols+') 
	EXEC sp_xml_removedocument @idoc '

	EXEC(@final_query)


  END
  ELSE IF EXISTS (SELECT TOP 1
	  b.value('local-name(.)','VARCHAR(50)')

    FROM @xml.nodes('/GridXML/GridRow') x (y)
	CROSS APPLY y.nodes('@*') a(b)
	)

  BEGIN
	IF OBJECT_ID('tempdb..#temp_colname2') IS NOT NULL
		DROP TABLE #temp_colname2

	SELECT DISTINCT b.value('local-name(.)','VARCHAR(100)') AS ColName
	INTO #temp_colname2
    FROM @xml.nodes('/GridXML/GridRow') x (y)
	CROSS APPLY y.nodes('@*') a(b)

	SELECT @cols = STUFF((SELECT DISTINCT ',' + QUOTENAME(ColName) +' NVARCHAR(MAX) '
    FROM #temp_colname2
    ORDER BY ',' + QUOTENAME(ColName) + ' NVARCHAR(MAX) '
    FOR XML PATH (''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '')
	
	SET @final_query=' 
	DECLARE @idoc                   INT
	DECLARE @doc                    NVARCHAR(1000)

	EXEC sp_xml_preparedocument @idoc OUTPUT, N'''+REPLACE(CAST(@xml AS NVARCHAR(MAX)),'''','')+''';

	SELECT * INTO ' + @xml_process_table + '
	FROM   OPENXML (@idoc, ''/GridXML/GridRow'',0)
	WITH ('+@cols+') 
	EXEC sp_xml_removedocument @idoc '

	-- PRINT('SELECT ' + @cols_select + ' INTO ' + @xml_process_table + '')
	EXEC(@final_query)
  END
  ELSE
  BEGIN
	;WITH cte_xml AS ( 
		SELECT 
		1 AS lvl, 
		x.value('local-name(.)','NVARCHAR(MAX)') AS Name, 
		CAST(NULL AS NVARCHAR(MAX)) AS ParentName,
		CAST(N'Element' AS NVARCHAR(20)) AS NodeType, 
		x.value('local-name(.)','NVARCHAR(MAX)') AS FullPath ,
		x.query('.') AS this,        
		x.query('*') AS t,
		CAST(CAST(1 AS VARBINARY(4)) AS VARBINARY(MAX)) AS Sort, 
        CAST(1 AS INT) AS ID,
		x.value('text()[1]','NVARCHAR(MAX)') AS Value    
	FROM @xml.nodes('/*') a(x) 
    
	UNION ALL
		    
	SELECT 
		p.lvl + 1 AS lvl, 
		c.value('local-name(.)','NVARCHAR(MAX)') AS Name, 
		CAST(p.Name AS NVARCHAR(MAX)) AS ParentName,
		CAST(N'Element' AS NVARCHAR(20)) AS NodeType, 
		CAST( 
			p.FullPath 
			+ N'/' 
			+ c.value('local-name(.)','NVARCHAR(MAX)') AS NVARCHAR(MAX) 
		) AS FullPath, 
		c.query('.') AS this,        
		c.query('*') AS t,
		CAST( 
            p.Sort 
            + CAST( (lvl + 1) * 1024 
            + (ROW_NUMBER() OVER(ORDER BY (SELECT 1)) * 2) AS VARBINARY(4) 
        ) AS VARBINARY(MAX) ) AS Sort, 
        CAST( 
            (lvl + 1) * 1024 
            + (ROW_NUMBER() OVER(ORDER BY (SELECT 1)) * 2) AS INT 
        ),
		CAST( c.value('text()[1]','NVARCHAR(MAX)') AS NVARCHAR(MAX) ) AS Value 
	FROM cte_xml p 
	CROSS APPLY p.t.nodes('*') b(c)        
), cte2 AS (
	SELECT  lvl,
			NAME,
			parentName,
			NodeType,
			FullPath,
			this,
			t,
			Sort, 
			ID,
			value 
	FROM cte_xml
	UNION ALL  
    SELECT 
        p.lvl, 
        x.value('local-name(.)','NVARCHAR(MAX)'), 
        p.Name parentName,
        CAST(N'Attribute' AS NVARCHAR(20)) NodeType, 
        p.FullPath + N'/@' + x.value('local-name(.)','NVARCHAR(MAX)') FullPath, 
		--the initial query returns this (column) with data type xml, but this query returns NVARCHAR. Joining them via UNION implicitly converts NVARCHAR to XML
		--Any xmlencoded value (e.g. &amp;) will throw issue in such implicit conversion. So calling dbo.FNAEncodeXML will encode such special characters.
        dbo.FNAEncodeXML(x.value('.','NVARCHAR(MAX)')) this,
        NULL t,
        p.Sort, 
        p.ID + 1,
		 x.value('.','NVARCHAR(MAX)')
    FROM cte_xml p 
    CROSS APPLY this.nodes('/*/@*') a(x)   
)


SELECT ROW_NUMBER() OVER(ORDER BY Sort, ID) AS ID, lvl, NAME, parentName, NodeType, FullPath, this, value t, Sort INTO #temp_data_from_cte from cte2
SELECT @root = [name] FROM  #temp_data_from_cte WHERE  lvl = 1

CREATE TABLE #nodes (
	[node_id]         INT IDENTITY,
	node_name         VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	parent_node_name  VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	lvl               INT,
	idx               CHAR(1) COLLATE DATABASE_DEFAULT 
)
IF OBJECT_ID('tempdb..#attributes') IS NOT NULL
    DROP TABLE #attributes

CREATE TABLE #attributes (
	[attribute_id]  INT IDENTITY,
	attribute_name  VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	node_name       VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	lvl             INT,
	idx             CHAR(1) COLLATE DATABASE_DEFAULT,
	order_id		INT
)

INSERT INTO #nodes(node_name, parent_node_name, lvl)
SELECT [name], parentname, MIN(lvl) lvl
FROM #temp_data_from_cte tmp 
WHERE parentname IS NOT NULL AND [name] IN (SELECT parentname FROM #temp_data_from_cte) AND tmp.NodeType = 'Element'
GROUP BY [name], parentname ORDER BY lvl

INSERT INTO #attributes(attribute_name, node_name, lvl, order_id)
SELECT [name], parentname, MIN(lvl) lvl, MIN(id) id
FROM #temp_data_from_cte tmp 
WHERE parentname IS NOT NULL AND parentname <> @root AND tmp.NodeType = 'Attribute'
GROUP BY [name], parentname ORDER BY lvl, id

UPDATE #nodes
SET idx = CASE [node_id]
              WHEN 1 THEN 'a'
              WHEN 2 THEN 'b'
              WHEN 3 THEN 'c'
              WHEN 4 THEN 'd'
              WHEN 5 THEN 'e'
              WHEN 6 THEN 'f'
              WHEN 7 THEN 'g'
              WHEN 8 THEN 'h'
              WHEN 9 THEN 'i'
              WHEN 10 THEN 'j'
              WHEN 11 THEN 'k'
          END 

IF OBJECT_ID('tempdb..#temp_columns') IS NOT NULL
	DROP TABLE #temp_columns

SELECT DISTINCT ',' + n.idx+'.value(' + CASE WHEN a.attribute_id IS NOT NULL THEN '''@'+[name]+'''' ELSE ''''+[name]+'[1]''' END + ' ,''NVARCHAR(MAX)'') ['+[name] +']' [col_name], [name]
INTO #temp_columns
FROM #temp_data_from_cte tmp 
INNER JOIN #nodes n ON tmp.parentname = n.node_name	
OUTER APPLY (SELECT * FROM #attributes a WHERE a.node_name = n.node_name) a				
WHERE parentname <> @root AND tmp.parentname IS NOT NULL
ORDER BY ',' + n.idx+'.value(' + CASE WHEN a.attribute_id IS NOT NULL THEN '''@'+[name]+'''' ELSE ''''+[name]+'[1]''' END + ' ,''NVARCHAR(MAX)'') ['+[name] +']' 

-- to preserve the order of xml attribute			
SELECT  @columns = 
			STUFF(( SELECT REPLACE([col_name], '', '')
			FROM #temp_columns tmp 
			INNER JOIN #attributes a ON a.attribute_name = tmp.[name]	
			ORDER BY a.order_id			
			FOR XML PATH('')
			), 1, 1, '') + ''			

/* Old version was discarded for following reasons
*	a. CASE WHEN a.attribute_id IS NOT NULL THEN n2.idx ELSE n2.idx END in select clause is redundant as both case is returning same result.
*	b. Similar statement is removed from ORDER BY clause.
*	c. OUTER APPLY with #attributes not required due to #a
*	d. The code was not working when GridDelete has multiple attributes as it generated duplicate CROSS APPLY clause for it.
*		Attribute grid_label was added for delete validation logic. * 
 */ 
--SELECT  @cs_query_node = 
--			STUFF((SELECT CASE 
--			                   WHEN n1.[node_id] = 1 THEN ' CROSS APPLY t.xmldata.nodes(''' + @root + '/' + n1.node_name + ''') '
--			                   ELSE ' CROSS APPLY ' + n1.parent_node_name + '.' + CASE WHEN a.attribute_id IS NOT NULL THEN n2.idx ELSE n2.idx END + '.nodes(''' + n1.node_name + ''') '
--			              END
--					+ n1.node_name + '(' + n1.idx + ')' 
--			FROM #nodes n1 
--			LEFT JOIN #nodes n2 ON n1.[node_id] = n2.[node_id]+1
--			OUTER APPLY (SELECT * FROM #attributes a WHERE a.node_name = n2.node_name) a	
--			LEFT JOIN #nodes n3 ON n3.[node_id] = 1
--			ORDER BY n1.idx, 
--			CASE WHEN n1.[node_id] = 1 THEN ' CROSS APPLY t.xmldata.nodes(''' + @root + '/' + n1.node_name + ''') '
--				 ELSE ' CROSS APPLY ' + n1.parent_node_name + '.' + CASE WHEN a.attribute_id IS NOT NULL THEN n3.idx ELSE n2.idx END + '.nodes(''' + n1.node_name + ''') '
--            END + n1.node_name + '(' + n1.idx + ')'   
--            FOR XML PATH('')), 1, 1, '') + ''
            
SELECT  @cs_query_node = 
			STUFF((SELECT CASE 
			                   WHEN n1.[node_id] = 1 THEN ' CROSS APPLY t.xmldata.nodes(''' + @root + '/' + n1.node_name + ''') '
			                   ELSE ' CROSS APPLY ' + n1.parent_node_name + '.' + n2.idx + '.nodes(''' + n1.node_name + ''') '
			              END
					+ n1.node_name + '(' + n1.idx + ')' 
			FROM #nodes n1 
			LEFT JOIN #nodes n2 ON n1.[node_id] = n2.[node_id] + 1
			LEFT JOIN #nodes n3 ON n3.[node_id] = 1
			ORDER BY n1.idx
			FOR XML PATH('')), 1, 1, '') + ''

/* Debugging statement
--PRINT @cs_query_node			

SELECT 'n1', n1.*, 'n2', n2.*, 'n3', n3.* 
FROM #nodes n1 
LEFT JOIN #nodes n2 ON n1.[node_id] = n2.[node_id]+1
LEFT JOIN #nodes n3 ON n3.[node_id] = 1
ORDER BY n1.idx
*/

CREATE TABLE #temp_xml (XMLDATA XML) 	
INSERT INTO #temp_xml SELECT @xml	



IF @flag = 'b' -- used for whole data importing
BEGIN
	SELECT @final_query = 'SELECT 
						  ' + @columns + ' 
						  INTO ' + @xml_process_table + '
	                      FROM #temp_xml T ' 
					 +	@cs_query_node
	--print @final_query
	EXEC(@final_query)	
END
IF @flag = 'c' -- select top 1 values for mapping
BEGIN
	SELECT @final_query = 'SELECT TOP 1
						  ' + @columns + '
						  INTO ' + @xml_process_table + '
	                      FROM   #temp_xml T ' + @cs_query_node
	EXEC(@final_query)	
END

END
-- returns new process name if it is not passed
IF @process_table_name IS NULL 
	SELECT @xml_process_table [process_table]