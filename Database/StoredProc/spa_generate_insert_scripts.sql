
SET NOCOUNT ON
GO

EXEC spa_print 'Checking for the existence of this procedure'
IF (SELECT OBJECT_ID('spa_generate_insert_scripts','P')) IS NOT NULL --means, the procedure already exists
	BEGIN
		EXEC spa_print 'Procedure already exists. So, dropping it'
		DROP PROC spa_generate_insert_scripts
	END
GO

CREATE PROC spa_generate_insert_scripts(
   @table_name VARCHAR(1000),	-- The table/view for which the INSERT statements will be generated using the existing data
   @target_table VARCHAR(1000) = NULL,	-- Use this parameter to specify a different table name into which the data will be inserted
   @include_column_list BIT = 1,	-- Use this parameter to include/ommit column list in the generated INSERT statement
   @from VARCHAR(MAX) = NULL,	-- Use this parameter to filter the rows based on a filter condition (using WHERE)
   @include_timestamp BIT = 0,	-- Specify 1 for this parameter, if you want to include the TIMESTAMP/ROWVERSION column's data in the INSERT statement
   @debug_mode BIT = 0,	-- If @debug_mode is set to 1, the SQL statements constructed by this procedure will be EXEC spa_printed for later examination
   @owner VARCHAR(500) = NULL,	-- Use this parameter if you are not the owner of the table
   @ommit_images BIT = 0,	-- Use this parameter to generate INSERT statements by omitting the 'image' columns
   @ommit_identity BIT = 1,	-- Use this parameter to ommit the identity columns
   @top INT = NULL,	-- Use this parameter to generate INSERT statements only for the TOP n rows
   @cols_to_include VARCHAR(MAX) = NULL,	-- List of columns to be included in the INSERT statement
   @cols_to_exclude VARCHAR(MAX) = NULL,	-- List of columns to be excluded from the INSERT statement
   @disable_constraints BIT = 0,	-- When 1, disables foreign key constraints and enables them after the INSERT statements
   @ommit_computed_cols BIT = 0,	-- When 1, computed columns will not be included in the INSERT statement
   @unique_key_list VARCHAR(MAX) = NULL,
   @reference_keys_process_table VARCHAR(500) = NULL,
   @parent_alias VARCHAR(50) = NULL,
   @output_table VARCHAR(600) = NULL
)
AS
BEGIN	

/**********************************************************************************************************
Example 1:	To generate INSERT statements for table 'titles':
		
		EXEC spa_generate_insert_scripts 'titles'

Example 2: 	To ommit the column list in the INSERT statement: (Column list is included by default)
		IMPORTANT: If you have too many columns, you are advised to ommit column list, as shown below,
		to avoid erroneous results
		
		EXEC spa_generate_insert_scripts 'titles', @include_column_list = 0

Example 3:	To generate INSERT statements for 'titlesCopy' table from 'titles' table:

		EXEC spa_generate_insert_scripts 'titles', 'titlesCopy'

Example 4:	To generate INSERT statements for 'titles' table for only those titles 
		which contain the word 'Computer' in them:
		NOTE: Do not complicate the FROM or WHERE clause here. It's assumed that you are good with T-SQL if you are using this parameter

		EXEC spa_generate_insert_scripts 'titles', @from = "from titles where title like '%Computer%'"

Example 5: 	To specify that you want to include TIMESTAMP column's data as well in the INSERT statement:
		(By default TIMESTAMP column's data is not scripted)

		EXEC spa_generate_insert_scripts 'titles', @include_timestamp = 1

Example 6:	To EXEC spa_print the debug information:
  
		EXEC spa_generate_insert_scripts 'titles', @debug_mode = 1

Example 7: 	If you are not the owner of the table, use @owner parameter to specify the owner name
		To use this option, you must have SELECT permissions on that table

		EXEC spa_generate_insert_scripts Nickstable, @owner = 'Nick'

Example 8: 	To generate INSERT statements for the rest of the columns excluding images
		When using this otion, DO NOT set @include_column_list parameter to 0.

		EXEC spa_generate_insert_scripts imgtable, @ommit_images = 1

Example 9: 	To generate INSERT statements excluding (ommiting) IDENTITY columns:
		(By default IDENTITY columns are included in the INSERT statement)

		EXEC spa_generate_insert_scripts mytable, @ommit_identity = 1

Example 10: 	To generate INSERT statements for the TOP 10 rows in the table:
		
		EXEC spa_generate_insert_scripts mytable, @top = 10

Example 11: 	To generate INSERT statements with only those columns you want:
		
		EXEC spa_generate_insert_scripts titles, @cols_to_include = 'title,title_id,au_id'

Example 12: 	To generate INSERT statements by omitting certain columns:
		
		EXEC spa_generate_insert_scripts titles, @cols_to_exclude = 'title,title_id,au_id'

Example 13:	To avoid checking the foreign key constraints while loading data with INSERT statements:
		
		EXEC spa_generate_insert_scripts titles, @disable_constraints = 1

Example 14: 	To exclude computed columns from the INSERT statement:
		EXEC spa_generate_insert_scripts MyTable, @ommit_computed_cols = 1
***********************************************************************************************************/

