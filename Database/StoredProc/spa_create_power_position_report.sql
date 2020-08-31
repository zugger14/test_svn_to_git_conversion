/****** Object:  StoredProcedure [dbo].[spa_create_power_position_report]    Script Date: 11/06/2010 09:47:13 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_create_power_position_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_create_power_position_report]
/****** Object:  StoredProcedure [dbo].[spa_create_power_position_report]    Script Date: 11/06/2010 09:39:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_create_power_position_report]                   
	 @summary_option CHAR(1)=null,-- 's' Summary, 'd' Detail
	 @group_by CHAR(1)=null,-- 'l'->location 'i'->index 'n'->None
 	 @sub_entity_id VARCHAR(100),             		
	 @strategy_entity_id VARCHAR(100) = NULL,             
	 @book_entity_id VARCHAR(100) = NULL,         
	 @as_of_date DATETIME,
	 @term_start VARCHAR(100)=null,
	 @term_end VARCHAR(100)=null,
	 @granularity INT,	
	 @counterparty INT=NULL, 
	 @commodity INT=NULL,
	 @source_system_book_id1 INT=NULL, 
	 @source_system_book_id2 INT=NULL, 
	 @source_system_book_id3 INT=NULL, 
	 @source_system_book_id4 INT=NULL,
	 @source_deal_header_id VARCHAR(50)=null,
	 @deal_id VARCHAR(50)=null,
	 @hour_from INT=NULL,
	 @hour_to INT=NULL,
	 @location_id VARCHAR(100)=NULL,
	 @show_generation CHAR(1)='y',
	 @show_outage CHAR(1)='y',
	 @show_load CHAR(1)='y',
	 @show_bilateral CHAR(1)='y',
	 @process_table VARCHAR(100)=NULL, 	
	 @drill_index VARCHAR(100)=NULL,
	 @drill_term VARCHAR(100)=NULL,
	 @drill_hour VARCHAR(10)=NULL,
	 @batch_process_id VARCHAR(50)=NULL,
	 @batch_report_param VARCHAR(1000)=NULL 

 AS            


BEGIN            
SET NOCOUNT ON            
--         
--IF @summary_option='d'
--	SET @granularity=982
if @drill_index=''
	set @drill_index=NULL
IF @drill_hour=''
	SET @drill_hour=NULL
--***********************************************      
-- testing
/*
DECLARE @sub_entity_id varchar(100), @strategy_entity_id varchar(100),@book_entity_id varchar(100),
@generator_id int,@technology int,@buy_sell_flag varchar(1),             
@generation_state int,@as_of_date datetime,@term_start datetime,@term_end datetime

DROP TABLE #ssbm
DROP TABLE #temp
*/            
	Declare @Sql_Select varchar(MAX)            
	Declare @Sql_Where varchar(8000)            
	DECLARE @convert_uom_id int             
	DECLARE @report_type int 
	DECLARE @storage_inventory_sub_type_id INT
	DECLARE @process_id VARCHAR(50)
	DECLARE @user_login_id VARCHAR(50)
	DECLARE @sel_sql VARCHAR(200)
	DECLARE @group_sql VARCHAR(200)
	DECLARE @round_value VARCHAR(10)
	DECLARE @str_batch_table varchar(max)        
	DECLARE @term_start_new DATETIME
	DECLARE @source_deal_detail_id INT
	DECLARE @hr_count INT
	DECLARE @source_generator_id INT
	DECLARE @block_group INT

	
	SET @block_group=-1
	SET @round_value='2'
	SET @user_login_id=dbo.FNADBUser()
	SET @process_id=REPLACE(newid(),'-','_')	

	SET @str_batch_table=''        
       
	IF @batch_process_id is not null  
		BEGIN      
			SELECT @str_batch_table=dbo.FNABatchProcess('s',@batch_process_id,@batch_report_param,NULL,NULL,NULL)   
			SET @str_batch_table = @str_batch_table
		END

	IF @term_start IS NULL AND @term_end IS NOT NULL
		SET @term_start=@term_end
	IF @term_start IS NOT NULL AND @term_end IS NULL
		SET @term_end=@term_start


	IF @process_table IS NOT NULL
		SET @process_table=' INTO '+@process_table
	ELSE
		SET @process_table=''




--******************************************************            
--CREATE source book map table and build index            
--*********************************************************            
	SET @sql_Where = ''            
        
----------------------------------            
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

      
    EXEC ( @Sql_Select)

--------------------------------------------------------------            

            
--******************************************************            
--End of source book map table and build index            
--*********************************************************          
create table #temp_deal(
	fas_book_id int,
	source_deal_header_id int,
	source_deal_detail_id int,
	deal_date datetime,
	volume float,
	UOM varchar(100) COLLATE DATABASE_DEFAULT,
	state_id int,
	state varchar(100) COLLATE DATABASE_DEFAULT,
	generator_id int,
	generator varchar(100) COLLATE DATABASE_DEFAULT,
	technology varchar(100) COLLATE DATABASE_DEFAULT,
	buy_sell_flag char(1) COLLATE DATABASE_DEFAULT,
	counterparty_id int,
	counterparty_name varchar(100) COLLATE DATABASE_DEFAULT,
	term_start datetime,
	term_end datetime,
	curve_id INT,
	curve_name VARCHAR(100) COLLATE DATABASE_DEFAULT,
	location_id INT,
	location_name VARCHAR(100) COLLATE DATABASE_DEFAULT,
	deal_frequency CHAR(1) COLLATE DATABASE_DEFAULT,
	block_type INT,
	block_definition_id INT,
	volume_mult INT,
	Frequency VARCHAR(20) COLLATE DATABASE_DEFAULT	
)



-- ###################### Fisrt get all the deals (bilateral contracts)

