IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_insert_position_schedule_xml_deal]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_insert_position_schedule_xml_deal]
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
* @single_deal_multiple_term = 1 
* Create single deal with multiple terms schedule deals. By default this is set to 0 to create multiple deals single term schedule deal.
* @flag = 'i' - Insert schedule transportation deal.
* @flag = 'r' - Reschedule transportation deal.
* @flag = 'd' - Delete scheduled deals.
*/

CREATE PROCEDURE [dbo].[spa_insert_position_schedule_xml_deal]
	@flag					VARCHAR(2),
	@deal_xml				TEXT = NULL,
	@source_deal_detail_id	INT = NULL,
	@source_deal_header_id	INT = NULL,
	@trans_id				VARCHAR(1000) = NULL,
	@isconfirm				BIT = 0
AS
SET NOCOUNT ON

/*

DEClARE	@flag					VARCHAR(2)
DEClARE	@deal_xml				VARCHAR(max)
DEClARE	@source_deal_detail_id	INT
DEClARE	@source_deal_header_id	INT 
DEClARE	@trans_id				VARCHAR(1000) 
DEClARE	@isconfirm				BIT 

SELECT @flag='i',
	@deal_xml='<Root>
		<PSRecordset edit_grid0="1" edit_grid1="758" edit_grid2="370" edit_grid3="2017-12-01" edit_grid4="2017-12-02" edit_grid5="12000" edit_grid6="0.02" edit_grid7="0" edit_grid8="11760" edit_grid9="" edit_grid10="" edit_grid11="1607" edit_grid12="1617" edit_grid13="" edit_grid14="" edit_grid15="2980" edit_grid16="2980" edit_grid17="" edit_grid18="n" edit_grid19="372000" edit_grid20="" edit_grid21="" edit_grid23="" edit_grid22="108">
			<group_path row_no="1" contract_id="370" clm_primary_path_id="758" clm_path="758" clm_scheduled_volume="4000" clm_shrinkage="0.02" clm_delivered_volume="3920" />
		</PSRecordset>
		<PSRecordset edit_grid0="2" edit_grid1="760" edit_grid2="370" edit_grid3="2017-12-01" edit_grid4="2017-12-03" edit_grid5="12000" edit_grid6="0" edit_grid7="0" edit_grid8="12000" edit_grid9="" edit_grid10="" edit_grid11="1607" edit_grid12="1618" edit_grid13="" edit_grid14="" edit_grid15="2980" edit_grid16="2980" edit_grid17="" edit_grid18="n" edit_grid19="372000" edit_grid20="" edit_grid21="" edit_grid23="" edit_grid22="108">
			<group_path row_no="1" contract_id="370" clm_primary_path_id="760" clm_path="758" clm_scheduled_volume="5000" clm_shrinkage="0.02" clm_delivered_volume="4900" />
			<group_path row_no="2" contract_id="370" clm_primary_path_id="760" clm_path="759" clm_scheduled_volume="4900" clm_shrinkage="0.02" clm_delivered_volume="4802" />
		</PSRecordset>
	</Root>',
	@source_deal_header_id='42353',
	@source_deal_detail_id=NULL,
	@isconfirm='0'
--*/


--DECLARE @internal_deal_subtype_value_id	VARCHAR(30)	= 'Transportation'
--Start collecting transportation/MR template details
	
DECLARE	@user_login_id					VARCHAR(30)	  = dbo.FNADBUser()	
		, @process_id					VARCHAR(50)	  = dbo.FNAGetNewID()
		, @sql							VARCHAR(MAX)
		, @validate_sch_deal_vol_log	VARCHAR(100)
		, @validate_table_name			VARCHAR(20) = 'schedule_detail'
		, @round_by						INT = 0
		, @optimizer_header				INT
		, @desc1						VARCHAR(10)
		, @desc2						VARCHAR(10)
		, @transport_desc2				VARCHAR(10)
	 
SET @validate_sch_deal_vol_log = dbo.FNAProcessTableName(@validate_table_name, @user_login_id, @process_id) 
				
--Type id 1 for Transportation template and 5 for MR template.	
IF OBJECT_ID(N'tempdb..#template_details') IS NOT NULL DROP TABLE #template_details
IF OBJECT_ID(N'tempdb..#source_deals') IS NOT NULL DROP TABLE #source_deals
IF OBJECT_ID(N'tempdb..#inserted_deals') IS NOT NULL DROP TABLE #inserted_deals
IF OBJECT_ID(N'tempdb..#inserted_deal_detail') IS NOT NULL DROP TABLE #inserted_deal_detail
IF OBJECT_ID(N'tempdb..#inserted_deal_detail2') IS NOT NULL DROP TABLE #inserted_deal_detail2
IF OBJECT_ID(N'tempdb..#inserted_dth') IS NOT NULL DROP TABLE #inserted_dth
IF OBJECT_ID(N'tempdb..#inserted_deal_scheduled') IS NOT NULL DROP TABLE #inserted_deal_scheduled
IF OBJECT_ID(N'tempdb..#inserted_deals_final') IS NOT NULL DROP TABLE #inserted_deals_final
IF OBJECT_ID(N'tempdb..#validate_sch_deal_vol_log') IS NOT NULL DROP TABLE #validate_sch_deal_vol_log
IF OBJECT_ID(N'tempdb..#volume_per_term') IS NOT NULL DROP TABLE #volume_per_term
IF OBJECT_ID(N'tempdb..#loss_factor') IS NOT NULL DROP TABLE #loss_factor
IF OBJECT_ID(N'tempdb..#group_path') IS NOT NULL DROP TABLE #group_path

CREATE TABLE #template_details (
	template_id				INT, 
	template_name			VARCHAR(250) COLLATE DATABASE_DEFAULT ,
	template_type_id		INT,
	term_frequency_type		CHAR(1) COLLATE DATABASE_DEFAULT , 
	option_flag				CHAR(1) COLLATE DATABASE_DEFAULT ,
	option_type				CHAR(1) COLLATE DATABASE_DEFAULT ,
	header_buy_sell_flag	CHAR(1) COLLATE DATABASE_DEFAULT ,
	physical_financial_flag CHAR(1) COLLATE DATABASE_DEFAULT ,
	deal_type_id			INT,
	deal_sub_type_id		INT,
	deal_prefix				VARCHAR(500) COLLATE DATABASE_DEFAULT ,
	commodity_id			INT
) 

SET @sql = '
	INSERT INTO #template_details(template_id,
			template_name, 
			template_type_id,
			term_frequency_type, 
			option_flag, 
			option_type, 
			header_buy_sell_flag,
			physical_financial_flag, 
			deal_type_id, 
			deal_sub_type_id, 
			deal_prefix,
			commodity_id 
	)
	SELECT sdht.template_id,
		sdht.template_name,
		gmv.clm1_value,
		ISNULL(sdht.term_frequency_type, ''d''),
		sdht.option_flag,
		sdht.option_type,
		sdht.header_buy_sell_flag,
		sdht.physical_financial_flag,
		sdht.source_deal_type_id,
		sdht.deal_sub_type_type_id,
		ISNULL(drip.prefix, ''SCHD_'') deal_prefix,
		sdht.commodity_id
	FROM generic_mapping_header gmh
	INNER JOIN generic_mapping_values gmv ON gmh.mapping_table_id = gmv.mapping_table_id AND gmh.mapping_name = ''Imbalance Report''
	LEFT JOIN source_deal_header_template sdht ON cast(sdht.template_id AS VARCHAR(100)) = gmv.clm3_value
	LEFT JOIN deal_reference_id_prefix drip ON drip.deal_type = sdht.source_deal_type_id
	WHERE gmv.clm1_value IN (''1'', ''5'')				
'			
			
EXEC(@sql)

