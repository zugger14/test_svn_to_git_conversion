
/****** Object:  StoredProcedure [dbo].[spa_publish_cube_data]    Script Date: 06/04/2012 06:33:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_publish_cube_data]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_publish_cube_data]
GO

/****** Object:  StoredProcedure [dbo].[spa_publish_cube_data]    Script Date: 06/04/2012 06:33:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


  
  
  
CREATE PROCEDURE [dbo].[spa_publish_cube_data]  
 @as_of_date VARCHAR(20) = NULL,  
 @run_type INT = 0 -- 0 - All, 1 - Dimensions, 2- Positions, 3- Hourly Position, 4- Index Breakdown, 5- FX Exposure,6-Forward Actual,7-Value Report,8-Position Explain,9 - MTM Explain
 --@pos_Only CHAR(1) = 'n'  
AS  
  
/*   
BEGIN TEST DATA  
 DECLARE @as_of_date VARCHAR(20)  
  , @pos_Only CHAR(1)  
  
 SET @as_of_date = '2012-06-27'  
 SET @pos_Only = 'y'  
END TEST DATA  
*/  
   
BEGIN   
 --Production   
 DECLARE @source_db VARCHAR(100), @destination_db VARCHAR(100), @source_server VARCHAR(100)   
 DECLARE @process_id VARCHAR(100),@user_login_id VARCHAR(100),@str_batch_table VARCHAR(100)  

 --SET @source_db = '[SPMDBP05\SPMMS005].TRMTracker.dbo.'  
 --SET @destination_db = 'TRMTracker_OLAP.dbo.'   
 --SET @source_server = '[SPMDBP05\SPMMS005].'  
   
 --UAT  
 --DECLARE @source_db VARCHAR(100), @destination_db VARCHAR(100), @source_server VARCHAR(100)   
 SET @source_db = '[spmdba04\spmms006].TRMTracker_UAT.dbo.'  
 SET @destination_db = 'TRMTracker_OLAP_Test.dbo.'   
 SET @source_server = '[spmdba04\spmms006].'  
   
  
 ----TEST  
 --DECLARE @source_db VARCHAR(100), @destination_db VARCHAR(100), @source_server VARCHAR(100)   
 --SET @source_db = '[spmdbt02\spmms004].TRM_Test.dbo.'  
 --SET @destination_db = 'TRMTracker_OLAP_Test.dbo.'   
 --SET @source_server = '[spmdbt02\spmms004].'  
    
 --Local  
 --DECLARE @source_db VARCHAR(100), @destination_db VARCHAR(100), @source_server VARCHAR(100)   
 --SET @source_db = 'TRMTracker.dbo.'  
 --SET @destination_db = 'TRMTracker_OLAP.dbo.'   
 --SET @source_server = ''  
  
 --DECLARE @source_db varchar(100)='TRMTracker_Essent.dbo.' ,@destination_db varchar(100)='TRMTracker_OLAP.dbo.'   
 --DECLARE @source_server varchar(100)=''  
 --SET @as_of_date = '2011-12-02'  
  
 DECLARE @hour INT  
 IF @as_of_date IS NULL  
  BEGIN  
  SET @hour=DATEPART(hour,GETDATE())  
  IF @hour>= 0 AND @hour<=19  
   SET @as_of_date=CONVERT(VARCHAR(10),getdate()-1,120)  
  ELSE  
   SET @as_of_date=CONVERT(VARCHAR(10),getdate(),120)   
  END  
  
 DECLARE @st VARCHAR(max)   
  

