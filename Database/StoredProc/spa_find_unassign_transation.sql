SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[spa_find_unassign_transation]') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_find_unassign_transation]
GO
/*
/* SP Created By: Shushil Bohara
 * Created Dt: 28-June-2017
 * Description: Logic to display Assigned deals to Unassign
 * Logic is only for RPS Compliance and Sold/Transfer
 *
 */ 
* */
   
CREATE PROCEDURE [dbo].[spa_find_unassign_transation]   
	  @flag CHAR(1)						= NULL, 
	  @fas_sub_id  VARCHAR(5000)        = NULL,
	  @fas_strategy_id  VARCHAR(5000)   = NULL,
	  @fas_book_id VARCHAR(5000)        = NULL,
	  @assignment_type INT   			= NULL,
	  @assigned_state INT    			= NULL,
	  @tier_value_id INT				= NULL,
	  @compliance_year INT				= NULL,
	  @assigned_dt_from	DATETIME		= NULL,
	  @assigned_dt_to	DATETIME		= NULL,
	  @volume			INT				= NULL,
	  @deal_id VARCHAR(5000)			= NULL,
	  @counterparty_id INT				= NULL,
	  @gen_date_from DATETIME			= NULL,
	  @gen_date_to DATETIME  			= NULL,
	  @debug BIT					    = 0,
	  @batch_process_id VARCHAR(50)     = NULL,
	  @batch_report_param VARCHAR(1000) = NULL,
	  @enable_paging INT                = 0,
	  @page_size INT				    = NULL,
	  @page_no INT					    = NULL
 AS
 
/**************************TEST CODE START************************				
DECLARE	
	 @flag CHAR(1)						= NULL, 
	  @fas_sub_id  VARCHAR(5000)        = NULL,
	  @fas_strategy_id  VARCHAR(5000)   = NULL,
	  @fas_book_id VARCHAR(5000)        = NULL,
	  @assignment_type INT   			= NULL,
	  @assigned_state INT    			= NULL,
	  @tier_value_id INT				= NULL,
	  @compliance_year INT				= NULL,
	  @assigned_dt_from	DATETIME		= NULL,
	  @assigned_dt_to	DATETIME		= NULL,
	  @volume			INT				= NULL,
	  @deal_id VARCHAR(5000)			= NULL,
	  @counterparty_id INT				= NULL,
	  @gen_date_from DATETIME			= NULL,
	  @gen_date_to DATETIME  			= NULL,
	  @debug BIT					    = 0,
	  @batch_process_id VARCHAR(50)     = NULL,
	  @batch_report_param VARCHAR(1000) = NULL,
	  @enable_paging INT                = 0,
	  @page_size INT				    = NULL,
	  @page_no INT					    = NULL

SELECT	  
@flag='u',@fas_sub_id='1694',@fas_strategy_id='1705',@fas_book_id='1707',@assignment_type='5146',@assigned_state='401435',@tier_value_id=NULL,@compliance_year=null,@assigned_dt_from=NULL,@assigned_dt_to=NULL,@volume=7296600,@deal_id=NULL,@counterparty_id=NULL,@gen_date_from=NULL,@gen_date_to=NULL	  


--**************************TEST CODE END************************/								
SET NOCOUNT ON    
IF OBJECT_ID('tempdb..#temp_deals') IS NOT NULL DROP TABLE #temp_deals 
IF OBJECT_ID('tempdb..#ssbm_rec') IS NOT NULL DROP TABLE #ssbm_rec
IF OBJECT_ID('tempdb..#tmp_finalized_deals') IS NOT NULL DROP TABLE #tmp_finalized_deals
-------------------------------------------    
  
 DECLARE @Sql_Select VARCHAR(MAX), @table_name VARCHAR(100)
 DECLARE @pr_name VARCHAR(5000)  
 DECLARE @log_time DATETIME, @sales_rec VARCHAR(100)
 DECLARE @vol_rounding TINYINT = 5
   
 --IF @debug = 1  
 --BEGIN  
	--SET @log_increment = 1  
	--PRINT '******************************************************************************************'  
	--PRINT '********************START [Assignment Process]*******************'  
 --END  
    
