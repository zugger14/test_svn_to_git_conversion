IF OBJECT_ID('spa_automation_forecasted_transaction') IS NOT NULL
DROP PROC dbo.spa_automation_forecasted_transaction
GO

CREATE PROC dbo.spa_automation_forecasted_transaction 
	@fas_sub_ids VARCHAR(1000),
		@as_of_date VARCHAR(10),
		@process_id VARCHAR(250) = NULL,
		@user_login_id VARCHAR(30)=NULL,
		@match_type VARCHAR(1)='p',
		@batch_process_id    VARCHAR(50) = NULL, 
		@batch_report_param  VARCHAR(1000) = NULL

AS
SET NOCOUNT ON
/*
declare @fas_sub_ids varchar(1000)='197,198,199',@as_of_date varchar(10)='2012-12-31',
		@process_id varchar(250)='cccc',
		@user_login_id varchar(30)='RE64582',@match_type varchar(1)='p'
delete from gen_hedge_group
delete from gen_hedge_group_detail


delete  gen_hedge_group  where create_ts>'2013-03-03'
delete  gen_hedge_group_detail  where create_ts>'2013-03-03'
delete  gen_deal_detail  where create_ts>'2013-03-03'
delete gen_deal_header  where create_ts>'2013-03-03'
delete gen_fas_link_detail where create_ts>'2013-03-03'
delete gen_fas_link_header  where create_ts>'2013-03-03'
delete  fas_link_detail  where create_ts>'2013-03-03'
delete  fas_link_header  where create_ts>'2013-03-03'
--*/

/*******************************************1st Paging Batch START**********************************************/
 
DECLARE @str_batch_table VARCHAR (8000)

SET @str_batch_table = ''        
 
IF @batch_process_id IS NOT NULL  
 
BEGIN      
 
	SELECT @str_batch_table = dbo.FNABatchProcess('s', @batch_process_id, @batch_report_param, NULL, NULL, NULL)   
 
	SET @str_batch_table = @str_batch_table
 
END
 
/*******************************************1st Paging Batch END**********************************************/

IF @process_id is NULL 
	SET @process_id = @batch_process_id

DECLARE @externalization VARCHAR(1)='n'
DECLARE @url_desc VARCHAR(MAX)
DECLARE @link_deal_term_used_per VARCHAR(250),@sql VARCHAR(MAX),@hedge_capacity VARCHAR(250),@forecated_tran VARCHAR(1)
DECLARE @desc1 VARCHAR(8000)

SET @forecated_tran='n'

IF @match_type='h'
	SET @forecated_tran='y'  --forected deal_id are exist in table gen_del_header where for other deal are exist in source_deal_header

SET @process_id=ISNULL(@process_id, REPLACE(NEWID(), '-', '_'))
SET @user_login_id =ISNULL(@user_login_id,dbo.fnadbuser())



SET @link_deal_term_used_per = dbo.FNAProcessTableName('link_deal_term_used_per', @user_login_id, @process_id)

DECLARE  @report_type VARCHAR(1)='c',@summary_option VARCHAR(1)='l'
	,@exception_flag CHAR(1)='a'
	,@asset_type_id INT = 402
	,@settlement_option CHAR(1) = 'f'
	,@include_gen_tranactions CHAR(1) = 'b'
	,@term_match_criteria VARCHAR(1)='p'  --'w'
	,@dedesignate_frequency VARCHAR(1)='m'
	,@dedesignate_look_in VARCHAR(1) ='i'
	,@volume_split VARCHAR(1)='y',@tenor_name VARCHAR(250)

SET @tenor_name='Automation forecasted transaction'

IF OBJECT_ID(@link_deal_term_used_per) IS NOT NULL
	EXEC('drop table '+@link_deal_term_used_per)
	
IF OBJECT_ID('tempdb..#used_percentage') IS NOT NULL
	DROP TABLE #used_percentage
	
