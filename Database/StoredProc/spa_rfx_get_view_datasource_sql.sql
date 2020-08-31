

IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].spa_rfx_get_view_datasource_sql') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].spa_rfx_get_view_datasource_sql
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ============================================================================================================================
-- Create date: 2013-06-14
-- Author : ssingh@pioneersolutionsglobal.com
-- Description: Returns the TSQL of the View or SQL source Alias used in the SQL source
-- The view alias must be enclosed in {}.
-- For eg: SELECT * FROM {MTM_VIEW} mtm
-- This procedure replaces the {MTM_VIEW} with the actaul code of the view
               
--Params:
--@datasource_sql VARCHAR(MAX): SQL of SQL source
--@data_source_process_id	VARCHAR(200) : process_id 
--@validate					BIT	: 0 = execute the replaced view,1 = validate the replaced view.
--@criteria					VARCHAR(MAX)  : criteria of the source
--@paramset_id				INT  : paramset_id of the dataset that contain refered view
--@with_criteria            CHAR(1): n = criteria has not been provided, y = criteria has been provided
--@final_sql				VARCHAR(MAX) OUTPUT: TSQL of the  View Alias used in the SQL source
--@required_cols			VARCHAR(MAX)  OUTPUT: The list of names of columns of a refered view that are used as parameters.
-- ============================================================================================================================

CREATE PROCEDURE [dbo].spa_rfx_get_view_datasource_sql
	@datasource_sql				VARCHAR(MAX)
	, @data_source_process_id	VARCHAR(200)
	, @validate					BIT	= 0
	, @criteria					VARCHAR(MAX) = NULL
	, @paramset_id				INT = NULL
	, @with_criteria            CHAR(1)= NULL
	, @final_sql				VARCHAR(MAX) OUTPUT 
	, @required_cols			VARCHAR(MAX)  OUTPUT
AS
--/* ------------------------------------------------TEST SCRIPT------------------------------------------------*/
/*
DECLARE @datasource_sql				VARCHAR(MAX)
	, @data_source_process_id	VARCHAR(200)
	, @validate					BIT	= 0
	, @paramset_id				INT = NULL
	, @with_criteria            CHAR(1)= 'n'
	, @final_sql				VARCHAR(MAX) --OUTPUT 
	, @required_cols			VARCHAR(MAX) 
	
SET	@datasource_sql = 'SELECT mtm_view.source_deal_header_id AS [MTM_sousource_deal_header_id],
       mtm_view.deal_id AS [MTM_deal_id],
       mtm_view.deal_date [MTM_deal_date],
       mtm_view.[Charge Type ID] AS [Charge_Type_ID],
       mtm_view.[Charge TYPE] AS [Charge_TYPE],
       mtm_view.[Credit Adjusted MTM] AS [Credit_Adjusted_MTM]
		FROM   {mtm_view} mtm
       INNER JOIN {sdh_view} sdh
            ON  sdh.source_deal_header_id = mtm.source_deal_header_id'				
SET @data_source_process_id	= '7D32C5E3_4B4C_43E9_B60D_6683FBF65114'
SET @validate	=	1			
SET @paramset_id =	NULL			
	
--*/
/*---------------------------------------------------------------------------------------------------------------*/
DECLARE @rfx_report_dataset VARCHAR(200) 
DECLARE @rfx_data_source	VARCHAR(200) 
DECLARE @user_name          VARCHAR(100) = dbo.FNADBUser()  
DECLARE @sql				VARCHAR(MAX)

IF OBJECT_ID('tempdb..#temp_map') IS NOT NULL
	DROP TABLE #temp_map
CREATE TABLE #temp_map
		(
			start_index				INT	
			,view_name               VARCHAR(100) COLLATE DATABASE_DEFAULT 
			,source_id				INT
			, ALIAS					VARCHAR(100) COLLATE DATABASE_DEFAULT 
		)