SET NOCOUNT ON

--Making sure user only uses either @cols_to_include or @cols_to_exclude
IF ((@cols_to_include IS NOT NULL) AND (@cols_to_exclude IS NOT NULL))
BEGIN
	RAISERROR('Use either @cols_to_include or @cols_to_exclude. Do not use both the parameters at once',16,1)
	RETURN -1 --Failure. Reason: Both @cols_to_include and @cols_to_exclude parameters are specified
END

--Checking to see if the database name is specified along wih the table name
--Your database context should be local to the table for which you want to generate INSERT statements
--specifying the database name is not allowed
IF (PARSENAME(@table_name,3)) IS NOT NULL
	BEGIN
		RAISERROR('Do not specify the database name. Be in the required database and just specify the table name.',16,1)
		RETURN -1 --Failure. Reason: Database name is specified along with the table name, which is not allowed
	END

--Checking for the existence of 'user table' or 'view'
--This procedure is not written to work on system tables
--To script the data in system tables, just create a view on the system tables and script the view instead

IF @owner IS NULL
BEGIN
	IF ((OBJECT_ID(@table_name,'U') IS NULL) AND (OBJECT_ID(@table_name,'V') IS NULL)) 
		BEGIN
			RAISERROR('User table or view not found.',16,1)
			EXEC spa_print 'You may see this error, if you are not the owner of this table or view. In that case use @owner parameter to specify the owner name.'
			EXEC spa_print 'Make sure you have SELECT permission on that table or view.'
			RETURN -1 --Failure. Reason: There is no user table or view with this name
		END
END
ELSE
BEGIN
	IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @table_name AND (TABLE_TYPE = 'BASE TABLE' OR TABLE_TYPE = 'VIEW') AND TABLE_SCHEMA = @owner)
		BEGIN
			RAISERROR('User table or view not found.',16,1)
			EXEC spa_print 'You may see this error, if you are not the owner of this table. In that case use @owner parameter to specify the owner name.'
			EXEC spa_print 'Make sure you have SELECT permission on that table or view.'
			RETURN -1 --Failure. Reason: There is no user table or view with this name		
		END
END

--Variable declarations
DECLARE @Column_ID int, 		
		@Column_List varchar(MAX), 
		@Column_Name varchar(MAX), 
		@Start_Insert varchar(MAX), 
		@Data_Type varchar(MAX), 
		@Actual_Values varchar(MAX),	--This is the string that will be finally executed to generate INSERT statements
		@IDN varchar(MAX),				--Will contain the IDENTITY column's name in the table
		@column_value VARCHAR(MAX),
		@column_name_with_alias VARCHAR(MAX)

DECLARE @referenced_table VARCHAR(300)
DECLARE @referenced_column VARCHAR(300)		

--Variable Initialization
SET @IDN = ''
SET @Column_ID = 0
SET @Column_Name = ''
SET @Column_List = ''
SET @Actual_Values = ''
DECLARE @key_check VARCHAR(MAX)
DECLARE @key_where VARCHAR(MAX)
DECLARE @where VARCHAR(MAX)
DECLARE @include_column VARCHAR(MAX)
SET @include_column = @cols_to_include
SET @key_check = NULL
SET @key_where = ''

