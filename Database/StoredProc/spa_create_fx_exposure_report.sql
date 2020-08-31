
/****** Object:  StoredProcedure [dbo].[spa_create_fx_exposure_report]    Script Date: 07/24/2011 21:39:33 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_create_fx_exposure_report]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_create_fx_exposure_report]
GO

-- EXEC spa_create_fx_exposure_report '2011-06-30', NULL, NULL, NULL, 4500, 5, NULL, NULL, NULL, 4, 1
CREATE PROCEDURE [dbo].[spa_create_fx_exposure_report](
	@as_of_date  VARCHAR(20),
	@sub_id VARCHAR(MAX), 
	@strategy_id VARCHAR(MAX), 
	@book_id VARCHAR(MAX), 
	@curve_source_value_id INT, 
	@report_group INT, 
	@deal_status VARCHAR(500),
	@source_deal_header_id INT, 
	@deal_id VARCHAR(100),	
	@round_value INT, 
	@calc  INT,
	@deal_list_table VARCHAR(300) = NULL, -- contains list of deals to be processed
	@batch_process_id VARCHAR(50)=NULL,  
	@batch_report_param VARCHAR(1000)=NULL,
	@enable_paging INT = 0,  --'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL
)
AS

SET NOCOUNT ON 

/*
-- 0. No report output  1. Sub 2. Sub,Strategy 3. Sub, Strategy, Book 4. Sub, Strategy, Book, Index 5. Detailed
DECLARE @as_of_date  VARCHAR(20)
DECLARE @sub_id VARCHAR(100), @strategy_id VARCHAR(100), @book_id VARCHAR(100), @source_deal_header_id INT, @deal_id VARCHAR(100),
		@curve_source_value_id INT, @round_value INT, @calc  INT, @report_group INT, @deal_status INT,
		@batch_process_id VARCHAR(50), @batch_report_param VARCHAR(1000), @enable_paging INT, @page_size INT, @page_no INT

DROP TABLE #books
DROP TABLE #report
DROP TABLE #deal_status
DROP TABLE #calc_status
DROP TABLE #fx_exposure
drop table #curve_list
drop table #formula_position

SET @as_of_date = '2011-11-15'
SET @curve_source_value_id = 4500
SET @calc = 0
SET @source_deal_header_id = 45215 -- 3866
SET @report_group = 5
SET @round_value=6

-- select * from #curve_list
-- select * from #formula_position
-- select * from #fx_exposure
-- select * from #lag_curve

--*/
------------------



---START Batch initilization--------------------------------------------------------
--------------------------------------------------------------------------------------
DECLARE @str_batch_table VARCHAR(8000)
DECLARE @is_batch BIT
DECLARE @sql_paging VARCHAR(8000)
DECLARE @user_login_id VARCHAR(50)
DECLARE @print_diagnostic INT
DECLARE @log_time datetime
DECLARE @pr_name VARCHAR(5000)
DECLARE @log_increment 	int
CREATE TABLE #source_deal_header_id (source_deal_header_id INT)
IF OBJECT_ID(@deal_list_table) IS NOT NULL
BEGIN
    EXEC ('INSERT INTO #source_deal_header_id  SELECT DISTINCT source_deal_header_id FROM ' + @deal_list_table)
END

DECLARE @baseload_block_type varchar(30),
		@baseload_block_define_id varchar(30)

SET @baseload_block_type = '12000'	-- Internal Static Data
SELECT @baseload_block_define_id = CAST(value_id as VARCHAR(10)) FROM static_data_value WHERE [type_id] = 10018 AND code LIKE 'Base Load' -- External Static Data
IF @baseload_block_define_id IS NULL 
	SET @baseload_block_define_id = 'NULL'



SET @str_batch_table = ''
SET @user_login_id = dbo.FNADBUser() 

SET @print_diagnostic = 1


If @print_diagnostic = 1
begin
	set @log_increment = 1
	print '******************************************************************************************'
	print '********************START &&&&&&&&&[spa_calc_mtm_job]**********'
end

--Start tracking time for Elapse time
DECLARE @begin_time DATETIME
SET @begin_time = GETDATE()

SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END		

IF @is_batch = 1
	SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)
	
IF @batch_process_id IS NULL
	SET @batch_process_id = dbo.FNAGetNewID()	
IF @enable_paging = 1 --paging processing
BEGIN
	SET @str_batch_table = dbo.FNAPagingProcess('p', @batch_process_id, @page_size, @page_no)

	--retrieve data from paging table instead of main table
	IF @page_no IS NOT NULL  
	BEGIN
		SET @sql_paging = dbo.FNAPagingProcess('s', @batch_process_id, @page_size, @page_no)    
		EXEC (@sql_paging)  
		RETURN  
	END
END

---END Batch initilization--------------------------------------------------------
--------------------------------------------------------------------------------------

IF @round_value IS NULL 
	SET @round_value = 2
IF @calc IS NULL 
	SET @calc = 0

DECLARE @SQL VARCHAR(2500)

IF @deal_id IS NOT NULL AND @source_deal_header_id IS NULL
	SELECT @source_deal_header_id = source_deal_header_id FROM source_deal_header WHERE deal_id = @deal_id

--If deal does not exist then use a non existing source_deal_header_id
IF 	@deal_id IS NOT NULL AND @source_deal_header_id IS NULL
	SET @source_deal_header_id  = -5555555
	
If @print_diagnostic = 1
begin
	set @pr_name= 'sql_log_' + cast(@log_increment as varchar)
	set @log_increment = @log_increment + 1
	set @log_time=getdate()
	print @pr_name+' Running..............'
end


CREATE TABLE #books ( 
	 fas_book_id INT
	,fas_stra_id INT
	,fas_sub_id INT
	,func_cur_id INT
	,source_system_book_id1 INT
	,source_system_book_id2 INT
	,source_system_book_id3 INT
	,source_system_book_id4  INT
	,fas_deal_type_value_id INT
	,sub_name VARCHAR(100) COLLATE DATABASE_DEFAULT
	,str_name VARCHAR(100) COLLATE DATABASE_DEFAULT
	,book_name VARCHAR(100) COLLATE DATABASE_DEFAULT
) 

 
SET @SQL = '
	INSERT INTO #books
	SELECT DISTINCT sbm.fas_book_id,stra.entity_id,stra.parent_entity_id,fs.func_cur_value_id func_cur_id,
	       source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,
	       sbm.fas_deal_type_value_id,sub.entity_name sub_name,stra.entity_name str_name,book.entity_name book_name
	FROM portfolio_hierarchy book (nolock) 
		INNER JOIN	Portfolio_hierarchy stra(NOLOCK) ON book.parent_entity_id = stra.entity_id 
		INNER JOIN Portfolio_hierarchy sub(NOLOCK) ON stra.parent_entity_id = sub.entity_id 
		INNER JOIN	source_system_book_map sbm ON sbm.fas_book_id = book.entity_id   
		INNER JOIN  fas_subsidiaries fs ON fs.fas_subsidiary_id = stra.parent_entity_id      
	WHERE 1=1 '   
	+CASE WHEN (ISNULL(@sub_id, '') <> '') THEN  ' AND sub.entity_id in ('+@sub_id + ')' ELSE '' END 
	+CASE WHEN (ISNULL(@strategy_id, '') <> '') THEN  ' AND stra.entity_id in ('+@strategy_id + ')'	ELSE '' END 
	+CASE WHEN (ISNULL(@book_id, '') <> '') THEN  ' AND book.entity_id in ('+@book_id + ')'	ELSE '' END
	
-- print @SQL
EXEC(@SQL)

CREATE INDEX indx_books ON #books(source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4)

If @print_diagnostic = 1
BEGIN
	print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
	print '**************** End of Collecting Books *****************************'	
END

