

IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_Report_record]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_Report_record]
GO

/****** Object:  StoredProcedure [dbo].[spa_Report_record]    Script Date: 07/24/2009 17:30:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[spa_Report_record]
	@flag char(1)=null,
	@report_id int=null,
	@report_name varchar(200)=null,
	@report_owner varchar(200)=null,
	@report_tablename varchar(100)=null,
	@report_groupby varchar(5000)=null,
	@report_where varchar(5000)=null,
	@report_having varchar(5000)=null,
    @report_orderby varchar(5000)=null,
	@report_sql_statement varchar(max)=null,
    @report_public char(1)='y',
    @report_internal_description char(1)=null,
    @report_sql_check char(1)=null ,
	@report_category_id int=null
AS
SET NOCOUNT ON 

DECLARE @sql VARCHAR(5000)
DECLARE @report_id1 INT

DECLARE @db_user VARCHAR(100)
SELECT  @db_user =  dbo.FNADBUser() 

IF @flag='i'
BEGIN
	IF EXISTS(SELECT 1 FROM Report_record WHERE report_name = @report_name)
		EXEC spa_ErrorHandler -1
			, 'Report name already exists.'
			, 'spa_Report_record'
			, 'DB Error'
			, 'Report name already exists.'
			, ''
	ELSE
	BEGIN
		INSERT INTO Report_record(
			report_name ,
			report_owner ,
			report_tablename ,
			report_groupby,
			report_where ,
			report_having,
			report_orderby,
   			report_sql_statement,
			report_public,
			report_internal_description,
			report_sql_check,
			report_category_id)
		VALUES(
			@report_name ,
			@report_owner ,
			@report_tablename, 
			@report_groupby,
			@report_where ,
			@report_having,
			@report_orderby,
			@report_sql_statement,
			@report_public,
			@report_internal_description,
			@report_sql_check,
			@report_category_id

		     
		)

		SELECT @report_id1 = SCOPE_IDENTITY() 

		IF @@ERROR <> 0
			EXEC spa_ErrorHandler @@ERROR
				, 'Report_record'
				, 'spa_Report_recordl'
				, 'DB Error'
				, 'Error Inserting Report_record.'
				, ''
		ELSE
			EXEC spa_ErrorHandler 0
				, 'Report_record'
				, 'spa_Report_record'
				, 'Success'
				, 'Report_record Inputs successfully inserted.'
				, @report_id1
	END
END
ELSE IF @flag = 'u'
BEGIN
	IF EXISTS(SELECT 1 FROM Report_record WHERE report_name = @report_name AND report_id <> @report_id)
		EXEC spa_ErrorHandler -1
			, 'Report name already exists.'
			, 'spa_Report_record'
			, 'DB Error'
			, 'Report name already exists.'
			, ''
	ELSE
	BEGIN
		UPDATE	Report_record
			SET report_name = @report_name ,
				report_owner = @report_owner ,
				report_tablename = @report_tablename, 
				report_groupby = @report_groupby,
				report_where = @report_where ,
				report_having = @report_having,
				report_orderby = @report_orderby,
				report_sql_statement = @report_sql_statement,
				report_public = @report_public,
				report_internal_description = @report_internal_description,
				report_category_id = @report_category_id
		WHERE	report_id = @report_id

		IF @@ERROR <> 0
			EXEC spa_ErrorHandler @@ERROR
				, 'Report_record'
				, 'spa_Report_recordl'
				, 'DB Error'
				, 'Error Updating Report_record.'
				, ''
		ELSE
			EXEC spa_ErrorHandler 0
				, 'Report_record'
				, 'spa_Report_record'
				, 'Success'
				, 'Report_record successfully udated.'
				, ''
	END
END
ELSE IF @flag ='a' 
BEGIN
	 SELECT report_name,
			report_owner,
			report_tablename,
			report_groupby,
			report_where,
			report_having,
			report_orderby,
			report_public,
			report_internal_description,
			report_sql_check,
			rwt.id AS table_id,   
			report_category_id,
			report_sql_statement		
	 FROM Report_record rr
	 LEFT JOIN report_writer_table rwt ON rr.report_tablename = rwt.table_name
	 WHERE report_id = @report_id 
END
ELSE IF @flag = 'd'
BEGIN
	 DELETE report_writer_column WHERE report_id in (select * from dbo.SplitCommaSeperatedValues(@report_id))
	 DELETE Report_record WHERE report_id in (select * from dbo.SplitCommaSeperatedValues(@report_id))

	IF @@ERROR <> 0
	BEGIN
		EXEC spa_ErrorHandler @@ERROR
			, 'Report Record'
			, 'spa_application_notes'
			, 'DB ERROR'
			, 'DELETE OF Report Record failed.'
			, ''
		END
	ELSE
		EXEC spa_ErrorHandler 0
			, 'Report Record'
			, 'spa_Report_record'
			, 'Success'
			, 'Report Record detail successfully selected.'
			, ''
END 
ELSE IF @flag='s'
BEGIN
	SET @sql = 'SELECT	a.report_id,
						a.report_name as [Report],
						a.report_groupby,
						a.report_having,
						a.report_orderby,
						a.report_tablename,
						a.report_sql_statement,
						CASE WHEN (a.report_internal_description = ''Y'') THEN ''System''  ELSE   a.report_owner end [Owner]	
				FROM Report_record a, report_writer_table b '

	SET @sql = @sql + 'where a.report_tablename=b.table_name ' 

	IF(@report_owner IS NOT NULL ) 
	BEGIN
		SET @sql = @sql + 'AND a.report_owner=''' + @report_owner + ''''
	END

	IF(@report_public IS NOT NULL) 
	BEGIN
		SET @sql = @sql + 'AND a.report_public=''' + @report_public + ''''
	END

	IF(@report_public IS NULL AND @report_owner IS  NULL) 
	BEGIN
		SET @sql = @sql + 'AND a.report_internal_description= ''Y'''
	END

	SET @sql = @sql + 'Order By Report'
	 
	--PRINT(@sql)
	EXEC(@sql)
END
ELSE IF @flag = 'z'
BEGIN
	SET @sql = 'SELECT report_name,report_owner,report_tablename FROM Report_record
				WHERE 1 = 1 ' 

	IF(@report_id IS NOT NULL)
		SET @sql = @sql + 'AND report_owner =''' + @report_owner + ''''

	IF(@report_public IS NOT NULL)
		SET @sql = @sql + 'AND report_public =''' + @report_public + ''''

	IF(@report_internal_description IS NOT NULL)
		SET @sql = @sql + 'AND report_internal_description=''' + @report_internal_description + ''''

	EXEC(@sql)
END
ELSE IF @flag = 'g'
BEGIN
	SELECT table_name FROM report_writer_table WHERE table_alias = (SELECT report_tablename FROM Report_record WHERE report_id = @report_id)
END
ELSE IF @flag='x' -- call from first page to display on the grid
BEGIN

	DECLARE @check_admin_role INT
	DECLARE @role_ids VARCHAR(MAX)
	SELECT @check_admin_role = ISNULL(dbo.FNAAppAdminRoleCheck(dbo.FNADBUser()), 0)
	
	DECLARE @check_report_admin_role INT
	SELECT @check_report_admin_role = ISNULL(dbo.FNAReportAdminRoleCheck(dbo.FNADBUser()), 0)
	
	SET @sql = 'SELECT a.report_id [Report ID]
	                  ,MAX(ISNULL(a.report_where ,'''')) [Report Where Clause]
	                  ,MAX(a.report_name) [Report Name]
	                  ,MAX(report_tablename) AS [View]
	                  , MAX(CASE WHEN (a.report_internal_description = ''Y '') THEN ''SYSTEM'' ELSE a.report_owner END) [Owner]
	                  ,MAX(sdv.code) [Category]
	                  ,MAX(report_internal_description) [Is System]
	                  , SUM(CASE WHEN c.filter_column = ''TRUE'' AND c.control_type = ''BSTREE'' THEN 1 ELSE 0 END ) [Tree Filter Required]
	                   --IMP: <> requires both operand to be NOT NULL, otherwise it returns false
	                  , SUM(CASE WHEN c.filter_column = ''TRUE'' AND ISNULL(c.control_type ,'''') <> ''BSTREE'' THEN 1 ELSE 0 END) [Other Filter Required]
	            FROM   Report_record a
				LEFT JOIN report_writer_table b ON  a.report_tablename = b.table_name
				LEFT JOIN report_writer_column c ON  a.report_id = c.report_id
				LEFT JOIN static_data_value sdv ON  a.report_category_id = sdv.value_id
				LEFT JOIN report_writer_privileges d ON d.report_writer_id = a.report_id
				LEFT JOIN application_role_user e ON d.role_id = e.role_id 		
	            WHERE  1 = 1 ' 
		
	SET @sql = @sql + CASE WHEN @report_internal_description IS NOT NULL THEN 'AND a.report_internal_description = ''' + ISNULL(@report_internal_description, 'n') + '''' ELSE '' END
					+ CASE WHEN @report_owner IS NOT NULL THEN ' AND a.report_owner ='''+@report_owner+'''' ELSE '' END 	
					+ CASE WHEN @report_category_id IS NOT NULL THEN ' AND report_category_id = '''+ CAST(@report_category_id AS VARCHAR) + '''' ELSE '' END 	
		
	IF @check_admin_role <> 1 AND @check_report_admin_role <> 1-- does not have admin role
	BEGIN
		SET @sql = @sql + ' AND (d.user_id = ''' + @db_user + ''' OR a.report_owner = ''' + @db_user + ''' OR d.role_id IN (SELECT role_id FROM dbo.FNAGetUserRole(''' + @db_user + ''')))'
	END
	
	SET @sql = @sql + ' GROUP BY a.report_id Order By [Report Name]'
	 
	--PRINT(@sql)
	EXEC(@sql)
END
ELSE IF @flag='r' 
BEGIN
    SET @sql = 'SELECT	a.report_id,
						a.column_id,
						a.column_selected,
						a.column_name,
						a.columns,
						a.column_alias,
						CASE WHEN R.where_required=''Y'' THEN ''true'' 
						 ELSE a.filter_column END filter_column,
						a.max,
						a.min,
						a.count,
						a.sum,
						a.average,
						isNull(UPPER(r.where_required),''N'') where_required,
						a.report_column_id,
						a.user_define,
						ISNULL(r.data_type, a.data_type) data_type,
						ISNULL(r.control_type, a.control_type) control_type,
						ISNULL(r.data_source, a.data_source) data_source, 
						ISNULL(r.default_value, a.default_value) default_value,
						ISNULL(UPPER(r.clm_type), ''N'') clm_type
				FROM Report_record b 
				INNER JOIN report_writer_column a ON b.report_id = a.report_id 
				LEFT OUTER JOIN report_where_column_required r ON r.column_name=a.column_name 
					AND	b.report_tablename = r.table_name ' 
					
	SET @sql = @sql + ' WHERE b.report_id = ' + CAST(@report_id AS VARCHAR) + ' ORDER BY a.column_id'
	
	--PRINT(@sql)
	EXEC(@sql)
END
ELSE IF @flag = 'c' -- Copy function
BEGIN
	BEGIN TRY
		BEGIN TRAN	
		/**
		* ------------------------Logic of copy function was changed to support multiple copy----------------------------
		* 
		* Temporary table #tmp_table_report_record was created to the save report ID of original report and copied report 
		* 
		* Data entry in table Report_record was done in two step
		* In 1st step original report ID was saved in report name of the copied report
		* In 2nd step report name of copied report was updated by the proper name
		* 
		* 
		**/
		
		CREATE TABLE #tmp_table_report_record (
			 org_report_id VARCHAR(100) COLLATE DATABASE_DEFAULT 
			 , copied_report_id VARCHAR(100) COLLATE DATABASE_DEFAULT  
		)
				
		INSERT INTO Report_record (
			report_name,
			report_owner,
			report_tablename,
			report_groupby,
			report_where ,
			report_having,
			report_orderby,
			report_sql_statement,
			report_public,
			report_internal_description,
			report_sql_check,
			report_category_id 
		) OUTPUT INSERTED.report_name, INSERTED.report_id INTO #tmp_table_report_record
		SELECT 
			rr.report_id,
			dbo.FNADBUser(),
			report_tablename ,
			report_groupby,
			report_where ,
			report_having,
			report_orderby,
			report_sql_statement,
			report_public,
			report_internal_description,
			report_sql_check,
			report_category_id 
		FROM Report_record rr
		INNER JOIN dbo.SplitCommaSeperatedValues(@report_id) scsv ON rr.report_id = scsv.item
		
		UPDATE rr	
		SET report_name = rpt_cnt.new_rpt_name	
		FROM Report_record rr
		INNER JOIN #tmp_table_report_record ttrr ON rr.report_id = ttrr.copied_report_id
		INNER JOIN Report_record rr_org ON ttrr.org_report_id = rr_org.report_id
		CROSS APPLY
		(
			SELECT '(' + CAST(COUNT(report_name) + 01 AS VARCHAR(10)) + ') Copy of ' + rr_org.report_name new_rpt_name
			FROM report_record
			WHERE report_name LIKE '(_) Copy of ' + rr_org.report_name
			 OR report_name LIKE '(__) Copy of ' + rr_org.report_name
			 OR report_name LIKE '(___) Copy of ' + rr_org.report_name	
		) rpt_cnt
	
		INSERT INTO report_writer_column(
			[report_id]
		  , [column_id]
		  , [column_selected]
		  , [column_name]
		  , [columns]
		  , [column_alias]
		  , [filter_column]
		  , [MAX]
		  , [MIN]
		  , [COUNT]
		  , [SUM]
		  , [average]
		  , [user_define]
		  , [data_type]
		  , [control_type]
		  , [data_source]
		  , [default_value]
		)
		SELECT 
			temp.copied_report_id
		  , [column_id]
		  , [column_selected]
		  , [column_name]
		  , [columns]
		  , [column_alias]
		  , [filter_column]
		  , [MAX]
		  , [MIN]
		  , [COUNT]
		  , [SUM]
		  , [average]
		  , [user_define]
		  , [data_type]
		  , [control_type]
		  , [data_source]
		  , [default_value]
		FROM [report_writer_column] rwc	
		INNER JOIN #tmp_table_report_record temp ON rwc.report_id = temp.org_report_id 
	
		/*
		--Uncomment this portion for copying privilage in copied report
		
		INSERT INTO report_writer_privileges(
			  [USER_ID]
			, [role_id]
			, [report_writer_ID] 
		)
		SELECT 
			  [USER_ID]
			, [role_id]
			, temp.copied_report_id 
		FROM report_writer_privileges rwp	
		INNER JOIN #tmp_table_report_record temp ON rwp.report_writer_ID = temp.org_report_id 
		*/	
		COMMIT
		EXEC spa_ErrorHandler 0
			, 'Report_record'
			, 'spa_Report_record'
			, 'Success'
			, 'Report_record Inputs successfully copied.'
			, ''
	END TRY
	BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK
		
	EXEC spa_ErrorHandler @@ERROR
		, 'Report_record'
		, 'spa_Report_recordl'
		, 'DB ERROR'
		, 'ERROR coping Report_record.'
		, ''		
	END CATCH			
END
ELSE IF @flag = 'f' --used in showing 'Applied Filter' in the final report (spa_html)
BEGIN
	SELECT  rr.report_id
			, rr.report_name
			, rwc.report_column_id
			, rwc.column_name
			, ISNULL(rwc.column_alias, rwc.column_name) AS column_alias
			, rwc.control_type
			, rwc.data_source
	FROM Report_record rr 
	LEFT JOIN report_writer_column rwc ON rr.report_id = rwc.report_id 
		AND rwc.filter_column = 'true'
	WHERE rr.report_id = @report_id
	ORDER BY rwc.column_id
END
ELSE IF @flag = 'y'
BEGIN
	SELECT rr.report_id, rr.report_name FROM Report_record rr
END
GO
