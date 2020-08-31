

IF OBJECT_ID('[dbo].[spa_REC_State_Allocation_Report]') IS NOT null
DROP PROC [dbo].[spa_REC_State_Allocation_Report]
go
CREATE PROC [dbo].[spa_REC_State_Allocation_Report]
	@as_of_date varchar(50), 
	@summary_option char(1),
	@compliance_year int,
	@assigned_state int = null,
	@generator_id int = null,
	@convert_uom_id int = 24,	  --convert to MWh
	@assignment_type int = NULL,
	@batch_process_id varchar(50)=NULL,
	@batch_report_param varchar(500)=NULL   

 AS

SET NOCOUNT ON

--to id = 3 mmbtu

--uncomment these to test locally
-- declare 	@as_of_date varchar(50)
-- declare 	@summary_option char(1)
-- declare 	@compliance_year int
-- declare 	@assigned_state int
-- declare 	@generator_id int
-- declare 	@convert_uom_id int
-- declare 	@assignment_type int
-- declare 	@batch_process_id varchar(50)
-- declare 	@batch_report_param  varchar(500)
-- 
-- set @as_of_date = '2006-12-31'
-- set @summary_option = 'd'
-- set @compliance_year = 2006
-- set @assigned_state = null
-- set @generator_id = null
-- set @convert_uom_id  = 24
-- drop table #tempAsset
-- drop table #Conversion
-----==========end of testdata


--*****************For batch processing********************************

DECLARE @str_batch_table varchar(max)
SET @str_batch_table=''
IF @batch_process_id is not null
	SELECT	@str_batch_table=dbo.FNABatchProcess('s',@batch_process_id,@batch_report_param,NULL,NULL,NULL) 
--***********************************************


declare @asset_type_id int
set @asset_type_id = 405

Declare @Sql_Select varchar(8000)
Declare @Sql_SelectS varchar(8000)
Declare @Sql_SelectD varchar(8000)
Declare @term_where_clause varchar(1000)

Declare @Sql_Where varchar(8000)

--declare @report_identifier int

