 
IF OBJECT_ID(N'[dbo].[spa_get_loss_factor_volume]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].spa_get_loss_factor_volume
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	Deal template privileges

	Parameters 
		@flag : Flag
		@path : Path
		@rate_type_id : Rate Type Id
		@volume : Volume
		@option : Option
		@term_start : Term Start
		@term_end : Term End
		@schedule_volume : Schedule Volume
		@deliver_volume : Deliver Volume
		@process_id : Process Id
		@source_deal_detail_id : Source Deal Detail Id
		@row : Row
		@source_deal_header_id : Source Deal Header Id
		@trans_id : Trans Id
		@contract : Contract
		@minor_location : Minor Location
		@receipt_deal_ids : Receipt Deal Ids
		@granularity : Granularity
		@period_from : Period From
		@call_from : Call From
		@delivery_deal_ids : Delivery Deal Ids
		@del_location : Del Location
		@uom : Uom

*/


CREATE PROCEDURE [dbo].[spa_get_loss_factor_volume]  
	@flag      CHAR(1) = NULL, -- 'd' call FROM deal schedule  
	@path      INT,  
	@rate_type_id    INT = NULL,  
	@volume      FLOAT = NULL,  
	@option      VARCHAR(10) = NULL,  
	@term_start     VARCHAR(25) = NULL, --yyyy-mm-dd  
	@term_end     VARCHAR(25) = NULL, --yyyy-mm-dd  
	@schedule_volume   FLOAT = NULL,  
	@deliver_volume    FLOAT = NULL,  
	@process_id     VARCHAR(100) = NULL,  
	@source_deal_detail_id  INT = NULL,  
	@row      VARCHAR(200) = NULL,  
	@source_deal_header_id  INT = NULL,  
	@trans_id     INT = NULL,  
	@contract     INT = NULL,  
	@minor_location    VARCHAR(100) = NULL,  
	@receipt_deal_ids   VARCHAR(1000)= NULL,  
	@granularity    INT = NULL,  
	@period_from    VARCHAR(1000) = NULL,  
	@call_from     VARCHAR(100) = NULL,  
	@delivery_deal_ids   VARCHAR(1000)= NULL,  
	@del_location    VARCHAR(100) = NULL,
	@uom int = null 
AS  
SET NOCOUNT ON  

/*  
--EXEC spa_get_loss_factor_volume @flag='q',@path='1310',@trans_id='3365',@source_deal_header_id='37690',@schedule_volume='50'  
	declare @flag      CHAR(1) = NULL, -- 'd' call FROM deal schedule  
	@path      INT,  
	@rate_type_id    INT = NULL,  
	@volume      FLOAT = NULL,  
	@option      VARCHAR(10) = NULL,  
	@term_start     VARCHAR(25) = NULL, --yyyy-mm-dd  
	@term_end     VARCHAR(25) = NULL, --yyyy-mm-dd  
	@schedule_volume   FLOAT = NULL,  
	@deliver_volume    FLOAT = NULL,  
	@process_id     VARCHAR(100) = NULL,  
	@source_deal_detail_id  INT = NULL,  
	@row      VARCHAR(200) = NULL,  
	@source_deal_header_id  INT = NULL,  
	@trans_id     INT = NULL,  
	@contract     INT = NULL,  
	@minor_location    VARCHAR(100) = NULL,  
	@receipt_deal_ids   VARCHAR(1000)= NULL,  
	@granularity    INT = NULL,  
	@period_from    VARCHAR(1000) = NULL,  
	@call_from     VARCHAR(100) = NULL,  
	@delivery_deal_ids   VARCHAR(1000)= NULL,  
	@del_location    VARCHAR(100) = NULL,
	@uom int = null 

	EXEC spa_drop_all_temp_table

			--SELECT @flag='m',@path='1604',@term_start='2018-05-01',@term_end='2018-05-31',@receipt_deal_ids='59848,59851,59853',@delivery_deal_ids='59860'  --for already matched volume
   
--select @flag='z',@path='1604',@term_start='2018-05-01',@term_end='2018-05-31',@process_id='ACF5B490_F55D_4EBD_838E_BE477064653B',@minor_location='2771',@receipt_deal_ids='59828',@del_location='2770',@delivery_deal_ids='59860'
	SELECT @flag='m',@path='109',@term_start='2019-11-01',@term_end='2019-11-01',@receipt_deal_ids='1740',@delivery_deal_ids=''

		
--*/  
 

DECLARE @From_Deal    INT  
		, @phy_deal_id   INT    
		, @grid_columns   VARCHAR(4000)  
		, @round_by    INT = 0  
		, @from_deal_detail  INT  
		, @row_no    INT  
		, @avail_volume   NUMERIC(38, 17)
		, @mdq_rmdq VARCHAR(200)  
		, @cols_dates VARCHAR(1000)   
		, @dates VARCHAR(1000)
		, @loss_list VARCHAR(2000)
		, @del_vol_list VARCHAR(2000) 
		, @rec_vol_list VARCHAR(2000)  
		, @loss FLOAT
		, @path_name VARCHAR(200)   
		, @first_child_path_id INT  
		, @child_path_id INT 
		, @child_path_name VARCHAR(200)
		, @count INT = 0 
		, @sum_deal_volume_rec FLOAT
		, @sum_deal_volume_del FLOAT
		, @is_receipt CHAR(1)
  
/*  
Shrinkage round BY zero or less than 5 may impact in deal creating logic.   
In CASE of GROUP path delivery path loss factor IS used despite of user given loss factor  
but in CASE of simple path user defined loss factor IS used to calculate delivery volume.  
 */  
  
 /* STORE LOSS FACTOR INFORMATION START */  
--extract latest effective date for loss factor1  
IF OBJECT_ID('tempdb..#tmp_lf1_eff_date') IS NOT NULL   
	DROP TABLE #tmp_lf1_eff_date  
  
CREATE TABLE #sch_deals(source_deal_header_id INT)  
CREATE TABLE #path_info(
	path_id INT, 
	child_path_id INT
)  

CREATE TABLE #temp_new_rec_vol (  
	n INT IDENTITY(1,1),  
  vol FLOAT  
)  
  
CREATE TABLE #temp_avail_volume (  
	term_start DATETIME,  
	volume VARCHAR(1000) COLLATE DATABASE_DEFAULT,  
	location_of VARCHAR(10) COLLATE DATABASE_DEFAULT 
)  
CREATE CLUSTERED INDEX IX_TERM_START_TEMP_AVAIL_VOLUME ON #temp_avail_volume (term_start, location_of)  

CREATE TABLE #tmp_lf1_eff_date (
	path_id INT
	, effective_date DATETIME 
)	
 
INSERT INTO #tmp_lf1_eff_date
SELECT pls.path_id
	, MAX(pls.effective_date) effective_date  
FROM path_loss_shrinkage pls  
WHERE pls.effective_date <= @term_start  
	AND contract_id = @contract
GROUP BY pls.path_id  
CREATE NONCLUSTERED INDEX IX_PATH_ID_TMP_LF1_EFF_DATE ON #tmp_lf1_eff_date (path_id)
 
--extract value associated with latest effective date found for loss factor1  
IF OBJECT_ID('tempdb..#tmp_lf1') IS NOT NULL   
	DROP TABLE #tmp_lf1  
  
CREATE TABLE #tmp_lf1(
	path_id INT
	, effective_date DATETIME
	, loss_factor NUMERIC(38, 18)
	, shrinkage_curve_id INT
)	 
CREATE CLUSTERED INDEX IX_PATH_ID_PATH_ID_TMP_LF1  ON #tmp_lf1 (path_id, effective_date)

INSERT INTO #tmp_lf1
SELECT  path_id
		, effective_date
		, loss_factor
		, shrinkage_curve_id  
FROM #tmp_lf1_eff_date t1  
CROSS APPLY (  
	SELECT p.loss_factor, p.shrinkage_curve_id   
	FROM path_loss_shrinkage p   
	WHERE p.path_id = t1.path_id 
		AND p.effective_date = t1.effective_date  
		AND contract_id = @contract
) ca_lf  
  
  
--extract latest effective date for loss factor2(time series data)  
IF OBJECT_ID('tempdb..#tmp_lf2_eff_date') IS NOT NULL   
	DROP TABLE #tmp_lf2_eff_date  
  
SELECT tsd.time_series_definition_id
	, MAX(tsd.effective_date) effective_date  
INTO #tmp_lf2_eff_date  
FROM time_series_data tsd  
WHERE tsd.effective_date <= @term_start  
GROUP BY tsd.time_series_definition_id  
  
--extract value associated with latest effective date found for loss factor2(time series data)  
IF OBJECT_ID('tempdb..#tmp_lf2') IS NOT NULL   
	DROP TABLE #tmp_lf2  
  
SELECT t2.time_series_definition_id
	, t2.effective_date
	, ca_lf.loss_factor  
INTO #tmp_lf2  
FROM #tmp_lf2_eff_date t2  
CROSS APPLY (  
	SELECT t.value loss_factor   
	FROM time_series_data t   
	WHERE t.time_series_definition_id = t2.time_series_definition_id   
		AND t.effective_date = t2.effective_date  
) ca_lf  
  
--final store of loss factor information  
IF OBJECT_ID('tempdb..#tmp_loss_factor') IS NOT NULL   
 DROP TABLE #tmp_loss_factor  
  
SELECT l1.path_id
	, l1.effective_date effective_date1
	, l1.loss_factor loss_factor1  
	, l1.shrinkage_curve_id
	, l2.effective_date effective_date2
	, l2.loss_factor loss_factor2  
	, COALESCE(l1.loss_factor, l2.loss_factor, 0) loss_factor  
INTO #tmp_loss_factor  
FROM #tmp_lf1 l1  
LEFT JOIN #tmp_lf2 l2   
	ON l2.time_series_definition_id = l1.shrinkage_curve_id  
  
SET @term_end = NULLIF(@term_end, '')  
--SELECT * FROM #tmp_loss_factor  
/* STORE LOSS FACTOR INFORMATION END */  
   
SET @grid_columns = '[Path]  
     , sub  
     , [Contract]       
     , storage_contract  
     , dbo.FNAGetSQLStandardDate([Term Start]) [Flow Date From]  
     , dbo.FNAGetSQLStandardDate([Term End]) [Flow Date To]  
     , ROUND([Scheduled Volume], ' + CAST(@round_by AS CHAR(1)) + ') [Scheduled Volume]  
     , [Fuel Charge]  
     , ROUND([Delivered Volume], ' + CAST(@round_by AS CHAR(1)) + ') [Delivered Volume]       
     , ROUND([Total Sch Vol], ' + CAST(@round_by AS CHAR(1)) + ') [Total Sch Vol]  
	 , ROUND(([Scheduled Volume] -[Delivered Volume]) / CASE [Scheduled Volume] WHEN 0 THEN 1 ELSE [Scheduled Volume] END , 5) [Shrinkage]
     , ROUND([Total Del Vol], ' + CAST(@round_by AS CHAR(1)) + ') [Total Del Vol]  
     , [Location From]  
     , [Location To]  
     , [Book]  
     , [Volume Frequency]       
     , [Shipping Counterparty]   
     , [Receiving Counterparty]  
     , [Trans ID]  
     , [is_mr]  [Is MR]  
     , ROUND([Available Volume], ' + CAST(@round_by AS CHAR(1)) + ') [Available Volume]  
     , [Deal ID]  
     , [delivery_path_detail_id]  
     , [ProcessID]   
     , [row_number]  
     , [Rescheduled_flag]'  
   
IF @source_deal_header_id IS NULL  
BEGIN  
	SELECT @phy_deal_id = sdh.source_deal_header_id  
	FROM source_deal_header sdh  
	INNER JOIN source_deal_detail sdd   
		ON sdh.source_deal_header_id = sdd.source_deal_header_id   
		AND sdd.source_deal_detail_id = @source_deal_detail_id  
END   
ELSE  
BEGIN  
	SET @phy_deal_id = @source_deal_header_id  
END  
  
SELECT @From_Deal = value_id  
FROM   static_data_value  
WHERE  code = 'From Deal'   
	AND [type_id] = 5500  
  
SELECT @from_deal_detail = value_id  
FROM   static_data_value  
WHERE  code = 'From Deal Detail'   
	AND [type_id] = 5500  
     

IF @volume IS NULL  
	SET @volume = 0  
   
IF @schedule_volume IS NULL  
	SET @schedule_volume = 0  
   
IF @deliver_volume IS NULL  
	SET @deliver_volume = 0  
  
  
DECLARE @fuel_charge VARCHAR(30)  
	,@fuel_charge_per FLOAT  
	,@label_vol VARCHAR(500)  
	,@sql VARCHAR(MAX)  
  
SET @fuel_charge ='Fuel_charge'  
IF @option = 'd'  
BEGIN   
	SET @label_vol='Delivered Volume'  
END  
ELSE  
BEGIN  
	SET @label_vol='Received Volume'  
END  
  
DECLARE @user_login_id    VARCHAR(100)  
	, @schedule_deal_table  VARCHAR(500)  
	, @table_exists    CHAR(1)  
	, @sch_filter    VARCHAR(8000)  
	, @process_table   VARCHAR(100)  
    
SET @user_login_id = dbo.FNADBUser()  
  