IF @run_type IN(0,1)
BEGIN
	 EXEC spa_print '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Start Sync Dimension Table @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'  
	 SET @st ='  
	   update d set  counterparty=s.counterparty_name, parent_counterparty=isnull(s1.counterparty_name,''Unknown Parent Counterparty'')   FROM '+@destination_db+'Counterparty d   
	   inner join ' + @source_db + '[source_counterparty] s on d.counterparty_id=s.source_counterparty_id   
	   LEFT JOIN ' + @source_db + '[source_counterparty] s1 ON s.parent_counterparty_id=s1.source_counterparty_id  
	     
	   INSERT INTO ' + @destination_db + '[Counterparty] (counterparty_id, counterparty, parent_counterparty)  
		select s.source_counterparty_id, s.counterparty_name, isnull(s1.counterparty_name,''Unknown Parent Counterparty'')     
		FROM ' + @source_db + '[source_counterparty] s left join '+@destination_db+'Counterparty d on d.counterparty_id=s.source_counterparty_id   
	   LEFT JOIN ' + @source_db + '[source_counterparty] s1 ON s.parent_counterparty_id=s1.source_counterparty_id  
		where d.counterparty_id is null  
	 '  
	 exec spa_print @st  
	 exec(@st)  
	  
	  
	 SET @st ='  
	   update d set  Template=s.template_name  FROM '+@destination_db+'[Template] d inner join ' + @source_db + 'source_deal_header_template s on d.template_id=s.template_id  
	     
	   INSERT INTO ' + @destination_db + '[Template] (template_id, Template) select s.template_id, s.template_name    
	   FROM ' + @source_db + 'source_deal_header_template s left join '+@destination_db+'[Template] d on d.template_id=s.template_id   
	   where d.template_id is null  
	 '  
	 exec spa_print @st  
	 exec(@st)  
	  
	  
	 SET @st ='  
	   update d set  Profile=s.code  FROM '+@destination_db+'[Profile] d inner join ' + @source_db + 'static_data_value s on d.profile_id=s.value_id and  s.[type_id]=17300  
	     
	   INSERT INTO ' + @destination_db + '[Profile] (profile_id, Profile) select s.value_id,s.code   
		FROM ' + @source_db + 'static_data_value s left join '+@destination_db+'[Profile] d on d.profile_id=s.value_id  
		where d.profile_id is null and  s.[type_id]=17300   
	 '  
	 exec spa_print @st  
	 exec(@st)  
	  
	 SET @st ='  
	   update d set  Deal_status=s.code    FROM  ' + @source_db + 'static_data_value s inner join '+@destination_db+'Deal_Status d   
	   on d.deal_status_id=s.value_id and s.[type_id]=5600  
	     
	   INSERT INTO ' + @destination_db + '[Deal_Status] (deal_status_id, Deal_status) select s.value_id,s.code    
	   FROM  ' + @source_db + 'static_data_value s left join '+@destination_db+'Deal_Status d   
	   on d.deal_status_id=s.value_id  
	   where d.deal_status_id is null and s.[type_id]=5600  
	 '  
	 exec spa_print @st  
	 exec(@st)  
	  
	 SET @st ='  
	   update d set  Currency=s.currency_name    
	   FROM ' + @source_db + 'source_currency s inner join '+@destination_db+'[Currency] d on d.currency_id=s.source_currency_id   
	     
	   INSERT INTO ' + @destination_db + '[Currency] (currency_id, Currency) select s.source_currency_id ,s.currency_name    
	   FROM ' + @source_db + 'source_currency s left join '+@destination_db+'[Currency] d on d.currency_id=s.source_currency_id   
	   where d.currency_id is null  
	 '  
	 exec spa_print @st  
	 exec(@st)  
	  
	  
	 SET @st ='  
	   update d set  broker=s.[counterparty_name]   
	   FROM ' + @source_db + '[source_counterparty] s inner join  '+@destination_db+'[Broker] d   
	   on d.broker_id=s.source_counterparty_id  and ISNULL(int_ext_flag,''i'')=''b''  
	  
	     
	   INSERT INTO ' + @destination_db + '[Broker] (broker_id, broker) select s.[source_counterparty_id],s.[counterparty_name]    
	   FROM ' + @source_db + '[source_counterparty] s left join  '+@destination_db+'[Broker] d   
	   on d.broker_id=s.source_counterparty_id   
	   where d.broker_id is null and ISNULL(int_ext_flag,''i'')=''b''  
	 '  
	 exec spa_print @st  
	 exec(@st)  
	   
	   
	 SET @st ='  
	   update d set  UserTOUBlock= s.block_name    
		FROM   
		' + @source_db + 'block_type_group s inner join '+@destination_db+'UserTOUBlock d on d.user_toublock_id=s.[id]  
	     
	   INSERT INTO ' + @destination_db + '[UserTOUBlock] (user_toublock_id, UserTOUBlock) select s.[id], s.block_name   
		FROM   
		' + @source_db + 'block_type_group s left join '+@destination_db+'UserTOUBlock d on d.user_toublock_id=s.[id]   
		 where d.user_toublock_id is null   
	 '  
	 exec spa_print @st  
	 exec(@st)  
	  
	 -- Charge Type Contract 
	 SET @st ='  
	   update d set  charge_type= s.code    
		FROM   
		' + @source_db + 'static_data_value s inner join '+@destination_db+'charge_type d on d.charge_type_id=s.value_id AND [type_id] IN(10019)   
	     
	   INSERT INTO ' + @destination_db + '[charge_type] (charge_type_id, charge_type) select s.value_id, s.code   
		FROM   
		' + @source_db + 'static_data_value s left join '+@destination_db+'charge_type d on d.charge_type_id=s.value_id   
		 where d.charge_type_id is null AND [type_id] IN (10019)   
	 '  
	 exec spa_print @st  
	 exec(@st)  
	  
	 -- Charge Type  Fees
	 SET @st ='  
	   update d set  charge_type= s.code    
		FROM   
		' + @source_db + 'static_data_value s inner join '+@destination_db+'charge_type d on d.charge_type_id=s.value_id AND [type_id] IN(5500)  
		INNER JOIN  ' + @source_db + 'user_defined_deal_fields_template uddft ON uddft.Field_name = s.value_id AND uddft.internal_field_type IS NOT NULL 
	     
	   INSERT INTO ' + @destination_db + '[charge_type] (charge_type_id, charge_type) select DISTINCT s.value_id, s.code   
		FROM   
		' + @source_db + 'static_data_value s left join '+@destination_db+'charge_type d on d.charge_type_id=s.value_id AND [type_id] IN (5500)
		INNER JOIN  ' + @source_db + 'user_defined_deal_fields_template uddft ON uddft.Field_name = s.value_id AND uddft.internal_field_type IS NOT NULL   
		 where d.charge_type_id is null 
	 '  
	 exec(@st) 
  
	   
	-- Category  
	 SET @st ='  
	   update d set  category= s.code    
		FROM   
		' + @source_db + 'static_data_value s inner join '+@destination_db+'category d on d.category_id=s.value_id AND [type_id]=18100   
	     
	   INSERT INTO ' + @destination_db + '[category] (category_id, category) select s.value_id, s.code   
		FROM   
		' + @source_db + 'static_data_value s left join '+@destination_db+'category d on d.category_id=s.value_id   
		 where d.category_id is null AND [type_id]=18100   
	 '  
	 exec spa_print @st  
	 exec(@st)  
	   
	 SET @st ='  
	   if not exists( select 1 from ' + @destination_db + '[Logical_Name] where  as_of_date_FROM='''+@as_of_date +''' and  as_of_date_to='''+@as_of_date +''')   
	   INSERT INTO ' + @destination_db + '[Logical_Name] ( Logical_Name, as_of_date_FROM , as_of_date_to)   
		select  '''+@as_of_date +''','''+@as_of_date +''','''+@as_of_date +'''  
	  '  
	 exec spa_print @st  
	 exec(@st)  
	   
	  
	  
	  
	 SET @st ='  
	   update d set  TOUBlock=s.code  FROM '+@destination_db+'TOUBlock d inner join ' + @source_db + 'static_data_value s on d.toublock_id=s.value_id AND [type_id]=10018  
	     
	   insert into ' + @destination_db + '[TOUBlock] (toublock_id, TOUBlock) select s.value_id, s.code    
	   FROM   
		' + @source_db + 'static_data_value s left join '+@destination_db+'TOUBlock d on d.toublock_id=s.value_id   
	   where d.toublock_id is null AND [type_id]=10018  
	 '  
	  
	 exec spa_print @st  
	 exec(@st)  
	  
	 SET @st ='  
	   update d set    
	   Subsidiary=sub.entity_name, Strategy=stra.entity_name, Book=book.entity_name,   
	   book_identifier1=sb1.source_book_name, book_identifier2=sb2.source_book_name,  
		book_identifier3=sb3.source_book_name, book_identifier4=sb4.source_book_name    
	   FROM '+@destination_db+'[Portfolio] d inner join ' + @source_db + 'source_system_book_map ssbm  
		ON d.book_deal_type_map_id=ssbm.book_deal_type_map_id  
		LEFT JOIN ' + @source_db + 'portfolio_hierarchy book ON  ssbm.fas_book_id=book.entity_id  
		LEFT JOIN ' + @source_db + 'portfolio_hierarchy stra ON stra.entity_id=book.parent_entity_id  
		LEFT JOIN ' + @source_db + 'portfolio_hierarchy sub ON sub.entity_id=stra.parent_entity_id  
		LEFT JOIN ' + @source_db + 'source_book sb1 ON sb1.source_book_id=ssbm.source_system_book_id1  
		LEFT JOIN ' + @source_db + 'source_book sb2 ON sb2.source_book_id=ssbm.source_system_book_id2  
		LEFT JOIN ' + @source_db + 'source_book sb3 ON sb3.source_book_id=ssbm.source_system_book_id3  
		LEFT JOIN ' + @source_db + 'source_book sb4 ON sb4.source_book_id=ssbm.source_system_book_id4  
	     
	   insert into ' + @destination_db + '[Portfolio] (book_deal_type_map_id, Subsidiary, Strategy, Book, book_identifier1, book_identifier2  
	   , book_identifier3, book_identifier4)   
	   select ssbm.book_deal_type_map_id, sub.entity_name, stra.entity_name, book.entity_name, sb1.source_book_name, sb2.source_book_name,  
		sb3.source_book_name, sb4.source_book_name    
	   FROM ' + @source_db + 'source_system_book_map ssbm  
		left join '+@destination_db+'[Portfolio] d ON d.book_deal_type_map_id=ssbm.book_deal_type_map_id  
		LEFT JOIN ' + @source_db + 'portfolio_hierarchy book ON  ssbm.fas_book_id=book.entity_id  
		LEFT JOIN ' + @source_db + 'portfolio_hierarchy stra ON stra.entity_id=book.parent_entity_id  
		LEFT JOIN ' + @source_db + 'portfolio_hierarchy sub ON sub.entity_id=stra.parent_entity_id  
		LEFT JOIN ' + @source_db + 'source_book sb1 ON sb1.source_book_id=ssbm.source_system_book_id1  
		LEFT JOIN ' + @source_db + 'source_book sb2 ON sb2.source_book_id=ssbm.source_system_book_id2  
		LEFT JOIN ' + @source_db + 'source_book sb3 ON sb3.source_book_id=ssbm.source_system_book_id3  
		LEFT JOIN ' + @source_db + 'source_book sb4 ON sb4.source_book_id=ssbm.source_system_book_id4  
	   where d.book_deal_type_map_id is null  
	 '  
	 exec spa_print @st  
	 exec(@st)  
	  
	 SET @st ='  
	   update d set  PRParty=s.code  FROM '+@destination_db+'PRParty d inner join ' + @source_db + 'static_data_value s on d.pvparty_id=s.value_id and s.[type_id]=18300  
	     
	   insert into ' + @destination_db + '[PRParty] (pvparty_id, PRParty) select s.value_id, s.code    
	   FROM ' + @source_db + 'static_data_value s left join '+@destination_db+'PRParty d on d.pvparty_id=s.value_id   
	   where d.pvparty_id is null and s.[type_id]=18300  
	 '  
	 exec spa_print @st  
	 exec(@st)  
	  
	 SET @st ='  
	   update d set  Contract=s.[contract_name]  FROM '+@destination_db+'[Contract] d inner join ' + @source_db + 'contract_group s on d.contract_id=s.contract_id  
	     
	   insert into ' + @destination_db + '[Contract] (contract_id, Contract) select s.contract_id, s.[contract_name]    
	   FROM ' + @source_db + 'contract_group s left join '+@destination_db+'[Contract] d on d.contract_id=s.contract_id   
	   where d.contract_id is null  
	 '  
	 exec spa_print @st  
	 exec(@st)  
	  
	 SET @st ='  
	   update d set  Deal_Type=s.source_deal_type_name  FROM '+@destination_db+'[Deal_Type] d inner join ' + @source_db + 'source_deal_type s on d.deal_type_id=s.source_deal_type_id  
	    
	   insert into ' + @destination_db + '[Deal_Type] (deal_type_id, Deal_Type)   
	   select s.[source_deal_type_id],s.[source_deal_type_name]    
	   FROM ' + @source_db + 'source_deal_type s left join '+@destination_db+'[Deal_Type] d on d.deal_type_id=s.source_deal_type_id  
		where d.deal_type_id is null  
	 '  
	  
	 exec spa_print @st  
	 exec(@st)  
	  
	 SET @st ='  
	   update d set  location=sml.[Location_Name], region=isnull(sdv2.code,''Unknown Region'') , grid=isnull(sdv1.code,''Unknown Grid'') , country=isnull(sdv.code,''Unknown Country'') , locationgroup=isnull(mjr.location_name,''Unknown Location Group'')   
		 FROM '+@destination_db+'[Location] d inner join ' + @source_db + '[source_minor_location] sml on d.location_id=sml.source_minor_location_id  
		left join ' + @source_db + 'static_data_value sdv1 on sdv1.value_id=sml.grid_value_id  
		left join ' + @source_db + 'static_data_value sdv on sdv.value_id=sml.country  
		left join ' + @source_db + 'static_data_value sdv2 on sdv2.value_id=sml.region  
		left join ' + @source_db + 'source_major_location mjr on  sml.source_major_location_ID=mjr.source_major_location_ID  
	  
	   insert into ' + @destination_db + '[Location] (location_id, location, region, grid, country, locationgroup)   
	   select sml.[source_minor_location_id],sml.[Location_Name],isnull(sdv2.code,''Unknown Region'') region,isnull(sdv1.code,''Unknown Grid'') grid,isnull(sdv.code,''Unknown Country'') country,isnull(mjr.location_name,''Unknown Location Group'') locationgroup  
		 FROM ' + @source_db + '[source_minor_location] sml left join '+@destination_db+'[Location] d on d.location_id=sml.source_minor_location_id  
		left join ' + @source_db + 'static_data_value sdv1 on sdv1.value_id=sml.grid_value_id  
		left join ' + @source_db + 'static_data_value sdv on sdv.value_id=sml.country  
		left join ' + @source_db + 'static_data_value sdv2 on sdv2.value_id=sml.region  
		left join ' + @source_db + 'source_major_location mjr on  sml.source_major_location_ID=mjr.source_major_location_ID  
		where d.location_id is null  
	 '  
	 exec spa_print @st  
	 exec(@st)  
	   
	--- CREATE THE location for unique combination of grid,country and region  
	  SET @st ='  
	   update d set  location=''Unknown Location'', region=isnull(sdv2.code,''Unknown Region'') , grid=isnull(sdv1.code,''Unknown Grid'') , country=isnull(sdv.code,''Unknown Country'') , locationgroup=''Unknown Location Group''   
		 FROM '+ @destination_db + '[Location] d   
		   INNER JOIN (SELECT -1*ROW_NUMBER() OVER (ORDER BY region,grid_value_id,country) location_id,  
			region,grid_value_id,country FROM '+@source_db+'[source_minor_location]  GROUP BY region,grid_value_id,country) sml  
		 ON d.location_id=sml.location_id  
		left join ' + @source_db + 'static_data_value sdv1 on sdv1.value_id=sml.grid_value_id  
		left join ' + @source_db + 'static_data_value sdv on sdv.value_id=sml.country  
		left join ' + @source_db + 'static_data_value sdv2 on sdv2.value_id=sml.region  
	  
	   insert into ' + @destination_db + '[Location] (location_id, location, region, grid, country, locationgroup)   
	   select sml.[location_id],''Unknown Location'',isnull(sdv2.code,''Unknown Region'') region,isnull(sdv1.code,''Unknown Grid'') grid,isnull(sdv.code,''Unknown Country'') country,''Unknown Location Group'' locationgroup  
		 FROM (SELECT -1*ROW_NUMBER() OVER (ORDER BY region,grid_value_id,country) location_id,  
			region,grid_value_id,country FROM '+@source_db+'[source_minor_location] GROUP BY region,grid_value_id,country) sml  
		LEFT JOIN '+ @destination_db + '[Location] d       
		 ON d.location_id=sml.location_id  
		left join ' + @source_db + 'static_data_value sdv1 on sdv1.value_id=sml.grid_value_id  
		left join ' + @source_db + 'static_data_value sdv on sdv.value_id=sml.country  
		left join ' + @source_db + 'static_data_value sdv2 on sdv2.value_id=sml.region  
		WHERE d.location_id is null      
	 '  
	 exec spa_print @st  
	 exec(@st)  
	   
	  
	 SET @st ='  
	   update d set  [index]=i.curve_name, commodity=isnull(c.commodity_name,''Unknown Commodity'') ,  
		 proxy_index1 = p1.curve_name,  
		 proxy_index2 = p2.curve_name,  
		 proxy_index3 = p3.curve_name,   
		 settlement_index = p4.curve_name,  
		 proxy_curve_name = p5.curve_name  
		FROM '+@destination_db+'[Index] d inner join ' + @source_db + '[source_price_curve_def] i on d.index_id=i.[source_curve_def_id]  
		LEFT JOIN ' + @source_db + 'source_commodity c ON i.commodity_id=c.source_commodity_id  
		LEFT JOIN ' + @source_db + 'source_price_curve_def p1 ON p1.source_curve_def_id = i.proxy_source_curve_def_id  
		LEFT JOIN ' + @source_db + 'source_price_curve_def p2 ON p2.source_curve_def_id = i.monthly_index  
		LEFT JOIN ' + @source_db + 'source_price_curve_def p3 ON p3.source_curve_def_id = i.proxy_curve_id3  
		LEFT JOIN ' + @source_db + 'source_price_curve_def p4 ON p4.source_curve_def_id = i.settlement_curve_id  
		LEFT JOIN ' + @source_db + 'source_price_curve_def p5 ON p5.source_curve_def_id = i.proxy_curve_id  
	     
	   insert into ' + @destination_db + '[Index] (index_id, [index], commodity,proxy_index1,proxy_index2,proxy_index3,settlement_index,proxy_curve_name)   
	   select i.[source_curve_def_id],i.[curve_name],isnull(c.commodity_name,''Unknown Commodity'') ,p1.curve_name,p2.curve_name,p3.curve_name,p4.curve_name,p5.curve_name  
		FROM ' + @source_db + '[source_price_curve_def] i left join '+@destination_db+'[Index] d on d.index_id=i.[source_curve_def_id]  
		LEFT JOIN ' + @source_db + 'source_commodity c ON i.commodity_id=c.source_commodity_id  
		 LEFT JOIN ' + @source_db + 'source_price_curve_def p1 ON p1.source_curve_def_id = i.proxy_source_curve_def_id  
		LEFT JOIN ' + @source_db + 'source_price_curve_def p2 ON p2.source_curve_def_id = i.monthly_index  
		LEFT JOIN ' + @source_db + 'source_price_curve_def p3 ON p3.source_curve_def_id = i.proxy_curve_id3  
		LEFT JOIN ' + @source_db + 'source_price_curve_def p4 ON p4.source_curve_def_id = i.settlement_curve_id  
		LEFT JOIN ' + @source_db + 'source_price_curve_def p5 ON p5.source_curve_def_id = i.proxy_curve_id  
	  
	   where d.index_id is null  
	 '  
	 exec spa_print @st  
	 exec(@st)  
	  
	 SET @st ='  
	   update d set  Product=s.[internal_portfolio_name]  FROM '+@destination_db+'[Product] d inner join ' + @source_db + '[source_internal_portfolio] s on d.product_id=s.source_internal_portfolio_id   
	     
	   insert into ' + @destination_db + '[Product] (product_id, Product) select s.[source_internal_portfolio_id],s.[internal_portfolio_name]    
	   FROM ' + @source_db + '[source_internal_portfolio] s left join '+@destination_db+'[Product] d on d.product_id=s.source_internal_portfolio_id   
	   where d.product_id is null  
	 '  
	 exec spa_print @st  
	 exec(@st)  
	  
	 SET @st ='  
	   update d set  Trader=s.[trader_name]  FROM '+@destination_db+'[Trader] d inner join ' + @source_db + '[source_traders] s on d.trader_id=s.[source_trader_id]  
	     
	   insert into ' + @destination_db + '[Trader] (trader_id, Trader) select s.[source_trader_id],s.[trader_name]    
	   FROM ' + @source_db + '[source_traders] s left join '+@destination_db+'[Trader] d on d.trader_id=s.[source_trader_id]   
	   where d.trader_id is null  
	 '  
	 exec spa_print @st  
	 exec(@st)  
	  
	 SET @st ='  
	   update d set  UOM=s.[uom_name]  FROM '+@destination_db+'UOM d left join ' + @source_db + '[source_uom] s on d.uom_id=s.[source_uom_id]  
	     
	   insert into ' + @destination_db + '[UOM] (uom_id, UOM) select s.[source_uom_id],s.[uom_name]   
		FROM ' + @source_db + '[source_uom] s left join '+@destination_db+' UOM d on d.uom_id=s.[source_uom_id]   
		where d.uom_id is null  
	 '  
	 exec spa_print @st  
	 exec(@st)  
	   
	 SET @st ='  
	   update d set  [Ref_Deal_ID]=s.deal_id ,[Deal_Date]=s.[Deal_Date],  
	   [reference]=NULLIF(s.reference,''''),[customer_parent] = uddf.udf_value   
	   FROM '+@destination_db+'Deal_Attributes d   
	   inner join ' + @source_db + 'source_deal_header s on d.deal_id=s.source_deal_header_id   
	   LEFT JOIN '+@source_db +'user_defined_deal_fields_template uddft ON uddft.template_id= s.template_id  
		AND uddft.Field_name=-5584  
	   LEFT JOIN '+@source_db +'user_defined_deal_fields uddf ON uddf.udf_template_id = uddft.udf_template_id  
		AND uddf.source_deal_header_id = s.source_deal_header_id  
	  
	  
	   INSERT INTO ' + @destination_db + '[Deal_Attributes] ([Deal_ID],[TRM_Deal_ID],[Ref_Deal_ID] ,[Deal_Date],[Reference],[Customer_Parent])  
		select s.source_deal_header_id, s.source_deal_header_id, s.deal_id,s.deal_date,NULLIF(s.reference,''''),uddf.udf_value    
		 FROM '+@source_db +'source_deal_header s  
		 LEFT JOIN ' + @destination_db + 'Deal_Attributes d on d.deal_id=s.source_deal_header_id   
		 LEFT JOIN '+@source_db +'user_defined_deal_fields_template uddft ON uddft.template_id= s.template_id  
		  AND uddft.Field_name=-5584  
		 LEFT JOIN '+@source_db +'user_defined_deal_fields uddf ON uddf.udf_template_id = uddft.udf_template_id  
		  AND uddf.source_deal_header_id = s.source_deal_header_id  
	   WHERE   
		d.deal_id is null  
	 '  
	 exec spa_print @st  
	 exec(@st)  
END


IF @run_type IN(0,2) -- position
BEGIN

 
 CREATE TABLE #temp_pos(  
  [source_deal_header_id] [int] NULL,  
  [source_curve_def_id] [int] NOT NULL,  
  [book_deal_type_map_id] [int] NULL,  
  [broker_id] [int] NULL,  
  [profile_id] [int] NULL,  
  [source_deal_type_id] [int] NULL,  
  [trader_id] [int] NULL,  
  [contract_id] [int] NULL,  
  [product_id] [int] NULL,  
  [template_id] [int] NULL,  
  [deal_status] [int] NULL,  
  [counterparty_id] [int] NULL,  
  [block_definition_id] [int] NULL,  
  [location_id] [int] NULL,  
  udf_block_group_id INT NULL,  
  [physical/Financial] [varchar](9) COLLATE DATABASE_DEFAULT NOT NULL,  
  [pv_party] [INT] NULL,  
  [Term Date] [datetime] NULL,  
  [Position] [numeric](38, 20) NULL,  
  [uom_id] [int] NULL,  
  category_id [int] NULL,  
  buy_sell_Flag CHAR(1) COLLATE DATABASE_DEFAULT  
 ) ON [PRIMARY]  
   
   
   
   
 SET @st = 'INSERT INTO #temp_pos(source_deal_header_id,source_curve_def_id,[book_deal_type_map_id],  
    [broker_id],[profile_id],source_deal_type_id,trader_id,contract_id,product_id,template_id,deal_status,counterparty_id,  
    [block_definition_id],udf_block_group_id,location_id,[physical/Financial],pv_party,[Term Date],[Position],uom_id,category_id,buy_sell_Flag) '  
   +' SELECT   
    source_deal_header_id ,  
    [Curve_id] ,  
    book_deal_type_map_id,  
    broker_id ,  
    profile_id,  
    source_deal_type_id,  
    trader_id ,  
    contract_id ,  
    product_id ,  
    template_id,  
    deal_status_id,     
    counterparty_id ,  
    block_define_id ,  
    udf_block_group_id ,  
    location_id ,  
    [physical/Financial],  
    pv_party_id,  
    [Term],  
    [Position],  
     uom_id,  
     category_id,  
     buy_sell_Flag  
    FROM '+@source_server+'adiha_process.dbo.cube_position_report_fin
    UNION
	SELECT   
    source_deal_header_id ,  
    [Curve_id] ,  
    book_deal_type_map_id,  
    broker_id ,  
    profile_id,  
    source_deal_type_id,  
    trader_id ,  
    contract_id ,  
    product_id ,  
    template_id,  
    deal_status_id,     
    counterparty_id ,  
    block_define_id ,  
    udf_block_group_id ,  
    location_id ,  
    [physical/Financial],  
    pv_party_id,  
    [Term],  
    [Position],  
     uom_id,  
     category_id,  
     buy_sell_Flag  
    FROM '+@source_server+'adiha_process.dbo.cube_position_report_phy    
    '  
   
 EXEC(@st)   

   
 SET @st = ' TRUNCATE TABLE '+@destination_db+'position_stage'
 EXEC(@st)
 
 
 SET @st = '  
  INSERT INTO '+@destination_db+'position_stage(logical_id,deal_id,book_deal_type_map_id,broker_id,profile_id,deal_type_id,trader_id,contract_id,  
  product_id,template_id  
  ,deal_status_id,counterparty_id,toublock_id,user_toublock_id,index_id,location_id,pvparty_id,uom_id,time_table_id,physical_financial_flag,buy_sell_Flag,Position,category_id,partition_flag)  
  SELECT lm.logical_id,pos.source_deal_header_id,isnull(pos.book_deal_type_map_id,-999999),isnull(pos.broker_id,-999999),isnull(pos.profile_id,-999999),  
   isnull(pos.source_deal_type_id,-999999),isnull(pos.trader_id,-999999),isnull(pos.contract_id,-999999),  
   isnull(pos.product_id,-999999),  
   isnull(pos.template_id,-999999)  
   ,isnull(pos.deal_status,-999999),isnull(pos.counterparty_id,-999999),  
   isnull(pos.block_definition_id,-999999),  
   isnull(pos.udf_block_group_id,-999999),  
   isnull(pos.source_curve_def_id,-999999),isnull(NULLIF(pos.location_id,-1),-999999),  
   ISNULL(pos.pv_party,-999999),  
   isnull(pos.uom_id,-999999),  
   t.time_table_id  
   ,LEFT(pos.[physical/financial],1),  
   pos.buy_sell_Flag,  
   pos.Position,  
   ISNULL(pos.category_id,-999999),
   2 partition_flag  
  FROM   
   #temp_pos pos  
   LEFT JOIN '+@destination_db+'[Time] t ON CAST(t.year AS INT)=YEAR(pos.[Term Date])  
     AND   t.month= UPPER(LEFT(DATENAME(m,pos.[Term Date]),3))  
     AND   (t.day)=UPPER(LEFT(DATENAME(m,pos.[Term Date]),3))  
     AND ISNUMERIC(t.day)=0   
   LEFT JOIN '+@destination_db+'logical_name lm ON lm.as_of_date_from = '''+@as_of_date+''' and lm.as_of_date_to ='''+@as_of_date+'''  
  '   
 exec spa_print @st   
 EXEC(@st)  
  

