
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[derivative_position_report]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[derivative_position_report]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/******************** Modification History **************************
  Modified By			: Pawan KC                                  
  Modification Date	: 11 Feb 2009								
  Modification Detail	: Added parameter @commodity_id 			
*******************************************************************
  Modified By			: Pawan KC                                  
  Modification Date	: 19 Feb 2009								
  Modification Detail	: Shifted Parameters @batch_process_id,		
						  @batch_report_param at the end of the	    
						  parameter list for the BATCH Processing	
  Modified By			: Pawan KC                                  
  Modification Date	: 19 Feb 2009								
  Modification Detail	: Shifted Parameters @batch_process_id,		
						  @batch_report_param at the end of the	    
						  parameter list for the BATCH Processing
	
  Modified By			: Anal Shrestha                                  
  Modification Date		: March 24 2009							
  Modification Detail	: Added the reference curve logic 

  Modified By			: Anal Shrestha                                  
  Modification Date		: April 29 2009							
  Modification Detail	: Added Group By option 
  
  Modified By			: Rajiv Basnet                                  
  Modification Date		: 17 Jan 2012							
  Modification Detail	: Added filter counterparty_options

********************************************************************/

CREATE PROC [dbo].[derivative_position_report]
	@as_of_date VARCHAR(50), 
	@subsidiary_id VARCHAR(MAX), 
	@strategy_id VARCHAR(MAX) = NULL, 
	@book_id VARCHAR(MAX) = NULL, 
	@summary_option CHAR(1), --'t'- term 'm' - By Month 'q' - By quater,'s' - By semiannual,'a' - By Annual, 'r' - Deal Summary, 'd' - Deal detail, 'i' - just by index
	@convert_unit_id INT = null,
	@settlement_option CHAR(1) = 'f', 
	@source_system_book_id1 INT=NULL, 
	@source_system_book_id2 INT=NULL, 
	@source_system_book_id3 INT=NULL, 
	@source_system_book_id4 INT=NULL,
	@transaction_type VARCHAR(100)=NULL,
	@source_deal_header_id VARCHAR(50)=NULL,
	@deal_id VARCHAR(50)=NULL,
	@as_of_date_from VARCHAR(50)=NULL, 
	@options CHAR(1)='d',--'d'- include delta positions, 'n'-Do not include delta positions
	@drill_index VARCHAR(100)=NULL,
	@drill_contractmonth VARCHAR(100)=NULL,
	@major_location VARCHAR(250)= NULL,
	@location_id VARCHAR(250) = NULL,
	@curve_id VARCHAR(MAX) = NULL,
	@commodity_id INT=NULL,
--	@deal_sub_type CHAR(1)='b', --'b' both, 'f' forward,'s' spot
	@deal_sub_type INT = NULL,
	@group_by CHAR(1)='i',-- 'i'-index,'l'-location
	@physical_financial_flag CHAR(1)='b',	--'b' both, 'p' physical, 'f' financial
	@deal_type INT=NULL,
	@trader_id INT=NULL,
	@tenor_from VARCHAR(20)=NULL,
	@tenor_to VARCHAR(20)=NULL,
	@show_cross_tabformat CHAR(1)='n',
	@deal_process_id VARCHAR(100)=NULL,  --when call from Check Position in deal insert
	@deal_status INT = NULL,
	@round_value CHAR(1) = '0',
	@book_transfer CHAR(1) = 'n',
	@counterparty_id VARCHAR(MAX) =NULL,
	@show_per CHAR(1) = NULL,
	@match CHAR(1) = 'n',
	--Added
	@drill_VolumeUOM VARCHAR(20) = NULL,
	@buySell_flag CHAR(1)=NULL,
	@show_hedgeVolume CHAR(1)='n',
	@counterparty_option CHAR(1) = 'a', --i means only internal and e means only external, a means all
	
	@batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL, 
	@enable_paging INT = 0,  --'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL
	

AS
BEGIN
SET NOCOUNT ON

--##############################################uncomment these to test locally
	-- declare @as_of_date VARCHAR(50)
	-- declare 	@subsidiary_id VARCHAR(100)
	-- declare 	@strategy_id VARCHAR(100)
	-- declare 	@book_id VARCHAR(100)
	-- declare 	@report_type CHAR(1)
	-- declare 	@summary_option CHAR(1)
	-- declare 	@CONVERT_unit_id INT
	-- declare 	@exception_flag CHAR(1)
	-- declare 	@asset_type_id INT
	-- declare 	@settlement_option CHAR(1)
	-- declare 	@include_gen_tranactions CHAR(1)
	-- set @as_of_date = '2004-04-1'
	-- set @subsidiary_id = '30'
	-- set @strategy_id = null
	-- set @book_id = null
	-- set @report_type = 'c'
	-- set @summary_option = 'q'
	-- set @CONVERT_unit_id = 14
	-- set @exception_flag = 'a'
	-- set @asset_type_id = 402
	-- SET @settlement_option = 'f'
	-- --n means dont include, a means approved only, u means unapproved, b means both
	-- SET @include_gen_tranactions = 'b'
	-- -- -- 
	-- drop table #tempItems
	-- drop table #tempAsset

	-- -- select dbo.FNAGetContractMonth(contract_expiration_date), sum(NetItemVol) from #tempItems where IndexName = 'CNG' group by contract_expiration_date order by contract_expiration_date
	-- -- select dbo.FNAGetContractMonth(contract_expiration_date), sum(NetAssetVol) from #tempAsset where IndexName = 'CNG' group by contract_expiration_date order by contract_expiration_date
	-- -- select * from #tempAsset

--##############################################


--*******************************************************
-- this report works only for Summary Level Data
--******************************************************
---###########Declare Variables

/*******************************************1st Paging Batch START**********************************************/
 
DECLARE @str_batch_table VARCHAR(8000)
DECLARE @user_login_id VARCHAR(50)
DECLARE @sql_paging VARCHAR(8000)
DECLARE @is_batch BIT
 
SET @str_batch_table = ''
SET @user_login_id = dbo.FNADBUser() 
SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END 
 
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
 