SET @Sql_Select=
	' 
		insert into #temp_deal 
		 SELECT  
			 ssbm.fas_book_id,        
			 sdh.source_deal_header_id,             
			 sdd.source_deal_detail_id,           
			 sdh.deal_date,              
			 sdd.deal_volume, 
			 suom.uom_name, 
			 state.value_id state_id,                   
			 state.code State,     
			 sdh.generator_id,            	
			 rg.code Generator,            
			 tech.code Technology,            
			 sdd.buy_sell_flag,            
			 sdh.counterparty_id,            
			 sc.counterparty_name,            
			 sdd.term_start term_start,
			 sdd.term_end,
			 sdd.curve_id,
			 spcd.curve_name,
			 sdd.location_id,
			 sml.location_name	,
			 sdd.deal_volume_frequency,
			 sdh.block_type,
			 sdh.block_define_id,
			 CASE WHEN sdd.deal_volume_frequency=''h'' AND '+CAST(@granularity AS VARCHAR)+'=982 THEN 1 
				  WHEN sdd.deal_volume_frequency=''h'' AND '+CAST(@granularity AS VARCHAR)+'=989 THEN 2
 				  WHEN sdd.deal_volume_frequency=''h'' AND '+CAST(@granularity AS VARCHAR)+'=987 THEN 4
				  WHEN '+CAST(@granularity AS VARCHAR)+'=982 THEN (DATEDIFF(day,sdd.term_start,sdd.term_end)+1)*24	
				  WHEN '+CAST(@granularity AS VARCHAR)+'=989 THEN (DATEDIFF(day,sdd.term_start,sdd.term_end)+1)*48
				  WHEN '+CAST(@granularity AS VARCHAR)+'=987 THEN (DATEDIFF(day,sdd.term_start,sdd.term_end)+1)*96
				  ELSE (DATEDIFF(day,sdd.term_start,sdd.term_end)+1) END AS volume_mult,
			 CASE WHEN sdd.deal_volume_frequency=''m'' THEN ''Monthly'' 
				  WHEN sdd.deal_volume_frequency=''a'' THEN ''Annually'' 
				  WHEN sdd.deal_volume_frequency=''d'' THEN ''Daily'' 
				  WHEN sdd.deal_volume_frequency=''s'' THEN ''Semi-Annually'' 
				  WHEN sdd.deal_volume_frequency=''q'' THEN ''Quarterly'' 
				  WHEN sdd.deal_volume_frequency=''h'' AND DATEDIFF(day,term_start,term_end)<=0   THEN ''Daily''
				  WHEN sdd.deal_volume_frequency=''h'' AND DATEDIFF(day,term_start,term_end)>1    THEN ''Monthly''
			 END AS Frequency	
		FROM            
			Source_deal_header sdh	
			INNER JOIN source_system_book_map ssbm ON sdh.source_system_book_id1=ssbm.source_system_book_id1     		                        
				AND sdh.source_system_book_id2=ssbm.source_system_book_id2                             
				AND sdh.source_system_book_id3=ssbm.source_system_book_id3                             
				AND sdh.source_system_book_id4=ssbm.source_system_book_id4                             
			INNER JOIN #books b ON ssbm.fas_book_id = b.fas_book_id 
			INNER JOIN source_deal_detail sdd on sdd.source_deal_header_id=sdh.source_deal_header_id
			LEFT OUTER JOIN rec_generator rg on rg.generator_id = sdh.generator_id 
			LEFT OUTER JOIN static_data_value state on state.value_id =rg.gen_state_value_id         
			LEFT OUTER JOIN static_data_value tech on tech.value_id = rg.technology                         
			LEFT OUTER JOIN source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id               
			LEFT OUTER JOIN source_uom suom on suom.source_uom_id = sdd.deal_volume_uom_id  
			LEFT OUTER JOIN source_price_curve_def spcd on spcd.source_curve_def_id = sdd.curve_id    
			LEFT OUTER JOIN source_minor_location sml on sml.source_minor_location_id = sdd.location_id
			LEFT OUTER JOIN source_deal_header_template sdht ON sdht.template_id=sdh.template_id
			LEFT OUTER JOIN source_deal_detail_template sddt ON sdht.template_id=sddt.template_id and sdd.leg=sddt.leg

			           	
		where 1=1         
			 AND ISNULL(sdd.deal_volume,0)<>0   
			 AND(sdh.status_value_id IS NULL or sdh.status_value_id not in(5170, 5179))
			 AND (ssbm.fas_deal_type_value_id in( 400,407))' 
			+ CASE WHEN @term_start IS NOT NULL THEN  ' AND (sdd.term_start between CONVERT(DATETIME, ''' + @term_start + ''', 102) AND              
											CONVERT(DATETIME, ''' + @term_end + ''', 102)) ' ELSE '' END	
			+ CASE WHEN @as_of_date IS NOT NULL THEN ' AND sdh.deal_date<='''+CAST(@as_of_date AS VARCHAR)+'''' ELSE '' END
			+ CASE WHEN  @source_system_book_id1 IS NOT NULL AND @source_system_book_id1>0 THEN ' AND (sdh.source_system_book_id1 IN (' + cast(@source_system_book_id1 as VARCHAR)+ ')) ' ELSE '' END
			+ CASE WHEN  @source_system_book_id2 IS NOT NULL AND @source_system_book_id2>0  THEN ' AND (sdh.source_system_book_id2 IN (' + cast(@source_system_book_id2 as VARCHAR)+ ')) ' ELSE '' END
			+ CASE WHEN  @source_system_book_id3 IS NOT NULL AND @source_system_book_id3>0  THEN ' AND (sdh.source_system_book_id3 IN (' + cast(@source_system_book_id3 as VARCHAR)+ ')) ' ELSE '' END
			+ CASE WHEN  @source_system_book_id4 IS NOT NULL AND @source_system_book_id4>0  THEN ' AND (sdh.source_system_book_id4 IN (' + cast(@source_system_book_id4 as VARCHAR)+ ')) ' ELSE '' END
			+ CASE WHEN  @source_deal_header_id IS NOT NULL THEN ' AND (sdh.source_deal_header_id IN (' + cast(@source_deal_header_id as VARCHAR) + ')) '  ELSE '' END
			+ CASE WHEN  @deal_id IS NOT NULL THEN 	' AND sdh.deal_id = ''' + cast(@deal_id as VARCHAR) + ''''  ELSE '' END
			+CASE WHEN @location_id IS NOT NULL THEN ' AND sdd.location_id IN('+@location_id+')' ELSE '' END
			+CASE WHEN @commodity IS NOT NULL THEN ' AND sddt.commodity_id ='+CAST(@commodity AS VARCHAR) ELSE '' END

			--+ CASE WHEN  @drill_index IS NOT NULL   THEN CASE WHEN @group_by='l' THEN ' AND sml.location_name='''+@drill_index+'''' ELSE ' AND spcd.curve_name='''+@drill_index+'''' END ELSE '' END
			--+ CASE WHEN @drill_term IS NOT NULL THEN ' AND sdd.term_start=dbo.fnagetcontractmonth('''+@drill_term+''')' ELSE '' END
			--+' AND sdd.contract_expiration_date>'''+CAST(@as_of_date AS VARCHAR)+''''

	EXEC spa_print @sql_select 
	exec(@sql_select)


---########## If the deals are saved in the hourly format then get the data from horuly tables

	CREATE TABLE #temp_deal_hour(
		source_deal_detail_id INT,
		deal_date datetime,
		deal_hour INT,
		deal_volume FLOAT,
		weekdays INT,
	)
		
	INSERT INTO #temp_deal_hour(source_deal_detail_id,deal_date,deal_hour,deal_volume,weekdays)
	SELECT source_deal_detail_id,prod_date,CAST(REPLACE(Hr,'hr','') AS INT),volume,DATEPART(dw,prod_date) FROM
	(SELECT 
		mv.source_deal_header_id source_deal_detail_id,mv.prod_date,CASE WHEN buy_sell_flag='b' THEN 1 ELSE -1 END*sdd.volume volume,
			CASE WHEN buy_sell_flag='b' THEN 1 ELSE -1 END * mv.hr1 hr1,
			CASE WHEN buy_sell_flag='b' THEN 1 ELSE -1 END *mv.hr2 hr2,
			CASE WHEN buy_sell_flag='b' THEN 1 ELSE -1 END *mv.hr3 hr3,
			CASE WHEN buy_sell_flag='b' THEN 1 ELSE -1 END *mv.hr4 hr4,
			CASE WHEN buy_sell_flag='b' THEN 1 ELSE -1 END *mv.hr5 hr5,
			CASE WHEN buy_sell_flag='b' THEN 1 ELSE -1 END *mv.hr6 hr6,
			CASE WHEN buy_sell_flag='b' THEN 1 ELSE -1 END *mv.hr7 hr7,
			CASE WHEN buy_sell_flag='b' THEN 1 ELSE -1 END *mv.hr8 hr8,
			CASE WHEN buy_sell_flag='b' THEN 1 ELSE -1 END *mv.hr9 hr9,
			CASE WHEN buy_sell_flag='b' THEN 1 ELSE -1 END *mv.hr10 hr10,
			CASE WHEN buy_sell_flag='b' THEN 1 ELSE -1 END *mv.hr11 hr11,
			CASE WHEN buy_sell_flag='b' THEN 1 ELSE -1 END *mv.hr12 hr12,
			CASE WHEN buy_sell_flag='b' THEN 1 ELSE -1 END *mv.hr13 hr13,
			CASE WHEN buy_sell_flag='b' THEN 1 ELSE -1 END *mv.hr14 hr14,
			CASE WHEN buy_sell_flag='b' THEN 1 ELSE -1 END *mv.hr15 hr15,
			CASE WHEN buy_sell_flag='b' THEN 1 ELSE -1 END *mv.hr16 hr16,
			CASE WHEN buy_sell_flag='b' THEN 1 ELSE -1 END *mv.hr17 hr17,
			CASE WHEN buy_sell_flag='b' THEN 1 ELSE -1 END *mv.hr18 hr18,
			CASE WHEN buy_sell_flag='b' THEN 1 ELSE -1 END *mv.hr19 hr19,
			CASE WHEN buy_sell_flag='b' THEN 1 ELSE -1 END *mv.hr20 hr20,
			CASE WHEN buy_sell_flag='b' THEN 1 ELSE -1 END *mv.hr21 hr21,
			CASE WHEN buy_sell_flag='b' THEN 1 ELSE -1 END *mv.hr22 hr22,
			CASE WHEN buy_sell_flag='b' THEN 1 ELSE -1 END *mv.hr23 hr23,
			CASE WHEN buy_sell_flag='b' THEN 1 ELSE -1 END *mv.hr24 hr24
		FROM mv90_data_hour mv JOIN #temp_deal sdd 
				ON sdd.source_deal_detail_id=mv.source_deal_header_id
		where mv.prod_date between @term_start and @term_end
			)p
	UNPIVOT
		(deal_volume FOR Hr IN(hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24)
	) AS Unpvt
		

---#### break down deals into hourly
----###### CREATE Temporary tables to insert each day in that term
	--DECLARE @source_deal_detail_id INT
	DECLARE @term_s VARCHAR(20),@term_e VARCHAR(20)
	CREATE TABLE #temp_day(source_deal_detail_id INT,term_date DATETIME,no_of_days INT,weekdays INT)

	CREATE  INDEX [IX_td1] ON [#temp_day]([term_date])            
	
	DECLARE cur1 CURSOR FOR
		SELECT DISTINCT source_deal_detail_id,term_start,term_end FROM #temp_deal --WHERE  DATEDIFF(day,term_start,term_end)<>0
		OPEN cur1
		FETCH NEXT FROM cur1 INTO @source_deal_detail_id,@term_s,@term_e
		WHILE @@FETCH_STATUS=0
			BEGIN
				SET @term_start_new=@term_s
				WHILE @term_start_new<=@term_e
					BEGIN
						INSERT INTO #temp_day(source_deal_detail_id,term_date,no_of_days,weekdays)
						SELECT @source_deal_detail_id,@term_start_new,DATEDIFF(day,@term_s,@term_e)+1,DATEPART(dw,@term_start_new)
						
						SET @term_start_new=DATEADD(day,1,@term_start_new)	
					END
			FETCH NEXT FROM cur1 INTO @source_deal_detail_id,@term_s,@term_e
			END
		CLOSE cur1
		DEALLOCATE cur1


---#########################
				SET @Sql_Select='
						INSERT INTO #temp_deal_hour(source_deal_detail_id,deal_date,deal_hour,deal_volume,weekdays)
						SELECT source_deal_detail_id,[Term],CAST(REPLACE(Hr,''hr'','''') AS INT),deal_volume,DATEPART(dw,[Term]) FROM
						(SELECT 
							tmp.source_deal_detail_id source_deal_detail_id
							,dbo.FNAdateformat(td.term_date) [Term]
							,ROUND(CASE WHEN  MAX(hb.onpeak_offpeak)=''o''  THEN CASE WHEN MAX(dst.insert_delete)=''d'' AND MAX(ISNULL(hb.dst_applies,''n''))=''y'' THEN -1*SUM(volume) WHEN MAX(dst.insert_delete)=''i'' AND MAX(ISNULL(hb.dst_applies,''n''))=''y''  THEN 1*SUM(Volume) ELSE 0 END ELSE 0 END,'+@round_value+')+ 
							ROUND(SUM(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr1),0) END *(volume)),'+@round_value+') AS Hr1,
							ROUND(SUM(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr2),0) END*(volume)),'+@round_value+') AS Hr2,
							ROUND(SUM(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr3),0) END*(volume)),'+@round_value+') AS Hr3,
							ROUND(SUM(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr4),0) END*(volume)),'+@round_value+') AS Hr4,
							ROUND(SUM(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr5),0) END*(volume)),'+@round_value+') AS Hr5,
							ROUND(SUM(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr6),0) END*(volume)),'+@round_value+') AS Hr6,
							ROUND(SUM(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr7),0) END*(volume)),'+@round_value+') AS Hr7,
							ROUND(SUM(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr8),0) END*(volume)),'+@round_value+') AS Hr8,
							ROUND(SUM(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr9),0) END*(volume)),'+@round_value+') AS Hr9,
							ROUND(SUM(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr10),0) END*(volume)),'+@round_value+') AS Hr10,
							ROUND(SUM(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr11),0) END*(volume)),'+@round_value+') AS Hr11,
							ROUND(SUM(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr12),0) END*(volume)),'+@round_value+') AS Hr12,
							ROUND(SUM(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr13),0) END*(volume)),'+@round_value+') AS Hr13,
							ROUND(SUM(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr14),0) END*(volume)),'+@round_value+') AS Hr14,
							ROUND(SUM(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr15),0) END*(volume)),'+@round_value+') AS Hr15,
							ROUND(SUM(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr16),0) END*(volume)),'+@round_value+') AS Hr16,
							ROUND(SUM(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr17),0) END*(volume)),'+@round_value+') AS Hr17,
							ROUND(SUM(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr18),0) END*(volume)),'+@round_value+') AS Hr18,
							ROUND(SUM(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr19),0) END*(volume)),'+@round_value+') AS Hr19,
							ROUND(SUM(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr20),0) END*(volume)),'+@round_value+') AS Hr20,
							ROUND(SUM(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr21),0) END*(volume)),'+@round_value+') AS Hr21,
							ROUND(SUM(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr22),0) END*(volume)),'+@round_value+') AS Hr22,
							ROUND(SUM(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr23),0) END*(volume)),'+@round_value+') AS Hr23,
							ROUND(SUM(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr24),0) END*(volume)),'+@round_value+') AS Hr24,
							MAX(UOM) AS [UOM]'
							+CASE WHEN @summary_option IN('s','a') THEN ',MAX(Frequency) AS [Frequency],MAX(no_of_days*24) Volume_Mult' ELSE '' END
					+ (CASE WHEN @summary_option = 'd' THEN @str_batch_table ELSE '' END)+ '
					FROM
						#temp_deal tmp
						LEFT JOIN #temp_day td ON td.source_deal_detail_id=tmp.source_deal_detail_id
						LEFT JOIN block_type_group btg ON btg.block_type_group_id=('+CAST(@block_group AS VARCHAR(MAX))+')
						LEFT JOIN hourly_block hb on hb.block_value_id=ISNULL(btg.hourly_block_id,tmp.block_definition_id)
							and hb.week_day=ISNULL(td.weekdays,DATEPART(dw,tmp.term_start))
							AND  hb.onpeak_offpeak= case when ISNULL(btg.block_type_id,tmp.block_type)=12000 THEN ''p''
												when ISNULL(btg.block_type_id,tmp.block_type)=12001 THEN ''o''
								END
						LEFT JOIN mv90_DST dst on dst.[date]=td.term_date
						LEFT JOIN holiday_group hg ON hg.hol_group_value_Id=hb.holiday_value_id
							 AND ((tmp.term_start=hg.hol_date AND td.term_date IS NULL) OR (td.term_date=hg.hol_date))

					WHERE 1=1 '
					+ CASE WHEN @drill_index IS NOT NULL AND @group_by='i' THEN ' AND '+@group_sql+'='''+@drill_index+'''' ELSE '' END
					+ CASE WHEN @term_start IS NOT NULL THEN  ' AND (td.term_date between CONVERT(DATETIME, ''' + @term_start + ''', 102) AND              
												CONVERT(DATETIME, ''' + @term_end + ''', 102)) ' ELSE '' END	
					+ CASE WHEN @drill_term IS NOT NULL  THEN ' AND td.term_date='''+@drill_term+'''' ELSE '' END
					+'GROUP BY 
						tmp.source_deal_detail_id
						,td.term_date
					)p
						UNPIVOT
							(deal_volume FOR Hr IN(hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24)
						) AS Unpvt'	

				EXEC spa_print @Sql_Select
				EXEC(@Sql_Select)





---##########################


----################## Get the Load Forecast Data
	CREATE TABLE #load_forecast(
		location_id INT,
		load_forecast_date DATETIME,
		load_forecast_hour INT,
		load_forecast_volume FLOAT
	)

	SET @Sql_Select=
		' INSERT INTO #load_forecast(location_id,load_forecast_date,load_forecast_hour,load_forecast_volume)
	      SELECT 
				location_id,forecast_date,forecast_hour,volume	
		  FROM
				Power_load_forecast
		  WHERE 1=1 '
			+ CASE WHEN @term_start IS NOT NULL THEN  ' AND (forecast_date between CONVERT(DATETIME, ''' + @term_start + ''', 102) AND              
											CONVERT(DATETIME, ''' + @term_end + ''', 102)) ' ELSE '' END	
		  								
			+CASE WHEN @location_id IS NOT NULL THEN ' AND location_id IN('+@location_id+')' ELSE '' END 
			+CASE WHEN @hour_from IS NOT NULL THEN ' AND forecast_hour+1>='+CAST(@hour_from AS VARCHAR) ELSE '' END
			+CASE WHEN @hour_to IS NOT NULL THEN ' AND forecast_hour+1<='+CAST(@hour_to AS VARCHAR) ELSE '' END
		EXEC spa_print @Sql_Select
		EXEC(@Sql_Select)


-------####### Get the Generation Data
	CREATE table #temp_generation(
		location_id INT,
		location_name VARCHAR(100) COLLATE DATABASE_DEFAULT,
		source_generator_id INT,
		source_generator_name VARCHAR(100) COLLATE DATABASE_DEFAULT,
		volume FLOAT,
		UOM VARCHAR(20) COLLATE DATABASE_DEFAULT,
		VolumeFrequency VARCHAR(20) COLLATE DATABASE_DEFAULT,
		term_start DATETIME,
		term_end DATETIME
	)


	CREATE  INDEX [IX_location_id] ON [#temp_generation]([location_id])                  
	CREATE  INDEX [IX_source_generator_id] ON [#temp_generation]([source_generator_id])                  
	CREATE  INDEX [IX_term_start] ON [#temp_generation]([term_start])                  
              

	SET @Sql_Select=
		' 
			INSERT INTO #temp_generation(location_id,location_name,source_generator_id,source_generator_name,volume,UOM,VolumeFrequency,term_start,term_end)
			SELECT
				sml.source_minor_location_id,
				sml.location_name,
				sg.source_generator_id,
				sg.generator_name,
				sg.generator_capacity,
				su.uom_name,
				''Hourly'' AS VolumeFrequency,
				'''+CAST(@term_start AS VARCHAR)+'''  term_start,
				'''+CAST(@term_end AS VARCHAR)+''' term_end
				
			FROM
				source_generator sg
				INNER JOIN #books b ON sg.book_id = b.fas_book_id 
				INNER JOIN source_minor_location sml on sml.source_minor_location_id=sg.location_id
				INNER JOIN source_uom su on su.source_uom_id=sg.uom_id 
			WHERE 1=1'+
			+ CASE WHEN @as_of_date IS NOT NULL THEN ' AND  sg.generator_start_date <='''+CAST(@as_of_date AS VARCHAR)+'''' ELSE '' END
			+ CASE WHEN @term_start IS NOT NULL THEN  ' AND (CONVERT(DATETIME, ''' + @term_start + ''', 102)>=sg.generator_start_date AND              
											CONVERT(DATETIME, ''' + @term_end + ''', 102)<=ISNULL(sg.generation_end_date,''9999-01-01'')) ' ELSE '' END	
						
	--print @Sql_Select
	EXEC(@Sql_Select)	


---################### Now get volume from the outage schedule
	CREATE TABLE #temp_outage(
		source_generator_id INT,
		location_id INT,	
		outage_date DATETIME,
		outage_min INT,
		outage FLOAT
	)

	CREATE  INDEX [IX_source_generator_id] ON [#temp_outage](source_generator_id)                  
	CREATE  INDEX [IX_outage_date] ON [#temp_outage](outage_date)                  

	SET @Sql_Select=
		' 
		INSERT INTO #temp_outage
		SELECT 
			po.source_generator_id,
			tg.location_id,
			CONVERT(VARCHAR(10),pod.outage_date,120)'
			      	
			+CASE WHEN @granularity IN(980,981,982) THEN ' ,(pod.outage_min/60)*60'
				   WHEN @granularity=989 THEN ' ,(pod.outage_min/30)*30'
				   WHEN @granularity=987 THEN ' ,(pod.outage_min)'
				   ELSE ',0'
				END	+
		 ',MAX(outage)	
		 FROM
			power_outage po
			JOIN #temp_generation tg on po.source_generator_id=tg.source_generator_id	
			JOIN power_outage_detail pod ON pod.power_outage_id=po.power_outage_id
			
		WHERE 1=1
		'
		+ CASE WHEN @term_start IS NOT NULL THEN  
				' AND (ISNULL(po.actual_start,po.planned_start)>=CONVERT(DATETIME, ''' + @term_start + ''', 102) AND              
				 ISNULL(po.actual_end,po.planned_end)<=CONVERT(DATETIME, ''' + @term_end + ' 23:59:00'', 102)) ' ELSE '' END	
		+ ' Group BY po.source_generator_id,tg.location_id,
			 pod.outage_date'
			      	
			+CASE WHEN @granularity IN(980,981,982) THEN ' ,(pod.outage_min/60)*60'
				   WHEN @granularity=989 THEN ' ,(pod.outage_min/30)*30'
				   WHEN @granularity=987 THEN ' ,(pod.outage_min)'
				   ELSE ''
				END	

	EXEC spa_print @Sql_Select
	EXEC(@Sql_Select)



