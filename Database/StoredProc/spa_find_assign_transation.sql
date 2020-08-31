SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[spa_find_assign_transation]') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_find_assign_transation]
GO
/*
/* SP Created By: Shushil Bohara
 * Created Dt: 20-June-2017
 * Description: Logic to display REC deals for defined target
 * Priority added for Technology, Technology Sub Type and Tier
 * Logic is only for RPS Compliance and Sold/Transfer
 *
 */ 
* */
   
CREATE PROCEDURE [dbo].[spa_find_assign_transation]   
	@flag CHAR(1)						= NULL, 
	@fas_sub_id  VARCHAR(5000)			= NULL,
	@fas_strategy_id  VARCHAR(5000)		= NULL,
	@fas_book_id VARCHAR(5000)			= NULL,
	@req_assignment_type INT   			= NULL,
	@req_assigned_state INT    			= NULL,
	@req_compliance_year INT			= NULL,
	@req_assigned_date VARCHAR(20)		= NULL,
	@curve_id INT   			        = NULL,
	@table_name VARCHAR(100)			= NULL,
	@req_convert_uom_id INT    			= NULL,
	@req_gen_state INT    				= NULL,
	@req_gen_date_from DATETIME			= NULL,
	@req_gen_date_to DATETIME  			= NULL,
	@req_counterparty_id INT  			= NULL,
	@req_deal_id varchar(500)  			= NULL,
	@req_tier_type INT  		        = NULL,
	@req_program_scope INT				= NULL,
	@req_volume NUMERIC(38, 20)			= 0,
	@req_assignment_priority INT		= NULL,
	@req_volume_type  VARCHAR(1)		= NULL,
	@req_delivery_date_from DATETIME	= NULL,
	@req_delivery_date_to	DATETIME	= NULL,
	@inv_env_product   VARCHAR(500)		= NULL,
	@inv_tier_type   INT		        = NULL,
	@inv_gen_date_from DATETIME			= NULL,
	@inv_gen_date_to DATETIME	        = NULL,
	@inv_gen_state INT					= NULL,
	@inv_cert_from INT					= NULL,
	@inv_cert_to INT				    = NULL,
	@inv_counterparty_id INT	        = NULL,
	@inv_sub_book	VARCHAR(MAX)		= NULL,
	@debug BIT							= 0,
	@batch_process_id VARCHAR(50)		= NULL,
	@inv_subsidiary_id VARCHAR(5000)	= NULL,
	@inv_book_id VARCHAR(5000)			= NULL,
	@inv_strategy_id VARCHAR(5000)		= NULL
 AS
 
/**************************TEST CODE START************************				
DECLARE	
		@flag CHAR(1)						= NULL, 
		@fas_sub_id  VARCHAR(5000)			= NULL,
		@fas_strategy_id  VARCHAR(5000)		= NULL,
		@fas_book_id VARCHAR(5000)			= NULL,
		@req_assignment_type INT   			= NULL,
		@req_assigned_state INT    			= NULL,
		@req_compliance_year INT			= NULL,
		@req_assigned_date VARCHAR(20)		= NULL,
		@curve_id INT   			        = NULL,
		@table_name VARCHAR(100)			= NULL,
		@req_convert_uom_id INT    			= NULL,
		@req_gen_state INT    				= NULL,
		@req_gen_date_from DATETIME			= NULL,
		@req_gen_date_to DATETIME  			= NULL,
		@req_counterparty_id INT  			= NULL,
		@req_deal_id varchar(500)  			= NULL,
		@req_tier_type INT  		        = NULL,
		@req_program_scope INT				= NULL,
		@req_volume NUMERIC(38, 20)			= 0,
		@req_assignment_priority INT		= NULL,
		@req_volume_type  VARCHAR(1)		= NULL,
		@req_delivery_date_from DATETIME	= NULL,
		@req_delivery_date_to	DATETIME	= NULL,
		@inv_env_product   VARCHAR(500)		= NULL,
		@inv_tier_type   INT		        = NULL,
		@inv_gen_date_from DATETIME			= NULL,
		@inv_gen_date_to DATETIME	        = NULL,
		@inv_gen_state INT					= NULL,
		@inv_cert_from INT					= NULL,
		@inv_cert_to INT				    = NULL,
		@inv_counterparty_id INT	        = NULL,
        @inv_sub_book	VARCHAR(MAX)        = NULL,
		@debug BIT							= 0,
		@batch_process_id VARCHAR(50)		= NULL

IF OBJECT_ID(N'tempdb..#bonus', N'U') IS NOT NULL
	DROP TABLE #bonus		
IF OBJECT_ID(N'tempdb..#ssbm_target', N'U') IS NOT NULL
	DROP TABLE #ssbm_target			
IF OBJECT_ID(N'tempdb..#target_deal_volume', N'U') IS NOT NULL
	DROP TABLE	#target_deal_volume			
IF OBJECT_ID(N'tempdb..#target_profile', N'U') IS NOT NULL
	DROP TABLE	#target_profile		
IF OBJECT_ID(N'tempdb..#temp_assign', N'U') IS NOT NULL
	DROP TABLE	#temp_assign			
IF OBJECT_ID(N'tempdb..#temp_cert', N'U') IS NOT NULL
	DROP TABLE	#temp_cert		
--IF OBJECT_ID(N'tempdb..#temp_const_tier_target', N'U') IS NOT NULL
--	DROP TABLE	#temp_const_tier_target		
IF OBJECT_ID(N'tempdb..#temp_deals', N'U') IS NOT NULL
	DROP TABLE	#temp_deals		
IF OBJECT_ID(N'tempdb..#temp_filtered_recs', N'U') IS NOT NULL
	DROP TABLE	#temp_filtered_recs			
IF OBJECT_ID(N'tempdb..#temp_filtered_recs_with_tier', N'U') IS NOT NULL
	DROP TABLE	#temp_filtered_recs_with_tier			
IF OBJECT_ID(N'tempdb..#temp_final', N'U') IS NOT NULL
	DROP TABLE	#temp_final		
IF OBJECT_ID(N'tempdb..#temp_final2', N'U') IS NOT NULL
	DROP TABLE	#temp_final2		
IF OBJECT_ID(N'tempdb..#temp_include', N'U') IS NOT NULL
	DROP TABLE	#temp_include	
IF OBJECT_ID(N'tempdb..#temp_tier_type', N'U') IS NOT NULL
	DROP TABLE	#temp_tier_type

----Fixed
--SELECT @flag='o',@fas_sub_id=NULL,@fas_strategy_id=NULL,@fas_book_id=NULL,@req_assignment_type='5146',@req_program_scope=NULL,@req_assigned_state='401310',@req_tier_type=NULL,@req_gen_state=NULL,@req_assignment_priority='41',@req_compliance_year='2017',@req_gen_date_from=NULL,@req_gen_date_to=NULL,@req_delivery_date_from=NULL,@req_delivery_date_to=NULL,@req_counterparty_id=NULL,@req_volume_type='f',@req_volume='30000',@req_convert_uom_id=NULL,@req_deal_id=NULL,@req_assigned_date='2017-07-26',@curve_id=NULL,@table_name=NULL,@inv_env_product=NULL,@inv_tier_type=NULL,@inv_gen_date_from=NULL,@inv_gen_date_to=NULL,@inv_gen_state=NULL,@inv_cert_from=NULL,@inv_cert_to=NULL,@inv_counterparty_id=NULL,@inv_subsidiary_id='1694',@inv_strategy_id='1702',@inv_book_id='1703'

----Target
--SELECT
--@flag='o',@fas_sub_id='1694',@fas_strategy_id='3732',@fas_book_id='3733',@req_assignment_type='5146',@req_program_scope=NULL,@req_assigned_state='401435',@req_tier_type=NULL,@req_gen_state=NULL,@req_assignment_priority='57',@req_compliance_year='2018',@req_gen_date_from=NULL,@req_gen_date_to=NULL,@req_delivery_date_from=NULL,@req_delivery_date_to=NULL,@req_counterparty_id=NULL,@req_volume_type='r',@req_volume=NULL,@req_convert_uom_id=NULL,@req_deal_id=NULL,@req_assigned_date='2017-08-01',@curve_id=NULL,@table_name=NULL,@inv_env_product=NULL,@inv_tier_type=NULL,@inv_gen_date_from=NULL,@inv_gen_date_to=NULL,@inv_gen_state=NULL,@inv_cert_from=NULL,@inv_cert_to=NULL,@inv_counterparty_id=NULL,@inv_subsidiary_id='1694',@inv_strategy_id='3732',@inv_book_id='3733'

----Required
--SELECT  @flag='o',@fas_sub_id='1694',@fas_strategy_id='3732',@fas_book_id='3733',@req_assignment_type='5146',@req_program_scope=NULL,@req_assigned_state='401435',@req_tier_type=NULL,@req_gen_state=NULL,@req_assignment_priority='32',@req_compliance_year='2017',@req_gen_date_from=NULL,@req_gen_date_to=NULL,@req_delivery_date_from=NULL,@req_delivery_date_to=NULL,@req_counterparty_id=NULL,@req_volume_type='r',@req_volume=NULL,@req_convert_uom_id=NULL,@req_deal_id=NULL,@req_assigned_date='2017-07-31',@curve_id=NULL,@table_name=NULL,@inv_env_product=NULL,@inv_tier_type=NULL,@inv_gen_date_from=NULL,@inv_gen_date_to=NULL,@inv_gen_state=NULL,@inv_cert_from=NULL,@inv_cert_to=NULL,@inv_counterparty_id=NULL,@inv_subsidiary_id='1694',@inv_strategy_id='3732',@inv_book_id='3733'



----Sold/Transfer
SELECT
@flag='o',@fas_sub_id='250',@fas_strategy_id='251',@fas_book_id='252',@req_assignment_type='5146',@req_program_scope='3102',@req_assigned_state='401073',@req_tier_type=NULL,@req_gen_state=NULL,@req_assignment_priority=NULL,@req_compliance_year='2017',@req_gen_date_from=NULL,@req_gen_date_to=NULL,@req_delivery_date_from=NULL,@req_delivery_date_to=NULL,@req_counterparty_id=NULL,@req_volume_type='t',@req_volume=NULL,@req_convert_uom_id=NULL,@req_deal_id=NULL,@req_assigned_date='2017-12-19',@curve_id=NULL,@table_name=NULL,@inv_env_product=NULL,@inv_tier_type=NULL,@inv_gen_date_from=NULL,@inv_gen_date_to=NULL,@inv_gen_state=NULL,@inv_cert_from=NULL,@inv_cert_to=NULL,@inv_counterparty_id=NULL,@inv_sub_book='376'

--**************************TEST CODE END************************/								
SET NOCOUNT ON    
IF OBJECT_ID('tempdb..#temp_deals') IS NOT NULL DROP TABLE #temp_deals  
IF OBJECT_ID('tempdb..#ssbm_target') IS NOT NULL DROP TABLE #ssbm_target
IF OBJECT_ID('tempdb..#ssbm_rec') IS NOT NULL DROP TABLE #ssbm_rec   
IF OBJECT_ID('tempdb..#bonus') IS NOT NULL DROP TABLE #bonus
IF OBJECT_ID('tempdb..#target_profile') IS NOT NULL DROP TABLE #target_profile    
-------------------------------------------    
 
 DECLARE @to_uom_id INT  
 DECLARE @sql_stmt VARCHAR(MAX)    
 DECLARE @sql_stmt2 VARCHAR(MAX)  
 DECLARE @Sql_Select VARCHAR(MAX)
 DECLARE @sql VARCHAR(MAX) 
 DECLARE @Sql_Where VARCHAR(MAX)    
 DECLARE @req_convert_uom_id_s VARCHAR(50)    
 DECLARE @log_increment INT  
 DECLARE @pr_name VARCHAR(5000)  
 DECLARE @log_time DATETIME, @sales_rec VARCHAR(100), @str_target_table VARCHAR(100), @str_allocation_table VARCHAR(100)
 DECLARE @vol_rounding TINYINT = 5
 DECLARE @default_tier_id INT
 DECLARE @target_type CHAR(10)='n'

 SELECT @default_tier_id = MAX(value_id) FROM static_data_value WHERE type_id = 15000 AND code = 'Unknown'
   
 SET @to_uom_id=@req_convert_uom_id    
 SET @req_convert_uom_id_s = CAST(@req_convert_uom_id AS VARCHAR)    
 IF @req_assigned_date IS NULL

	SET @req_assigned_date = CONVERT(VARCHAR(10),GETDATE(), 121)

	DECLARE @user_login_id VARCHAR(50)
	SET @user_login_id = dbo.FNADBUser() 


	SET @sales_rec = dbo.FNAProcessTableName('sales_rec_', @user_login_id, @batch_process_id)
	SET @str_target_table =  dbo.FNAProcessTableName('target', @user_login_id, @batch_process_id)
	SET @str_allocation_table =  dbo.FNAProcessTableName('allocation', @user_login_id, @batch_process_id)

	 IF @flag IN ('t','a')
	 BEGIN
			SET @target_type = @flag
			SET @flag = 'o'
	END

	 IF @req_volume_type = 't'
	 SET @flag = 's'
    
	 SET @Sql_Where=''
 
