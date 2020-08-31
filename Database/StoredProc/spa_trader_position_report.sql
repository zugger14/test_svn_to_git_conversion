
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_trader_Position_Report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_trader_Position_Report]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE  procedure [dbo].[spa_trader_Position_Report]
@as_of_date VARCHAR(50), 
@sub_entity_id VARCHAR(100), 
@strategy_entity_id VARCHAR(100) = NULL, 
@book_entity_id VARCHAR(100) = NULL, 
@summary_option CHAR(1), --'t'- term 'm' - By Month 'q' - By quater,'s' - By semiannual,'a' - By Annual, 'r' - Deal Summary, 'd' - Deal detail, 'i' - just by index
@CONVERT_unit_id INT,
@settlement_option CHAR(1) = 'f', 
@source_system_book_id1 INT=NULL, 
@source_system_book_id2 INT=NULL, 
@source_system_book_id3 INT=NULL, 
@source_system_book_id4 INT=NULL,
@transaction_type VARCHAR(100)=null,
@source_deal_header_id VARCHAR(50)=null,
@deal_id VARCHAR(50)=null,
--@as_of_date_from VARCHAR(50)=null, 
@options CHAR(1)='d',--'d'- include delta positions, 'n'-Do not include delta positions
@drill_index VARCHAR(100)=NULL,
@drill_contractmonth VARCHAR(100)=NULL,
@major_location VARCHAR(250)= NULL,
@minor_location VARCHAR(250) = NULL,
@index VARCHAR(250) = NULL,
@commodity_id INT=NULL,
@sub_type CHAR(1)='b', --'b' both, 'f' forward,'s' spot
@group_by CHAR(1)='i',-- 'i'-index,'l'-location
@physical_financial_flag CHAR(1)='b',	--'b' both, 'p' physical, 'f' financial
@deal_type INT=NULL,
@trader_id INT=NULL,
@tenor_from VARCHAR(20)=NULL,
@tenor_to VARCHAR(20)=NULL,
@show_cross_tabformat CHAR(1)='n',
@deal_process_id VARCHAR(100)=NULL,  --when call from Check Position in deal insert
@deal_status int = null,
@block_definition_id_on int=null,
@block_definition_id_off int=null,
@round_value char(1) = '0',
@curve_source_id  int = NULL,
@period INT=NULL,
@deal_list_table VARCHAR(300) = NULL, -- contains list of deals to be processed
--@detail_deal_id VARCHAR = NULL,
@batch_process_id VARCHAR(50)=NULL,
@batch_report_param VARCHAR(1000)=NULL 
	

AS
SET NOCOUNT ON
/*
---exec spa_Create_Position_Report '2009-12-31', '7', '8', NULL, 't', null, 'f', NULL, NULL, NULL, NULL,'401,400,407',NULL, NULL,NULL,'n',NULL,NULL,NULL,NULL,NULL,NULL,'b','i','b',NULL,NULL,NULL,NULL,NULL,NULL,NULL

--SET NOCOUNT ON

--##############################################uncomment these to test locally

	

	
	
declare @as_of_date VARCHAR(50), 
	@sub_entity_id VARCHAR(100), 
	@strategy_entity_id VARCHAR(100) , 
	@book_entity_id VARCHAR(100) , 
	@summary_option CHAR(1), --'t'- term 'm' - By Month 'q' - By quater,'s' - By semiannual,'a' - By Annual, 'r' - Deal Summary, 'd' - Deal detail, 'i' - just by index
	@CONVERT_unit_id INT,
	@settlement_option CHAR(1) , 
	@source_system_book_id1 INT, 
	@source_system_book_id2 INT, 
	@source_system_book_id3 INT, 
	@source_system_book_id4 INT,
	@transaction_type VARCHAR(100),
	@source_deal_header_id VARCHAR(50),
	@deal_id VARCHAR(50),
	@as_of_date_from VARCHAR(50), 
	@options CHAR(1),--'d'- include delta positions, 'n'-Do not include delta positions
	@drill_index VARCHAR(100),
	@drill_contractmonth VARCHAR(100),
	@major_location VARCHAR(250),
	@minor_location VARCHAR(250) ,
	@index VARCHAR(250) ,
	@commodity_id INT,
	@sub_type CHAR(1), --'b' both, 'f' forward,'s' spot
	@group_by CHAR(1),-- 'i'-index,'l'-location
	@physical_financial_flag CHAR(1),--'b'	--'b' both, 'p' physical, 'f' financial
	@deal_type INT,
	@trader_id INT,
	@tenor_from VARCHAR(20),
	@tenor_to VARCHAR(20),
	@show_cross_tabformat CHAR(1),
	@deal_process_id VARCHAR(100),  --when call from Check Position in deal insert
	@deal_status int ,
	@block_definition_id_on int,
	@block_definition_id_off int,
	@round_value VARCHAR(2),
	@batch_process_id VARCHAR(50),
	@batch_report_param VARCHAR(1000) ,@curve_source_id  int ,
@period INT
--exec spa_trader_Position_Report '2009-12-16', '7', NULL, NULL, 't', null, 'f', NULL, NULL, NULL, NULL,'409,401,400,407',NULL, NULL,'d'
--,NULL,NULL,NULL,NULL,'2',NULL,NULL,'i','b',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'0',4500,NULL

SELECT 
@as_of_date='2009-12-16',
@sub_entity_id= '7',
@strategy_entity_id= null,
@book_entity_id= null,
@summary_option= 'r',
@CONVERT_unit_id= null,
@settlement_option= 'f',
@source_system_book_id1 = NULL,
@source_system_book_id2= NULL,
@source_system_book_id3 = NULL,
@source_system_book_id4 = NULL,
@transaction_type ='409,401,400,407',
@source_deal_header_id =null,
@deal_id= NULL,
@options= 'd',
@drill_index =NULL,
@drill_contractmonth=NULL,
@major_location=NULL,
@minor_location=NULL,
@index=null ,--'21,22',
@commodity_id =NULL,
@sub_type=null,
@group_by='i',
@physical_financial_flag='b',
@deal_type =NULL,
@trader_id =NULL,
@tenor_from =NULL,
@tenor_to=NULL,
@show_cross_tabformat=NULL,
@deal_process_id=NULL,
@deal_status=NULL,
@block_definition_id_on =null,--291193,
@block_definition_id_off =null, --291193,
@round_value=0,
@batch_process_id=NULL,
@batch_report_param=NULL,@curve_source_id=4500


--exec spa_trader_Position_Report '2009-12-16', '7', NULL, NULL, 'm', null, 'f', NULL, NULL, NULL, -4,'409,401,400,407',NULL, NULL,'d',NULL,NULL,NULL,NULL,NULL,NULL,'b','i','b',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'0'


---exec spa_trader_Position_Report '2009-12-16', NULL, NULL, NULL, 't', null, 'f', NULL, NULL, NULL, NULL,'401,400,407','190', NULL,'n',NULL,NULL,NULL,NULL,NULL,NULL,'b','i','b',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL

--SELECT * FROM static_data_value sdv WHERE sdv.value_id=291193

--SELECT * FROM  #temp_order
--	select  YEAR([Term])[actualTerm],[Term], 365 - case when term=2009 then datediff(day,term+'-01-01','2009-12-16') else 0 end
--		* 24 as no_hrs
--	    FROM #tempPivot GROUP BY [Term]
--		 ORDER BY CAST([Term] AS DATETIME)



DROP TABLE #tempItems
DROP TABLE #tempMTM
--DROP TABLE #templOAD
--DROP TABLE #tmp_per
DROP TABLE  #tempPivot
DROP TABLE  #temp_order
--##############################################
--*/
SET @show_cross_tabformat='y'
--*******************************************************
-- this report works only for Summary Level Data
--******************************************************
---###########Declare Variables

