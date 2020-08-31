
/****** Object:  StoredProcedure [dbo].[spa_cube_MTM]    Script Date: 06/04/2012 06:29:44 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_cube_MTM]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_cube_MTM]
GO

/****** Object:  StoredProcedure [dbo].[spa_cube_MTM]    Script Date: 06/04/2012 06:29:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


  
CREATE PROC [dbo].[spa_cube_MTM]   
 @as_of_date VARCHAR(20)=NULL,  
 @source_deal_header_id VARCHAR(2000) = NULL  
  
AS  
BEGIN  
  
 DECLARE @process_table_name VARCHAR(100),@sql VARCHAR(MAX),@final_actual_table VARCHAR(100),@term_start VARCHAR(10),@term_end VARCHAR(10),@final_forward_table VARCHAR(100)  
 DECLARE @value_report VARCHAR(100)  
   
 DECLARE @hour INT  
 IF @as_of_date IS NULL  
 BEGIN  
  --SET @hour=DATEPART(hour,GETDATE())  
  --IF @hour>= 0 AND @hour<=11  
  -- SET @as_of_date=CONVERT(VARCHAR(10),getdate()-1,120)  
  --ELSE  
   SET @as_of_date=CONVERT(VARCHAR(10),getdate(),120)   
 END   
  --SET @process_table_name = 'adiha_process.dbo.cube_mtm_report'  
  
 SET @term_start='NULL'  
 SET @term_end='NULL'  
  
  
 SET @final_forward_table='adiha_process.dbo.cube_forward_actual_values'  
 SET @value_report = 'adiha_process.dbo.value_report'  
  
  
  IF OBJECT_ID(N'adiha_process.dbo.cube_index_brk_report', N'U') IS NOT NULL   
  DROP TABLE adiha_process.dbo.cube_index_brk_report      
  
  
  IF OBJECT_ID(N'adiha_process.dbo.value_report', N'U') IS NOT NULL   
  DROP TABLE adiha_process.dbo.value_report      
   
  
 IF OBJECT_ID(N'msdb..#deal_pnl', N'U') IS NOT NULL  
  DROP TABLE #deal_pnl  
  
  
 IF OBJECT_ID(N'adiha_process.dbo.cube_forward_actual_values', N'U') IS NOT NULL  
  DROP TABLE adiha_process.dbo.cube_forward_actual_values  
    
   
 -- Populate the process Tables  
  
 SET @sql = '  
   SELECT     
    sdp.as_of_date as_of_date,  
    sdp.term_start,  
    isnull(ssbm.book_deal_type_map_id,-999999) book_deal_type_map_id,  
    isnull(sdh.broker_id,-999999) broker_id,  
    isnull(sdh.internal_desk_id,-999999) profile_id,  
    isnull(sdh.source_deal_type_id,-999999) deal_type_id,  
    isnull(sdh.trader_id,-999999) trader_id,  
    isnull(sdh.contract_id,-999999) contract_id,  
    isnull(sdh.internal_portfolio_id,-999999) product_id,  
    isnull(sdh.template_id,-999999) template_id,  
    isnull(sdh.deal_status,-999999) deal_status_id,  
    isnull(sdh.counterparty_id,-999999) counterparty_id,  
    isnull(ISNULL(spcd.block_define_id,sdh.block_define_id),-999999) toublock_id  
    ,isnull(sdd.curve_id,-999999) index_id,  
    isnull(sdd.pv_party,-999999) pvparty_id,  
    isnull(NULLIF(sdd.location_id,-1),-999999) location_id,  
    isnull(sdp.currency_id,-999999) currency_id,  
    sdd.physical_financial_flag,  
    sdd.buy_sell_flag,  
    sdh.source_deal_header_id Deal_ID,  
    sdp.field_ID,   
    sdp.value,
    sdp.field_name    
   INTO  
    adiha_process.dbo.cube_index_brk_report      
   FROM  
    index_fees_breakdown sdp   
    INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdp.source_deal_header_id  
      AND sdp.internal_type = -1  
    INNER JOIN [deal_status_group] dsg ON dsg.status_value_id = sdh.deal_status   
    INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id=sdh.source_deal_header_id  
     AND sdd.Leg=sdp.leg  
     AND sdd.term_start=sdp.term_start   
    INNER JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1    
     AND ssbm.source_system_book_id2 = sdh.source_system_book_id2  
     AND ssbm.source_system_book_id3 = sdh.source_system_book_id3  
     AND ssbm.source_system_book_id4 = sdh.source_system_book_id4  
    LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=sdd.curve_id    
   WHERE sdp.as_of_date = '''+@as_of_date+''''  
   +CASE WHEN @source_deal_header_id IS NOT NULL THEN ' AND sdh.source_deal_header_id IN('+@source_deal_header_id+')' ELSE '' END  
    
    
  EXEC(@sql)  
      
  
---- Populate PNL forward and Actual  
  
 SET @sql='    
  CREATE TABLE '+@final_forward_table+'(  
   [term_start] [datetime] NULL,  
   [book_deal_type_map_id] [int],  
   [broker_id] [int],  
   [internal_desk_id] [int],  
   [source_deal_type_id] [int],  
   [trader_id] [int],  
   [contract_id] [int],  
   [internal_portfolio_id] [int],  
   [template_id] [int],  
   [deal_status] [int],  
   [counterparty_id] [int],  
   [block_define_id] [int],  
   [curve_id] [int],  
   [pv_party] [int],  
   [location_id] [int],  
   [pnl_currency_id] [int],  
   [physical_financial_flag] [char](1) NULL,  
   [buy_sell_flag] [char](1),  
   [und_pnl] [float] NULL,  
   [dis_pnl] [float] NULL,  
   [market_value] [float] NULL,  
   [dis_market_value] [float] NULL,  
   [contract_value] [float] NULL,  
   [dis_contract_value] [float] NULL,  
   [source_deal_header_id] [int],  
   [charge_type] [varchar](100),  
   [charge_type_id] INT NULL,  
   [cashflow_date] DATETIME,  
   [pnl_date] DATETIME,  
   [category_id] INT,  
   [pnl_type] VARCHAR(100),  
   forward_actual_flag CHAR(1),  
   Volume FLOAT,  
   pnl_volume FLOAT,
   pnl_amount FLOAT,
   [CAT1] VARCHAR(100),
   [CAT2] VARCHAR(100),
   [CAT3] VARCHAR(100)
  )'  
 EXEC(@sql)  
   
 IF @source_deal_header_id IS NULL  
  SET @source_deal_header_id=''  
    
 SET @sql='   
 INSERT INTO '+@final_forward_table+
 ' EXEC spa_Create_MTM_Period_Report_TRM '''+@as_of_date+''', ''147,148,149'',NULL,NULL, ''u'', ''a'', ''a'',''21'',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,''n'',''401,400'','''+@source_deal_header_id+''','''+@source_deal_header_id+
 ''',NULL,NULL,''n'',''n'',''y'',''n'',''2'',''a'',''m'',''n'',NULL,4500,''b'',NULL, NULL,''b'',NULL,''n'',NULL,NULL,NULL, NULL, ''y'', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,1, ''t'',NULL,NULL '  
   
 EXEC spa_print @sql   
 EXEC(@sql)  
  
   
  
  
 --########### value Report  
   
  CREATE TABLE #temp_VR(  
   [as_of_date] VARCHAR(20) COLLATE DATABASE_DEFAULT NULL,  
   [vr_logical_name] VARCHAR(50) COLLATE DATABASE_DEFAULT NULL,  
   [index_id] [int] NULL,  
   [counterparty_id] [int] NULL,  
   [book_id] [int] NULL,  
   [commodity_id] [int] NULL,  
   [base_curve_id] int NULL,     
   [user_toublock_id] [int] NULL,  
   [type] [VARCHAR](20) COLLATE DATABASE_DEFAULT NULL,  
   [avg_price] [FLOAT] NULL,  
   [value] [FLOAT] NULL,  
   [value_in_base_uom] [FLOAT] NULL,  
   [currency_id] [int] NULL,   
   [uom_id] [int] NULL,  
   [source_system_book_id1] [int] NULL,  
   [source_system_book_id2] [int] NULL,  
   [source_system_book_id3] [int] NULL,  
   [source_system_book_id4] [int] NULL,
   [year] INT,
   [month] INT,
   [season] VARCHAR(20) COLLATE DATABASE_DEFAULT, 
   [quarter] INT     
  )  
    
 INSERT INTO #temp_VR  
 EXEC spa_get_value_report @as_of_date,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'c'  
   
 SET @sql='   
 SELECT  
  [as_of_date],  
  [vr_logical_name],  
  [index_id],  
  [counterparty_id],  
  ssbm.book_deal_type_map_id,  
  [user_toublock_id],  
  [type],  
  [avg_price],  
  [value],  
  [value_in_base_uom],  
  [currency_id],   
  [uom_id],
  [year],
  [month],
  [season],
  ''Q''+CAST([quarter] AS VARCHAR)[quarter]    
 INTO '+@value_report+'  
 FROM  
  #temp_VR tv  
  LEFT JOIN source_system_book_map ssbm  
   ON tv.source_system_book_id1 = ssbm.source_system_book_id1  
      AND tv.source_system_book_id2 = ssbm.source_system_book_id2  
      AND tv.source_system_book_id3 = ssbm.source_system_book_id3  
      AND tv.source_system_book_id4 = ssbm.source_system_book_id4  
 '  
   
   
 EXEC(@sql)  
  
  
END  
 /************************************* Object: 'spa_cube_MTM' END *************************************/ 

GO


