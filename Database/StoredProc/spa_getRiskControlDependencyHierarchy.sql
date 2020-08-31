if object_id('[dbo].[spa_getRiskControlDependencyHierarchy]','p') is not null
DROP PROC [dbo].[spa_getRiskControlDependencyHierarchy]
go
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go



CREATE PROC [dbo].[spa_getRiskControlDependencyHierarchy]
	@flag						VARCHAR(1),				
	@risk_control_id			INT = NULL, 
	@as_of_date					VARCHAR(50) = NULL,
	@as_of_date_to				VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @sql_select VARCHAR(MAX),
			@sql_from VARCHAR(MAX),
			@sql VARCHAR(MAX),
			@sql_select_d VARCHAR(MAX)				

	DECLARE @hierarchy_level INT
	DECLARE @level_depth INT
	DECLARE @count_level_depth INT
	DECLARE @sql_level_depth VARCHAR(MAX)

	DECLARE @count INT
	DECLARE @maxrowno INT 		

	SELECT @count = 1
	DECLARE @perfect_match TABLE
	(
		rowno INT IDENTITY ,
		hierarchy_level INT
	)
	
--	IF @as_of_date IS NULL 
--		SELECT @as_of_date = dbo.FNAGetSQLStandardDate(GETDATE())
		
	IF @as_of_date IS NULL 
		SELECT @as_of_date = dbo.FNAGetSQLStandardDate('1900-01-01')

	IF @as_of_date_to IS NULL 
		SELECT @as_of_date_to = getdate()