Declare @Sql_Select VARCHAR(MAX)
Declare @term_where_clause VARCHAR(1000)
Declare @Sql_Where VARCHAR(8000)
Declare @report_identifier INT
DECLARE @granularity_type VARCHAR(1)
DECLARE @process_id VARCHAR(50)
DECLARE @user_login_id VARCHAR(50)
DECLARE @tempTable VARCHAR(100)
DECLARE @deal_volume_str VARCHAR(200)
DECLARE @storage_inventory_sub_type_id INT
--DECLARE @drill_contract_month_clause	VARCHAR(100)
DECLARE @year VARCHAR(4),@start_month VARCHAR(4),@end_month VARCHAR(4)
DECLARE @str_batch_table varchar(max)        
DECLARE @listCol VARCHAR(5000)
DECLARE @tbl_name_header VARCHAR(150)
DECLARE @tbl_name_detail VARCHAR(150)

DECLARE @tenor_from_temp DATETIME,
	@tenor_to_temp DATETIME

 --if 'period' has been defined, calculate tenor_from and tenor_to from the help of as_of_date and period.
	IF @period IS NOT NULL
    BEGIN
		SET @tenor_from_temp= CAST(YEAR(@as_of_date) AS VARCHAR)+ '-' + CAST(MONTH(@as_of_date) AS VARCHAR) + '-01' ;
		SET @tenor_from_temp= dateadd(mm,1,@tenor_from_temp)
		SET @tenor_from= CAST(YEAR(@tenor_from_temp) AS VARCHAR)+ '-' + CAST(MONTH(@tenor_from_temp) AS VARCHAR) + '-01' ;

		SET @tenor_to_temp= dateadd(mm,@period,@tenor_from_temp)
		SET @tenor_to_temp= dateadd(dd,-1,@tenor_to_temp)
		SET @tenor_to= CAST(YEAR(@tenor_to_temp) AS VARCHAR)+ '-' + CAST(MONTH(@tenor_to_temp) AS VARCHAR) + '-' + CAST(DAY(@tenor_to_temp) AS VARCHAR)  ;
		--print @tenor_from
		--print @tenor_to
	END

SET @storage_inventory_sub_type_id=17
SET @str_batch_table=''        
SET @sql_Where = ''
set @tbl_name_header='source_deal_header'
set @tbl_name_detail ='source_deal_detail'
set @user_login_id=dbo.FNADBuser()
SET @process_id=REPLACE(newid(),'-','_')	
declare @rst_report varchar(150)

IF @deal_process_id IS NOT NULL  --when call from Check Position in deal insert
BEGIN
	set @tbl_name_header=dbo.FNAProcessTableName('deal_header', @user_login_id,@deal_process_id)
	set @tbl_name_detail =dbo.FNAProcessTableName('deal_detail', @user_login_id,@deal_process_id)
END
SET @str_batch_table=''        
IF @batch_process_id is not null  
BEGIN      
	SELECT @str_batch_table=dbo.FNABatchProcess('s',@batch_process_id,@batch_report_param,NULL,NULL,NULL)
	SET @rst_report = REPLACE(@str_batch_table, 'into ', '')
END
ELSE
BEGIN
	SET @rst_report = dbo.FNAProcessTableName('result', @user_login_id,@process_id)
END

CREATE TABLE #source_deal_header_id (source_deal_header_id INT)
IF OBJECT_ID(@deal_list_table) IS NOT NULL
BEGIN
    EXEC ('INSERT INTO #source_deal_header_id  SELECT DISTINCT source_deal_header_id FROM ' + @deal_list_table)
END

--if @as_of_date_from IS NULL
--	SET @as_of_date_from='1900-01-01'
--
SET @granularity_type=@summary_option

if @summary_option='r'
	set @granularity_type='a'
--if @summary_option='t'
--	set @granularity_type='m'


