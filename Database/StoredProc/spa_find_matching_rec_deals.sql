

/****** Object:  StoredProcedure [dbo].[spa_find_matching_rec_deals]    Script Date: 11/12/2009 01:30:39 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_find_matching_rec_deals]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_find_matching_rec_deals]
/****** Object:  StoredProcedure [dbo].[spa_find_matching_rec_deals]    Script Date: 11/12/2009 01:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[spa_find_matching_rec_deals]
  @flag varchar(1)=NULL,	  
  @fas_sub_id varchar(5000) = null,  
  @fas_strategy_id varchar(5000) = null, 
  @fas_book_id varchar(5000) = null,  
  @assignment_type int,  
  @assigned_state int,  
  @compliance_year int,   
  @assigned_date varchar(20),  
  @fifo_lifo varchar(1),  -- 'f'-> order by vintage, 'l'-> order by price
  @volume float,  
  @curve_id int = NULL,  
  @table_name varchar(128) = NULL,  
  @unassign int = 0,  
  @convert_uom_id float,  
  @gen_state int=NULL,  
  @gen_year int=NULL,  
  @gen_date_from datetime=NULL,  
  @gen_date_to datetime=NULL,  
  @generator_id int=NULL,  
  @counterparty_id int=NULL,
  @cert_from int=NULL,
  @cert_to int=NULL  ,
  @deal_id varchar(100)=null,
  @udf_group1 INT=NULL,
  @udf_group2 INT=NULL,
  @udf_group3 INT=NULL,
  @tier_type INT=NULL,
  @program_scope INT=NULL			
    
AS  
  
SET NOCOUNT ON  


--set @convert_uom_id = 24  
--EXEC spa_print 'in :' + dbo.FNAGetSQLStandardDateTime(getdate())  
	

--------------------------------------------------  
/*
DECLARE @assigned_state int  
DECLARE @compliance_year int   
DECLARE @fas_sub_id  varchar(5000)  
DECLARE @fas_strategy_id  varchar(5000)  
DECLARE @fas_book_id varchar(5000)  
DECLARE @assignment_type int  
DECLARE @assigned_date varchar(20)  
--DECLARE @assigned_counterparty int  
--DECLARE @assigned_price float  
--DECLARE @trader_id int  
DECLARE @fifo_lifo varchar(1)  
DECLARE @volume int  
DECLARE @curve_id int  
DECLARE @table_name varchar(100)  
DECLARE @unassign int  
DECLARE @convert_uom_id int  
DECLARE @gen_state int  
DECLARE @gen_year int  
DECLARE @gen_date_from datetime
DECLARE @gen_date_to datetime
DECLARE @generator_id int
DECLARE @counterparty_id int
declare @FLAG CHAR(1)
--DECLARE @frequency varchar(1)  
--   
SET @assignment_type = 5173  
set @fas_sub_id = null
set @fas_strategy_id = NULL  
SET @fas_book_id = 192
--SET @fas_book_id = '120, 108' --sps.generation.native  
--SET @assignment_type = 5173  
--set @assigned_state = 5098  
SET @compliance_year = 2006  
SET @assigned_date = '08/20/2007'  
--SET @assigned_counterparty = 2  
--SET @assigned_price = 2.89  
--SET @trader_id = 1  
SET @fifo_lifo = 'f'  
SET @volume = 100  
SET @curve_id = 96  
--SET @table_name = 'adiha_process.dbo.test_assign'  
SET @unassign = 0 --1 means yes 0 means no  
SET @convert_uom_id = 26 -- MWh  
--SET @frequency = 'h'  
  
drop table #temp  
drop table #temp_exclude  
drop table #temp_include  
drop table #ssbm  
drop table #conversion  
drop table #bonus  
*/
-------------------------------------------  
--Can't find deals for assigning to banked state  
  
-- If isnull(@assignment_type, 5149) = 5149  
-- begin  
--  Select 'Error' ErrorCode, 'Find RECs' Module, 'spa_find_matching_rec_deals', 'Invalid Category' Status,   
--   ('You can not assign RECs deal  to Banked Category as non assigned RECs are banked by default.')  Message,   
--   'Please select another category to assign.' Recommendation    
--  RETURN  
-- end  
  
--DECLARE @table_name varchar(500)  

DECLARE @to_uom_id int
set @to_uom_id=@convert_uom_id

  
DECLARE @convert_uom_id_s varchar(50)  
  
set @convert_uom_id_s = cast(@convert_uom_id as varchar)  
  
--print 'XX ' + @conver_uom_id_s  
  
-- DECLARE @mwh_tons_conv_factor1 float  
-- DECLARE @mwh_tons_conv_factor2 float  
-- DECLARE @mwh_tons_conv_factor float  
  
--FIND MWh to Tons (short) conversion factor  
-- SET @mwh_tons_conv_factor1 = null  
-- SET @mwh_tons_conv_factor2 = null  
  
-- IF @assigned_state IS NOT NULL  
-- BEGIN  
--  SELECT  @mwh_tons_conv_factor1 = conversion_factor   
--  FROM    rec_volume_unit_conversion  
--  WHERE   (state_value_id = @assigned_state) AND   
--   (curve_id = @curve_id) AND (from_source_uom_id = 24) AND (to_source_uom_id = 29) AND   
--          (assignment_type_value_id = 5148)  
--    
--  SELECT  @mwh_tons_conv_factor2 = conversion_factor   
--  FROM    rec_volume_unit_conversion  
--  WHERE   (state_value_id = @assigned_state) AND   
--   (curve_id IS NULL) AND (from_source_uom_id = 24) AND (to_source_uom_id = 29) AND   
--          (assignment_type_value_id = 5148)  
-- END  
  
-- set @mwh_tons_conv_factor = isnull(@mwh_tons_conv_factor1, @mwh_tons_conv_factor2)  
  
--print @mwh_tons_conv_factor  
  
  
if @convert_uom_id IS NULL  
BEGIN  
 Select 'Error' ErrorCode, 'Assign RECs' Module, 'spa_assign_rec_deals_job', 'Invalid State' Status,   
  ('Units of Measure must be selected.')  Message,   
  'Please input Units of Measure.' Recommendation    
 Return  
END  
  
  
--if @assignment_type = 5173 AND @curve_id IS NULL  
--BEGIN  
-- Select 'Error' ErrorCode, 'Assign RECs' Module, 'spa_assign_rec_deals_job', 'Invalid State' Status,   
--  ('Renewable obligation is required for assignment to SOLD category.')  Message,   
--  'Please input renewable obligation.' Recommendation    
-- Return  
--END  
  
-- if @assignment_type NOT IN (5149, 5173, 5144) AND @assigned_state IS NULL  
-- BEGIN  
--  Select 'Error' ErrorCode, 'Assign RECs' Module, 'spa_assign_rec_deals_job', 'Invalid State' Status,   
--   ('State is required of assignment.')  Message,   
--   'Please input State.' Recommendation    
--  Return  
-- END  
  
-- if isnull(@total_tons, 0) <> 0 AND @mwh_tons_conv_factor IS NULL  
-- BEGIN  
--  Select 'Error' ErrorCode, 'Assign RECs' Module, 'spa_assign_rec_deals_job', 'Invalid State' Status,   
--   ('Conversion rates to Tons not found for selected input.')  Message,   
--   'Please enter conversion rate.' Recommendation    
--  Return  
-- END  
  

-- if isnull(@volume, 0) = 0 --AND isnull(@total_tons, 0) = 0  
-- BEGIN  
--  Select 'Error' ErrorCode, 'Assign RECs' Module, 'spa_assign_rec_deals_job', 'Invalid Volume' Status,   
--   ('Volume in MWh or Tons is required. Please make sure appropriate Volume is entered.')  Message,   
--   'Please enter volume.' Recommendation    
--  Return  
-- END  
  