-------- Break the outage volume according to granularity


--------############# Break the generation volume according to frequency

	Create TABLE #gen_volume_frequency(
			source_generator_id INT,
			term_start DATETIME,
			term_end DATETIME,
			term_hour INT
		)

	CREATE  INDEX [IX_source_generator_id] ON [#gen_volume_frequency](source_generator_id)                  
	CREATE  INDEX [IX_term_start] ON [#gen_volume_frequency](term_start)                  


	DECLARE cur_gen CURSOR FOR
		SELECT DISTINCT source_generator_id,term_start,term_end FROM #temp_generation
		OPEN cur_gen
		FETCH NEXT FROM cur_gen INTO @source_generator_id,@term_start,@term_end
		WHILE @@FETCH_STATUS=0
			BEGIN
				SET @term_start_new=@term_start
				WHILE @term_start_new<=@term_end
					BEGIN
						SET @hr_count=0
						IF @granularity in(982,989,987,980)
						BEGIN
							WHILE @hr_count<1440
							BEGIN	
								INSERT INTO #gen_volume_frequency(source_generator_id,term_start,term_end,term_hour)
								SELECT @source_generator_id,@term_start_new,
										CASE WHEN @granularity IN(991,992,993) THEN DATEADD(MONTH,1,@term_start_new)-1 ELSE @term_start_new END,
										@hr_count
								
								SET @hr_count=@hr_count+CASE @granularity WHEN 982 THEN 60 
																		  WHEN 980 THEN 60	
																		  WHEN 989 THEN 30 WHEN 987 THEN 15 END
							END
						END
						ELSE
								INSERT INTO #gen_volume_frequency(source_generator_id,term_start,term_end,term_hour)
								SELECT @source_generator_id,@term_start_new,DATEADD(MONTH,1,@term_start_new)-1,0

						
						
						IF @granularity=980
							SET @term_start_new=DATEADD(DAY,1,@term_start_new)	
						ELSE IF @granularity=991
							SET @term_start_new=DATEADD(MONTH,3,@term_start_new)	
						ELSE IF @granularity=992
							SET @term_start_new=DATEADD(MONTH,6,@term_start_new)	
						ELSE IF @granularity=993
							SET @term_start_new=DATEADD(YEAR,1,@term_start_new)	
						ELSE 
							SET @term_start_new=DATEADD(DAY,1,@term_start_new)	

					

			END
		FETCH NEXT FROM cur_gen INTO @source_generator_id,@term_start,@term_end
		END
	CLOSE cur_gen
	DEALLOCATE cur_gen	
		



----######################
	CREATE TABLE #temp_final(
			location_id INT,
			location VARCHAR(100) COLLATE DATABASE_DEFAULT,	
			term DATETIME,
			term_hour INT,
			volume FLOAT,
			UOM VARCHAR(20) COLLATE DATABASE_DEFAULT
		)	


	SET @Sql_Select=
			' 
		INSERT INTO #temp_final
		SELECT 
				tg.location_id,
				tg.location_name,
				gvf.term_start,
				gvf.term_hour,
				tg.volume,
				tg.UOM
		FROM
			#temp_generation tg	
			LEFT JOIN #gen_volume_frequency gvf on tg.source_generator_id=gvf.source_generator_id
--			LEFT JOIN #temp_outage tout on tout.source_generator_id=tg.source_generator_id
--				AND tout.outage_date=gvf.term_start and tout.outage_min=gvf.term_hour
		WHERE 1=1
			  

'
	EXEC(@Sql_Select)


----###### CREATE Temporary tables to insert each day in that term
	
--	CREATE TABLE #temp_day(source_deal_detail_id INT,term_date DATETIME,no_of_days INT,weekdays INT)
--
--	CREATE  INDEX [IX_td1] ON [#temp_day]([term_date])            
--	
--	DECLARE cur1 CURSOR FOR
--		SELECT DISTINCT source_deal_detail_id,term_start,term_end FROM #temp_deal --WHERE  DATEDIFF(day,term_start,term_end)<>0
--		OPEN cur1
--		FETCH NEXT FROM cur1 INTO @source_deal_detail_id,@term_start,@term_end
--		WHILE @@FETCH_STATUS=0
--			BEGIN
--				SET @term_start_new=@term_start
--				WHILE @term_start_new<=@term_end
--					BEGIN
--						INSERT INTO #temp_day(source_deal_detail_id,term_date,no_of_days,weekdays)
--						SELECT @source_deal_detail_id,@term_start_new,DATEDIFF(day,@term_start,@term_end)+1,DATEPART(dw,@term_start_new)
--						
--						SET @term_start_new=DATEADD(day,1,@term_start_new)	
--					END
--			FETCH NEXT FROM cur1 INTO @source_deal_detail_id,@term_start,@term_end
--			END
--		CLOSE cur1
--		DEALLOCATE cur1
	
--delete from #temp_final where dbo.fnagetcontractmonth(term)<>'2009-05-01' and location_id<>24
-------#############################	
	-- Create select and group by sql based on criteria Index and Location


	SELECT @sel_sql = CASE @group_by WHEN 'i' THEN ' curve_name AS [Index],' WHEN 'l' THEN ' location_name AS [Location],' ELSE ' NULL AS [Location],' END
	SELECT @group_sql = CASE @group_by WHEN 'i' THEN ' curve_name,' WHEN 'l' THEN 'location_name,' ELSE ' ' END

		--IF @summary_option='s'
		--IF @granularity=982 -- hourly
			BEGIN

			DECLARE @location_value AS VARCHAR(100)
			SELECT @location_value = item  FROM [dbo].[SplitCommaSeperatedValues](@group_sql)
			exec spa_print @location_value
			IF @location_value = 'curve_name' 
				SET @location_value = '[Index]'
			ELSE 
				SET @location_value = '[Location]'

			SET @Sql_Select='
				'+CASE WHEN @summary_option='s' THEN 
				' SELECT 
					ISNULL(b.[Location],a.'+@location_value+') [Location],'+
					CASE WHEN (@granularity=982 ) THEN 'dbo.fnadateformat(ISNULL(b.[Term],a.[term]))' ELSE 'dbo.fnadateformat(dbo.FNATermGrouping_Month(ISNULL(b.[Term],a.[term]),'+CAST(@granularity AS VARCHAR)+'))' END +' AS [Term],'+
					CASE WHEN @granularity=982 THEN 'ISNULL(b.term_hour,a.[Hours])/60+1' ELSE '''''' END +' [Hour],	
					SUM('+CASE WHEN @show_bilateral='y' THEN 'ISNULL(a.[volume],0)' ELSE '0' END+'
					+'+CASE WHEN @show_generation='y' THEN 'ISNULL(b.volume,0)' ELSE '0' END+'
					+'+CASE WHEN @show_outage='y' THEN '(-1*CASE WHEN tout.outage_date IS NOT NULL THEN tout.[outage] ELSE 0 END)' ELSE '0' END+'
					+ '+CASE WHEN @show_load='y' THEN '(-1*ISNULL(plf.volume,0))' ELSE '0' END+') [Volume],
					MAX(ISNULL(a.UOM,b.UOM))UOM '
				 ELSE
				' SELECT 
					ISNULL(b.[Location],a.'+@location_value+') [Location],'+
					CASE WHEN (@granularity=982 ) THEN 'dbo.fnadateformat(ISNULL(b.[Term],a.[term]))' ELSE 'dbo.fnadateformat(dbo.FNATermGrouping_Month(ISNULL(b.[Term],a.[term]),'+CAST(@granularity AS VARCHAR)+'))' END +' AS [Term],'+
					CASE WHEN @granularity=982 THEN 'ISNULL(b.term_hour,a.[Hours])/60+1' ELSE '''''' END +' [Hour],	
					'+CASE WHEN @show_generation='y' THEN ' SUM(ISNULL(b.[volume],0)) [GenerationVolume],' ELSE '' END+'
					'+CASE WHEN @show_outage='y' THEN ' -1*SUM(CASE WHEN tout.outage_date IS NOT NULL THEN tout.[outage] ELSE 0 END) [Outage],' ELSE '' END+'
					'+CASE WHEN @show_load='y' THEN ' -1*SUM(cast (plf.volume as float)) [Load Forecast],' ELSE '' END+'
					'+CASE WHEN @show_bilateral='y' THEN ' SUM(ISNULL(a.[volume],0)) [BilateralVolume],' ELSE '' END+'
					SUM('+CASE WHEN @show_bilateral='y' THEN 'ISNULL(a.[volume],0)' ELSE '0' END+'
					+'+CASE WHEN @show_generation='y' THEN 'ISNULL(b.volume,0)' ELSE '0' END+'
					+'+CASE WHEN @show_outage='y' THEN '(-1*CASE WHEN tout.outage_date IS NOT NULL THEN tout.[outage] ELSE 0 END)' ELSE '0' END+'
					+ '+CASE WHEN @show_load='y' THEN '(-1*ISNULL(plf.volume,0))' ELSE '0' END+') [Total Volume],
					MAX(ISNULL(a.UOM,b.UOM))UOM '
				 END +
				--CASE WHEN @process_table<>'' THEN ',MAX(ISNULL(b.[Location_id],a.'+@location_value+')) location_id' ELSE '' END+ 
				--@process_table+
				@str_batch_table + 
				' FROM 
					 #temp_final b 
					 RIGHT JOIN 
					(SELECT 
							'+@sel_sql+'
			   				(tdh.deal_date) [Term],
							location_id,		
							MAX(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE 1 END) *ROUND(SUM(tdh.deal_volume)/MAX(1),'+@round_value+') AS Volume,
							(deal_hour-1)'+CASE WHEN @granularity IN(980,981,982) THEN '*60' 
									WHEN @granularity=989 THEN '*30' 
									WHEN @granularity=987 THEN '*15' 
									ELSE '*0' END+' as [hours],
							MAX(UOM) AS [UOM]
					
					FROM
						#temp_deal tmp
						--LEFT JOIN #temp_day td ON td.source_deal_detail_id=tmp.source_deal_detail_id
						INNER JOIN #temp_deal_hour tdh on tdh.source_deal_detail_id=tmp.source_deal_detail_id
						LEFT JOIN hourly_block hb on hb.block_value_id=tmp.block_definition_id
							and hb.week_day=ISNULL(tdh.weekdays,DATEPART(dw,tmp.term_start))
							AND  hb.onpeak_offpeak= case when tmp.block_type=12000 THEN ''p''
												when tmp.block_type=12001 THEN ''o''
												when tmp.block_type=12002 THEN ''p'' 
								END
						LEFT JOIN mv90_DST dst on dst.[date]=tdh.deal_date
						LEFT JOIN holiday_group hg ON hg.hol_group_value_Id=hb.holiday_value_id
							 AND ((tmp.term_start=hg.hol_date AND tdh.deal_date IS NULL) OR (tdh.deal_date=hg.hol_date))
					where 1=1

					GROUP BY 
						'+@group_sql+
						'tdh.deal_date ,location_id,tdh.deal_hour
					)a
						ON 
						 b.[Term]=a.[Term]
						And b.[Term_hour]=a.[Hours]
					LEFT JOIN #temp_outage tout on tout.location_id=ISNULL(a.[Location_id],b.[Location_id])
							 AND tout.outage_date=ISNULL(b.[Term],a.[Term])
							 AND tout.outage_min=ISNULL(b.[Term_hour],a.[Hours])
					LEFT JOIN power_load_forecast plf on plf.location_id=ISNULL(a.[Location_id],b.[Location_id])
							AND plf.forecast_date=ISNULL(b.[Term],a.[Term])
							AND plf.forecast_hour=((ISNULL(b.term_hour,a.[Hours])/60)+1)
					WHERE 1=1 '
						+CASE WHEN @drill_hour IS NOT NULL AND @granularity=982 THEN +' AND ISNULL(b.term_hour,a.[Hours])/60+1='+@drill_hour ELSE '' END
						+CASE WHEN @drill_term IS NOT NULL THEN CASE WHEN @granularity=980 THEN ' AND dbo.FNAgetContractMonth(ISNULL(b.[Term],a.[term]))=dbo.FNAgetContractMonth('''+@drill_term+''')' ELSE' AND (ISNULL(b.[Term],a.[term]))='''+@drill_term+'''' END ELSE '' END+
						+CASE WHEN @drill_index IS NOT NULL THEN +' AND (ISNULL(b.[Location],a.'+@location_value+'))='''+@drill_index+'''' ELSE '' END+
						+CASE WHEN @hour_from IS NOT NULL THEN ' AND ISNULL(b.term_hour,a.[Hours])/60+1>='+CAST(@hour_from AS VARCHAR) ELSE '' END+
						+CASE WHEN @hour_to IS NOT NULL THEN ' AND ISNULL(b.term_hour,a.[Hours])/60+1<='+CAST(@hour_to AS VARCHAR) ELSE '' END+'
					GROUP BY
						ISNULL(b.[Location],a.'+@location_value+'),'+
						CASE WHEN (@granularity=982 ) THEN 'dbo.fnadateformat(ISNULL(b.[Term],a.[term]))' ELSE 'dbo.fnadateformat(dbo.FNATermGrouping_Month(ISNULL(b.[Term],a.[term]),'+CAST(@granularity AS VARCHAR)+'))' END+
						CASE WHEN (@granularity=982 ) THEN ',a.[Hours],b.term_hour	' ELSE '' END+
					' ORDER BY  ISNULL(b.[Location],a.'+@location_value+'),'+
					CASE WHEN (@granularity=982 ) THEN 'dbo.fnadateformat(ISNULL(b.[Term],a.[term]))' ELSE 'dbo.fnadateformat(dbo.FNATermGrouping_Month(ISNULL(b.[Term],a.[term]),'+CAST(@granularity AS VARCHAR)+'))' END+
					CASE WHEN (@granularity=982 ) THEN ',a.[Hours],b.term_hour	' ELSE '' END

				EXEC spa_print @Sql_Select
				EXEC(@Sql_Select)								
			END

--	ELSE IF @summary_option='s'
--	BEGIN
--
--		DECLARE @vol_frequency_table VARCHAR(100)
--		SET @vol_frequency_table=dbo.FNAProcessTableName('deal_volume_frequency_mult', @user_login_id, @process_id)
--		set @sql_Select='SELECT DISTINCT 
--						term_start, 
--						term_end,
--						deal_frequency AS deal_volume_frequency,
--						block_type,
--						block_definition_id
--				INTO '+@vol_frequency_table+'
--				FROM
--					#temp_deal	
--				WHERE 
--					deal_frequency IN(''d'',''h'')'
--		
--		EXEC(@sql_Select)
--
--		EXEC spa_get_dealvolume_mult_byfrequency @vol_frequency_table
--
-----------------------------
--
--		SET @Sql_Select='
--				SELECT '+
--					@sel_sql+
--					'dbo.FNAdateformat(tmp.term_start) [Term],
--					Frequency AS VolumeFrequency,
--					SUM(Volume*ISNULL(vft.Volume_Mult,1)) AS Volume,
--					MAX(UOM) AS UOM
--				'+@str_batch_table+'
--				FROM
--					#temp_deal tmp 		
--					LEFT JOIN '+@vol_frequency_table+' vft ON vft.term_start=tmp.term_start
--						AND vft.term_end=tmp.term_end 
--						AND vft.deal_volume_frequency=tmp.deal_frequency
--						AND ISNULL(vft.block_type,-1)=ISNULL(tmp.block_type,-1)
--						AND ISNULL(vft.block_definition_id,-1)=ISNULL(tmp.block_definition_id,-1)
--				GROUP BY '+	
--					@group_sql+				
--					'tmp.term_start,Frequency
--				ORDER BY '+		
--					@group_sql+			
--					'tmp.term_start
--				'
--		--print @sql_select 
--		EXEC(@Sql_Select)
--	END
/*
	ELSE IF @summary_option='d'
	BEGIN
		IF @granularity=982 -- hourly
			BEGIN
				SET @Sql_Select='SELECT 
							'+@sel_sql+'
			   				,dbo.FNAdateformat(td.term_date) [Term],
							MAX(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr1),0) END) *ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS Hr1,
							MAX(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr2),0) END)*ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS Hr2,
							MAX(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr3),0) END)*ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS Hr3,
							MAX(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr4),0) END)*ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS Hr4,
							MAX(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr5),0) END)*ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS Hr5,
							MAX(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr6),0) END)*ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS Hr6,
							MAX(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr7),0) END)*ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS Hr7,
							MAX(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr8),0) END)*ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS Hr8,
							MAX(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr9),0) END)*ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS Hr9,
							MAX(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr10),0) END)*ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS Hr10,
							MAX(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr11),0) END)*ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS Hr11,
							MAX(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr12),0) END)*ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS Hr12,
							MAX(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr13),0) END)*ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS Hr13,
							MAX(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr14),0) END)*ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS Hr14,
							MAX(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr15),0) END)*ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS Hr15,
							MAX(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr16),0) END)*ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS Hr16,
							MAX(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr17),0) END)*ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS Hr17,
							MAX(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr18),0) END)*ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS Hr18,
							MAX(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr19),0) END)*ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS Hr19,
							MAX(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr20),0) END)*ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS Hr20,
							MAX(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr21),0) END)*ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS Hr21,
							MAX(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr22),0) END)*ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS Hr22,
							MAX(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr23),0) END)*ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS Hr23,
							MAX(CASE WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''p'' THEN NULL WHEN hg.hol_date<>'''' AND hb.onpeak_offpeak=''o'' THEN 1 ELSE NULLIF((hb.hr24),0) END)*ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS Hr24,
							MAX(UOM) AS [UOM]
					'+@str_batch_table+'
					FROM
						#temp_deal tmp
						LEFT JOIN #temp_day td ON td.source_deal_detail_id=tmp.source_deal_detail_id
						LEFT JOIN hourly_block hb on hb.block_value_id=tmp.block_definition_id
							and hb.week_day=ISNULL(td.weekdays,DATEPART(dw,tmp.term_start))
							AND  hb.onpeak_offpeak= case when tmp.block_type=12000 THEN ''p''
												when tmp.block_type=12001 THEN ''o''
												when tmp.block_type=12002 THEN ''p'' 
								END
						LEFT JOIN mv90_DST dst on dst.[date]=td.term_date
						LEFT JOIN holiday_group hg ON hg.hol_group_value_Id=hb.holiday_value_id
							 AND ((tmp.term_start=hg.hol_date AND td.term_date IS NULL) OR (td.term_date=hg.hol_date))
						where 1=1
						--AND tmp.deal_volume_frequency IN(''d'',''h'')
					GROUP BY 
						'+@group_sql+
						'td.term_date	
					ORDER BY 
						'+@group_sql+'td.term_date '	
				EXEC(@Sql_Select)								
			END

	IF @granularity=989 -- 30 Mins
			BEGIN
				SET @Sql_Select='SELECT 
							'+@sel_sql+'
			   				,dbo.FNAdateformat(td.term_date) [Term],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr0:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr1:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr1:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr2:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr2:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr3:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr3:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr4:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr4:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr5:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr5:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr6:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr6:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr7:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr7:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr8:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr8:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr9:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr9:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr10:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr10:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr11:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr11:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr12:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr12:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr13:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr13:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr14:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr14:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr15:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr15:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr16:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr16:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr17:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr17:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr18:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr18:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr19:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr19:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr20:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr20:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr21:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr21:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr22:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr22:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr23:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr23:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr24:00],
							MAX(UOM) AS [UOM]
					'+@str_batch_table+'
					FROM
						#temp_deal tmp
						CROSS JOIN #temp_day td 
					GROUP BY 
						'+@group_sql+
						',td.term_date	
					ORDER BY 
						'+@group_sql+',td.term_date '	
				EXEC(@Sql_Select)								
			END

	IF @granularity=987 -- 15 Mins
			BEGIN
				SET @Sql_Select='SELECT 
							'+@sel_sql+'
			   				,dbo.FNAdateformat(td.term_date) [Term],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr0:15],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr0:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr0:45],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr1:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr1:15],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr1:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr1:45],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr2:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr2:15],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr2:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr2:45],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr3:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr3:15],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr3:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr3:45],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr4:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr4:15],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr4:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr4:45],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr5:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr5:15],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr5:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr5:45],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr6:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr6:15],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr6:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr6:45],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr7:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr7:15],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr7:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr7:45],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr8:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr8:15],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr8:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr8:45],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr9:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr9:15],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr9:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr9:45],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr10:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr10:15],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr10:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr10:45],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr11:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr11:15],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr11:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr11:45],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr12:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr12:15],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr12:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr12:45],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr13:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr13:15],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr13:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr13:45],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr14:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr14:15],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr14:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr14:45],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr15:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr15:15],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr15:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr15:45],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr16:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr16:15],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr16:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr16:45],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr17:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr17:15],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr17:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr17:45],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr18:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr18:15],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr18:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr18:45],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr19:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr19:15],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr19:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr19:45],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr20:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr20:15],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr20:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr20:45],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr21:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr21:15],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr21:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr21:45],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr22:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr22:15],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr22:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr22:45],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr23:00],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr23:15],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr23:30],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr23:45],
							ROUND(SUM(volume)/MAX(volume_mult),'+@round_value+') AS [Hr24:00],
							MAX(UOM) AS [UOM]
					'+@str_batch_table+'
					FROM
						#temp_deal tmp
						CROSS JOIN #temp_day td 
					GROUP BY 
						'+@group_sql+
						',td.term_date	
					ORDER BY 
						'+@group_sql+',td.term_date '	
				EXEC(@Sql_Select)								
			END

	END