--******************************************************    
--CREATE source book map table and build index    
--*********************************************************    
	CREATE TABLE #ssbm_target(    
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
	'INSERT INTO #ssbm_target              
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

	CREATE INDEX [INDX_ssbm_target] ON [#ssbm_target]([source_system_book_id1], [source_system_book_id2], [source_system_book_id3], [source_system_book_id4])

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
					FROM   portfolio_hierarchy book(nolock) 
						INNER JOIN portfolio_hierarchy stra(nolock) 
								ON book.parent_entity_id = stra.entity_id 
						INNER JOIN portfolio_hierarchy sub (nolock) 
								ON stra.parent_entity_id = sub.entity_id 
						INNER JOIN source_system_book_map ssbm 
								ON ssbm.fas_book_id = book.entity_id 
						INNER JOIN fas_subsidiaries fs 
								ON fs.fas_subsidiary_id = sub.entity_id 
						LEFT JOIN static_data_value sdv 
								ON sdv.[type_id] = 400 
									AND ssbm.fas_deal_type_value_id = sdv.value_id             
					WHERE 1=1 ' +             
  
	CASE WHEN @inv_sub_book IS NOT NULL THEN ' AND ssbm.book_deal_type_map_id IN  ( ' + @inv_sub_book + ') ' ELSE '' END +
	CASE WHEN @inv_subsidiary_id IS NOT NULL THEN ' AND stra.parent_entity_id IN  ( ' + @inv_subsidiary_id + ') ' ELSE '' END +
	CASE WHEN @inv_strategy_id IS NOT NULL THEN ' AND (stra.entity_id IN(' + @inv_strategy_id + ' ))' ELSE '' END +
	CASE WHEN @inv_book_id IS NOT NULL THEN ' AND (book.entity_id IN(' + @inv_book_id + ')) ' ELSE '' END
  
	IF @debug = 1
	PRINT @sql_select             
	EXEC (@Sql_Select)              
   
	CREATE INDEX [INDX_ssbm_rec] ON [#ssbm_rec]([source_system_book_id1], [source_system_book_id2], [source_system_book_id3], [source_system_book_id4])         
	--CREATE INDEX [IX_PH6] ON [#ssbm_rec]([fas_book_id])          
	--CREATE INDEX [IX_PH7] ON [#ssbm_rec]([stra_book_id])          
	--CREATE INDEX [IX_PH8] ON [#ssbm_rec]([sub_entity_id])          
      
	--******************************************************    
	--End of source book map table and build index    
	--*********************************************************    
  
	--******************************************************    
	--CREATE bonus table and build index    
	--*********************************************************  
	CREATE TABLE #bonus(    
		state_value_id INT,    
		technology INT,    
		assignment_type_value_id INT,    
		from_date DATETIME,    
		to_date DATETIME,    
		gen_state_value_id INT,    
		bonus_per NUMERIC(38, 20),
		curve_id INT    
	)    
    
	INSERT INTO #bonus    
		SELECT  
		bS.state_value_id  state_value_id,    
		bS.technology technology,    
		bS.assignment_type_value_id assignment_type_value_id,    
		bS.from_date from_date,    
		bS.to_date to_date,    
		bS.gen_code_value gen_state_value_id,
		--TODO: may be we could change the data type in the table column itself
		CAST(bS.bonus_per AS NUMERIC(38, 20)) bonus_per,
		curve_id 
	FROM state_properties_bonus bS 
	WHERE gen_code_value IS NOT NULL
		AND state_value_id = @req_assigned_state	   

	CREATE INDEX [IX_bonus1] ON [#bonus]([state_value_id])          
	CREATE INDEX [IX_bonus2] ON [#bonus]([technology])          
	CREATE INDEX [IX_bonus3] ON [#bonus]([assignment_type_value_id])          
	CREATE INDEX [IX_bonus4] ON [#bonus]([from_date])          
	CREATE INDEX [IX_bonus5] ON [#bonus]([to_date])          
	CREATE INDEX [IX_bonus6] ON [#bonus]([gen_state_value_id])          

	DECLARE @gis_deal_id INT, @certificate_f INT, @certificate_t INT, @inv_cert_from_f INT, @inv_cert_to_t INT, @bank_assignment INT  
	DECLARE @req_volume_left2 FLOAT, @target_volume2 FLOAT, @source_deal_header_id2 INT, @floating_target_volume2 FLOAT


	IF OBJECT_ID('tempdb..#temp_assign') IS NOT NULL
		DROP TABLE #temp_assign

	IF OBJECT_ID('tempdb..#temp_cert') IS NOT NULL
		DROP TABLE #temp_cert

	IF OBJECT_ID('tempdb..#temp_final') IS NOT NULL
		DROP TABLE #temp_final

	IF OBJECT_ID('tempdb..#temp_include') IS NOT NULL
		DROP TABLE #temp_include

BEGIN
	IF OBJECT_ID('tempdb..#temp_tier_type') IS NOT NULL
		DROP TABLE #temp_tier_type
	
	CREATE TABLE #temp_deals  
	 (   
	 	  id INT IDENTITY(1, 1),
		  priority INT,	 
		  source_deal_header_id INT,    
		  source_deal_detail_id INT,  
		  deal_date DATETIME,    
		  gen_date DATETIME,    
		  source_curve_def_id INT,  
		  counterparty_id INT,  
		  generator_id INT,  
		  jurisdiction_state_id INT,  
		  gen_state_value_id INT,  
		  price NUMERIC(38, 20),    
		  volume NUMERIC(38, 20),    
		  bonus NUMERIC(38, 20),    
		  expiration VARCHAR(30) COLLATE DATABASE_DEFAULT,    
		  uom_id INT,  
		  volume_left NUMERIC(38, 20),
		  vol_to_be_assigned NUMERIC(38, 20),  
		  ext_deal_id INT,  --TODO: check if it is really needed 
		  conv_factor NUMERIC(38, 20),  
		  expiration_date DATETIME,  
		  assigned_date DATETIME,  
		  status_value_id INT,  
		  term_start DATETIME,
		  technology INT,
		  product INT,
		  compliance_year INT,
		  tier_type INT,
		  tech_sub_type INT,
		  sub_tier_value_id INT,
		  volume_left_con INT,
		  inv_ref_id VARCHAR(100) COLLATE DATABASE_DEFAULT
	 )    
    
  
	--******************************************************    
	-- Collect Eligible Deals  
	--******************************************************    
		  
	IF @debug = 1  
	BEGIN  
		SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)  
		SET @log_increment = @log_increment + 1  
		SET @log_time=GETDATE()  
		PRINT @pr_name+' Running..............'  
	END  
	
	IF OBJECT_ID('tempdb..#temp_filtered_recs_with_tier') IS NOT NULL DROP TABLE #temp_filtered_recs_with_tier
	IF OBJECT_ID('tempdb..#rec_gen_eligibility') IS NOT NULL DROP TABLE #rec_gen_eligibility

	SELECT state_value_id, 
		gen_state_value_id, 
		technology, 
		program_scope, 
		tier_type, 
		technology_sub_type, 
		from_year, 
		to_year,
		sub_tier_value_id
	INTO #rec_gen_eligibility
	FROM rec_gen_eligibility
	WHERE state_value_id = @req_assigned_state

	IF NOT EXISTS(SELECT TOP 1 1 FROM #rec_gen_eligibility)
		INSERT INTO #rec_gen_eligibility(state_value_id)
		SELECT @req_assigned_state
	
	--Create a set of filtered deals with tier which can be used for both #temp_filtered_recs and #temp_tier_type
	CREATE TABLE #temp_filtered_recs_with_tier (   
		source_deal_header_id		INT
		, deal_date					DATETIME
		, counterparty_id			INT
		, status_value_id			INT
		, assignment_type_value_id	INT
		, state_value_id			INT  
		, gen_state_value_id		INT
		, technology				INT
		, generator_id				INT
		, tier_type					INT
		, tech_sub_type				INT
		, sub_tier_value_id			INT
	)
	
	INSERT INTO #temp_filtered_recs_with_tier (
			source_deal_header_id		
			, deal_date					
			, counterparty_id			
			, status_value_id	
			, generator_id			
			, assignment_type_value_id	
			, state_value_id			
			, gen_state_value_id		
			, technology				
			, tier_type
			, tech_sub_type
			, sub_tier_value_id
		)
	SELECT 
			a.source_deal_header_id
			, a.deal_date
			, a.counterparty_id
			, ISNULL(a.status_value_id, 5171) status_value_id
			, a.generator_id
			, @req_assignment_type assignment_type_value_id
			, @req_assigned_state state_value_id
			, a.gen_state_value_id
			, a.technology
			, a.tier_type
			, a.tech_sub_type
			, a.sub_tier_value_id
	FROM
	(
		SELECT DISTINCT sdh.source_deal_header_id  -- First find deals with their tiers that fall under the gis_certificate criteria
			, sdh.deal_date
			, MAX(sdh.counterparty_id) counterparty_id
			, MAX(ISNULL(sdh.status_value_id, 5171)) status_value_id
			, MAX(sdh.generator_id) generator_id
			, MAX(rg.gen_state_value_id) gen_state_value_id
			, MAX(rg.technology) technology
			, COALESCE(gc.tier_type, rge.tier_type, @default_tier_id) AS tier_type
			, MAX(ISNULL(rge.technology_sub_type, rg.classification_value_id)) AS tech_sub_type
			, MAX(ISNULL(rge.sub_tier_value_id, rg.sub_tier_value_id)) AS sub_tier_value_id
		FROM #rec_gen_eligibility rge 
		INNER JOIN gis_certificate gc ON gc.state_value_id = rge.state_value_id
			AND ISNULL(gc.tier_type, @default_tier_id) = COALESCE(rge.tier_type, @default_tier_id)
			AND (@req_compliance_year IS NULL OR (@req_compliance_year BETWEEN ISNULL(rge.from_year, '1900') AND ISNULL(rge.to_year, '9999')))
		INNER JOIN source_deal_detail sdd ON gc.source_deal_header_id = sdd.source_deal_detail_id
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
		INNER JOIN #ssbm_rec ssbm ON sdh.source_system_book_id1 = ssbm.source_system_book_id1    
			AND sdh.source_system_book_id2 = ssbm.source_system_book_id2  
			AND sdh.source_system_book_id3 = ssbm.source_system_book_id3     
			AND sdh.source_system_book_id4 = ssbm.source_system_book_id4
		INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			AND rg.state_value_id = rge.state_value_id
		WHERE ssbm.fas_deal_type_value_id <> 405	--exclude target deals  
			AND ISNULL(sdh.status_value_id, 5171) NOT IN (5170, 5179)     
			AND sdh.deal_date <= CONVERT(NVARCHAR(10), @req_assigned_date, 20) 
			AND rge.state_value_id = @req_assigned_state
		GROUP BY sdh.source_deal_header_id, sdh.deal_date, COALESCE(gc.tier_type, rge.tier_type, @default_tier_id)  
		
		UNION 
		
		SELECT sdh.source_deal_header_id    -- find deals that fall under criteria of generator
			, sdh.deal_date
			, sdh.counterparty_id
			, ISNULL(sdh.status_value_id, 5171) status_value_id
			, sdh.generator_id
			, rg.gen_state_value_id
			, ISNULL(rge.technology, rg.technology)
			, COALESCE(rge.tier_type, rg.tier_type, @default_tier_id)
			, ISNULL(rge.technology_sub_type, rg.classification_value_id)
			, ISNULL(rge.sub_tier_value_id, rg.sub_tier_value_id) AS sub_tier_value_id
		FROM #rec_gen_eligibility rge
		INNER JOIN rec_generator rg ON rg.state_value_id = rge.state_value_id
			AND rg.gen_state_value_id = ISNULL(rge.gen_state_value_id, rg.gen_state_value_id)
		    AND rg.technology = ISNULL(rge.technology, rg.technology)
			AND ISNULL(rg.classification_value_id, -1) = COALESCE(rge.technology_sub_type, rg.classification_value_id, -1)
			AND (@req_compliance_year IS NULL OR (@req_compliance_year BETWEEN ISNULL(rge.from_year, '1900') AND ISNULL(rge.to_year, '9999')))
		INNER JOIN source_deal_header sdh ON sdh.generator_id = rg.generator_id
			AND sdh.source_deal_header_id 
			NOT IN (
			SELECT ISNULL(sdh2.source_deal_header_id,-1) source_deal_header_id_sdh 
				FROM gis_certificate gc 
				INNER JOIN source_deal_detail sdd2 ON gc.source_deal_header_id = sdd2.source_deal_detail_id
				INNER JOIN source_deal_header sdh2 ON sdh2.source_deal_header_id = sdd2.source_deal_header_id
				INNER JOIN #ssbm_rec ssbm2 ON sdh2.source_system_book_id1 = ssbm2.source_system_book_id1    
					AND sdh2.source_system_book_id2 = ssbm2.source_system_book_id2  
					AND sdh2.source_system_book_id3 = ssbm2.source_system_book_id3     
					AND sdh2.source_system_book_id4 = ssbm2.source_system_book_id4
				WHERE gc.state_value_id = @req_assigned_state --and gc.tier_type  = 300747
					AND sdh2.source_deal_header_id IS NOT NULL
					AND ssbm2.fas_deal_type_value_id <> 405
			)
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN #ssbm_rec ssbm ON sdh.source_system_book_id1 = ssbm.source_system_book_id1    
			AND sdh.source_system_book_id2 = ssbm.source_system_book_id2  
			AND sdh.source_system_book_id3 = ssbm.source_system_book_id3     
			AND sdh.source_system_book_id4 = ssbm.source_system_book_id4
		WHERE ssbm.fas_deal_type_value_id <> 405	--exclude target deals 
			AND ISNULL(sdh.status_value_id, 5171) NOT IN (5170, 5179)     
			AND ISNULL(rg.exclude_inventory, 'n') = 'n'
			AND sdh.deal_date <= CONVERT(NVARCHAR(10), @req_assigned_date, 20)
			AND rge.state_value_id = @req_assigned_state 
	) a WHERE 1 = 1
	AND (@inv_tier_type IS NULL OR a.tier_type = @inv_tier_type)
	--select * from #temp_filtered_recs_with_tier --where source_deal_header_id = 67804 
	--return
	--TODO: Remove extra joins repeated in temporary table and main query
	IF OBJECT_ID('tempdb..#temp_filtered_recs') IS NOT NULL DROP TABLE #temp_filtered_recs
	
	CREATE TABLE #temp_filtered_recs (
		source_deal_header_id		INT
		, deal_date					DATETIME
		, counterparty_id			INT
		, status_value_id			INT
		, assignment_type_value_id	INT
		, state_value_id			INT  
		, gen_state_value_id		INT
		, technology				INT
		, generator_id				INT
		, gen_offset_technology		CHAR(1) COLLATE DATABASE_DEFAULT
		, source_curve_def_id		INT
		, exclude_inventory			VARCHAR(1) COLLATE DATABASE_DEFAULT
		, udf_group1				INT
		, udf_group2				INT
		, udf_group3				INT
		, tier_type					INT
		, tech_sub_type				INT
		, sub_tier_value_id			INT	
	)
	 
		INSERT INTO #temp_filtered_recs (
			source_deal_header_id		
			, deal_date					
			, counterparty_id			
			, status_value_id	
			, generator_id			
			, assignment_type_value_id	
			, state_value_id			
			, gen_state_value_id		
			, technology				
			, gen_offset_technology		
			, source_curve_def_id		
			, exclude_inventory			
			, udf_group1				
			, udf_group2				
			, udf_group3
			, tier_type
			, tech_sub_type
			, sub_tier_value_id				
		)
		SELECT 
			tfrwt.source_deal_header_id
			, MAX(tfrwt.deal_date) deal_date
			, MAX(tfrwt.counterparty_id) counterparty_id
			, MAX(ISNULL(tfrwt.status_value_id, 5171)) status_value_id
			, MAX(tfrwt.generator_id) generator_id
			, @req_assignment_type assignment_type_value_id
			, @req_assigned_state state_value_id
			, MAX(tfrwt.gen_state_value_id) gen_state_value_id
			, MAX(tfrwt.technology) technology
			, MAX(rg.gen_offset_technology) gen_offset_technology
			, MAX(rg.source_curve_def_id) source_curve_def_id
			, MAX(rg.exclude_inventory) exclude_inventory
			, MAX(rg.udf_group1) udf_group1
			, MAX(rg.udf_group2) udf_group2
			, MAX(rg.udf_group3) udf_group3
			, MAX(tfrwt.tier_type)
			, MAX(tfrwt.tech_sub_type)
			, tfrwt.sub_tier_value_id
		FROM #temp_filtered_recs_with_tier tfrwt 
		INNER JOIN rec_generator rg ON rg.generator_id = tfrwt.generator_id
		GROUP BY source_deal_header_id, tfrwt.tier_type, tfrwt.sub_tier_value_id
		
	CREATE NONCLUSTERED INDEX [IX_tfr_] ON [dbo].[#temp_filtered_recs] ([state_value_id])
		INCLUDE ([source_deal_header_id], [deal_date], [counterparty_id], [status_value_id], [gen_state_value_id], [technology], [generator_id], [gen_offset_technology], [source_curve_def_id])
  
	
	
	IF @debug = 1
	BEGIN
		SELECT '#temp_filtered_recs'
		SELECT * FROM #temp_filtered_recs
	END
	
	IF @target_type <> 't'
	BEGIN
		--Collect eligible deals
		SET @sql_stmt =     
			'  
			INSERT INTO #temp_deals(
				source_deal_header_id,    
				source_deal_detail_id,  
				deal_date,    
				gen_date,    
				source_curve_def_id,  
				counterparty_id,  
				generator_id,  
				jurisdiction_state_id,  
				gen_state_value_id,  
				price,    
				volume,    
				bonus,    
				uom_id,  
				volume_left,
				conv_factor,  
				expiration_date,  
				status_value_id,  
				term_start,
				technology,
				product,
				compliance_year,
				tier_type,
				tech_sub_type,
				sub_tier_value_id,
				inv_ref_id
			)    
			SELECT 
				tfr.source_deal_header_id,  
				sdd.source_deal_detail_id,    
				tfr.deal_date,     
				sdd.term_start gen_date,    
				sdd.curve_id AS source_curve_def_id,    
				tfr.counterparty_id AS counterparty_id,  
				tfr.generator_id AS generator_id,  
				tfr.state_value_id,  
				tfr.gen_state_value_id,  
				ISNULL(CAST(sdd.fixed_price as NUMERIC(38,20)), 0) AS price,   
				ROUND((sdd.deal_volume * rs_cf.conversion_factor), 0) AS volume,
				0 AS bonus,    
				su.source_uom_id AS uom_id, 
				ROUND((sdd.volume_left * rs_cf.conversion_factor), 0) AS Volume_left,
				rs_cf.conversion_factor AS conv_factor,  
				DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,cast((year(sdd.term_start) + 
									CASE WHEN(isnull(tfr.gen_offset_technology, ''n'') = ''n'') THEN 
										ISNULL(spd.duration ,isnull(sp.duration, 0)) 
									ELSE ISNULL(spd.offset_duration ,isnull(sp.offset_duration, 0)) END 
									- 1) AS VARCHAR) 
									+ ''-'' + CAST(isnull(sp.calendar_to_month, 12) as varchar) + ''-01'')+1,0)) expiration_date,
				tfr.status_value_id,  
				sdd.term_start,
				tfr.technology,
				ISNULL(tfr.source_curve_def_id, sdd.curve_id) AS product,
				' + CAST(@req_compliance_year AS VARCHAR(4)) + ',
				tfr.tier_type,
				tfr.tech_sub_type,
				tfr.sub_tier_value_id,
				sdh.deal_id
			FROM #temp_filtered_recs tfr
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = tfr.source_deal_header_id
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			AND sdd.buy_sell_flag = ''b''  -- select only buy deals  
			INNER JOIN rec_generator rg ON rg.generator_id = tfr.generator_id
			INNER JOIN static_data_value sdv_tech ON sdv_tech.value_id = tfr.technology
			INNER JOIN state_properties sp ON sp.state_value_id = ' + CAST(@req_assigned_state AS VARCHAR) + '-- tfr.state_value_id 
			LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id         
			LEFT JOIN state_properties_duration spd on spd.state_value_id = sp.state_value_id 
				AND spd.technology = tfr.technology 	
				AND (ISNULL(spd.assignment_type_Value_id, 5149) = ISNULL(NULL, 5149) OR spd.assignment_type_Value_id IS NULL)
			LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = tfr.counterparty_id    
			LEFT JOIN static_data_value state ON state.value_id = tfr.state_value_id  
			LEFT JOIN source_uom su ON su.source_uom_id = sdd.deal_volume_uom_id     
			LEFT JOIN #bonus bns ON bns.state_value_id = sp.state_value_id    
				AND bns.technology = tfr.technology
				AND (bns.curve_id IS NULL OR tfr.source_curve_def_id = bns.curve_id)  
				AND sdd.term_start between bns.from_date and bns.to_date  
				AND bns.gen_state_value_id = tfr.gen_state_value_id
				AND sdd.term_start BETWEEN bns.from_date AND bns.to_date  '
			
		SET @sql_stmt2 ='
			LEFT JOIN rec_volume_unit_conversion Conv1 ON conv1.from_source_uom_id = sdd.deal_volume_uom_id               
				AND conv1.to_source_uom_id = '+ISNULL(CAST(@req_convert_uom_id AS VARCHAR),'NULL')+'              
				And conv1.state_value_id = state.value_id  
				AND conv1.assignment_type_value_id = ' + CAST(@req_assignment_type AS VARCHAR) + '    
				AND conv1.curve_id = sdd.curve_id     
				AND conv1.to_curve_id IS NULL        
			LEFT JOIN rec_volume_unit_conversion Conv2 ON conv2.from_source_uom_id = sdd.deal_volume_uom_id   
				AND conv2.to_source_uom_id = '+ISNULL(CAST(@req_convert_uom_id AS VARCHAR),'NULL')+'              
				And conv2.state_value_id IS NULL  
				AND conv2.assignment_type_value_id = ' + CAST(@req_assignment_type AS VARCHAR) + '    
				AND conv2.curve_id = sdd.curve_id    
				AND conv2.to_curve_id IS NULL        
			LEFT JOIN rec_volume_unit_conversion Conv3 ON conv3.from_source_uom_id =  sdd.deal_volume_uom_id              
				AND conv3.to_source_uom_id = '+ISNULL(CAST(@req_convert_uom_id AS VARCHAR),'NULL')+'              
				And conv3.state_value_id IS NULL  
				AND conv3.assignment_type_value_id IS NULL  
				AND conv3.curve_id = sdd.curve_id            
				AND conv3.to_curve_id IS NULL        
			LEFT JOIN rec_volume_unit_conversion Conv4 ON conv4.from_source_uom_id = sdd.deal_volume_uom_id  
				AND conv4.to_source_uom_id = '+ISNULL(CAST(@req_convert_uom_id AS VARCHAR),'NULL')+'              
				And conv4.state_value_id IS NULL  
				AND conv4.assignment_type_value_id IS NULL  
				AND conv4.curve_id IS NULL  
				AND conv4.to_curve_id IS NULL        
			LEFT JOIN rec_volume_unit_conversion Conv5 ON conv5.from_source_uom_id  = sdd.deal_volume_uom_id                
				AND conv5.to_source_uom_id = '+ISNULL(CAST(@req_convert_uom_id AS VARCHAR),'NULL')+'              
				And conv5.state_value_id = state.value_id  
				AND conv5.assignment_type_value_id is null  
				AND conv5.curve_id = sdd.curve_id   
				AND conv5.to_curve_id IS NULL
			OUTER APPLY(
						   SELECT CAST(
									  COALESCE(
										  conv1.conversion_factor
										 , conv5.conversion_factor
										 , conv2.conversion_factor
										 , conv3.conversion_factor
										 , conv4.conversion_factor
										 , 1
									  ) AS NUMERIC(20, 8)
								  ) AS conversion_factor
					   ) rs_cf     
			LEFT JOIN gis_certificate gis ON gis.source_deal_header_id = sdd.source_deal_detail_id 
				AND gis.state_value_id = tfr.state_value_id
				AND (gis.tier_type IS NULL OR gis.tier_type = tfr.tier_type)
			LEFT JOIN static_data_value sdv_gen_state ON sdv_gen_state.value_id=tfr.gen_state_value_id  
			WHERE  1 = 1  
				AND sdd.volume_left > 0  
				AND sdd.volume_left IS NOT NULL -- select deals having volume available
				AND YEAR(sdd.term_start) <= ' + CAST(@req_compliance_year AS VARCHAR(10)) + ' 
				AND sdd.term_start <= CASE WHEN (ISNULL(sp.bank_assignment_required, ''n'') = ''n'') THEN CONVERT(NVARCHAR(10), ''' + @req_assigned_date + ''', 20) ELSE sdd.term_start END 
			
				AND (CASE WHEN  ' +ISNULL(CAST(@req_assignment_type AS VARCHAR),5146) + '=5173 THEN 
	 			--replace FNADEALRECExpirationState with equivalent code (for year only) to gain performance
	 			  YEAR(DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, CAST((YEAR(sdd.term_start) + 
									CASE WHEN(ISNULL(tfr.gen_offset_technology, ''n'') = ''n'') THEN 
										ISNULL(spd.duration, ISNULL(sp.duration, 0)) 
									ELSE ISNULL(spd.offset_duration, ISNULL(sp.offset_duration, 0)) END 
									- 1) AS VARCHAR) 
									+ ''-'' + CAST(ISNULL(sp.calendar_to_month, 12) AS VARCHAR) + ''-01'') + 1, 0))) 
		  
		 
			 ELSE CASE WHEN gis.source_certificate_number IS NOT NULL AND gis.contract_expiration_date IS NOT NULL 
			 THEN  YEAR(gis.contract_expiration_date)
	 		 --replace FNADEALRECExpirationState with equivalent code (for year only) to gain performance   
	 		 ELSE YEAR(DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, CAST((YEAR(sdd.term_start) + 
									CASE WHEN(ISNULL(tfr.gen_offset_technology, ''n'') = ''n'') THEN 
										ISNULL(spd.duration, ISNULL(sp.duration, 0)) 
									ELSE ISNULL(spd.offset_duration, ISNULL(sp.offset_duration, 0)) END 
									- 1) AS VARCHAR) 
									+ ''-'' + CAST(isnull(sp.calendar_to_month, 12) AS VARCHAR) + ''-01'') + 1, 0)))  
			 END  END >= ' + CAST(@req_compliance_year AS VARCHAR) + ' OR spd.not_expire = ''n'')' + 
				--INVENTORY tab Filters
				+ CASE WHEN @inv_env_product IS NOT NULL THEN ' AND rg.source_curve_def_id = ' + @inv_env_product ELSE '' END
				+ CASE WHEN @inv_gen_date_from IS NOT NULL THEN ' AND sdd.term_start >= ''' + CAST(@inv_gen_date_from AS VARCHAR) + '''' ELSE '' END
				+ CASE WHEN @inv_gen_date_to IS NOT NULL THEN ' AND sdd.term_start <= ''' + CAST(@inv_gen_date_to AS VARCHAR) + '''' ELSE '' END
				+ CASE WHEN @inv_counterparty_id IS NOT NULL THEN ' AND sc.source_counterparty_id = ' + CAST(@inv_counterparty_id AS VARCHAR) + '' ELSE '' END
				+ CASE WHEN @inv_gen_state IS NOT NULL THEN ' AND rg.gen_state_value_id = ' + CAST(@inv_gen_state AS VARCHAR) + '' ELSE '' END
				+ CASE WHEN @inv_cert_from IS NOT NULL THEN ' AND gis.certificate_number_from_int >= ' + CAST(@inv_cert_from AS VARCHAR) + '' ELSE '' END
				+ CASE WHEN @inv_cert_to IS NOT NULL THEN ' AND gis.certificate_number_to_int <= ' + CAST(@inv_cert_to AS VARCHAR) + '' ELSE '' END

		IF @debug = 1  
		PRINT @sql_Stmt + @sql_stmt2
		EXEC (@sql_Stmt + @sql_stmt2)	

		IF @target_type = 'a'
		BEGIN
			SET @sql_Stmt = '
			UPDATE td SET td.volume_left = (td.volume_left-st.volume)
			FROM #temp_deals td
			INNER JOIN (SELECT sr.rec_deal_detail_id AS detail_id, SUM(sr.volume_assign) AS volume FROM ' + @sales_rec + ' sr GROUP BY sr.rec_deal_detail_id) st 
					ON st.detail_id = td.source_deal_detail_id'

			IF @debug = 1
			PRINT @sql_Stmt
			EXEC (@sql_Stmt)
		END

		IF @req_assignment_type='5173'
		BEGIN
			SET @req_volume_type = 's'

			SET @sql_Stmt = '
			UPDATE td SET td.volume_left = (td.volume_left-st.volume)
			FROM #temp_deals td
			INNER JOIN (SELECT sr.rec_deal_detail_id AS detail_id, SUM(sr.volume_assign) AS volume FROM ' + @sales_rec + ' sr GROUP BY sr.rec_deal_detail_id) st 
					ON st.detail_id = td.source_deal_detail_id'

			IF @debug = 1
			PRINT @sql_Stmt
			EXEC (@sql_Stmt)

		END
		   
		IF @debug = 1  
		BEGIN  
			PRINT @pr_name + ': ' + CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'  
			PRINT '**************** End of Eligible Deal Collection *****************************'   
		END  

		--******************************************************    
		-- Sort the Deals based ON the Priority Group  
		--******************************************************    
		IF @debug = 1  
		BEGIN  
			SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)  
			SET @log_increment = @log_increment + 1  
			SET @log_time=GETDATE()  
			PRINT @pr_name+' Running..............'  
		END

		--Prepare the priority order in a variable
		IF @req_assignment_priority iS NULL AND @req_volume_type = 'r'
		SELECT 
			@req_assignment_priority = rec_assignment_priority_group_id 
		FROM state_rec_requirement_data 
		WHERE state_value_id = @req_assigned_state
		AND @req_compliance_year BETWEEN from_year AND to_year  

		DECLARE @priority_order_by VARCHAR(1000)
		SELECT @priority_order_by = STUFF((
			SELECT ', ' + (CASE --rapd.priority_type 
						--IMP: Make sure alias and column name match with the dataset
						WHEN rapd.priority_type = 21000 THEN 'MAX(td.price)' + (CASE MAX(rapo.priority_type_value_id) WHEN 21000 THEN ' DESC' ELSE ' ASC' END)--Cost
						WHEN rapd.priority_type = 21100 THEN 'MAX(td.term_start)' + (CASE MAX(rapo.priority_type_value_id) WHEN 21100 THEN ' ASC' ELSE ' DESC' END)--Vintage
						--Tier Type
						--IMP: if priority is not defined for some products, put it into the last by putting largest INT value. Otherwise 
						--rapo_prd.order_number will be NULL and put first in the priority
						WHEN rapd.priority_type IN (20900) THEN 'ISNULL(MIN(rapo_prd.product), 2147483647) ASC'--Product
						WHEN rapd.priority_type IN (15000) THEN 'ISNULL(MIN(rapo_prd.tier), 2147483647) ASC'--Tier
						WHEN rapd.priority_type IN (10009) THEN 'ISNULL(MIN(rapo_prd.technology), 2147483647) ASC'--Technology
						WHEN rapd.priority_type IN (13000) THEN 'ISNULL(MIN(rapo_prd.tech_sub_type), 2147483647) ASC'--Technology Sub Type
					END) 																
			FROM rec_assignment_priority_order rapo
			INNER JOIN rec_assignment_priority_detail rapd ON rapd.rec_assignment_priority_detail_id = rapo.rec_assignment_priority_detail_id
			INNER JOIN rec_assignment_priority_group rapg ON rapg.rec_assignment_priority_group_id = rapd.rec_assignment_priority_group_id
			WHERE 1 = 1 
				AND rapg.rec_assignment_priority_group_id = @req_assignment_priority
			GROUP BY rapd.priority_type, rapd.order_number
			ORDER BY rapd.order_number
		FOR XML PATH('')), 1, 2, '')

		IF NULLIF(@priority_order_by, '') IS NULL
			SET @priority_order_by = 'MAX(td.term_start) ASC'

		SET @sql = '
			UPDATE td
			SET priority = td_sorted.priority
			FROM #temp_deals td
			INNER JOIN (
				SELECT ROW_NUMBER() OVER(ORDER BY ' + @priority_order_by + ') priority, id
				FROM #temp_deals td
				OUTER APPLY (
				SELECT rapd.priority_type, 
					--rapo.priority_type_value_id, 
					prod.order_number AS product, 
					tier.order_number AS tier,
					tech.order_number AS technology,
					techSub.order_number AS tech_sub_type 
				FROM rec_assignment_priority_group rapg
				INNER JOIN rec_assignment_priority_detail rapd ON rapg.rec_assignment_priority_group_id = rapd.rec_assignment_priority_group_id
				OUTER APPLY (SELECT rapo.order_number FROM rec_assignment_priority_order rapo 
							WHERE rapd.rec_assignment_priority_detail_id = rapo.rec_assignment_priority_detail_id
								AND rapo.priority_type_value_id = td.product) prod
				OUTER APPLY (SELECT rapo.order_number FROM rec_assignment_priority_order rapo 
							WHERE rapd.rec_assignment_priority_detail_id = rapo.rec_assignment_priority_detail_id
								AND rapo.priority_type_value_id = td.tier_type) tier
				OUTER APPLY (SELECT rapo.order_number FROM rec_assignment_priority_order rapo 
							WHERE rapd.rec_assignment_priority_detail_id = rapo.rec_assignment_priority_detail_id
								AND rapo.priority_type_value_id = td.technology) tech
				OUTER APPLY (SELECT rapo.order_number FROM rec_assignment_priority_order rapo 
							WHERE rapd.rec_assignment_priority_detail_id = rapo.rec_assignment_priority_detail_id
								AND rapo.priority_type_value_id = td.tech_sub_type) techSub
				LEFT JOIN state_rec_requirement_data srrd ON srrd.rec_assignment_priority_group_id = rapg.rec_assignment_priority_group_id
				WHERE 1 = 1 ' +
					CASE WHEN @req_assignment_priority IS NOT NULL THEN ' 
					AND rapg.rec_assignment_priority_group_id = ' + CAST(@req_assignment_priority AS VARCHAR) ELSE '' END + '
				) rapo_prd
				GROUP BY id
			) td_sorted ON td_sorted.id = td.id
		'

		IF @debug = 1
		PRINT (@sql)
		EXEC (@sql)	
	
		IF @debug = 1
		BEGIN
			SELECT '#temp_deals' AS tbl_sorted
			SELECT * FROM #temp_deals ORDER BY priority
		END

		--Take account of adjustment deals, which will deduct the volume of eligible detail RECs
		SET @sql = '
			UPDATE td
			SET volume_left = td.volume_left - rs_adjst.adjst_deal_volume
			FROM #temp_deals td
			CROSS APPLY (
				SELECT
					SUM(sdd_adjst.deal_volume) adjst_deal_volume
				FROM #temp_filtered_recs tfr
				INNER JOIN source_deal_header sdh_adjst ON sdh_adjst.source_deal_header_id = tfr.source_deal_header_id
					AND sdh_adjst.generator_id = td.generator_id
					AND sdh_adjst.status_value_id = 5182	--include only adjustment deals (Status: Adjustments)
				INNER JOIN source_deal_detail sdd_adjst ON sdd_adjst.source_deal_header_id = sdh_adjst.source_deal_header_id
					AND sdd_adjst.buy_sell_flag = ''s''	--offset deal will be sell
					AND sdd_adjst.term_start = td.term_start
			) rs_adjst
			WHERE rs_adjst.adjst_deal_volume IS NOT NULL	--avoid updating deals which do not have adjustments
		'
	
		IF @debug = 1
		PRINT @sql
		EXEC (@sql)

		CREATE INDEX [IX_td_tech_state] ON #temp_deals (source_deal_header_id, term_start, tier_type, sub_tier_value_id)
		CREATE INDEX [IX_td_priority] ON #temp_deals (priority) 

	END
		
	IF OBJECT_ID('tempdb..#temp_tier_type') IS NOT NULL
		DROP TABLE #temp_tier_type
		
	--create a mapping table with tier and technology-gen_state. This table will be used to resolve tier of a deal
	CREATE TABLE #temp_tier_type (
		tier_type INT,
		source_deal_header_id INT
	)
		
	IF OBJECT_ID('tempdb..#target_profile') IS NOT NULL
		DROP TABLE #target_profile
	
	--create table to hold target for each tier
	CREATE TABLE #target_profile  
	(    
		effective_year_from DATETIME, 
		effective_year_to DATETIME, 
		tier_type_name VARCHAR(150) COLLATE DATABASE_DEFAULT,
		tier_type INT,  
		min_target NUMERIC(38, 20),    
		max_target NUMERIC(38, 20),  
		total_target NUMERIC(38, 20),
		requirement_type_id INT,
		sub_tier_value_id INT
	)  

	IF OBJECT_ID('tempdb..#target_profile_cons') IS NOT NULL
		DROP TABLE #target_profile_cons

	CREATE TABLE #target_profile_cons(
		sub_tier_value_id INT,
		max_target INT
	)

	INSERT INTO #temp_tier_type (tier_type, source_deal_header_id)
	SELECT tier_type, source_deal_header_id FROM #temp_filtered_recs_with_tier

	IF @target_type <> 'a'
	BEGIN
		IF @flag = 'o' AND @req_volume_type = 'f' 
		BEGIN
			--put total target in a table with tier type (in this case, only one tier (VirtualTier with id: 0) is assumed.
			INSERT INTO #target_profile (effective_year_from, effective_year_to, tier_type_name, tier_type, min_target, max_target, total_target, requirement_type_id)
			SELECT DISTINCT NULL effective_year_from, 
				NULL effective_year_to, 
				sdv.code tier_type_name, 
				tier_type, --pick only Assignement type requirements
				NULL min_target, 
				NULL max_target,
				@req_volume total_target,
				23400 requirement_type_id	
			FROM #temp_filtered_recs_with_tier tfrwt 
			INNER JOIN static_data_value sdv ON sdv.value_id = tfrwt.tier_type
			WHERE 1 = 1
		END
		ELSE
		BEGIN
			IF OBJECT_ID('tempdb..#target_deal_volume') IS NOT NULL
				DROP TABLE #target_deal_volume
					
			SELECT SUM(sdd.deal_volume * ISNULL(sdd.multiplier,1)) deal_volume,
				YEAR(sdd.term_start) term_yr, 
				sdh.state_value_id, 
				sdh.tier_value_id
			INTO #target_deal_volume
			FROM source_deal_header sdh   
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id  
			INNER JOIN #ssbm_target ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1  
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2  
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3  
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4  
			WHERE 1 = 1  
				AND (@req_deal_id IS NOT NULL OR ssbm.fas_deal_type_value_id = CASE WHEN @req_volume_type = 'r' THEN 409 ELSE 405 END)
				AND YEAR(sdd.term_start) = @req_compliance_year
				AND (@req_deal_id IS NULL OR sdh.source_deal_header_id IN (@req_deal_id)) --65753
				AND (@req_gen_date_from IS NULL OR sdd.term_start BETWEEN @req_gen_date_from AND @req_gen_date_to)
				GROUP BY YEAR(sdd.term_start), sdh.state_value_id, sdh.tier_value_id
	
			IF @req_volume_type = 'r'
			BEGIN
				INSERT INTO #target_profile (
					effective_year_from, 
					effective_year_to, 
					tier_type_name, 
					tier_type, 
					min_target, 
					max_target, 
					total_target, 
					requirement_type_id, 
					sub_tier_value_id)
				SELECT MAX(srrd.from_year) effective_year_from, MAX(srrd.to_year) effective_year_to, MAX(sdv_tt.code) tier_type_name, srrde.tier_type
				, ISNULL(MAX(CAST(srrde.min_absolute_target AS INT)), (MAX(srrde.min_target) / 100 * MAX(dv.deal_volume))) - ISNULL(MAX(assigned_volume),0)  min_target 
				, ISNULL(MAX(CAST(srrde.max_absolute_target AS INT)) , (MAX(srrde.max_target) / 100 * MAX(dv.deal_volume))) - ISNULL(MAX(assigned_volume),0) max_target
				, ISNULL((MAX(srrd.per_profit_give_back) / 100 * MAX(dv.deal_volume)), MAX(srrd.renewable_target)) total_target
				, MIN(srrd.requirement_type_id) requirement_type_id	
				--MIN is used to pick up requiremtn type: Assignment for those tiers which is both assignment and constraint (e.g. Out of State All RECs)
				, srrde.sub_tier_value_id
				FROM state_rec_requirement_data srrd 
				INNER JOIN state_rec_requirement_detail srrde ON srrd.state_rec_requirement_data_id = srrde.state_rec_requirement_data_id
				INNER JOIN static_data_value sdv_tt ON sdv_tt.value_id = CASE WHEN NULLIF(srrde.sub_tier_value_id, 0) IS NULL THEN srrde.tier_type ELSE sdv_tt.value_id END 
				LEFT JOIN #target_deal_volume dv ON dv.term_yr BETWEEN srrd.from_year AND srrd.to_year
					AND ISNULL(dv.state_value_id, @req_assigned_state) = srrd.state_value_id				--Fixed
				OUTER APPLY(	
							SELECT SUM(assigned_volume) assigned_volume 
							FROM assignment_audit WHERE assignment_type = srrd.assignment_type_id 
								AND state_value_id = srrd.state_value_id 
								AND compliance_year = @req_compliance_year
								AND srrde.tier_type = tier) aa
				WHERE 1 = 1  
					AND srrd.state_value_id = @req_assigned_state
					AND @req_compliance_year BETWEEN srrd.from_year AND srrd.to_year
					AND (@req_tier_type IS NULL OR srrde.tier_type = @req_tier_type)
					AND (@target_type = 'n' OR (dv.deal_volume IS NOT NULL OR dv.deal_volume > 0))
				GROUP BY srrde.tier_type, srrde.sub_tier_value_id

				INSERT INTO #target_profile_cons
				SELECT DISTINCT tp.sub_tier_value_id, max_target
				FROM #target_profile tp WHERE sub_tier_value_id > 0

				DELETE FROM #target_profile WHERE sub_tier_value_id > 0
			END

			IF @req_volume_type IN ('t', 's')
			BEGIN
				INSERT INTO #target_profile (effective_year_from, effective_year_to, tier_type_name, tier_type, min_target, max_target, total_target, requirement_type_id)
				SELECT DISTINCT NULL effective_year_from, 
					NULL effective_year_to, 
					sdv.code tier_type_name, 
					tier_type, --pick only Assignement type requirements
					NULL min_target, 
					NULL max_target,
					tdv.vol total_target,
					23400 requirement_type_id	
				FROM #temp_filtered_recs_with_tier tfrwt 
				INNER JOIN static_data_value sdv ON sdv.value_id = tfrwt.tier_type
				INNER JOIN(SELECT tier_value_id, SUM(deal_volume) vol FROM #target_deal_volume GROUP BY tier_value_id) tdv ON tdv.tier_value_id = tfrwt.tier_type
				WHERE (@req_tier_type IS NULL OR tfrwt.tier_type = @req_tier_type)
			END
		END
	END

	IF @target_type <> 'n'
	BEGIN
		IF @target_type = 't'
		BEGIN
			IF @req_volume_type = 'r'
			UPDATE #target_profile SET total_target = CASE WHEN ISNULL(min_target, 0) > 0 THEN min_target ELSE max_target END

			SET @sql = '
					INSERT INTO ' + @str_target_table + '(
						compliance_year,
						state_value_id,
						tier_value_id,
						total_target
						)
					SELECT ' + CAST(@req_compliance_year AS VARCHAR) + ', ' + CAST(@req_assigned_state AS VARCHAR) + ', tier_type, total_target FROM #target_profile'

			EXEC(@sql)
			RETURN
		END
		ELSE
		BEGIN
			DELETE FROM #target_profile
			SET @sql = ' 
				INSERT INTO #target_profile(
					effective_year_from, 
					effective_year_to, 
					tier_type_name, 
					tier_type, 
					min_target, 
					max_target, 
					total_target, 
					requirement_type_id) 
				SELECT 
					NULL,
					NULL,
					sdv.code,
					sat.tier_value_id,
					NULL,
					NULL,
					sat.total_target,
					23400
				FROM ' + @str_allocation_table + ' sat
				INNER JOIN static_data_value sdv ON sat.tier_value_id = sdv.value_id'

			EXEC(@sql)

			DELETE FROM #target_profile_cons
		END
	END

	IF @target_type = 't'
		RETURN

	DELETE td 
	FROM #temp_deals td
	WHERE NOT EXISTS(SELECT 1 FROM #target_profile WHERE tier_type = td.tier_type)
	
	IF @debug = 1
	BEGIN
		SELECT '#target_profile' AS tbl
		SELECT * FROM #target_profile
	END
	
	DECLARE @max_loop_count INT
	--DECLARE @loop_index INT
	SET @max_loop_count = 20

	IF @req_volume_type = 't'
		UPDATE tp SET tp.max_target = tp.total_target, tp.total_target = t.tar
		FROM #target_profile tp
		OUTER APPLY(SELECT SUM(total_target) tar FROM #target_profile) t
	
	DECLARE @ii INT = 1, @priority INT, @tier INT, @deal_id INT, @min_max_target INT, @tot_target INT, @tot_assigned_val INT, @remain_val INT, @target INT,
		@tier_assigned INT, @conts_val INT, @sub_tier_value_id INT, @conts_assign INT
	
	WHILE @ii <= 2
	BEGIN
		DECLARE cur_tier_type CURSOR LOCAL FOR
		SELECT priority, tier_type, source_deal_header_id, sub_tier_value_id FROM #temp_deals ORDER BY priority
		OPEN cur_tier_type;
		
		FETCH NEXT FROM cur_tier_type INTO @priority, @tier, @deal_id, @sub_tier_value_id
		WHILE @@FETCH_STATUS = 0
		BEGIN
				
			SELECT @min_max_target = CASE WHEN @ii = 1 THEN ISNULL(min_target, 0) ELSE ISNULL(max_target, 0) END FROM #target_profile WHERE tier_type = @tier --tier min, max
			SELECT @tier_assigned = ISNULL(SUM(vol_to_be_assigned), 0) FROM #temp_deals WHERE tier_type = @tier --tier assigned
			
			SELECT @tot_target = MAX(total_target) FROM #target_profile --total target
			SELECT @tot_assigned_val = ISNULL(SUM(vol_to_be_assigned), 0) FROM #temp_deals --total assigned

			SELECT @remain_val = @tot_target - @tot_assigned_val
			
			--Contraint Check
			SET @conts_val = 0

			SELECT @conts_val = ISNULL(max_target, 0) FROM #target_profile_cons WHERE sub_tier_value_id = @sub_tier_value_id

			SELECT @conts_assign = ISNULL(SUM(vol_to_be_assigned), 0) FROM #temp_deals WHERE sub_tier_value_id = @sub_tier_value_id 
			SELECT @conts_val = @conts_val - @conts_assign

			
			IF @min_max_target = 0 AND @ii = 2
				SELECT @min_max_target = @remain_val
			ELSE
				SELECT @min_max_target = @min_max_target - @tier_assigned
				
			

			IF @remain_val > 0
			BEGIN
				IF EXISTS(SELECT 1 FROM #target_profile_cons WHERE sub_tier_value_id = @sub_tier_value_id)
				BEGIN
					SELECT @target = CASE WHEN @conts_val > @remain_val THEN @remain_val ELSE @conts_val END
				END
				ELSE
					SELECT @target = CASE WHEN @min_max_target > @remain_val THEN @remain_val ELSE @min_max_target END

				SELECT @target = CASE WHEN @target < 0 THEN 0 ELSE @target END

				UPDATE td SET vol_to_be_assigned = ISNULL(vol_to_be_assigned,0) + 
					CASE WHEN (volume_left+volume_left*ISNULL(bonus_per, 0)/100)-ISNULL(vol_to_be_assigned,0) > @target THEN 
						@target 
					ELSE 
						(volume_left+volume_left*ISNULL(bonus_per, 0)/100)-ISNULL(vol_to_be_assigned,0) 
					END
				FROM #temp_deals td
				LEFT JOIN #bonus b ON td.gen_state_value_id = b.gen_state_value_id 
					AND td.technology = b.technology  
					AND td.term_start BETWEEN b.from_date AND b.to_date
					AND (b.curve_id IS NULL OR td.product = b.curve_id)
				WHERE td.priority = @priority
			END
			
		FETCH NEXT FROM cur_tier_type INTO @priority, @tier, @deal_id, @sub_tier_value_id
		END;
		CLOSE cur_tier_type;
		DEALLOCATE cur_tier_type;
		
		SET @ii = @ii+1
		
	END

		UPDATE td SET td.bonus = (td.vol_to_be_assigned-(td.vol_to_be_assigned/(1+ISNULL(b.bonus_per,0)/100)))
		FROM #temp_deals td			
		INNER JOIN #temp_tier_type ttt ON ttt.source_deal_header_id = td.source_deal_header_id
		INNER JOIN #bonus b ON td.gen_state_value_id = b.gen_state_value_id
			AND td.technology = b.technology  
			AND td.term_start BETWEEN b.from_date AND b.to_date
			AND (b.curve_id IS NULL OR td.product = b.curve_id)
		INNER JOIN #target_profile tp ON tp.tier_type = td.tier_type

		UPDATE #temp_deals SET volume_left = (volume_left - (vol_to_be_assigned-bonus))

	SET @bank_assignment = 5149  
	  
	CREATE TABLE #temp_assign (  
		source_deal_detail_id INT,  
		cert_from INT,  
		cert_to INT,  
		assignment_type INT
	)  
	
	CREATE TABLE #temp_cert (  
		source_deal_header_id INT,  
		certificate_number_from_int INT,  
		certificate_number_to_int INT  
	)  
	  
	INSERT #temp_cert  
	SELECT gis.source_deal_header_id, gis.certificate_number_from_int, gis.certificate_number_to_int   
	FROM gis_certificate gis
	INNER JOIN #temp_deals tds ON tds.source_deal_detail_id = gis.source_deal_header_id

	DECLARE cursor1 CURSOR FOR  
	SELECT source_deal_header_id, certificate_number_from_int, certificate_number_to_int 
	FROM #temp_cert  
	  
	OPEN cursor1  
	FETCH NEXT FROM cursor1 INTO @gis_deal_id, @certificate_f, @certificate_t  
	   
	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		DECLARE cursor2 CURSOR FOR   
		SELECT cert_from, cert_to 
		FROM assignment_audit 
		WHERE source_deal_header_id_from = @gis_deal_id AND assigned_volume > 0  
		ORDER BY cert_from
		
		OPEN cursor2  
		FETCH NEXT FROM cursor2 INTO @inv_cert_from_f, @inv_cert_to_t  
		WHILE @@FETCH_STATUS = 0  
		BEGIN  
			IF @inv_cert_from_f > @certificate_f   
			BEGIN  
				INSERT #temp_assign (source_deal_detail_id, cert_from, cert_to, assignment_type)  
				VALUES (@gis_deal_id, @certificate_f, @inv_cert_from_f - 1, @bank_assignment)  
			END  

			SET @certificate_f = @inv_cert_to_t + 1  

			FETCH NEXT FROM cursor2 INTO @inv_cert_from_f, @inv_cert_to_t  
		END  
		IF (@certificate_f - 1) < @certificate_t  
		BEGIN  
			INSERT #temp_assign (source_deal_detail_id, cert_from, cert_to, assignment_type) 
			VALUES (@gis_deal_id, @certificate_f, @certificate_t, @bank_assignment)  
		END  
		FETCH NEXT FROM cursor1 INTO @gis_deal_id,@certificate_f,@certificate_t  
		
		CLOSE cursor2  
		DEALLOCATE cursor2   
	 END   
	CLOSE cursor1  
	DEALLOCATE cursor1   
	   
	IF OBJECT_ID('tempdb..#temp_final') IS NOT NULL
		DROP TABLE #temp_final
	  
	CREATE TABLE #temp_final (  
		[ID] INT IDENTITY,  
		source_deal_detail_id INT,  
		cert_From INT,  
		cert_to INT,  
		assignment_type INT,  
		volume NUMERIC(38, 20)   
	)

	INSERT INTO #temp_final(source_deal_detail_id, cert_from, cert_to, assignment_type, volume)  
	SELECT source_deal_detail_id, cert_from, cert_to, assignment_type, (cert_to - cert_from + 1) AS volume
	FROM (  
		SELECT source_deal_detail_id, cert_from, cert_to, assignment_type FROM #temp_assign  
		UNION ALL  
		SELECT source_deal_header_id_from, cert_from, cert_to, assignment_type FROM assignment_audit  
	) a

	IF OBJECT_ID('tempdb..#temp_final2') IS NOT NULL
		DROP TABLE #temp_final2
	  
	SELECT [ID], source_deal_detail_id, cert_from, cert_to, assignment_type, a.volume,volume_cumu, vol_to_be_assigned AS volume_left 
	INTO #temp_final2 
	FROM  
	(  
		SELECT b.[ID], b.source_deal_detail_id, cert_from, cert_to,assignment_type, a.volume
		, (SELECT SUM(volume) 
			 FROM #temp_final 
			 WHERE [ID] <= a.[ID] --and assignment_type = @req_assignment_type  
				AND source_deal_detail_id = a.source_deal_detail_id
			) AS volume_cumu
		, b.vol_to_be_assigned
		FROM #temp_final a
		INNER JOIN #temp_deals b ON a.source_deal_detail_id = b.source_deal_detail_id 
		WHERE 1 = 1 AND assignment_type = @req_assignment_type   
	) a  
	WHERE ROUND((CASE WHEN volume_cumu - vol_to_be_assigned <= 0 THEN volume ELSE    
	 volume - (volume_cumu - vol_to_be_assigned) END), @vol_rounding) > 0    

	  
	IF OBJECT_ID('tempdb..#temp_include') IS NOT NULL
		DROP TABLE #temp_include

	CREATE TABLE #temp_include    
	( 
		id INT,    
		deal_id INT,    
		volume_assign NUMERIC(38, 20),      
		bonus NUMERIC(38, 20),      
		volume NUMERIC(38, 20),    
		volume_left NUMERIC(38, 20),
		tier_type_value_id INT   
	)
	   
	INSERT INTO #temp_include    
	SELECT id,source_deal_header_id, vol_to_be_assigned AS volume_assign    
	, CASE WHEN vol_to_be_assigned = 0 OR vol_to_be_assigned - volume_left_cumu  <= 0 THEN volume_left - volume_left1 ELSE    
	(volume_left - (vol_to_be_assigned - volume_left_cumu)) - ((volume_left - (vol_to_be_assigned - volume_left_cumu)) / (1 + bonus_per)) END  AS bonus,  
	 a.volume_left AS volume,  
	a.volume_left AS volume_left,
	a.tier_type
	FROM
	(
		SELECT id, source_deal_header_id, volume, bonus, (bonus / (CASE WHEN volume = 0 THEN 1 ELSE volume END)) bonus_per, volume_left + (volume_left * (bonus / CASE WHEN volume = 0 THEN 1 ELSE volume END)) volume_left
		, volume_left volume_left1, vol_to_be_assigned, tier_type
		, (
			SELECT SUM(volume_left + (volume_left * (bonus / CASE WHEN volume = 0 THEN 1 ELSE volume END))) 
			FROM #temp_deals WHERE id <= a.id
			) AS volume_left_cumu    
	FROM     
	#temp_deals a    
	) a     
	WHERE  1=1
			
	IF @table_name IS NULL OR @table_name = ''    
		SET @table_name = dbo.FNAProcessTableName('recassign_', dbo.FNADBUser(), dbo.FNAGetNewID())
			 
	SET @sql = '
	SELECT row_unique_id = IDENTITY(INT, 1, 1),
		tds.source_deal_header_id [rec_deal_id], 
		tds.source_deal_detail_id [rec_deal_detail_id],  
		dbo.FNADateFormat(tds.deal_date) deal_date,
		dbo.FNADateFormat(tds.gen_date) [vintage], 
		dbo.FNADateFormat(tds.expiration_date) expiration, 
		sdv_jurisdiction.code jurisdiction, 
		sdv_gen.code [gen_state], 
		rg.name [generator],
		spcd.curve_name obligation,
		sc.counterparty_name [counterparty], 
		ROUND(tds.volume_left, 0) [volume_left],
		ROUND(isnull(tds.bonus,0), 0) bonus, 
		su.uom_name [UOM], 
		tds.price,
		ROUND((vol_to_be_assigned - ' + CASE WHEN @target_type IN ('t','a') THEN '0' ELSE 'tds.bonus' END + '), 0) [volume_assign], 
		ROUND(vol_to_be_assigned, 0) [total_volume], ' + 
		CASE WHEN @inv_cert_from IS NOT NULL THEN 
			CAST(@inv_cert_from AS VARCHAR) 
		ELSE 
			'  COALESCE(tf.cert_from,assign1.assigned_volume+gis.certificate_number_from_int,gis.certificate_number_from_int) ' 
		END +' as cert_from,' + 
		CASE WHEN @inv_cert_to IS NOT NULL THEN 
			CAST(@inv_cert_to AS VARCHAR)
		ELSE 
			' ISNULL(CASE WHEN tf.cert_from IS NOT NULL AND tf.volume_left+ROUND(ISNULL(b.bonus/tds.conv_factor, 0), 0)<0 THEN 
						ROUND(tf.volume-b.volume_left,0)+tf.cert_from-1 
					ELSE 
						ROUND(tf.volume-b.volume_Left,0)+tf.cert_from-1 
					END, ISNULL((assign1.assigned_volume-1+b.volume_assign),b.volume_assign)+gis.certificate_number_from_int) ' 
		END +' as cert_to, 
		tds.compliance_year,
		rg.gen_state_value_id, 
		sdv_tech.code [technology], 
		tds.jurisdiction_state_id, 
		sdv_tier.code [tier], 
		tds.tier_type tier_value_id,
		' + ISNULL(@req_deal_id, 'NULL') + ' AS assign_deal,
		tds.inv_ref_id
	--select *
	INTO ' + @table_name + '
	FROM #temp_deals tds
	INNER JOIN #temp_include b ON tds.id = b.id  
		AND tds.tier_type = b.tier_type_value_id
	LEFT JOIN rec_generator rg ON tds.generator_id = rg.generator_id
		AND tds.gen_state_value_id = rg.gen_state_value_id
		AND tds.technology = rg.technology
	LEFT JOIN static_data_value sdv_tier ON sdv_tier.value_id = tds.tier_type
	LEFT JOIN static_data_value sdv_tech ON sdv_tech.value_id = rg.technology
	INNER JOIN static_data_value sdv_jurisdiction ON sdv_jurisdiction.value_id = tds.jurisdiction_state_id
	LEFT JOIN static_data_value sdv_gen ON sdv_gen.value_id =  rg.gen_state_value_id
	LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = tds.product 
	LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = tds.counterparty_id 
	LEFT JOIN assignment_audit assign ON tds.source_deal_detail_id = assign.source_deal_header_id 
	LEFT JOIN source_uom su ON su.source_uom_id = tds.uom_id	
	LEFT JOIN static_data_value state ON state.value_id = ISNULL(assign.state_value_id,rg.state_value_id)
	LEFT JOIN #temp_final2 tf ON tf.source_deal_detail_id = tds.source_deal_detail_id
	LEFT JOIN certificate_rule cr ON isnull(rg.gis_value_id, 5164) = cr.gis_id
	LEFT JOIN        
		(
			SELECT source_deal_header_id_from,sum(assigned_volume) assigned_volume from         
			assignment_audit group by source_deal_header_id_from
		) assign1        
		ON assign1.source_deal_header_id_from=tds.source_deal_header_id 
	LEFT JOIN #temp_cert gis ON gis.source_deal_header_id = tds.source_deal_header_id   
	WHERE ROUND(tds.vol_to_be_assigned, ' + CAST(@vol_rounding AS VARCHAR(15)) + ') > 0
	ORDER BY tds.priority'
	
	IF @debug = 1	
	PRINT @sql
	EXEC(@sql)

	 IF @target_type = 'a'
	 BEGIN
		SET @sql = 'INSERT INTO ' + @str_target_table + ' (compliance_year, state_value_id, tier_value_id, total_target)
				SELECT compliance_year,  
					jurisdiction_state_id,
					tier_value_id, 
					SUM(volume_assign)
				FROM ' + @table_name + '
				GROUP BY compliance_year,  
					jurisdiction_state_id,
					tier_value_id'
		
		IF @debug = 1
		PRINT(@sql)
		EXEC(@sql)

		SET @sql = 'INSERT INTO ' + @sales_rec + '
				SELECT rec_deal_id, 
					rec_deal_detail_id,
					deal_date,
					vintage,
					jurisdiction,
					gen_state,
					generator,
					obligation,
					volume_left,
					volume_assign,
					total_volume,
					compliance_year,
					gen_state_value_id,
					technology,
					jurisdiction_state_id,
					tier,
					tier_value_id
				FROM ' + @table_name

		IF @debug = 1
		PRINT(@sql)
		EXEC(@sql)
	 END
	 ELSE
	 BEGIN
		 IF @req_assignment_type = 5146
		 BEGIN
			SET @sql = '
				SELECT ''' + @table_name + ''' [Process Table]
					, assign_deal
					, NULL dem_ref_id
					, row_unique_id
					, rec_deal_id AS [Deal ID]
					, inv_ref_id
					, rec_deal_detail_id AS [ID]
					, deal_date [Deal Date]
					, Vintage--, Expiration 
					, Jurisdiction
					, [Tier] as [Assigned To Tier]
					, Technology
					, gen_state AS [Gen State]
					, Generator
					, obligation [Env Product]
					, Counterparty
					, CAST(dbo.FNARemoveTrailingZero(ROUND(CAST([volume_assign] AS NUMERIC(38, 20)), ' + CAST(@vol_rounding AS VARCHAR(2)) + ')) AS FLOAT)  [Volume Assign]
					, CAST(dbo.FNARemoveTrailingZero(ROUND(CAST([volume_left] AS NUMERIC(38, 20)), ' + CAST(@vol_rounding AS VARCHAR(2)) + ')) AS FLOAT)  AS [Volume Available]
					, CAST(dbo.FNARemoveTrailingZero(ROUND(CAST(bonus AS NUMERIC(38, 20)), ' + CAST(@vol_rounding AS VARCHAR(2)) + ')) AS FLOAT)  Bonus 
					, CAST(dbo.FNARemoveTrailingZero(ROUND(CAST([total_volume] AS NUMERIC(38, 20)), ' + CAST(@vol_rounding AS VARCHAR(2)) + ')) AS FLOAT) [Total Volume]
					, UOM
					, CAST(dbo.FNARemoveTrailingZero(ROUND(Price, ' + CAST(@vol_rounding AS VARCHAR(2)) + ')) AS FLOAT) [Price]
					, gen_state_value_id, jurisdiction_state_id, compliance_year, tier_value_id
				FROM ' + @table_name + ' a
				ORDER BY row_unique_id'
		END
		ELSE
		BEGIN
			SET @sql = 'INSERT INTO ' + @sales_rec + '
				SELECT 
					t.rec_deal_id,
					t.rec_deal_detail_id,
					t.deal_date,
					t.vintage,
					t.expiration,
					t.jurisdiction,
					t.gen_state,
					t.generator,
					t.obligation,
					t.counterparty,
					t.volume_left,
					t.bonus,
					t.UOM,
					t.price,
					t.volume_assign,
					t.total_volume,
					t.cert_from,
					t.cert_to,
					t.compliance_year,
					t.gen_state_value_id,
					t.technology,
					t.jurisdiction_state_id,
					t.tier,
					t.tier_value_id,
					t.assign_deal,
					t.inv_ref_id,
					sdh.deal_id AS dem_ref_id
				FROM ' + @table_name + ' t
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = t.assign_deal
				'
		END

		IF @debug = 1
		PRINT @sql
		EXEC(@sql)
	END
END
GO