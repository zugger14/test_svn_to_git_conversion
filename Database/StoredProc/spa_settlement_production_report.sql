
/****** Object:  StoredProcedure [dbo].[spa_settlement_production_report]    Script Date: 12/16/2010 08:59:08 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_settlement_production_report]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_settlement_production_report]
/****** Object:  StoredProcedure [dbo].[spa_settlement_production_report]    Script Date: 12/16/2010 08:48:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_settlement_production_report]              
	 @sub_entity_id VARCHAR(100),             		
	 @strategy_entity_id VARCHAR(100) = NULL,             
	 @book_entity_id VARCHAR(100) = NULL,         
	 @generator_id INT = NULL,            
	 @technology INT = NULL,            
	 @counterparty VARCHAR(MAX)= NULL, 
	 @buy_sell_flag VARCHAR(1) = NULL,             
	 @generation_state INT = NULL,
	 @as_of_date DATETIME = NULL,
	 @term_start VARCHAR(10)= NULL,
	 @term_end VARCHAR(10) = NULL,
	 @report_type VARCHAR(1) = NULL, -- 's' select all, 'm' select missing data, 'p' estimated production data,'d' hour drill, 'p' proxy date drill
	 @drill_counterparty VARCHAR(500)= NULL,
	 @drill_technology VARCHAR(100) = NULL,
	 @drill_deal_date VARCHAR(100) = NULL,
	 @drill_buy_sell_flag VARCHAR(100) = NULL,
	 @drill_state VARCHAR(100) = NULL,
	 @drill_recorderid VARCHAR(100) = NULL,
	 @drill_Channel INT = NULL,
	 @drill_generator VARCHAR(500) = NULL,
	 @uom_id INT = NULL	,
	 @module_type CHAR(1) = 'r', -- 'r' rec 's' settlement
	 @granularity INT = NULL,
	 @production_month_format CHAR(1) = 'y',
	 @round_value CHAR(2) = '0',
	 @format_option CHAR(1)='c',
	 @batch_process_id VARCHAR(250) = NULL,
	 @batch_report_param VARCHAR(2500) = NULL, 
	 @enable_paging INT = 0,  --'1' = enable, '0' = disable
	 @page_size INT = NULL,
	 @page_no INT = NULL
 AS        
SET NOCOUNT ON            

DECLARE @Sql_Select VARCHAR(8000)
DECLARE @Sql_Select1 VARCHAR(8000)
DECLARE @Sql_Select2 VARCHAR(8000)
DECLARE @Sql_Select3 VARCHAR(8000)
DECLARE @Sql_WHERE VARCHAR(8000)
DECLARE @default_uom INT

SET @default_uom = 24   



/*******************************************1st Paging Batch START**********************************************/
EXEC spa_print '@batch_process_id:' -- + @batch_process_id
DECLARE @str_batch_table VARCHAR(8000)
DECLARE @user_login_id VARCHAR(50)
DECLARE @sql_paging VARCHAR(8000)
DECLARE @is_batch bit
		 
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

	CREATE TABLE #books ( fas_book_id INT ) 
	CREATE  INDEX [IX_Book] ON [#books]([fas_book_id])                  

    SET @Sql_Select = '
		INSERT INTO  #books
		SELECT distinct book.entity_id fas_book_id FROM portfolio_hierarchy book (nolock) INNER JOIN
				Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id LEFT OUTER JOIN            
				source_system_book_map ssbm ON ssbm.fas_deal_type_value_id = book.entity_id         
		WHERE (fas_deal_type_value_id IS NULL OR fas_deal_type_value_id BETWEEN 400 AND 401) 
		'   
               
    IF @sub_entity_id IS NOT NULL 
        SET @Sql_Select = @Sql_Select + ' AND stra.parent_entity_id IN  ( '
            + @sub_entity_id + ') '         
    IF @strategy_entity_id IS NOT NULL 
        SET @Sql_Select = @Sql_Select + ' AND (stra.entity_id IN('
            + @strategy_entity_id + ' ))'        
    IF @book_entity_id IS NOT NULL 
        SET @Sql_Select = @Sql_Select + ' AND (book.entity_id IN('
            + @book_entity_id + ')) '        
    
    EXEC(@Sql_Select)
            

IF @report_type = 'z'
	BEGIN
		SET @Sql_Select='		
		select  
			counterparty_name Counterparty,' 
			+CASE WHEN @module_type='r' THEN 	
			'max(tech.code) Technology,
			rg.code as Generator,
			max(state.code) as [Gen State],' ELSE '' END+ 
			CASE WHEN @production_month_format='y' THEN ' dbo.FNADateFormat(mv.from_date) ' ELSE 'MIN(dbo.FNADateFormat(mvh.prod_date))+'' - ''+ MAX(dbo.FNADateFormat(mvh.prod_date))' END +' AS [Production Month],                           
			CAST(sum(isnull(hr1,0)+isnull(hr2,0)+isnull(hr3,0)+isnull(hr4,0)+isnull(hr5,0)+isnull(hr6,0)+
			isnull(hr7,0)+isnull(hr8,0)+isnull(hr9,0)+isnull(hr10,0)+isnull(hr11,0)+isnull(hr12,0)+
			isnull(hr13,0)+isnull(hr14,0)+isnull(hr15,0)+isnull(hr16,0)+isnull(hr17,0)+isnull(hr18,0)+
			isnull(hr19,0)+isnull(hr20,0)+isnull(hr21,0)+isnull(hr22,0)+isnull(hr23,0)+isnull(hr24,0)) AS NUMERIC(38, ' + @round_value + ')) as volume,
			max(suom.uom_name) UOM
			' + @str_batch_table + '      
		from  
			mv90_data mv 
			INNER JOIN mv90_data_hour mvh on mv.meter_data_id=mvh.meter_data_id
				AND mv.from_date=dbo.fnagetcontractmonth(mvh.prod_date)  
			LEFT JOIN recorder_generator_map rgm on rgm.meter_id=mv.meter_id
			LEFT JOIN rec_generator rg on rgm.generator_id=rg.generator_id
			INNER JOIN recorder_properties md on mv.meter_id=md.meter_id AND md.channel=mv.channel  
			LEFT OUTER JOIN static_data_value state on state.value_id =rg.gen_state_value_id
			LEFT OUTER JOIN static_data_value tech on tech.value_id = rg.technology  
			LEFT OUTER JOIN source_minor_location_meter smlm ON smlm.meter_id=mv.meter_id
			LEFT OUTER JOIN source_deal_detail sdd ON sdd.location_id=smlm.source_minor_location_id
			LEFT OUTER JOIN source_deal_header sdh ON sdh.source_deal_header_id=sdd.source_deal_header_id
			LEFT JOIN source_system_book_map ssbm ON sdh.source_system_book_id1=ssbm.source_system_book_id1     		                        
				AND sdh.source_system_book_id2=ssbm.source_system_book_id2                             
				AND sdh.source_system_book_id3=ssbm.source_system_book_id3                             
				AND sdh.source_system_book_id4=ssbm.source_system_book_id4   
			INNER JOIN #books b ON  b.fas_book_id=ISNULL(rg.fas_book_id,ssbm.fas_book_id)
			LEFT JOIN source_counterparty sc on sc.source_counterparty_id=ISNULL(rg.ppa_counterparty_id,sdh.counterparty_id)
			LEFT JOIN source_uom suom on suom.source_uom_id =md.uom_id

		WHERE 1=1 
			 '
			+ CASE WHEN @term_start IS NOT NULL THEN ' AND mvh.prod_date >=  ''' + CONVERT(VARCHAR(10), @term_start, 120) + '''' ELSE '' END              
			+ CASE WHEN @term_end IS NOT NULL THEN ' AND mvh.prod_date <=  ''' + CONVERT(VARCHAR(10), @term_end, 120) + ''''  ELSE '' END
			+ CASE WHEN  @generation_state IS NOT NULL THEN ' AND (rg.gen_state_value_id IN(' + CAST(@generation_state AS VARCHAR)+ ')) ' ELSE '' END               
			+ CASE WHEN  @technology IS NOT NULL THEN ' AND (rg.technology=' + CAST(@technology AS VARCHAR)+ ') ' ELSE '' END               
			+ CASE WHEN  @counterparty IS NOT NULL THEN ' AND sc.source_counterparty_id IN ( ' + CAST(@counterparty AS VARCHAR) + ')' ELSE '' END
			+ CASE WHEN  @generator_id IS NOT NULL THEN ' AND rg.generator_id = ' + CAST(@generator_id AS VARCHAR)  ELSE '' END
			+' 
				GROUP BY counterparty_name'
				+CASE WHEN @module_type='r' THEN ',rg.code' ELSE '' END+
				+CASE WHEN @production_month_format='y' THEN ',mv.from_date' ELSE '' END+
				' ORDER BY counterparty_name'+
				+CASE WHEN @production_month_format='y' THEN ',mv.from_date' ELSE '' END

		EXEC(@Sql_Select)
	END
ELSE IF @report_type = 'y' --hourly of z
	BEGIN
	
		SET @Sql_Select=' 
		select DISTINCT mi.recorderid [Record ID],  ' + CASE WHEN @format_option='c' THEN 'dbo.FNADateFormat' ELSE '' END +'(mvh.prod_date) [Prod Date],mv.channel [Channel],
			CAST(isnull(hr1,0) AS NUMERIC(38, ' + @round_value + ')) HR1, CAST(isnull(hr2,0) AS NUMERIC(38, ' + @round_value + ')) HR2,
			CAST(isnull(hr3,0) AS NUMERIC(38, ' + @round_value + ')) HR3, CAST(isnull(hr4,0) AS NUMERIC(38, ' + @round_value + ')) HR4,
			CAST(isnull(hr5,0) AS NUMERIC(38, ' + @round_value + ')) HR5, CAST(isnull(hr6,0) AS NUMERIC(38, ' + @round_value + ')) HR6, 
			CAST(isnull(hr7,0) AS NUMERIC(38, ' + @round_value + ')) HR7, CAST(isnull(hr8,0) AS NUMERIC(38, ' + @round_value + ')) HR8,
			CAST(isnull(hr9,0) AS NUMERIC(38, ' + @round_value + ')) HR9, CAST(isnull(hr10,0) AS NUMERIC(38, ' + @round_value + ')) HR10,
			CAST(isnull(hr11,0) AS NUMERIC(38, ' + @round_value + ')) HR11, CAST(isnull(hr12,0) AS NUMERIC(38, ' + @round_value + ')) HR12,
			CAST(isnull(hr13,0) AS NUMERIC(38, ' + @round_value + ')) HR13, CAST(isnull(hr14,0) AS NUMERIC(38, ' + @round_value + ')) HR14,
			CAST(isnull(hr15,0) AS NUMERIC(38, ' + @round_value + ')) HR15, CAST(isnull(hr16,0) AS NUMERIC(38, ' + @round_value + ')) HR16,
			CAST(isnull(hr17,0) AS NUMERIC(38, ' + @round_value + ')) HR17, CAST(isnull(hr18,0) AS NUMERIC(38, ' + @round_value + ')) HR18,
			CAST(isnull(hr19,0) AS NUMERIC(38, ' + @round_value + ')) HR19, CAST(isnull(hr20,0)  AS NUMERIC(38, ' + @round_value + ')) HR20,
			CAST(isnull(hr21,0) AS NUMERIC(38, ' + @round_value + ')) HR21, CAST(isnull(hr22,0) AS NUMERIC(38, ' + @round_value + ')) HR22,
			CAST(isnull(hr23,0) AS NUMERIC(38, ' + @round_value + ')) HR23, CAST(isnull(hr24,0) AS NUMERIC(38, ' + @round_value + ')) HR24 
		' + CASE WHEN @format_option='c' THEN @str_batch_table ELSE ' ,CAST(isnull(hr25,0) AS NUMERIC(38, ' + @round_value + ')) HR25  INTO #temp_pivot ' END + ' 
		from  
			mv90_data mv 
			INNER JOIN mv90_data_hour mvh on mv.meter_data_id=mvh.meter_data_id
			INNER JOIN meter_id mi ON mi.meter_id=mv.meter_id
			LEFT JOIN recorder_generator_map rgm on rgm.meter_id=mv.meter_id 
			LEFT JOIN rec_generator rg on rgm.generator_id=rg.generator_id
			INNER JOIN recorder_properties md on mv.meter_id=md.meter_id AND md.channel=mv.channel  
			LEFT OUTER JOIN source_minor_location_meter smlm ON smlm.meter_id=mv.meter_id
			LEFT OUTER JOIN source_deal_detail sdd ON sdd.location_id=smlm.source_minor_location_id
			LEFT OUTER JOIN source_deal_header sdh ON sdh.source_deal_header_id=sdd.source_deal_header_id
			LEFT JOIN source_system_book_map ssbm ON sdh.source_system_book_id1=ssbm.source_system_book_id1     		                        
				AND sdh.source_system_book_id2=ssbm.source_system_book_id2                             
				AND sdh.source_system_book_id3=ssbm.source_system_book_id3                             
				AND sdh.source_system_book_id4=ssbm.source_system_book_id4   
			INNER JOIN #books b ON  b.fas_book_id=ISNULL(rg.fas_book_id,ssbm.fas_book_id)
			LEFT JOIN source_uom suom on suom.source_uom_id =md.uom_id
			LEFT JOIN source_counterparty sc on sc.source_counterparty_id=ISNULL(rg.ppa_counterparty_id,sdh.counterparty_id)
			LEFT OUTER JOIN static_data_value state on state.value_id =rg.gen_state_value_id
			LEFT OUTER JOIN static_data_value tech on tech.value_id = rg.technology  
		WHERE 1=1 '
			+ CASE WHEN  @drill_state IS NOT NULL THEN ' AND (rg.gen_state_value_id IN(' + CAST(@generation_state AS VARCHAR)+ ')) ' ELSE '' END               
			+ CASE WHEN  @drill_technology IS NOT NULL THEN ' AND (tech.code=''' + (@drill_technology)+ ''') ' ELSE '' END               
			+ CASE WHEN  @drill_Counterparty IS NOT NULL THEN ' AND sc.counterparty_name = ''' + (@drill_Counterparty )+'''' ELSE '' END
			+ CASE WHEN  @drill_generator IS NOT NULL THEN ' AND rg.code = ''' + (@drill_generator)+''''  ELSE '' END
			+ CASE WHEN @drill_deal_date IS NOT NULL THEN ' AND dbo.fnagetcontractmonth(mv.from_date)  = dbo.fnagetcontractmonth(''' + @drill_deal_date + ''')' ELSE '' END
			+ CASE WHEN @term_start IS NULL THEN '' ELSE ' AND mvh.prod_date>='''+@term_start+'''' END
			+ CASE WHEN @term_end IS NULL THEN '' ELSE ' AND mvh.prod_date<='''+@term_end+''''  END
			+ ' order by mi.recorderid,mv.channel,' + CASE WHEN @format_option='c' THEN 'dbo.FNADateFormat' ELSE '' END +'(mvh.prod_date);'
	
	IF @format_option='r' 
		SET @Sql_Select= @Sql_Select+' 
				 SELECT [Record ID],
						[Channel],						
						dbo.FNADateFormat([Prod Date])[Prod Date],
						CASE WHEN mv.date IS NOT NULL THEN mv.Hour ELSE SUBSTRING(Hours,3,2) END [Hour],
						CASE WHEN CAST(convert(varchar(10),CAST([Prod Date] AS DATETIME),120)+'' ''+RIGHT(''00''+CAST(CASE WHEN mv.date IS NOT NULL THEN mv.Hour ELSE SUBSTRING(Hours,3,2) END -1 AS VARCHAR),2)+'':00:000'' AS DATETIME) BETWEEN CAST(convert(varchar(10),mv2.date,120)+'' ''+CAST(mv2.Hour-1 AS VARCHAR)+'':00:00'' AS DATETIME) 
							AND CAST(convert(varchar(10),mv3.date,120)+'' ''+CAST(mv3.Hour-1 AS VARCHAR)+'':00:00'' AS DATETIME) AND SUBSTRING(Hours,3,2) <>  25  THEN 1 ELSE 0 END AS DST,
						CASE WHEN mv3.[Hour]=SUBSTRING([Hours],3,2) AND mv3.date=[Prod Date] THEN Volume-dst_hr ELSE Volume END [Volume]' 
				+@str_batch_table+
				' FROM		
					(SELECT 
						[Record ID],[Prod Date],[Channel],hr25 as dst_hr,hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25 FROM #temp_pivot)p
					UNPIVOT
					(Volume for Hours IN
						(hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24,hr25)
					) AS unpvt
					LEFT JOIN mv90_DST mv ON ([Prod Date])=(mv.date)
							  AND mv.insert_delete=''i''
							  AND SUBSTRING(Hours,3,2)=25
					LEFT JOIN mv90_DST mv1 ON ([Prod Date])=(mv1.date)
							  AND mv1.insert_delete=''d''
						  AND mv1.Hour=SUBSTRING(Hours,3,2)		
					LEFT JOIN mv90_DST mv2 ON YEAR([Prod Date])=(mv2.YEAR)
							  AND mv2.insert_delete=''d''
					LEFT JOIN mv90_DST mv3 ON YEAR([Prod Date])=(mv3.YEAR)
							  AND mv3.insert_delete=''i''
				WHERE 1=1 AND ((SUBSTRING(Hours,3,2)=25 AND mv.date IS NOT NULL) OR (SUBSTRING(Hours,3,2)<>25)) AND (mv1.date IS NULL)
				ORDER BY [Record ID],[Prod Date],[Channel],[Hour]'
			
	EXEC(@Sql_Select)


	END
ELSE
BEGIN
	--declare @report_identifier int            
	--*****************For batch processing********************************        
	        

	CREATE TABLE #temp_all(
		fas_book_id INT,
		source_deal_header_id INT,
		source_deal_id INT,
		deal_date DATETIME,
		volume FLOAT,
		UOM VARCHAR(100) COLLATE DATABASE_DEFAULT,
		state_id INT,
		STATE VARCHAR(100) COLLATE DATABASE_DEFAULT,
		generator_id INT,
		generator VARCHAR(100) COLLATE DATABASE_DEFAULT,
		technology VARCHAR(100) COLLATE DATABASE_DEFAULT,
		buy_sell_flag CHAR(1) COLLATE DATABASE_DEFAULT,
		counterparty_id INT,
		counterparty_name VARCHAR(100) COLLATE DATABASE_DEFAULT,
		term_start DATETIME,
		term_end DATETIME,
		generator_name VARCHAR(100) COLLATE DATABASE_DEFAULT	
	)

	SET @Sql_Select=
	' 
	insert into #temp_all 
	 SELECT  
		 NULL,        
		 NULL,             
		 NULL,           
		 a.from_date,              
		 sum(a.volume)*ISNULL(max(rg.contract_allocation),1),  
		 max(suom.uom_name) UOM, 
		 NULL,                   
		 max(state.code) State,     
		 rg.generator_id,            	
		 max(rg.code) Generator,            
		 max(tech.code) Technology,            
		 NULL,            
		 max(sc.source_counterparty_id),            
		 max(sc.counterparty_name),            
		 a.from_date,
		 dbo.FNAGetSQLStandardDate(dbo.FNALastDayInDate(a.from_date)),  
		 rg.code generator_name
	FROM            
		(select meter_id as meter_id,sum(volume*conv.conversion_factor) as volume,max(uom_id) as uom_id,sum(volume) as settlement_volume,   
			  max(from_date) from_date from   
			  (select   distinct
					mv.meter_id as meter_id,  
					(mv.volume-(COALESCE(meter.gre_per,meter1.gre_per,0))*mv.volume) * mult_factor as volume,  
					mv.channel,  
					mult_factor,  
					md.uom_id,  
					dbo.FNAGetContractMonth(mv.from_date) from_date       
			 from  
			  mv90_data mv   
			  INNER JOIN recorder_generator_map rgm on rgm.meter_id=mv.meter_id '
			 +CASE WHEN @term_start IS NOT NULL THEN ' AND (mv.from_date between CONVERT(DATETIME, ''' + dbo.FNAGetContractMonth(@term_start) + ''', 102) AND                 
			 CONVERT(DATETIME, ''' + @term_end + ''', 102)) ' ELSE '' END +
			  ' INNER JOIN rec_generator rg on rgm.generator_id=rg.generator_id
			  AND rg.legal_entity_value_id in(' + @sub_entity_id + ')		
			  INNER JOIN recorder_properties md on mv.meter_id=md.meter_id AND md.channel=mv.channel  
			  LEFT JOIN meter_id_allocation meter on meter.meter_id=mv.meter_id  
			   AND meter.production_month=mv.from_date  
			  LEFT JOIN meter_id_allocation meter1 on meter1.meter_id=mv.meter_id 
		  ) a 
		  LEFT JOIN rec_volume_unit_conversion conv on  
		  a.uom_id=conv.from_source_uom_id AND conv.to_source_uom_id='+CAST(ISNULL(@uom_id,@default_uom) AS VARCHAR)+'  
		  AND conv.state_value_id is null AND conv.assignment_type_value_id is null  
		  AND conv.curve_id is null   
		  GROUP BY meter_id,from_date) a   
		  INNER JOIN recorder_generator_map rgm on rgm.meter_id=a.meter_id  
		  INNER JOIN rec_generator rg on rg.generator_id=rgm.generator_id  
			AND rg.legal_entity_value_id in(' + @sub_entity_id + ')		
		  LEFT OUTER JOIN static_data_value state on state.value_id =rg.gen_state_value_id         
		  LEFT OUTER JOIN static_data_value tech on tech.value_id = rg.technology  
		  LEFT JOIN source_counterparty sc on sc.source_counterparty_id=rg.ppa_counterparty_id	
		  LEFT OUTER JOIN source_uom suom on suom.source_uom_id = '+CASE WHEN @uom_id IS NOT NULL THEN CAST(@uom_id AS VARCHAR) ELSE CAST(@default_uom AS VARCHAR) END +'
	WHERE 1=1 '
		+ CASE WHEN  @generation_state IS NOT NULL THEN ' AND (rg.gen_state_value_id IN(' + CAST(@generation_state AS VARCHAR)+ ')) ' ELSE '' END               
		+ CASE WHEN  @technology IS NOT NULL THEN ' AND (rg.technology=' + CAST(@technology AS VARCHAR)+ ') ' ELSE '' END               
		+ CASE WHEN  @counterparty IS NOT NULL THEN ' AND sc.source_counterparty_id IN ( ' + CAST(@counterparty AS VARCHAR) + ')' ELSE '' END
		+ CASE WHEN  @generator_id IS NOT NULL THEN ' AND rg.generator_id = ' + CAST(@generator_id AS VARCHAR)  ELSE '' END
	+' GROUP BY  
		  rg.generator_id,a.from_date,rg.code  
	'
	EXEC spa_print @Sql_Select
	EXEC(@Sql_Select)

	IF @report_type='s' OR @report_type='m'  OR @report_type='d'  OR @report_type='p' OR @report_type='r' OR @report_type='h'  OR @report_type='c'-- show missing data
	BEGIN

	-- first select hourly data into temp table

	SELECT mv.*,mv90.meter_id,mv90.channel,rgm.generator_id INTO 
			#temp_mv90_hour 
	FROM
			 mv90_data_hour mv 
			 INNER JOIN mv90_data mv90 ON mv90.meter_data_id=mv.meter_data_id
			 INNER JOIN recorder_generator_map rgm  ON mv90.meter_id=rgm.meter_id
			 INNER JOIN #temp_all a ON a.generator_id=rgm.generator_id
			 AND a.term_start=dbo.fnagetcontractmonth(mv.prod_date)
	WHERE
			dbo.fnagetcontractmonth(mv.prod_date)=ISNULL(dbo.fnagetcontractmonth(@drill_deal_date),dbo.fnagetcontractmonth(mv.prod_date))
			AND (@term_start IS NOT NULL AND mv.prod_date>=@term_start OR @term_start IS NULL) AND (@term_end IS NOT NULL AND mv.prod_date<=@term_end OR @term_end IS NULL)
	

	---------------------------------------------------------
	-- find all the missing data AND insert into temp table

	CREATE TABLE #temp_recorder(
		generator_id INT,
		meter_id VARCHAR(100) COLLATE DATABASE_DEFAULT,
		channel INT,
		from_date DATETIME,
		to_date DATETIME,
		volume FLOAT,
		uom_id INT
	)

	INSERT INTO 
		#temp_recorder
	SELECT DISTINCT
		a.generator_id,
		rgm.meter_id,
		rp.channel,
		mv90.from_date,
		mv90.to_date,
		mv90.volume*ISNULL(mult_factor,1),
		mv90.uom_id
	FROM
		#temp_all a
		INNER JOIN recorder_generator_map rgm ON a.generator_id=rgm.generator_id
		INNER JOIN mv90_data mv90 ON mv90.meter_id=rgm.meter_id AND mv90.from_date>=a.term_start AND mv90.to_date<=a.term_end
		INNER JOIN recorder_properties rp ON rp.meter_id=mv90.meter_id
		AND mv90.channel=rp.channel


	IF @report_type='s' -- production data
		BEGIN

		SET @Sql_Select=
			' select  
			counterparty_name [Counterparty], '
			+ CASE WHEN @module_type='r' THEN 
			'Technology,             
			generator_name as Generator,       
			State as [Gen State],' ELSE '' END +
			CASE WHEN @production_month_format='y' THEN ' dbo.FNADateFormat(deal_date) ' ELSE 'MIN(dbo.FNADateFormat(mv90.prod_date))+'' - ''+ MAX(dbo.FNADateFormat(mv90.prod_date))' END +' AS [Production Month],                           
			CAST(SUM((mv90.HR1)*ISNULL(rp.mult_factor,1)+
			(mv90.HR2)*ISNULL(rp.mult_factor,1)+
			(mv90.HR3)*ISNULL(rp.mult_factor,1)+
			(mv90.HR4)*ISNULL(rp.mult_factor,1)+
			(mv90.HR5)*ISNULL(rp.mult_factor,1)+
			(mv90.HR6)*ISNULL(rp.mult_factor,1)+
			(mv90.HR7)*ISNULL(rp.mult_factor,1)+
			(mv90.HR8)*ISNULL(rp.mult_factor,1)+
			(mv90.HR9)*ISNULL(rp.mult_factor,1)+
			(mv90.HR10)*ISNULL(rp.mult_factor,1)+
			(mv90.HR11)*ISNULL(rp.mult_factor,1)+
			(mv90.HR12)*ISNULL(rp.mult_factor,1)+
			(mv90.HR13)*ISNULL(rp.mult_factor,1)+
			(mv90.HR14)*ISNULL(rp.mult_factor,1)+
			(mv90.HR15)*ISNULL(rp.mult_factor,1)+
			(mv90.HR16)*ISNULL(rp.mult_factor,1)+
			(mv90.HR17)*ISNULL(rp.mult_factor,1)+
			(mv90.HR18)*ISNULL(rp.mult_factor,1)+
			(mv90.HR19)*ISNULL(rp.mult_factor,1)+
			(mv90.HR20)*ISNULL(rp.mult_factor,1)+
			(mv90.HR21)*ISNULL(rp.mult_factor,1)+
			(mv90.HR22)*ISNULL(rp.mult_factor,1)+
			(mv90.HR23)*ISNULL(rp.mult_factor,1)+
			(mv90.HR24)*ISNULL(rp.mult_factor,1)) AS NUMERIC(38, ' + @round_value + ')) [Volume],           
			isnull(UOM,'''') UOM
		' + @str_batch_table + ' 
		from
			#temp_all a 
			INNER JOIN recorder_generator_map rgm on a.generator_id=rgm.generator_id
			INNER JOIN #temp_mv90_hour mv90 on mv90.meter_id=rgm.meter_id AND mv90.prod_date>=a.term_start AND mv90.prod_date<=a.term_end
			INNER JOIN recorder_properties rp on rp.meter_id=mv90.meter_id
			AND mv90.channel=rp.channel
		WHERE 1=1 '
				+CASE WHEN @term_start IS NOT NULL THEN ' AND mv90.prod_date>='''+@term_start+'''' ELSE '' END
				+CASE WHEN @term_end IS NOT NULL THEN ' AND mv90.prod_date<='''+@term_end+'''' ELSE '' END+

		' GROUP BY
			 counterparty_name, Technology, generator_name,State,state_id,UOM '+CASE WHEN @production_month_format='y' THEN ',deal_date' ELSE '' END+
			 ' order by counterparty_name, Technology, generator_name'
			 +CASE WHEN @production_month_format='y' THEN ',deal_date' ELSE '' END
		EXEC(@Sql_Select)

	END

	ELSE IF @report_type='m'
	BEGIN
	SET @Sql_Select='select  
			counterparty_name Counterparty,'
			+ CASE WHEN @module_type='r' THEN 
			'Technology,             
			generator_name as Generator,       
			State as [Gen State],' ELSE '' END +
			CASE WHEN @production_month_format='y' THEN ' dbo.FNADateFormat(deal_date) ' ELSE 'MIN(dbo.FNADateFormat(c.term_start))+'' - ''+ MAX(dbo.FNADateFormat(c.term_end))' END +' AS [Production Month],  
			--CAST(sum(c.Volume) AS NUMERIC(38, ' + @round_value + ')) Volume,               
			UOM
		' + @str_batch_table + ' 
		from
			#temp_all a INNER JOIN #temp_recorder b on a.generator_id=b.generator_id
			AND a.term_start=b.from_date AND a.term_end=b.to_date
			INNER JOIN
			(SELECT mi.meter_id,
			        channel,
			        dbo.fnagetcontractmonth(prod_date) prod_date,
			        SUM(
			            ISNULL(HR1, 0) + ISNULL(HR2, 0) + ISNULL(HR3, 0) + 
			            ISNULL(HR4, 0) + ISNULL(HR5, 0) + ISNULL(HR6, 0) + 
			            ISNULL(HR7, 0) + ISNULL(HR8, 0) + ISNULL(HR9, 0) + 
			            ISNULL(HR10, 0) +
			            ISNULL(HR11, 0) + ISNULL(HR12, 0) + ISNULL(HR13, 0) + 
			            ISNULL(HR14, 0) + ISNULL(HR15, 0) + ISNULL(HR16, 0) + 
			            ISNULL(HR17, 0) + ISNULL(HR18, 0) + ISNULL(HR19, 0) + 
			            ISNULL(HR20, 0) +
			            ISNULL(HR21, 0) + ISNULL(HR22, 0) + ISNULL(HR23, 0) + 
			            ISNULL(HR24, 0)
			        ) AS  Volume,
			        MIN(prod_date)     term_start,
			        MAX(prod_date)     term_end
			 FROM   mv90_data_hour mdh
			 INNER JOIN mv90_data mvd ON mvd.meter_data_id = mdh.meter_data_id
			 INNER JOIN meter_id mi ON mi.meter_id = mvd.meter_id
			 WHERE  data_missing = ''y'' '
			+ CASE WHEN @term_start IS NOT NULL THEN ' AND prod_date>='''+@term_start+'''' ELSE '' END
			+ CASE WHEN @term_end IS NOT NULL THEN ' AND prod_date<='''+@term_end+'''' ELSE '' END+
			' GROUP BY mi.meter_id,channel,dbo.fnagetcontractmonth(prod_date)) c
			on b.meter_id=c.meter_id AND b.channel=c.channel
			AND b.from_date=c.prod_date 
			--WHERE a.volume<>0
		GROUP BY counterparty_name,UOM '
			+ CASE WHEN @production_month_format='y' THEN ' ,deal_date ' ELSE '' END+
			+ CASE WHEN @module_type='r' THEN  ', generator_name, Technology, State,state_id' ELSE '' END +               
			 ' order by counterparty_name'
			+ CASE WHEN @production_month_format='y' THEN ' ,deal_date ' ELSE '' END+
			+ CASE WHEN @module_type='r' THEN ',Technology,generator_name' ELSE '' END
			EXEC(@Sql_Select)
	END
	ELSE IF @report_type='p' -- estimated production data
		BEGIN

		SELECT 
		   rg.generator_id,mv.meter_id,mv.channel,
			dbo.fnagetcontractmonth(mv.prod_date) prod_date,
			SUM(ISNULL(mvp.HR1,mv.HR1)*ISNULL(rp.mult_factor,1)+
			ISNULL(mvp.HR2,mv.HR2)*ISNULL(rp.mult_factor,1)+
			ISNULL(mvp.HR3,mv.HR3)*ISNULL(rp.mult_factor,1)+
			ISNULL(mvp.HR4,mv.HR4)*ISNULL(rp.mult_factor,1)+
			ISNULL(mvp.HR5,mv.HR5)*ISNULL(rp.mult_factor,1)+
			ISNULL(mvp.HR6,mv.HR6)*ISNULL(rp.mult_factor,1)+
			ISNULL(mvp.HR7,mv.HR7)*ISNULL(rp.mult_factor,1)+
			ISNULL(mvp.HR8,mv.HR8)*ISNULL(rp.mult_factor,1)+
			ISNULL(mvp.HR9,mv.HR9)*ISNULL(rp.mult_factor,1)+
			ISNULL(mvp.HR10,mv.HR10)*ISNULL(rp.mult_factor,1)+
			ISNULL(mvp.HR11,mv.HR11)*ISNULL(rp.mult_factor,1)+
			ISNULL(mvp.HR12,mv.HR12)*ISNULL(rp.mult_factor,1)+
			ISNULL(mvp.HR13,mv.HR13)*ISNULL(rp.mult_factor,1)+
			ISNULL(mvp.HR14,mv.HR14)*ISNULL(rp.mult_factor,1)+
			ISNULL(mvp.HR15,mv.HR15)*ISNULL(rp.mult_factor,1)+
			ISNULL(mvp.HR16,mv.HR16)*ISNULL(rp.mult_factor,1)+
			ISNULL(mvp.HR17,mv.HR17)*ISNULL(rp.mult_factor,1)+
			ISNULL(mvp.HR18,mv.HR18)*ISNULL(rp.mult_factor,1)+
			ISNULL(mvp.HR19,mv.HR19)*ISNULL(rp.mult_factor,1)+
			ISNULL(mvp.HR20,mv.HR20)*ISNULL(rp.mult_factor,1)+
			ISNULL(mvp.HR21,mv.HR21)*ISNULL(rp.mult_factor,1)+
			ISNULL(mvp.HR22,mv.HR22)*ISNULL(rp.mult_factor,1)+
			ISNULL(mvp.HR23,mv.HR23)*ISNULL(rp.mult_factor,1)+
			ISNULL(mvp.HR24,mv.HR24)*ISNULL(rp.mult_factor,1))*MAX(conv.conversion_factor) AS Volume	,
			MAX(dbo.fnadateformat(mv.proxy_date)) proxy_date,
			MIN(mv.prod_date) term_start,
			MAX(mv.prod_date) term_end
		INTO #temp_missing
	FROM
		#temp_all a 
		INNER JOIN rec_generator rg ON a.generator_id = rg.generator_id 
		INNER JOIN recorder_generator_map MAP ON rg.generator_id = map.generator_id   
		INNER JOIN #temp_mv90_hour mv 
			ON mv.meter_id = map.meter_id 
			AND mv.generator_id = map.generator_id
			AND a.term_start = dbo.fnagetcontractmonth(mv.prod_date)
		INNER JOIN recorder_properties rp 
			ON rp.meter_id = mv.meter_id
			AND mv.channel = rp.channel
		LEFT JOIN mv90_data_proxy mvp ON mv.meter_id = mvp.meter_data_id 
			AND mv.prod_date = mvp.prod_date 
			AND mv.data_missing = 'y'
		LEFT JOIN rec_volume_unit_conversion conv 
			ON rp.uom_id = conv.from_source_uom_id 
			AND conv.to_source_uom_id = ISNULL(@uom_id, @default_uom)
			AND conv.state_value_id IS NULL 
			AND conv.assignment_type_value_id IS NULL  
			AND conv.curve_id IS NULL   
		GROUP BY mv.meter_id,mv.channel,dbo.fnagetcontractmonth(mv.prod_date),rg.generator_id


	SET @sql_select='
		select  
			counterparty_name,' 
			+ CASE WHEN @module_type='r' THEN 
			'Technology,             
			generator_name as Generator,       
			State as [Gen State],' ELSE '' END +
			CASE WHEN @production_month_format='y' THEN ' dbo.FNADateFormat(deal_date) ' ELSE 'dbo.FNADateFormat(MIN(c.term_start))+'' - ''+ dbo.FNADateFormat(MAX(c.term_end))' END +' AS [Production Month],                              
			CAST(sum(c.Volume) AS NUMERIC(38, ' + @round_value + ')) Volume,               
			UOM,max(c.proxy_date) [Proxy Date]
		' + @str_batch_table + ' 
		from
			#temp_all a INNER JOIN #temp_recorder b on a.generator_id=b.generator_id
			AND a.term_start=b.from_date AND a.term_end=b.to_date
			INNER JOIN
			#temp_missing c
			on b.meter_id=c.meter_id AND b.channel=c.channel
			AND b.from_date=c.prod_date  AND a.generator_id=c.generator_id
		GROUP BY counterparty_name,UOM '
			+ CASE WHEN @module_type='r' THEN  ', generator_name, Technology, State,state_id' ELSE '' END +    
		    + CASE WHEN @production_month_format='y' THEN ' ,deal_date ' ELSE '' END+       
			 ' order by counterparty_name'
			+ CASE WHEN @production_month_format='y' THEN ' ,deal_date ' ELSE '' END+
			+ CASE WHEN @module_type='r' THEN ',Technology,generator_name' ELSE '' END

			EXEC(@Sql_Select)

	END

	ELSE IF @report_type='h'  -- show hourly drill
	BEGIN

	IF @granularity=982 -- hour
		BEGIN

			SELECT 
						b.generator_id,
						a.recorderid,CAST(MAX(rp.channel * rp.mult_factor) AS VARCHAR)
							+ CASE WHEN MAX(rp.channel)<>MIN(rp.channel) THEN 
								CASE WHEN MIN(rp.mult_factor)>0 THEN '+' ELSE '' END +CAST(MIN(rp.channel *rp.mult_factor) AS VARCHAR) ELSE '' END AS channel,
						prod_date,
						SUM(CASE WHEN a.data_missing='y' AND HR1 IS NULL THEN NULL ELSE HR1*rp.mult_factor END) HR1,
						SUM(CASE WHEN a.data_missing='y' AND HR2 IS NULL THEN NULL ELSE HR2*rp.mult_factor END) HR2,
						SUM(CASE WHEN a.data_missing='y' AND HR3 IS NULL THEN NULL ELSE HR3*rp.mult_factor END) HR3,
						SUM(CASE WHEN a.data_missing='y' AND HR4 IS NULL THEN NULL ELSE HR4*rp.mult_factor END) HR4,
						SUM(CASE WHEN a.data_missing='y' AND HR5 IS NULL THEN NULL ELSE HR5*rp.mult_factor END) HR5,
						SUM(CASE WHEN a.data_missing='y' AND HR6 IS NULL THEN NULL ELSE HR6*rp.mult_factor END) HR6,
						SUM(CASE WHEN a.data_missing='y' AND HR7 IS NULL THEN NULL ELSE HR7*rp.mult_factor END) HR7,
						SUM(CASE WHEN a.data_missing='y' AND HR8 IS NULL THEN NULL ELSE HR8*rp.mult_factor END) HR8,
						SUM(CASE WHEN a.data_missing='y' AND HR9 IS NULL THEN NULL ELSE HR9*rp.mult_factor END) HR9,
						SUM(CASE WHEN a.data_missing='y' AND HR10 IS NULL THEN NULL ELSE HR10*rp.mult_factor END) HR10,
						SUM(CASE WHEN a.data_missing='y' AND HR11 IS NULL THEN NULL ELSE HR11*rp.mult_factor END) HR11,
						SUM(CASE WHEN a.data_missing='y' AND HR12 IS NULL THEN NULL ELSE HR12*rp.mult_factor END) HR12,
						SUM(CASE WHEN a.data_missing='y' AND HR13 IS NULL THEN NULL ELSE HR13*rp.mult_factor END) HR13,
						SUM(CASE WHEN a.data_missing='y' AND HR14 IS NULL THEN NULL ELSE HR14*rp.mult_factor END) HR14,
						SUM(CASE WHEN a.data_missing='y' AND HR15 IS NULL THEN NULL ELSE HR15*rp.mult_factor END) HR15,
						SUM(CASE WHEN a.data_missing='y' AND HR16 IS NULL THEN NULL ELSE HR16*rp.mult_factor END) HR16,
						SUM(CASE WHEN a.data_missing='y' AND HR17 IS NULL THEN NULL ELSE HR17*rp.mult_factor END) HR17,
						SUM(CASE WHEN a.data_missing='y' AND HR18 IS NULL THEN NULL ELSE HR18*rp.mult_factor END) HR18,
						SUM(CASE WHEN a.data_missing='y' AND HR19 IS NULL THEN NULL ELSE HR19*rp.mult_factor END) HR19,
						SUM(CASE WHEN a.data_missing='y' AND HR20 IS NULL THEN NULL ELSE HR20*rp.mult_factor END) HR20,
						SUM(CASE WHEN a.data_missing='y' AND HR21 IS NULL THEN NULL ELSE HR21*rp.mult_factor END) HR21,
						SUM(CASE WHEN a.data_missing='y' AND HR22 IS NULL THEN NULL ELSE HR22*rp.mult_factor END) HR22,
						SUM(CASE WHEN a.data_missing='y' AND HR23 IS NULL THEN NULL ELSE HR23*rp.mult_factor END) HR23,
						SUM(CASE WHEN a.data_missing='y' AND HR24 IS NULL THEN NULL ELSE HR24*rp.mult_factor END) HR24,
						proxy_date
			INTO 	
				#temp_hour2
			FROM 		
					#temp_mv90_hour a INNER JOIN #temp_recorder b ON 
					b.recorderid=a.recorderid AND b.channel=a.channel AND 
					b.from_date=dbo.fnagetcontractmonth(a.prod_date)
					INNER JOIN recorder_properties rp ON rp.recorderid=b.recorderid
					AND rp.channel=b.channel
			GROUP BY b.generator_id,a.recorderid,prod_date,proxy_date


			SET @Sql_Select='	
				select 	
					--counterparty_name Counterparty,
					recorderid [Recorder ID],
					dbo.FNADateFormat(prod_date) [Prod Date],b.channel,
					CAST(HR1 AS NUMERIC(38, ' + @round_value + ')) HR1,
					CAST(HR2 AS NUMERIC(38, ' + @round_value + ')) HR2,
					CAST(HR3 AS NUMERIC(38, ' + @round_value + ')) HR3,
					CAST(HR4 AS NUMERIC(38, ' + @round_value + ')) HR4,
					CAST(HR5 AS NUMERIC(38, ' + @round_value + ')) HR5,
					CAST(HR6 AS NUMERIC(38, ' + @round_value + ')) HR6,
					CAST(HR7 AS NUMERIC(38, ' + @round_value + ')) HR7,
					CAST(HR8 AS NUMERIC(38, ' + @round_value + ')) HR8,
					CAST(HR9 AS NUMERIC(38, ' + @round_value + ')) HR9,
					CAST(HR10 AS NUMERIC(38, ' + @round_value + ')) HR10,
					CAST(HR11 AS NUMERIC(38, ' + @round_value + ')) HR11,
					CAST(HR12 AS NUMERIC(38, ' + @round_value + ')) HR12,
					CAST(HR13 AS NUMERIC(38, ' + @round_value + ')) HR13,
					CAST(HR14 AS NUMERIC(38, ' + @round_value + ')) HR14,
					CAST(HR15 AS NUMERIC(38, ' + @round_value + ')) HR15,
					CAST(HR16 AS NUMERIC(38, ' + @round_value + ')) HR16,
					CAST(HR17 AS NUMERIC(38, ' + @round_value + ')) HR17,
					CAST(HR18 AS NUMERIC(38, ' + @round_value + ')) HR18,
					CAST(HR19 AS NUMERIC(38, ' + @round_value + ')) HR19,
					CAST(HR20 AS NUMERIC(38, ' + @round_value + ')) HR20,
					CAST(HR21 AS NUMERIC(38, ' + @round_value + ')) HR21,
					CAST(HR22 AS NUMERIC(38, ' + @round_value + ')) HR22,
					CAST(HR23 AS NUMERIC(38, ' + @round_value + ')) HR23,
					CAST(HR24 AS NUMERIC(38, ' + @round_value + ')) HR24
				' + @str_batch_table + ' 
				from
					#temp_all a
					join #temp_hour2 b on
					a.generator_id=b.generator_id AND a.term_start=dbo.fnagetcontractmonth(b.prod_date)
				WHERE 1=1 
				'
				+ CASE WHEN (@drill_Counterparty IS NULL) THEN '' ELSE ' AND counterparty_name  = ''' + @drill_Counterparty + '''' END   
				+ CASE WHEN (@drill_technology IS NULL) THEN '' ELSE ' AND technology  = ''' + @drill_technology + '''' END   
				+ CASE WHEN (@drill_deal_date IS NULL) THEN '' ELSE ' AND deal_date  = ''' + @drill_deal_date + '''' END   
				+ CASE WHEN (@drill_state IS NULL) THEN '' ELSE ' AND state  = ''' + @drill_state + '''' END   
				+ CASE WHEN (@drill_buy_sell_flag IS NULL) THEN '' ELSE ' AND case when buy_sell_flag=''b'' then ''buy'' else ''sell'' end = ''' + @drill_buy_sell_flag + ''''END       
				+ CASE WHEN (@drill_generator IS NULL) THEN '' ELSE ' AND generator_name  = ''' + @drill_generator+ '''' END   
				+ ' order by recorderid,b.channel,prod_date'
				EXEC spa_print @Sql_Select
				EXEC(@Sql_Select)

	END

	ELSE IF @granularity=989 -- 30 MINS
		BEGIN
			SELECT 
						b.generator_id,
						a.recorderid,CAST(MAX(rp.channel * rp.mult_factor) AS VARCHAR)
							+ CASE WHEN MAX(rp.channel)<>MIN(rp.channel) THEN 
								CASE WHEN MIN(rp.mult_factor)>0 THEN '+' ELSE '' END +CAST(MIN(rp.channel *rp.mult_factor) AS VARCHAR) ELSE '' END AS channel,
						prod_date,
						SUM(CASE WHEN a.data_missing='y' AND HR1_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR1_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR1_30,
						SUM(CASE WHEN a.data_missing='y' AND HR1_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR1_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR1_60,
						SUM(CASE WHEN a.data_missing='y' AND HR2_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR2_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR2_30,
						SUM(CASE WHEN a.data_missing='y' AND HR2_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR2_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR2_60,
						SUM(CASE WHEN a.data_missing='y' AND HR3_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR3_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR3_30,
						SUM(CASE WHEN a.data_missing='y' AND HR3_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR3_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR3_60,
						SUM(CASE WHEN a.data_missing='y' AND HR4_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR4_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR4_30,
						SUM(CASE WHEN a.data_missing='y' AND HR4_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR4_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR4_60,
						SUM(CASE WHEN a.data_missing='y' AND HR5_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR5_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR5_30,
						SUM(CASE WHEN a.data_missing='y' AND HR5_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR5_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR5_60,
						SUM(CASE WHEN a.data_missing='y' AND HR6_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR6_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR6_30,
						SUM(CASE WHEN a.data_missing='y' AND HR6_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR6_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR6_60,
						SUM(CASE WHEN a.data_missing='y' AND HR7_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR7_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR7_30,
						SUM(CASE WHEN a.data_missing='y' AND HR7_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR7_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR7_60,
						SUM(CASE WHEN a.data_missing='y' AND HR8_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR8_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR8_30,
						SUM(CASE WHEN a.data_missing='y' AND HR8_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR8_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR8_60,
						SUM(CASE WHEN a.data_missing='y' AND HR9_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR9_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR9_30,
						SUM(CASE WHEN a.data_missing='y' AND HR9_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR9_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR9_60,
						SUM(CASE WHEN a.data_missing='y' AND HR10_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR10_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR10_30,
						SUM(CASE WHEN a.data_missing='y' AND HR10_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR10_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR10_60,
						SUM(CASE WHEN a.data_missing='y' AND HR11_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR11_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR11_30,
						SUM(CASE WHEN a.data_missing='y' AND HR11_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR11_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR11_60,
						SUM(CASE WHEN a.data_missing='y' AND HR12_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR12_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR12_30,
						SUM(CASE WHEN a.data_missing='y' AND HR12_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR12_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR12_60,
						SUM(CASE WHEN a.data_missing='y' AND HR13_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR13_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR13_30,
						SUM(CASE WHEN a.data_missing='y' AND HR13_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR13_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR13_60,
						SUM(CASE WHEN a.data_missing='y' AND HR14_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR14_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR14_30,
						SUM(CASE WHEN a.data_missing='y' AND HR14_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR14_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR14_60,
						SUM(CASE WHEN a.data_missing='y' AND HR15_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR15_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR15_30,
						SUM(CASE WHEN a.data_missing='y' AND HR15_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR15_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR15_60,
						SUM(CASE WHEN a.data_missing='y' AND HR16_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR16_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR16_30,
						SUM(CASE WHEN a.data_missing='y' AND HR16_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR16_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR16_60,
						SUM(CASE WHEN a.data_missing='y' AND HR17_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR17_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR17_30,
						SUM(CASE WHEN a.data_missing='y' AND HR17_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END)+
						SUM(CASE WHEN a.data_missing='y' AND HR17_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR17_60,
						SUM(CASE WHEN a.data_missing='y' AND HR18_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR18_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR18_30,
						SUM(CASE WHEN a.data_missing='y' AND HR18_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR18_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR18_60,
						SUM(CASE WHEN a.data_missing='y' AND HR19_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR19_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR19_30,
						SUM(CASE WHEN a.data_missing='y' AND HR19_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR19_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR19_60,
						SUM(CASE WHEN a.data_missing='y' AND HR20_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR20_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR20_30,
						SUM(CASE WHEN a.data_missing='y' AND HR20_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR20_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR20_60,
						SUM(CASE WHEN a.data_missing='y' AND HR21_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR21_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR21_30,
						SUM(CASE WHEN a.data_missing='y' AND HR21_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR21_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR21_60,
						SUM(CASE WHEN a.data_missing='y' AND HR22_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR22_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR22_30,
						SUM(CASE WHEN a.data_missing='y' AND HR22_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR22_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR22_60,
						SUM(CASE WHEN a.data_missing='y' AND HR23_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR23_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR23_30,
						SUM(CASE WHEN a.data_missing='y' AND HR23_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR23_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR23_60,
						SUM(CASE WHEN a.data_missing='y' AND HR24_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR24_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR24_30,
						SUM(CASE WHEN a.data_missing='y' AND HR24_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) +
						SUM(CASE WHEN a.data_missing='y' AND HR24_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR24_60,
						proxy_date
			INTO 	
				#temp_hour5
			FROM 		
					mv90_data_mins a INNER JOIN #temp_recorder b ON 
					b.recorderid=a.recorderid AND b.channel=a.channel AND 
					b.from_date=dbo.fnagetcontractmonth(a.prod_date)
					INNER JOIN recorder_properties rp ON rp.recorderid=b.recorderid
					AND rp.channel=b.channel
			GROUP BY b.generator_id,a.recorderid,prod_date,proxy_date


			SET @Sql_Select='	
				select 	
					--counterparty_name Counterparty,
					recorderid [Recorder ID],
					dbo.FNADateFormat(prod_date) [Prod Date],b.channel,
					CAST(HR1_30 AS NUMERIC(38, ' + @round_value + ') HR1_30, CAST(HR1_60 AS NUMERIC(38, ' + @round_value + ') HR1_60,
					CAST(HR2_30 AS NUMERIC(38, ' + @round_value + ') HR2_30, CAST(HR2_60 AS NUMERIC(38, ' + @round_value + ') HR2_60,
					CAST(HR3_30 AS NUMERIC(38, ' + @round_value + ') HR3_30, CAST(HR3_60 AS NUMERIC(38, ' + @round_value + ') HR3_60,
					CAST(HR4_30 AS NUMERIC(38, ' + @round_value + ') HR4_30, CAST(HR4_60 AS NUMERIC(38, ' + @round_value + ') HR4_60,
					CAST(HR5_30 AS NUMERIC(38, ' + @round_value + ') HR5_30, CAST(HR5_60 AS NUMERIC(38, ' + @round_value + ') HR5_60,
					CAST(HR6_30 AS NUMERIC(38, ' + @round_value + ') HR6_30, CAST(HR6_60 AS NUMERIC(38, ' + @round_value + ') HR6_60,
					CAST(HR7_30 AS NUMERIC(38, ' + @round_value + ') HR7_30, CAST(HR7_60 AS NUMERIC(38, ' + @round_value + ') HR7_60,
					CAST(HR8_30 AS NUMERIC(38, ' + @round_value + ') HR8_30, CAST(HR8_60 AS NUMERIC(38, ' + @round_value + ') HR8_60,
					CAST(HR9_30 AS NUMERIC(38, ' + @round_value + ') HR9_30, CAST(HR9_60 AS NUMERIC(38, ' + @round_value + ') HR9_60,
					CAST(HR10_30 AS NUMERIC(38, ' + @round_value + ') HR10_30, CAST(HR10_60 AS NUMERIC(38, ' + @round_value + ') HR10_60,
					CAST(HR11_30 AS NUMERIC(38, ' + @round_value + ') HR11_30, CAST(HR11_60 AS NUMERIC(38, ' + @round_value + ') HR11_60,
					CAST(HR12_30 AS NUMERIC(38, ' + @round_value + ') HR12_30, CAST(HR12_60 AS NUMERIC(38, ' + @round_value + ') HR12_60,
					CAST(HR13_30 AS NUMERIC(38, ' + @round_value + ') HR13_30, CAST(HR13_60 AS NUMERIC(38, ' + @round_value + ') HR13_60,
					CAST(HR14_30 AS NUMERIC(38, ' + @round_value + ') HR14_30, CAST(HR14_60 AS NUMERIC(38, ' + @round_value + ') HR14_60,
					CAST(HR15_30 AS NUMERIC(38, ' + @round_value + ') HR15_30, CAST(HR15_60 AS NUMERIC(38, ' + @round_value + ') HR15_60,
					CAST(HR16_30 AS NUMERIC(38, ' + @round_value + ') HR16_30, CAST(HR16_60 AS NUMERIC(38, ' + @round_value + ') HR16_60,
					CAST(HR17_30 AS NUMERIC(38, ' + @round_value + ') HR17_30, CAST(HR17_60 AS NUMERIC(38, ' + @round_value + ') HR17_60,
					CAST(HR18_30 AS NUMERIC(38, ' + @round_value + ') HR18_30, CAST(HR18_60 AS NUMERIC(38, ' + @round_value + ') HR18_60,
					CAST(HR19_30 AS NUMERIC(38, ' + @round_value + ') HR19_30, CAST(HR19_60 AS NUMERIC(38, ' + @round_value + ') HR19_60,
					CAST(HR20_30 AS NUMERIC(38, ' + @round_value + ') HR20_30, CAST(HR20_60 AS NUMERIC(38, ' + @round_value + ') HR20_60,
					CAST(HR21_30 AS NUMERIC(38, ' + @round_value + ') HR21_30, CAST(HR21_60 AS NUMERIC(38, ' + @round_value + ') HR21_60,
					CAST(HR22_30 AS NUMERIC(38, ' + @round_value + ') HR22_30, CAST(HR22_60 AS NUMERIC(38, ' + @round_value + ') HR22_60,
					CAST(HR23_30 AS NUMERIC(38, ' + @round_value + ') HR23_30, CAST(HR23_60 AS NUMERIC(38, ' + @round_value + ') HR23_60,
					CAST(HR24_30 AS NUMERIC(38, ' + @round_value + ') HR24_30, CAST(HR24_60 AS NUMERIC(38, ' + @round_value + ') HR24_60
			' + @str_batch_table + ' 
			from
					#temp_all a
					join #temp_hour5 b on
					a.generator_id=b.generator_id AND a.term_start=dbo.fnagetcontractmonth(b.prod_date)
				WHERE 1=1 
				'
				+ CASE WHEN (@drill_Counterparty IS NULL) THEN '' ELSE ' AND counterparty_name  = ''' + @drill_Counterparty + '''' END   
				+ CASE WHEN (@drill_technology IS NULL) THEN '' ELSE ' AND technology  = ''' + @drill_technology + '''' END   
				+ CASE WHEN (@drill_deal_date IS NULL) THEN '' ELSE ' AND deal_date  = ''' + @drill_deal_date + '''' END   
				+ CASE WHEN (@drill_state IS NULL) THEN '' ELSE ' AND state  = ''' + @drill_state + '''' END   
				+ CASE WHEN (@drill_buy_sell_flag IS NULL) THEN '' ELSE ' AND case when buy_sell_flag=''b'' then ''buy'' else ''sell'' end = ''' + @drill_buy_sell_flag + ''''END       
				+ CASE WHEN (@drill_generator IS NULL) THEN '' ELSE ' AND generator_name  = ''' + @drill_generator+ '''' END   
				+ ' order by recorderid,b.channel,prod_date'
				EXEC spa_print @Sql_Select
				EXEC(@Sql_Select)

	END

	ELSE IF @granularity=987 -- 15 MINS
		BEGIN
			SELECT 
						b.generator_id,
						a.recorderid,CAST(MAX(rp.channel * rp.mult_factor) AS VARCHAR)
							+ CASE WHEN MAX(rp.channel)<>MIN(rp.channel) THEN 
								CASE WHEN MIN(rp.mult_factor)>0 THEN '+' ELSE '' END +CAST(MIN(rp.channel *rp.mult_factor) AS VARCHAR) ELSE '' END AS channel,
						prod_date,
						SUM(CASE WHEN a.data_missing='y' AND HR1_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR1_15,
						SUM(CASE WHEN a.data_missing='y' AND HR1_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR1_30,
						SUM(CASE WHEN a.data_missing='y' AND HR1_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR1_45,
						SUM(CASE WHEN a.data_missing='y' AND HR1_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR1_60,
						SUM(CASE WHEN a.data_missing='y' AND HR2_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR2_15,
						SUM(CASE WHEN a.data_missing='y' AND HR2_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR2_30,
						SUM(CASE WHEN a.data_missing='y' AND HR2_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR2_45,
						SUM(CASE WHEN a.data_missing='y' AND HR2_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR2_60,
						SUM(CASE WHEN a.data_missing='y' AND HR3_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR3_15,
						SUM(CASE WHEN a.data_missing='y' AND HR3_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR3_30,
						SUM(CASE WHEN a.data_missing='y' AND HR3_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR3_45,
						SUM(CASE WHEN a.data_missing='y' AND HR3_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR3_60,
						SUM(CASE WHEN a.data_missing='y' AND HR4_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR4_15,
						SUM(CASE WHEN a.data_missing='y' AND HR4_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR4_30,
						SUM(CASE WHEN a.data_missing='y' AND HR4_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR4_45,
						SUM(CASE WHEN a.data_missing='y' AND HR4_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR4_60,
						SUM(CASE WHEN a.data_missing='y' AND HR5_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR5_15,
						SUM(CASE WHEN a.data_missing='y' AND HR5_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR5_30,
						SUM(CASE WHEN a.data_missing='y' AND HR5_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR5_45,
						SUM(CASE WHEN a.data_missing='y' AND HR5_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR5_60,
						SUM(CASE WHEN a.data_missing='y' AND HR6_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR6_15,
						SUM(CASE WHEN a.data_missing='y' AND HR6_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR6_30,
						SUM(CASE WHEN a.data_missing='y' AND HR6_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR6_45,
						SUM(CASE WHEN a.data_missing='y' AND HR6_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR6_60,
						SUM(CASE WHEN a.data_missing='y' AND HR7_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR7_15,
						SUM(CASE WHEN a.data_missing='y' AND HR7_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR7_30,
						SUM(CASE WHEN a.data_missing='y' AND HR7_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR7_45,
						SUM(CASE WHEN a.data_missing='y' AND HR7_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR7_60,
						SUM(CASE WHEN a.data_missing='y' AND HR8_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR8_15,
						SUM(CASE WHEN a.data_missing='y' AND HR8_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR8_30,
						SUM(CASE WHEN a.data_missing='y' AND HR8_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR8_45,
						SUM(CASE WHEN a.data_missing='y' AND HR8_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR8_60,
						SUM(CASE WHEN a.data_missing='y' AND HR9_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR9_15,
						SUM(CASE WHEN a.data_missing='y' AND HR9_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR9_30,
						SUM(CASE WHEN a.data_missing='y' AND HR9_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR9_45,
						SUM(CASE WHEN a.data_missing='y' AND HR9_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR9_60,
						SUM(CASE WHEN a.data_missing='y' AND HR10_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR10_15,
						SUM(CASE WHEN a.data_missing='y' AND HR10_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR10_30,
						SUM(CASE WHEN a.data_missing='y' AND HR10_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR10_45,
						SUM(CASE WHEN a.data_missing='y' AND HR10_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR10_60,
						SUM(CASE WHEN a.data_missing='y' AND HR11_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR11_15,
						SUM(CASE WHEN a.data_missing='y' AND HR11_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR11_30,
						SUM(CASE WHEN a.data_missing='y' AND HR11_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR11_45,
						SUM(CASE WHEN a.data_missing='y' AND HR11_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR11_60,
						SUM(CASE WHEN a.data_missing='y' AND HR12_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR12_15,
						SUM(CASE WHEN a.data_missing='y' AND HR12_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR12_30,
						SUM(CASE WHEN a.data_missing='y' AND HR12_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR12_45,
						SUM(CASE WHEN a.data_missing='y' AND HR12_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR12_60,
						SUM(CASE WHEN a.data_missing='y' AND HR13_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR13_15,
						SUM(CASE WHEN a.data_missing='y' AND HR13_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR13_30,
						SUM(CASE WHEN a.data_missing='y' AND HR13_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR13_45,
						SUM(CASE WHEN a.data_missing='y' AND HR13_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR13_60,
						SUM(CASE WHEN a.data_missing='y' AND HR14_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR14_15,
						SUM(CASE WHEN a.data_missing='y' AND HR14_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR14_30,
						SUM(CASE WHEN a.data_missing='y' AND HR14_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR14_45,
						SUM(CASE WHEN a.data_missing='y' AND HR14_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR14_60,
						SUM(CASE WHEN a.data_missing='y' AND HR15_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR15_15,
						SUM(CASE WHEN a.data_missing='y' AND HR15_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR15_30,
						SUM(CASE WHEN a.data_missing='y' AND HR15_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR15_45,
						SUM(CASE WHEN a.data_missing='y' AND HR15_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR15_60,
						SUM(CASE WHEN a.data_missing='y' AND HR16_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR16_15,
						SUM(CASE WHEN a.data_missing='y' AND HR16_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR16_30,
						SUM(CASE WHEN a.data_missing='y' AND HR16_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR16_45,
						SUM(CASE WHEN a.data_missing='y' AND HR16_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR16_60,
						SUM(CASE WHEN a.data_missing='y' AND HR17_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR17_15,
						SUM(CASE WHEN a.data_missing='y' AND HR17_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR17_30,
						SUM(CASE WHEN a.data_missing='y' AND HR17_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR17_45,
						SUM(CASE WHEN a.data_missing='y' AND HR17_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR17_60,
						SUM(CASE WHEN a.data_missing='y' AND HR18_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR18_15,
						SUM(CASE WHEN a.data_missing='y' AND HR18_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR18_30,
						SUM(CASE WHEN a.data_missing='y' AND HR18_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR18_45,
						SUM(CASE WHEN a.data_missing='y' AND HR18_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR18_60,
						SUM(CASE WHEN a.data_missing='y' AND HR19_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR19_15,
						SUM(CASE WHEN a.data_missing='y' AND HR19_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR19_30,
						SUM(CASE WHEN a.data_missing='y' AND HR19_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR19_45,
						SUM(CASE WHEN a.data_missing='y' AND HR19_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR19_60,
						SUM(CASE WHEN a.data_missing='y' AND HR20_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR20_15,
						SUM(CASE WHEN a.data_missing='y' AND HR20_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR20_30,
						SUM(CASE WHEN a.data_missing='y' AND HR20_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR20_45,
						SUM(CASE WHEN a.data_missing='y' AND HR20_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR20_60,
						SUM(CASE WHEN a.data_missing='y' AND HR21_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR21_15,
						SUM(CASE WHEN a.data_missing='y' AND HR21_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR21_30,
						SUM(CASE WHEN a.data_missing='y' AND HR21_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR21_45,
						SUM(CASE WHEN a.data_missing='y' AND HR21_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR21_60,
						SUM(CASE WHEN a.data_missing='y' AND HR22_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR22_15,
						SUM(CASE WHEN a.data_missing='y' AND HR22_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR22_30,
						SUM(CASE WHEN a.data_missing='y' AND HR22_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR22_45,
						SUM(CASE WHEN a.data_missing='y' AND HR22_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR22_60,
						SUM(CASE WHEN a.data_missing='y' AND HR23_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR23_15,
						SUM(CASE WHEN a.data_missing='y' AND HR23_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR23_30,
						SUM(CASE WHEN a.data_missing='y' AND HR23_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR23_45,
						SUM(CASE WHEN a.data_missing='y' AND HR23_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR23_60,
						SUM(CASE WHEN a.data_missing='y' AND HR24_15 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR24_15,
						SUM(CASE WHEN a.data_missing='y' AND HR24_30 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR24_30,
						SUM(CASE WHEN a.data_missing='y' AND HR24_45 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR24_45,
						SUM(CASE WHEN a.data_missing='y' AND HR24_60 IS NULL THEN NULL ELSE HR1_15*rp.mult_factor END) HR24_60,
						proxy_date
			INTO 	
				#temp_hour6
			FROM 		
					mv90_data_mins a INNER JOIN #temp_recorder b ON 
					b.recorderid=a.recorderid AND b.channel=a.channel AND 
					b.from_date=dbo.fnagetcontractmonth(a.prod_date)
					INNER JOIN recorder_properties rp ON rp.recorderid=b.recorderid
					AND rp.channel=b.channel
			GROUP BY b.generator_id,a.recorderid,prod_date,proxy_date


			SET @Sql_Select='	
				select 
					--counterparty_name Counterparty,
					recorderid [Recorder ID],
					dbo.FNADateFormat(prod_date) [Prod Date],b.channel,
					CAST(HR1_15 AS NUMERIC(38, ' + @round_value + ')) HR1_15, CAST(HR1_30 AS NUMERIC(38, ' + @round_value + ')) HR1_30, , CAST(HR1_45 AS NUMERIC(38, ' + @round_value + ')) HR1_45, CAST(HR1_60 AS NUMERIC(38, ' + @round_value + ')) HR1_60,
					CAST(HR2_15 AS NUMERIC(38, ' + @round_value + ')) HR2_15, CAST(HR2_30 AS NUMERIC(38, ' + @round_value + ')) HR2_30, , CAST(HR2_45 AS NUMERIC(38, ' + @round_value + ')) HR2_45, CAST(HR2_60 AS NUMERIC(38, ' + @round_value + ')) HR2_60,
					CAST(HR3_15 AS NUMERIC(38, ' + @round_value + ')) HR3_15, CAST(HR3_30 AS NUMERIC(38, ' + @round_value + ')) HR3_30, , CAST(HR3_45 AS NUMERIC(38, ' + @round_value + ')) HR3_45, CAST(HR3_60 AS NUMERIC(38, ' + @round_value + ')) HR3_60,
					CAST(HR4_15 AS NUMERIC(38, ' + @round_value + ')) HR4_15, CAST(HR4_30 AS NUMERIC(38, ' + @round_value + ')) HR4_30, , CAST(HR4_45 AS NUMERIC(38, ' + @round_value + ')) HR4_45, CAST(HR4_60 AS NUMERIC(38, ' + @round_value + ')) HR4_60,
					CAST(HR5_15 AS NUMERIC(38, ' + @round_value + ')) HR5_15, CAST(HR5_30 AS NUMERIC(38, ' + @round_value + ')) HR5_30, , CAST(HR5_45 AS NUMERIC(38, ' + @round_value + ')) HR5_45, CAST(HR5_60 AS NUMERIC(38, ' + @round_value + ')) HR5_60,
					CAST(HR6_15 AS NUMERIC(38, ' + @round_value + ')) HR6_15, CAST(HR6_30 AS NUMERIC(38, ' + @round_value + ')) HR6_30, , CAST(HR6_45 AS NUMERIC(38, ' + @round_value + ')) HR6_45, CAST(HR6_60 AS NUMERIC(38, ' + @round_value + ')) HR6_60,
					CAST(HR7_15 AS NUMERIC(38, ' + @round_value + ')) HR7_15, CAST(HR7_30 AS NUMERIC(38, ' + @round_value + ')) HR7_30, , CAST(HR7_45 AS NUMERIC(38, ' + @round_value + ')) HR7_45, CAST(HR7_60 AS NUMERIC(38, ' + @round_value + ')) HR7_60,
					CAST(HR8_15 AS NUMERIC(38, ' + @round_value + ')) HR8_15, CAST(HR8_30 AS NUMERIC(38, ' + @round_value + ')) HR8_30, , CAST(HR8_45 AS NUMERIC(38, ' + @round_value + ')) HR8_45, CAST(HR8_60 AS NUMERIC(38, ' + @round_value + ')) HR8_60,
					CAST(HR9_15 AS NUMERIC(38, ' + @round_value + ')) HR9_15, CAST(HR9_30 AS NUMERIC(38, ' + @round_value + ')) HR9_30, , CAST(HR9_45 AS NUMERIC(38, ' + @round_value + ')) HR9_45, CAST(HR9_60 AS NUMERIC(38, ' + @round_value + ')) HR9_60,
					CAST(HR10_15 AS NUMERIC(38, ' + @round_value + ')) HR10_15, CAST(HR10_30 AS NUMERIC(38, ' + @round_value + ')) HR10_30, , CAST(HR10_45 AS NUMERIC(38, ' + @round_value + ')) HR10_45, CAST(HR10_60 AS NUMERIC(38, ' + @round_value + ')) HR10_60,
					CAST(HR11_15 AS NUMERIC(38, ' + @round_value + ')) HR11_15, CAST(HR11_30 AS NUMERIC(38, ' + @round_value + ')) HR11_30, , CAST(HR11_45 AS NUMERIC(38, ' + @round_value + ')) HR11_45, CAST(HR11_60 AS NUMERIC(38, ' + @round_value + ')) HR11_60,
					CAST(HR12_15 AS NUMERIC(38, ' + @round_value + ')) HR12_15, CAST(HR12_30 AS NUMERIC(38, ' + @round_value + ')) HR12_30, , CAST(HR12_45 AS NUMERIC(38, ' + @round_value + ')) HR12_45, CAST(HR12_60 AS NUMERIC(38, ' + @round_value + ')) HR12_60,
					CAST(HR13_15 AS NUMERIC(38, ' + @round_value + ')) HR13_15, CAST(HR13_30 AS NUMERIC(38, ' + @round_value + ')) HR13_30, , CAST(HR13_45 AS NUMERIC(38, ' + @round_value + ')) HR13_45, CAST(HR13_60 AS NUMERIC(38, ' + @round_value + ')) HR13_60,
					CAST(HR14_15 AS NUMERIC(38, ' + @round_value + ')) HR14_15, CAST(HR14_30 AS NUMERIC(38, ' + @round_value + ')) HR14_30, , CAST(HR14_45 AS NUMERIC(38, ' + @round_value + ')) HR14_45, CAST(HR14_60 AS NUMERIC(38, ' + @round_value + ')) HR14_60,
					CAST(HR15_15 AS NUMERIC(38, ' + @round_value + ')) HR15_15, CAST(HR15_30 AS NUMERIC(38, ' + @round_value + ')) HR15_30, , CAST(HR15_45 AS NUMERIC(38, ' + @round_value + ')) HR15_45, CAST(HR15_60 AS NUMERIC(38, ' + @round_value + ')) HR15_60,
					CAST(HR16_15 AS NUMERIC(38, ' + @round_value + ')) HR16_15, CAST(HR16_30 AS NUMERIC(38, ' + @round_value + ')) HR16_30, , CAST(HR16_45 AS NUMERIC(38, ' + @round_value + ')) HR16_45, CAST(HR16_60 AS NUMERIC(38, ' + @round_value + ')) HR16_60,
					CAST(HR17_15 AS NUMERIC(38, ' + @round_value + ')) HR17_15, CAST(HR17_30 AS NUMERIC(38, ' + @round_value + ')) HR17_30, , CAST(HR17_45 AS NUMERIC(38, ' + @round_value + ')) HR17_45, CAST(HR17_60 AS NUMERIC(38, ' + @round_value + ')) HR17_60,
					CAST(HR18_15 AS NUMERIC(38, ' + @round_value + ')) HR18_15, CAST(HR18_30 AS NUMERIC(38, ' + @round_value + ')) HR18_30, , CAST(HR18_45 AS NUMERIC(38, ' + @round_value + ')) HR18_45, CAST(HR18_60 AS NUMERIC(38, ' + @round_value + ')) HR18_60,
					CAST(HR19_15 AS NUMERIC(38, ' + @round_value + ')) HR19_15, CAST(HR19_30 AS NUMERIC(38, ' + @round_value + ')) HR19_30, , CAST(HR19_45 AS NUMERIC(38, ' + @round_value + ')) HR19_45, CAST(HR19_60 AS NUMERIC(38, ' + @round_value + ')) HR19_60,
					CAST(HR20_15 AS NUMERIC(38, ' + @round_value + ')) HR20_15, CAST(HR20_30 AS NUMERIC(38, ' + @round_value + ')) HR20_30, , CAST(HR20_45 AS NUMERIC(38, ' + @round_value + ')) HR20_45, CAST(HR20_60 AS NUMERIC(38, ' + @round_value + ')) HR20_60,
					CAST(HR21_15 AS NUMERIC(38, ' + @round_value + ')) HR21_15, CAST(HR21_30 AS NUMERIC(38, ' + @round_value + ')) HR21_30, , CAST(HR21_45 AS NUMERIC(38, ' + @round_value + ')) HR21_45, CAST(HR21_60 AS NUMERIC(38, ' + @round_value + ')) HR21_60,
					CAST(HR22_15 AS NUMERIC(38, ' + @round_value + ')) HR22_15, CAST(HR22_30 AS NUMERIC(38, ' + @round_value + ')) HR22_30, , CAST(HR22_45 AS NUMERIC(38, ' + @round_value + ')) HR22_45, CAST(HR22_60 AS NUMERIC(38, ' + @round_value + ')) HR22_60,
					CAST(HR23_15 AS NUMERIC(38, ' + @round_value + ')) HR23_15, CAST(HR23_30 AS NUMERIC(38, ' + @round_value + ')) HR23_30, , CAST(HR23_45 AS NUMERIC(38, ' + @round_value + ')) HR23_45, CAST(HR23_60 AS NUMERIC(38, ' + @round_value + ')) HR23_60,
					CAST(HR24_15 AS NUMERIC(38, ' + @round_value + ')) HR24_15, CAST(HR24_30 AS NUMERIC(38, ' + @round_value + ')) HR24_30, , CAST(HR24_45 AS NUMERIC(38, ' + @round_value + ')) HR24_45, CAST(HR24_60 AS NUMERIC(38, ' + @round_value + ')) HR24_60
			' + @str_batch_table + ' 
			from
					#temp_all a
					join #temp_hour6 b on
					a.generator_id=b.generator_id AND a.term_start=dbo.fnagetcontractmonth(b.prod_date)
				WHERE 1=1 
				'
				+ CASE WHEN (@drill_Counterparty IS NULL) THEN '' ELSE ' AND counterparty_name  = ''' + @drill_Counterparty + '''' END   
				+ CASE WHEN (@drill_technology IS NULL) THEN '' ELSE ' AND technology  = ''' + @drill_technology + '''' END   
				+ CASE WHEN (@drill_deal_date IS NULL) THEN '' ELSE ' AND deal_date  = ''' + @drill_deal_date + '''' END   
				+ CASE WHEN (@drill_state IS NULL) THEN '' ELSE ' AND state  = ''' + @drill_state + '''' END   
				+ CASE WHEN (@drill_buy_sell_flag IS NULL) THEN '' ELSE ' AND case when buy_sell_flag=''b'' then ''buy'' else ''sell'' end = ''' + @drill_buy_sell_flag + ''''END       
				+ CASE WHEN (@drill_generator IS NULL) THEN '' ELSE ' AND generator_name  = ''' + @drill_generator+ '''' END   
				+ ' order by recorderid,b.channel,prod_date'
				EXEC spa_print @Sql_Select
				EXEC(@Sql_Select)

	END

	END
	
	ELSE IF @report_type='c'  -- Estimated Hourly Drill
	BEGIN

	SELECT 
				b.generator_id,
				a.recorderid,CAST(MAX(rp.channel * rp.mult_factor) AS VARCHAR)
					+ CASE WHEN MAX(rp.channel)<>MIN(rp.channel) THEN 
						CASE WHEN MIN(rp.mult_factor)>0 THEN '+' ELSE '' END +CAST(MIN(rp.channel *rp.mult_factor) AS VARCHAR) ELSE '' END AS channel,
				a.prod_date,
				SUM(ISNULL(mvp.HR1,a.HR1)*rp.mult_factor) HR1,
				SUM(ISNULL(mvp.HR2,a.HR2)*rp.mult_factor) HR2,
				SUM(ISNULL(mvp.HR3,a.HR3)*rp.mult_factor) HR3,
				SUM(ISNULL(mvp.HR4,a.HR4)*rp.mult_factor) HR4,
				SUM(ISNULL(mvp.HR5,a.HR5)*rp.mult_factor) HR5,
				SUM(ISNULL(mvp.HR6,a.HR6)*rp.mult_factor) HR6,
				SUM(ISNULL(mvp.HR7,a.HR7)*rp.mult_factor) HR7,
				SUM(ISNULL(mvp.HR8,a.HR8)*rp.mult_factor) HR8,
				SUM(ISNULL(mvp.HR9,a.HR9)*rp.mult_factor) HR9,
				SUM(ISNULL(mvp.HR10,a.HR10)*rp.mult_factor) HR10,
				SUM(ISNULL(mvp.HR11,a.HR11)*rp.mult_factor) HR11,
				SUM(ISNULL(mvp.HR12,a.HR12)*rp.mult_factor) HR12,
				SUM(ISNULL(mvp.HR13,a.HR13)*rp.mult_factor) HR13,
				SUM(ISNULL(mvp.HR14,a.HR14)*rp.mult_factor) HR14,
				SUM(ISNULL(mvp.HR15,a.HR15)*rp.mult_factor) HR15,
				SUM(ISNULL(mvp.HR16,a.HR16)*rp.mult_factor) HR16,
				SUM(ISNULL(mvp.HR17,a.HR17)*rp.mult_factor) HR17,
				SUM(ISNULL(mvp.HR18,a.HR18)*rp.mult_factor) HR18,
				SUM(ISNULL(mvp.HR19,a.HR19)*rp.mult_factor) HR19,
				SUM(ISNULL(mvp.HR20,a.HR20)*rp.mult_factor) HR20,
				SUM(ISNULL(mvp.HR21,a.HR21)*rp.mult_factor) HR21,
				SUM(ISNULL(mvp.HR22,a.HR22)*rp.mult_factor) HR22,
				SUM(ISNULL(mvp.HR23,a.HR23)*rp.mult_factor) HR23,
				SUM(ISNULL(mvp.HR24,a.HR24)*rp.mult_factor) HR24,
				a.proxy_date
	INTO 	
		#temp_hour3
	FROM 		
			#temp_mv90_hour a INNER JOIN #temp_recorder b ON 
			b.recorderid=a.recorderid AND b.channel=a.channel AND 
			b.from_date=dbo.fnagetcontractmonth(a.prod_date)
			INNER JOIN recorder_properties rp ON rp.recorderid=b.recorderid
			AND rp.channel=b.channel
			LEFT JOIN mv90_data_proxy mvp ON mvp.recorderid=a.recorderid AND
			mvp.channel=a.channel AND mvp.prod_date=a.prod_date AND a.data_missing='y'
	GROUP BY b.generator_id,a.recorderid,a.prod_date,a.proxy_date
			
			--WHERE data_missing='y'
	SET @Sql_Select='	
		select 	
			--counterparty_name Counterparty,
			recorderid [Recorder ID],
			dbo.FNADateFormat(prod_date) [Prod Date],b.channel,
			CAST(HR1 AS NUMERIC(38, ' + @round_value + ')) HR1,
			CAST(HR2 AS NUMERIC(38, ' + @round_value + ')) HR2,
			CAST(HR3 AS NUMERIC(38, ' + @round_value + ')) HR3,
			CAST(HR4 AS NUMERIC(38, ' + @round_value + ')) HR4,
			CAST(HR5 AS NUMERIC(38, ' + @round_value + ')) HR5,
			CAST(HR6 AS NUMERIC(38, ' + @round_value + ')) HR6,
			CAST(HR7 AS NUMERIC(38, ' + @round_value + ')) HR7,
			CAST(HR8 AS NUMERIC(38, ' + @round_value + ')) HR8,
			CAST(HR9 AS NUMERIC(38, ' + @round_value + ')) HR9,
			CAST(HR10 AS NUMERIC(38, ' + @round_value + ')) HR10,
			CAST(HR11 AS NUMERIC(38, ' + @round_value + ')) HR11,
			CAST(HR12 AS NUMERIC(38, ' + @round_value + ')) HR12,
			CAST(HR13 AS NUMERIC(38, ' + @round_value + ')) HR13,
			CAST(HR14 AS NUMERIC(38, ' + @round_value + ')) HR14,
			CAST(HR15 AS NUMERIC(38, ' + @round_value + ')) HR15,
			CAST(HR16 AS NUMERIC(38, ' + @round_value + ')) HR16,
			CAST(HR17 AS NUMERIC(38, ' + @round_value + ')) HR17,
			CAST(HR18 AS NUMERIC(38, ' + @round_value + ')) HR18,
			CAST(HR19 AS NUMERIC(38, ' + @round_value + ')) HR19,
			CAST(HR20 AS NUMERIC(38, ' + @round_value + ')) HR20,
			CAST(HR21 AS NUMERIC(38, ' + @round_value + ')) HR21,
			CAST(HR22 AS NUMERIC(38, ' + @round_value + ')) HR22,
			CAST(HR23 AS NUMERIC(38, ' + @round_value + ')) HR23,
			CAST(HR24 AS NUMERIC(38, ' + @round_value + ')) HR24
	' + @str_batch_table + ' 
	from
			#temp_all a
			join #temp_hour3 b on
			a.generator_id=b.generator_id AND a.term_start=dbo.fnagetcontractmonth(b.prod_date)
		WHERE 1=1 
		'
		+ CASE WHEN (@drill_Counterparty IS NULL) THEN '' ELSE ' AND counterparty_name  = ''' + @drill_Counterparty + '''' END   
		+ CASE WHEN (@drill_technology IS NULL) THEN '' ELSE ' AND technology  = ''' + @drill_technology + '''' END   
		+ CASE WHEN (@drill_deal_date IS NULL) THEN '' ELSE ' AND deal_date  = ''' + @drill_deal_date + '''' END   
		+ CASE WHEN (@drill_state IS NULL) THEN '' ELSE ' AND state  = ''' + @drill_state + '''' END   
		+ CASE WHEN (@drill_buy_sell_flag IS NULL) THEN '' ELSE ' AND case when buy_sell_flag=''b'' then ''buy'' else ''sell'' end = ''' + @drill_buy_sell_flag + ''''END       
		+ CASE WHEN (@drill_generator IS NULL) THEN '' ELSE ' AND generator_name  = ''' + @drill_generator+ '''' END   
		+ CASE WHEN @term_start IS NULL THEN '' ELSE ' AND prod_date>='''+@term_start+'''' END
		+ CASE WHEN @term_end IS NULL THEN '' ELSE ' AND prod_date<='''+@term_end+''''  END
		+ ' order by recorderid,b.channel,prod_date'
		EXEC spa_print @Sql_Select
		EXEC(@Sql_Select)
	END
	ELSE IF @report_type='r'
	BEGIN

		SELECT b.generator_id,a.recorderid,b.channel,prod_date,HR1,HR2,HR3,HR4,HR5,HR6,HR7,HR8,HR9,HR10,HR11,HR12
					,HR13,HR14,HR15,HR16,HR17,HR18,HR19,HR20,HR21,HR22,HR23,HR24,proxy_date 

		INTO 	
			#temp_hour1
		FROM 		
				mv90_data_proxy a INNER JOIN #temp_recorder b ON 
				b.recorderid=a.recorderid AND b.channel=a.channel AND 
				b.from_date=dbo.fnagetcontractmonth(a.prod_date)
				--WHERE data_missing='y'
		SET @Sql_Select='	
			select 	distinct
				--counterparty_name Counterparty,
				recorderid [Recorder ID],
				dbo.FNADateFormat(proxy_date) [Prod Date],b.channel,
				CAST(HR1 AS NUMERIC(38, ' + @round_value + ')) HR1,
				CAST(HR2 AS NUMERIC(38, ' + @round_value + ')) HR2,
				CAST(HR3 AS NUMERIC(38, ' + @round_value + ')) HR3,
				CAST(HR4 AS NUMERIC(38, ' + @round_value + ')) HR4,
				CAST(HR5 AS NUMERIC(38, ' + @round_value + ')) HR5,
				CAST(HR6 AS NUMERIC(38, ' + @round_value + ')) HR6,
				CAST(HR7 AS NUMERIC(38, ' + @round_value + ')) HR7,
				CAST(HR8 AS NUMERIC(38, ' + @round_value + ')) HR8,
				CAST(HR9 AS NUMERIC(38, ' + @round_value + ')) HR9,
				CAST(HR10 AS NUMERIC(38, ' + @round_value + ')) HR10,
				CAST(HR11 AS NUMERIC(38, ' + @round_value + ')) HR11,
				CAST(HR12 AS NUMERIC(38, ' + @round_value + ')) HR12,
				CAST(HR13 AS NUMERIC(38, ' + @round_value + ')) HR13,
				CAST(HR14 AS NUMERIC(38, ' + @round_value + ')) HR14,
				CAST(HR15 AS NUMERIC(38, ' + @round_value + ')) HR15,
				CAST(HR16 AS NUMERIC(38, ' + @round_value + ')) HR16,
				CAST(HR17 AS NUMERIC(38, ' + @round_value + ')) HR17,
				CAST(HR18 AS NUMERIC(38, ' + @round_value + ')) HR18,
				CAST(HR19 AS NUMERIC(38, ' + @round_value + ')) HR19,
				CAST(HR20 AS NUMERIC(38, ' + @round_value + ')) HR20,
				CAST(HR21 AS NUMERIC(38, ' + @round_value + ')) HR21,
				CAST(HR22 AS NUMERIC(38, ' + @round_value + ')) HR22,
				CAST(HR23 AS NUMERIC(38, ' + @round_value + ')) HR23,
				CAST(HR24 AS NUMERIC(38, ' + @round_value + ')) HR24

			' + @str_batch_table + ' 
			from
				#temp_all a
				join #temp_hour1 b on
				a.generator_id=b.generator_id AND a.term_start=dbo.fnagetcontractmonth(b.prod_date)
			WHERE 1=1 
			'
			+ CASE WHEN (@drill_Counterparty IS NULL) THEN '' ELSE ' AND counterparty_name  = ''' + @drill_Counterparty + '''' END   
			+ CASE WHEN (@drill_technology IS NULL) THEN '' ELSE ' AND technology  = ''' + @drill_technology + '''' END   
			+ CASE WHEN (@drill_deal_date IS NULL) THEN '' ELSE ' AND dbo.fnagetcontractmonth(deal_date)  = dbo.fnagetcontractmonth(''' + @drill_deal_date + ''')' END   
			+ CASE WHEN (@drill_state IS NULL) THEN '' ELSE ' AND state  = ''' + @drill_state + '''' END   
			+ CASE WHEN (@drill_buy_sell_flag IS NULL) THEN '' ELSE ' AND case when buy_sell_flag=''b'' then ''buy'' else ''sell'' end = ''' + @drill_buy_sell_flag + ''''END       
			+ CASE WHEN (@drill_generator IS NULL) THEN '' ELSE ' AND generator_name  = ''' + @drill_generator+ '''' END   
			+ ''
			EXEC spa_print @Sql_Select
			EXEC(@Sql_Select)
	END
	ELSE IF @report_type='d'
	BEGIN

		SELECT b.generator_id,a.recorderid,b.channel,prod_date,HR1,HR2,HR3,HR4,HR5,HR6,HR7,HR8,HR9,HR10,HR11,HR12
					,HR13,HR14,HR15,HR16,HR17,HR18,HR19,HR20,HR21,HR22,HR23,HR24,proxy_date 

		INTO 	
			#temp_hour
		FROM 		mv90_data_hour a INNER JOIN #temp_recorder b ON 
				b.recorderid=a.recorderid AND b.channel=a.channel AND 
				b.from_date=dbo.fnagetcontractmonth(a.prod_date)
				WHERE data_missing='y'
		SET @Sql_Select='
			
			select 	distinct
				counterparty_name Counterparty,
				recorderid [Recorder ID],
				dbo.FNADateFormat(prod_date) [Prod Date],b.channel,
				CAST(HR1 AS NUMERIC(38, ' + @round_value + ')) HR1,
				CAST(HR2 AS NUMERIC(38, ' + @round_value + ')) HR2,
				CAST(HR3 AS NUMERIC(38, ' + @round_value + ')) HR3,
				CAST(HR4 AS NUMERIC(38, ' + @round_value + ')) HR4,
				CAST(HR5 AS NUMERIC(38, ' + @round_value + ')) HR5,
				CAST(HR6 AS NUMERIC(38, ' + @round_value + ')) HR6,
				CAST(HR7 AS NUMERIC(38, ' + @round_value + ')) HR7,
				CAST(HR8 AS NUMERIC(38, ' + @round_value + ')) HR8,
				CAST(HR9 AS NUMERIC(38, ' + @round_value + ')) HR9,
				CAST(HR10 AS NUMERIC(38, ' + @round_value + ')) HR10,
				CAST(HR11 AS NUMERIC(38, ' + @round_value + ')) HR11,
				CAST(HR12 AS NUMERIC(38, ' + @round_value + ')) HR12,
				CAST(HR13 AS NUMERIC(38, ' + @round_value + ')) HR13,
				CAST(HR14 AS NUMERIC(38, ' + @round_value + ')) HR14,
				CAST(HR15 AS NUMERIC(38, ' + @round_value + ')) HR15,
				CAST(HR16 AS NUMERIC(38, ' + @round_value + ')) HR16,
				CAST(HR17 AS NUMERIC(38, ' + @round_value + ')) HR17,
				CAST(HR18 AS NUMERIC(38, ' + @round_value + ')) HR18,
				CAST(HR19 AS NUMERIC(38, ' + @round_value + ')) HR19,
				CAST(HR20 AS NUMERIC(38, ' + @round_value + ')) HR20,
				CAST(HR21 AS NUMERIC(38, ' + @round_value + ')) HR21,
				CAST(HR22 AS NUMERIC(38, ' + @round_value + ')) HR22,
				CAST(HR23 AS NUMERIC(38, ' + @round_value + ')) HR23,
				CAST(HR24 AS NUMERIC(38, ' + @round_value + ')) HR24,
				dbo.FNADateFormat(proxy_date) [Proxy Date Used]		
			' + @str_batch_table + ' 
			from
				#temp_all a
				join #temp_hour b on
				a.generator_id=b.generator_id AND a.term_start=dbo.fnagetcontractmonth(b.prod_date)
			WHERE 1=1 
			'
			+ CASE WHEN (@drill_Counterparty IS NULL) THEN '' ELSE ' AND counterparty_name  = ''' + @drill_Counterparty + '''' END   
			+ CASE WHEN (@drill_technology IS NULL) THEN '' ELSE ' AND technology  = ''' + @drill_technology + '''' END   
			+ CASE WHEN (@drill_deal_date IS NULL) THEN '' ELSE ' AND deal_date  = ''' + @drill_deal_date + '''' END   
			+ CASE WHEN (@drill_state IS NULL) THEN '' ELSE ' AND state  = ''' + @drill_state + '''' END   
			+ CASE WHEN (@drill_buy_sell_flag IS NULL) THEN '' ELSE ' AND case when buy_sell_flag=''b'' then ''buy'' else ''sell'' end = ''' + @drill_buy_sell_flag + ''''END       
			+ CASE WHEN (@drill_generator IS NULL) THEN '' ELSE ' AND generator_name  = ''' + @drill_generator+ '''' END   
			+ CASE WHEN @term_start IS NULL THEN '' ELSE ' AND prod_date>='''+@term_start+'''' END
			+ CASE WHEN @term_end IS NULL THEN '' ELSE ' AND prod_date<='''+@term_end+''''  END
			+ ''
			EXEC spa_print @Sql_Select
			EXEC(@Sql_Select)
		END
	END
	ELSE IF @report_type='p' -- proxy drill down
	BEGIN
		SET @Sql_Select = '
			SELECT 
				recorderid[Recorder ID],channel [Channel],dbo.fnadateformat(prod_date) [DATE],HR1,HR2,HR3,HR4,HR5,HR6,HR7,HR8,HR9,HR10,HR11,HR12
						,HR13,HR14,HR15,HR16,HR17,HR18,HR19,HR20,HR21,HR22,HR23,HR24
				' + @str_batch_table + ' 
			FROM
					mv90_data_proxy WHERE recorderid = ''' + CAST(@drill_recorderid AS VARCHAR(10)) + ' AND
					channel = ' + CAST(@drill_channel AS VARCHAR(10)) + ' AND prod_date = ''' + @drill_deal_date + ''''
					
		EXEC spa_print @Sql_Select
		EXEC(@Sql_Select)		
				
	END
END

/*******************************************2nd Paging Batch START**********************************************/
--update time spent AND batch completion message in message board
IF @is_batch = 1
BEGIN
	SELECT @str_batch_table = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL)   
	EXEC(@str_batch_table)                   

	SELECT @str_batch_table = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_settlement_production_report', 'Settlement Production Report')         
	EXEC(@str_batch_table)        
	RETURN
END

--if it is first call from paging, return total no. of rows AND process id instead of actual data
IF @enable_paging = 1 AND @page_no IS NULL
BEGIN
	SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
	EXEC(@sql_paging)
END
/*******************************************2nd Paging Batch END**********************************************/
GO
