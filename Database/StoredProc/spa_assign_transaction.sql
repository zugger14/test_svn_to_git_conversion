IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_assign_transaction]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_assign_transaction]
/*
/* SP Created By: Shushil Bohara
 * Created Dt: 20-June-2017
 * Description: Logic to create Assign deals, works for RPS Compliance and Sold/Transfer Only
 * Insert records in assignment_audit table then it will update the volume_left of REC deals 
 *
 */ 
* */
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spa_assign_transaction]
	@source_deal_detail_ids VARCHAR(MAX) = NULL, 
	@assignment_type INT = NULL, 
	@assigned_state INT = NULL, --@assigned_state IS NULL for Buy/Sell
	@compliance_year INT = NULL, 
	@assigned_date DATETIME = NULL, 
	@assigned_counterparty INT = NULL, 
	@assigned_price NUMERIC(38, 20) = NULL, 
	@trader_id INT = NULL, 
	@table_name VARCHAR(500) = NULL, 
	@unassign INT = 0, 
	@user_id VARCHAR(50) = NULL, 
	@gen_state INT = NULL, 
	@gen_year INT = NULL, 
	@gen_date_from DATETIME = NULL, 
	@gen_date_to DATETIME = NULL, 
	@generator_id INT = NULL, 
	@counterparty_id INT = NULL, 
	@book_deal_type_map_id INT = NULL, 
	@assign_id VARCHAR(100) = NULL, 
	@template_id INT = NULL, 
	@volume VARCHAR(100) = NULL, 
	@select_all_deals INT = 0, 
	@selected_row_ids VARCHAR(MAX) = NULL, 
	@committed BIT = 0,
	@compliance_group_id INT = NULL,
	@commit_type CHAR(1) = NULL,
	@call_from_old INT = 0,
	@call_from_sale_deal INT = NULL,
	@original_deal_id INT = NULL,
	@inserted_source_deal_header_id VARCHAR(MAX) = NULL OUTPUT,		 
	@program_scope INT = NULL		
AS
SET NOCOUNT ON
/**************************TEST CODE START************************				
DECLARE	@source_deal_detail_ids	VARCHAR(MAX)	=	NULL
DECLARE	@assignment_type	INT	=	NULL
DECLARE	@assigned_state	INT	=	NULL
DECLARE	@compliance_year	INT	=	NULL
DECLARE	@assigned_date	DATETIME	=	NULL
DECLARE	@assigned_counterparty	INT	=	NULL
DECLARE	@assigned_price	NUMERIC	=	NULL
DECLARE	@trader_id	INT	=	NULL
DECLARE	@table_name	VARCHAR(500)	=	NULL
DECLARE	@unassign	INT	=	'0'
DECLARE	@user_id	VARCHAR(50)	=	NULL
DECLARE	@gen_state	INT	=	NULL
DECLARE	@gen_year	INT	=	NULL
DECLARE	@gen_date_from	DATETIME	=	NULL
DECLARE	@gen_date_to	DATETIME	=	NULL
DECLARE	@generator_id	INT	=	NULL
DECLARE	@counterparty_id	INT	=	NULL
DECLARE	@book_deal_type_map_id	INT	=	NULL
DECLARE	@assign_id	VARCHAR(100)	=	''
DECLARE	@template_id	INT	=	NULL  
DECLARE	@volume	VARCHAR(100)	=	NULL
DECLARE	@select_all_deals	INT	=	NULL
DECLARE	@selected_row_ids	VARCHAR(MAX)	=	NULL
DECLARE	@committed	BIT	=	NULL
DECLARE	@compliance_group_id	INT	=	NULL
DECLARE	@commit_type	CHAR(1)	=	NULL
DECLARE	@call_from_old	INT	=	NULL
DECLARE	@call_from_sale_deal	INT	=	NULL
DECLARE	@original_deal_id	INT		
DECLARE	@inserted_source_deal_header_id	VARCHAR(MAX)
DECLARE	@program_scope INT = NULL
		
IF OBJECT_ID(N'tempdb..#deal_count1', N'U') IS NOT NULL
	DROP TABLE	#deal_count1			
IF OBJECT_ID(N'tempdb..#deals_count', N'U') IS NOT NULL
	DROP TABLE	#deals_count			
IF OBJECT_ID(N'tempdb..#deals_count1', N'U') IS NOT NULL
	DROP TABLE	#deals_count1			
IF OBJECT_ID(N'tempdb..#inserted_source_deal_header_id', N'U') IS NOT NULL
	DROP TABLE	#inserted_source_deal_header_id			
IF OBJECT_ID(N'tempdb..#source_deal_header_id', N'U') IS NOT NULL
	DROP TABLE	#source_deal_header_id			
IF OBJECT_ID(N'tempdb..#table_name', N'U') IS NOT NULL
	DROP TABLE	#table_name			
IF OBJECT_ID(N'tempdb..#temp_ids', N'U') IS NOT NULL
	DROP TABLE	#temp_ids			
IF OBJECT_ID(N'tempdb..#unique_id', N'U') IS NOT NULL
	DROP TABLE	#unique_id
IF OBJECT_ID(N'tempdb..#sale_deals', N'U') IS NOT NULL
	DROP TABLE #sale_deals			

--SELECT  @assignment_type='5146',@assigned_state='401310',@compliance_year='2017',@assigned_date='2017-07-20',@gen_date_from=NULL,@gen_date_to=NULL,@counterparty_id=NULL,@book_deal_type_map_id='1278',@table_name='adiha_process.dbo.recassign__farrms_admin_05105EF4_F1F4_4C2D_8FDE_63A4D57C4FB7',@assign_id=NULL,@volume=NULL,@select_all_deals='0',@selected_row_ids='1,2,3,4,5,6,7,8,9,10,11,12,13,14',@committed='0',@compliance_group_id=NULL,@call_from_sale_deal='0',@original_deal_id='5146',@call_from_old='0'

----Unassign
--SELECT @assignment_type='5146',@assigned_state='401435',@compliance_year=NULL,@table_name='adiha_process.dbo.recassign__farrms_admin_B0F440AC_63EB_4796_A731_FB9CFA45EAF4',@select_all_deals='0',@selected_row_ids='3,1',@assign_id='1200,1505',@unassign='1'
SELECT
	@assignment_type='5173',
	@assigned_state=NULL,	--Jurisdiction
	@compliance_year='2018',
	@assigned_date='2018-08-14',
	@book_deal_type_map_id='250',
	@table_name='adiha_process.dbo.BuySellMatch__farrms_admin_9E7C9DDF_9DF3_42DD_92C2_41C95546A6AD',
	@call_from_sale_deal='1'

--SELECT * FROM adiha_process.dbo.BuySellMatch__farrms_admin_9C26258F_F0AF_4393_917D_1F3AC3195598

--**************************TEST CODE END************************/				
DECLARE @user_name VARCHAR(50)
DECLARE @sql_stmt VARCHAR(5000)
DECLARE @sql_stmt2 VARCHAR(5000)
DECLARE @sql_where VARCHAR(5000)
DECLARE @sql_where2 VARCHAR(5000)
DECLARE @job_name VARCHAR(100)
DECLARE @process_id VARCHAR(50)
DECLARE @desc VARCHAR(1000)
DECLARE @farrms_dealId VARCHAR(20)
DECLARE @ref_id VARCHAR(20)
DECLARE @deal_id VARCHAR(100)
DECLARE @uom VARCHAR(100)
DECLARE @assign_commit_label VARCHAR(100)
DECLARE @unassign_commit_label VARCHAR(100)
DECLARE @list_of_states VARCHAR(8000) 
DECLARE @compliance INT, @generated INT, @transferred INT, @status_type_id INT = 25000