IF OBJECT_ID('tempdb..#hedge_deal') IS NOT NULL
	DROP TABLE #hedge_deal

IF OBJECT_ID('tempdb..#tmp_deals') IS NOT NULL
	DROP TABLE #tmp_deals

IF OBJECT_ID('tempdb..#used_percentage') IS NULL
	CREATE TABLE #used_percentage (source_deal_header_id INT,term_start DATE,used_percentage FLOAT,link_end_date DATETIME)
ELSE
	TRUNCATE TABLE #used_percentage
	
IF OBJECT_ID('tempdb..#hedge_capacity') IS NOT NULL
	DROP TABLE #hedge_capacity

CREATE TABLE #hedge_capacity(
	fas_sub_id INT,
	fas_str_id INT,
	fas_book_id INT,
	curve_id INT,
	fas_sub VARCHAR(250) COLLATE DATABASE_DEFAULT  ,
	fas_str VARCHAR(250) COLLATE DATABASE_DEFAULT  ,
	fas_book VARCHAR(250) COLLATE DATABASE_DEFAULT  ,
	IndexName VARCHAR(250) COLLATE DATABASE_DEFAULT  ,
	TenorBucket VARCHAR(250) COLLATE DATABASE_DEFAULT  ,
	TenorStart DATETIME,
	TenorEnd DATETIME,
	vol_frequency VARCHAR(50) COLLATE DATABASE_DEFAULT,
	vol_uom VARCHAR(100) COLLATE DATABASE_DEFAULT  ,
	net_asset_vol NUMERIC(38,20),
	net_item_vol NUMERIC(38,20),
	net_available_vol NUMERIC(38,20),
	over_hedge VARCHAR(3) COLLATE DATABASE_DEFAULT  ,net_vol NUMERIC(26,10)
)
--exec spa_Create_Available_Hedge_Capacity_Exception_Report '2011-10-31','35', null, null,'c','l',null,'a'

--call hedge_capacity_report
SET @url_desc = '' 


--PRINT '*************************************************'
--PRINT 'start automation forecast transaction'
--PRINT '*************************************************'

-----spa_Create_Available_Hedge_Capacity_Exception_Report


--PRINT '*************************************************'
--PRINT 'start call spa_Create_Available_Hedge_Capacity_Exception_Report'
--PRINT '*************************************************'

INSERT INTO #hedge_capacity (fas_sub_id ,fas_str_id ,fas_book_id ,curve_id ,fas_sub ,fas_str ,fas_book ,IndexName ,
	TenorBucket,TenorStart ,TenorEnd  ,vol_frequency ,vol_uom ,net_asset_vol ,net_item_vol ,net_available_vol ,over_hedge)
EXEC spa_Create_Available_Hedge_Capacity_Exception_Report @as_of_date,@fas_sub_ids, NULL, NULL,@report_type,@summary_option,NULL,@exception_flag,@asset_type_id,@settlement_option,@include_gen_tranactions,@forecated_tran,'UK'


SET @hedge_capacity= dbo.FNAProcessTableName('hedge_capacity', @user_login_id, @process_id)

UPDATE #hedge_capacity SET net_vol=ABS(ABS(ISNULL(net_asset_vol,0))-abs(ISNULL(net_item_vol,0)))	* CASE WHEN ISNULL(net_asset_vol,0)<0 THEN -1 ELSE 1 END	

--update #hedge_capacity set net_vol=isnull(net_asset_vol,0)-isnull(net_item_vol,0)
	
IF OBJECT_ID(@hedge_capacity) IS NOT NULL
	EXEC('drop table '+@hedge_capacity)
		
--PRINT('select *  into '+@hedge_capacity+ ' from #hedge_capacity  where over_hedge=''No'' and isnull(net_vol,0)<>0')
		
EXEC('select *  into '+@hedge_capacity+ ' from #hedge_capacity  where over_hedge=''No'' and isnull(net_vol,0)<>0')
	