END


IF @run_type IN(0,3) -- Hourly position
BEGIN  

  
 CREATE TABLE #temp_pos_hourly(  
  [source_curve_def_id] [int] NOT NULL,  
  [book_deal_type_map_id] [int] NULL,  
  [broker_id] [int] NULL,  
  [profile_id] [int] NULL,  
  [source_deal_type_id] [int] NULL,  
  [trader_id] [int] NULL,  
  [contract_id] [int] NULL,  
  [product_id] [int] NULL,  
  [template_id] [int] NULL,  
  [deal_status] [int] NULL,  
  [counterparty_id] [int] NULL,  
  [block_definition_id] [int] NULL,  
  udf_block_group_id INT NULL,  
  [location_id] [int] NULL,  
  [physical/Financial] [varchar](9) COLLATE DATABASE_DEFAULT NOT NULL,  
  [pv_party] INT NULL,  
  [Term Date] [datetime] NULL,  
  [Hour] [int] NULL,  
  [DST] [int] NOT NULL,  
  [Position] [numeric](38, 20) NULL,  
  [uom_id] [int] NULL,  
  region INT NULL,  
  grid INT NULL,  
  country INT NULL,  
  category_id INT NULL,  
  buy_sell_Flag CHAR(1) COLLATE DATABASE_DEFAULT  
 ) ON [PRIMARY]  
   
   
   
   
 SET @st = ' INSERT INTO #temp_pos_hourly(source_curve_def_id,[book_deal_type_map_id],  
    [broker_id],[profile_id],source_deal_type_id,trader_id,contract_id,product_id,template_id,deal_status,counterparty_id,  
    [block_definition_id],udf_block_group_id,location_id,[physical/Financial],pv_party,[Term Date], [Hour], DST, [Position],uom_id,region,grid,country,category_id,buy_sell_Flag)'  
   +' SELECT   
    [Index] ,  
    book_deal_type_map_id,  
    broker_id ,  
    profile_id,  
    source_deal_type_id,  
    trader_id ,  
    contract_id ,  
    product_id ,  
    template_id,  
    deal_status,     
    counterparty_id ,  
    block_defintion_id ,  
    udf_block_group_id ,  
    location_id ,  
    [physical/Financial],  
    pv_party_id,  
    [Term],  
    [Hour],  
    DST,  
    [Position],  
     uom_id,  
     region,  
     grid,  
     country,  
     category_id,  
     buy_sell_Flag  
    FROM '+@source_server+'adiha_process.dbo.cube_position_report_hourly'  
   
 EXEC(@st)   
   

 SET @st = ' TRUNCATE TABLE '+@destination_db+'Hourly_Position_stage'
 EXEC(@st)
    
 SET @st = '  
  SELECT   
   location_id,sdv.value_id region,sdv1.value_id grid,sdv2.value_id country  
  INTO #temp_grid_region  
  FROM   
   '+@destination_db+'location l  
   LEFT JOIN '+@source_db+'static_data_value sdv ON sdv.code=l.region AND sdv.type_id=11150  
   LEFT JOIN '+@source_db+'static_data_value sdv1 ON sdv1.code=l.grid AND sdv1.type_id=18000  
   LEFT JOIN '+@source_db+'static_data_value sdv2 ON sdv2.code=l.country AND sdv2.type_id=14000  
  WHERE   
   l.location_id<-1  
     
  INSERT INTO '+@destination_db+'Hourly_Position_stage(logical_id,book_deal_type_map_id,broker_id,profile_id,deal_type_id,trader_id,contract_id,  
  product_id,template_id  
  ,deal_status_id,counterparty_id,toublock_id,user_toublock_id,index_id,location_id,pvparty_id,uom_id,time_table_id,physical_financial_flag,buy_sell_Flag,Position,category_id,partition_flag)  
  SELECT lm.logical_id,isnull(pos.book_deal_type_map_id,-999999),isnull(pos.broker_id,-999999),isnull(pos.profile_id,-999999),  
   isnull(pos.source_deal_type_id,-999999),isnull(pos.trader_id,-999999),isnull(pos.contract_id,-999999),  
   isnull(pos.product_id,-999999),  
   isnull(pos.template_id,-999999)  
   ,isnull(pos.deal_status,-999999),isnull(pos.counterparty_id,-999999),  
   isnull(pos.block_definition_id,-999999),  
   isnull(pos.udf_block_group_id,-999999),  
   isnull(pos.source_curve_def_id,-999999),  
   isnull(tg.location_id,-999999),  
   ISNULL(pos.pv_party,-999999),  
   isnull(pos.uom_id,-999999),  
   t.time_table_id,  
   LEFT(pos.[physical/financial],1),  
   pos.buy_sell_Flag,  
   pos.Position,  
   ISNULL(pos.category_id,-999999) ,
   2 partition_flag 
  FROM   
   #temp_pos_hourly pos  
   LEFT JOIN '+@source_db +'mv90_DST mv ON mv.[Date] = pos.[Term Date] AND mv.insert_delete = ''i'' AND pos.[Hour] = mv.[Hour]  
   LEFT JOIN '+@destination_db+'[Time] t ON CAST(t.year AS INT)=YEAR(pos.[Term date])  
     AND   t.month= UPPER(LEFT(DATENAME(m,pos.[Term date]),3))  
     AND   (t.day)=RIGHT(''00''+ CAST(DAY(pos.[Term date]) AS VARCHAR),2)  
     AND  (t.Hour)=RIGHT(''00''+ CAST(pos.[Hour] AS VARCHAR),2) + CASE WHEN mv.id IS NOT NULL AND pos.DST = 1 THEN '' -DST'' ELSE '''' END  
     AND ISNUMERIC(t.day)=1   
   LEFT JOIN '+@destination_db+'logical_name lm ON lm.as_of_date_from = '''+@as_of_date+''' and lm.as_of_date_to ='''+@as_of_date+'''  
   LEFT JOIN #temp_grid_region tg ON ISNULL(tg.region,-1)=ISNULL(pos.region,-1)  
    AND ISNULL(tg.grid,-1)=ISNULL(pos.grid,-1)  
    AND ISNULL(tg.country,-1)=ISNULL(pos.country,-1)  
  '   
 exec spa_print @st   
 EXEC(@st)  

END


IF @run_type IN(0,4) -- Index Breakdown  
BEGIN  
	 -- charge type from Index Breakdown  
	 SET @st ='  
	   INSERT into ' + @destination_db + '[pnl_type] (pnl_type)   
	   SELECT s.pnl_type  FROM   
	   (SELECT DISTINCT pnl_type FROM '+@source_server+'adiha_process.dbo.cube_forward_actual_values) s  
	   left join '+@destination_db+'pnl_type d on d.pnl_type=s.pnl_type     
	   where d.pnl_type is null  
	 '  
	 exec spa_print @st  
	 exec(@st)  
	

	 SET @st ='  
	   update d set  IndexBRK_Def=s.IndexBRK_Def  FROM '+@destination_db+'IndexBRK_Def d inner JOIN   
	   (SELECT DISTINCT field_id IndexBRK_ID,max(field_name) IndexBRK_Def FROM  '+@source_server+'adiha_process.dbo.cube_index_brk_report
	   group by field_id) s on d.IndexBRK_ID=s.IndexBRK_ID  
	     
	   insert into ' + @destination_db + '[IndexBRK_Def] (IndexBRK_ID, IndexBRK_Def) select s.IndexBRK_ID, s.IndexBRK_Def    
	   FROM   
	   (SELECT DISTINCT field_id IndexBRK_ID,max(field_name) IndexBRK_Def FROM '+@source_server+'adiha_process.dbo.cube_index_brk_report   
	   group by field_id) s   
	   left join '+@destination_db+'IndexBRK_Def d on d.IndexBRK_ID=s.IndexBRK_ID     
	   where d.IndexBRK_ID is null  
	 '  
	 exec spa_print @st  
	 exec(@st)  
	  

	 SET @st = ' TRUNCATE TABLE '+@destination_db+'IndexBRK_stage'
	 EXEC(@st)
		   
	SET @st ='  
	  INSERT INTO ' + @destination_db + '[IndexBRK_stage] ([logical_id],[book_deal_type_map_id],[broker_id],[profile_id],[deal_type_id],[trader_id],[contract_id]  
	   ,[product_id],[template_id],[deal_status_id],[counterparty_id],[toublock_id],[index_id],[pvparty_id]  
	   ,[location_id],[currency_id],[time_table_id],[Deal_ID],[physical_financial_flag],[buy_sell_Flag], IndexBRK_ID, IndexBRK,partition_flag)  
		select l.[logical_id],isnull(i.[book_deal_type_map_id],-999999),isnull(i.[broker_id],-999999),isnull(i.[profile_id],-999999)  
		,isnull(i.[deal_type_id],-999999),isnull(i.[trader_id],-999999),isnull(i.[contract_id],-999999)  
	   ,isnull(i.[product_id],-999999),isnull(i.[template_id],-999999),isnull(i.[deal_status_id],-999999),isnull(i.[counterparty_id],-999999)  
	   ,isnull(i.[toublock_id],-999999),isnull(i.[index_id],-999999),isnull(i.[pvparty_id],-999999)  
	   ,isnull(i.[location_id],-999999),isnull(i.[currency_id],-999999),t.[time_table_id],i.[Deal_ID],i.[physical_financial_flag],i.[buy_sell_Flag],   
	   i.field_ID, i.value,
	   2 partition_flag     
	  FROM   
	   '+@source_server+'adiha_process.dbo.cube_index_brk_report i   
	   inner JOIN   
		' + @destination_db + '[Time] t on CAST(t.year AS INT)=YEAR(i.term_start)  
		 AND   t.month= UPPER(LEFT(DATENAME(m,i.term_start),3))  
		 AND   (t.day)=UPPER(LEFT(DATENAME(m,i.term_start),3))  
		 AND ISNUMERIC(t.day)=0   
	   LEFT JOIN '+@destination_db+'logical_name l ON l.as_of_date_from = '''+ @as_of_date+''' and l.as_of_date_to='''+ @as_of_date+'''  '  
	 exec spa_print @st  
	 exec(@st)  
END

IF @run_type IN(0,5) -- FX Exposure
BEGIN  

	
	 SET @st = ' TRUNCATE TABLE '+@destination_db+'FX_Exposure_stage'
	 EXEC(@st)

	SET @st ='  
	  insert into ' + @destination_db + '[FX_Exposure_stage]  
	   ( [logical_id],[book_deal_type_map_id],[broker_id],[profile_id],[deal_type_id],[trader_id]  
	   ,[contract_id],[product_id],[template_id],[deal_status_id],[counterparty_id],[toublock_id]  
	   ,[index_id],[pvparty_id],[location_id],[currency_id],[time_table_id],[Deal_ID]  
	   ,[physical_financial_flag],[buy_sell_Flag],[Exposure_Side],[FX_Exposure],partition_flag  
		 )  
	   select   
	   l.[logical_id],isnull(ssbm.[book_deal_type_map_id],-999999),isnull(sdh.[broker_id],-999999),isnull(sdh.internal_desk_id,-999999) [profile_id]  
	   ,isnull(sdh.source_deal_type_id,-999999) [deal_type_id],isnull(sdh.[trader_id],-999999),isnull(sdh.[contract_id],-999999),isnull(sdh.[internal_portfolio_id],-999999)  
	   ,isnull(sdh.[template_id],-999999),isnull(sdh.deal_status,-999999) [deal_status_id],isnull(sdh.[counterparty_id],-999999),isnull(sdh.block_define_id,-999999) [toublock_id]  
	   ,isnull(max(i.curve_id),-999999) [index_id],isnull(max(sdd.[pv_party]),-999999) [pvparty_id],isnull(max(sdd.[location_id]),-999999),isnull(i.currency_id,-999999) [currency_id]  
	   ,max(t.[time_table_id]) [time_table_id],i.source_deal_header_id [Deal_ID]  
	   ,max(i.phy_fin) [physical_financial_flag],case when sum(i.volume)>0 then ''b'' else ''s'' end [buy_sell_Flag]  
	   ,max(i.exp_side) [Exposure_Side],sum(i.[FX_Exposure]) FX_Exposure,
	   2 partition_flag  
	   from    
	   ' + @source_db + '[FX_Exposure] i   
	   inner JOIN ' + @destination_db + '[Time] t on CAST(t.year AS INT)=YEAR(i.monthly_term)  
		 AND   t.[month]= UPPER(LEFT(DATENAME(m,i.monthly_term),3))  
		 AND   t.[day]=UPPER(LEFT(DATENAME(m,i.monthly_term),3))  
		 AND ISNUMERIC(t.day)=0   
	   INNER JOIN '+@source_db +'source_deal_header sdh ON sdh.source_deal_header_id = i.source_deal_header_id  
	   INNER JOIN '+@source_db +'[deal_status_group] dsg ON dsg.status_value_id = sdh.deal_status  
	   INNER JOIN '+@source_db +'source_system_book_map ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1    
		AND ssbm.source_system_book_id2 = sdh.source_system_book_id2  
		AND ssbm.source_system_book_id3 = sdh.source_system_book_id3  
		AND ssbm.source_system_book_id4 = sdh.source_system_book_id4  
	   LEFT JOIN '+@source_db +'source_deal_detail sdd ON sdd.source_deal_header_id = i.source_deal_header_id  
		AND convert(varchar(7),sdd.term_start,120) = convert(varchar(7),i.monthly_term,120)  
		AND sdd.leg=1  
	   LEFT join ' + @destination_db + 'logical_name l on  l.as_of_date_from=i.as_of_date and l.as_of_date_to=i.as_of_date  
	   and i.as_of_date='''+@as_of_date+'''  
	  WHERE i.as_of_date ='''+ @as_of_date+'''    
	  group by   i.source_deal_header_id,convert(varchar(7),i.monthly_term,120),i.currency_id,l.[logical_id],ssbm.[book_deal_type_map_id],sdh.[broker_id],sdh.internal_desk_id,sdh.source_deal_type_id  
		,sdh.[trader_id],sdh.[contract_id],sdh.[internal_portfolio_id],sdh.[template_id],sdh.deal_status,sdh.[counterparty_id],sdh.block_define_id,i.curve_id  
	  
	 '  
	  
	 exec spa_print @st  
	 exec(@st)  
  
	  
END

IF @run_type IN(0,6) -- Forward Actual
BEGIN  
		  
	 SET @st = ' TRUNCATE TABLE '+@destination_db+'Forward_Actual_stage'
	 EXEC(@st)
	  
	 -- Insert PNL Forward Actual Values  
	 set @st='  
	  INSERT INTO '+@destination_db+'Forward_Actual_stage  
		(logical_id,book_deal_type_map_id,broker_id,profile_id,deal_type_id,trader_id,contract_id,product_id,  
		template_id,deal_status_id,counterparty_id,toublock_id,index_id,pvparty_id,location_id,  
		currency_id,time_table_id,physical_financial_flag,buy_sell_Flag,mtm,dis_mtm,market_value,  
		dis_market_value,contract_value,dis_contract_value,Deal_ID,cashflow_month_id,pnl_month_id,category_id,charge_type_id,volume,pnl_volume,pnl_type_id,forward_actual_flag,pnl_amount,partition_flag)  
	   SELECT  
		lm.logical_id,  
		isnull(sdp.book_deal_type_map_id,-999999),isnull(sdp.broker_id,-999999),isnull(sdp.internal_desk_id,-999999),  
		isnull(sdp.source_deal_type_id,-999999),isnull(sdp.trader_id,-999999),isnull(sdp.contract_id,-999999),isnull(sdp.internal_portfolio_id,-999999),  
		isnull(sdp.template_id,-999999),isnull(sdp.deal_status,-999999),isnull(sdp.counterparty_id,-999999)  
		,isnull(sdp.block_define_id,-999999)  
		,isnull(sdp.curve_id,-999999),isnull(sdp.pv_party,-999999),  
		isnull(NULLIF(sdp.location_id,-1),-999999),isnull(sdp.pnl_currency_id,-999999),t.time_table_id,  
		sdp.physical_financial_flag,sdp.buy_sell_flag,sdp.und_pnl,sdp.dis_pnl,  
		sdp.market_value,sdp.dis_market_value,sdp.contract_value,sdp.dis_contract_value,sdp.source_deal_header_id,  
		ISNULL(t1.cf_time_table_id,-999999),  
		ISNULL(t2.pnl_time_table_id,t.time_table_id),  
		ISNULL(sdp.category_id,-999999),  
		ISNULL(sdp.charge_type_id,-999999),  
		sdp.volume,  
		sdp.pnl_volume,  
		ISNULL(pt.pnl_type_id,-999999),  
		sdp.forward_actual_flag,
		sdp.pnl_amount,
		2 partition_flag  
	   FROM  
		'+@source_server+'adiha_process.dbo.cube_forward_actual_values sdp  
		INNER JOIN '+@destination_db+'logical_name lm ON lm.as_of_date_from = '''+ @as_of_date+''' and lm.as_of_date_to='''+ @as_of_date+'''  
		INNER JOIN '+@destination_db+'[Time] t ON CAST(t.year AS INT)=YEAR(sdp.term_start)  
		 AND   t.month= UPPER(LEFT(DATENAME(m,sdp.term_start),3))  
		 AND   (t.day)=UPPER(LEFT(DATENAME(m,sdp.term_start),3))  
		 AND ISNUMERIC(t.day)=0    
		LEFT JOIN '+@destination_db+'[cashflow_date] t1 ON CAST(t1.year AS INT)=YEAR(sdp.cashflow_date)  
		 AND t1.month= UPPER(LEFT(DATENAME(m,sdp.cashflow_date),3))  
		 AND CAST(t1.day AS INT)=Datepart(d,sdp.cashflow_date)  
		LEFT JOIN '+@destination_db+'[pnl_date] t2 ON CAST(t2.year AS INT)=YEAR(sdp.pnl_date)  
		 AND t2.month= UPPER(LEFT(DATENAME(m,sdp.pnl_date),3))  
		 AND CAST(t2.day AS INT)=Datepart(d,sdp.pnl_date)   
		LEFT JOIN pnl_type pt ON pt.pnl_type =  sdp.pnl_type   '    
	 exec spa_print @st  
	 exec(@st)  
  	
END

IF @run_type IN(0,7) -- Value Report
BEGIN  

	  
	 SET @st = ' TRUNCATE TABLE '+@destination_db+'Value_Report_stage'
	 EXEC(@st)  

	 SET @st ='  
	  INSERT INTO ' + @destination_db + '[Value_Report_stage] ([logical_id],[vr_logical_id],[index_id],[book_deal_type_map_id],[counterparty_id],[user_toublock_id],  
	   [type],[avg_price],[value],[value_in_base_uom],[currency_id],[uom_id],partition_flag)  
	  SELECT  
	   l.[logical_id],  
	   COALESCE(lt.[vr_logical_id],lt1.[vr_logical_id],lt2.[vr_logical_id],lt3.[vr_logical_id]) vr_logical_id,  
	   ISNULL(vr.index_id,-999999),  
	   ISNULL(vr.book_deal_type_map_id,-999999),  
	   ISNULL(vr.counterparty_id,-999999),  
	   ISNULL(vr.user_toublock_id,-999999),  
	   ISNULL(vr.type,-999999),  
	   vr.avg_price,  
	   vr.value,  
	   vr.value_in_base_uom,  
	   ISNULL(vr.currency_id,-999999),  
	   ISNULL(vr.uom_id,-999999),
	   2 partition_flag  
	  FROM   
	   '+@source_server+'adiha_process.dbo.value_report vr   
	   LEFT JOIN '+@destination_db+'logical_name l ON l.as_of_date_from = '''+ @as_of_date+''' and l.as_of_date_to='''+ @as_of_date+'''  
	   LEFT join '+@destination_db+'Value_Report_Logical_Term lt on lt.[year]=vr.[year] AND vr.[type]=lt.[type_yearly] AND vr.[type]=''Yearly'' 
	   LEFT join '+@destination_db+'Value_Report_Logical_Term lt1 on lt1.[year]=vr.[year] AND lt1.[quarter]=vr.[quarter] AND vr.[type]=lt1.[type_quarterly] AND vr.[type]=''Quarterly''   
	   LEFT join '+@destination_db+'Value_Report_Logical_Term lt2 on lt2.[year]=vr.[year] AND lt2.[season]=vr.[season] AND vr.[type]=lt2.[type_seasonal] AND vr.[type]=''Seasonal''   
	   LEFT join '+@destination_db+'Value_Report_Logical_Term lt3 on lt3.[year]=vr.[year] AND lt3.[MonthNo]=vr.[month] AND vr.[type]=lt3.[type_monthly] AND vr.[type]=''Monthly'''  
	 
	 EXEC(@st)   	  	    