SELECT @compliance = value_id FROM static_data_value WHERE code = 'Compliance' AND type_id = @status_type_id
SELECT @generated = value_id FROM static_data_value WHERE code = 'Generated' AND type_id = @status_type_id
SELECT @transferred = value_id FROM static_data_value WHERE code = 'Transferred' AND type_id = @status_type_id

SET @sql_where = ''
SET @sql_where2 = ''
SET @farrms_dealId = '' 

IF @assigned_date IS NULL
	SET @assigned_date = GETDATE()


IF @program_scope IS NOT NULL
BEGIN
	SELECT sdv.value_id, sdv.code 
	FROM state_properties sp 
	INNER JOIN static_data_value sdv ON sdv.value_id = sp.state_value_id 
	WHERE sp.program_scope = @program_scope

	RETURN
END
		
SET @assign_commit_label = CASE @committed WHEN 1 THEN 'committed' ELSE 'assigned' END
SET @unassign_commit_label = CASE @committed WHEN 1 THEN 'reverted' ELSE 'unassigned' END

SELECT @deal_id = code FROM static_data_value WHERE value_id = @assignment_type

	IF @table_name IS NOT NULL AND @select_all_deals = 1
	BEGIN
		DECLARE @all_deal_ids VARCHAR(MAX), @sql_ids VARCHAR(250)	
	
		SET @sql_ids = 'SELECT STUFF((SELECT '', '' + CAST([rec_deal_detail_id] AS VARCHAR) FROM '
						+ @table_name + 
						' ORDER BY [rec_deal_detail_id] FOR XML PATH('''')), 1, 1, '''')'
	
		CREATE TABLE #temp_ids(deal_ids VARCHAR(MAX) COLLATE DATABASE_DEFAULT)
		INSERT INTO #temp_ids EXEC(@sql_ids)
		SELECT @all_deal_ids  = deal_ids FROM #temp_ids
	
		SET @sql_where = ' AND rec_deal_detail_id IN (' + CAST(@all_deal_ids AS VARCHAR(MAX)) + ')'
	END	
	ELSE IF @select_all_deals = 0
	BEGIN
		IF @source_deal_detail_ids IS NOT NULL 
			SET @sql_where = ' AND rec_deal_detail_id IN (' + @source_deal_detail_ids + ')'
		
		IF @selected_row_ids IS NOT NULL 
			SET @sql_where = ISNULL(@sql_where, '') + ' AND row_unique_id IN (' + @selected_row_ids + ')'
	END
	ELSE
	BEGIN
		SET @sql_where=''
	END
	
	SET @process_id = dbo.FNAGetNewID()
	SET @job_name = 'rec_' + @process_id

	IF ISNULL(@user_id, '') = ''
		SET @user_name = dbo.FNADBUser()
	ELSE	
		SET @user_name = @user_id

	CREATE TABLE #deals_count
	(
		[ID] INT IDENTITY, 
		source_deal_detail_id INT,
		source_deal_header_id INT, 
		volume NUMERIC(38,20),
		cert_from INT, 
		cert_to INT, 
		assign_id INT, 
		uom VARCHAR(100) COLLATE DATABASE_DEFAULT, 
		compliance_year INT, 
		tier INT,
		state_value_id INT,
		book_deal_type_map_id INT,
		counterparty INT,
		assigned_date DATETIME,
		desc1 VARCHAR(100) COLLATE DATABASE_DEFAULT,
		desc2 VARCHAR(100) COLLATE DATABASE_DEFAULT,
		desc3 VARCHAR(100) COLLATE DATABASE_DEFAULT
	)

	CREATE TABLE #sale_deals
	(
		[ID] INT IDENTITY, 
		deal_id INT,
		detail_id INT,
		sale_deal_id INT,
		sale_detail_id INT, 
		volume INT,
		cert_from INT, 
		cert_to INT, 
		assign_id INT, 
		uom VARCHAR(100) COLLATE DATABASE_DEFAULT, 
		tier INT,
		compliance_year INT,
		state_value_id INT
	)
	

	CREATE TABLE #deals_count1
	(
		[ID] INT IDENTITY, 
		source_deal_detail_id INT, 
		volume NUMERIC(38, 20), 
		cert_from INT, 
		cert_to INT , 
		uom VARCHAR(100) COLLATE DATABASE_DEFAULT, 
		compliance_year INT, 
		tier INT,
		book_deal_type_map_id INT,
		counterparty INT,
		assigned_date DATETIME,
		desc1 VARCHAR(100) COLLATE DATABASE_DEFAULT,
		desc2 VARCHAR(100) COLLATE DATABASE_DEFAULT,
		desc3 VARCHAR(100) COLLATE DATABASE_DEFAULT,
		state_value_id INT
	)

	IF @table_name IS NOT NULL --Collecting deal info from the table
	BEGIN
		IF @unassign = 0
		BEGIN
			SET @sql_stmt = '
			INSERT INTO #deals_count(source_deal_detail_id, volume, cert_from, cert_to, uom, tier, state_value_id) 
			SELECT [rec_deal_detail_id], [volume_assign], CAST(cert_from AS INT), CAST(cert_to AS INT), uom, tier_value_id, jurisdiction_state_id
			FROM ' + @table_name + ' 
			WHERE 1 = 1 ' + @sql_where

			SET @sql_stmt2 = '
			INSERT INTO #deals_count1 (source_deal_detail_id, volume) 
			SELECT [rec_deal_detail_id], SUM([volume_assign]) 
			FROM ' + @table_name + ' 
			WHERE 1 = 1 ' + @sql_where + ' GROUP BY [rec_deal_detail_id] ' 

			EXEC(@sql_stmt)
			EXEC(@sql_stmt2)

		END
		ELSE
		BEGIN
			SET @sql_stmt = 'INSERT INTO #deals_count(source_deal_detail_id, volume, assign_id, uom, tier) 
			SELECT [rec_deal_detail_id], [volume], assign_id, uom , tier_value_id 
			FROM ' + @table_name + ' 
			WHERE 1 = 1 ' + @sql_where

			--print(@sql_stmt)
			EXEC(@sql_stmt)
		END

		SELECT @list_of_states = ISNULL(@list_of_states,'') + CASE WHEN @list_of_states IS NULL THEN '' ELSE ', ' END + sdv.code FROM #deals_count dc
		INNER JOIN (SELECT * FROM static_Data_value WHERE type_id = 10002) sdv ON sdv.value_id = dc.state_value_id 
		GROUP BY sdv.code

		IF (SELECT COUNT(*) FROM #deals_count) <= 0
		BEGIN
			RETURN
		END
	END

	SELECT @uom = MAX(uom) FROM #deals_count
	--Can't find deals for assigning to banked state

	IF @@ERROR <> 0
	BEGIN
	SET @sql_stmt = 'Failed to assign deals: ' + @source_deal_detail_ids
	EXEC spa_ErrorHandler @@ERROR, 'Assign Credits/Allowance Deals', 
			'spa_assign_transaction', 'DB Error', 
			@sql_stmt, ''
	RETURN
	END

	DECLARE @maxid INT
	CREATE TABLE #unique_id([ID] INT IDENTITY, unique_ID INT)

	IF @assignment_type = 5173 AND @call_from_sale_deal = 1 -- Sold Transfer: Inserting link data in assignment_audit and update volume
	BEGIN
		SELECT @maxid = MAX(farrms_id) FROM farrms_dealId
	
		IF @table_name IS NULL      
			INSERT farrms_dealId SELECT GETDATE() FROM transactions
		ELSE
			EXEC('INSERT farrms_dealId SELECT getDate() FROM '+ @table_name)

		SET @sql_stmt = '
			INSERT INTO #sale_deals(deal_id, 
				detail_id, 
				sale_deal_id, 
				' + CASE WHEN @assigned_state IS NULL THEN 'sale_detail_id,' ELSE '' END + '
				volume, 
				cert_from, 
				cert_to, 
				uom, 
				tier,
				compliance_year,
				state_value_id) 
			SELECT [rec_deal_id], 
				[rec_deal_detail_id], 
				assign_deal, 
				' + CASE WHEN @assigned_state IS NULL THEN 'assign_detail_id,' ELSE '' END + '
				[volume_assign], 
				CAST(cert_from AS INT), 
				CAST(cert_to AS INT), 
				uom, 
				tier_value_id,
				compliance_year,
				jurisdiction_state_id
			FROM ' + @table_name + ' t
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = t.rec_deal_detail_id
			WHERE 1 = 1 ' + @sql_where
			
		EXEC(@sql_stmt)

		IF @assigned_state IS NOT NULL
		BEGIN
			UPDATE sd SET sale_detail_id = sdd.source_deal_detail_id
			FROM #sale_deals sd
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sd.sale_deal_id
		END

		INSERT INTO #unique_id(unique_ID) SELECT farrms_id FROM farrms_dealId WHERE farrms_id > @maxid

		UPDATE org
		SET org.assignment_type_value_id = @assignment_type
		FROM source_deal_header org
		INNER JOIN #sale_deals sd ON sd.sale_deal_id = org.source_deal_header_id

		IF @@ERROR <> 0
		BEGIN
			SET @sql_stmt = 'Failed to create sale positions for Credits/Allowance: ' + @source_deal_detail_ids
			EXEC spa_ErrorHandler @@ERROR, 'Assign Credits/Allowance Deals', 
					'spa_assign_transaction', 'DB Error', @sql_stmt, ''
			RETURN
		END
		ELSE
		BEGIN
			IF OBJECT_ID('tempdb..#tmp_volume_left_info') IS NOT NULL
			DROP TABLE #tmp_volume_left_info

			--IF OBJECT_ID('tempdb..#tmp_volume_left_info_sale') IS NOT NULL
			--DROP TABLE #tmp_volume_left_info_sale

			SELECT detail_id, ROUND(sdd.volume_left, 0) volume_left, td.volume AS assigned_vol
			INTO #tmp_volume_left_info
			FROM source_deal_detail sdd
			INNER JOIN (SELECT ROUND(SUM(volume), 0) volume, detail_id  
						FROM #sale_deals 
						GROUP BY detail_id) td ON td.detail_id = sdd.source_deal_detail_id

			--SELECT sale_detail_id, ROUND(sdd.volume_left, 0) volume_left, td.volume AS assigned_vol
			--INTO #tmp_volume_left_info_sale
			--FROM source_deal_detail sdd
			--INNER JOIN (SELECT ROUND(SUM(volume), 0) volume, sale_detail_id  
			--			FROM #sale_deals 
			--			GROUP BY sale_detail_id) td ON td.sale_detail_id = sdd.source_deal_detail_id

			--IMP: source_deal_header_id AND source_deal_header_id_from in table assignment_audit actually stores deal detail ids.
			SET @sql_stmt = '
			INSERT INTO assignment_audit
			(
				assignment_type, 
				assigned_volume, 
				source_deal_header_id, 
				source_deal_header_id_from, 
				compliance_year, 
				state_value_id,
				assigned_date, 
				assigned_by, 
				cert_from, 
				cert_to, 
				tier, 
				committed, 
				compliance_group_id, 
				org_assigned_volume
			)
			--distinct is required as joining with sdh.ext_deal_id produces duplicates when same deal is contributing to multiple tiers,
			--resulting in creation of multiple assignment deals having same ext_deal_id
			SELECT DISTINCT
				' + CAST(@assignment_type AS VARCHAR(25)) + ' assignment_type, 
				tmp.[volume] assigned_volume, 
				tmp.sale_detail_id source_deal_header_id,
				tmp.detail_id source_deal_header_id_from, 
				ISNULL(tmp.compliance_year, ' + CAST(@compliance_year AS VARCHAR(10)) + '), 
				state_value_id,
				''' + dbo.FNAGetSQLStandardDate(@assigned_date) + ''', 
				dbo.FNADBUser(), 
				tmp.cert_from, 
				tmp.cert_to, 
				tmp.tier, 
				' + CAST(ISNULL(@committed, 0) AS VARCHAR(1)) + ',
				' + CAST(ISNULL(@compliance_group_id,0) AS VARCHAR(100)) + ', 
				tmp.[volume] org_assigned_volume
			FROM #sale_deals tmp'
		
			--PRINT(@sql_stmt)
			EXEC(@sql_stmt)


			UPDATE sdd SET status = @transferred
			FROM #sale_deals sd
			INNER JOIN source_deal_detail sdd ON sd.detail_id = sdd.source_deal_detail_id

			IF OBJECT_ID(N'tempdb..#cert_info', N'U') IS NOT NULL
			DROP TABLE	#cert_info

			SELECT aa.source_deal_header_id_from AS detail_id, MAX(COALESCE(gc.certificate_number_to_int, gcc.certificate_number_from_int, 1)) from_int
			INTO #cert_info
			FROM #sale_deals sd
			INNER JOIN assignment_audit aa ON aa.source_deal_header_id_from = sd.detail_id
			INNER JOIN gis_certificate gcc ON gcc.source_deal_header_id = aa.source_deal_header_id_from
			LEFT JOIN gis_certificate gc ON gc.source_deal_header_id_from = aa.source_deal_header_id_from
					AND gc.source_deal_header_id = aa.source_deal_header_id
			GROUP BY aa.source_deal_header_id_from

			UPDATE sd 
			SET sd.cert_from = (ci.from_int+ISNULL(t.vol, 0)) + CASE WHEN ci.from_int = 1 THEN 0 ELSE 1 END,
				sd.cert_to = (ci.from_int+tt.vol) - CASE WHEN ci.from_int = 1 THEN 1 ELSE 0 END
			FROM #cert_info ci
			INNER JOIN #sale_deals sd ON ci.detail_id = sd.detail_id
			OUTER APPLY(SELECT CAST(SUM(sd1.volume) AS INT) vol FROM #sale_deals sd1 WHERE sd1.id < sd.id AND sd.detail_id = sd1.detail_id) t
			OUTER APPLY(SELECT CAST(SUM(sd2.volume) AS INT) vol FROM #sale_deals sd2 WHERE sd2.id <= sd.id AND sd.detail_id = sd2.detail_id) tt

			IF ISNULL(@commit_type, 1) <> 'a'
			BEGIN
				UPDATE sdd SET sdd.volume_left = (tvli.volume_left - tvli.assigned_vol)
				FROM source_deal_detail sdd
				INNER JOIN #tmp_volume_left_info tvli ON tvli.detail_id = sdd.source_deal_detail_id

				--UPDATE sdd SET sdd.volume_left = (tvlis.volume_left - tvlis.assigned_vol)
				--FROM source_deal_detail sdd
				--INNER JOIN #tmp_volume_left_info_sale tvlis ON tvlis.sale_detail_id = sdd.source_deal_detail_id
			END

			INSERT INTO gis_certificate(source_deal_header_id, 
				gis_certificate_number_from, 
				gis_certificate_number_to, 
				certificate_number_from_int, 
				certificate_number_to_int, 
				gis_cert_date,
				state_value_id,
				tier_type,
				contract_expiration_date,
				[year],
				certification_entity,
				source_deal_header_id_from
				)
			SELECT DISTINCT sdd_sale.source_deal_detail_id,
				CASE WHEN ISNUMERIC(substring(gc_assign.gis_certificate_number_from,len(gc_assign.gis_certificate_number_from)-charindex('-',reverse(gc_assign.gis_certificate_number_from))+2,LEN(gc_assign.gis_certificate_number_from))) = 1 THEN
					SUBSTRING(gc_assign.gis_certificate_number_from,0,LEN(gc_assign.gis_certificate_number_from) - CHARINDEX('-',REVERSE(gc_assign.gis_certificate_number_from)) + 2) 
			+ CAST((gc_assign.certificate_number_from_int + (sdd_sale.deal_volume - sdd_sale.volume_left)) AS VARCHAR)
				ELSE gc_assign.gis_certificate_number_from END,

				CASE WHEN ISNUMERIC(substring(gc_assign.gis_certificate_number_to,len(gc_assign.gis_certificate_number_to)-charindex('-',reverse(gc_assign.gis_certificate_number_to))+2,LEN(gc_assign.gis_certificate_number_to))) = 1 THEN 
					SUBSTRING(gc_assign.gis_certificate_number_from,0,LEN(gc_assign.gis_certificate_number_from) - CHARINDEX('-',REVERSE(gc_assign.gis_certificate_number_from)) + 2) 
			+ CAST((gc_assign.certificate_number_from_int + (sdd_sale.deal_volume - sdd_sale.volume_left) + dc.volume)-1 AS VARCHAR)
				ELSE gc_assign.gis_certificate_number_to END,
				dc.cert_from, 
				dc.cert_to,
				GETDATE(),
				CASE WHEN @assigned_state IS NULL THEN mhdi.state_value_id ELSE sdh_sale.state_value_id END,
				CASE WHEN @assigned_state IS NULL THEN mhdi.tier_value_id ELSE dc.tier END,
				gc_assign.contract_expiration_date,
				gc_assign.[year],
				gc_assign.certification_entity,
				dc.detail_id	
			FROM #sale_deals dc 
			INNER JOIN source_deal_detail sdd_assign ON sdd_assign.source_deal_detail_id = dc.detail_id
			LEFT JOIN matching_header_detail_info mhdi ON mhdi.source_deal_detail_id_from = dc.detail_id --For Buy/Sell
			INNER JOIN gis_certificate gc_assign ON gc_assign.source_deal_header_id = sdd_assign.source_deal_detail_id
				AND (@assigned_state IS NOT NULL OR gc_assign.state_value_id = mhdi.state_value_id)
				AND (@assigned_state IS NOT NULL OR gc_assign.tier_type = mhdi.tier_value_id) --For Buy/Sell
			INNER JOIN source_deal_header sdh_assign ON sdh_assign.source_deal_header_id = sdd_assign.source_deal_header_id
			INNER JOIN assignment_audit sdh_sale on sdh_sale.source_deal_header_id = dc.sale_detail_id
				AND sdh_sale.source_deal_header_id_from = dc.detail_id
			INNER JOIN source_deal_detail sdd_sale on sdd_sale.source_deal_detail_id = sdh_sale.source_deal_header_id
		END
	END		
	ELSE IF @assignment_type IN (5146,10013) AND @unassign = 0   --RPS Complience : creating assigned deals
	BEGIN
		SELECT @maxid = MAX(farrms_id) FROM farrms_dealId
	
		IF @table_name IS NULL      
			INSERT farrms_dealId SELECT GETDATE() FROM transactions
		ELSE
			EXEC('INSERT farrms_dealId SELECT getDate() FROM '+ @table_name)
		
		INSERT INTO #unique_id(unique_ID) SELECT farrms_id FROM farrms_dealId WHERE farrms_id > @maxid
		CREATE TABLE #inserted_source_deal_header_id(source_deal_header_id INT, unique_deal_tier_id INT)

		BEGIN
			SET @sql_stmt = '
			INSERT INTO source_deal_header
			(
				source_system_id, 
				deal_id, deal_date, 
				ext_deal_id, 
				physical_financial_flag, 
				structured_deal_id, 
				counterparty_id, 
				entire_term_start, 
				entire_term_end, 
				source_deal_type_id, 
				deal_sub_type_type_id, 
				option_flag, 
				option_type, 
				option_excercise_type, 
				source_system_book_id1, 
				source_system_book_id2, 
				source_system_book_id3, 
				source_system_book_id4, 
				description1, 
				description2, 
				description3, 
				deal_category_value_id, 
				trader_id, 
				internal_deal_type_value_id, 
				internal_deal_subtype_value_id, 
				template_id, 
				header_buy_sell_flag, 
				broker_id, 
				generator_id, 
				status_date, 
				assignment_type_value_id, 
				compliance_year, 
				state_value_id, 
				assigned_date, 
				assigned_by,
				deal_status, 
				confirm_status_type
			) 
			OUTPUT inserted.source_deal_header_id, INSERTED.ext_deal_id INTO #inserted_source_deal_header_id (source_deal_header_id, unique_deal_tier_id)
			SELECT source_system_id  
				, ''Assigned-'' + CAST(unq.unique_id AS VARCHAR(50)) AS deal_id	   
				, ' + CASE WHEN @call_from_old = 3 THEN ' assign.assigned_date' ELSE '''' + dbo.FNAGetSQLStandardDate(@assigned_date) + '''' END + ' deal_date
				--CAST(sdh.source_deal_header_id AS VARCHAR) ext_deal_id
				, assign.ID	--save unique id of #deal_count1 instead of saving real ext_deal_id. This will help us to map between newly created deal AND original deal AND its tier.
				, sdh.physical_financial_flag
				, NULL AS structured_deal_id
				, ' + CASE WHEN @call_from_old = 3 THEN ' assign.counterparty ' WHEN @assigned_counterparty IS NULL THEN 
								' sdh.counterparty_id ' 
							ELSE CAST(@assigned_counterparty AS VARCHAR(250)) 
						END + '
				, ' + CASE WHEN @assignment_type = 10013 THEN 'CONVERT(datetime,''' + CAST(@compliance_year AS VARCHAR) + '-01-01'')' ELSE ' sdh.entire_term_start ' END + ' AS entire_term_start
				, ' + CASE WHEN @assignment_type = 10013 THEN 'CONVERT(datetime,''' + CAST(@compliance_year AS VARCHAR) + '-01-31'')' ELSE ' sdh.entire_term_end ' END + ' AS entire_term_end 
				, CASE WHEN (source_deal_type_id = 53) THEN 55 ELSE source_deal_type_id END source_deal_type_id
				, deal_sub_type_type_id, option_flag, option_type, option_excercise_type
				, ISNULL(ssbm.source_system_book_id1, sdh.source_system_book_id1)
				, ISNULL(ssbm.source_system_book_id2, sdh.source_system_book_id2) 
				, ISNULL(ssbm.source_system_book_id3, sdh.source_system_book_id3)
				, ISNULL(ssbm.source_system_book_id4, sdh.source_system_book_id4) 
				, '+ CASE WHEN @call_from_old = 3 THEN 
						' assign.desc1 ' 
					ELSE '(''' + @deal_id + ''' + '' FROM deal '' + CAST(sdh.source_deal_header_id AS VARCHAR(25)))' END + ' description1
				, '+ CASE WHEN @call_from_old = 3 THEN 
						' assign.desc2 ' 
					ELSE ' sdh.description2 ' END + ', 
				' + CASE WHEN @call_from_old = 3 THEN 
						' assign.desc3 ' 
					ELSE ' sdh.description3 ' END + '
				, sdh.deal_category_value_id 
				, ' + CASE WHEN @trader_id IS NULL THEN 
						' trader_id ' 
					ELSE CAST(@trader_id  AS VARCHAR(25)) END + '
				, internal_deal_type_value_id
				, internal_deal_subtype_value_id
				, template_id
				, ''s'' header_buy_sell_flag
				, broker_id
				, generator_id
				, status_date
				, ' + CAST(@assignment_type AS VARCHAR(25)) + ' assignment_type_value_id
				, CASE WHEN ' + CAST(@assignment_type AS VARCHAR(25)) + ' <> 5149 AND ' + CAST(@assignment_type AS VARCHAR(25)) + ' <> 5173 
					THEN ISNULL(assign.compliance_year, ' + CAST(ISNULL(@compliance_year, '') AS VARCHAR(10)) + ') ELSE NULL END
				, CASE WHEN ' + CAST(@assignment_type AS VARCHAR(25)) + ' <> 5173 THEN ' + CAST(ISNULL(@assigned_state, '') AS VARCHAR(25)) 
					+ ' ELSE NULL END
				, ' + CASE WHEN @call_from_old = 3 THEN ' assign.assigned_date' ELSE '''' + dbo.FNAGetSQLStandardDate(@assigned_date) + '''' END + '
				, ''' + @user_name + '''
				, 5604
				, 17200	
			FROM source_deal_header sdh 
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id 
			INNER JOIN #deals_count1 assign	ON sdd.[source_deal_detail_id] = assign.[source_deal_detail_id]
			INNER JOIN static_data_value at ON at.value_id = ' + CAST(@assignment_type AS VARCHAR(25)) + '  
			INNER JOIN #unique_id unq ON unq.[ID] = assign.[ID]
			LEFT JOIN source_system_book_map ssbm ON ssbm.book_deal_type_map_id = ' +
				CASE WHEN @call_from_old IN (2,3) THEN ' assign.book_deal_type_map_id' ELSE CASE WHEN ISNULL(@book_deal_type_map_id,'-1') = '-1' THEN 'NULL' ELSE 
				CAST(@book_deal_type_map_id AS VARCHAR(25)) END END + '		
			WHERE 1 = 1 '

		END	--@template_id NULL
	
		EXEC(@sql_stmt)

			UPDATE sdh SET sdh.tier_value_id = dc.tier 
			FROM source_deal_header sdh
			INNER JOIN #inserted_source_deal_header_id isdhi ON sdh.source_deal_header_id = isdhi.source_deal_header_id
			INNER JOIN #deals_count1 dc1 ON dc1.id = isdhi.unique_deal_tier_id
			INNER JOIN #deals_count dc ON dc.source_deal_detail_id = dc1.source_deal_detail_id
	
			SET @inserted_source_deal_header_id = ''
			SELECT @inserted_source_deal_header_id = @inserted_source_deal_header_id 
				+ CASE WHEN @inserted_source_deal_header_id = '' THEN '' ELSE ', ' END + CAST(source_deal_header_id AS VARCHAR(25)) 
			FROM #inserted_source_deal_header_id 

			SET @sql_stmt =
				'INSERT INTO source_deal_detail(source_deal_header_id, 
					term_start, 
					term_end, 
					leg, 
					contract_expiration_date, 
					fixed_float_leg, 
					buy_sell_flag, 
					curve_id, 
					fixed_price, 
					fixed_price_currency_id, 
					option_strike_price, 
					deal_volume, 
					deal_volume_frequency, 
					deal_volume_uom_id, 
					block_description, 
					deal_detail_description, 
					formula_id, 
					physical_financial_flag,
					settlement_uom,
					settlement_volume
				)
			SELECT sdh1.source_deal_header_id
				, ' + CASE WHEN @assignment_type = 10013 THEN 'CONVERT(datetime,''' + CAST(@compliance_year AS VARCHAR) + '-01-01'')' ELSE ' sdd.term_start ' END + ' AS entire_term_start
				, ' + CASE WHEN @assignment_type = 10013 THEN 'CONVERT(datetime,''' + CAST(@compliance_year AS VARCHAR) + '-01-31'')' ELSE ' sdd.term_end ' END + ' AS entire_term_end 
				, sdd.Leg
				, ' + CASE WHEN @assignment_type = 10013 THEN 'CONVERT(datetime,''' + CAST(@compliance_year AS VARCHAR) + '-01-31'')' ELSE ' sdd.contract_expiration_date ' END + ' AS entire_term_start
				, sdd.fixed_float_leg
				, ''s'', sdd.curve_id
				, ' + CASE WHEN @assigned_price IS NULL THEN 'sdd.fixed_price' ELSE CAST(@assigned_price AS VARCHAR(40)) END + '
				, sdd.fixed_price_currency_id
				, sdd.option_strike_price
				, assign.[volume]  
				, sdd.deal_volume_frequency
				, sdd.deal_volume_uom_id
				, sdd.block_description
				, sdd.deal_detail_description
				, sdd.formula_id
				, sdd.physical_financial_flag
				, ' + CASE WHEN @assignment_type = 10013 THEN 'NULL' ELSE ' settlement_uom ' END + ' AS settlement_uom 
				, ' + CASE WHEN @assignment_type = 10013 THEN ' assign.[volume] ' ELSE ' assign.[volume]*CAST(ISNULL(conv.conversion_factor,1) AS NUMERIC(18,10)) ' END + ' AS settlement_volume 
			FROM source_deal_header sdh 
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id 
			INNER JOIN #deals_count1 assign ON sdd.[source_deal_detail_id] = assign.source_deal_detail_id
			--INNER JOIN source_deal_header sdh1 ON CAST(sdh1.ext_deal_id AS VARCHAR) = CAST(sdh.source_deal_header_id AS VARCHAR(25))
			INNER JOIN #inserted_source_deal_header_id isdh ON isdh.unique_deal_tier_id = assign.ID
			INNER JOIN source_deal_header sdh1 ON sdh1.source_deal_header_id = isdh.source_deal_header_id
			INNER JOIN #unique_id unq ON ''Assigned-'' + CAST(unq.[unique_id] AS VARCHAR(25)) = sdh1.deal_id
				OR ''Sold/Xferred-'' + CAST(unq.[unique_id] AS VARCHAR(25)) = sdh1.deal_id
			INNER JOIN static_data_value at ON at.value_id = ' + CAST(@assignment_type AS VARCHAR(25)) + '
			LEFT JOIN source_system_book_map ssbm ON ssbm.book_deal_type_map_id = ' 
				+ CASE WHEN @call_from_old IN (2,3) THEN ' assign.book_deal_type_map_id' ELSE CASE WHEN ISNULL(@book_deal_type_map_id,'-1') = '-1' THEN 'NULL' ELSE 
				CAST(@book_deal_type_map_id AS VARCHAR(25)) END END + '	
			LEFT JOIN rec_volume_unit_conversion conv on sdd.deal_volume_uom_id = conv.from_source_uom_id 
				AND conv.to_source_uom_id = sdd.settlement_uom
				AND conv.state_value_id is null and conv.assignment_type_value_id is null and conv.curve_id is null   		
			WHERE 1 = 1 '


			EXEC(@sql_stmt)

			--finally UPDATE newly created offset deal's ext_deal_id with its original value
			UPDATE sdh
				SET sdh.ext_deal_id = CAST(sdd.source_deal_header_id AS VARCHAR(50)),
					sdh.close_reference_id = CAST(sdd.source_deal_header_id AS VARCHAR(50))
			FROM #inserted_source_deal_header_id tsdh
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = tsdh.source_deal_header_id
			INNER JOIN #deals_count1 dc ON dc.ID = tsdh.unique_deal_tier_id
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = dc.source_deal_detail_id

			UPDATE sdd SET status = @compliance
			FROM #deals_count1 sd
			INNER JOIN source_deal_detail sdd ON sd.source_deal_detail_id = sdd.source_deal_detail_id
	
	
			IF @@ERROR <> 0
			BEGIN
				SET @sql_stmt = 'Failed to create sale positions for Credits/Allowance: ' + @source_deal_detail_ids
				EXEC spa_ErrorHandler @@ERROR, 'Assign Credits/Allowance Deals', 
						'spa_assign_transaction', 'DB Error', @sql_stmt, ''
				RETURN
			END
			ELSE
			BEGIN
			IF @call_from_old IN (0,1,2,3)
			BEGIN
				--IMP: source_deal_header_id AND source_deal_header_id_from in table assignment_audit actually stores deal detail ids.
				SET @sql_stmt = '
					INSERT INTO assignment_audit
					(
						assignment_type, 
						assigned_volume, 
						source_deal_header_id, 
						source_deal_header_id_from, 
						compliance_year, 
						state_value_id,
						assigned_date, 
						assigned_by, 
						cert_from, 
						cert_to, 
						committed, 
						compliance_group_id, 
						org_assigned_volume,
						Tier
					)
					--distinct is required as joining with sdh.ext_deal_id produces duplicates when same deal is contributing to multiple tiers,
					--resulting in creation of multiple assignment deals having same ext_deal_id
					SELECT DISTINCT
						' + CAST(@assignment_type AS VARCHAR(25)) + ' assignment_type, 
						tmp.[volume] assigned_volume, 
						sdd_assign.source_deal_detail_id source_deal_header_id,
						dc.source_deal_detail_id source_deal_header_id_from, 
						' + CAST(@compliance_year AS VARCHAR(10)) + ', 
						' + CAST(@assigned_state AS VARCHAR(25)) + ',
						' + CASE WHEN @call_from_old = 3 THEN 
								' tmp.assigned_date' 
							ELSE '''' + dbo.FNAGetSQLStandardDate(@assigned_date) + '''' END + ', 
						dbo.FNADBUser(), 
						tmp.cert_from, 
						tmp.cert_to,  
						' + CAST(ISNULL(@committed, 0) AS VARCHAR(1)) + ',
						' + CAST(ISNULL(@compliance_group_id,0) AS VARCHAR(100)) + ', 
						tmp.[volume] org_assigned_volume,
						tmp.tier
					FROM #deals_count tmp
					INNER JOIN #deals_count1 dc ON dc.source_deal_detail_id = tmp.source_deal_detail_id 
					INNER JOIN #inserted_source_deal_header_id tsdh ON dc.ID = tsdh.unique_deal_tier_id
					INNER JOIN source_deal_detail sdd_assign ON sdd_assign.source_deal_header_id = tsdh.source_deal_header_id'
		END
		ELSE
		BEGIN
			--IMP: source_deal_header_id AND source_deal_header_id_from in table assignment_audit actually stores deal detail ids.
			SET @sql_stmt = '
			INSERT INTO assignment_audit
			(
				assignment_type, 
				assigned_volume, 
				source_deal_header_id, 
				source_deal_header_id_from, 
				compliance_year, 
				state_value_id,
				assigned_date, 
				assigned_by, 
				cert_from, 
				cert_to, 
				tier, 
				committed, 
				compliance_group_id, 
				org_assigned_volume,
				Tier
			)
			--distinct is required as joining with sdh.ext_deal_id produces duplicates when same deal is contributing to multiple tiers,
			--resulting in creation of multiple assignment deals having same ext_deal_id
			SELECT DISTINCT
				' + CAST(@assignment_type AS VARCHAR(25)) + ' assignment_type, 
				tmp.[volume] assigned_volume, 
				sdd_assign.source_deal_detail_id source_deal_header_id,
				sdd_recs.source_deal_detail_id source_deal_header_id_from, 
				ISNULL(tmp.compliance_year, ' + CAST(@compliance_year AS VARCHAR(10)) + '), 
				' + CAST(@assigned_state AS VARCHAR(25)) + ',
				' + CASE WHEN @call_from_old = 3 THEN 
						' tmp.assigned_date' 
					ELSE '''' + dbo.FNAGetSQLStandardDate(@assigned_date) + ''''  END + ', 
				dbo.FNADBUser(), 
				tmp.cert_from, 
				tmp.cert_to, 
				tmp.tier, 
				' + CAST(ISNULL(@committed, 0) AS VARCHAR(1)) + ',
				' + CAST(ISNULL(@compliance_group_id,0) AS VARCHAR(100)) + ', 
				tmp.[volume] org_assigned_volume,
				tmp.tier
			FROM #deals_count tmp 
			INNER JOIN source_deal_detail sdd_recs ON tmp.source_deal_detail_id = sdd_recs.source_deal_detail_id
			INNER JOIN source_deal_header sdh_assign ON CAST(sdd_recs.[source_deal_header_id] AS VARCHAR(25)) = sdh_assign.ext_deal_id
			INNER JOIN source_deal_detail sdd_assign ON sdd_assign.source_deal_header_id = sdh_assign.source_deal_header_id
			INNER JOIN #unique_id unq ON ''Assigned-'' + CAST(unq.[unique_id] AS VARCHAR) = sdh_assign.deal_id
			WHERE 1 = 1
				AND NOT EXISTS (SELECT 1 FROM assignment_audit WHERE source_deal_header_id = sdd_recs.source_deal_detail_id)'

			END
	
			--PRINT(@sql_stmt)
			EXEC(@sql_stmt)
	
			IF @commit_type <> 'a'
			BEGIN
				SET @sql_stmt = '
				UPDATE sdd_allocated
					SET sdd_allocated.volume_left = sdd_allocated.volume_left - (sdd_allocated.deal_volume/sdd.deal_volume)*ISNULL(rs_tmp.volume,0)
				FROM
					source_deal_detail sdd 
					INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
					INNER JOIN source_deal_header sdh_offset ON sdh.source_deal_header_id = sdh_offset.close_reference_id
					INNER JOIN source_deal_header sdh_allocated ON sdh_offset.source_deal_header_id = sdh_allocated.close_reference_id
					INNER JOIN source_deal_detail sdd_allocated ON sdh_allocated.source_deal_header_id = sdd_allocated.source_deal_header_id
					INNER JOIN (
						SELECT SUM(volume) volume, source_deal_detail_id  
						FROM #deals_count tmp 
						group by source_deal_detail_id
					) rs_tmp ON rs_tmp.[source_deal_detail_id] = sdd.source_deal_detail_id
					WHERE 1 = 1'

				IF @assign_id IS NOT NULL AND @assign_id <> ''
					SET @sql_where2 = ' AND tmp.assign_id in(' + @assign_id + ')'
			
				SET @sql_stmt = @sql_stmt + @sql_where2
		
				EXEC (@sql_stmt)
			END
		
			IF @call_from_old = 3
			BEGIN
				SET @desc = ''
			END
			ELSE
			BEGIN
				SET @desc = (SELECT code FROM static_data_value WHERE value_id = @assignment_type) +
				CASE WHEN(@assignment_type = 5173) THEN ' Category.' ELSE		
				' Category for ' +  ISNULL((SELECT code FROM static_data_value WHERE value_id = @assigned_state), 'NoState') +
					' State for Year ' + CAST(@compliance_year AS VARCHAR(10)) 
				END 
				+
				CASE WHEN(@assignment_type =  5173) THEN ' And sales position for ' 
					+ (SELECT counterparty_name 
						FROM source_counterparty 
						WHERE source_counterparty_id = @assigned_counterparty) + ' automatically created' ELSE '' 
				END
			END

			UPDATE dc SET dc.source_deal_header_id = sdd.source_deal_header_id
			FROM #deals_count dc
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = dc.source_deal_detail_id

			IF OBJECT_ID(N'tempdb..#cert_info_r', N'U') IS NOT NULL
			DROP TABLE	#cert_info_r

			SELECT aa.source_deal_header_id_from AS detail_id, MAX(COALESCE(gc.certificate_number_to_int, gcc.certificate_number_from_int, 1)) from_int
			INTO #cert_info_r
			FROM #deals_count dc
			INNER JOIN assignment_audit aa ON aa.source_deal_header_id_from = dc.source_deal_detail_id
			LEFT JOIN gis_certificate gc ON gc.source_deal_header_id = aa.source_deal_header_id
			INNER JOIN gis_certificate gcc ON gcc.source_deal_header_id = aa.source_deal_header_id_from
			GROUP BY aa.source_deal_header_id_from

			UPDATE dc
			SET dc.cert_from = (ci.from_int+ISNULL(t.vol, 0)) + CASE WHEN ci.from_int = 1 THEN 0 ELSE 1 END, 
				dc.cert_to = (ci.from_int+tt.vol) - CASE WHEN ci.from_int = 1 THEN 1 ELSE 0 END
			FROM #cert_info_r ci
			INNER JOIN #deals_count dc ON ci.detail_id = dc.source_deal_detail_id
			OUTER APPLY(SELECT CAST(SUM(dc1.volume) AS INT) vol FROM #deals_count dc1 WHERE dc1.id < dc.id AND dc.source_deal_header_id = dc1.source_deal_header_id) t
			OUTER APPLY(SELECT CAST(SUM(dc2.volume) AS INT) vol FROM #deals_count dc2 WHERE dc2.id <= dc.id AND dc.source_deal_header_id = dc2.source_deal_header_id) tt
	
			IF @template_id IS NULL
			BEGIN
				INSERT INTO gis_certificate(
					source_deal_header_id, 
					gis_certificate_number_from, 
					gis_certificate_number_to, 
					certificate_number_from_int, 
					certificate_number_to_int, 
					gis_cert_date,
					state_value_id,
					tier_type,
					source_deal_header_id_from)
				SELECT sdd_recs.source_deal_detail_id, 
					CASE WHEN ISNUMERIC(substring(gc_assign.gis_certificate_number_from,len(gc_assign.gis_certificate_number_from)-charindex('-',reverse(gc_assign.gis_certificate_number_from))+2,LEN(gc_assign.gis_certificate_number_from))) = 1
					THEN
						SUBSTRING(gc_assign.gis_certificate_number_from,0,LEN(gc_assign.gis_certificate_number_from) - CHARINDEX('-',REVERSE(gc_assign.gis_certificate_number_from)) + 2) 
						+ CAST((gc_assign.certificate_number_from_int + (sdd_recs.deal_volume - sdd_recs.volume_left)) AS VARCHAR)
					ELSE gc_assign.gis_certificate_number_from END
					, CASE WHEN ISNUMERIC(substring(gc_assign.gis_certificate_number_to,len(gc_assign.gis_certificate_number_to)-charindex('-',reverse(gc_assign.gis_certificate_number_to))+2,LEN(gc_assign.gis_certificate_number_to))) = 1
					THEN 
						SUBSTRING(gc_assign.gis_certificate_number_from,0,LEN(gc_assign.gis_certificate_number_from) - CHARINDEX('-',REVERSE(gc_assign.gis_certificate_number_from)) + 2) 
						+ CAST((gc_assign.certificate_number_from_int + (sdd_recs.deal_volume - sdd_recs.volume_left) + dc.volume) AS VARCHAR)
					ELSE gc_assign.gis_certificate_number_to END ,
					dc.cert_from,
					dc.cert_to,
					--(gc_assign.certificate_number_from_int + (sdd_assign.deal_volume - (sdd_assign.volume_left+dc.volume))) , 
					--(gc_assign.certificate_number_from_int + (sdd_assign.deal_volume - sdd_assign.volume_left)-1), 
					GETDATE(),
					dc.state_value_id,
					dc.tier,
					aa.source_deal_header_id_from
				FROM #deals_count dc 
				INNER JOIN source_deal_detail sdd_assign ON sdd_assign.source_deal_detail_id = dc.source_deal_detail_id
				INNER JOIN gis_certificate gc_assign ON gc_assign.source_deal_header_id = sdd_assign.source_deal_detail_id
					AND gc_assign.state_value_id = dc.state_value_id
				INNER JOIN assignment_audit aa ON aa.source_deal_header_id_from = sdd_assign.source_deal_detail_id
					AND aa.Tier = dc.tier
				INNER JOIN source_deal_detail sdd_recs ON sdd_recs.source_deal_detail_id = aa.source_deal_header_id
				LEFT JOIN gis_certificate gcc ON gcc.source_deal_header_id = sdd_recs.source_deal_detail_id
					AND dc.state_value_id = gcc.state_value_id
				WHERE (gcc.source_deal_header_id IS NULL OR gcc.state_value_id IS NULL)
			END

			INSERT INTO rec_assign_log(process_id, code, [Module], [source], [type], [description], source_deal_header_id, source_deal_header_id_sale_from)  
			SELECT DISTINCT @process_id, 
				'Success', 
				'Credits/Allowance Assign', 
				'spa_assign_transaction', 
				'Status',
				'Deal ' + CAST(sdd.source_deal_header_id AS VARCHAR(25)) + ' assigned to ' + @desc, 
				sdh.source_deal_header_id, 
				sdd.source_deal_header_id
			FROM  #deals_count tmp
			INNER JOIN source_deal_detail sdd ON tmp.source_deal_detail_id = sdd.source_deal_detail_id
			INNER JOIN source_deal_header sdh ON sdh.ext_deal_id = CAST(sdd.source_deal_header_id AS VARCHAR(25))
			INNER JOIN source_deal_detail sdd1 ON sdd1.source_deal_header_id = sdh.source_deal_header_id	
		END
	END	--assignment type = 5146

	IF @unassign = 1  
	BEGIN

		IF OBJECT_ID('tempdb..#source_deals') IS NOT NULL
			DROP TABLE #source_deals
			
		SELECT aa.source_deal_header_id_from
		INTO #source_deals 
		FROM assignment_audit aa 
		INNER JOIN #deals_count dc ON dc.assign_id = aa.assignment_id

		IF OBJECT_ID('tempdb..#agg_detail_volume') IS NOT NULL
			DROP TABLE #agg_detail_volume

		SELECT sdd.source_deal_detail_id, sdd.volume_left, volume
		INTO #agg_detail_volume
		FROM source_deal_detail sdd
		INNER JOIN (
					SELECT 
						au.source_deal_header_id_from,
						SUM(au.assigned_volume) AS volume 
					FROM #deals_count dc 
					INNER JOIN assignment_audit au ON au.assignment_ID = dc.assign_id
					GROUP BY au.source_deal_header_id_from) t ON sdd.source_deal_detail_id = t.source_deal_header_id_from

		IF @assignment_type = 5173
		BEGIN 
			UPDATE sdh
			SET sdh.assignment_type_value_id = NULL
			FROM #deals_count dc 
			INNER JOIN assignment_audit aa ON aa.assignment_id = dc.assign_id
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = aa.source_deal_header_id
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id

			UPDATE sdd SET
				[status] = ISNULL(t.[status], sdd.[status])
			FROM source_deal_detail sdd
			INNER JOIN #deals_count dc ON dc.source_deal_detail_id = sdd.source_deal_detail_id
			OUTER APPLY (SELECT TOP 1 sdda.status 
						FROM source_deal_detail_audit sdda 
						WHERE sdda.source_deal_detail_id = dc.source_deal_detail_id ORDER BY sdda.audit_id DESC) t

			DELETE gc 
			FROM #deals_count dc 
			INNER JOIN assignment_audit aa ON aa.assignment_id = dc.assign_id
			INNER JOIN  gis_certificate gc ON gc.source_deal_header_id = aa.source_deal_header_id
				AND gc.source_deal_header_id_from = aa.source_deal_header_id_from
				AND gc.state_value_id = aa.state_value_id
				AND gc.tier_type = aa.tier

			DELETE aa FROM assignment_audit aa 
			INNER JOIN #deals_count dc ON dc.assign_id = aa.assignment_id



		END
		ELSE
		BEGIN
			DELETE aa FROM assignment_audit aa 
			INNER JOIN #deals_count dc ON dc.assign_id = aa.assignment_id

			IF OBJECT_ID('tempdb..#source_deal_header_id') IS NOT NULL
				DROP TABLE #source_deal_header_id
	
			SELECT sdd.source_deal_header_id 
			INTO #source_deal_header_id 
			FROM source_deal_detail sdd
			INNER JOIN #deals_count dc ON dc.source_deal_detail_id = sdd.source_deal_detail_id
	
			DELETE gc FROM gis_certificate gc 
			INNER JOIN source_deal_detail sdd ON gc.source_deal_header_id = sdd.source_deal_detail_id
			INNER JOIN #source_deal_header_id sdhi ON sdhi.source_deal_header_id = sdd.source_deal_header_id

			DELETE sdd FROM source_deal_detail sdd 
			INNER JOIN #source_deal_header_id isdh ON isdh.source_deal_header_id = sdd.source_deal_header_id

			DELETE uddf FROM user_defined_deal_fields uddf 
			INNER JOIN #source_deal_header_id sdhi ON sdhi.source_deal_header_id = uddf.source_deal_header_id

			DELETE csr FROM confirm_status_recent csr
			INNER JOIN #source_deal_header_id sdhi ON sdhi.source_deal_header_id = csr.source_deal_header_id

			DELETE cs FROM confirm_status cs
			INNER JOIN #source_deal_header_id sdhi ON sdhi.source_deal_header_id = cs.source_deal_header_id

			DELETE sdh FROM source_deal_header sdh 
			INNER JOIN #source_deal_header_id isdh ON isdh.source_deal_header_id = sdh.source_deal_header_id

		END

		UPDATE sdd SET sdd.volume_left = adv.volume_left + ISNULL(adv.volume, 0)
		FROM source_deal_detail sdd
		INNER JOIN #agg_detail_volume adv ON adv.source_deal_detail_id = sdd.source_deal_detail_id

		UPDATE sdd SET status = @generated
		FROM #source_deals sd
		INNER JOIN source_deal_detail sdd ON sd.source_deal_header_id_from = sdd.source_deal_detail_id

		SET @desc = 'Banked (Inventory)'+ ' Category.'

		/****************Source Deal Header ID selected instead of Source Deal Detail ID*******/
		INSERT INTO rec_assign_log(process_id, code, [module], [source], [type], [description], source_deal_header_id, 
		source_deal_header_id_sale_from)  
		SELECT DISTINCT	@process_id, 'Success', 'Credits/Allowance Assign', 'spa_assign_transaction', 'Status' 
			, 'Deal ' + CAST(sdh.source_deal_header_id AS VARCHAR(25)) + ' assigned to ' + @desc 
			, sdh.source_deal_header_id, sdh.ext_deal_id
		FROM #deals_count dc 
		INNER JOIN source_deal_detail sd ON dc.source_deal_detail_id = sd.source_deal_detail_id
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sd.source_deal_header_id 	
	END	--unassignment log

	IF @assigned_state IS NULL
	RETURN

	IF @unassign = 0
	BEGIN
		SELECT @desc = CAST(CAST(SUM(tmp.volume) AS INT) AS VARCHAR)
			+ ' ' + (SELECT @uom) + '  assigned to ' 
			+ (SELECT code FROM static_data_value WHERE value_id = @assignment_type) 
			+  ' Category.'
		FROM #deals_count tmp
	END
	ELSE
	BEGIN
		SET @desc = CAST(CAST((
			SELECT SUM(tmp.volume)
				FROM #deals_count tmp) AS INT) AS VARCHAR(40)) 
				+ ' ' + (@uom) + ' assigned to Banked (Inventory) '
				+ ' Category on ' + dbo.FNADateFormat(@assigned_date) 

	END

	EXEC spa_message_board 'i', @user_name, NULL, 'Assign Credits/Allowance', @desc, '', '', 's', @job_name

	IF @@ERROR <> 0
	BEGIN	
		SET @sql_stmt = 'Failed to unassign Credits/Allowance: ' + @source_deal_detail_ids
		EXEC spa_ErrorHandler @@ERROR, 'Assign Credits/Allowance Deals', 'spa_assign_transaction', 'DB Error', @sql_stmt, ''
	END
	ELSE
	BEGIN
	IF @unassign = 0
		SET @sql_stmt = 'Successfully ' + @assign_commit_label + ' Credits '  +
			CASE WHEN(@assignment_type = 5173) THEN ', AND sales position created.' ELSE '' END
	ELSE
		SET @sql_stmt = 'Successfully ' + @unassign_commit_label + ' Credits ' +
			CASE WHEN(@assignment_type = 5173) THEN ', AND sales position deleted.' ELSE '' END

	EXEC spa_ErrorHandler 0, 'Assign Credits/Allowance Deals', 'spa_assign_transaction', 'Success', @sql_stmt, ''
	END