IF @flag IN ('i', 'r') 
BEGIN	
	DECLARE @frequency					CHAR(1)			= 'd',	
			@idoc						INT,
			@doc						VARCHAR(1000),
			@phy_deal_id				INT,
			@map1						INT,
			@map2						INT, 
			@map3						INT,
			@map4						INT,
			@single_deal_multiple_term	BIT = 0,			
			@err_msg					VARCHAR(3000)

	--variables used in cursor
	DECLARE @row						INT,
			@row_sch					INT,
			@prev_row_sch				INT = 0,
			@path_id					INT,
			--@path_detail_id 			INT,
			@term_start					DATETIME,
			@term_end					DATETIME,		
			@book_id					INT, 
			@book_map1					INT,
			@book_map2					INT, 
			@book_map3					INT,
			@book_map4					INT,
			@from_curve					VARCHAR(500),
			@from_location				VARCHAR(500),
			@from_meter					VARCHAR(500),
			@to_curve					VARCHAR(500),
			@to_location				VARCHAR(500),
			@to_meter					VARCHAR(500),
			@delivered_volume			NUMERIC(38, 20),
			@prev_delivered_volume		NUMERIC(38, 20) = 0,
			@prev_location_to			VARCHAR(100),
			@prev_primary_path_id		VARCHAR(100),
			@prev_path_id				VARCHAR(100),
			@new_schedule				BIT = 0,
			@group_path_id				INT,
			@template_type_id			INT = 1		--Transportation template in generic mapping table
			
	--For UDF fields
	DECLARE @del_counterparty_value_id		VARCHAR(400),
			 @rec_counterparty_value_id		VARCHAR(400),
			 @from_deal_value_id			VARCHAR(10),
			 @delivery_path_id				VARCHAR(20),
			 @from_deal_detail_value_id		VARCHAR(10)

	--Collects xml data
	EXEC sp_xml_preparedocument @idoc OUTPUT, @deal_xml
	SELECT 
		clm_row_no,	
		clm_contract,
		clm_loss_factor,
		clm_fuel_charge,
		clm_scheduled_volume,
		clm_available_volume,
		clm_delivered_volume,
		clm_trader,
		clm_location_from,
		clm_location_to,
		clm_counterparty_delivered,
		clm_counterparty_receive,
		clm_path,
		clm_path_detail_id,
		clm_term_start,
		clm_term_end,
		clm_book,
		clm_trans_id,
		clm_source_deal_header_id,
		CASE clm_is_mr WHEN '1' THEN 'y' ELSE 'n' END clm_is_mr,
		clm_storage_contract
	INTO #source_deals
	FROM   OPENXML (@idoc, '/Root/PSRecordset',2)
	WITH ( 
		clm_row_no					INT				'@edit_grid0',
		clm_path					VARCHAR(100)	'@edit_grid1',
		clm_contract				VARCHAR(200)	'@edit_grid2',
		clm_term_start				VARCHAR(100)	'@edit_grid3',
		clm_term_end				VARCHAR(100)	'@edit_grid4',
		clm_scheduled_volume		NUMERIC(38,20)	'@edit_grid5',
		clm_loss_factor				NUMERIC(38,20)	'@edit_grid6',  
		clm_fuel_charge				VARCHAR(200)	'@edit_grid7',
		clm_delivered_volume		NUMERIC(38,20)	'@edit_grid8',
		clm_total_sch_volume		VARCHAR(200)	'@edit_grid9', 
		clm_total_del_volume		VARCHAR(200)	'@edit_grid10', 	
		clm_location_from			VARCHAR(200)	'@edit_grid11',
		clm_location_to				VARCHAR(200)	'@edit_grid12',
		clm_book					VARCHAR(100)	'@edit_grid13',
		clm_uom						VARCHAR(100)	'@edit_grid14',
		clm_counterparty_delivered	VARCHAR(100)	'@edit_grid15',
		clm_counterparty_receive	VARCHAR(100)	'@edit_grid16',	
		clm_trans_id				INT				'@edit_grid17',
		clm_is_mr					CHAR(1)			'@edit_grid18',
		clm_available_volume		VARCHAR(200)	'@edit_grid19', 
		clm_source_deal_header_id	INT				'@edit_grid20', 
		clm_path_detail_id			VARCHAR(100)	'@edit_grid21',
		clm_trader					VARCHAR(100)	'@edit_grid22',		 --in php clm index no of process id is used
		clm_storage_contract		INT				'@edit_grid23'
	)

	EXEC sp_xml_removedocument @idoc

	--Collects xml data
	EXEC sp_xml_preparedocument @idoc OUTPUT, @deal_xml
	SELECT 
		parent_row_no,
		row_no,	
		clm_contract,
		clm_primary_path_id,
		clm_path,
		clm_scheduled_volume,
		clm_shrinkage,
		clm_delivered_volume
	INTO #group_path
	FROM   OPENXML (@idoc, '/Root/PSRecordset/group_path',2)
	WITH ( 
		parent_row_no				INT		'../@edit_grid0',
		row_no						INT		'@row_no',
		clm_contract				INT		'@contract_id',
		clm_primary_path_id			INT		'@clm_primary_path_id',
		clm_path					INT		'@clm_path',
		clm_scheduled_volume		FLOAT	'@clm_scheduled_volume',
		clm_shrinkage				FLOAT	'@clm_shrinkage',
		clm_delivered_volume		FLOAT	'@clm_delivered_volume'
	)

	EXEC sp_xml_removedocument @idoc

	IF EXISTS(
		select 1
		FROM generic_mapping_header gmh
		INNER JOIN generic_mapping_values gmv
			ON gmh.mapping_table_id = gmv.mapping_table_id
		INNER JOIN #source_deals sd 
			ON sd.clm_counterparty_delivered = gmv.clm1_value		
		WHERE gmh.mapping_name = 'Flow Optimization Mapping'
			AND NULLIF(gmv.clm2_value, '') IS NULL
			AND NULLIF(sd.clm_book, '')  IS NULL
	)
	BEGIN
		SET @err_msg = 'Mapping not found for the pipeline, please select appropriate book.'
		
		EXEC spa_ErrorHandler -1,
			'Path MDQ', 
			'spa_insert_position_schedule_xml_deal',
			'Error',
			@err_msg,
			@err_msg
			
		RETURN
	END

	DECLARE @gen_mapping_id1 INT,  @gen_mapping_id2 INT, @gen_mapping_id3 INT, @gen_mapping_id4 INT

	SELECT @gen_mapping_id1	= source_system_book_id1, 
		@gen_mapping_id2	= source_system_book_id2, 
		@gen_mapping_id3	= source_system_book_id3, 
		@gen_mapping_id4	= source_system_book_id4
	FROM generic_mapping_header gmh
		INNER JOIN generic_mapping_values gmv
			ON gmh.mapping_table_id = gmv.mapping_table_id
		INNER JOIN #source_deals sd 
			ON sd.clm_counterparty_delivered = gmv.clm1_value
		INNER JOIN source_system_book_map ssbm
			ON ssbm.book_deal_type_map_id = gmv.clm2_value
	WHERE gmh.mapping_name = 'Flow Optimization Mapping'

	DECLARE @chk_template_name VARCHAR(100)

	SELECT @chk_template_name = CASE  clm_is_mr WHEN 'y' THEN 'MR' ELSE 'Transportation' END 
	FROM #source_deals sd
	LEFT JOIN #template_details td 
		ON td.template_type_id = CASE clm_is_mr WHEN 'y' THEN '5' ELSE '1' END
	WHERE td.template_id IS NULL

	IF @chk_template_name IS NOT NULL
	BEGIN	
		SET @err_msg = 'Template not available for ' + @chk_template_name + ' template.'
		EXEC spa_ErrorHandler -1, 
			'Transportation', 
			'spa_schedule_n_delivery',
			'Error',
			'Fail to create transport deal. Template undefined',
			@err_msg
		RETURN
	END

	IF @source_deal_header_id IS NOT NULL
	BEGIN
		SET @phy_deal_id = @source_deal_header_id
	END
	ELSE
	BEGIN
		SELECT	@phy_deal_id = source_deal_header_id 
		FROM	source_deal_detail 
		WHERE	source_deal_detail_id = @source_deal_detail_id
	END

	SELECT @map1	= sdh.source_system_book_id1,
		@map2		= sdh.source_system_book_id2,
		@map3		= sdh.source_system_book_id3,
		@map4		= sdh.source_system_book_id4
	FROM source_deal_header sdh 
	WHERE sdh.source_deal_header_id = @phy_deal_id

	--UDFs
	SELECT @rec_counterparty_value_id = value_id
	FROM   static_data_value
	WHERE  code = 'Receiving Counterparty' 
		AND TYPE_ID = 5500 

	SELECT @del_counterparty_value_id = value_id
	FROM   static_data_value
	WHERE  code = 'Shipping Counterparty' 
		AND TYPE_ID = 5500 

	SELECT @from_deal_value_id = value_id
	FROM   static_data_value
	WHERE  code = 'From Deal' 
		AND TYPE_ID = 5500 

	SELECT @from_deal_detail_value_id = value_id
	FROM   static_data_value
	WHERE  code = 'From Deal Detail' 
		AND TYPE_ID = 5500 
	
	SELECT @delivery_path_id = value_id
	FROM   static_data_value sdv
	WHERE  sdv.code = 'Delivery Path' 
		AND TYPE_ID = 5500 
			
	SELECT	@frequency = term_frequency_type 
	FROM #template_details 
	WHERE template_type_id = 1	--term_frequency_type of transportation template.

	--Ends Collecting transportation/MR deal template details.

	--Physical deal volume termwise breakdown. Daily term frequency is in use.
	IF OBJECT_ID(N'tempdb..#phy_deal_vol') IS NOT NULL DROP TABLE #phy_deal_vol
	CREATE TABLE #phy_deal_vol (
		term_start		DATETIME
		, term_end		DATETIME
		, deal_volume	NUMERIC(38, 20)	
	)

	/*
	* Breakdown physical volume to daily.
	* Read daily position from previously calculated table (report_hourly_position_deal)
	*/

	SET @sql = '
		INSERT INTO #phy_deal_vol (term_start, term_end, deal_volume)
		SELECT MIN(term_start), MAX(term_end), SUM(deal_volume)  
		FROM source_deal_detail sdd			
		WHERE 1 = 1
	'

	IF @source_deal_detail_id IS NOT NULL
	BEGIN
		SET @sql = @sql + ' AND sdd.source_deal_detail_id = ' + CAST(@source_deal_detail_id AS VARCHAR(20)) 
	END
	ELSE IF @phy_deal_id IS NOT NULL
	BEGIN
		SET @sql = @sql + ' AND sdd.source_deal_header_id = ' + CAST(@source_deal_header_id AS VARCHAR(20))
	END	

	SET @sql = @sql + '  GROUP BY source_deal_detail_id'

	EXEC(@sql)
	
	UPDATE #source_deals SET clm_trader = NULL WHERE  clm_trader = 'NULL' OR clm_trader = '' OR clm_trader = 0
	UPDATE #source_deals SET clm_counterparty_delivered = NULL WHERE  clm_counterparty_delivered = 'NULL' OR clm_counterparty_delivered = '' OR clm_counterparty_delivered = 0
	UPDATE #source_deals SET clm_counterparty_receive = NULL WHERE  clm_counterparty_receive = 'NULL' OR clm_counterparty_receive = '' OR clm_counterparty_receive = 0
	
	DELETE FROM #source_deals WHERE   clm_counterparty_delivered IS NULL OR clm_trader IS NULL OR clm_counterparty_receive IS NULL

	DECLARE @chk_sch_deal INT
	SELECT @chk_sch_deal = COUNT(1) FROM #source_deals
	
	IF @chk_sch_deal = 0
	BEGIN	
		EXEC spa_ErrorHandler -1, 
			'Transportation', 
			'spa_schedule_n_delivery', 
			'Error', 
			'Receiving Counterparty/Trader is not defined. Please check.', 
			'Counterparty or Trader undefined'
		RETURN
	END

	--GroupPath
	IF OBJECT_ID(N'tempdb..#source_deals_gp') IS NOT NULL DROP TABLE #source_deals_gp
	CREATE TABLE #source_deals_gp (
		row_no						INT IDENTITY(1, 1),	
		clm_contract				VARCHAR(200) COLLATE DATABASE_DEFAULT ,	
		clm_loss_factor				NUMERIC(38,20),				
		clm_scheduled_volume		NUMERIC(38,20),			
		clm_delivered_volume		NUMERIC(38,20),		
		clm_trader					VARCHAR(100) COLLATE DATABASE_DEFAULT ,
		clm_location_from			VARCHAR(200) COLLATE DATABASE_DEFAULT ,		
		clm_location_to				VARCHAR(200) COLLATE DATABASE_DEFAULT ,			
		clm_counterparty_delivered	CHAR(100) COLLATE DATABASE_DEFAULT ,	
		clm_counterparty_receive	VARCHAR(100) COLLATE DATABASE_DEFAULT ,			
		clm_path					VARCHAR(100) COLLATE DATABASE_DEFAULT ,	
		clm_path_detail_id			VARCHAR(100) COLLATE DATABASE_DEFAULT ,					
		clm_term_start				DATETIME, --VARCHAR(100) COLLATE DATABASE_DEFAULT ,			
		clm_term_end				DATETIME, --VARCHAR(100) COLLATE DATABASE_DEFAULT ,			
		clm_book					VARCHAR(100) COLLATE DATABASE_DEFAULT ,	
		clm_trans_id				INT,
		clm_source_deal_header_id	INT,
		clm_primary_path_id			VARCHAR(100) COLLATE DATABASE_DEFAULT ,	
		clm_schedule_no				INT	,
		clm_is_mr					CHAR(1) COLLATE DATABASE_DEFAULT ,
		clm_storage_contract		INT,					
		clm_withdraw_or_injection	CHAR(1) COLLATE DATABASE_DEFAULT 
	)

	--Breakdown #source_deals_gp before cursor begins when @single_deal_multiple_term = 0. If @single_deal_multiple_term = 1 then breakdown inside cursor.
	--Deal is created as breakdown in this table.
	
	IF @single_deal_multiple_term = 0
	BEGIN
		SELECT @term_start	= MIN(clm_term_start)
			, @term_end		= MAX(clm_term_end)
		FROM #source_deals
	END

	CREATE TABLE #loss_factor (
		path_id			INT,
		term_start		DATETIME,
		effective_date	DATETIME,
		loss_factor		NUMERIC(38, 18)
	)

	INSERT INTO #loss_factor(path_id, term_start, effective_date, loss_factor)
	SELECT pls.path_id, s.term_start, pls.effective_date, pls.loss_factor	
	FROM [path_loss_shrinkage] pls 
	INNER JOIN (
		SELECT pls.path_id, 
			MAX(effective_date) effective_date,
			tb.term_start

		FROM #source_deals sd
		INNER JOIN delivery_path_detail dpd 
			ON sd.clm_path =  ISNULL(dpd.Path_id, -1)
		INNER JOIN delivery_path dp 
			ON dp.path_id = ISNULL(dpd.Path_name, sd.clm_path)  
		INNER JOIN [path_loss_shrinkage] pls
			ON pls.path_id = dp.path_id
		INNER JOIN dbo.FNATermBreakdown(@frequency, @term_start, @term_end) tb
			ON pls.effective_date <= tb.term_start
		GROUP BY pls.path_id, tb.term_start
	) s
		ON s.path_id = pls.path_id
			AND s.effective_date = pls.effective_date
		
	SET @sql = ' 
		INSERT INTO #source_deals_gp (
				clm_contract,				
				clm_loss_factor,		
				clm_scheduled_volume,	
				clm_delivered_volume,		
				clm_trader,				
				clm_location_from,			
				clm_location_to,			
				clm_counterparty_delivered,
				clm_counterparty_receive,	
				clm_path,					
				clm_path_detail_id,			
				clm_term_start,			
				clm_term_end,				
				clm_book,					
				clm_trans_id,					
				clm_source_deal_header_id,
				clm_primary_path_id,
				clm_schedule_no,	
				clm_is_mr					
			)
			SELECT 	
				--sd.clm_contract	
				CASE WHEN dpd.Path_id IS NULL THEN ISNULL(sd.clm_contract, 0) ELSE ISNULL(dp.[CONTRACT], 0) END
				, CASE WHEN dpd.Path_id IS NULL THEN ISNULL(sd.clm_loss_factor, 0) ELSE ISNULL(lf.loss_factor, 0) END
				, sd.clm_scheduled_volume
				,  ROUND(sd.clm_scheduled_volume * (1 - CAST(CASE WHEN dpd.Path_id IS NULL THEN ISNULL(sd.clm_loss_factor, 0) ELSE ISNULL(lf.loss_factor, 0) END AS NUMERIC(38,20))), ' + CAST(@round_by AS CHAR(1)) + ')
				, sd.clm_trader
				, dp.from_location 
				--, ISNULL(sd.clm_location_from, dp.from_location )
				, dp.to_location 	
				, sd.clm_counterparty_delivered
				, sd.clm_counterparty_receive
				, dp.path_id 			
				, dpd.delivery_path_detail_id 	
				, '  
				+	CASE @single_deal_multiple_term 
						WHEN 0 THEN 'fb.term_start, fb.term_end' 
						ELSE 'sd.clm_term_start, sd.clm_term_end' 
					END				
				+ '
				, sd.clm_book
				, sd.clm_trans_id
				, sd.clm_source_deal_header_id
				, sd.clm_path
				, sd.clm_row_no
				, sd.clm_is_mr

			FROM #source_deals sd
			LEFT JOIN delivery_path_detail dpd 
				ON sd.clm_path =  ISNULL(dpd.Path_id, -1)
			LEFT JOIN delivery_path dp 
				ON dp.path_id = ISNULL(dpd.Path_name, sd.clm_path)
				'  
				+	CASE @single_deal_multiple_term 
						WHEN 0 THEN 'CROSS JOIN dbo.FNATermBreakdown(''' + @frequency + ''', ''' + CONVERT(VARCHAR, @term_start, 120) + ''', ''' + CONVERT(VARCHAR, @term_end, 120) + ''') fb
								LEFT JOIN #loss_factor lf 
									ON lf.path_id = dp.path_id
									AND lf.term_start = fb.term_start
								WHERE fb.term_start BETWEEN sd.clm_term_start AND sd.clm_term_end
								ORDER BY sd.clm_row_no
								'
						ELSE '' 
					END
	EXEC(@sql)
	
	DECLARE @storage_contract_id INT

	SELECT @storage_contract_id = clm_storage_contract 
	FROM #source_deals

	--Withdrawal
	UPDATE sdg
	SET sdg.clm_withdraw_or_injection = 'w'
	FROM #source_deals_gp sdg
	INNER JOIN source_minor_location sml 
		ON sdg.clm_location_from = sml.source_minor_location_id
	INNER JOIN source_major_location smjl 
		ON sml.source_major_location_ID = smjl.source_major_location_ID
	WHERE smjl.location_name = 'storage'

	--Injection
	UPDATE sdg
	SET sdg.clm_withdraw_or_injection = 'i'
	FROM #source_deals_gp sdg
	INNER JOIN source_minor_location sml 
		ON sdg.clm_location_to = sml.source_minor_location_id
	INNER JOIN source_major_location smjl 
		ON sml.source_major_location_ID = smjl.source_major_location_ID
	WHERE smjl.location_name = 'storage'

	IF EXISTS (SELECT 1 FROM #group_path)
	BEGIN			
		UPDATE sdg
		SET sdg.clm_contract = gp.clm_contract,
			sdg.clm_scheduled_volume = gp.clm_scheduled_volume,
			sdg.clm_loss_factor = gp.clm_shrinkage,
			sdg.clm_delivered_volume = gp.clm_delivered_volume
		FROM #source_deals_gp sdg
		INNER JOIN #group_path gp
			ON gp.clm_path = sdg.clm_path
				AND gp.clm_primary_path_id = sdg.clm_primary_path_id
				AND gp.parent_row_no = sdg.clm_schedule_no
	END
		
	DECLARE  @temp_source_deal_header_id VARCHAR(MAX)			

	SET @temp_source_deal_header_id = '#'   
	
	--Create temp tables.	
	CREATE TABLE #inserted_deals (
		source_deal_header_id	INT, 
		term_start				DATETIME, 
		term_end				DATETIME,
		[deal_sub_type_type_id] INT,
		source_deal_type_id		INT
	)

	CREATE TABLE #inserted_deal_detail (
		source_deal_header_id	INT, 
		source_deal_detail_id	INT,
		deal_volume				FLOAT    
	)

	CREATE TABLE #inserted_deal_detail2 (
		source_deal_header_id	INT, 
		source_deal_detail_id	INT,	
		deal_volume				FLOAT    
	)

	CREATE TABLE #inserted_dth (
		deal_transport_id		INT, 
		source_deal_header_id	INT 	
	)

	CREATE TABLE #inserted_deal_scheduled (
		deal_schedule_id		INT, 
		path_id					INT 	
	)

	CREATE TABLE #inserted_deals_final (
		source_deal_header_id	INT, 
		term_start				DATETIME, 
		term_end				DATETIME,
		[deal_sub_type_type_id] INT,
		source_deal_type_id		INT
	)
		
	CREATE table #validate_sch_deal_vol_log(
		term_start					DATETIME,
		term_end					DATETIME,
		total_phy_volume			NUMERIC(38,20),
		total_sch_volume			NUMERIC(38,20),
		new_sch_volume				NUMERIC(38,20),
		total_available_volume		NUMERIC(38,20)
	)
	
	/*
	* @flag = i To create schedule deal.
	* @flag = r To create reschedule deal.
	* In case of rescheduling first reset deal volume of reschedule deal before creating new schedule deal.
	*/
	IF OBJECT_ID(N'tempdb..#source_deals_vol_update') IS NOT NULL 
		DROP TABLE #source_deals_vol_update
	
	CREATE TABLE #source_deals_vol_update (
		clm_row_no					INT IDENTITY(1, 1),	
		clm_source_deal_header_id	INT,					
		clm_term_start				DATETIME,			
		clm_term_end				DATETIME,		
		clm_scheduled_volume		NUMERIC(38,20),
		clm_loss_factor				NUMERIC(38,20),				
		clm_delivered_volume		NUMERIC(38,20),	
		clm_location_from			VARCHAR(200) COLLATE DATABASE_DEFAULT ,		
		clm_location_to				VARCHAR(200) COLLATE DATABASE_DEFAULT ,			
		clm_path					VARCHAR(100) COLLATE DATABASE_DEFAULT ,	
		clm_path_detail_id			VARCHAR(100) COLLATE DATABASE_DEFAULT ,	
		clm_schedule_no				INT				
	)

			
	IF @flag IN ('i', 'r') 
	BEGIN

		DECLARE @deal_status_new		INT = 17200	-- Deal Confirm Status value for 'Not Confirmed' 
		DECLARE @confirm_status_new		INT 
		
		SELECT @deal_status_new = srd.Change_to_status_id
		FROM status_rule_detail srd
		INNER JOIN status_rule_header srh
			ON srh.status_rule_id = srd.status_rule_id
		LEFT JOIN static_data_value sdv1
			ON srd.event_id = sdv1.value_id
			AND sdv1.[type_id] = 19500
		WHERE srh.status_rule_name = 'Deal Status'
			AND sdv1.code = 'deal insert'
			AND srd.event_id = 19501

		BEGIN TRY
			BEGIN TRAN	
				--In case of rescheduling first reset deal volume of rescheduled deal before creating new schedule deal.
				IF @flag = 'r'
				BEGIN
					--print 'Reset rescheduled deal volume before scheduling deal.'
					IF OBJECT_ID(N'tempdb..#total_resch_deals') IS NOT NULL DROP TABLE  #total_resch_deals
				
					DECLARE @rescheduled_trans_id	INT
						, @vol_to_be_sch			NUMERIC(38, 20)
						, @chk_is_mr				CHAR(1)
				
					SELECT TOP 1 @rescheduled_trans_id	= sdg.clm_trans_id,
						@term_start						= MIN(sdg.clm_term_start),
						@term_end						= MAX(sdg.clm_term_end),
						@vol_to_be_sch					= MAX(sdg.clm_scheduled_volume)							 
					FROM #source_deals_gp sdg 
					GROUP BY sdg.clm_trans_id
				
					--Collects rescheduled deals for paticular rescheduled trans id.
					SELECT
						uddf_resch.source_deal_header_id
						, sdd.term_start
						, sdd.term_end
						, @vol_to_be_sch sch_vol
						, @vol_to_be_sch * (1- CAST(uddf_loss.udf_value AS NUMERIC(38,20))) del_vol
						, uddf_path.udf_value path_id
						, uddf_path_detail.udf_value path_detail_id
						, uddf_loss.udf_value loss_factor
						, CASE  WHEN sdd.leg = 1 THEN sdd.location_id ELSE NULL END clm_location_from
						, CASE  WHEN sdd.leg = 2 THEN sdd.location_id ELSE NULL END clm_location_to
					INTO #total_resch_deals
					FROM [user_defined_deal_fields_template] uddft
					INNER JOIN source_deal_header_template sdht 
						ON sdht.template_id = uddft.template_id
					INNER JOIN  user_defined_deal_fields uddf_resch  WITH (NOLOCK) 
						ON uddf_resch.udf_template_id = uddft.udf_template_id 
							AND uddft.field_name = -5607	--Scheduled ID UDF field
							AND uddf_resch.udf_value = CAST(@rescheduled_trans_id AS VARCHAR) 
					INNER JOIN source_deal_detail sdd 
						ON sdd.source_deal_header_id = uddf_resch.source_deal_header_id
							AND sdd.term_start BETWEEN @term_start AND @term_end
					INNER JOIN user_defined_deal_fields uddf_path  WITH (NOLOCK) 
						ON  uddf_path.source_deal_header_id = uddf_resch.source_deal_header_id
					INNER JOIN [user_defined_deal_fields_template] uddft_path 
						ON uddft_path.udf_template_id = uddf_path.udf_template_id
							AND uddft_path.field_id = @delivery_path_id -- Delivery path udf
					INNER JOIN user_defined_deal_fields uddf_path_detail  WITH (NOLOCK) 
						ON  uddf_path_detail.source_deal_header_id = uddf_resch.source_deal_header_id
					INNER JOIN [user_defined_deal_fields_template] uddft_path_detail 
						ON uddft_path_detail.udf_template_id = uddf_path_detail.udf_template_id
							AND uddft_path_detail.field_id = -5606 --path detail id udf
					--LEFT JOIN delivery_path dp ON CAST(dp.path_id AS VARCHAR) = uddf_path.udf_value
					--udf loss
					INNER JOIN user_defined_deal_fields uddf_loss  WITH (NOLOCK)
						ON  uddf_loss.source_deal_header_id = uddf_resch.source_deal_header_id
					INNER JOIN [user_defined_deal_fields_template] uddft_loss 
						ON uddft_loss.udf_template_id = uddf_loss.udf_template_id
							AND uddft_loss.field_id = -5614 -- loss udf	
					ORDER BY uddf_resch.source_deal_header_id
				
					INSERT INTO #source_deals_vol_update(
						clm_source_deal_header_id,					
						clm_term_start,	
						clm_term_end,	
						clm_scheduled_volume,
						clm_loss_factor,			
						clm_delivered_volume,
						clm_location_from,	
						clm_location_to,		
						clm_path,
						clm_path_detail_id,
						clm_schedule_no
					)
					SELECT source_deal_header_id
						, term_start
						, term_end
						, MAX(sch_vol)
						, loss_factor
						, MAX(del_vol)
						, MAX(clm_location_from)
						, MAX(clm_location_to)
						, path_id 
						, path_detail_id
						, @rescheduled_trans_id
					FROM #total_resch_deals
					GROUP BY source_deal_header_id
						, term_start
						, term_end
						, path_id 
						, path_detail_id
						, loss_factor

					DECLARE @resch_deal_id INT
						, @resch_row	INT 
				
					DECLARE cur_resch_deal CURSOR LOCAL FOR
						SELECT clm_row_no, clm_source_deal_header_id
						FROM #source_deals_vol_update resch_deals
						ORDER BY clm_source_deal_header_id
					
					OPEN cur_resch_deal
						FETCH NEXT FROM cur_resch_deal INTO @resch_row, @resch_deal_id
						WHILE @@FETCH_STATUS = 0   
						BEGIN 
							--Update deal volume of rescheduled deals.	
							UPDATE sdd 
							SET sdd.deal_volume = ROUND(
								CASE 
									WHEN sdd.leg = 1 
										THEN 
											CASE WHEN (sdd.deal_volume - sdg.clm_scheduled_volume) < 0 
												THEN 0 
												ELSE (sdd.deal_volume - sdg.clm_scheduled_volume) 
											END
									WHEN sdd.leg = 2 
										THEN 
											CASE WHEN (sdd.deal_volume - sdg.clm_delivered_volume) < 0 
												THEN 0 
												ELSE (sdd.deal_volume - sdg.clm_delivered_volume) 
											END
								END, @round_by
							)				 
							FROM 
							#source_deals_vol_update sdg
							INNER JOIN source_deal_detail sdd 
								ON sdd.term_start BETWEEN sdg.clm_term_start AND sdg.clm_term_end
									AND sdd.source_deal_header_id = @resch_deal_id	
							WHERE sdg.clm_row_no = @resch_row
					
							--Update volume to be scheduled for next path defined in given group path.			
							UPDATE sdg 
							SET sdg.clm_scheduled_volume	= sdg1.clm_delivered_volume
								, sdg.clm_delivered_volume	= sdg1.clm_delivered_volume * (1 - sdg.clm_loss_factor)
							FROM #source_deals_vol_update sdg 
							INNER JOIN (
								SELECT TOP 1 rs_next.clm_row_no, rs.clm_delivered_volume
								FROM #source_deals_vol_update rs_next
								LEFT JOIN #source_deals_vol_update rs
									ON rs.clm_row_no = @resch_row 
								WHERE rs.clm_term_start = rs_next.clm_term_start
									AND rs.clm_term_end = rs_next.clm_term_end 
									AND rs_next.clm_path_detail_id > rs.clm_path_detail_id
									AND rs.clm_location_to = rs_next.clm_location_from
							) sdg1
								ON sdg1.clm_row_no = sdg.clm_row_no
							
							FETCH NEXT FROM cur_resch_deal INTO @resch_row, @resch_deal_id
						END
					CLOSE cur_resch_deal
					DEALLOCATE  cur_resch_deal
					--print 'Volume updating cursor ends.'	
				
					----update volume of rescheduled deal in dtd
					UPDATE dtd 
					SET dtd.volume = ROUND(-1 * ABS(sdd.deal_volume), @round_by) 
					FROM #source_deals_vol_update resch_ids
		 			INNER JOIN source_deal_detail sdd 
		 				ON sdd.source_deal_header_id = resch_ids.clm_source_deal_header_id
							AND sdd.term_start BETWEEN @term_start AND @term_start
					INNER JOIN deal_transport_detail dtd 
						ON dtd.source_deal_detail_id_from = sdd.source_deal_detail_id
				
					--update delivered_volume of rescheduled deal in delivery status
					UPDATE ds 
					SET ds.delivered_volume = ROUND(ABS(sdd.deal_volume), @round_by) 		
					FROM #source_deals_vol_update resch_ids
					INNER JOIN source_deal_detail sdd 
						ON sdd.source_deal_header_id = resch_ids.clm_source_deal_header_id
							AND sdd.term_start BETWEEN @term_start AND @term_start
					INNER JOIN deal_transport_detail dtd 
						ON dtd.source_deal_detail_id_from = sdd.source_deal_detail_id
					CROSS APPLY (
						SELECT MAX(status_timestamp) as_of_date FROM delivery_status  WHERE source_deal_detail_id = sdd.source_deal_detail_id
					) dt	
					INNER JOIN delivery_status ds 
						ON ds.source_deal_detail_id = sdd.source_deal_detail_id	
							AND ds.status_timestamp = dt.as_of_date
				END
			
				/*
				* Starts Volume validation logic before deal creating cursor starts.	
				* Here #volume_per_term table is used only for validation purpose.
				*/
					
				SELECT @term_start	= MIN(clm_term_start)
					, @term_end		= MAX(clm_term_end)
				FROM #source_deals
					
				CREATE TABLE #volume_per_term (
					term_start			DATETIME,
					term_end			DATETIME,
					scheduled_volume	NUMERIC(38,20)
				)

				IF OBJECT_ID(N'tempdb..#source_deal_gp_breakdown') IS NOT NULL DROP TABLE #source_deal_gp_breakdown
				SELECT sd.clm_path primary_path_id
					, dp.path_id path_id
					, dpd.delivery_path_detail_id path_detail_id
					, dp.from_location 
				INTO #source_deal_gp_breakdown
				FROM #source_deals sd
				LEFT JOIN delivery_path_detail dpd 
					ON sd.clm_path =  ISNULL(dpd.Path_id, -1)
				LEFT JOIN delivery_path dp 
					ON dp.path_id = ISNULL(dpd.Path_name, sd.clm_path)
			
				SET @sql = ' 
					INSERT INTO #volume_per_term (
						term_start,
						term_end,
						scheduled_volume
					)
					SELECT fb.term_start
						, fb.term_end	
						, MAX(sd.clm_scheduled_volume) 
					FROM #source_deals sd
					LEFT JOIN 
					(
						SELECT sdgb.primary_path_id, min(sdgb.path_detail_id) path_detail_id 
						FROM #source_deal_gp_breakdown sdgb
						GROUP BY sdgb.primary_path_id
					) min_path_rs 
						on min_path_rs.primary_path_id = sd.clm_path
					LEFT JOIN delivery_path_detail dpd 
						ON dpd.delivery_path_detail_id = min_path_rs.path_detail_id
					LEFT JOIN delivery_path dp 
						ON dp.path_id = ISNULL(dpd.path_name, min_path_rs.primary_path_id)	
					LEFT JOIN #source_deal_gp_breakdown sdgb
						ON sdgb.primary_path_id = min_path_rs.primary_path_id
							AND sdgb.from_location = dp.from_location	
					CROSS JOIN dbo.FNATermBreakdown(''' + @frequency + ''', ''' + CONVERT(VARCHAR, @term_start, 120) + ''', ''' + CONVERT(VARCHAR, @term_end, 120) + ''') fb
					WHERE fb.term_start BETWEEN sd.clm_term_start AND sd.clm_term_end
					GROUP BY fb.term_start
						, fb.term_end
						, sdgb.primary_path_id
						, sdgb.from_location
						, sdgb.path_detail_id	
						, sd.clm_row_no	
				'  						

				EXEC(@sql)

				SET @sql = '
					IF OBJECT_ID(N''tempdb..#total_scheduled_deals'') IS NOT NULL DROP TABLE  #total_scheduled_deals
					IF OBJECT_ID(N''tempdb..#scheduled_deal_vol'') IS NOT NULL DROP TABLE  #scheduled_deal_vol					

					SELECT * 
					INTO #total_scheduled_deals
					FROM (
						SELECT sdh.source_deal_header_id			
								, uddft_sch.Field_label
								, uddf_sch.udf_value [udf_value]
								, sdh.template_id
						FROM [user_defined_deal_fields_template] uddft
						INNER JOIN  user_defined_deal_fields uddf  WITH (NOLOCK) 
							ON uddf.udf_template_id = uddft.udf_template_id 
								AND uddft.field_name = ' + @from_deal_value_id  + '
								AND uddf.udf_value = CAST(' + CAST(@source_deal_header_id AS VARCHAR(10)) + ' AS VARCHAR)
						INNER JOIN source_deal_header sdh
							ON sdh.source_deal_header_id = uddf.source_deal_header_id
						INNER JOIN user_defined_deal_fields_template uddft_sch
							ON sdh.template_id = uddft_sch.template_id
						INNER JOIN user_defined_deal_fields uddf_sch  WITH (NOLOCK)
							ON uddf_sch.udf_template_id = uddft_sch.udf_template_id 
								AND sdh.source_deal_header_id = uddf_sch.source_deal_header_id
					) s1
					PIVOT(MAX(udf_value) FOR Field_label IN ([Scheduled ID], [Path Detail ID])) AS a
						
					SELECT 
						MIN(sdd.term_start) term_start,
						MAX(sdd.term_start) term_end,
						SUM(sdd.deal_volume) scheduled_deal_volume
					INTO #scheduled_deal_vol
					FROM (
						SELECT tsd_inner.[Scheduled ID] scheduled_id
							, ISNULL(MIN(tsd_inner.[Path Detail ID]), -1) path_detail_id
						FROM #total_scheduled_deals tsd_inner
						GROUP BY tsd_inner.[Scheduled ID]
					) sch_deals
					INNER JOIN #total_scheduled_deals tsd
						ON tsd.[Scheduled ID] = sch_deals.scheduled_id
							AND ISNULL(tsd.[Path Detail ID], -1) = sch_deals.path_detail_id
					INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = tsd.source_deal_header_id AND sdd.leg = 1
					GROUP BY ' +	CASE 
										WHEN @frequency = 'm' THEN 'YEAR(sdd.term_start), MONTH(sdd.term_start)' 
										ELSE 'sdd.term_start' 
									END + '
					ORDER BY term_start							
			
					INSERT INTO #validate_sch_deal_vol_log(term_start, term_end, total_phy_volume, total_sch_volume, new_sch_volume, total_available_volume)
					SELECT MIN(tsd.term_start) 
						, MAX(tsd.term_start)
						, ROUND(MAX(ISNULL(pdv.deal_volume, 0)),' + CAST(@round_by AS CHAR(1)) + ') 
						, MAX(ISNULL(sdv.scheduled_deal_volume, 0)) 
						, SUM(tsd.scheduled_volume) 
						, ROUND(MAX(ISNULL(pdv.deal_volume, 0)) - MAX(ISNULL(scheduled_deal_volume, 0)) - SUM(tsd.scheduled_volume), ' + CAST(@round_by AS CHAR(1)) + ')   	
					FROM #volume_per_term tsd		
					LEFT JOIN #phy_deal_vol pdv 
						ON tsd.term_start  BETWEEN pdv.term_start AND pdv.term_end
					LEFT JOIN #scheduled_deal_vol sdv 
						ON sdv.term_start BETWEEN tsd.term_start AND tsd.term_end			
					GROUP BY ' +	CASE 
										WHEN @frequency = 'm' THEN 'YEAR(tsd.term_start), MONTH(tsd.term_start)' 
										ELSE 'tsd.term_start' 
									END
			
				--print 'Before deal cursor starts. ' +  ISNULL(@sql, ' sql is null')
				EXEC(@sql)			--Here table variable is used to prevent validation log from rollback transaction.
			
				SELECT @vol_to_be_sch = SUM(a.val) 
				FROM  (
					SELECT MAX(sdg.clm_scheduled_volume) [val]	,sdg.clm_schedule_no						 
					FROM #source_deals_gp sdg 
					GROUP BY sdg.clm_trans_id, sdg.clm_schedule_no 
				) a
				
				DECLARE @log_tbl TABLE(
					term_start					DATETIME,
					term_end					DATETIME,
					total_phy_volume			NUMERIC(38,20),
					total_sch_volume			NUMERIC(38,20),
					new_sch_volume				NUMERIC(38,20),
					total_available_volume		NUMERIC(38,20)	
				)
	
				IF EXISTS (
					SELECT 1		
					FROM #validate_sch_deal_vol_log
					WHERE  total_phy_volume - total_sch_volume - @vol_to_be_sch < 0
				)
				BEGIN				
					--print 'Before cursor - Insufficient volume'
					INSERT INTO @log_tbl (
						term_start,				
						term_end,				
						total_phy_volume,			
						total_sch_volume,	
						new_sch_volume,		
						total_available_volume
					)
					SELECT term_start,				
						term_end,				
						total_phy_volume,			
						total_sch_volume,	
						new_sch_volume,		
						total_available_volume
					FROM #validate_sch_deal_vol_log
					WHERE  total_available_volume < 0
											
					RAISERROR (N'Insufficient volume to be scheduled. Please change volume.', -- Message text.
						12, -- Severity,
						1, -- State
						''
					);
				END
				ELSE IF EXISTS (
					SELECT 1		
					FROM #validate_sch_deal_vol_log	
					WHERE  total_available_volume > 0
				) AND @isconfirm = 0
				BEGIN					
					--print 'Before cursor - Under scheduled volume'
					INSERT INTO @log_tbl (
						term_start,				
						term_end,				
						total_phy_volume,			
						total_sch_volume,	
						new_sch_volume,		
						total_available_volume
					)
					SELECT term_start,				
						term_end,				
						total_phy_volume,			
						total_sch_volume,	
						new_sch_volume,		
						total_available_volume
					FROM #validate_sch_deal_vol_log
					WHERE  total_available_volume > 0
				
					--to do changed for new fx
					declare @detail_exec_sp varchar(2000) = 'EXEC spa_view_validation_log ''' + @validate_table_name + ''',''' + @process_id + ''',''s'''
				
					RAISERROR (N'Scheduled volume is less than available volume.Do you want to proceed?<br><br/> %s', -- -- Message text word proceed decide for confirmation msg box.
						12, -- Severity,
						1, -- State
						''
					);
				END	
			
				--Volume validation before deal creating cursor starts ends here.					
		
				--Create schedule deal starts
				DECLARE @phy_deal_detail_id		INT, 
					@reschedule_deal_id			INT, 
					@withdraw_or_injection		CHAR(1),
					@clm_scheduled_volume		NUMERIC(38, 18),
					@clm_delivered_volume		NUMERIC(38, 18),					
					@clm_location_from			INT,
					@clm_location_to			INT,
					@storage_deal_volume		NUMERIC(38, 18),
					@storage_deal_location		INT,
					@storage_book_id			INT,
					@storage_counterparty_id	INT,
					@inserted_deal_id			INT,
					@withdrawal_deal_id			INT,
					@injection_deal_id			INT
					
				DECLARE deal_sch_cursor CURSOR LOCAL FOR			
					--IMP: sorting is very important here.
					SELECT sdg.row_no, 
						sdg.clm_path, 
						sdg.clm_book, 
						sdg.clm_term_start, 
						sdg.clm_term_end, 
						sdg.clm_schedule_no, 
						sdg.clm_primary_path_id, 
						sdvu.clm_source_deal_header_id,
						sdg.clm_withdraw_or_injection,
						sdg.clm_scheduled_volume,
						sdg.clm_delivered_volume,
						sdg.clm_location_from, 
						sdg.clm_location_to

					FROM #source_deals_gp sdg
						LEFT JOIN #source_deals_vol_update sdvu 
							ON sdvu.clm_row_no = sdg.row_no
					ORDER BY sdg.clm_schedule_no, 
							sdg.clm_primary_path_id, 
							sdg.clm_path_detail_id, 
							sdg.row_no
				
				OPEN deal_sch_cursor
				FETCH NEXT FROM deal_sch_cursor INTO @row, @path_id, @book_id, @term_start, @term_end, @row_sch, @group_path_id, @reschedule_deal_id, @withdraw_or_injection, @clm_scheduled_volume, @clm_delivered_volume, @clm_location_from, @clm_location_to 
				WHILE @@FETCH_STATUS = 0   
				BEGIN 
					TRUNCATE TABLE #inserted_deals
					TRUNCATE TABLE #inserted_deal_detail
					TRUNCATE TABLE #inserted_deal_detail2
					TRUNCATE TABLE #inserted_dth 				
				
					SELECT @phy_deal_detail_id = source_deal_detail_id 
					FROM source_deal_detail
					WHERE source_deal_header_id = @source_deal_header_id
						AND term_start = @term_start 
						AND term_end = @term_end

					IF (@row_sch <> @prev_row_sch)
					BEGIN
						SET @new_schedule = 1
					END
					ELSE 
					BEGIN
						SELECT @new_schedule = CASE COUNT(1) WHEN 0 THEN 1 ELSE 0 END 
						FROM #source_deals_gp sdg 
						WHERE sdg.row_no = @row AND sdg.clm_schedule_no = @prev_row_sch 
							AND (sdg.clm_path = @prev_path_id OR  sdg.clm_location_from = @prev_location_to)
					END
				
					SELECT @template_type_id = CASE sdg.clm_is_mr WHEN 'y' THEN 5 ELSE 1 END FROM #source_deals_gp sdg WHERE sdg.row_no = @row
					--Do deal volume validation only for new schedule id
				
					IF @new_schedule = 1
					BEGIN
						--clear table on every user input grid row (schedule id)				
						TRUNCATE TABLE #inserted_deal_scheduled		
					END	
						
					--use phy deal book if not defined.
					SELECT  @book_map1	= source_system_book_id1
						,@book_map2		= source_system_book_id2
						,@book_map3		= source_system_book_id3
						,@book_map4		= source_system_book_id4
					FROM source_system_book_map 
					WHERE book_deal_type_map_id = @book_id
				
					SELECT @desc1 = description1  
					FROM source_deal_header 
					WHERE source_deal_header_id = @source_deal_header_id

					SELECT @transport_desc2 = description2 
					FROM source_deal_header_template 
					WHERE template_name = 'Transportation NG'

					DECLARE @max_source_deal_detail_id INT

					SELECT @max_source_deal_detail_id = MAX(source_deal_detail_id) 
					FROM source_deal_detail
					WHERE source_deal_header_id = @source_deal_header_id

					SELECT @desc2 = COALESCE(sdv.code, sdh.description2, @transport_desc2) 
					FROM source_deal_header sdh
					INNER JOIN source_deal_detail sdd
						ON sdh.source_deal_header_id = sdd.source_deal_header_id
					INNER JOIN user_defined_deal_detail_fields udddf
						ON udddf.source_deal_detail_id = sdd.source_deal_detail_id
					INNER JOIN user_defined_deal_fields_template uddft
						ON udddf.udf_template_id = uddft.udf_template_id
					INNER JOIN user_defined_fields_template udft
						ON uddft.field_id = udft.field_id
						AND udft.field_label = 'priority'
					LEFT JOIN static_data_value sdv
						ON sdv.value_id = udddf.udf_value
					WHERE sdd.source_deal_detail_id = ISNULL(@source_deal_detail_id, @max_source_deal_detail_id)

					INSERT INTO source_deal_header (
						[source_system_id]
						, [deal_id]
						, [deal_date]
						, [physical_financial_flag]
						, [counterparty_id]
						, [entire_term_start]
						, [entire_term_end]
						, [source_deal_type_id]
						, [deal_sub_type_type_id]
						, [option_flag]
						, [option_type]					  		   
						, [source_system_book_id1]
						, [source_system_book_id2]
						, [source_system_book_id3]
						, [source_system_book_id4]
						, [deal_category_value_id]
						, [trader_id]
						, [header_buy_sell_flag]					  
						, create_user
						, create_ts
						, template_id
						, term_frequency
						, contract_id
						, confirm_status_type
						, deal_status
						, commodity_id
						, description1
						, description2	
						, sub_book					
					)
					OUTPUT INSERTED.source_deal_header_id, INSERTED.entire_term_start, INSERTED.entire_term_end , INSERTED.[deal_sub_type_type_id],INSERTED.source_deal_type_id
					INTO #inserted_deals 
					SELECT 2
						, @process_id + '_' + CAST(row_no AS VARCHAR) + '_' +  CONVERT(VARCHAR,@term_start, 12)
						, @term_start			
						, t.physical_financial_flag
						, p.counterparty
						, @term_start    
						, @term_end  
						, t.deal_type_id
						, t.[deal_sub_type_id]
						, t.option_flag
						, t.option_type
						, COALESCE (@gen_mapping_id1, @book_map1,@map1)
						, COALESCE (@gen_mapping_id2, @book_map2,@map2)
						, COALESCE (@gen_mapping_id3, @book_map3,@map3)
						, COALESCE (@gen_mapping_id4, @book_map4,@map4)		
						, 475 --a.deal_category_value_id
						, a.clm_trader
						, t.header_buy_sell_flag				
						, dbo.FNADBUser()
						, GETDATE()
						, t.template_id
						, @frequency		--'d'
						--, p.[CONTRACT] 
						, a.clm_contract
						, @confirm_status_new
						, @deal_status_new
						, ISNULL(p.commodity, t.commodity_id)
						, @desc1
						, @desc2
						, ssbm.book_deal_type_map_id
					FROM #template_details t
					INNER JOIN #source_deals_gp a  
						ON 1 = 1 AND a.row_no = @row
					INNER JOIN delivery_path p  
						ON p.path_id = a.clm_path 
					LEFT JOIN source_system_book_map ssbm
						ON ssbm.source_system_book_id1 = COALESCE (@gen_mapping_id1, @book_map1, @map1)
							AND	ssbm.source_system_book_id2 = COALESCE (@gen_mapping_id2, @book_map2, @map2)
							AND	ssbm.source_system_book_id3 = COALESCE (@gen_mapping_id3, @book_map3, @map3)
							AND	ssbm.source_system_book_id4 = COALESCE (@gen_mapping_id4, @book_map4, @map4)
				
					WHERE t.template_type_id = @template_type_id 
					--CROSS JOIN dbo.FNATermBreakdown(@frequency, @term_start, @term_end) fb

					SELECT @from_curve	= term_pricing_index,
						@from_location	= p.from_location,
						@to_location	= p.to_location 
					FROM source_minor_location s
					INNER JOIN delivery_path p  ON p.from_location =  s.source_minor_location_id
					AND p.path_id = @path_id
						
					INSERT INTO [dbo].[deal_transport_header]([source_deal_header_id]) 
					OUTPUT INSERTED.deal_transport_id, INSERTED.source_deal_header_id 
					INTO #inserted_dth
					SELECT source_deal_header_id FROM #inserted_deals
							
					IF @new_schedule = 1
					BEGIN				
						INSERT INTO [dbo].[deal_schedule](path_id, term_start, term_end, scheduled_volume, delivered_volume) 
						OUTPUT INSERTED.deal_schedule_id, INSERTED.path_id 
						INTO #inserted_deal_scheduled
						SELECT MAX(sdg.clm_primary_path_id)
							, MIN(sdg.clm_term_start)
							, MAX(sdg.clm_term_end)
							, MAX(sdg.clm_scheduled_volume)
							, MAX(sdg.clm_delivered_volume)  
						FROM #source_deals_gp sdg  
						WHERE sdg.clm_schedule_no = @row_sch AND sdg.clm_primary_path_id = @group_path_id AND sdg.clm_path = @path_id --sdg.row_no = @row
					END	
			
					/*Update deal reference prefix. 'SCHD_' for transportation deal*/	
					UPDATE sdh
					SET deal_id = ISNULL(td.deal_prefix, 'FARRMS_') + CAST(sdh.source_deal_header_id  AS VARCHAR(100))  
					FROM source_deal_header sdh
					INNER JOIN #inserted_dth idth 
						ON idth.source_deal_header_id = sdh.source_deal_header_id 
					INNER JOIN #template_details td 
						ON td.template_id = sdh.template_id

					/* START OF CHECK PATH AND CONTRACT MDQ VIOLATON */
					DECLARE  @contract_id INT, @flow_date DATETIME, @scheduled_volume NUMERIC(38, 20), @avail_schedule_volume NUMERIC(38, 20)
				
					SELECT @path_id			= clm_path, 
						@contract_id		= clm_contract, 
						@flow_date			= clm_term_start,
						@scheduled_volume	= clm_scheduled_volume
					FROM #source_deals_gp
					WHERE row_no = @row
				
					DECLARE @mdq_rmdq VARCHAR(200)
				
					EXEC [spa_check_mdq_volume] 'PATH', @flow_date, @path_id, @contract_id , @avail_schedule_volume OUTPUT, @mdq_rmdq OUTPUT
	
					IF ROUND(@scheduled_volume, 0) > ROUND(@avail_schedule_volume, 0) AND @isconfirm = 0
					BEGIN	
						SET @err_msg = 'Schedule volume is greater than Path MDQ.<br>Do you want to continue ?'

						RAISERROR (@err_msg, -- -- Message text word proceed decide for confirmation msg box.
							12, -- Severity,
							1, -- State
							''
						);
					END

					EXEC [spa_check_mdq_volume] 'CONTRACT',  @flow_date, @path_id, @contract_id , @avail_schedule_volume OUTPUT, @mdq_rmdq OUTPUT
	
					IF ROUND(@scheduled_volume, 0) > ROUND(@avail_schedule_volume, 0) AND @isconfirm = 0
					BEGIN	
						SET @err_msg = 'Contract MDQ exceed.<br>Do you want to continue ?'
					
						RAISERROR (@err_msg, -- -- Message text word proceed decide for confirmation msg box.
							12, -- Severity,
							1, -- State
							''	
						);				
					END
					/* END OF CHECK PATH AND CONTRACT MDQ VIOLATON */
				
					SET @sql = '
						INSERT INTO [dbo].[source_deal_detail] (
							[source_deal_header_id]
							,[term_start]
							,[term_end]
							,[Leg]
							,[contract_expiration_date]
							,[fixed_float_leg]
							,[buy_sell_flag]
							,[curve_id]
							,[fixed_price]
							,[fixed_price_currency_id]
							,[deal_volume]
							,[deal_volume_frequency]
							,[deal_volume_uom_id]
							,[block_description]
							,[volume_left]
							,[create_user]
							,[create_ts]
							,[update_user]
							,[update_ts]
							,[location_id]
							,[physical_financial_flag]
							,[pay_opposite]
							,[meter_id]
						)
						OUTPUT INSERTED.source_deal_header_id, INSERTED.source_deal_detail_id ,INSERTED.deal_volume  
						INTO #inserted_deal_detail 
						SELECT 
							id.source_deal_header_id
							, '  
							+	CASE @single_deal_multiple_term 
									WHEN 1 THEN 'fb.term_start, fb.term_end' 
									ELSE 'id.term_start, id.term_end' 
								END				
							+ '
							, td.leg
							, '  
							+	CASE @single_deal_multiple_term 
									WHEN 1 THEN 'fb.term_end' 
									ELSE 'id.term_end' 
								END				
							+ '					
							, td.fixed_float_leg
							, ''s''
							, '
							+	CASE 
									WHEN @from_curve IS NULL THEN 'td.curve_id' 
									ELSE '' + @from_curve + '' 
						 		END +
							'					
							, NULL
							, td.fixed_price_currency_id
							, ROUND(ABS(a.clm_scheduled_volume), ' + CAST(@round_by AS CHAR(1)) + ')
							, ''' + @frequency + '''
							, td.[deal_volume_uom_id] 
							, td.block_description
							, ABS(a.clm_scheduled_volume)
							, dbo.fnadbuser()
							, GETDATE()
							, dbo.fnadbuser()
							, GETDATE()
							, a.clm_location_from 
							, ''p''
							, ''n''
							, dp.meter_from
						FROM [dbo].[source_deal_detail_template] td 
						INNER JOIN #template_details t ON td.template_id = t.template_id AND td.leg = 1	AND t.template_type_id = ' + CAST(@template_type_id AS VARCHAR) + ' 		
						LEFT JOIN #source_deals_gp a  ON 1 = 1 AND a.row_no = ' + CAST(@row AS VARCHAR) + '
						LEFT JOIN delivery_path dp ON dp.path_id = a.clm_path 
						CROSS JOIN #inserted_deals id  '
						+	CASE @single_deal_multiple_term 
								WHEN 1 THEN 'CROSS JOIN dbo.FNATermBreakdown(''' + @frequency + ''', ''' + CONVERT(VARCHAR, @term_start, 120) + ''', ''' + CONVERT(VARCHAR, @term_end, 120) + ''') fb'
								ELSE '' 
							END	
						
					EXEC(@sql)
					--print 'Leg 1 sdd data inserted.'
				
					INSERT INTO dbo.deal_transport_detail (deal_transport_id,source_deal_detail_id_from,source_deal_detail_id_to,volume)
					SELECT dth.deal_transport_id	
						,idd.source_deal_detail_id	
						,idd.source_deal_detail_id
						,-1 * ABS(idd.deal_volume)  
					FROM  #inserted_deal_detail idd
					INNER JOIN deal_transport_header dth 
						ON idd.source_deal_header_id = dth.source_deal_header_id
				
					SELECT @to_curve = term_pricing_index 
					FROM source_minor_location s
						INNER JOIN delivery_path dp  
							ON dp.to_location =  s.source_minor_location_id
								AND dp.path_id = @path_id	

					SET @sql = '
						INSERT INTO [dbo].[source_deal_detail] (
							[source_deal_header_id]
							, [term_start]
							, [term_end]
							, [Leg]
							, [contract_expiration_date]
							, [fixed_float_leg]
							, [buy_sell_flag]
							, [curve_id]
							, [fixed_price]
							, [fixed_price_currency_id]
							, [deal_volume]
							, [deal_volume_frequency]
							, [deal_volume_uom_id]
							, [block_description]
							, [volume_left]
							, [create_user]
							, [create_ts]
							, [update_user]
							, [update_ts]
							, [location_id]
							, [physical_financial_flag]
							, [pay_opposite]
							, [meter_id]
						)
						OUTPUT INSERTED.source_deal_header_id, INSERTED.source_deal_detail_id ,INSERTED.deal_volume  
						INTO #inserted_deal_detail2
						SELECT 
							id.source_deal_header_id	
							, '  
							+	CASE @single_deal_multiple_term 
									WHEN 1 THEN 'fb.term_start, fb.term_end' 
									ELSE 'id.term_start, id.term_end' 
								END				
							+ '
							, td.leg
							, '  
							+	CASE @single_deal_multiple_term 
									WHEN 1 THEN 'fb.term_end' 
									ELSE 'id.term_end' 
								END				
							+ '					
							, td.fixed_float_leg
							, ''b''
							, '
							+	CASE 
									WHEN @to_curve IS NULL THEN 'td.curve_id' 
									ELSE '' + @to_curve + '' 
						 		END +
							'	
							, NULL 
							, td.fixed_price_currency_id
							--, ABS(a.clm_scheduled_volume * (1 - ISNULL(CAST(dp.loss_factor AS NUMERIC(38,20)), 0))) 
							, ROUND(ABS(a.clm_scheduled_volume * (1 - a.clm_loss_factor)), ' + CAST(@round_by AS CHAR(1)) + ')  
							, ''' + @frequency + '''
							, td.[deal_volume_uom_id]
							, td.block_description
							--, ABS(a.clm_scheduled_volume * (1 - ISNULL(CAST(dp.loss_factor AS NUMERIC(38,20)), 0))) 
							, ABS(a.clm_scheduled_volume * (1 - a.clm_loss_factor))
							, dbo.fnadbuser()
							, GETDATE()
							, dbo.fnadbuser()
							, GETDATE()
							, a.clm_location_to
							, ''p''
							, ''n''
							, dp.meter_to
						FROM [dbo].[source_deal_detail_template] td 
						INNER JOIN 	#template_details t  ON td.template_id = t.template_id AND td.leg = 2 AND t.template_type_id = ' + CAST(@template_type_id AS VARCHAR) + '
						LEFT JOIN #source_deals_gp a  ON 1 = 1 AND a.row_no = ' + CAST(@row AS VARCHAR)	+ '
						LEFT JOIN delivery_path dp ON dp.path_id = a.clm_path	
						CROSS JOIN #inserted_deals id '
						+	CASE @single_deal_multiple_term 
								WHEN 1 THEN 'CROSS JOIN dbo.FNATermBreakdown(''' + @frequency + ''', ''' + CONVERT(VARCHAR, @term_start, 120) + ''', ''' + CONVERT(VARCHAR, @term_end, 120) + ''') fb'
								ELSE '' 
							END

					EXEC(@sql)
		
					--Set delivered volume.
				
					SELECT  @prev_location_to	= a.clm_location_to,
						@prev_primary_path_id	= a.clm_primary_path_id,
						@prev_path_id			= a.clm_path
					FROM #source_deals_gp a
					WHERE a.row_no = @row	
				 
					SELECT @prev_delivered_volume = MAX(sdd.deal_volume) 
					FROM #inserted_deal_detail2 idd 
					INNER JOIN source_deal_detail sdd 
						ON sdd.source_deal_header_id = idd.source_deal_header_id 
							AND leg = 2
				
					--Update volume to be scheduled for next path defined in given group path.
				
					UPDATE sdg 
					SET sdg.clm_scheduled_volume	= sdg1.clm_delivered_volume
						, sdg.clm_delivered_volume	= sdg1.clm_delivered_volume * (1 - sdg.clm_loss_factor)
					FROM #source_deals_gp sdg 
					INNER JOIN (
						SELECT TOP 1 rs_next.row_no, rs.clm_delivered_volume
						FROM #source_deals_gp rs_next
						LEFT JOIN  #source_deals_gp rs 
							ON  rs.row_no = @row 
						WHERE rs.clm_term_start = rs_next.clm_term_start
							AND rs.clm_term_end = rs_next.clm_term_end 
							AND rs_next.clm_path_detail_id > rs.clm_path_detail_id
							AND rs.clm_location_to = rs_next.clm_location_from
							AND rs_next.clm_schedule_no = @row_sch 
					) sdg1 
						ON sdg1.row_no = sdg.row_no

					--update [deal_schedule].delivered_volume for group path. Case A to B, B to C
					IF @new_schedule = 0
					BEGIN
						UPDATE ds 
						SET ds.delivered_volume = @prev_delivered_volume
						FROM #inserted_deal_scheduled ids
						INNER JOIN deal_schedule ds 
							ON ds.deal_schedule_id = ids.deal_schedule_id
								AND ds.path_id = ids.path_id
						INNER JOIN #source_deals_gp sdg 
							ON sdg.row_no = @row 
								AND ds.path_id = sdg.clm_primary_path_id
					END
				
					INSERT INTO dbo.deal_transport_detail (deal_transport_id,source_deal_detail_id_from,source_deal_detail_id_to,volume)
					SELECT dth.deal_transport_id	
						,idd.source_deal_detail_id	
						,idd.source_deal_detail_id	
						,-1*ABS(idd.deal_volume)  
					FROM 
					#inserted_deal_detail2 idd 
					INNER JOIN deal_transport_header dth 
						ON idd.source_deal_header_id = dth.source_deal_header_id 
				
					/**********************End  leg2******************************************************/

					

					/**********************insert into *[user_defined_deal_fields]*****************************************************/

					--print @del_counterparty_value_id
					--print @rec_counterparty_value_id
					/*
					* ---5605 value for Rescheduled From udf field. Holds deal_schedule_id of deal_schedule table.
					* ---5606 value for Path Detail ID udf field.
					* ---5607 value for Scheduled ID udf field.
					* -- -5614 value for Loss UDF field.
					* Delivery path udf field holds simple path id (both group path and simple path)
					*/			

					INSERT INTO [dbo].[user_defined_deal_fields] (
						[source_deal_header_id]
						,[udf_template_id]
						,[udf_value]
						,[create_user]
						,[create_ts]
					)
					SELECT id.source_deal_header_id 
						, udf.udf_template_id,
						CASE udf.field_id
								WHEN @del_counterparty_value_id THEN a.clm_counterparty_delivered
								WHEN @rec_counterparty_value_id THEN a.clm_counterparty_receive
								WHEN @from_deal_value_id THEN @source_deal_header_id
								WHEN @from_deal_detail_value_id THEN @phy_deal_detail_id
								WHEN @delivery_path_id THEN a.clm_path 
								WHEN -5605 THEN CASE a.clm_trans_id WHEN 0 THEN NULL ELSE a.clm_trans_id END --trans_id instead of deal id
								WHEN -5606 THEN a.clm_path_detail_id
								WHEN -5607 THEN ids.deal_schedule_id
								WHEN -5614 THEN a.clm_loss_factor
								ELSE trs.rate
						END
						,dbo.fnadbuser()
						,GETDATE()
					FROM [dbo].[user_defined_deal_fields_template] udf 				 
					INNER JOIN #template_details td 
						ON td.template_id = udf.template_id 
							AND td.template_type_id = @template_type_id
					LEFT JOIN #source_deals_gp a  
						ON 1 = 1 
							AND a.row_no = @row
					LEFT JOIN #inserted_deal_scheduled ids 
						ON ids.path_id = a.clm_primary_path_id	
					INNER JOIN delivery_path dp  
						ON dp.path_id = a.clm_path
					LEFT JOIN transportation_rate_schedule trs 
						ON udf.field_name = trs.rate_type_id 
							AND trs.rate_schedule_id = dp.rateSchedule
					CROSS JOIN #inserted_deals id 
				
					--Insert UDF details
						--leg1
					INSERT INTO user_defined_deal_detail_fields (
						-- udf_deal_id -- this column value is auto-generated
						source_deal_detail_id,
						udf_template_id,
						udf_value
					)
					SELECT idd.source_deal_detail_id
						, uddft.udf_template_id
						, uddft.default_value
					FROM #inserted_deal_detail idd
					INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = idd.source_deal_header_id
					INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id = sdh.template_id
					WHERE uddft.udf_type = 'd'
						AND uddft.leg = 1						
					UNION
					SELECT idd.source_deal_detail_id
						, uddft.udf_template_id
						, uddft.default_value
					FROM #inserted_deal_detail2 idd
					INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = idd.source_deal_header_id
					INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id = sdh.template_id
					WHERE uddft.udf_type = 'd'
						AND uddft.leg = 2
						
					INSERT INTO #inserted_deals_final SELECT * FROM #inserted_deals
							
					SET @prev_row_sch = @row_sch

					SET @optimizer_header = IDENT_CURRENT('source_deal_header')
				
					IF @flag = 'i' 
					BEGIN
						SET @reschedule_deal_id = NULL
					END
				
					SELECT @storage_book_id = book_deal_type_map_id 
					FROM source_system_book_map ssbm
					WHERE ssbm.source_system_book_id1 = COALESCE (@gen_mapping_id1, @book_map1, @map1)
						AND	ssbm.source_system_book_id2 = COALESCE (@gen_mapping_id2, @book_map2, @map2)
						AND	ssbm.source_system_book_id3 = COALESCE (@gen_mapping_id3, @book_map3, @map3)
						AND	ssbm.source_system_book_id4 = COALESCE (@gen_mapping_id4, @book_map4, @map4)

				
					SET @inserted_deal_id = NULL
					SET @injection_deal_id = NULL
					SET @withdrawal_deal_id = NULL

					IF @withdraw_or_injection IS NOT NULL
					BEGIN
						IF @withdraw_or_injection = 'i' 
						BEGIN
							SET @storage_deal_volume = @clm_delivered_volume
							SET @storage_deal_location = @clm_location_to
						END
						ELSE
						BEGIN
							SET @storage_deal_volume = @clm_scheduled_volume
							SET @storage_deal_location = @clm_location_from
						END

						SELECT @storage_counterparty_id = counterparty 
						FROM delivery_path 
						WHERE path_id = @path_id					

						--select  @withdraw_or_injection, @storage_book_id, @storage_deal_volume, @term_start, @storage_deal_location, @storage_contract_id, @storage_counterparty_id
				

						--select @withdraw_or_injection, @storage_book_id, @storage_deal_volume, @term_start, @storage_deal_location, @storage_contract_id, @storage_counterparty_id
					
					

						EXEC [spa_withdrawal_injection_deal] @withdraw_or_injection, @storage_book_id, @storage_deal_volume, @term_start, @storage_deal_location, @storage_contract_id, @storage_counterparty_id, @inserted_deal_id OUTPUT
				
				
						IF @withdraw_or_injection = 'i' 
						BEGIN
							SET @injection_deal_id = @inserted_deal_id
						END
						ELSE
						BEGIN
							SET @withdrawal_deal_id = @inserted_deal_id
						END	
					END
				
					EXEC spa_optimizer_deals @flag = 'h', @source_deal_header_id = @optimizer_header, @from_detail_id = @source_deal_detail_id, @reschedule_deal_id = @reschedule_deal_id, @injection_deal_id = @injection_deal_id, @withdrawal_deal_id = @withdrawal_deal_id
				
					FETCH NEXT FROM deal_sch_cursor INTO @row, @path_id, @book_id, @term_start, @term_end, @row_sch, @group_path_id, @reschedule_deal_id, @withdraw_or_injection, @clm_scheduled_volume, @clm_delivered_volume, @clm_location_from, @clm_location_to  
 				END
				CLOSE deal_sch_cursor
				DEALLOCATE  deal_sch_cursor
			
				--TODO Why this update code needed?
				UPDATE source_deal_header SET deal_id = CAST(source_deal_header_id AS VARCHAR)+ '_farrms' WHERE deal_id LIKE @process_id+'%'

				INSERT INTO  delivery_status (  
					deal_transport_id,
					estimated_delivery_date,
					status_timestamp,
					delivered_volume,
					deal_transport_detail_id,
					uom_id,
					source_deal_detail_id,
					location_id,
					meter_id,
					pipeline_id,
					contract_id,
					receive_delivery,
					delivery_status
				)
				SELECT dth.deal_transport_id,  
						sdd.term_start,  
						sdd.term_start,   
						ROUND(ABS(sdd.deal_volume), @round_by), 
						dtd.deal_transport_deatail_id,
						sdd.deal_volume_uom_id,  
						sdd.source_deal_detail_id,  
						sdd.location_id,  
						smlm.meter_id,  
						sdh1.counterparty_id,  
						sdh1.contract_id,  
						CASE WHEN sdd.Leg=1 THEN 'r' ELSE 'd' END  reciept_delivery,
						1650
				FROM #inserted_deals_final sdh 
				INNER JOIN #template_details td ON td.deal_type_id = sdh.source_deal_type_id 
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id 
				INNER JOIN source_deal_header sdh1 ON sdh1.source_deal_header_id = sdh.source_deal_header_id
				INNER JOIN deal_transport_header dth ON sdd.source_deal_header_id = dth.source_deal_header_id  
				INNER JOIN deal_transport_detail dtd ON dtd.deal_transport_id = dth.deal_transport_id  
					AND dtd.source_deal_detail_id_from =  sdd.source_deal_detail_id  
				LEFT JOIN source_minor_location_meter smlm ON smlm.source_minor_location_id = sdd.location_id

				DECLARE @report_position_deals	VARCHAR(300),
					@spa						VARCHAR(MAX),
					@job_name					VARCHAR(MAX),
					@spa_resch_vol_update		VARCHAR(MAX) = '',
					@deal_ids					VARCHAR(MAX)
			
				--Deal audit logic for insert deals starts
				SELECT @deal_ids = STUFF((SELECT ','+ CAST(sdh.source_deal_header_id  AS VARCHAR)  
										  FROM #inserted_deals_final sdh ORDER BY  sdh.source_deal_header_id  FOR XML PATH ('')), 1, 1, '')
			
				----- call compliance work flow	for inserted deals
				EXEC dbo.spa_callDealConfirmationRule @deal_ids, 19501, NULL, NULL
						
				EXEC spa_insert_update_audit 'i', @deal_ids
				--Deal audit logic for insert deals starts
			
				SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id, @process_id)
				EXEC ('CREATE TABLE ' + @report_position_deals + '( source_deal_header_id INT, action CHAR(1))')
		
				IF @flag = 'r'
				BEGIN
					--Deal audit logic for update deals starts
					SELECT @deal_ids = STUFF((SELECT ','+ CAST(sdh.source_deal_header_id  AS VARCHAR)  
											  FROM #total_resch_deals sdh ORDER BY  sdh.source_deal_header_id  FOR XML PATH ('')), 1, 1, '')
				
					EXEC spa_insert_update_audit 'u', @deal_ids
					--Deal audit logic for update deals ends
				
					SET @spa_resch_vol_update = ' UNION 
											SELECT source_deal_header_id, ''i''  
											FROM #total_resch_deals'
				END
					
				SET @sql = 'INSERT INTO ' + @report_position_deals + '(source_deal_header_id,action) 
							SELECT source_deal_header_id,''i''  from #inserted_deals_final					
							' + @spa_resch_vol_update
				EXEC (@sql) 
			
				SELECT @temp_source_deal_header_id = @temp_source_deal_header_id + STUFF((SELECT ','+ CAST(sdh.source_deal_header_id  AS VARCHAR)  FROM #inserted_deals_final sdh ORDER BY  sdh.source_deal_header_id  FOR XML PATH ('')), 1, 1, '')
			
				SET @spa = 'spa_update_deal_total_volume NULL,''' + CAST(@process_id AS VARCHAR(200)) + '''' 
				SET @job_name = 'spa_update_deal_total_volume_' + @process_id 
				EXEC spa_run_sp_as_job @job_name, @spa, 'spa_update_deal_total_volume', @user_login_id
			
				EXEC spa_ErrorHandler 0, 'Transportation', 
							'spa_schedule_n_delivery', 'Success',
							'Successfully saved transportation deal.', @temp_source_deal_header_id
			--ROLLBACK
			COMMIT
		END TRY
		BEGIN CATCH
			DECLARE @err_no INT
			--print 'Catch Error:' + ERROR_MESSAGE()	
			
			IF @@TRANCOUNT > 0 
				ROLLBACK
			
			
			/* Table variable cannot be used in dynamic sql statement. 
				So temp table #error_log is used  to dump data from table variable into process table.
			*/
			IF OBJECT_ID(N'tempdb..#error_log') IS NOT NULL DROP TABLE #error_log
			
			SELECT dbo.FNADateformat(term_start) [Term]
				, dbo.FNARemoveTrailingZeroes(ROUND((total_phy_volume-total_sch_volume), @round_by)) [Available Volume]
				, dbo.FNARemoveTrailingZeroes(ROUND(new_sch_volume, @round_by)) [Schedule Volume] 
				, CASE WHEN total_available_volume < 0 THEN 'Insufficient Volume.'
					 WHEN total_available_volume > 0 THEN 'Under Scheduled.'
					 ELSE ''
				  END Remarks				  
			INTO #error_log
			FROM @log_tbl	
			WHERE total_available_volume <> 0
				
			SET @sql = 'select * into ' + @validate_sch_deal_vol_log + ' from  #error_log'
			EXEC(@sql)
			--print @sql
			--EXEC('select * from ' +@validate_sch_deal_vol_log)

			IF CURSOR_STATUS('local', 'deal_sch_cursor') >= 0 
			BEGIN
				CLOSE deal_sch_cursor
				DEALLOCATE deal_sch_cursor;
			END
			
			IF CURSOR_STATUS('local', 'cur_resch_deal') >= 0 
			BEGIN
				CLOSE cur_resch_deal
				DEALLOCATE cur_resch_deal;
			END
		
			SELECT @err_no = ERROR_NUMBER()
			
			IF @err_no = 50000	--thrown by RAISE statement
			BEGIN
				SET @err_msg = ERROR_MESSAGE()
				EXEC spa_ErrorHandler @err_no, 'Transportation', 
						'spa_schedule_n_delivery', 'Error', @err_msg, @err_msg
			END
			ELSE
			BEGIN
				EXEC spa_ErrorHandler @err_no, 'Transportation', 
						'spa_schedule_n_delivery', 'Error',
						'Fail to save transportation deal.',@err_msg	
			END
			
		END CATCH --*/
	END
	/*****************End of 'i' or 'r' flag****/
END
ELSE IF @flag = 'd'
BEGIN
	DECLARE @sch_deal_ids VARCHAR(MAX)
	SELECT * INTO  #tmp_source_deal_header_id FROM  SplitCommaSeperatedValues(@trans_id)
	
	SELECT @sch_deal_ids = STUFF((SELECT ',' + CAST(uddf_resch.source_deal_header_id AS VARCHAR(10))
						FROM [user_defined_deal_fields_template] uddft
						INNER JOIN #template_details td ON td.template_id = uddft.template_id
						--INNER JOIN [default_deal_post_values] d ON uddft.[template_id] = d.[template_id] 
						--INNER JOIN internal_deal_type_subtype_types i
						--	ON i.[internal_deal_type_subtype_id] = d.[internal_deal_type_subtype_id]
						--	AND i.internal_deal_type_subtype_type = @internal_deal_subtype_value_id
						INNER JOIN  user_defined_deal_fields uddf_resch WITH (NOLOCK) ON uddf_resch.udf_template_id = uddft.udf_template_id 
							AND uddft.field_name = -5607	--Scheduled ID UDF field
						INNER JOIN #tmp_source_deal_header_id temp_deals ON temp_deals.item = uddf_resch.udf_value
						 FOR XML PATH('')
						), 1, 1, '') 	
	--print @sch_deal_ids
	
	IF @sch_deal_ids IS NOT NULL
	BEGIN
		EXEC spa_sourcedealheader
				 'd'
				, NULL
				, NULL
				, NULL
				, NULL
				, NULL
				, @sch_deal_ids
	END
	ELSE
	BEGIN
		--print 'No deals to delete.'
		EXEC spa_ErrorHandler
			1,
			'Source Deal Header',
			'spa_sourcedealheader',
			'DB Error',
			'No deals to delete.',
			'' 
	END
END