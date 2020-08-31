BEGIN TRY
    BEGIN TRANSACTION

		SET NOCOUNT ON

		
		IF OBJECT_ID(N'tempdb..#collect_sdv_to_correct') IS NOT NULL
			DROP TABLE #collect_sdv_to_correct

		/*
			1. Collect external static data values using value if in between 10000000 AND 49999999. These value must be update once reseeded to not less than 50000000
		*/
		SELECT sdv.*
		INTO #collect_sdv_to_correct
		FROM static_data_value sdv
		INNER JOIN static_data_type sdt ON sdt.[type_id] = sdv.[type_id]
		WHERE sdt.internal = 0 
			AND sdv.value_id BETWEEN 10000000 AND 49999999

		IF NOT EXISTS(SELECT 1 FROM #collect_sdv_to_correct)
		BEGIN
			PRINT 'No data to process.'
			RETURN
		END
		ELSE PRINT 'Proceed to update existing data.'

		--select pk.field_name,pk.field_id,fk.field_name,fk.field_id  ,fk.*
		--	------ DELETE fk
		--	from user_defined_deal_fields_template fk
		--	INNER JOIN user_defined_fields_template pk ON pk.field_name = fk.field_name
		--	INNER JOIN user_defined_fields_template pk1 ON pk1.field_name = fk.field_id
		--	INNER JOIN #collect_sdv_to_correct sdv ON sdv.value_id = pk.field_name


		IF CURSOR_STATUS('global','fk_cursor') = 1
		BEGIN
			CLOSE fk_cursor;
			DEALLOCATE fk_cursor;
		END

		/*
			2. Update code with suffix '- old'. These data are deleted at the end of script.
		*/
		UPDATE sdv
		SET code = sdv.code + '- old' 
		--SELECT sdv.* 
		FROM static_data_value sdv
		INNER JOIN #collect_sdv_to_correct ut ON ut.value_id = sdv.value_id

		IF OBJECT_ID(N'tempdb..#inserted_sdv') IS NOT NULL
			DROP TABLE  #inserted_sdv

		CREATE TABLE #inserted_sdv(
			new_value_id INT,
			[type_id] INT,
			code VARCHAR(500)
		)

		/*
			3. Restore previous values of static data values on table with new auto generated value_id ...
		*/
		INSERT INTO static_data_value(
			[type_id]
			, code
			, [description]
			, [entity_id]
			, xref_value_id
			, xref_value
			, category_id)
		OUTPUT INSERTED.value_id, INSERTED.type_id, INSERTED.code INTO #inserted_sdv
		SELECT [type_id]
			, code
			, [description]
			, [entity_id]
			, xref_value_id
			, xref_value
			, category_id
		FROM #collect_sdv_to_correct

		--SELECT COUNT(1) FROM #inserted_sdv
		--SELECT * FROM #inserted_sdv

		/*
			4. Update FK value id if those value_id were used in any table ...
		*/
		-- Create table to store constraints values
		DECLARE @table TABLE(
		   RowId								INT PRIMARY KEY IDENTITY(1, 1),
		   ForeignKeyConstraintName				NVARCHAR(200),
		   ForeignKeyConstraintTableSchema		NVARCHAR(200),
		   ForeignKeyConstraintTableName		NVARCHAR(200),
		   ForeignKeyConstraintColumnName		NVARCHAR(200),
		   PrimaryKeyConstraintName				NVARCHAR(200),
		   PrimaryKeyConstraintTableSchema		NVARCHAR(200),
		   PrimaryKeyConstraintTableName		NVARCHAR(200),
		   PrimaryKeyConstraintColumnName		NVARCHAR(200)
		)

		IF OBJECT_ID('tempdb..#fk_constraint') IS NOT NULL
			DROP TABLE #fk_constraint

		CREATE TABLE #fk_constraint (
			table_name		VARCHAR(500),
			column_name		VARCHAR(500),
			constraint_name	VARCHAR(500)
		)
		DECLARE @disable_chk_constraint_sql		VARCHAR(MAX) 
			, @enable_chk_constraint_sql		VARCHAR(MAX) 
			, @fk_update_sql					VARCHAR(MAX) = ''
			, @nested_fk_update_sql				VARCHAR(MAX) = ''
			, @table_name						VARCHAR(200)
			, @column_name						VARCHAR(200)
			, @nested_table_name				VARCHAR(200)
			, @nested_column_name				VARCHAR(200)
			, @nested_constraint_name			VARCHAR(200)
			, @add_contraint_option				VARCHAR(100)

		IF OBJECT_ID(N'tempdb..#updated_table_list') IS NOT NULL
			DROP TABLE  #updated_table_list

		CREATE TABLE #updated_table_list(
			table_name VARCHAR(500),
			column_name VARCHAR(500),
			old_value_id INT,
			new_value_id INT
		)

		IF OBJECT_ID(N'tempdb..#exists_dependent_data') IS NOT NULL
			DROP TABLE  #exists_dependent_data

		CREATE TABLE #exists_dependent_data(
			data_exists INT
		)

		DECLARE fk_cursor CURSOR FOR
			SELECT DISTINCT fk.table_name, cu.column_name
			FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS C 
			INNER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS FK ON C.CONSTRAINT_NAME = FK.CONSTRAINT_NAME 
			INNER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS PK ON C.UNIQUE_CONSTRAINT_NAME = PK.CONSTRAINT_NAME 
			INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE CU ON C.CONSTRAINT_NAME = CU.CONSTRAINT_NAME 
			INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE CCU ON PK.CONSTRAINT_NAME = CCU.CONSTRAINT_NAME
			WHERE FK.CONSTRAINT_TYPE = 'FOREIGN KEY' AND pk.table_name = 'static_data_value'
		OPEN fk_cursor
		FETCH NEXT FROM fk_cursor INTO @table_name, @column_name
		WHILE @@FETCH_STATUS = 0
		BEGIN

			TRUNCATE TABLE #fk_constraint

			INSERT INTO #fk_constraint (table_name, column_name, constraint_name)
			SELECT fk.table_name, cu.column_name, c.constraint_name--,cu.ORDINAL_POSITION,CCU1.ORDINAL_POSITION,ccu.COLUMN_NAME
			FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS C
			INNER JOIN  INFORMATION_SCHEMA.TABLE_CONSTRAINTS FK ON C.CONSTRAINT_NAME = FK.CONSTRAINT_NAME
			INNER JOIN  INFORMATION_SCHEMA.TABLE_CONSTRAINTS PK ON C.UNIQUE_CONSTRAINT_NAME = PK.CONSTRAINT_NAME
			INNER JOIN  INFORMATION_SCHEMA.KEY_COLUMN_USAGE CU ON C.CONSTRAINT_NAME = CU.CONSTRAINT_NAME
			INNER JOIN  INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE CCU ON PK.CONSTRAINT_NAME = CCU.CONSTRAINT_NAME
			INNER JOIN  INFORMATION_SCHEMA.KEY_COLUMN_USAGE CCU1 ON CCU1.CONSTRAINT_NAME = CCU.CONSTRAINT_NAME
				AND ccu.column_name = ccu1.column_name 
				AND CCU1.ORDINAL_POSITION = CU.ORDINAL_POSITION
			WHERE FK.CONSTRAINT_TYPE = 'FOREIGN KEY' AND pk.table_name = @table_name AND ccu.column_name = @column_name
		
			IF EXISTS (SELECT 1 FROM #fk_constraint)
			BEGIN
				EXEC('INSERT INTO #updated_table_list(table_name,column_name,old_value_id,new_value_id)
				SELECT ''' + @table_name + ''',''' + @column_name + ''',sdv.value_id,i.new_value_id
				FROM dbo.' + @table_name + ' rs
						INNER JOIN #collect_sdv_to_correct sdv ON sdv.value_id = rs.' + @column_name + '
						INNER JOIN #inserted_sdv i ON i.type_id = sdv.type_id AND i.code = sdv.code
						')
				-- Prepare primary table update script if its FK is defined.
				SET @fk_update_sql = CONCAT(@fk_update_sql , '
						UPDATE rs
						SET ' + @column_name + ' = i.new_value_id
						FROM dbo.' + @table_name + ' rs
						INNER JOIN #collect_sdv_to_correct sdv ON sdv.value_id = rs.' + @column_name + '
						INNER JOIN #inserted_sdv i ON i.type_id = sdv.type_id AND i.code = sdv.code
					')

				DECLARE fk_cursor_nested CURSOR FOR
					SELECT table_name, column_name, constraint_name FROM #fk_constraint
				OPEN fk_cursor_nested
				FETCH NEXT FROM fk_cursor_nested INTO @nested_table_name, @nested_column_name, @nested_constraint_name
				WHILE @@FETCH_STATUS = 0
				BEGIN
					TRUNCATE TABLE #exists_dependent_data
					
					EXEC('INSERT INTO #exists_dependent_data(data_exists)
						SELECT 1
						FROM dbo.' + @table_name + ' rs
						INNER JOIN #collect_sdv_to_correct sdv ON sdv.value_id = rs.' + @column_name + '
						INNER JOIN ' + @nested_table_name + ' i ON rs.' + @column_name + ' = i.' + @nested_column_name + '
								')

					IF EXISTS(SELECT 1 FROM #exists_dependent_data)
					BEGIN
						--select  @nested_table_name, @nested_column_name, @nested_constraint_name
						DELETE FROM @table

						INSERT INTO @table(ForeignKeyConstraintName, ForeignKeyConstraintTableSchema, ForeignKeyConstraintTableName, ForeignKeyConstraintColumnName)
						SELECT U.CONSTRAINT_NAME, U.TABLE_SCHEMA, U.TABLE_NAME, U.COLUMN_NAME
						FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE U
						INNER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS C ON U.CONSTRAINT_NAME = C.CONSTRAINT_NAME
						WHERE C.CONSTRAINT_TYPE = 'FOREIGN KEY' AND U.CONSTRAINT_NAME = @nested_constraint_name
							AND U.COLUMN_NAME = @nested_column_name
					
						UPDATE @table SET
						   PrimaryKeyConstraintName = UNIQUE_CONSTRAINT_NAME
						FROM 
						   @table T
							  INNER JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS R
								 ON T.ForeignKeyConstraintName = R.CONSTRAINT_NAME

						UPDATE @table SET
						   PrimaryKeyConstraintTableSchema  = TABLE_SCHEMA,
						   PrimaryKeyConstraintTableName  = TABLE_NAME
						FROM @table T
						   INNER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS C
							  ON T.PrimaryKeyConstraintName = C.CONSTRAINT_NAME

						UPDATE @table SET
						   PrimaryKeyConstraintColumnName = COLUMN_NAME
						FROM @table T
						   INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE U
							  ON T.PrimaryKeyConstraintName = U.CONSTRAINT_NAME

						/*
							# Created Variables for storing SQL for :
							i. Drop existing Constraints to allow update on tables
							ii. Update values with latest value_id
							iii. Create Constraints with nocheck
						*/					
					
						-- i. Query to Drop Existing Constraint
						SELECT @disable_chk_constraint_sql = CONCAT(@disable_chk_constraint_sql,
						   '
						   ALTER TABLE [' + ForeignKeyConstraintTableSchema + '].[' + ForeignKeyConstraintTableName + '] NOCHECK CONSTRAINT [' + ForeignKeyConstraintName + '] ')
						FROM @table

						EXEC('INSERT INTO #updated_table_list(table_name,column_name,old_value_id,new_value_id)
							SELECT ''' + @nested_table_name + ''',''' + @nested_column_name + ''',sdv.value_id,i.new_value_id
							FROM dbo.' + @nested_table_name + ' rs
									INNER JOIN #collect_sdv_to_correct sdv ON sdv.value_id = rs.' + @nested_column_name + '
									INNER JOIN #inserted_sdv i ON i.type_id = sdv.type_id AND i.code = sdv.code
									')
					
						SET @nested_fk_update_sql = CONCAT(@nested_fk_update_sql  , '
							UPDATE rs
							SET ' + @nested_column_name + ' = i.new_value_id
							FROM dbo.' + @nested_table_name + ' rs
							INNER JOIN #collect_sdv_to_correct sdv ON sdv.value_id = rs.' + @nested_column_name + '
							INNER JOIN #inserted_sdv i ON i.type_id = sdv.type_id AND i.code = sdv.code
						')

						-- iii. Recreate Dropped Constraint
						--If primary table is user_defined_fields_template then add contraint without rechecking contraint. There are many orphand fk data which is not in this scope. These data will be handled separately. 
						if (@table_name = 'user_defined_fields_template')
							SET @add_contraint_option = 'CHECK CONSTRAINT'
						ELSE
							SET @add_contraint_option = 'WITH CHECK CHECK CONSTRAINT'

						SELECT @enable_chk_constraint_sql = CONCAT(@enable_chk_constraint_sql,
						   '
						   ALTER TABLE [' + ForeignKeyConstraintTableSchema + '].[' + ForeignKeyConstraintTableName + '] ' + @add_contraint_option + '[' + ForeignKeyConstraintName + '] ')
						FROM @table

					END
					FETCH NEXT FROM fk_cursor_nested INTO @nested_table_name, @nested_column_name, @nested_constraint_name
				END
				CLOSE fk_cursor_nested;
				DEALLOCATE fk_cursor_nested;
			END
			ELSE
			BEGIN
				-- Update if nested constraint doesnot exist
				EXEC('INSERT INTO #updated_table_list(table_name,column_name,old_value_id,new_value_id)
				SELECT ''' + @table_name + ''',''' + @column_name + ''',sdv.value_id,i.new_value_id
				FROM dbo.' + @table_name + ' rs
						INNER JOIN #collect_sdv_to_correct sdv ON sdv.value_id = rs.' + @column_name + '
						INNER JOIN #inserted_sdv i ON i.type_id = sdv.type_id AND i.code = sdv.code
						')

				EXEC('
					UPDATE rs
					SET ' + @column_name + ' = i.new_value_id
					FROM dbo.' + @table_name + ' rs
					INNER JOIN #collect_sdv_to_correct sdv ON sdv.value_id = rs.' + @column_name + '
					INNER JOIN #inserted_sdv i ON i.type_id = sdv.type_id AND i.code = sdv.code
				')
			END

			FETCH NEXT FROM fk_cursor INTO @table_name, @column_name
		END
		CLOSE fk_cursor;
		DEALLOCATE fk_cursor;

		DECLARE @final_sql NVARCHAR(MAX)

		SET @final_sql = CONCAT(@disable_chk_constraint_sql, @fk_update_sql, @nested_fk_update_sql, @enable_chk_constraint_sql)

		-- Final SQL when there are nested constraints
		--PRINT ('Final SQL is : ' + @final_sql)
		EXEC(@final_sql)


		/******************Manual Update******************************************************************/
		-- i. Hourly Block
		UPDATE rs
		SET holiday_value_id = i.new_value_id
		FROM dbo.hourly_block rs
		INNER JOIN #collect_sdv_to_correct sdv ON sdv.value_id = rs.holiday_value_id
		INNER JOIN #inserted_sdv i ON i.type_id = sdv.type_id AND i.code = sdv.code

		DECLARE @block_value_id INT

        DECLARE cur_blocks CURSOR LOCAL FOR
		--get hourly_block whose block_value_id is updated
        SELECT i.new_value_id AS block_value_id
		FROM #inserted_sdv i
		WHERE i.type_id = 10018

		UNION 

		--get hourly block whose holiday_value_id is updated
		SELECT rs.block_value_id
		FROM dbo.hourly_block rs
		INNER JOIN #inserted_sdv i ON i.new_value_id = rs.holiday_value_id
			AND i.type_id = 10017
        
        OPEN cur_blocks ;
 
        FETCH NEXT FROM cur_blocks INTO @block_value_id
        WHILE @@FETCH_STATUS = 0
        BEGIN
              --re-generate hour_block_term including total volume update
			EXEC dbo.spa_generate_hour_block_term @block_value_id, NULL, NULL
             
			FETCH NEXT FROM cur_blocks INTO @block_value_id
        END;
 
        CLOSE cur_blocks ;
        DEALLOCATE cur_blocks ;
 
		-- ii. Holiday Calendar
		UPDATE rs
		SET hol_group_value_id = i.new_value_id
		FROM dbo.holiday_group rs
		INNER JOIN #collect_sdv_to_correct sdv ON sdv.value_id = rs.hol_group_value_id
		INNER JOIN #inserted_sdv i ON i.type_id = sdv.type_id AND i.code = sdv.code

		UPDATE rs
		SET calendar_desc = i.new_value_id
		FROM dbo.default_holiday_calendar rs
		INNER JOIN #collect_sdv_to_correct sdv ON sdv.value_id = rs.calendar_desc
		INNER JOIN #inserted_sdv i ON i.type_id = sdv.type_id AND i.code = sdv.code
		/****************************************************************************/

		/*
			5. Finally delete old values from static data values table after new data are inserted ...
		*/
		DELETE sdv
		FROM static_data_value sdv
		INNER JOIN #collect_sdv_to_correct ut ON ut.value_id = sdv.value_id
					
    COMMIT
END TRY
BEGIN CATCH
	--SELECT 'ROLLBACK', ERROR_MESSAGE ()
	DECLARE @err_msg VARCHAR(MAX) = ERROR_MESSAGE()
	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION

	IF CURSOR_STATUS ('local', 'cur_blocks') > 0
	BEGIN
			CLOSE cur_blocks ;
			DEALLOCATE cur_blocks ;
	END

	RAISERROR (@err_msg, 17, -1);
END CATCH

GO


/* -- For Checking
SELECT field_id,field_name,* FROM user_defined_fields_template
WHERE field_name BETWEEN 10000000 AND 49999999

SELECT field_id,field_name,* FROM user_defined_fields_template
WHERE field_name > 50000000 

SELECT field_id,field_name,* FROM user_defined_deal_fields_template
WHERE field_name BETWEEN 10000000 AND 49999999

select field_id,field_name,* from user_defined_deal_fields_template
where field_name > 50000000

select * from #collect_sdv_to_correct cstc
left join user_defined_fields_template udft on udft.field_name = cstc.value_id

select * from static_data_value sdv where value_id > 50000000

select * from holiday_group where hol_group_value_id  BETWEEN 10000000 AND 49999999

select * from default_holiday_calendar where calendar_desc BETWEEN 10000000 AND 49999999

select * from hourly_block where block_value_id BETWEEN 10000000 AND 49999999

SELECT sdv.*, sdt.type_name
FROM static_data_value sdv
INNER JOIN static_data_type sdt ON sdt.[type_id] = sdv.[type_id]
WHERE sdt.internal = 0 
AND sdv.value_id BETWEEN 10000000 AND 49999999
*/