SELECT @sch_filter = ' (1 = 1 ' +  
		CASE WHEN @term_start IS NOT NULL THEN 'AND [Term Start] >= ''' + @term_start + '''' ELSE '' END  
		+ CASE WHEN @term_end IS NOT NULL THEN 'AND [Term End] <= ''' + @term_end + '''' ELSE '' END  
		--IF both term start & end are blank, exclude them  
		+ CASE WHEN ISNULL(@term_start, @term_end) IS NULL THEN 'AND 1 = 2' ELSE '' END  
		+ ') '  
  
IF OBJECT_ID('tempdb..#temp_total_volume') IS NOT NULL  
	DROP TABLE #temp_total_volume  
  
CREATE TABLE #temp_total_volume (  
	source_deal_header_id  VARCHAR(200) COLLATE DATABASE_DEFAULT,  
	flow_date_from       DATETIME,  
	flow_date_to         DATETIME,  
	pipeline             VARCHAR(100) COLLATE DATABASE_DEFAULT,  
	trader               VARCHAR(100) COLLATE DATABASE_DEFAULT,  
	volume               NUMERIC(38, 20),  
	schedule_volume      NUMERIC(38, 20),  
	available_volume     NUMERIC(38, 20),  
	uom					 VARCHAR(100) COLLATE DATABASE_DEFAULT  
)  
CREATE CLUSTERED INDEX IX_SOURCE_DEAL_HEADER_ID_TEMP_TOTAL_VOLUME ON #temp_total_volume (source_deal_header_id)
   
--Calculate delivered volume for given path  
IF @flag = 'v'  
BEGIN  
	DECLARE @primary_path_id INT  
	SET @primary_path_id = @path  
    
	IF OBJECT_ID('tempdb..#total_simple_path') IS NOT NULL   
		DROP TABLE #total_simple_path   
   
	CREATE TABLE #total_simple_path (  
		row_no     INT IDENTITY(1, 1),  
		delivery_path_detail_id INT,  
		path_id     INT,  
		from_location   INT,  
		to_location    INT,  
		loss_factor    NUMERIC(38,20)  
	)  
  
	INSERT INTO #total_simple_path (  
		delivery_path_detail_id,  
		path_id,  
		from_location,  
		to_location,  
		loss_factor  
	)  
	SELECT dpd.delivery_path_detail_id  
		, dp_primary.path_id  
		, dp_primary.from_location  
		, dp_primary.to_location  
		, ISNULL(CAST(dp_primary.loss_factor AS NUMERIC(38, 20)), 0) loss_factor  
	FROM delivery_path dp  
	LEFT JOIN delivery_path_detail dpd   
		ON dpd.path_id = dp.path_id   
	LEFT JOIN delivery_path dp_primary   
		ON dp_primary.path_id = ISNULL(dpd.Path_name, dp.path_id)  
	WHERE dp.Path_id = @primary_path_id  
	ORDER BY dpd.delivery_path_detail_id  

	--SELECT * FROM #total_simple_path  
  
	DECLARE @path_id INT  
			, @location_from INT  
			, @location_to INT  
			, @loss_factor NUMERIC(38,20)  
			, @prev_location_to INT  
			, @delivered_volume NUMERIC(38,20)  
     
    
	DECLARE volume_cursor CURSOR LOCAL FOR   
		SELECT row_no, path_id, from_location, to_location, loss_factor   
		FROM #total_simple_path  
		ORDER BY delivery_path_detail_id, path_id  
    
	OPEN volume_cursor  
	FETCH NEXT FROM volume_cursor INTO @row_no, @path_id, @location_from, @location_to, @loss_factor  
	WHILE @@FETCH_STATUS = 0     
	BEGIN   
		IF @row_no = 1  
		BEGIN  
			SET @delivered_volume = @schedule_volume * (1 - @loss_factor)  
		END  
		ELSE  
		BEGIN  
			IF @location_from = @prev_location_to  
			SET @delivered_volume = @delivered_volume * (1 - @loss_factor)   
		END   
     
		SET @prev_location_to = @location_to     
		FETCH NEXT FROM volume_cursor INTO @row_no, @path_id, @location_from, @location_to, @loss_factor  
	END  
	CLOSE volume_cursor  
	DEALLOCATE  volume_cursor   
  
	SELECT dbo.FNARemoveTrailingZero(ROUND(@delivered_volume, @round_by))  
  
END  
ELSE IF @flag = 'x'  
BEGIN  
	--Delete row temporarily FROM the grid   
	DECLARE @schedule_deal_table1 VARCHAR(MAX)  
	
	SET @schedule_deal_table1 = dbo.FNAProcessTableName('schedule_deal', dbo.fnadbuser(), @process_id)  

	SET @sql= '  
	DELETE FROM '+@schedule_deal_table1  + ' WHERE ROW_NUMBER IN (' + ISNULL(@row, -1) + ')  
   
	SELECT  ' + @grid_columns + '  
	FROM ' + @schedule_deal_table1  + '  
	WHERE [Trans ID] IS NULL OR ' + @sch_filter + ' 
	ORDER BY [Trans ID] DESC'  
	--print @sql  
	EXEC(@sql)   
    
END  
ELSE IF @flag = 'c'  
BEGIN   
	SET @schedule_deal_table = dbo.FNAProcessTableName('schedule_deal', @user_login_id, @process_id) 
	 
	SET @sql= '	SELECT ' + @grid_columns + '  
				FROM ' + @schedule_deal_table  + ' 
				WHERE 1 = 1 ' + CASE WHEN @trans_id IS NOT NULL THEN ' AND [Trans ID] = ' + CAST(@trans_id AS VARCHAR(100)) ELSE '' END +      
				' ORDER BY row_number'  
	--print @sql  
	EXEC(@sql)  
   
END  
ELSE IF @flag = 'a'  
BEGIN  
	SELECT @avail_volume = MAX(sdd1.deal_volume) * MAX(DATEDIFF(dd,sdd1.term_start,sdd1.term_end)+1)-((SUM(sdd.deal_volume))* MAX(DATEDIFF(dd,sdd.term_start,sdd.term_end)+1))     
	FROM  source_deal_detail sdd   
	INNER JOIN source_deal_header sdh 
		ON sdh.source_deal_header_id = sdd.source_deal_header_id  
	INNER JOIN user_defined_deal_fields_template udft  
		ON udft.[template_id] = sdh.[template_id]   
	AND udft.field_id = @From_Deal  
	INNER JOIN  [user_defined_deal_fields] uddf 
		ON uddf.source_deal_header_id = sdd.source_deal_header_id  
	AND udft.udf_template_id = uddf.udf_template_id      
	INNER JOIN source_deal_detail sdd1 
		ON CAST(sdd1.source_deal_header_id AS VARCHAR) = uddf.udf_value     
		AND sdd.term_start BETWEEN sdd1.term_start AND sdd1.term_end  
		AND sdd.Leg = sdd1.Leg  
	WHERE sdd1.source_deal_detail_id = @source_deal_detail_id   
  
	SELECT   
		ISNULL(@avail_volume, @volume * (DATEDIFF(dd, sdd.term_start, sdd.term_end) + 1))
		,fs.counterparty_id
		,sdh.deal_id     
	FROM   
	source_deal_detail sdd  
	INNER JOIN source_deal_header sdh 
		ON sdd.source_deal_header_id = sdh.source_deal_header_id  
	INNER JOIN source_system_book_map ssbm 
		ON ssbm.source_system_book_id1 = sdh.source_system_book_id1  
		AND ssbm.source_system_book_id2 = sdh.source_system_book_id2  
		AND ssbm.source_system_book_id3 = sdh.source_system_book_id3  
		AND ssbm.source_system_book_id4 = sdh.source_system_book_id4  
	INNER JOIN portfolio_hierarchy ph 
		ON ph.entity_id = ssbm.fas_book_id  
	INNER JOIN portfolio_hierarchy ph1 
		ON ph.parent_entity_id = ph1.entity_id  
	INNER JOIN portfolio_hierarchy ph2 
		ON ph1.parent_entity_id = ph2.entity_id  
	INNER JOIN fas_subsidiaries fs 
		ON fs.fas_subsidiary_id = ph2.entity_id  
	WHERE sdd.source_deal_detail_id= @source_deal_detail_id  
   
END  
  
/*  
* Returns volume AND related data of physical deal.  
*/  
ELSE IF @flag = 't'  
BEGIN  
	DECLARE @total_deal_volume FLOAT  
	SET @process_table = dbo.FNAProcessTableName('volume_summary', @user_login_id, dbo.FNAGetNewID())  
  
	--SELECT 't',@phy_deal_id, NULL, NULL, @process_table, @source_deal_detail_id   
	EXEC spa_deal_schedule_report 't',@phy_deal_id, NULL, NULL, @process_table, @source_deal_detail_id   
   
	--process TABLE IS used due to nested exec error.  
	SET @sql = 'INSERT INTO #temp_total_volume  
				(  
					source_deal_header_id,  
					flow_date_from,  
					flow_date_to,  
					pipeline,  
					trader,  
					volume,  
					schedule_volume,  
					available_volume,  
					uom  
				)  
				SELECT [Deal ID], [Flow Date From], [Flow Date To], [Pipeline], [Trader], [Volume], [Scheduled Volume], [Available Volume], [UOM]  
				FROM ' + @process_table  
	EXEC(@sql)      
   
	SELECT @total_deal_volume = SUM(available_volume)   
	FROM #temp_total_volume  
   
	SELECT MAX(sdh.source_deal_header_id) source_deal_header_id  
		, MAX(sdh.deal_id) deal_id  
		, MAX(sdh.trader_id) trader_id   
		, ROUND(CASE MAX(sdh.header_buy_sell_flag) WHEN 'b' THEN 1 ELSE -1 END *   
		ISNULL(@total_deal_volume, SUM(sdd.deal_volume *(DATEDIFF(dd, sdd.term_start, sdd.term_end) + 1))), @round_by) [total_volume]  
		, MAX(fs.counterparty_id) primary_counterparty_id  
		, MIN(sdd.term_start ) entire_term_start
		, MAX(sdd.term_end ) entire_term_end
		, MAX(sdh.counterparty_id) counterparty_id  
		, MAX(sdd.location_id) location_id  
		, MAX(sdd.deal_volume_uom_id) deal_volume_uom_id  
	FROM source_deal_header sdh  
	INNER JOIN source_deal_detail sdd 
		ON sdd.source_deal_header_id = sdh.source_deal_header_id --AND sdd.leg = 1  
	INNER JOIN source_system_book_map ssbm 
		ON ssbm.source_system_book_id1 = sdh.source_system_book_id1  
		AND ssbm.source_system_book_id2 = sdh.source_system_book_id2  
		AND ssbm.source_system_book_id3 = sdh.source_system_book_id3  
		AND ssbm.source_system_book_id4 = sdh.source_system_book_id4  
	INNER JOIN portfolio_hierarchy ph 
		ON ph.entity_id = ssbm.fas_book_id  
	INNER JOIN portfolio_hierarchy ph1 
		ON ph.parent_entity_id = ph1.entity_id  
	INNER JOIN portfolio_hierarchy ph2 
		ON ph1.parent_entity_id = ph2.entity_id  
	INNER JOIN fas_subsidiaries fs 
		ON fs.fas_subsidiary_id = ph2.entity_id  
	WHERE sdh.source_deal_header_id = @source_deal_header_id  
		AND (sdd.source_deal_detail_id = @source_deal_detail_id 
				OR @source_deal_detail_id IS NULL
			)  
	GROUP BY sdh.entire_term_start, sdh.entire_term_end  
   
END    
ELSE IF @flag IN('d', 'r')  
BEGIN   
	SET @table_exists = 'y'  
  
	IF @process_id IS NULL   
	BEGIN  
		SET @process_id = REPLACE(NEWID(), '-', '_')  
		SET @table_exists = 'n'  
	END   
	SET @schedule_deal_table = dbo.FNAProcessTableName('schedule_deal', @user_login_id, @process_id)  
  
	SELECT @fuel_charge_per = trs.rate   
	FROM  Transportation_rate_schedule trs   
	INNER JOIN static_data_value sdv   
		ON sdv.value_id = trs.rate_type_id 
		AND sdv.code = @fuel_charge  
	LEFT JOIN delivery_path dp   
		ON  trs.rate_schedule_id = dp.rateSchedule    
		AND dp.path_id = @path  
  
	SET @sql = '  
	CREATE TABLE ' + @schedule_deal_table + '(  
		row_number INT IDENTITY(1,1),   
		[Path] [INT] NOT NULL,  
		[Shipping Counterparty] [INT] NULL,  
		[Receiving Counterparty] [INT] NULL,  
		--[Pipeline Owner] [VARCHAR](100) NULL,  
		[Location From] [VARCHAR](205) NULL,  
		[Location To] [VARCHAR](205) NULL,  
		[Scheduled Volume] [FLOAT] NULL,  
		[Available Volume] [FLOAT] NULL,  
		[Delivered Volume] [FLOAT] NULL,  
		[Loss Factor] [FLOAT] NOT NULL,  
		[Fuel Charge] [FLOAT] NOT NULL,  
		[Contract] [VARCHAR](50) NULL,  
		storage_contract VARCHAR(50) NULL,  
		--[Transportation Rate Schedule] [VARCHAR](500) NULL,  
		[delivery_path_detail_id] [INT]  NULL,  
		[Term Start] DATETIME NULL,  
		[Term End] DATETIME NULL,  
		[Book] INT NULL,  
		[ProcessID] [VARCHAR](36) NOT NULL,  
		[Trans ID] INT NULL,  
		[Total Sch Vol] [FLOAT] NULL,  
		[Total Del Vol] [FLOAT] NULL,  
		[Deal ID] Varchar(2000) NULL,
		[Rescheduled_flag] BIT DEFAULT 0,  
		[Volume Frequency] VARCHAR(50),  
		[is_mr] CHAR(1) DEFAULT ''n'',  
		sub CHAR(1) DEFAULT ''1''  
	) '  
    
	IF @table_exists = 'n'  
	EXEC(@sql)   
  
	--SELECT @table_exists,@phy_deal_id phy_deal_id,@From_Deal From_Deal,@From_Deal_detail,@source_deal_detail_id,@source_deal_header_id  
   
	IF @table_exists = 'n' AND @phy_deal_id IS NOT NULL  
	BEGIN  
		---starts loading schedule deal  
		IF OBJECT_ID('tempdb..#temp_template') IS NOT NULL  
			DROP TABLE #temp_template   
    
		SELECT sdht.template_id,  
			gmv.clm1_value [type id]  
		INTO #temp_template  
		FROM generic_mapping_header gmh  
		INNER JOIN generic_mapping_values gmv   
			ON gmh.mapping_table_id = gmv.mapping_table_id   
			AND gmh.mapping_name = 'Imbalance Report'  
		LEFT JOIN source_deal_header_template sdht   
			ON CAST(sdht.template_id AS VARCHAR(100)) = gmv.clm3_value  
		WHERE gmv.clm1_value IN ('1', '5')  
		--SELECT * FROM #temp_template  
  
		IF OBJECT_ID('tempdb..#temp_std') IS NOT NULL   
			DROP TABLE #temp_std   
  
		SELECT    
			source_deal_header_id  
			, term_start  
			, term_end  
			, ISNULL(scheduled_vol, 0) scheduled_vol  
			, ISNULL(delivery_vol, 0) delivery_vol  
			, location_from  
			, location_to  
			, MAX([Scheduled ID]) scheduled_id  
			, [Path Detail ID] path_detail_id  
			, MAX([Receiving Counterparty]) [Receiving Counterparty]  
			, MAX([Shipping Counterparty]) [Shipping Counterparty]      
		INTO #temp_std --SELECT * FROM #temp_std  
		FROM (  
			SELECT sdh.source_deal_header_id  
				, sdd.term_start  
				, sdd.term_end  
				, sdd.leg  
				, (CASE WHEN sdd.leg = 1 THEN sdd.deal_volume ELSE NULL END) scheduled_vol  
				, (CASE WHEN sdd.leg = 2 THEN sdd.deal_volume ELSE NULL END) delivery_vol  
				, (CASE WHEN sdd.leg = 1 THEN sdd.location_id ELSE NULL END) location_from  
				, (CASE WHEN sdd.leg = 2 THEN sdd.location_id ELSE NULL END) location_to  
				, uddft_sch.Field_label  
				, uddf_sch.udf_value [udf_value]       
			FROM [user_defined_deal_fields_template] uddft  
			INNER JOIN  user_defined_deal_fields uddf   
				ON uddf.udf_template_id = uddft.udf_template_id   
				AND uddft.field_name = @From_Deal   
				AND uddf.udf_value = CAST(@source_deal_header_id AS VARCHAR(10))  
			--INNER JOIN  user_defined_deal_fields uddf_d  
			-- ON uddf_d.udf_template_id = uddft.udf_template_id   
			-- AND uddft.field_name = @From_Deal_detail   
			-- AND (uddf_d.udf_value = CAST(@source_deal_detail_id AS VARCHAR(10)) OR @source_deal_detail_id IS NULL)  
			--AND uddft.field_name = 293418 AND uddf.udf_value = CAST(34589 AS VARCHAR)  
			INNER JOIN source_deal_header sdh   
				ON sdh.source_deal_header_id = uddf.source_deal_header_id  
			INNER JOIN source_deal_detail sdd   
				ON sdd.source_deal_header_id = sdh.source_deal_header_id   
				--AND (sdd.source_deal_detail_id = @source_deal_detail_id OR @source_deal_detail_id IS NULL)  
			INNER JOIN user_defined_deal_fields_template uddft_sch   
				ON sdh.template_id = uddft_sch.template_id  
			INNER JOIN user_defined_deal_fields uddf_sch   
				ON uddf_sch.udf_template_id = uddft_sch.udf_template_id   
				AND sdh.source_deal_header_id = uddf_sch.source_deal_header_id      
		) s1  
	PIVOT(MAX(udf_value) FOR Field_label IN ([Scheduled ID], [Path Detail ID], [Receiving Counterparty], [Shipping Counterparty])) AS a  
	GROUP BY source_deal_header_id
		, term_start
		, term_end
		, scheduled_vol  
		, delivery_vol  
		, location_from  
		, location_to  
		, [Path Detail ID]  
  
  
	IF EXISTS (SELECT 1 FROM #temp_std)   
	BEGIN     
    --Single row for GROUP path  
		IF OBJECT_ID('tempdb..#temp_deal') IS NOT NULL   
			DROP TABLE #temp_deal  
		
		SELECT  
			ds.path_id  
			, tsdt.[Receiving Counterparty] rec_cpty  
			, tsdt.[Shipping Counterparty] shipping_cpty   
			, MAX(location_from) location_from  
			, MAX(location_to) location_to  
			, 0 available_vol  
			, SUM(tsdt.scheduled_vol) total_sch_vol  
			, SUM(tsdt.delivery_vol) total_del_vol       
			, ISNULL(MAX(dp.loss_factor),  0)loss_factor  
			, ISNULL(MAX(dp.fuel_factor),  0) fuel_change  
			, sdh.contract_id contract_id  
			, tsdt.path_detail_id [delivery_path_detail_id]   
			, MIN(tsdt.term_start) term_start  
			, MAX(tsdt.term_end) term_end        
			, ssbm.book_deal_type_map_id book       
			, '' process_id  
			, MIN(tsdt.source_deal_header_id) source_deal_header_id  
			, tsdt.scheduled_id trans_id   
			, MAX(sdh.template_id) template_id    
			, MAX(sdht.term_frequency_type) term_frequency_type    
		INTO #temp_deal --SELECT * FROM #temp_deal  
		FROM #temp_std tsdt  
		INNER JOIN deal_schedule ds   
			ON ds.deal_schedule_id = tsdt.scheduled_id  
		INNER JOIN delivery_path dp   
			ON dp.path_id = ds.path_id  
		INNER JOIN source_deal_header sdh   
			ON  sdh.source_deal_header_id = tsdt.source_deal_header_id  
		INNER JOIN source_deal_header_template sdht   
			ON sdh.template_id = sdht.template_id  
		LEFT JOIN source_system_book_map ssbm   
			ON ssbm.source_system_book_id1 = sdh.source_system_book_id1  
			AND ssbm.source_system_book_id2 = sdh.source_system_book_id2  
			AND ssbm.source_system_book_id3 = sdh.source_system_book_id3  
			AND ssbm.source_system_book_id4 = sdh.source_system_book_id4  
		GROUP BY ds.path_id  
			, sdh.contract_id  
			, tsdt.[Receiving Counterparty]  
			, tsdt.[Shipping Counterparty]  
			, ssbm.book_deal_type_map_id  
			, tsdt.scheduled_id  
			, tsdt.path_detail_id  
    
		
		SET @sql = '				
			INSERT INTO ' + @schedule_deal_table + '([Path],[Shipping Counterparty], [Receiving Counterparty] 
		   , [Location From],[Location To], [Scheduled Volume], [Available Volume], [Delivered Volume]  
		   , [Loss Factor], [Fuel Charge], [Contract], [delivery_path_detail_id] , [Term Start], [Term End]  
		   , [Book],[ProcessID]  
		   , [Trans ID]  
		   , [Total Sch Vol]  
		   , [Total Del Vol]  
		   , [Deal ID]  
		   , [Rescheduled_flag]  
		   , [Volume Frequency]  
		   , [is_mr]  
		   )  
		  SELECT   
		   min_rs.path_id  
		   , min_rs.shipping_cpty   
		   , min_rs.rec_cpty  
		   , min_rs.location_from  
		   , max_rs.location_to  
		   , AVG(tsdt_sch_avg.scheduled_vol)  
		   , min_rs.available_vol  
		   , AVG(tsdt_del_avg.delivery_vol)  
		   --, AVG((tsdt_sch_avg.scheduled_vol - tsdt_del_avg.delivery_vol)/CASE tsdt_sch_avg.scheduled_vol WHEN 0 THEN 1 ELSE tsdt_sch_avg.scheduled_vol END)  
		   , ISNULL(MAX(lf.loss_factor), 0)  
		   , min_rs.fuel_change  
		   , min_rs.contract_id  
		   , min_rs.delivery_path_detail_id   
		   , min_rs.term_start  
		   , min_rs.term_end        
		   , min_rs.book       
		   ,''' + @process_id + '''  
		   , min_rs.trans_id  
		   ,  min_rs.total_sch_vol  
		   ,  max_rs.total_del_vol  
		   , Case WHEN min_rs.source_deal_header_id IS NULL THEN NULL ELSE 
			max(dbo.FNADecodeXML(LEFT(a.deal_ids, LEN(a.deal_ids ) - 1)))						
			END [Deal ID]	 
		   , CASE WHEN MAX(uddf.udf_value) IS NULL THEN 0 ELSE 1 END rescheduled_flag  
		   , CASE MAX(min_rs.term_frequency_type)  
			WHEN ''a'' then ''Annually''  
			WHEN ''d'' THEN ''Daily''  
			WHEN ''h'' THEN ''Hourly''  
			WHEN ''m'' THEN ''Monthly''  
			WHEN ''q'' THEN ''Quarterly''  
			WHEN ''s'' THEN ''Semi-Annually''  
			ELSE  
			''''  
			END  
		   --, CASE WHEN MAX(td.[type id]) = 5 THEN ''y'' ELSE ''n'' END  
		   , CASE WHEN MAX(td.[type id]) = 5 THEN 1 ELSE 0 END  
		  FROM (  
		  SELECT td.path_id, td.trans_id	         
			, MIN(td.source_deal_header_id)  min_source_deal_header_id  
			, MAX(td.source_deal_header_id)  max_source_deal_header_id   
		   FROM #temp_deal td  
		   GROUP BY  td.path_id,  
			td.trans_id  
		  ) min_max_deal
		  outer APPLY (
							SELECT dbo.FNATRMWinHyperlink(''a'', 10131010, td.source_deal_header_id, ABS(td.source_deal_header_id),''n'',null,null,null,null,null,null,null,null,null,null,0) + '',''
							FROM #temp_deal td
							where td.path_id = min_max_deal.path_id
							and td.trans_id = min_max_deal.trans_id
							FOR XML PATH('''')
						) a (deal_ids)   
		  INNER JOIN #temp_deal min_rs ON min_rs.source_deal_header_id = min_max_deal.min_source_deal_header_id    
		  INNER JOIN #temp_deal max_rs ON max_rs.source_deal_header_id = min_max_deal.max_source_deal_header_id  
		  INNER JOIN source_deal_header_template sdht ON sdht.template_id = min_rs.template_id  
		  INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id = min_rs.template_id  
		  LEFT JOIN #temp_template td ON td.[template_id] = sdht.template_id  
		  --LEFT JOIN delivery_path_detail dpd ON dpd.Path_id = min_rs.path_id  
		  --LEFT JOIN delivery_path dp ON CAST(dp.path_id AS VARCHAR) = ISNULL(dpd.Path_name, min_rs.path_id)  
		  LEFT JOIN  [user_defined_deal_fields] uddf ON uddf.udf_template_id = uddft.udf_template_id  
			AND uddft.field_id = -5605 --Rescheduled From udf   
			AND uddf.source_deal_header_id = min_rs.source_deal_header_id  
			--AND uddf.udf_value = CAST(min_rs.trans_id  AS VARCHAR)  
		  CROSS APPLY (SELECT ISNULL(AVG(tsdt_sch_vol.scheduled_vol), 0) scheduled_vol  
					   FROM #temp_std tsdt_sch_vol  
					   WHERE tsdt_sch_vol.scheduled_id = min_rs.trans_id  
			  AND ISNULL(tsdt_sch_vol.path_detail_id, -1) = ISNULL(min_rs.delivery_path_detail_id, -1)  
			  AND tsdt_sch_vol.scheduled_vol > 0) tsdt_sch_avg   
		  CROSS APPLY (SELECT ISNULL(AVG(tsdt_inner.delivery_vol), 0) delivery_vol  
					   FROM #temp_std tsdt_inner   
					   WHERE tsdt_inner.scheduled_id = max_rs.trans_id  
			  AND ISNULL(tsdt_inner.path_detail_id, -1) = ISNULL(max_rs.delivery_path_detail_id, -1)  
			  AND tsdt_inner.delivery_vol > 0) tsdt_del_avg  
		  LEFT JOIN #tmp_loss_factor lf ON lf.path_id = min_rs.path_id  
		  GROUP BY min_rs.path_id  
		   , min_rs.rec_cpty  
		   , min_rs.shipping_cpty   
		   , min_rs.location_from  
		   , max_rs.location_to  
		   , min_rs.available_vol  
		   , min_rs.total_sch_vol  
		   , max_rs.total_del_vol  
		   , min_rs.fuel_change  
		   , min_rs.contract_id  
		   , min_rs.delivery_path_detail_id   
		   , min_rs.term_start  
		   , min_rs.term_end        
		   , min_rs.book       
		   , min_rs.process_id  
		   , min_rs.source_deal_header_id  
		   , min_rs.trans_id  
		  ORDER BY min_rs.trans_id  
		 '  
		--print @sql  
		EXEC(@sql)  
  
	END   
END     
   
	--adding new schedule deal row  
	 IF @flag = 'r'  
	 BEGIN  
		DECLARE @phy_book_id INT   
    
		SET @process_table = dbo.FNAProcessTableName('volume_summary', @user_login_id, dbo.FNAGetNewID())  
  
		EXEC spa_deal_schedule_report 't', @phy_deal_id, NULL, NULL, @process_table, @source_deal_detail_id   
  
  
		DECLARE @location_id INT  
  
		SELECT @location_id = location_id   
		FROM source_deal_detail   
		WHERE source_deal_detail_id = @source_deal_detail_id  
  
  
		--process TABLE IS used due to nested exec error.  
		SET @sql = 'INSERT INTO #temp_total_volume  
			(  
			source_deal_header_id,  
			flow_date_from,  
			flow_date_to,  
			pipeline,  
			trader,  
			volume,  
			schedule_volume,  
			available_volume,  
			uom  
			)  
			SELECT [Deal ID], [Flow Date From], [Flow Date To], [Pipeline], [Trader], [Volume], [Scheduled Volume], [Available Volume], [UOM]  
			FROM ' + @process_table  
		EXEC(@sql)      
    
		DECLARE @schedule_volume_avail NUMERIC(38, 20)  
   
		SELECT @schedule_volume_avail = ISNULL(MIN(available_volume), 0) FROM #temp_total_volume  
		WHERE flow_date_from BETWEEN   
		--dbo.FNAGetContractMonth(@term_start)   
		--AND  dbo.FNALastDayInDate(@term_start)   
		@term_start   
		AND @term_end   
     
		SELECT @phy_book_id = ssbm.book_deal_type_map_id  
		FROM source_deal_header sdh   
		LEFT JOIN source_system_book_map ssbm   
			ON ssbm.source_system_book_id1 = sdh.source_system_book_id1  
			AND ssbm.source_system_book_id2 = sdh.source_system_book_id2  
			AND ssbm.source_system_book_id3 = sdh.source_system_book_id3  
			AND ssbm.source_system_book_id4 = sdh.source_system_book_id4  
		WHERE sdh.source_deal_header_id = @phy_deal_id  
  
		SET @sql =   
			'INSERT INTO ' + @schedule_deal_table + ' (  
					[Path],  
					[Shipping Counterparty],  
					[Receiving Counterparty],  
					[Location From],  
					[Location To],  
					[Scheduled Volume],  
					[Available Volume],  
					[Delivered Volume],  
					[Loss Factor],  
					[Fuel Charge],  
					[Contract],  
					[delivery_path_detail_id],  
					[Term Start],  
					[Term End],  
					[Book],  
					[ProcessID]  
				)' +       
			CASE WHEN @table_exists ='y' THEN ' SELECT TOP 1 ' ElSE ' SELECT ' END + '         
					dp.path_id [Path],  
					MAX(ISNULL(dgp_first.[counterparty], dp.[counterparty])) [Shipping Counterparty],  
					MAX(ISNULL(dgp_received_cpty.[counterparty_id], dp.[counterparty])) [Receiving Counterparty],' +   
					'MAX(COALESCE(' + ISNULL(CAST(@location_id AS VARCHAR(10)), 'NULL') + ',dgp_first.from_location, dp.from_location)) [Location From],  
					MAX(ISNULL(dgp_last.to_location, dp.to_location)) [Location To]  
					,CAST('+  
					CAST(ABS(@schedule_volume_avail) AS VARCHAR(100))          
					+ ' AS FLOAT) [Scheduled Volume],'  +  
					'CAST('+CAST(ABS(@volume-@schedule_volume) AS VARCHAR) + ' AS FLOAT) [Available Volume],'  +  
					'CAST('+CAST(ABS(@schedule_volume_avail) AS VARCHAR) + ' AS FLOAT)  
					* (1 - AVG(COALESCE(lf.loss_factor, 0))) [' + @label_vol + '],' +  
					'ISNULL(MAX(lf.loss_factor), 0) [Loss Factor],  
					0 [Fuel Charge],' +  
					----ISNULL(CAST(@fuel_charge_per AS VARCHAR),0) + ' [Fuel Charge],' +  
					'--cg.contract_name [Contract],  
					MAX(ISNULL(dgp_first.[contract], dp.[contract])) [Contract],  
					--sdv.code [Transportation Rate Schedule],  
					NULL [delivery_path_detail_id],  
					''' + @term_start + ''' AS [Term Start],  
					''' + @term_end + '''  AS [Term End],  
					--dbo.FNAGetContractMonth(''' + @term_start + ''') AS [Term Start],   
					--dbo.FNALastDayInDate(''' + @term_start + ''') AS [Term End],   
					NULL [Book],  
					'''+@process_id+''' [ProcessID]  
				FROM delivery_path dp  
				LEFT JOIN delivery_path_detail dpd 
					ON dpd.path_id = dp.path_id   
				LEFT JOIN delivery_path dp_child_path 
					ON dp_child_path.path_id = ISNULL(dpd.Path_name, dp.path_id)  
				OUTER APPLY (  
					SELECT TOP 1 dp_inner.from_location
						, dp_inner.[contract], dp_inner.counterparty  
					FROM delivery_path_detail dpd_inner  
					INNER JOIN delivery_path dp_inner 
						ON dp_inner.Path_id = dpd_inner.path_name  
					WHERE dpd_inner.path_id = dp.path_id  
					ORDER BY dpd_inner.delivery_path_detail_id ASC  
				) dgp_first   
				OUTER APPLY (  
					SELECT TOP 1 dp_inner.to_location  
					FROM delivery_path_detail dpd_inner  
					INNER JOIN delivery_path dp_inner ON dp_inner.Path_id = dpd_inner.path_name  
					WHERE dpd_inner.path_id = dp.path_id  
					ORDER BY dpd_inner.delivery_path_detail_id DESC  
				) dgp_last
				OUTER APPLY (
							SELECT TOP 1 sc.source_counterparty_id [counterparty_id], sc.counterparty_name [counterparty_name]
							FROM source_counterparty sc 
							WHERE sc.int_ext_flag = ''i'' 
							ORDER BY sc.counterparty_name ASC
						) dgp_received_cpty  
				LEFT JOIN #tmp_loss_factor lf 
					ON lf.path_id = dp.path_id        
				WHERE dp.Path_id = ' + CAST(ISNULL(@path, '') AS VARCHAR) + '  
				GROUP BY dp.path_id '  
  
			EXEC(@sql)  
	 END  
	--SELECT @table_exists,@location_id,@schedule_volume_avail,@volume,@schedule_volume,@label_vol,@process_id  
    
	SET @sql= 'SELECT ' + @grid_columns + '  
	FROM ' + @schedule_deal_table  +   
	' WHERE ' + @sch_filter   

	IF @flag = 'r'  
	BEGIN   
			SET @sql = --@sql + ' UNION 
				'SELECT ' + @grid_columns + '
					FROM ' + @schedule_deal_table  +   
					' WHERE [Trans ID] IS NULL'  
	END   
	
	SET @sql = @sql + '  ORDER BY [Trans ID] DESC'     
	--print @sql  
	EXEC(@sql)     
END  
ELSE IF @flag = 'b' --@flag <> 'd' Except deal schedule flag b IS used to load grid with all possible path detail  
BEGIN  
	SELECT @fuel_charge_per = trs.rate 
	FROM  transportation_rate_schedule trs   
	INNER JOIN static_data_value sdv 
		ON sdv.value_id = trs.rate_type_id 
		AND sdv.code = @fuel_charge  
	LEFT JOIN delivery_path dp 
		ON  trs.rate_schedule_id=dp.rateSchedule  
		AND dp.path_id = @path  
  
	SET @sql = '
		SELECT dp.path_name [Path Name],  
			 CASE WHEN dpd.grp =''y'' THEN dp2.counterparty ELSE dp.shipping_counterparty END [Shipping Counterparty],  
			 CASE WHEN dpd.grp =''y'' THEN dp2.counterparty ELSE dp.receiving_counterparty  END [Receiving Counterparty],' +   
			 'sc2.counterparty_name [Pipeline Owner],  
			 CASE   
			  WHEN sml2.location_name IS NULL THEN ''''  
			  ELSE sml2.location_name + '' - > ''  
			 END + sml_from.location_name [Location From],  
			  CASE   
			  WHEN sml3.location_name IS NULL THEN ''''  
			  ELSE sml3.location_name + '' - > ''  
			 END + sml_to.location_name [Location To]  
			 ,'+       
			 CAST(ABS(@volume) AS VARCHAR) + ' [Scheduled Volume],'  +  
			 CAST(ABS(@volume) AS VARCHAR) + ' [Available Volume],'  +  
			 CAST(ABS(@volume) AS VARCHAR) + ' [' + @label_vol + '],' +  
            
			 'ISNULL(dp.loss_factor,0)[Loss Factor],  
			 ISNULL(dp.fuel_factor,0) [Fuel Charge],' +  
			 ----ISNULL(CAST(@fuel_charge_per AS VARCHAR),0) + ' [Fuel Charge],' +  
			 'cg.contract_name [Contract],  
			 sdv.code [Transportation Rate Schedule],  
			dpd.delivery_path_detail_id [delivery_path_detail_id]       
		FROM dbo.delivery_path dp       
		INNER JOIN (  
			SELECT path_id,meter_from ,meter_to ,''n'' grp,'''' delivery_path_detail_id, path_id primary_path_id 
			FROM dbo.delivery_path 
			WHERE 1=1 ' +          
			CASE WHEN @path IS NOT NULL THEN 'AND path_id='+CAST(@path AS VARCHAR)   
			ELSE ' AND path_id IS NULL' END +  
        
		  ' AND groupPath=''n''  
		  UNION ALL  
		  SELECT path_name,from_meter ,to_meter ,''y'' grp , delivery_path_detail_id AS delivery_path_detail_id, path_id primary_path_id FROM dbo.delivery_path_detail WHERE 1=1 ' +   
		  CASE WHEN @path IS NOT NULL THEN ' AND path_id='+CAST(@path AS VARCHAR)  
		  ELSE ' AND path_id IS NULL' END +  
		  '  
     ) dpd ON dpd.path_id= dp.path_id --AND dp.groupPath=dpd.grp  
     LEFT JOIN delivery_path dp2  
		ON dp2.path_id = dpd.primary_path_id     
     LEFT JOIN source_minor_location_meter smlm 
		ON smlm.source_minor_location_id = dp.from_location 
		AND smlm.meter_id = dp.meter_from  
     LEFT JOIN source_minor_location_meter smlm1 
		ON smlm1.source_minor_location_id = dp.to_location 
		AND smlm1.meter_id = dp.meter_to  
     LEFT JOIN source_minor_location sml 
		ON smlm.source_minor_location_id= sml.source_minor_location_id  
     LEFT JOIN source_minor_location sml1 
		ON smlm1.source_minor_location_id= sml1.source_minor_location_id  
     LEFT JOIN source_major_location smm
		ON sml.source_major_location_id= smm.source_major_location_id  
     LEFT JOIN source_major_location smm1 
		ON sml1.source_major_location_id= smm1.source_major_location_id  
     LEFT JOIN source_minor_location sml_from 
		ON sml_from.source_minor_location_id =  dp.from_location  
     LEFT JOIN source_major_location sml2 
		ON sml2.source_major_location_id = sml_from.source_major_location_id  
     LEFT JOIN source_minor_location sml_to 
		ON sml_to.source_minor_location_id =  dp.to_location  
     LEFT JOIN source_major_location sml3
		ON sml3.source_major_location_id = sml_to.source_major_location_id  
     LEFT JOIN source_counterparty sc
		ON sc.source_counterparty_id=smm.counterparty  
     LEFT JOIN source_counterparty sc1 
		ON sc1.source_counterparty_id=smm1.counterparty    
     INNER JOIN contract_group cg 
		ON dp.CONTRACT=cg.contract_id   
     LEFT JOIN static_data_value sdv 
		ON sdv.value_id = dp.rateSchedule  
     LEFT outer JOIN source_counterparty sc2 
		ON dp.counterParty=sc2.source_counterparty_id'  
EXEC(@sql)  
  
END  
ELSE IF @flag = 'l' --extract path id->lossfactor for deal schedule grid  
BEGIN  
	SELECT dp.path_id
		, ISNULL(lf.loss_factor, 0) loss_factor
		, dp.[CONTRACT]
		, from_location
		, to_location  
	FROM delivery_path dp   
	LEFT JOIN #tmp_loss_factor lf 
		ON lf.path_id = dp.path_id  
	WHERE dp.path_id = ISNULL(@path,dp.path_id)  
END  
ELSE IF @flag = 'q'  
BEGIN  
	SET @trans_id = NULLIF(@trans_id, ''); 
	DECLARE @deal_term_start DATETIME	
	SELECT @deal_term_start = entire_term_start from source_deal_header WHERE source_deal_header_id = @source_deal_header_id
	   
	SET @sql = '  
		SELECT DISTINCT '+CASE WHEN @trans_id IS NOT NULL THEN 'CAST(sdd_leg1.term_start AS DATE) [term_start]'
						ELSE ''''' [term_start]'
					 END + ',  
			 ISNULL(dp1.path_id, dp.path_id) path_id
			, ISNULL(dp1.path_code, dp.path_code) path_code
			, sml_from.Location_Name from_location  
			, sml_to.Location_Name to_location '       
			+ CASE WHEN @trans_id IS NULL THEN ', cg.contract_id ' ELSE ', sdh.contract_id ' END +  
			+ CASE WHEN @trans_id IS NULL THEN ', '''' ' ELSE ', dbo.FNARemoveTrailingZero(round(sdd_leg1.deal_volume,0)) ' END + ' schedule_volume '  
			+ CASE WHEN @trans_id IS NULL THEN ', CAST(0.00 AS FLOAT )' ELSE ', IIF(ISNULL(sdd_leg1.deal_volume,0) = 0, 0, CAST(dbo.FNARemoveTrailingZero(round((sdd_leg1.deal_volume - sdd_leg2.deal_volume)/sdd_leg1.deal_volume,4)) AS FLOAT))' END + ' loss_factors '
			+ CASE WHEN @trans_id IS NULL THEN ', '''' ' ELSE ', dbo.FNARemoveTrailingZero(round(sdd_leg2.deal_volume,0)) ' END + ' delivered_volume ' +	' 
			, dp.receiving_counterparty receiving_counterparty  
			, dp.shipping_counterparty shipping_counterparty
			,'+ CASE WHEN @trans_id IS NULL THEN ' NULL ' ELSE 'dbo.FNATRMWinHyperlink(''a'', 10131010, sdh.source_deal_header_id, ABS(sdh.source_deal_header_id),''n'',null,null,null,null,null,null,null,null,null,null,0) ' END + ' [Deal ID]  
			, dpd.delivery_path_detail_id
				 INTO #temp_schedules	 
		FROM delivery_path dp 
		LEFT JOIN delivery_path_detail dpd	     
			ON dpd.path_id = dp.path_id   
		LEFT JOIN delivery_path dp1 			
			ON ISNULL(dp1.path_id, dp.path_id) = dpd.path_name		
		LEFT JOIN source_minor_location sml_from 
			ON sml_from.source_minor_location_id = ISNULL(dp1.from_location, dp.from_location)
		LEFT JOIN source_minor_location sml_to 
			ON sml_to.source_minor_location_id = ISNULL(dp1.to_location, dp.to_location)
		LEFT JOIN source_counterparty sc 
			ON sc.source_counterparty_id = ISNULL(dp1.counterParty, dp.counterParty)
		LEFT JOIN contract_group cg 
			ON cg.contract_id = ISNULL(dp1.CONTRACT, dp.CONTRACT) and cg.is_active = ''y'''
		+ CASE WHEN @trans_id IS NULL THEN '' ELSE '
		LEFT JOIN static_data_value sdv 
			ON sdv.value_id = ISNULL(dp1.[priority], dp.[priority]) AND sdv.type_id = 31400
		LEFT JOIN source_deal_detail sdd_leg1 
			ON (sdd_leg1.location_id = ISNULL(dp1.from_location, dp.from_location) AND sdd_leg1.leg = 1) 
		LEFT JOIN source_deal_detail sdd_leg2 
			ON (sdd_leg2.location_id = ISNULL(dp1.to_location, dp.to_location) AND sdd_leg2.leg = 2)  			
			LEFT JOIN source_deal_header sdh   
				ON sdd_leg1.source_deal_header_id = sdh.source_deal_header_id  
				AND sdd_leg2.source_deal_header_id = sdh.source_deal_header_id    
			LEFT JOIN user_defined_deal_fields uddf   
				ON uddf.source_deal_header_id = sdh.source_deal_header_id  
			LEFT JOIN user_defined_deal_fields_template uddft   
				ON uddft.udf_template_id = uddf.udf_template_id  
			LEFT JOIN user_defined_fields_template udft   
				ON uddft.field_id = udft.field_id   
			LEFT JOIN user_defined_deal_fields uddf1   
				ON uddf1.source_deal_header_id = sdh.source_deal_header_id  
			LEFT JOIN user_defined_deal_fields_template uddft1   
				ON uddft1.udf_template_id = uddf1.udf_template_id  
			LEFT JOIN user_defined_fields_template udft1   
				ON uddft1.field_id = udft1.field_id '    
        
		END + '    
		WHERE dp.path_id = ' + CAST(@path AS VARCHAR(10)) +  
			CASE WHEN @trans_id IS NULL   
			THEN   
			''   
			ELSE   
			' AND udft.Field_label = ''From Deal''   
			AND udft1.Field_label = ''scheduled id''   
			AND uddf1.udf_value= ''' + CAST(@trans_id AS VARCHAR(10)) +   
			'''  AND uddf.udf_value = ''' + CAST(@source_deal_header_id AS VARCHAR(10)) + ''''   
					END
			+  CASE WHEN @trans_id IS NULL THEN '
				
				UPDATE ts_outer
				SET ts_outer.loss_factors = pls_outer.loss_factor
				FROM path_loss_shrinkage pls_outer 
				INNER JOIN #temp_schedules ts_outer ON ts_outer.path_id = pls_outer.path_id
				INNER JOIN (
					SELECT pls.path_id, MAX( pls.effective_date) effective_date 
					FROM #temp_schedules ts
					INNER JOIN path_loss_shrinkage pls ON ts.path_id = pls.path_id
					AND pls.effective_date <= ''' + CAST(@deal_term_start AS VARCHAR(50)) + '''
					GROUP BY pls.path_id
				) flt ON flt.path_id = pls_outer.path_id AND pls_outer.effective_Date = flt.effective_Date
				' ELSE '' END
				+ '
					
				DECLARE @name varchar(MAX)
				select @name = COALESCE(@name + '','', '''') + ''['' + name + '']'' 
				from tempdb.sys.columns  WITH(NOLOCK)  where object_id =
				object_id(''tempdb..#temp_schedules'')-- and name <> ''term_start'' 
				ORDER BY column_id
				
				EXEC(''SELECT '' + @name + '' FROM '' + ''#temp_schedules ts
				ORDER BY 
				' +		CASE
							WHEN @trans_id IS NOT NULL THEN ' ts.term_start ASC, ts.delivery_path_detail_id asc'
							ELSE 'ts.delivery_path_detail_id'
						END + ''')
				'
		EXEC spa_print @sql
		EXEC (@sql)		
    
END  
ELSE IF @flag = 'g'  
BEGIN  
  
	CREATE TABLE #group_path_loss (  
		row_no INT IDENTITY(1, 1),    
		schedule_volume INT,  
		loss_factors FLOAT,  
		delivered_volume INT   
	)  
  
	INSERT INTO #group_path_loss(schedule_volume, loss_factors)  
	SELECT @schedule_volume, ls.loss_factor  
	FROM delivery_path_detail dpd  
	INNER JOIN delivery_path dp      
		ON dpd.path_id = dp.path_id   
	INNER JOIN delivery_path dp1      
		ON dp1.path_id = dpd.path_name  
	INNER JOIN path_loss_shrinkage ls   
		ON ls.path_id = dp1.path_id  
		AND ls.contract_id = @contract
	WHERE dp.path_id = @path  
	ORDER BY dpd.delivery_path_detail_id   
  
   
	DECLARE volume_cursor CURSOR LOCAL FOR   
	SELECT row_no FROM #group_path_loss ORDER BY row_no  
   
	OPEN volume_cursor  
	FETCH NEXT FROM volume_cursor INTO @row_no  
	WHILE @@FETCH_STATUS = 0     
	BEGIN   
     
		UPDATE t1 
			SET t1.schedule_volume = t2.delivered_volume  
		FROM #group_path_loss t1   
		INNER JOIN #group_path_loss t2  
			ON t1.row_no - 1 = t2.row_no  
		WHERE t1.row_no = @row_no  
  
		UPDATE #group_path_loss   
			SET delivered_volume = (1-loss_factors) * schedule_volume  
		WHERE row_no = @row_no    
      
	FETCH NEXT FROM volume_cursor INTO @row_no  
	END  
	CLOSE volume_cursor  
	DEALLOCATE  volume_cursor   
  
	SELECT * FROM #group_path_loss  
