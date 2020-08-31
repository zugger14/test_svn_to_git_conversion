SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[spa_find_assign_transation_sales]') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_find_assign_transation_sales]
GO
--/*
/* SP Created By: Shushil Bohara
 * Created Dt: 15-July-2017
 * Description: Logic to display REC deals for defined target from SOLD/TRANSFER
 * Priority added for Technology, Technology Sub Type and Tier
 * Logic is for Sold/Transfer
 *
 */ 
--* */
   
CREATE PROCEDURE [dbo].[spa_find_assign_transation_sales]   
	  @flag CHAR(1)						 = NULL, 
	  @fas_sub_id  VARCHAR(5000)         = NULL,
	  @fas_strategy_id  VARCHAR(5000)    = NULL,
	  @fas_book_id VARCHAR(5000)         = NULL,
	  @req_assignment_type INT   	     = NULL,
	  @req_assigned_state INT    	     = NULL,
	  @req_compliance_year INT           = NULL,
	  @req_assigned_date VARCHAR(20)     = NULL,
	  @curve_id INT   			         = NULL,
	  @table_name VARCHAR(100)           = NULL,
	  @req_convert_uom_id INT    	     = NULL,
	  @req_gen_state INT    		     = NULL,
	  @gen_year INT    					 = NULL,
	  @req_gen_date_from DATETIME        = NULL,
	  @req_gen_date_to DATETIME  	     = NULL,
	  @generator_id INT  		         = NULL,
	  @req_counterparty_id INT  	     = NULL,
	  @req_deal_id varchar(500)  	     = NULL,
	  @req_tier_type INT  		         = NULL,
	  @req_program_scope INT		     = NULL,
	  @assignment_group INT  	         = NULL,
	  @cert_from INT  		             = NULL,
	  @cert_to INT  		             = NULL,
	  @unassign INT  		             = 0,
	  @req_volume NUMERIC(38, 20)	     = 0,
	  @req_env_product VARCHAR(500) 	 = NULL,
	  @req_assignment_priority INT       = NULL,
	  @req_volume_type  VARCHAR(1)       = NULL,
	  @req_fifo_lifo VARCHAR(1)	         = NULL,
	  @req_delivery_date_from DATETIME	 = NULL,
	  @req_delivery_date_to	DATETIME	 = NULL,
	  @inv_env_product   VARCHAR(500)    = NULL,
	  @inv_tier_type   INT		         = NULL,
	  @inv_gen_date_from DATETIME	     = NULL,
	  @inv_gen_date_to DATETIME	         = NULL,
	  @inv_gen_state INT		         = NULL,
	  @inv_cert_from INT		         = NULL,
	  @inv_cert_to INT				     = NULL,
	  @inv_counterparty_id INT	         = NULL,
	  @inv_sub_book	VARCHAR(MAX)		= NULL,
	  @debug BIT					     = 0,
	  @batch_process_id VARCHAR(50)      = NULL
 AS
 