/*******************************************1st Paging Batch END**********************************************/

	DECLARE @Sql_Select VARCHAR(MAX)
	DECLARE @term_where_clause VARCHAR(1000)
	DECLARE @Sql_Where VARCHAR(8000)
	DECLARE @report_identifier INT
	DECLARE @granularity_type VARCHAR(1)
	DECLARE @process_id VARCHAR(50)
	
	DECLARE @tempTable VARCHAR(100)
	DECLARE @deal_volume_str VARCHAR(200)
	DECLARE @storage_inventory_sub_type_id INT
	DECLARE @drill_contract_month_clause	VARCHAR(100)
	DECLARE @year VARCHAR(4),@start_month VARCHAR(4),@end_month VARCHAR(4)
	DECLARE @listCol VARCHAR(5000)
	DECLARE @tbl_name_header VARCHAR(150)
	DECLARE @tbl_name_detail VARCHAR(150)

	SET @storage_inventory_sub_type_id=17
	SET @sql_Where = ''
	SET @tbl_name_header='source_deal_header'
	SET @tbl_name_detail ='source_deal_detail'
	
	IF @deal_process_id IS NOT NULL  --when call from Check Position in deal insert
	BEGIN
		SET @tbl_name_header=dbo.FNAProcessTableName('deal_header', @user_login_id,@deal_process_id)
		SET @tbl_name_detail =dbo.FNAProcessTableName('deal_detail', @user_login_id,@deal_process_id)

		SET @Sql_Select='IF COL_LENGTH('''+@tbl_name_header+''', ''fas_deal_type_value_id'') IS NULL
			BEGIN
				ALTER TABLE '+@tbl_name_header+' ADD fas_deal_type_value_id INT
			END'
		EXEC(@Sql_Select)			

	END
	
	IF @location_id  = 'null'  --when call from Check Position in deal insert
	BEGIN
		SET @location_id = NULL
	END


	IF @as_of_date_from IS NULL
		SET @as_of_date_from='1900-01-01'

	SET @granularity_type=@summary_option

	SET @drill_contract_month_clause=''
	IF @settlement_option = 'f'
		SET @term_where_clause = ' AND ((sdd.term_start >  CONVERT(DATETIME, ''' + @as_of_date + ''' , 102) AND sdd.deal_volume_frequency in(''d'',''h'')) OR (sdd.term_start >  CONVERT(DATETIME, DBO.FNAGETCONTRACTMONTH(''' + @as_of_date + ''') , 102) AND sdd.deal_volume_frequency not in(''d'',''h'')))'
	ELSE IF @settlement_option = 'c'
		SET @term_where_clause = ' AND sdd.term_start >=  CONVERT(DATETIME, ''' + CAST(MONTH(@as_of_date) AS VARCHAR) + '/1/' + CAST(YEAR(@as_of_date) AS VARCHAR) + ''' , 102)'
	ELSE IF @settlement_option = 's'
		SET @term_where_clause = ' AND ((sdd.term_start <=  CONVERT(DATETIME, ''' + CAST(MONTH(@as_of_date) AS VARCHAR) + '/1/' + CAST(YEAR(@as_of_date) AS VARCHAR) + ''' , 102) AND COALESCE(spcd1.block_define_id,sdh.block_define_id) IS NULL) OR (sdd.term_start <=CONVERT(DATETIME, ''' + @as_of_date + ''' , 102) AND COALESCE(spcd1.block_define_id,sdh.block_define_id) IS NOT NULL))'
	ELSE
		SET @term_where_clause = ''


	IF @drill_index IS NOT NULL
		SET @granularity_type='d'

	IF @summary_option IN('t')
		SELECT @drill_contract_month_clause=CASE WHEN @drill_contractmonth IS NOT NULL THEN  ' AND dbo.fnadateformat(sdd.term_start)='''+@drill_contractmonth+'''' ELSE '' END
	ELSE IF @summary_option IN('m')
		SELECT @drill_contract_month_clause=CASE WHEN @drill_contractmonth IS NOT NULL THEN ' AND dbo.fnadateformat(cast(dbo.fnagetcontractmonth(sdd.term_start) as datetime))='''+@drill_contractmonth+'''' ELSE '' END
	ELSE IF @summary_option IN('q')
		BEGIN

			SELECT @start_month=CASE  WHEN  @drill_contractmonth LIKE '%1st%' THEN '-01' WHEN  @drill_contractmonth LIKE '%2nd%' THEN '-04' WHEN  @drill_contractmonth LIKE '%3rd%' THEN '-07'  WHEN  @drill_contractmonth LIKE '%4th%' THEN '-10' END
			SELECT @end_month=CASE  WHEN  @drill_contractmonth LIKE '%1st%' THEN '-03' WHEN  @drill_contractmonth LIKE '%2nd%' THEN '-06' WHEN  @drill_contractmonth LIKE '%3rd%' THEN '-09'  WHEN  @drill_contractmonth LIKE '%4th%' THEN '-12' END
			SELECT @year=SUBSTRING(@drill_contractmonth,CHARINDEX('-',@drill_contractmonth,0)+1,4)
			SELECT @drill_contract_month_clause=CASE WHEN @drill_contractmonth IS NOT NULL THEN 
				' AND cast((sdd.term_start) as datetime) BETWEEN '''+(@year+@start_month+'-01')+''' AND '''+(@year+@end_month+'-01')+'''' ELSE '' END
		END
	ELSE IF @summary_option IN('s')
		BEGIN

			SELECT @start_month=CASE  WHEN  @drill_contractmonth LIKE '%1st%' THEN '-01' WHEN  @drill_contractmonth LIKE '%2nd%' THEN '-07' END
			SELECT @end_month=CASE  WHEN  @drill_contractmonth LIKE '%1st%' THEN '-06' WHEN  @drill_contractmonth LIKE '%2nd%' THEN '-12' END
			SELECT @year=SUBSTRING(@drill_contractmonth,CHARINDEX('-',@drill_contractmonth,0)+1,4)
			SELECT @drill_contract_month_clause=CASE WHEN @drill_contractmonth IS NOT NULL THEN 
				' AND cast((sdd.term_start) as datetime) BETWEEN '''+(@year+@start_month+'-01')+''' AND '''+(@year+@end_month+'-01')+'''' ELSE '' END
		END
	ELSE IF @summary_option IN('a')
		SELECT @drill_contract_month_clause=CASE WHEN @drill_contractmonth IS NOT NULL THEN ' AND YEAR(sdd.term_start)='''+@drill_contractmonth+'''' ELSE '' END



---###### For the Deal sub type filter


--	IF @deal_sub_type='t'
--		SET @deal_sub_type=4
--	ELSE IF @deal_sub_type='s'
--		SET @deal_sub_type=1

---######
------####### Create Temporary Tables

	CREATE TABLE [dbo].[#tempItems] (
		[source_deal_header_id] INT,
		[fas_book_id] [INT] NOT NULL ,
		[deal_id] [VARCHAR] (1000)  NOT NULL ,
		[ref_id] [VARCHAR] (200)  NOT NULL ,
		[contract_expiration_date] DATETIME,
--		[NetItemVol] [float] NULL ,
		[NetItemVol] NUMERIC(38,20) NULL ,
		[deal_volume_frequency] [CHAR] (20)  NOT NULL ,
		[IndexName] [VARCHAR] (100)   ,
		[sui] [INT]  NOT NULL,  --[sui] [int] NOT NULL, (chande
		deal_date DATETIME,
		term_start DATETIME,
		term_end DATETIME,
		price FLOAT,
		block_type INT,
		block_definition_id INT,
		volume_frequency CHAR(1) ,
		Location VARCHAR(100) ,
		physical_financial_flag CHAR(1) 
	) ON [PRIMARY]

	CREATE TABLE #unit_conversion(  
		 convert_from_uom_id INT,  
		 convert_to_uom_id INT,  
		 conversion_factor NUMERIC(38,20)  
	)  

	INSERT INTO #unit_conversion(convert_from_uom_id,convert_to_uom_id,conversion_factor)    
	 SELECT   
		  from_source_uom_id,  
		  to_source_uom_id,  
		  conversion_factor  
	 FROM  
		 rec_volume_unit_conversion  
	 WHERE  1=1 
--		  AND to_source_uom_id=@CONVERT_unit_id  
		  AND state_value_id IS NULL  
		  AND curve_id IS NULL  
		  AND assignment_type_value_id IS NULL  
		  AND to_curve_id IS NULL  
		  

	

-----------########################### Find out the reference Curve
	SET @user_login_id=dbo.FNADBUser()
	
	SET @process_id=REPLACE(NEWID(),'-','_')	
	SET @tempTable=dbo.FNAProcessTableName('pricecurve_reference', @user_login_id,@process_id)

	
	EXEC spa_get_price_curve_reference @tempTable

-----############# Reference Curve fetch completed

-----------#############################Get all the Items first
	SELECT @deal_volume_str=CASE WHEN @options='d' THEN 'CASE WHEN (sdh.option_flag = ''y'') THEN CASE WHEN ISNULL(sdd.leg,-1)=1 THEN sdpdo.deal_volume* DELTA WHEN  ISNULL(sdd.leg,-1)=2 THEN sdpdo.deal_volume2*DELTA2 ELSE 0 END ELSE  sdd.deal_volume END ' ELSE ' sdd.deal_volume' END


	SET @sql_Select = 'INSERT INTO #tempItems
	
		SELECT  
				sdh.source_deal_header_id, ssbm.fas_book_id, '+
				CASE WHEN @deal_process_id IS NOT NULL THEN '''''' ELSE 
				--'dbo.FNAHyperLinkText2(10131010, (cast(sdh.source_deal_header_id as VARCHAR)),sdh.source_deal_header_id,'+@round_value+')' 
				'dbo.FNATRMWinHyperlink(''a'', 10131010, sdh.source_deal_header_id, ABS(sdh.source_deal_header_id), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0) '
				END +', 
				 sdh.deal_id,
				(sdd.term_start) AS contract_expiration_date,
				CASE WHEN(sdd.deal_volume_frequency = ''d'') THEN 
						'+CASE WHEN @summary_Option = 'r' THEN ' (case when sdd.curve_id is not null then (CASE WHEN (sdd.buy_sell_flag = ''s'') THEN -1 *'+ @deal_volume_str + ' ELSE '+ @deal_volume_str+ ' END) else 0 end )' 
						       ELSE '(CASE WHEN (sdd.buy_sell_flag = ''s'') THEN -1 * '+ @deal_volume_str+ ' 
									   ELSE '+ @deal_volume_str+ ' END)  '
						   END+  ' '+
					'ELSE
						'+CASE WHEN @summary_Option = 'r' THEN ' (case when sdd.curve_id is not null then (CASE WHEN (sdd.buy_sell_flag = ''s'') THEN -1 *'+ @deal_volume_str+' ELSE '+ @deal_volume_str+ ' END) else 0 end ) ' 
							   ELSE '(CASE WHEN (sdd.buy_sell_flag = ''s'') THEN -1 * '+ @deal_volume_str + ' 
								ELSE '+ @deal_volume_str + '  END) '
						  END+ 
				 'END 	' + (CASE WHEN @CONVERT_unit_id IS NOT NULL THEN ' *  ISNULL(CAST(uc.conversion_factor AS NUMERIC(21,16)), 1)' ELSE '' END) + '*ISNULL(cr.factor,1)*ISNULL(NULLIF(sdd.price_multiplier,0),1) AS NetItemVol, '
				 
	
	
	
	
				 
	IF @book_transfer <> 'y'		 
		SET @sql_Select = @sql_Select + '
				
				CASE WHEN sdd.deal_volume_frequency=''m'' THEN ''Monthly'' 
					  WHEN sdd.deal_volume_frequency=''a'' THEN ''Annually'' 
					  WHEN sdd.deal_volume_frequency=''d'' THEN ''Daily'' 
					  WHEN sdd.deal_volume_frequency=''w'' THEN ''Weekly''
					  WHEN sdd.deal_volume_frequency=''s'' THEN ''Semi-Annually'' 
					  WHEN sdd.deal_volume_frequency=''q'' THEN ''Quarterly'' 
					  WHEN sdd.deal_volume_frequency=''h'' AND '''+@granularity_type+'''=''t'' THEN ''Hourly''
					  WHEN sdd.deal_volume_frequency=''h'' AND DATEDIFF(day,sdd.term_start,sdd.term_end)<=0  AND '''+@summary_option+''' NOT IN (''t'',''d'',''r'') THEN ''Daily''
					  WHEN sdd.deal_volume_frequency=''h'' AND DATEDIFF(day,sdd.term_start,sdd.term_end)>1  AND '''+@summary_option+''' NOT IN(''t'',''d'',''r'') THEN ''Monthly''
					  WHEN sdd.deal_volume_frequency=''h'' AND (('''+@granularity_type+'''=''d'' AND '''+@summary_option+''' IN(''t'',''d'')) OR '''+@summary_option+''' IN (''r'')) THEN ''Hourly''
					  WHEN sdd.deal_volume_frequency = ''t'' then ''Daily''
					  WHEN sdd.deal_volume_frequency = ''x'' then ''Term''
					  WHEN sdd.deal_volume_frequency = ''y'' then ''30 Minutes''
					END AS deal_volume_frequency, 
					CASE WHEN(sdd.fixed_float_leg = ''f'') THEN ''Fixed'' ELSE COALESCE (pspcd.curve_name, spcd.curve_name) END AS IndexName, 
					'
	ELSE
		SET @sql_Select = @sql_Select + ' --sdd.deal_volume_frequency deal_volume_frequency, 
		
		CASE WHEN sdd.deal_volume_frequency=''m'' THEN ''m'' 
					  WHEN sdd.deal_volume_frequency=''a'' THEN ''a'' 
					  WHEN sdd.deal_volume_frequency=''d'' THEN ''d'' 
					  WHEN sdd.deal_volume_frequency=''w'' THEN ''w''
					  WHEN sdd.deal_volume_frequency=''s'' THEN ''s'' 
					  WHEN sdd.deal_volume_frequency=''q'' THEN ''q'' 
					  WHEN sdd.deal_volume_frequency = ''t'' then ''Daily''
					  WHEN sdd.deal_volume_frequency = ''x'' then ''Term''
					  WHEN sdd.deal_volume_frequency=''h'' AND '''+@granularity_type+'''=''t'' THEN ''h''
					  WHEN sdd.deal_volume_frequency=''h'' AND DATEDIFF(day,sdd.term_start,sdd.term_end)<=0  AND '''+@summary_option+''' NOT IN (''t'',''d'',''r'') THEN ''d''
					  WHEN sdd.deal_volume_frequency=''h'' AND DATEDIFF(day,sdd.term_start,sdd.term_end)>1  AND '''+@summary_option+''' NOT IN(''t'',''d'',''r'') THEN ''m''
					  WHEN sdd.deal_volume_frequency=''h'' AND (('''+@granularity_type+'''=''d'' AND '''+@summary_option+''' IN(''t'',''d'')) OR '''+@summary_option+''' IN (''r'')) THEN ''h''

					END AS deal_volume_frequency, 
					
					COALESCE (pspcd.source_curve_def_id, spcd.source_curve_def_id)  AS IndexName, '
	
				 
	SET @sql_Select = @sql_Select + 
				 --case when (isnull(sdd.price_multiplier, 0) = 0) or sdd.price_multiplier=1 then sdd.deal_volume_uom_id else COALESCE (pspcd.uom_id, spcd.uom_id) end  deal_volume_uom_id,
				 ' sdd.deal_volume_uom_id, ' --FASTracker does not use curve''s UOM id, use that of deal
				 + 'sdh.deal_date,
				 sdd.term_start, 
				 sdd.term_end, 
				'+CASE WHEN @summary_Option = 'r' THEN ' (case when sdd.fixed_price is not null and sdd.fixed_price>0 then sdd.fixed_price else NULL end )' ELSE '0' END+',
				COALESCE(spcd1.block_type,sdh.block_type) block_type,
				COALESCE(spcd1.block_define_id,sdh.block_define_id) block_define_id,
				sdd.deal_volume_frequency,'
	
	IF @book_transfer <> 'y'
		SET @sql_Select = @sql_Select +	'mi.location_name,'
	ELSE 
		SET @sql_Select = @sql_Select +	'mi.source_minor_location_id,'
	
	SET @sql_Select = @sql_Select + '
				sdh.physical_financial_flag
		 FROM         
				'+ @tbl_name_header +' sdh 
				INNER JOIN ' +@tbl_name_detail +' sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
				LEFT JOIN '+@tempTable+' cr ON ISNULL(cr.curve_id,-1)=sdd.curve_id
				LEFT OUTER JOIN source_price_curve_def spcd ON ISNULL(cr.Curve_ref_id,sdd.curve_id) = spcd.source_curve_def_id
				LEFT OUTER JOIN source_price_curve_def pspcd ON spcd.proxy_source_curve_def_id = pspcd.source_curve_def_id
				 '+CASE WHEN @CONVERT_unit_id IS NOT NULL THEN 
				 	' LEFT JOIN #unit_conversion uc ON uc.convert_from_uom_id=sdd.deal_volume_uom_id AND uc.convert_to_uom_id='+CAST(@CONVERT_unit_id AS VARCHAR) 
					ELSE  '' END + '
				INNER JOIN source_system_book_map ssbm ON sdh.source_system_book_id1 = ssbm.source_system_book_id1 AND 
						   sdh.source_system_book_id2 = ssbm.source_system_book_id2  
						   AND sdh.source_system_book_id3 = ssbm.source_system_book_id3  
						   AND sdh.source_system_book_id4 = ssbm.source_system_book_id4	
				INNER JOIN portfolio_hierarchy book ON ssbm.fas_book_id = book.entity_id 
				INNER JOIN portfolio_hierarchy stra ON book.parent_entity_id = stra.entity_id 
				INNER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id
				INNER JOIN fas_strategy fs ON stra.entity_id = fs.fas_strategy_id
				LEFT JOIN source_minor_location mi on sdd.location_id=mi.source_minor_location_id 
				LEFT JOIN source_major_location ma  on ma.source_major_location_id=mi.source_major_location_id
				LEFT JOIN source_deal_detail sdd1 on sdh.source_deal_header_id=sdd1.source_deal_header_id
						  AND sdd.term_start=sdd1.term_start and sdd1.leg=1
				LEFT JOIN source_price_curve_def spcd1 ON ISNULL(cr.Curve_ref_id,sdd1.curve_id) = spcd1.source_curve_def_id
				INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id'

		+CASE WHEN @options='d' THEN 
				' LEFT JOIN source_deal_pnl_detail_options sdpdo ON
							sdpdo.as_of_date=CONVERT(DATETIME, ''' + @as_of_date + ''' , 102) 
							AND sdpdo.source_deal_header_id=sdh.source_deal_header_id
							AND sdpdo.term_start=sdd.term_start
							--AND sdpdo.curve_1=sdd.curve_id
					'
			  ELSE '' END
		+' WHERE 1=1 '
		+ CASE WHEN @transaction_type IS NOT NULL THEN ' 
			AND (isnull(sdh.fas_deal_type_value_id,ssbm.fas_deal_type_value_id) in ( ' + @transaction_type  + '))' ELSE '' END
		+ ' AND ISNULL(sdh.internal_deal_subtype_value_id,-1)<>'+CAST(@storage_inventory_sub_type_id AS VARCHAR)
		+ CASE WHEN @options='n' THEN ' AND ISNULL(sdh.option_flag,''n'')<>''y''' ELSE '' END
		+ CASE WHEN @drill_index IS NOT NULL AND @group_by='i' AND @drill_index<>'Fixed' THEN ' AND spcd.curve_name='''+@drill_index+'''' ELSE '' END
		+ CASE WHEN @drill_index IS NOT NULL AND @group_by='i' AND  @drill_index='Fixed' THEN ' AND sdd.fixed_float_leg = ''f''' ELSE '' END
		+ CASE WHEN @drill_index IS NOT NULL AND @group_by='l'THEN ' AND ISNULL(mi.location_name,'''') = '''+ISNULL(@drill_index,'')+'''' ELSE '' END
		+ CASE WHEN  @subsidiary_id IS NOT NULL THEN ' AND sub.entity_id IN  (' + @subsidiary_id + ') '  ELSE '' END
		+ CASE WHEN  @source_deal_header_id IS NOT NULL THEN ' AND (sdh.source_deal_header_id IN (' + CAST(@source_deal_header_id AS VARCHAR) + ')) '  ELSE '' END
		+ CASE WHEN  @deal_id IS NOT NULL THEN 	' AND sdh.deal_id = ''' + CAST(@deal_id AS VARCHAR) + ''''  ELSE '' END
		+ CASE WHEN  @commodity_id IS NOT NULL THEN ' AND spcd.commodity_id = ''' + CAST(@commodity_id AS VARCHAR) + ''''  ELSE '' END
		+ CASE WHEN @source_deal_header_id IS  NULL AND @deal_id IS  NULL THEN 
						' AND (sdh.deal_date <= CONVERT(DATETIME, ''' + @as_of_date + ''' , 102)) '+
							CASE WHEN @as_of_date_from IS NOT NULL THEN '  AND (sdh.deal_date >= CONVERT(DATETIME, ''' + @as_of_date_from + ''' , 102))  ' ELSE '' END + @term_where_clause ELSE '' END
		+ CASE WHEN  @strategy_id IS NOT NULL THEN ' AND (stra.entity_id IN(' + @strategy_id + ' ))'  ELSE '' END

		+ CASE WHEN  @strategy_id IS NOT NULL THEN ' AND (stra.entity_id IN(' + @strategy_id + ' ))'  ELSE '' END
		+ CASE WHEN  @book_id IS NOT NULL THEN ' AND (book.entity_id IN(' + @book_id + ')) ' ELSE '' END
		+ CASE WHEN  @source_system_book_id1 IS NOT NULL THEN ' AND (sdh.source_system_book_id1 IN (' + CAST(@source_system_book_id1 AS VARCHAR)+ ')) ' ELSE '' END
		+ CASE WHEN  @source_system_book_id2 IS NOT NULL THEN ' AND (sdh.source_system_book_id2 IN (' + CAST(@source_system_book_id2 AS VARCHAR)+ ')) ' ELSE '' END
		+ CASE WHEN  @source_system_book_id3 IS NOT NULL THEN ' AND (sdh.source_system_book_id3 IN (' + CAST(@source_system_book_id3 AS VARCHAR)+ ')) ' ELSE '' END
		+ CASE WHEN  @source_system_book_id4 IS NOT NULL THEN ' AND (sdh.source_system_book_id4 IN (' + CAST(@source_system_book_id4 AS VARCHAR)+ ')) ' ELSE '' END
		+ CASE WHEN  @major_location IS NOT NULL THEN ' AND ma.source_major_location_id in (' +@major_location + ')'  ELSE '' END
		+ CASE WHEN  @location_id IS NOT NULL THEN ' AND sdd.location_id in (' +@location_id + ')' ELSE '' END
		+ CASE WHEN  @curve_id IS NOT NULL THEN  ' AND sdd.curve_id in (' +@curve_id + ')' ELSE '' END
		+ CASE WHEN @physical_financial_flag<>'b' THEN ' AND sdd.physical_financial_flag='''+@physical_financial_flag+'''' ELSE '' END 
--		+ CASE WHEN @deal_sub_type<>'b' THEN ' AND sdh.deal_sub_type_type_id='+cast(@deal_sub_type as varchar) ELSE '' END 
		+ @drill_contract_month_clause
		+' AND (( sdd.contract_expiration_date>='''+@as_of_date+''' AND sdd.leg<>1) OR sdd.leg=1)'
		+' AND sdd.curve_id IS NOT NULL'
		+ CASE WHEN @deal_type IS NOT NULL THEN ' AND sdh.source_deal_type_id='+CAST(@deal_type AS VARCHAR) ELSE '' END
		
		+ CASE WHEN @trader_id IS NOT NULL THEN ' AND sdh.trader_id='+CAST(@trader_id AS VARCHAR) ELSE '' END
		+ CASE WHEN @counterparty_id IS NOT NULL THEN ' AND sdh.counterparty_id IN ('+CAST(@counterparty_id AS VARCHAR)+ ')' ELSE '' END
		+ CASE WHEN @deal_status IS NOT NULL THEN ' AND sdh.deal_status='+CAST(@deal_status AS VARCHAR) ELSE '' END
		+ CASE WHEN @tenor_from IS NOT NULL AND  @match = 'n' THEN ' AND sdd.term_start>='''+@tenor_from+'''' ELSE '' END
		+ CASE WHEN @tenor_to IS NOT NULL AND  @match = 'n' THEN ' AND sdd.term_start<='''+@tenor_to+'''' ELSE '' END
		+ CASE WHEN @tenor_from IS NOT NULL AND  @match = 'y' THEN ' AND sdh.entire_term_start='''+@tenor_from+'''' ELSE '' END
		+ CASE WHEN @tenor_to IS NOT NULL AND  @match = 'y' THEN ' AND sdh.entire_term_end='''+@tenor_to+'''' ELSE '' END
		+ CASE WHEN @buySell_flag IS NOT NULL THEN ' AND sdd.buy_sell_flag= '''+@buySell_flag+'''' ELSE '' END
		+ CASE WHEN ISNULL(@counterparty_option, 'a') <> 'a' THEN '  AND sc.int_ext_flag = ''' + @counterparty_option + '''' ELSE '' END

		 IF @deal_sub_type IS NOT NULL 
		 SET @sql_Select = @sql_Select + ' AND sdh.deal_sub_type_type_id='+CAST(@deal_sub_type AS VARCHAR)
	
	
	EXEC spa_print 'Print:', @sql_Select, @sql_Where
	--select @sql_Select  + @sql_Where
	
	EXEC (@sql_Select + @sql_Where)

--
--select * from #tempItems --where source_deal_header_id=3121 order by indexname,term_start
--return
--##########################################################################################
--Create a temporary table to SP "spa_get_dealvolume_mult_byfrequency". This SP will return volume multiplier based on frequency
DECLARE @vol_frequency_table VARCHAR(100)
DECLARE @vol_frequency_table_all VARCHAR(100)

SET @vol_frequency_table=dbo.FNAProcessTableName('deal_volume_frequency_mult', @user_login_id, @process_id)
SET @vol_frequency_table_all=dbo.FNAProcessTableName('deal_volume_frequency_mult_all', @user_login_id, @process_id)

	SET @sql_Select='SELECT DISTINCT 
						term_start, 
						term_end,
						volume_frequency AS deal_volume_frequency,
						block_type,
						block_definition_id
				INTO '+@vol_frequency_table+'
				FROM
					#tempItems	
				WHERE 
					volume_frequency IN(''d'',''h'')'
	EXEC(@sql_Select)

	EXEC('select * into '+@vol_frequency_table_all+' FROM '+@vol_frequency_table)

	DECLARE @as_of_date_mult DATETIME
	DECLARE @as_of_date_mult_to DATETIME

	SET @as_of_date_mult=@as_of_date
	SET @as_of_date_mult_to=@as_of_date
	--IF @source_deal_header_id IS NOT NULL OR @deal_id IS NOT NULL 
	--	SET @as_of_date_mult='1900-01-01'
	IF  @settlement_option NOT IN('f','s','c') OR  (@source_deal_header_id IS  NOT NULL OR @deal_id IS  NOT NULL)
		SET @as_of_date_mult='1900-01-01'
	IF @settlement_option<>'s'
		SET @as_of_date_mult_to='9999-01-01'

	EXEC spa_get_dealvolume_mult_byfrequency @vol_frequency_table,@as_of_date_mult,@as_of_date_mult_to,'y',@settlement_option

	-----###############

	EXEC spa_get_dealvolume_mult_byfrequency @vol_frequency_table_all,NULL,NULL,'y',@settlement_option
	

--################ Find out Percentage available
	CREATE TABLE #tmp_per(source_deal_header_id INT,percentage_rem FLOAT,term_start DATETIME)
	
	
	DECLARE @link_deal_term_used_per VARCHAR(200)


	SET @link_deal_term_used_per = dbo.FNAProcessTableName('link_deal_term_used_per', @user_login_id, @process_id)

	SET @link_deal_term_used_per = dbo.FNAProcessTableName('link_deal_term_used_per', @user_login_id, @process_id)
	
	IF OBJECT_ID(@link_deal_term_used_per) IS NOT NULL
			EXEC('drop table '+@link_deal_term_used_per)
			
	EXEC dbo.spa_get_link_deal_term_used_per @as_of_date =@as_of_date,@link_ids=NULL,@header_deal_id =@source_deal_header_id,@term_start=NULL
			,@no_include_link_id =NULL,@output_type =1	,@include_gen_tranactions  = 'b',@process_table=@link_deal_term_used_per

	SET @Sql_Select = 'INSERT INTO #tmp_per (source_deal_header_id  ,percentage_rem ,term_start)	
			SELECT source_deal_header_id, 1-sum(isnull(percentage_used,0)) percentage_used,	term_start 
			from ' +@link_deal_term_used_per + ' GROUP BY source_deal_header_id,term_start	'
			
	EXEC(@Sql_Select)			
			 
--supporting granularity type 's' means monthly, 'q' quarter, 's' semi-annual, 'a' anual
	
	DECLARE @group_by_sql VARCHAR(200)	
	SET @group_by_sql=CASE WHEN @group_by='i' THEN ' IndexName, ' ELSE ' Location, ' END 

	IF @granularity_type <> 'd' AND @summary_option <> 'r' 
		SET @summary_option = 's'

--SELECT percentage_rem FROM #tmp_per

	SET @Sql_Select = '
	SELECT ' +  
			CASE
				WHEN @group_by = 'i' THEN  'IndexName AS [Index Name], '  
				ELSE 'Location, '  
			END +
			CASE WHEN (@granularity_type IN ('t')) THEN  ' dbo.FNADateformat(A.ContractMonth) AS Term, ' 
			WHEN (@granularity_type IN ('m')) THEN  ' dbo.FNADateformat(dbo.FNAGetContractMonth(A.ContractMonth)) AS Term, ' 			
			ELSE ' dbo.FNAGetTermGrouping(A.ContractMonth , ''' + @granularity_type + ''') AS Term, ' END + 				
--			' round(SUM(ISNULL(A.[NetItemVol],0)),2) AS [Volume],
--			' CAST(SUM(ISNULL(A.[NetItemVol],0)) AS NUMERIC(30,' +@round_value + ')) AS [Volume],
			
			' CAST(CAST(SUM(ISNULL(A.[NetItemVol],0)) AS NUMERIC(38,' + @round_value + ')) AS VARCHAR(50)) AS [Volume], '
			

	IF @book_transfer <> 'y'		
		SET @Sql_Select = @Sql_Select + CASE WHEN @granularity_type='m' THEN '''Monthly'''
				   WHEN @granularity_type='q' THEN '''Quarterly'''
				   WHEN @granularity_type='s' THEN '''Semi-Annually'''
				   WHEN @granularity_type='a' THEN '''Annually'''
					WHEN @granularity_type='w' THEN '''Weekly'''
				   ELSE ' MAX(A.VolumeFrequency) ' END +' AS [Volume Frequency], '
	ELSE 
		SET @Sql_Select = @Sql_Select + CASE WHEN @granularity_type='m' THEN '''m'''
				   WHEN @granularity_type='q' THEN '''q'''
				   WHEN @granularity_type='s' THEN '''s'''
				   WHEN @granularity_type='a' THEN '''a'''
					WHEN @granularity_type='w' THEN '''w'''
				   ELSE ' MAX(A.VolumeFrequency) ' END +' AS [Volume Frequency], '
--		SET @Sql_Select = @Sql_Select + ' MAX(A.VolumeFrequency) AS [Volume Frequency], '
		
				   
	SET @Sql_Select = @Sql_Select + '			   
			A.VolumeUOM AS [Volume UOM]'+CASE WHEN @show_cross_tabformat='y' THEN ',MAX(A.ContractMonth) AS [actualTerm]' ELSE '' END
			+  @str_batch_table +	'				  			     
	FROM         
			portfolio_hierarchy sub INNER JOIN
			portfolio_hierarchy stra INNER JOIN
			(SELECT  it.fas_book_id AS fas_book_id, 
					 '+@group_by_sql+' 
					it.ced AS ContractMonth,  
					it.dvf AS VolumeFrequency,'
	
	DECLARE @check INT 
	SELECT @check = 1 FROM #unit_conversion WHERE convert_to_uom_id = @CONVERT_unit_id
		
	IF @book_transfer <> 'y'
	BEGIN                  
		SET @Sql_Select = @Sql_Select + (CASE WHEN @check = 1  THEN ' (CASE WHEN UOM.source_uom_id IS NOT NULL THEN UOM.uom_name ELSE IUOM.uom_name END)' ELSE ' IUOM.uom_name' END) + '  AS VolumeUOM, '
	END		
	ELSE
	BEGIN
		SET @Sql_Select = @Sql_Select + (CASE WHEN @check = 1 THEN '(CASE WHEN UOM.source_uom_id IS NOT NULL THEN UOM.source_uom_id ELSE IUOM.source_uom_id END)' ELSE 'IUOM.source_uom_id' END) + '  AS VolumeUOM, '		
	END 
				
	SET @Sql_Select = @Sql_Select + ' 
					it.NetItemVol AS NetItemVol
			  FROM 
					(SELECT fas_book_id, 
							ti.contract_expiration_date AS ced,
							
							'+CASE WHEN @granularity_type='t' THEN 'SUM((ti.NetItemVol)' ELSE ' SUM((ti.NetItemVol*CASE WHEN ti.physical_financial_flag=''p'' THEN ISNULL(vft.Volume_Mult,1) ELSE ISNULL(vft1.Volume_Mult,1) END ) ' END +'*'+ CASE WHEN @show_hedgeVolume='y' THEN '(ISNULL(tmp.percentage_rem, 1))' ELSE '1' END+') AS NetItemVol, 
							ti.deal_volume_frequency AS dvf, 
							'+@group_by_sql+' 
							ti.sui
					  FROM   #tempItems ti
							LEFT JOIN '+@vol_frequency_table+' vft ON
							vft.term_start=ti.term_start AND
							vft.term_end=ti.term_end AND
							vft.deal_volume_frequency=ti.volume_frequency AND
							ISNULL(vft.block_type,-1)=ISNULL(ti.block_type,-1) AND
							ISNULL(vft.block_definition_id,-1)=ISNULL(ti.block_definition_id,-1)
							
							LEFT JOIN '+@vol_frequency_table_all+' vft1 ON
							vft1.term_start=ti.term_start AND
							vft1.term_end=ti.term_end AND
							vft1.deal_volume_frequency=ti.volume_frequency AND
							ISNULL(vft1.block_type,-1)=ISNULL(ti.block_type,-1) AND
							ISNULL(vft1.block_definition_id,-1)=ISNULL(ti.block_definition_id,-1)
							left join #tmp_per tmp on ti.source_deal_header_id=tmp.source_deal_header_id and ti.term_start=tmp.term_start'
						+CASE WHEN @show_per = 'y' THEN ' WHERE isnull(tmp.percentage_rem,1) > 0 ' ELSE '' END+
						' GROUP BY 
							ti.fas_book_id, ti.contract_expiration_date, ti.deal_volume_frequency, '+@group_by_sql+'  ti.sui
					) it
						' + CASE WHEN @check = 1  THEN    
					' LEFT JOIN #unit_conversion uc ON uc.convert_from_uom_id = it.sui AND uc.convert_to_uom_id = ' + CAST(@CONVERT_unit_id AS VARCHAR) + '
						LEFT JOIN source_uom UOM on UOM.source_uom_id = uc.convert_to_uom_id ' ELSE '' END+ 
						' left JOIN source_uom IUOM on IUOM.source_uom_id=it.sui 
			 ) A 
				INNER JOIN portfolio_hierarchy book ON A.fas_book_id = book.entity_id ON stra.entity_id = book.parent_entity_id 
							ON sub.entity_id = stra.parent_entity_id 
				'

		SET @Sql_Select = @Sql_Select +' GROUP BY 
				 '+@group_by_sql+
				 CASE WHEN (@granularity_type IN ( 't')) THEN  ' A.ContractMonth,' 
				WHEN (@granularity_type IN ('m')) THEN  ' dbo.FNAGetContractMonth(A.ContractMonth),' 
				 ELSE '  
						substring(dbo.FNAGetTermGrouping(A.ContractMonth , ''' + @granularity_type + ''') ,
						len(dbo.FNAGetTermGrouping(A.ContractMonth , ''' + @granularity_type + ''')) -3, 4), 
						dbo.FNAGetTermGrouping(A.ContractMonth , ''' + @granularity_type + '''), ' END +'A.VolumeUOM '


	IF @summary_option = 's' AND @granularity_type<>'d'	
		BEGIN

			SET @Sql_Select = @Sql_Select + 
					' ORDER BY '+@group_by_sql+
					CASE WHEN (@granularity_type IN ( 'd')) THEN  ' A.ContractMonth ' 
					WHEN (@granularity_type IN ('m')) THEN  ' dbo.FNAGetContractMonth(A.ContractMonth) ' 	
					ELSE '  
					substring(dbo.FNAGetTermGrouping(A.ContractMonth , ''' + @granularity_type + ''') , len(dbo.FNAGetTermGrouping(A.ContractMonth , ''' + @granularity_type + ''')) -3, 4), 
					dbo.FNAGetTermGrouping(A.ContractMonth , ''' + @granularity_type + ''') '  
							 --else ', substring(dbo.FNAGetTermGrouping(A.ContractMonth , ''' + @granularity_type + '''), dbo.FNAGetTermGrouping(A.ContractMonth , ''' + @granularity_type + ''') - 5, 4)'
				END
		END
	ELSE
		BEGIN
			
			SET @Sql_Select = '
				SELECT    1 as aa,
				source_deal_header_id, sub.entity_name AS Subsidiary, stra.entity_name AS Strategy, book.entity_name AS Book, A.IndexName,  
				(A.ContractMonth) AS ContractMonth, Type, A.DealID, A.RefId, A.VolumeFrequency, A.VolumeUOM,A.deal_date, 
					round(A.[Vol], '+@round_value+') AS [volume],term_start,term_end,price	,(a.Location) Location	
				FROM         portfolio_hierarchy sub INNER JOIN
				portfolio_hierarchy stra INNER JOIN
				(
				SELECT  ti.source_deal_header_id,
						ti.fas_book_id, 
						ti.IndexName,'+ 
					CASE WHEN (@granularity_type IN ('m', 'd')) THEN  ' (contract_expiration_date) AS ContractMonth, ' ELSE ' dbo.FNAGetTermGrouping(contract_expiration_date , ''' + @granularity_type + ''') AS ContractMonth, ' END +
					'''Items'' Type,
					ti.deal_id DealID, 
					ti.ref_id RefID,
					'+CASE WHEN (@granularity_type='d' AND (@summary_option='t' OR @summary_option='d') OR @summary_option='r') THEN 'ti.deal_volume_frequency' ELSE '''Monthly''' END +' AS VolumeFrequency, 
					'+CASE WHEN @granularity_type='d' AND (@summary_option='t' OR @summary_option='d') THEN 'SUM(ti.NetItemVol)' ELSE ' SUM(ti.NetItemVol*CASE WHEN ti.physical_financial_flag=''p'' THEN ISNULL(vft.Volume_Mult,1) ELSE ISNULL(vft1.Volume_Mult,1) END ) ' END +' AS Vol, 
					'+CASE WHEN @CONVERT_unit_id IS NOT NULL THEN '(CASE WHEN MAX(IUOM.source_uom_id) IS NOT NULL THEN MAX(IUOM.uom_name) ELSE MAX(UOM.uom_name) END)' ELSE 'MAX(UOM.uom_name)' END + '  AS VolumeUOM,
					ti.deal_date,
					(ti.term_start) term_start,
					(ti.term_end) term_end,
					avg(ti.price) price
					,MAX(ti.Location) Location
				FROM 
					#tempItems ti
					LEFT OUTER JOIN source_uom UOM ON sui = UOM.source_uom_id 
					LEFT OUTER JOIN '+@vol_frequency_table+' vft ON
							vft.term_start=ti.term_start AND
							vft.term_end=ti.term_end AND
							vft.deal_volume_frequency=ti.volume_frequency AND
							ISNULL(vft.block_type,-1)=ISNULL(ti.block_type,-1) AND
							ISNULL(vft.block_definition_id,-1)=ISNULL(ti.block_definition_id,-1)
				LEFT JOIN '+@vol_frequency_table_all+' vft1 ON
							vft1.term_start=ti.term_start AND
							vft1.term_end=ti.term_end AND
							vft1.deal_volume_frequency=ti.volume_frequency AND
							ISNULL(vft1.block_type,-1)=ISNULL(ti.block_type,-1) AND
							ISNULL(vft1.block_definition_id,-1)=ISNULL(ti.block_definition_id,-1)
				' + CASE WHEN @CONVERT_unit_id IS NOT NULL  THEN    
					' LEFT JOIN #unit_conversion uc ON uc.convert_from_uom_id = ti.sui AND uc.convert_to_uom_id = ''' + CAST(@CONVERT_unit_id AS VARCHAR(10)) + '''   
					LEFT JOIN source_uom IUOM on IUOM.source_uom_id = uc.convert_to_uom_id ' ELSE '' END+'
				GROUP BY ti.fas_book_id,  ti.IndexName, ti.contract_expiration_date, ti.source_deal_header_id, 
					ti.deal_id, ti.ref_id, ti.deal_volume_frequency, sui,ti.deal_date,ti.term_start,ti.term_end
				) A INNER JOIN portfolio_hierarchy book ON A.fas_book_id = book.entity_id ON stra.entity_id = book.parent_entity_id ON 
				sub.entity_id = stra.parent_entity_id '
						
		
		IF @granularity_type = 'd'
		BEGIN
			SET @Sql_Select = 'SELECT A.Subsidiary, A.Strategy, A.Book,isnull(A.Location+''/'','''')+ A.IndexName [Location/Index],A.DealId [Deal Id], dbo.fnadateformat(A.ContractMonth) [Contract Month], 