--exec('select *    from '+@hedge_capacity)

-----------------------------------------------------------------------

/* process creating item --*/
--PRINT '*************************************************'
--PRINT 'start prepare data for collecting hedge deals'
--PRINT '*************************************************'


CREATE TABLE #tmp_deals ( 
source_deal_header_id INT,vol NUMERIC(26,10),book_deal_type_map_id INT,curve_id INT
,deal_id VARCHAR(150) COLLATE DATABASE_DEFAULT  ,term_start DATETIME,term_end DATETIME,deal_date DATETIME
,commodity_id INT,instrument_type_id INT,source_system_book_id1 INT,source_system_book_id2 INT,
source_system_book_id3 INT,source_system_book_id4 INT,fas_sub_id INT
)
			
SET @sql='
	insert into #tmp_deals ( source_deal_header_id,curve_id ,vol,book_deal_type_map_id,deal_id,term_start,term_end,deal_date,commodity_id,instrument_type_id
	,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,fas_sub_id)
	SELECT sdd.source_deal_header_id,sdd.curve_id,SUM(deal_volume) vol,max(sbm.book_deal_type_map_id) book_deal_type_map_id
		,max(sdh.deal_id),min(sdd.term_start),max(sdd.term_end),max(sdh.deal_date) deal_date
		,max(spcd.commodity_id) commodity_id,max(sdh.source_system_book_id3) instrument_type_id,
		max(sdh.source_system_book_id1),max(sdh.source_system_book_id2),max(sdh.source_system_book_id3),max(sdh.source_system_book_id4),max(s.parent_entity_id) fas_sub_id
	FROM source_deal_detail sdd inner join source_deal_header sdh on  sdh.source_deal_header_id=sdd.source_deal_header_id 
	and sdh.deal_id not like ''MA_%'' and  sdh.deal_status<>5607
	INNER JOIN source_system_book_map sbm ON sdh.source_system_book_id1 = sbm.source_system_book_id1 AND 
		   sdh.source_system_book_id2 = sbm.source_system_book_id2 AND sdh.source_system_book_id3 = sbm.source_system_book_id3 AND 
		   sdh.source_system_book_id4 = sbm.source_system_book_id4 and isnull(sdh.fas_deal_type_value_id,sbm.fas_deal_type_value_id)=400
		 inner join portfolio_hierarchy b on b.entity_id=sbm.fas_book_id
		 inner join portfolio_hierarchy s on s.entity_id=b.parent_entity_id
		 and s.parent_entity_id in ('+@fas_sub_ids+')
	left join source_price_curve_def spcd on spcd.source_curve_def_id=sdd.curve_id
	WHERE sdd.curve_id IS NOT NULL AND sdd.leg=1  and sdh.deal_date  <='''+@as_of_date+''' 
	GROUP BY sdd.source_deal_header_id,sdd.curve_id    
'
--PRINT(@sql)
EXEC(@sql)

CREATE INDEX idx_tmp_sdd1_1 ON #tmp_deals (source_deal_header_id)

SET @link_deal_term_used_per = dbo.FNAProcessTableName('link_deal_term_used_per', @user_login_id, @process_id)

IF OBJECT_ID(@link_deal_term_used_per) IS NOT NULL
	EXEC('drop table '+@link_deal_term_used_per)
	
EXEC dbo.spa_get_link_deal_term_used_per @as_of_date =@as_of_date,@link_ids=NULL,@header_deal_id =NULL,@term_start=NULL
	,@no_include_link_id =NULL,@output_type =1	,@include_gen_tranactions  = 'b',@process_table=@link_deal_term_used_per


SET @sql = '
	INSERT INTO #used_percentage (source_deal_header_id ,used_percentage )	
	select source_deal_header_id ,sum(percentage_used) percentage_used 
	from (
		SELECT ud.source_deal_header_id,term_start, sum(isnull(percentage_used ,0)) percentage_used 
		from ' +@link_deal_term_used_per +' ud
		GROUP BY ud.source_deal_header_id,term_start
	 ) a group by source_deal_header_id