SET @sql_Where = ''
--******************************************************
--CREATE Conversion table and build index
--*********************************************************
-- CREATE TABLE #Conversion(
-- 	from_source_uom_id int,
-- 	to_source_uom_id int,
-- 	state_value_id int,
-- 	assignment_type_value_id int,
-- 	curve_id int,
-- 	conversion_factor FLOAT,
-- 	uom_label VARCHAR(100) COLLATE DATABASE_DEFAULT 
-- )
-- INSERT INTO 
-- 	#Conversion
-- select 	DISTINCT
-- 	COALESCE(conv1.from_source_uom_id, conv2.from_source_uom_id, conv3.from_source_uom_id,conv4.from_source_uom_id,
-- 			conv5.from_source_uom_id) from_source_uom_id,
-- 	COALESCE(conv1.to_source_uom_id, conv2.to_source_uom_id, conv3.to_source_uom_id,conv4.to_source_uom_id,
-- 			conv5.to_source_uom_id) to_source_uom_id,
-- 	COALESCE(conv1.state_value_id, conv2.state_value_id, conv3.state_value_id,conv4.state_value_id,
-- 			conv5.state_value_id) state_value_id,
-- 	COALESCE(conv1.assignment_type_value_id, conv2.assignment_type_value_id, conv3.assignment_type_value_id,
-- 			conv4.assignment_type_value_id,conv5.assignment_type_value_id) assignment_type_value_id,
-- 	COALESCE(conv1.curve_id, conv2.curve_id, conv3.curve_id,
-- 			conv4.curve_id,conv5.curve_id) curve_id,
-- 	COALESCE(conv1.conversion_factor, conv2.conversion_factor, conv3.conversion_factor,
-- 			conv4.conversion_factor,conv5.conversion_factor) conversion_factor,
-- 	COALESCE(conv1.uom_label, conv2.uom_label, conv3.uom_label,
-- 			conv4.uom_label,conv5.uom_label) uom_labe
-- -- 	rvuc.conversion_factor, 
-- -- 	rvuc.uom_label
-- from 
-- (
-- --State, Curve, Assignment   
-- select 	state_value_id, assignment_type_value_id, curve_id, from_source_uom_id, to_source_uom_id, conversion_factor, uom_label
-- 	 from rec_volume_unit_conversion
-- where 	to_source_uom_id = @convert_uom_id and
-- 	(@assignment_type  IS NOT NULL and assignment_type_value_id is not null and assignment_type_value_id = @assignment_type) AND
-- 	curve_id is not null and state_value_id is not null) conv1 --on
-- --conv1.from_source_uom_id = rvuc.from_source_uom_id and conv1.to_source_uom_id = rvuc.to_source_uom_id 
-- full outer join	
-- (
-- --State, Curve
-- select 	state_value_id, mis.value_id assignment_type_value_id, curve_id, from_source_uom_id, to_source_uom_id, conversion_factor, uom_label
-- from rec_volume_unit_conversion inner join
-- (select value_id, @convert_uom_id conv_id from static_data_value where type_id = 10013) mis ON 
-- 	mis.conv_id = to_source_uom_id
-- where 	to_source_uom_id = @convert_uom_id and
-- 	assignment_type_value_id is null AND
-- 	curve_id is not null and state_value_id is not null) conv2 on
-- conv2.from_source_uom_id = conv1.from_source_uom_id and conv2.to_source_uom_id = conv1.to_source_uom_id
-- and conv2.state_value_id = conv1.state_value_id and conv2.assignment_type_value_id = conv1.assignment_type_value_id and
-- conv2.curve_id = conv1.curve_id
--  
-- full outer join
-- (
-- --Curve, Assignment
-- select 	mis2.value_id state_value_id, assignment_type_value_id, curve_id, from_source_uom_id, to_source_uom_id, conversion_factor, uom_label 
-- from rec_volume_unit_conversion  inner join
-- (select value_id, @convert_uom_id conv_id from static_data_value where type_id = 10002) mis2 ON 
-- 	mis2.conv_id = to_source_uom_id
-- where 	to_source_uom_id = @convert_uom_id and
-- 	(@assignment_type  IS NOT NULL and assignment_type_value_id is not null and assignment_type_value_id = @assignment_type) AND
-- 	curve_id is not null and state_value_id is null) conv3 on 
-- conv3.from_source_uom_id = conv2.from_source_uom_id and conv3.to_source_uom_id = conv2.to_source_uom_id
-- and conv3.state_value_id = conv2.state_value_id and conv3.assignment_type_value_id = conv2.assignment_type_value_id and
-- conv3.curve_id = conv2.curve_id
-- 
-- full outer join
-- (
-- --Curve
-- select 	mis2.value_id state_value_id, mis.value_id assignment_type_value_id, curve_id, from_source_uom_id, to_source_uom_id, conversion_factor, uom_label 
-- from rec_volume_unit_conversion inner join
-- (select value_id, @convert_uom_id conv_id from static_data_value where type_id = 10013) mis ON 
-- 	mis.conv_id = to_source_uom_id inner join
-- (select value_id, @convert_uom_id conv_id from static_data_value where type_id = 10002) mis2 ON 
-- 	mis2.conv_id = to_source_uom_id
-- where 	to_source_uom_id = @convert_uom_id and
-- 	assignment_type_value_id IS NULL AND
-- 	curve_id is not null and state_value_id is null
-- ) conv4 on 
-- conv4.from_source_uom_id = conv3.from_source_uom_id and conv4.to_source_uom_id = conv3.to_source_uom_id
-- and conv4.state_value_id = conv3.state_value_id and conv4.assignment_type_value_id = conv3.assignment_type_value_id and
-- conv4.curve_id = conv3.curve_id
-- 
-- full outer join
-- (
-- --ONLY uom
-- select 	mis2.value_id state_value_id, mis.value_id assignment_type_value_id, 
-- 	mis3.source_curve_def_id curve_id, from_source_uom_id, to_source_uom_id, conversion_factor, uom_label 
-- from rec_volume_unit_conversion inner join
-- (select value_id, @convert_uom_id conv_id from static_data_value where type_id = 10013) mis ON 
-- 	mis.conv_id = to_source_uom_id inner join
-- (select value_id, @convert_uom_id conv_id from static_data_value where type_id = 10002) mis2 ON 
-- 	mis2.conv_id = to_source_uom_id  inner join
-- (select source_curve_def_id,  @convert_uom_id conv_id from source_price_curve_def) mis3 ON
-- 	mis3.conv_id = to_source_uom_id 
-- where 	to_source_uom_id = @convert_uom_id and
-- 	assignment_type_value_id IS NULL AND
-- 	curve_id is null and state_value_id is null )conv5 on 
-- conv5.from_source_uom_id = conv4.from_source_uom_id and conv5.to_source_uom_id = conv4.to_source_uom_id
-- and conv5.state_value_id = conv4.state_value_id and conv5.assignment_type_value_id = conv4.assignment_type_value_id and
-- conv5.curve_id = conv4.curve_id
-- ------------------------------------------------------------
-- CREATE  INDEX [IX_Conversion1] ON [#COnversion]([from_source_uom_id])      
-- CREATE  INDEX [IX_Conversion2] ON [#COnversion]([to_source_uom_id])      
-- CREATE  INDEX [IX_Conversion3] ON [#COnversion]([state_value_id])      
-- CREATE  INDEX [IX_Conversion4] ON [#COnversion]([assignment_type_value_id])      
-- CREATE  INDEX [IX_Conversion5] ON [#COnversion]([curve_id])      
--------------------------------------------------------------------
--******************************************************
--END of Conversion table 
--*********************************************************


--========Asset
--drop table [dbo].[#tempAsset]

CREATE TABLE [dbo].[#tempAsset] (
	[fas_book_id] [int] NOT NULL ,
	[source_deal_header_id] [int] NOT NULL ,
	[deal_id] [varchar] (50) ,
	[gen_date] datetime,
	[volume] [float] ,
	[bonus] [float] ,
	[uom] [varchar] (7) ,
	[assignment] [varchar] (100),
	[compliance_year] [varchar] (20),
	[target_actual] varchar(10),
	[assigned_state] varchar(20),
	[assigned_state_id] int,
	[curve_name] varchar(100),
	[generator_id] int,
	[generator_name] varchar(100),
	[assignment_type_value_id] int,
	[buy_sell_flag] char(1)
) ON [PRIMARY]




SET @sql_Select = '
INSERT INTO #tempAsset
SELECT  ssbm.fas_book_id,  sdh.source_deal_header_id, sdh.deal_id, 			
	sdd.term_start AS gen_date,
	CASE WHEN (sdd.buy_sell_flag = ''s'' and sdh.assignment_type_value_id is  null) THEN -1 * sdd.deal_volume ELSE sdd.deal_volume END 
	* isnull(COALESCE(conv1.conversion_factor,conv5.conversion_factor,conv2.conversion_factor,conv3.conversion_factor,conv4.conversion_factor), 1) volume,
	0 as bonus,
	COALESCE(Conv1.curve_label,Conv5.curve_label,Conv2.curve_label,Conv3.curve_label,Conv4.curve_label)  UOM,
	isnull(at.code, ''Banked'') Assignment, 
	CASE when (at.code is null) THEN
		cast(year(dbo.FNADEALRECExpiration(sdh.source_deal_header_id, sdd.contract_expiration_date, null)) as varchar)
	ELSE
		isnull(cast(sdh.compliance_year as varchar), '''') 
	END compliance_year,		
	case when (ssbm.fas_deal_type_value_id = 405) then ''Target'' else ''Actual'' end target_actual,
	isnull(state.code, '''') assigned_state,
	state.value_id,
	spcd.curve_name,
	rg.generator_id,
	rg.name,
	isnull(sdh.assignment_type_value_id, 5149),
	sdd.buy_sell_flag	
		
FROM  	
      	source_deal_header sdh 
	inner join source_deal_detail sdd on sdd.source_deal_header_id=sdh.source_deal_header_id	LEFT OUTER JOIN
      	source_price_curve_def spcd ON sdd.curve_id = spcd.source_curve_def_id LEFT OUTER JOIN
      	source_price_curve_def pspcd ON spcd.proxy_source_curve_def_id = pspcd.source_curve_def_id INNER JOIN		      

      	source_system_book_map ssbm ON sdh.source_system_book_id1 = ssbm.source_system_book_id1 AND 
      	sdh.source_system_book_id2 = ssbm.source_system_book_id2 AND sdh.source_system_book_id3 = ssbm.source_system_book_id3 AND 
      	sdh.source_system_book_id4 = ssbm.source_system_book_id4 
--	INNER JOIN portfolio_hierarchy book ON ssbm.fas_book_id = book.entity_id 
	 
	left outer join rec_generator rg on rg.generator_id = sdh.generator_id 
	left outer join static_data_value at on at.value_id = sdh.assignment_type_value_id
	left outer  join state_properties sp1 on sp1.state_value_id =isnull(sdh.state_value_id, rg.state_value_id)	
	left outer  join rec_gen_eligibility rge on rge.state_value_id=sp1.state_value_id and rge.state_value_id = isnull(sdh.state_value_id, rg.state_value_id)
--	left outer join rec_gen_eligibility rge on rge.generator_id = sdh.generator_id and
	--		rge.state_value_id = isnull(sdh.state_value_id, rg.state_value_id)
	--left outer join state_properties sp on sp.state_value_id = isnull(rge.state_value_id,rg.state_value_id)
	left outer join static_data_value state on state.value_id = isnull(sdh.state_value_id, sp1.state_value_id)
	
	LEFT OUTER JOIN rec_volume_unit_conversion Conv1 ON            
	 conv1.from_source_uom_id  = sdd.deal_volume_uom_id             
	 AND conv1.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id as varchar),'NULL')+'            
	 And conv1.state_value_id = state.value_id   
	 AND conv1.assignment_type_value_id = isnull(at.value_id, 5149) 
	 AND conv1.curve_id = sdd.curve_id             
	
	LEFT OUTER JOIN rec_volume_unit_conversion Conv2 ON            
	 conv2.from_source_uom_id = sdd.deal_volume_uom_id             
	 AND conv2.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id as varchar),'NULL')+'            
	 And conv2.state_value_id IS NULL
	 AND conv2.assignment_type_value_id = isnull(at.value_id, 5149) 
	 AND conv2.curve_id = sdd.curve_id  
	
	LEFT OUTER JOIN rec_volume_unit_conversion Conv3 ON            
	conv3.from_source_uom_id =  sdd.deal_volume_uom_id             
	 AND conv3.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id as varchar),'NULL')+'            
	 And conv3.state_value_id IS NULL
	 AND conv3.assignment_type_value_id IS NULL
	 AND conv3.curve_id = sdd.curve_id 
	       
	LEFT OUTER JOIN rec_volume_unit_conversion Conv4 ON            
	 conv4.from_source_uom_id = sdd.deal_volume_uom_id
	 AND conv4.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id as varchar),'NULL')+'            
	 And conv4.state_value_id IS NULL
	 AND conv4.assignment_type_value_id IS NULL
	 AND conv4.curve_id IS NULL
	
	LEFT OUTER JOIN rec_volume_unit_conversion Conv5 ON            
	 conv5.from_source_uom_id  = sdd.deal_volume_uom_id             
	 AND conv5.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id as varchar),'NULL')+'            
	 And conv5.state_value_id = state.value_id   
	 AND conv5.assignment_type_value_id is null
	 AND conv5.curve_id = sdd.curve_id 

	 	  							