END

IF @run_type IN(0,8) -- Position Explain
BEGIN  
	
	 SET @st = ' TRUNCATE TABLE '+@destination_db+'Position_Explain_stage'
	 EXEC(@st)

	SET @st = '  
				INSERT INTO Position_Explain_stage (logical_id,book_deal_type_map_id,
					counterparty_id,index_id,user_toublock_id,
					time_table_id,physical_financial_flag,uom_id,
					begin_position,new_deal_position,modified_deal_position,
					forecast_changed_position,deleted_position,delivered_position,end_position,partition_flag)
				SELECT
					lm.logical_id,
					isnull(sdp.book_deal_type_map_id,-999999),
					isnull(sdp.counterparty_id,-999999),
					isnull(sdp.curve_id,-999999),
					ISNULL(NULLIF(CAST(sdp.tou_id AS VARCHAR),''NULL''),-999999) tou_id,
					t.time_table_id,
					sdp.physical_financial_flag,
					isnull(sdp.uom_id,-999999),
					ob_value,
					new_deal,
					modify_deal,
					forecast_changed,
					deleted,
					delivered,
					cb_value,
					2 partition_flag
				FROM
					'+@source_db +'explain_position sdp
					INNER JOIN logical_name lm ON lm.as_of_date_from = sdp.as_of_date_to AND lm.as_of_date_from = '''+@as_of_date+''' and lm.as_of_date_to='''+@as_of_date+'''
					INNER JOIN [Time] t ON CAST(t.year AS INT)=YEAR(sdp.term_start)
						AND   t.month= UPPER(LEFT(DATENAME(m,sdp.term_start),3))
						AND   (t.day)=DAY(sdp.term_start)
						AND	  ISNUMERIC(t.day)=1
						AND   t.hour = cast(sdp.Hr as varchar) '		 
	EXEC(@st) 