END  
ELSE IF @flag = 'w'  
BEGIN  
	DECLARE @contract_id INT  
   
	--SET @term_end = CAST(dbo.FNAGetTermEndDate('m', @term_start, 0) AS DATE)  
  
	INSERT INTO #sch_deals (source_deal_header_id)  
	SELECT DISTINCT transport_deal_id   
	FROM optimizer_detail od  
	INNER JOIN dbo.SplitCommaSeperatedValues(@receipt_deal_ids) t  
		ON t.item = od.source_deal_header_id  
	WHERE up_down_stream='u'  
  
	INSERT INTO #path_info(path_id, child_path_id)  
	SELECT dpd.path_id	
		, MIN(dpd.path_name) child_path_id  
	FROM delivery_path_detail dpd  
	INNER JOIN (  
		SELECT DISTINCT sdh.description4 path_id  
		FROM #sch_deals sd  
		INNER JOIN source_deal_header sdh  
			ON sd.source_deal_header_id = sdh.source_deal_header_id   
	) sub  
	ON dpd.path_id = sub.path_id  
	GROUP BY dpd.path_id  
  
  
  
	SELECT  1 sub
		, uddf.udf_value path_id
		, NULL contract
		, NULL storage_contract
		, NULL mdq_rmdq
		, MAX(sdh.sub_book) book
		, MIN(sdd.term_start) term_from
		, MAX(sdd.term_end) term_to, 'n' new  
	FROM #sch_deals sd  
	INNER JOIN source_deal_header sdh  
		ON sdh.source_deal_header_id = sd.source_deal_header_id   
	INNER JOIN source_deal_detail sdd  
		ON sdd.source_deal_header_id = sdh.source_deal_header_id  
	INNER JOIN user_defined_deal_fields_template uddft   
		ON uddft.template_id = sdh.template_id  
	INNER JOIN user_defined_deal_fields uddf  
		ON uddf.source_deal_header_id = sdh.source_deal_header_id   
		AND uddft.udf_template_id = uddf.udf_template_id   
	WHERE sdd.term_start BETWEEN @term_start AND ISNULL(@term_end, @term_start)  
		AND uddft.field_label = 'Delivery Path' 
		AND uddf.udf_value = CAST(@path AS VARCHAR(10))
	GROUP BY uddf.udf_value  
	UNION ALL  
	SELECT 1 sub, @path path_id, NULL contract, NULL storage_contract, NULL mdq_rmdq, NULL book, @term_start term_from, @term_end term_to, 'y' new  
  