--				A.[volume] as Volume, 
				CAST(cast(A.[volume] as numeric(30,' +@round_value + ')) AS VARCHAR(100)) as Volume, 
				--cast(round(ISNULL(tmp.percentage_rem, 1),2) as VARCHAR) [Percentage Available],

				CAST(cast(ISNULL(tmp.percentage_rem, 1) as numeric(30,' +@round_value + ')) AS VARCHAR(100)) [Percentage Available],
--				case when round(ISNULL(tmp.percentage_rem, 1),2)=0 then 0 else A.[volume] * ISNULL(tmp.percentage_rem, 1) end [Volume Available],
				CAST(case when round(ISNULL(tmp.percentage_rem, 1),2)=0 then CAST(0 as numeric(30,' +@round_value + ')) else cast(A.[volume] * ISNULL(tmp.percentage_rem, 1) as numeric(30,' +@round_value + ')) end AS VARCHAR(100)) [Volume Available],
				 A.VolumeFrequency [Volume Frequency], A.VolumeUOM [Volume UOM] ' +  @str_batch_table +
				' FROM (' + @Sql_Select + ') A left join #tmp_per tmp on a.source_deal_header_id=tmp.source_deal_header_id and convert(varchar(7),A.ContractMonth,120)=convert(varchar(7),tmp.term_start,120)  '
			IF @show_per = 'y'
				BEGIN
					SET @Sql_Select = @Sql_Select + ' WHERE isnull(tmp.percentage_rem,1) > 0' + CASE WHEN  @drill_VolumeUOM IS NOT NULL THEN ' AND  A.VolumeUOM='''+ @drill_VolumeUOM +'''' ELSE '' END
				END 
			IF @show_per = 'n'
				BEGIN
					SET @Sql_Select = @Sql_Select + CASE WHEN  @drill_VolumeUOM IS NOT NULL THEN ' WHERE  A.VolumeUOM='''+ @drill_VolumeUOM +'''' ELSE ' ' END
				END 

			SET @Sql_Select = @Sql_Select + ' ORDER BY A.Subsidiary, A.Strategy, A.Book, A.IndexName, CONVERT(datetime, replace(A.ContractMonth, ''-'', ''-1-''), 102), A.Type, A.DealId'
		END
		
		ELSE IF @summary_Option = 'r'
		BEGIN
			
			SET @Sql_Select = 'SELECT A.Subsidiary, A.Strategy, A.Book,isnull(MAX(a.Location)+''/'','''')+max(A.IndexName) [Location/Index],A.DealId [Deal Id], A.RefId [Ref Id], dbo.FNAdateformat(A.deal_date) [Deal Date], dbo.FNAdateformat(min(A.term_start)) +'' - ''+ dbo.FNAdateformat(max(A.term_end)) Term, 
						CAST(cast(sum(A.[volume]) as numeric(30,' +@round_value + ')) AS VARCHAR(100)) as Volume, CAST(cast(max(ISNULL(tmp.percentage_rem, 1)) AS numeric(30,' +@round_value + ')) as VARCHAR(100)) [Percentage Available],CAST(case when round(max(ISNULL(tmp.percentage_rem, 1)),2)=0 then cast(0 AS numeric(30,' +@round_value + ')) else cast(sum(A.[volume])* max(ISNULL(tmp.percentage_rem, 1)) as numeric(30,' +@round_value + '))end AS VARCHAR(100))   [Volume Available], 