/*******************************************1st Paging Batch START**********************************************/
 
	DECLARE @str_batch_table VARCHAR(8000)
	DECLARE @user_login_id VARCHAR(50)
	DECLARE @sql_paging VARCHAR(8000)
	DECLARE @is_batch BIT
 
	SET @str_batch_table = ''
	SET @user_login_id = dbo.FNADBUser() 
	SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END 

	SET @sales_rec = dbo.FNAProcessTableName('sales_rec_', @user_login_id, @batch_process_id)
 
	IF @is_batch = 1
	   SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)
 
	IF @enable_paging = 1 --paging processing
	BEGIN
	   IF @batch_process_id IS NULL
		  SET @batch_process_id = dbo.FNAGetNewID()
 
	   SET @str_batch_table = dbo.FNAPagingProcess('p', @batch_process_id, @page_size, @page_no)
 
	   --retrieve data from paging table instead of main table
	   IF @page_no IS NOT NULL 
	   BEGIN
		  SET @sql_paging = dbo.FNAPagingProcess('s', @batch_process_id, @page_size, @page_no) 
		  EXEC (@sql_paging) 
		  RETURN 
	   END
	END
 
	CREATE TABLE #ssbm_rec(    
		source_system_book_id1 INT,              
		source_system_book_id2 INT,              
		source_system_book_id3 INT,              
		source_system_book_id4 INT,              
		fas_deal_type_value_id INT,              
		book_deal_type_map_id INT,              
		fas_book_id INT,              
		stra_book_id INT,              
		sub_entity_id INT              
	)
	
	SET @Sql_Select=    
	'INSERT INTO #ssbm_rec              
	SELECT              
		source_system_book_id1,source_system_book_id2,source_system_book_id3,  
		source_system_book_id4,fas_deal_type_value_id,              
		book_deal_type_map_id,book.entity_id fas_book_id,book.parent_entity_id stra_book_id,  
		stra.parent_entity_id sub_entity_id               
	FROM source_system_book_map ssbm               
	INNER JOIN portfolio_hierarchy book (nolock) ON ssbm.fas_book_id = book.entity_id               
	INNER JOIN Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id               
	WHERE 1=1 ' +             
  
	CASE WHEN @fas_sub_id IS NOT NULL THEN ' AND stra.parent_entity_id IN  ( ' + @fas_sub_id + ') ' ELSE '' END +
	CASE WHEN @fas_strategy_id IS NOT NULL THEN ' AND (stra.entity_id IN(' + @fas_strategy_id + ' ))' ELSE '' END +
	CASE WHEN @fas_book_id IS NOT NULL THEN ' AND (book.entity_id IN(' + @fas_book_id + ')) ' ELSE '' END
  
	IF @debug = 1
	PRINT @sql_select             
	EXEC (@Sql_Select)

