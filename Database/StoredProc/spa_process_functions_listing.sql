
/*
Author		: Vishwas Khanal
Dated		: 04-Aug-2009
Description : This SP will populate the values for all the list box for all the filters user has chosen. 
*/

IF OBJECT_ID('[dbo].[spa_process_functions_listing]','p') IS NOT NULL
	DROP PROC [dbo].[spa_process_functions_listing]
GO

CREATE PROC [dbo].[spa_process_functions_listing]
	@functionID INT
AS

BEGIN	 
	DECLARE @parent				VARCHAR(500)
		   ,@label				VARCHAR(500)
		   ,@filterId			VARCHAR(500)
		   ,@valueID			INT
		   ,@min				INT
		   ,@max				INT
		   ,@colNameForValue	VARCHAR(500)
		   ,@colNameForId		VARCHAR(500)
		   ,@sql				VARCHAR(MAX)
		   ,@tableName			VARCHAR(500)	
		   ,@previousId			VARCHAR(500)
		   ,@allFilters			VARCHAR(8000)
		   ,@valueDesc			VARCHAR(8000)

	/*
		 Programming Flow : 
		 ==================

		 1. Based on the @functionID, all the descriptions from the process_filters will be shifted to #process_filters.
			#process_filters is used just to avoid cursor.
		 
		 2. The Value Description and the Value Id for all the filters will be populated in #allFilterValues.

		 3. Then the immediate parent has to be found and populated to the #output table. If any new functionality is added that needs
			multiple list box then the insertion in this #output table has to be worked out. 
	*/

	CREATE TABLE #allFilterValues 
	(
		sno				INT IDENTITY(1,1),
		label			VARCHAR(500) COLLATE DATABASE_DEFAULT,
		valueDesc		VARCHAR(800) COLLATE DATABASE_DEFAULT,
		valueID			VARCHAR(100) COLLATE DATABASE_DEFAULT
	)

	CREATE TABLE #output
	(
		sno				INT IDENTITY(1,1),
		label			VARCHAR(500) COLLATE DATABASE_DEFAULT,
		valueID			VARCHAR(500) COLLATE DATABASE_DEFAULT
	)
			
	SELECT @filterId = ''

	SELECT @filterId = @filterId + ',' + pfd.filterID 
		FROM process_filters pf 
		INNER JOIN process_functions_detail pfd
			ON pf.filterID = pfd.filterID
				WHERE userVendorFlag =  'u'
					AND functionID = @functionID

	SELECT @filterId = SUBSTRING(@filterId,2,LEN(@filterId))

	SELECT IDENTITY(INT,1,1) 'sno',item 'filterID',
		tableName 'tableName',colNameForValue 'colNameForValue',colNameForId 'colNameForId'
			 INTO #process_filters 
			  FROM dbo.splitCommaSeperatedValues(@filterId) 
				INNER JOIN process_filters ON item = filterID
					ORDER BY precedence ASC
		
	SELECT @min = MIN(sno),
		   @max = MAX(sno) 
			FROM #process_filters

	WHILE (@min<=@max)
	BEGIN			
		SELECT @filterID = filterID, 
			   @tableName  = tableName,
			   @colNameForValue = colNameForValue,
			   @colNameForId= colNameForId
			FROM #process_filters WHERE sno = @min

		SELECT @sql = 'INSERT INTO #allFilterValues 
					SELECT 	'+ 
						''''+@filterID+''''+ ','+@colNameForValue +
					+ ','+@colNameForId+ ' FROM '+@tableName+' WHERE 1=1 '+
						CASE WHEN @filterID = 'Subsidiary' THEN 'AND hierarchy_level = 2'
							 WHEN @filterID = 'Strategy' THEN 'AND hierarchy_level = 1'
							 WHEN @filterID = 'Book' THEN 'AND hierarchy_level = 0'								
							 WHEN @filterID = 'BackOffice' THEN 'AND type_id = 5651'															 
							 WHEN @filterID = 'MiddleOffice' THEN 'AND type_id = 5651'
							 WHEN @filterID = 'DealIU' THEN 'AND type_id = 5652' 
							 WHEN @filterID = 'DealDeletion' THEN 'AND type_id = 5700'
							 WHEN @filterID = 'ActivityImport' THEN 'AND type_id = 13400'
							 WHEN @filterID = 'AllowanceImport' THEN 'AND type_id = 13500'
							 WHEN @filterID = 'Nymex' THEN 'AND source_system_id = 13'
							 WHEN @filterID = 'Treasury' THEN 'AND source_system_id = 14'
							 WHEN @filterID = 'Platts' THEN 'AND source_system_id = 12'
							 WHEN @filterID = 'ApproveHedgeRel' THEN 'AND type_id = 5800'
							 WHEN @filterID = 'FinalizeHedgeRel' THEN 'AND type_id = 5900'
								 
							 WHEN @filterID = 'HourlyDataImport' THEN 'AND type_id = 13600'
							 WHEN @filterID = 'LimitViolation' THEN 'AND type_id = 6000'
							ELSE ''
						END		
		EXEC (@sql)	
		SELECT @min = @min + 1
	END			
							
	SELECT @min = MIN(sno),
		   @max = MAX(sno) 
			FROM #allFilterValues

	WHILE @min < = @max
	BEGIN
		SELECT @label = label,@valueID = valueID, @valueDesc = valueDesc FROM #allFilterValues WHERE sno = @min

		--SELECT @label = filterDesc FROM #process_filters WHERE filterID = @id

		IF @min = 1 SELECT @parent = @label

		IF @previousId <> @label							
			SELECT @parent = @previousId

			SELECT @previousId = @label		
					
			SELECT @sql = 'insert into #output '


			IF @label = @parent 
				SELECT @sql = @sql + ' SELECT '''+cast(@label AS VARCHAR)+''','''+@valueDesc+'|'+ cast(@valueID  AS VARCHAR)+'|NULL'''
			ELSE IF (@label = 'Strategy' AND @parent = 'Subsidiary') OR (@label = 'Book' AND @parent = 'Strategy')
				SELECT @sql = @sql +  ' SELECT '''+cast(@label AS VARCHAR)+''','''+@valueDesc+'|'+CAST(@valueID AS VARCHAR) +''+'|''+'+ 'CAST(parent_entity_id AS VARCHAR) FROM dbo.portfolio_hierarchy 										
									WHERE entity_id = '+cast(@valueID AS VARCHAR)
			ELSE IF @label = 'Book' AND @parent = 'Subsidiary'
				SELECT @sql = @sql +  ' SELECT '''+cast(@label AS VARCHAR)+''','''+@valueDesc+'|'+CAST(@valueID AS VARCHAR) +''+'|''+'+'dbo.FNAGetSubsidiary ('+cast(@valueID AS VARCHAR)+','+'''i'''+')'				
			ELSE IF @label = 'Contract'	
				SELECT @sql = @sql + ' SELECT '''+cast(@label AS VARCHAR)+''','''+@valueDesc+'|'+CAST(@valueID AS VARCHAR) +'''+''|'''+ '+CAST(sub_id AS VARCHAR) FROM dbo.contract_group WHERE contract_id = '+ cast(@valueID AS VARCHAR)
			ELSE IF @label = 'Counterparty'
				SELECT @sql = @sql + ' SELECT '''+cast(@label AS VARCHAR)+''','''+@valueDesc+'|'+CAST(@valueID AS VARCHAR) +'''+''|'''+ 
				'+ ISNULL(cast(rg.ppa_contract_id as VARCHAR), ''NULL'') FROM dbo.source_counterparty sc 
				JOIN rec_generator rg on rg.ppa_counterparty_id = sc.source_counterparty_id 
				WHERE source_counterparty_id = '+ cast(@valueID AS VARCHAR)
			
		exec spa_print @sql

		EXEC (@sql)

		SELECT @min = @min + 1
		
	END

	SELECT label [Label] ,
		SUBSTRING(
		(
			SELECT (','+valueID)
			FROM #output o2
			WHERE o1.label = o2.label
			ORDER BY
			label,
			valueID
			FOR XML PATH ('')
		),2,1000) [Value] --into #tmp
	FROM #output o1
		GROUP BY label
			ORDER BY MAX(sno)  ASC		
END