END  
ELSE IF @flag = 'y'  
BEGIN  

	--
	--IF @call_from = 'opt_book_out' and @path = -1
	--begin
		
	--	SELECT   1 sub, @path path_id, null contract, NULL storage_contract, null mdq_rmdq,  null book, @term_start term_from, @term_end term_to, 'd'
	--	return

	--end


 --DECLARE @contract_id INT  
   
 --SET @term_end = CAST(dbo.FNAGetTermEndDate('m', @term_start, 0) AS DATE)  
   
 --SELECT @path path,1 sub, NULL contract, NULL mdq_rmdq, 331 book, @term_start term_from, @term_end term_to  
   
 --CREATE TABLE #sch_deals(source_deal_header_id INT)  
 --CREATE TABLE #path_info(path_id INT, child_path_id INT)  
  
	INSERT INTO #sch_deals (source_deal_header_id)  
	SELECT DISTINCT transport_deal_id   
	FROM optimizer_detail od  
	INNER JOIN dbo.SplitCommaSeperatedValues(@receipt_deal_ids) t  
	ON t.item = od.source_deal_header_id  
	WHERE up_down_stream='u'  

  
	SELECT   1 sub
		, uddf.udf_value path_id
		, NULL contract
		, NULL storage_contract
		, NULL mdq_rmdq
		, MAX(sdh.sub_book) book
		, MIN(sdd.term_start) term_from
		, MAX(sdd.term_end) term_to
		, 'n'  
	FROM  #sch_deals sd  
	INNER JOIN source_deal_header sdh  
		ON sdh.source_deal_header_id = sd.source_deal_header_id    
	INNER JOIN source_deal_detail sdd  
		ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN source_deal_header_template sdht  
		ON sdht.template_id = sdh.template_id    
	INNER JOIN user_defined_deal_fields_template uddft   
		ON uddft.template_id = sdh.template_id  
	INNER JOIN user_defined_deal_fields uddf  
		ON uddf.source_deal_header_id = sdh.source_deal_header_id   
		AND uddft.udf_template_id = uddf.udf_template_id     
	WHERE uddft.field_label = 'Delivery Path'  
		AND sdd.term_start BETWEEN @term_start AND ISNULL(@term_end, @term_start) 
		AND  uddf.udf_value = CAST(@path  AS VARCHAR(10))
	GROUP BY uddf.udf_value   
END  
ELSE IF @flag = 'e'  
BEGIN  
   
	--declare @avail_volume float, @mdq_rmdq VARCHAR(MAX)  
	EXEC spa_check_mdq_volume 'MDQ_RMDQ', @term_start, @path, @contract, @avail_volume OUTPUT, @mdq_rmdq OUTPUT  
  
	SELECT @mdq_rmdq  
  