IF @calc = 1
BEGIN

	CREATE TABLE #calc_status
	(
		process_id     VARCHAR(100) COLLATE DATABASE_DEFAULT,
		ErrorCode      VARCHAR(50) COLLATE DATABASE_DEFAULT,
		Module         VARCHAR(100) COLLATE DATABASE_DEFAULT,
		Source         VARCHAR(100) COLLATE DATABASE_DEFAULT,
		type           VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[description]  VARCHAR(1000) COLLATE DATABASE_DEFAULT,
		[nextstep]     VARCHAR(250) COLLATE DATABASE_DEFAULT
	)


	CREATE TABLE #fx_exposure(as_of_date DATETIME, source_deal_header_id INT, exp_side VARCHAR(100) COLLATE DATABASE_DEFAULT, phy_fin varchar(1) COLLATE DATABASE_DEFAULT, 
			curve_id INT, monthly_term DATETIME, volume float, volume_uom_id INT, uom_conf_factor float, curve_value float, 
			fx_exposure float, currency_id INT, price_uom_id INT)

	If @print_diagnostic = 1
	begin
		set @pr_name= 'sql_log_' + cast(@log_increment as varchar)
		set @log_increment = @log_increment + 1
		set @log_time=getdate()
		print @pr_name+' Running..............'
	end

