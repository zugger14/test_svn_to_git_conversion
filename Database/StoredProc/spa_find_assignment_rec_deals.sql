

----------/****** Object:  StoredProcedure [dbo].[spa_find_assignment_rec_deals]    Script Date: 5/23/2014 10:51:20 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[spa_find_assignment_rec_deals]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_find_assignment_rec_deals]
GO
/*
* History:
* 2013-06-19 - bbajracharya
*	Rewrote assignment logic and used same logic for both requirement % type and flat target type assignment.
* 2013-06-26 - mmanandhar
*	Showed the selected deals in the grid along with its related columns from different tables.
* 2013-07-01 - bbajracharya
*	Changed assignment logic to show the result tier wise, which will allow to see the contribution made by 
*	a deal into different tiers. This is required in Target Position Report.
* 2013-07-04 - bbajracharya
*	Changed assignment logic to support assignment and constraint requirement types of tier. 
*	Also supports both carryover and no-carryover in allocation, which is configurable via Applied Constraint property in requirement.
*	Please refer to visio flowchart (GreenCO Assignment Logic Flowchart)
* 2013-08-02 bbajracharya
*	Changed FLOAT to NUMERIC(38, 20) of few columns (price, volume, conv_factor etc).
* 2013-08-12 bbajracharya
*	Taken account of adjustment deals, which will deduct the volume of eligible detail RECs
* 2013-08-19 bbajracharya
*	Replaced paging and batch logic with new ones. Previous has issues with paging as the whole logic was executed even when page change was called.	
* 2013-11-30 mmanandhar
* Added bonus and expiration logic
* 2013-12-02 mmanandhar
* Changed deal pulling logic
* */
  
 CREATE procedure [dbo].[spa_find_assignment_rec_deals]   
 @flag CHAR(1)	--s (requirement %), o (flat target)
 , @fas_sub_id  VARCHAR(5000)  
 , @fas_strategy_id  VARCHAR(5000)  
 , @fas_book_id VARCHAR(5000)  
 , @assignment_type INT   
 , @assigned_state INT    
 , @compliance_year INT    
 , @assigned_date VARCHAR(20)   
 , @curve_id INT   
 , @table_name VARCHAR(100)    
 , @convert_uom_id INT    
 , @gen_state INT    
 , @gen_year INT    
 , @gen_date_from DATETIME  
 , @gen_date_to DATETIME  
 , @generator_id INT  
 , @counterparty_id INT  
 , @deal_id varchar(500)  
 , @udf_group1 INT  
 , @udf_group2 INT  
 , @udf_group3 INT  
 , @tier_type INT  
 , @program_scope INT
 
 , @assignment_group INT  
 , @cert_from INT=NULL  
 , @cert_to INT=NULL  
 , @unassign int = 0  
 , @volume NUMERIC(38, 20) = 0
 , @fifo_lifo varchar(1) = NULL
 , @debug BIT  = 0
 , @export CHAR = NULL
 , @batch_process_id varchar(50)=NULL
 , @batch_report_param varchar(1000)=NULL
 , @enable_paging int=0  --'1'=enable '0'=disable
 , @page_size int =NULL
 , @page_no int=NULL
 AS  
 
 /**************************TEST CODE START************************				
DECLARE	@flag	CHAR(1)	=	'o'
DECLARE	@fas_sub_id	VARCHAR(5000)	=	'1577,1471,1461,1341,1334,1275,1249,1323,1188,1301,1441,1588,1266,1283,1305,1292,1328,1329,1256,1253,1492,1584,1499,1574,1261,1509,1508,1297,1376,1468,1488,1438,1316,1278'
DECLARE	@fas_strategy_id	VARCHAR(5000)	=	'1578,1580,1582,1472,1462,1342,1367,1393,1399,1452,1464,1467,1480,1585,1335,1336,1337,1381,1387,1402,1477,1478,1276,1250,1324,1189,1190,1281,1295,1302,1384,1447,1442,1267,1268,1272,1284,1306,1293,1330,1332,1257,1254,1493,1495,1497,1500,1575,1262,1264,1475,1298,1391,1412,1433,1377,1469,1489,1439,1317,1374,1389,1395,1425,1506,1520,1521,1522,1523,1536,1279'
DECLARE	@fas_book_id	VARCHAR(5000)	=	'1579,1581,1583,1473,1474,1463,1372,1368,1369,1394,1400,1453,1454,1465,1466,1487,1338,1339,1340,1382,1383,1388,1403,1479,1277,1251,1274,1325,1241,1246,1259,1243,1244,1245,1247,1248,1260,1282,1296,1303,1308,1309,1315,1364,1371,1385,1448,1269,1270,1273,1285,1286,1307,1294,1313,1314,1331,1333,1258,1255,1494,1496,1498,1501,1576,1263,1265,1450,1476,1299,1386,1392,1397,1398,1401,1404,1411,1413,1436,1378,1380,1470,1490,1440,1318,1319,1320,1321,1322,1370,1373,1444,1445,1491,1375,1390,1396,1426,1507,1524,1525,1526,1527,1528,1529,1537,1280'
DECLARE	@assignment_type	INT	=	'5173'
DECLARE	@assigned_state	INT	=	'309371'
DECLARE	@compliance_year	INT	=	'2016'
DECLARE	@assigned_date	VARCHAR(20)	=	'2016-07-14'
DECLARE	@curve_id	INT	=	NULL
DECLARE	@table_name	VARCHAR(100)	=	NULL
DECLARE	@convert_uom_id	INT	=	'1159'
DECLARE	@gen_state	INT	=	NULL
DECLARE	@gen_year	INT	=	NULL
DECLARE	@gen_date_from	DATETIME	=	NULL
DECLARE	@gen_date_to	DATETIME	=	NULL
DECLARE	@generator_id	INT	=	NULL
DECLARE	@counterparty_id	INT	=	NULL
DECLARE	@deal_id	VARCHAR(500)	=	NULL
DECLARE	@udf_group1	INT	=	NULL
DECLARE	@udf_group2	INT	=	NULL
DECLARE	@udf_group3	INT	=	NULL
DECLARE	@tier_type	INT	=	NULL
DECLARE	@program_scope	INT	=	NULL
DECLARE	@assignment_group	INT	=	NULL
DECLARE	@cert_from	INT	=	NULL
DECLARE	@cert_to	INT	=	NULL
DECLARE	@unassign	INT	=	'0'
DECLARE	@volume	NUMERIC	=	NULL
DECLARE	@fifo_lifo	VARCHAR(1)	=	'f'
DECLARE	@debug	BIT		
DECLARE	@export	CHAR(1)		
DECLARE	@batch_process_id	VARCHAR(50)		
DECLARE	@batch_report_param	VARCHAR(1000)		
DECLARE	@enable_paging	INT		
DECLARE	@page_size	INT		
DECLARE	@page_no	INT		
IF OBJECT_ID(N'tempdb..#bonus', N'U') IS NOT NULL	DROP TABLE	#bonus			
IF OBJECT_ID(N'tempdb..#conversion', N'U') IS NOT NULL	DROP TABLE	#conversion			
IF OBJECT_ID(N'tempdb..#final_deal_volume_cutoff', N'U') IS NOT NULL	DROP TABLE	#final_deal_volume_cutoff			
IF OBJECT_ID(N'tempdb..#final_deals', N'U') IS NOT NULL	DROP TABLE	#final_deals			
IF OBJECT_ID(N'tempdb..#first_temp_deals_for_unassignment', N'U') IS NOT NULL	DROP TABLE	#first_temp_deals_for_unassignment			
IF OBJECT_ID(N'tempdb..#margin_for_volume', N'U') IS NOT NULL	DROP TABLE	#margin_for_volume			
IF OBJECT_ID(N'tempdb..#ssbm', N'U') IS NOT NULL	DROP TABLE	#ssbm			
IF OBJECT_ID(N'tempdb..#target_deal_volume', N'U') IS NOT NULL	DROP TABLE	#target_deal_volume			
IF OBJECT_ID(N'tempdb..#target_profile', N'U') IS NOT NULL	DROP TABLE	#target_profile			
IF OBJECT_ID(N'tempdb..#target_profile2', N'U') IS NOT NULL	DROP TABLE	#target_profile2			
IF OBJECT_ID(N'tempdb..#temp', N'U') IS NOT NULL	DROP TABLE	#temp			
IF OBJECT_ID(N'tempdb..#temp_1', N'U') IS NOT NULL	DROP TABLE	#temp_1			
IF OBJECT_ID(N'tempdb..#temp_assign', N'U') IS NOT NULL	DROP TABLE	#temp_assign			
IF OBJECT_ID(N'tempdb..#temp_assign_1', N'U') IS NOT NULL	DROP TABLE	#temp_assign_1			
IF OBJECT_ID(N'tempdb..#temp_assign_2', N'U') IS NOT NULL	DROP TABLE	#temp_assign_2			
IF OBJECT_ID(N'tempdb..#temp_assign_3', N'U') IS NOT NULL	DROP TABLE	#temp_assign_3			
IF OBJECT_ID(N'tempdb..#temp_assign2', N'U') IS NOT NULL	DROP TABLE	#temp_assign2			
IF OBJECT_ID(N'tempdb..#temp_cert', N'U') IS NOT NULL	DROP TABLE	#temp_cert			
IF OBJECT_ID(N'tempdb..#temp_cert_1', N'U') IS NOT NULL	DROP TABLE	#temp_cert_1			
IF OBJECT_ID(N'tempdb..#temp_cert_2', N'U') IS NOT NULL	DROP TABLE	#temp_cert_2			
IF OBJECT_ID(N'tempdb..#temp_cert_3', N'U') IS NOT NULL	DROP TABLE	#temp_cert_3			
IF OBJECT_ID(N'tempdb..#temp_cert2', N'U') IS NOT NULL	DROP TABLE	#temp_cert2			
IF OBJECT_ID(N'tempdb..#temp_const_tier_target', N'U') IS NOT NULL	DROP TABLE	#temp_const_tier_target			
IF OBJECT_ID(N'tempdb..#temp_const_tier_type', N'U') IS NOT NULL	DROP TABLE	#temp_const_tier_type			
IF OBJECT_ID(N'tempdb..#temp_deals', N'U') IS NOT NULL	DROP TABLE	#temp_deals			
IF OBJECT_ID(N'tempdb..#temp_deals_after_adjustments', N'U') IS NOT NULL	DROP TABLE	#temp_deals_after_adjustments			
IF OBJECT_ID(N'tempdb..#temp_deals_collect', N'U') IS NOT NULL	DROP TABLE	#temp_deals_collect			
IF OBJECT_ID(N'tempdb..#temp_deals_collect2', N'U') IS NOT NULL	DROP TABLE	#temp_deals_collect2			
IF OBJECT_ID(N'tempdb..#temp_deals_cutoff', N'U') IS NOT NULL	DROP TABLE	#temp_deals_cutoff			
IF OBJECT_ID(N'tempdb..#temp_deals_cutoff2', N'U') IS NOT NULL	DROP TABLE	#temp_deals_cutoff2			
IF OBJECT_ID(N'tempdb..#temp_deals_for_unassignment', N'U') IS NOT NULL	DROP TABLE	#temp_deals_for_unassignment			
IF OBJECT_ID(N'tempdb..#temp_filtered_recs', N'U') IS NOT NULL	DROP TABLE	#temp_filtered_recs			
IF OBJECT_ID(N'tempdb..#temp_filtered_recs_with_tier', N'U') IS NOT NULL	DROP TABLE	#temp_filtered_recs_with_tier			
IF OBJECT_ID(N'tempdb..#temp_final', N'U') IS NOT NULL	DROP TABLE	#temp_final			
IF OBJECT_ID(N'tempdb..#temp_final_1', N'U') IS NOT NULL	DROP TABLE	#temp_final_1			
IF OBJECT_ID(N'tempdb..#temp_final_2', N'U') IS NOT NULL	DROP TABLE	#temp_final_2			
IF OBJECT_ID(N'tempdb..#temp_final_3', N'U') IS NOT NULL	DROP TABLE	#temp_final_3			
IF OBJECT_ID(N'tempdb..#temp_final_4', N'U') IS NOT NULL	DROP TABLE	#temp_final_4			
IF OBJECT_ID(N'tempdb..#temp_final_5', N'U') IS NOT NULL	DROP TABLE	#temp_final_5			
IF OBJECT_ID(N'tempdb..#temp_final_6', N'U') IS NOT NULL	DROP TABLE	#temp_final_6			
IF OBJECT_ID(N'tempdb..#temp_final1', N'U') IS NOT NULL	DROP TABLE	#temp_final1			
IF OBJECT_ID(N'tempdb..#temp_final2', N'U') IS NOT NULL	DROP TABLE	#temp_final2			
IF OBJECT_ID(N'tempdb..#temp_final3', N'U') IS NOT NULL	DROP TABLE	#temp_final3			
IF OBJECT_ID(N'tempdb..#temp_final4', N'U') IS NOT NULL	DROP TABLE	#temp_final4			
IF OBJECT_ID(N'tempdb..#temp_finalized_deals', N'U') IS NOT NULL	DROP TABLE	#temp_finalized_deals			
IF OBJECT_ID(N'tempdb..#temp_finalized_deals2', N'U') IS NOT NULL	DROP TABLE	#temp_finalized_deals2			
IF OBJECT_ID(N'tempdb..#temp_finalized_deals3', N'U') IS NOT NULL	DROP TABLE	#temp_finalized_deals3			
IF OBJECT_ID(N'tempdb..#temp_include', N'U') IS NOT NULL	DROP TABLE	#temp_include			
IF OBJECT_ID(N'tempdb..#temp_include_1', N'U') IS NOT NULL	DROP TABLE	#temp_include_1			
IF OBJECT_ID(N'tempdb..#temp_include2', N'U') IS NOT NULL	DROP TABLE	#temp_include2			
IF OBJECT_ID(N'tempdb..#temp_sorted_deals_by_tier', N'U') IS NOT NULL	DROP TABLE	#temp_sorted_deals_by_tier			
IF OBJECT_ID(N'tempdb..#temp_sorted_violated_deals', N'U') IS NOT NULL	DROP TABLE	#temp_sorted_violated_deals			
IF OBJECT_ID(N'tempdb..#temp_table', N'U') IS NOT NULL	DROP TABLE	#temp_table			
IF OBJECT_ID(N'tempdb..#temp_tier_type', N'U') IS NOT NULL	DROP TABLE	#temp_tier_type			
IF OBJECT_ID(N'tempdb..#temp2', N'U') IS NOT NULL	DROP TABLE	#temp2			


select @flag='o',@fas_sub_id='1471',@fas_strategy_id='1472',@fas_book_id='1473,1474',@assignment_type='5173',@assigned_state='310388',@compliance_year='2016',@assigned_date='2016-07-20',@curve_id=NULL,@table_name=NULL,@convert_uom_id='1186',@gen_state=NULL,@gen_year=NULL,@gen_date_from=NULL,@gen_date_to=NULL,@generator_id=NULL,@counterparty_id=NULL,@deal_id=NULL,@udf_group1=NULL,@udf_group2=NULL,@udf_group3=NULL,@tier_type=NULL,@program_scope=NULL,@assignment_group=NULL,@cert_from=NULL,@cert_to=NULL,@unassign='0',@volume=NULL,@fifo_lifo='f'
--**************************TEST CODE END************************/								
SET NOCOUNT ON    
IF OBJECT_ID('tempdb..#temp_deals') IS NOT NULL DROP TABLE #temp_deals  
IF OBJECT_ID('tempdb..#ssbm') IS NOT NULL DROP TABLE #ssbm  
IF OBJECT_ID('tempdb..#bonus') IS NOT NULL DROP TABLE #bonus  
IF OBJECT_ID('tempdb..#conversion') IS NOT NULL DROP TABLE #conversion  
IF OBJECT_ID('tempdb..#temp_finalized_deals') IS NOT NULL DROP TABLE #temp_finalized_deals  
IF OBJECT_ID('tempdb..#target_profile') IS NOT NULL DROP TABLE #target_profile    
IF OBJECT_ID('tempdb..#final_deals') IS NOT NULL DROP TABLE #final_deals    
    
  
-------------------------------------------    
 DECLARE @to_uom_id INT  
 DECLARE @sql_stmt VARCHAR(MAX)    
 DECLARE @sql_stmt2 VARCHAR(MAX)   
 DECLARE @sql_stmt3 VARCHAR(MAX)   
 DECLARE @Sql_Select VARCHAR(MAX)
 DECLARE @sql VARCHAR(MAX) 
 DECLARE @Sql_Where VARCHAR(MAX)    
 DECLARE @convert_uom_id_s VARCHAR(50)    
 DECLARE @log_increment INT  
 DECLARE @pr_name VARCHAR(5000)  
 DECLARE @log_time DATETIME
 DECLARE @vol_rounding TINYINT = 5
   
 SET @to_uom_id=@convert_uom_id    
 SET @convert_uom_id_s = CAST(@convert_uom_id AS VARCHAR)    
    
 SET @Sql_Where=''     
 SET @sql_where=''     
   
 --IF @debug = 1  
 --BEGIN  
	--SET @log_increment = 1  
	--PRINT '******************************************************************************************'  
	--PRINT '********************START [Assignment Process]*******************'  
 --END  
    
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

----TODO: Use new paging logic
--IF @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL
--	SET @is_batch = 1
--ELSE
--	SET @is_batch = 0
	
--IF (@is_batch = 1 OR @enable_paging = 1)
--begin
--	IF (@batch_process_id IS NULL)
--		SET @batch_process_id = dbo.FNAGetNewID()
		
--	SET @user_login_id = dbo.FNADBUser()	
--	SET @temptablename = dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)
--	PRINT('@temptablename' + @temptablename)
--	SET @str_batch_table=', ROWID=IDENTITY(int,1,1) INTO ' + @temptablename
----	SET @str_get_row_number=', ROWID=IDENTITY(int,1,1)'
--	IF @enable_paging = 1
--	BEGIN

--		IF @page_size IS not NULL
--		begin
--			declare @row_to int,@row_from int
--			set @row_to=@page_no * @page_size
--			if @page_no > 1 
--				set @row_from =((@page_no-1) * @page_size)+1
--			else
--				set @row_from =@page_no
--			set @sql_stmt=''
--			--	select @temptablename
--			--select * from adiha_process.sys.columns where [object_id]=object_id(@temptablename) and [name]<>'ROWID' ORDER BY column_id

--			select @sql_stmt=@sql_stmt+',['+[name]+']' from adiha_process.sys.columns where [object_id]=object_id(@temptablename) and [name]<>'ROWID' ORDER BY column_id
--			SET @sql_stmt=SUBSTRING(@sql_stmt,2,LEN(@sql_stmt))
			
--			set @sql_stmt='select '+@sql_stmt +'
--				  from '+ @temptablename   +' 
--				  where rowid between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) 
				 
--			print(@sql_stmt)		
--			exec(@sql_stmt)
--			return
--		END --else @page_size IS not NULL
--	END --enable_paging = 1
		
--end  
    
--******************************************************    
--CREATE source book map table and build index    
--*********************************************************    
 CREATE TABLE #ssbm(    
	source_system_book_id1 INT,              
	source_system_book_id2 INT,              
	source_system_book_id3 INT,              
	source_system_book_id4 INT,              
	fas_deal_type_value_id INT,              
	book_deal_type_map_id INT,              
	fas_book_id INT,              
	stra_book_id INT,              
	sub_entity_id INT              
 )    
  SET @Sql_Select=    
  'INSERT INTO #ssbm              
   SELECT              
    source_system_book_id1,source_system_book_id2,source_system_book_id3,  
    source_system_book_id4,fas_deal_type_value_id,              
    book_deal_type_map_id,book.entity_id fas_book_id,book.parent_entity_id stra_book_id,  
    stra.parent_entity_id sub_entity_id               
  FROM              
   source_system_book_map ssbm               
   INNER JOIN portfolio_hierarchy book (nolock) ON ssbm.fas_book_id = book.entity_id               
   INNER JOIN Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id               
  WHERE 1=1 '              
  
  IF @fas_sub_id IS NOT NULL              
    SET @Sql_Where = @Sql_Where + ' AND stra.parent_entity_id IN  ( ' + @fas_sub_id + ') '               
  IF @fas_strategy_id IS NOT NULL              
    SET @Sql_Where = @Sql_Where + ' AND (stra.entity_id IN(' + @fas_strategy_id + ' ))'              
  IF @fas_book_id IS NOT NULL              
    SET @Sql_Where = @Sql_Where + ' AND (book.entity_id IN(' + @fas_book_id + ')) '              
  SET @Sql_Select=@Sql_Select+@Sql_Where   
  
  --PRINT @sql_select             
  EXEC (@Sql_Select)              
  
  
  
  --------------------------------------------------------------    
CREATE INDEX [IX_PH1] ON [#ssbm]([source_system_book_id1])          
CREATE INDEX [IX_PH2] ON [#ssbm]([source_system_book_id2])          
CREATE INDEX [IX_PH3] ON [#ssbm]([source_system_book_id3])          
CREATE INDEX [IX_PH4] ON [#ssbm]([source_system_book_id4])          
CREATE INDEX [IX_PH5] ON [#ssbm]([fas_deal_type_value_id])          
CREATE INDEX [IX_PH6] ON [#ssbm]([fas_book_id])          
CREATE INDEX [IX_PH7] ON [#ssbm]([stra_book_id])          
CREATE INDEX [IX_PH8] ON [#ssbm]([sub_entity_id])          
      
  --******************************************************    
  --End of source book map table and build index    
  --*********************************************************    
  
--******************************************************    
--CREATE bonus table and build index    
--*********************************************************    
--IF @debug = 1  
--BEGIN  
--	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)  
--	SET @log_increment = @log_increment + 1  
--	SET @log_time=GETDATE()  
--	PRINT @pr_name+' Running..............'  
--END  
  
CREATE TABLE #bonus(    
	state_value_id INT,    
	technology INT,    
	assignment_type_value_id INT,    
	from_date DATETIME,    
	to_date DATETIME,    
	gen_state_value_id INT,    
	bonus_per NUMERIC(38, 20)    
)    
    
INSERT INTO #bonus    
	SELECT  
	bS.state_value_id   state_value_id,    
	bS.technology technology,    
	bS.assignment_type_value_id assignment_type_value_id,    
	bS.from_date from_date,    
	bS.to_date to_date,    
	bS.gen_code_value gen_state_value_id,
	--TODO: may be we could change the data type in the table column itself
	CAST(bS.bonus_per AS NUMERIC(38, 20)) bonus_per    
	FROM    
	(  
		SELECT state_value_id, technology, assignment_type_value_id, from_date, to_date, gen_code_value, bonus_per    
		FROM state_properties_bonus WHERE gen_code_value IS NOT NULL    
	) bS    
    
  
CREATE INDEX [IX_bonus1] ON [#bonus]([state_value_id])          
CREATE INDEX [IX_bonus2] ON [#bonus]([technology])          
CREATE INDEX [IX_bonus3] ON [#bonus]([assignment_type_value_id])          
CREATE INDEX [IX_bonus4] ON [#bonus]([from_date])          
CREATE INDEX [IX_bonus5] ON [#bonus]([to_date])          
CREATE INDEX [IX_bonus6] ON [#bonus]([gen_state_value_id])          
  
  
--IF @debug = 1  
--BEGIN  
--	PRINT @pr_name+': '+CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'  
--	PRINT '**************** End of bonus calculation *****************************'   
--END  
  
 --select * from #bonus  
--******************************************************    
--End of bonus table    
--*********************************************************    
  
  
--******************************************************    
-- Collect target Profiles  
--******************************************************    
--IF @debug = 1  
--BEGIN  
--	SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)  
--	SET @log_increment = @log_increment + 1  
--	SET @log_time=GETDATE()  
--	PRINT @pr_name+' Running..............'  
--END  
   
 --set @assigned_state = 293482 
 ----drop table #target_profile 

/*
* --Energy Efficiency logic is implemented differently now.
	
*/
	
--IF @debug = 1  
--BEGIN  
--	PRINT @pr_name+': '+CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'  
--	PRINT '**************** End of Target Profile  *****************************'   
--END  
  DECLARE @gis_deal_id INT, @certificate_f INT, @certificate_t INT, @cert_from_f INT, @cert_to_t INT, @bank_assignment INT  
  DECLARE @volume_left2 FLOAT, @target_volume2 FLOAT, @source_deal_header_id2 INT, @floating_target_volume2 FLOAT


IF OBJECT_ID('tempdb..#temp_1') IS NOT NULL
	DROP TABLE #temp_1

IF OBJECT_ID('tempdb..#temp') IS NOT NULL
	DROP TABLE #temp

IF OBJECT_ID('tempdb..#temp_assign') IS NOT NULL
	DROP TABLE #temp_assign

IF OBJECT_ID('tempdb..#temp_cert') IS NOT NULL
	DROP TABLE #temp_cert

IF OBJECT_ID('tempdb..#temp_final') IS NOT NULL
	DROP TABLE #temp_final
 
IF OBJECT_ID('tempdb..#temp_final1') IS NOT NULL
	DROP TABLE #temp_final1

IF OBJECT_ID('tempdb..#temp_include') IS NOT NULL
	DROP TABLE #temp_include
	
IF OBJECT_ID('tempdb..#temp_assign2') IS NOT NULL
	DROP TABLE #temp_assign2

IF OBJECT_ID('tempdb..#temp_cert2') IS NOT NULL
	DROP TABLE #temp_cert2

IF OBJECT_ID('tempdb..#temp_final3') IS NOT NULL
	DROP TABLE #temp_final3
 
IF OBJECT_ID('tempdb..#temp_final4') IS NOT NULL
	DROP TABLE #temp_final4

IF OBJECT_ID('tempdb..#temp_include2') IS NOT NULL
	DROP TABLE #temp_include2

IF @assignment_type in(5173,5183) AND @flag = 'o'
BEGIN
	
	IF OBJECT_ID('tempdb..#temp_deals_collect') IS NOT NULL DROP TABLE #temp_deals_collect
	CREATE TABLE #temp_deals_collect  
	 (   
		  id INT IDENTITY(1, 1),
		  source_deal_header_id INT,    
		  source_deal_detail_id INT,  
		  deal_date DATETIME,    
		  gen_date DATETIME,    
		  source_curve_def_id INT,  
		  counterparty_id INT,  
		  generator_id INT,  
		  jurisdiction_state_id INT,  
		  gen_state_value_id INT,  
		  price NUMERIC(38, 20),    
		  volume NUMERIC(38, 20),    
		  bonus NUMERIC(38, 20),    
		  expiration VARCHAR(30) COLLATE DATABASE_DEFAULT,    
		  uom_id INT,  
		  volume_left NUMERIC(38, 20),
		  vol_to_be_assigned NUMERIC(38, 20),  
		  ext_deal_id INT,  --TODO: check if it is really needed 
		  conv_factor NUMERIC(38, 20),  
		  expiration_date DATETIME,  
		  assigned_date DATETIME,  
		  status_value_id INT,  
		  term_start DATETIME,
		  technology INT,
		  product INT,
		  compliance_year INT
	 )    
	

	IF @table_name IS NULL OR @table_name = ''    
	SET @table_name = dbo.FNAProcessTableName('recassign_', dbo.FNADBUser(), dbo.FNAGetNewID()) 

	EXEC('CREATE TABLE ' + @table_name + ' (
		  row_unique_id INT,
		  [Deal ID] INT,    
		  [ID] INT,  
		  deal_date DATETIME,    
		  gen_date DATETIME,    
		  source_curve_def_id INT,  
		  counterparty_id INT,  
		  generator_id INT,  
		  jurisdiction_state_id INT,  
		  gen_state_value_id INT,  
		  price NUMERIC(38, 20),    
		  volume NUMERIC(38, 20),    
		  bonus NUMERIC(38, 20),    
		  expiration VARCHAR(30),    
		  uom INT,  
		  volume_left NUMERIC(38, 20),
		  [Volume Assign] NUMERIC(38, 20),  
		  ext_deal_id INT,  --TODO: check if it is really needed 
		  conv_factor NUMERIC(38, 20),  
		  expiration_date DATETIME,  
		  assigned_date DATETIME,  
		  status_value_id INT,  
		  term_start DATETIME,
		  technology INT,
		  product INT,
		  cert_from INT,
		  cert_to INT,
		  compliance_year INT,
		  tier_value_id INT
		  )'
		  )

		  
 
 SET @sql_stmt =     
		'  
		INSERT INTO #temp_deals_collect(
			source_deal_header_id,    
			source_deal_detail_id,  
			deal_date,    
			gen_date,    
			source_curve_def_id,  
			counterparty_id,  
			generator_id,  
			jurisdiction_state_id,  
			gen_state_value_id,  
			price,    
			volume,    
			bonus,    
			uom_id,  
			volume_left,
			vol_to_be_assigned,
			conv_factor,  
			expiration_date,  
			status_value_id,  
			term_start,
			technology,
			product,
			compliance_year
			
		)    
		SELECT 
		sdh.source_deal_header_id,  
		sdd.source_deal_detail_id,    
		sdh.deal_date,     
		sdd.term_start gen_date,    
		sdd.curve_id AS source_curve_def_id,    
		sdh.counterparty_id AS counterparty_id,  
		rg.generator_id AS generator_id,  
		rg.state_value_id,  
		rg.gen_state_value_id,  
		ISNULL(CAST(sdd.fixed_price as NUMERIC(38,20)), 0) AS price,   
		sdd.deal_volume * rs_cf.conversion_factor AS volume,    
		ISNULL(bns.bonus_per, 0)/100 * sdd.volume_left * rs_cf.conversion_factor bonus,    
		su.source_uom_id AS uom_id,   
		ISNULL(bns.bonus_per, 0)/100 * sdd.volume_left * rs_cf.conversion_factor + sdd.volume_left * rs_cf.conversion_factor AS Volume_left,  
		ISNULL(bns.bonus_per, 0)/100 * sdd.volume_left * rs_cf.conversion_factor + sdd.volume_left * rs_cf.conversion_factor AS Vol_to_be_assigned,  
		rs_cf.conversion_factor AS conv_factor,  
		DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,cast((year(sdd.term_start) + 
							CASE WHEN(isnull(rg.gen_offset_technology, ''n'') = ''n'') THEN 
								ISNULL(spd.duration ,isnull(sp.duration, 0)) 
							ELSE ISNULL(spd.offset_duration ,isnull(sp.offset_duration, 0)) END 
							- 1) AS VARCHAR) 
							+ ''-'' + CAST(isnull(sp.calendar_to_month, 12) as varchar) + ''-01'')+1,0)) expiration_date,
		sdh.status_value_id,  
		sdd.term_start,
		rg.technology,
		rg.source_curve_def_id,
		YEAR(sdd.term_start)
		FROM source_deal_header sdh
		INNER JOIN #ssbm ssbm ON sdh.source_system_book_id1 = ssbm.source_system_book_id1
			AND sdh.source_system_book_id2 = ssbm.source_system_book_id2
			AND sdh.source_system_book_id3 = ssbm.source_system_book_id3
			AND sdh.source_system_book_id4 = ssbm.source_system_book_id4
		INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id 
			AND sdd.buy_sell_flag = ''b''  -- select only buy deals  
		INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		--INNER JOIN rec_gen_eligibility rge on rge.gen_state_value_id = rg.gen_state_value_id
		--	AND rge.technology = rg.technology
		INNER JOIN static_data_value sdv_tech ON sdv_tech.value_id = rg.technology
		INNER JOIN state_properties sp ON sp.state_value_id =  rg.state_value_id 
		LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id       
			--AND tfr.program_scope = spcd.program_scope_value_id  
		LEFT JOIN state_properties_duration spd on spd.state_value_id = sp.state_value_id 
			AND spd.technology = rg.technology 	
			AND (ISNULL(spd.assignment_type_Value_id, 5149) = ISNULL(NULL, 5149) OR spd.assignment_type_Value_id IS NULL)
		LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id    
		LEFT JOIN static_data_value state ON state.value_id = rg.state_value_id  
		LEFT JOIN source_uom su ON su.source_uom_id = sdd.deal_volume_uom_id     
		LEFT JOIN #bonus bns ON bns.state_value_id = sp.state_value_id    
			AND bns.technology = rg.technology  
			AND ISNULL(bns.assignment_type_value_id, 5149) =  ' + CAST(@assignment_type AS VARCHAR) + '  
			AND sdd.term_start between bns.from_date and bns.to_date  
			AND bns.gen_state_value_id = rg.gen_state_value_id
		
			  '
			
	SET @sql_stmt2 ='
		 LEFT JOIN rec_volume_unit_conversion Conv1 ON conv1.from_source_uom_id = sdd.deal_volume_uom_id               
			AND conv1.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id AS VARCHAR),'NULL')+'              
			And conv1.state_value_id = state.value_id  
			AND conv1.assignment_type_value_id = ' + CAST(@assignment_type AS VARCHAR) + '    
			AND conv1.curve_id = sdd.curve_id     
			AND conv1.to_curve_id IS NULL        
		LEFT JOIN rec_volume_unit_conversion Conv2 ON conv2.from_source_uom_id = sdd.deal_volume_uom_id   
			AND conv2.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id AS VARCHAR),'NULL')+'              
			And conv2.state_value_id IS NULL  
			AND conv2.assignment_type_value_id = ' + CAST(@assignment_type AS VARCHAR) + '    
			AND conv2.curve_id = sdd.curve_id    
			AND conv2.to_curve_id IS NULL        
		LEFT JOIN rec_volume_unit_conversion Conv3 ON conv3.from_source_uom_id =  sdd.deal_volume_uom_id              
			AND conv3.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id AS VARCHAR),'NULL')+'              
			And conv3.state_value_id IS NULL  
			AND conv3.assignment_type_value_id IS NULL  
			AND conv3.curve_id = sdd.curve_id            
			AND conv3.to_curve_id IS NULL        
		LEFT JOIN rec_volume_unit_conversion Conv4 ON conv4.from_source_uom_id = sdd.deal_volume_uom_id  
			AND conv4.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id AS VARCHAR),'NULL')+'              
			And conv4.state_value_id IS NULL  
			AND conv4.assignment_type_value_id IS NULL  
			AND conv4.curve_id IS NULL  
			AND conv4.to_curve_id IS NULL        
		LEFT JOIN rec_volume_unit_conversion Conv5 ON conv5.from_source_uom_id  = sdd.deal_volume_uom_id                
			AND conv5.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id AS VARCHAR),'NULL')+'              
			And conv5.state_value_id = state.value_id  
			AND conv5.assignment_type_value_id is null  
			AND conv5.curve_id = sdd.curve_id   
			AND conv5.to_curve_id IS NULL
		OUTER APPLY(
		               SELECT CAST(
		                          COALESCE(
		                              conv1.conversion_factor
		                             , conv5.conversion_factor
		                             , conv2.conversion_factor
		                             , conv3.conversion_factor
		                             , conv4.conversion_factor
		                             , 1
		                          ) AS NUMERIC(20, 8)
		                      ) AS conversion_factor
		           ) rs_cf      
		LEFT JOIN gis_certificate gis ON gis.source_deal_header_id = sdd.source_deal_detail_id 
			AND gis.state_value_id = rg.state_value_id
		LEFT JOIN static_data_value sdv_gen_state ON sdv_gen_state.value_id=rg.gen_state_value_id 

	
	