--	SELECT @as_of_date 

	INSERT INTO @perfect_match(hierarchy_level)
	SELECT DISTINCT risk_hierarchy_level 
		FROM process_risk_controls_dependency 
			ORDER BY risk_hierarchy_level

	SELECT  @maxrowno = MAX(rowno) FROM @perfect_match

	IF @flag = 's'
	BEGIN

		DECLARE @dependencyVar_s TABLE
		(
			sno INT IDENTITY,
			risk_control_dependency_id INT,
			risk_control_description VARCHAR(8000), 
			have_rights INT, 
			[level] INT,
			risk_control_id_depend_on INT, 
			risk_control_id INT
		)

		SELECT  @sql=''
		SELECT @sql_select_d=''
		
		SELECT @level_depth = risk_hierarchy_level 
			FROM process_risk_controls_dependency 
			WHERE risk_control_id = @risk_control_id 
			AND risk_control_id_depend_on IS NOT NULL 
		
		SELECT 	@level_depth=isnull(@level_depth,0)				
		SELECT @count_level_depth = 0
		SELECT @sql_level_depth = ''

		WHILE @count_level_depth <= @level_depth
		BEGIN
			IF @count_level_depth=0
			BEGIN
				SELECT @sql_level_depth=@sql_level_depth+
				'process_risk_controls_dependency a'+CAST(@count_level_depth AS VARCHAR)
				+' join	process_risk_controls d'+CAST(@count_level_depth AS VARCHAR)
				+ ' on d'+ CAST(@count_level_depth AS VARCHAR) +'.risk_control_id=a'
				+CAST(@count_level_depth AS VARCHAR)+'.risk_control_id' 

			END
			ELSE
			BEGIN
				SELECT @sql_level_depth=@sql_level_depth+
				' join process_risk_controls_dependency a'+CAST(@count_level_depth AS VARCHAR)
				+' on a'+CAST(@count_level_depth AS VARCHAR)+'.risk_control_id_depend_on=a'
				+CAST(@count_level_depth-1 AS VARCHAR)+'.risk_control_dependency_id	join process_risk_controls d'
				+CAST(@count_level_depth AS VARCHAR)+'  on d'+CAST(@count_level_depth AS VARCHAR)
				+'.risk_control_id=a'+CAST(@count_level_depth AS VARCHAR)+'.risk_control_id'
			END
		
			SELECT @count_level_depth=@count_level_depth+1

		END --WHILE @count_level_depth <= @level_depth

		SELECT @sql_level_depth=@sql_level_depth + 
			CASE WHEN @risk_control_id IS NULL THEN '' 
				ELSE ' AND a'+CAST(@level_depth AS VARCHAR) + '.risk_control_id='+CAST(@risk_control_id AS VARCHAR) 
			END

		WHILE (@count <= @maxrowno)
		BEGIN
			SELECT @hierarchy_level =  hierarchy_level 
				FROM @perfect_match  
					WHERE rowno = @count


			SELECT @sql_select=''
			SELECT @sql_from=''
			SELECT @sql_select_d=''

			SELECT 
				@sql_select_d=@sql_select_d+'d'+CAST(a.risk_hierarchy_level AS VARCHAR)+'.risk_control_description + '' | ''+',
				@sql_from=@sql_from+
				CASE WHEN a.risk_hierarchy_level <= @level_depth 
					THEN 
						CASE WHEN  @sql_from='' 
							THEN 
								@sql_level_depth ELSE '' END
					ELSE
						' join process_risk_controls_dependency a'+CAST(a.risk_hierarchy_level AS VARCHAR)
						+' on a'+CAST(a.risk_hierarchy_level AS VARCHAR)+'.risk_control_id_depend_on=a'
						+CAST(a.risk_hierarchy_level-1 AS VARCHAR)+'.risk_control_dependency_id	join process_risk_controls d'
						+CAST(a.risk_hierarchy_level AS VARCHAR)+'  on d'+CAST(a.risk_hierarchy_level AS VARCHAR)
						+'.risk_control_id=a'+CAST(a.risk_hierarchy_level AS VARCHAR)+'.risk_control_id'
				END
			FROM (
			SELECT distinct risk_hierarchy_level 
				FROM process_risk_controls_dependency 
					WHERE risk_hierarchy_level<=@hierarchy_level
				 ) a 

			SELECT @sql_select_d=left(@sql_select_d,len(@sql_select_d)-9)

			SELECT @sql_select_d='a'+CAST(@hierarchy_level AS VARCHAR)+'.risk_control_dependency_id, ' +
			@sql_select_d+', 1 AS have_rights,'+CAST(@hierarchy_level AS VARCHAR)+' level, ' + 'a'+
			CAST(@hierarchy_level AS VARCHAR)+'.risk_control_id_depend_on, ' +
			'a'+CAST(@hierarchy_level AS VARCHAR)+'.risk_control_id'
			

			SELECT @sql_from=@sql_from+' AND a'+CAST(@hierarchy_level AS VARCHAR)+'.risk_hierarchy_level='+CAST(@hierarchy_level AS VARCHAR)					
			
			SELECT @sql=@sql+CASE WHEN @hierarchy_level=0 THEN '' ELSE ' union all ' END +  ' SELECT ' +@sql_select_d + ' FROM '+@sql_from 

			IF @count = @maxrowno
			BEGIN						
				INSERT INTO @dependencyVar_s EXEC(@sql)	
			END							
			
			SELECT @count = @count + 1

		END --WHILE (@count <= @maxrowno)
						
		SELECT  risk_control_dependency_id,
		risk_control_description + '|' entity_name,
		have_rights ,[level],
		risk_control_id_depend_on, risk_control_id 
			FROM @dependencyVar_s 
				WHERE risk_control_description IS NOT NULL 
					ORDER BY risk_control_description
	END -- IF @flag = 's'