END

IF @run_type IN(0,9) -- Position Explain
BEGIN

	 SET @st = ' TRUNCATE TABLE '+@destination_db+'MTM_Explain_stage'
	 EXEC(@st)
  

	SET @st = ' INSERT INTO MTM_Explain_stage (logical_id,book_deal_type_map_id,
					counterparty_id,index_id,time_table_id,physical_financial_flag,
					charge_type_id,currency_id,begin_mtm,new_deal_mtm,modified_deal_mtm,
					forecast_changed_mtm,deleted_mtm,delivered_mtm,price_changed_mtm,unexplained_mtm,end_mtm,partition_flag)
				SELECT
					lm.logical_id,
					ISNULL(sdp.book_deal_type_map_id,-999999),
					ISNULL(sdp.counterparty_id,-999999),
					ISNULL(sdp.curve_id,-999999),
					t.time_table_id,
					sdp.physical_financial_flag,
					ISNULL(sdp.charge_type,-999999),
					ISNULL(sdp.currency_id,-999999),
					ob_mtm,
					new_deal,
					deal_modify,
					forecast_changed,
					deleted,
					delivered,
					price_changed,
					un_explain,
					cb_mtm,
					2 partition_flag
				FROM
					explain_mtm sdp
					INNER JOIN logical_name lm ON lm.as_of_date_from = sdp.as_of_date_to AND lm.as_of_date_from = '''+@as_of_date+''' and lm.as_of_date_to='''+@as_of_date+'''
					INNER JOIN [Time] t ON CAST(t.year AS INT)=YEAR(sdp.term_start)
					  AND t.month= UPPER(LEFT(DATENAME(m,sdp.term_start),3))
					 AND (t.day)=UPPER(LEFT(DATENAME(m,sdp.term_start),3))  
					 AND ISNUMERIC(t.day)=0    '		 
	EXEC(@st) 
 
	END 