'
--PRINT(@sql)			
EXEC(@sql)			

SELECT CAST (ROUND((1 - ISNULL(SUM(pu.used_percentage), 0) - ISNULL(MAX(outstanding.percentage_use), 0)), 2) AS FLOAT) AS PerAvail
	, dh.source_deal_header_id ,MAX(dh.curve_id) curve_id,MAX(book_deal_type_map_id) book_deal_type_map_id
	,MAX(dh.source_system_book_id1) source_system_book_id1,MAX(dh.source_system_book_id2) source_system_book_id2
	,MAX(dh.source_system_book_id3) source_system_book_id3,MAX(dh.source_system_book_id4) source_system_book_id4,MAX(dh.fas_sub_id) fas_sub_id
	INTO #hedge_deal FROM #tmp_deals dh 
LEFT JOIN	fas_link_detail fld ON fld.source_deal_header_id = dh.source_deal_header_id AND fld.hedge_or_item='h'
LEFT JOIN	fas_link_header flh ON fld.link_id=flh.link_id 
--inner join generic_mapping_values g on g.clm1_value=flh.eff_test_profile_id
--	and g.clm2_value=dh.commodity_id and g.clm3_value=dh.instrument_type_id
--inner join generic_mapping_header h on g.mapping_table_id=h.mapping_table_id and h.mapping_name= @tenor_name
LEFT JOIN #used_percentage pu ON pu.source_deal_header_id=dh.source_deal_header_id
LEFT OUTER JOIN
(
	SELECT 	dh.source_deal_header_id, SUM(ghgd.percentage_use) AS  percentage_use
	FROM 	#tmp_deals dh INNER JOIN gen_hedge_group_detail ghgd ON ghgd.source_deal_header_id = dh.source_deal_header_id 
		LEFT OUTER JOIN	gen_fas_link_header ghg ON ghg.gen_hedge_group_id = ghgd.gen_hedge_group_id 
	WHERE   (ghg.gen_status IS NULL  OR ghg.gen_status = 'a')  
	GROUP BY dh.source_deal_header_id
) outstanding ON outstanding.source_deal_header_id = dh.source_deal_header_id
GROUP BY   dh.source_deal_header_id 
HAVING (1 - ISNULL(SUM(pu.used_percentage), 0)- ISNULL(MAX(outstanding.percentage_use), 0)) >= 0.01

--PRINT '*************************************************'
--PRINT 'start insert gen hedge deal for automation forecast transaction'
--PRINT '*************************************************'

DECLARE @insert_ts DATETIME
SET @insert_ts=GETDATE()

DECLARE  @auto_finalize_gen_trans INT
SELECT     @auto_finalize_gen_trans = var_value
FROM         adiha_default_codes_values
WHERE     (default_code_id = 18) AND (seq_no = 1) AND (instance_no = '1')



/*
--for isnull(h.matching_type,'a') in ('b','h') , the @forecast_tran='y'
--for isnull(h.matching_type,'a') in ('p') , the @forecast_tran='n'


*/
IF OBJECT_ID('tempdb..#new_gen_hedge_group_id') IS NOT NULL
DROP TABLE #new_gen_hedge_group_id

CREATE TABLE #new_gen_hedge_group_id (gen_hedge_group_id INT)


