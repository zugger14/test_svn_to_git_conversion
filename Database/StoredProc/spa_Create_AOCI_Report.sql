

IF OBJECT_ID(N'spa_Create_AOCI_Report', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_Create_AOCI_Report]
 GO 




--exec spa_Create_AOCI_Report '2004-12-31', '30', '208', '223', 'f', 'd', 'd'

-- exec spa_Create_AOCI_Report '2004-12-31', '30', '208', '223', 'f', 'd', 'd'

-- exec spa_Create_AOCI_Report '2004-08-30', '1', null, '64', 'c', 'd', 's'
-- EXEC spa_Create_AOCI_Report  '7/31/2003', '1,2,20,30', null, null, 'f', 'd', 'd'
-- EXEC spa_Create_AOCI_Report  '7/31/2003', '1,2,20,30', null, null, 'f', 'd', 'p'
-- EXEC spa_Create_AOCI_Report  '7/31/2003', '1,2,20,30', null, null, 'f', 'd', 'r'
-- EXEC spa_Create_AOCI_Report  '9/30/2004', '71,1,20,30', null, null, 'f', 'u', 's'

   
--===========================================================================================
--This Procedure spa_Create_AOCI_Report
--Input Parameters
--@as_of_date - as of date
--@sub_entity_id - subsidiary Id
--@strategy_entity_id - strategy Id
--@book_entity_id - book Id
--@settlment_option - 'a' is all, 's' for settlement, 'c' for current and foward,  and  'f' for forward only
--@discount_option - takes two values 'd' or 'u', corresponding to 'discounted', 'undiscounted' 

--@summary_option - takes 'd' for detailed, 's' for summary,
--		   'p' summary by  sub/tenor, 'r' sub/strategy/rollout, 't' sub/rollout/tenor, 'u' for sub/rollout
--===========================================================================================
 create PROC [dbo].[spa_Create_AOCI_Report] 
	@as_of_date varchar(50), 
	@sub_entity_id varchar(MAX), 
 	@strategy_entity_id varchar(MAX) = NULL, 
	@book_entity_id varchar(MAX) = NULL, 
	@settlement_option varchar(1),
	@discount_option char(1), 
	@summary_option char(1),
	@round_value char(1) = '0',
	@term_start DATETIME=NULL,
	@term_end DATETIME=NULL,
	@batch_process_id varchar(50)=NULL,
	@batch_report_param varchar(500)=NULL   ,
	@enable_paging int=0,  --'1'=enable, '0'=disable
	@page_size int =NULL,
	@page_no int=NULL

 AS

 SET NOCOUNT ON



--////////////////////////////Paging_Batch///////////////////////////////////////////
EXEC spa_print	'@batch_process_id:', @batch_process_id 
EXEC spa_print	'@batch_report_param:', @batch_report_param

declare @str_batch_table varchar(max),@str_get_row_number VARCHAR(100)
declare @temptablename varchar(128),@user_login_id varchar(50),@flag CHAR(1)
DECLARE @is_batch bit
DECLARE @sql_paging VARCHAR(MAX)



declare @sql_stmt varchar(5000)

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

--////////////////////////////End_Batch///////////////////////////////////////////





/*
--*****************For batch processing********************************        
        
DECLARE @str_batch_table varchar(max)        
SET @str_batch_table=''        
IF @batch_process_id is not null        
 SELECT @str_batch_table=dbo.FNABatchProcess('s',@batch_process_id,@batch_report_param,NULL,NULL,NULL)         

-- 
-- declare @as_of_date varchar(50), @sub_entity_id varchar(100), 
--  	@strategy_entity_id varchar(100), 
--  	@book_entity_id varchar(100), @discount_option char(1), 
--  	@summary_option char(1),@settlement_option varchar(1)
--  
-- set @as_of_date='9/30/2004'
-- set  @sub_entity_id ='1,20,30,71'
-- set 	 @discount_option ='u'
-- 
-- --set  @report_type ='f'
-- set @summary_option ='t'
-- set @strategy_entity_id = null
-- set @book_entity_id  = null
*/
 if @settlement_option IS NULL
	set @settlement_option = 'f'

Declare @Sql_Select varchar(5000)

Declare @Sql_From varchar(5000)

Declare @Sql_Where varchar(5000)

Declare @Sql_GpBy varchar(5000)

Declare @Sql_OrderBy varchar(5000)

Declare @Sql1 varchar(8000)
Declare @Sql2 varchar(8000)

--==================================================================================================
If @term_start IS NOT NULL and @term_end IS NULL
	SET @term_end=@term_start
If @term_start IS NULL and @term_end IS NOT NULL
	SET @term_start=@term_end


	--==========================Get all Linked hedges=========================================================================