IF OBJECT_ID('tempdb..#unique_testing_list') IS NOT NULL
	DROP TABLE #unique_testing_list
	
IF OBJECT_ID('tempdb..#referenced_columns') IS NOT NULL
	DROP TABLE #referenced_columns
	
CREATE TABLE #unique_testing_list (column_name VARCHAR(500) COLLATE DATABASE_DEFAULT)

CREATE TABLE #referenced_columns (
	column_name        VARCHAR(300) COLLATE DATABASE_DEFAULT,
	referenced_table   VARCHAR(300) COLLATE DATABASE_DEFAULT,
	referenced_column  VARCHAR(300) COLLATE DATABASE_DEFAULT
)

IF @reference_keys_process_table IS NOT NULL
BEGIN
	INSERT INTO #referenced_columns
	EXEC('SELECT * FROM ' + @reference_keys_process_table)
END

IF @unique_key_list IS NOT NULL
BEGIN
	INSERT INTO #unique_testing_list
	SELECT QUOTENAME(item) FROM dbo.SplitCommaSeperatedValues(@unique_key_list) scsv	
END

INSERT INTO #unique_testing_list
SELECT QUOTENAME(CCU.COLUMN_NAME)
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS TC
INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE AS CCU
    ON  TC.CONSTRAINT_CATALOG = CCU.CONSTRAINT_CATALOG
    AND TC.CONSTRAINT_SCHEMA = CCU.CONSTRAINT_SCHEMA
    AND TC.CONSTRAINT_NAME = CCU.CONSTRAINT_NAME
INNER JOIN INFORMATION_SCHEMA.COLUMNS IC ON ic.TABLE_NAME = tc.TABLE_NAME AND ic.COLUMN_NAME = ccu.COLUMN_NAME 
LEFT JOIN #unique_testing_list utl ON utl.column_name = QUOTENAME(CCU.COLUMN_NAME)
WHERE  TC.CONSTRAINT_SCHEMA = 'dbo'
       AND (TC.CONSTRAINT_TYPE = 'UNIQUE' OR (TC.CONSTRAINT_TYPE = 'PRIMARY KEY' AND ic.DATA_TYPE <> 'INT'))
       AND TC.TABLE_NAME = @table_name
       AND utl.column_name IS NULL
GROUP BY CCU.COLUMN_NAME

IF @cols_to_include IS NOT NULL
BEGIN
	SELECT @cols_to_include = COALESCE(@cols_to_include + ',', '') + SUBSTRING(utl.column_name, 2, LEN(utl.column_name)-2)
	FROM #unique_testing_list utl 
	LEFT JOIN dbo.SplitCommaSeperatedValues(@include_column) scsv ON utl.column_name = QUOTENAME(scsv.item)
	WHERE scsv.item IS NULL
END

DECLARE @cols_to_include1 VARCHAR(MAX)
SET @cols_to_include1 = '@cols_to_include==============' + @cols_to_include

EXEC spa_print @cols_to_include1

IF @owner IS NULL 
	BEGIN
		SET @Start_Insert = 'INSERT INTO ' + '[' + RTRIM(COALESCE(@target_table,@table_name)) + ']' 
	END
ELSE
	BEGIN
		SET @Start_Insert = 'INSERT ' + '[' + LTRIM(RTRIM(@owner)) + '].' + '[' + RTRIM(COALESCE(@target_table,@table_name)) + ']' 		
	END

--To get the first column's ID

SELECT	@Column_ID = MIN(ORDINAL_POSITION) 	
FROM	INFORMATION_SCHEMA.COLUMNS (NOLOCK) 
WHERE 	TABLE_NAME = @table_name AND
(@owner IS NULL OR TABLE_SCHEMA = @owner)