SET @sql='
insert into dbo.gen_hedge_group(
	gen_hedge_group_name,link_type_value_id,hedge_effective_date,
	eff_test_profile_id,perfect_hedge,tenor_from,tenor_to,reprice_date,
	create_user,create_ts,update_user,update_ts,tran_type,process_id
) output inserted.gen_hedge_group_id into #new_gen_hedge_group_id(gen_hedge_group_id)
select hd.source_deal_header_id,
	450 link_type_value_id,td.deal_date hedge_effective_date,(d.eff_test_profile_id) eff_test_profile_id,case when isnull(h.matching_type,''a'')=''p'' then ''y'' else ''n'' end sperfect_hedge
	,null tenor_from,null tenor_to,null reprice_date,'''+@user_login_id +''' create_user
	,getdate() create_ts,null update_user,null update_ts,null tran_type,'''+@process_id+'''

FROM fas_eff_hedge_rel_type h INNER JOIN fas_eff_hedge_rel_type_detail d ON h.eff_test_profile_id=d.eff_test_profile_id 
	inner join #hedge_deal hd on hd.book_deal_type_map_id=ISNULL(d.book_deal_type_map_id,hd.book_deal_type_map_id)
	and hd.source_system_book_id1=ISNULL(d.source_system_book_id1,hd.source_system_book_id1)
	and hd.source_system_book_id2=ISNULL(d.source_system_book_id2,hd.source_system_book_id2)
	and hd.source_system_book_id3=ISNULL(d.source_system_book_id3,hd.source_system_book_id3)
	and hd.source_system_book_id4=ISNULL(d.source_system_book_id4,hd.source_system_book_id4)
	and hd.fas_sub_id=ISNULL(d.sub_id,hd.fas_sub_id)
	and d.source_curve_def_id=hd.curve_id and d.hedge_or_item=''h'' AND d.source_curve_def_id IS NOT NULL 
	AND ('''+CONVERT(VARCHAR(10),@as_of_date,120)+''' BETWEEN ISNULL(effective_start_date,''1900-01-01'') AND ISNULL(effective_end_date,''9999-01-01'')) 
	AND profile_active=''y'' AND profile_approved=''y'' AND isnull(externalization,''n'')='''+ISNULL(@externalization,'n') +'''
	and isnull(h.matching_type,''a'') in ('''+CASE WHEN ISNULL(@match_type,'p') ='p' THEN 'p' ELSE 'h'',''b' END +''')
	left join  #tmp_deals td on hd.source_deal_header_id=td.source_deal_header_id
order by td.deal_date,td.source_deal_header_id
'

--PRINT(@sql)
EXEC(@sql)

INSERT INTO dbo.gen_hedge_group_detail(
	gen_hedge_group_id,source_deal_header_id,percentage_use,create_user,create_ts,update_user,update_ts,process_id
)
SELECT ghg.gen_hedge_group_id,hd.source_deal_header_id source_deal_header_id,hd.PerAvail percentage_use
	,@user_login_id create_user,GETDATE() create_ts,NULL update_user,NULL update_ts,@process_id
FROM dbo.gen_hedge_group ghg INNER JOIN #new_gen_hedge_group_id i ON ghg.gen_hedge_group_id=i.gen_hedge_group_id
INNER JOIN #hedge_deal hd ON ISNUMERIC(ghg.gen_hedge_group_name)=1 AND  ghg.gen_hedge_group_name=hd.source_deal_header_id
	
UPDATE dbo.gen_hedge_group SET gen_hedge_group_name=CASE WHEN ISNULL(@match_type,'p') ='p' THEN 'PM ' ELSE 'Hyp ' END+
	 CAST( hd.source_deal_header_id AS VARCHAR) +'/'+td.deal_id+'('+CONVERT(VARCHAR(10),td.term_start,120)+ ' : '
	  +CONVERT(VARCHAR(10),td.term_end,120)+')'
 FROM gen_hedge_group ghg 
 INNER JOIN #new_gen_hedge_group_id i ON ghg.gen_hedge_group_id=i.gen_hedge_group_id
 INNER JOIN gen_hedge_group_detail hd ON ghg.gen_hedge_group_id=hd.gen_hedge_group_id
 LEFT JOIN  #tmp_deals td ON hd.source_deal_header_id=hd.source_deal_header_id