-- if isnull(@total_tons, 0) <> 0 AND @assigned_state IS NULL  
-- BEGIN  
--  Select 'Error' ErrorCode, 'Assign RECs' Module, 'spa_assign_rec_deals_job', 'Invalid State' Status,   
--   ('When volume in Tons is provided, State must be entered for conversion factor.')  Message,   
--   'Please input State.' Recommendation    
--  Return  
-- END  
  
------------------------------------------------------------------------------------------------------------------------  
--------------------------------------------BEGIN OF DATA PRE-LOAD IN DENORMALIZED WAY ---------------------------------  
------------------------------------------------------------------------------------------------------------------------  
  
  
DECLARE @sql_stmt varchar(8000)  
DECLARE @Sql_Select varchar(8000)  
DECLARE @Sql_Where varchar(8000)  
  
set @Sql_Where=''  
  
--******************************************************  
--CREATE source book map table and build index  
--*********************************************************  
CREATE TABLE #ssbm(  
  source_system_book_id1 int,            
 source_system_book_id2 int,            
 source_system_book_id3 int,            
 source_system_book_id4 int,            
 fas_deal_type_value_id int,            
 book_deal_type_map_id int,            
 fas_book_id int,            
 stra_book_id int,            
 sub_entity_id int            
)  
----------------------------------  
SET @Sql_Select=  
'INSERT INTO #ssbm            
SELECT            
 source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,fas_deal_type_value_id,            
  book_deal_type_map_id,book.entity_id fas_book_id,book.parent_entity_id stra_book_id, stra.parent_entity_id sub_entity_id             
FROM            
 source_system_book_map ssbm             
INNER JOIN            
 portfolio_hierarchy book (nolock)             
ON             
  ssbm.fas_book_id = book.entity_id             
INNER JOIN            
 Portfolio_hierarchy stra (nolock)            
 ON            
  book.parent_entity_id = stra.entity_id             
            
WHERE 1=1 '            
IF @fas_sub_id IS NOT NULL            
  SET @Sql_Where = @Sql_Where + ' AND stra.parent_entity_id IN  ( ' + @fas_sub_id + ') '             
 IF @fas_strategy_id IS NOT NULL            
  SET @Sql_Where = @Sql_Where + ' AND (stra.entity_id IN(' + @fas_strategy_id + ' ))'            
 IF @fas_book_id IS NOT NULL            
  SET @Sql_Where = @Sql_Where + ' AND (book.entity_id IN(' + @fas_book_id + ')) '            
SET @Sql_Select=@Sql_Select+@Sql_Where            
EXEC (@Sql_Select)            



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

--******************************************************  
--CREATE Bonus table and build index  
--*********************************************************  
  
CREATE TABLE #bonus(  
 state_value_id int,  
 technology int,  
 assignment_type_value_id int,  
 from_date datetime,  
 to_date datetime,  
 gen_code_value int,  
 bonus_per Float  
)  
  
INSERT INTO #bonus  
select  COALESCE(bS.state_value_id, bA.state_value_id) state_value_id,  
 COALESCE(bS.technology, bA.technology) technology,  
 COALESCE(bS.assignment_type_value_id, bA.assignment_type_value_id) assignment_type_value_id,  
 COALESCE(bS.from_date, bA.from_date) from_date,  
 COALESCE(bS.to_date, bA.to_date) to_date,  
 COALESCE(bS.gen_code_value, bA.gen_code_value) gen_code_value,  
 COALESCE(bS.bonus_per, bA.bonus_per) bonus_per  