-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
	IF @flag='r'
	BEGIN
		DECLARE @dependencyVar_r TABLE
		(
			sno INT IDENTITY,
			risk_control_id int,
			risk_control_dependency_id int,
			risk_control_id_depend_on int,
			risk_control_description VARCHAR(8000), 
			have_rights int,
			[level] int, 
			code VARCHAR(50), 
			[action] VARCHAR(max),
			as_of_date datetime
		)

		SELECT @sql=''
		SELECT @sql_select_d=''
		SELECT @level_depth = 0

		SELECT @level_depth = risk_hierarchy_level 
			FROM process_risk_controls_dependency 
				WHERE risk_control_id = @risk_control_id 
				AND risk_control_id_depend_on IS NOT NULL 

		SELECT @level_depth=isnull(@level_depth,0)		

		SELECT @level_depth = @level_depth
		
		SELECT @count_level_depth = 0

		SELECT @sql_level_depth = ''

		WHILE (@count <= @maxrowno)
		BEGIN
			SELECT @hierarchy_level =  hierarchy_level 
				FROM @perfect_match  
					WHERE rowno = @count

			SELECT @sql_select=''
			SELECT @sql_from=''
			SELECT @sql_select_d=''

			IF @hierarchy_level >= @level_depth
			BEGIN
				SELECT 
				@sql_select_d=@sql_select_d+'d'+CAST(a.risk_hierarchy_level AS VARCHAR)+'.risk_control_description + '' | ''+',				
				@sql_from=@sql_from+
				CASE 
				WHEN a.risk_hierarchy_level < @level_depth 
				THEN 
				''
				WHEN a.risk_hierarchy_level = @level_depth 
				THEN 
				'process_risk_controls_dependency a'+CAST(a.risk_hierarchy_level AS VARCHAR)
				+' join	process_risk_controls d'+CAST(a.risk_hierarchy_level AS VARCHAR)
				+ ' on d'+ CAST(a.risk_hierarchy_level AS VARCHAR) +'.risk_control_id=a'
				+CAST(a.risk_hierarchy_level AS VARCHAR)+'.risk_control_id' 
				+' join process_risk_controls_activities prca' +CAST(a.risk_hierarchy_level AS VARCHAR)+ ' on prca' + CAST(a.risk_hierarchy_level AS VARCHAR)+ '.risk_control_id = a'+CAST(a.risk_hierarchy_level AS VARCHAR)+'.risk_control_id 
				AND (prca' +CAST(a.risk_hierarchy_level AS VARCHAR)+  '.as_of_date between dbo.FNAGetSQLStandardDate(''' + @as_of_date + ''')
				AND dbo.FNAGetSQLStandardDate(''' + @as_of_date_to + '''))
				join static_data_value sdv'+CAST(a.risk_hierarchy_level AS VARCHAR)+' on sdv'+CAST(a.risk_hierarchy_level AS VARCHAR)+'.value_id = prca'+CAST(a.risk_hierarchy_level AS VARCHAR)+'.control_status
				join process_risk_controls pc'+CAST(a.risk_hierarchy_level AS VARCHAR)+' on prca'+CAST(a.risk_hierarchy_level AS VARCHAR)+'.risk_control_id = pc'+CAST(a.risk_hierarchy_level AS VARCHAR)+'.risk_control_id '+ 
				CASE 
					WHEN @risk_control_id IS NULL 
						THEN '' ELSE ' AND a' + CAST(a.risk_hierarchy_level AS VARCHAR) + '.risk_control_id='+CAST(@risk_control_id AS VARCHAR) 
				END
				ELSE
				' join process_risk_controls_dependency a'+CAST(a.risk_hierarchy_level AS VARCHAR)
				+' on a'+CAST(a.risk_hierarchy_level AS VARCHAR)+'.risk_control_id_depend_on=a'
				+CAST(a.risk_hierarchy_level-1 AS VARCHAR)+'.risk_control_dependency_id	join process_risk_controls d'
				+CAST(a.risk_hierarchy_level AS VARCHAR)+'  on d'+CAST(a.risk_hierarchy_level AS VARCHAR)
				+'.risk_control_id=a'+CAST(a.risk_hierarchy_level AS VARCHAR)+'.risk_control_id'
				+' join process_risk_controls_activities prca' +CAST(a.risk_hierarchy_level AS VARCHAR)+ ' on prca' + +CAST(a.risk_hierarchy_level AS VARCHAR)+ '.risk_control_id = a'+CAST(a.risk_hierarchy_level AS VARCHAR)+'.risk_control_id 
				AND (prca' +CAST(a.risk_hierarchy_level AS VARCHAR)+  '.as_of_date between dbo.FNAGetSQLStandardDate(''' + @as_of_date + ''')
				AND dbo.FNAGetSQLStandardDate(''' + @as_of_date_to + '''))
				join static_data_value sdv'+CAST(a.risk_hierarchy_level AS VARCHAR)+' on sdv'+CAST(a.risk_hierarchy_level AS VARCHAR)+'.value_id = prca'+CAST(a.risk_hierarchy_level AS VARCHAR)+'.control_status
				join process_risk_controls pc'+CAST(a.risk_hierarchy_level AS VARCHAR)+' on prca'+CAST(a.risk_hierarchy_level AS VARCHAR)+'.risk_control_id = pc'+CAST(a.risk_hierarchy_level AS VARCHAR)+'.risk_control_id '
				END
				FROM (
						SELECT distinct risk_hierarchy_level 
							FROM process_risk_controls_dependency 
								WHERE risk_hierarchy_level<=@hierarchy_level 
								AND risk_hierarchy_level >= @level_depth
					) a 

				SELECT @sql_select_d=left(@sql_select_d,len(@sql_select_d)-9)

				SELECT @sql_select_d='a'+CAST(@hierarchy_level AS VARCHAR)+'.risk_control_id,'+'a'+CAST(@hierarchy_level AS VARCHAR)
				+'.risk_control_dependency_id,'+'a'+CAST(@hierarchy_level AS VARCHAR)+'.risk_control_id_depend_on,'
				+@sql_select_d+', 1 AS have_rights,'+CAST(@hierarchy_level AS VARCHAR)+' level, sdv'+CAST(@hierarchy_level AS VARCHAR)+'.code, '
				
				+ ' dbo.FNAComplianceActivityStatus(prca' + CAST(@hierarchy_level AS VARCHAR) + '.risk_control_activity_id,''y'',''' 