--Loop through all the columns of the table, to get the column names and their data types
WHILE @Column_ID IS NOT NULL
BEGIN
	SELECT 	@Column_Name = QUOTENAME(COLUMN_NAME), 
	@Data_Type = DATA_TYPE 
	FROM 	INFORMATION_SCHEMA.COLUMNS (NOLOCK) 
	WHERE 	ORDINAL_POSITION = @Column_ID AND 
	TABLE_NAME = @table_name AND
	(@owner IS NULL OR TABLE_SCHEMA = @owner)
	
	IF @parent_alias IS NOT NULL
	BEGIN
		SET @column_name_with_alias = @parent_alias + '.' + @Column_Name
	END
	ELSE
	BEGIN
		SET @column_name_with_alias = @Column_Name
	END
	
	
	IF @cols_to_include IS NOT NULL --Selecting only user specified columns
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM dbo.SplitCommaSeperatedValues(@cols_to_include) scsv WHERE QUOTENAME(scsv.item) = @Column_Name)
		BEGIN
			GOTO SKIP_LOOP
		END
	END

	IF @cols_to_exclude IS NOT NULL --Selecting only user specified columns
	BEGIN
		IF EXISTS (SELECT 1 FROM dbo.SplitCommaSeperatedValues(@cols_to_exclude) scsv WHERE QUOTENAME(scsv.item) = @Column_Name)
		BEGIN
			GOTO SKIP_LOOP
		END
	END

	--Making sure to output SET IDENTITY_INSERT ON/OFF in case the table has an IDENTITY column
	IF (SELECT COLUMNPROPERTY( OBJECT_ID(QUOTENAME(COALESCE(@owner,USER_NAME())) + '.' + @table_name),SUBSTRING(@Column_Name,2,LEN(@Column_Name) - 2),'IsIdentity')) = 1 
	BEGIN
		IF @ommit_identity = 0 --Determing whether to include or exclude the IDENTITY column
			SET @IDN = @Column_Name
		ELSE
			GOTO SKIP_LOOP			
	END
	
	--Making sure whether to output computed columns or not
	IF @ommit_computed_cols = 1
	BEGIN
		IF (SELECT COLUMNPROPERTY( OBJECT_ID(QUOTENAME(COALESCE(@owner,USER_NAME())) + '.' + @table_name),SUBSTRING(@Column_Name,2,LEN(@Column_Name) - 2),'IsComputed')) = 1 
		BEGIN
			GOTO SKIP_LOOP					
		END
	END
	
	--Tables with columns of IMAGE data type are not supported for obvious reasons
	IF(@Data_Type in ('image'))
	BEGIN
		IF (@ommit_images = 0)
		BEGIN
			RAISERROR('Tables with image columns are not supported.',16,1)
			EXEC spa_print 'Use @ommit_images = 1 parameter to generate INSERTs for the rest of the columns.'
			EXEC spa_print 'DO NOT ommit Column List in the INSERT statements. If you ommit column list using @include_column_list=0, the generated INSERTs will fail.'
			RETURN -1 --Failure. Reason: There is a column with image data type
		END
		ELSE
		BEGIN
			GOTO SKIP_LOOP
		END
	END

	--Determining the data type of the column and depending on the data type, the VALUES part of
	--the INSERT statement is generated. Care is taken to handle columns with NULL values. Also
	--making sure, not to lose any data from flot, real, money, smallmomey, datetime columns
	SET @column_value = 
	CASE 
		WHEN @Data_Type IN ('char','varchar','nchar','nvarchar') 
			THEN 
				'COALESCE('''''''' + REPLACE(RTRIM(CAST(' + @column_name_with_alias + ' AS VARCHAR(MAX))),'''''''','''''''''''')+'''''''',''NULL'')'
		WHEN @Data_Type IN ('datetime','smalldatetime') 
			THEN 
				'COALESCE('''''''' + RTRIM(CONVERT(VARCHAR(MAX),' + @column_name_with_alias + ',109))+'''''''',''NULL'')'
		WHEN @Data_Type IN ('uniqueidentifier') 
			THEN  
				'COALESCE('''''''' + REPLACE(CONVERT(VARCHAR(MAX),RTRIM(' + @column_name_with_alias + ')),'''''''','''''''''''')+'''''''',''NULL'')'
		WHEN @Data_Type IN ('text','ntext') 
			THEN  
				'COALESCE('''''''' + REPLACE(CONVERT(VARCHAR(MAX),' + @column_name_with_alias + '),'''''''','''''''''''')+'''''''',''NULL'')'					
		WHEN @Data_Type IN ('binary','varbinary') 
			THEN  
				'COALESCE(RTRIM(CONVERT(char,' + 'CONVERT(int,' + @column_name_with_alias + '))),''NULL'')'  
		WHEN @Data_Type IN ('timestamp','rowversion') 
			THEN  
				CASE 
					WHEN @include_timestamp = 0 
						THEN 
							'''DEFAULT''' 
						ELSE 
							'COALESCE(RTRIM(CONVERT(VARCHAR(MAX),' + 'CONVERT(int,' + @column_name_with_alias + '))),''NULL'')'  
				END
		WHEN @Data_Type IN ('float','real','money','smallmoney')
			THEN
				'COALESCE(LTRIM(RTRIM(' + 'CONVERT(VARCHAR(MAX), ' +  @column_name_with_alias  + ',2)' + ')),''NULL'')' 
		ELSE 
			'COALESCE(LTRIM(RTRIM(' + 'CONVERT(VARCHAR(MAX), ' +  @column_name_with_alias  + ')' + ')),''NULL'')' 
	END   + '+' +  ''',''' + ' + '
	
	
	IF EXISTS(SELECT 1 FROM #referenced_columns WHERE column_name = @Column_Name)
	BEGIN
		SELECT @referenced_table = referenced_table,
		       @referenced_column = referenced_column
		FROM   #referenced_columns
		WHERE  column_name = @Column_Name
		
		IF OBJECT_ID('tempdb..#reference_table_unique_columns') IS NOT NULL
			DROP TABLE #reference_table_unique_columns
		
		CREATE TABLE #reference_table_unique_columns (unique_columns VARCHAR(300) COLLATE DATABASE_DEFAULT NULL, relation_query VARCHAR(5000) COLLATE DATABASE_DEFAULT NULL)
		
		INSERT INTO #reference_table_unique_columns(unique_columns)
		SELECT QUOTENAME(CCU.COLUMN_NAME)
		FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS TC
		INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE AS CCU
			ON  TC.CONSTRAINT_CATALOG = CCU.CONSTRAINT_CATALOG
			AND TC.CONSTRAINT_SCHEMA = CCU.CONSTRAINT_SCHEMA
			AND TC.CONSTRAINT_NAME = CCU.CONSTRAINT_NAME
		INNER JOIN INFORMATION_SCHEMA.COLUMNS IC ON ic.TABLE_NAME = tc.TABLE_NAME AND ic.COLUMN_NAME = ccu.COLUMN_NAME
		WHERE  TC.CONSTRAINT_SCHEMA = 'dbo'
			   AND (TC.CONSTRAINT_TYPE = 'UNIQUE' OR (TC.CONSTRAINT_TYPE = 'PRIMARY KEY' AND ic.DATA_TYPE <> 'INT'))
			   AND TC.TABLE_NAME = @referenced_table
		GROUP BY CCU.COLUMN_NAME
		
		UPDATE #reference_table_unique_columns
		SET relation_query = '''' + unique_columns + ' = '''''' + ' +  '(SELECT ISNULL(CAST(' + unique_columns + ' AS VARCHAR(MAX)), ''NULL'')   FROM ' + @referenced_table + ' WHERE CAST(' + @referenced_column + '  AS VARCHAR(MAX)) = ' + REPLACE(REPLACE(LEFT(@column_value, len(@column_value) - 6), ''''''''' +', ''), '+''''''''', '')  + ') + '''''''''
		
		SET @where = NULL
		SELECT @where = COALESCE(@where + ' + '' AND '' + ', '') + relation_query
		FROM   #reference_table_unique_columns

		SET @where = LEFT(@where, len(@where) - 2)
		SET @where = @where + ''')'''
		
		SET @column_value = 'ISNULL(''(SELECT ' + @referenced_column + ' FROM ' + @referenced_table + ' WHERE '' + ' + @where + ', ''NULL'')'
		SET @column_value = @column_value + ' + ''''' + '+' +  ''',''' + ' + '		
	END
	
	-- Build the test string to check if record exists	
	IF EXISTS(SELECT 1 FROM #unique_testing_list WHERE column_name = @Column_Name)
	BEGIN
		
		SET @key_where = @key_where + CASE WHEN @key_where = '' THEN ' WHERE ' ELSE ' + '' AND ' END  + @Column_Name + ' = '' + ' + @column_value
		SET @key_where = LEFT(@key_where, len(@key_where) - 6)
		
	END
	
	SET @Actual_Values = @Actual_Values + @column_value
	
	--Generating the column list for the INSERT statement
	SET @Column_List = @Column_List +  @Column_Name + ','	
	
	SKIP_LOOP: --The label used in GOTO

	SELECT 	@Column_ID = MIN(ORDINAL_POSITION) 
	FROM 	INFORMATION_SCHEMA.COLUMNS (NOLOCK) 
	WHERE 	TABLE_NAME = @table_name AND 
	ORDINAL_POSITION > @Column_ID AND
	(@owner IS NULL OR TABLE_SCHEMA = @owner)
--Loop ends here!
END
	
--To get rid of the extra characters that got concatenated during the last run through the loop
SET @Column_List = LEFT(@Column_List,len(@Column_List) - 1)
SET @Actual_Values = LEFT(@Actual_Values,len(@Actual_Values) - 6)

IF EXISTS(SELECT 1 FROM #unique_testing_list)
BEGIN
	SET @key_check = 'IF NOT EXISTS (SELECT 1 FROM ' + '[' + RTRIM(COALESCE(@target_table,@table_name)) + ']'  
	SET @key_check = '''' + @key_check + ' ' +  @key_where + ' + '' ) '