IF @run_type IN(-1) -- Transfer data to main table from staging table
BEGIN	  
	
 SET @st ='  
  delete ' + @destination_db + 'position  from ' + @destination_db + 'position s inner join ' + @destination_db + 'logical_name l on s.logical_id=l.logical_id and l.as_of_date_from='''+ @as_of_date+''' and l.as_of_date_to='''+ @as_of_date +''''  
 exec spa_print @st  
 exec(@st)  


 SET @st ='   
  delete ' + @destination_db + 'hourly_position  from ' + @destination_db + 'hourly_position s inner join ' + @destination_db + 'logical_name l on s.logical_id=l.logical_id and l.as_of_date_from='''+ @as_of_date+''' and l.as_of_date_to='''+ @as_of_date +''''  
  exec spa_print @st  
  exec(@st)      

 SET @st ='  
  delete ' + @destination_db + '[IndexBRK]  from ' + @destination_db + '[IndexBRK] s inner join ' + @destination_db + 'logical_name l on s.logical_id=l.logical_id and l.as_of_date_from='''+ @as_of_date+''' and l.as_of_date_to='''+ @as_of_date +''''  
 exec spa_print @st  
 exec(@st)  

 SET @st ='   
  delete ' + @destination_db + 'FX_Exposure  from ' + @destination_db + 'FX_Exposure s inner join ' + @destination_db + 'logical_name l on s.logical_id=l.logical_id and l.as_of_date_from='''+ @as_of_date+''' and l.as_of_date_to='''+ @as_of_date +''''  
  exec spa_print @st  
  exec(@st)  


 SET @st ='   
  delete ' + @destination_db + 'forward_actual  from ' + @destination_db + 'forward_actual s inner join ' + @destination_db + 'logical_name l on s.logical_id=l.logical_id and l.as_of_date_from='''+ @as_of_date+''' and l.as_of_date_to='''+ @as_of_date +''''  
  exec spa_print @st  
  exec(@st)   

 SET @st ='   
  delete ' + @destination_db + 'Value_Report  from ' + @destination_db + 'Value_Report s inner join ' + @destination_db + 'logical_name l on s.logical_id=l.logical_id and l.as_of_date_from='''+ @as_of_date+''' and l.as_of_date_to='''+ @as_of_date +''''  
  exec spa_print @st  
  exec(@st)   
	  

	 
 SET @st ='   
  delete ' + @destination_db + 'Position_Explain  from ' + @destination_db + 'Position_Explain s inner join ' + @destination_db + 'logical_name l on s.logical_id=l.logical_id and l.as_of_date_from='''+ @as_of_date+''' and l.as_of_date_to='''+ @as_of_date +''''  
  exec spa_print @st  
  exec(@st)   


 SET @st ='   
  delete ' + @destination_db + 'MTM_Explain  from ' + @destination_db + 'MTM_Explain s inner join ' + @destination_db + 'logical_name l on s.logical_id=l.logical_id and l.as_of_date_from='''+ @as_of_date+''' and l.as_of_date_to='''+ @as_of_date +''''  
  exec spa_print @st  
  exec(@st)   