--return

IF @@ROWCOUNT>0
BEGIN

	IF ISNULL(@match_type,'p') ='h'
	BEGIN
		---call automation of forecast transaction
		--PRINT '*************************************************'
		--PRINT 'start call automation of forecast transaction'
		--PRINT '*************************************************'
	--return
		EXEC spa_create_forecasted_transaction_job 'l', 1, @process_id, @user_login_id,@as_of_date,'y','DE'
	END
	ELSE
	BEGIN
		-- Create link header
		INSERT INTO gen_fas_link_header
		SELECT  ghg.gen_hedge_group_id, 
		CASE WHEN (@auto_finalize_gen_trans = 1 ) THEN 'y' ELSE 'n' END AS  gen_approved, 
		 ghg.eff_test_profile_id , 
		rt.fas_book_id , 
		 ghg.perfect_hedge, 
		ghg.gen_hedge_group_name AS link_description, 
		ghg.eff_test_profile_id, 
		  ghg.hedge_effective_date AS link_effective_date, 
		ghg.link_type_value_id AS link_type_value_id, NULL AS link_id, 
				'p' AS gen_status, @process_id, @user_login_id, NULL, NULL
		FROM    gen_hedge_group ghg INNER JOIN
		fas_eff_hedge_rel_type rt ON rt.eff_test_profile_id = ghg.eff_test_profile_id
		INNER JOIN #new_gen_hedge_group_id i ON ghg.gen_hedge_group_id=i.gen_hedge_group_id
		ORDER BY ghg.hedge_effective_date,ghg.gen_hedge_group_id

		INSERT INTO gen_fas_link_detail
				([gen_link_id]
			   ,[deal_number]
			   ,[hedge_or_item]
			   ,[percentage_included]
			   ,[create_user]
			   ,[create_ts]
			   ,[effective_date],deal_id_source) 
		SELECT	flh.gen_link_id, ghgd.source_deal_header_id, 
		'h' AS hedge_or_item, ghgd.percentage_use AS percentage_included,
		@user_login_id, NULL, NULL effective_date,'s'
		FROM    gen_hedge_group_detail ghgd INNER JOIN
			gen_fas_link_header flh ON flh.gen_hedge_group_id = ghgd.gen_hedge_group_id 
		INNER JOIN #new_gen_hedge_group_id i ON ghgd.gen_hedge_group_id=i.gen_hedge_group_id
	END
	--PRINT '*************************************************'
	--PRINT 'start call spa_auto_matching_limit_validation'
	--PRINT '*************************************************'