from  
(select state_value_id, technology, isnull(assignment_type_value_id, 5149) assignment_type_value_id, from_date, to_date,   
gen_code_value, bonus_per  
from state_properties_bonus where gen_code_value is not null  
) bS  
full outer join  
(  
select state_value_id, technology, assignment_type_value_id, from_date, to_date,   
state.value_id as gen_code_value, bonus_per  
from  
(select state_value_id, technology, isnull(assignment_type_value_id, 5149) assignment_type_value_id, from_date, to_date,   
 bonus_per, 1 as link_id  
from state_properties_bonus where gen_code_value is  null) bonus INNER JOIN  
(select value_id, 1 as link_id from static_data_value where type_id = 10002) state  
on state.link_id = bonus.link_id  
) bA on bA.state_value_id = bs.state_value_id and bA.technology = bS.technology and  
bA.assignment_type_value_id = bS.assignment_type_value_id and  
bA.from_date = bs.from_date and bA.to_date = bs.to_date  
--------------------------------------------------------------  
CREATE  INDEX [IX_bonus1] ON [#bonus](state_value_id)        
CREATE  INDEX [IX_bonus2] ON [#bonus]([technology])        
CREATE  INDEX [IX_bonus3] ON [#bonus]([assignment_type_value_id])        
CREATE  INDEX [IX_bonus4] ON [#bonus]([from_date])        
CREATE  INDEX [IX_bonus5] ON [#bonus]([to_date])        
CREATE  INDEX [IX_bonus6] ON [#bonus]([gen_code_value])        
--------------------------------------------------------------  
--******************************************************  
--End of bonus table  
--*********************************************************  

set @sql_stmt = ''  
  
  
--EXEC spa_print 'after figuring books :' + dbo.FNAGetSQLStandardDateTime(getdate())  
  
  
CREATE TABLE #temp_1
(  
next_id int identity,  
DealId int,  
DealDate Datetime,  
GenDate Datetime,  
HE varchar(255) COLLATE DATABASE_DEFAULT ,  
Obligation varchar(100) COLLATE DATABASE_DEFAULT ,  
Price float,  
Volume float,  
Bonus float,  
Expiration varchar(100) COLLATE DATABASE_DEFAULT ,  
Counterparty varchar(250) COLLATE DATABASE_DEFAULT ,  
GenCode varchar(250) COLLATE DATABASE_DEFAULT ,  
Generator varchar(250) COLLATE DATABASE_DEFAULT ,
FacilityOwner varchar(250) COLLATE DATABASE_DEFAULT ,  
Label varchar(50) COLLATE DATABASE_DEFAULT ,  
volume_left float,
generator_id int,
ext_deal_id int,
conv_factor float,
source_deal_header_id int,
gen_state varchar(50) COLLATE DATABASE_DEFAULT ,
Expiration_date datetime,
Assigned_date datetime,
status_value_id int
-- CO2_offset_conv_factor float  
)  

CREATE TABLE #temp
(  
	next_id int,  
	DealId int,  
	DealDate Datetime,  
	GenDate Datetime,  
	HE varchar(255) COLLATE DATABASE_DEFAULT ,  
	Obligation varchar(100) COLLATE DATABASE_DEFAULT ,  
	Price float,  
	Volume float,  
	Bonus float,  
	Expiration varchar(100) COLLATE DATABASE_DEFAULT ,  
	Counterparty varchar(250) COLLATE DATABASE_DEFAULT ,  
	GenCode varchar(250) COLLATE DATABASE_DEFAULT ,  
	Generator varchar(250) COLLATE DATABASE_DEFAULT ,
	FacilityOwner varchar(250) COLLATE DATABASE_DEFAULT ,  
	Label varchar(50) COLLATE DATABASE_DEFAULT ,  
	volume_left float,
	generator_id int,
	ext_deal_id int,
	conv_factor float,
	source_deal_header_id int,
	gen_state varchar(50) COLLATE DATABASE_DEFAULT ,
	Expiration_date datetime,
	Assigned_date datetime,
	status_value_id int
)  
	
  
set @sql_where=''  
If @unassign = 0  
	BEGIN  
	 set @sql_stmt =   
	 '
		insert into  #temp_1  
		  (
			  DealId,  
			  DealDate,  
			  GenDate,  
			  HE,  
			  Obligation,  
			  Price,  
			  Volume,  
			  Bonus,  
			  Expiration,  
			  Counterparty,  
			  GenCode,  
			  Generator,
			  FacilityOwner,  
			  Label,  
			  volume_left,
			  generator_id,
			  conv_factor,
			  source_deal_header_id,
			  gen_state,
			  Expiration_date,
			  status_value_id				

		  )  
	  select 	  
		  sdd.source_deal_detail_id as DealID,  
		  sdh.deal_date DealDate,   
		  sdd.term_start GenDate,  
		  NULL,	 
		  spcd.curve_name Obligation,  
		  isnull(cast(sdd.fixed_price as NUMERIC(38,20)), 0) Price, 
		  sdd.deal_volume * COALESCE(conv1.conversion_factor,conv5.conversion_factor,conv2.conversion_factor,conv3.conversion_factor,conv4.conversion_factor,1) Volume,  
		  round(CASE WHEN (isnull(sdh.status_value_id , 5171) IN (5171, 5177)) THEN  isnull(spbAll.bonus_per, 0) * sdd.deal_volume   
				ELSE 0 END * COALESCE(conv1.conversion_factor,conv5.conversion_factor,conv2.conversion_factor,conv3.conversion_factor,conv4.conversion_factor,1),0) Bonus,  
		  state.code +  '': '' + dbo.FNADEALRECExpirationState(sdd.source_deal_detail_id, sdd.contract_expiration_date, ' + cast(@assignment_type as varchar) + ',rg1.state_value_id) Expiration,  
		  sc.counterparty_name Counterparty,  
		  rg1.code GenCode,
		  rg1.name,  
		  rg1.owner FacilityOwner,  
		  --COALESCE(conv1.uom_label,conv5.uom_label,conv2.uom_label,conv3.uom_label,conv4.uom_label, su.uom_name) uom_label,  
		  su.uom_name uom_label,	
		  sdd.volume_left * COALESCE(conv1.conversion_factor,conv5.conversion_factor,conv2.conversion_factor,conv3.conversion_factor,conv4.conversion_factor,1) Volume_left,
		  sdh.generator_id,
		  COALESCE(conv1.conversion_factor,conv5.conversion_factor,conv2.conversion_factor,conv3.conversion_factor,conv4.conversion_factor,1) as conv_factor,
		  sdh.source_deal_header_id,
		  sd3.code,
		  dbo.FNADEALRECExpirationState(sdd.source_deal_detail_id, sdd.contract_expiration_date, ' + cast(@assignment_type as varchar) + ',rg1.state_value_id) Expiration_date,
		  sdh.status_value_id	
	  FROM 
		  state_properties sp 
		  LEFT OUTER JOIN rec_gen_eligibility rge on sp.state_value_id = rge.state_value_id 
			 AND rge.state_value_id='+CAST(@assigned_state AS VARCHAR)+'
		  LEFT JOIN rec_generator rg1 ON  rg1.gen_state_value_id=rge.gen_state_value_id	
		 	AND (rge.technology=rg1.technology OR rge.technology IS NULL)
			AND (rge.tier_type=rg1.tier_type OR rge.tier_type IS NULL)
		  INNER JOIN source_deal_header sdh ON sdh.generator_id=rg1.generator_id
		  INNER JOIN source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id 
			 AND (sdd.buy_sell_flag = ''b'' or (sdd.buy_sell_flag = ''s'' and isnull(sdh.status_value_id, 5171)=5180))	
		  INNER JOIN #ssbm ssbm ON sdh.source_system_book_id1 = ssbm.source_system_book_id1		
			AND sdh.source_system_book_id2 = ssbm.source_system_book_id2
			AND sdh.source_system_book_id3 = ssbm.source_system_book_id3   
			AND sdh.source_system_book_id4 = ssbm.source_system_book_id4  
		  INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=sdd.curve_id     
				AND rge.program_scope=spcd.program_scope_value_id

		  LEFT OUTER JOIN source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id  
		  LEFT OUTER JOIN static_data_value state on state.value_id = rg1.state_value_id
		  LEFT OUTER JOIN source_uom su on su.source_uom_id = sdd.deal_volume_uom_id	  
		  LEFT OUTER JOIN #bonus spbAll ON spbAll.state_value_id = sp.state_value_id  
			AND spbAll.technology = rg1.technology
			AND isnull(spbAll.assignment_type_value_id, 5149) =  ' + cast(@assignment_type as varchar) + '
			AND sdd.term_start between spbAll.from_date and spbAll.to_date
			AND spbAll.gen_code_value = rg1.gen_state_value_id  	  
		  LEFT OUTER JOIN rec_volume_unit_conversion Conv1 ON  conv1.from_source_uom_id  = sdd.deal_volume_uom_id             
			AND conv1.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id as varchar),'NULL')+'            
			And conv1.state_value_id = state.value_id
			AND conv1.assignment_type_value_id = ' + cast(@assignment_type as varchar) + '  
			AND conv1.curve_id = sdd.curve_id   
			AND conv1.to_curve_id IS NULL      
		  LEFT OUTER JOIN rec_volume_unit_conversion Conv2 ON conv2.from_source_uom_id = sdd.deal_volume_uom_id 
			 AND conv2.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id as varchar),'NULL')+'            
			 And conv2.state_value_id IS NULL
			 AND conv2.assignment_type_value_id = ' + cast(@assignment_type as varchar) + '  
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
			 AND conv4.to_curve_id IS NULL      
		   LEFT OUTER JOIN rec_volume_unit_conversion Conv5 ON conv5.from_source_uom_id  = sdd.deal_volume_uom_id              
			 AND conv5.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id as varchar),'NULL')+'            
			 And conv5.state_value_id = state.value_id
			 AND conv5.assignment_type_value_id is null
			 AND conv5.curve_id = sdd.curve_id 
			 AND conv5.to_curve_id IS NULL      
		  LEFT JOIN gis_certificate gis on gis.source_deal_header_id=sdd.source_deal_detail_id
		  LEFT JOIN static_data_value sd3 on sd3.value_id=rg1.gen_state_value_id	   
		
		WHERE  
			  sdd.deal_volume>=0
			  AND ssbm.fas_deal_type_value_id <> 402   
			  AND isnull(sdh.assignment_type_value_id, 5149) = 5149 
			  AND isnull(sp.begin_date, sdh.deal_date) <= sdh.deal_date 
			  AND isnull(sdh.status_value_id, 5171) NOT IN (5170, 5179)   
			  AND sdd.buy_sell_flag = ''b''  
			  AND isnull(rg1.exclude_inventory,''n'')=''n''
			' +   
		  
			  --Can sale REC Offsets?  
			  ' AND ( (' + cast(@assignment_type as varchar) + ' <> 5173 ) OR (' +  cast(@assignment_type as varchar) + ' = 5173   
				AND (ISNULL(rg1.gen_offset_technology,''n'') = ''n'' OR (ISNULL(rg1.gen_offset_technology,''n'') = ''y'' AND sp.offset_trade = ''y'')))) '+
		  
		--Convert to CO2 Offsets  
			 ' AND ((' + cast(@assignment_type as varchar) + ' <> 5148 ) OR (' +  cast(@assignment_type as varchar) + ' = 5148     
			   AND isnull(sp.qualifies_for_CO2_offsets, ''n'') = ''y''    
			   AND isnull(sdh.aggregate_environment, isnull(rg1.aggregate_environment, ''n'')) = ''y''))
			   AND sdh.deal_date <= DBO.FNAGetSQLStandardDate(''' + @assigned_date + ''') 
			   AND sdd.term_start <= CASE WHEN (isnull(sp.bank_assignment_required, ''n'') = ''n'') THEN  DBO.FNAGetSQLStandardDate(''' + @assigned_date + ''')  else sdd.term_start end '

			  + CASE WHEN  ISNULL(@assignment_type,5146)=5173 then  
				  ' and dbo.FNADEALRECExpirationState(sdd.source_deal_detail_id, sdd.contract_expiration_date, ' + cast(@assignment_type as varchar) + ', rg1.state_value_id) >= cast(''' + @assigned_date + ''' as datetime) '
			  else	
				  ' and year(dbo.FNADEALRECExpirationState(sdd.source_deal_detail_id, sdd.contract_expiration_date, ' + cast(@assignment_type as varchar) + ', ISNULL(rg1.state_value_id,''''))) >= ' + cast(@compliance_year as varchar) end
			 
			 + CASE WHEN @deal_id is not null then ' AND sdh.source_deal_header_id='+@deal_id else
			 + CASE WHEN (@curve_id IS NULL) then '' else ' AND sdd.curve_id = ' + cast(@curve_id as varchar) end   
			 + CASE WHEN (@gen_state IS NULL) then '' else ' AND  rg1.gen_state_value_id = ' + cast(@gen_state as varchar) end  
			 + CASE WHEN (@gen_year IS NULL) then '' else ' AND  year(sdd.term_start) = ' + cast(@gen_year as varchar) end  
			 + CASE WHEN (@gen_date_from IS NULL) then '' else ' AND  sdd.term_start BETWEEN ''' + cast(@gen_date_from as varchar)+ ''' AND ''' + cast(@gen_date_to as varchar)+ '''' end  
			 + CASE WHEN (@generator_id IS NULL) then '' else ' AND  rg1.generator_id = ' + cast(@generator_id as varchar) end  
			 + CASE WHEN (@counterparty_id IS NULL) then '' else ' AND  sdh.counterparty_id = ' + cast(@counterparty_id as varchar) end  
			 + CASE WHEN @udf_group1 IS NOT NULL THEN ' AND rg1.udf_group1='+CAST(@udf_group1 AS VARCHAR) ELSE '' END
			 + CASE WHEN @udf_group2 IS NOT NULL THEN ' AND rg1.udf_group2='+CAST(@udf_group2 AS VARCHAR) ELSE '' END
			 + CASE WHEN @udf_group3 IS NOT NULL THEN ' AND rg1.udf_group3='+CAST(@udf_group3 AS VARCHAR) ELSE '' END
			 + CASE WHEN @tier_type IS NOT NULL THEN ' AND rg1.tier_type='+CAST(@tier_type AS VARCHAR) ELSE '' END
			 + CASE WHEN @program_scope IS NOT NULL THEN ' AND spcd.program_scope_value_id='+CAST(@program_scope AS VARCHAR) ELSE '' END
			 --bank_assignment_required used as Are RECs forward allowed for compliance??  

			+ CASE WHEN (isnull(@assigned_state,'')<>'') then
			 ' AND ((rge.state_value_id='+cast(@assigned_state as varchar)+'))'
				   else ' '  end end+

	 ' order by '
			  + CASE WHEN @fifo_lifo='l' THEN ' sdd.fixed_price,' ELSE '' END +	
			  'year(dbo.FNADEALRECExpirationState(sdd.source_deal_detail_id, sdd.contract_expiration_date, ' + cast(@assignment_type as varchar) + ', ISNULL(rg1.state_value_id,''''))) asc,  
			  sdd.term_start asc,   
			  cast((CASE WHEN (isnull(deal_detail_description, '''') = '''') then  0 else deal_detail_description end) as int) asc,   
			  sdh.source_deal_header_id asc' 

		EXEC spa_print @sql_Stmt   
		exec (@sql_Stmt)  

	END  
ELSE  
	BEGIN  
	 set @sql_stmt =   
	 'insert into  #temp_1  
	  (
	  DealId,  
	  DealDate,  
	  GenDate,  
	  HE,  
	  Obligation,  
	  Price,  
	  Volume,  
	  Bonus,  
	  Expiration,  
	  Counterparty,  
	  GenCode,  
	  FacilityOwner,
	  Generator,  
	  Label,
	  generator_id,
	  ext_deal_id,
	  conv_factor,
	  gen_state,
	  assigned_date,
	  source_deal_header_id,
	  status_value_id	 		    
	)  
	 select
		   
	  sdd.source_deal_detail_id as DealID,  
	  dbo.FNADateFormat(sdh.deal_date) DealDate,   
	  dbo.FNADateFormat(sdd.term_start) AssignedDate,   
	  NULL as HE,  
	  COALESCE(Conv1.curve_label,Conv5.curve_label,Conv2.curve_label,Conv3.curve_label,Conv4.curve_label, spcd.curve_name) Obligation,  
	  isnull(cast(sdd.fixed_price as NUMERIC(38,20)), 0) Price,  
	  sdd.deal_volume * COALESCE(conv1.conversion_factor,conv5.conversion_factor,conv2.conversion_factor,conv3.conversion_factor,conv4.conversion_factor,0) Volume,  
	  
	  ROUND(CASE WHEN (isnull(sdh.status_value_id , 5171) IN (5171, 5177)) THEN  
	   isnull(spbAll.bonus_per, 0)  
	   * sdd.deal_volume   
	  ELSE 0 END * COALESCE(conv1.conversion_factor,conv5.conversion_factor,conv2.conversion_factor,conv3.conversion_factor,conv4.conversion_factor,0),0) Bonus,  
	  
	  state.code +  '': '' +   
	   dbo.FNADEALRECExpiration(sdh.source_deal_header_id, sdd.contract_expiration_date, ' + cast(@assignment_type as varchar) + ' ) Expiration,  
	  sc.counterparty_name Counterparty,  
	  rg1.code GenCode,  
	  rg1.name,
	  rg1.owner FacilityOwner,  
	  --COALESCE(conv1.uom_label,conv5.uom_label,conv2.uom_label,conv3.uom_label,conv4.uom_label) uom_label,
	  su.uom_name as label,
	  sdh.generator_id,	
	  sdh.ext_deal_id,
	  COALESCE(conv1.conversion_factor,conv5.conversion_factor,conv2.conversion_factor,conv3.conversion_factor,conv4.conversion_factor,0) as conv_factor,      
	  sd3.code,
	  assign.assigned_date,
	  sdd.source_deal_header_id,
	  sdh.status_value_id		 
	  from source_deal_header  sdh   INNER JOIN
	  source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
	  INNER JOIN  
	  assignment_audit assign  
	  on sdd.source_deal_detail_id=assign.source_deal_header_id  
	  INNER JOIN  
	  #ssbm ssbm ON  
	  sdh.source_system_book_id1 = ssbm.source_system_book_id1 AND   
	  sdh.source_system_book_id2 = ssbm.source_system_book_id2 AND  
	  sdh.source_system_book_id3 = ssbm.source_system_book_id3 AND   
	  sdh.source_system_book_id4 = ssbm.source_system_book_id4  

	  INNER JOIN   
	  rec_generator rg on rg.generator_id = sdh.generator_id   

	  LEFT OUTER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=sdd.curve_id     
	  LEFT OUTER JOIN rec_gen_eligibility rge on rge.state_value_id = rg.state_value_id 
		AND (rge.technology=rg.technology OR rge.technology IS NULL)
		AND rge.program_scope=spcd.program_scope_value_id
		AND (rge.tier_type=rg.tier_type OR rge.tier_type IS NULL)
	  LEFT OUTER JOIN state_properties sp on sp.state_value_id = rg.state_value_id
	  LEFT OUTER JOIN rec_generator rg1 ON rg1.generator_id=rg.generator_id
		AND rg1.gen_state_value_id=rge.gen_state_value_id		  
	  LEFT OUTER JOIN source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id  
	  LEFT OUTER JOIN static_data_value state on state.value_id = ISNULL(assign.state_value_id,rg1.state_value_id)  
  
	  LEFT OUTER JOIN #bonus spbAll ON  
		spbAll.state_value_id = sp.state_value_id and   
		spbAll.technology = rg1.technology and  
		isnull(spbAll.assignment_type_value_id, 5149) =' + cast(@assignment_type as varchar) + '   and  
		sdd.term_start between spbAll.from_date and spbAll.to_date and  
		spbAll.gen_code_value = rg1.gen_state_value_id  
	        
	  
	LEFT OUTER JOIN rec_volume_unit_conversion Conv1 ON            
	 conv1.from_source_uom_id  = sdd.deal_volume_uom_id             
	 AND conv1.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id as varchar),'NULL')+'            
	 And conv1.state_value_id = state.value_id
	 AND conv1.assignment_type_value_id = ' + cast(@assignment_type as varchar) + '  
	 AND conv1.curve_id = sdd.curve_id             
	 AND conv1.to_curve_id IS NULL

	LEFT OUTER JOIN rec_volume_unit_conversion Conv2 ON            
	 conv2.from_source_uom_id = sdd.deal_volume_uom_id             
	 AND conv2.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id as varchar),'NULL')+'            
	 And conv2.state_value_id IS NULL
	 AND conv2.assignment_type_value_id = ' + cast(@assignment_type as varchar) + '  
	 AND conv2.curve_id = sdd.curve_id  
	 AND conv2.to_curve_id IS NULL

	LEFT OUTER JOIN rec_volume_unit_conversion Conv3 ON            
	conv3.from_source_uom_id =  sdd.deal_volume_uom_id             
	 AND conv3.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id as varchar),'NULL')+'            
	 And conv3.state_value_id IS NULL
	 AND conv3.assignment_type_value_id IS NULL
	 AND conv3.curve_id = sdd.curve_id 
	 AND conv3.to_curve_id IS NULL
	       
	LEFT OUTER JOIN rec_volume_unit_conversion Conv4 ON            
	 conv4.from_source_uom_id = sdd.deal_volume_uom_id
	 AND conv4.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id as varchar),'NULL')+'            
	 And conv4.state_value_id IS NULL
	 AND conv4.assignment_type_value_id IS NULL
	 AND conv4.curve_id IS NULL
	 AND conv4.to_curve_id IS NULL

	LEFT OUTER JOIN rec_volume_unit_conversion Conv5 ON            
	 conv5.from_source_uom_id  = sdd.deal_volume_uom_id             
	 AND conv5.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id as varchar),'NULL')+'            
	 And conv5.state_value_id = state.value_id
	 AND conv5.assignment_type_value_id is null
	 AND conv5.curve_id = sdd.curve_id 
	 AND conv5.to_curve_id IS NULL

	left join static_data_value sd3 on sd3.value_id=rg1.gen_state_value_id
	LEFT OUTER JOIN source_uom su on su.source_uom_id = sdd.deal_volume_uom_id	  	   
	 where  ssbm.fas_deal_type_value_id <> 402 AND  
	  isnull(sdh.status_value_id, 5171) NOT IN (5170, 5179)   AND  
	  --inputs  
	  sdh.assignment_type_value_id = ' + cast(@assignment_type as varchar) +
	 
	 + CASE WHEN @deal_id is not null then ' AND sdh.source_deal_header_id='+@deal_id else 
			  ' AND (assign.state_value_id IS NOT NULL AND isnull(assign.state_value_id, -1) ='
	 + CASE WHEN @assigned_state is null then '-1' else cast(@assigned_state as varchar) end +' OR (assign.state_value_id IS NULL)) AND  
		  assign.assigned_date <= cast(''' + @assigned_date + ''' as datetime)  '  
	  
	 + CASE WHEN @compliance_year is null or @assignment_type=5173 then '' else ' AND assign.compliance_year = ' + cast(@compliance_year as varchar) end  
	 + CASE WHEN (@curve_id IS NULL) then '' else ' AND sdd.curve_id = ' + cast(@curve_id as varchar) end   
	 + CASE WHEN (@gen_state IS NULL) then '' else ' AND  rg1.gen_state_value_id = ' + cast(@gen_state as varchar) end  
	 + CASE WHEN (@gen_year IS NULL) then '' else ' AND  year(sdd.term_start) = ' + cast(@gen_year as varchar) end  
	 + CASE WHEN (@gen_date_from IS NULL) then '' else ' AND  sdd.term_start BETWEEN ''' + cast(@gen_date_from as varchar)+ ''' AND ''' + cast(@gen_date_to as varchar)+ '''' end  
	 + CASE WHEN (@generator_id IS NULL) then '' else ' AND  rg1.generator_id = ' + cast(@generator_id as varchar) end  
	 + CASE WHEN (@counterparty_id IS NULL) then '' else ' AND  sdh.counterparty_id = ' + cast(@counterparty_id as varchar) end  
	 + CASE WHEN @udf_group1 IS NOT NULL THEN ' AND rg1.udf_group1='+CAST(@udf_group1 AS VARCHAR) ELSE '' END
	 + CASE WHEN @udf_group2 IS NOT NULL THEN ' AND rg1.udf_group2='+CAST(@udf_group2 AS VARCHAR) ELSE '' END
	 + CASE WHEN @udf_group3 IS NOT NULL THEN ' AND rg1.udf_group3='+CAST(@udf_group3 AS VARCHAR) ELSE '' END
	 + CASE WHEN @tier_type IS NOT NULL THEN ' AND rg1.tier_type='+CAST(@tier_type AS VARCHAR) ELSE '' END
	 + CASE WHEN @program_scope IS NOT NULL THEN ' AND spcd.program_scope_value_id='+CAST(@program_scope AS VARCHAR) ELSE '' END


	 + CASE WHEN (@cert_from is NULL) then '' else
  		' And '+cast(@cert_from as varchar)+' between  gis.certificate_number_from_int  and  gis.certificate_number_to_int  
		 And '+cast(@cert_to as varchar)+' between  gis.certificate_number_from_int  and  gis.certificate_number_to_int ' end 
	 end +    
	 ' ORDER BY assign.assigned_date desc, sdd.term_start desc,   
	  cast((CASE WHEN (isnull(deal_detail_description, '''') = '''') then  0 else deal_detail_description end) as int) desc,  
	  sdd.source_deal_header_id desc'  


	EXEC spa_print @sql_stmt  
	EXEC(@sql_stmt)  
	  
	  
	END  
  
--EXEC spa_print 'after collecting deals :' + dbo.FNAGetSQLStandardDateTime(getdate())  
 
--
DECLARE @DealId INT,@GenDate DATETIME

	DECLARE  cur1 CURSOR FOR
	SELECT DealId,generator_id,GenDate FROM #temp_1
	OPEN cur1
	FETCH NEXT FROM cur1 INTO @DealId,@generator_id,@GenDate
	WHILE @@FETCH_STATUS=0
		BEGIN
		INSERT INTO #temp
			select 
				a.next_id,  
				a.DealId ,  
				a.DealDate ,  
				a.GenDate ,  
				a.HE ,  
				a.Obligation ,  
				a.Price ,  
				a.volume-ISNULL(b.volume,0) Volume ,  
				a.bonus-ISNULL(b.bonus,0) Bonus ,  
				a.Expiration ,  
				a.Counterparty ,  
				a.GenCode ,  
				a.Generator ,
				a.FacilityOwner ,  
				a.Label ,  
				a.volume_left-ISNULL(b.volume_left,0) volume_left ,
				a.generator_id ,
				a.ext_deal_id ,
				a.conv_factor ,
				a.source_deal_header_id ,
				a.gen_state, 
				a.Expiration_date ,
				a.Assigned_date ,
				a.status_value_id 
			FROM	
				(select 
						(DealDate) DealDate,  
						(GenDate)GenDate,  
						(volume) volume,
						(bonus) bonus,
						(volume_left) volume_left,
						generator_id,
						(source_deal_header_id) source_deal_header_id,
						next_id,  
						DealId ,  
						HE ,  
						Obligation ,  
						Price ,  
						Expiration ,  
						Counterparty ,  
						GenCode ,  
						Generator ,
						FacilityOwner ,  
						Label ,  
						ext_deal_id ,
						conv_factor ,
						gen_state, 
						Expiration_date ,
						Assigned_date ,
						status_value_id 
								  
				from 
					#temp_1 
					where isnull(status_value_id,'')<>5180
					AND DealId=@DealId
						 -- group by generator_id,genDate
				)a
				LEFT JOIN 
				(select 
						generator_id,GenDate,sum(volume) volume,sum(bonus)bonus,sum(volume_left)volume_left
					from 
						#temp_1 where isnull(status_value_id,'')=5180
						group by generator_id,GenDate
				)b
				on a.generator_id=b.generator_id
				   and a.gendate=b.gendate
				   and a.volume>=b.volume
				LEFT JOIN
				 #temp c on
				   a.generator_id=c.generator_id
				   and a.gendate=c.gendate
				WHERE
					c.generator_id IS NULL					
				
				FETCH NEXT FROM cur1 INTO @DealId,@generator_id,@GenDate
			END
		CLOSE cur1
		DEALLOCATE cur1
	

INSERT INTO #temp SELECT * FROM #temp_1 WHERE next_id NOT IN(SELECT next_id from #temp) AND isnull(status_value_id,'')<>5180



---########################## create temporary table to insert deals for certificates block
declare @gis_deal_id int,@certificate_f int,@certificate_t int,@cert_from_f int,@cert_to_t int,@bank_assignment int
set @bank_assignment=5149


create TABLE #temp_assign(
source_deal_detail_id int,
cert_from int,
cert_to int,
assignment_type int,
)
create table #temp_cert(
source_deal_header_id int,
certificate_number_from_int int,
certificate_number_to_int int
)

insert #temp_cert
	select gis.source_deal_header_id,gis.certificate_number_from_int,gis.certificate_number_to_int 
	from gis_certificate gis where source_deal_header_id in(select dealid from #temp)
	

DECLARE cursor1 cursor FOR
	select source_deal_header_id,certificate_number_from_int,certificate_number_to_int from #temp_cert

 open cursor1
 fetch next from cursor1
 into
 	@gis_deal_id,@certificate_f,@certificate_t
 
 WHILE @@FETCH_STATUS=0
 BEGIN

	DECLARE cursor2 cursor for 
		select cert_from,cert_to from assignment_audit where source_deal_header_id_from=@gis_deal_id and assigned_volume>0
		order by cert_from
	open cursor2
	fetch next from cursor2
	into @cert_from_f,@cert_to_t
	WHILE @@FETCH_STATUS=0
	BEGIN
		
		
		if @cert_from_f > @certificate_f 
			BEGIN

				insert #temp_assign( source_deal_detail_id,cert_from,cert_TO,assignment_type)
				values (@gis_deal_id, @certificate_f, @cert_from_f - 1,@bank_assignment)
			END

		set @certificate_f=@cert_to_t + 1
		
	fetch next from cursor2
	into @cert_from_f,@cert_to_t
	END
	if (@certificate_f - 1)	< @certificate_t
		begin

			insert #temp_assign( source_deal_detail_id,cert_from,cert_TO,assignment_type)
			values (@gis_deal_id, @certificate_f, @certificate_t,@bank_assignment)
		end
fetch next from cursor1
into
 	@gis_deal_id,@certificate_f,@certificate_t
CLOSE cursor2
DEALLOCATE cursor2	
	
 END	
CLOSE cursor1
DEALLOCATE cursor1	
	


create table #temp_final(
	[ID] int identity,
	source_deal_detail_id int,
	cert_From int,
	cert_to int,
	assignment_type int,
	volume float	
)
insert into #temp_final(source_deal_detail_id,cert_from,cert_to,assignment_type,volume)
select  source_deal_detail_id,cert_from,cert_to,assignment_type,cert_to-cert_from+1 as volume   from (
SELECT source_deal_detail_id,cert_from,cert_to,assignment_type FROM #temp_assign
union all
select source_deal_header_id_from,cert_from,cert_to,assignment_type from assignment_audit
) a order by a.source_deal_detail_id,a.cert_from

-----------##############################################################################



create table #temp_include  
 ( next_id int,  
   deal_id int,  
   volume_assign float,    
   bonus float,    
   volume float,  
   volume_left float  
 
)   



IF isnull(@cert_from,'')<>'' 
BEGIN
	 insert into #temp_include  
	select next_id,dealid,@volume-bonus,bonus,@volume,volume_left-@volume from
	#temp
END

ELSE
BEGIN
	If @unassign = 0  
BEGIN	 insert into #temp_include   select next_id,dealid,
	 CASE WHEN volume_left_cumu-@volume <=0 then volume_left1 else  
	 (volume_left-(volume_left_cumu-@volume))/(1+bonus_per) end  as volume_assign,  
	 CASE WHEN volume_left_cumu-@volume <=0 then volume_left-volume_left1 else  
	 (volume_left-(volume_left_cumu-@volume))-((volume_left-(volume_left_cumu-@volume))/(1+bonus_per)) end  as bonus,
	
	 CASE WHEN volume_left_cumu-@volume <=0 then volume_left else  
	 volume_left-(volume_left_cumu-@volume) end  as Total_volume,
	 CASE WHEN volume_left_cumu-@volume <=0 then volume_left1-volume_left1 else
	 volume_left1-(volume_left-(volume_left_cumu-@volume))/(1+bonus_per) end as Volumeleft	
	
	 from(  
	 select   
	  next_id,dealid,volume,bonus,bonus/CASE WHEN volume=0 then 1 else volume end bonus_per,volume_left+(volume_Left*(bonus/CASE WHEN volume=0 then 1 else volume end)) volume_left,
	  volume_left volume_left1, 	  
	  (select sum(volume_left+(volume_left*(bonus/CASE WHEN volume=0 then 1 else volume end))) from #temp where next_id<=a.next_id) as volume_left_cumu  
	    
	 from   
	  #temp a  
	 ) a   
	   
	 where   
	 CASE WHEN volume_left_cumu-@volume <=0 then volume_left else  
	 volume_left-(volume_left_cumu-@volume) end >0  
END	
ELSE  
	 
	 insert into #temp_include  
	 select next_id,dealid,
	 CASE WHEN volume_cumu-@volume <=0 then volume1 else  
	 (volume-(volume_cumu-@volume))/(1+bonus_per) end  as volume_assign,  
	 CASE WHEN volume_cumu-@volume <=0 then volume-volume1 else  
	 (volume-(volume_cumu-@volume))-((volume-(volume_cumu-@volume))/(1+bonus_per)) end  as bonus,
	 CASE WHEN volume_cumu-@volume <=0 then volume else  
	 volume-(volume_cumu-@volume) end  as Total_volume,
	 volume_left  
	 from(  
	 select   
	  next_id,dealid,volume+(volume*(bonus/CASE WHEN volume=0 then 1 else volume end)) as Volume,bonus,bonus/CASE WHEN volume=0 then 1 else volume end bonus_per,volume_left,Volume as Volume1,  
	  (select sum(volume+(volume*(bonus/CASE WHEN volume=0 then 1 else volume end))) from #temp where next_id<=a.next_id) as volume_cumu  
	    
	 from   
	  #temp a  
	 ) a   
   
--  where   
--  CASE WHEN volume_cumu-@volume <=0 then volume else  
--  volume-(volume_cumu-@volume) end >0  
END
  


DECLARE @select_stmt varchar(8000)  
DECLARE @left_volume FLOAT
SET @select_stmt = ''  

select
	[ID],source_deal_detail_id,cert_from,cert_to,assignment_type,volume,volume_cumu,volume_cumu-@volume AS VOLUME_LEFT  into #temp_final1 from
(
select 
	[ID],source_deal_detail_id,cert_from,cert_to,assignment_type,volume,
	(select sum(volume) from #temp_final where [ID]<=a.[ID] and assignment_type=5149 and source_deal_detail_id=a.source_deal_detail_id )as volume_cumu

 from #temp_final a where assignment_type=5149 
) a
where CASE WHEN volume_cumu-@volume <=0 then volume else  
 volume-(volume_cumu-@volume) end >0  

--select * from #temp_final1

IF @table_name is null or @table_name=''  
 	set @table_name =dbo.FNAProcessTableName('recassign_', dbo.FNADBUser(),REPLACE(newid(),'-','_'))  




if @unassign=0
BEGIN

declare @source_deal_header_id int


--select * from #temp
--select * from #temp_final1
-- Check if the Given certificate number lies within the given range
if @cert_from is not null 

	BEGIN
		if not exists(select * from #temp)
			select * from #temp
		else
		if not exists(
		select 
			assign.*
		from 
			#temp a INNER JOIN 
			#temp_final assign on a.dealid=assign.source_deal_detail_id
		 	where @cert_from between assign.cert_from and assign.cert_to 
			and assignment_type=5149	
		 	and @cert_to between assign.cert_from and assign.cert_to ) 
		BEGIN

		select @source_deal_header_id=source_deal_header_id from #temp
		if @source_deal_header_id is NULL 
		    set @source_deal_header_id=0

		declare @url varchar(5000)
		--print @source_deal_header_id
		set @url='<a href="../../dev/spa_html.php?spa=exec spa_create_lifecycle_of_recs '''+ dbo.FNADateFormat(getdate()) +''',NULL,'+cast(@source_deal_header_id as varchar)+'">Click here...</a>'
		
		  select 'Err',null, 'No Certificate available in the range' as Message, dbo.FNAEmissionHyperlink(31,12121500,' Please click here to view the report ',@source_deal_header_id,dbo.FNADateFormat(getdate())) as Recommendation 

		  Return  
		END

	END


SET @select_stmt  = 
	'select 
	'+ CASE WHEN (@cert_from is NULL) then '' else '
	top 1 ' end + '
	a.DealId [ID], 
	dbo.FNACertificateRule(cr.cert_rule,rg.[ID],'+CASE WHEN @cert_from is not null then cast(@cert_from as varchar) else ' COALESCE(tf.cert_from,assign1.assigned_volume+gis.certificate_number_from_int,gis.certificate_number_from_int)' end+' ,a.GenDate) as [Cert # From],
	dbo.FNACertificateRule(cr.cert_rule,rg.[ID],'+CASE WHEN @cert_from is not null then cast(@cert_to as varchar) else 
		'ISNULL(CASE WHEN tf.cert_from is not null and tf.volume_left+round(isnull(b.Bonus/a.conv_factor, 0), 0)<0 then round(tf.volume-b.volume_left,0)+tf.cert_from-1 else round(tf.volume-b.volume_Left,0)+tf.cert_from-1 end ,
		ISNULL((assign1.assigned_volume-1+b.volume_assign),b.volume_assign-1)+gis.certificate_number_from_int)' end +' ,a.GenDate) as	 [Cert # T0],
	dbo.FNADateFormat(a.DealDate) DealDate,  
	dbo.FNADateFormat(a.GenDate) Vintage,   
	a.Obligation as [Env Product],  
	a.Price,   
 	'+CASE WHEN @cert_from is not null then cast(@volume as varchar) else  '
	CASE WHEN tf.cert_from is not null then 
		CASE WHEN  tf.volume_left <0 then round(tf.volume-b.volume_left/a.conv_factor,0) else round(tf.volume-b.volume_Left/a.conv_factor,0) end 
		     else  round(b.volume_assign/a.conv_factor,0) end ' end + ' as  [Volume Assign],
	round(isnull(b.Bonus/a.conv_factor, 0), 0) Bonus, 
	'+CASE WHEN @cert_from is not null then cast(@volume as varchar) else  '
	CASE WHEN tf.cert_from is not null then
		 CASE WHEN  tf.volume_left+round(isnull(b.Bonus/a.conv_factor, 0), 0)<0 then round(tf.volume-b.volume_left/a.conv_factor,0)+round(isnull(b.Bonus/a.conv_factor, 0), 0) else round(tf.volume-b.volume_Left/a.conv_factor,0)+round(isnull(b.Bonus/a.conv_factor, 0), 0) end 
		 else round(b.volume_assign/a.conv_factor,0)+round(isnull(b.Bonus/a.conv_factor, 0), 0) end ' end + '  as  [Total Volume],  
	round((b.volume_left/a.conv_factor), 0)  [Volume Left],	
	ISNULL(a.label,su.uom_name) UOM,  
	a.Expiration Expiration,   
	a.Counterparty, a.GenCode,a.generator,a.FacilityOwner,
	'+CASE WHEN @cert_from is not null then cast(@cert_from as varchar) else '  COALESCE(tf.cert_from,assign1.assigned_volume+gis.certificate_number_from_int,gis.certificate_number_from_int) ' end +' as cert_from,'
	+CASE WHEN @cert_from is not null then cast(@cert_to as varchar) else '  ISNULL(CASE WHEN tf.cert_from is not null and tf.volume_left+round(isnull(b.Bonus/a.conv_factor, 0), 0)<0 then round(tf.volume-b.volume_left,0)+tf.cert_from-1 else round(tf.volume-b.volume_Left,0)+tf.cert_from-1 end ,
		ISNULL((assign1.assigned_volume-1+b.volume_assign),b.volume_assign)+gis.certificate_number_from_int) ' end +' as cert_to,
	ISNULL(assign1.assigned_volume+gis.certificate_number_from_int,gis.certificate_number_from_int) cert_from1,
	ISNULL((assign1.assigned_volume-1+b.volume_assign),b.volume_assign)+gis.certificate_number_from_int cert_to1,
	a.gen_state,
	expiration_date,
	assigned_date,
	a.source_deal_header_id [Deal ID]
	 ' +  
	CASE WHEN (@table_name IS NULL) then '' else ' INTO ' + @table_name end   
	+'  
	 from  #temp a inner  join #temp_include b  
	on a.next_id=b.next_id
	LEFT JOIN Gis_certificate gis on        
		gis.source_deal_header_id=a.dealid        
	LEFT join rec_generator rg on        
		a.generator_id=rg.generator_id         
	LEFT JOIN        
		certificate_rule cr on isnull(rg.gis_value_id, 5164) = cr.gis_id'+CASE WHEN @cert_from is not null then '
	LEFT OUTER JOIN 
		#temp_final tf on tf.source_deal_detail_id=a.dealid and tf.assignment_type=5149  '
	else ' LEFT OUTER JOIN 
		#temp_final1 tf on tf.source_deal_detail_id=a.dealid and tf.assignment_type=5149  ' end +'

	LEFT JOIN      
	(SELECT source_deal_header_id_from,sum(assigned_volume) assigned_volume from       
	assignment_audit group by source_deal_header_id_from) assign1      
	on assign1.source_deal_header_id_from=a.dealid 
	LEFT Join source_UOM su on su.source_uom_id='+cast(@to_uom_id as varchar) +'
	where 1=1 '
	
	 + CASE WHEN (@cert_from is NULL) then '' else
	  	' And '+cast(@cert_from as varchar)+' between  tf.cert_from  and  tf.cert_to
	 And '+cast(@cert_to as varchar)+' between  tf.cert_from  and  tf.cert_to ' end 

END
else

--SET @select_stmt  = 	
--'select distinct
--	assign.assignment_id [assign_id],
--	a.DealId ID, 
--	dbo.FNACertificateRule(cr.cert_rule,rg.[ID],assign.cert_from,gis.gis_cert_date) as [Cert # From],
--	dbo.FNACertificateRule(cr.cert_rule,rg.[ID],assign.cert_to ,gis.gis_cert_date) as [Cert # T0],
--	dbo.FNADateFormat(a.DealDate) DealDate,  
--	dbo.FNADateFormat(a.GenDate) Vintage,   
--	a.Obligation as [Env Product],  
--	a.Price,   
--	CASE WHEN assign.cert_from is not null then round((assign.cert_to-assign.cert_from+1)/a.conv_factor, 0) else   round((a.volume/a.conv_factor), 0) end as   	
--	[Volume UnAssign],  
--	round(a.Bonus/a.conv_factor, 0) Bonus,   
--	CASE WHEN assign.cert_from is not null then round((assign.cert_to-assign.cert_from+1)/a.conv_factor, 0) else   round((a.volume/a.conv_factor), 0) end as [Total Volume], 
--	su.uom_name UOM,
--	a.Expiration Expiration,   
--	a.Counterparty, a.GenCode,a.generator, a.FacilityOwner,
--	assign.cert_from,
--	assign.cert_to as cert_to,
--	gen_state
--	 
--	' +  
--	CASE WHEN (@table_name IS NULL) then '' else ' INTO ' + @table_name end   
--	+' from  #temp a
--	--  inner  join #temp_include b  
--	--on a.next_id=b.next_id
--	left join assignment_audit assign on assign.source_deal_header_id=a.DealId
-- 	LEFT JOIN Gis_certificate gis on        
-- 		gis.source_deal_header_id=assign.source_deal_header_id_from
-- 	LEFT join rec_generator rg on        
-- 		a.generator_id=rg.generator_id         
-- 	LEFT JOIN        
-- 		certificate_rule cr on rg.gis_value_id=cr.gis_id     
-- 
---- 	LEFT JOIN      
---- 	(SELECT source_deal_header_id_from,sum(assigned_volume) assigned_volume from       
---- 	assignment_audit group by source_deal_header_id_from) assign1      
---- 	on assign1.source_deal_header_id_from=a.ext_deal_id 
--	LEFT Join source_UOM su on su.source_uom_id='+cast(@to_uom_id as varchar)+'
-- where 1=1 and assign.assigned_volume>0 '

SET @select_stmt  = 	
'select distinct
	assign.assignment_id [assign_id],
	a.DealId [ID], 
	dbo.FNACertificateRule(cr.cert_rule,rg.[ID],assign.cert_to-b.volume+1,a.GenDate) as [Cert # From],
	dbo.FNACertificateRule(cr.cert_rule,rg.[ID],assign.cert_to,a.GenDate) as [Cert # T0],
	dbo.FNADateFormat(a.DealDate) DealDate,  
	dbo.FNADateFormat(a.GenDate) Vintage,   
	a.Obligation as [Env Product],  
	a.Price,   
	round((b.volume/a.conv_factor), 0) as [Volume UnAssign], 
	round(a.Bonus/a.conv_factor, 0) Bonus,   
	round((b.volume/a.conv_factor), 0) as [Total Volume], 
	ISNULL(a.label,su.uom_name) UOM,
	a.Expiration Expiration,   
	a.Counterparty, a.GenCode,a.generator, a.FacilityOwner,
	assign.cert_to-b.volume+1 as cert_from,
	assign.cert_to as cert_to,
	gen_state,
	expiration_date,
	a.assigned_date,
	a.source_deal_header_id	[Deal ID] 
	' +  
	CASE WHEN (@table_name IS NULL) then '' else ' INTO ' + @table_name end   
	+' from  #temp a
	inner  join #temp_include b  
	on a.next_id=b.next_id
	left join assignment_audit assign on assign.source_deal_header_id=a.DealId
 	LEFT JOIN Gis_certificate gis on        
 		gis.source_deal_header_id=assign.source_deal_header_id_from
 	LEFT join rec_generator rg on        
 		a.generator_id=rg.generator_id         
 	LEFT JOIN        
 		certificate_rule cr on rg.gis_value_id=cr.gis_id     
 
-- 	LEFT JOIN      
-- 	(SELECT source_deal_header_id_from,sum(assigned_volume) assigned_volume from       
-- 	assignment_audit group by source_deal_header_id_from) assign1      
-- 	on assign1.source_deal_header_id_from=a.ext_deal_id 
	LEFT Join source_UOM su on su.source_uom_id='+cast(@to_uom_id as varchar)+'
 where 1=1 and b.volume>0 '


EXEC(@select_stmt)  	


--EXEC(' select * into '+@table_name+' from #temp_final ')
  

if @flag='s'
    if @unassign=0
	SET @select_stmt  ='select '''+@table_name +''',NULL,[ID] [Detail ID],
	dbo.FNAHyperLinkText(10131010,[Deal ID],[Deal ID]) [Deal ID],[Cert # From],[Cert # T0],gen_state [Gen State],Dealdate,Vintage,[Env Product],Price,
	[Volume Assign],Bonus,[Total Volume],[Volume Left],
	UOM,Expiration,Counterparty,Generator,FacilityOwner from '+@table_name +' a order by expiration_date'  
    else
	SET @select_stmt  ='select '''+@table_name +''',assign_id,[ID] [Detail ID],[Deal ID],[Cert # From],[Cert # T0],gen_state [Gen State],Dealdate,Vintage,[Env Product],Price,
	[Volume UnAssign],Bonus,[Total Volume],UOM,Expiration,Counterparty,Generator,FacilityOwner from '+@table_name +' a order by assigned_date  '  
		
else
   if @unassign=0
	SET @select_stmt  ='select [ID] [Detail ID],dbo.FNAHyperLinkText(10131010,[Deal ID],[Deal ID]) [Deal ID],[Cert # From],[Cert # T0],gen_state[Gen State],Dealdate,Vintage,[Env Product],Price,
	[Volume Assign],Bonus,[Total Volume],[Volume Left],UOM,Expiration,Counterparty,Generator,FacilityOwner from '+@table_name +' a order by expiration_date  '  
  else
	SET @select_stmt  ='select assign_id,[ID] [Detail ID],dbo.FNAHyperLinkText(10131010,[Deal ID],[Deal ID]) [Deal ID],[Cert # From],[Cert # T0],gen_state[Gen State],Dealdate,Vintage,[Env Product],Price,
	[Volume UnAssign],Bonus,[Total Volume],UOM,Expiration,Counterparty,Generator,FacilityOwner from '+@table_name +' a order by assigned_date '  

EXEC(@select_stmt)