*/
--if @summary_option='s'
--	BEGIN
--		set @sql_select= 'select  
--			curve_name [IndexName], Technology, dbo.fnagetcontractmonth(term_start) [Term],              
--			case when(buy_sell_flag = ''b'') then ''Buy'' else ''Sell'' end BuySell,               
--			dbo.FNAHyperLinkText(146, state, cast(State_id as varchar)) [Gen State],                             
--			sum(Volume) Volume,               
--			UOM
--		from 
--			#temp_deal
--		group by 
--			curve_name, Technology, dbo.fnagetcontractmonth(term_start), buy_sell_flag,State,state_id,UOM              
--			order by curve_name, Technology, dbo.fnagetcontractmonth(term_start), buy_sell_flag'       
--
--		--print @sql_select
--		exec (@sql_select)
--	END
--
--ELSE if @summary_option='h' 
--	BEGIN
--
--		SELECT 
--			mv.source_deal_header_id [DealId],dbo.fnadateformat(mv.prod_date)[Term],
--			mv.HR1,mv.HR2,mv.HR3,mv.HR4,mv.HR5,mv.HR6,mv.HR6,mv.HR7,mv.HR8,mv.HR9,mv.HR10,mv.HR11,mv.HR12,
--			mv.HR13,mv.HR14,mv.HR15,mv.HR16,mv.HR17,mv.HR18,mv.HR19,mv.HR20,mv.HR21,mv.HR22,mv.HR23,mv.HR24
--		FROM
--			#temp_deal tmp 
--			INNER JOIN source_deal_detail sdd on tmp.source_deal_header_id=sdd.source_deal_detail_id
--			INNER JOIN mv90_data_hour mv on mv.source_deal_header_id=sdd.source_deal_detail_id
--		WHERE 1=1
--			AND curve_name=@drill_counterparty
--			AND dbo.fnagetcontractmonth(mv.prod_date)=dbo.fnagetcontractmonth(@drill_deal_date)
--				
--
--	END
--
--
--
--ELSE if @summary_option='d'
--	BEGIN
--
--		select b.generator_id,a.recorderid,b.channel,prod_date,HR1,HR2,HR3,HR4,HR5,HR6,HR7,HR8,HR9,HR10,HR11,HR12
--					,HR13,HR14,HR15,HR16,HR17,HR18,HR19,HR20,HR21,HR22,HR23,HR24,proxy_date 
--		into 	
--			#temp_hour
--		from 		mv90_data_hour a inner join #temp_recorder b on 
--				b.recorderid=a.recorderid and b.channel=a.channel and 
--				b.from_date=dbo.fnagetcontractmonth(a.prod_date)
--				where data_missing='y'
--		SET @Sql_Select='
--			
--			select 	distinct
--				counterparty_name Counterparty,
--				dbo.FNADateFormat(prod_date) [Prod Date],b.channel,
--				HR1,HR2,HR3,HR4,HR5,HR6,HR7,HR8,HR9,HR10,HR11,HR12
--				,HR13,HR14,HR15,HR16,HR17,HR18,HR19,HR20,HR21,HR22,HR23,HR24,
--				dbo.FNADateFormat(proxy_date) [Date Used]		
--			from
--				#temp_deal a
--				join #temp_hour b on
--				a.generator_id=b.generator_id and a.term_start=dbo.fnagetcontractmonth(b.prod_date)
--			where 1=1 
--			'
--			+ case when (@drill_Counterparty is null) then '' else ' and counterparty_name  = ''' + @drill_Counterparty + '''' end   
--			+ case when (@drill_technology is null) then '' else ' and technology  = ''' + @drill_technology + '''' end   
--			+ case when (@drill_deal_date is null) then '' else ' and deal_date  = ''' + @drill_deal_date + '''' end   
--			+ case when (@drill_state is null) then '' else ' and state  = ''' + @drill_state + '''' end   
--			+ case when (@drill_buy_sell_flag is null) then '' else ' and case when buy_sell_flag=''b'' then ''buy'' else ''sell'' end = ''' + @drill_buy_sell_flag + ''''end       
--			+ ''
--			EXEC spa_print @Sql_Select
--			Exec(@Sql_Select)
--	END


--*****************FOR BATCH PROCESSING**********************************    
     
	IF  @batch_process_id is not null        
		BEGIN        
			 SELECT @str_batch_table=dbo.FNABatchProcess('u',@batch_process_id,@batch_report_param,GETDATE(),NULL,NULL)         
			 EXEC(@str_batch_table)        
			 declare @report_name VARCHAR(100)        

			 set @report_name='Run Power Position Report'        
			        
			 SELECT @str_batch_table=dbo.FNABatchProcess('c',@batch_process_id,@batch_report_param,GETDATE(),'spa_create_hourly_position_report',@report_name)         
			 EXEC(@str_batch_table)        
			        
		END        
--********************************************************************   


END