DECLARE @sql_str varchar(MAX),@sql_str1 varchar(MAX),@sql_str2 varchar(MAX)
				

	/***** STEP 1  **************/
	--Gather physical shaped and deal volume based deals (position table: report_hourly_position_deal) which has curve_id that is non functional currency
	--Exposure = Non expired Position * Market Price * Convert Price UOM to Position UOM if not the same
	SET @sql_str = 'INSERT INTO #fx_exposure
	SELECT	 ''' + @as_of_date + ''' as_of_date,
				rd.source_deal_header_id, 
				''Market'' exp_side, 
				MAX(rd.physical_financial_flag) phy_fin,		
				rd.curve_id, 
				CAST(CAST(YEAR(rd.term_start) AS VARCHAR) + ''-'' + CAST(MONTH(rd.term_start) AS VARCHAR) + ''-01'' AS DATETIME) monthly_term, 
				round(SUM(hr1+hr2+hr3+hr4+hr5+hr6+hr7+hr8+hr9+hr10+hr11+hr12+hr13+hr14+hr15+hr16+hr17+hr18+hr19+hr20+hr21+hr22+hr23+hr24),6) volume,
				MAX(rd.deal_volume_uom_id) volume_uom_id, 
				MAX(ISNULL(vuc1.conversion_factor, 1)) uom_conv_factor, 
				SUM(
				(hr1+hr2+hr3+hr4+hr5+hr6+hr7+hr8+hr9+hr10+hr11+hr12+hr13+hr14+hr15+hr16+hr17+hr18+hr19+hr20+hr21+hr22+hr23+hr24) *
				coalesce(spc1.curve_value, spc2.curve_value, spc3.curve_value, spc4.curve_value) *				
				ISNULL(sc1.factor, 1) * 
				CASE WHEN(spcd1.uom_id <> rd.deal_volume_uom_id) THEN ISNULL(vuc1.conversion_factor, 1) ELSE 1 END 
				)/SUM(hr1+hr2+hr3+hr4+hr5+hr6+hr7+hr8+hr9+hr10+hr11+hr12+hr13+hr14+hr15+hr16+hr17+hr18+hr19+hr20+hr21+hr22+hr23+hr24)  curve_value,
				SUM(
				(hr1+hr2+hr3+hr4+hr5+hr6+hr7+hr8+hr9+hr10+hr11+hr12+hr13+hr14+hr15+hr16+hr17+hr18+hr19+hr20+hr21+hr22+hr23+hr24) *
				coalesce(spc1.curve_value, spc2.curve_value, spc3.curve_value, spc4.curve_value) *				
				ISNULL(sc1.factor, 1) * 
				CASE WHEN(spcd1.uom_id <> rd.deal_volume_uom_id) THEN ISNULL(vuc1.conversion_factor, 1) ELSE 1 END 
				)
				fx_exposure,
				MAX(ISNULL(sc1.currency_id_to, spcd1.source_currency_id)) currency_id, 				
				NULL price_uom_id
	FROM	report_hourly_position_deal_main rd 
				inner join dbo.position_report_group_map g on g.rowid=rd.rowid
				inner join dbo.source_system_book_map ssbm on ssbm.book_deal_type_map_id=g.subbook_id				
				INNER JOIN #books books ON 
					books.source_system_book_id1 = ssbm.source_system_book_id1 AND
					books.source_system_book_id2 = ssbm.source_system_book_id2 AND
					books.source_system_book_id3 = ssbm.source_system_book_id3 AND
					books.source_system_book_id4 = ssbm.source_system_book_id4 AND 
					rd.expiration_date > ''' + @as_of_date + ''' AND rd.term_start > ''' + @as_of_date + '''' + 	
					case when (@source_deal_header_id IS NOT NULL) THEN 
						' AND rd.source_deal_header_id = ' + CAST(@source_deal_header_id AS VARCHAR) ELSE '' END	+				
				' AND (hr1+hr2+hr3+hr4+hr5+hr6+hr7+hr8+hr9+hr10+hr11+hr12+hr13+hr14+hr15+hr16+hr17+hr18+hr19+hr20+hr21+hr22+hr23+hr24) <> 0	 INNER JOIN				
				source_price_curve_def spcd1 ON spcd1.source_curve_def_id = g.curve_id INNER JOIN
				source_currency sc1 ON sc1.source_currency_id = spcd1.source_currency_id AND
					ISNULL(sc1.currency_id_to, spcd1.source_currency_id) <> books.func_cur_id INNER JOIN
				source_deal_header sdh ON sdh.source_deal_header_id = rd.source_deal_header_id LEFT JOIN
				source_price_curve_def spcd2 ON spcd2.source_curve_def_id = spcd1.proxy_source_curve_def_id LEFT JOIN
				source_price_curve_def spcd3 ON spcd3.source_curve_def_id = spcd1.monthly_index LEFT JOIN
				source_price_curve_def spcd4 ON spcd4.source_curve_def_id = spcd1.proxy_curve_id3 LEFT JOIN
				source_price_curve spc1 ON spc1.source_curve_def_id = spcd1.source_curve_def_id AND
							spc1.curve_source_value_id = ' + CAST(@curve_source_value_id as varchar) + ' AND
							spc1.as_of_date = ''' + @as_of_date + ''' AND 
							spc1.maturity_date =  						
								 CAST(CASE WHEN (spcd1.Granularity = 980) THEN 
									cast(Year(rd.term_start) as varchar) + ''-'' + cast(Month(rd.term_start) as varchar) + ''-01'' 
								 WHEN (spcd1.Granularity = 991) THEN 
									cast(Year(rd.term_start) as varchar) + ''-'' + cast(datepart(q, rd.term_start) as varchar) + ''-01'' 
								 WHEN (spcd1.Granularity = 992) THEN 
									cast(Year(rd.term_start) as varchar) + ''-'' + cast(CASE datepart(q, rd.term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''
								 WHEN (spcd1.Granularity = 993) THEN 
									cast(Year(rd.term_start) as varchar) + ''-01-01'' 
								 ELSE rd.term_start END AS DATETIME) LEFT JOIN							
				source_price_curve spc2 ON spc2.source_curve_def_id = spcd2.source_curve_def_id AND
							spc2.curve_source_value_id = ' + CAST(@curve_source_value_id as varchar) + ' AND
							spc2.as_of_date = ''' + @as_of_date + '''  AND 
							spc2.maturity_date =  						
								 CAST(CASE WHEN (spcd2.Granularity = 980) THEN 
									cast(Year(rd.term_start) as varchar) + ''-'' + cast(Month(rd.term_start) as varchar) + ''-01'' 
								 WHEN (spcd2.Granularity = 991) THEN 
									cast(Year(rd.term_start) as varchar) + ''-'' + cast(datepart(q, rd.term_start) as varchar) + ''-01'' 
								 WHEN (spcd2.Granularity = 992) THEN 
									cast(Year(rd.term_start) as varchar) + ''-'' + cast(CASE datepart(q, rd.term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''
								 WHEN (spcd2.Granularity = 993) THEN 
									cast(Year(rd.term_start) as varchar) + ''-01-01'' 
								 ELSE rd.term_start END AS DATETIME) LEFT JOIN
				source_price_curve spc3 ON spc3.source_curve_def_id = spcd3.source_curve_def_id AND
							spc3.curve_source_value_id = ' + CAST(@curve_source_value_id as varchar) + ' AND
							spc3.as_of_date = ''' + @as_of_date + '''  AND 
							spc3.maturity_date =  						
								 CAST(CASE WHEN (spcd3.Granularity = 980) THEN 
									cast(Year(rd.term_start) as varchar) + ''-'' + cast(Month(rd.term_start) as varchar) + ''-01'' 
								 WHEN (spcd3.Granularity = 991) THEN 
									cast(Year(rd.term_start) as varchar) + ''-'' + cast(datepart(q, rd.term_start) as varchar) + ''-01'' 
								 WHEN (spcd3.Granularity = 992) THEN 
									cast(Year(rd.term_start) as varchar) + ''-'' + cast(CASE datepart(q, rd.term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''
								 WHEN (spcd3.Granularity = 993) THEN 
									cast(Year(rd.term_start) as varchar) + ''-01-01'' 
								 ELSE rd.term_start END AS DATETIME) LEFT JOIN
				source_price_curve spc4 ON spc4.source_curve_def_id = spcd4.source_curve_def_id AND
							spc4.curve_source_value_id = ' + CAST(@curve_source_value_id as varchar) + '  AND
							spc4.as_of_date = ''' + @as_of_date + '''  AND 
							spc4.maturity_date =  						
								 CAST(CASE WHEN (spcd4.Granularity = 980) THEN 
									cast(Year(rd.term_start) as varchar) + ''-'' + cast(Month(rd.term_start) as varchar) + ''-01'' 
								 WHEN (spcd4.Granularity = 991) THEN 
									cast(Year(rd.term_start) as varchar) + ''-'' + cast(datepart(q, rd.term_start) as varchar) + ''-01'' 
								 WHEN (spcd4.Granularity = 992) THEN 
									cast(Year(rd.term_start) as varchar) + ''-'' + cast(CASE datepart(q, rd.term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''
								 WHEN (spcd4.Granularity = 993) THEN 
									cast(Year(rd.term_start) as varchar) + ''-01-01'' 
								 ELSE rd.term_start END AS DATETIME) LEFT JOIN						
				rec_volume_unit_conversion vuc1 ON	vuc1.from_source_uom_id = rd.deal_volume_uom_id AND
													vuc1.to_source_uom_id =   spcd1.uom_id 
				' + CASE WHEN @deal_list_table IS NOT NULL THEN ' INNER JOIN #source_deal_header_id t ON rd.source_deal_header_id = t.source_deal_header_id ' ELSE '' END + '								
	GROUP BY	rd.source_deal_header_id, g.curve_id,
				--rd.term_start,
				CAST(CAST(YEAR(rd.term_start) AS VARCHAR) + ''-'' + CAST(MONTH(rd.term_start) AS VARCHAR) + ''-01'' AS DATETIME)
'			

--PRINT(@sql_str)
	EXEC(@sql_str)


	If @print_diagnostic = 1
	BEGIN
		print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
		print '**************** End of Calculating exposure for  physical shaped and deal volume based deals *****************************'	
	END

	If @print_diagnostic = 1
	begin
		set @pr_name= 'sql_log_' + cast(@log_increment as varchar)
		set @log_increment = @log_increment + 1
		set @log_time=getdate()
		print @pr_name+' Running..............'
	end
		  
	/***** STEP 2  **************/
	--Gather physical profile volume based deals (position table: report_hourly_position_profile) which has curve_id that is non functional currency
	--Exposure = Non expired Position * Market Price * Convert Price UOM to Position UOM if not the same
	--This step is same as Step 1 except we need to run this because forecast deals' position are save in a seperate table
	set @sql_str = REPLACE(@sql_str, 'report_hourly_position_deal', 'report_hourly_position_profile')
	EXEC(@sql_str)


	If @print_diagnostic = 1
	BEGIN
		print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
		print '**************** End of Calculating exposure for physical profile volume based deals *****************************'	
	END


	If @print_diagnostic = 1
	begin
		set @pr_name= 'sql_log_' + cast(@log_increment as varchar)
		set @log_increment = @log_increment + 1
		set @log_time=getdate()
		print @pr_name+' Running..............'
	end

	/***** STEP 3  **************/
	--Gather physical shaped and deal volume based deals for Fixed Price (position table: report_hourly_position_deal) which has curve_id that is non functional currency
	--Exposure = Non expired Position * Fixed Price * Convert Price UOM to Position UOM if not the same
	SET @sql_str = 'INSERT INTO #fx_exposure
	SELECT DISTINCT [as_of_date], [source_deal_header_id], [exp_side], [phy_fin], [curve_id], [monthly_term], SUM(volume) volume, [volume_uom_id], [uom_conv_factor], [curve_value], sum(fx_exposure) fx_exposure, [currency_id], [price_uom_id]
	FROM(
		SELECT		''' + @as_of_date + ''' as_of_date,
					rd.source_deal_header_id, 
					''Contract'' exp_side, 
					MAX(rd.physical_financial_flag) phy_fin,		
					-1 curve_id, 
					CAST(CAST(YEAR(rd.term_start) AS VARCHAR) + ''-'' + CAST(MONTH(rd.term_start) AS VARCHAR) + ''-01'' AS DATETIME) monthly_term, 
					-1*round(SUM(hr1+hr2+hr3+hr4+hr5+hr6+hr7+hr8+hr9+hr10+hr11+hr12+hr13+hr14+hr15+hr16+hr17+hr18+hr19+hr20+hr21+hr22+hr23+hr24),6) volume,
					MAX(rd.deal_volume_uom_id) volume_uom_id, 
					MAX(ISNULL(vuc1.conversion_factor, 1)) uom_conv_factor, 
					MAX(ISNULL(sdd.fixed_price, 0)*ISNULL(sc1.factor, 1) * 
						CASE WHEN(sdd.price_uom_id <> rd.deal_volume_uom_id) THEN ISNULL(vuc1.conversion_factor, 1) ELSE 1 END 
					)  curve_value,
					SUM(
					-1*(hr1+hr2+hr3+hr4+hr5+hr6+hr7+hr8+hr9+hr10+hr11+hr12+hr13+hr14+hr15+hr16+hr17+hr18+hr19+hr20+hr21+hr22+hr23+hr24) *
					ISNULL(sdd.fixed_price, 0) *				
					ISNULL(sc1.factor, 1) * 
					CASE WHEN(ISNULL(sdd.price_uom_id, rd.deal_volume_uom_id) <> rd.deal_volume_uom_id) THEN ISNULL(vuc1.conversion_factor, 1) ELSE 1 END 
					) fx_exposure,
					MAX(sdd.fixed_price_currency_id) currency_id, 				
					max(sdd.price_uom_id) price_uom_id
									
		FROM		report_hourly_position_deal rd
		' + CASE WHEN @deal_list_table IS NOT NULL THEN ' INNER JOIN #source_deal_header_id t ON rd.source_deal_header_id = t.source_deal_header_id ' ELSE '' END + ' 
		inner join dbo.position_report_group_map g on g.rowid=rd.rowid
		inner join dbo.source_system_book_map ssbm on ssbm.book_deal_type_map_id=g.subbook_id				
		INNER JOIN #books books ON 
			books.source_system_book_id1 = ssbm.source_system_book_id1 AND
			books.source_system_book_id2 = ssbm.source_system_book_id2 AND
			books.source_system_book_id3 = ssbm.source_system_book_id3 AND
			books.source_system_book_id4 = ssbm.source_system_book_id4 AND 
						rd.expiration_date > ''' + @as_of_date + ''' AND rd.term_start > ''' + @as_of_date + '''' + 	
						case when (@source_deal_header_id IS NOT NULL) THEN 
							' AND rd.source_deal_header_id = ' + CAST(@source_deal_header_id AS VARCHAR) ELSE '' END	+				
					' AND (hr1+hr2+hr3+hr4+hr5+hr6+hr7+hr8+hr9+hr10+hr11+hr12+hr13+hr14+hr15+hr16+hr17+hr18+hr19+hr20+hr21+hr22+hr23+hr24) <> 0	 INNER JOIN  				
					source_deal_detail sdd ON sdd.source_deal_header_id = rd.source_deal_header_id AND 
									YEAR(sdd.term_start) = YEAR(rd.term_start) AND
									MONTH(sdd.term_start) = MONTH(rd.term_start) INNER JOIN								
					source_currency sc1 ON sc1.source_currency_id = sdd.fixed_price_currency_id AND
					ISNULL(sc1.currency_id_to, sdd.fixed_price_currency_id) <> books.func_cur_id INNER JOIN
					source_deal_header sdh ON sdh.source_deal_header_id = rd.source_deal_header_id LEFT JOIN							
					rec_volume_unit_conversion vuc1 ON	vuc1.from_source_uom_id = rd.deal_volume_uom_id AND
														vuc1.to_source_uom_id =   ISNULL(sdd.price_uom_id, -1)
		GROUP BY	rd.source_deal_header_id, g.curve_id,
					--rd.term_start,
					CAST(CAST(YEAR(rd.term_start) AS VARCHAR) + ''-'' + CAST(MONTH(rd.term_start) AS VARCHAR) + ''-01'' AS DATETIME)
	) t
	GROUP BY [as_of_date], [source_deal_header_id], [exp_side], [phy_fin], [curve_id], [monthly_term], [volume_uom_id], [uom_conv_factor], [curve_value], [currency_id], [price_uom_id]
	'

	--PRINT(@sql_str)
	EXEC (@sql_str)


	If @print_diagnostic = 1
	BEGIN
		print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
		print '**************** End of Calculating exposure for physical shaped and deal volume based deals for Fixed Price *****************************'	
	END


	If @print_diagnostic = 1
	begin
		set @pr_name= 'sql_log_' + cast(@log_increment as varchar)
		set @log_increment = @log_increment + 1
		set @log_time=getdate()
		print @pr_name+' Running..............'
	end


	/***** STEP 4  **************/
	--Gather physical profile volume based deals Fixed Price (position table: report_hourly_position_profile) which has curve_id that is non functional currency
	--Exposure = Non expired Position * Fixed Price * Convert Price UOM to Position UOM if not the same
	-- This step is same as Step 3 but we need to run it because forecast deals' positon are saved in a seperate table
	set @sql_str = REPLACE(@sql_str, 'report_hourly_position_deal', 'report_hourly_position_profile')
	EXEC(@sql_str)


	If @print_diagnostic = 1
	BEGIN
		print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
		print '**************** End of Calculating exposure for physical profile volume based deals Fixed Price *****************************'	
	END


	If @print_diagnostic = 1
	begin
		set @pr_name= 'sql_log_' + cast(@log_increment as varchar)
		set @log_increment = @log_increment + 1
		set @log_time=getdate()
		print @pr_name+' Running..............'
	end
	
	-- Get prices for Lag curve
	CREATE TABLE #curve_list (curve_id INT, term_start DATETIME) 
	
	/***** STEP 5  **************/
	--Gather contract price formula based curves that are in non functional currency.

SET @sql_str = '
	insert into #curve_list (curve_id , term_start )
	select  curve.curve_id,curve.term_start 
        FROM 
                (  select distinct curve_id,func_cur_id,convert(varchar(8),term_start,120)+ ''01'' term_start from report_hourly_position_breakdown s '
               + case when  @source_deal_header_id IS NULL and @deal_id IS NULL then '' else ' inner join source_deal_header sdh on sdh.source_deal_header_id=s.source_deal_header_id' end
               + case when  @source_deal_header_id IS NULL then '' else ' and s.source_deal_header_id='+ CAST(@source_deal_header_id as varchar) end
               + case when  @deal_id IS NULL then '' else ' and sdh.deal_id='''+ @deal_id +'''' end +'
                INNER JOIN #books books ON books.source_system_book_id1 = s.source_system_book_id1 AND
                    books.source_system_book_id2 = s.source_system_book_id2 AND
                    books.source_system_book_id3 = s.source_system_book_id3 AND
                    books.source_system_book_id4 = s.source_system_book_id4
                 and  DATEDIFF(month, term_start, term_end )=0 
                 ' + CASE WHEN @deal_list_table IS NOT NULL THEN ' INNER JOIN #source_deal_header_id t ON s.source_deal_header_id = t.source_deal_header_id ' ELSE '' END + '	
			union all
                select distinct curve_id,func_cur_id,br.term_start from report_hourly_position_breakdown s'
               + case when  @source_deal_header_id IS NULL and @deal_id IS NULL then '' else ' inner join source_deal_header sdh on sdh.source_deal_header_id=s.source_deal_header_id' end
               + case when  @source_deal_header_id IS NULL then '' else ' and s.source_deal_header_id='+ CAST(@source_deal_header_id as varchar) end
               + case when  @deal_id IS NULL then '' else ' and sdh.deal_id='''+ @deal_id +'''' end +' 
				INNER JOIN  #books books ON books.source_system_book_id1 = s.source_system_book_id1 AND
						books.source_system_book_id2 = s.source_system_book_id2 AND
						books.source_system_book_id3 = s.source_system_book_id3 AND
						books.source_system_book_id4 = s.source_system_book_id4
					 and  DATEDIFF(month, term_start, term_end )<>0
				' + CASE WHEN @deal_list_table IS NOT NULL THEN ' INNER JOIN #source_deal_header_id t ON s.source_deal_header_id = t.source_deal_header_id ' ELSE '' END + '
                  cross apply   [dbo].FNATermBreakdown(''m'',  s.term_start,s.term_end) br                  
                                                
				) curve
                        LEFT JOIN source_price_curve_def spcd WITH (NOLOCK) ON spcd.source_curve_def_id=curve.curve_id 
                        LEFT JOIN source_price_curve_def spcd_s WITH (NOLOCK) ON spcd.settlement_curve_id=spcd_s.source_curve_def_id
                        LEFT JOIN source_currency sc ON sc.source_currency_id = spcd.source_currency_id
				where ISNULL(sc.currency_id_to,sc.source_currency_id)<>curve.func_cur_id'
				
				

SET @sql_str = '
	insert into #curve_list (curve_id , term_start )
	select distinct s.curve_id,null term_start 
         from report_hourly_position_breakdown s '
               + case when  @source_deal_header_id IS NULL and @deal_id IS NULL then '' else ' inner join source_deal_header sdh on sdh.source_deal_header_id=s.source_deal_header_id' end
               + case when  @source_deal_header_id IS NULL then '' else ' and s.source_deal_header_id='+ CAST(@source_deal_header_id as varchar) end
               + case when  @deal_id IS NULL then '' else ' and sdh.deal_id='''+ @deal_id +'''' end +'
                INNER JOIN #books books ON books.source_system_book_id1 = s.source_system_book_id1 AND
                    books.source_system_book_id2 = s.source_system_book_id2 AND
                    books.source_system_book_id3 = s.source_system_book_id3 AND
                    books.source_system_book_id4 = s.source_system_book_id4
            LEFT JOIN source_price_curve_def spcd WITH (NOLOCK) ON spcd.source_curve_def_id=s.curve_id 
            LEFT JOIN source_price_curve_def spcd_s WITH (NOLOCK) ON spcd.settlement_curve_id=spcd_s.source_curve_def_id
            LEFT JOIN source_currency sc ON sc.source_currency_id = spcd.source_currency_id
            ' + CASE WHEN @deal_list_table IS NOT NULL THEN ' INNER JOIN #source_deal_header_id t ON s.source_deal_header_id = t.source_deal_header_id ' ELSE '' END + '
	where ISNULL(sc.currency_id_to,sc.source_currency_id)<>books.func_cur_id
	'				

	exec(@sql_str)
	
--	CREATE INDEX idx_curve_list1 ON #curve_list (term_start)
	CREATE INDEX idx_curve_list2 ON #curve_list (curve_id)

	--SELECT term_start, curve_id, dbo.FNARawLagcurve(term_start, @as_of_date, @curve_source_value_id, NULL, curve_id, 0, 0, 0, 1) lag_value
	--INTO #lag_curve
	--FROM #curve_list

	--CREATE INDEX idx_lag_curve1 ON #lag_curve (term_start)
	--CREATE INDEX idx_lag_curve2 ON #lag_curve (curve_id)
	
	If @print_diagnostic = 1
	BEGIN
		print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
		print '**************** End of Collecting Curve List and Building Index *****************************'	
	END
	

	If @print_diagnostic = 1
	begin
		set @pr_name= 'sql_log_' + cast(@log_increment as varchar)
		set @log_increment = @log_increment + 1
		set @log_time=getdate()
		print @pr_name+' Running..............'
	end

-- select * from #formula_position 

	--Get position for formula
	CREATE TABLE #formula_position 
	(
	source_deal_header_id INT, 
	curve_id INT,
	term_start datetime,
	volume float,
	deal_volume_uom_id int 
	) 

	/***** STEP 6  **************/
	--Gather forward position for all contract formula based curves 

SET @sql_str = '
	insert into  #formula_position 
	(source_deal_header_id , curve_id ,term_start ,volume ,deal_volume_uom_id )
      SELECT    s.source_deal_header_id, s.curve_id, hb.term_date term_start,
			(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr1,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=1 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)+
			(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr2,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=2 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)+
			(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr3,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=3 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END) +
			(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr4,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=4 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END) +
			(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr5,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=5 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END) +
			(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr6,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=6 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END) +
			(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr7,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=7 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)  +
			(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr8,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=8 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END) +
			(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr9,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=9 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END) +
			(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr10,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=10 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END) +
			'
set @sql_str1='
			(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr11,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=11 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END) +
			(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr12,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=12 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)+
			(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr13,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=13 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END) +
			(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr14,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=14 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END) +
			(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr15,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=15 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)+
			(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr16,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=16 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)+
			(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr17,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=17 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END) +
			(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr18,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=18 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END) +
			(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr19,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=19 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)+
			(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr20,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=20 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)+
			(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr21,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=21 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)+
			(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr22,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=22 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END)+
			(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr23,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=23 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END) +
			(cast(cast(cast(s.calc_volume as numeric(22,10))* cast(isnull(hb.hr24,0) as numeric(1,0)) as numeric(22,10))*cast(CASE WHEN isnull(hb.add_dst_hour,0)=24 THEN 2 ELSE 1 END as numeric(1,0)) as numeric(22,10)))/cast(nullif(isnull(term_hrs.term_no_hrs,term_hrs_exp.term_no_hrs),0) as numeric(8,0))*(CASE WHEN (hb.term_date)>=CAST(YEAR(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-''+CAST(MONTH(DATEADD(m,1,'''+@as_of_date +''' )) AS VARCHAR)+''-01'' THEN ISNULL(remain_month.remain_days/CAST(remain_month.total_days AS FLOAT),1) ELSE 1 END) position,
			s.deal_volume_uom_id'
set @sql_str2='	from report_hourly_position_breakdown s  (nolock)  '
           + case when  @source_deal_header_id IS NULL and @deal_id IS NULL then '' else ' inner join source_deal_header sdh on sdh.source_deal_header_id=s.source_deal_header_id' end
           + case when  @source_deal_header_id IS NULL then '' else ' and s.source_deal_header_id='+ CAST(@source_deal_header_id as varchar) end
           + case when  @deal_id IS NULL then '' else ' and sdh.deal_id='''+ @deal_id +'''' end +' 
		INNER JOIN #books books ON books.source_system_book_id1 = s.source_system_book_id1 AND
				books.source_system_book_id2 = s.source_system_book_id2 AND
				books.source_system_book_id3 = s.source_system_book_id3 AND
				books.source_system_book_id4 = s.source_system_book_id4 
				--AND s.term_start>'''+@as_of_date +''' 
				AND s.deal_date<='''+@as_of_date +''' 
            inner join (select distinct curve_id from #curve_list ) cl on cl.curve_id=s.curve_id                             
	            	left JOIN source_price_curve_def spcd with (nolock) ON spcd.source_curve_def_id=s.curve_id                          
			LEFT JOIN source_price_curve_def spcd1 (nolock) On spcd1.source_curve_def_id=spcd.settlement_curve_id
			outer apply (select sum(volume_mult) term_no_hrs from hour_block_term hbt where isnull(spcd.hourly_volume_allocation,17601) <17603 and hbt.block_define_id=COALESCE(spcd.block_define_id,'+@baseload_block_define_id+')	and  hbt.block_type=COALESCE(spcd.block_type,'+@baseload_block_type+') and hbt.term_date between s.term_start  and s.term_END ) term_hrs
			outer apply ( select sum(volume_mult) term_no_hrs from hour_block_term hbt inner join (select distinct exp_date from holiday_group h where  h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.exp_date between s.term_start  and s.term_END ) ex on ex.exp_date=hbt.term_date
			where  isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and hbt.block_define_id=COALESCE(spcd.block_define_id,'+@baseload_block_define_id+')	and  hbt.block_type=COALESCE(spcd.block_type,'+@baseload_block_type+') and hbt.term_date between s.term_start  and s.term_END) term_hrs_exp
			LEFT JOIN hour_block_term hb with (nolock) on hb.block_define_id=COALESCE(spcd.block_define_id,'+@baseload_block_define_id+')	and  hb.block_type=COALESCE(spcd.block_type,'+@baseload_block_type+') 
			and hb.term_date between s.term_start  and s.term_end  
			  outer apply  (select MAX(exp_date) exp_date from holiday_group h where h.hol_date=hb.term_date AND 
			  h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.hol_date between s.term_start  and s.term_END AND COALESCE(spcd1.ratio_option,spcd.ratio_option,-1) <> 18800 ) hg   
			 outer apply  (select MIN(exp_date) hol_date ,MAX(exp_date) hol_date_to  from holiday_group h where 1=1 AND h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) and h.hol_date between s.term_start  and s.term_END AND s.formula NOT IN(''REBD'')) hg1   
			 outer apply  (select count(exp_date) total_days,SUM(CASE WHEN h.exp_date>'''+@as_of_date+''' THEN 1 else 0 END) remain_days from holiday_group h where h.hol_group_value_id=ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id) 
						AND h.exp_date BETWEEN hg1.hol_date AND ISNULL(hg1.hol_date_to,dbo.FNALastDayInDate(hg1.hol_date))
						AND ISNULL(spcd1.ratio_option,spcd.ratio_option) = 18800 AND s.formula NOT IN(''REBD'')) remain_month  
			' + CASE WHEN @deal_list_table IS NOT NULL THEN ' INNER JOIN #source_deal_header_id t ON s.source_deal_header_id = t.source_deal_header_id ' ELSE '' END + '	     
      where 
		     ((ISNULL(spcd1.ratio_option,spcd.ratio_option) = 18800 AND ISNULL(hg1.hol_date_to,''9999-01-01'')>'''+@as_of_date+''') OR COALESCE(spcd1.ratio_option,spcd.ratio_option,-1) <> 18800)
		     AND ((isnull(spcd.hourly_volume_allocation,17601) IN(17603,17604) and  hg.exp_date is not null) or (isnull(spcd.hourly_volume_allocation,17601)<17603 ))		           
		  		   and CASE WHEN s.formula IN(''dbo.FNACurveH'',''dbo.FNACurveD'') THEN ISNULL(hg.exp_date,hb.term_date) WHEN ISNULL(spcd.hourly_volume_allocation,17601) IN(17603,17604) THEN ISNULL(hg.exp_date,s.expiration_date) ELSE s.expiration_date END>'''+@as_of_date+'''
   '                   
       
      -- print(@sql_str)  
     --  print(@sql_str1)  
     --  print(@sql_str2) 
    exec(@sql_str+@sql_str1+@sql_str2)    
     
	If @print_diagnostic = 1
	BEGIN
		print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
		print '**************** End of Collecting Financial Formula Breakdown Position *****************************'	
	END


	If @print_diagnostic = 1
	begin
		set @pr_name= 'sql_log_' + cast(@log_increment as varchar)
		set @log_increment = @log_increment + 1
		set @log_time=getdate()
		print @pr_name+' Running..............'
	end

	CREATE INDEX idx_formula_position1 ON #formula_position (curve_id)
	CREATE INDEX idx_formula_position2 ON #formula_position (source_deal_header_id)
	CREATE INDEX idx_formula_position3 ON #formula_position (term_start)
	CREATE INDEX idx_formula_position4 ON #formula_position (deal_volume_uom_id)

	If @print_diagnostic = 1
	BEGIN
		print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
		print '**************** End of Building index on #formula_position table *****************************'	
	END


	If @print_diagnostic = 1
	begin
		set @pr_name= 'sql_log_' + cast(@log_increment as varchar)
		set @log_increment = @log_increment + 1
		set @log_time=getdate()
		print @pr_name+' Running..............'
	end

	/***** STEP 7 **************/
	--Calcualte Exposure for formula curves:  Unexpired position * Curve Price * UOM conversion if price uom id not same as position uom id
	SET @sql_str = 'INSERT INTO #fx_exposure
	SELECT		''' + @as_of_date + ''' as_of_date,
				rd.source_deal_header_id, 
				''Contract'' exp_side, 
				''f'' phy_fin,		
				rd.curve_id, 
				CAST(CAST(YEAR(rd.term_start) AS VARCHAR) + ''-'' + CAST(MONTH(rd.term_start) AS VARCHAR) + ''-01'' AS DATETIME) monthly_term, 
				round(SUM(volume),6) volume,
				MAX(rd.deal_volume_uom_id) volume_uom_id, 
				MAX(ISNULL(vuc1.conversion_factor, 1)) uom_conv_factor, 
				SUM(
				(volume) *
				coalesce(spc1.curve_value, spc2.curve_value, spc3.curve_value, spc4.curve_value) *				
				ISNULL(sc1.factor, 1) * 
				CASE WHEN(spcd1.uom_id <> rd.deal_volume_uom_id) THEN ISNULL(vuc1.conversion_factor, 1) ELSE 1 END 
				)/SUM(volume)  curve_value,
				SUM(
				(volume) *
				coalesce(spc1.curve_value, spc2.curve_value, spc3.curve_value, spc4.curve_value) *				
				ISNULL(sc1.factor, 1) * 
				CASE WHEN(spcd1.uom_id <> rd.deal_volume_uom_id) THEN ISNULL(vuc1.conversion_factor, 1) ELSE 1 END 
				)
				fx_exposure,
				MAX(ISNULL(sc1.currency_id_to, spcd1.source_currency_id)) currency_id, 				
				NULL price_uom_id
								
	FROM		
				#formula_position rd INNER JOIN
				source_price_curve_def spcd1 ON spcd1.source_curve_def_id = rd.curve_id AND
					rd.volume <> 0 INNER JOIN
				source_currency sc1 ON sc1.source_currency_id = spcd1.source_currency_id INNER JOIN
				source_deal_header sdh ON sdh.source_deal_header_id = rd.source_deal_header_id LEFT JOIN
				source_price_curve_def spcd2 ON spcd2.source_curve_def_id = spcd1.proxy_source_curve_def_id LEFT JOIN
				source_price_curve_def spcd3 ON spcd3.source_curve_def_id = spcd1.monthly_index LEFT JOIN
				source_price_curve_def spcd4 ON spcd4.source_curve_def_id = spcd1.proxy_curve_id3 LEFT JOIN
				source_price_curve spc1 ON spc1.source_curve_def_id = spcd1.source_curve_def_id AND
							spc1.curve_source_value_id = ' + CAST(@curve_source_value_id as varchar) + ' AND
							spc1.as_of_date = ''' + @as_of_date + ''' AND 
							spc1.maturity_date =  						
								 CAST(CASE WHEN (spcd1.Granularity = 980) THEN 
									cast(Year(rd.term_start) as varchar) + ''-'' + cast(Month(rd.term_start) as varchar) + ''-01'' 
								 WHEN (spcd1.Granularity = 991) THEN 
									cast(Year(rd.term_start) as varchar) + ''-'' + cast(datepart(q, rd.term_start) as varchar) + ''-01'' 
								 WHEN (spcd1.Granularity = 992) THEN 
									cast(Year(rd.term_start) as varchar) + ''-'' + cast(CASE datepart(q, rd.term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''
								 WHEN (spcd1.Granularity = 993) THEN 
									cast(Year(rd.term_start) as varchar) + ''-01-01'' 
								 ELSE rd.term_start END AS DATETIME) LEFT JOIN							
				source_price_curve spc2 ON spc2.source_curve_def_id = spcd2.source_curve_def_id AND
							spc2.curve_source_value_id = ' + CAST(@curve_source_value_id as varchar) + ' AND
							spc2.as_of_date = ''' + @as_of_date + '''  AND 
							spc2.maturity_date =  						
								 CAST(CASE WHEN (spcd2.Granularity = 980) THEN 
									cast(Year(rd.term_start) as varchar) + ''-'' + cast(Month(rd.term_start) as varchar) + ''-01'' 
								 WHEN (spcd2.Granularity = 991) THEN 
									cast(Year(rd.term_start) as varchar) + ''-'' + cast(datepart(q, rd.term_start) as varchar) + ''-01'' 
								 WHEN (spcd2.Granularity = 992) THEN 
									cast(Year(rd.term_start) as varchar) + ''-'' + cast(CASE datepart(q, rd.term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''
								 WHEN (spcd2.Granularity = 993) THEN 
									cast(Year(rd.term_start) as varchar) + ''-01-01'' 
								 ELSE rd.term_start END AS DATETIME) LEFT JOIN
				source_price_curve spc3 ON spc3.source_curve_def_id = spcd3.source_curve_def_id AND
							spc3.curve_source_value_id = ' + CAST(@curve_source_value_id as varchar) + ' AND
							spc3.as_of_date = ''' + @as_of_date + '''  AND 
							spc3.maturity_date =  						
								 CAST(CASE WHEN (spcd3.Granularity = 980) THEN 
									cast(Year(rd.term_start) as varchar) + ''-'' + cast(Month(rd.term_start) as varchar) + ''-01'' 
								 WHEN (spcd3.Granularity = 991) THEN 
									cast(Year(rd.term_start) as varchar) + ''-'' + cast(datepart(q, rd.term_start) as varchar) + ''-01'' 
								 WHEN (spcd3.Granularity = 992) THEN 
									cast(Year(rd.term_start) as varchar) + ''-'' + cast(CASE datepart(q, rd.term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''
								 WHEN (spcd3.Granularity = 993) THEN 
									cast(Year(rd.term_start) as varchar) + ''-01-01'' 
								 ELSE rd.term_start END AS DATETIME) LEFT JOIN
				source_price_curve spc4 ON spc4.source_curve_def_id = spcd4.source_curve_def_id AND
							spc4.curve_source_value_id = ' + CAST(@curve_source_value_id as varchar) + '  AND
							spc4.as_of_date = ''' + @as_of_date + '''  AND 
							spc4.maturity_date =  						
								 CAST(CASE WHEN (spcd4.Granularity = 980) THEN 
									cast(Year(rd.term_start) as varchar) + ''-'' + cast(Month(rd.term_start) as varchar) + ''-01'' 
								 WHEN (spcd4.Granularity = 991) THEN 
									cast(Year(rd.term_start) as varchar) + ''-'' + cast(datepart(q, rd.term_start) as varchar) + ''-01'' 
								 WHEN (spcd4.Granularity = 992) THEN 
									cast(Year(rd.term_start) as varchar) + ''-'' + cast(CASE datepart(q, rd.term_start) WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 7 END as varchar) + ''-01''
								 WHEN (spcd4.Granularity = 993) THEN 
									cast(Year(rd.term_start) as varchar) + ''-01-01'' 
								 ELSE rd.term_start END AS DATETIME) LEFT JOIN						
				rec_volume_unit_conversion vuc1 ON	vuc1.from_source_uom_id = rd.deal_volume_uom_id AND
													vuc1.to_source_uom_id =   spcd1.uom_id 	
																				
	GROUP BY	rd.source_deal_header_id, rd.curve_id,
				--rd.term_start,
				CAST(CAST(YEAR(rd.term_start) AS VARCHAR) + ''-'' + CAST(MONTH(rd.term_start) AS VARCHAR) + ''-01'' AS DATETIME)
	'			


	EXEC(@sql_str)

		If @print_diagnostic = 1
		BEGIN
			print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
			print '**************** End of calculating exposure for formula breakdown *****************************'	
		END


		If @print_diagnostic = 1
		begin
			set @pr_name= 'sql_log_' + cast(@log_increment as varchar)
			set @log_increment = @log_increment + 1
			set @log_time=getdate()
			print @pr_name+' Running..............'
		end

		CREATE INDEX idx_fx_exposure1 ON #fx_exposure (as_of_date)
		CREATE INDEX idx_fx_exposure2 ON #fx_exposure (source_deal_header_id)
		CREATE INDEX idx_fx_exposure3 ON #fx_exposure (curve_id)

		If @print_diagnostic = 1
		BEGIN
			print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
			print '**************** End of Calculating index on #fx_exposure *****************************'	
		END


		DECLARE @status_type VARCHAR(1)
		DECLARE @desc VARCHAR(5000)

		If @print_diagnostic = 1
		begin
			set @pr_name= 'sql_log_' + cast(@log_increment as varchar)
			set @log_increment = @log_increment + 1
			set @log_time=getdate()
			print @pr_name+' Running..............'
		end

		INSERT INTO MTM_TEST_RUN_LOG(process_id,code,MODULE,source,TYPE,[description],nextsteps)  
		SELECT	@batch_process_id, '<font color="red">Error</font>', 'FX Calc', 'FX Exposure', 
				'Error',
				' FX calc for Deal failed perhaps due to price curve missing Deal ID: ' +  
				CAST(f.source_deal_header_id AS VARCHAR) + ' Curve: ' + MAX(ISNULL(spcd.curve_name + ' (ID: ' + CAST(f.curve_id AS VARCHAR) + ')', 'Fixed')) +
				MAX(' Exposure type: ' + f.exp_side) + ' for term ' + 
				ISNULL(dbo.FNADateFormat(MIN(f.monthly_term)), CONVERT(VARCHAR(7), MIN(f.monthly_term), 120)) + 
				' to ' + ISNULL(dbo.FNADateFormat(MAX(f.monthly_term)), CONVERT(VARCHAR(7), MAX(f.monthly_term), 120)) description,
				'Please Import Price Curves'
		FROM #fx_exposure f LEFT JOIN
			 source_price_curve_def spcd ON spcd.source_curve_def_id = f.curve_id
		WHERE fx_exposure IS NULL
		GROUP BY f.source_deal_header_id


		If @print_diagnostic = 1
		BEGIN
			print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
			print '**************** End of Inserting in MTM_TEST_RUN_LOG *****************************'	
		END

	
		IF @@ROWCOUNT > 0 
			SET @status_type = 'e'
		ELSE
			SET @status_type = 's'
		
		DECLARE @e_time_s INT
		DECLARE @e_time_text_s VARCHAR(100)
		SET @e_time_s = DATEDIFF(ss,@begin_time,GETDATE())
		SET @e_time_text_s = CAST(CAST(@e_time_s/60 AS INT) AS VARCHAR) + ' Mins ' + CAST(@e_time_s - CAST(@e_time_s/60 AS INT) * 60 AS VARCHAR) + ' Secs'
		
		
		IF @status_type = 'e'
			SET @desc = '<a target="_blank" href="' +  './dev/spa_html.php?__user_name__=' + @user_login_id + 
				'&spa=exec spa_get_mtm_test_run_log ''' + @batch_process_id + '''' + '">' + 
			'Errors Found in FX Exposure Calc process for as of date ' + ISNULL(dbo.FNADateFormat(@as_of_date), @as_of_date) + 
			' [Elapse time: ' + @e_time_text_s + ']' + 
			'.</a>'
		ELSE
				SET @desc = 'FX Exposure Calc process completed for as of date ' + ISNULL(dbo.FNADateFormat(@as_of_date), @as_of_date) +
				' [Elapse time: ' + @e_time_text_s + ']' 
 		
		
		If @print_diagnostic = 1
		begin
			set @pr_name= 'sql_log_' + cast(@log_increment as varchar)
			set @log_increment = @log_increment + 1
			set @log_time=getdate()
			print @pr_name+' Running..............'
		end

		DELETE  fx_exposure FROM fx_exposure f
		INNER JOIN #fx_exposure tf ON	f.as_of_date = tf.as_of_date AND
			f.source_deal_header_id=tf.source_deal_header_id 
			--AND
			--f.exp_side = tf.exp_side AND
			--f.phy_fin = tf.phy_fin AND
			--f.curve_id = tf.curve_id AND
			--f.monthly_term = tf.monthly_term AND
			--f.currency_id = tf.currency_id						
If @print_diagnostic = 1
		BEGIN
			print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
			print '**************** End of Deleting from fx_exposure table*****************************'	
		END

		
		If @print_diagnostic = 1
		begin
			set @pr_name= 'sql_log_' + cast(@log_increment as varchar)
			set @log_increment = @log_increment + 1
			set @log_time=getdate()
			print @pr_name+' Running..............'
		end
		
		;WITH temp_fx_exposure AS
		(
		 SELECT *,
		  ROW_NUMBER() OVER(PARTITION BY as_of_date, source_deal_header_id, exp_side, phy_fin, curve_id, monthly_term, currency_id ORDER BY as_of_date, source_deal_header_id, exp_side, phy_fin, curve_id, monthly_term, currency_id) AS rn
		 FROM #fx_exposure
		 )
		
		INSERT INTO fx_exposure
		  (
		    as_of_date,
		    source_deal_header_id,
		    exp_side,
		    phy_fin,
		    curve_id,
		    monthly_term,
		    volume,
		    volume_uom_id,
		    uom_conv_factor,
		    curve_value,
		    fx_exposure,
		    currency_id,
		    price_uom_id,
		    create_user,
		    create_ts
		  )
		SELECT as_of_date,
		       source_deal_header_id,
		       exp_side,
		       phy_fin,
		       curve_id,
		       monthly_term,
		       volume,
		       volume_uom_id,
		       uom_conf_factor,
		       curve_value,
		       fx_exposure,
		       currency_id,
		       price_uom_id,
		       dbo.FNADBUser() create_user,
		       GETDATE()
		FROM   temp_fx_exposure
		WHERE  rn = 1

		If @print_diagnostic = 1
		BEGIN
			print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
			print '**************** End of Inserting in fx_exposure table*****************************'	
		END

		
		DECLARE @job_name VARCHAR(250)
		SET @job_name = 'report_batch_'+@batch_process_id 
		EXEC  spa_message_board 'u', @user_login_id, NULL, 'FX Calc', @desc, '', '', @status_type, @job_name,NULL, @batch_process_id,NULL,'n',NULL,'y' 
			
		IF @status_type='e'
			RETURN


END				

If @report_group = 0 -- no report output
	RETURN

CREATE TABLE #deal_status (status_value_id INT)

IF @source_deal_header_id IS NOT NULL
	INSERT INTO #deal_status
	SELECT value_id FROM static_data_value WHERE TYPE_ID = 5600
ELSE IF @deal_status  IS NOT NULL 
	EXEC('INSERT INTO #deal_status SELECT value_id FROM static_data_value WHERE value_id IN (' + @deal_status + ')')
ELSE
	INSERT INTO #deal_status
	SELECT status_value_id FROM deal_status_group
	
SELECT	f.*, b.sub_name, b.str_name, b.book_name, su.uom_name deal_volume_uom, 
		sc.currency_name, CASE WHEN (f.curve_id =-1) THEN 'Fixed' ELSE spcd.curve_name END curve_name,
		sup.uom_name price_uom
INTO #report		
FROM fx_exposure f INNER JOIN
	 source_deal_header sdh ON sdh.source_deal_header_id = f.source_deal_header_id  
	 INNER JOIN #deal_status d ON d.status_value_id = sdh.deal_status 
	 INNER JOIN #books b ON 
			b.source_system_book_id1 = sdh.source_system_book_id1 AND
			b.source_system_book_id2 = sdh.source_system_book_id2 AND
			b.source_system_book_id3 = sdh.source_system_book_id3 AND
			b.source_system_book_id4 = sdh.source_system_book_id4 
	LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = f.curve_id 
	LEFT JOIN source_uom su ON su.source_uom_id = f.volume_uom_id 
	LEFT JOIN source_currency sc ON sc.source_currency_id = f.currency_id 
	LEFT JOIN source_uom sup ON sup.source_uom_id = f.price_uom_id
WHERE f.as_of_date = @as_of_date AND (@source_deal_header_id IS NULL  OR sdh.source_deal_header_id = @source_deal_header_id) AND (@deal_list_table IS NULL OR sdh.source_deal_header_id IN (SELECT source_deal_header_id FROM #source_deal_header_id))
	  
--@report_group


--select* from fx_exposure order by exp_side, monthly_term
IF @report_group = 1
	SET @sql = '
	SELECT r.sub_name Sub,ISNULL(dbo.FNADateFormat(r.monthly_term), r.monthly_term) Term,
			ROUND(SUM(r.fx_exposure), ' + CAST(@round_value AS VARCHAR)+ ') [FX Exposure],
	       r.currency_name Currency' + @str_batch_table + '
	FROM   #report r
	GROUP BY r.sub_name, r.monthly_term, r.currency_name
	ORDER BY r.sub_name, r.currency_name, r.monthly_term'
ELSE IF @report_group = 2
	SET @sql = '
	SELECT r.sub_name Sub, r.str_name Strategy, ISNULL(dbo.FNADateFormat(r.monthly_term),  r.monthly_term) Term, 
	round(SUM(r.fx_exposure), ' + CAST(@round_value AS VARCHAR)+ ') [FX Exposure], 
	r.currency_name Currency
	' + @str_batch_table + '
	FROM #report r
	GROUP BY 	r.sub_name, r.str_name, r.monthly_term, r.currency_name
	ORDER BY r.sub_name, r.str_name, r.currency_name,r.monthly_term
	'
ELSE IF @report_group = 3
	SET @sql = '
	SELECT r.sub_name Sub, r.str_name Strategy, r.book_name Book, ISNULL(dbo.FNADateFormat(r.monthly_term),  r.monthly_term) Term, 
	round(SUM(r.fx_exposure), ' + CAST(@round_value AS VARCHAR)+ ') [FX Exposure], 
	r.currency_name Currency
	' + @str_batch_table + '
	FROM #report r
	GROUP BY 	r.sub_name, r.str_name, r.book_name, r.monthly_term, r.currency_name
	ORDER BY r.sub_name, r.str_name, r.book_name, r.currency_name, r.monthly_term
	'
ELSE IF @report_group = 4
	SET @sql = '
	SELECT r.sub_name Sub, r.str_name Strategy, r.book_name Book, r.curve_name [Index], ISNULL(dbo.FNADateFormat(r.monthly_term),  r.monthly_term) Term, 
	round(SUM(r.fx_exposure), ' + CAST(@round_value AS VARCHAR)+ ') [FX Exposure], 
	r.currency_name Currency
	' + @str_batch_table + '
	FROM #report r
	GROUP BY 	r.sub_name, r.str_name, r.book_name, r.curve_name, r.monthly_term, r.currency_name
	ORDER BY r.sub_name, r.str_name, r.book_name, r.curve_name, r.currency_name, r.monthly_term
	'
ELSE -- 5 Detailed
	SET @sql = 'SELECT ISNULL(dbo.FNADateFormat(r.as_of_date),  r.as_of_date) [As Of Date],
	r.source_deal_header_id [Deal ID], 
	sdh.deal_id [Ref ID],
	r.sub_name Sub, r.str_name Strategy, r.book_name Book, 
	dbo.FNAHyperlinktext(10131024,r.exp_side,r.source_deal_header_id )[Type], 
	case when (phy_fin=''f'') then ''Fin'' else ''Phy'' end [Phy/Fin],
	r.curve_name [Index], ISNULL(dbo.FNADateFormat(r.monthly_term),  r.monthly_term) Term, 
	round(r.volume, ' + CAST(@round_value AS VARCHAR)+ ') [Volume],
	r.deal_volume_uom [Volume UOM],
	r.uom_conv_factor [Volume Factor],
	round(r.curve_value, ' +  CAST(@round_value AS VARCHAR) + ') [Float/Fixed Price], 
	r.price_uom [Price UOM],
	round(r.fx_exposure, ' +  CAST(@round_value AS VARCHAR) + ') [FX Exposure], 
	r.currency_name Currency
	' + @str_batch_table + '
	FROM #report r inner join 
		 source_deal_header sdh on sdh.source_deal_header_id = r.source_deal_header_id 
	ORDER BY r.sub_name, r.str_name, r.book_name, r.source_deal_header_id, r.curve_name, r.currency_name, r.monthly_term'
	
--print(@sql)
EXEC(@sql)	
	
	
		
	--SET @sql = 'select * from ' + @str_batch_table
	--EXEC(@sql)
	
		
	/*******************************************2nd Paging Batch START**********************************************/
	--update time spent and batch completion message in message board
	IF @is_batch = 1
	BEGIN
		SELECT @str_batch_table = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL)   
		EXEC(@str_batch_table)                   

		SELECT @str_batch_table = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_create_fx_exposure_report', 'FX Exposure Report')         
		EXEC(@str_batch_table)        
		RETURN
	END

	--if it is first call from paging, return total no. of rows and process id instead of actual data
	IF @enable_paging = 1 AND @page_no IS NULL
	BEGIN
		SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
		EXEC(@sql_paging)
	END
	/*******************************************2nd Paging Batch END**********************************************/
		