WHERE  1 = 1'

			
	 set @sql_stmt3 ='
	 AND sdd.volume_left > 0  

			AND sdd.volume_left IS NOT NULL -- select deals having volume available
			
			AND YEAR(sdd.term_start) <= ' + CAST(YEAR(@assigned_date) AS VARCHAR(10)) + ' 
			AND sdd.term_start <= CASE WHEN (ISNULL(sp.bank_assignment_required, ''n'') = ''n'') THEN CONVERT(NVARCHAR(10), ''' + @assigned_date + ''', 20) ELSE sdd.term_start END 
				AND CASE WHEN  ' +ISNULL(CAST(@assignment_type AS VARCHAR),5146) + '=5173 THEN 
	 		--replace FNADEALRECExpirationState with equivalent code (for year only) to gain performance
	 		  YEAR(DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, CAST((YEAR(sdd.term_start) + 
								CASE WHEN(ISNULL(rg.gen_offset_technology, ''n'') = ''n'') THEN 
									ISNULL(spd.duration, ISNULL(sp.duration, 0)) 
								ELSE ISNULL(spd.offset_duration, ISNULL(sp.offset_duration, 0)) END 
								- 1) AS VARCHAR) 
								+ ''-'' + CAST(ISNULL(sp.calendar_to_month, 12) AS VARCHAR) + ''-01'') + 1, 0))) 
		  
		 
		 ELSE CASE WHEN gis.source_certificate_number IS NOT NULL AND gis.contract_expiration_date IS NOT NULL 
		 THEN  YEAR(gis.contract_expiration_date)
	 		--replace FNADEALRECExpirationState with equivalent code (for year only) to gain performance   
	 	 ELSE YEAR(DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, CAST((YEAR(sdd.term_start) + 
								CASE WHEN(ISNULL(rg.gen_offset_technology, ''n'') = ''n'') THEN 
									ISNULL(spd.duration, ISNULL(sp.duration, 0)) 
								ELSE ISNULL(spd.offset_duration, ISNULL(sp.offset_duration, 0)) END 
								- 1) AS VARCHAR) 
								+ ''-'' + CAST(isnull(sp.calendar_to_month, 12) AS VARCHAR) + ''-01'') + 1, 0)))  
		 END  END >= ' + CASE WHEN ISNULL(@assignment_type,5146)=5173 THEN  CAST('' + @assigned_date + '' AS VARCHAR)
		 ELSE CAST(@compliance_year AS VARCHAR)  END 

		
		+ CASE WHEN @deal_id IS NOT NULL THEN ' AND sdh.source_deal_header_id = '+@deal_id 
			ELSE  
			+ CASE WHEN (@curve_id IS NULL) THEN '' ELSE ' AND sdd.curve_id = ' + CAST(@curve_id AS VARCHAR) END     
			+ CASE WHEN (@gen_state IS NULL) THEN '' ELSE ' AND rg.gen_state_value_id = ' + CAST(@gen_state AS VARCHAR) END    
			+ CASE WHEN (@gen_year IS NULL) THEN '' ELSE ' AND YEAR(sdd.term_start) = ' + CAST(@gen_year AS VARCHAR) END 
			+ CASE WHEN (@gen_date_from IS NULL) THEN '' ELSE ' AND sdd.term_start ' + (CASE WHEN @gen_date_to IS NOT NULL THEN ' >' ELSE '' END) + '= ''' + CONVERT(VARCHAR(10), @gen_date_from, 120) + '''' END 
			+ CASE WHEN (@gen_date_to IS NULL) THEN '' ELSE ' AND sdd.term_start ' + (CASE WHEN @gen_date_from IS NOT NULL THEN ' <' ELSE '' END) + '= ''' + CONVERT(VARCHAR(10), @gen_date_to, 120) + '''' END
			+ CASE WHEN (@generator_id IS NULL) THEN '' ELSE ' AND rg.generator_id = ' + CAST(@generator_id AS VARCHAR) END    
			+ CASE WHEN (@counterparty_id IS NULL) THEN '' ELSE ' AND sdh.counterparty_id = ' + CAST(@counterparty_id AS VARCHAR) END    
			+ CASE WHEN @program_scope IS NOT NULL THEN ' AND spcd.program_scope_value_id = ' + CAST(@program_scope AS VARCHAR) ELSE '' END  
		  END  
		
	--IF @debug = 1 
	--print '************'
	-- PRINT @sql_Stmt + @sql_stmt2 + @sql_stmt3
	-- print '************'
	
	
	EXEC (@sql_Stmt  + @sql_stmt2 + @sql_stmt3)    
	
	IF OBJECT_ID(N'tempdb..#temp_deals_cutoff', N'U') IS NOT NULL
	DROP TABLE	#temp_deals_cutoff
		
	CREATE TABLE #temp_deals_cutoff(id INT IDENTITY(1,1) , source_deal_header_id INT, volume_left FLOAT)

	DECLARE cur_status CURSOR LOCAL FOR
	select t.source_deal_header_id, t.volume_left from #temp_deals_collect t
	order by t.gen_date
		
	OPEN cur_status;

	FETCH NEXT FROM cur_status INTO @source_deal_header_id2, @volume_left2
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		IF @volume_left2 >  @volume
		BEGIN
			SET @volume_left2 =  @volume
		END

		--select  @volume

		IF @volume =  0
		BEGIN
			BREAK
		END
			
		INSERT INTO #temp_deals_cutoff(source_deal_header_id, volume_left)
		SELECT @source_deal_header_id2, @volume_left2
		
		
		SET  @volume =  @volume - @volume_left2
		
		FETCH NEXT FROM cur_status INTO @source_deal_header_id2, @volume_left2
	END;

	CLOSE cur_status;
	DEALLOCATE cur_status;	

	--select * from #temp_deals_cutoff

	IF OBJECT_ID('tempdb..#temp_assign_2') is not null
	DROP TABLE #temp_assign_2
	
	CREATE TABLE #temp_assign_2 (  
		source_deal_detail_id INT,  
		cert_from INT,  
		cert_to INT,  
		assignment_type INT
	)  
	
	IF OBJECT_ID('tempdb..#temp_cert_2') is not null
	DROP TABLE #temp_cert_2
	
	CREATE TABLE #temp_cert_2 (  
		source_deal_header_id INT,  
		certificate_number_from_int INT,  
		certificate_number_to_int INT  
	)  
	  
	INSERT #temp_cert_2
	SELECT DISTINCT gis.source_deal_header_id, gis.certificate_number_from_int, gis.certificate_number_to_int   
	FROM gis_certificate gis
	INNER JOIN #temp_deals_collect tds ON tds.source_deal_detail_id = gis.source_deal_header_id

	DECLARE cursor1 CURSOR FOR  
	SELECT source_deal_header_id, certificate_number_from_int, certificate_number_to_int 
	FROM #temp_cert_2  
	  
	OPEN cursor1  
	FETCH NEXT FROM cursor1 INTO @gis_deal_id, @certificate_f, @certificate_t  
	   
	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		DECLARE cursor2 CURSOR FOR   
		SELECT cert_from, cert_to 
		FROM assignment_audit 
		WHERE source_deal_header_id_from = @gis_deal_id AND assigned_volume > 0  
		ORDER BY cert_from
		
		OPEN cursor2  
		FETCH NEXT FROM cursor2 INTO @cert_from_f, @cert_to_t  
		WHILE @@FETCH_STATUS = 0  
		BEGIN  
			IF @cert_from_f > @certificate_f   
			BEGIN  
				INSERT #temp_assign_2 (source_deal_detail_id, cert_from, cert_to, assignment_type)  
				VALUES (@gis_deal_id, @certificate_f, @cert_from_f - 1, @bank_assignment)  
			END  

			SET @certificate_f = @cert_to_t + 1  

			FETCH NEXT FROM cursor2 INTO @cert_from_f, @cert_to_t  
		END  
		IF (@certificate_f - 1) < @certificate_t  
		BEGIN  
			INSERT #temp_assign_2 (source_deal_detail_id, cert_from, cert_to, assignment_type) 
			VALUES (@gis_deal_id, @certificate_f, @certificate_t, @bank_assignment)  
		END  
		FETCH NEXT FROM cursor1 INTO @gis_deal_id,@certificate_f,@certificate_t  
		
		CLOSE cursor2  
		DEALLOCATE cursor2   
	 END   
	CLOSE cursor1  
	DEALLOCATE cursor1   
	   
	
	IF OBJECT_ID('tempdb..#temp_final_3') IS NOT NULL
		DROP TABLE #temp_final_3
	  
	CREATE TABLE #temp_final_3 (  
		[ID] INT IDENTITY,  
		source_deal_detail_id INT,  
		cert_From INT,  
		cert_to INT,  
		assignment_type INT,  
		volume NUMERIC(38, 20)   
	)

	INSERT INTO #temp_final_3(source_deal_detail_id, cert_from, cert_to, assignment_type, volume)  
	SELECT source_deal_detail_id, cert_from, cert_to, assignment_type, (cert_to - cert_from + 1) AS volume
	FROM (  
		SELECT source_deal_detail_id, cert_from, cert_to, assignment_type FROM #temp_assign_2  
		UNION ALL  
		SELECT source_deal_header_id_from, cert_from, cert_to, assignment_type FROM assignment_audit  
	) a 
	--ORDER BY a.source_deal_detail_id, a.cert_from  

	IF OBJECT_ID('tempdb..#temp_final_4') IS NOT NULL
		DROP TABLE #temp_final_4
	  
	SELECT [ID], source_deal_detail_id, cert_from, cert_to, assignment_type, a.volume,volume_cumu, vol_to_be_assigned AS volume_left 
	INTO #temp_final_4 
	FROM  
	(  
		SELECT b.[ID], b.source_deal_detail_id, cert_from, cert_to,assignment_type, a.volume
		, (SELECT SUM(volume) 
			 FROM #temp_final_3 
			 WHERE [ID] <= a.[ID] --and assignment_type = @assignment_type  
				AND source_deal_detail_id = a.source_deal_detail_id
			) AS volume_cumu
		, b.vol_to_be_assigned
		FROM #temp_final_3 a
		INNER JOIN #temp_deals_collect b ON a.source_deal_detail_id = b.source_deal_detail_id 
		WHERE 1 = 1 --assignment_type = @assignment_type   
	) a  
	WHERE ROUND((CASE WHEN volume_cumu - vol_to_be_assigned <= 0 THEN volume ELSE    
	 volume - (volume_cumu - vol_to_be_assigned) END), @vol_rounding) > 0 

	 

	SET @sql = 'INSERT  INTO ' + @table_name + '(	
										row_unique_id,
										[Deal ID],    
										[ID],  
										deal_date,    
										gen_date,    
										source_curve_def_id,  
										counterparty_id,  
										generator_id,  
										jurisdiction_state_id,  
										gen_state_value_id,  
										price,    
										volume,    
										bonus,    
										uom,  
										volume_left,
										[Volume Assign],
										conv_factor,  
										expiration_date,  
										status_value_id,  
										term_start,
										technology,
										product,
										cert_from,
										cert_to,
										compliance_year,
										tier_value_id
									)
									 
				SELECT  ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) row_unique_id,
						tdc.source_deal_header_id,    
						tdc.source_deal_detail_id,  
						deal_date,    
						gen_date,    
						tdc.source_curve_def_id,  
						counterparty_id,  
						tdc.generator_id,  
						jurisdiction_state_id,  
						tdc.gen_state_value_id,  
						price,    
						tdc.volume,    
						bonus,    
						uom_id,  
						tdc.volume_left,
						tdcu.volume_left,
						conv_factor,  
						expiration_date,  
						status_value_id,  
						term_start,
						tdc.technology,
						product,
						'+ CASE WHEN @cert_from IS NOT NULL THEN CAST(@cert_from AS VARCHAR) 
						ELSE '  COALESCE(tf.cert_from,assign1.assigned_volume+gis.certificate_number_from_int,gis.certificate_number_from_int) ' END +' as cert_from,'  
						+ CASE WHEN @cert_from IS NOT NULL THEN CAST(@cert_to AS VARCHAR)
						ELSE '  ISNULL(CASE WHEN tf.cert_from is not null and tf.volume_left+round(isnull(tdc.bonus/tdc.conv_factor, 0), 0)<0 then round(tf.volume-tdc.volume_left,0)+tf.cert_from-1 else round(tf.volume-tdc.volume_Left,0)+tf.cert_from-1 end, 
						ISNULL((assign1.assigned_volume-1+tdc.vol_to_be_assigned),tdc.vol_to_be_assigned)+gis.certificate_number_from_int) ' END +' as cert_to
						, compliance_year, rg.tier_type
				FROM #temp_deals_collect tdc
				INNER JOIN #temp_deals_cutoff tdcu ON tdc.source_deal_header_id = tdcu.source_deal_header_id
				LEFT JOIN #temp_final_4 tf ON tf.source_deal_detail_id = tdc.source_deal_detail_id
				LEFT JOIN #temp_cert_2 gis ON gis.source_deal_header_id = tdc.source_deal_detail_id  
				LEFT JOIN        
					(
						SELECT source_deal_header_id_from,sum(assigned_volume) assigned_volume from         
						assignment_audit group by source_deal_header_id_from
					) assign1        
				ON assign1.source_deal_header_id_from=tdc.source_deal_detail_id 		
				LEFT JOIN rec_generator rg ON rg.generator_id = tdc.generator_id
				'

	EXEC(@sql)

	--IF @debug = 1
	--BEGIN
	--	--select * from #bonus
	--	SELECT '#temp_deals_collect'
	--	SELECT * FROM #temp_deals_collect 
	--END

	 --'SELECT ''' + @table_name + ''' [Process Table], [Assign_id], row_unique_id, [ID] [Detail ID]
		--		, dbo.FNAHyperLinkText(10131010, [Deal ID], [Deal ID]) [Deal ID], deal_date [Deal Date], Vintage, Expiration 
		--		, Jurisdiction, Technology, [Gen State], Generator, obligation [Env Product], Counterparty
		--		, dbo.FNARemoveTrailingZero(ROUND(CAST(assigned_volume AS NUMERIC(38, 20)), ' + CAST(@vol_rounding AS VARCHAR(2)) + ')) AS [Assigned Volume]
		--		, dbo.FNARemoveTrailingZero(ROUND(CAST([Volume UNassign] AS NUMERIC(38, 20)), ' + CAST(@vol_rounding AS VARCHAR(2)) + ')) [Unassign Volume]
		--		, dbo.FNARemoveTrailingZero(ROUND(CAST(assigned_volume AS NUMERIC(38, 20)), ' + CAST(@vol_rounding AS VARCHAR(2)) + ')) [Total Volume]
		--		, UOM
		--		' + CASE WHEN @assignment_type <> 5173 THEN '
		--		, tier AS [Unassigned To Tier]
		--		, dbo.FNARemoveTrailingZero(ROUND(fixed_price, ' + CAST(@vol_rounding AS VARCHAR(2)) + ')) [Price]'
		--		ELSE '' END + '
		--		' + @str_batch_table + '
	 --           FROM	            
	 --            ' + @table_name + ' a'   


	 

	SET @sql = 'select  ''' + @table_name + ''' [Process ID],NULL [Assign_id], ROW_NUMBER() OVER (ORDER BY MAX(tdcu.id)) row_unique_id,
			  MAX(source_deal_detail_id) [Detail ID], tdc.source_deal_header_id [Deal ID] ,  dbo.FNADateFormat(MAX(deal_date)) [Deal Date],
			 dbo.FNADateFormat(MAX(gen_date)) [Vintage], dbo.FNADateFormat(MAX(expiration_date)) [Expiration],
			MAX(sdv_state.code) [Jurisdiction], MAX(sdv_tech.code) [Technology], MAX(sdv_gen_state.code) [Gen State],
			MAX(rg.name) [Generator], MAX(spcd.curve_name) [Env Product], MAX(sc.counterparty_name) [Counterparty], 
			MAX(volume) [Volume Left], MAX(tdcu.volume_left) [Volume Assigned], MAX(bonus) Bonus,
			MAX(tdcu.volume_left) [Total Volume], MAX(tdc.uom_id) [UOM], MAX(price) Price, tier_type
			 --dbo.FNADateFormat(MAX(term_start)) [Term Start], 
			 --MAX(spcd_prod.curve_name) Product
			 ' + @str_batch_table + ' from #temp_deals_collect tdc
			 INNER JOIN #temp_deals_cutoff tdcu ON tdc.source_deal_header_id = tdcu.source_deal_header_id
			 INNER JOIN source_price_curve_def spcd On spcd.source_curve_def_id = tdc.source_curve_def_id
			INNER JOIN source_counterparty sc ON sc.source_counterparty_id = tdc.counterparty_id
			INNER JOIN rec_generator rg ON rg.generator_id = tdc.generator_id 
			INNER JOIN static_data_value sdv_state ON sdv_state.value_id = tdc.jurisdiction_state_id
			INNER JOIN static_data_value sdv_gen_state ON sdv_gen_state.value_id = tdc.gen_state_value_id
			INNER JOIN static_data_value sdv_tech ON sdv_tech.value_id = tdc.technology
			 INNER JOIN source_price_curve_def spcd_prod On spcd_prod.source_curve_def_id = tdc.product
			 GROUP BY tdc.source_deal_header_id, tier_type
			order by MAX(tdcu.id)'
	
	--PRINT @sql
	EXEC(@sql)

	/*******************************************2nd Paging Batch START**********************************************/
 
	--update time spent and batch completion message in message board
	IF @is_batch = 1
	BEGIN
	   SELECT @sql_paging = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
	   EXEC(@sql_paging)
	 
	   --TODO: modify sp and report name
	   SELECT @sql_paging = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_find_assignment_rec_deals', 'Run Assignment logic')
	   EXEC(@sql_paging)  
	 
	   RETURN
	END
	 
	--if it is first call from paging, return total no. of rows and process id instead of actual data
	IF @enable_paging = 1 AND @page_no IS NULL
	BEGIN
	   SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
	   EXEC(@sql_paging)
	END

END


ELSE IF @assignment_type = 5180 AND @flag = 'o'
BEGIN
	
	IF OBJECT_ID('tempdb..#temp_deals_collect2') IS NOT NULL DROP TABLE #temp_deals_collect2
	CREATE TABLE #temp_deals_collect2  
	 (   
		  id INT IDENTITY(1, 1),
		  source_deal_header_id INT,    
		  source_deal_detail_id INT,  
		  deal_date DATETIME,    
		  gen_date DATETIME,    
		  source_curve_def_id INT,  
		  counterparty_id INT,  
		  generator_id INT,  
		  jurisdiction_state_id INT,  
		  gen_state_value_id INT,  
		  price NUMERIC(38, 20),    
		  volume NUMERIC(38, 20),    
		  bonus NUMERIC(38, 20),    
		  expiration VARCHAR(30) COLLATE DATABASE_DEFAULT,    
		  uom_id INT,  
		  volume_left NUMERIC(38, 20),
		  vol_to_be_assigned NUMERIC(38, 20),  
		  ext_deal_id INT,  --TODO: check if it is really needed 
		  conv_factor NUMERIC(38, 20),  
		  expiration_date DATETIME,  
		  assigned_date DATETIME,  
		  status_value_id INT,  
		  term_start DATETIME,
		  technology INT,
		  product INT
	 )    
	

	IF @table_name IS NULL OR @table_name = ''    
	SET @table_name = dbo.FNAProcessTableName('recassign_', dbo.FNADBUser(), dbo.FNAGetNewID()) 

	EXEC('CREATE TABLE ' + @table_name + ' (
		  row_unique_id INT,
		  [Deal ID] INT,    
		  [ID] INT,  
		  deal_date DATETIME,    
		  gen_date DATETIME,    
		  source_curve_def_id INT,  
		  counterparty_id INT,  
		  generator_id INT,  
		  jurisdiction_state_id INT,  
		  gen_state_value_id INT,  
		  price NUMERIC(38, 20),    
		  volume NUMERIC(38, 20),    
		  bonus NUMERIC(38, 20),    
		  expiration VARCHAR(30),    
		  uom INT,  
		  volume_left NUMERIC(38, 20),
		  [Volume Assign] NUMERIC(38, 20),  
		  ext_deal_id INT,  --TODO: check if it is really needed 
		  conv_factor NUMERIC(38, 20),  
		  expiration_date DATETIME,  
		  assigned_date DATETIME,  
		  status_value_id INT,  
		  term_start DATETIME,
		  technology INT,
		  product INT,
		  cert_from INT,
		  cert_to INT
		  )'
		  )

 
 SET @sql_stmt =     
		'  
		INSERT INTO #temp_deals_collect2(
			source_deal_header_id,    
			source_deal_detail_id,  
			deal_date,    
			gen_date,    
			source_curve_def_id,  
			counterparty_id,  
			generator_id,  
			jurisdiction_state_id,  
			gen_state_value_id,  
			price,    
			volume,    
			bonus,    
			uom_id,  
			volume_left,
			vol_to_be_assigned,
			conv_factor,  
			expiration_date,  
			status_value_id,  
			term_start,
			technology,
			product
			
		)    
		SELECT 
		sdh.source_deal_header_id,  
		sdd.source_deal_detail_id,    
		sdh.deal_date,     
		sdd.term_start gen_date,    
		sdd.curve_id AS source_curve_def_id,    
		sdh.counterparty_id AS counterparty_id,  
		rg.generator_id AS generator_id,  
		rg.state_value_id,  
		rg.gen_state_value_id,  
		ISNULL(CAST(sdd.fixed_price as NUMERIC(38,20)), 0) AS price,   
		sdd.deal_volume * rs_cf.conversion_factor AS volume,    
		ISNULL(bns.bonus_per, 0)/100 * sdd.volume_left * rs_cf.conversion_factor bonus,    
		su.source_uom_id AS uom_id,   
		ISNULL(bns.bonus_per, 0)/100 * sdd.volume_left * rs_cf.conversion_factor + sdd.volume_left * rs_cf.conversion_factor AS Volume_left,  
		ISNULL(bns.bonus_per, 0)/100 * sdd.volume_left * rs_cf.conversion_factor + sdd.volume_left * rs_cf.conversion_factor AS Vol_to_be_assigned,  
		rs_cf.conversion_factor AS conv_factor,  
		DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,cast((year(sdd.term_start) + 
							CASE WHEN(isnull(rg.gen_offset_technology, ''n'') = ''n'') THEN 
								ISNULL(spd.duration ,isnull(sp.duration, 0)) 
							ELSE ISNULL(spd.offset_duration ,isnull(sp.offset_duration, 0)) END 
							- 1) AS VARCHAR) 
							+ ''-'' + CAST(isnull(sp.calendar_to_month, 12) as varchar) + ''-01'')+1,0)) expiration_date,
		sdh.status_value_id,  
		sdd.term_start,
		rg.technology,
		rg.source_curve_def_id
		--select sdh.*
		FROM source_deal_header sdh
		INNER JOIN #ssbm ssbm ON sdh.source_system_book_id1 = ssbm.source_system_book_id1
			AND sdh.source_system_book_id2 = ssbm.source_system_book_id2
			AND sdh.source_system_book_id3 = ssbm.source_system_book_id3
			AND sdh.source_system_book_id4 = ssbm.source_system_book_id4
		INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id 
			AND sdd.buy_sell_flag = ''b''  -- select only buy deals  
		INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		--INNER JOIN rec_gen_eligibility rge on rge.gen_state_value_id = rg.gen_state_value_id
		--	AND rge.technology = rg.technology
		INNER JOIN static_data_value sdv_tech ON sdv_tech.value_id = rg.technology
		INNER JOIN state_properties sp ON sp.state_value_id =  rg.state_value_id 
		INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id       
			--AND tfr.program_scope = spcd.program_scope_value_id  
		LEFT JOIN state_properties_duration spd on spd.state_value_id = sp.state_value_id 
			AND spd.technology = rg.technology 	
			AND (ISNULL(spd.assignment_type_Value_id, 5149) = ISNULL(NULL, 5149) OR spd.assignment_type_Value_id IS NULL)
		LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id    
		LEFT JOIN static_data_value state ON state.value_id = rg.state_value_id  
		LEFT JOIN source_uom su ON su.source_uom_id = sdd.deal_volume_uom_id     
		LEFT JOIN #bonus bns ON bns.state_value_id = sp.state_value_id    
			AND bns.technology = rg.technology  
			AND ISNULL(bns.assignment_type_value_id, 5149) =  ' + CAST(@assignment_type AS VARCHAR) + '  
			AND sdd.term_start between bns.from_date and bns.to_date  
			AND bns.gen_state_value_id = rg.gen_state_value_id
		
			  '
			
	SET @sql_stmt2 ='
		 LEFT JOIN rec_volume_unit_conversion Conv1 ON conv1.from_source_uom_id = sdd.deal_volume_uom_id               
			AND conv1.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id AS VARCHAR),'NULL')+'              
			And conv1.state_value_id = state.value_id  
			AND conv1.assignment_type_value_id = ' + CAST(@assignment_type AS VARCHAR) + '    
			AND conv1.curve_id = sdd.curve_id     
			AND conv1.to_curve_id IS NULL        
		LEFT JOIN rec_volume_unit_conversion Conv2 ON conv2.from_source_uom_id = sdd.deal_volume_uom_id   
			AND conv2.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id AS VARCHAR),'NULL')+'              
			And conv2.state_value_id IS NULL  
			AND conv2.assignment_type_value_id = ' + CAST(@assignment_type AS VARCHAR) + '    
			AND conv2.curve_id = sdd.curve_id    
			AND conv2.to_curve_id IS NULL        
		LEFT JOIN rec_volume_unit_conversion Conv3 ON conv3.from_source_uom_id =  sdd.deal_volume_uom_id              
			AND conv3.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id AS VARCHAR),'NULL')+'              
			And conv3.state_value_id IS NULL  
			AND conv3.assignment_type_value_id IS NULL  
			AND conv3.curve_id = sdd.curve_id            
			AND conv3.to_curve_id IS NULL        
		LEFT JOIN rec_volume_unit_conversion Conv4 ON conv4.from_source_uom_id = sdd.deal_volume_uom_id  
			AND conv4.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id AS VARCHAR),'NULL')+'              
			And conv4.state_value_id IS NULL  
			AND conv4.assignment_type_value_id IS NULL  
			AND conv4.curve_id IS NULL  
			AND conv4.to_curve_id IS NULL        
		LEFT JOIN rec_volume_unit_conversion Conv5 ON conv5.from_source_uom_id  = sdd.deal_volume_uom_id                
			AND conv5.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id AS VARCHAR),'NULL')+'              
			And conv5.state_value_id = state.value_id  
			AND conv5.assignment_type_value_id is null  
			AND conv5.curve_id = sdd.curve_id   
			AND conv5.to_curve_id IS NULL
		OUTER APPLY(
		               SELECT CAST(
		                          COALESCE(
		                              conv1.conversion_factor
		                             , conv5.conversion_factor
		                             , conv2.conversion_factor
		                             , conv3.conversion_factor
		                             , conv4.conversion_factor
		                             , 1
		                          ) AS NUMERIC(20, 8)
		                      ) AS conversion_factor
		           ) rs_cf      
		LEFT JOIN gis_certificate gis ON gis.source_deal_header_id = sdd.source_deal_detail_id 
			AND gis.state_value_id = rg.state_value_id
		LEFT JOIN static_data_value sdv_gen_state ON sdv_gen_state.value_id=rg.gen_state_value_id 
		
WHERE  1 = 1
AND sdd.volume_left > 0  

			AND sdd.volume_left IS NOT NULL -- select deals having volume available
			AND YEAR(sdd.term_start) <= ' + CAST(YEAR(@assigned_date) AS VARCHAR(10)) + ' 
			AND sdd.term_start <= CASE WHEN (ISNULL(sp.bank_assignment_required, ''n'') = ''n'') THEN CONVERT(NVARCHAR(10), ''' + @assigned_date + ''', 20) ELSE sdd.term_start END 
				AND CASE WHEN  ' +ISNULL(CAST(@assignment_type AS VARCHAR),5146) + '=5173 THEN 
	 		--replace FNADEALRECExpirationState with equivalent code (for year only) to gain performance
	 		  YEAR(DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, CAST((YEAR(sdd.term_start) + 
								CASE WHEN(ISNULL(rg.gen_offset_technology, ''n'') = ''n'') THEN 
									ISNULL(spd.duration, ISNULL(sp.duration, 0)) 
								ELSE ISNULL(spd.offset_duration, ISNULL(sp.offset_duration, 0)) END 
								- 1) AS VARCHAR) 
								+ ''-'' + CAST(ISNULL(sp.calendar_to_month, 12) AS VARCHAR) + ''-01'') + 1, 0))) 
		  
		 
		 ELSE CASE WHEN gis.source_certificate_number IS NOT NULL AND gis.contract_expiration_date IS NOT NULL 
		 THEN  YEAR(gis.contract_expiration_date)
	 		--replace FNADEALRECExpirationState with equivalent code (for year only) to gain performance   
	 	 ELSE YEAR(DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, CAST((YEAR(sdd.term_start) + 
								CASE WHEN(ISNULL(rg.gen_offset_technology, ''n'') = ''n'') THEN 
									ISNULL(spd.duration, ISNULL(sp.duration, 0)) 
								ELSE ISNULL(spd.offset_duration, ISNULL(sp.offset_duration, 0)) END 
								- 1) AS VARCHAR) 
								+ ''-'' + CAST(isnull(sp.calendar_to_month, 12) AS VARCHAR) + ''-01'') + 1, 0)))  
		 END  END >= ' + CASE WHEN ISNULL(@assignment_type,5146)=5180 THEN  CAST('' + @assigned_date + '' AS VARCHAR)
		 ELSE CAST(@compliance_year AS VARCHAR)  END 
			
			  
		
		 + CASE WHEN @deal_id IS NOT NULL THEN ' AND sdh.source_deal_header_id = '+@deal_id 
			ELSE  
			+ CASE WHEN (@curve_id IS NULL) THEN '' ELSE ' AND sdd.curve_id = ' + CAST(@curve_id AS VARCHAR) END     
			+ CASE WHEN (@gen_state IS NULL) THEN '' ELSE ' AND rg.gen_state_value_id = ' + CAST(@gen_state AS VARCHAR) END    
			+ CASE WHEN (@gen_year IS NULL) THEN '' ELSE ' AND YEAR(sdd.term_start) = ' + CAST(@gen_year AS VARCHAR) END 
			+ CASE WHEN (@gen_date_from IS NULL) THEN '' ELSE ' AND sdd.term_start ' + (CASE WHEN @gen_date_to IS NOT NULL THEN ' >' ELSE '' END) + '= ''' + CONVERT(VARCHAR(10), @gen_date_from, 120) + '''' END 
			+ CASE WHEN (@gen_date_to IS NULL) THEN '' ELSE ' AND sdd.term_start ' + (CASE WHEN @gen_date_from IS NOT NULL THEN ' <' ELSE '' END) + '= ''' + CONVERT(VARCHAR(10), @gen_date_to, 120) + '''' END
			+ CASE WHEN (@generator_id IS NULL) THEN '' ELSE ' AND rg.generator_id = ' + CAST(@generator_id AS VARCHAR) END    
			+ CASE WHEN (@counterparty_id IS NULL) THEN '' ELSE ' AND sdh.counterparty_id = ' + CAST(@counterparty_id AS VARCHAR) END    
			--+ CASE WHEN @udf_group1 IS NOT NULL THEN ' AND tfr.udf_group1='+CAST(@udf_group1 AS VARCHAR) ELSE '' END  
			--+ CASE WHEN @udf_group2 IS NOT NULL THEN ' AND tfr.udf_group2='+CAST(@udf_group2 AS VARCHAR) ELSE '' END  
			--+ CASE WHEN @udf_group3 IS NOT NULL THEN ' AND tfr.udf_group3='+CAST(@udf_group3 AS VARCHAR) ELSE '' END  
			----+ CASE WHEN @tier_type IS NOT NULL THEN ' AND tfr.tier_type='+CAST(@tier_type AS VARCHAR) ELSE '' END  
			+ CASE WHEN @program_scope IS NOT NULL THEN ' AND spcd.program_scope_value_id = ' + CAST(@program_scope AS VARCHAR) ELSE '' END  
		  END  
		  --+ ' having sum(sdd.volume_left) <=' + @volume
		  
		  	 --+ CASE WHEN  ISNULL(@assignment_type,5146)=5173 THEN 
	 	--	--replace FNADEALRECExpirationState with equivalent code (for year only) to gain performance
	 	--	' AND DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, CAST((YEAR(sdd.term_start) + 
			--					CASE WHEN(ISNULL(tfr.gen_offset_technology, ''n'') = ''n'') THEN 
			--						ISNULL(spd.duration, ISNULL(sp.duration, 0)) 
			--					ELSE ISNULL(spd.offset_duration, ISNULL(sp.offset_duration, 0)) END 
			--					- 1) AS VARCHAR) 
			--					+ ''-'' + CAST(ISNULL(sp.calendar_to_month, 12) AS VARCHAR) + ''-01'') + 1, 0)) >= CAST(''' + @assigned_date + ''' AS DATETIME)'  
		  --' AND dbo.FNADEALRECExpirationState(sdd.source_deal_detail_id, sdd.contract_expiration_date, ' + CAST(@assignment_type AS VARCHAR) + ', tfr.state_value_id) >= CAST(''' + @assigned_date + ''' AS DATETIME) '  
	   --PRINT @sql_Stmt + @sql_stmt2
	IF @debug = 1  PRINT @sql_Stmt + @sql_stmt2

	 --PRINT isnull(@sql_Stmt,'chk1')

	 --print isnull(@sql_stmt2,'chk2')

	EXEC (@sql_Stmt  + @sql_stmt2)    
	--return
	
	--DECLARE @volume_left2 FLOAT, @target_volume2 FLOAT, @source_deal_header_id2 INT, @floating_target_volume2 FLOAT

	IF OBJECT_ID(N'tempdb..#temp_deals_cutoff2', N'U') IS NOT NULL
	DROP TABLE	#temp_deals_cutoff2
		
	CREATE TABLE #temp_deals_cutoff2(id INT IDENTITY(1,1) , source_deal_header_id INT, volume_left FLOAT)

	--return
	DECLARE cur_status CURSOR LOCAL FOR
	select t.source_deal_header_id, t.volume_left from #temp_deals_collect2 t
	order by t.gen_date
		
	OPEN cur_status;

	FETCH NEXT FROM cur_status INTO @source_deal_header_id2, @volume_left2
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		IF @volume_left2 >  @volume
		BEGIN
			SET @volume_left2 =  @volume
		END

		--select  @volume

		IF @volume =  0
		BEGIN
			BREAK
		END
			
		INSERT INTO #temp_deals_cutoff2(source_deal_header_id, volume_left)
		SELECT @source_deal_header_id2, @volume_left2
		
		
		SET  @volume =  @volume - @volume_left2
		
		FETCH NEXT FROM cur_status INTO @source_deal_header_id2, @volume_left2
	END;

	CLOSE cur_status;
	DEALLOCATE cur_status;	

	--select * from #temp_deals_cutoff

	IF OBJECT_ID('tempdb..#temp_assign_3') is not null
	DROP TABLE #temp_assign_3
	
	CREATE TABLE #temp_assign_3 (  
		source_deal_detail_id INT,  
		cert_from INT,  
		cert_to INT,  
		assignment_type INT
	)  
	
	IF OBJECT_ID('tempdb..#temp_cert_3') is not null
	DROP TABLE #temp_cert_3
	
	CREATE TABLE #temp_cert_3 (  
		source_deal_header_id INT,  
		certificate_number_from_int INT,  
		certificate_number_to_int INT  
	)  
	  
	INSERT #temp_cert_3
	SELECT gis.source_deal_header_id, gis.certificate_number_from_int, gis.certificate_number_to_int   
	FROM gis_certificate gis
	INNER JOIN #temp_deals_collect2 tds ON tds.source_deal_detail_id = gis.source_deal_header_id

	DECLARE cursor1 CURSOR FOR  
	SELECT source_deal_header_id, certificate_number_from_int, certificate_number_to_int 
	FROM #temp_cert_3  
	  
	OPEN cursor1  
	FETCH NEXT FROM cursor1 INTO @gis_deal_id, @certificate_f, @certificate_t  
	   
	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		DECLARE cursor2 CURSOR FOR   
		SELECT cert_from, cert_to 
		FROM assignment_audit 
		WHERE source_deal_header_id_from = @gis_deal_id AND assigned_volume > 0  
		ORDER BY cert_from
		
		OPEN cursor2  
		FETCH NEXT FROM cursor2 INTO @cert_from_f, @cert_to_t  
		WHILE @@FETCH_STATUS = 0  
		BEGIN  
			IF @cert_from_f > @certificate_f   
			BEGIN  
				INSERT #temp_assign_3 (source_deal_detail_id, cert_from, cert_to, assignment_type)  
				VALUES (@gis_deal_id, @certificate_f, @cert_from_f - 1, @bank_assignment)  
			END  

			SET @certificate_f = @cert_to_t + 1  

			FETCH NEXT FROM cursor2 INTO @cert_from_f, @cert_to_t  
		END  
		IF (@certificate_f - 1) < @certificate_t  
		BEGIN  
			INSERT #temp_assign_3 (source_deal_detail_id, cert_from, cert_to, assignment_type) 
			VALUES (@gis_deal_id, @certificate_f, @certificate_t, @bank_assignment)  
		END  
		FETCH NEXT FROM cursor1 INTO @gis_deal_id,@certificate_f,@certificate_t  
		
		CLOSE cursor2  
		DEALLOCATE cursor2   
	 END   
	CLOSE cursor1  
	DEALLOCATE cursor1   
	   
	
	IF OBJECT_ID('tempdb..#temp_final_5') IS NOT NULL
		DROP TABLE #temp_final_5
	  
	CREATE TABLE #temp_final_5 (  
		[ID] INT IDENTITY,  
		source_deal_detail_id INT,  
		cert_From INT,  
		cert_to INT,  
		assignment_type INT,  
		volume NUMERIC(38, 20)   
	)

	INSERT INTO #temp_final_5(source_deal_detail_id, cert_from, cert_to, assignment_type, volume)  
	SELECT source_deal_detail_id, cert_from, cert_to, assignment_type, (cert_to - cert_from + 1) AS volume
	FROM (  
		SELECT source_deal_detail_id, cert_from, cert_to, assignment_type FROM #temp_assign_3  
		UNION ALL  
		SELECT source_deal_header_id_from, cert_from, cert_to, assignment_type FROM assignment_audit  
	) a 
	--ORDER BY a.source_deal_detail_id, a.cert_from  

	IF OBJECT_ID('tempdb..#temp_final_6') IS NOT NULL
		DROP TABLE #temp_final_6
	  
	SELECT [ID], source_deal_detail_id, cert_from, cert_to, assignment_type, a.volume,volume_cumu, vol_to_be_assigned AS volume_left 
	INTO #temp_final_6 
	FROM  
	(  
		SELECT b.[ID], b.source_deal_detail_id, cert_from, cert_to,assignment_type, a.volume
		, (SELECT SUM(volume) 
			 FROM #temp_final_5 
			 WHERE [ID] <= a.[ID] --and assignment_type = @assignment_type  
				AND source_deal_detail_id = a.source_deal_detail_id
			) AS volume_cumu
		, b.vol_to_be_assigned
		FROM #temp_final_5 a
		INNER JOIN #temp_deals_collect2 b ON a.source_deal_detail_id = b.source_deal_detail_id 
		WHERE 1 = 1 --assignment_type = @assignment_type   
	) a  
	WHERE ROUND((CASE WHEN volume_cumu - vol_to_be_assigned <= 0 THEN volume ELSE    
	 volume - (volume_cumu - vol_to_be_assigned) END), @vol_rounding) > 0 

	SET @sql = 'INSERT  INTO ' + @table_name + '(	
										row_unique_id,
										[Deal ID],    
										[ID],  
										deal_date,    
										gen_date,    
										source_curve_def_id,  
										counterparty_id,  
										generator_id,  
										jurisdiction_state_id,  
										gen_state_value_id,  
										price,    
										volume,    
										bonus,    
										uom,  
										volume_left,
										[Volume Assign],
										conv_factor,  
										expiration_date,  
										status_value_id,  
										term_start,
										technology,
										product,
										cert_from,
										cert_to
									)
									 
				SELECT  ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) row_unique_id,
						tdc.source_deal_header_id,    
						tdc.source_deal_detail_id,  
						deal_date,    
						gen_date,    
						source_curve_def_id,  
						counterparty_id,  
						generator_id,  
						jurisdiction_state_id,  
						gen_state_value_id,  
						price,    
						tdc.volume,    
						bonus,    
						uom_id,  
						tdc.volume_left,
						tdcu.volume_left,
						conv_factor,  
						expiration_date,  
						status_value_id,  
						term_start,
						technology,
						product,
						'+ CASE WHEN @cert_from IS NOT NULL THEN CAST(@cert_from AS VARCHAR) 
						ELSE '  COALESCE(tf.cert_from,assign1.assigned_volume+gis.certificate_number_from_int,gis.certificate_number_from_int) ' END +' as cert_from,'  
						+ CASE WHEN @cert_from IS NOT NULL THEN CAST(@cert_to AS VARCHAR)
						ELSE '  ISNULL(CASE WHEN tf.cert_from is not null and tf.volume_left+round(isnull(tdc.bonus/tdc.conv_factor, 0), 0)<0 then round(tf.volume-tdc.volume_left,0)+tf.cert_from-1 else round(tf.volume-tdc.volume_Left,0)+tf.cert_from-1 end, 
						ISNULL((assign1.assigned_volume-1+tdc.vol_to_be_assigned),tdc.vol_to_be_assigned)+gis.certificate_number_from_int) ' END +' as cert_to
				FROM #temp_deals_collect2 tdc
				INNER JOIN #temp_deals_cutoff2 tdcu ON tdc.source_deal_header_id = tdcu.source_deal_header_id
				LEFT JOIN #temp_final_6 tf ON tf.source_deal_detail_id = tdc.source_deal_detail_id
				LEFT JOIN #temp_cert_3 gis ON gis.source_deal_header_id = tdc.source_deal_detail_id  
				LEFT JOIN        
					(
						SELECT source_deal_header_id_from,sum(assigned_volume) assigned_volume from         
						assignment_audit group by source_deal_header_id_from
					) assign1        
				ON assign1.source_deal_header_id_from=tdc.source_deal_detail_id 		
				'

	--PRINT @sql
	EXEC(@sql)

	IF @debug = 1
	BEGIN
		--select * from #bonus
		SELECT '#temp_deals_collect2'
		SELECT * FROM #temp_deals_collect2
	END

	 --'SELECT ''' + @table_name + ''' [Process Table], [Assign_id], row_unique_id, [ID] [Detail ID]
		--		, dbo.FNAHyperLinkText(10131010, [Deal ID], [Deal ID]) [Deal ID], deal_date [Deal Date], Vintage, Expiration 
		--		, Jurisdiction, Technology, [Gen State], Generator, obligation [Env Product], Counterparty
		--		, dbo.FNARemoveTrailingZero(ROUND(CAST(assigned_volume AS NUMERIC(38, 20)), ' + CAST(@vol_rounding AS VARCHAR(2)) + ')) AS [Assigned Volume]
		--		, dbo.FNARemoveTrailingZero(ROUND(CAST([Volume UNassign] AS NUMERIC(38, 20)), ' + CAST(@vol_rounding AS VARCHAR(2)) + ')) [Unassign Volume]
		--		, dbo.FNARemoveTrailingZero(ROUND(CAST(assigned_volume AS NUMERIC(38, 20)), ' + CAST(@vol_rounding AS VARCHAR(2)) + ')) [Total Volume]
		--		, UOM
		--		' + CASE WHEN @assignment_type <> 5173 THEN '
		--		, tier AS [Unassigned To Tier]
		--		, dbo.FNARemoveTrailingZero(ROUND(fixed_price, ' + CAST(@vol_rounding AS VARCHAR(2)) + ')) [Price]'
		--		ELSE '' END + '
		--		' + @str_batch_table + '
	 --           FROM	            
	 --            ' + @table_name + ' a'   

	 

	SET @sql = 'select  ''' + @table_name + ''' [Process ID],NULL [Assign_id], ROW_NUMBER() OVER (ORDER BY MAX(tdcu.id)) row_unique_id,
			  MAX(source_deal_detail_id) [Detail ID], tdc.source_deal_header_id [Deal ID] ,  dbo.FNADateFormat(MAX(deal_date)) [Deal Date],
			 dbo.FNADateFormat(MAX(gen_date)) [Vintage], dbo.FNADateFormat(MAX(expiration_date)) [Expiration],
			MAX(sdv_state.code) [Jurisdiction], MAX(sdv_tech.code) [Technology], MAX(sdv_gen_state.code) [Gen State],
			MAX(rg.name) [Generator], MAX(spcd.curve_name) [Env Product], MAX(sc.counterparty_name) [Counterparty], 
			MAX(volume) [Volume Left], MAX(tdcu.volume_left) [Volume Assigned], MAX(bonus) Bonus,
			MAX(tdcu.volume_left) [Total Volume], MAX(tdc.uom_id) [UOM], MAX(price) Price
			 --dbo.FNADateFormat(MAX(term_start)) [Term Start], 
			 --MAX(spcd_prod.curve_name) Product
			 ' + @str_batch_table + ' from #temp_deals_collect2 tdc
			 INNER JOIN #temp_deals_cutoff2 tdcu ON tdc.source_deal_header_id = tdcu.source_deal_header_id
			 INNER JOIN source_price_curve_def spcd On spcd.source_curve_def_id = tdc.source_curve_def_id
			INNER JOIN source_counterparty sc ON sc.source_counterparty_id = tdc.counterparty_id
			INNER JOIN rec_generator rg ON rg.generator_id = tdc.generator_id 
			INNER JOIN static_data_value sdv_state ON sdv_state.value_id = tdc.jurisdiction_state_id
			INNER JOIN static_data_value sdv_gen_state ON sdv_gen_state.value_id = tdc.gen_state_value_id
			INNER JOIN static_data_value sdv_tech ON sdv_tech.value_id = tdc.technology
			 INNER JOIN source_price_curve_def spcd_prod On spcd.source_curve_def_id = tdc.product
			 GROUP BY tdc.source_deal_header_id
			order by MAX(tdcu.id)'
	EXEC(@sql)

	/*******************************************2nd Paging Batch START**********************************************/
 
	--update time spent and batch completion message in message board
	IF @is_batch = 1
	BEGIN
	   SELECT @sql_paging = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
	   EXEC(@sql_paging)
	 
	   --TODO: modify sp and report name
	   SELECT @sql_paging = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_find_assignment_rec_deals', 'Run Assignment logic')
	   EXEC(@sql_paging)  
	 
	   RETURN
	END
	 
	--if it is first call from paging, return total no. of rows and process id instead of actual data
	IF @enable_paging = 1 AND @page_no IS NULL
	BEGIN
	   SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
	   EXEC(@sql_paging)
	END

END

ELSE IF @flag = 'p'
BEGIN

	
	IF OBJECT_ID('tempdb..#temp_finalized_deals2') IS NOT NULL DROP TABLE #temp_finalized_deals2  
	CREATE TABLE #temp_finalized_deals2
	(  
		id INT IDENTITY(1, 1),
		priority INT,  
		source_deal_header_id INT,    
		source_deal_detail_id INT,  
		deal_date DATETIME,    
		gen_date DATETIME,    
		source_curve_def_id INT,  
		counterparty_id INT,  
		generator_id INT,  
		jurisdiction_state_id INT,  
		gen_state_value_id INT,  
		price NUMERIC(38, 20),    
		volume NUMERIC(38, 20),    
		bonus NUMERIC(38, 20),    
		expiration VARCHAR(30) COLLATE DATABASE_DEFAULT,    
		uom_id INT,  
		volume_left NUMERIC(38, 20),
		vol_to_be_assigned NUMERIC(38, 20),
		ext_deal_id INT,  --TODO: check if it is really needed 
		conv_factor NUMERIC(38, 20),  
		expiration_date DATETIME,  
		assigned_date DATETIME,  
		status_value_id INT,  
		term_start DATETIME,
		technology INT,
		product INT,
		compliance_year INT,
		tier_type_value_id INT,
		close_reference_id INT
	) 
	
	--select @deal_id
	
	INSERT INTO #temp_finalized_deals2(source_deal_header_id,source_deal_detail_id, deal_date, gen_date, source_curve_def_id, 
				counterparty_id, generator_id, jurisdiction_state_id, gen_state_value_id, price, volume, bonus, uom_id, vol_to_be_assigned
				, volume_left,  conv_factor, expiration_date, assigned_date, status_value_id, term_start, technology, product, 
				compliance_year, tier_type_value_id, close_reference_id)
	
	select  sdh.source_deal_header_id, max(sdd.source_deal_detail_id), max(sdh.deal_date), max(sdd.term_start), max(sdd.curve_id)
	, max(sdh.counterparty_id), max(sdh.generator_id), max(gc.state_value_id), max(rg.gen_state_value_id), max(ISNULL(CAST(sdd.fixed_price as NUMERIC(38,20)), 0))
	, max(sdd.deal_volume)  AS volume, 0 bonus
	, max(su.source_uom_id) AS uom_id, max(sdd.volume_left)  AS vol_to_be_assigned
	, max(sdd.volume_left)  AS Volume_left,  
	max(rs_cf.conversion_factor) AS conv_factor, DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,cast((year(max(sdd.term_start)) + 
	CASE WHEN(isnull(max(rg.gen_offset_technology), 'n') = 'n') THEN 
		ISNULL(max(spd.duration) ,isnull(max(sp.duration), 0)) 
	ELSE ISNULL(max(spd.offset_duration) ,isnull(max(sp.offset_duration), 0)) END 
	- 1) AS VARCHAR) 
	+ '-' + CAST(ISNULL(max(sp.calendar_to_month), 12) as varchar) + '-01')+1,0)) expiration_date, NULL
	, max(sdh.status_value_id), max(sdd.term_start), max(rg.technology), max(rg.source_curve_def_id), YEAR(max(sdd.term_start)), max(tc.[tier/class])
	, max(sdh.close_reference_id)
	 
	 --select distinct sdh.source_deal_header_id
	 FROM 
	 source_deal_header sdh 
	INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
		AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
		AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
		AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
	INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
	INNER JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
		--AND gc.state_value_id = tc.jurisdiction
	INNER JOIN tier_class tc ON tc.[tier/class] = gc.tier_type
		AND tc.jurisdiction = gc.state_value_id
		AND ISNULL(gc.[year],tc.[year]) = tc.[year]
		--and tc.deal_id = 5813
		--AND tc.[year] = YEAR(sdd.term_start)
	--INNER JOIN (select  * from static_data_value where type_id =10092) sdv_year ON sdv_year.value_id = tc.[year]
	--	AND sdv_year.code = ISNULL(gc.[year], sdv_year.code)
	INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		--AND rg.gis_value_id = tc.cert_entity
	INNER JOIN state_properties sp ON sp.state_value_id = gc.state_value_id
	LEFT JOIN static_data_value state ON state.value_id = tc.jurisdiction 
	LEFT JOIN source_uom su ON su.source_uom_id = sdd.deal_volume_uom_id   
	LEFT JOIN state_properties_duration spd on spd.state_value_id = sp.state_value_id 
			AND spd.technology = rg.technology 	
			AND (ISNULL(spd.assignment_type_Value_id, 5149) = ISNULL(NULL, 5149) OR spd.assignment_type_Value_id IS NULL) 
	LEFT JOIN #bonus bns ON bns.state_value_id = sp.state_value_id    
			AND bns.technology = rg.technology  
			AND ISNULL(bns.assignment_type_value_id, 5149) = @assignment_type  
			AND sdd.term_start between bns.from_date and bns.to_date  
			AND bns.gen_state_value_id = rg.gen_state_value_id  
	LEFT JOIN rec_volume_unit_conversion Conv1 ON conv1.from_source_uom_id = sdd.deal_volume_uom_id               
			AND conv1.to_source_uom_id = ISNULL(CAST(@convert_uom_id AS VARCHAR),'NULL')              
			And conv1.state_value_id = state.value_id  
			AND conv1.assignment_type_value_id = CAST(@assignment_type AS VARCHAR)  
			AND conv1.curve_id = sdd.curve_id     
			AND conv1.to_curve_id IS NULL        
	LEFT JOIN rec_volume_unit_conversion Conv2 ON conv2.from_source_uom_id = sdd.deal_volume_uom_id   
		AND conv2.to_source_uom_id = ISNULL(CAST(@convert_uom_id AS VARCHAR),'NULL')              
		And conv2.state_value_id IS NULL  
		AND conv2.assignment_type_value_id =  CAST(@assignment_type AS VARCHAR)    
		AND conv2.curve_id = sdd.curve_id    
		AND conv2.to_curve_id IS NULL        
	LEFT JOIN rec_volume_unit_conversion Conv3 ON conv3.from_source_uom_id =  sdd.deal_volume_uom_id              
		AND conv3.to_source_uom_id = ISNULL(CAST(@convert_uom_id AS VARCHAR),'NULL')             
		And conv3.state_value_id IS NULL  
		AND conv3.assignment_type_value_id IS NULL  
		AND conv3.curve_id = sdd.curve_id            
		AND conv3.to_curve_id IS NULL        
	LEFT JOIN rec_volume_unit_conversion Conv4 ON conv4.from_source_uom_id = sdd.deal_volume_uom_id  
		AND conv4.to_source_uom_id = ISNULL(CAST(@convert_uom_id AS VARCHAR),'NULL')              
		And conv4.state_value_id IS NULL  
		AND conv4.assignment_type_value_id IS NULL  
		AND conv4.curve_id IS NULL  
		AND conv4.to_curve_id IS NULL        
	LEFT JOIN rec_volume_unit_conversion Conv5 ON conv5.from_source_uom_id  = sdd.deal_volume_uom_id                
		AND conv5.to_source_uom_id = ISNULL(CAST(@convert_uom_id AS VARCHAR),'NULL')              
		And conv5.state_value_id = state.value_id  
		AND conv5.assignment_type_value_id is null  
		AND conv5.curve_id = sdd.curve_id   
		AND conv5.to_curve_id IS NULL
	OUTER APPLY(
		               SELECT CAST(
		                          COALESCE(
		                              conv1.conversion_factor
		                             , conv5.conversion_factor
		                             , conv2.conversion_factor
		                             , conv3.conversion_factor
		                             , conv4.conversion_factor
		                             , 1
		                          ) AS NUMERIC(20, 8)
		                      ) AS conversion_factor
		           ) rs_cf 
		WHERE tc.deal_id = @deal_id
			--AND ISNULL(sdh.close_reference_id,-1) <> @deal_id
			AND sdh.source_deal_header_id not in(
				
							SELECT a.source_deal_header_id FROM
							(
							SELECT tc_inner.deal_id, COUNT(tc_inner.deal_id) all_count FROM tier_class tc_inner WHERE tc_inner.deal_id = @deal_id GROUP BY tc_inner.deal_id
							) tc
							CROSS JOIN (
							SELECT sdh.source_deal_header_id,
							--, tc_all.[tier/class], tc_all.jurisdiction
							MAX(CASE WHEN tc_all.[and/or] = 1 THEN 1 ELSE 0 END) max_and_or
							--, COUNT(tc_all.deal_id) all_count
							, COUNT(sdh.source_deal_header_id) match_count
							FROM tier_class tc_all
							INNER JOIN tier_class tc_matching ON tc_all.tier_class_id = tc_matching.tier_class_id
							LEFT JOIN Gis_Certificate gc ON gc.tier_type = tc_matching.[tier/class]
								AND gc.state_value_id = tc_matching.jurisdiction
								AND ISNULL(gc.[year], tc_matching.[year]) = tc_matching.[year]
							--IMP: Gis_Certificate.source_deal_header actually points to sdh.source_deal_header_id
							LEFT JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = gc.source_deal_header_id
							LEFT JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
							LEFT JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
								AND rg.gis_value_id = tc_matching.cert_entity
							--LEFT JOIN static_data_value sdv ON sdv.value_id = tc_matching.[year]
							--	AND sdv.code = ISNULL(gc.[year], sdv.code)
							LEFT JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
								AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
								AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
								AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
							WHERE tc_all.deal_id IN (@deal_id) 
							GROUP BY sdh.source_deal_header_id
							) a
							where tc.deal_id = @deal_id
							AND (a.max_and_or = 1  AND a.match_count < all_count)
									OR  (a.max_and_or = 0 AND match_count = 0)
				--order by sdh.source_deal_header_id
			)
			group by sdh.source_deal_header_id
			
			--return
--select * from #ssbm
			--where tc.tier_class_id is  null
			
			--select * from #temp_finalized_deals2
	
			--return
		
	IF OBJECT_ID('tempdb..#target_profile2') IS NOT NULL
	DROP TABLE #target_profile2
	
	--create table to hold target for each tier
	CREATE TABLE #target_profile2  
	(    
		target_volume float
	)  
	
	IF OBJECT_ID('tempdb..#temp_finalized_deals3') IS NOT NULL
	DROP TABLE #temp_finalized_deals3
	
	CREATE TABLE #temp_finalized_deals3
	(
		source_deal_header_id INT,
		volume_left	float,
	)
	
	--SELECT  MAX(sdd.volume_left) - ISNULL(SUM(aa.assigned_volume),0)
	--  --target_volume
	-- FROM source_deal_detail sdd
	--INNER JOIN dbo.SplitCommaSeperatedValues(@deal_id) scsv ON scsv.item = sdd.source_deal_header_id
	--left JOIN source_deal_header sdh_buy ON sdh_buy.close_reference_id = scsv.item
	--LEFT JOIN source_deal_detail sdd_buy ON sdd_buy.source_deal_header_id = sdh_buy.source_deal_header_id
	--LEFT JOIN assignment_audit aa ON aa.source_deal_header_id_from = sdd_buy.source_deal_detail_id
	--GROUP BY sdd.source_deal_header_id
	--select * from #target_profile2
	INSERT INTO #target_profile2(target_volume)
	SELECT MAX(sdd.volume_left) - ISNULL(SUM(aa.assigned_volume),0) target_volume FROM source_deal_detail sdd
	INNER JOIN dbo.SplitCommaSeperatedValues(@deal_id) scsv ON scsv.item = sdd.source_deal_header_id
	LEFT JOIN source_deal_header sdh_buy ON sdh_buy.close_reference_id = sdd.source_deal_header_id
	LEFT JOIN source_deal_detail sdd_buy ON sdd_buy.source_deal_header_id = sdh_buy.source_deal_header_id
	LEFT JOIN assignment_audit aa ON aa.source_deal_header_id_from = sdd_buy.source_deal_detail_id
	
	DECLARE @message VARCHAR(100)
	SET @message = 'The transaction has already been delivered'
	
	 IF EXISTS
	(
		SELECT   1 FROM  source_deal_header sdh 
		INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
		INNER JOIN assignment_audit aa ON sdd.source_deal_detail_id = aa.source_deal_header_id_from
		CROSS APPLY #target_profile2 tp
		where sdh.close_reference_id =5814-- @deal_id
		having SUM(aa.assigned_volume) >= MAX(tp.target_volume) 
	)
	BEGIN
		EXEC spa_ErrorHandler -1, 'Assign Transactions', 'spa_find_assignment_rec_deals', 'Failure', @message, ''
		
	END
	
	
	DECLARE @source_deal_header_id INT, @volume_left float, @target_volume float, @floating_target_volume float
	
	DECLARE cur_status CURSOR LOCAL FOR
	SELECT source_deal_header_id, volume_left, tp.target_volume from #temp_finalized_deals2 tfd
	CROSS APPLY #target_profile2 tp
	
		
	OPEN cur_status;

	FETCH NEXT FROM cur_status INTO @source_deal_header_id, @volume_left, @target_volume
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		IF @volume_left > @target_volume
		BEGIN
			SET @volume_left = @target_volume
		END
			
		INSERT INTO #temp_finalized_deals3(source_deal_header_id, volume_left)
		SELECT @source_deal_header_id, @volume_left
		
		IF @volume_left = @target_volume
		BEGIN
			BREAK
		END
		
		SET @floating_target_volume = @target_volume - @volume_left
		
		UPDATE #target_profile2 SET target_volume = @floating_target_volume
		
		--IF EXISTS(select 1 from #temp_finalized_deals3 tfd
		--CROSS APPLY #target_profile2 tp having SUM(volume_left)> max(target_volume))
		--BEGIN
						 
		--	BREAK
		--END
	
		FETCH NEXT FROM cur_status INTO @source_deal_header_id, @volume_left, @target_volume
	END;

	CLOSE cur_status;
	DEALLOCATE cur_status;	 
	
	IF OBJECT_ID('tempdb..#temp_table') IS NOT NULL
	DROP TABLE #temp_table
	
	--select * from #temp_finalized_deals2
	
	SELECT * INTO #temp_table from #temp_finalized_deals2
	DELETE FROM #temp_finalized_deals2
	INSERT INTO #temp_finalized_deals2
	(
		source_deal_header_id,source_deal_detail_id, deal_date, gen_date, source_curve_def_id, 
		counterparty_id, generator_id, jurisdiction_state_id, gen_state_value_id, price, volume, bonus, uom_id, vol_to_be_assigned
		, volume_left,  conv_factor, expiration_date, assigned_date, status_value_id, term_start, technology, product, 
		compliance_year, tier_type_value_id
	)
	SELECT tt.source_deal_header_id,source_deal_detail_id, deal_date, gen_date, source_curve_def_id, 
		counterparty_id, generator_id, jurisdiction_state_id, gen_state_value_id, price, volume, bonus, uom_id, tfd.volume_left
		, tt.volume_left - tfd.volume_left,  conv_factor, expiration_date, assigned_date, status_value_id, term_start, technology, product, 
		compliance_year, tier_type_value_id
	FROM #temp_table tt INNER JOIN #temp_finalized_deals3 tfd ON tt.source_deal_header_id = tfd.source_deal_header_id
	
		   --select * from #temp_finalized_deals3
		   
		   --return      
	
		IF OBJECT_ID('tempdb..#temp_include_1') IS NOT NULL
		DROP TABLE #temp_include_1

	CREATE TABLE #temp_include_1   
	( 
		id INT,    
		deal_id INT,    
		volume_assign NUMERIC(38, 20),      
		bonus NUMERIC(38, 20),      
		volume NUMERIC(38, 20),    
		volume_left NUMERIC(38, 20),
		tier_type_value_id INT   
	)     
	--drop table #temp_include
	--select * from #temp2
	--UPDATE #temp2 SET TARGET = 200
	--UPDATE #temp2 SET TARGET = 154100 WHERE deal_id = 432708
	   
	INSERT INTO #temp_include_1    
	SELECT id,source_deal_header_id, vol_to_be_assigned AS volume_assign    
	, CASE WHEN vol_to_be_assigned = 0 OR vol_to_be_assigned - volume_left_cumu  <= 0 THEN volume_left - volume_left1 ELSE    
	(volume_left - (vol_to_be_assigned - volume_left_cumu)) - ((volume_left - (vol_to_be_assigned - volume_left_cumu)) / (1 + bonus_per)) END  AS bonus,  
	--CASE WHEN [target] = 0 OR [target] - volume_left_cumu <= 0 THEN
	 a.volume_left
	--	 else    
	--volume_left-([target] - volume_left_cumu) end  
	AS volume,  
	--CASE WHEN [target] = 0 OR [target] - volume_left_cumu <=0 then 
	a.volume_left
	--else  
	 --[target]  -	volume_left
	--volume_left1-(volume_left-([target] - volume_left_cumu))/(1+bonus_per)
	--END
	AS volume_left,
	a.tier_type_value_id
	FROM
	(
		SELECT id, source_deal_header_id, volume, bonus, (bonus / (CASE WHEN volume = 0 THEN 1 ELSE volume END)) bonus_per, volume_left + (volume_left * (bonus / CASE WHEN volume = 0 THEN 1 ELSE volume END)) volume_left
		, volume_left volume_left1, vol_to_be_assigned, tier_type_value_id
		, (
			SELECT SUM(volume_left + (volume_left * (bonus / CASE WHEN volume = 0 THEN 1 ELSE volume END))) 
			FROM #temp_finalized_deals2 WHERE id <= a.id
			) AS volume_left_cumu    
	FROM     
	#temp_finalized_deals2 a    
	) a     
	WHERE  1=1 
	
	IF OBJECT_ID('tempdb..#temp_assign_1') is not null
	DROP TABLE #temp_assign_1
	
	CREATE TABLE #temp_assign_1 (  
		source_deal_detail_id INT,  
		cert_from INT,  
		cert_to INT,  
		assignment_type INT
	)  
	
	IF OBJECT_ID('tempdb..#temp_cert_1') is not null
	DROP TABLE #temp_cert_1
	
	CREATE TABLE #temp_cert_1 (  
		source_deal_header_id INT,  
		certificate_number_from_int INT,  
		certificate_number_to_int INT  
	)  
	  
	INSERT #temp_cert_1  
	SELECT gis.source_deal_header_id, gis.certificate_number_from_int, gis.certificate_number_to_int   
	FROM gis_certificate gis
	INNER JOIN #temp_finalized_deals2 tds ON tds.source_deal_header_id = gis.source_deal_header_id

	DECLARE cursor1 CURSOR FOR  
	SELECT source_deal_header_id, certificate_number_from_int, certificate_number_to_int 
	FROM #temp_cert_1  
	  
	OPEN cursor1  
	FETCH NEXT FROM cursor1 INTO @gis_deal_id, @certificate_f, @certificate_t  
	   
	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		DECLARE cursor2 CURSOR FOR   
		SELECT cert_from, cert_to 
		FROM assignment_audit 
		WHERE source_deal_header_id_from = @gis_deal_id AND assigned_volume > 0  
		ORDER BY cert_from
		
		OPEN cursor2  
		FETCH NEXT FROM cursor2 INTO @cert_from_f, @cert_to_t  
		WHILE @@FETCH_STATUS = 0  
		BEGIN  
			IF @cert_from_f > @certificate_f   
			BEGIN  
				INSERT #temp_assign_1 (source_deal_detail_id, cert_from, cert_to, assignment_type)  
				VALUES (@gis_deal_id, @certificate_f, @cert_from_f - 1, @bank_assignment)  
			END  

			SET @certificate_f = @cert_to_t + 1  

			FETCH NEXT FROM cursor2 INTO @cert_from_f, @cert_to_t  
		END  
		IF (@certificate_f - 1) < @certificate_t  
		BEGIN  
			INSERT #temp_assign_1 (source_deal_detail_id, cert_from, cert_to, assignment_type) 
			VALUES (@gis_deal_id, @certificate_f, @certificate_t, @bank_assignment)  
		END  
		FETCH NEXT FROM cursor1 INTO @gis_deal_id,@certificate_f,@certificate_t  
		
		CLOSE cursor2  
		DEALLOCATE cursor2   
	 END   
	CLOSE cursor1  
	DEALLOCATE cursor1   
	   
	
	IF OBJECT_ID('tempdb..#temp_final_1') IS NOT NULL
		DROP TABLE #temp_final_1
	  
	CREATE TABLE #temp_final_1 (  
		[ID] INT IDENTITY,  
		source_deal_detail_id INT,  
		cert_From INT,  
		cert_to INT,  
		assignment_type INT,  
		volume NUMERIC(38, 20)   
	)

	INSERT INTO #temp_final_1(source_deal_detail_id, cert_from, cert_to, assignment_type, volume)  
	SELECT source_deal_detail_id, cert_from, cert_to, assignment_type, (cert_to - cert_from + 1) AS volume
	FROM (  
		SELECT source_deal_detail_id, cert_from, cert_to, assignment_type FROM #temp_assign_1  
		UNION ALL  
		SELECT source_deal_header_id_from, cert_from, cert_to, assignment_type FROM assignment_audit  
	) a 
	--ORDER BY a.source_deal_detail_id, a.cert_from  

	IF OBJECT_ID('tempdb..#temp_final_2') IS NOT NULL
		DROP TABLE #temp_final_2
	  
	SELECT [ID], source_deal_detail_id, cert_from, cert_to, assignment_type, a.volume,volume_cumu, vol_to_be_assigned AS volume_left 
	INTO #temp_final_2 
	FROM  
	(  
		SELECT b.[ID], b.source_deal_detail_id, cert_from, cert_to,assignment_type, a.volume
		, (SELECT SUM(volume) 
			 FROM #temp_final_1 
			 WHERE [ID] <= a.[ID] --and assignment_type = @assignment_type  
				AND source_deal_detail_id = a.source_deal_detail_id
			) AS volume_cumu
		, b.vol_to_be_assigned
		FROM #temp_final_1 a
		INNER JOIN #temp_finalized_deals2 b ON a.source_deal_detail_id = b.source_deal_detail_id 
		WHERE 1 = 1 --assignment_type = @assignment_type   
	) a  
	WHERE ROUND((CASE WHEN volume_cumu - vol_to_be_assigned <= 0 THEN volume ELSE    
	 volume - (volume_cumu - vol_to_be_assigned) END), @vol_rounding) > 0    
	 
	IF @table_name IS NULL OR @table_name = ''    
	SET @table_name = dbo.FNAProcessTableName('recassign_', dbo.FNADBUser(), dbo.FNAGetNewID())  
	
	--SELECT * FROM #temp_finalized_deals2
	--SELECT * FROM #temp_include_1
	
	 
		SET @sql = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) row_unique_id, tds.source_deal_detail_id [ID], tds.source_deal_header_id [Deal ID], dbo.FNADateFormat(tds.deal_date) deal_date,
	dbo.FNADateFormat(tds.gen_date) [Vintage], dbo.FNADateFormat(tds.expiration_date) expiration, sdv_jurisdiction.code jurisdiction, 
	sdv_gen.code [Gen State], rg.name [Generator],
	COALESCE(Conv1.curve_label,Conv5.curve_label,Conv2.curve_label,Conv3.curve_label,Conv4.curve_label, spcd.curve_name) obligation,
	sc.counterparty_name [Counterparty], tds.volume_left + vol_to_be_assigned [Volume Left],isnull(tds.bonus,0) bonus, su.uom_name [UOM], tds.price,
	vol_to_be_assigned - tds.bonus [Volume Assign], vol_to_be_assigned [Total Volume],  
	dbo.FNACertificateRule(cr.cert_rule,rg.[ID],'+CASE WHEN @cert_from IS NOT NULL THEN CAST(@cert_from AS VARCHAR) 
	ELSE ' COALESCE(tf.cert_from,assign1.assigned_volume+gis.certificate_number_from_int,gis.certificate_number_from_int)' END+' ,tds.gen_date) as  [Cert # From], 
	dbo.FNACertificateRule(cr.cert_rule,rg.[ID],'+CASE WHEN @cert_from IS NOT NULL THEN CAST(@cert_to AS VARCHAR) ELSE   
	'ISNULL(CASE WHEN tf.cert_from is not null and tf.volume_left+round(isnull(b.bonus/tds.conv_factor, 0), 0)<0 then round(tf.volume-b.volume_left,0)+tf.cert_from-1 else round(tf.volume-b.volume_Left,0)+tf.cert_from-1 end ,  
	ISNULL((assign1.assigned_volume-1+b.volume_assign),b.volume_assign-1)+gis.certificate_number_from_int)' END +' ,tds.gen_date) as  [Cert # T0],  
	'+CASE WHEN @cert_from IS NOT NULL THEN CAST(@cert_from AS VARCHAR) 
	ELSE '  COALESCE(tf.cert_from,assign1.assigned_volume+gis.certificate_number_from_int,gis.certificate_number_from_int) ' END +' as cert_from,'  
	 +CASE WHEN @cert_from IS NOT NULL THEN CAST(@cert_to AS VARCHAR)
	  ELSE '  ISNULL(CASE WHEN tf.cert_from is not null and tf.volume_left+round(isnull(b.bonus/tds.conv_factor, 0), 0)<0 then round(tf.volume-b.volume_left,0)+tf.cert_from-1 else round(tf.volume-b
	.volume_Left,0)+tf.cert_from-1 end ,  
	  ISNULL((assign1.assigned_volume-1+b.volume_assign),b.volume_assign)+gis.certificate_number_from_int) ' END +' as cert_to, 
	tds.compliance_year--, td.tier_type, ISNULL(tp.min_target, tp.max_target) target, tp.total_target
	, rg.gen_state_value_id, sdv_tech.code [Technology], tds.jurisdiction_state_id, sdv_tier.code [Tier], sdv_tier.value_id [Tier_value_id]
	--select *
	INTO ' + @table_name + '
	FROM #temp_finalized_deals2 tds
	INNER JOIN #temp_include_1 b ON tds.id = b.id  
		AND tds.tier_type_value_id = b.tier_type_value_id
	LEFT JOIN rec_generator rg ON tds.generator_id = rg.generator_id
		AND tds.gen_state_value_id = rg.gen_state_value_id
		AND tds.technology = rg.technology
	LEFT JOIN static_data_value sdv_tier ON sdv_tier.value_id = tds.tier_type_value_id
	LEFT JOIN static_data_value sdv_tech ON sdv_tech.value_id = rg.technology
	INNER JOIN static_data_value sdv_jurisdiction ON sdv_jurisdiction.value_id = tds.jurisdiction_state_id
	LEFT JOIN static_data_value sdv_gen ON sdv_gen.value_id =  rg.gen_state_value_id
	LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = tds.source_curve_def_id  
	LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = tds.counterparty_id 
	LEFT JOIN assignment_audit assign ON tds.source_deal_detail_id = assign.source_deal_header_id 
	LEFT JOIN source_uom su ON su.source_uom_id = tds.uom_id	
	LEFT JOIN static_data_value state ON state.value_id = ISNULL(assign.state_value_id,rg.state_value_id) 
	LEFT JOIN rec_volume_unit_conversion Conv1 ON            
	 conv1.from_source_uom_id  = tds.uom_id             
		AND conv1.to_source_uom_id = ' + ISNULL(CAST(@convert_uom_id as varchar),'NULL') +'           
		And conv1.state_value_id = state.value_id
		AND conv1.assignment_type_value_id = ' + cast(@assignment_type as varchar) + ' 
		AND conv1.curve_id = tds.source_curve_def_id             
		AND conv1.to_curve_id IS NULL
	LEFT JOIN rec_volume_unit_conversion Conv2 ON            
	 conv2.from_source_uom_id = tds.uom_id              
		AND conv2.to_source_uom_id = ' + ISNULL(CAST(@convert_uom_id as varchar),'NULL') +'        
		And conv2.state_value_id IS NULL
		AND conv2.assignment_type_value_id = ' + cast(@assignment_type as varchar) + '  
		AND conv2.curve_id = tds.source_curve_def_id  
		AND conv2.to_curve_id IS NULL
	LEFT JOIN rec_volume_unit_conversion Conv3 ON            
	conv3.from_source_uom_id =  tds.uom_id             
		AND conv3.to_source_uom_id = ' + ISNULL(CAST(@convert_uom_id as varchar),'NULL') +'           
		And conv3.state_value_id IS NULL
		AND conv3.assignment_type_value_id IS NULL
		AND conv3.curve_id = tds.source_curve_def_id  
		AND conv3.to_curve_id IS NULL
	LEFT JOIN rec_volume_unit_conversion Conv4 ON            
	 conv4.from_source_uom_id = tds.uom_id
		AND conv4.to_source_uom_id = ' + ISNULL(CAST(@convert_uom_id as varchar),'NULL') +'         
		And conv4.state_value_id IS NULL
		AND conv4.assignment_type_value_id IS NULL
		AND conv4.curve_id IS NULL
		AND conv4.to_curve_id IS NULL
	LEFT JOIN rec_volume_unit_conversion Conv5 ON            
	 conv5.from_source_uom_id  = tds.uom_id             
		AND conv5.to_source_uom_id = ' + ISNULL(CAST(@convert_uom_id as varchar),'NULL') +'         
		And conv5.state_value_id = state.value_id
		AND conv5.assignment_type_value_id is null
		AND conv5.curve_id = tds.source_curve_def_id 
		AND conv5.to_curve_id IS NULL
	LEFT JOIN #temp_final_2 tf ON tf.source_deal_detail_id = tds.source_deal_detail_id
	LEFT JOIN certificate_rule cr ON isnull(rg.gis_value_id, 5164) = cr.gis_id
	LEFT JOIN        
		(
			SELECT source_deal_header_id_from,sum(assigned_volume) assigned_volume from         
			assignment_audit group by source_deal_header_id_from
		) assign1        
		ON assign1.source_deal_header_id_from=tds.source_deal_header_id 
	LEFT JOIN #temp_cert_1 gis ON gis.source_deal_header_id = tds.source_deal_header_id   
	WHERE ROUND(tds.vol_to_be_assigned, ' + CAST(@vol_rounding AS VARCHAR(15)) + ') > 0
	ORDER BY tds.priority'
		
	--PRINT @sql
	EXEC(@sql)
	
	SET @sql = 'SELECT ''' + @table_name + ''' [Process Table], NULL [Assign_id], row_unique_id, [ID] [Detail ID]
				, [Deal ID], deal_date [Deal Date], Vintage--, Expiration 
				, Jurisdiction, Technology, [Gen State], Generator, obligation [Env Product], Counterparty
				, CAST(dbo.FNARemoveTrailingZero(ROUND(CAST([Volume Left] AS NUMERIC(38, 20)), ' + CAST(@vol_rounding AS VARCHAR(2)) + ')) AS FLOAT)  AS [Volume Available]
				, CAST(dbo.FNARemoveTrailingZero(ROUND(CAST([Volume Assign] AS NUMERIC(38, 20)), ' + CAST(@vol_rounding AS VARCHAR(2)) + ')) AS FLOAT)  [Volume Assign]
				, CAST(dbo.FNARemoveTrailingZero(ROUND(CAST(Bonus AS NUMERIC(38, 20)), ' + CAST(@vol_rounding AS VARCHAR(2)) + ')) AS FLOAT)  Bonus 
				, CAST(dbo.FNARemoveTrailingZero(ROUND(CAST([Total Volume] AS NUMERIC(38, 20)), ' + CAST(@vol_rounding AS VARCHAR(2)) + ')) AS FLOAT) [Total Volume]
				, UOM
				, CAST(dbo.FNARemoveTrailingZero(ROUND(Price, ' + CAST(@vol_rounding AS VARCHAR(2)) + ')) AS FLOAT) [Price]
				
				' + @str_batch_table + '
	            FROM	            
	             ' + @table_name + ' a'   
	          
	 --PRINT @sql
	 EXEC(@sql)
	 
	
		          
	
	/*******************************************2nd Paging Batch START**********************************************/
 
	--update time spent and batch completion message in message board
	IF @is_batch = 1
	BEGIN
	   SELECT @sql_paging = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
	   EXEC(@sql_paging)
	 
	   --TODO: modify sp and report name
	   SELECT @sql_paging = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_find_assignment_rec_deals', 'Run Assignment logic')
	   EXEC(@sql_paging)  
	 
	   RETURN
	END
	 
	--if it is first call from paging, return total no. of rows and process id instead of actual data
	IF @enable_paging = 1 AND @page_no IS NULL
	BEGIN
	   SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
	   EXEC(@sql_paging)
	END
END
	
ELSE IF @flag = 'u'
BEGIN
	
	if object_id('tempdb..#temp_deals_for_unassignment') is not null
		drop table #temp_deals_for_unassignment
	
	--CREATE TABLE #temp_deals_for_unassignment(ID INT IDENTITY(1,1), source_deal_header_id INT, source_deal_detail_id INT, assigned_volume FLOAT, assigned_tier INT, vol_to_be_assigned FLOAT)
	
	
	IF OBJECT_ID('tempdb..#first_temp_deals_for_unassignment') IS NOT NULL
		DROP TABLE #first_temp_deals_for_unassignment
		
	
	
	SELECT ROW_NUMBER() OVER(ORDER BY MAX(sdd.term_start)) row_no
	, sdh.source_deal_header_id
	, MAX(sdd.source_deal_detail_id) source_deal_detail_id 
	, MAX(aa.assigned_volume) assigned_volume
	, MAX(sdd.term_start) term_start
	, aa.tier tier
	INTO #first_temp_deals_for_unassignment
	--select *
	FROM assignment_audit aa 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = aa.source_deal_header_id
	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
	INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
		AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
		AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
		AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
	WHERE 1=1 AND ISNULL(aa.[committed], -1) <> 1
		AND	ISNULL(aa.compliance_year,-1) = COALESCE(@compliance_year, aa.compliance_year, -1)
		AND ISNULL(aa.state_value_id,-1) = COALESCE(@assigned_state, aa.state_value_id, -1)
		AND aa.assignment_type = ISNULL(@assignment_type, aa.assignment_type)
		AND sdh.source_deal_header_id in (ISNULL(@deal_id,sdh.source_deal_header_id))
		AND ISNULL(aa.assigned_date,-1) = COALESCE(@assigned_date, aa.assignment_date,-1)
		--AND a.rolling_sum >= @volume
	GROUP BY sdh.source_deal_header_id, aa.tier
	ORDER BY term_start
	

	
	IF @debug = 1
	BEGIN
		
		select '#first_temp_deals_for_unassignment'
		select * from #first_temp_deals_for_unassignment
	END
	

	--select * from #first_temp_deals_for_unassignment
	
	 
	
	IF OBJECT_ID('tempdb..#margin_for_volume') IS NOT NULL
		DROP TABLE #margin_for_volume
		
	CREATE TABLE #margin_for_volume
	(
		source_deal_header_id INT, source_deal_detail_id INT, assigned_volume FLOAT, rolling_assigned_volume FLOAT, term_start DATETIME,
		fixed_volume FLOAT, row_no INT, tier INT
	)

	--INSERT INTO #temp_deals_for_unassignment(source_deal_header_id, source_deal_detail_id, assigned_volume, assigned_tier, vol_to_be_assigned)
	INSERT INTO #margin_for_volume
	(
		source_deal_header_id, source_deal_detail_id, assigned_volume, rolling_assigned_volume, term_start,
		fixed_volume, row_no, tier
	)
	SELECT TOP 1 ftdfu.source_deal_header_id
	, ftdfu.source_deal_detail_id
	, ftdfu.assigned_volume
	, a.rolling_assigned_volume
	, ftdfu.term_start
	, @volume fixed_volume
	, row_no
	, tier
	FROM #first_temp_deals_for_unassignment ftdfu
	OUTER APPLY
	(
		SELECT SUM(ftdfu_inner.assigned_volume) rolling_assigned_volume
		FROM #first_temp_deals_for_unassignment ftdfu_inner
		WHERE 1 = 1
			AND ftdfu_inner.row_no <= ftdfu.row_no
	) a
	WHERE 1 = 1
		AND a.rolling_assigned_volume >= ISNULL(@volume,a.rolling_assigned_volume)
	--GROUP BY sdh.source_deal_header_id
	--ORDER BY term_start, source_deal_detail_id
	
	
	
	IF @debug = 1
	BEGIN
		select '#margin_for_volume'
		select * from #margin_for_volume
	END
	--return
	IF NOT EXISTS(SELECT 1 FROM #margin_for_volume)
	BEGIN
		INSERT INTO #margin_for_volume
		(
			source_deal_header_id, source_deal_detail_id, assigned_volume, rolling_assigned_volume, term_start,
			fixed_volume, row_no, tier
		)
		SELECT TOP 1 ftdfu.source_deal_header_id
		, ftdfu.source_deal_detail_id
		, ftdfu.assigned_volume
		, a.rolling_assigned_volume
		, ftdfu.term_start
		, @volume fixed_volume
		, row_no
		, tier
		FROM #first_temp_deals_for_unassignment ftdfu
		OUTER APPLY
		(
			SELECT SUM(ftdfu_inner.assigned_volume) rolling_assigned_volume
			FROM #first_temp_deals_for_unassignment ftdfu_inner
			WHERE 1 = 1
				AND ftdfu_inner.row_no <= ftdfu.row_no
		) a
		WHERE 1 = 1
		ORDER BY row_no desc
	END
	
	--select * from #margin_for_volume
	
	IF @debug = 1
	BEGIN
		SELECT '#margin_for_volume'
		SELECT * from #margin_for_volume
	END
	
	IF OBJECT_ID('tempdb..#final_deal_volume_cutoff') IS NOT NULL
		DROP TABLE #final_deal_volume_cutoff
		
	SELECT  top 1 ftdfu.source_deal_header_id
	, ftdfu.source_deal_detail_id
	, ftdfu.assigned_volume - (rolling_assigned_volume - CASE WHEN @volume > rolling_assigned_volume
	 THEN rolling_assigned_volume ELSE @volume END) assigned_volume
	, rolling_assigned_volume
	, ftdfu.term_start
	, fixed_volume
	, ftdfu.row_no
	, ftdfu.tier
	INTO #final_deal_volume_cutoff
	FROM #first_temp_deals_for_unassignment ftdfu
	INNER JOIN #margin_for_volume mfv ON ftdfu.row_no <= mfv.row_no 
	order by row_no desc
	
	IF @debug = 1
	BEGIN
		select * from #final_deal_volume_cutoff
	END
	
	SELECT  a.source_deal_header_id
		, a.source_deal_detail_id
		, a.assigned_volume
		, a.rolling_assigned_volume
		, a.term_start
		, a.fixed_volume
		, a.row_no [ID]
		, a.tier
	INTO #temp_deals_for_unassignment
	FROM (
			SELECT  ftdfu.source_deal_header_id
				, ftdfu.source_deal_detail_id
				, ftdfu.assigned_volume
				, rolling_assigned_volume
				, ftdfu.term_start
				, @volume fixed_volume
				, ftdfu.row_no
				, ftdfu.tier
				FROM #first_temp_deals_for_unassignment ftdfu
				INNER JOIN #margin_for_volume mfv ON ftdfu.row_no < mfv.row_no 
			UNION ALL
			SELECT  fdvc.source_deal_header_id
			, fdvc.source_deal_detail_id
			, fdvc.assigned_volume
			, fdvc.rolling_assigned_volume
			, fdvc.term_start
			, fdvc.fixed_volume
			, fdvc.row_no
			, fdvc.tier
			FROM #final_deal_volume_cutoff fdvc
		  ) a
	
	IF @debug = 1
	BEGIN
		SELECT '#temp_deals_for_unassignment'
		SELECT * FROM #temp_deals_for_unassignment
	END
	
	SET @bank_assignment = 5149  
	  
	CREATE TABLE #temp_assign2 (  
		source_deal_detail_id INT,  
		cert_from INT,  
		cert_to INT,  
		assignment_type INT
	)  
	
	CREATE TABLE #temp_cert2 (  
		source_deal_header_id INT,  
		certificate_number_from_int INT,  
		certificate_number_to_int INT  
	)  
	  
	INSERT #temp_cert2  
	SELECT gis.source_deal_header_id, gis.certificate_number_from_int, gis.certificate_number_to_int   
	FROM gis_certificate gis
	INNER JOIN #temp_deals_for_unassignment tds ON tds.source_deal_detail_id = gis.source_deal_header_id
	
	DECLARE cursor1 CURSOR FOR  
	SELECT source_deal_header_id, certificate_number_from_int, certificate_number_to_int 
	FROM #temp_cert2 
	  
	OPEN cursor1  
	FETCH NEXT FROM cursor1 INTO @gis_deal_id, @certificate_f, @certificate_t  
	   
	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		DECLARE cursor2 CURSOR FOR   
		SELECT cert_from, cert_to 
		FROM assignment_audit 
		WHERE source_deal_header_id_from = @gis_deal_id AND assigned_volume > 0  
		ORDER BY cert_from
		
		OPEN cursor2  
		FETCH NEXT FROM cursor2 INTO @cert_from_f, @cert_to_t  
		WHILE @@FETCH_STATUS = 0  
		BEGIN  
			IF @cert_from_f > @certificate_f   
			BEGIN  
				INSERT #temp_assign2 (source_deal_detail_id, cert_from, cert_to, assignment_type)  
				VALUES (@gis_deal_id, @certificate_f, @cert_from_f - 1, @bank_assignment)  
			END  

			SET @certificate_f = @cert_to_t + 1  

			FETCH NEXT FROM cursor2 INTO @cert_from_f, @cert_to_t  
		END  
		IF (@certificate_f - 1) < @certificate_t  
		BEGIN  
			INSERT #temp_assign2 (source_deal_detail_id, cert_from, cert_to, assignment_type) 
			VALUES (@gis_deal_id, @certificate_f, @certificate_t, @bank_assignment)  
		END  
		FETCH NEXT FROM cursor1 INTO @gis_deal_id,@certificate_f,@certificate_t  
		
		CLOSE cursor2  
		DEALLOCATE cursor2   
	 END   
	CLOSE cursor1  
	DEALLOCATE cursor1   
	   
	IF OBJECT_ID('tempdb..#temp_final3') IS NOT NULL
		DROP TABLE #temp_final3
	  
	CREATE TABLE #temp_final3 (  
		[ID] INT IDENTITY,  
		source_deal_detail_id INT,  
		cert_From INT,  
		cert_to INT,  
		assignment_type INT,  
		volume NUMERIC(38, 20)   
	)

	INSERT INTO #temp_final3(source_deal_detail_id, cert_from, cert_to, assignment_type, volume)  
	SELECT source_deal_detail_id, cert_from, cert_to, assignment_type, (cert_to - cert_from + 1) AS volume
	FROM (  
		SELECT source_deal_detail_id, cert_from, cert_to, assignment_type FROM #temp_assign2  
		UNION ALL  
		SELECT source_deal_header_id_from, cert_from, cert_to, assignment_type FROM assignment_audit  
	) a 
	--ORDER BY a.source_deal_detail_id, a.cert_from  
	
	IF @debug = 1
	BEGIN
		SELECT '#temp_final3'
		SELECT * FROM #temp_final3
	END

	IF OBJECT_ID('tempdb..#temp_final4') IS NOT NULL
		DROP TABLE #temp_final4
	  
	SELECT [ID], source_deal_detail_id, cert_from, cert_to, assignment_type, a.volume,volume_cumu, vol_to_be_assigned AS volume_left 
	INTO #temp_final4 
	FROM  
	(  
		SELECT b.[ID], b.source_deal_detail_id, cert_from, cert_to,assignment_type, a.volume
		, (
			SELECT SUM(volume) 
			FROM #temp_final3 
			WHERE [ID] <= a.[ID] --and assignment_type = @assignment_type  
				AND source_deal_detail_id = a.source_deal_detail_id
		  ) AS volume_cumu
		, b.assigned_volume vol_to_be_assigned
		FROM #temp_final3 a
		INNER JOIN #temp_deals_for_unassignment b ON a.source_deal_detail_id = b.source_deal_detail_id 
		WHERE 1 = 1 --assignment_type = @assignment_type   
	) a  
	WHERE ROUND((CASE WHEN volume_cumu - vol_to_be_assigned <= 0 THEN volume ELSE    
	volume - (volume_cumu - vol_to_be_assigned) END), @vol_rounding) > 0    
	  
	IF OBJECT_ID('tempdb..#temp_include2') IS NOT NULL
		DROP TABLE #temp_include2

	CREATE TABLE #temp_include2    
	( 
		id INT,    
		deal_id INT,    
		volume_assign NUMERIC(38, 20),      
		--bonus NUMERIC(38, 20),      
		volume NUMERIC(38, 20),    
		volume_left NUMERIC(38, 20)
	)     
	
	   
	INSERT INTO #temp_include2    
	SELECT id,source_deal_header_id, vol_to_be_assigned AS volume_assign    
	,  
	--CASE WHEN [target] = 0 OR [target] - volume_left_cumu <= 0 THEN
	 a.volume_left
	--	 else    
	--volume_left-([target] - volume_left_cumu) end  
	AS volume,  
	--CASE WHEN [target] = 0 OR [target] - volume_left_cumu <=0 then 
	a.volume_left
	--else  
	 --[target]  -	volume_left
	--volume_left1-(volume_left-([target] - volume_left_cumu))/(1+bonus_per)
	--END
	AS volume_left
	FROM
	(
		SELECT id, source_deal_header_id, assigned_volume volume, assigned_volume volume_left
		, assigned_volume volume_left1, assigned_volume vol_to_be_assigned
		, (
			SELECT SUM(assigned_volume) volume_left
			FROM #temp_deals_for_unassignment WHERE id <= a.id
			) AS volume_left_cumu    
	FROM     
	#temp_deals_for_unassignment a    
	) a     
	WHERE  1=1 
	
	IF @table_name IS NULL OR @table_name = ''    
		SET @table_name = dbo.FNAProcessTableName('recassign_', dbo.FNADBUser(), dbo.FNAGetNewID())   
		
	IF @debug = 1
	BEGIN
		SELECT '#temp_include2'
		SELECT * FROM #temp_include2
	END
	
						 
	SET @sql = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) row_unique_id, tds.source_deal_detail_id [ID], tds.source_deal_header_id [Deal ID], dbo.FNADateFormat(sdh.deal_date) deal_date,
	dbo.FNADateFormat(sdd.term_start) [Vintage], dbo.FNADateFormat(sdd.contract_expiration_date) expiration, sdv_jurisdiction.code jurisdiction, 
	sdv_gen.code [Gen State], rg.name [Generator],
	COALESCE(Conv1.curve_label,Conv5.curve_label,Conv2.curve_label,Conv3.curve_label,Conv4.curve_label, spcd.curve_name) obligation,
	sc.counterparty_name [Counterparty], tds.assigned_volume  [Volume Left], su.uom_name [UOM], sdd.fixed_price,
	tds.assigned_volume [Volume Unassign], tds.assigned_volume [Total Volume],  
	dbo.FNACertificateRule(cr.cert_rule,rg.[ID],'+CASE WHEN @cert_from IS NOT NULL THEN CAST(@cert_from AS VARCHAR) 
	ELSE ' COALESCE(tf.cert_from,assign1.assigned_volume+gis.certificate_number_from_int,gis.certificate_number_from_int)' END+' ,sdd.term_start) as  [Cert # From], 
	dbo.FNACertificateRule(cr.cert_rule,rg.[ID],'+CASE WHEN @cert_from IS NOT NULL THEN CAST(@cert_to AS VARCHAR) ELSE   
	'ISNULL(CASE WHEN tf.cert_from is not null and tf.volume_left<0 then round(tf.volume-b.volume_left,0)+tf.cert_from-1 else round(tf.volume-b.volume_Left,0)+tf.cert_from-1 end ,  
	ISNULL((assign1.assigned_volume-1+b.volume_assign),b.volume_assign-1)+gis.certificate_number_from_int)' END +' ,sdd.term_start) as  [Cert # T0],  
	'+CASE WHEN @cert_from IS NOT NULL THEN CAST(@cert_from AS VARCHAR) 
	ELSE '  COALESCE(tf.cert_from,assign1.assigned_volume+gis.certificate_number_from_int,gis.certificate_number_from_int) ' END +' as cert_from,'  
	 +CASE WHEN @cert_from IS NOT NULL THEN CAST(@cert_to AS VARCHAR)
	  ELSE '  ISNULL(CASE WHEN tf.cert_from is not null and tf.volume_left<0 then round(tf.volume-b.volume_left,0)+tf.cert_from-1 else round(tf.volume-b
	.volume_Left,0)+tf.cert_from-1 end ,  
	  ISNULL((assign1.assigned_volume-1+b.volume_assign),b.volume_assign)+gis.certificate_number_from_int) ' END +' as cert_to, 
	sdh.compliance_year, tds.tier [tier_value_id]--, ISNULL(tp.min_target, tp.max_target) target, tp.total_target
	, rg.gen_state_value_id, sdv_tech.code [Technology], sdv_tier.code [Tier], sdh.state_value_id, assign.assignment_id [Assign_id], assign.assigned_volume
	--select *
	INTO ' + @table_name + '
	FROM #temp_deals_for_unassignment tds
	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = tds.source_deal_header_id
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN #temp_include2 b ON tds.id = b.id  
	LEFT JOIN rec_generator rg ON sdh.generator_id = rg.generator_id
		--AND tds.gen_state_value_id = rg.gen_state_value_id
		--AND tds.technology = rg.technology
	LEFT JOIN static_data_value sdv_tier ON sdv_tier.value_id = tds.tier
	LEFT JOIN static_data_value sdv_tech ON sdv_tech.value_id = rg.technology
	LEFT JOIN static_data_value sdv_jurisdiction ON sdv_jurisdiction.value_id = sdh.state_value_id
	LEFT JOIN static_data_value sdv_gen ON sdv_gen.value_id =  rg.gen_state_value_id
	LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id 
	LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id 
	LEFT JOIN assignment_audit assign ON tds.source_deal_detail_id = assign.source_deal_header_id 
	LEFT JOIN source_uom su ON su.source_uom_id = sdd.deal_volume_uom_id	
	LEFT JOIN static_data_value state ON state.value_id = ISNULL(assign.state_value_id,rg.state_value_id) 
	LEFT JOIN rec_volume_unit_conversion Conv1 ON            
	 conv1.from_source_uom_id  = sdd.deal_volume_uom_id             
		AND conv1.to_source_uom_id = ' + ISNULL(CAST(@convert_uom_id as varchar),'NULL') +'           
		And conv1.state_value_id = state.value_id
		AND conv1.assignment_type_value_id = ' + cast(@assignment_type as varchar) + ' 
		AND conv1.curve_id = spcd.source_curve_def_id             
		AND conv1.to_curve_id IS NULL
	LEFT JOIN rec_volume_unit_conversion Conv2 ON            
	 conv2.from_source_uom_id = su.source_uom_id              
		AND conv2.to_source_uom_id = ' + ISNULL(CAST(@convert_uom_id as varchar),'NULL') +'        
		And conv2.state_value_id IS NULL
		AND conv2.assignment_type_value_id = ' + cast(@assignment_type as varchar) + '  
		AND conv2.curve_id = spcd.source_curve_def_id  
		AND conv2.to_curve_id IS NULL
	LEFT JOIN rec_volume_unit_conversion Conv3 ON            
	conv3.from_source_uom_id =  su.source_uom_id             
		AND conv3.to_source_uom_id = ' + ISNULL(CAST(@convert_uom_id as varchar),'NULL') +'           
		And conv3.state_value_id IS NULL
		AND conv3.assignment_type_value_id IS NULL
		AND conv3.curve_id = spcd.source_curve_def_id  
		AND conv3.to_curve_id IS NULL
	LEFT JOIN rec_volume_unit_conversion Conv4 ON            
	 conv4.from_source_uom_id = su.source_uom_id
		AND conv4.to_source_uom_id = ' + ISNULL(CAST(@convert_uom_id as varchar),'NULL') +'         
		And conv4.state_value_id IS NULL
		AND conv4.assignment_type_value_id IS NULL
		AND conv4.curve_id IS NULL
		AND conv4.to_curve_id IS NULL
	LEFT JOIN rec_volume_unit_conversion Conv5 ON            
	 conv5.from_source_uom_id  = su.source_uom_id             
		AND conv5.to_source_uom_id = ' + ISNULL(CAST(@convert_uom_id as varchar),'NULL') +'         
		And conv5.state_value_id = state.value_id
		AND conv5.assignment_type_value_id is null
		AND conv5.curve_id = spcd.source_curve_def_id 
		AND conv5.to_curve_id IS NULL
	LEFT JOIN #temp_final4 tf ON tf.source_deal_detail_id = tds.source_deal_detail_id
	LEFT JOIN certificate_rule cr ON isnull(rg.gis_value_id, 5164) = cr.gis_id
	LEFT JOIN        
		(
			SELECT source_deal_header_id_from,sum(assigned_volume) assigned_volume from         
			assignment_audit group by source_deal_header_id_from
		) assign1        
		ON assign1.source_deal_header_id_from=tds.source_deal_detail_id 
	LEFT JOIN #temp_cert2 gis ON gis.source_deal_header_id = tds.source_deal_header_id  
	'
		
	--PRINT @sql
	EXEC(@sql)
	
	SET @sql = 'SELECT ''' + @table_name + ''' [Process Table], [Assign_id], row_unique_id, [ID] [Detail ID]
				, [Deal ID], deal_date [Deal Date], Vintage, Expiration 
				, Jurisdiction, Technology, [Gen State], Generator, obligation [Env Product], Counterparty
				, dbo.FNARemoveTrailingZero(ROUND(CAST(assigned_volume AS NUMERIC(38, 20)), ' + CAST(@vol_rounding AS VARCHAR(2)) + ')) AS [Assigned Volume]
				, dbo.FNARemoveTrailingZero(ROUND(CAST([Volume UNassign] AS NUMERIC(38, 20)), ' + CAST(@vol_rounding AS VARCHAR(2)) + ')) [Unassign Volume]
				, dbo.FNARemoveTrailingZero(ROUND(CAST(assigned_volume AS NUMERIC(38, 20)), ' + CAST(@vol_rounding AS VARCHAR(2)) + ')) [Total Volume]
				, UOM
				' + CASE WHEN @assignment_type <> 5173 THEN '
				, tier AS [Unassigned To Tier]
				, dbo.FNARemoveTrailingZero(ROUND(fixed_price, ' + CAST(@vol_rounding AS VARCHAR(2)) + ')) [Price]'
				ELSE '' END + '
				' + @str_batch_table + '
	            FROM	            
	             ' + @table_name + ' a'   
	
	--PRINT @sql
	EXEC(@sql)
	
	
	/*******************************************2nd Paging Batch START**********************************************/
 
	--update time spent and batch completion message in message board
	IF @is_batch = 1
	BEGIN
	   SELECT @sql_paging = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
	   EXEC(@sql_paging)
	 
	   --TODO: modify sp and report name
	   SELECT @sql_paging = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_find_assignment_rec_deals', 'Run Assignment logic')
	   EXEC(@sql_paging)  
	 
	   RETURN
	END
	 
	--if it is first call from paging, return total no. of rows and process id instead of actual data
	IF @enable_paging = 1 AND @page_no IS NULL
	BEGIN
	   SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
	   EXEC(@sql_paging)
	END
END
ELSE
 
BEGIN


	IF OBJECT_ID('tempdb..#temp_tier_type') IS NOT NULL
		DROP TABLE #temp_tier_type
	
	CREATE TABLE #temp_deals  
	 (   
	 	  id INT IDENTITY(1, 1),
		  priority INT,	 
		  source_deal_header_id INT,    
		  source_deal_detail_id INT,  
		  deal_date DATETIME,    
		  gen_date DATETIME,    
		  source_curve_def_id INT,  
		  counterparty_id INT,  
		  generator_id INT,  
		  jurisdiction_state_id INT,  
		  gen_state_value_id INT,  
		  price NUMERIC(38, 20),    
		  volume NUMERIC(38, 20),    
		  bonus NUMERIC(38, 20),    
		  expiration VARCHAR(30) COLLATE DATABASE_DEFAULT,    
		  uom_id INT,  
		  volume_left NUMERIC(38, 20),
		  vol_to_be_assigned NUMERIC(38, 20),  
		  ext_deal_id INT,  --TODO: check if it is really needed 
		  conv_factor NUMERIC(38, 20),  
		  expiration_date DATETIME,  
		  assigned_date DATETIME,  
		  status_value_id INT,  
		  term_start DATETIME,
		  technology INT,
		  product INT,
		  compliance_year INT
	 )    
    
  
	--******************************************************    
	-- Collect Eligible Deals  
	--******************************************************    
		  
	IF @debug = 1  
	BEGIN  
		SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)  
		SET @log_increment = @log_increment + 1  
		SET @log_time=GETDATE()  
		PRINT @pr_name+' Running..............'  
	END  
	
	IF OBJECT_ID('tempdb..#temp_filtered_recs_with_tier') IS NOT NULL DROP TABLE #temp_filtered_recs_with_tier
	
	--Create a set of filtered deals with tier which can be used for both #temp_filtered_recs and #temp_tier_type
	CREATE TABLE #temp_filtered_recs_with_tier (   
		source_deal_header_id		INT
		, deal_date					DATETIME
		, counterparty_id			INT
		, status_value_id			INT
		, assignment_type_value_id	INT
		, state_value_id			INT  
		, gen_state_value_id		INT
		, technology				INT
		, generator_id				INT
		, tier_type					INT
	)
	
	--select @assigned_state
	
	INSERT INTO #temp_filtered_recs_with_tier (
			source_deal_header_id		
			, deal_date					
			, counterparty_id			
			, status_value_id	
			, generator_id			
			, assignment_type_value_id	
			, state_value_id			
			, gen_state_value_id		
			, technology				
			, tier_type		
		)
	SELECT 
			a.source_deal_header_id
			, a.deal_date
			, a.counterparty_id
			, ISNULL(a.status_value_id, 5171) status_value_id
			, a.generator_id
			, @assignment_type assignment_type_value_id
			, @assigned_state state_value_id
			, a.gen_state_value_id
			, a.technology
			, a.tier_type
	FROM
	(
		SELECT sdh.source_deal_header_id  -- First find deals with their tiers that fall under the gis_certificate criteria
		, sdh.deal_date
		, sdh.counterparty_id
		, ISNULL(sdh.status_value_id, 5171) status_value_id
		, sdh.generator_id
		, rg.gen_state_value_id
		, rg.technology
		, gc.tier_type
		FROM state_rec_requirement_data srrd 
		INNER JOIN state_rec_requirement_detail srrde ON srrde.state_value_id = srrd.state_value_id
			AND srrd.assignment_type_id = srrde.assignment_type_id
			--AND srrd.from_month = srrde.from_month
			--AND srrd.to_month = srrde.to_month
			AND srrd.state_value_id = @assigned_state
			AND srrd.assignment_type_id =  @assignment_type 
			AND @compliance_year BETWEEN srrd.from_year AND srrd.to_year
		INNER JOIN gis_certificate gc ON gc.state_value_id = srrd.state_value_id
			AND gc.tier_type = ISNULL(srrde.tier_type,'-1')
		INNER JOIN source_deal_detail sdd ON gc.source_deal_header_id = sdd.source_deal_detail_id
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
		INNER JOIN #ssbm ssbm ON sdh.source_system_book_id1 = ssbm.source_system_book_id1    
			AND sdh.source_system_book_id2 = ssbm.source_system_book_id2  
			AND sdh.source_system_book_id3 = ssbm.source_system_book_id3     
			AND sdh.source_system_book_id4 = ssbm.source_system_book_id4
		INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		WHERE ssbm.fas_deal_type_value_id <> 405	--exclude target deals  
			AND ISNULL(sdh.status_value_id, 5171) NOT IN (5170, 5179)     
			AND sdh.deal_date <= CONVERT(NVARCHAR(10), @assigned_date, 20)  
		
		UNION 
		
		SELECT sdh.source_deal_header_id    -- find deals that fall under criteria of generator
		, sdh.deal_date
		, sdh.counterparty_id
		, ISNULL(sdh.status_value_id, 5171) status_value_id
		, sdh.generator_id
		, rg.gen_state_value_id
		, rg.technology
		, srrde.tier_type
		--select *
		FROM state_rec_requirement_data srrd 
		INNER JOIN state_rec_requirement_detail srrde ON srrde.state_value_id = srrd.state_value_id
			AND srrd.assignment_type_id = srrde.assignment_type_id
			--AND srrd.from_month = srrde.from_month
			--AND srrd.to_month = srrde.to_month
			AND srrd.state_value_id = @assigned_state 
			AND srrd.assignment_type_id =  @assignment_type
			AND @compliance_year BETWEEN srrd.from_year AND srrd.to_year
		INNER JOIN rec_generator rg ON rg.tier_type = srrde.tier_type
		INNER JOIN source_deal_header sdh ON sdh.generator_id = rg.generator_id
			AND sdh.source_deal_header_id 
			NOT IN (
			SELECT ISNULL(sdh2.source_deal_header_id,-1) source_deal_header_id_sdh 
				FROM gis_certificate gc 
				INNER JOIN source_deal_detail sdd2 ON gc.source_deal_header_id = sdd2.source_deal_detail_id
				INNER JOIN source_deal_header sdh2 ON sdh2.source_deal_header_id = sdd2.source_deal_header_id
				INNER JOIN #ssbm ssbm2 ON sdh2.source_system_book_id1 = ssbm2.source_system_book_id1    
					AND sdh2.source_system_book_id2 = ssbm2.source_system_book_id2  
					AND sdh2.source_system_book_id3 = ssbm2.source_system_book_id3     
					AND sdh2.source_system_book_id4 = ssbm2.source_system_book_id4
				WHERE gc.state_value_id = @assigned_state --and gc.tier_type  = 300747
					AND sdh2.source_deal_header_id is not null
					AND ssbm2.fas_deal_type_value_id <> 405
			)
			--<> ISNULL(gc.source_deal_header_id_sdh,-1)
		INNER JOIN #ssbm ssbm ON sdh.source_system_book_id1 = ssbm.source_system_book_id1    
			AND sdh.source_system_book_id2 = ssbm.source_system_book_id2  
			AND sdh.source_system_book_id3 = ssbm.source_system_book_id3     
			AND sdh.source_system_book_id4 = ssbm.source_system_book_id4
		WHERE ssbm.fas_deal_type_value_id <> 405	--exclude target deals 
			--AND sdh2.source_deal_header_id IS NULL
			AND ISNULL(sdh.status_value_id, 5171) NOT IN (5170, 5179)     
			AND ISNULL(rg.exclude_inventory, 'n') = 'n' 
			AND sdh.deal_date <= CONVERT(NVARCHAR(10), @assigned_date, 20)
		
		UNION 
		
		SELECT sdh.source_deal_header_id  -- find the deals that fall under the eligibility criteria
		, sdh.deal_date
		, sdh.counterparty_id
		, ISNULL(sdh.status_value_id, 5171) status_value_id
		, sdh.generator_id
		, rg.gen_state_value_id
		, rg.technology
		, rge.tier_type
		FROM state_rec_requirement_data srrd 
		INNER JOIN state_rec_requirement_detail srrde ON srrde.state_value_id = srrd.state_value_id
			AND srrd.assignment_type_id = srrde.assignment_type_id
			--AND srrd.from_month = srrde.from_month
			--AND srrd.to_month = srrde.to_month
			AND srrd.state_value_id = @assigned_state 
			AND srrd.assignment_type_id =  @assignment_type 
			AND @compliance_year BETWEEN srrd.from_year AND srrd.to_year
		OUTER APPLY	
		(
		 SELECT gc.*, sdh2.source_deal_header_id source_deal_header_id_sdh 
			FROM gis_certificate gc 
			INNER JOIN source_deal_detail sdd2 ON gc.source_deal_header_id = sdd2.source_deal_detail_id
			INNER JOIN source_deal_header sdh2 ON sdh2.source_deal_header_id = sdd2.source_deal_header_id
			INNER JOIN #ssbm ssbm2 ON sdh2.source_system_book_id1 = ssbm2.source_system_book_id1    
				AND sdh2.source_system_book_id2 = ssbm2.source_system_book_id2  
				AND sdh2.source_system_book_id3 = ssbm2.source_system_book_id3     
				AND sdh2.source_system_book_id4 = ssbm2.source_system_book_id4
			WHERE gc.state_value_id = @assigned_state --and gc.tier_type  = 300747
				AND sdh2.source_deal_header_id is not null
				AND ssbm2.fas_deal_type_value_id <> 405
		) gc 
		OUTER APPLY	(
					SELECT rg.*,sdh.source_deal_header_id 
						FROM rec_generator rg 
						INNER JOIN source_deal_header sdh ON sdh.generator_id = rg.generator_id
						WHERE rg.tier_type = srrde.tier_type
					) rg_filter
		INNER JOIN
		(
			SELECT DISTINCT state_value_id, assignment_type, gen_state_value_id, technology, tier_type
			FROM rec_gen_eligibility
			WHERE state_value_id = @assigned_state 
				AND @compliance_year BETWEEN from_year AND to_year 
				AND assignment_type = @assignment_type 
		) rge ON rge.state_value_id = srrd.state_value_id
		INNER JOIN rec_generator rg ON rg.gen_state_value_id = rge.gen_state_value_id
			AND rg.technology = rge.technology
		INNER JOIN source_deal_header sdh ON sdh.generator_id = rg.generator_id
			AND sdh.source_deal_header_id NOT IN 
			(
				SELECT  ISNULL(sdh2.source_deal_header_id,-1) source_deal_header_id_sdh 
				FROM gis_certificate gc 
				INNER JOIN source_deal_detail sdd2 ON gc.source_deal_header_id = sdd2.source_deal_detail_id
				INNER JOIN source_deal_header sdh2 ON sdh2.source_deal_header_id = sdd2.source_deal_header_id
				INNER JOIN #ssbm ssbm2 ON sdh2.source_system_book_id1 = ssbm2.source_system_book_id1    
					AND sdh2.source_system_book_id2 = ssbm2.source_system_book_id2  
					AND sdh2.source_system_book_id3 = ssbm2.source_system_book_id3     
					AND sdh2.source_system_book_id4 = ssbm2.source_system_book_id4
				WHERE gc.state_value_id = @assigned_state --and gc.tier_type  = 300747
					AND sdh2.source_deal_header_id is not null
					AND ssbm2.fas_deal_type_value_id <> 405
			)
			AND sdh.source_deal_header_id NOT IN 
			(
				SELECT ISNULL(sdh.source_deal_header_id ,-1) source_deal_header_id
				FROM rec_generator rg 
				INNER JOIN source_deal_header sdh ON sdh.generator_id = rg.generator_id
				WHERE rg.tier_type = srrde.tier_type
			)
		INNER JOIN #ssbm ssbm ON sdh.source_system_book_id1 = ssbm.source_system_book_id1    
			AND sdh.source_system_book_id2 = ssbm.source_system_book_id2  
			AND sdh.source_system_book_id3 = ssbm.source_system_book_id3     
			AND sdh.source_system_book_id4 = ssbm.source_system_book_id4
		LEFT JOIN state_properties sp ON sp.state_value_id = rge.state_value_id
		WHERE ssbm.fas_deal_type_value_id <> 405	--exclude target deals     
			--AND ISNULL(sdh.assignment_type_value_id, 5149) = 5149   
			AND ISNULL(sp.begin_date, sdh.deal_date) <= sdh.deal_date   
			AND ISNULL(sdh.status_value_id, 5171) NOT IN (5170, 5179)     
			AND ISNULL(rg.exclude_inventory, 'n') = 'n' 
			AND sdh.deal_date <= CONVERT(NVARCHAR(10), @assigned_date, 20)   
	) a
		
	
		--select * from #temp_filtered_recs_with_tier
	
	--TODO: Remove extra joins repeated in temporary table and main query
	IF OBJECT_ID('tempdb..#temp_filtered_recs') IS NOT NULL DROP TABLE #temp_filtered_recs
	
	CREATE TABLE #temp_filtered_recs (
		source_deal_header_id		INT
		, deal_date					DATETIME
		, counterparty_id			INT
		, status_value_id			INT
		, assignment_type_value_id	INT
		, state_value_id			INT  
		, gen_state_value_id		INT
		, technology				INT
		, generator_id				INT
		, gen_offset_technology		CHAR(1) COLLATE DATABASE_DEFAULT
		, source_curve_def_id		INT
		, exclude_inventory			VARCHAR(1) COLLATE DATABASE_DEFAULT
		, udf_group1				INT
		, udf_group2				INT
		, udf_group3				INT	
	)
	 
		INSERT INTO #temp_filtered_recs (
			source_deal_header_id		
			, deal_date					
			, counterparty_id			
			, status_value_id	
			, generator_id			
			, assignment_type_value_id	
			, state_value_id			
			, gen_state_value_id		
			, technology				
			, gen_offset_technology		
			, source_curve_def_id		
			, exclude_inventory			
			, udf_group1				
			, udf_group2				
			, udf_group3				
		)
		SELECT 
			tfrwt.source_deal_header_id
			, MAX(tfrwt.deal_date) deal_date
			, MAX(tfrwt.counterparty_id) counterparty_id
			, MAX(ISNULL(tfrwt.status_value_id, 5171)) status_value_id
			, MAX(tfrwt.generator_id) generator_id
			, @assignment_type assignment_type_value_id
			, @assigned_state state_value_id
			, MAX(tfrwt.gen_state_value_id) gen_state_value_id
			, MAX(tfrwt.technology) technology
			, MAX(rg.gen_offset_technology) gen_offset_technology
			, MAX(rg.source_curve_def_id) source_curve_def_id
			, MAX(rg.exclude_inventory) exclude_inventory
			, MAX(rg.udf_group1) udf_group1
			, MAX(rg.udf_group2) udf_group2
			, MAX(rg.udf_group3) udf_group3
		FROM #temp_filtered_recs_with_tier tfrwt 
		INNER JOIN rec_generator rg ON rg.generator_id = tfrwt.generator_id
		GROUP BY source_deal_header_id
		
	CREATE NONCLUSTERED INDEX [IX_tfr_] ON [dbo].[#temp_filtered_recs] ([state_value_id])
		INCLUDE ([source_deal_header_id], [deal_date], [counterparty_id], [status_value_id], [gen_state_value_id], [technology], [generator_id], [gen_offset_technology], [source_curve_def_id])
  
	
	
	IF @debug = 1
	BEGIN
		SELECT '#temp_filtered_recs'
		SELECT * FROM #temp_filtered_recs
	END
	
		--select * from #bonus
	
	--Collect eligible deals
	SET @sql_stmt =     
		'  
		INSERT INTO #temp_deals(
			source_deal_header_id,    
			source_deal_detail_id,  
			deal_date,    
			gen_date,    
			source_curve_def_id,  
			counterparty_id,  
			generator_id,  
			jurisdiction_state_id,  
			gen_state_value_id,  
			price,    
			volume,    
			bonus,    
			uom_id,  
			volume_left,
			conv_factor,  
			expiration_date,  
			status_value_id,  
			term_start,
			technology,
			product,
			compliance_year
		)    
		SELECT 
		tfr.source_deal_header_id,  
		sdd.source_deal_detail_id,    
		tfr.deal_date,     
		sdd.term_start gen_date,    
		sdd.curve_id AS source_curve_def_id,    
		tfr.counterparty_id AS counterparty_id,  
		tfr.generator_id AS generator_id,  
		tfr.state_value_id,  
		tfr.gen_state_value_id,  
		ISNULL(CAST(sdd.fixed_price as NUMERIC(38,20)), 0) AS price,   
		sdd.deal_volume * rs_cf.conversion_factor AS volume,    
		ISNULL(bns.bonus_per, 0)/100 * sdd.volume_left * rs_cf.conversion_factor bonus,    
		su.source_uom_id AS uom_id,   
		ISNULL(bns.bonus_per, 0)/100 * sdd.volume_left * rs_cf.conversion_factor + sdd.volume_left * rs_cf.conversion_factor AS Volume_left,  
		rs_cf.conversion_factor AS conv_factor,  
		--dbo.FNADEALRECExpirationState(sdd.source_deal_detail_id, sdd.contract_expiration_date, ' + CAST(@assignment_type AS VARCHAR) + ',tfr.state_value_id) expiration_date,  
		DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,cast((year(sdd.term_start) + 
							CASE WHEN(isnull(tfr.gen_offset_technology, ''n'') = ''n'') THEN 
								ISNULL(spd.duration ,isnull(sp.duration, 0)) 
							ELSE ISNULL(spd.offset_duration ,isnull(sp.offset_duration, 0)) END 
							- 1) AS VARCHAR) 
							+ ''-'' + CAST(isnull(sp.calendar_to_month, 12) as varchar) + ''-01'')+1,0)) expiration_date,
		--sdd.term_start,
		tfr.status_value_id,  
		sdd.term_start,
		tfr.technology,
		tfr.source_curve_def_id,
		' + CAST(@compliance_year AS VARCHAR(4)) + '
		FROM #temp_filtered_recs tfr
		INNER JOIN source_deal_detail sdd ON tfr.source_deal_header_id = sdd.source_deal_header_id 
			AND sdd.buy_sell_flag = ''b''  -- select only buy deals  
		INNER JOIN rec_generator rg ON rg.generator_id = tfr.generator_id
		
		INNER JOIN static_data_value sdv_tech ON sdv_tech.value_id = tfr.technology
		INNER JOIN state_properties sp ON sp.state_value_id = ' + CAST(@assigned_state AS VARCHAR) + '-- tfr.state_value_id 
		INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id       
			--AND tfr.program_scope = spcd.program_scope_value_id  
		LEFT JOIN state_properties_duration spd on spd.state_value_id = sp.state_value_id 
			AND spd.technology = tfr.technology 	
			AND (ISNULL(spd.assignment_type_Value_id, 5149) = ISNULL(NULL, 5149) OR spd.assignment_type_Value_id IS NULL)
		LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = tfr.counterparty_id    
		LEFT JOIN static_data_value state ON state.value_id = tfr.state_value_id  
		LEFT JOIN source_uom su ON su.source_uom_id = sdd.deal_volume_uom_id     
		LEFT JOIN #bonus bns ON bns.state_value_id = sp.state_value_id    
			AND bns.technology = tfr.technology  
			AND ISNULL(bns.assignment_type_value_id, 5149) =  ' + CAST(@assignment_type AS VARCHAR) + '  
			AND sdd.term_start between bns.from_date and bns.to_date  
			AND bns.gen_state_value_id = tfr.gen_state_value_id  '
			
	SET @sql_stmt2 ='
		LEFT JOIN rec_volume_unit_conversion Conv1 ON conv1.from_source_uom_id = sdd.deal_volume_uom_id               
			AND conv1.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id AS VARCHAR),'NULL')+'              
			And conv1.state_value_id = state.value_id  
			AND conv1.assignment_type_value_id = ' + CAST(@assignment_type AS VARCHAR) + '    
			AND conv1.curve_id = sdd.curve_id     
			AND conv1.to_curve_id IS NULL        
		LEFT JOIN rec_volume_unit_conversion Conv2 ON conv2.from_source_uom_id = sdd.deal_volume_uom_id   
			AND conv2.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id AS VARCHAR),'NULL')+'              
			And conv2.state_value_id IS NULL  
			AND conv2.assignment_type_value_id = ' + CAST(@assignment_type AS VARCHAR) + '    
			AND conv2.curve_id = sdd.curve_id    
			AND conv2.to_curve_id IS NULL        
		LEFT JOIN rec_volume_unit_conversion Conv3 ON conv3.from_source_uom_id =  sdd.deal_volume_uom_id              
			AND conv3.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id AS VARCHAR),'NULL')+'              
			And conv3.state_value_id IS NULL  
			AND conv3.assignment_type_value_id IS NULL  
			AND conv3.curve_id = sdd.curve_id            
			AND conv3.to_curve_id IS NULL        
		LEFT JOIN rec_volume_unit_conversion Conv4 ON conv4.from_source_uom_id = sdd.deal_volume_uom_id  
			AND conv4.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id AS VARCHAR),'NULL')+'              
			And conv4.state_value_id IS NULL  
			AND conv4.assignment_type_value_id IS NULL  
			AND conv4.curve_id IS NULL  
			AND conv4.to_curve_id IS NULL        
		LEFT JOIN rec_volume_unit_conversion Conv5 ON conv5.from_source_uom_id  = sdd.deal_volume_uom_id                
			AND conv5.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id AS VARCHAR),'NULL')+'              
			And conv5.state_value_id = state.value_id  
			AND conv5.assignment_type_value_id is null  
			AND conv5.curve_id = sdd.curve_id   
			AND conv5.to_curve_id IS NULL
		OUTER APPLY(
		               SELECT CAST(
		                          COALESCE(
		                              conv1.conversion_factor
		                             , conv5.conversion_factor
		                             , conv2.conversion_factor
		                             , conv3.conversion_factor
		                             , conv4.conversion_factor
		                             , 1
		                          ) AS NUMERIC(20, 8)
		                      ) AS conversion_factor
		           ) rs_cf     
		LEFT JOIN gis_certificate gis ON gis.source_deal_header_id = sdd.source_deal_detail_id 
			AND gis.state_value_id = tfr.state_value_id
		LEFT JOIN static_data_value sdv_gen_state ON sdv_gen_state.value_id=tfr.gen_state_value_id  
		WHERE  1 = 1  
			AND sdd.deal_volume >= 0  
			AND sdd.volume_left IS NOT NULL -- select deals having volume available
			AND YEAR(sdd.term_start) <= ' + CAST(@compliance_year AS VARCHAR(10)) + ' 
			AND sdd.term_start <= CASE WHEN (ISNULL(sp.bank_assignment_required, ''n'') = ''n'') THEN CONVERT(NVARCHAR(10), ''' + @assigned_date + ''', 20) ELSE sdd.term_start END 
			
			AND CASE WHEN  ' +ISNULL(CAST(@assignment_type AS VARCHAR),5146) + '=5173 THEN 
	 		--replace FNADEALRECExpirationState with equivalent code (for year only) to gain performance
	 		  YEAR(DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, CAST((YEAR(sdd.term_start) + 
								CASE WHEN(ISNULL(tfr.gen_offset_technology, ''n'') = ''n'') THEN 
									ISNULL(spd.duration, ISNULL(sp.duration, 0)) 
								ELSE ISNULL(spd.offset_duration, ISNULL(sp.offset_duration, 0)) END 
								- 1) AS VARCHAR) 
								+ ''-'' + CAST(ISNULL(sp.calendar_to_month, 12) AS VARCHAR) + ''-01'') + 1, 0))) 
		  
		 
		 ELSE CASE WHEN gis.source_certificate_number IS NOT NULL AND gis.contract_expiration_date IS NOT NULL 
		 THEN  YEAR(gis.contract_expiration_date)
	 		--replace FNADEALRECExpirationState with equivalent code (for year only) to gain performance   
	 	 ELSE YEAR(DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, CAST((YEAR(sdd.term_start) + 
								CASE WHEN(ISNULL(tfr.gen_offset_technology, ''n'') = ''n'') THEN 
									ISNULL(spd.duration, ISNULL(sp.duration, 0)) 
								ELSE ISNULL(spd.offset_duration, ISNULL(sp.offset_duration, 0)) END 
								- 1) AS VARCHAR) 
								+ ''-'' + CAST(isnull(sp.calendar_to_month, 12) AS VARCHAR) + ''-01'') + 1, 0)))  
		 END  END >= ' + CASE WHEN ISNULL(@assignment_type,5146)=5173 THEN  CAST('' + @assigned_date + '' AS VARCHAR)
		 ELSE CAST(@compliance_year AS VARCHAR)  END  
		+ CASE WHEN @deal_id IS NOT NULL THEN ' AND tfr.source_deal_header_id = '+@deal_id 
			ELSE  
			+ CASE WHEN (@curve_id IS NULL) THEN '' ELSE ' AND sdd.curve_id = ' + CAST(@curve_id AS VARCHAR) END     
			+ CASE WHEN (@gen_state IS NULL) THEN '' ELSE ' AND tfr.gen_state_value_id = ' + CAST(@gen_state AS VARCHAR) END    
			+ CASE WHEN (@gen_year IS NULL) THEN '' ELSE ' AND YEAR(sdd.term_start) = ' + CAST(@gen_year AS VARCHAR) END 
			+ CASE WHEN (@gen_date_from IS NULL) THEN '' ELSE ' AND sdd.term_start ' + (CASE WHEN @gen_date_to IS NOT NULL THEN ' >' ELSE '' END) + '= ''' + CONVERT(VARCHAR(10), @gen_date_from, 120) + '''' END 
			+ CASE WHEN (@gen_date_to IS NULL) THEN '' ELSE ' AND sdd.term_start ' + (CASE WHEN @gen_date_from IS NOT NULL THEN ' <' ELSE '' END) + '= ''' + CONVERT(VARCHAR(10), @gen_date_to, 120) + '''' END
			+ CASE WHEN (@generator_id IS NULL) THEN '' ELSE ' AND tfr.generator_id = ' + CAST(@generator_id AS VARCHAR) END    
			+ CASE WHEN (@counterparty_id IS NULL) THEN '' ELSE ' AND tfr.counterparty_id = ' + CAST(@counterparty_id AS VARCHAR) END    
			+ CASE WHEN @udf_group1 IS NOT NULL THEN ' AND tfr.udf_group1='+CAST(@udf_group1 AS VARCHAR) ELSE '' END  
			+ CASE WHEN @udf_group2 IS NOT NULL THEN ' AND tfr.udf_group2='+CAST(@udf_group2 AS VARCHAR) ELSE '' END  
			+ CASE WHEN @udf_group3 IS NOT NULL THEN ' AND tfr.udf_group3='+CAST(@udf_group3 AS VARCHAR) ELSE '' END  
			--+ CASE WHEN @tier_type IS NOT NULL THEN ' AND tfr.tier_type='+CAST(@tier_type AS VARCHAR) ELSE '' END  
			+ CASE WHEN @program_scope IS NOT NULL THEN ' AND spcd.program_scope_value_id = ' + CAST(@program_scope AS VARCHAR) ELSE '' END  
		  END  
		  
		  	 --+ CASE WHEN  ISNULL(@assignment_type,5146)=5173 THEN 
	 	--	--replace FNADEALRECExpirationState with equivalent code (for year only) to gain performance
	 	--	' AND DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, CAST((YEAR(sdd.term_start) + 
			--					CASE WHEN(ISNULL(tfr.gen_offset_technology, ''n'') = ''n'') THEN 
			--						ISNULL(spd.duration, ISNULL(sp.duration, 0)) 
			--					ELSE ISNULL(spd.offset_duration, ISNULL(sp.offset_duration, 0)) END 
			--					- 1) AS VARCHAR) 
			--					+ ''-'' + CAST(ISNULL(sp.calendar_to_month, 12) AS VARCHAR) + ''-01'') + 1, 0)) >= CAST(''' + @assigned_date + ''' AS DATETIME)'  
		  --' AND dbo.FNADEALRECExpirationState(sdd.source_deal_detail_id, sdd.contract_expiration_date, ' + CAST(@assignment_type AS VARCHAR) + ', tfr.state_value_id) >= CAST(''' + @assigned_date + ''' AS DATETIME) '  
	   --PRINT @sql_Stmt + @sql_stmt2
	IF @debug = 1  PRINT @sql_Stmt + @sql_stmt2
	EXEC (@sql_Stmt + @sql_stmt2)    

	IF @debug = 1
	BEGIN
		select * from #bonus
		SELECT '#temp_deals'
		SELECT * FROM #temp_deals ORDER BY priority, source_deal_header_id
	END
	 
	--CREATE INDEX [IX_td1] ON [#temp_deals]([source_deal_header_id])          
	--CREATE INDEX [IX_td2] ON [#temp_deals]([generator_id])          
	--CREATE INDEX [IX_td3] ON [#temp_deals]([term_start])
	--CREATE INDEX [IX_temp_deals_id] ON [#temp_deals](id)
	CREATE INDEX [IX_td_tech_state] ON #temp_deals (technology, gen_state_value_id)
	CREATE INDEX [IX_td_priority] ON #temp_deals (priority) INCLUDE (volume_left) 
		   
	IF @debug = 1  
	BEGIN  
		PRINT @pr_name + ': ' + CAST(DATEDIFF(ss,@log_time,GETDATE()) AS VARCHAR) +'*************************************'  
		PRINT '**************** End of Eligible Deal Collection *****************************'   
	END  

	--******************************************************    
	-- Sort the Deals based ON the Priority Group  
	--******************************************************    
	IF @debug = 1  
	BEGIN  
		SET @pr_name= 'sql_log_' + CAST(@log_increment AS VARCHAR)  
		SET @log_increment = @log_increment + 1  
		SET @log_time=GETDATE()  
		PRINT @pr_name+' Running..............'  
	END 
	
	--select * from #temp_deals

	--Prepare the priority order in a variable
	DECLARE @priority_order_by VARCHAR(1000)
	SELECT @priority_order_by = STUFF((
		SELECT ', ' + (CASE rapd.priority_type 
					--IMP: Make sure alias and column name match with the dataset
					WHEN 21000 THEN 'MAX(td.price)' + (CASE MAX(rapo.cost_order_type) WHEN 21000 THEN ' DESC' ELSE ' ASC' END)					--Cost
					WHEN 21100 THEN 'MAX(td.term_start)' + (CASE MAX(rapo.vintage_order_type) WHEN 21100 THEN ' ASC' ELSE ' DESC' END)			--Vintage
					--IMP: if priority is not defined for some products, put it into the last by putting largest INT value. Otherwise 
					--rapo_prd.order_number will be NULL and put first in the priority
					WHEN 20900 THEN 'ISNULL(MIN(rapo_prd.order_number), 2147483647) ASC'															--Product
				END) 																
		FROM rec_assignment_priority_order rapo
		INNER JOIN rec_assignment_priority_detail rapd ON rapd.rec_assignment_priority_detail_id = rapo.rec_assignment_priority_detail_id
		INNER JOIN rec_assignment_priority_group rapg ON rapg.rec_assignment_priority_group_id = rapd.rec_assignment_priority_group_id
		INNER JOIN state_rec_requirement_data srrd ON srrd.rec_assignment_priority_group_id = rapg.rec_assignment_priority_group_id
		WHERE srrd.state_value_id = @assigned_state
			AND @compliance_year BETWEEN srrd.from_year AND srrd.to_year
			AND srrd.assignment_type_id = @assignment_type
		GROUP BY rapd.priority_type, rapd.rec_assignment_priority_detail_id
		ORDER BY rapd.rec_assignment_priority_detail_id
	FOR XML PATH('')), 1, 2, '')
	
	--select @priority_order_by
	
	SET @sql = '
		UPDATE td
		SET priority = td_sorted.priority
		FROM #temp_deals td
		INNER JOIN (
			SELECT ROW_NUMBER() OVER(ORDER BY ' + @priority_order_by + ') priority, id
			FROM #temp_deals td
			OUTER APPLY (
			SELECT rapd.priority_type, rapo.priority_type_value_id, rapo.order_number 
			FROM rec_assignment_priority_order rapo
			INNER JOIN rec_assignment_priority_detail rapd ON rapd.rec_assignment_priority_detail_id = rapo.rec_assignment_priority_detail_id
			INNER JOIN rec_assignment_priority_group rapg ON rapg.rec_assignment_priority_group_id = rapd.rec_assignment_priority_group_id
			INNER JOIN state_rec_requirement_data srrd ON srrd.rec_assignment_priority_group_id = rapg.rec_assignment_priority_group_id
			WHERE srrd.state_value_id = ' + CAST(@assigned_state AS VARCHAR) + '
				AND ' + CAST(@compliance_year AS VARCHAR) + ' BETWEEN srrd.from_year AND srrd.to_year
				AND srrd.assignment_type_id = ' + CAST(@assignment_type AS VARCHAR) + '
				--AND rapd.priority_type = 20900	--Product
				AND rapo.priority_type_value_id = td.product
			) rapo_prd
			group by id
		) td_sorted ON td_sorted.id = td.id
	'
	--PRINT @sql
	EXEC (@sql)
	
	
	
	IF @debug = 1
	BEGIN
		SELECT '#temp_deals' AS tbl_sorted
		SELECT * FROM #temp_deals ORDER BY priority
	END
	
	--Take account of adjustment deals, which will deduct the volume of eligible detail RECs
	SET @sql = '
		UPDATE td
		SET volume_left = td.volume_left - rs_adjst.adjst_deal_volume
		--SELECT td.source_deal_header_id, td.volume_left, rs_adjst.*
		FROM #temp_deals td
		CROSS APPLY (
			SELECT
				SUM(sdd_adjst.deal_volume) adjst_deal_volume
				--sdd_adjst.* 
			FROM #temp_filtered_recs tfr
			INNER JOIN source_deal_header sdh_adjst ON sdh_adjst.source_deal_header_id = tfr.source_deal_header_id
				AND sdh_adjst.generator_id = td.generator_id
				AND sdh_adjst.status_value_id = 5182	--include only adjustment deals (Status: Adjustments)
			INNER JOIN source_deal_detail sdd_adjst ON sdd_adjst.source_deal_header_id = sdh_adjst.source_deal_header_id
				AND sdd_adjst.buy_sell_flag = ''s''	--offset deal will be sell
				AND sdd_adjst.term_start = td.term_start
		) rs_adjst
		WHERE rs_adjst.adjst_deal_volume IS NOT NULL	--avoid updating deals which do not have adjustments
	'
	
	--PRINT @sql
	EXEC (@sql)
	
	--RETURN
	
	IF @debug = 1
	BEGIN
		SELECT '#temp_deals after adjustments' AS #temp_deals_after_adjustments
		SELECT * FROM #temp_deals ORDER BY priority
		--RETURN
	END
	
	IF OBJECT_ID('tempdb..#temp_finalized_deals') IS NOT NULL DROP TABLE #temp_finalized_deals  
	CREATE TABLE #temp_finalized_deals
	(  
		id INT,
		priority INT,  
		source_deal_header_id INT,    
		source_deal_detail_id INT,  
		deal_date DATETIME,    
		gen_date DATETIME,    
		source_curve_def_id INT,  
		counterparty_id INT,  
		generator_id INT,  
		jurisdiction_state_id INT,  
		gen_state_value_id INT,  
		price NUMERIC(38, 20),    
		volume NUMERIC(38, 20),    
		bonus NUMERIC(38, 20),    
		expiration VARCHAR(30) COLLATE DATABASE_DEFAULT,    
		uom_id INT,  
		volume_left NUMERIC(38, 20),
		vol_to_be_assigned NUMERIC(38, 20),
		ext_deal_id INT,  --TODO: check if it is really needed 
		conv_factor NUMERIC(38, 20),  
		expiration_date DATETIME,  
		assigned_date DATETIME,  
		status_value_id INT,  
		term_start DATETIME,
		technology INT,
		product INT,
		compliance_year INT,
		tier_type_value_id INT
	) 
		
	IF OBJECT_ID('tempdb..#temp_tier_type') IS NOT NULL
		DROP TABLE #temp_tier_type
		
	--create a mapping table with tier and technology-gen_state. This table will be used to resolve tier of a deal
	CREATE TABLE #temp_tier_type (
		tier_type INT,
		source_deal_header_id INT
	)
		
	IF OBJECT_ID('tempdb..#target_profile') IS NOT NULL
		DROP TABLE #target_profile
	
	--create table to hold target for each tier
	CREATE TABLE #target_profile  
	(    
		effective_year_from DATETIME, 
		effective_year_to DATETIME, 
		tier_type_name VARCHAR(150) COLLATE DATABASE_DEFAULT,
		tier_type INT,  
		min_target NUMERIC(38, 20),    
		max_target NUMERIC(38, 20),  
		total_target NUMERIC(38, 20),
		requirement_type_id INT
	)  
	
	IF @flag = 'o'
	BEGIN
		--put all technology-gen_state pair from eligible deals to a same virtual tier (0), so that they are treated as a one tier.
		INSERT INTO #temp_tier_type (tier_type, source_deal_header_id)
		SELECT DISTINCT 0 tier_type,source_deal_header_id FROM #temp_filtered_recs_with_tier
			
		--put total target in a table with tier type (in this case, only one tier (VirtualTier with id: 0) is assumed.
		INSERT INTO #target_profile (effective_year_from, effective_year_to, tier_type_name, tier_type, min_target, max_target, total_target, requirement_type_id)
		SELECT TOP 1 srrd.from_year effective_year_from, srrd.to_year effective_year_to, 'VirtualTier' tier_type_name, 0 tier_type --pick only Assignement type requirements
		, NULL min_target 
		, NULL max_target
		, @volume total_target
		,23400 requirement_type_id	
		FROM state_rec_requirement_data srrd 
		WHERE 1 = 1  
			AND srrd.state_value_id = @assigned_state
			AND srrd.assignment_type_id = @assignment_type
			AND @compliance_year BETWEEN srrd.from_year AND srrd.to_year
	END
	ELSE
	BEGIN
		--save all technology-gen_state pair for all tier type
		INSERT INTO #temp_tier_type (tier_type, source_deal_header_id)
		SELECT tier_type, source_deal_header_id FROM #temp_filtered_recs_with_tier
		
		--select * from #temp_tier_type
		--SELECT DISTINCT rge.tier_type, rge.technology, rge.gen_state_value_id
		--FROM rec_gen_eligibility rge
		--WHERE rge.state_value_id = @assigned_state
		--	AND @compliance_year BETWEEN YEAR(rge.from_month) AND YEAR(rge.to_month)
			
		IF OBJECT_ID('tempdb..#target_deal_volume') IS NOT NULL
			DROP TABLE #target_deal_volume
		
		SELECT SUM(sdd.deal_volume * ISNULL(sdd.multiplier,1)) deal_volume
		, YEAR(sdd.term_start) term_yr, sdh.state_value_id
		
		 --, (ssbm.source_system_book_id1) source_system_book_id1,
		--(ssbm.source_system_book_id2) source_system_book_id2, 
		--(ssbm.source_system_book_id3) source_system_book_id3,
		--(ssbm.source_system_book_id4) source_system_book_id4 
		--select sdd.*
		INTO #target_deal_volume
		FROM source_deal_header sdh   
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id  
		INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1  
			AND ssbm.source_system_book_id2 = sdh.source_system_book_id2  
			AND ssbm.source_system_book_id3 = sdh.source_system_book_id3  
			AND ssbm.source_system_book_id4 = sdh.source_system_book_id4  
		WHERE 1 = 1  
			AND ssbm.fas_deal_type_value_id = 405 
			AND YEAR(sdd.term_start) = @compliance_year
			GROUP BY YEAR(sdd.term_start), sdh.state_value_id
		--GROUP BY ssbm.source_system_book_id1, ssbm.source_system_book_id2, ssbm.source_system_book_id3, ssbm.source_system_book_id4
		--return
		--select * from #target_deal_volume
		--select * from #target_profile
		--put total target in a table with tier type
		INSERT INTO #target_profile (effective_year_from, effective_year_to, tier_type_name, tier_type, min_target, max_target, total_target, requirement_type_id)
		SELECT MAX(srrd.from_year) effective_year_from, MAX(srrd.to_year) effective_year_to, MAX(sdv_tt.code) tier_type_name, srrde.tier_type
		, ISNULL(MAX(srrde.min_absolute_target), (MAX(srrde.min_target) / 100 * MAX(dv.deal_volume))) - ISNULL(MAX(assigned_volume),0)  min_target 
		, ISNULL(MAX(srrde.max_absolute_target) , (MAX(srrde.max_target) / 100 * MAX(dv.deal_volume))) - ISNULL(MAX(assigned_volume),0) max_target
		, MAX(srrd.per_profit_give_back) / 100 * MAX(dv.deal_volume) total_target
		, MIN(srrde.requirement_type_id) requirement_type_id	--MIN is used to pick up requiremtn type: Assignment for those tiers which is both assignment and constraint (e.g. Out of State All RECs)
		--select year(srrde.from_month), year(srrde.to_month), sdh.* 
		--, ISNULL(MIN(sdd.multiplier),1) multiplier,MAX(srrde.min_target) min_target
		
		FROM state_rec_requirement_data srrd 
		INNER JOIN state_rec_requirement_detail srrde ON srrd.state_value_id = srrde.state_value_id
			--AND srrd.from_month = srrde.from_month 
			--AND srrd.to_month = srrde.to_month 
			--AND srrde.requirement_type_id = 23400	--pick only Assignement type requirements
		--INNER JOIN rec_generator rg ON rg.state_value_id = srrd.state_value_id  
		INNER JOIN source_deal_header sdh ON sdh.state_value_id = srrd.state_value_id  
		INNER JOIN source_deal_detail sdd on sdd.source_deal_header_id = sdh.source_deal_header_id  
		INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1  
			AND ssbm.source_system_book_id2 = sdh.source_system_book_id2  
			AND ssbm.source_system_book_id3 = sdh.source_system_book_id3  
			AND ssbm.source_system_book_id4 = sdh.source_system_book_id4  
		--INNER JOIN state_rec_requirement_data srrd2 ON srrd2.state_value_id = srrd.state_value_id
		--LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
		--	AND gc.state_value_id = srrd2.state_value_id
		--INNER JOIN state_rec_requirement_detail srrde2 ON srrd2.state_value_id = srrde2.state_value_id
		--	AND srrd2.from_month = srrde2.from_month 
		--	AND srrd2.to_month = srrde2.to_month 
		--	AND srrde2.tier_type = COALESCE(gc.tier_type, rg.tier_type,srrde.tier_type)
		INNER JOIN static_data_value sdv_tt ON sdv_tt.value_id = srrde.tier_type --COALESCE(gc.tier_type, rg.tier_type,srrde.tier_type)
		INNER JOIN #target_deal_volume dv ON dv.term_yr = YEAR(sdd.term_start)
			AND dv.state_value_id = srrde.state_value_id
		OUTER APPLY
		(	
			SELECT SUM(assigned_volume) assigned_volume 
			FROM assignment_audit WHERE assignment_type = srrd.assignment_type_id 
				AND state_value_id = srrd.state_value_id 
				AND compliance_year = @compliance_year
				AND srrde.tier_type = tier
		) aa
		WHERE 1 = 1  
		--and YEAR(srrde.to_month) = 2013
		--and sdh.source_deal_header_id = 1010
			AND srrd.state_value_id = @assigned_state
			AND srrd.assignment_type_id = @assignment_type 
			AND @compliance_year BETWEEN srrd.from_year AND srrd.to_year
		GROUP BY srrde.tier_type
		
		
		
	END
	
	--return
	
	IF @debug = 1
	BEGIN
		SELECT '#target_profile' AS tbl
		SELECT * FROM #target_profile	
		
		
	END
	
	IF OBJECT_ID('tempdb..#temp_sorted_deals_by_tier') IS NOT NULL
		DROP TABLE #temp_sorted_deals_by_tier
	
	--create a new table almost same as #temp_deals to hold eligible deals for only one tier
	SELECT priority, source_deal_header_id, source_deal_detail_id, deal_date, 
	jurisdiction_state_id, volume, volume_left, term_start, technology, gen_state_value_id
	, CAST(NULL AS NUMERIC(38, 20)) sliced_volume, CAST(NULL AS INT) id, CAST(NULL AS INT) loop_index
	INTO #temp_sorted_deals_by_tier
	FROM #temp_deals WHERE 1 = 2

	IF OBJECT_ID('tempdb..#temp_sorted_violated_deals') IS NOT NULL 
		DROP TABLE #temp_sorted_violated_deals
	--create table to hold viloating deals when eligible deals are selected for a tier
	CREATE TABLE #temp_sorted_violated_deals(
		processing_tier_type INT
		, violated_tier_type INT
		, violated_technology INT
		, violated_gen_state_value_id INT
		, max_target NUMERIC(38, 20)
		, rolling_vol NUMERIC(38, 20)
		, source_deal_header_id INT
		, volume_left NUMERIC(38, 20)
		, processing_priority INT
		, violated_priority INT
		, exceeding_vol NUMERIC(38, 20)
		, sliced_volume NUMERIC(38, 20)
		, loop_index INT
	)
	
	IF OBJECT_ID('tempdb..#temp_const_tier_type') IS NOT NULL
		DROP TABLE #temp_const_tier_type

	--table to hold applied constraint tier for an assigned tier (e.g. Solar Set Aside Out of State (Constraint requirement) 
	--and Out of State All RECs (Constraint requirement) may be applied to Solar Set Aside (Assignement requirement)
	CREATE TABLE #temp_const_tier_type (
		assigned_tier_type INT
		, const_tier_type INT
	)
	--select * from state_rec_requirement_detail_constraint
	INSERT INTO #temp_const_tier_type (assigned_tier_type, const_tier_type)
	SELECT srrd.tier_type, srrd_const.tier_type
    FROM state_rec_requirement_detail_constraint srrdc
	INNER JOIN state_rec_requirement_detail srrd ON srrd.state_rec_requirement_detail_id = srrdc.state_rec_requirement_detail_id
	INNER JOIN state_rec_requirement_detail srrd_const ON srrd_const.state_rec_requirement_detail_id = srrdc.state_rec_requirement_applied_constraint_detail_id
    WHERE srrd.state_value_id = @assigned_state
		AND srrd.assignment_type_id = @assignment_type
	
	IF @debug = 1
	BEGIN
		SELECT 'Assigned Constraints per Tier (#temp_const_tier_type)'
		SELECT * FROM #temp_const_tier_type
		
	END
	
	
				
	DECLARE @rqm_tier_type INT
	DECLARE @rqm_min_target NUMERIC(38, 20)
	DECLARE @rqm_max_target NUMERIC(38, 20)
	DECLARE @tier_priority INT
	DECLARE @tier_order_num INT
	DECLARE @remaining_target_for_tier NUMERIC(38, 20)
	DECLARE @max_loop_count INT
	DECLARE @loop_index INT
	
	
	SET @max_loop_count = 20
	
	IF OBJECT_ID('tempdb..#temp_const_tier_target') IS NOT NULL
		DROP TABLE #temp_const_tier_target
		
	CREATE TABLE #temp_const_tier_target 
	(
		const_tier_type INT
		, remaining_target NUMERIC(38, 20)
	)
	--select * from #target_profile
		
	BEGIN TRY
		DECLARE cur_tier_type CURSOR LOCAL FOR
	
		--select all tier type in their priority order.
		SELECT tp.tier_type, MAX(tp.min_target) min_target, MAX(tp.max_target) max_target, ISNULL(MAX(rapo.order_number), 999999) tier_order_num
		FROM #target_profile tp
		LEFT JOIN rec_assignment_priority_order rapo ON (tp.tier_type = 0	--flag=o
			OR rapo.priority_type_value_id = tp.tier_type)					--flag=s
		LEFT JOIN rec_assignment_priority_detail rapd ON rapd.rec_assignment_priority_detail_id = rapo.rec_assignment_priority_detail_id
			AND rapd.priority_type = 15000	--Tier Type
		LEFT JOIN rec_assignment_priority_group rapg ON rapg.rec_assignment_priority_group_id = rapd.rec_assignment_priority_group_id
		INNER JOIN state_rec_requirement_data srrd ON srrd.rec_assignment_priority_group_id = rapg.rec_assignment_priority_group_id
		WHERE 1 = 1
			--AND tier_type IN (293521, 293483)--,293523,293525) --, 293522, 293524, 293486, 293526, 293440, 293489)	--TODO: change
			AND srrd.state_value_id = @assigned_state
			AND @compliance_year BETWEEN srrd.from_year AND srrd.to_year
			AND srrd.assignment_type_id = @assignment_type
			AND tp.requirement_type_id = 23400	--take requirement type: Assignement only, as those are the ones which will pick up eligible deals
		GROUP BY tp.tier_type
		ORDER BY tier_order_num
		
		OPEN cur_tier_type;
		
		FETCH NEXT FROM cur_tier_type INTO @rqm_tier_type, @rqm_min_target, @rqm_max_target, @tier_order_num
		WHILE @@FETCH_STATUS = 0
		BEGIN
			--PRINT('Now processing tier_type ' + CAST(@rqm_tier_type AS VARCHAR(15)))
			
			--reset
			TRUNCATE TABLE #temp_sorted_deals_by_tier
			TRUNCATE TABLE #temp_sorted_violated_deals
			TRUNCATE TABLE #temp_const_tier_target
			SET @tier_priority = NULL
			SET @remaining_target_for_tier = NULL
			SET @loop_index = 0
			
			IF @debug = 1
			BEGIN
				SELECT CAST(@rqm_tier_type AS VARCHAR(15)) processing_tier
			END
			
			--save constraint tier and remaining target for that tier
			INSERT INTO #temp_const_tier_target(const_tier_type, remaining_target)
			SELECT const_tier_type, NULL remaining_target 
			FROM #temp_const_tier_type tctt
			WHERE tctt.assigned_tier_type = @rqm_tier_type
			
			--LOOP START
			WHILE @loop_index < @max_loop_count
			BEGIN
				SET @loop_index = @loop_index + 1
				--calculate remaining target for every loop, so that the added deals should only satisfy remaining target, but not the whole target
				IF @rqm_min_target IS NULL AND @rqm_max_target IS NULL
				BEGIN
					SELECT @remaining_target_for_tier = tp.total_target - rs_tot.tot_vol_allocated
					FROM (SELECT TOP 1 total_target FROM #target_profile) tp
					CROSS JOIN (SELECT ISNULL(SUM(vol_to_be_assigned), 0) tot_vol_allocated
								FROM #temp_deals
					) rs_tot
				END
				ELSE
				BEGIN
					SELECT @remaining_target_for_tier = ISNULL(@rqm_max_target, @rqm_min_target) - ISNULL(SUM(tds.vol_to_be_assigned), 0)  
					FROM #temp_deals tds
					INNER JOIN #temp_tier_type ttt ON ttt.source_deal_header_id = tds.source_deal_header_id
--					LEFT JOIN #temp_sorted_deals_by_tier tsdbt ON tsdbt.source_deal_header_id = tds.source_deal_header_id
					WHERE ttt.tier_type = @rqm_tier_type
				END
				
				IF @debug = 1
				BEGIN
					SELECT @loop_index 'loop_index', @remaining_target_for_tier 'remaining_target_for_tier'
				END
			
				--sometimes remaining target becomes near to zero but not exact zero (e.g. 0.000000000000000033).
				--ROUNDING is done to handle such inaccuracies
				IF ROUND(@remaining_target_for_tier, @vol_rounding) <= 0
				BEGIN
					IF @debug = 1
					BEGIN
						SELECT @loop_index 'Loop broken at', 'Target fullfilled.' [reason]
					END 
					BREAK
				END
						
				--update remaining target for the constraint tier		
				UPDATE tctt
				SET remaining_target = ISNULL(tp.max_target, tp.min_target) - ISNULL(rs_tot_vol.total_assigned_vol, 0)
				--SELECT ISNULL(tp.max_target, tp.min_target), rs_tot_vol.*
				FROM #temp_const_tier_target tctt
				INNER JOIN #target_profile tp ON tp.tier_type = tctt.const_tier_type
				CROSS APPLY (
					SELECT  
					--tds.vol_to_be_assigned, tsdbt.sliced_volume, tsdbt.volume_left , ttt.tier_type
					SUM(tds.vol_to_be_assigned) total_assigned_vol
					FROM #temp_tier_type ttt 
					INNER JOIN #temp_deals tds ON ttt.source_deal_header_id = tds.source_deal_header_id
					WHERE ttt.tier_type = tctt.const_tier_type
					GROUP BY ttt.tier_type
				) rs_tot_vol
							
				IF @debug = 1
				BEGIN
					SELECT '#temp_const_tier_target'
					SELECT * FROM #temp_const_tier_target
				END
		
				--select * from #temp_tier_type
				--pick up deals to satisfy the tier's requirement. For that, find max priority in number of included deals fullfilling the target.
				--Rolling sum method is used to find the max priority
				
				--DECLARE @rqm_tier_type AS INT = 293521
				--DECLARE @vol_rounding AS TINYINT = 5
				--DECLARE @remaining_target_for_tier AS FLOAT = 1575
				
				--CTE is used here not for recursion, but for holding a resultset of eligible deals, so that rolling sum can be performed on that set only,
				--without repeating all those WHERE clauses to filter the eligible deals. Same can be achieved using a temp table as well.
				;WITH cte_priority_deals (priority, source_deal_header_id, volume, volume_left, vol_to_be_assigned)
				AS
				(
					SELECT tds.priority, tds.source_deal_header_id, tds.volume, tds.volume_left, tds.vol_to_be_assigned
					--SELECT * --tds.priority, tds.source_deal_header_id, volume, volume_left, vol_to_be_assigned, rs_rv.*
					FROM 
					#temp_deals tds
					INNER JOIN #temp_tier_type ttt ON ttt.source_deal_header_id = tds.source_deal_header_id
					OUTER APPLY (SELECT MAX(priority) AS max_priority FROM #temp_sorted_deals_by_tier tsdbt_inner) tsdbt
					WHERE ROUND(tds.volume_left, @vol_rounding) > 0
						AND ttt.tier_type = @rqm_tier_type
						--Exclude constraint tier whose quota has been fulfilled
						AND NOT EXISTS (
							SELECT 1
							FROM #temp_const_tier_target tctt 
							INNER JOIN #temp_tier_type ttt_inner ON tctt.const_tier_type = ttt_inner.tier_type
							WHERE ttt_inner.source_deal_header_id = tds.source_deal_header_id
								AND ROUND(tctt.remaining_target, @vol_rounding) <= 0
						)
						--Exclude deals from violated tier
						--Note: This step isn't necessary as violating tiers will have remaining target <=0, 
						--so will be excluded by the previous non existence check (#temp_const_tier_target)
						--AND NOT EXISTS (
						--	SELECT *	--TODO: change to 1
						--	FROM #temp_sorted_violated_deals tsvd 
						--	INNER JOIN #temp_tier_type ttt_inner ON tsvd.violated_tier_type = ttt_inner.tier_type
						--	WHERE ttt_inner.technology = tds.technology
						--		AND ttt_inner.gen_state_value_id = tds.gen_state_value_id
						--)
						--exclude already selected deals, so that only new deals are picked
						AND tds.priority > ISNULL(tsdbt.max_priority, 0)
				)
				
				SELECT TOP 1 @tier_priority = cpd.priority
				--SELECT * --tds.priority, tds.source_deal_header_id, volume, volume_left, vol_to_be_assigned, rs_rv.*
				FROM cte_priority_deals cpd
				CROSS APPLY (
					SELECT SUM(cpd_inner.volume_left) rolling_volume_left
					--, tds_inner.source_deal_header_id, tds_inner.priority
					FROM cte_priority_deals cpd_inner
					WHERE cpd_inner.priority <= cpd.priority
				) rs_rv
				WHERE rs_rv.rolling_volume_left >= @remaining_target_for_tier
				ORDER BY cpd.priority;			
				
				IF @debug = 1
				BEGIN
					SELECT MAX(priority) AS max_priority, @tier_priority [@tier_priority] FROM #temp_sorted_deals_by_tier
				END
				
				IF ISNULL(@tier_priority, 0) <= (SELECT MAX(priority) AS max_priority FROM #temp_sorted_deals_by_tier tsdbt_inner)
				BEGIN
					IF @debug = 1
					BEGIN
						SELECT @loop_index 'Breaking loop at', 'No more valid eligible deals.' [reason]
					END 
					BREAK
				END
				 
				--insert all eligible deals fulfilling the target, which is lower or equal to chosen priority in the previous step.
				--if the chosen priority is null (which means all eligible deals can't fullfill the tier target), insert all
				--eligible deals for that target
				INSERT INTO #temp_sorted_deals_by_tier(id, priority, source_deal_header_id, source_deal_detail_id, deal_date, jurisdiction_state_id, volume, volume_left, term_start, technology, gen_state_value_id, loop_index)
				SELECT tds.id, tds.priority, tds.source_deal_header_id, tds.source_deal_detail_id, tds.deal_date, tds.jurisdiction_state_id, tds.volume,  tds.volume_left, tds.term_start, tds.technology, tds.gen_state_value_id, @loop_index
				FROM #temp_deals tds
				INNER JOIN #temp_tier_type ttt ON ttt.source_deal_header_id = tds.source_deal_header_id
				WHERE ttt.tier_type = @rqm_tier_type
					AND (@tier_priority IS NULL OR tds.priority <= ISNULL(@tier_priority, 0))
					AND ROUND(tds.volume_left, @vol_rounding) > 0
					--Exclude constraint tier whose quota has been fulfilled
					AND NOT EXISTS (
						SELECT 1
						FROM #temp_const_tier_target tctt 
						INNER JOIN #temp_tier_type ttt_inner ON tctt.const_tier_type = ttt_inner.tier_type
						WHERE ttt_inner.source_deal_header_id = tds.source_deal_header_id
							AND ROUND(tctt.remaining_target, @vol_rounding) <= 0
					)
					--Exclude deals from violated tier
					AND NOT EXISTS (
						SELECT *	--TODO: change to 1
						FROM #temp_sorted_violated_deals tsvd 
						INNER JOIN #temp_tier_type ttt_inner ON tsvd.violated_tier_type = ttt_inner.tier_type
						WHERE ttt_inner.source_deal_header_id = tds.source_deal_header_id
					)
					--exclude already selected deals, so that only new deals are picked
					AND NOT EXISTS (
						SELECT 1
						FROM #temp_sorted_deals_by_tier tsdbt_inner
						WHERE tsdbt_inner.id = tds.id
					)	
					
				IF @debug = 1
				BEGIN
					SELECT '#temp_sorted_deals_by_tier' tbl, @rqm_min_target min_target, @rqm_max_target max_target, @remaining_target_for_tier remaining_target_for_tier
					SELECT * FROM #temp_sorted_deals_by_tier ORDER BY priority
				END

				--if constraints are applied in this tier, check for violation of those
				IF EXISTS (SELECT 1 FROM #temp_const_tier_type) 
				BEGIN
					--check if any other tier's requirement has been violated. Take only newly added deals in this loop into account
					INSERT INTO #temp_sorted_violated_deals (processing_tier_type, violated_tier_type, violated_technology, violated_gen_state_value_id 
					, max_target, rolling_vol, source_deal_header_id, volume_left, processing_priority, violated_priority, exceeding_vol, sliced_volume, loop_index)
					SELECT @rqm_tier_type processing_tier_type, ttt.tier_type violated_tier_type, tds.technology violated_technology, tds.gen_state_value_id violated_gen_state_value_id
					, tp.max_target, rs_rv.rolling_vol, tds.source_deal_header_id, tds.volume_left, tsdbt.priority processing_priority, tds.priority AS violated_priority
					, (rs_rv.rolling_vol - tcttgt.remaining_target) exceeding_vol, (tds.volume_left - (rs_rv.rolling_vol - tcttgt.remaining_target)) sliced_volume
					, @loop_index 
					--SELECT *--tsdbt.*, rs_rv.*
					FROM #temp_sorted_deals_by_tier tsdbt
					INNER JOIN #temp_deals tds ON tds.source_deal_header_id = tsdbt.source_deal_header_id
					INNER JOIN #temp_tier_type ttt ON ttt.source_deal_header_id = tsdbt.source_deal_header_id
					--Limit violoation check to only applied constraint tiers only
					INNER JOIN #temp_const_tier_type tctt ON tctt.assigned_tier_type = @rqm_tier_type
						AND tctt.const_tier_type = ttt.tier_type
					INNER JOIN #target_profile tp ON tp.tier_type = ttt.tier_type
					INNER JOIN #temp_const_tier_target tcttgt ON tcttgt.const_tier_type = ttt.tier_type
					OUTER APPLY (
						SELECT ttt_inner.tier_type, SUM(ISNULL(tsdbt_inner.sliced_volume, tsdbt_inner.volume_left)) rolling_vol
						--SELECT ttt_inner.tier_type, MAX(tds_inner.vol_to_be_assigned) vol_to_be_assigned, MAX(tsdbt.sliced_volume) sliced_volume, MAX(tsdbt.volume_left) volume_left, NULL rolling_vol
						FROM #temp_sorted_deals_by_tier tsdbt_inner
						INNER JOIN #temp_tier_type ttt_inner ON ttt_inner.source_deal_header_id = tsdbt_inner.source_deal_header_id
						WHERE ttt_inner.tier_type = ttt.tier_type 
							AND tsdbt_inner.priority <= tds.priority
							--IMP: Make sure main query where clauses are applied in this outer apply as well, so that same set of deals will be picked for rolling sum
							AND tsdbt_inner.loop_index = 1--@loop_index
							AND NOT EXISTS (
								SELECT ttt_inner.tier_type
								FROM #temp_sorted_violated_deals tsvd_inner 
								WHERE tsvd_inner.source_deal_header_id = tsdbt_inner.source_deal_header_id
							)
						GROUP BY ttt_inner.tier_type
					) rs_rv
					WHERE 1 = 1
						AND tsdbt.loop_index = 1--@loop_index
						AND rs_rv.rolling_vol > tcttgt.remaining_target
						--Exclude exisiting data for rolling sum calc
						AND NOT EXISTS (
							SELECT tsvd_inner.source_deal_header_id
							FROM #temp_sorted_violated_deals tsvd_inner 
							WHERE tsvd_inner.source_deal_header_id = tsdbt.source_deal_header_id
						)
						
					IF @debug = 1
					BEGIN
						SELECT 'Violated deals'
						SELECT * FROM #temp_sorted_violated_deals WHERE processing_tier_type = @rqm_tier_type
					END
					
					--Delete all viloating deals (except the one with lowest priority in number as it needs to be sliced) from #temp_sorted_deals_by_tier
					--as including them will always violate.
					DELETE tsdbt 
					FROM #temp_sorted_deals_by_tier tsdbt
					INNER JOIN #temp_tier_type ttt ON ttt.source_deal_header_id = tsdbt.source_deal_header_id
					INNER JOIN (
						--get violated deal with lowest priority in number for exclusion
						SELECT violated_tier_type, MIN(processing_priority) processing_priority
						FROM #temp_sorted_violated_deals
						WHERE loop_index = @loop_index
						GROUP BY violated_tier_type
					) tsvd_violated ON tsvd_violated.violated_tier_type = ttt.tier_type
						AND tsdbt.priority > tsvd_violated.processing_priority	--exclude the violated deal with top priority, as it needs to be sliced
					
					IF @debug = 1
					BEGIN
						SELECT '#temp_sorted_deals_by_tier after removing violated deals' tbl
						SELECT * FROM #temp_sorted_deals_by_tier ORDER BY priority
					END
					
					--Slice the only violating deal. Take reference from #temp_sorted_violated_deals for sliced volume as it has been already calculated.
					--volume_left will be updated later at once.
					UPDATE tsdbt
					SET sliced_volume = tsvd.sliced_volume
					FROM #temp_sorted_deals_by_tier tsdbt
					INNER JOIN #temp_sorted_violated_deals tsvd ON tsvd.source_deal_header_id = tsdbt.source_deal_header_id
				END
				
				--Slice exceeding volume. If target is not met, no slicing is necessary, i.e. take all the available volume (volume_left).
				--If volume_left exceeds target, slice it to meet the target.
				UPDATE tsdbt
				SET sliced_volume = ISNULL(sliced_volume, 0) 
										+ (volume_left -  
											CASE WHEN rs_tv.tot_vol <= @remaining_target_for_tier THEN 0
											ELSE (rs_tv.tot_vol - @remaining_target_for_tier)
											END)
				FROM #temp_sorted_deals_by_tier tsdbt
				INNER JOIN #temp_tier_type ttt ON ttt.source_deal_header_id = tsdbt.source_deal_header_id
				--filter the deal to be sliced, which is having lowest priority (means highest number)
				INNER JOIN (SELECT TOP 1 id, source_deal_header_id FROM #temp_sorted_deals_by_tier ORDER BY priority DESC) tsdbt_max ON tsdbt_max.id = tsdbt.id
				CROSS APPLY (SELECT SUM(ISNULL(sliced_volume, volume_left)) tot_vol
							FROM #temp_sorted_deals_by_tier tsdbt_inner
							WHERE tsdbt_inner.loop_index = @loop_index) rs_tv
				--exclude violated deal from slicing as it has already been sliced. 
				--This case is possible when no new deals are added after last deal in the set was viloated and sliced.
				--This check prevent such violated deal from getting sliced again.
				WHERE tsdbt.loop_index = @loop_index 
					AND NOT EXISTS (
							SELECT 1
							FROM #temp_sorted_violated_deals tsvd 
							WHERE tsvd.source_deal_header_id = tsdbt.source_deal_header_id
						)
				
				IF @debug = 1
				BEGIN
					SELECT '#temp_sorted_deals_by_tier after slicing deal'
					SELECT * FROM #temp_sorted_deals_by_tier ORDER BY priority
				END
				
				--select * from #temp_finalized_deals
				--select * from #temp_sorted_deals_by_tier
				
				
				--save deals allocated for each tier in another temp table, as we require final allocation tier wise, not deal wise
				INSERT INTO #temp_finalized_deals(id, priority, source_deal_header_id, source_deal_detail_id, deal_date, gen_date, source_curve_def_id, 
				counterparty_id, generator_id, jurisdiction_state_id, gen_state_value_id, price, volume, bonus, expiration, uom_id, vol_to_be_assigned
				, volume_left, ext_deal_id, conv_factor, expiration_date, assigned_date, status_value_id, term_start, technology, product, 
				compliance_year, tier_type_value_id)
				SELECT tds.id, tds.priority, tds.source_deal_header_id, tds.source_deal_detail_id, tds.deal_date, tds.gen_date, tds.source_curve_def_id 
				, tds.counterparty_id, tds.generator_id, tds.jurisdiction_state_id, tds.gen_state_value_id, tds.price, tds.volume, tds.bonus, tds.expiration
				, tds.uom_id
				, ISNULL(tsdbt.sliced_volume, tsdbt.volume_left) vol_to_be_assigned
				, (tsdbt.volume_left - ISNULL(tsdbt.sliced_volume, tsdbt.volume_left)) volume_left
				, tds.ext_deal_id, tds.conv_factor, tds.expiration_date, tds.assigned_date, tds.status_value_id, tds.term_start, tds.technology
				, tds.product, tds.compliance_year, @rqm_tier_type
				FROM #temp_deals tds
				INNER JOIN #temp_sorted_deals_by_tier tsdbt ON tsdbt.source_deal_header_id = tds.source_deal_header_id
					AND tds.technology = tsdbt.technology
					AND ISNULL(tds.gen_state_value_id, 1) = ISNULL(tsdbt.gen_state_value_id, 1)
				WHERE tsdbt.loop_index = @loop_index
			 --select * from #temp_Deals
				--Update main stack (#temp_deals) to reflect assigned and left volume for this tier type
				UPDATE td
				SET td.vol_to_be_assigned = ISNULL(td.vol_to_be_assigned, 0) + tfd.vol_to_be_assigned
					, td.volume_left = tfd.volume_left 
				--SELECT tds.volume_left, tsdbt.vol_to_be_assigned, ISNULL(tsdbt.vol_to_be_assigned, tsdbt.volume_left) vol_to_be_assigned, tsdbt.volume_left
				FROM #temp_deals td
				INNER JOIN #temp_finalized_deals tfd ON tfd.id = td.id
					AND tfd.tier_type_value_id = @rqm_tier_type
				INNER JOIN #temp_sorted_deals_by_tier tsdbt ON tsdbt.id = tfd.id
				WHERE tsdbt.loop_index = @loop_index
				
				IF @debug = 1
				BEGIN
					SELECT '#temp_deals after updating for a tier'
					SELECT ttt.tier_type, tds.* FROM #temp_finalized_deals tds
					INNER JOIN #temp_tier_type ttt ON ttt.source_deal_header_id = tds.source_deal_header_id
					WHERE ttt.tier_type = @rqm_tier_type
						AND ROUND(tds.vol_to_be_assigned, @vol_rounding) > 0 
					ORDER BY priority
				END
			END
			--WHILE LOOP END
			--select * from #temp_tier_type
			
			FETCH NEXT FROM cur_tier_type INTO @rqm_tier_type, @rqm_min_target, @rqm_max_target, @tier_order_num
		END;
		CLOSE cur_tier_type;
		DEALLOCATE cur_tier_type;	
	END TRY
	BEGIN CATCH
		IF CURSOR_STATUS('local', 'cur_tier_type') >= 0 
		BEGIN
			CLOSE cur_tier_type
			DEALLOCATE cur_tier_type;
		END
		--PRINT 'Error #' + CAST(ERROR_NUMBER() AS VARCHAR(20)) + ' in catch: ' + ERROR_MESSAGE()
	END CATCH	
	
	--DECLARE @gis_deal_id INT, @certificate_f INT, @certificate_t INT, @cert_from_f INT, @cert_to_t INT, @bank_assignment INT  
	
	SET @bank_assignment = 5149  
	  
	CREATE TABLE #temp_assign (  
		source_deal_detail_id INT,  
		cert_from INT,  
		cert_to INT,  
		assignment_type INT
	)  
	
	CREATE TABLE #temp_cert (  
		source_deal_header_id INT,  
		certificate_number_from_int INT,  
		certificate_number_to_int INT  
	)  
	  
	INSERT #temp_cert  
	SELECT gis.source_deal_header_id, gis.certificate_number_from_int, gis.certificate_number_to_int   
	FROM gis_certificate gis
	INNER JOIN #temp_finalized_deals tds ON tds.source_deal_detail_id = gis.source_deal_header_id

	DECLARE cursor1 CURSOR FOR  
	SELECT source_deal_header_id, certificate_number_from_int, certificate_number_to_int 
	FROM #temp_cert  
	  
	OPEN cursor1  
	FETCH NEXT FROM cursor1 INTO @gis_deal_id, @certificate_f, @certificate_t  
	   
	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		DECLARE cursor2 CURSOR FOR   
		SELECT cert_from, cert_to 
		FROM assignment_audit 
		WHERE source_deal_header_id_from = @gis_deal_id AND assigned_volume > 0  
		ORDER BY cert_from
		
		OPEN cursor2  
		FETCH NEXT FROM cursor2 INTO @cert_from_f, @cert_to_t  
		WHILE @@FETCH_STATUS = 0  
		BEGIN  
			IF @cert_from_f > @certificate_f   
			BEGIN  
				INSERT #temp_assign (source_deal_detail_id, cert_from, cert_to, assignment_type)  
				VALUES (@gis_deal_id, @certificate_f, @cert_from_f - 1, @bank_assignment)  
			END  

			SET @certificate_f = @cert_to_t + 1  

			FETCH NEXT FROM cursor2 INTO @cert_from_f, @cert_to_t  
		END  
		IF (@certificate_f - 1) < @certificate_t  
		BEGIN  
			INSERT #temp_assign (source_deal_detail_id, cert_from, cert_to, assignment_type) 
			VALUES (@gis_deal_id, @certificate_f, @certificate_t, @bank_assignment)  
		END  
		FETCH NEXT FROM cursor1 INTO @gis_deal_id,@certificate_f,@certificate_t  
		
		CLOSE cursor2  
		DEALLOCATE cursor2   
	 END   
	CLOSE cursor1  
	DEALLOCATE cursor1   
	   
	IF OBJECT_ID('tempdb..#temp_final') IS NOT NULL
		DROP TABLE #temp_final
	  
	CREATE TABLE #temp_final (  
		[ID] INT IDENTITY,  
		source_deal_detail_id INT,  
		cert_From INT,  
		cert_to INT,  
		assignment_type INT,  
		volume NUMERIC(38, 20)   
	)

	INSERT INTO #temp_final(source_deal_detail_id, cert_from, cert_to, assignment_type, volume)  
	SELECT source_deal_detail_id, cert_from, cert_to, assignment_type, (cert_to - cert_from + 1) AS volume
	FROM (  
		SELECT source_deal_detail_id, cert_from, cert_to, assignment_type FROM #temp_assign  
		UNION ALL  
		SELECT source_deal_header_id_from, cert_from, cert_to, assignment_type FROM assignment_audit  
	) a 
	--ORDER BY a.source_deal_detail_id, a.cert_from  

	IF OBJECT_ID('tempdb..#temp_final2') IS NOT NULL
		DROP TABLE #temp_final2
	  
	SELECT [ID], source_deal_detail_id, cert_from, cert_to, assignment_type, a.volume,volume_cumu, vol_to_be_assigned AS volume_left 
	INTO #temp_final2 
	FROM  
	(  
		SELECT b.[ID], b.source_deal_detail_id, cert_from, cert_to,assignment_type, a.volume
		, (SELECT SUM(volume) 
			 FROM #temp_final 
			 WHERE [ID] <= a.[ID] --and assignment_type = @assignment_type  
				AND source_deal_detail_id = a.source_deal_detail_id
			) AS volume_cumu
		, b.vol_to_be_assigned
		FROM #temp_final a
		INNER JOIN #temp_finalized_deals b ON a.source_deal_detail_id = b.source_deal_detail_id 
		WHERE 1 = 1 --assignment_type = @assignment_type   
	) a  
	WHERE ROUND((CASE WHEN volume_cumu - vol_to_be_assigned <= 0 THEN volume ELSE    
	 volume - (volume_cumu - vol_to_be_assigned) END), @vol_rounding) > 0    
	  
	IF OBJECT_ID('tempdb..#temp_include') IS NOT NULL
		DROP TABLE #temp_include

	CREATE TABLE #temp_include    
	( 
		id INT,    
		deal_id INT,    
		volume_assign NUMERIC(38, 20),      
		bonus NUMERIC(38, 20),      
		volume NUMERIC(38, 20),    
		volume_left NUMERIC(38, 20),
		tier_type_value_id INT   
	)     
	--drop table #temp_include
	--select * from #temp2
	--UPDATE #temp2 SET TARGET = 200
	--UPDATE #temp2 SET TARGET = 154100 WHERE deal_id = 432708
	   
	INSERT INTO #temp_include    
	SELECT id,source_deal_header_id, vol_to_be_assigned AS volume_assign    
	, CASE WHEN vol_to_be_assigned = 0 OR vol_to_be_assigned - volume_left_cumu  <= 0 THEN volume_left - volume_left1 ELSE    
	(volume_left - (vol_to_be_assigned - volume_left_cumu)) - ((volume_left - (vol_to_be_assigned - volume_left_cumu)) / (1 + bonus_per)) END  AS bonus,  
	--CASE WHEN [target] = 0 OR [target] - volume_left_cumu <= 0 THEN
	 a.volume_left
	--	 else    
	--volume_left-([target] - volume_left_cumu) end  
	AS volume,  
	--CASE WHEN [target] = 0 OR [target] - volume_left_cumu <=0 then 
	a.volume_left
	--else  
	 --[target]  -	volume_left
	--volume_left1-(volume_left-([target] - volume_left_cumu))/(1+bonus_per)
	--END
	AS volume_left,
	a.tier_type_value_id
	FROM
	(
		SELECT id, source_deal_header_id, volume, bonus, (bonus / (CASE WHEN volume = 0 THEN 1 ELSE volume END)) bonus_per, volume_left + (volume_left * (bonus / CASE WHEN volume = 0 THEN 1 ELSE volume END)) volume_left
		, volume_left volume_left1, vol_to_be_assigned, tier_type_value_id
		, (
			SELECT SUM(volume_left + (volume_left * (bonus / CASE WHEN volume = 0 THEN 1 ELSE volume END))) 
			FROM #temp_finalized_deals WHERE id <= a.id
			) AS volume_left_cumu    
	FROM     
	#temp_finalized_deals a    
	) a     
	WHERE  1=1 
	--and
	--CASE WHEN volume_left_cumu-[target] <=0 then volume_left else    
	--volume_left-(volume_left_cumu-[target]) end >0
	--select * from #target_profile
	--select * from #temp_deals
	--select * from #temp_finalized_deals
	--select * from #temp_include
	
	
	
			
	IF @table_name IS NULL OR @table_name = ''    
		SET @table_name = dbo.FNAProcessTableName('recassign_', dbo.FNADBUser(), dbo.FNAGetNewID())   
				 
	SET @sql = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) row_unique_id, tds.source_deal_detail_id [ID], tds.source_deal_header_id [Deal ID], dbo.FNADateFormat(tds.deal_date) deal_date,
	dbo.FNADateFormat(tds.gen_date) [Vintage], dbo.FNADateFormat(tds.expiration_date) expiration, sdv_jurisdiction.code jurisdiction, 
	sdv_gen.code [Gen State], rg.name [Generator],
	COALESCE(Conv1.curve_label,Conv5.curve_label,Conv2.curve_label,Conv3.curve_label,Conv4.curve_label, spcd.curve_name) obligation,
	sc.counterparty_name [Counterparty], tds.volume_left + vol_to_be_assigned [Volume Left],isnull(tds.bonus,0) bonus, su.uom_name [UOM], tds.price,
	vol_to_be_assigned - tds.bonus [Volume Assign], vol_to_be_assigned [Total Volume],  
	dbo.FNACertificateRule(cr.cert_rule,rg.[ID],'+CASE WHEN @cert_from IS NOT NULL THEN CAST(@cert_from AS VARCHAR) 
	ELSE ' COALESCE(tf.cert_from,assign1.assigned_volume+gis.certificate_number_from_int,gis.certificate_number_from_int)' END+' ,tds.gen_date) as  [Cert # From], 
	dbo.FNACertificateRule(cr.cert_rule,rg.[ID],'+CASE WHEN @cert_from IS NOT NULL THEN CAST(@cert_to AS VARCHAR) ELSE   
	'ISNULL(CASE WHEN tf.cert_from is not null and tf.volume_left+round(isnull(b.bonus/tds.conv_factor, 0), 0)<0 then round(tf.volume-b.volume_left,0)+tf.cert_from-1 else round(tf.volume-b.volume_Left,0)+tf.cert_from-1 end ,  
	ISNULL((assign1.assigned_volume-1+b.volume_assign),b.volume_assign-1)+gis.certificate_number_from_int)' END +' ,tds.gen_date) as  [Cert # T0],  
	'+CASE WHEN @cert_from IS NOT NULL THEN CAST(@cert_from AS VARCHAR) 
	ELSE '  COALESCE(tf.cert_from,assign1.assigned_volume+gis.certificate_number_from_int,gis.certificate_number_from_int) ' END +' as cert_from,'  
	 +CASE WHEN @cert_from IS NOT NULL THEN CAST(@cert_to AS VARCHAR)
	  ELSE '  ISNULL(CASE WHEN tf.cert_from is not null and tf.volume_left+round(isnull(b.bonus/tds.conv_factor, 0), 0)<0 then round(tf.volume-b.volume_left,0)+tf.cert_from-1 else round(tf.volume-b
	.volume_Left,0)+tf.cert_from-1 end ,  
	  ISNULL((assign1.assigned_volume-1+b.volume_assign),b.volume_assign)+gis.certificate_number_from_int) ' END +' as cert_to, 
	tds.compliance_year--, td.tier_type, ISNULL(tp.min_target, tp.max_target) target, tp.total_target
	, rg.gen_state_value_id, sdv_tech.code [Technology], tds.jurisdiction_state_id, sdv_tier.code [Tier], rg.tier_type tier_value_id
	--select *
	INTO ' + @table_name + '
	FROM #temp_finalized_deals tds
	INNER JOIN #temp_include b ON tds.id = b.id  
		AND tds.tier_type_value_id = b.tier_type_value_id
	LEFT JOIN rec_generator rg ON tds.generator_id = rg.generator_id
		AND tds.gen_state_value_id = rg.gen_state_value_id
		AND tds.technology = rg.technology
	LEFT JOIN static_data_value sdv_tier ON sdv_tier.value_id = tds.tier_type_value_id
	LEFT JOIN static_data_value sdv_tech ON sdv_tech.value_id = rg.technology
	INNER JOIN static_data_value sdv_jurisdiction ON sdv_jurisdiction.value_id = tds.jurisdiction_state_id
	LEFT JOIN static_data_value sdv_gen ON sdv_gen.value_id =  rg.gen_state_value_id
	LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = tds.source_curve_def_id  
	LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = tds.counterparty_id 
	LEFT JOIN assignment_audit assign ON tds.source_deal_detail_id = assign.source_deal_header_id 
	LEFT JOIN source_uom su ON su.source_uom_id = tds.uom_id	
	LEFT JOIN static_data_value state ON state.value_id = ISNULL(assign.state_value_id,rg.state_value_id) 
	LEFT JOIN rec_volume_unit_conversion Conv1 ON            
	 conv1.from_source_uom_id  = tds.uom_id             
		AND conv1.to_source_uom_id = ' + ISNULL(CAST(@convert_uom_id as varchar),'NULL') +'           
		And conv1.state_value_id = state.value_id
		AND conv1.assignment_type_value_id = ' + cast(@assignment_type as varchar) + ' 
		AND conv1.curve_id = tds.source_curve_def_id             
		AND conv1.to_curve_id IS NULL
	LEFT JOIN rec_volume_unit_conversion Conv2 ON            
	 conv2.from_source_uom_id = tds.uom_id              
		AND conv2.to_source_uom_id = ' + ISNULL(CAST(@convert_uom_id as varchar),'NULL') +'        
		And conv2.state_value_id IS NULL
		AND conv2.assignment_type_value_id = ' + cast(@assignment_type as varchar) + '  
		AND conv2.curve_id = tds.source_curve_def_id  
		AND conv2.to_curve_id IS NULL
	LEFT JOIN rec_volume_unit_conversion Conv3 ON            
	conv3.from_source_uom_id =  tds.uom_id             
		AND conv3.to_source_uom_id = ' + ISNULL(CAST(@convert_uom_id as varchar),'NULL') +'           
		And conv3.state_value_id IS NULL
		AND conv3.assignment_type_value_id IS NULL
		AND conv3.curve_id = tds.source_curve_def_id  
		AND conv3.to_curve_id IS NULL
	LEFT JOIN rec_volume_unit_conversion Conv4 ON            
	 conv4.from_source_uom_id = tds.uom_id
		AND conv4.to_source_uom_id = ' + ISNULL(CAST(@convert_uom_id as varchar),'NULL') +'         
		And conv4.state_value_id IS NULL
		AND conv4.assignment_type_value_id IS NULL
		AND conv4.curve_id IS NULL
		AND conv4.to_curve_id IS NULL
	LEFT JOIN rec_volume_unit_conversion Conv5 ON            
	 conv5.from_source_uom_id  = tds.uom_id             
		AND conv5.to_source_uom_id = ' + ISNULL(CAST(@convert_uom_id as varchar),'NULL') +'         
		And conv5.state_value_id = state.value_id
		AND conv5.assignment_type_value_id is null
		AND conv5.curve_id = tds.source_curve_def_id 
		AND conv5.to_curve_id IS NULL
	LEFT JOIN #temp_final2 tf ON tf.source_deal_detail_id = tds.source_deal_detail_id
	LEFT JOIN certificate_rule cr ON isnull(rg.gis_value_id, 5164) = cr.gis_id
	LEFT JOIN        
		(
			SELECT source_deal_header_id_from,sum(assigned_volume) assigned_volume from         
			assignment_audit group by source_deal_header_id_from
		) assign1        
		ON assign1.source_deal_header_id_from=tds.source_deal_header_id 
	LEFT JOIN #temp_cert gis ON gis.source_deal_header_id = tds.source_deal_header_id   
	WHERE ROUND(tds.vol_to_be_assigned, ' + CAST(@vol_rounding AS VARCHAR(15)) + ') > 0
	ORDER BY tds.priority'
		
	--PRINT @sql
	EXEC(@sql)
	IF @export = 'y' 
	BEGIN
		SET @sql = 'SELECT row_unique_id [Row ID], [Deal ID], deal_date [Deal Date], Vintage--, Expiration
				, Jurisdiction, Technology, [Gen State], Generator, obligation [Env Product], Counterparty
				, dbo.FNARemoveTrailingZero(ROUND(CAST([Volume Left] AS NUMERIC(38, 20)), ' + CAST(@vol_rounding AS VARCHAR(2)) + ')) AS [Volume Available]
				, dbo.FNARemoveTrailingZero(ROUND(CAST([Volume Assign] AS NUMERIC(38, 20)), ' + CAST(@vol_rounding AS VARCHAR(2)) + ')) [Volume Assign]
				, dbo.FNARemoveTrailingZero(ROUND(CAST(Bonus AS NUMERIC(38, 20)), ' + CAST(@vol_rounding AS VARCHAR(2)) + ')) Bonus
				, dbo.FNARemoveTrailingZero(ROUND(CAST([Total Volume] AS NUMERIC(38, 20)), ' + CAST(@vol_rounding AS VARCHAR(2)) + ')) [Total Volume]
				, UOM
				, dbo.FNARemoveTrailingZero(ROUND(Price, ' + CAST(@vol_rounding AS VARCHAR(2)) + ')) [Price]
				, [Tier] as [Assigned To Tier]
				' + @str_batch_table + '
	            FROM	            
	             ' + @table_name + ' a'
	END			
	ELSE 
	BEGIN
		SET @sql = 'SELECT ''' + @table_name + ''' [Process Table], NULL [Assign_id], row_unique_id, [ID] [Detail ID]
				, [Deal ID], deal_date [Deal Date], Vintage--, Expiration 
				, Jurisdiction, Technology, [Gen State], Generator, obligation [Env Product], Counterparty
				, CAST(dbo.FNARemoveTrailingZero(ROUND(CAST([Volume Left] AS NUMERIC(38, 20)), ' + CAST(@vol_rounding AS VARCHAR(2)) + ')) AS FLOAT)  AS [Volume Available]
				, CAST(dbo.FNARemoveTrailingZero(ROUND(CAST([Volume Assign] AS NUMERIC(38, 20)), ' + CAST(@vol_rounding AS VARCHAR(2)) + ')) AS FLOAT)  [Volume Assign]
				, CAST(dbo.FNARemoveTrailingZero(ROUND(CAST(Bonus AS NUMERIC(38, 20)), ' + CAST(@vol_rounding AS VARCHAR(2)) + ')) AS FLOAT)  Bonus 
				, CAST(dbo.FNARemoveTrailingZero(ROUND(CAST([Total Volume] AS NUMERIC(38, 20)), ' + CAST(@vol_rounding AS VARCHAR(2)) + ')) AS FLOAT) [Total Volume]
				, UOM
				, CAST(dbo.FNARemoveTrailingZero(ROUND(Price, ' + CAST(@vol_rounding AS VARCHAR(2)) + ')) AS FLOAT) [Price]
				, [Tier] as [Assigned To Tier], gen_state_value_id, jurisdiction_state_id, compliance_year, tier_value_id
				' + @str_batch_table + '
	            FROM	            
	             ' + @table_name + ' a'   
	END
	
	--PRINT @sql
	EXEC(@sql)

	IF @debug = 1
	BEGIN
		SELECT tier_type_value_id, source_deal_header_id, volume, volume_left, vol_to_be_assigned
		FROM #temp_finalized_deals WHERE ROUND(vol_to_be_assigned, @vol_rounding) > 0 ORDER BY source_deal_header_id, vol_to_be_assigned
	END
	
	--test
	--SELECT  * FROM #temp_tier_type where source_deal_header_id IN (1200, 1201, 1203, 1205)

	/*******************************************2nd Paging Batch START**********************************************/
 
	--update time spent and batch completion message in message board
	IF @is_batch = 1
	BEGIN
	   SELECT @sql_paging = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
	   EXEC(@sql_paging)
	 
	   --TODO: modify sp and report name
	   SELECT @sql_paging = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_find_assignment_rec_deals', 'Run Assignment logic')
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

END

GO



