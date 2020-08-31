

IF OBJECT_ID(N'[dbo].[spa_get_co2_avoided_recs]', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_get_co2_avoided_recs]
 GO 
/******************************************************
Created By: Anal Shrestha
Created On: 15/02/2008
Description: This SP is converts the REC to amount of the emissions

EXEC spa_get_co2_avoided_recs '135,136,137,138', '12/31/2006', 2006,2000, 26,'adiha_process.zzzz_temp',NULL,26,127

******************************************************/

CREATE PROCEDURE [dbo].[spa_get_co2_avoided_recs]
	@fas_sub_id  varchar(1000),  
	@as_of_date varchar(20),  
	@reporting_year int, 
	@max_base_year int, 
	@convert_uom_id int,
	@tablename varchar(100)=NULL,
	@drill_generator_name varchar(100)  = NULL,
	@co2_uom_id int=null,
	@co2_gas_id int=null

    
AS  
  
SET NOCOUNT ON  
BEGIN


	--------------------------------------------------  

	-- DECLARE @fas_sub_id  varchar(1000)  
	-- DECLARE @as_of_date varchar(20)  
	-- DECLARE @reporting_year int   
	-- DECLARE @convert_uom_id int
	-- DECLARE @drill_generator_name varchar(100)  
	-- 
	-- set @fas_sub_id  = 136
	-- set @as_of_date = '12/31/2006'
	-- set @reporting_year = 2006
	-- set @convert_uom_id = 29
	--set @drill_generator_name = 'Ashland Windfarm, LLC'
	--set @drill_generator_name = 'Uday'
	  
	-- drop table #temp  
	-- drop table #temp_exclude  
	-- drop table #temp_include  
	-- drop table #ssbm  
	-- drop table #conversion  
	-- drop table #bonus  


	--============ end of test data


	DECLARE @sql_stmt varchar(8000)  
	DECLARE @Sql_Select varchar(8000)  
	DECLARE @Sql_Where varchar(8000)  
	DECLARE @assignment_type_id int

	SET @Sql_Where=''  
	SET @assignment_type_id = 5148  
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
	 sub_entity_id int,
	 sub_name VARCHAR(100) COLLATE DATABASE_DEFAULT             
	)  
	----------------------------------  
	SET @Sql_Select=  
			'INSERT INTO #ssbm            
			SELECT            
			 source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,fas_deal_type_value_id,            
			  book_deal_type_map_id,book.entity_id fas_book_id,book.parent_entity_id stra_book_id, stra.parent_entity_id sub_entity_id ,
			  sub.entity_name	            
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
			INNER JOIN            
			 Portfolio_hierarchy sub (nolock)          
			 ON            
			  stra.parent_entity_id = sub.entity_id             
			            
			WHERE 1=1 '            
	IF @fas_sub_id IS NOT NULL            
	  SET @Sql_Where = @Sql_Where + ' AND stra.parent_entity_id IN  ( ' + @fas_sub_id + ') '             
	SET @Sql_Select=@Sql_Select+@Sql_Where            
	EXEC spa_print @Sql_Select
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




	set @sql_stmt =
		' 