END  
ELSE IF @flag = 'z' --for new daily deal match  
BEGIN  
	SELECT @cols_dates = ISNULL(@cols_dates + ',', '') + 'day' + CAST(n AS VARCHAR(5)) + ' FLOAT',  
			@dates = ISNULL(@dates + ',', '') + 'day' + CAST(n AS VARCHAR(5))   
	FROM seq  
	WHERE n <= DATEDIFF(DAY, @term_start, @term_end) + 1  
    
	IF OBJECT_ID('tempdb..#deal_term_breakdown') IS NOT NULL  
		DROP TABLE #deal_term_breakdown  
   
	IF OBJECT_ID('tempdb..#temp_rec') IS NOT NULL  
		DROP TABLE #temp_rec   
    
	IF OBJECT_ID('tempdb..#temp_del') IS NOT NULL  
		DROP TABLE #temp_del   
  
	CREATE TABLE #deal_term_breakdown (  
		source_deal_header_id INT,   
		term_start DATETIME,   
		term_end DATETIME,    
		leg INT,   
		location_id INT,   
		deal_volume NUMERIC(38, 17),  
		location_of VARCHAR(10) COLLATE DATABASE_DEFAULT 
	)  
	CREATE NONCLUSTERED INDEX IX_SOURCE_DEAL_HEADER_ID_DEAL_TERM_BREAKDOWN ON #deal_term_breakdown (source_deal_header_id)
      	
	SELECT sdh.source_deal_header_id
		, tm.term_start
		, tm.term_end
		, sdd.leg
		, sdd.location_id
		, ISNULL(rvuc.conversion_factor, 1) * CASE WHEN od.volume_used IS NULL THEN sdd.deal_volume ELSE sdd.deal_volume - od.volume_used END [deal_volume]
		, 'REC' [location_of]  
	INTO #temp_rec  
	FROM source_deal_header sdh  
	INNER JOIN source_deal_detail sdd 
		ON sdh.source_deal_header_id = sdd.source_deal_header_id  
		AND sdd.term_start  BETWEEN @term_start AND ISNULL(@term_end, @term_start)  
	INNER JOIN dbo.FNASplit(@receipt_deal_ids, ',') s  
		ON s.item = sdh.source_deal_header_id 
	CROSS APPLY [dbo].[FNATermBreakdown](sdd.deal_volume_frequency, @term_start, @term_end) tm   
	LEFT JOIN optimizer_detail AS od 
		ON od.source_deal_header_id = s.item  
		AND od.flow_date = tm.term_start
	LEFT JOIN rec_volume_unit_conversion rvuc 
		ON rvuc.to_source_uom_id = ISNULL(@uom,-1) 
		AND rvuc.from_source_uom_id = sdd.deal_volume_uom_id
	WHERE  tm.term_start = sdd.term_start  
		AND tm.term_end = sdd.term_end  
		AND sdh.term_frequency = 'd'  
		--AND sdd.location_id = @minor_location  
	UNION ALL   
	SELECT sdh.source_deal_header_id
		, tm.term_start
		, tm.term_end
		, sdd.leg
		, sdd.location_id
		, ISNULL(rvuc.conversion_factor, 1) * CASE WHEN od.volume_used IS NULL THEN sdd.deal_volume ELSE sdd.deal_volume - od.volume_used END
		, 'REC'   
	FROM source_deal_header sdh  
	INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id  
		AND sdd.term_start >= @term_start AND sdd.term_start <= dbo.[FNAGetFirstLastDayOfMonth](@term_end,'l')
	INNER JOIN dbo.FNASplit(@receipt_deal_ids, ',') s ON s.item = sdh.source_deal_header_id   
	CROSS APPLY [dbo].[FNATermBreakdown](sdd.deal_volume_frequency, @term_start, @term_end) tm  
	LEFT JOIN optimizer_detail AS od 
		ON od.source_deal_header_id = s.item   
		AND od.flow_date = tm.term_start
	LEFT JOIN rec_volume_unit_conversion rvuc 
		ON rvuc.to_source_uom_id = ISNULL(@uom,-1) 
		AND rvuc.from_source_uom_id = sdd.deal_volume_uom_id
	WHERE sdh.term_frequency = 'm'  
	--AND sdd.location_id = @minor_location
	OPTION (RECOMPILE)
	
	SELECT sdh.source_deal_header_id
		, tm.term_start
		, tm.term_end
		, sdd.leg
		, sdd.location_id,   
		ISNULL(rvuc.conversion_factor, 1) * CASE WHEN odd.deal_volume IS NULL THEN sdd.deal_volume ELSE sdd.deal_volume - odd.deal_volume END [deal_volume],  
		'DEL' [location_of]  
	INTO #temp_del  
	FROM source_deal_header sdh  
	INNER JOIN source_deal_detail sdd 
		ON sdh.source_deal_header_id = sdd.source_deal_header_id 
		AND sdd.term_start BETWEEN @term_start AND ISNULL(@term_end, @term_start)
	INNER JOIN dbo.FNASplit(@delivery_deal_ids, ',') s  
		ON s.item = sdh.source_deal_header_id   
	CROSS APPLY [dbo].[FNATermBreakdown](sdd.deal_volume_frequency, @term_start, @term_end) tm  
	LEFT JOIN optimizer_detail_downstream AS odd  
		ON odd.source_deal_header_id = s.item   
		AND odd.flow_date = tm.term_start
	LEFT JOIN rec_volume_unit_conversion rvuc 
		ON rvuc.to_source_uom_id = ISNULL(@uom,-1) 
		AND rvuc.from_source_uom_id = sdd.deal_volume_uom_id
	WHERE  tm.term_start = sdd.term_start  
		AND tm.term_end = sdd.term_end  
		AND sdh.term_frequency = 'd'  
		--AND sdd.location_id = @del_location  
	UNION ALL   
	SELECT sdh.source_deal_header_id
		, tm.term_start, tm.term_end
		, sdd.leg, sdd.location_id,   
		ISNULL(rvuc.conversion_factor, 1) * CASE WHEN odd.deal_volume IS NULL THEN sdd.deal_volume ELSE sdd.deal_volume - odd.deal_volume END [deal_volume]
		, 'DEL'  
	FROM source_deal_header sdh  
	INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id 
		AND sdd.term_start >= @term_start AND sdd.term_start <= dbo.[FNAGetFirstLastDayOfMonth](@term_end,'l')
	INNER JOIN dbo.FNASplit(@delivery_deal_ids, ',') s  ON s.item = sdh.source_deal_header_id   
	CROSS APPLY [dbo].[FNATermBreakdown](sdd.deal_volume_frequency, @term_start, @term_end) tm  
	LEFT JOIN optimizer_detail_downstream AS odd  
		ON odd.source_deal_header_id = s.item   
		AND odd.flow_date = tm.term_start
	LEFT JOIN rec_volume_unit_conversion rvuc 
		ON rvuc.to_source_uom_id = ISNULL(@uom,-1) 
		AND rvuc.from_source_uom_id = sdd.deal_volume_uom_id
	WHERE sdh.term_frequency = 'm'  
		--AND sdd.location_id = @del_location  
	OPTION (RECOMPILE)   

	CREATE NONCLUSTERED INDEX IX_SOURCE_DEAL_HEADER_ID_DEAL_TEMP_REC ON #temp_rec (source_deal_header_id, term_start)
	CREATE NONCLUSTERED INDEX IX_SOURCE_DEAL_HEADER_ID_DEAL_TEMP_DEL ON #temp_del (source_deal_header_id, term_start)

