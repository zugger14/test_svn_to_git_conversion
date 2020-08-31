
/****** Object:  StoredProcedure [dbo].[spa_import_source_facility]    Script Date: 03/04/2010 09:59:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_import_source_facility]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_import_source_facility]
/****** Object:  StoredProcedure [dbo].[spa_import_source_facility]    Script Date: 03/04/2010 09:59:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spa_import_source_facility]
	@temp_table_name	VARCHAR(100),  
	@table_id			VARCHAR(100),  
	@job_name			VARCHAR(100),  
	@process_id			VARCHAR(100),  
	@user_login_id		VARCHAR(50)  
  
AS
BEGIN  
	DECLARE @user		   VARCHAR(100) ,
			@own_display   VARCHAR(100) ,
			@state		   VARCHAR(100) ,
			@facility_name VARCHAR(100) ,
			@orispl_code   VARCHAR(100) ,
			@name		   VARCHAR(100) ,	
			@message	   VARCHAR(250) ,
			@error_msg     VARCHAR(1000),		
			@url		   VARCHAR(1000), 
			@desc		   VARCHAR(1000),		
			@sql		   VARCHAR(MAX) ,
			@sno		   INT			,
			@unitid		   INT			,
			@op_year       INT			,
			@fas_book_id   INT			,	
			@statevalue	   INT			,
			@generatorid   INT			,
			@count		   INT			,			
			@op_date	   DATETIME		,
			@error_code    CHAR(1)		,	
			@mandatoryDataMissing CHAR(1),		
			@sub_id			INT			,
			@stra_id		INT			,
			@gen_state		VARCHAR(100)

	SET @sub_id=6
	SET @stra_id=220


BEGIN TRY
	IF @temp_table_name IS NOT NULL AND @job_name IS NULL
	BEGIN					
		EXEC('SELECT code as Code,
				     facility_name as ''Facility Name'',
					 orispl_code as ''Facility ID'',
					 unitid as ''UNIT ID'',
					 op_year as ''Start Date'',
					 [state] as ''State'',
					 descr as ''Description''
					 FROM '+@temp_table_name)
		RETURN
	END

	CREATE TABLE #count ( cnt INT)

	CREATE TABLE #temp_sourcefacility
	(
				 [state]	   VARCHAR(100) COLLATE DATABASE_DEFAULT,
				 facility_name VARCHAR(100) COLLATE DATABASE_DEFAULT,
				 orispl_code   VARCHAR(100) COLLATE DATABASE_DEFAULT,
				 unitid		   INT		   ,
				 op_year	   INT		   ,
				 own_display   VARCHAR(100) COLLATE DATABASE_DEFAULT,
				 sno		   INT	,
				 Gen_state		VARCHAR(100) COLLATE DATABASE_DEFAULT	
	)

	SELECT @error_code = 's',@mandatoryDataMissing = 'n',@user_login_id = dbo.FNAdbuser()
	
	BEGIN TRAN
	-- Update the code as 'Error' if the mandatory fields are missing
	EXEC('UPDATE '+@temp_table_name+
		' SET code  = ''Error''
			WHERE facility_name IS NULL
				OR unitid IS  NULL
				OR op_year IS NULL
				OR orispl_code IS NULL
				OR [STATE] IS NULL')

	-- Update the code as 'Success' if the mandatory fields are not missing	
	EXEC('UPDATE '+@temp_table_name+
		' SET code = ''Success''
			WHERE code IS NULL')
	
	EXEC('IF EXISTS (SELECT ''x'' FROM '+@temp_table_name +' WHERE code = ''Error'')
		INSERT INTO #count SELECT 0')

	IF EXISTS (SELECT 'x' FROM #count)
		SELECT @mandatoryDataMissing = 'y'

	IF @mandatoryDataMissing = 'y'
	BEGIN
		EXEC('UPDATE '+@temp_table_name+
			 ' SET descr = isnull(descr,'''') + ''Source Name,''
				WHERE facility_name IS NULL
				AND code = ''Error''')
		
		EXEC('UPDATE '+@temp_table_name+
			 ' SET descr = isnull(descr,'''') + ''Unit,''
				WHERE unitid IS NULL
				AND code = ''Error''')

		EXEC('UPDATE '+@temp_table_name+
			 ' SET descr = isnull(descr,'''') + ''Start Date,''
				WHERE op_year IS NULL
				AND code = ''Error''')

		EXEC('UPDATE '+@temp_table_name+
			 ' SET descr = isnull(descr,'''') + ''Facility ID,''
				WHERE orispl_code IS NULL
				AND code = ''Error''')

		EXEC('UPDATE '+@temp_table_name+
			 ' SET descr = isnull(descr,'''') + ''State,''
				WHERE [State] IS NULL
				AND code = ''Error''')

		EXEC('UPDATE ' + @temp_table_name+'
			 SET descr = substring(descr,1,len(descr)-1)  +'' missing.''
					WHERE code = ''Error''')
	END
	exec('UPDATE '+@temp_table_name+
		' SET code  = ''<b><font color = red>Error</font></b>''
			 WHERE code = ''Error''')
				


	DELETE FROM #count

	EXEC 
	(
		'INSERT INTO #temp_sourcefacility 
			 ([state],facility_name,orispl_code,unitid,op_year,own_display,sno,Gen_state)
			SELECT 
				sd.value_id,
				NULLIF(ltrim(rtrim(facility_name)),''NULL''),
				NULLIF(ltrim(rtrim(orispl_code)),''NULL''),
				unitid,
				op_year,
				NULLIF(ltrim(rtrim(own_display)),''NULL''),
				sno,
				sd1.value_id as Gen_state
			FROM ' + @temp_table_name
			+'	
			LEFT JOIN static_data_value sd ON sd.code=ltrim(rtrim(state)) AND sd.type_id=10002
			LEFT JOIN static_data_value sd1 ON sd1.code=ltrim(rtrim(state)) AND sd1.type_id=10016
			WHERE [state] IS NOT NULL
							AND facility_name IS NOT NULL
							AND unitid IS NOT NULL
							AND op_year IS NOT NULL
							AND orispl_code IS NOT NULL'
	)
	

		---###### Insert the Book as the facility name.

		INSERT INTO portfolio_hierarchy(entity_name,entity_type_value_id,hierarchy_level,parent_entity_id)
		SELECT 
			DISTINCT facility_name,527,0,@stra_id
		FROM
			#temp_sourcefacility
		WHERE
			facility_name not in(select entity_name from portfolio_hierarchy where entity_type_value_id=527 and hierarchy_level=0 and parent_entity_id=@stra_id)

		
		DECLARE rec_cursor 
			CURSOR FOR 
				SELECT [state], facility_name, orispl_code, unitid, op_year, own_display,sno,Gen_state
					FROM #temp_sourcefacility
					
		OPEN rec_cursor

		FETCH NEXT FROM rec_cursor INTO @state,@facility_name,@orispl_code,@unitid,@op_year,@own_display,@sno,@gen_state

		WHILE @@FETCH_STATUS = 0
		BEGIN


			SET @fas_book_id=NULL
			SELECT @fas_book_id=phbook.entity_id 
				FROM portfolio_hierarchy phbook
					INNER JOIN portfolio_hierarchy phstrat 
				ON phstrat.entity_id=phbook.parent_entity_id
				WHERE phbook.entity_name=@facility_name
				  AND phbook.parent_entity_id=@stra_id
				  AND phstrat.parent_entity_id=@sub_id

		    
			IF @fas_book_id IS NOT NULL
			BEGIN
				SELECT @statevalue=value_id 
					FROM static_data_value 
						WHERE [TYPE_ID]=10002 
						AND code=@state
			
				SELECT @op_date=CAST(CAST(@op_year AS VARCHAR) AS DATETIME)
				
				SET @generatorid =NULL
				SELECT @generatorid=generator_id 
					FROM rec_generator 
					WHERE id=@orispl_code 
					  AND code=CAST(@unitid AS VARCHAR)
		 
				IF @generatorid IS NOT NULL
				BEGIN

				--record exists, update this	
					UPDATE rec_generator SET [OWNER]=@own_display, first_gen_date=@op_date,state_value_id=@statevalue,fas_book_id=@fas_book_id,[name]=@facility_name
					WHERE generator_id=@generatorid
					
					SELECT @sql = 'UPDATE '+@temp_table_name +' SET descr = ''<font color = 990000 >Updated</font>'' WHERE descr IS NULL AND sno= ' + CAST(@sno AS VARCHAR)
					EXEC spa_print @sql
					EXEC (@sql)

				END
				ELSE
				BEGIN
					--no record, do insert.
					INSERT INTO rec_generator
					(
						[name],
						[OWNER],
						id,
						first_gen_date,
						code,
						state_value_id,
						fas_book_id,
						registered,generator_type,
						gen_state_value_id
					)
					SELECT @facility_name,@own_display,@orispl_code,@op_date,@unitid,@state,@fas_book_id,'n','r',@gen_state

					SELECT @sql = 'UPDATE '+@temp_table_name +' SET descr = ''New Entry'' WHERE descr IS NULL AND sno= ' + CAST(@sno AS VARCHAR)
					EXEC spa_print @sql
					EXEC (@sql)

				END
			END -- IF @fas_book_id is not null

			FETCH NEXT FROM rec_cursor INTO @state,@facility_name,@orispl_code,@unitid,@op_year,@own_display,@sno,@gen_state
		END 
		CLOSE rec_cursor
		DEALLOCATE rec_cursor
		COMMIT
	END TRY
	BEGIN CATCH
		SELECT @error_msg = ERROR_MESSAGE()
		SELECT @error_code = 'e'
		ROLLBACK
	END CATCH

	IF @error_code = 's'
	BEGIN			
		SELECT @name = @temp_table_name
		EXEC('insert into #count SELECT count(*) FROM '+@name)
		SELECT @count = cnt  FROM #count
	END
	
	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + '&spa=exec spa_import_source_facility '''+@temp_table_name+''',NULL,NULL, NULL,'''+@user_login_id+''''
		
	SELECT @desc =
		CASE @count 
		WHEN 0 THEN
			 CASE @error_code 
			 WHEN  's' THEN 
				'EDR Import source empty. Please verify with the source.'
			 ELSE
				'Error on EDR Import process.. Please contact technical support. [Error : ]: '+ @error_msg
			END
		ELSE
			'<a target="_blank" href="' + @url + '">' + 
			CASE @mandatoryDataMissing
			WHEN 'y' THEN
				'EDR Import process completed: No Source found to import (Errors Found).'
			ELSE																																														
				'EDR Import process completed: Total '+ CAST(@count AS VARCHAR)+ ' sources imported…'
			END
		   +'</a>'	
		END

	DECLARE list_user CURSOR FOR 
		SELECT application_users.user_login_id	
			FROM dbo.application_role_user 
				INNER JOIN dbo.application_security_role 
					ON dbo.application_role_user.role_id = dbo.application_security_role.role_id 
				INNER JOIN dbo.application_users 
					ON dbo.application_role_user.user_login_id = dbo.application_users.user_login_id
				WHERE (dbo.application_users.user_active = 'y') AND (dbo.application_security_role.role_type_value_id =2) 							
				GROUP BY dbo.application_users.user_login_id,  dbo.application_users.user_emal_add
	OPEN list_user
		FETCH NEXT FROM list_user INTO 	@user
		WHILE @@FETCH_STATUS = 0
		BEGIN							
			EXEC  spa_message_board 'i', @user,NULL, 'Import.Data',@desc, '', '', @error_code, 'Interface Adaptor',null,@process_id
			FETCH NEXT FROM list_user INTO 	@user
		END
	CLOSE list_user
	DEALLOCATE list_user
END -- End of Procedure