SELECT  
			'''+cast(@as_of_date as varchar)+''' as_of_date,
			sub.entity_id Group1_ID,
			stra.entity_id Group2_ID,
			book.entity_id Group3_ID,
			sub.entity_name Group1,
			stra.entity_name Group2, 
			book.entity_name Group3, 
			rg.generator_id generator_id, 
			rg.[name] generator_name, 
			CASE WHEN sdd.deal_volume_frequency=''m'' THEN 703
				 WHEN sdd.deal_volume_frequency=''q'' THEN 704
				 WHEN sdd.deal_volume_frequency=''a'' THEN 706	 	
			END	AS frequency, 
			sdd.curve_id AS curve_id, 
			spcd.curve_name AS curve_name, 
			spcd.curve_des AS curve_des,
			0 AS volume,
			COALESCE(conv6.to_source_uom_id,conv1.to_source_uom_id,conv5.to_source_uom_id,conv2.to_source_uom_id,conv3.to_source_uom_id,conv4.to_source_uom_id) AS uom_id,
			COALESCE(conv6.uom_label,conv1.uom_label,conv5.uom_label,conv2.uom_label,conv3.uom_label,conv4.uom_label, su.uom_name) uom_name,
			'+isnull(cast(@reporting_year as varchar), 'year(sdd.term_start)')+' reporting_year,
			NULL AS fuel_value_id,
			sub.entity_name AS sub,
			rg.captured_co2_emission AS captured_co2_emission,
			rg.technology As technology,
			rg.classification_value_id AS technology_sub_type,
			rg.reduc_start_date AS reduc_start_date,
			sdd.term_start AS term_start,
			sdd.term_end AS term_end,
			NULL AS output_id,
			NULL AS ouput_value,
			NULL AS output_uom_name,
			NULL AS heatcontent_value,
			NULL AS heatinput_uom_id,
			''r'' as current_forecast,
			case when (sdd.buy_sell_flag = ''b'') then -1 else 1 end *
				sdd.deal_volume * 
				COALESCE(conv6.conversion_factor,conv1.conversion_factor,conv5.conversion_factor,conv2.conversion_factor,conv3.conversion_factor,conv4.conversion_factor) reduction_volume,  
 			rg.de_minimis_source,
			NULL AS co2_captured_for_generator_id,
			esf.forecast_type AS Series_type,
			series.code AS series_code,
			rg.fuel_value_id as fuel_type_value_id,
			esmd.ems_source_model_id,
			case when esf.default_inventory=''y'' then -1 else NULL end as default_inventory,
			esf.sequence_order AS sequence_order,
			st.forecast_type AS forecast_type,
			ssbm.sub_name AS OpCo,
			state.Code AS state,
			rg.[name],
			NULL as uom_name1,
			NULL AS input_value,
			NULL AS uom_name2 ' +
		--case when (@tablename is null) then '' else ' into ' + @tablename end+
		' FROM
			source_deal_header sdh 
		 INNER JOIN  
			source_deal_detail sdd ON sdh.source_deal_header_id=sdd.source_deal_header_id   	 
		 INNER JOIN rec_generator rg (nolock) ON
			rg.generator_id=sdh.generator_id
		 INNER JOIN source_sink_type sst ON  
			sst.generator_id=rg.generator_id		
		 INNER JOIN ems_portfolio_hierarchy book ON              
			sst.source_sink_type_id=book.entity_id
		 INNER JOIN ems_portfolio_hierarchy stra ON              
			book.parent_entity_id = stra.entity_id             
		 INNER JOIN ems_portfolio_hierarchy sub ON             
			stra.parent_entity_id = sub.entity_id    
		 INNER JOIN #ssbm ssbm ON  
			sdh.source_system_book_id1 = ssbm.source_system_book_id1 AND   
			sdh.source_system_book_id2 = ssbm.source_system_book_id2 AND  
			sdh.source_system_book_id3 = ssbm.source_system_book_id3 AND   
			sdh.source_system_book_id4 = ssbm.source_system_book_id4  
		 LEFT OUTER JOIN source_counterparty sc ON 
			sc.source_counterparty_id = sdh.counterparty_id  
		 LEFT OUTER JOIN static_data_value state ON 
			state.value_id = rg.gen_state_value_id
		 LEFT OUTER JOIN state_properties sp ON 
			sp.state_value_id = rg.state_value_id
		 LEFT OUTER JOIN source_uom su ON 
			su.source_uom_id = sdd.deal_volume_uom_id
		 LEFT OUTER JOIN source_price_curve_def spcd ON 
			spcd.source_curve_def_id = '+cast(@co2_gas_id as varchar)+'
		 LEFT OUTER JOIN source_deal_type sdt ON 
			sdt.source_deal_type_id = sdh.source_deal_type_id
		INNER JOIN ems_source_model_effective esme ON
			esme.generator_id=rg.generator_id
		INNER JOIN (select max(isnull(effective_date,''1900-01-01'')) effective_date,generator_id FROM 
						ems_source_model_effective WHERE 1=1 group by generator_id) ab ON
			esme.generator_id=ab.generator_id and isnull(esme.effective_date,''1900-01-01'')=ab.effective_date
		INNER JOIN ems_source_model_detail esmd ON 
			esmd.ems_source_model_id = esme.ems_source_model_id AND	esmd.curve_id ='+cast(@co2_gas_id as varchar)+'
		LEFT OUTER JOIN ems_source_formula esf ON
			esf.ems_source_model_id=esmd.ems_source_model_id AND esf.curve_id='+cast(@co2_gas_id as varchar)+' AND esf.default_inventory=''y''
		LEFT OUTER JOIN static_data_value series ON
			series.value_id=esf.forecast_type
		LEFT OUTER JOIN dbo.series_type st ON
			st.series_type_value_id=esf.forecast_type and st.forecast_type=''f''

		LEFT OUTER JOIN rec_volume_unit_conversion Conv1 ON            
		 conv1.from_source_uom_id  = sdd.deal_volume_uom_id             
		 AND conv1.to_source_uom_id = '+cast(@co2_uom_id as varchar)+'
		 And conv1.state_value_id = state.value_id
		 AND conv1.assignment_type_value_id = '+cast(@assignment_type_id as varchar)+'
		 AND conv1.curve_id = '+cast(@co2_gas_id as varchar)+'

		LEFT OUTER JOIN rec_volume_unit_conversion Conv2 ON            
		 conv2.from_source_uom_id = sdd.deal_volume_uom_id             
		 AND conv2.to_source_uom_id = '+cast(@co2_uom_id as varchar)+' 
		 And conv2.state_value_id IS NULL
		 AND conv2.assignment_type_value_id = '+cast(@assignment_type_id as varchar)+'
		 AND conv2.curve_id = '+cast(@co2_gas_id as varchar)+' 


		LEFT OUTER JOIN rec_volume_unit_conversion Conv3 ON            
		conv3.from_source_uom_id =  sdd.deal_volume_uom_id             
		 AND conv3.to_source_uom_id = '+cast(@co2_uom_id as varchar)+' 
		 And conv3.state_value_id IS NULL
		 AND conv3.assignment_type_value_id IS NULL
		 AND conv3.curve_id ='+cast(@co2_gas_id as varchar)+'
		       
		LEFT OUTER JOIN rec_volume_unit_conversion Conv4 ON            
		 conv4.from_source_uom_id = sdd.deal_volume_uom_id
		 AND conv4.to_source_uom_id = '+cast(@co2_uom_id as varchar)+' 
		 And conv4.state_value_id IS NULL
		 AND conv4.assignment_type_value_id IS NULL
		 AND conv4.curve_id IS NULL

		LEFT OUTER JOIN rec_volume_unit_conversion Conv5 ON            
		 conv5.from_source_uom_id  = sdd.deal_volume_uom_id             
		 AND conv5.to_source_uom_id = '+cast(@co2_uom_id as varchar)+' 
		 And conv5.state_value_id = state.value_id
		 AND conv5.assignment_type_value_id is null
		 AND conv5.curve_id is null

		LEFT OUTER JOIN rec_volume_unit_conversion Conv6 ON            
		 conv5.from_source_uom_id  = COALESCE(conv1.to_source_uom_id,conv5.to_source_uom_id,conv2.to_source_uom_id,conv3.to_source_uom_id,conv4.to_source_uom_id)             
		 AND conv5.to_source_uom_id = '+cast(@convert_uom_id as varchar)+' 
		 And conv5.state_value_id = state.value_id
		 AND conv5.assignment_type_value_id is null
		 AND conv5.curve_id is null

		LEFT OUTER JOIN gis_certificate gis ON gis.source_deal_header_id=sdd.source_deal_detail_id
		LEFT OUTER JOIN static_data_value sd3 ON sd3.value_id=rg.gen_state_value_id
		WHERE  	ssbm.fas_deal_type_value_id = 409	
			and sdh.deal_date <= '''+cast(@as_of_date as varchar)+'''
 			and isnull(sdh.status_value_id, 5171) NOT IN (5170, 5179) 
			and sdh.source_deal_type_id in (53, 55) -- ONLY REC and REC Energy
			and isnull(sdh.deal_sub_type_type_id, 1) in (1)  -- ONLY Spot 
			and isnull(sc.int_ext_flag, ''i'') = ''e''
			and (sdh.header_buy_sell_flag = ''b'' or (sdh.header_buy_sell_flag = ''s'' and isnull(sdh.assignment_type_value_id, 5173) = 5173)) ' 

			+ case when (@max_base_year is not null) then ' and year(sdd.term_start) > ' + cast(@max_base_year as varchar) 
				else 'and year(sdd.term_start) = '+ isnull(cast(@reporting_year as varchar), 'year(sdd.term_start)') end
			+ case when @drill_generator_name is not null then ' and rg.[name] = '''+@drill_generator_name+''''  else '' end
	EXEC spa_print @sql_stmt
	exec(@sql_stmt)
END