/**************************TEST CODE START************************				
DECLARE	
	@flag CHAR(1)						 = NULL, 
	  @fas_sub_id  VARCHAR(5000)         = NULL,
	  @fas_strategy_id  VARCHAR(5000)    = NULL,
	  @fas_book_id VARCHAR(5000)         = NULL,
	  @req_assignment_type INT   	     = NULL,
	  @req_assigned_state INT    	     = NULL,
	  @req_compliance_year INT           = NULL,
	  @req_assigned_date VARCHAR(20)     = NULL,
	  @curve_id INT   			         = NULL,
	  @table_name VARCHAR(100)           = NULL,
	  @req_convert_uom_id INT    	     = NULL,
	  @req_gen_state INT    		     = NULL,
	  @gen_year INT    					 = NULL,
	  @req_gen_date_from DATE			= NULL,
	  @req_gen_date_to DATE  			= NULL,
	  @generator_id INT  		         = NULL,
	  @req_counterparty_id INT  	     = NULL,
	  @req_deal_id varchar(500)  	     = NULL,
	  @req_tier_type INT  		         = NULL,
	  @req_program_scope INT		     = NULL,
	  @assignment_group INT  	         = NULL,
	  @cert_from INT  		             = NULL,
	  @cert_to INT  		             = NULL,
	  @unassign INT  		             = 0,
	  @req_volume NUMERIC(38, 20)	     = 0,
	  @req_env_product VARCHAR(500) 	 = NULL,
	  @req_assignment_priority INT       = NULL,
	  @req_volume_type  VARCHAR(1)       = NULL,
	  @req_fifo_lifo VARCHAR(1)	         = NULL,
	  @req_delivery_date_from DATE		= NULL,
	  @req_delivery_date_to	DATE		= NULL,
	  @inv_env_product   VARCHAR(500)    = NULL,
	  @inv_tier_type   INT		         = NULL,
	  @inv_gen_date_from DATE			= NULL,
	  @inv_gen_date_to DATE				= NULL,
	  @inv_gen_state INT		         = NULL,
	  @inv_cert_from INT		         = NULL,
	  @inv_cert_to INT				     = NULL,
	  @inv_counterparty_id INT	         = NULL,
	  @inv_sub_book	VARCHAR(MAX)		 = NULL,
	  @debug BIT					     = 0,
	  @batch_process_id VARCHAR(50)      = NULL


SELECT @flag='o',@fas_sub_id='250',@fas_strategy_id='251',@fas_book_id='252',@req_assignment_type='5173',@req_program_scope='3102',@req_assigned_state='401073',@req_tier_type=NULL,@req_gen_state=NULL,@req_assignment_priority=NULL,@req_compliance_year='2017',@req_gen_date_from=NULL,@req_gen_date_to=NULL,@req_delivery_date_from='2017-01-01',@req_delivery_date_to='2018-12-31',@req_counterparty_id=NULL,@req_volume_type='s',@req_volume=NULL,@req_convert_uom_id=NULL,@req_deal_id=NULL,@req_assigned_date='2018-01-02',@curve_id=NULL,@table_name=NULL,@inv_env_product=NULL,@inv_tier_type=NULL,@inv_gen_date_from=NULL,@inv_gen_date_to=NULL,@inv_gen_state=NULL,@inv_cert_from=NULL,@inv_cert_to=NULL,@inv_counterparty_id=NULL,@inv_sub_book='376'

--*/