+ CAST(@as_of_date as varchar) + ''', ''' + ISNULL(cast(@as_of_date_to as varchar), '''') + ''', ''' + CAST(@hierarchy_level AS VARCHAR) + ''') AS [Action], '
				
				+ ' prca'+CAST(@hierarchy_level AS VARCHAR)+'.as_of_date AS as_of_date'

				SELECT @sql_from=@sql_from+' AND a'+CAST(@hierarchy_level AS VARCHAR)+'.risk_hierarchy_level='+CAST(@hierarchy_level AS VARCHAR)
				SELECT @sql=@sql+CASE WHEN @hierarchy_level = @level_depth THEN '' ELSE ' union all ' END +  ' SELECT ' +@sql_select_d + ' FROM '+@sql_from 
																			
			END -- IF @hierarchy_level >= @level_depth

			IF @count = @maxrowno
			BEGIN							
				INSERT INTO @dependencyVar_r EXEC(@sql)	
			END																				
--
			SELECT @count = @count + 1	
		END	--WHILE (@count <= @maxrowno)

		EXEC spa_print @sql 
		
		SELECT a.risk_control_dependency_id,
		dbo.FNAComplianceHyperlink('f',10101125,a.risk_control_description + '|','333',CAST(a.risk_control_id AS VARCHAR),1,default,default,@as_of_date,@as_of_date_to) entity_name, a.have_rights, 
		a.level -  CAST(@level_depth AS VARCHAR) level  ,a.risk_control_id_depend_on, 
		dbo.FNAComplianceHyperlink('b',367,a.code, CAST(risk_control_id AS VARCHAR),dbo.FNADateFormat(a.as_of_date),default,default,default,default,default) AS [Status], 
		a.[Action] AS [action]
		FROM @dependencyVar_r a WHERE risk_control_description IS NOT NULL order by risk_control_description
	
	END --IF @flag='r'