END

IF LTRIM(@Column_List) = '' 
BEGIN
	RAISERROR('No columns to select. There should at least be one column to generate the output',16,1)
	RETURN -1 --Failure. Reason: Looks like all the columns are ommitted using the @cols_to_exclude parameter
END

--Forming the final string that will be executed, to output the INSERT statements
IF (@include_column_list <> 0)
BEGIN
	SET @Actual_Values = 
		'SELECT ' +  
		CASE WHEN @top IS NULL OR @top < 0 THEN '' ELSE ' TOP ' + LTRIM(STR(@top)) + ' ' END 
		+ ISNULL(@key_check, '''') + 
		'' + RTRIM(@Start_Insert) + 
		' '' + ' + '''(' + RTRIM(@Column_List) +  ''' + ' + ''')''' + 
		' + ''VALUES('' + ' +  @Actual_Values  + ' + '')''' + '' + COALESCE(@from,' FROM   ' + CASE WHEN @owner IS NULL THEN '' ELSE ' [' + LTRIM(RTRIM(@owner)) + '].' END + ' [' + rtrim(@table_name) + ']' + '(NOLOCK)')
END
ELSE IF (@include_column_list = 0)
BEGIN
	SET @Actual_Values = 
		'SELECT ' + 
		CASE WHEN @top IS NULL OR @top < 0 THEN '' ELSE ' TOP ' + LTRIM(STR(@top)) + ' ' END + 
		+ ISNULL(@key_check, '''') + 
		'' + RTRIM(@Start_Insert) + 
		' '' +''VALUES(''+ ' +  @Actual_Values + '+'')''' + ' ' + 
		COALESCE(@from,' FROM ' + CASE WHEN @owner IS NULL THEN '' ELSE '[' + LTRIM(RTRIM(@owner)) + '].' END + '[' + rtrim(@table_name) + ']' + '(NOLOCK)')
END	

--Determining whether to ouput any debug information
IF @debug_mode =1
	BEGIN
		EXEC spa_print '/*****START OF DEBUG INFORMATION*****'
		EXEC spa_print 'Beginning of the INSERT statement:'
		EXEC spa_print @Start_Insert
		EXEC spa_print ''
		EXEC spa_print 'The column list:'
		EXEC spa_print @Column_List
		EXEC spa_print ''
		EXEC spa_print 'The SELECT statement executed to generate the INSERTs'
		EXEC spa_print @Actual_Values
		EXEC spa_print ''
		EXEC spa_print '*****END OF DEBUG INFORMATION*****/'
		EXEC spa_print ''
	END

--Determining whether to EXEC spa_print IDENTITY_INSERT or not
IF (@IDN <> '')
	BEGIN
		
		DECLARE @table_name1 VARCHAR(1000)
		SET @table_name1 = 'SET IDENTITY_INSERT ' + QUOTENAME(COALESCE(@owner,USER_NAME())) + '.' + QUOTENAME(@table_name) + ' ON'

		EXEC spa_print @table_name1
		EXEC spa_print 'GO'
		EXEC spa_print ''
	END


IF @disable_constraints = 1 AND (OBJECT_ID(QUOTENAME(COALESCE(@owner,USER_NAME())) + '.' + @table_name, 'U') IS NOT NULL)
	BEGIN
		IF @owner IS NULL
			BEGIN
				SELECT 	'ALTER TABLE ' + QUOTENAME(COALESCE(@target_table, @table_name)) + ' NOCHECK CONSTRAINT ALL' AS '--Code to disable constraints temporarily'
			END
		ELSE
			BEGIN
				SELECT 	'ALTER TABLE ' + QUOTENAME(@owner) + '.' + QUOTENAME(COALESCE(@target_table, @table_name)) + ' NOCHECK CONSTRAINT ALL' AS '--Code to disable constraints temporarily'
			END

		EXEC spa_print 'GO'
	END

DECLARE @print_str VARCHAR(1000)
SET @print_str =  'PRINT ''Inserting values into ' + '[' + RTRIM(COALESCE(@target_table,@table_name)) + ']' + ''''
EXEC spa_print  @print_str


--All the hard work pays off here!!! You'll get your INSERT statements, when the next line executes!
IF OBJECT_ID('tempdb..#temp_insert_scripts') IS NOT NULL
	DROP TABLE #temp_insert_scripts
CREATE TABLE #temp_insert_scripts (scripts VARCHAR(MAX) COLLATE DATABASE_DEFAULT)
exec spa_print @Actual_Values

INSERT INTO #temp_insert_scripts
EXEC(@Actual_Values)

IF @output_table IS NOT NULL
BEGIN
	DECLARE @sql VARCHAR(1000)
	SET @sql = 'INSERT INTO ' + @output_table + '
				SELECT REPLACE(REPLACE(scripts, '' = NULL'', '' IS NULL ''), '' = ''''NULL'''''', '' IS NULL '')
	            FROM   #temp_insert_scripts
				GROUP BY scripts'
	exec spa_print @sql
	EXEC(@sql)	
END
ELSE
BEGIN
	SELECT REPLACE(REPLACE(scripts, '= NULL', ' IS NULL '), ' = ''NULL''', ' IS NULL ') FROM #temp_insert_scripts GROUP BY scripts
END

EXEC spa_print 'PRINT ''Done'''
EXEC spa_print ''


IF @disable_constraints = 1 AND (OBJECT_ID(QUOTENAME(COALESCE(@owner,USER_NAME())) + '.' + @table_name, 'U') IS NOT NULL)
BEGIN
	IF @owner IS NULL
		BEGIN
			SELECT 	'ALTER TABLE ' + QUOTENAME(COALESCE(@target_table, @table_name)) + ' CHECK CONSTRAINT ALL'  AS '--Code to enable the previously disabled constraints'
		END
	ELSE
		BEGIN
			SELECT 	'ALTER TABLE ' + QUOTENAME(@owner) + '.' + QUOTENAME(COALESCE(@target_table, @table_name)) + ' CHECK CONSTRAINT ALL' AS '--Code to enable the previously disabled constraints'
		END

	EXEC spa_print 'GO'
END

EXEC spa_print ''
IF (@IDN <> '')
BEGIN
	DECLARE @print_str1 VARCHAR(1000)
	SET @print_str1 = 'SET IDENTITY_INSERT ' + QUOTENAME(COALESCE(@owner,USER_NAME())) + '.' + QUOTENAME(@table_name) + ' OFF'
	EXEC spa_print @print_str1
	EXEC spa_print 'GO'
END

EXEC spa_print 'SET NOCOUNT OFF'


SET NOCOUNT OFF
RETURN 0 --Success. We are done!
END

GO

EXEC spa_print 'Created the procedure'
GO


--Mark procedure as system object
EXEC sys.sp_MS_marksystemobject spa_generate_insert_scripts
GO

SET NOCOUNT OFF
GO

EXEC spa_print 'Done'