SET @st =' INSERT INTO ' + @destination_db + 'position(logical_id,book_deal_type_map_id,broker_id,profile_id,deal_type_id,trader_id,contract_id,product_id,template_id,deal_status_id,counterparty_id,user_toublock_id,toublock_id,index_id,location_id,pvparty_id,uom_id,time_table_id,physical_financial_flag,buy_sell_Flag,deal_id,position,Category_id) SELECT t.logical_id,book_deal_type_map_id,broker_id,profile_id,deal_type_id,trader_id,contract_id,product_id,template_id,deal_status_id,counterparty_id,user_toublock_id,toublock_id,index_id,location_id,pvparty_id,uom_id,time_table_id,physical_financial_flag,buy_sell_Flag,deal_id,position,Category_id FROM ' + @destination_db + 'position_stage t '     
 
 EXEC(@st)

 SET @st =' INSERT INTO ' + @destination_db + 'hourly_position(logical_id,book_deal_type_map_id,broker_id,profile_id,deal_type_id,trader_id,contract_id,product_id,template_id,deal_status_id,counterparty_id,user_toublock_id,toublock_id,index_id,location_id,pvparty_id,uom_id,time_table_id,physical_financial_flag,buy_sell_Flag,Position,Category_id) SELECT t.logical_id,book_deal_type_map_id,broker_id,profile_id,deal_type_id,trader_id,contract_id,product_id,template_id,deal_status_id,counterparty_id,user_toublock_id,toublock_id,index_id,location_id,pvparty_id,uom_id,time_table_id,physical_financial_flag,buy_sell_Flag,Position,Category_id FROM ' + @destination_db + 'hourly_position_stage t '     
 EXEC(@st)

 SET @st =' INSERT INTO ' + @destination_db + 'IndexBRK(logical_id,book_deal_type_map_id,broker_id,profile_id,deal_type_id,trader_id,contract_id,product_id,template_id,deal_status_id,counterparty_id,toublock_id,index_id,pvparty_id,location_id,currency_id,time_table_id,Deal_ID,physical_financial_flag,buy_sell_Flag,IndexBRK_ID,IndexBRK) SELECT t.logical_id,book_deal_type_map_id,broker_id,profile_id,deal_type_id,trader_id,contract_id,product_id,template_id,deal_status_id,counterparty_id,toublock_id,index_id,pvparty_id,location_id,currency_id,time_table_id,Deal_ID,physical_financial_flag,buy_sell_Flag,IndexBRK_ID,IndexBRK FROM ' + @destination_db + 'IndexBRK_stage t '     
 EXEC(@st)
 
 SET @st =' INSERT INTO ' + @destination_db + 'FX_Exposure(logical_id,book_deal_type_map_id,broker_id,profile_id,deal_type_id,trader_id,contract_id,product_id,template_id,deal_status_id,counterparty_id,toublock_id,index_id,pvparty_id,location_id,currency_id,time_table_id,Deal_ID,physical_financial_flag,buy_sell_Flag,Exposure_Side,FX_Exposure) SELECT t.logical_id,book_deal_type_map_id,broker_id,profile_id,deal_type_id,trader_id,contract_id,product_id,template_id,deal_status_id,counterparty_id,toublock_id,index_id,pvparty_id,location_id,currency_id,time_table_id,Deal_ID,physical_financial_flag,buy_sell_Flag,Exposure_Side,FX_Exposure FROM ' + @destination_db + 'FX_Exposure_stage t '     
 EXEC(@st)
 
 SET @st =' INSERT INTO ' + @destination_db + 'forward_actual(logical_id,book_deal_type_map_id,broker_id,profile_id,deal_type_id,trader_id,contract_id,product_id,template_id,deal_status_id,counterparty_id,toublock_id,index_id,pvparty_id,location_id,category_id,charge_type_id,currency_id,time_table_id,pnl_month_id,cashflow_month_id,Deal_ID,physical_financial_flag,buy_sell_Flag,leg,pnl_type_id,forward_actual_flag,MTM,Dis_MTM,Market_Value,Dis_Market_Value,Contract_Value,Dis_Contract_Value,Volume,PNL_Volume,PNL_Amount) SELECT t.logical_id,book_deal_type_map_id,broker_id,profile_id,deal_type_id,trader_id,contract_id,product_id,template_id,deal_status_id,counterparty_id,toublock_id,index_id,pvparty_id,location_id,category_id,charge_type_id,currency_id,time_table_id,pnl_month_id,cashflow_month_id,Deal_ID,physical_financial_flag,buy_sell_Flag,leg,pnl_type_id,forward_actual_flag,MTM,Dis_MTM,Market_Value,Dis_Market_Value,Contract_Value,Dis_Contract_Value,Volume,PNL_Volume,PNL_Amount FROM ' + @destination_db + 'forward_actual_stage t '     
 EXEC(@st)

 SET @st =' INSERT INTO ' + @destination_db + 'Value_Report(logical_id,vr_logical_id,index_id,book_deal_type_map_id,counterparty_id,user_toublock_id,type,avg_price,value,value_in_base_uom,currency_id,uom_id) SELECT t.logical_id,vr_logical_id,index_id,book_deal_type_map_id,counterparty_id,user_toublock_id,type,avg_price,value,value_in_base_uom,currency_id,uom_id FROM ' + @destination_db + 'Value_Report_stage t '     
 EXEC(@st)

 SET @st =' INSERT INTO ' + @destination_db + 'Position_Explain(logical_id,book_deal_type_map_id,counterparty_id,index_id,physical_financial_flag,user_toublock_id,time_table_id,uom_id,begin_position,new_deal_position,modified_deal_position,forecast_changed_position,deleted_position,delivered_position,end_position) SELECT t.logical_id,book_deal_type_map_id,counterparty_id,index_id,physical_financial_flag,user_toublock_id,time_table_id,uom_id,begin_position,new_deal_position,modified_deal_position,forecast_changed_position,deleted_position,delivered_position,end_position FROM ' + @destination_db + 'Position_Explain_stage t '     
 EXEC(@st)

 SET @st =' INSERT INTO ' + @destination_db + 'MTM_Explain(logical_id,book_deal_type_map_id,counterparty_id,index_id,physical_financial_flag,charge_type_id,currency_id,time_table_id,begin_mtm,new_deal_mtm,modified_deal_mtm,forecast_changed_mtm,deleted_mtm,delivered_mtm,price_changed_mtm,unexplained_mtm,end_mtm) SELECT t.logical_id,book_deal_type_map_id,counterparty_id,index_id,physical_financial_flag,charge_type_id,currency_id,time_table_id,begin_mtm,new_deal_mtm,modified_deal_mtm,forecast_changed_mtm,deleted_mtm,delivered_mtm,price_changed_mtm,unexplained_mtm,end_mtm FROM ' + @destination_db + 'MTM_Explain_stage t '     
 --EXEC(@st)

END

END  
