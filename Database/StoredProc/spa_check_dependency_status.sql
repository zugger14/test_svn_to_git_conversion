
/****** Object:  StoredProcedure [dbo].[spa_check_dependency_status]    Script Date: 04/14/2009 21:23:11 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_check_dependency_status]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_check_dependency_status]
/****** Object:  StoredProcedure [dbo].[spa_check_dependency_status]    Script Date: 04/14/2009 21:23:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec spa_check_dependency_status 1226,null

CREATE PROCEDURE [dbo].[spa_check_dependency_status]
	@risk_control_id VARCHAR(100) = NULL,
	@risk_hierarchy_level VARCHAR(100) = NULL,
	@temp_table_name VARCHAR(100) = NULL
AS
SET NOCOUNT ON;
BEGIN
	SET NOCOUNT ON
	DECLARE @pending_activity int
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

	SET @risk_hierarchy_level = NULLIF(@risk_hierarchy_level, 'null')

	IF @risk_hierarchy_level IS NULL
	BEGIN
		SELECT @count = 1
		DECLARE @perfect_match TABLE (
			rowno INT IDENTITY ,
			hierarchy_level INT
		)

		INSERT INTO @perfect_match(hierarchy_level)
		SELECT DISTINCT risk_hierarchy_level 
			FROM process_risk_controls_dependency 
				ORDER BY risk_hierarchy_level

		SELECT  @maxrowno = MAX(rowno) FROM @perfect_match
		
		create table #t (
				risk_control_id int,
				control_status varchar(10) COLLATE DATABASE_DEFAULT,
				risk_control_id_depend_on int NULL
			)


		BEGIN

			DECLARE @dependencyVar_s TABLE (
				sno INT IDENTITY,
				risk_control_dependency_id INT,
				risk_control_description VARCHAR(8000), 
				have_rights INT, 
				[level] INT,
				risk_control_id_depend_on INT, 
				risk_control_id INT,
				control_status INT
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
					SELECT @sql_level_depth = @sql_level_depth +
					       'process_risk_controls_dependency a' + CAST(@count_level_depth AS VARCHAR)
					       + ' join	process_risk_controls d' + CAST(@count_level_depth AS VARCHAR)
					       + ' on d' + CAST(@count_level_depth AS VARCHAR) + '.risk_control_id=a'
					       + CAST(@count_level_depth AS VARCHAR) + '.risk_control_id'
					       + ' join process_risk_controls_activities prca' + CAST(@count_level_depth AS VARCHAR) +
					       + ' on d' + CAST(@count_level_depth AS VARCHAR) + '.risk_control_id=prca'
					       + CAST(@count_level_depth AS VARCHAR) + '.risk_control_id' 
				END
				ELSE
				BEGIN
					SELECT @sql_level_depth = @sql_level_depth + ' join process_risk_controls_dependency a' + CAST(@count_level_depth AS VARCHAR)
					       + ' on a' + CAST(@count_level_depth AS VARCHAR) + '.risk_control_id_depend_on=a'
					       + CAST(@count_level_depth -1 AS VARCHAR) + '.risk_control_dependency_id	join process_risk_controls d'
					       + CAST(@count_level_depth AS VARCHAR) + '  on d' 
					       + CAST(@count_level_depth AS VARCHAR)
					       + '.risk_control_id=a' + CAST(@count_level_depth AS VARCHAR)
					       + '.risk_control_id'
					       + ' join process_risk_controls_activities prca' 
					       + CAST(@count_level_depth AS VARCHAR) +
					       + ' on d' + CAST(@count_level_depth AS VARCHAR) + '.risk_control_id=prca'
					       + CAST(@count_level_depth AS VARCHAR) + '.risk_control_id' 					
				END
			
				SELECT @count_level_depth=@count_level_depth+1
			END

			SELECT @sql_level_depth = @sql_level_depth +
			       CASE 
			            WHEN @risk_control_id IS NULL THEN ''
			            ELSE ' AND a' + CAST(@level_depth AS VARCHAR) + '.risk_control_id=' + CAST(@risk_control_id AS VARCHAR)
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
							+' join process_risk_controls_activities prca'+CAST(a.risk_hierarchy_level AS VARCHAR)+
							+ ' on d'+ CAST(a.risk_hierarchy_level AS VARCHAR) +'.risk_control_id=prca'
							+CAST(a.risk_hierarchy_level AS VARCHAR)+'.risk_control_id' 
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
				'a'+CAST(@hierarchy_level AS VARCHAR)+'.risk_control_id, '+
				'prca'+CAST(@hierarchy_level AS VARCHAR)+'.control_status'
				

				SELECT @sql_from=@sql_from+' AND a'+CAST(@hierarchy_level AS VARCHAR)+'.risk_hierarchy_level='+CAST(@hierarchy_level AS VARCHAR)					
				
				SELECT @sql=@sql+CASE WHEN @hierarchy_level=0 THEN '' ELSE ' union all ' END +  ' SELECT ' +@sql_select_d + ' FROM '+@sql_from 

				--print(@sql)
				IF @count = @maxrowno
				BEGIN						
					INSERT INTO @dependencyVar_s EXEC(@sql)	
				END							
				
				SELECT @count = @count + 1

			END --WHILE (@count <= @maxrowno)
							
--			SELECT  risk_control_dependency_id,
--			risk_control_description + '|' entity_name,
--			have_rights ,[level],
--			risk_control_id_depend_on, risk_control_id,control_status 
--				FROM @dependencyVar_s 
--					WHERE risk_control_description IS NOT NULL 
--						ORDER BY risk_control_description


--select * from @dependencyVar_s 

			INSERT INTO #t
				SELECT risk_control_id,control_status,risk_control_id_depend_on
				FROM @dependencyVar_s 
					WHERE risk_control_description IS NOT NULL 
					AND control_status NOT IN (728,729)
					and risk_control_id <>@risk_control_id
				 	ORDER BY risk_control_description
			
--			select * from #t 
			

			select @pending_activity = count(control_status) from #t 
			
		END
END
	ELSE
		BEGIN


			SELECT  @pending_activity = count(prca.control_status) 
			  FROM  process_risk_controls_dependency prcd1
				JOIN process_risk_controls_dependency prcd2 ON prcd2.risk_control_id_depend_on = prcd1.risk_control_dependency_id
				JOIN process_risk_controls_activities prca ON prca.risk_control_id = prcd2.risk_control_id
			WHERE 
				prcd1.risk_control_id =  @risk_control_id 
			AND prcd1.risk_hierarchy_level = @risk_hierarchy_level 
			AND prca.control_status NOT IN (728,729)
		END
	
	if @pending_activity > 0
		BEGIN
				IF @temp_table_name IS NOT NULL
					EXEC('SELECT '+@risk_control_id+' AS risk_control_id,''Error'' as [Status],''Dependent activity needs to be completed.'' as [Description]
					INTO '+@temp_table_name)
				ELSE
				Exec spa_ErrorHandler 1, " ", 
					 "spa_update_process", "DB Error", 
					 "Dependency exists for the activity. Failed to complete.",1
		END
	ELSE
		BEGIN
			IF @temp_table_name IS NOT NULL
					EXEC('SELECT '+@risk_control_id +'AS risk_control_id,''Success'' as [Status],''No Dependent activity or all Dependent activity completed.'' as [Description]
					INTO '+@temp_table_name)
			ELSE
				Exec spa_ErrorHandler 0, ' No Dependent activity or all Dependent activity completed.', 
					 'spa_update_process', 'Success', 
					 'No Dependent activity or all Dependent activity completed.',0
		END
END