BEGIN
	CREATE TABLE #temp_deals(   
	 	id INT IDENTITY(1, 1),
		assign_id INT,
		source_deal_detail_id INT,	 
		source_deal_header_id INT,      
		gen_date DATETIME, 
		jurisdiction VARCHAR(500),   
		generator VARCHAR(500), 
		counterparty VARCHAR(500), 
		volume FLOAT,  
		UOM VARCHAR(500),
		price FLOAT,
		tier_value_id INT,
		tier VARCHAR(500)
	 )    

	SET @Sql_Select = '
		INSERT INTO #temp_deals(assign_id,
			source_deal_detail_id,
			source_deal_header_id,
			gen_date,
			jurisdiction,
			generator,
			counterparty,
			volume,
			UOM,
			price,
			tier_value_id,
			tier)
		SELECT aa.assignment_ID, 
			aa.source_deal_header_id AS source_deal_detail_id,
			sdh.source_deal_header_id,
			sdd.term_start AS gen_date,
			jur.code AS jurisdiction,
			rg.name AS generator,
			sc.counterparty_name,
			aa.assigned_volume,
			uom.uom_name,
			sdd.fixed_price,
			tier.value_id AS tier_value_id,
			tier.code AS tier
		FROM source_deal_header sdh
		INNER JOIN #ssbm_rec ssbm ON sdh.source_system_book_id1 = ssbm.source_system_book_id1 
			AND sdh.source_system_book_id2 = ssbm.source_system_book_id2 
			AND sdh.source_system_book_id3 = ssbm.source_system_book_id3 
			AND sdh.source_system_book_id4 = ssbm.source_system_book_id4
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN assignment_audit aa ON aa.source_deal_header_id = sdd.source_deal_detail_id
		LEFT JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		LEFT JOIN static_data_value jur ON jur.value_id = aa.state_value_id
		LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
		LEFT JOIN source_uom uom ON uom.source_uom_id = sdd.deal_volume_uom_id
		LEFT JOIN static_data_value tier ON tier.value_id = aa.tier
		WHERE 1 = 1 ' +
			
		CASE WHEN @assignment_type IS NOT NULL THEN ' AND aa.assignment_type = ' + CAST(@assignment_type AS VARCHAR) + '' ELSE '' END +
		CASE WHEN @assigned_state IS NOT NULL THEN ' AND aa.state_value_id = ' + CAST(@assigned_state AS VARCHAR) + '' ELSE '' END +
		CASE WHEN @tier_value_id IS NOT NULL THEN ' AND aa.tier = ' + CAST(@tier_value_id AS VARCHAR) + '' ELSE '' END +
		CASE WHEN @compliance_year IS NOT NULL THEN ' AND aa.compliance_year = ' + CAST(@compliance_year AS VARCHAR) + '' ELSE '' END +
		CASE WHEN @assigned_dt_from IS NOT NULL THEN ' AND aa.assigned_date >= ''' + CAST(@assigned_dt_from AS VARCHAR) + '''' ELSE '' END +
		CASE WHEN @assigned_dt_to IS NOT NULL THEN ' AND aa.assigned_date <= ''' + CAST(@assigned_dt_to AS VARCHAR) + '''' ELSE '' END +
		CASE WHEN @deal_id IS NOT NULL THEN ' AND sdh.source_deal_header_id IN (' + @deal_id + ')' ELSE '' END +
		CASE WHEN @counterparty_id IS NOT NULL THEN ' AND sdh.counterparty_id = ' + CAST(@counterparty_id AS VARCHAR) + '' ELSE '' END +
		CASE WHEN @gen_date_from IS NOT NULL THEN ' AND sdd.term_start >= ''' + CAST(@gen_date_from AS VARCHAR) + '''' ELSE '' END +
		CASE WHEN @gen_date_to IS NOT NULL THEN ' AND sdd.term_start <= ''' + CAST(@gen_date_to AS VARCHAR) + '''' ELSE '' END
	
	IF @debug = 1
	PRINT @sql_select		
	EXEC(@Sql_Select)

	IF @table_name IS NULL OR @table_name = ''    
		SET @table_name = dbo.FNAProcessTableName('recassign_', dbo.FNADBUser(), dbo.FNAGetNewID())
	
	SET @Sql_Select = '
		;WITH quantityCheck AS (
			SELECT 
				id,
				assign_id,
				source_deal_detail_id AS rec_deal_detail_id,
				source_deal_header_id AS rec_deal_id,
				gen_date,
				jurisdiction,
				generator,
				counterparty,
				SUM(volume) OVER (ORDER BY volume) AS volumeCheck,
				volume,
				UOM,
				price,
				tier_value_id,
				tier
			FROM #temp_deals)
		SELECT 
			row_unique_id = IDENTITY(INT, 1, 1),
			NULL AS ID,
			assign_id,
			rec_deal_detail_id,
			rec_deal_id,
			dbo.FNADateFormat(gen_date) AS gen_date,
			jurisdiction,
			generator,
			counterparty,
			volume,
			UOM,
			price,
			tier_value_id,
			tier
		INTO ' + @table_name + '
		FROM quantityCheck 
		WHERE 1 = 1 ' +
		CASE WHEN @volume IS NOT NULL THEN ' AND volumeCheck <= ' + CAST(@volume AS VARCHAR) + '' ELSE '' END
	
	IF @debug = 1
	PRINT @sql_select	
	EXEC(@Sql_Select)

	EXEC('UPDATE ' + @table_name + ' SET ID = row_unique_id')
	
	SET @Sql_Select = 'SELECT 
		''' + @table_name + ''' [Process ID], 
		assign_id AS [Assign ID],
		row_unique_id AS [Row Unique ID],
		rec_deal_detail_id AS [Detail ID],
		rec_deal_id AS [Deal ID],
		gen_date AS [Vintage],
		jurisdiction AS [Jurisdiction],
		tier AS [Tier],
		generator AS [Generator],
		counterparty AS [Counterparty],
		volume AS [Volume],
		UOM,
		price AS [Price]
	' + @str_batch_table + '
	FROM ' + @table_name + ' a
	ORDER BY CAST(gen_date AS DATE) DESC'
	
	IF @debug = 1
	PRINT @sql_select				 
	EXEC(@Sql_Select)

	--SELECT TOP 5 * FROM assignment_audit
	--SELECT deal_volume_uom_id FROM source_deal_detail
	--SELECT * FROM source_uom WHERE source_uom_id = 1158
	/*******************************************2nd Paging Batch START**********************************************/
 
	--update time spent and batch completion message in message board
	IF @is_batch = 1
	BEGIN
	   SELECT @sql_paging = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
	   EXEC(@sql_paging)
	 
	   --TODO: modify sp and report name
	   SELECT @sql_paging = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_find_unassign_transation', 'Run Assignment logic')
	   EXEC(@sql_paging)  
	 
	   RETURN
	END
	 
	--if it is first call from paging, return total no. of rows and process id instead of actual data
	IF @enable_paging = 1 AND @page_no IS NULL
	BEGIN
	   SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
	   EXEC(@sql_paging)
	END
	 
	/*******************************************2nd Paging Batch END**********************************************/

END

GO