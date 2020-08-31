/****** Object:  StoredProcedure [dbo].[spa_manual_archive_data]    Script Date: 05/05/2014 11:38:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_archive_dependent_data]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_archive_dependent_data]
GO


/****** Object:  StoredProcedure [dbo].[spa_manual_archive_data]    Script Date: 26/05/2014 11:38:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===============================================================================================================
-- Create date: 2014-05-26
-- Description:	Performs Archiving of dependent data based on ID and not related to date
-- Params:
--	@main_table				VARCHAR(128), 
--	@process_id				VARCHAR(128)
-- ===============================================================================================================

CREATE PROCEDURE [dbo].[spa_archive_dependent_data]
	@main_table				VARCHAR(128), 
	@process_id				VARCHAR(128),
	@is_arch_table			INT
	
AS

--SET NOCOUNT ON;
BEGIN 
	DECLARE @formula_table		VARCHAR(128)
	DECLARE @formula_table1		VARCHAR(128)
	DECLARE @user_login_id		VARCHAR(100)
	DECLARE @tbl_name			VARCHAR(128)
	DECLARE @whr_field			VARCHAR(500)
	DECLARE @row_cnt			INT
	DECLARE @sql				VARCHAR(5000)
	DECLARE @fq_table_to		VARCHAR(128)
	declare @fq_table_from		VARCHAR (128)
		DECLARE @ColumnList VARCHAR(MAX)
	
	IF @user_login_id IS NULL
	SET @user_login_id = dbo.FNADBUser()
-- identifying sequence to archive child table first if the archival is from main to arch table 
--RETURN
SET @formula_table=dbo.FNAProcessTableName(@main_table + '_', @user_login_id, @process_id)
SET @formula_table1=dbo.FNAProcessTableName(@main_table , @user_login_id, @process_id)
PRINT @formula_table
IF OBJECT_ID('tempdb..#arch_list_1') IS NOT NULL
	DROP TABLE #arch_list_1
CREATE TABLE #arch_list_1
(
table_name VARCHAR(128),
where_field VARCHAR(500)
) 
--IF OBJECT_ID('tempdb..#id_date_map') IS NOT NULL
--	DROP TABLE #id_date_map
--CREATE TABLE #id_date_map
--(
--	id			INT , 
--	as_of_date	DATETIME
--	)

IF @is_arch_table = 1 
BEGIN 
INSERT INTO #arch_list_1 (table_name, where_field)
		SELECT dependent_table, child_column 
		FROM archive_dependency 
		WHERE main_table = @main_table
		ORDER BY arch_seq DESC

END 
ELSE
BEGIN
	PRINT 'is here'
INSERT INTO #arch_list_1 (table_name, where_field)
		SELECT dependent_table , child_column 
		FROM archive_dependency 
		WHERE main_table = @main_table
		ORDER BY arch_seq 
	
END
	
DECLARE tbl_main_cursor CURSOR LOCAL FOR
	
	SELECT  table_name, where_field
	FROM #arch_list_1
	
	OPEN tbl_main_cursor
	SET XACT_ABORT ON
	--IF EXISTS(SELECT 1 
	--			  FROM archive_data_policy_detail 
	--			  WHERE table_name = @main_table AND is_arch_table = 0
	--			  AND ISNULL(CHARINDEX('.', archive_db), 0) <> 0)
	--	BEGIN 
	--		BEGIN DISTRIBUTED TRAN
	--	END
	--ELSE
	--	BEGIN	
	--		BEGIN TRAN
	--	END
	FETCH NEXT FROM tbl_main_cursor INTO  @tbl_name, @whr_field
	WHILE @@FETCH_STATUS = 0
	
		BEGIN 		
		--TRUNCATE TABLE #id_date_map
		PRINT @tbl_name
		PRINT @whr_field
		IF @is_arch_table = 1 
			BEGIN
				SET @fq_table_to = @tbl_name+ '_arch1'	
				SET @fq_table_from = @tbl_name
				
			END
		ELSE
			BEGIN
				SET @fq_table_to = @tbl_name
				SET @fq_table_from = @tbl_name + '_arch1'
			END
		
		PRINT @fq_table_to
		
		-- EXEC (@sql) 
		-- Existence check ie delete records from destination table if it exists 
		SET @sql = '
					DELETE t from ' + @fq_table_to + ' t 
					INNER JOIN '+@formula_table+' esd ON  t.' + @whr_field + ' = esd.d_id' 
			
			PRINT @sql
			EXEC (@sql)
			PRINT @tbl_name
		--- Now insert records in Destination table 
		
		
	SET @ColumnList = NULL
		
		
		--BEGIN
			IF EXISTS(SELECT * FROM sys.objects WHERE OBJECTPROPERTY(object_id,'TableHasIdentity') = 1 AND NAME = @fq_table_to)
			BEGIN
				
				SELECT @ColumnList = COALESCE(@ColumnList + ',a.', '') + COLUMN_NAME
				FROM information_schema.columns WHERE table_name = @tbl_name
				AND COLUMN_NAME NOT IN (SELECT NAME FROM sys.identity_columns WHERE sys.identity_columns.[object_id] = OBJECT_ID (@tbl_name))
				ORDER BY ORDINAL_POSITION
			END 
			ELSE
				BEGIN
					PRINT 'true'
					SELECT @ColumnList = COALESCE(@ColumnList + ',a.', '') + COLUMN_NAME
					FROM information_schema.columns WHERE table_name = @tbl_name
					--AND COLUMN_NAME NOT IN (SELECT NAME FROM sys.identity_columns WHERE sys.identity_columns.[object_id] = OBJECT_ID (@tbl_name))
					ORDER BY ORDINAL_POSITION
				END
		 
		 PRINT @tbl_name
		
		 PRINT @ColumnList
		 IF @is_arch_table = 0 
			BEGIN 
		 	
				SET @ColumnList = 'a.' + @ColumnList
				SET @ColumnList = REPLACE (@ColumnList, 'a.calc_id', 'c.calc_id') 
			END 
			IF @is_arch_table <> 1 
			BEGIN 
				SET @sql = '  
						INSERT INTO ' + @fq_table_to + ' ( ' + @ColumnList + ')
							 SELECT '+ @ColumnList+' 
								FROM ' + @fq_table_from + ' a inner join '+@formula_table+' b on a.'+@whr_field+' = b.d_id
								INNER JOIN ' +@formula_table1+ ' c on b.d_id = c.old_id'
			END 
			ELSE
				BEGIN 
				SET @sql = '  
					INSERT INTO ' + @fq_table_to + ' ( ' + @ColumnList + ')
						 SELECT '+ @ColumnList+' 
							FROM ' + @fq_table_from + ' a inner join '+@formula_table+' b on a.'+@whr_field+' = b.d_id
							'
				END 
				
									
			--PRINT ('INSERT:' + ISNULL(@sql, 'NULL'))
			PRINT @sql
			EXEC(@sql);
			
			-- deleting records from source table 
			SET @sql = '
					DELETE t from ' + @fq_table_from + ' t 
					INNER JOIN '+@formula_table+' esd ON  t.' + @whr_field + ' = esd.d_id' 
			
			PRINT @sql
			EXEC (@sql)
			--- deleting records from process_table_location if exists 
			
			---- inserting corresponding date relevant to particular ID in temp table 
			--SET @sql = ('insert into #id_date_map(id,as_of_date) select distinct  p.id, m.prod_date from '+@formula_table +' p inner join '+ @fq_table_to+' m on p.id = m.'+ @whr_field+'')
			--PRINT @sql
			--EXEC (@sql)
			
			---- Deleting records in process_table_location  if exists
			--DELETE process_table_location
			--FROM process_table_location ptl
			--INNER JOIN #id_date_map esd ON ptl.as_of_date = esd.as_of_date
			--WHERE  tbl_name = @tbl_name
			
			DECLARE @a VARCHAR(100) 
			SET @a = REPLACE (@fq_table_to,@tbl_name,'')
			PRINT @a
			
			--SET @sql = 'INSERT INTO process_table_location (as_of_date, prefix_location_table, dbase_name, tbl_name)
			--SELECT m.as_of_Date, REPLACE('+@fq_table_to+', '+@tbl_name+','') ,dbo,'+@tbl_name+'
			--FROM  #id_date_map m 
			--'
			--PRINT @sql
			--EXEC (@sql)
			
			
		--END	
	
		
		FETCH NEXT FROM tbl_main_cursor INTO  @tbl_name, @whr_field	
		END 
		CLOSE tbl_main_cursor
		DEALLOCATE tbl_main_cursor


END 