--						cast(round(AVG(A.Price),2) as VARCHAR) Price, 
						CAST(cast(AVG(A.Price) as numeric(30,' +@round_value + ')) AS VARCHAR(100)) Price, 
						' +
					'  A.VolumeFrequency [Volume Frequency], A.VolumeUOM [Volume UOM] ' +  @str_batch_table +
					' FROM (' + @Sql_Select + ') A left join #tmp_per tmp on a.source_deal_header_id=tmp.source_deal_header_id and a.term_start=tmp.term_start'
			IF @show_per = 'y'
				BEGIN
					SET @Sql_Select = @Sql_Select + ' WHERE isnull(tmp.percentage_rem,1) > 0 '
				END
			SET @Sql_Select = @Sql_Select + ' group by A.Subsidiary, A.Strategy, A.Book, A.DealId, A.RefId, dbo.FNAdateformat(A.deal_date),A.VolumeFrequency, A.VolumeUOM
					ORDER BY A.Subsidiary, A.Strategy, A.Book,  A.DealId, dbo.FNAdateformat(A.deal_date)'
		END
		EXEC spa_print ' @summary_Option:',@summary_Option
	
	END


	IF @show_cross_tabformat='y' AND @summary_Option NOT IN('d','r') AND @drill_index IS NULL-----show the report in cross tab forMAT
		BEGIN
			
			CREATE TABLE #tempPivot(Item VARCHAR(100) COLLATE DATABASE_DEFAULT  ,[Term] VARCHAR(20) COLLATE DATABASE_DEFAULT  ,Volume FLOAT,VolumeFrequency VARCHAR(20) COLLATE DATABASE_DEFAULT  ,VolumeUOM VARCHAR(20) COLLATE DATABASE_DEFAULT  ,[actualTerm] DATETIME)
			SET @Sql_Select=REPLACE(@Sql_Select,@str_batch_table,'')
			SET @Sql_Select=' INSERT INTO #tempPivot'+@Sql_Select	
		--	exec spa_print @Sql_Select	  	
			EXEC(@Sql_Select)

			
			SELECT DISTINCT YEAR([actualTerm])[actualTerm],[Term] INTO #temp_order FROM #tempPivot ORDER BY YEAR([actualTerm])

			SELECT  @listCol = STUFF(( SELECT  '],[' +[Term]
				 FROM    #temp_order
					    FOR XML PATH('')), 1, 2, '') + ']'

			DECLARE @listCol_SUM VARCHAR(MAX)
			SET @listCol_SUM=''
				SELECT  @listCol_SUM = @listCol_SUM + CASE WHEN @listCol_SUM='' THEN '' ELSE ',' END +'round([' +[Term]+'],'+@round_value+')  as ['+[Term]+']'	 FROM    #temp_order 

			IF @listCol_SUM=''
			BEGIN
				SELECT 'No Data Found...' Status
				RETURN
			END

			IF @listCol IS NULL
				SET @listCol='[0]'
			
			SET @Sql_Select=
				'SELECT [Item] AS '+ CASE WHEN @group_by='i' THEN ' [IndexName]' ELSE '[Location]' END +','+@listCol_SUM+',VolumeUOM ' + @str_batch_table+
				' FROM (
						SELECT [Item],[Term],Volume,VolumeUOM  FROM #tempPivot
					 ) P
				 PIVOT
					(
						SUM(Volume) FOR [Term] IN('+@listCol+')
					) AS PVT	
			
					'
			EXEC(@Sql_Select)
		END
	ELSE
	BEGIN

		EXEC spa_print @Sql_Select
		EXEC(@Sql_Select)
	END
END	

/*******************************************2nd Paging Batch START**********************************************/
 
--update time spent and batch completion message in message board
IF @is_batch = 1
BEGIN
   SELECT @sql_paging = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
   EXEC(@sql_paging)
 
   --TODO: modify sp and report name
   SELECT @sql_paging = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'derivative_position_report', 'Derivative Position Report')
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