If @settlement_option = 'f'
		set @term_where_clause = ' AND ((sdd.term_start >  CONVERT(DATETIME, ''' + @as_of_date + ''' , 102) AND COALESCE(spcd1.block_define_id,sdh.block_define_id) IS NOT NULL) OR (sdd.term_start >  CONVERT(DATETIME, DBO.FNAGETCONTRACTMONTH(''' + @as_of_date + ''') , 102) AND COALESCE(spcd1.block_define_id,sdh.block_define_id) IS NULL))'
Else If @settlement_option = 'c'
	set @term_where_clause = ' AND sdd.term_start >=  CONVERT(DATETIME, ''' + cast(month(@as_of_date) as VARCHAR) + '/1/' + cast(year(@as_of_date) as VARCHAR) + ''' , 102)'
Else If @settlement_option = 's'
	set @term_where_clause = ' AND ((sdd.term_start <=  CONVERT(DATETIME, ''' + cast(month(@as_of_date) as VARCHAR) + '/1/' + cast(year(@as_of_date) as VARCHAR) + ''' , 102) AND sdh.block_define_id IS NULL) OR (sdd.term_start <=CONVERT(DATETIME, ''' + @as_of_date + ''' , 102) AND sdh.block_define_id IS NOT NULL))'
Else
	set @term_where_clause = ''


--IF @summary_option in('t')
--	SELECT @drill_contract_month_clause=CASE WHEN @drill_contractmonth IS NOT NULL THEN  ' AND dbo.fnadateformat(sdd.term_start)='''+@drill_contractmonth+'''' ELSE '' END
--ELSE IF @summary_option in('m')
--	SELECT @drill_contract_month_clause=CASE WHEN @drill_contractmonth IS NOT NULL THEN ' AND dbo.fnadateformat(cast(dbo.fnagetcontractmonth(sdd.term_start) as datetime))='''+@drill_contractmonth+'''' ELSE '' END
--ELSE IF @summary_option in('q')
--BEGIN
--	select @start_month=CASE  WHEN  @drill_contractmonth like '%1st%' then '-01' WHEN  @drill_contractmonth like '%2nd%' then '-04' WHEN  @drill_contractmonth like '%3rd%' then '-07'  WHEN  @drill_contractmonth like '%4th%' then '-10' END
--	select @end_month=CASE  WHEN  @drill_contractmonth like '%1st%' then '-03' WHEN  @drill_contractmonth like '%2nd%' then '-06' WHEN  @drill_contractmonth like '%3rd%' then '-09'  WHEN  @drill_contractmonth like '%4th%' then '-12' END
--	select @year=substring(@drill_contractmonth,charindex('-',@drill_contractmonth,0)+1,4)
--	SELECT @drill_contract_month_clause=CASE WHEN @drill_contractmonth IS NOT NULL THEN 
--		' AND cast((sdd.term_start) as datetime) BETWEEN '''+(@year+@start_month+'-01')+''' AND '''+(@year+@end_month+'-01')+'''' ELSE '' END
--END
--ELSE IF @summary_option in('s')
--BEGIN
--
--	select @start_month=CASE  WHEN  @drill_contractmonth like '%1st%' then '-01' WHEN  @drill_contractmonth like '%2nd%' then '-07' END
--	select @end_month=CASE  WHEN  @drill_contractmonth like '%1st%' then '-06' WHEN  @drill_contractmonth like '%2nd%' then '-12' END
--	select @year=substring(@drill_contractmonth,charindex('-',@drill_contractmonth,0)+1,4)
--	SELECT @drill_contract_month_clause=CASE WHEN @drill_contractmonth IS NOT NULL THEN 
--		' AND cast((sdd.term_start) as datetime) BETWEEN '''+(@year+@start_month+'-01')+''' AND '''+(@year+@end_month+'-01')+'''' ELSE '' END
--END
--ELSE IF @summary_option in('a')
--	SELECT @drill_contract_month_clause=CASE WHEN @drill_contractmonth IS NOT NULL THEN ' AND YEAR(sdd.term_start)='''+@drill_contractmonth+'''' ELSE '' END
--

---###### For the Deal sub type filter

IF @sub_type='t'
	SET @sub_type=2
ELSE IF @sub_type='s'
	SET @sub_type=1

---######
------####### Create Temporary Tables

CREATE TABLE [dbo].[#tempItems] (
	[source_deal_header_id] INT ,
	[fas_book_id] [int] NOT NULL ,
	[deal_id] [VARCHAR] (200)  NOT NULL ,
	[contract_expiration_date] datetime,
	[NetItemVol] [float] NULL ,
--	[deal_volume_frequency] [char] (20)  NOT NULL ,
	[deal_volume_frequency] [char] (20)  NULL ,
	[IndexName] [VARCHAR] (100)   ,
	[sui] [int]  not NULL,  --[sui] [int] NOT NULL, (chande
	deal_date datetime,
	term_start datetime,
	term_end datetime,
	price float,
	block_type INT,
	block_definition_id INT,
	volume_frequency CHAR(1),
	Location VARCHAR(100),
	physical_financial_flag VARCHAR(1),
	commodity VARCHAR(100),
	curve_id INT,
	fas_deal_type_value_id INT,
	load_volume FLOAT,
	peak_off VARCHAR(100),
	peak_value_id INT
) ON [PRIMARY]



-----------########################### Find out the reference Curve
SET @user_login_id=dbo.FNADBUser()

SET @tempTable=dbo.FNAProcessTableName('pricecurve_reference', @user_login_id,@process_id)

EXEC spa_get_price_curve_reference @tempTable

-----############# Reference Curve fetch completed

-----------#############################Get all the Items first
SELECT @deal_volume_str=CASE WHEN @options='d' THEN 'CASE WHEN (sdh.option_flag = ''y'') THEN CASE WHEN ISNULL(sdd.leg,-1)=1 THEN sdpdo.deal_volume* DELTA WHEN  ISNULL(sdd.leg,-1)=2 THEN sdpdo.deal_volume2*DELTA2 ELSE 0 END ELSE  sdd.deal_volume END ' ELSE ' sdd.deal_volume' END

SET @sql_Select = 
	'INSERT INTO #tempItems
	SELECT    
			sdh.source_deal_header_id, ssbm.fas_book_id, '+
			case when @deal_process_id IS not NULL then '''''' else 
			'dbo.FNAHyperLinkText(10131010, (cast(sdh.source_deal_header_id as VARCHAR) + ''('' + sdh.deal_id +  '')''),sdh.source_deal_header_id)' 
			END +', 
			(sdd.term_start) AS contract_expiration_date,
			CASE WHEN(sdd.deal_volume_frequency = ''d'') THEN 
					
					CASE WHEN (sdd.buy_sell_flag = ''s'') THEN -1 * '+ @deal_volume_str+' 
								   ELSE '+ @deal_volume_str+' END 
					ELSE
						CASE WHEN (sdd.buy_sell_flag = ''s'') THEN -1 * '+ @deal_volume_str+' 
							ELSE '+ @deal_volume_str+'  END 
			END *ISNULL(cr.factor,1)*ISNULL(NULLIF(sdd.price_multiplier,0),1) AS NetItemVol, 
			
			CASE WHEN sdd.deal_volume_frequency=''m'' THEN ''Monthly'' 
				  WHEN sdd.deal_volume_frequency=''a'' THEN ''Annually'' 
				  WHEN sdd.deal_volume_frequency=''d'' THEN ''Daily'' 
					WHEN sdd.deal_volume_frequency=''w'' THEN ''Weekly''
				  WHEN sdd.deal_volume_frequency=''s'' THEN ''Semi-Annually'' 
				  WHEN sdd.deal_volume_frequency=''q'' THEN ''Quarterly''
				  WHEN sdd.deal_volume_frequency=''t'' THEN ''Term'' 
				  WHEN sdd.deal_volume_frequency=''h'' AND '''+@granularity_type+'''=''t'' THEN ''Hourly''
				  WHEN sdd.deal_volume_frequency=''h'' AND DATEDIFF(day,sdd.term_start,sdd.term_end)<=0  AND '''+@summary_option+''' NOT IN (''t'',''d'') THEN ''Daily''
				  WHEN sdd.deal_volume_frequency=''h'' AND DATEDIFF(day,sdd.term_start,sdd.term_end)>1  AND '''+@summary_option+''' NOT IN(''t'',''d'') THEN ''Monthly''
				  WHEN sdd.deal_volume_frequency=''h'' AND (('''+@granularity_type+'''=''d'' AND '''+@summary_option+''' IN(''t'',''d''))) THEN ''Hourly''

				END AS deal_volume_frequency, 
			 CASE WHEN(sdd.fixed_float_leg = ''f'') THEN ''Fixed'' ELSE COALESCE (pspcd.curve_name, spcd.curve_name) END AS IndexName, 
			 case when (isnull(sdd.price_multiplier, 0) = 0) or sdd.price_multiplier=1 then sdd.deal_volume_uom_id else COALESCE (pspcd.uom_id, spcd.uom_id) end  deal_volume_uom_id,
			 --sdd.deal_volume_uom_id,
			 sdh.deal_date,
			 sdd.term_start, 
			 sdd.term_end, 
			0,
			COALESCE(spcd1.block_type,sdh.block_type),
			COALESCE(spcd1.block_define_id,sdh.block_define_id),
			sdd.deal_volume_frequency,
			mi.location_name,
			sdd.physical_financial_flag,
			scom.commodity_id,
			CASE WHEN(sdd.fixed_float_leg = ''f'') THEN -1 ELSE COALESCE (pspcd.source_curve_def_id, spcd.source_curve_def_id) END AS curve_id,
			ssbm.fas_deal_type_value_id ,
			case when fas_deal_type_value_id=409 then
				CASE WHEN(sdd.deal_volume_frequency = ''d'') THEN 
					(CASE WHEN (sdd.buy_sell_flag = ''s'') THEN -1 * '+ @deal_volume_str+' 
								   ELSE '+ @deal_volume_str+' END)  
				ELSE
					(CASE WHEN (sdd.buy_sell_flag = ''s'') THEN -1 * '+ @deal_volume_str+' 
							ELSE '+ @deal_volume_str+'  END) 
				END *ISNULL(cr.factor,1)*ISNULL(NULLIF(sdd.price_multiplier,0),1) 
			 elSE 0 end load_volume,
			 case when scom.commodity_id=''Natural Gas'' then '''' else isnull(peak.code,'''') end peak_off,
			 CASE WHEN peak.value_id=12000 THEN 1 ELSE 2 END as peak_value_id
	 FROM         
			'+ @tbl_name_header +' sdh 
			INNER JOIN ' +@tbl_name_detail +' sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
			LEFT JOIN '+@tempTable+' cr ON ISNULL(cr.curve_id,-1)=sdd.curve_id
			LEFT OUTER JOIN source_price_curve_def spcd ON ISNULL(cr.Curve_ref_id,sdd.curve_id) = spcd.source_curve_def_id
			LEFT OUTER JOIN source_price_curve_def pspcd ON spcd.proxy_source_curve_def_id = pspcd.source_curve_def_id
			INNER JOIN source_system_book_map ssbm ON sdh.source_system_book_id1 = ssbm.source_system_book_id1 AND 
					   sdh.source_system_book_id2 = ssbm.source_system_book_id2  
					   AND sdh.source_system_book_id3 = ssbm.source_system_book_id3  
					   AND sdh.source_system_book_id4 = ssbm.source_system_book_id4	
			INNER JOIN portfolio_hierarchy book ON ssbm.fas_book_id = book.entity_id 
			INNER JOIN portfolio_hierarchy stra ON book.parent_entity_id = stra.entity_id 
			INNER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id
			INNER JOIN fas_strategy fs ON stra.entity_id = fs.fas_strategy_id
			left join source_commodity scom on scom.source_commodity_id=isnull(pspcd.commodity_id,spcd.commodity_id)
			LEFT JOIN source_minor_location mi on sdd.location_id=mi.source_minor_location_id 
			LEFT JOIN source_major_location ma  on ma.source_major_location_id=mi.source_major_location_id'
	+CASE WHEN @options='d' THEN 
			' LEFT JOIN source_deal_pnl_detail_options sdpdo ON
						sdpdo.as_of_date=CONVERT(DATETIME, ''' + @as_of_date + ''' , 102) 
						AND sdpdo.source_deal_header_id=sdh.source_deal_header_id
						AND sdpdo.term_start=sdd.term_start
						--AND sdpdo.curve_1=sdd.curve_id
				'
		  ELSE '' END
	+' LEFT JOIN source_deal_detail sdd1 on sdh.source_deal_header_id=sdd1.source_deal_header_id
					  AND sdd.term_start=sdd1.term_start and sdd1.leg=1
	   LEFT JOIN source_price_curve_def spcd1 ON sdd1.curve_id = spcd1.source_curve_def_id
			left JOIN static_data_value peak ON COALESCE(spcd1.block_type,sdh.block_type)=peak.value_id 
	
		' + CASE WHEN @deal_list_table IS NOT NULL THEN ' INNER JOIN #source_deal_header_id t ON sdh.source_deal_header_id = t.source_deal_header_id ' ELSE '' END + ''		 
	+' WHERE 1=1 '
		+ case when @transaction_type is not null then ' 
		AND (ssbm.fas_deal_type_value_id in( ' + @transaction_type  + '))' else '' end
	+ ' AND ISNULL(sdh.internal_deal_subtype_value_id,-1)<>'+CAST(@storage_inventory_sub_type_id AS VARCHAR)
	+ CASE WHEN @options='n' THEN ' AND ISNULL(sdh.option_flag,''n'')<>''y''' ELSE '' END
	+ CASE WHEN @drill_index IS NOT NULL AND @group_by='i' AND @drill_index<>'Fixed' THEN ' AND spcd.curve_name='''+@drill_index+'''' ELSE '' END
	+ CASE WHEN @drill_index IS NOT NULL AND @group_by='i' AND  @drill_index='Fixed' THEN ' AND sdd.fixed_float_leg = ''f''' ELSE '' END
	+ CASE WHEN @drill_index IS NOT NULL AND @group_by='l'THEN ' AND ISNULL(mi.location_name,'''') = '''+ISNULL(@drill_index,'')+'''' ELSE '' END
	+ CASE WHEN  @sub_entity_id IS NOT NULL THEN ' AND sub.entity_id IN  (' + @sub_entity_id + ') '  ELSE '' END
	+ CASE WHEN  @source_deal_header_id IS NOT NULL THEN ' AND (sdh.source_deal_header_id IN (' + cast(@source_deal_header_id as VARCHAR) + ')) '  ELSE '' END
	--+ CASE WHEN  @detail_deal_id IS NOT NULL THEN ' AND (sdh.source_deal_header_id IN (' + cast(@detail_deal_id as VARCHAR) + ')) '  ELSE '' END
	+ CASE WHEN  @deal_id IS NOT NULL THEN 	' AND sdh.deal_id = ''' + cast(@deal_id as VARCHAR) + ''''  ELSE '' END
	+ CASE WHEN  @commodity_id IS NOT NULL THEN ' AND spcd.commodity_id = ''' + cast(@commodity_id as VARCHAR) + ''''  ELSE '' END
	+ CASE WHEN @source_deal_header_id is  null and @deal_id is  null THEN 
					' AND (sdh.deal_date <= CONVERT(DATETIME, ''' + @as_of_date + ''' , 102)) ' + @term_where_clause ELSE '' END
	+ CASE WHEN  @strategy_entity_id IS NOT NULL THEN ' AND (stra.entity_id IN(' + @strategy_entity_id + ' ))'  ELSE '' END

	+ CASE WHEN  @strategy_entity_id IS NOT NULL THEN ' AND (stra.entity_id IN(' + @strategy_entity_id + ' ))'  ELSE '' END
	+ CASE WHEN  @book_entity_id IS NOT NULL THEN ' AND (book.entity_id IN(' + @book_entity_id + ')) ' ELSE '' END
	+ CASE WHEN  @source_system_book_id1 IS NOT NULL  THEN ' AND (sdh.source_system_book_id1 IN (' + cast(@source_system_book_id1 as VARCHAR)+ ')) ' ELSE '' END
	+ CASE WHEN  @source_system_book_id2 IS NOT NULL   THEN ' AND (sdh.source_system_book_id2 IN (' + cast(@source_system_book_id2 as VARCHAR)+ ')) ' ELSE '' END
	+ CASE WHEN  @source_system_book_id3 IS NOT NULL   THEN ' AND (sdh.source_system_book_id3 IN (' + cast(@source_system_book_id3 as VARCHAR)+ ')) ' ELSE '' END
	+ CASE WHEN  @source_system_book_id4 IS NOT NULL   THEN ' AND (sdh.source_system_book_id4 IN (' + cast(@source_system_book_id4 as VARCHAR)+ ')) ' ELSE '' END
	+ CASE WHEN  @major_location IS NOT NULL THEN ' AND ma.source_major_location_id in (' +@major_location + ')'  ELSE '' END
	+ CASE WHEN  @minor_location IS NOT NULL THEN ' AND sdd.location_id in (' +@minor_location + ')' ELSE '' END
	+ CASE WHEN  @index IS NOT NULL THEN  ' AND sdd.curve_id in (' +@index + ')' ELSE '' END
	+ CASE WHEN @physical_financial_flag<>'b' THEN ' AND sdd.physical_financial_flag='''+@physical_financial_flag+'''' ELSE '' END 
	+ CASE WHEN @sub_type<>'b' THEN ' AND sdh.deal_sub_type_type_id='+@sub_type ELSE '' END 
--	+@drill_contract_month_clause
	+' AND (( sdd.contract_expiration_date>='''+@as_of_date+''' AND sdd.leg<>1) OR sdd.leg=1)'
	+' AND sdd.curve_id IS NOT NULL'
	+ CASE WHEN @deal_type IS NOT NULL THEN ' AND sdh.source_deal_type_id='+CAST(@deal_type AS VARCHAR) ELSE '' END
	+ CASE WHEN @trader_id IS NOT NULL THEN ' AND sdh.trader_id='+CAST(@trader_id AS VARCHAR) ELSE '' END
	+ CASE WHEN @deal_status IS NOT NULL THEN ' AND sdh.deal_status='+CAST(@deal_status AS VARCHAR) ELSE '' END
	+ CASE WHEN @tenor_from IS NOT NULL THEN ' AND sdd.term_start>='''+@tenor_from+'''' ELSE '' END
	+ CASE WHEN @tenor_to IS NOT NULL THEN ' AND sdd.term_start<='''+@tenor_to+'''' ELSE '' END
    
EXEC spa_print 'Print:', @sql_Select, @sql_Where
EXEC (@sql_Select + @sql_Where)
EXEC spa_print 'End'



CREATE TABLE [dbo].[#tempMTM] (
	term varchar(100),
	mtm FLOAT	
) 
--CREATE TABLE [dbo].[#tempLoad] (
--	term_start datetime,
--	market_cost FLOAT,	
--	total_Volume float	
--) 

CREATE index indx_tempItems1 ON #tempItems (source_deal_header_id)
CREATE index indx_tempItems2 ON #tempItems (term_start)
CREATE index indx_tempItems3 ON #tempItems (term_end)



SET @Sql_Select='
	insert into [dbo].[#tempMTM] (term ,mtm )
	SELECT '+
			case when (@granularity_type in ('t')) then  ' dbo.FNADateformat(m.term_start) AS Term, ' 
			WHEN (@granularity_type in ('m')) then  ' dbo.FNADateformat(dbo.FNAGetContractMonth(m.term_start)) AS Term, ' 			
			else ' dbo.FNAGetTermGrouping(m.term_start , ''' + @granularity_type + ''') AS Term, ' end + 				
	'
		
	SUM(und_pnl) mtm 
	FROM 	'	+	dbo.FNAGetProcessTableName(@as_of_date, 'source_deal_pnl') + ' 
	 m 
	INNER JOIN (
			SELECT 	distinct	[source_deal_header_id],
			term_start,
			term_end FROM #tempItems
		) d ON 
			d.[source_deal_header_id]=m.[source_deal_header_id] AND 
			d.term_start=m.term_start AND
			d.term_end=m.term_end AND
			m.pnl_as_of_date='''+CAST(@as_of_date AS VARCHAR) +''' AND
			m.pnl_source_value_id='+case when @curve_source_id is not null then  '' + CAST(@curve_source_id AS VARCHAR) else  '4500' end +'
	group by ' +
	case when (@granularity_type in ('t')) then  ' dbo.FNADateformat(m.term_start) ' 
			WHEN (@granularity_type in ('m')) then  ' dbo.FNADateformat(dbo.FNAGetContractMonth(m.term_start)) ' 			
			else ' dbo.FNAGetTermGrouping(m.term_start , ''' + @granularity_type + ''')'
	end		
exec spa_print @Sql_Select
EXEC(@Sql_Select) 


--##########################################################################################
--Create a temporary table to SP "spa_get_dealvolume_mult_byfrequency". This SP will return volume multiplier based on frequency





--SELECT * FROM #tempItems
DECLARE @as_of_date_mult DATETIME
DECLARE @as_of_date_mult_to DATETIME


SET @as_of_date_mult=@as_of_date
SET @as_of_date_mult_to=@as_of_date

IF @settlement_option<>'f'
	SET @as_of_date_mult='1900-01-01'
IF @settlement_option<>'s'
	SET @as_of_date_mult_to='9999-01-01'

---

DECLARE @vol_frequency_table VARCHAR(100),@vol_frequency_table_conv VARCHAR(100)
SET @vol_frequency_table=dbo.FNAProcessTableName('deal_volume_frequency_mult', @user_login_id, @process_id)
SET @vol_frequency_table_conv=dbo.FNAProcessTableName('deal_volume_frequency_mult_conv', @user_login_id, @process_id)

set @sql_Select='SELECT DISTINCT 
					term_start, 
					term_end,
					volume_frequency AS deal_volume_frequency,
					block_type,
					block_definition_id
					,block_definition_id deal_block_definition_id
			INTO '+@vol_frequency_table+'
			FROM
				#tempItems	
			WHERE 
				volume_frequency IN(''d'',''h'')'
EXEC(@sql_Select)

EXEC spa_get_dealvolume_mult_byfrequency @vol_frequency_table,@as_of_date_mult,@as_of_date_mult_to

set @sql_Select='ALTER TABLE '+@vol_frequency_table+' ADD  conv_hour_factot float,org_Volume_Mult int'
EXEC spa_print @sql_Select
exec(@sql_Select)

EXEC('update '+@vol_frequency_table+'  set conv_hour_factot=1,org_Volume_Mult=Volume_Mult ')
--set @sql_Select='ALTER TABLE '+@vol_frequency_table+' drop column  Volume_Mult'
--PRINT @sql_Select
--exec(@sql_Select)
--
if @block_definition_id_on is not null --OnPeak
BEGIN
	SET @sql_Select='update ' +@vol_frequency_table+' set block_definition_id='+ cast(@block_definition_id_on AS VARCHAR)+'  where block_type=12000'
	exec spa_print @sql_Select
	exec(@sql_Select) 
END

if @block_definition_id_off is not null --OffPeak
BEGIN
	SET @sql_Select='update ' +@vol_frequency_table+' set block_definition_id='+ cast(@block_definition_id_off AS VARCHAR)+'  where block_type=12001'
	exec spa_print @sql_Select
	exec(@sql_Select) 
END

set @sql_Select='SELECT DISTINCT 
					term_start, 
					term_end,
					deal_volume_frequency,
					block_type,
					block_definition_id
			INTO '+@vol_frequency_table_conv+'
			FROM
				'+@vol_frequency_table
EXEC(@sql_Select)

		

EXEC spa_get_dealvolume_mult_byfrequency @vol_frequency_table_conv,@as_of_date_mult,@as_of_date_mult_to

set @sql_Select='update a set conv_hour_factot=isnull(cast(org_Volume_Mult as numeric(38,8))/replace(b.Volume_Mult, 0, 1),1)
      from '+@vol_frequency_table+' a inner join '+@vol_frequency_table_conv+' b on a.term_start=b.term_start and 
					a.term_end=b.term_end and
					a.deal_volume_frequency=b.deal_volume_frequency and 
					a.block_type=b.block_type and
					a.block_definition_id=b.block_definition_id'
exec spa_print @sql_Select
EXEC(@sql_Select)
			
set @sql_Select='update a set Volume_Mult=isnull(b.Volume_Mult,1)
      from '+@vol_frequency_table+' a inner join '+@vol_frequency_table_conv+' b on a.term_start=b.term_start and 
					a.term_end=b.term_end and
					a.deal_volume_frequency=b.deal_volume_frequency and 
					a.block_type=b.block_type and
					a.block_definition_id=b.block_definition_id'
exec spa_print @sql_Select
EXEC(@sql_Select)			


DECLARE @group_by_sql VARCHAR(200)	
DECLARE @fields_sql VARCHAR(200)

SET @fields_sql=' commodity [Commodity], peak_off [Offpeak],' +CASE WHEN @group_by='i' THEN ' IndexName as [Index Name], ' ELSE ' Location, ' END 
SET @group_by_sql=' commodity, peak_off,' +CASE WHEN @group_by='i' THEN ' IndexName, ' ELSE ' Location, ' END 


SET @Sql_Select = '
	SELECT ' +  
			@fields_sql+
			case when (@granularity_type in ('t')) then  ' dbo.FNADateformat(A.ContractMonth) AS Term, ' 
			WHEN (@granularity_type in ('m')) then  ' dbo.FNADateformat(dbo.FNAGetContractMonth(A.ContractMonth)) AS Term, ' 			
			else ' dbo.FNAGetTermGrouping(A.ContractMonth , ''' + @granularity_type + ''') AS Term, ' end + 				
			' SUM(ISNULL(A.[NetItemVol],0)) AS [Volume],
			'+CASE WHEN @granularity_type='m' THEN '''Monthly'''
				   WHEN @granularity_type='q' THEN '''Quaterly'''
				   WHEN @granularity_type='s' THEN '''Semi-Annually'''
				   WHEN @granularity_type='a' THEN '''Annualy'''
					WHEN @granularity_type='w' THEN '''Weekly'''
				   ELSE ' A.VolumeFrequency ' END +' AS [Volume Frequency], 
			A.VolumeUOM [Volume UOM]'+CASE WHEN @show_cross_tabformat='y' 
			THEN ',MAX(A.ContractMonth) AS [Actual Term],SUM(ISNULL(A.Physical_volume,0)) AS [Physical Volume],SUM(ISNULL(A.NetItemAmt,0)) AS [Net Item Amount]
			,sum(load_volume) [Load Volume],sum(load_cost) [Load Cost],
			
			sum(
				case when commodity=''Natural Gas''  then Vol_equ else 0 end
				+
				(case when commodity=''Electricity'' and peak_off=''On Peak'' then Vol_equ else 0 end * isnull(rt_on.heat_rate,1)) 
				+
				(case when commodity=''Electricity'' and peak_off=''Off Peak'' then Vol_equ else 0 end * isnull(rt_off.heat_rate,1)) 
			) as 	Vol_equ
--			sum(Vol_equ) [Volume Equ]
			,MAX(peak_value_id)peak_value_id  ' ELSE '' END
			+  @str_batch_table +	'				  			     
	FROM     
			portfolio_hierarchy sub INNER JOIN
			portfolio_hierarchy stra INNER JOIN
			(SELECT  
					it.fas_book_id AS fas_book_id, 
					 '+@group_by_sql+' 
					it.ced AS ContractMonth,  
					it.dvf AS VolumeFrequency,
					IUOM.uom_name AS VolumeUOM, 
					it.NetItemVol AS NetItemVol,
					it.Physical_volume,
					it.NetItemAmt,
					it.load_volume,load_cost,it.Vol_equ,
					it.peak_value_id
			  FROM 
					(
						SELECT fas_book_id, 
							ti.term_start AS ced,
							ti.deal_volume_frequency AS dvf, 
							'+@group_by_sql+' 
							ti.sui,
							sum(case when physical_financial_flag=''p'' then '
							+CASE WHEN @granularity_type='t' or @summary_option='r' THEN 
								'case when commodity=''Natural Gas'' then cast((ti.NetItemVol*ISNULL(vft.Volume_Mult,1)) as numeric(38,8))/(datediff(day,ti.term_start,ti.term_end)+1) else ti.NetItemVol*ISNULL(vft.conv_hour_factot,1) end ' 
							ELSE ' ti.NetItemVol*ISNULL(vft.Volume_Mult,1) ' END +
							' ELSE 0 end) Physical_volume,
							sum('
							+CASE WHEN @granularity_type='t' or @summary_option='r' THEN 
								'case when commodity=''Natural Gas'' then cast((ti.NetItemVol*ISNULL(vft.Volume_Mult,1)) as numeric(38,8))/(datediff(day,ti.term_start,ti.term_end)+1) else ti.NetItemVol*ISNULL(vft.conv_hour_factot,1) end ' 
							 ELSE ' ti.NetItemVol*ISNULL(vft.Volume_Mult,1) ' END +
							') NetItemVol,
							sum('
							+CASE WHEN @granularity_type='t' THEN 
								' case when commodity=''Natural Gas'' then cast((ti.NetItemVol*ISNULL(vft.Volume_Mult,1)) as numeric(38,8))/(datediff(day,ti.term_start,ti.term_end)+1) else ti.NetItemVol*ISNULL(vft.conv_hour_factot,1) end ' 
							 ELSE ' ti.NetItemVol*ISNULL(vft.Volume_Mult,1) ' END +
							') NetItemAmt,
							sum(ti.load_volume*ISNULL(vft.Volume_Mult,1)) load_volume,
							sum(spc.curve_value*ti.load_volume*ISNULL(vft.Volume_Mult,1)) load_cost,
							sum(ti.NetItemVol*ISNULL(vft.org_Volume_Mult,1)) Vol_equ,
							--sum(ti.NetItemVol*ISNULL(vft.Volume_Mult,1)) Vol_equ,
							MAX(peak_value_id)peak_value_id
					  FROM   #tempItems ti
							LEFT JOIN '+@vol_frequency_table+' vft ON
							vft.term_start=ti.term_start AND
							vft.term_end=ti.term_end AND
							vft.deal_volume_frequency=ti.volume_frequency AND
							ISNULL(vft.block_type,-1)=ISNULL(ti.block_type,-1) AND
							ISNULL(vft.deal_block_definition_id,-1)=ISNULL(ti.block_definition_id,-1)
						inner join source_price_curve spc on spc.source_curve_def_id=ti.curve_id and
							 spc.maturity_date=ti.term_start AND spc.as_of_date='''+cast(@as_of_date as varchar)+'''
							 and curve_source_value_id='+case when @curve_source_id is not null then  '' + CAST(@curve_source_id AS VARCHAR) else  '4500' end +'
						GROUP BY 
							ti.fas_book_id,ti.term_start, --ti.contract_expiration_date,
							 ti.deal_volume_frequency, '+@group_by_sql+'  ti.sui
					) it  
						left JOIN source_uom IUOM on IUOM.source_uom_id=it.sui
			 ) A 
				INNER JOIN portfolio_hierarchy book ON A.fas_book_id = book.entity_id ON stra.entity_id = book.parent_entity_id 
							ON sub.entity_id = stra.parent_entity_id 
			left join 
				( select spc.maturity_date term ,spc.curve_value heat_rate from source_price_curve_def spcd
					inner join source_price_curve spc   on spcd.source_curve_def_id=spc.source_curve_def_id and spc.as_of_date='''+ cast(@as_of_date as varchar) +''' and spc.curve_source_value_id='+case when @curve_source_id is not null then cast(@curve_source_id as varchar) else '4500' end +'
					and  spcd.source_curve_type_value_id=578 and spcd.curve_id=''Mead/SoCal On HR''
				) rt_on on rt_on.term=A.contractMonth
				left join 
				( select spc.maturity_date term ,spc.curve_value heat_rate from source_price_curve_def spcd
					inner join source_price_curve spc on spcd.source_curve_def_id=spc.source_curve_def_id and spc.as_of_date='''+ cast(@as_of_date as varchar) +''' and spc.curve_source_value_id='+case when @curve_source_id is not null then cast(@curve_source_id as varchar) else '4500' end +'
					and  spcd.source_curve_type_value_id=578 and spcd.curve_id=''Mead/SoCal Off HR''
				) rt_off on rt_off.term=A.contractMonth


	 GROUP BY  '+@group_by_sql+
			case when (@granularity_type IN ( 'd')) then  ' A.ContractMonth, ' 
			  when (@granularity_type IN ( 't')) then  ' A.ContractMonth,' 
			WHEN (@granularity_type in ('m')) then  ' dbo.FNAGetContractMonth(A.ContractMonth),' 
			 else '  
					substring(dbo.FNAGetTermGrouping(A.ContractMonth , ''' + @granularity_type + ''') ,
					len(dbo.FNAGetTermGrouping(A.ContractMonth , ''' + @granularity_type + ''')) -3, 4), 
					dbo.FNAGetTermGrouping(A.ContractMonth , ''' + @granularity_type + '''), ' end +' A.VolumeFrequency, 
			 A.VolumeUOM'


EXEC spa_print ' @summary_Option:', @summary_Option, '            @granularity_type:', @granularity_type

SET @Sql_Select = @Sql_Select + 
	' ORDER BY '+@group_by_sql+
	case when (@granularity_type IN ( 'd')) then  ' A.ContractMonth ' 
	WHEN (@granularity_type in ('m')) then  ' dbo.FNAGetContractMonth(A.ContractMonth) ' 	
	else '  
		substring(dbo.FNAGetTermGrouping(A.ContractMonth , ''' + @granularity_type + ''') , len(dbo.FNAGetTermGrouping(A.ContractMonth , ''' + @granularity_type + ''')) -3, 4), 
		dbo.FNAGetTermGrouping(A.ContractMonth , ''' + @granularity_type + ''') '  
	end

IF @show_cross_tabformat='y' AND @summary_Option<>'d' -----show the report in cross tab format
BEGIN
	CREATE TABLE #tempPivot
	(commodity varchar(100) COLLATE DATABASE_DEFAULT,peak_off varchar(100) COLLATE DATABASE_DEFAULT,Item VARCHAR(100) COLLATE DATABASE_DEFAULT,[Term] VARCHAR(20) COLLATE DATABASE_DEFAULT,Volume FLOAT,VolumeFrequency VARCHAR(20) COLLATE DATABASE_DEFAULT,
	VolumeUOM VARCHAR(20) COLLATE DATABASE_DEFAULT
	,[actualTerm] DATETIME
	,Physical_volume float,
	NetItemAmt FLOAT,
	load_volume FLOAT,
	load_cost float,Vol_equ float,peak_value_id INT)
	
	set @Sql_Select=replace(@Sql_Select,@str_batch_table,'')
	SET @Sql_Select=' INSERT INTO #tempPivot'+@Sql_Select	
	exec spa_print @Sql_Select	  	
	EXEC(@Sql_Select)


	if @summary_option='r'
	begin
		EXEC spa_print '	UPDATE #tempPivot SET volume=cast(volume AS NUMERIC(38,8))/nullif((12-case when year(@as_of_date)=term then month(@as_of_date) ELSE 0 END),0)'
	--select * from #tempPivot order by term
		UPDATE #tempPivot SET volume=cast(volume AS NUMERIC(38,8))/nullif((12-case when year(@as_of_date)=term then month(@as_of_date) ELSE 0 END),0)

		UPDATE #tempPivot SET physical_volume=cast(physical_volume AS NUMERIC(38,8))/nullif((12-case when year(@as_of_date)=term then month(@as_of_date) ELSE 0 END),0) 
	 
	--select (12-case when year(@as_of_date)=term then month(@as_of_date) ELSE 0 END) divv,* from #tempPivot order by term

	end





--	SELECT * FROM #tempPivot
	DECLARE @listCol_SUM VARCHAR(Max)
	set @listCol_SUM=''

	CREATE TABLE #temp_order (actualTerm int,Term VARCHAR(50) COLLATE DATABASE_DEFAULT,no_hrs INT)
	set @Sql_Select='insert into #temp_order(actualTerm ,Term ,no_hrs)
		select '+ case when @granularity_type in ('t','m') then 'top(1000)' ELSE '' END +' YEAR([Term])[actualTerm],[Term],'+
		case  when @granularity_type in ('t','m') then
			'datediff(day,[Term],dateadd(month,1,[Term]))' 
		else
			' abs((datediff(day,term+''-01-01'',term+''-12-31'')) - case when term='+CAST(YEAR(@as_of_date) AS VARCHAR) + ' then datediff(day,term+''-01-01'',dateadd(month,1,term+''-''+''' + CAST(month(@as_of_date) AS VARCHAR)+ '''+''-01'')) else 0 end)' 
		END 
		+'
			--* 24 -- since the requirement is day,not converting into hour.
			as no_hrs
			FROM #tempPivot GROUP BY [Term]
			 ORDER BY CAST([Term] AS DATETIME)
		   '
	exec spa_print @Sql_Select
	exec(@Sql_Select)
			
	SELECT  @listCol = STUFF(( SELECT  '],[' + [Term]
		 FROM    #temp_order ORDER BY cast([Term] as datetime)
				FOR XML PATH('')), 1, 2, '') + ']'

	SELECT  @listCol_SUM = @listCol_SUM + case when @listCol_SUM='' then '' else ',' end +'sum([' +[Term]+'])  as ['+[Term]+']'	 FROM    #temp_order  
	if @listCol_SUM=''
	BEGIN
		SET @Sql_Select='SELECT ''No Data Found...'' Status '+@str_batch_table
		EXEC(@Sql_Select)
		--RETURN 	--IF @batch_process_id is not null goto .. batch processing
		GOTO BatchProcessing
	END
	IF @listCol IS NULL
		SET @listCol='[0]'

	SET @Sql_Select='SELECT case when GROUPING(PEAK_OFF)=1 then ''yyyyy2''+COMMODITY
					else  COMMODITY  end COMMODITY,
			case when GROUPING(PEAK_OFF)=1 then ''TOTAL'' else PEAK_OFF end PEAK_OFF ,
			case when GROUPING('+ CASE WHEN @group_by='i' THEN ' [IndexName]' ELSE '[Location]' END +')=1 then
				case when GROUPING(PEAK_OFF)=1 then ''<b>TOTAL Power (Price Position)</b>''
					else  ''<b><i>TOTAL  ''  + PEAK_OFF + '' (Price Position)</i></b>'' end
			else '+ CASE WHEN @group_by='i' THEN ' [IndexName]' ELSE '[Location]' END +'
			end '+ CASE WHEN @group_by='i' THEN ' [IndexName]' ELSE '[Location]' END +' ,'+@listCol_SUM+',max(VolumeUOM) VolumeUOM,cast(MAX(peak_value_id) as float) peak_value_id,Rowid=identity(int,1,1) into  '+ @rst_report + ' from (
				SELECT COMMODITY,PEAK_OFF,[Item] AS '+ CASE WHEN @group_by='i' THEN ' [IndexName]' ELSE '[Location]' END +','+@listCol+',VolumeUOM,peak_value_id 
			 FROM (	SELECT COMMODITY,PEAK_OFF,[Item],[Term],Volume,VolumeUOM,peak_value_id FROM #tempPivot ) P
			 PIVOT	(SUM(Volume) FOR [Term] IN('+@listCol+')) AS PVT	
		) aaa group by COMMODITY,PEAK_OFF,'+ CASE WHEN @group_by='i' THEN ' [IndexName]' ELSE '[Location]' END  + ' with rollup 
			having (GROUPING(COMMODITY)=0 and COMMODITY<>''Natural Gas'')
		or (COMMODITY=''Natural Gas'' and GROUPING(PEAK_OFF)=0 )'

	EXEC spa_print @Sql_Select
	EXEC(@Sql_Select)
			
	declare @listCol_null	VARCHAR(MAX)	
	SET @listCol_null=''
	SELECT  @listCol_null = @listCol_null + case when @listCol_null='' then '' else ',' end + 'null' 	 
	FROM    #temp_order 
	

	EXEC spa_print '**********************************'
	EXEC spa_print @listCol_SUM


	SET @Sql_Select='insert into '+ @rst_report + '
		SELECT commodity,null,
		case when commodity=''Electricity'' and peak_off=''Off Peak'' then ''<b style="font-size:12px">POWER OFF PEAK (std product MW)</b>''
			when 	commodity=''Electricity'' and peak_off=''On Peak'' then ''<b style="font-size:12px">POWER ON PEAK (std product MW)''
			when 	commodity=''Natural Gas''  then ''<b style="font-size:12px">GAS (MMBTU/day)</b>''
		end,
		'+ @listCol_null + ',null,
		
		case when commodity=''Electricity'' and peak_off=''Off Peak'' then min(peak_value_id)-.5
			when 	commodity=''Electricity'' and peak_off=''On Peak'' then null
			when 	commodity=''Natural Gas''  then null
		end
		 FROM #tempPivot
		group by commodity,peak_off'
		
	EXEC spa_print @Sql_Select
	EXEC(@Sql_Select)

	SET @Sql_Select='insert into '+ @rst_report + '
					SELECT 
					
					case when grouping(PEAK_OFF)=0 then COMMODITY
						else ''yyyyyyyyyyy'' end									
					COMMODITY,case when grouping(PEAK_OFF)=1 then ''TOTAL'' else  PEAK_OFF end PEAK_OFF,
					case when grouping(PEAK_OFF)=0 then ''<b><i>TOTAL   '' + PEAK_OFF + '' (Physical Position)</i></b>''
						else ''<b>TOTAL Power (Physical Position)</b>'' end
				 tran_type,'+@listCol_sum+',max(VolumeUOM) VolumeUOM,MAX(peak_value_id)
				 FROM (
						SELECT COMMODITY,PEAK_OFF,[Term],physical_volume Volume,VolumeUOM,peak_value_id FROM #tempPivot
					 ) P
				 PIVOT
					(
						SUM(Volume) FOR [Term] IN('+@listCol+')
					) AS PVT group by 	COMMODITY,PEAK_OFF with rollup 
				having (grouping(COMMODITY)<>1 and COMMODITY<>''Natural Gas'')
				or ( COMMODITY=''Natural Gas'' and grouping(PEAK_OFF)=0)

	'
	EXEC spa_print @Sql_Select
	EXEC(@Sql_Select)


	if @summary_option in ('t','r')
	BEGIN
			SET @Sql_Select=
			'insert into '+ @rst_report + '
						SELECT ''yyyyyyyyyyyyy'' tran_type0, ''yyyyyyyyyyyyy'' tran_type,''<b>eq. all-in Price position (mmbtu/d)</b>'' tran_type1,'+@listCol+',null VolumeUOM,100
					 FROM (
							select o.term,cast(Vol_equ as float)/nullif(o.no_hrs,0) [Equiv_Price]
							from #temp_order o inner join #tempPivot t on o.term=t.term
						 ) P
					 PIVOT
						(
							SUM([Equiv_Price]) FOR [Term] IN('+@listCol+')
						) AS PVT	

				'	
		
		
		
	/*	
		
		SET @Sql_Select=
			'insert into '+ @rst_report + '
						SELECT ''yyyyyyyyyyyyy'' tran_type0, ''yyyyyyyyyyyyy'' tran_type,''<b>eq. all-in price position (mmbtu)</b>'' tran_type1,'+@listCol+',null VolumeUOM,100
					 FROM (
							select o.term,(vol.GasVol  +(vol.ElectricityVol_on * isnull(rt_on.heat_rate,1))+(vol.ElectricityVol_off * isnull(rt_off.heat_rate,1)))/nullif(o.no_hrs,0) [Equiv_Price]
							from #temp_order o inner join (
									select term ,sum(case when commodity=''Electricity'' and peak_off=''On Peak'' then Vol_equ else 0 end) ElectricityVol_on
									,sum(case when commodity=''Electricity'' and peak_off=''Off Peak'' then Vol_equ else 0 end) ElectricityVol_off
										,sum(case when commodity=''Natural Gas''  then Vol_equ else 0 end) GasVol 
										 from #tempPivot
									group by term
									) vol on vol.term=o.term
							left join 
							( select spc.maturity_date term ,spc.curve_value heat_rate from source_price_curve_def spcd
								inner join source_price_curve spc   on spcd.source_curve_def_id=spc.source_curve_def_id and spc.as_of_date='''+ cast(@as_of_date as varchar) +''' and spc.curve_source_value_id='+case when @curve_source_id is not null then cast(@curve_source_id as varchar) else '4500' end +'
								and  spcd.source_curve_type_value_id=578 and spcd.curve_id=''Mead/SoCal On HR''
							) rt_on on rt_on.term=o.term
							left join 
							( select spc.maturity_date term ,spc.curve_value heat_rate from source_price_curve_def spcd
								inner join source_price_curve spc on spcd.source_curve_def_id=spc.source_curve_def_id and spc.as_of_date='''+ cast(@as_of_date as varchar) +''' and spc.curve_source_value_id='+case when @curve_source_id is not null then cast(@curve_source_id as varchar) else '4500' end +'
								and  spcd.source_curve_type_value_id=578 and spcd.curve_id=''Mead/SoCal Off HR''
							) rt_off on rt_off.term=o.term
						 ) P
					 PIVOT
						(
							SUM([Equiv_Price]) FOR [Term] IN('+@listCol+')
						) AS PVT	

				'
			*/	
				EXEC spa_print @Sql_Select
				EXEC(@Sql_Select)
	END

	SET @Sql_Select=
		'insert into '+ @rst_report + '
					SELECT ''yyyyy'' tran_type0,tran_type,''<b>TOTAL MTM</b>'' tran_type1,'+@listCol+',VolumeUOM,200
				 FROM (
						SELECT ''yyyyy'' tran_type,t.term,isnull(m.mtm,0) mtm,null VolumeUOM FROM #tempMTM m
						right join #temp_order t  on t.term=m.term
					 ) P
				 PIVOT
					(
						SUM(mtm) FOR [Term] IN('+@listCol+')
					) AS PVT	

			'
	EXEC spa_print @Sql_Select
	EXEC(@Sql_Select)

	if @summary_option IN ('t','r')
	begin
		SET @Sql_Select=
			'insert into '+ @rst_report + '
						SELECT ''yyyyy1'' tran_type0,tran_type,''<b>''+' + case when @summary_option='t' then '''FULL LOAD ''' ELSE '''AVG ''' END  + '+'' UNIT COST</b>'' tran_type1,'+@listCol+',VolumeUOM,500
					 FROM (
							select ''yyyyy1'' tran_type, t.term,cast(((-1*sum(isnull(load_cost,0)))-sum(isnull(m1.mtm,0))) as numeric(38,8))/(-1*nullif(sum(m.load_volume),0)) total_load,null VolumeUOM 
							FROM (  
								select term ,sum(isnull(load_cost,0)) load_cost,sum(load_volume) load_volume 
								FROM #tempPivot group by term
							) m inner join #tempMTM m1 on m.term=m1.term AND isnull(m.load_volume,0)<>0
							right join #temp_order t  on t.term=m.term group by t.term
						 ) P
					 PIVOT
						(
							SUM(total_load) FOR [Term] IN('+@listCol+')
						) AS PVT	

				'
				EXEC spa_print @Sql_Select
				EXEC(@Sql_Select)
	end


	SET @listCol_SUM=''
--	SELECT  @listCol_SUM = @listCol_SUM + case when @listCol_SUM='' then '' else ',' end +'round([' +[Term]+'],'+@round_value+')  as [' + case when @summary_option in ('t','m') then left(DATENAME(month, cast([Term] as datetime)),3)+'-'+  cast(DATENAME(YEAR, cast([Term] as datetime)) AS VARCHAR) else [Term] end + ']'	 
	SELECT  @listCol_SUM = @listCol_SUM + case when @listCol_SUM='' then '' else ',' end +'[' +[Term]+']  as [' + case when @summary_option in ('t','m') then left(DATENAME(month, cast([Term] as datetime)),3)+'-'+  cast(DATENAME(YEAR, cast([Term] as datetime)) AS VARCHAR) else [Term] end + ']'	 
	FROM    #temp_order 





	-- Remove "Total Power (Price Position)" and "Total Power (Physical Positon)" lines from Monthly Avg and Annual Avg. 
	DECLARE @sql VARCHAR(200)
	IF @summary_option = 't' OR @summary_option = 'r'
	SET @sql = 'DELETE FROM ' + @rst_report + ' WHERE '+CASE WHEN @group_by='i' THEN '[IndexName]' ELSE '[Location]' END + ' LIKE ''%TOTAL Power%'''
	EXEC (@sql)


	--exec('select * from '+ @rst_report + ' order by COMMODITY,peak_value_id,rowid')
	set @Sql_Select='select '+ CASE WHEN @group_by='i' THEN ' [IndexName] as [Product]' ELSE '[Location]' END +','+@listCol_SUM+' from '+ @rst_report + ' order by COMMODITY,peak_value_id,rowid'
	EXEC spa_print @Sql_Select
	EXEC(@Sql_Select) 
--			select * from #tempMTM
--			select * from #tempload
END
ELSE
	BEGIN

		EXEC spa_print @Sql_Select
		EXEC(@Sql_Select)
	END

---------==============================

--*****************FOR BATCH PROCESSING**********************************    
BatchProcessing:     
IF  @batch_process_id is not null        
BEGIN        
	 SELECT @str_batch_table=dbo.FNABatchProcess('u',@batch_process_id,@batch_report_param,GETDATE(),NULL,NULL)
	 EXEC(@str_batch_table)        
	 declare @report_name VARCHAR(100)        

	 set @report_name='Run Trader Position Report'        
	        
	 SELECT @str_batch_table=dbo.FNABatchProcess('c',@batch_process_id,@batch_report_param,GETDATE(),'spa_Create_Position_Report',@report_name)         
	 EXEC(@str_batch_table)        
	        
END        
--********************************************************************