-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------

	IF @flag = 'i'		-- for instance creation
	BEGIN
		DECLARE @dependencyVar_i TABLE 
		(
			sno INT IDENTITY,			
			risk_control_id INT,
			risk_control_dependency_id INT,
			risk_control_id_depend_on INT, 
			risk_control_description VARCHAR(8000), 
			have_rights INT, 
			[level] INT
		)

		SELECT @sql=''

		SELECT @sql_select_d=''
		
		SELECT @level_depth = risk_hierarchy_level 
			FROM process_risk_controls_dependency 
				WHERE risk_control_id = @risk_control_id 
				and risk_control_id_depend_on is not null 
		
		SELECT 	@level_depth=isnull(@level_depth,0)		
		
		SELECT @count_level_depth = 0
		
		SELECT @sql_level_depth = ''

		WHILE @count_level_depth <= @level_depth
		BEGIN
			IF @count_level_depth=0
			BEGIN
				SELECT @sql_level_depth=@sql_level_depth+
				'process_risk_controls_dependency a'+cast(@count_level_depth AS VARCHAR)
				+' join	process_risk_controls d'+cast(@count_level_depth AS VARCHAR)
				+ ' on d'+ cast(@count_level_depth AS VARCHAR) +'.risk_control_id=a'
				+cast(@count_level_depth AS VARCHAR)+'.risk_control_id' 
			
			END
			ELSE
			BEGIN
				SELECT @sql_level_depth=@sql_level_depth+
				' join process_risk_controls_dependency a'+cast(@count_level_depth AS VARCHAR)
				+' on a'+cast(@count_level_depth AS VARCHAR)+'.risk_control_id_depend_on=a'
				+cast(@count_level_depth-1 AS VARCHAR)+'.risk_control_dependency_id	join process_risk_controls d'
				+cast(@count_level_depth AS VARCHAR)+'  on d'+cast(@count_level_depth AS VARCHAR)
				+'.risk_control_id=a'+cast(@count_level_depth AS VARCHAR)+'.risk_control_id'
			END

			SELECT @count_level_depth=@count_level_depth+1

		END --WHILE @count_level_depth <= @level_depth

		SELECT @sql_level_depth=@sql_level_depth + CASE WHEN @risk_control_id is null THEN '' ELSE ' and a'+cast(@level_depth AS VARCHAR) + '.risk_control_id='+cast(@risk_control_id AS VARCHAR) END				

		WHILE (@count <= @maxrowno)
		BEGIN
			SELECT @hierarchy_level =  hierarchy_level 
				FROM @perfect_match  
					WHERE rowno = @count
				
			SELECT @sql_select=''
			SELECT @sql_from=''
			SELECT @sql_select_d=''					
			SELECT 
			@sql_select_d=@sql_select_d+'d'+cast(a.risk_hierarchy_level AS VARCHAR)+'.risk_control_description + '' | ''+',

			@sql_from=@sql_from+
			CASE WHEN a.risk_hierarchy_level <= @level_depth 
			THEN 
				CASE WHEN  @sql_from='' THEN @sql_level_depth ELSE '' END
			ELSE
					' join process_risk_controls_dependency a'+cast(a.risk_hierarchy_level AS VARCHAR)
					+' on a'+cast(a.risk_hierarchy_level AS VARCHAR)+'.risk_control_id_depend_on=a'
					+cast(a.risk_hierarchy_level-1 AS VARCHAR)+'.risk_control_dependency_id	join process_risk_controls d'
					+cast(a.risk_hierarchy_level AS VARCHAR)+'  on d'+cast(a.risk_hierarchy_level AS VARCHAR)
					+'.risk_control_id=a'+cast(a.risk_hierarchy_level AS VARCHAR)+'.risk_control_id'
			END
			FROM (
				SELECT distinct risk_hierarchy_level FROM process_risk_controls_dependency WHERE risk_hierarchy_level<=@hierarchy_level) a 

			SELECT @sql_select_d=left(@sql_select_d,len(@sql_select_d)-9)

			SELECT @sql_select_d='a'+cast(@hierarchy_level AS VARCHAR)+'.risk_control_id,'+'a'+cast(@hierarchy_level AS VARCHAR)+'.risk_control_dependency_id,'+'a'+cast(@hierarchy_level AS VARCHAR)+'.risk_control_id_depend_on,'+@sql_select_d+', 1 AS have_rights,'+cast(@hierarchy_level AS VARCHAR)+' level'

			SELECT @sql_from=@sql_from+' and a'+cast(@hierarchy_level AS VARCHAR)+'.risk_hierarchy_level='+cast(@hierarchy_level AS VARCHAR)

			SELECT @sql=@sql+CASE WHEN @hierarchy_level=0 THEN '' ELSE ' union all ' END +  ' SELECT ' +@sql_select_d + ' FROM '+@sql_from 

			IF @count = @maxrowno
			BEGIN						
				INSERT INTO @dependencyVar_i EXEC(@sql)

				INSERT INTO #temp_risk_control_dependency
					SELECT a.risk_control_id FROM @dependencyVar_i a 
						WHERE risk_control_description IS NOT NULL 
							ORDER BY risk_control_description
			END							

			SELECT @count = @count + 1

		END	-- WHILE (@count <= @maxrowno)
		-- SELECT a.risk_control_id FROM @dependencyVar_i a WHERE risk_control_description is not null order by risk_control_description
	END --IF @flag = 'i'
END -- End of Procedure