SELECT @sum_deal_volume_rec = SUM(deal_volume) FROM #temp_rec
SELECT @sum_deal_volume_del =SUM(deal_volume) FROM #temp_del 
  
 IF ((SELECT sum(deal_volume) FROM #temp_rec) < (SELECT sum(deal_volume) FROM #temp_del))  
 BEGIN  
		SELECT TOP 1 @loss = ISNULL(loss_factor, 0),@is_receipt = is_receipt FROM path_loss_shrinkage WHERE path_id = @path AND contract_id = @contract  
		ORDER BY effective_date DESC
		INSERT INTO #deal_term_breakdown  
		SELECT source_deal_header_id, term_start,	term_end,	leg,	location_id, deal_volume, location_of 
		FROM #temp_rec  
		
		IF ((@sum_deal_volume_rec * (1 - @loss)) > @sum_deal_volume_del)
		BEGIN
			IF @is_receipt = 'd'
			BEGIN
				DELETE FROM #deal_term_breakdown  
				INSERT INTO #deal_term_breakdown  
				SELECT source_deal_header_id
				, term_start
				, term_end
				, leg
				, location_id
				, deal_volume
				, location_of
			FROM #temp_del
			END
		END
		SELECT term_start, volume, location_of 
		INTO #final_data_coll_rec
		FROM (  
		SELECT  dtb.term_start, SUM(dtb.deal_volume) volume, dtb.location_of  
		FROM #deal_term_breakdown dtb  

		GROUP BY dtb.term_start, dtb.term_end, dtb.location_of ) x
		OPTION (RECOMPILE)

		INSERT INTO #temp_avail_volume(term_start, volume, location_of)  
		SELECT term_start, CAST(volume AS NUMERIC(12,0)), location_of 
		FROM #final_data_coll_rec

	END  
	ELSE  
	BEGIN  
		SELECT TOP 1 @loss = ISNULL(loss_factor, 0),@is_receipt = is_receipt FROM path_loss_shrinkage WHERE path_id = @path AND contract_id = @contract  
		ORDER BY effective_date DESC
		INSERT INTO #deal_term_breakdown  
			SELECT source_deal_header_id
				, term_start
				, term_end
				, leg
				, location_id
				, deal_volume
				, location_of
			FROM #temp_del
		IF ((@sum_deal_volume_del / (1 - @loss)) > @sum_deal_volume_rec)
		BEGIN
			IF @is_receipt = 'r'
			BEGIN
				DELETE FROM #deal_term_breakdown  
				INSERT INTO #deal_term_breakdown  
				SELECT source_deal_header_id
				, term_start
				, term_end
				, leg
				, location_id
				, deal_volume
				, location_of
			FROM #temp_rec
			END
		END

		SELECT term_start, volume, location_of 
		INTO #final_data_coll_del
		FROM (  
			SELECT  dtb.term_start, SUM(dtb.deal_volume) volume, dtb.location_of  
			FROM #deal_term_breakdown dtb  
			GROUP BY dtb.term_start, dtb.term_end, dtb.location_of 
		) x
		OPTION (RECOMPILE)

		INSERT INTO #temp_avail_volume(term_start, volume, location_of)  
		SELECT term_start, CAST(volume AS NUMERIC(12,0)), location_of 
		FROM #final_data_coll_del
	END  
   
	IF EXISTS (SELECT 1 FROM delivery_path WHERE path_id = @path AND groupPath = 'n')  
	BEGIN  
		SET @first_child_path_id = @path  
	END  
	ELSE IF EXISTS (SELECT 1 FROM delivery_path WHERE path_id = @path AND groupPath = 'y')  
	BEGIN   
		SELECT TOP 1 @first_child_path_id = dp_child.path_id   
		FROM delivery_path dp   
		INNER JOIN delivery_path_detail dpd  
			ON dp.path_id = dpd.path_id  
		INNER JOIN delivery_path dp_child  
			ON dp_child.path_id = dpd.Path_name  
		WHERE dp.path_id = @path   
			AND dp.groupPath = 'y'  
	END   

--select @term_start,@minor_location,@process_id,@term_end,@receipt_deal_ids  
   
 IF EXISTS (SELECT 1 FROM delivery_path WHERE path_id = @path and groupPath = 'n')  
 BEGIN  
  SET @first_child_path_id = @path  
 END  
 ELSE IF EXISTS (SELECT 1 FROM delivery_path where path_id = @path and groupPath = 'y')  
 BEGIN   
  SELECT top 1 @first_child_path_id = dp_child.path_id   
  FROM delivery_path dp   
   INNER JOIN delivery_path_detail dpd  
    ON dp.path_id = dpd.path_id  
   INNER JOIN delivery_path dp_child  
    ON dp_child.path_id = dpd.Path_name  
  WHERE dp.path_id = @path   
   AND dp.groupPath = 'y'  
 END   

 --update tav set volume = volume - isnull(sub.deal_volume, 0)   
 --from #temp_avail_volume tav  
 -- left join ( select   
 --     max(uddf.udf_value) path_id,  sum(sdd.deal_volume) deal_volume, sdd.term_start   
 --    from user_defined_deal_fields uddf  
 --         inner join user_defined_deal_fields_template uddft   
 --         on uddf.udf_template_id = uddft.udf_template_id  
 --         inner join user_defined_fields_template udft  
 --         on udft.field_id = uddft.field_id  
 --         inner join source_deal_detail sdd  
 --         on sdd.source_deal_header_id = uddf.source_deal_header_id  
 --    where udft.Field_label = 'Delivery Path'  
 --     and uddf.udf_value = cast(@first_child_path_id as varchar(100))  
 --     and sdd.leg = 1  
 --    Group by term_start   
 --  ) sub  
 -- on tav.term_start = sub.term_start   
  
  
 SET @sql = '  
    CREATE TABLE #deal_term_data (  
     id INT IDENTITY(1,1),  
     path_id INT,  
     path VARCHAR(200) COLLATE DATABASE_DEFAULT,  
     volume VARCHAR(10) COLLATE DATABASE_DEFAULT,  
     ' + @cols_dates + '  
    )   
  
    '  
IF @receipt_deal_ids = '' AND @delivery_deal_ids = ''
BEGIN
	SET @loss = 0  
	SELECT @loss = ISNULL(loss_factor, 0) FROM path_loss_shrinkage WHERE path_id = @path AND contract_id = @contract
	SELECT @path_name = Replace(path_name, '''', '''''') FROM delivery_path WHERE path_id = @path 
	SET @sql += ' INSERT INTO #deal_term_data (        
					path_id,  
					path ,  
					volume ,  
					' + @dates + ')   
					SELECT ' + CAST(@path AS VARCHAR(10)) + ', ''' + @path_name + ''', ''Rec'', ' + CAST(@volume AS VARCHAR(20)) + ' UNION ALL   
					SELECT ' + CAST(@path AS VARCHAR(10)) + ', '''', ''Fuel'', ' + ISNULL(@loss_list + ',', '') + CAST(@loss AS VARCHAR(50)) + ' UNION ALL   
					SELECT ' + CAST(@path AS VARCHAR(10)) + ', '''' , ''Del'', ' + CAST(@volume AS VARCHAR(20))
END
ELSE IF @minor_location = ''     
 BEGIN     
  SET @loss = 0  
  SELECT @loss = ISNULL(loss_factor, 0) FROM path_loss_shrinkage WHERE path_id = @path AND contract_id = @contract
  SELECT @path_name = Replace(path_name, '''', '''''') FROM delivery_path WHERE path_id = @path  
    
  SELECT term_start, volume, location_of 
 INTO #temp_avail_volume_del
 FROM (  
	SELECT  dtb.term_start, SUM(dtb.deal_volume) volume, dtb.location_of  
   FROM #temp_del dtb  

  GROUP BY dtb.term_start, dtb.term_end, dtb.location_of ) x


    
		SELECT   
		@rec_vol_list = ISNULL(@rec_vol_list + ',', '') +  CAST(CAST(tav.volume / (1- @loss) AS INT) AS VARCHAR(50)),  
		@loss_list = ISNULL(@loss_list + ',', '') + CAST(@loss AS VARCHAR(50)),  
		@del_vol_list = ISNULL(@del_vol_list + ',', '') + CAST(tav.volume AS VARCHAR(50))      
		FROM seq s  
		INNER JOIN #temp_avail_volume_del tav  
		ON DATEADD(DAY, n-1, CAST(@term_start AS DATE)) = tav.term_start  
		WHERE n <= DATEDIFF(DAY, @term_start, @term_end) + 1  

     
		SET @sql += ' INSERT INTO #deal_term_data (  
        
			path_id,  
			path ,  
			volume ,  
			' + @dates + ')   
			SELECT ' + CAST(@path AS VARCHAR(10)) + ', ''' + @path_name + ''', ''Rec'', ' + @rec_vol_list + ' UNION ALL   
			SELECT ' + CAST(@path AS VARCHAR(10)) + ', '''', ''Fuel'', ' + @loss_list + ' UNION ALL   
			SELECT ' + CAST(@path AS VARCHAR(10)) + ', '''' , ''Del'', ' + @del_vol_list   
	END  
	ELSE IF @del_location = ''  
	BEGIN     
		SET @loss = 0  
		SELECT @loss = ISNULL(loss_factor, 0) 
		FROM path_loss_shrinkage 
		WHERE path_id = @path 
			AND contract_id = @contract  
		
		SELECT @path_name = Replace(path_name, '''', '''''')
		FROM delivery_path 
		WHERE path_id = @path  

SELECT term_start, volume, location_of 
	INTO #temp_avail_volume_rec
	FROM (  
	SELECT  dtb.term_start, SUM(dtb.deal_volume) volume, dtb.location_of  
   FROM #temp_rec dtb  
   GROUP BY dtb.term_start, dtb.term_end, dtb.location_of ) x
    
		SELECT   
			@rec_vol_list = ISNULL(@rec_vol_list + ',', '') +  CAST(tav.volume AS VARCHAR(50))  ,  
			@loss_list = ISNULL(@loss_list + ',', '') + CAST(@loss AS VARCHAR(50)),  
			@del_vol_list = ISNULL(@del_vol_list + ',', '') + CAST(CAST(tav.volume  * (1- @loss) AS INT) AS VARCHAR(50))   
		FROM seq s  
		INNER JOIN #temp_avail_volume_rec tav  
			ON DATEADD(DAY, n-1, CAST(@term_start AS DATE)) = tav.term_start  
		WHERE n <= DATEDIFF(DAY, @term_start, @term_end) + 1  
     
		SET @sql += ' INSERT INTO #deal_term_data (        
					path_id,  
					path ,  
					volume ,  
					' + @dates + ')   
					SELECT ' + CAST(@path AS VARCHAR(10)) + ', ''' + @path_name + ''', ''Rec'', ' + @rec_vol_list + ' UNION ALL   
					SELECT ' + CAST(@path AS VARCHAR(10)) + ', '''', ''Fuel'', ' + @loss_list + ' UNION ALL   
					SELECT ' + CAST(@path AS VARCHAR(10)) + ', '''' , ''Del'', ' + @del_vol_list   
	END  
	ELSE  
	BEGIN   
		IF EXISTS (SELECT 1 FROM delivery_path WHERE path_id = @path AND groupPath = 'n')  
		BEGIN  
			SET @loss = 0  
			SELECT @loss = ISNULL(loss_factor, 0) FROM path_loss_shrinkage WHERE path_id = @path	AND contract_id = @contract  
			SELECT @path_name = Replace(path_name, '''', '''''') FROM delivery_path WHERE path_id = @path  

			SELECT   
				@rec_vol_list = ISNULL(@rec_vol_list + ',', '') + CASE WHEN tav.location_of = 'REC' THEN CAST(tav.volume AS VARCHAR(50)) ELSE CAST(CAST(tav.volume  / (1- @loss) AS INT) AS VARCHAR(50)) END ,  
				@loss_list = ISNULL(@loss_list + ',', '') + CAST(@loss AS VARCHAR(50)),  
				@del_vol_list = ISNULL(@del_vol_list + ',', '') + CASE WHEN tav.location_of = 'DEL' THEN CAST(tav.volume AS VARCHAR(50)) ELSE CAST(CAST(tav.volume  * (1 - @loss)AS INT)AS VARCHAR(50)) END     
			FROM seq s  
			INNER JOIN #temp_avail_volume tav  
				ON DATEADD(DAY, n-1, CAST(@term_start AS DATE)) = tav.term_start  
			WHERE n <= DATEDIFF(DAY, @term_start, @term_end) + 1
      
			SET @sql += ' INSERT INTO #deal_term_data (  
        
				path_id,  
				path ,  
				volume ,  
				' + @dates + ')   
				SELECT ' + CAST(@path AS VARCHAR(10)) + ', ''' + @path_name + ''', ''Rec'', ' + @rec_vol_list + ' UNION ALL   
				SELECT ' + CAST(@path AS VARCHAR(10)) + ', '''', ''Fuel'', ' + @loss_list + ' UNION ALL   
				SELECT ' + CAST(@path AS VARCHAR(10)) + ', '''' , ''Del'', ' + @del_vol_list   

   
		END   
		ELSE IF EXISTS (SELECT 1 FROM delivery_path WHERE path_id = @path AND groupPath = 'y')  
		BEGIN  
			DECLARE group_path_cursor CURSOR FORWARD_ONLY READ_ONLY   
			FOR  
				SELECT dp_child.path_id , Replace(dp_child.path_name, '''', '''''') path_name   
			FROM delivery_path dp   
				INNER JOIN delivery_path_detail dpd  
				ON dp.path_id = dpd.path_id  
				INNER JOIN delivery_path dp_child  
				ON dp_child.path_id = dpd.Path_name  
			WHERE dp.path_id = @path   
				AND dp.groupPath = 'y'  
   
			OPEN group_path_cursor  
			FETCH NEXT FROM group_path_cursor INTO @child_path_id, @child_path_name                                    
			WHILE @@FETCH_STATUS = 0  
			BEGIN  
				SET @loss = 0  
  
				SELECT @loss = ISNULL(loss_factor, 0)   
				FROM path_loss_shrinkage   
				WHERE path_id = @child_path_id  
					AND contract_id = @contract
				IF @count = 0   
				BEGIN  
					SET @rec_vol_list = NULL  
					SET @loss_list = NULL  
					SET @del_vol_list = NULL  
  
					SELECT   
					@rec_vol_list = ISNULL(@rec_vol_list + ',', '') + CASE WHEN tav.location_of = 'REC' THEN CAST(tav.volume AS VARCHAR(50)) ELSE CAST(CAST(tav.volume  / (1 - @loss) AS INT ) AS VARCHAR(50)) END,     
					@loss_list = ISNULL(@loss_list + ',', '') + CAST(@loss AS VARCHAR(50)),  
					@del_vol_list = ISNULL(@del_vol_list + ',', '') + CASE WHEN tav.location_of = 'DEL' THEN CAST(tav.volume AS VARCHAR(50)) ELSE CAST(CAST(tav.volume  * (1 - @loss) AS INT ) AS VARCHAR(50)) END  
					FROM seq s  
					INNER JOIN #temp_avail_volume tav  
					ON DATEADD(DAY, n - 1, @term_start) = tav.term_start  
					WHERE n <= DATEDIFF(DAY, @term_start, @term_end) + 1  
  
				END  
				ELSE  
				BEGIN    
					SET @rec_vol_list = NULL  
					SET @loss_list = NULL  
      
  
					TRUNCATE TABLE #temp_new_rec_vol  
  
					INSERT INTO #temp_new_rec_vol (vol)   
					SELECT * FROM dbo.SplitCommaSeperatedValues(@del_vol_list)  
 
					SET @del_vol_list = NULL  
      
					SELECT   
					@rec_vol_list = ISNULL(@rec_vol_list + ',', '') + CAST(t.vol AS VARCHAR(50)),  
					@loss_list = ISNULL(@loss_list + ',', '') + CAST(@loss AS VARCHAR(50)),  
					@del_vol_list = ISNULL(@del_vol_list + ',', '') + CAST(CAST((t.vol * (1 - @loss)) AS INT) AS VARCHAR(50))  
     
					FROM seq s  
					LEFT JOIN #temp_new_rec_vol t  
					ON s.n = t.n  
					WHERE s.n <= DATEDIFF(DAY,@term_start, @term_end) + 1  
  
  
				END   
  
				SET @sql += ' INSERT INTO #deal_term_data (  
					path_id,  
					path ,  
					volume ,  
					' + @dates + ')   
						SELECT ' + CAST(@child_path_id AS VARCHAR(10)) + ', ''' + @child_path_name + ''', ''Rec'', ' + @rec_vol_list + ' UNION ALL   
						SELECT ' + CAST(@child_path_id AS VARCHAR(10)) + ', '''', ''Fuel'', ' + @loss_list + ' UNION ALL   
						SELECT ' + CAST(@child_path_id AS VARCHAR(10)) + ', '''', ''Del'', ' + @del_vol_list   
    
    SET @count += 1;  
   FETCH NEXT FROM group_path_cursor INTO @child_path_id, @child_path_name         
   END  
   CLOSE group_path_cursor  
   DEALLOCATE group_path_cursor  
  END  
	else if @call_from in ('opt_book_out','opt_book_out_b2b')
	begin
		SELECT   
		@rec_vol_list = ISNULL(@rec_vol_list + ',', '') + CAST(tav.volume AS VARCHAR(50)) ,  
		@loss_list = ISNULL(@loss_list + ',', '') + CAST(0 AS VARCHAR(50)),  
		@del_vol_list = ISNULL(@del_vol_list + ',', '') + CAST(tav.volume AS VARCHAR(50))     
		FROM seq s  
		INNER JOIN #temp_avail_volume tav  
			ON DATEADD(DAY, n-1, cast(@term_start AS DATE)) = tav.term_start  
		WHERE n <= DATEDIFF(DAY, @term_start, @term_end) + 1  
   
		SET @sql += ' INSERT INTO #deal_term_data (  
        
			path_id,  
			path ,  
			volume ,  
			' + @dates + ')   
			SELECT ' + CAST(@path AS VARCHAR(10)) + ', ''Back to Back Path'', ''Rec'', ' + @rec_vol_list + ' UNION ALL   
			SELECT ' + CAST(@path AS VARCHAR(10)) + ', '''', ''Fuel'', ' + @loss_list + ' UNION ALL   
			SELECT ' + CAST(@path AS VARCHAR(10)) + ', '''' , ''Del'', ' + @del_vol_list   
	  end
 END   

	SET @sql += ' SELECT  path_id, path, volume, ' + @dates + ' FROM #deal_term_data'  
   --print @sql
	EXEC (@sql)  

END  
ELSE IF @flag = 'h' --for hour deal match  
BEGIN  
	IF OBJECT_ID('tempdb..#temp_avail_volume_hr') IS NOT NULL   
		DROP TABLE #temp_avail_volume_hr  
  
	IF OBJECT_ID('tempdb..#temp_vol') IS NOT NULL   
		DROP TABLE #temp_vol  
  
	CREATE TABLE #temp_vol (  
		id INT IDENTITY(1,1),  
		path_id INT,  
		path_name VARCHAR(500) COLLATE DATABASE_DEFAULT,  
		volume VARCHAR(10) COLLATE DATABASE_DEFAULT,  
		term_start DATETIME,  
		hr1 NUMERIC(38, 17), hr2 NUMERIC(38, 17), hr3 NUMERIC(38, 17), hr4 NUMERIC(38, 17), hr5 NUMERIC(38, 17),   
		hr6 NUMERIC(38, 17), hr7 NUMERIC(38, 17), hr8 NUMERIC(38, 17), hr9 NUMERIC(38, 17), hr10 NUMERIC(38, 17),   
		hr11 NUMERIC(38, 17), hr12 NUMERIC(38, 17), hr13 NUMERIC(38, 17), hr14 NUMERIC(38, 17), hr15 NUMERIC(38, 17),   
		hr16 NUMERIC(38, 17), hr17 NUMERIC(38, 17), hr18 NUMERIC(38, 17), hr19 NUMERIC(38, 17), hr20 NUMERIC(38, 17),   
		hr21 NUMERIC(38, 17), hr22 NUMERIC(38, 17), hr23 NUMERIC(38, 17), hr24 NUMERIC(38, 17), is_editable CHAR(1) COLLATE DATABASE_DEFAULT  
  
	)  
  
	CREATE TABLE #temp_avail_volume_hr (  
		source_deal_header_id INT,   
		path_id INT,  
		term_start DATE,     
		hr1 NUMERIC(38, 17), hr2 NUMERIC(38, 17), hr3 NUMERIC(38, 17), hr4 NUMERIC(38, 17), hr5 NUMERIC(38, 17),   
		hr6 NUMERIC(38, 17), hr7 NUMERIC(38, 17), hr8 NUMERIC(38, 17), hr9 NUMERIC(38, 17), hr10 NUMERIC(38, 17),   
		hr11 NUMERIC(38, 17), hr12 NUMERIC(38, 17), hr13 NUMERIC(38, 17), hr14 NUMERIC(38, 17), hr15 NUMERIC(38, 17),   
		hr16 NUMERIC(38, 17), hr17 NUMERIC(38, 17), hr18 NUMERIC(38, 17), hr19 NUMERIC(38, 17), hr20 NUMERIC(38, 17),   
		hr21 NUMERIC(38, 17), hr22 NUMERIC(38, 17), hr23 NUMERIC(38, 17), hr24 NUMERIC(38, 17)   
	)  
  
	DECLARE @sdh_id INT  
  
	SELECT @sdh_id = transport_deal_id  
	FROM optimizer_detail  
	WHERE source_deal_header_id =@receipt_deal_ids  
		AND up_down_stream = 'u'  
  
	IF @call_from = 'MATCHED'   
	BEGIN      
		INSERT INTO #temp_avail_volume_hr (  
			source_deal_header_id,   
			path_id,  
			term_start,   
			hr1, hr2, hr3, hr4, hr5, hr6, hr7, hr8, hr9, hr10, hr11, hr12,  
			hr13, hr14, hr15, hr16, hr17, hr18, hr19, hr20, hr21, hr22, hr23, hr24 
		)  
		SELECT rhpd.source_deal_header_id,   
		@path,   
		rhpd.term_start,   
		rhpd.hr1,  
		rhpd.hr2,  
		rhpd.hr3,   
		rhpd.hr4,   
		rhpd.hr5,   
		rhpd.hr6,   
		rhpd.hr7,   
		rhpd.hr8,   
		rhpd.hr9,   
		rhpd.hr10,   
		rhpd.hr11,   
		rhpd.hr12,   
		rhpd.hr13,   
		rhpd.hr14,   
		rhpd.hr15,   
		rhpd.hr16,   
		rhpd.hr17,   
		rhpd.hr18,   
		rhpd.hr19,   
		rhpd.hr20,   
		rhpd.hr21,   
		rhpd.hr22,   
		rhpd.hr23,   
		rhpd.hr24  
		FROM report_hourly_position_deal rhpd    
		WHERE source_deal_header_id = @sdh_id -- 46575   
			AND term_start BETWEEN @term_start AND ISNULL(@term_end, @term_start)  
			AND hr1 >= 0    
	END   
	ELSE   
	BEGIN  
  
		INSERT INTO #temp_avail_volume_hr (  
			source_deal_header_id,   
			path_id,  
			term_start,   
			hr1, hr2, hr3, hr4, hr5, hr6, hr7, hr8, hr9, hr10, hr11, hr12,  
			hr13, hr14, hr15, hr16, hr17, hr18, hr19, hr20, hr21, hr22, hr23, hr24
		)  
		SELECT rhpd.source_deal_header_id,   
			@path,   
			rhpd.term_start,   
			rhpd.hr1 - ISNULL(rhpd1.hr1, 0),  
			rhpd.hr2 - ISNULL(rhpd1.hr2, 0),  
			rhpd.hr3 - ISNULL(rhpd1.hr3, 0),   
			rhpd.hr4 - ISNULL(rhpd1.hr4, 0),   
			rhpd.hr5 - ISNULL(rhpd1.hr5, 0),   
			rhpd.hr6 - ISNULL(rhpd1.hr6, 0),   
			rhpd.hr7 - ISNULL(rhpd1.hr7, 0),   
			rhpd.hr8 - ISNULL(rhpd1.hr8, 0),   
			rhpd.hr9 - ISNULL(rhpd1.hr9, 0),   
			rhpd.hr10 - ISNULL(rhpd1.hr10, 0),  
			rhpd.hr11 - ISNULL(rhpd1.hr11, 0),  
			rhpd.hr12 - ISNULL(rhpd1.hr12, 0),  
			rhpd.hr13 - ISNULL(rhpd1.hr13, 0),  
			rhpd.hr14 - ISNULL(rhpd1.hr14, 0),  
			rhpd.hr15 - ISNULL(rhpd1.hr15, 0),  
			rhpd.hr16 - ISNULL(rhpd1.hr16, 0),  
			rhpd.hr17 - ISNULL(rhpd1.hr17, 0),  
			rhpd.hr18 - ISNULL(rhpd1.hr18, 0),  
			rhpd.hr19 - ISNULL(rhpd1.hr19, 0),  
			rhpd.hr20 - ISNULL(rhpd1.hr20, 0),  
			rhpd.hr21 - ISNULL(rhpd1.hr21, 0),  
			rhpd.hr22 - ISNULL(rhpd1.hr22, 0),  
			rhpd.hr23 - ISNULL(rhpd1.hr23, 0),  
			rhpd.hr24 - ISNULL(rhpd1.hr24, 0)  
		FROM report_hourly_position_deal rhpd   
		LEFT JOIN report_hourly_position_deal rhpd1  
			ON rhpd1.term_start = rhpd.term_start  
			AND rhpd1.hr1 >= 0  
			AND rhpd1.source_deal_header_id = @sdh_id   
		WHERE rhpd.source_deal_header_id = @receipt_deal_ids       
			AND rhpd.term_start BETWEEN @term_start AND ISNULL(@term_end, @term_start)  
			AND rhpd.hr1 >= 0  
	END  
	IF EXISTS (SELECT 1 FROM delivery_path WHERE path_id = @path AND groupPath = 'n')  
	BEGIN  
		SET @first_child_path_id = @path  
	END  
	ELSE IF EXISTS (SELECT 1 FROM delivery_path WHERE path_id = @path AND groupPath = 'y')  
	BEGIN   
		SELECT top 1 @first_child_path_id = dp_child.path_id   
		FROM delivery_path dp   
		INNER JOIN delivery_path_detail dpd  
			ON dp.path_id = dpd.path_id  
		INNER JOIN delivery_path dp_child  
			ON dp_child.path_id = dpd.Path_name  
		WHERE dp.path_id = @path   
		AND dp.groupPath = 'y'  
	END   
   
 
	IF EXISTS (SELECT 1 FROM delivery_path WHERE path_id = @path AND groupPath = 'n')  
	BEGIN  
		INSERT INTO #temp_vol  
		SELECT dp.path_id,      
			CASE vol.volume WHEN 'REC' THEN dp.path_name ELSE NULL END path_name,   
			vol.volume,   
			term_start,    
			CASE vol.volume WHEN 'REC' THEN tav.hr1 WHEN 'Loss' THEN ISNULL(pls.loss_factor, 0) ELSE tav.hr1 * (1 - ISNULL(pls.loss_factor, 0)) END hr1 ,  
			CASE vol.volume WHEN 'REC' THEN tav.hr2 WHEN 'Loss' THEN ISNULL(pls.loss_factor, 0) ELSE tav.hr2 * (1 - ISNULL(pls.loss_factor, 0)) END hr2 ,  
			CASE vol.volume WHEN 'REC' THEN tav.hr3 WHEN 'Loss' THEN ISNULL(pls.loss_factor, 0) ELSE tav.hr3 * (1 - ISNULL(pls.loss_factor, 0)) END hr3 ,  
			CASE vol.volume WHEN 'REC' THEN tav.hr4 WHEN 'Loss' THEN ISNULL(pls.loss_factor, 0) ELSE tav.hr4 * (1 - ISNULL(pls.loss_factor, 0)) END hr4 ,  
			CASE vol.volume WHEN 'REC' THEN tav.hr5 WHEN 'Loss' THEN ISNULL(pls.loss_factor, 0) ELSE tav.hr5 * (1 - ISNULL(pls.loss_factor, 0)) END hr5 ,  
			CASE vol.volume WHEN 'REC' THEN tav.hr6 WHEN 'Loss' THEN ISNULL(pls.loss_factor, 0) ELSE tav.hr6 * (1 - ISNULL(pls.loss_factor, 0)) END hr6 ,  
			CASE vol.volume WHEN 'REC' THEN tav.hr7 WHEN 'Loss' THEN ISNULL(pls.loss_factor, 0) ELSE tav.hr7 * (1 - ISNULL(pls.loss_factor, 0)) END hr7 ,  
			CASE vol.volume WHEN 'REC' THEN tav.hr8 WHEN 'Loss' THEN ISNULL(pls.loss_factor, 0) ELSE tav.hr8 * (1 - ISNULL(pls.loss_factor, 0)) END hr8 ,  
			CASE vol.volume WHEN 'REC' THEN tav.hr9 WHEN 'Loss' THEN ISNULL(pls.loss_factor, 0) ELSE tav.hr9 * (1 - ISNULL(pls.loss_factor, 0)) END hr9 ,  
			CASE vol.volume WHEN 'REC' THEN tav.hr10 WHEN 'Loss' THEN ISNULL(pls.loss_factor, 0) ELSE tav.hr10 * (1 - ISNULL(pls.loss_factor, 0)) END hr10,  
			CASE vol.volume WHEN 'REC' THEN tav.hr11 WHEN 'Loss' THEN ISNULL(pls.loss_factor, 0) ELSE tav.hr11 * (1 - ISNULL(pls.loss_factor, 0)) END hr11,  
			CASE vol.volume WHEN 'REC' THEN tav.hr12 WHEN 'Loss' THEN ISNULL(pls.loss_factor, 0) ELSE tav.hr12 * (1 - ISNULL(pls.loss_factor, 0)) END hr12,  
			CASE vol.volume WHEN 'REC' THEN tav.hr13 WHEN 'Loss' THEN ISNULL(pls.loss_factor, 0) ELSE tav.hr13 * (1 - ISNULL(pls.loss_factor, 0)) END hr13,  
			CASE vol.volume WHEN 'REC' THEN tav.hr14 WHEN 'Loss' THEN ISNULL(pls.loss_factor, 0) ELSE tav.hr14 * (1 - ISNULL(pls.loss_factor, 0)) END hr14,  
			CASE vol.volume WHEN 'REC' THEN tav.hr15 WHEN 'Loss' THEN ISNULL(pls.loss_factor, 0) ELSE tav.hr15 * (1 - ISNULL(pls.loss_factor, 0)) END hr15,  
			CASE vol.volume WHEN 'REC' THEN tav.hr16 WHEN 'Loss' THEN ISNULL(pls.loss_factor, 0) ELSE tav.hr16 * (1 - ISNULL(pls.loss_factor, 0)) END hr16,  
			CASE vol.volume WHEN 'REC' THEN tav.hr17 WHEN 'Loss' THEN ISNULL(pls.loss_factor, 0) ELSE tav.hr17 * (1 - ISNULL(pls.loss_factor, 0)) END hr17,  
			CASE vol.volume WHEN 'REC' THEN tav.hr18 WHEN 'Loss' THEN ISNULL(pls.loss_factor, 0) ELSE tav.hr18 * (1 - ISNULL(pls.loss_factor, 0)) END hr18,  
			CASE vol.volume WHEN 'REC' THEN tav.hr19 WHEN 'Loss' THEN ISNULL(pls.loss_factor, 0) ELSE tav.hr19 * (1 - ISNULL(pls.loss_factor, 0)) END hr19,  
			CASE vol.volume WHEN 'REC' THEN tav.hr20 WHEN 'Loss' THEN ISNULL(pls.loss_factor, 0) ELSE tav.hr20 * (1 - ISNULL(pls.loss_factor, 0)) END hr20,  
			CASE vol.volume WHEN 'REC' THEN tav.hr21 WHEN 'Loss' THEN ISNULL(pls.loss_factor, 0) ELSE tav.hr21 * (1 - ISNULL(pls.loss_factor, 0)) END hr21,  
			CASE vol.volume WHEN 'REC' THEN tav.hr22 WHEN 'Loss' THEN ISNULL(pls.loss_factor, 0) ELSE tav.hr22 * (1 - ISNULL(pls.loss_factor, 0)) END hr22,  
			CASE vol.volume WHEN 'REC' THEN tav.hr23 WHEN 'Loss' THEN ISNULL(pls.loss_factor, 0) ELSE tav.hr23 * (1 - ISNULL(pls.loss_factor, 0)) END hr23,  
			CASE vol.volume WHEN 'REC' THEN tav.hr24 WHEN 'Loss' THEN ISNULL(pls.loss_factor, 0) ELSE tav.hr24 * (1 - ISNULL(pls.loss_factor, 0)) END hr24,  
			CASE WHEN vol.volume IN ('REC', 'Loss') THEN 'y' ELSE 'n' END  
     
		FROM #temp_avail_volume_hr tav       
		INNER JOIN delivery_path dp  
			ON dp.path_id = tav.path_id  
		LEFT JOIN path_loss_shrinkage pls  
			ON pls.path_id = dp.path_id  
			AND contract_id = @contract
		CROSS JOIN (  
			SELECT 1 id, 'Rec' volume UNION ALL  
			SELECT 2, 'Loss' UNION ALL  
			SELECT 3, 'Del'   
		) vol 
		ORDER BY tav.term_start, vol.id    
	END  
	ELSE IF EXISTS (SELECT 1 FROM delivery_path WHERE path_id = @path AND groupPath = 'y')  
	BEGIN  
		IF OBJECT_ID('tempdb..#temp_new_rec_vol_hr') IS NOT NULL   
			DROP TABLE #temp_new_rec_vol_hr  
  
		CREATE TABLE #temp_new_rec_vol_hr (    
			term_start DATE,   
			volume VARCHAR(10) COLLATE DATABASE_DEFAULT,  
			hr1 NUMERIC(38, 17), hr2 NUMERIC(38, 17), hr3 NUMERIC(38, 17), hr4 NUMERIC(38, 17), hr5 NUMERIC(38, 17),   
			hr6 NUMERIC(38, 17), hr7 NUMERIC(38, 17), hr8 NUMERIC(38, 17), hr9 NUMERIC(38, 17), hr10 NUMERIC(38, 17),   
			hr11 NUMERIC(38, 17), hr12 NUMERIC(38, 17), hr13 NUMERIC(38, 17), hr14 NUMERIC(38, 17), hr15 NUMERIC(38, 17),   
			hr16 NUMERIC(38, 17), hr17 NUMERIC(38, 17), hr18 NUMERIC(38, 17), hr19 NUMERIC(38, 17), hr20 NUMERIC(38, 17),   
			hr21 NUMERIC(38, 17), hr22 NUMERIC(38, 17), hr23 NUMERIC(38, 17), hr24 NUMERIC(38, 17)   
		)  
    
	  DECLARE group_path_cursor CURSOR FORWARD_ONLY READ_ONLY   
	  FOR  
			SELECT dp_child.path_id , dp_child.path_name, ISNULL(pls.loss_factor, 0) loss_factor  
			FROM delivery_path dp   
			INNER JOIN delivery_path_detail dpd  
				ON dp.path_id = dpd.path_id  
			INNER JOIN delivery_path dp_child  
				ON dp_child.path_id = dpd.Path_name  
			LEFT JOIN path_loss_shrinkage pls  
				ON pls.path_id = dp_child.path_id  
				AND contract_id = @contract
			WHERE dp.path_id = @path   
				AND dp.groupPath = 'y'  
   
	OPEN group_path_cursor  
	FETCH NEXT FROM group_path_cursor INTO @child_path_id, @child_path_name, @loss_factor                                 
	WHILE @@FETCH_STATUS = 0  
	BEGIN     
		IF @count = 0   
		BEGIN  
			INSERT INTO #temp_vol  
			SELECT @child_path_id,   
				CASE vol.volume WHEN 'REC' THEN @child_path_name ELSE NULL END path_name,   
				vol.volume,   
				term_start,    
				CASE vol.volume WHEN 'REC' THEN tav.hr1 WHEN 'Loss' THEN @loss_factor ELSE tav.hr1 * (1 - @loss_factor) END hr1 ,  
				CASE vol.volume WHEN 'REC' THEN tav.hr2 WHEN 'Loss' THEN @loss_factor ELSE tav.hr2 * (1 - @loss_factor) END hr2 ,  
				CASE vol.volume WHEN 'REC' THEN tav.hr3 WHEN 'Loss' THEN @loss_factor ELSE tav.hr3 * (1 - @loss_factor) END hr3 ,  
				CASE vol.volume WHEN 'REC' THEN tav.hr4 WHEN 'Loss' THEN @loss_factor ELSE tav.hr4 * (1 - @loss_factor) END hr4 ,  
				CASE vol.volume WHEN 'REC' THEN tav.hr5 WHEN 'Loss' THEN @loss_factor ELSE tav.hr5 * (1 - @loss_factor) END hr5 ,  
				CASE vol.volume WHEN 'REC' THEN tav.hr6 WHEN 'Loss' THEN @loss_factor ELSE tav.hr6 * (1 - @loss_factor) END hr6 ,  
				CASE vol.volume WHEN 'REC' THEN tav.hr7 WHEN 'Loss' THEN @loss_factor ELSE tav.hr7 * (1 - @loss_factor) END hr7 ,  
				CASE vol.volume WHEN 'REC' THEN tav.hr8 WHEN 'Loss' THEN @loss_factor ELSE tav.hr8 * (1 - @loss_factor) END hr8 ,  
				CASE vol.volume WHEN 'REC' THEN tav.hr9 WHEN 'Loss' THEN @loss_factor ELSE tav.hr9 * (1 - @loss_factor) END hr9 ,  
				CASE vol.volume WHEN 'REC' THEN tav.hr10 WHEN 'Loss' THEN @loss_factor ELSE tav.hr10 * (1 - @loss_factor) END hr10,  
				CASE vol.volume WHEN 'REC' THEN tav.hr11 WHEN 'Loss' THEN @loss_factor ELSE tav.hr11 * (1 - @loss_factor) END hr11,  
				CASE vol.volume WHEN 'REC' THEN tav.hr12 WHEN 'Loss' THEN @loss_factor ELSE tav.hr12 * (1 - @loss_factor) END hr12,  
				CASE vol.volume WHEN 'REC' THEN tav.hr13 WHEN 'Loss' THEN @loss_factor ELSE tav.hr13 * (1 - @loss_factor) END hr13,  
				CASE vol.volume WHEN 'REC' THEN tav.hr14 WHEN 'Loss' THEN @loss_factor ELSE tav.hr14 * (1 - @loss_factor) END hr14,  
				CASE vol.volume WHEN 'REC' THEN tav.hr15 WHEN 'Loss' THEN @loss_factor ELSE tav.hr15 * (1 - @loss_factor) END hr15,  
				CASE vol.volume WHEN 'REC' THEN tav.hr16 WHEN 'Loss' THEN @loss_factor ELSE tav.hr16 * (1 - @loss_factor) END hr16,  
				CASE vol.volume WHEN 'REC' THEN tav.hr17 WHEN 'Loss' THEN @loss_factor ELSE tav.hr17 * (1 - @loss_factor) END hr17,  
				CASE vol.volume WHEN 'REC' THEN tav.hr18 WHEN 'Loss' THEN @loss_factor ELSE tav.hr18 * (1 - @loss_factor) END hr18,  
				CASE vol.volume WHEN 'REC' THEN tav.hr19 WHEN 'Loss' THEN @loss_factor ELSE tav.hr19 * (1 - @loss_factor) END hr19,  
				CASE vol.volume WHEN 'REC' THEN tav.hr20 WHEN 'Loss' THEN @loss_factor ELSE tav.hr20 * (1 - @loss_factor) END hr20,  
				CASE vol.volume WHEN 'REC' THEN tav.hr21 WHEN 'Loss' THEN @loss_factor ELSE tav.hr21 * (1 - @loss_factor) END hr21,  
				CASE vol.volume WHEN 'REC' THEN tav.hr22 WHEN 'Loss' THEN @loss_factor ELSE tav.hr22 * (1 - @loss_factor) END hr22,  
				CASE vol.volume WHEN 'REC' THEN tav.hr23 WHEN 'Loss' THEN @loss_factor ELSE tav.hr23 * (1 - @loss_factor) END hr23,  
				CASE vol.volume WHEN 'REC' THEN tav.hr24 WHEN 'Loss' THEN @loss_factor ELSE tav.hr24 * (1 - @loss_factor) END hr24,  
				CASE WHEN vol.volume IN ('REC', 'Loss') THEN 'y' ELSE 'n' END  
			FROM #temp_avail_volume_hr tav  
			CROSS JOIN (  
				SELECT 1 id,  'Rec' volume UNION ALL  
				SELECT 2, 'Loss' UNION ALL  
				SELECT 3, 'Del'   
			) vol 
			ORDER BY tav.term_start, vol.id  
  
			INSERT INTO #temp_new_rec_vol_hr  
			SELECT term_start, volume, hr1, hr2, hr3, hr4, hr5, hr6, hr7, hr8, hr9, hr10, hr11, hr12,  
				hr13, hr14, hr15, hr16, hr17, hr18, hr19, hr20, hr21, hr22, hr23, hr24   
			FROM #temp_vol  
			WHERE volume = 'del'  
  
		END  
		ELSE      
		BEGIN  
			INSERT INTO #temp_vol  
			SELECT @child_path_id,   
				CASE vol.volume WHEN 'REC' THEN @child_path_name ELSE NULL END path_name,   
				vol.volume,   
				tav.term_start,    
				CASE vol.volume WHEN 'REC' THEN tv.hr1 WHEN 'Loss' THEN @loss_factor ELSE tv.hr1 * (1 - @loss_factor) END hr1 ,  
				CASE vol.volume WHEN 'REC' THEN tv.hr2 WHEN 'Loss' THEN @loss_factor ELSE tv.hr2 * (1 - @loss_factor) END hr2 ,  
				CASE vol.volume WHEN 'REC' THEN tv.hr3 WHEN 'Loss' THEN @loss_factor ELSE tv.hr3 * (1 - @loss_factor) END hr3 ,  
				CASE vol.volume WHEN 'REC' THEN tv.hr4 WHEN 'Loss' THEN @loss_factor ELSE tv.hr4 * (1 - @loss_factor) END hr4 ,  
				CASE vol.volume WHEN 'REC' THEN tv.hr5 WHEN 'Loss' THEN @loss_factor ELSE tv.hr5 * (1 - @loss_factor) END hr5 ,  
				CASE vol.volume WHEN 'REC' THEN tv.hr6 WHEN 'Loss' THEN @loss_factor ELSE tv.hr6 * (1 - @loss_factor) END hr6 ,  
				CASE vol.volume WHEN 'REC' THEN tv.hr7 WHEN 'Loss' THEN @loss_factor ELSE tv.hr7 * (1 - @loss_factor) END hr7 ,  
				CASE vol.volume WHEN 'REC' THEN tv.hr8 WHEN 'Loss' THEN @loss_factor ELSE tv.hr8 * (1 - @loss_factor) END hr8 ,  
				CASE vol.volume WHEN 'REC' THEN tv.hr9 WHEN 'Loss' THEN @loss_factor ELSE tv.hr9 * (1 - @loss_factor) END hr9 ,  
				CASE vol.volume WHEN 'REC' THEN tv.hr10 WHEN 'Loss' THEN @loss_factor ELSE tv.hr10 * (1 - @loss_factor) END hr10,  
				CASE vol.volume WHEN 'REC' THEN tv.hr11 WHEN 'Loss' THEN @loss_factor ELSE tv.hr11 * (1 - @loss_factor) END hr11,  
				CASE vol.volume WHEN 'REC' THEN tv.hr12 WHEN 'Loss' THEN @loss_factor ELSE tv.hr12 * (1 - @loss_factor) END hr12,  
				CASE vol.volume WHEN 'REC' THEN tv.hr13 WHEN 'Loss' THEN @loss_factor ELSE tv.hr13 * (1 - @loss_factor) END hr13,  
				CASE vol.volume WHEN 'REC' THEN tv.hr14 WHEN 'Loss' THEN @loss_factor ELSE tv.hr14 * (1 - @loss_factor) END hr14,  
				CASE vol.volume WHEN 'REC' THEN tv.hr15 WHEN 'Loss' THEN @loss_factor ELSE tv.hr15 * (1 - @loss_factor) END hr15,  
				CASE vol.volume WHEN 'REC' THEN tv.hr16 WHEN 'Loss' THEN @loss_factor ELSE tv.hr16 * (1 - @loss_factor) END hr16,  
				CASE vol.volume WHEN 'REC' THEN tv.hr17 WHEN 'Loss' THEN @loss_factor ELSE tv.hr17 * (1 - @loss_factor) END hr17,  
				CASE vol.volume WHEN 'REC' THEN tv.hr18 WHEN 'Loss' THEN @loss_factor ELSE tv.hr18 * (1 - @loss_factor) END hr18,  
				CASE vol.volume WHEN 'REC' THEN tv.hr19 WHEN 'Loss' THEN @loss_factor ELSE tv.hr19 * (1 - @loss_factor) END hr19,  
				CASE vol.volume WHEN 'REC' THEN tv.hr20 WHEN 'Loss' THEN @loss_factor ELSE tv.hr20 * (1 - @loss_factor) END hr20,  
				CASE vol.volume WHEN 'REC' THEN tv.hr21 WHEN 'Loss' THEN @loss_factor ELSE tv.hr21 * (1 - @loss_factor) END hr21,  
				CASE vol.volume WHEN 'REC' THEN tv.hr22 WHEN 'Loss' THEN @loss_factor ELSE tv.hr22 * (1 - @loss_factor) END hr22,  
				CASE vol.volume WHEN 'REC' THEN tv.hr23 WHEN 'Loss' THEN @loss_factor ELSE tv.hr23 * (1 - @loss_factor) END hr23,  
				CASE vol.volume WHEN 'REC' THEN tv.hr24 WHEN 'Loss' THEN @loss_factor ELSE tav.hr24 * (1 - @loss_factor) END hr24,  
				'n'  
			FROM #temp_avail_volume_hr tav  
			CROSS JOIN (  
				SELECT 1 id,  'Rec' volume UNION ALL  
				SELECT 2, 'Loss' UNION ALL  
				SELECT 3, 'Del'   
			) vol    
			LEFT JOIN #temp_new_rec_vol_hr tv   
				ON tv.term_start = tav.term_start 
			ORDER BY tav.term_start, vol.id  
  
			TRUNCATE TABLE #temp_new_rec_vol_hr  
  
			--SELECT * FROM #temp_new_rec_vol  
			INSERT INTO #temp_new_rec_vol_hr  
			SELECT term_start, volume, hr1, hr2, hr3, hr4, hr5, hr6, hr7, hr8, hr9, hr10, hr11, hr12,  
				hr13, hr14, hr15, hr16, hr17, hr18, hr19, hr20, hr21, hr22, hr23, hr24   
			FROM #temp_vol  
			WHERE volume = 'del'  
				AND path_id = @child_path_id  
		END  
		SET @count += 1;  
		FETCH NEXT FROM group_path_cursor INTO @child_path_id, @child_path_name, @loss_factor     
		
	END  
	CLOSE group_path_cursor  
	DEALLOCATE group_path_cursor  
  
END  
   
	DECLARE @hrs VARCHAR(1000)  
   
	SELECT @hrs = ISNULL(@hrs + ',', '') + 'CAST(hr' + CAST(item AS VARCHAR(3)) + ' AS NUMERIC(38, 2)) hr'   
		+ CAST(item AS VARCHAR(3))  
	FROM dbo.SplitCommaSeperatedValues(@period_from)  
  
	SET @sql = 'SELECT   
		path_id,   
		is_editable,  
		path_name,   
		volume,   
		CASE WHEN volume =''REC'' AND is_editable = ''y'' THEN dbo.FNADateFormat(term_start) ELSE NULL END term_start1,  
	' + @hrs +   
	' FROM #temp_vol ORDER BY term_start,id'   
	 
	EXEC(@sql)  
 
END  
  
ELSE IF @flag='m' -- To Show already matched data  
BEGIN  
	IF OBJECT_ID('tempdb..#temp_del_volume') IS NOT NULL  
		DROP TABLE #temp_del_volume   
    
	CREATE TABLE #temp_del_volume (  
		term_start DATETIME,  
		volume INT,  
		location_of VARCHAR(10)  COLLATE DATABASE_DEFAULT 

	)   
   
	SELECT @cols_dates = ISNULL(@cols_dates + ',', '') + 'day' + CAST(n AS VARCHAR(5)) + ' FLOAT',  
		@dates = ISNULL(@dates + ',', '') + 'day' + CAST(n AS VARCHAR(5))   
	FROM seq  
	WHERE n <= DATEDIFF(DAY, @term_start, @term_end) + 1  

	SELECT @contract  = sdh.contract_id 
	FROM optimizer_detail od
	INNER JOIN source_Deal_header sdh
		ON od.transport_deal_id = sdh.source_deal_header_id
	INNER JOIN dbo.splitCommaSeperatedValues(@receipt_deal_ids) t
		ON t.item =  od.source_deal_header_id


	INSERT INTO #temp_avail_volume(term_start, volume, location_of)  
	EXEC spa_get_loss_factor_volume @flag ='o', @path = @path, @receipt_deal_ids = @receipt_deal_ids, @term_start = @term_start, @term_end = @term_end  

	INSERT INTO #temp_del_volume(term_start, volume, location_of)  
	EXEC spa_get_loss_factor_volume @flag ='p', @path = @path, @delivery_deal_ids = @delivery_deal_ids, @term_start = @term_start, @term_end = @term_end  

	INSERT INTO #temp_avail_volume(term_start, volume, location_of)  
	SELECT DATEADD(DAY, n-1, @term_start)
		, 0 
		, 'Rec'  
	FROM seq s   
	LEFT JOIN #temp_avail_volume t  
		ON t.term_start = DATEADD(DAY, n - 1, @term_start)  
	WHERE DATEADD(DAY, n - 1, @term_start) <= @term_end  
		AND t.term_start IS NULL 
		AND t.location_of = 'Rec'  
   
	INSERT INTO #temp_del_volume(term_start, volume, location_of)  
	SELECT DATEADD(DAY, n-1, @term_start)
		, 0 
		, 'Del'  
	FROM seq s   
	LEFT JOIN #temp_del_volume t  
		ON t.term_start = DATEADD(DAY, n - 1, @term_start)  
	WHERE DATEADD(DAY, n - 1, @term_start) <= @term_end  
		AND t.term_start IS NULL 
		AND t.location_of = 'Del'  
  

	IF EXISTS (SELECT 1 FROM delivery_path WHERE path_id = @path AND groupPath = 'n')  
	BEGIN  
		SET @first_child_path_id = @path  
	END  
	ELSE IF EXISTS (SELECT 1 FROM delivery_path WHERE path_id = @path AND groupPath = 'y')  
	BEGIN   
		SELECT top 1 @first_child_path_id = dp_child.path_id   
		FROM delivery_path dp   
		INNER JOIN delivery_path_detail dpd  
			ON dp.path_id = dpd.path_id  
		INNER JOIN delivery_path dp_child  
			ON dp_child.path_id = dpd.Path_name  
		WHERE dp.path_id = @path   
			AND dp.groupPath = 'y'  
	END   
  
	SET @sql = '  
	CREATE TABLE #deal_term_data (  
		id INT IDENTITY(1,1),  
		path_id INT,  
		path VARCHAR(200) COLLATE DATABASE_DEFAULT,  
		volume VARCHAR(10) COLLATE DATABASE_DEFAULT,  
		' + @cols_dates + '  
	)   
  
	'  
    
	IF EXISTS (SELECT 1 FROM delivery_path WHERE path_id = @path AND groupPath = 'n')  
	BEGIN  

		SET @loss = 0  
		
		SELECT @loss = ISNULL(loss_factor, 0) 
		FROM path_loss_shrinkage 
		WHERE path_id = @path 
		AND contract_id = @contract

		SELECT @path_name = path_name 
		FROM delivery_path 
		WHERE path_id = @path  
    
		SELECT   
			@rec_vol_list = ISNULL(@rec_vol_list + ',', '') + CAST(ISNULL(tav.volume, 0) AS VARCHAR(50)) ,  
			@loss_list = ISNULL(@loss_list + ',', '') + CAST(@loss AS VARCHAR(50)),  
			@del_vol_list = ISNULL(@del_vol_list + ',', '') + CAST(CAST((ISNULL(tav.volume, 0) * (1 - @loss)) AS INT) AS VARCHAR(50))   
		FROM seq s  
		LEFT JOIN #temp_avail_volume tav  
			ON DATEADD(DAY, n-1, CAST(@term_start AS DATE)) = tav.term_start  
		WHERE n <= DATEDIFF(DAY, @term_start, @term_end) + 1  
          
		SET @sql += ' INSERT INTO #deal_term_data (  
        
			path_id,  
			path ,  
			volume ,  
			' + @dates + ')   
			SELECT ' + CAST(@path AS VARCHAR(10)) + ', ''' + @path_name + ''', ''Rec'', ' + @rec_vol_list + ' UNION ALL   
			SELECT ' + CAST(@path AS VARCHAR(10)) + ', '''', ''Fuel'', ' + @loss_list + ' UNION ALL   
			SELECT ' + CAST(@path AS VARCHAR(10)) + ', '''' , ''Del'', ' + @del_vol_list   
   
	END   
	ELSE IF EXISTS (SELECT 1 FROM delivery_path WHERE path_id = @path AND groupPath = 'y')  
	BEGIN  
		DECLARE group_path_cursor CURSOR FORWARD_ONLY READ_ONLY   
		FOR  
			SELECT dp_child.path_id 
				, dp_child.path_name  
			FROM delivery_path dp   
			INNER JOIN delivery_path_detail dpd  
				ON dp.path_id = dpd.path_id  
			INNER JOIN delivery_path dp_child  
				ON dp_child.path_id = dpd.Path_name  
			WHERE dp.path_id = @path   
				AND dp.groupPath = 'y'  
   
		OPEN group_path_cursor  
		FETCH NEXT FROM group_path_cursor INTO @child_path_id, @child_path_name                                    
		WHILE @@FETCH_STATUS = 0  
		BEGIN  
			SET @loss = 0  
  
			SELECT @loss = ISNULL(loss_factor, 0)   
			FROM path_loss_shrinkage   
			WHERE path_id = @child_path_id
			AND contract_id = @contract  
     
     
			IF @count = 0   
			BEGIN  
				SET @rec_vol_list = NULL  
				SET @loss_list = NULL  
				SET @del_vol_list = NULL      
       
				SELECT   
					@rec_vol_list = ISNULL(@rec_vol_list + ',', '') + CAST(ISNULL(tav.volume, 0) AS VARCHAR(50)),   
					@loss_list = ISNULL(@loss_list + ',', '') + CAST(@loss AS VARCHAR(50)),  
					@del_vol_list = ISNULL(@del_vol_list + ',', '') + CAST(CAST(ISNULL(tav.volume, 0) * (1 - @loss) AS INT) AS VARCHAR(50))        
				FROM seq s  
					LEFT JOIN #temp_avail_volume tav  
					ON DATEADD(DAY, n - 1, @term_start) = tav.term_start  
				WHERE n <= DATEDIFF(DAY, @term_start, @term_end) + 1   
			END  
			ELSE  
			BEGIN  
  
				SET @rec_vol_list = NULL  
				SET @loss_list = NULL  
      
  
				TRUNCATE TABLE #temp_new_rec_vol  
  
				INSERT INTO #temp_new_rec_vol (vol)   
				SELECT * FROM dbo.SplitCommaSeperatedValues(@del_vol_list)  
      
				SET @del_vol_list = NULL  
      
				SELECT   
					@rec_vol_list = ISNULL(@rec_vol_list + ',', '') + CAST(t.vol AS VARCHAR(50)) ,  
					@loss_list = ISNULL(@loss_list + ',', '') + CAST(@loss AS VARCHAR(50)),  
					@del_vol_list = ISNULL(@del_vol_list + ',', '') + CAST(CAST((t.vol * (1 - @loss)) AS INT) AS VARCHAR(50))   
     
				FROM seq s  
					LEFT JOIN #temp_new_rec_vol t  
					ON s.n = t.n  
				WHERE s.n <= DATEDIFF(DAY,@term_start, @term_end) + 1  
  
  
			END   
  
			SET @sql += ' INSERT INTO #deal_term_data (  
				path_id,  
				path ,  
				volume ,  
				' + @dates + ')   
				SELECT ' + CAST(@child_path_id AS VARCHAR(10)) + ', ''' + @child_path_name + ''', ''Rec'', ' + @rec_vol_list + ' UNION ALL   
				SELECT ' + CAST(@child_path_id AS VARCHAR(10)) + ', '''', ''Fuel'', ' + @loss_list + ' UNION ALL   
				SELECT ' + CAST(@child_path_id AS VARCHAR(10)) + ', '''', ''Del'', ' + @del_vol_list   
    
			SET @count += 1;  
			FETCH NEXT FROM group_path_cursor INTO @child_path_id, @child_path_name         
		END  
		CLOSE group_path_cursor  
		DEALLOCATE group_path_cursor  
	END  
  
	SET @sql += ' SELECT  path_id, path, volume, ' + @dates + ' FROM #deal_term_data'  
   
	EXEC (@sql)  
  
END  
ELSE IF @flag='o'  
BEGIN  		
	SELECT od.flow_date,   
		--MAX(sdd2.deal_volume) - SUM(sdd.deal_volume) [deal_volume],  
		MAX(sdd.deal_volume) [deal_volume],  
		'Rec' [location_of]  
	FROM optimizer_detail od   
	INNER  JOIN dbo.SplitCommaSeperatedValues(@receipt_deal_ids) t  
		ON t.item = od.source_deal_header_id  
		AND up_down_stream='u'  
	LEFT JOIN  source_deal_detail sdd  
		ON sdd.source_Deal_header_id = od.transport_deal_id    
		AND sdd.term_start = od.flow_date   
	INNER JOIN source_deal_header sdh
		ON sdh.source_deal_header_id = sdd.source_deal_header_id
	INNER JOIN source_deal_header_template sdht  
		ON sdht.template_id = sdh.template_id    
	INNER JOIN user_defined_deal_fields_template uddft   
		ON uddft.template_id = sdh.template_id  
	INNER JOIN user_defined_deal_fields uddf  
		ON uddf.source_deal_header_id = sdh.source_deal_header_id   
		AND uddft.udf_template_id = uddf.udf_template_id  
	WHERE sdd.leg = 1 
		AND od.flow_date >= @term_start 
		AND od.flow_date <= @term_end 
		AND od.source_deal_header_id = t.item  
		AND  uddft.field_label = 'Delivery Path'  
		AND uddf.udf_value = CAST(@path AS VARCHAR(10))
	GROUP BY od.flow_date    
END  
ELSE IF @flag='p' --To get available volume of delivery deals  
BEGIN  
	SELECT DISTINCT d.term_start,  
		ISNULL(odd.deal_volume,0) [deal_volume],  
		'Del' [location_of]       
	FROM source_deal_header sdh  
	INNER JOIN dbo.SplitCommaSeperatedValues(@delivery_deal_ids) t   
		ON t.item = sdh.source_deal_header_id   
	LEFT JOIN dbo.FNATermBreakdown('d',@term_start,@term_end) d  
		ON d.term_start >= @term_start AND d.term_start <= @term_end  
	LEFT JOIN optimizer_detail_downstream AS odd    
		ON sdh.source_deal_header_id = odd.source_deal_header_id 
		AND odd.flow_date = d.term_start  
	WHERE d.term_start >= @term_start 
		AND d.term_end <= @term_end  
	END    
ELSE IF @flag = 'f'  
BEGIN  
	DECLARE @source_deal_header_ids VARCHAR(1000)  
  
	SELECT  @source_deal_header_ids = ISNULL(@source_deal_header_ids + ',', '') + CAST(transport_deal_id AS VARCHAR(10))  
	FROM optimizer_detail od  
	INNER JOIN dbo.SplitCommaSeperatedValues(@receipt_deal_ids) t  
		ON t.item = od.source_deal_header_id  
	WHERE up_down_stream = 'u'  
  
	EXEC spa_source_deal_header @flag = 'd', @deal_ids = @source_deal_header_ids, @comments = 'Deleted FROM flow deal match.'  
  
END  
  