SET NOCOUNT ON

	 DECLARE @Sql_Select VARCHAR(MAX), @sales_rec VARCHAR(150), @user_login_id VARCHAR(100),
		 @vol_rounding TINYINT = 5
	 DECLARE @Sql_Where VARCHAR(MAX) = ''  

	 SET @batch_process_id =  dbo.FNAGetNewID()
	 SET @user_login_id = dbo.FNADBUser() 
 
	IF OBJECT_ID(N'tempdb..#ssbm', N'U') IS NOT NULL
	DROP TABLE #ssbm

	IF OBJECT_ID(N'tempdb..#tmp_sale_deals', N'U') IS NOT NULL
	DROP TABLE #tmp_sale_deals

	IF OBJECT_ID(N'tempdb..#deal_detail', N'U') IS NOT NULL
	DROP TABLE #deal_detail

	SET @sales_rec = dbo.FNAProcessTableName('sales_rec_', @user_login_id, @batch_process_id)

	EXEC('IF OBJECT_ID(''' + @sales_rec + ''') IS NOT NULL
	DROP TABLE ' + @sales_rec)	

	SET @Sql_Select = 'CREATE TABLE ' + @sales_rec + '(
			[row_unique_id] [int] IDENTITY(1,1) NOT NULL,
			[rec_deal_id] [int] NULL,
			[rec_deal_detail_id] [int] NULL,
			[deal_date] [varchar](50) NULL,
			[Vintage] [varchar](50) NULL,
			[expiration] [varchar](50) NULL,
			[jurisdiction] [varchar](500) NULL,
			[gen_state] [varchar](500) NULL,
			[generator] [varchar](250) NULL,
			[obligation] [varchar](100) NULL,
			[counterparty] [nvarchar](100) NULL,
			[volume_left] [numeric](38, 20) NULL,
			[bonus] [numeric](38, 20) NOT NULL,
			[UOM] [varchar](100) NULL,
			[price] [numeric](38, 20) NULL,
			[volume_assign] [numeric](38, 20) NULL,
			[total_volume] [numeric](38, 20) NULL,
			[cert_from] [numeric](38, 10) NULL,
			[cert_to] [numeric](38, 20) NULL,
			[compliance_year] [int] NULL,
			[gen_state_value_id] [int] NULL,
			[technology] [varchar](500) NULL,
			[jurisdiction_state_id] [int] NULL,
			[tier] [varchar](500) NULL,
			[tier_value_id] [int] NULL,
			[assign_deal] [int] NOT NULL,
			[inv_ref_id] [nvarchar](100),
			[dem_ref_id] [nvarchar](100))'

		IF @debug = 1
		PRINT @Sql_Select
		EXEC(@Sql_Select)

	CREATE TABLE #deal_detail(
		source_deal_header_id INT,
		generator_id INT,
		product_id INT,
		tier_value_id INT
	)

	CREATE TABLE #ssbm(    
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
	SET @Sql_Select='INSERT INTO #ssbm              
	SELECT source_system_book_id1,
		source_system_book_id2,
		source_system_book_id3,  
		source_system_book_id4,
		fas_deal_type_value_id,              
		book_deal_type_map_id,
		book.entity_id fas_book_id,
		book.parent_entity_id stra_book_id,  
		stra.parent_entity_id sub_entity_id               
	FROM source_system_book_map ssbm               
	INNER JOIN portfolio_hierarchy book (nolock) ON ssbm.fas_book_id = book.entity_id               
	INNER JOIN Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id               
	WHERE 1=1 '              
  
	--IF @fas_sub_id IS NOT NULL              
		SET @Sql_Where = @Sql_Where + ' AND stra.parent_entity_id IN  ( ' + @fas_sub_id + ') '  
		             
	--IF @fas_strategy_id IS NOT NULL              
		SET @Sql_Where = @Sql_Where + ' AND (stra.entity_id IN(' + @fas_strategy_id + ' ))'  
		            
	--IF @fas_book_id IS NOT NULL              
		SET @Sql_Where = @Sql_Where + ' AND (book.entity_id IN(' + @fas_book_id + ')) ' 
		             
		SET @Sql_Select = @Sql_Select + @Sql_Where   
  
	IF @debug = 1
	PRINT @sql_select             
	EXEC (@Sql_Select)

	SELECT DISTINCT source_deal_header_id
	INTO #tmp_sale_deals
	FROM(
		SELECT item AS source_deal_header_id 
		FROM dbo.FNASplit(@req_deal_id, ',')
		UNION ALL
		SELECT DISTINCT 
			sdh.source_deal_header_id
		FROM source_deal_header sdh 
		INNER JOIN #ssbm sbm ON sdh.source_system_book_id1 = sbm.source_system_book_id1 
			AND sdh.source_system_book_id2 = sbm.source_system_book_id2 
			AND sdh.source_system_book_id3 = sbm.source_system_book_id3 
			AND sdh.source_system_book_id4 = sbm.source_system_book_id4) book		
BEGIN
	SET @Sql_Select='INSERT INTO #deal_detail
		SELECT 
			tsd.source_deal_header_id,
			MAX(sdh.generator_id),
			MAX(COALESCE(rg.source_curve_def_id, sdd.curve_id)) AS product,
			MAX(COALESCE(sdh.tier_value_id, rg.tier_type)) AS tier
		FROM #tmp_sale_deals tsd
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = tsd.source_deal_header_id
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		LEFT JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		WHERE sdd.buy_sell_flag = ''s''' +

		CASE WHEN @req_delivery_date_from IS NOT NULL THEN 
			' AND sdd.delivery_date BETWEEN ''' + CAST(@req_delivery_date_from AS VARCHAR) + ''' AND ''' + CAST(@req_delivery_date_to AS VARCHAR) + '''' ELSE '' END +
		CASE WHEN @req_tier_type IS NOT NULL THEN ' AND sdh.tier_value_id = ' + CAST(@req_tier_type AS VARCHAR) + '' ELSE '' END +
		CASE WHEN @req_gen_state IS NOT NULL THEN ' AND (rg.gen_state_value_id IS NULL OR rg.gen_state_value_id = ' + CAST(@req_gen_state AS VARCHAR) + ')' ELSE '' END +
		CASE WHEN @req_gen_date_from IS NOT NULL THEN 
			' AND sdd.term_start BETWEEN ''' + CAST(@req_gen_date_from AS VARCHAR) + ''' AND ''' + CAST(@req_gen_date_to AS VARCHAR) + '''' ELSE '' END +
		CASE WHEN @req_counterparty_id IS NOT NULL THEN ' AND ISNULL(rg.ppa_counterparty_id, sdh.counterparty_id) = ' + CAST(@req_counterparty_id AS VARCHAR) + '' ELSE '' END +
		CASE WHEN @curve_id IS NOT NULL THEN ' AND ISNULL(rg.source_curve_def_id, sdd.curve_id) = ' + CAST(@curve_id AS VARCHAR) + '' ELSE '' END +
		CASE WHEN @req_assigned_state IS NOT NULL THEN ' AND sdh.state_value_id = ' + CAST(@req_assigned_state AS VARCHAR) + '' ELSE '' END +
		' GROUP BY tsd.source_deal_header_id'

		IF @debug = 1
		PRINT @sql_select             
		EXEC (@Sql_Select)

		DECLARE @deal_id INT, @gen_id INT, @product_id INT, @tier_value_id INT

		DECLARE cur_select_rec CURSOR LOCAL FOR
		SELECT source_deal_header_id, generator_id, product_id, ISNULL(@inv_tier_type, tier_value_id) FROM #deal_detail
		OPEN cur_select_rec;
		
		FETCH NEXT FROM cur_select_rec INTO @deal_id, @gen_id, @product_id, @tier_value_id
		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC spa_find_assign_transation
				@flag = @flag,
				@req_assignment_type = @req_assignment_type,
				@req_assigned_state = @req_assigned_state,
				@req_gen_state = @req_gen_state,
				@req_compliance_year = @req_compliance_year,
				@req_gen_date_from = @req_gen_date_from,
				@req_gen_date_to = @req_gen_date_to,
				--@generator_id = @gen_id,
				@req_volume_type = @req_volume_type,
				@req_deal_id = @deal_id,
				@req_assigned_date = @req_assigned_date,
				@batch_process_id = @batch_process_id,			
				@req_assignment_priority = @req_assignment_priority,
				--Inventory Filters
				@inv_sub_book	= @inv_sub_book,
				@inv_env_product = @inv_env_product,
				@inv_tier_type = @tier_value_id,
				@inv_gen_date_from = @inv_gen_date_from,
				@inv_gen_date_to = @inv_gen_date_to,
				@inv_counterparty_id = @inv_counterparty_id,
				@inv_gen_state = @inv_gen_state,
				@inv_cert_from = @inv_cert_from,
				@inv_cert_to = @inv_cert_to															

		FETCH NEXT FROM cur_select_rec INTO @deal_id, @gen_id, @product_id, @tier_value_id
		END;
		CLOSE cur_select_rec;
		DEALLOCATE cur_select_rec;

		--EXEC('SELECT 
		--FROM ' + @sales_rec)

		SET @Sql_Select = 'SELECT ''' + @sales_rec + ''' [Process Table], 
				assign_deal,
				dem_ref_id, 
				row_unique_id, 
				rec_deal_id AS [Deal ID],
				inv_ref_id,
				rec_deal_detail_id AS [ID], 
				deal_date [Deal Date], 
				Vintage, 
				Jurisdiction, 
				[Tier] as [Assigned To Tier], 
				Technology, 
				gen_state AS [Gen State], 
				Generator, 
				obligation [Env Product], 
				Counterparty,
				CAST(dbo.FNARemoveTrailingZero(ROUND(CAST([volume_assign] AS NUMERIC(38, 20)), ' + CAST(@vol_rounding AS VARCHAR(2)) + ')) AS FLOAT)  [Volume Assign],
				CAST(dbo.FNARemoveTrailingZero(ROUND(CAST([volume_left] AS NUMERIC(38, 20)), ' + CAST(@vol_rounding AS VARCHAR(2)) + ')) AS FLOAT)  AS [Volume Available],
				CAST(dbo.FNARemoveTrailingZero(ROUND(CAST(bonus AS NUMERIC(38, 20)), ' + CAST(@vol_rounding AS VARCHAR(2)) + ')) AS FLOAT) AS  Bonus,
				CAST(dbo.FNARemoveTrailingZero(ROUND(CAST([total_volume] AS NUMERIC(38, 20)), ' + CAST(@vol_rounding AS VARCHAR(2)) + ')) AS FLOAT) AS [Total Volume],
				UOM,
				CAST(dbo.FNARemoveTrailingZero(ROUND(Price, ' + CAST(@vol_rounding AS VARCHAR(2)) + ')) AS FLOAT) [Price],
				gen_state_value_id, 
				jurisdiction_state_id, 
				compliance_year, 
				tier_value_id
			FROM ' + @sales_rec + ' a ORDER BY row_unique_id'

			IF @debug = 1
			PRINT @sql_select             
			EXEC (@Sql_Select)
END