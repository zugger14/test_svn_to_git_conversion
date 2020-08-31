/****** Object:  StoredProcedure [dbo].[spa_create_rec_compliance_report]    Script Date: 09/01/2009 01:14:48 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_create_rec_compliance_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_create_rec_compliance_report]
/****** Object:  StoredProcedure [dbo].[spa_create_rec_compliance_report]    Script Date: 09/01/2009 01:14:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spa_create_rec_compliance_report]        
  @sub_entity_id varchar(100),         
  @strategy_entity_id varchar(100) = NULL,         
  @book_entity_id varchar(100) = NULL,         
  @compliance_state int,        
  @compliance_year int,        
  @assignment_type_value_id int = 5146,        
  @convert_uom_id int,        
  @report_format int = 1 ,      
  @show_bonus int=1, -- 1 - with bonus 2- without bonus 3- only bonus       
  @month int=NULL,         
  @as_of_date DATETIME=NULL,	
  @drill_down_level int = 0,          
  @drill_value varchar(100) = null,  
  @drill_value1 varchar(100) = null,  	
  @batch_process_id varchar(50)=NULL,  
  @batch_report_param varchar(500)=NULL        
AS      
SET NOCOUNT ON  

  
-- beginning of test data        
-- exec spa_create_rec_compliance_report '137',NULL,NULL,5080,2006,5146,24,2,0,NULL,1  
-- DECLARE  @sub_entity_id varchar(100)        
-- DECLARE  @strategy_entity_id varchar(100)        
-- DECLARE  @book_entity_id varchar(100)        
-- DECLARE  @compliance_state int        
-- DECLARE  @compliance_year int        
-- DECLARE  @drill_down_level int        
-- declare  @assignment_type_value_id int      
-- DECLARE  @drill_value varchar(100)      
-- DECLARE  @convert_uom_id int      
-- DECLARE  @report_format int      
-- DECLARE @batch_process_id varchar(50)  
-- DECLARE @batch_report_param varchar(500)        
-- DECLARE @show_bonus int  
--   
-- set @convert_uom_id=24      
-- set @assignment_type_value_id=5146      
-- SET @sub_entity_id = '138'        
-- SET @strategy_entity_id  = null        
-- SET @book_entity_id = null        
-- SET @compliance_state = 5118        
-- SET @compliance_year  = 2003       
--  -- 5146 Compliance, 5148 CO2        
-- SET @drill_down_level = 11
-- SET @drill_value = 'Llano Estacado(texico)'
--         
-- set @report_format=1      
-- SET @show_bonus = 1  
--   
-- drop table #temp        
-- drop table #temp1        
-- drop table #ssbm          
-- drop table #bonus      
-- drop table #temp_duration      
-- ----drop table #temp_compliance      
-- drop table #assign      
--==========end of test data        
--*****************For batch processing********************************  
  
DECLARE @str_batch_table varchar(max)  
SET @str_batch_table=''  
IF @batch_process_id is not null  
 SELECT @str_batch_table=dbo.FNABatchProcess('s',@batch_process_id,@batch_report_param,NULL,NULL,NULL)   
--***********************************************  
    
DECLARE @pre_compliance_year int
DECLARE @compliance_type varchar(500) 
DECLARE @sql_stmt varchar(MAX)        
DECLARE @sql_stmt1 varchar(MAX)       

     
DECLARE @assignment_type int        
        
SET @assignment_type = @assignment_type_value_id        

SET @compliance_type = cast (@assignment_type_value_id as varchar)        
SET @pre_compliance_year = @compliance_year - 1        
        
	CREATE TABLE #temp (        
		 [type] [varchar] (50) COLLATE DATABASE_DEFAULT,        
		 [generator_id] [int],        
		 [name] [varchar] (250) COLLATE DATABASE_DEFAULT,        
		 [SourceDealId] [int] ,  
		 [Source_Deal_Detail_Id] [int] ,        
		 [RefDealId] [varchar] (50) COLLATE DATABASE_DEFAULT,    
		 [ext_deal_id] [int],        
		 [volume] [float],        
		 [bonus] [float],        
		 [assigned_state] [int] ,        
		 [assignment_type_value_id] [int] ,        
		 [gen_date] [datetime] ,        
		 [buy_sell_flag] [varchar] (1) COLLATE DATABASE_DEFAULT,        
		 [Expiration] [datetime],        
		 [deal_date] [datetime] ,        
		 [HE] [varchar] (100) COLLATE DATABASE_DEFAULT,        
		 [Counterparty] [varchar] (100) COLLATE DATABASE_DEFAULT,        
		 [int_ext_flag] [varchar] (1) COLLATE DATABASE_DEFAULT,        
		 [Settlement] [float],        
		 [compliance_year] [int],        
		 [curve_name] [varchar] (100) COLLATE DATABASE_DEFAULT,        
		 [assigned_date] [datetime] ,  
		 [total_volume] float,  
		 [volume_left] float,  
		 ext_facility_id varchar(50) COLLATE DATABASE_DEFAULT,           
		 [pre_volume_left] float    ,
		 [status_value_id] int,
		 [purchase_volume] float
	) ON [PRIMARY]        
        
	select * into #temp1 from #temp where 1 = 2        

    
--******************************************************        
--CREATE source book map table and build index        
--*********************************************************        
	CREATE TABLE #ssbm(        
		 source_system_book_id1 int,        
		 source_system_book_id2 int,        
		 source_system_book_id3 int,        
		 source_system_book_id4 int,        
		 fas_deal_type_value_id int,        
		 fas_book_id int,        
		 stra_book_id int,        
		 sub_entity_id int        
	)        
	        
--------------------------------------------------------------        
	CREATE  INDEX [IX_PH1] ON [#ssbm]([source_system_book_id1])              
	CREATE  INDEX [IX_PH2] ON [#ssbm]([source_system_book_id2])              
	CREATE  INDEX [IX_PH3] ON [#ssbm]([source_system_book_id3])              
	CREATE  INDEX [IX_PH4] ON [#ssbm]([source_system_book_id4])              
	CREATE  INDEX [IX_PH5] ON [#ssbm]([fas_deal_type_value_id])              
	CREATE  INDEX [IX_PH6] ON [#ssbm]([fas_book_id])       
	CREATE  INDEX [IX_PH7] ON [#ssbm]([stra_book_id])              
	CREATE  INDEX [IX_PH8] ON [#ssbm]([sub_entity_id])              
        
--******************************************************        
--End of source book map table and build index        
--*********************************************************        
----------------------------------        
	SET @sql_stmt=        
	'
	INSERT INTO #ssbm        
	SELECT        
		 source_system_book_id1,
		 source_system_book_id2,
		 source_system_book_id3,
		 source_system_book_id4,
		 fas_deal_type_value_id,        
		 book.entity_id fas_book_id,
		 book.parent_entity_id stra_book_id,
		 stra.parent_entity_id sub_entity_id         
	FROM        
		 source_system_book_map ssbm         
		INNER JOIN portfolio_hierarchy book (nolock) ON ssbm.fas_book_id = book.entity_id
		INNER JOIN Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id         
	WHERE 1=1 '        
	        
	+CASE WHEN @sub_entity_id IS NOT NULL THEN ' AND stra.parent_entity_id IN  ( ' + @sub_entity_id + ') ' ELSE '' END        
	+CASE WHEN @strategy_entity_id IS NOT NULL THEN ' AND (stra.entity_id IN(' + @strategy_entity_id + ' ))' ELSE '' END
	+CASE WHEN @book_entity_id IS NOT NULL THEN ' AND (book.entity_id IN(' + @book_entity_id + ')) ' ELSE '' END
	 --print @sql_stmt
	EXEC (@sql_stmt)        
        
--******************************************************        
--CREATE Bonus table and build index        
--*********************************************************        
        
	CREATE TABLE #bonus(            
		 code_value int,            
		 technology int,            
		 assignment_type_value_id int,            
		 from_date datetime,            
		 to_date datetime,            
		 gen_code_value int,            
		 bonus_per Float,
		 curve_id INT	            
	)            
	            
	INSERT INTO #bonus            
	SELECT  
		 COALESCE(bS.code_value, bA.code_value) code_value,            
		 COALESCE(bS.technology, bA.technology) technology,            
		 COALESCE(bS.assignment_type_value_id, bA.assignment_type_value_id) assignment_type_value_id,            
		 COALESCE(bS.from_date, bA.from_date) from_date,            
		 COALESCE(bS.to_date, bA.to_date) to_date,            
		 COALESCE(bS.gen_code_value, bA.gen_code_value) gen_code_value,            
		 COALESCE(bS.bonus_per, bA.bonus_per) bonus_per ,
		 COALESCE(bS.curve_id, bA.curve_id) curve_id         
	FROM            
	(
		select code_value, technology, isnull(assignment_type_value_id, 5149) assignment_type_value_id, from_date, to_date,	gen_code_value, bonus_per,curve_id            
		from state_properties_bonus where gen_code_value is not null            
	) bS            
	full outer join            
	(            
		select code_value, technology, assignment_type_value_id, from_date, to_date,             
		state.value_id as gen_code_value, bonus_per,curve_id            
		from            
			(select code_value, technology, isnull(assignment_type_value_id, 5149) assignment_type_value_id, from_date, to_date,             
			 bonus_per, 1 as link_id,curve_id            
			from state_properties_bonus where gen_code_value is  null) bonus inner join            
			(select value_id, 1 as link_id from static_data_value where type_id = 10016) state            
			on state.link_id = bonus.link_id            
	) bA 
	ON bA.code_value = bs.code_value and bA.technology = bS.technology and            
	bA.assignment_type_value_id = bS.assignment_type_value_id and            
	bA.from_date = bs.from_date and bA.to_date = bs.to_date       
	and bA.curve_id=bA.curve_id     
	      

  
--**************DURATION
	CREATE TABLE #temp_duration        
	(
		code_value int,        
		technology int,        
		assignment_type_value_id int,        
		duration int,        
		offset_duration int,        
		gen_code_value int,        
		banking_period_frequency int
	)        
	      
	        
	CREATE  INDEX [IX_duration1] ON [#temp_duration]([code_value])              
	CREATE  INDEX [IX_duration2] ON [#temp_duration]([technology])              
	CREATE  INDEX [IX_duration3] ON [#temp_duration]([assignment_type_value_id])              
	CREATE  INDEX [IX_duration4] ON [#temp_duration]([gen_code_value])       
      

	INSERT INTO #temp_duration        
	SELECT  
		 COALESCE(bS.code_value, bA.code_value) code_value,        
		 COALESCE(bS.technology, bA.technology) technology,        
		 COALESCE(bS.assignment_type_value_id, bA.assignment_type_value_id) assignment_type_value_id,        
		 COALESCE(bS.duration, bA.duration) duration,        
		 COALESCE(bS.offset_duration, bA.offset_duration) offset_duration,        
		 COALESCE(bS.gen_code_value, bA.gen_code_value) gen_code_value,        
		 COALESCE(bS.banking_period_frequency, bA.banking_period_frequency) banking_period_frequency        
	FROM        
		(select code_value, technology, isnull(assignment_type_value_id, 5149) assignment_type_value_id, duration, offset_duration,         
		gen_code_value, banking_period_frequency        
		from state_properties_duration where gen_code_value is not null        
		) bS        
		full outer join        
		(        
			select code_value, technology, isnull(assignment_type_value_id, 5149) assignment_type_value_id, duration, offset_duration,         
			state.value_id as gen_code_value, banking_period_frequency        
			from        
				(select code_value, technology, isnull(assignment_type_value_id, 5149) assignment_type_value_id, duration, offset_duration,         
				gen_code_value, banking_period_frequency, 1 as link_id        
				from state_properties_duration where gen_code_value is  null) duration inner join        
				(select value_id, 1 as link_id from static_data_value where type_id = 10002) state        
				on state.link_id = duration.link_id        
		) bA 
		ON bA.code_value = bs.code_value and bA.technology = bS.technology and        
		bA.assignment_type_value_id = bS.assignment_type_value_id         
             
          
---**********************************
------####################### rec_gen_eligibility

	CREATE TABLE #rec_gen_eligibility(            
		 state_value_id int,            
		 gen_state_value_id int,    
		 technology INT,        
		 program_scope int,            
		 tier_type int,            
	)            
            
	
		select  DISTINCT
		 COALESCE(bS.state_value_id, bA.state_value_id) state_value_id,            
		 COALESCE(bS.gen_state_value_id, bA.gen_state_value_id) gen_state_value_id,            
		 COALESCE(bS.technology, bA.technology) technology,            
		 COALESCE(bS.program_scope, bA.program_scope) program_scope,
		 COALESCE(bS.tier_type, bA.tier_type) tier_type
	INTO #rec_gen_eligibility_org            
	from            
		(select state_value_id, gen_state_value_id, technology,program_scope,tier_type  from rec_gen_eligibility  where technology is not null) bS            
		full outer join            
		(            
		select state_value_id, gen_state_value_id, tech.value_id technology,program_scope,tier_type from            
			(
				select state_value_id, gen_state_value_id, technology,program_scope,tier_type,1 as link_id	from rec_gen_eligibility where technology is  null
			) rge inner join            
			(
				select value_id, 1 as link_id from static_data_value where type_id = 10009) tech on rge.link_id = tech.link_id   
			) bA on bA.state_value_id = bs.state_value_id 
					AND ISNULL(bA.tier_type,-1) = ISNULL(bS.tier_type,-1)
					AND bA.gen_state_value_id = bS.gen_state_value_id
					AND bA.program_scope = bs.program_scope
	WHERE
		COALESCE(bS.state_value_id, bA.state_value_id)=@compliance_state


	INSERT INTO #rec_gen_eligibility   
	select  DISTINCT
		 COALESCE(bS.state_value_id, bA.state_value_id) state_value_id,            
		 COALESCE(bS.gen_state_value_id, bA.gen_state_value_id) gen_state_value_id,            
		 COALESCE(bS.technology, bA.technology) technology,            
		 COALESCE(bS.program_scope, bA.program_scope) program_scope,
		 COALESCE(bS.tier_type, bA.tier_type) tier_type
	from            
		(select state_value_id, gen_state_value_id, technology,program_scope,tier_type  from #rec_gen_eligibility_org  where tier_type is not null) bS            
		full outer join            
		(            
		select state_value_id, gen_state_value_id, tier.value_id tier_type,program_scope,technology from            
			(
				select state_value_id, gen_state_value_id, technology,program_scope,tier_type,1 as link_id	from #rec_gen_eligibility_org where tier_type is  null
			) rge inner join            
			(
				select value_id, 1 as link_id from static_data_value where type_id = 15000) tier on rge.link_id = tier.link_id   
			) bA on bA.state_value_id = bs.state_value_id 
					AND ISNULL(bA.technology,-1) = ISNULL(bS.technology,-1)
					AND bA.gen_state_value_id = bS.gen_state_value_id
					AND bA.program_scope = bs.program_scope
	WHERE
		COALESCE(bS.state_value_id, bA.state_value_id)=@compliance_state

--------------------------------------------------------------            
	CREATE  INDEX [IX_rge1] ON [#rec_gen_eligibility]([state_value_id])                  
	CREATE  INDEX [IX_rge2] ON [#rec_gen_eligibility](gen_state_value_id)                  
	CREATE  INDEX [IX_rge3] ON [#rec_gen_eligibility](technology)                  
	CREATE  INDEX [IX_rge4] ON [#rec_gen_eligibility](program_scope)    
	CREATE  INDEX [IX_rge5] ON [#rec_gen_eligibility](tier_type)                  
--------------------------------------------------------------       

         
--***********************************
--Beginning balance from  last year = what is banked for the state that did not expire        
--***********************************

	SET @sql_stmt = '
		INSERT INTO #temp        
		SELECT		   
			 tech.code type,        
			 rg1.generator_id,         
			 rg1.name,        
			 sdh.source_deal_header_id SourceDealId,	  
			 sdd.Source_Deal_detail_Id Source_Deal_detail_Id,        
			 sdh.deal_id RefDealId,    
			 sdh.ext_deal_id,         
			 case when status_value_id=5180 and buy_sell_flag=''s'' then -1 else 1 end *deal_volume * isnull(COALESCE(conv1.conversion_factor,conv5.conversion_factor,conv2.conversion_factor,conv3.conversion_factor,conv4.conversion_factor), 1) * isnull(df.decay_per, 1)  volume,        
			 ISNULL( CASE WHEN  (isnull(sdh.status_value_id , 5171) in  (5171, 5177) AND sbm.fas_deal_type_value_id = 400) THEN isnull(spbAll.bonus_per, 0)* deal_volume ELSE 0 END * isnull(COALESCE(conv1.conversion_factor,conv5.conversion_factor,conv2.conversion_factor,conv3.conversion_factor,conv4.conversion_factor), 1),0) bonus,        
			 sdh.state_value_id assigned_state,         
			 sdh.assignment_type_value_id,        
			 sdd.term_start gen_date, 
			 case when status_value_id=5180 and buy_sell_flag=''s'' then ''b'' else sdd.buy_sell_flag end ,        
			 dbo.FNADEALRECExpirationState(sdd.source_deal_detail_id, sdd.contract_expiration_date, ' +         
			 cast(@assignment_type_value_id as varchar) + ', rge.state_value_id)   as Expiration,        
			 sdh.deal_date ,         
			 deal_detail_description as HE,        
			 sc.counterparty_name Counterparty,        
			 sc.int_ext_flag,        
			 case when sdd.buy_sell_flag = ''b'' then -1 else 1 end *         
			 sdd.deal_volume * isnull(sdd.fixed_price, 0) Settlement,        
			 sdh.compliance_year,    
			 COALESCE(Conv1.curve_label,Conv5.curve_label,Conv2.curve_label,Conv3.curve_label,Conv4.curve_label, pspcd.curve_name, spcd.curve_name, pspcd.curve_name,spcd.curve_name) as curve_name,        
			 sdh.assigned_date,        
			 sdd.deal_Volume,  
			 case when status_value_id=5180 and buy_sell_flag=''s'' then -1 else 1 end *deal_volume-ISNULL(assign.assigned_volume,0) * isnull(COALESCE(conv1.conversion_factor,conv5.conversion_factor,conv2.conversion_factor,conv3.conversion_factor,conv4.conversion_factor), 1) * isnull(df.decay_per, 1)  volume_left,        
			 rg1.id GenID,       
			 case when status_value_id=5180 and buy_sell_flag=''s'' then -1 else 1 end * deal_volume-ISNULL(pre_assign.assigned_volume,0) * isnull(COALESCE(conv1.conversion_factor,conv5.conversion_factor,conv2.conversion_factor,conv3.conversion_factor,conv4.conversion_factor), 1) * isnull(df.decay_per, 1)  pre_volume_left,
			 sdh.status_value_id,
			 CASE WHEN buy_sell_flag = ''b'' THEN (sdd.deal_volume) ELSE 0 END [purchase_volume]	 
		FROM
		  state_properties sp 
		  LEFT OUTER JOIN #rec_gen_eligibility rge on sp.code_value = rge.state_value_id
		  LEFT JOIN rec_generator rg1 ON  rg1.gen_state_value_id=rge.gen_state_value_id	
 				AND (rge.technology=rg1.technology)
				AND (rge.tier_type=ISNULL(rg1.tier_type,-1) OR (rg1.tier_type IS NULL))
		  INNER JOIN source_deal_header sdh on sdh.generator_id = rg1.generator_id        
		  INNER JOIN source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id   
		  INNER JOIN #ssbm sbm (nolock) on sdh.source_system_book_id1 = sbm.source_system_book_id1
			  AND sdh.source_system_book_id2 = sbm.source_system_book_id2          
			  AND sdh.source_system_book_id3 = sbm.source_system_book_id3          
			  AND sdh.source_system_book_id4 = sbm.source_system_book_id4      
		  LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=sdd.curve_id AND rge.program_scope=spcd.program_scope_value_id
		  INNER JOIN static_data_value tech on tech.value_id = rg1.technology
		  INNER JOIN static_data_value state_rg on state_rg.value_id = rg1.state_value_id 
		  INNER JOIN source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id         
		  LEFT JOIN #bonus spbAll ON spbAll.code_value = rg1.state_value_id   
			 AND spbAll.technology = rg1.technology         
			 AND isnull(spbAll.assignment_type_value_id, 5149) =isnull(sdh.assignment_type_value_id, 5149)
			 AND sdd.term_start between spbAll.from_date and spbAll.to_date
			 AND spbAll.gen_code_value = rg1.gen_state_value_id        
			 AND (spbAll.curve_id IS NULL OR spbAll.curve_id=sdd.curve_id)
		  LEFT JOIN source_price_curve_def pspcd ON spcd.proxy_source_curve_def_id = pspcd.source_curve_def_id      
		  LEFT OUTER JOIN rec_volume_unit_conversion Conv1 ON conv1.from_source_uom_id  = sdd.deal_volume_uom_id               
			 AND conv1.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id as varchar),'NULL')+'              
			 And conv1.state_value_id = isnull(sdh.state_value_id, ' + cast(@compliance_state as varchar) + ')          
			 AND conv1.assignment_type_value_id = ' + case when (@assignment_type_value_id is not null) then cast(@assignment_type_value_id as varchar) else ' isnull(sdh.assignment_type_value_id, 5149) ' end + '          
			 AND conv1.curve_id = sdd.curve_id   
			 AND conv1.to_curve_id IS NULL	            
		  LEFT OUTER JOIN rec_volume_unit_conversion Conv2 ON conv2.from_source_uom_id = sdd.deal_volume_uom_id               
			 AND conv2.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id as varchar),'NULL')+'              
			 And conv2.state_value_id IS NULL  
			 AND conv2.assignment_type_value_id = ' + case when (@assignment_type_value_id is not null) then cast(@assignment_type_value_id as varchar) else ' isnull(sdh.assignment_type_value_id, 5149) ' end + '          
			 AND conv2.curve_id = sdd.curve_id		
			 AND conv2.to_curve_id IS NULL
		  LEFT OUTER JOIN rec_volume_unit_conversion Conv3 ON conv3.from_source_uom_id =  sdd.deal_volume_uom_id               
			 AND conv3.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id as varchar),'NULL')+'              
			 And conv3.state_value_id IS NULL  
			 AND conv3.assignment_type_value_id IS NULL  
			 AND conv3.curve_id = sdd.curve_id   
			 AND conv3.to_curve_id IS NULL'
		set @sql_stmt1=' LEFT OUTER JOIN rec_volume_unit_conversion Conv4 ON conv4.from_source_uom_id = sdd.deal_volume_uom_id  
			 AND conv4.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id as varchar),'NULL')+'              
			 And conv4.state_value_id IS NULL  
			 AND conv4.assignment_type_value_id IS NULL  
			 AND conv4.curve_id IS NULL		  
			 AND conv4.to_curve_id IS NULL
		  LEFT OUTER JOIN rec_volume_unit_conversion Conv5 ON conv5.from_source_uom_id  = sdd.deal_volume_uom_id               
			 AND conv5.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id as varchar),'NULL')+'              
			 And conv5.state_value_id = isnull(sdh.state_value_id, ' + cast(@compliance_state as varchar) + ')          
			 AND conv5.assignment_type_value_id is null  
			 AND conv5.curve_id = sdd.curve_id   
			 AND conv5.to_curve_id IS NULL
		  LEFT OUTER JOIN  
			(
				SELECT
					aa.source_deal_header_id_from,sum(aa.assigned_volume) assigned_volume  
				FROM
					assignment_audit aa inner join source_deal_detail sdd on sdd.source_deal_detail_id = aa.source_deal_header_id  
					INNER JOIN source_deal_header sdh on sdh.source_deal_header_id = sdd.source_deal_header_id  
				WHERE ' + cast(@pre_compliance_year as varchar) + ' >= case when sdh.assignment_type_value_id=5173 THEN year(sdh.deal_date) else sdh.compliance_year END
					group by source_deal_header_id_from  
			) pre_assign 
				ON sdd.source_deal_detail_id=pre_assign.source_deal_header_id_from  
		  LEFT OUTER JOIN  
			(
				select 
					aa.source_deal_header_id_from,sum(aa.assigned_volume) assigned_volume  
				from 
					assignment_audit aa inner join  
					source_deal_detail sdd on sdd.source_deal_detail_id = aa.source_deal_header_id inner join  
					source_deal_header sdh on sdh.source_deal_header_id = sdd.source_deal_header_id  
					where ' + cast(@compliance_year as varchar) + ' >= case when sdh.assignment_type_value_id=5173 then  year(sdh.deal_date) else sdh.compliance_year end  
					group by source_deal_header_id_from  
			) assign on sdd.source_deal_detail_id=assign.source_deal_header_id_from  
		    
		  LEFT OUTER JOIN decaying_factor df on df.curve_id = sdd.curve_id and df.year =' + cast(@compliance_year as varchar)+'         
				AND df.gen_year=year(sdd.term_start)      
		  --LEFT OUTER JOIN rec_generator_assignment rga on rg1.generator_id=rga.generator_id
				--AND ((sdd.term_start between rga.term_start and rga.term_end) OR (sdd.term_end between rga.term_start and rga.term_end))	         
	WHERE 
		 sbm.fas_deal_type_value_id = 400 --AND (ISNULL(rga.exclude_inventory,rg1.exclude_inventory) is null or ISNULL(rga.exclude_inventory,rg1.exclude_inventory)=''n'')   
		 AND isnull(sp.begin_date, sdh.deal_date) <= sdh.deal_date         
		 AND isnull(sdh.status_value_id, 5171) NOT IN (5170, 5179) '
		--+CASE WHEN  @assignment_type_value_id is NOT  NULL THEN ' AND sdh.assignment_type_value_id ='+cast(@assignment_type_value_id as varchar) ELSE '' END

		--PRINT @sql_stmt + @sql_stmt1
		EXEC (@sql_stmt + @sql_stmt1)        

        
	SET @sql_stmt1 = ''        
	        
	If @drill_down_level < 12        
	BEGIN        
	        
		 -- assigned to other states but retiring        
		 set @sql_stmt ='         
		 INSERT INTO #temp1        
			  select         
			  tech.code type,        
			  rg1.generator_id,         
			  rg1.name,          
			  sdh.source_deal_header_id SourceDealId,  
			  sdd.Source_Deal_detail_Id Source_Deal_detail_Id,        
			  sdh.deal_id RefDealId,    
			  sdh.ext_deal_id,    
			  deal_volume * isnull(COALESCE(conv1.conversion_factor,conv5.conversion_factor,conv2.conversion_factor,conv3.conversion_factor,conv4.conversion_factor), 1) volume  ,        
			  CASE WHEN  (isnull(sdh.status_value_id , 5171) IN (5171, 5177) AND sbm.fas_deal_type_value_id = 400) THEN isnull(spbAll.bonus_per, 0)* deal_volume ELSE 0 END * isnull(COALESCE(conv1.conversion_factor,conv5.conversion_factor,conv2.conversion_factor,conv3.conversion_factor,conv4.conversion_factor), 1) bonus,        
			  sdh.state_value_id assigned_state, 
			  sdh.assignment_type_value_id,        
			  sdd.term_start gen_date, sdd.buy_sell_flag,        
			  dbo.FNADEALRECExpirationState(sdd.source_deal_detail_id, sdd.contract_expiration_date, ' +         
			  cast(@assignment_type_value_id as varchar) + ', sdh.state_value_id) Expiration,        
			  sdh.deal_date ,         
			  deal_detail_description as HE,        
			  sc.counterparty_name Counterparty,        
			  sc.int_ext_flag,        
			  case when sdd.buy_sell_flag = ''b'' then -1 else 1 end *         
			  sdd.deal_volume * isnull(sdd.fixed_price, 0) Settlement,        
			  sdh.compliance_year,        
			  ISNULL(pspcd.curve_name,spcd.curve_name),        
			  sdh.assigned_date,  
			  sdd.deal_Volume,  
			  volume_left * isnull(COALESCE(conv1.conversion_factor,conv5.conversion_factor,conv2.conversion_factor,conv3.conversion_factor,conv4.conversion_factor), 1)  volume_left,        
			  rg1.id,
			  0 pre_volume_left,
			  sdh.status_value_id,
			  CASE WHEN sdd.buy_sell_flag = ''b'' THEN sdd.deal_volume ELSE 0 END [purchase_volume]
		  FROM 
			  state_properties sp 
			  LEFT OUTER JOIN #rec_gen_eligibility rge on sp.code_value = rge.state_value_id
			  LEFT JOIN rec_generator rg1 ON  rg1.gen_state_value_id=rge.gen_state_value_id	
 				AND (rge.technology=rg1.technology)
				AND (rge.tier_type=ISNULL(rg1.tier_type,-1) OR (rg1.tier_type IS NULL))
			  INNER JOIN source_deal_header sdh on sdh.generator_id = rg1.generator_id        
			  INNER JOIN source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id  
			  INNER JOIN #ssbm sbm (nolock) on sdh.source_system_book_id1 = sbm.source_system_book_id1          
				  AND sdh.source_system_book_id2 = sbm.source_system_book_id2
				  AND sdh.source_system_book_id3 = sbm.source_system_book_id3
				  AND sdh.source_system_book_id4 = sbm.source_system_book_id4    
			  INNER JOIN static_data_value tech on tech.value_id = rg1.technology         
			  LEFT OUTER JOIN source_price_curve_def spcd on spcd.source_curve_def_id = sdd.curve_id         
			  LEFT OUTER JOIN source_price_curve_def pspcd ON spcd.proxy_source_curve_def_id = pspcd.source_curve_def_id        
			  LEFT OUTER JOIN static_data_value state_rg on state_rg.value_id = rg1.state_value_id 
			  LEFT OUTER JOIN source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id 		        
			  LEFT OUTER JOIN #bonus spbAll ON spbAll.code_value = sp.code_value
				AND spbAll.technology = rg1.technology
			    AND isnull(spbAll.assignment_type_value_id, 5149)=isnull(sdh.assignment_type_value_id, 5149)
				AND sdd.term_start between spbAll.from_date and spbAll.to_date
				AND spbAll.gen_code_value = rg1.gen_state_value_id
			    AND (spbAll.curve_id IS NULL OR spbAll.curve_id=sdd.curve_id)			  
			LEFT OUTER JOIN rec_volume_unit_conversion Conv1 ON              
				conv1.from_source_uom_id  = sdd.deal_volume_uom_id               
				AND conv1.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id as varchar),'NULL')+'              
				And conv1.state_value_id = isnull(sdh.state_value_id, ' + cast(@compliance_state as varchar) + ')          
				AND conv1.assignment_type_value_id = ' + case when (@assignment_type_value_id is not null) then cast(@assignment_type_value_id as varchar) else ' isnull(sdh.assignment_type_value_id, 5149) ' end + '          
				AND conv1.curve_id = sdd.curve_id               
				AND conv1.to_curve_id IS NULL	            
			LEFT OUTER JOIN rec_volume_unit_conversion Conv2 ON conv2.from_source_uom_id = sdd.deal_volume_uom_id               
				AND conv2.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id as varchar),'NULL')+'              
				And conv2.state_value_id IS NULL  
				AND conv2.assignment_type_value_id = ' + case when (@assignment_type_value_id is not null) then cast(@assignment_type_value_id as varchar) else ' isnull(sdh.assignment_type_value_id, 5149) ' end + '          
				AND conv2.curve_id = sdd.curve_id		  
				AND conv2.to_curve_id IS NULL	          
			LEFT OUTER JOIN rec_volume_unit_conversion Conv3 ON conv3.from_source_uom_id =  sdd.deal_volume_uom_id               
				AND conv3.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id as varchar),'NULL')+'              
				And conv3.state_value_id IS NULL  
				AND conv3.assignment_type_value_id IS NULL  
				AND conv3.curve_id = sdd.curve_id   
			    AND conv3.to_curve_id IS NULL			         
			LEFT OUTER JOIN rec_volume_unit_conversion Conv4 ON conv4.from_source_uom_id = sdd.deal_volume_uom_id  
				AND conv4.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id as varchar),'NULL')+'              
				And conv4.state_value_id IS NULL  
				AND conv4.assignment_type_value_id IS NULL  
				AND conv4.curve_id IS NULL			  
			LEFT OUTER JOIN rec_volume_unit_conversion Conv5 ON conv5.from_source_uom_id  = sdd.deal_volume_uom_id               
				AND conv5.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id as varchar),'NULL')+'              
				And conv5.state_value_id = isnull(sdh.state_value_id, ' + cast(@compliance_state as varchar) + ')          
				AND conv5.assignment_type_value_id is null  
				AND conv5.curve_id = sdd.curve_id   
				AND conv5.curve_id IS NULL			  
			--LEFT OUTER JOIN rec_generator_assignment rga on rg1.generator_id=rga.generator_id
			--	AND ((sdd.term_start between rga.term_start and rga.term_end) OR (sdd.term_end between rga.term_start and rga.term_end))	         
		where 1=1
		   AND sbm.fas_deal_type_value_id = 400     
		   --AND (ISNULL(rga.exclude_inventory,rg1.exclude_inventory) is null or ISNULL(rga.exclude_inventory,rg1.exclude_inventory)=''n'')      
		   AND isnull(sp.begin_date, sdh.deal_date) <= sdh.deal_date         
		   AND  (sdh.assignment_type_value_id is not null and sdh.assignment_type_value_id <> 5149) and        
		   sdh.compliance_year = ' + cast(@compliance_year as varchar) + ' and        
		   isnull(sdh.status_value_id, 5171) NOT IN (5170, 5179) AND        
		   sp.code_value <> ' + cast(@compliance_state as varchar)         
		 exec(@sql_stmt)        
		    
	
  
	select assignment_id,source_deal_header_id,source_deal_header_id_from,assigned_volume,cert_from,cert_to  
	into #assign from assignment_audit where assigned_volume > 0  
	insert into #assign(source_deal_header_id,source_deal_header_id_from ,assigned_volume,cert_from,cert_to)  
	select source_deal_header_id,source_deal_header_id,-1,certificate_number_from_int,certificate_number_to_int from gis_certificate  
  

If @drill_down_level between 1 and 11 -- drill down on columns        
 BEGIN        
	  SET @sql_stmt1 = ''        
	  set @sql_stmt =         
	   'SELECT         
		sdh.[name] Resource,        
		dbo.FNAHyperLinkText(10131010, cast(SourceDealId as varchar),         
	   cast(SourceDealId as varchar)) ID,        
	  dbo.FNACertificateRule(cr.cert_rule,rg.generator_id,assign.cert_from, gen_date)+''&nbsp;'' as [Cert# From],    
	  dbo.FNACertificateRule(cr.cert_rule,rg.generator_id,assign.cert_to,gen_date)+''&nbsp;'' as [Cert# To],    
	    
	   RefDealId RefId,           
		isnull(b.code, ds.code) [Assigned Jurisdiction],         
		isnull(a.code, ''Banked'') AssignedType,        
		isnull(curve_name, '''') [Env Product],        
		isnull(sdh.compliance_year, year(Expiration))  [Year],        
		dbo.FNADateFormat(gen_date) Vintager,         
		case when (sdh.buy_sell_flag=''b'') then  ''Buy'' else ''Sell'' end [Buy/Sell],        
		dbo.FNADateFormat(Expiration) Expiration,          
		dbo.FNADateFormat(sdh.deal_date)[Date],         
		 HE as HE,  
		Counterparty, ' +        
		case when @drill_down_level in (2) then        
		' pre_volume_left [Volume], bonus [Bonus], (pre_volume_left + bonus) [Total Volume MWh (+Long/-Short)], '
		when @drill_down_level in (8, 10, 11) then        
		' volume_left [Volume], bonus [Bonus], (volume_left + bonus) [Total Volume MWh (+Long/-Short)], '
			 else 
		' volume [Volume], bonus [Bonus], (volume + bonus) [Total Volume MWh (+Long/-Short)], '
		end + '        
	  
		Settlement [Settlement $]           
		  from #temp sdh left outer join         
		  static_data_value a on a.value_id = sdh.assignment_type_value_id left outer join        
		  static_data_value b on b.value_id = assigned_state left outer join         
		  static_data_value ds on ds.value_id = ' + cast(@compliance_state as varchar)+'         
	 LEFT JOIN          
	 #assign assign          
	ON          
	 sdh.source_deal_detail_id=assign.source_deal_header_id          
	LEFT JOIN Gis_certificate gis on          
	 gis.source_deal_header_id=assign.source_deal_header_id_from         
	LEFT join rec_generator rg on          
	 sdh.generator_id=rg.generator_id           
	LEFT JOIN          
	 certificate_rule cr on rg.gis_value_id=cr.gis_id        
	LEFT JOIN      
	(SELECT source_deal_header_id_from,sum(assigned_volume) assigned_volume from           
	 assignment_audit group by source_deal_header_id_from) assign1          
	 on assign1.source_deal_header_id_from=sdh.Source_Deal_detail_Id '    
  
--   where --year(Expiration) >= @compliance_year and  --1. has not expired        
--   (tmp.assigned_date is null OR year(tmp.assigned_date) <= @compliance_year)        
--   and (year(gen_date) <  @compliance_year --3. generated prior to this year        
--  AND year(deal_date) < @compliance_year)  
--   --and buy_sell_flag = 'b' --4. only generated or bought         

   
  If @drill_down_level = 2 --Column a.        
   set @sql_stmt =  @sql_stmt + '             
    where year(Expiration) >= ' + cast(@compliance_year as varchar) + ' and  
	(sdh.assigned_date is null OR year(sdh.assigned_date) <= ' + cast(@compliance_year as varchar) + ')         
    and (year(gen_date) <  ' + cast(@compliance_year as varchar) + ' AND  year(deal_date) < ' + cast(@compliance_year as varchar) + ') '         

  Else If @drill_down_level = 3 --Column b.        
   set @sql_stmt =  @sql_stmt + ' where 1=1 and year(Expiration) >= ' + cast(@compliance_year as varchar) + '         
    and buy_sell_flag = ''b'' and year(gen_date) =  ' + cast(@compliance_year as varchar) 
        
  Else If @drill_down_level = 4 --Column c.        
	   set @sql_stmt =  @sql_stmt + ' where year(Expiration) >= ' + cast(@compliance_year as varchar) + '           
		and year(sdh.deal_date) =  ' + cast(@compliance_year as varchar) + '         
		and sdh.buy_sell_flag = ''s'' and (assignment_type_value_id is null or assignment_type_value_id=5173)'      
        
  Else If @drill_down_level = 6 --Column e.        
	   set @sql_stmt =  @sql_stmt + ' where year(Expiration) >= ' + cast(@compliance_year as varchar) + '          
		and sdh.assignment_type_value_id = ' + @compliance_type + '        
		and sdh.compliance_year =  ' + cast(@compliance_year as varchar)         
        
  Else If @drill_down_level = 7 --Column f.        
	BEGIN        
	   SET @sql_stmt1 =  @sql_stmt        
	   SET @sql_stmt1 = REPLACE(@sql_stmt1, '#temp', '#temp1')         
	   set @sql_stmt =  @sql_stmt + ' where year(Expiration) >= ' + cast(@compliance_year as varchar) + '           
		and (assignment_type_value_id is not null and assignment_type_value_id<>' + cast(@assignment_type_value_id as varchar) + ' and assignment_type_value_id<>5173 ) 
		and sdh.compliance_year =  ' + cast(@compliance_year as varchar)        
	   SET @sql_stmt1 =  ' UNION ' + @sql_stmt1        
	  END        
  Else If @drill_down_level = 8 --Column g.        
	   set @sql_stmt =  @sql_stmt + ' where year(Expiration) = ' + cast(@compliance_year as varchar) + '           
		 and (isnull(sdh.assignment_type_value_id, 5149) = 5149)'        
        
  Else If @drill_down_level = 10 --Column i.        
   set @sql_stmt =  @sql_stmt + ' where year(Expiration) = (' + cast(@compliance_year as varchar) + ' + 1)
		and year(gen_date) <= ' + cast(@compliance_year as varchar) + '
		and buy_sell_flag = ''b'''	        
        
  Else If @drill_down_level = 11 --Column j.        
   set @sql_stmt =  @sql_stmt + ' where year(Expiration) >= (' + cast(@compliance_year as varchar) + ' + 2)  
		and year(gen_date) <= ' + cast(@compliance_year as varchar) + '
		and buy_sell_flag = ''b'''	                
        
  --print @sql_stmt        
  --print @sql_stmt1        
   



  if @sql_stmt1 = ''       
  begin        
	   set @sql_stmt =  @sql_stmt + CASE WHEN @drill_value1 IS NOT NULL THEN ' and sdh.[type] = ''' + @drill_value1 + '''' ELSE '' END
	   set @sql_stmt =  @sql_stmt + ' and sdh.[name] = ''' + @drill_value + ''' ORDER BY SourceDealId'         

	  --print @sql_stmt+ @sql_stmt1        
	  EXEC(@sql_stmt + @sql_stmt1)        
  end        
  Else        
  begin         
	   set @sql_stmt =  @sql_stmt + CASE WHEN @drill_value1 IS NOT NULL THEN ' and sdh.[type] = ''' + @drill_value1 + '''' ELSE '' END	
	   set @sql_stmt =  @sql_stmt + ' and sdh.[name] = ''' + @drill_value + ''''        
	    
		 EXEC('select * from (' + @sql_stmt + @sql_stmt1 + ') xx ' )        
    
  end        
	exec spa_print 'select * from (', @sql_stmt, @sql_stmt1, ') xx '            

	--print @sql_stmt        
	--print @sql_stmt1        

  Return        
END        
  

 -- compliance reports        
IF @drill_down_level = 0        
BEGIN        

CREATE TABLE #temp_compliance( [Type] varchar(100) COLLATE DATABASE_DEFAULT,             
	 [Resource] varchar(100) COLLATE DATABASE_DEFAULT,         
	 [Beginning  Balance] float,   --a.        
	 [Compliance Year  Received] float, --b.        
	 [Sold] float, --c.        
	 [Total Compliance Year  Avail] float, --d.        
	 [Retired for Compliance] float, --e.        
	 [Retired for Other States] float, --f.        
	 [Expiring Year End] float, --g.        
	 [Ending  Balance] float, --h.        
	 [Eligibility Ends Year+1] int, --i.        
	 [Eligibility Ends Year+2] int, --j.       
	 [Compliance Year  Received Monthly] int, --b.       
	 [Bonus] float, 
	 [RetiredBonus] float,  
	 [PriorVintagesRECSales] float,
	 [TotalRECsAvailable] float,
	 GenId varchar(100) COLLATE DATABASE_DEFAULT
	 )

set @sql_stmt ='
	INSERT INTO #temp_compliance
	select  main.type Type,             
	main.[name] Resource,         
	isnull(clmA.a, 0) [Beginning  Balance],   --a.        
	isnull(clmB.b, 0) [Compliance Year  Received], --b.        
	isnull(clmC.c, 0) [Sold], --c.        
	isnull(clmA.a, 0) + isnull(clmB.b, 0) - isnull(clmC.c, 0) [Total Compliance Year  Avail], --d.        
	isnull(clmE.e, 0) [Retired for Compliance], --e.        
	isnull(clmF.f, 0) + isnull(clmF2.f2, 0) [Retired for Other States], --f.        
	isnull(clmG.g, 0) [Expiring Year End], --g.        
	case when ' + cast(@show_bonus as varchar) + '=1 then isnull(clmE.bonus,0)  else 0 end+(isnull(clmA.a, 0) + isnull(clmB.b, 0) - isnull(clmC.c, 0)) -        
	isnull(clmE.e, 0) - isnull(clmF.f, 0) - isnull(clmF2.f2, 0) - isnull(clmG.g, 0) [Ending  Balance], --h.        
	isnull(clmI.year1, 0) [Eligibility Ends Year+1], --i.        
	isnull(clmI.year2, 0) [Eligibility Ends Year+2], --j.       
	Isnull(clmK.b, 0) [Compliance Year  Received Monthly], --b.       
	clmM.TotalBonus [Bonus], 
	clmE.bonus [RetiredBonus],  
	clmL.volume [PriorVintagesRECSales],
	clmM.volume [TotalRECsAvailable],
	ext_facility_id GenId      
	from (select  generator_id, type,sum(bonus) bonus,name,ext_facility_id 
	from #temp group by  generator_id, type,name,ext_facility_id) main         
	  
	left outer join        
	(  
		select generator_id, type, name,         
		sum(pre_volume_left) a         
		from #temp tmp          
		where year(Expiration) >= ' + cast(@compliance_year as varchar)+ ' and  --1. has not expired        
		(tmp.assigned_date is null OR year(tmp.assigned_date) <= ' + cast(@compliance_year as varchar)+ ')        
		and (year(gen_date) < ' + cast(@compliance_year as varchar)+ '  --3. generated prior to this year        
		AND year(deal_date) < ' + cast(@compliance_year as varchar)+ ' ) '
		if @assignment_type_value_id is NOT  NULL 
		set @sql_stmt = @sql_stmt + ' AND tmp.assignment_type_value_id ='+cast(@assignment_type_value_id as varchar)
		set @sql_stmt = @sql_stmt + ' group by generator_id, type, name 
		

	)  
	clmA on clmA.generator_id = main.generator_id        
	 
	left outer join        
	--b) Compliance Year  Received         
	(
		select generator_id, type, name, sum(purchase_volume) b        
		from #temp        
		where year(Expiration) >= ' + cast(@compliance_year as varchar)+ '  --1. has not expired        
		and (year(gen_date) =  ' + cast(@compliance_year as varchar)+ '  --2. generated in the current year or bought in the current year   
		)          
		and (buy_sell_flag = ''b'')--3. only generated or bought         
		group by generator_id, type, name
	) clmB on clmB.generator_id = main.generator_id 
   
	left outer join        
	--c)  Sold        
	(
		select generator_id, type, name, sum(volume) c        
		from #temp        
		where year(Expiration) >= ' + cast(@compliance_year as varchar)+ '  --1. has not expired        
		and year(deal_date) = ' + cast(@compliance_year as varchar)+ '  --2. sold in the current year        
		and (buy_sell_flag = ''s'' and (assignment_type_value_id is null or assignment_type_value_id=5173))--3. only sold        
		group by generator_id, type, name
	) clmC on clmC.generator_id = main.generator_id        
	  
	--d. Total Compliance Year  Available        
	-- a) + b) - c)         
	left outer join   
	--e.  Retired for Compliance for TX        
	(
		select generator_id, type, name, sum(bonus) bonus,  
		case when ' + cast(@show_bonus as varchar) + '=1 then sum(volume + bonus)  
		when ' + cast(@show_bonus as varchar) + '=2 then sum(volume)  
		when ' + cast(@show_bonus as varchar) + '=3 then sum(bonus) end e        
		from #temp        
		where year(Expiration) >= ' + cast(@compliance_year as varchar)+ '  --1. has not expired        
		and (assignment_type_value_id = ' + cast(@compliance_type as varchar) + ')  --2. assignment type is what ever passed          
		and compliance_year =  ' + cast(@compliance_year as varchar)+ '  --3. assigned for current year 
		and assigned_state= ' + cast(@compliance_state as varchar) 
		if @assignment_type_value_id IS NOT  NULL 
		set @sql_stmt = @sql_stmt + ' AND assignment_type_value_id ='+cast(@assignment_type_value_id as varchar)	       
		set @sql_stmt = @sql_stmt + ' group by generator_id, type, name
	) clmE on clmE.generator_id = main.generator_id        
	  
	left outer join        
	--f.  Retired for Compliance for other States or Other type of assignment        
	(
		select generator_id, type, name, sum(volume) f        
		from #temp1 where 1=1 		
		group by generator_id, type, name
	) clmF on clmF.generator_id = main.generator_id        
	 
	left outer join        
	--f2.  assigned to different category for the same year and may be same state        
	(
		select generator_id, type, name, sum(volume + bonus) f2        
		from #temp        
		where year(Expiration) >= ' + cast(@compliance_year as varchar)+ '   --1. has not expired        
		and (assignment_type_value_id is not null and assignment_type_value_id<>' + cast(@assignment_type_value_id as varchar) + ' and assignment_type_value_id<>5173 ) -- or CO2 and Windsource assignment and compliance        
		and compliance_year =  ' + cast(@compliance_year as varchar)+ ' --3. assigned for current year    
		and assigned_state= ' + cast(@compliance_state as varchar) + '
		group by generator_id, type, name
	) clmF2 on clmF2.generator_id = main.generator_id        
	  
	left outer join        
	--g.  Expiring Compliance Year End        
	(
		select generator_id, type, name,   
		sum(case when (buy_sell_flag = ''s'') then -1 else 1 end * (volume_left + bonus)) g        
		from #temp        
		where year(Expiration) = ' + cast(@compliance_year as varchar)+ '  --1. will expire this year        
		and (isnull(assignment_type_value_id, 5149) = 5149) --OR --2. that has not been assigned or banked        
		--assignment_type_value_id = 5173 )     --2.1 or assigned to sold since sale position is included   
		'
		if @assignment_type_value_id IS NOT  NULL 
		set @sql_stmt = @sql_stmt + ' AND assignment_type_value_id ='+cast(@assignment_type_value_id as varchar)      
		set @sql_stmt = @sql_stmt + ' group by generator_id, type, name
	) clmG on clmG.generator_id = main.generator_id        
	  
	--h.= d. - e. - f. - g.        
	  
	left outer join        

	--i. j. Compliance Year Eligibility Ends        
	(
		select generator_id, type, name,         
		sum(case when (year(Expiration) = ' + cast(@compliance_year as varchar)+ '  + 1) then         
		volume_left else 0 end 
		) as year1,        

		sum(case when (year(Expiration) >= ' + cast(@compliance_year as varchar)+ '  + 2) then         
		volume_left else 0 end           
		) as year2        
		from #temp        
		where year(Expiration) > ' + cast(@compliance_year as varchar)+ ' 
		and year(gen_date) <= ' + cast(@compliance_year as varchar)+ ' 

		and buy_sell_flag = ''b'' '
		if @assignment_type_value_id IS NOT  NULL 
		set @sql_stmt = @sql_stmt + ' AND assignment_type_value_id ='+cast(@assignment_type_value_id as varchar) 
		set @sql_stmt = @sql_stmt + ' group by generator_id, type, [name]
	) clmI on clmI.generator_id = main.generator_id        

	left outer join        
	--k) Compliance Year  Received (Monthly)         
	(
		select generator_id, type, name, sum(volume) b        
		from #temp        
		where year(Expiration) >= ' + cast(@compliance_year as varchar)+ '  --1. has not expired        
		and (year(gen_date) =  ' + cast(@compliance_year as varchar)+ '  --2. generated in the current year or bought in the current year   
		'
		if @assignment_type_value_id IS NOT  NULL 
		set @sql_stmt = @sql_stmt + ' AND assignment_type_value_id ='+cast(@assignment_type_value_id as varchar)
		set @sql_stmt = @sql_stmt + ' AND (' + cast(@report_format as varchar) + '=2 and ' + cast(isnull(@month,'') as varchar) + ' <>'' and month(gen_date)=' + cast(isnull(@month,'') as varchar) + ') OR (' + cast(@report_format as varchar) + '=2 and ' + cast(isnull(@month,'') as varchar) + ' ='') OR (' + cast(@report_format as varchar) + '<>2)
	)          
	and buy_sell_flag = ''b'' --3. only generated or bought         
	group by generator_id, type, name) clmK on clmK.generator_id = main.generator_id        
       
	left outer join        
	--L) Prior Vintages  REC Sales Transfer       
	(
		select generator_id, type, name, sum(volume) volume        
		from #temp        
		where year(Expiration) >= ' + cast(@compliance_year as varchar)+ '  --1. has not expired        
		and year(deal_date) = ' + cast(@compliance_year as varchar)+ '  --2. sold in the current year  
		and YEAR(gen_date)< ' + cast(@compliance_year as varchar)+ '      
		and (buy_sell_flag = ''s'' and (assignment_type_value_id is null or assignment_type_value_id=5173))--3. only sold
		'
		if @assignment_type_value_id IS NOT  NULL 
		set @sql_stmt = @sql_stmt + ' AND assignment_type_value_id ='+cast(@assignment_type_value_id as varchar)        
		set @sql_stmt = @sql_stmt + ' group by generator_id, type, name
	) clmL on clmL.generator_id = main.generator_id        

	left outer join        
	--M)  Total RECs available(all vintages)        
	(
		select generator_id, type, name, sum(volume_left) volume ,sum(bonus) TotalBonus       
		from #temp        
		where year(Expiration) >= ' + cast(@compliance_year as varchar)+ '  --1. has not expired        
		and (buy_sell_flag = ''b'')--3. only sold 
		'
		if @assignment_type_value_id IS NOT  NULL 
		set @sql_stmt = @sql_stmt + ' AND assignment_type_value_id ='+cast(@assignment_type_value_id as varchar)       
		set @sql_stmt = @sql_stmt + ' group by generator_id, type, name
	) clmM on clmM.generator_id = main.generator_id      
	order by main.type, main.[name] '
	--print @sql_stmt
	exec(@sql_stmt)   



	 if @report_format=1 
		 SET @sql_stmt='     
		  select Type,Resource,
			[Beginning  Balance],      
			[Compliance Year  Received],      
  			[Sold],      
  			[Total Compliance Year  Avail],      
  			[Retired for Compliance],      
  			[Retired for Other States],      
  			[Expiring Year End],      
  			[Ending  Balance],      
  			[Eligibility Ends Year+1],      
  			[Eligibility Ends Year+2]  '+  @str_batch_table+ '    
		  from #temp_compliance
		  where	[Beginning  Balance] <> 0 OR
			[Compliance Year  Received] <> 0 OR
			[Sold] <> 0 OR
			[Total Compliance Year  Avail] <> 0 OR
			[Retired for Compliance] <> 0 OR
			[Retired for Other States] <> 0 OR     
			[Expiring Year End] <> 0 OR     
			[Ending  Balance] <> 0 OR     
			[Eligibility Ends Year+1] <> 0 OR     
			[Eligibility Ends Year+2] <> 0 '
		      
	 ELSE IF @report_format=2   
	 BEGIN 	
			set @sql_stmt='select Type,Resource,
				[Beginning  Balance],   
				[PriorVintagesRECSales],   
   				[Expiring Year End],     
				[Beginning  Balance]-[PriorVintagesRECSales]-[Expiring Year End] AS [Vintage Expired in Current Years],
				[Compliance Year  Received],
   				[Total Compliance Year  Avail] as [ Available],        
				[Sold],
				[Total Compliance Year  Avail]-[Sold] AS [Comp Year Total RECs Avail],
				[TotalRECsAvailable],
				[TotalRECsAvailable]+[bonus] AS [TotalRECsAvailable with Bonus],
   				[Retired for Compliance] as [RECs  Retired],      
				[RetiredBonus] as [RECs  Retired Bonus],	
				[Retired for Compliance]+[RetiredBonus] AS [Total RECs Retired],
				[TotalRECsAvailable]-[Retired for Compliance] AS [RECs Carried Forward],
				[TotalRECsAvailable]+[bonus]-[Retired for Compliance]+[RetiredBonus] AS [RECs Carried Forward with Bonus]	
   				'+  @str_batch_table+ '     
			  from #temp_compliance      
			  where 1=1	'
	END
	else if @report_format=3  
		set @sql_stmt='
			select Type,Resource,GenId, 
			[Beginning  Balance],      
			[Compliance Year  Received],      
			[Sold],      
			[Total Compliance Year  Avail],      
			[Retired for Compliance],      
			[Retired for Other States],      
			[Expiring Year End],      
			[Ending  Balance]   '+  @str_batch_table+ ' 
			from #temp_compliance    
			where
			[Beginning  Balance] <> 0 OR     
			[Compliance Year  Received] <> 0 OR      
			[Sold] <> 0 OR      
			[Total Compliance Year  Avail] <> 0 OR      
			[Retired for Compliance] <> 0 OR      
			[Retired for Other States] <> 0 OR      
			[Expiring Year End] <> 0 OR      
			[Ending  Balance] <> 0'

 END        
   -- EXEC spa_print @sql_stmt   
     exec(@sql_stmt)   
END        
ELSE IF @drill_down_level = 44        
BEGIN        
  
	If @drill_value IS NULL         
	BEGIN  
		select name [Renewable Resource], Counterparty Purchaser, sum(volume) [ Sold],
		cast(round(sum(Settlement), 2) as varchar) [Total $ Received],
		cast(round(sum(Settlement)/nullif(sum(volume), 0), 2) as varchar) [$/REC]        

		from #temp        
		where year(Expiration) >= @compliance_year --1. has not expired        
		and year(deal_date) = @compliance_year --2. sold in the current year        
		and (buy_sell_flag = 's' and (assignment_type_value_id is null or assignment_type_value_id=5173))--3. only sold        
		group by name, counterparty
		having sum(volume) <> 0 OR sum(Settlement) <> 0

	 END        
	 ELSE        
	 BEGIN        
		SELECT        
		[name] Resource,        
		dbo.FNAEmissionHyperlink(2,10131010, cast(SourceDealId as varchar),         
		cast(SourceDealId as varchar),NULL) ID,         
		NULL [Cert# From],        
		NULL [Cert# To],        
		RefDealId RefId,          
		isnull(b.code, '') [Assigned Jurisdiction],         
		isnull(a.code, '') AssignedType,        
		isnull(curve_name, '') [Env Product],        
		isnull(cast(compliance_year as varchar), '')  [Year],        
		dbo.FNADateFormat(gen_date) Vintage,         
		case when (buy_sell_flag='b') then  'Buy' else 'Sell' end [Buy/Sell],        
							dbo.FNADateFormat(Expiration) Expiration,          
							dbo.FNADateFormat(deal_date)[Date],         
							HE as HE,        
							Counterparty,        
							case when status_value_id=5183 and buy_sell_flag='s' then -1 else 1 end * volume [Volume MWh],        
							bonus [Bonus MWh],        
							case when status_value_id=5183 and buy_sell_flag='s' then -1 else 1 end * volume + bonus [Total Volume MWh (+Long/-Short)],        
							Settlement [Settlement $]        
							from #temp left outer join        
							 static_data_value a on a.value_id = assignment_type_value_id left outer join        
							 static_data_value b on a.value_id = assigned_state        
							where year(Expiration) >= @compliance_year --1. has not expired        
							and year(deal_date) = @compliance_year --2. sold in the current year        
							and (buy_sell_flag = 's' and (assignment_type_value_id is null or assignment_type_value_id=5173))--3. only sold        
							and Counterparty = @drill_value          
	END        
END        
ELSE IF @drill_down_level = 77        
BEGIN        

	select result.type Type, result.name Resource from        
	(        
	select main.type, main.name, count(*) Total        
	from (select distinct generator_id, type, name from #temp) 
	main 
	--inner join rec_gen_eligibility rge on rge.generator_id = main.generator_id         
	group by main.type,  main.name        
	having (count(*)) = 1) result        
        
END        
        
  
        
--*****************FOR BATCH PROCESSING**********************************      
IF  @batch_process_id is not null  
 BEGIN  
 SELECT @str_batch_table=dbo.FNABatchProcess('u',@batch_process_id,@batch_report_param,GETDATE(),NULL,NULL)   
 EXEC(@str_batch_table)  
  
 SELECT @str_batch_table=dbo.FNABatchProcess('c',@batch_process_id,@batch_report_param,GETDATE(),  
 'spa_create_rec_compliance_report','Compliance Report')   
 EXEC(@str_batch_table)  
  
 END  
--********************************************************************  
  
  
  
  
  
 

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
