--SELECT  * FROM 	#temp_map

/*
* Replace the Single quotes with double quotes.
* Single quotes are required to be replaced since first the @datasource_sql is treated as a string only
* Or else it gives escaping error.
*/

IF CHARINDEX('''', @datasource_sql, 0) > 0
BEGIN
	SET @datasource_sql = REPLACE(@datasource_sql, '''','''''')
END



IF @validate = 1   --Retrive the refered view or sql source alias name list from the proces table while the dataset is being saved.
BEGIN 
	SET @rfx_report_dataset = dbo.FNAProcessTableName('report_dataset', @user_name, @data_source_process_id)
	SET @rfx_data_source = dbo.FNAProcessTableName('data_source', @user_name, @data_source_process_id)
	
	SET @sql = 'INSERT INTO #temp_map (start_index,view_name, source_id, Alias)
		SELECT pos_alias_name.n
		     ,''{'' + rrd.alias +''}''
			 , source_id	
			 , alias		
		FROM ' + @rfx_report_dataset +' rrd
		LEFT JOIN dbo.seq pos_alias_name ON pos_alias_name.n <= LEN(''' + @datasource_sql +''')
		AND SUBSTRING(''' + @datasource_sql +''', pos_alias_name.n, LEN(''{'' + rrd.alias +''}''))  =''{'' + rrd.alias +''}''
		WHERE pos_alias_name.n IS NOT NULL
		'
	EXEC spa_print @sql
	EXEC (@sql)
END 
ELSE IF @validate = 0  --Retrive the refered view or sql source alias name list from the physical table while the query is being built.
BEGIN 
	SET @sql = 'INSERT INTO #temp_map (start_index,view_name, source_id, Alias)
		SELECT pos_alias_name.n
		     ,''{'' + rd.alias +''}''
			 , source_id	
			 , rd.alias	
		FROM report_paramset rp
		INNER JOIN report_page rpage ON rpage.report_page_id = rp.page_id
		INNER JOIN report_dataset rd ON rd.report_id = rpage.report_id
		INNER JOIN data_source ds ON rd.source_id = ds.data_source_id 
		LEFT JOIN dbo.seq pos_alias_name ON pos_alias_name.n <= LEN(''' + @datasource_sql +''')
		AND SUBSTRING(''' + @datasource_sql +''', pos_alias_name.n, LEN(''{'' + rd.alias +''}''))  = ''{'' + rd.alias +''}''
		WHERE rp.report_paramset_id = ' + CAST(@paramset_id AS VARCHAR(8000))  + '
		AND pos_alias_name.n IS NOT NULL
		'
	EXEC spa_print @sql
	EXEC (@sql)
END 
--	AND ds.[type_id] = 1
--SELECT * FROM #temp_map
--RETURN

--Replace the datasource with the actaul view and return required parameters  for the criteria to be processed
IF @validate = 1 AND @with_criteria = 'n'  
BEGIN
	SELECT @datasource_sql = REPLACE(
										@datasource_sql
										, tm.[view_name]
										,   '(' + MAX(ds.[tsql]) + ')' 
									)
	FROM #temp_map tm
	INNER JOIN data_source ds ON ds.data_source_id = tm.source_id
	GROUP BY start_index,tm.[view_name]
	ORDER BY start_index DESC --start replacing the source from the end such that the position of the alias doesnt change.

	SELECT @final_sql = CAST('' AS VARCHAR(MAX)) + @datasource_sql

	SELECT @required_cols = STUFF(( 
					SELECT ', ' + 
					tm.alias + '.'+  dsc.[name]
					FROM data_source ds
					INNER JOIN data_source_column dsc ON dsc.source_id = ds.data_source_id
					INNER JOIN #temp_map tm ON tm.source_id = ds.data_source_id
					--WHERE dsc.reqd_param = 1
					WHERE dsc.required_filter is not null
					FOR XML PATH(''), TYPE).value('.[1]', 'VARCHAR(8000)'), 1, 1, '')	


	SELECT @final_sql  AS [final_sql], @required_cols AS [reqd_cols]
END 


--SELECT  * FROM   #temp_map
--Actaully run the datasource_sql after the refered view has been replaced with the actual view.
/*
* First it executes the actaul code refered by the view or sql sources alias.
* If the refered view was a batch process it dumps the data to a temp table and replaces the refered view with table name
* Else if not the actual code is replaced. 
* */

IF @with_criteria = 'y' 
BEGIN
	EXEC spa_print '1111111111111111111111111111111111'

	DECLARE	@data_source_tsql	VARCHAR(MAX)
	DECLARE @data_source_alias	VARCHAR(100)
	DECLARE @batch_identifier	VARCHAR(20) = '--[__batch_report__]'	
		

	DECLARE cur_data_source CURSOR LOCAL FOR
	
	SELECT DISTINCT ds.[tsql],ds.ALIAS
	FROM #temp_map tm
	INNER JOIN data_source ds ON ds.data_source_id = tm.source_id
	
	OPEN cur_data_source   
	FETCH NEXT FROM cur_data_source INTO @data_source_tsql, @data_source_alias
	
	WHILE @@FETCH_STATUS = 0   
	BEGIN
		EXEC spa_rfx_handle_data_source
			@data_source_tsql			
			, @data_source_alias		
			, @criteria					
			, @data_source_process_id	
			, 0	--@validate				
			, 0	--@handle_single_line_sql
		FETCH NEXT FROM cur_data_source INTO @data_source_tsql, @data_source_alias
	END	
	
	CLOSE cur_data_source   
	DEALLOCATE cur_data_source


--SELECT  * FROM @temp_map
  
	SELECT @datasource_sql = REPLACE(
									@datasource_sql
									, tm.[view_name]
									,  CASE WHEN @with_criteria = 'n'
												THEN '(' + MAX(ds.[tsql]) + ')' 
											WHEN  @with_criteria = 'y'
												THEN 
													CASE WHEN CHARINDEX(@batch_identifier, MAX(ds.[tsql])) > 0 
																THEN dbo.FNAProcessTableName('report_dataset_' + MAX(ds.[alias]), dbo.FNADBUser(), @data_source_process_id) 
															ELSE '(' + MAX(ds.[tsql]) + ')' 
													END
										END
								)
--SELECT tm.[start_index],tm.[view_name],max(ds.[tsql])
	FROM #temp_map tm
	INNER JOIN data_source ds ON ds.data_source_id = tm.source_id
	GROUP BY start_index,tm.[view_name]
	ORDER BY start_index DESC --start replacing the source from the end such that the position of the alias doesnt change.

/*
* In the case when a parameter of the @final_sql is placed inside quotes eg:
*    select * from {cev} c where c.book_id = '@book_id'
* then it is passed as 
*	'select * from {cev} c where c.book_id = ''@book_id''' (single quote becomes double).
* The double quote creates a escape character due to which the query is malformed.
* To over come this first  
* 1.Replace the Single quotes with '$'
* 2.Then replace the double dollar signs '$$' with a single quote.
* 3.In case the view used itself contains single quotes they will already be replaced with $ 
*   by the replacement above which should be reverted so a single $ is replaced with a single quote again.
* Double quotes are required to be replaced since it gives escaping error while execution the query.	
*/
--SELECT @datasource_sql
--return
	IF CHARINDEX('''', @final_sql, 0) > 0
	BEGIN
		--SET @datasource_sql = REPLACE(REPLACE(@datasource_sql,'''','_'),'__','''')
		SET @datasource_sql = REPLACE(REPLACE(REPLACE(@datasource_sql,'''','$'),'$$',''''), '$' ,'''')
	END

	SELECT @final_sql = CAST('' AS VARCHAR(MAX)) + @datasource_sql
END
--RETURN