-- 	IF @summary_option = 's'
-- 		SET @Sql_Select = 'SELECT     PH.entity_name AS Sub, PH1.entity_name AS Strategy, PH2.entity_name AS Book, '	
-- 	Else IF @summary_option = 'd'
		SET @Sql_Select = 'SELECT     	PH.entity_name AS Sub, PH1.entity_name AS Strategy, 
						PH2.entity_name AS Book, RMV.link_id AS [ID], 
						RMV.term_month AS [Expiration], oci_rollout.code AS [Rollout], '
-- 	Else If @summary_option = 'p'
-- 		SET @Sql_Select = 'SELECT     PH.entity_name AS Sub, RMV.term_month AS [Expiration], '	
	

	
	IF @discount_option='u'
		SET @Sql_Select = @Sql_Select  + ' RMV.u_total_aoci AS [AOCI]'
	ELSE IF @discount_option='d'
		SET @Sql_Select = @Sql_Select  + ' RMV.d_total_aoci AS [AOCI]'


	SET @Sql_From = ' FROM         portfolio_hierarchy PH2 INNER JOIN
		                      portfolio_hierarchy PH1 INNER JOIN
		                     	'+ dbo.FNAGetProcessTableName(@as_of_date, 'report_measurement_values') + '  RMV INNER JOIN
		                      portfolio_hierarchy PH ON RMV.sub_entity_id = PH.entity_id ON PH1.entity_id = RMV.strategy_entity_id ON 
		                      PH2.entity_id = RMV.book_entity_id
					--WhatIf Changes
					INNER JOIN fas_books fb ON fb.fas_book_id = RMV.book_entity_id
					INNER JOIN fas_strategy FS ON RMV.strategy_entity_id = FS.fas_strategy_id INNER JOIN
					static_data_value oci_rollout on  oci_rollout.value_id = FS.oci_rollout_approach_value_id'
	
	SET @Sql_Where = ' WHERE   
					--WhatIf Changes
					(fb.no_link IS NULL OR fb.no_link = ''n'') AND 
					(RMV.as_of_date = CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) AND   
						                      (RMV.sub_entity_id IN( ' + @sub_entity_id + ')) '
					
	IF @strategy_entity_id IS NOT NULL
		SET @Sql_Where = @Sql_Where + ' AND (RMV.strategy_entity_id IN(' + @strategy_entity_id + ' ))'
	IF @book_entity_id IS NOT NULL
		SET @Sql_Where = @Sql_Where + ' AND (RMV.book_entity_id IN(' + @book_entity_id + ')) '
	
	--For Cash Flow
	SET @Sql_Where = @Sql_Where + ' AND FS.hedge_type_value_id = 150'
	
	
	IF @settlement_option = 'f' -- f
	   SET @Sql_Where = @Sql_Where + ' and term_month > ''' +  cast(@as_of_date as varchar) + ''''
	ELSE IF @settlement_option = 'c' -- c, f
	   SET @Sql_Where = @Sql_Where + ' and term_month >= ''' +  dbo.FNAGetContractMonth(@as_of_date)  + ''''
	ELSE IF @settlement_option = 's' -- c, s
	   SET @Sql_Where = @Sql_Where + ' and term_month <= ''' +  dbo.FNAGetContractMonth(@as_of_date) + ''''


	IF (@term_start IS NOT NULL)
		SET @Sql_Where = @Sql_Where +' AND convert(varchar(10),term_month,120) >='''+convert(varchar(10),@term_start,120) +''''

	IF (@term_end IS NOT NULL)
		SET @Sql_Where = @Sql_Where +' AND convert(varchar(10),term_month,120)<='''+convert(varchar(10),@term_end,120) +''''

	   --SET @Sql_Where = @Sql_Where + ' and term_month > ''' +  cast(@as_of_date as varchar) + ''''
		
	SET @Sql1 = @Sql_Select + @Sql_From + @Sql_Where --+ @Sql_GpBy
	
	
	--print  @Sql1

	--=================SUMMARIZE======================================================
	
	If @summary_option = 'r'
	BEGIN
		SET @Sql_Select = 'SELECT      Sub,  Strategy, Rollout, '	
		SET @Sql_GpBy = ' GROUP BY Sub, Strategy, Rollout HAVING sum(aoci ) <> 0'
		Set @Sql_OrderBy =  ' ORDER BY Sub, Strategy, Rollout'
	END
	Else If @summary_option = 'u'
	BEGIN
		SET @Sql_Select = 'SELECT      Sub,  Rollout, '	
		SET @Sql_GpBy = ' GROUP BY Sub, Rollout HAVING sum(aoci ) <> 0'
		Set @Sql_OrderBy =  ' ORDER BY Sub, Rollout'
	END
	Else If @summary_option = 't'
	BEGIN
		SET @Sql_Select = 'SELECT      Sub,  Rollout, dbo.FNAContractMonthFormat(Expiration) AS [Expiration], '	
		SET @Sql_GpBy = ' GROUP BY Sub, Rollout, [Expiration] HAVING sum(aoci ) <> 0'
		Set @Sql_OrderBy =  ' ORDER BY Sub, Rollout, cast((dbo.FNAContractMonthFormat(Expiration) + ''-01'') AS datetime)'
	END
	Else If @summary_option = 's'
	BEGIN
		SET @Sql_Select = 'SELECT      Sub,  Strategy,  Book, '	
		SET @Sql_GpBy = ' GROUP BY Sub, Strategy, Book HAVING sum(aoci ) <> 0'
		Set @Sql_OrderBy =  ' ORDER BY Sub, Strategy, Book '
	END
	Else IF @summary_option = 'd'
	BEGIN
		SET @Sql_Select = 'SELECT      Sub,  Strategy,  Book, [ID], dbo.FNAContractMonthFormat(Expiration) AS [Expiration], max(Rollout) [Rollout], '
		SET @Sql_GpBy = 'GROUP BY Sub, Strategy, Book, [ID], [Expiration] HAVING sum(cast(aoci as float)) <> 0'
		Set @Sql_OrderBy =  ' ORDER BY Sub, Strategy, Book, ID, cast((dbo.FNAContractMonthFormat(Expiration) + ''-01'') AS datetime) '
	END
	Else IF @summary_option = 'p'
	BEGIN
		SET @Sql_Select = 'SELECT      Sub,  dbo.FNAContractMonthFormat(Expiration) AS [Expiration], '	
		SET @Sql_GpBy = 'GROUP BY Sub, [Expiration] HAVING sum(aoci ) <> 0'
		Set @Sql_OrderBy =  ' ORDER BY Sub, [Expiration] '
	END


	IF @summary_option = 'd'
	BEGIN
		CREATE TABLE #tmp_report(
				[As Of Date] [varchar](50) COLLATE DATABASE_DEFAULT  NULL,
				[Rel ID] [int] NULL,
				[Delivery Month] [varchar](50) COLLATE DATABASE_DEFAULT  NULL,
				[Der Deal ID] [int] NOT NULL,
				[Source Deal ID] [varchar](50) COLLATE DATABASE_DEFAULT  NOT NULL,
				[Der Contract Month] [varchar](50) COLLATE DATABASE_DEFAULT  NULL,
				[Der Strip Months] [tinyint] NULL,
				[Der Lagging Months] [tinyint] NULL,
				[Item Strip Months] [tinyint] NULL,
				[Release Type] [varchar](500) COLLATE DATABASE_DEFAULT  NULL,
				[AOCI Release %] [float] NULL,
				[AOCI] [float] NULL,
				[AOCI Release] [float] NULL
			) ON [PRIMARY]
			
			--EXEC spa_create_detailed_aoci_schedule @as_of_date, NULL, NULL, @discount_option, @sub_entity_id, @strategy_entity_id, @book_entity_id, 'd',@round_value,@term_start,@term_end, @batch_process_id, @batch_report_param
			insert into #tmp_report EXEC spa_create_detailed_aoci_schedule @as_of_date, NULL, NULL, @discount_option, @sub_entity_id, @strategy_entity_id, @book_entity_id, 'd',@round_value,@term_start,@term_end
			set @Sql_Select='SELECT * ' + @str_batch_table +' FROM #tmp_report where [Delivery Month]+''-01''>'''  + @as_of_date + ''''
			exec spa_print @Sql_Select 
			EXEC(@Sql_Select) 
	END
	ELSE
	BEGIN
		SET @Sql_Select = @Sql_Select  + ' SUM( [AOCI]  ) AS [AOCI]'
		set @sQL_fROM =  @str_batch_table + ' FROM (' + @Sql1 +  ') AS A '
		
		EXEC(@Sql_Select + @Sql_From + @Sql_GpBy + @Sql_OrderBy)
	END


/*******************************************2nd Paging Batch START**********************************************/
 
--update time spent and batch completion message in message board
IF @is_batch = 1
BEGIN
   SELECT @sql_paging = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
   EXEC(@sql_paging)
 
   --TODO: modify sp and report name
   SELECT @sql_paging = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_Create_AOCI_Report', 'AOCI Report')
   EXEC(@sql_paging)  
 
   RETURN
END
 
--if it is first call from paging, return total no. of rows and process id instead of actual data
IF @enable_paging = 1 AND @page_no IS NULL
BEGIN
   SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
   EXEC(@sql_paging)
END
GO