--select  @as_of_date ,@user_login_id,@process_id,'y'

	EXEC dbo.spa_auto_matching_limit_validation @as_of_date ,@user_login_id,@process_id,@forecated_tran,@fas_sub_ids,'UK'

	--PRINT '*************************************************'
	--PRINT 'end call spa_auto_matching_limit_validation'
	--PRINT '*************************************************'

	UPDATE flh SET gen_status='a' FROM    gen_hedge_group ghg 
	INNER JOIN gen_fas_link_header flh ON flh.gen_hedge_group_id = ghg.gen_hedge_group_id 
		INNER JOIN #new_gen_hedge_group_id i ON ghg.gen_hedge_group_id=i.gen_hedge_group_id AND flh.gen_status='p'

	IF @auto_finalize_gen_trans = 1 
	BEGIN

		--PRINT '*************************************************'
		--PRINT 'start call spa_finalize_approved_transactions_job'
		--PRINT '*************************************************'
		
		DECLARE @hedge_groups_tmp VARCHAR(250),@job_name VARCHAR(250)
		SET @job_name='finalize_transactions'+@process_id
		
		SELECT @hedge_groups_tmp=ISNULL(@hedge_groups_tmp+',','') +CAST(gen_hedge_group_id AS VARCHAR) FROM #new_gen_hedge_group_id
								
		EXEC spa_finalize_approved_transactions_job 'u', 30, @job_name, @user_login_id,	@process_id, @hedge_groups_tmp
		
		--PRINT '*************************************************'
		--PRINT 'end call spa_finalize_approved_transactions_job'
		--PRINT '*************************************************'

	END
	
	DECLARE @source VARCHAR(100)
	IF @match_type = 'p'
	BEGIN
		SET @source = 'Perfect hedges'
	END
	ELSE
	BEGIN
		SET @source = 'Automation'
	END
	
	DECLARE @url_path1 VARCHAR(500)

	
	SET @url_path1 = './dev/spa_html.php?__user_name__=' + @user_login_id + '&spa=exec spa_get_transaction_gen_status '
					 + dbo.fnasinglequote('-9999')+' , NULL, '+dbo.fnasinglequote(@process_id) + ',''' + @match_type + ''', ''' + @as_of_date + '''' 
	
	
	SET @desc1 = 'Perfect Hedges generation process is completed for ' + @as_of_date + '.' 	
	SET @desc1 = '<a href="#" onclick="TRMHyperlink(10234500, ''-9999'')">' + @desc1 +'</a>'

	EXEC  spa_message_board 'i', @user_login_id,
				NULL, @source,
				@desc1, 
				'', '', 's', @process_id

	 SELECT  'Success' ErrorCode,
			'Automation' MODULE,
			'Automation' Area,
			'Success' [Status],
			@desc1 [MESSAGE],
			'' Recommendation
END
ELSE 
BEGIN
	--PRINT '*************************************************'
	--PRINT 'head deal not found'
	--PRINT '*************************************************'

	INSERT INTO gen_transaction_status
	SELECT @process_id, -9999, 
		'Error' , 'Automation Forecasted Transaction' , 'spa_gen_transaction' , 
					'Data Error' , 
		'Data not found to generate forecasted transaction.', 
		'Please check the data.',
		@user_login_id, NULL

	
	SET @url_path1 = './dev/spa_html.php?__user_name__=' + @user_login_id + '&spa=exec spa_get_transaction_gen_status '
					 + dbo.fnasinglequote('-9999')+' , NULL, '+dbo.fnasinglequote(@process_id) + ',''' + @match_type + ''', ''' + @as_of_date + '''' 
	
	IF @match_type = 'p'
	BEGIN
		SET @desc1 = 'Perfect Hedges generation process is completed for ' + @as_of_date + ' (Errors found).'
		SET @source = 'Perfect Hedges'
	END
	ELSE 
	BEGIN
	SET @desc1 = 'Forecasted transactions automation failed.'
		SET @source = 'Automation'
	END

	SET @desc1 = '<a target="_blank" href="' + @url_path1 + '">' + @desc1 +'</a>'

	EXEC  spa_message_board 'i', @user_login_id, NULL, @source, @desc1, '', '', 'e', @process_id

	IF  @match_type = 'p'
	BEGIN
		SELECT  'Success' ErrorCode, 
				'Automation' Module,
				'Automation' Area,
				'Success' [Status],
				'Perfect Hedges generation process has been run and will complete shortly. Please check/refresh your message board.' [Message],
				'' Recommendation
	END
	ELSE 
	BEGIN
		DECLARE @msg VARCHAR(1000)
		SET @msg = 'Perfect Hedges generation process is completed for. ' + @as_of_date + ' (Errors Found).'
		SELECT  'Error' ErrorCode, 'Automation' Module,
				'Automation' Area,
				'DB Error' [Status],
				@msg [Message],
				'' Recommendation
	END 
END 


/*******************************************2nd Paging Batch START**********************************************/
 
IF  @batch_process_id IS NOT NULL        
 
BEGIN        
	SELECT @str_batch_table = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL)
 
	EXEC(@str_batch_table)     
 
END        

/*******************************************2nd Paging Batch END**********************************************/
 
GO