WHERE    
	 (sdh.deal_date  <= CONVERT(DATETIME, ''' + @as_of_date+ ''', 102))  
 	  AND isnull(sp1.begin_date, sdh.deal_date) <= sdh.deal_date 
 	  AND isnull(sdh.status_value_id, 5171) NOT IN (5170, 5179) 
 	  AND ssbm.fas_deal_type_value_id = 400
 	  AND (rg.exclude_inventory is null or rg.exclude_inventory=''n'')	
	  ' 
--+case when (@assignment_type is not null) then ' AND isnull(at.value_id, 5149) = ' + cast(@assignment_type as varchar) else '' end

-- only consider deals after the state program begin date
--' AND sdh.term_start >  CONVERT(DATETIME, ''' + @as_of_date + ''' , 102)'


-- 
-- IF @asset_type_id IS NOT NULL
-- 	SET @Sql_Where = @Sql_Where + ' AND ssbm.fas_deal_type_value_id = ' + cast(@asset_type_id as varchar)


--print @sql_Select + @sql_Where

EXEC (@sql_Select)


-- IF @generator_id IS NOT NULL
-- 	SET @Sql_Where = @Sql_Where + ' AND (rg.generator_id IN(' + cast(@generator_id as varchar)+ ')) '
-- IF @assigned_state IS NOT NULL
-- 	SET @Sql_Where = @Sql_Where + ' AND (state.value_id IN(' + cast(@assigned_state as varchar)+ ')) '

--select buy_sell_flag,assignment_type_value_id,*  from #tempAsset


if @summary_option = 'd'
SET @sql_Select='
	select 	[REC Generator] as [Generator/Credit Source], [State] as [Jurisdiction], [Percentage Assigned], [Percentage Allowed], [Violation]   '+@str_batch_table+'
	from (
		select #tempAsset.generator_id, assigned_state_id,
			dbo.FNAEmissionHyperlink(2,12101710, generator_name, #tempAsset.generator_id,NULL) [REC Generator], 
			dbo.FNAHyperLinkText(10101012, assigned_state, cast(assigned_state_id as varchar)) [State], 
			(100 * round(sum(case when (isnull(assignment_type_value_id,5149) <> 5149) then volume else 0 end )/max(case when ISNULL(gen_total,0)=0 then 1 else gen_total end), 4)) [Percentage Assigned], 
			100* isnull(max(rge.percentage_allocation), 1) [Percentage Allowed],
			case when (sum(case when (isnull(assignment_type_value_id,5149) <> 5149) then volume else 0 end )/max(case when ISNULL(gen_total,0)=0 then 1 else gen_total end) > isnull(max(rge.percentage_allocation), 1)) then ''<font color=''''red''''><b>Yes</b></font>'' else ''No'' end [Violation]
		from #tempAsset inner join
		(select generator_id, sum(volume) gen_total
		from #tempAsset 
		where (buy_sell_flag=''b'' and isnull(assignment_type_value_id,5149) =5149)
		group by generator_id) total_generator on total_generator.generator_id = #tempAsset.generator_id 
		left outer join
		rec_gen_eligibility rge on 
			rge.state_value_id = #tempAsset.assigned_state_id
		
		group by generator_name, #tempAsset.generator_id, assigned_state, assigned_state_id	
	) xx WHERE generator_id = isnull('+ISNULL(CAST(@generator_id as varchar),'NULL')+', generator_id)
		  -- and assigned_state_id = isnull('+ISNULL(CAST(@assigned_state as varchar),'NULL')+', assigned_state_id)
	order by [REC Generator], [State] '
Else
SET @sql_Select='
	select 	[REC Generator] as [Generator/Credit Source], [State] as [Jurisdiction], [Assignment Type], [Percentage Assigned] '+@str_batch_table+'
	from (
	select #tempAsset.generator_id, assigned_state_id,
	dbo.FNAEmissionHyperlink(2,12101710, generator_name, #tempAsset.generator_id,NULL)  [REC Generator], 
	dbo.FNAHyperLinkText(10101012, assigned_state, cast(assigned_state_id as varchar)) [State], 
	assignment [Assignment Type], 
		(100 * round(sum(case when (assignment_type_value_id <> 5149) then volume else 0 end )/max(case when ISNULL(gen_total,0)=0 then 1 else gen_total end), 4)) [Percentage Assigned]
	from #tempAsset inner join
	(select generator_id, sum(volume) gen_total
	from #tempAsset where (buy_sell_flag=''b'' and isnull(assignment_type_value_id,5149) =5149)
	group by generator_id) total_generator on total_generator.generator_id = #tempAsset.generator_id left outer join
	rec_gen_eligibility rge on 
	--rge.generator_id = #tempAsset.generator_id and
		rge.state_value_id = #tempAsset.assigned_state_id
	group by generator_name, #tempAsset.generator_id, assigned_state, assigned_state_id, assignment
	)xx WHERE generator_id = isnull('+ISNULL(CAST(@generator_id as varchar),'NULL')+', generator_id) and
		   assigned_state_id = isnull('+ISNULL(CAST(@assigned_state as varchar),'NULL')+', assigned_state_id)
		   AND 	[Percentage Assigned] > 0
	order by [REC Generator], [State]'

EXEC spa_print @sql_Select
EXEC (@sql_Select)
--*****************FOR BATCH PROCESSING**********************************    
IF  @batch_process_id is not null
	BEGIN
	SELECT	@str_batch_table=dbo.FNABatchProcess('u',@batch_process_id,@batch_report_param,GETDATE(),NULL,NULL) 
	EXEC(@str_batch_table)

	SELECT	@str_batch_table=dbo.FNABatchProcess('c',@batch_process_id,@batch_report_param,GETDATE(),'spa_REC_State_Allocation_Report','Rec Generator Allocation Report') 
	EXEC(@str_batch_table)

	END
--********************************************************************
--Return


-- 









