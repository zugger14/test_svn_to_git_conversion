

/****** Object:  StoredProcedure [dbo].[spa_Create_MTM_Period_Report]    Script Date: 11/09/2011 12:23:00 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_Create_MTM_Period_Report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_Create_MTM_Period_Report]
GO


/****** Object:  StoredProcedure [dbo].[spa_Create_MTM_Period_Report]    Script Date: 11/09/2011 12:23:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


 /**
	Retrieve MTM/Settlement data for report

	Parameters : 
	@as_of_date : As Of Date to process
	@sub_entity_id : Subsidiary filter for deals to process
	@strategy_entity_id : Strategy filter for deals to process
	@book_entity_id : Book filter for deals to process
	@discount_option : Discount Option
						- 'y' - Discounted MTM value
						- 'n' - Undiscount MTM value
	@settlement_option : Filter tenor option
						- 's' - Settled value
						- 'f' - Forward value only
						- 'c' - Forward with curent value
	@report_type : Report filter option
						- 'c' - Cash-flow Hedges Deals
						- 'f' - Fair-value Hedges Deals
						- 'm' - MTM (Fair Value) Deals
						- 'n' - Normal Purchase/Sales (Out of Scope) Deals
	@summary_option : Summary Option
	@counterparty_id : Counterparty Id
	@tenor_from : Tenor From
	@tenor_to : Tenor To
	@previous_as_of_date : Previous As Of Date
	@trader_id : Trader Id
	@include_item : Include Item
	@source_system_book_id1 : Source System Book Id1
	@source_system_book_id2 : Source System Book Id2
	@source_system_book_id3 : Source System Book Id3
	@source_system_book_id4 : Source System Book Id4
	@show_firstday_gain_loss : Show Firstday Gain Loss
	@transaction_type : Transaction Type
	@deal_id_from : Deal Id From
	@deal_id_to : Deal Id To
	@deal_id : Deal Id
	@threshold_values : Threshold Values
	@show_prior_processed_values : Show Prior Processed Values
	@exceed_threshold_value : Exceed Threshold Value
	@show_only_for_deal_date : Show Only For Deal Date
	@use_create_date : Use Create Date
	@round_value : Round Value
	@counterparty : Counterparty
	@mapped : Mapped
	@match_id : Match Id
	@cpty_type_id : Cpty Type Id
	@curve_source_id : Curve Source Id
	@deal_sub_type : Deal Sub Type
	@deal_date_from : Deal Date From
	@deal_date_to : Deal Date To
	@phy_fin : Phy Fin
	@deal_type_id : Deal Type Id
	@period_report : Period Report
	@term_start : Term Start
	@term_end : Term End
	@settlement_date_from : Settlement Date From
	@settlement_date_to : Settlement Date To
	@settlement_only : Settlement Only
	@drill1 : Drill1
	@drill2 : Drill2
	@drill3 : Drill3
	@drill4 : Drill4
	@drill5 : Drill5
	@drill6 : Drill6
	@risk_bucket_header_id : Risk Bucket Header Id
	@risk_bucket_detail_id : Risk Bucket Detail Id
	@commodity_id : Commodity Id
	@graph : Graph
	@batch_process_id : Batch Process Id
	@batch_report_param : Batch Report Param
	@enable_paging : Enable Paging
	@page_size : Page Size
	@page_no : Page No

  */



CREATE PROC [dbo].[spa_Create_MTM_Period_Report] 

					@as_of_date VARCHAR(50),
					@sub_entity_id VARCHAR(MAX), 
					@strategy_entity_id VARCHAR(MAX) = NULL, 
					@book_entity_id VARCHAR(MAX) = NULL, 
					@discount_option CHAR(1), 
					@settlement_option CHAR(1), 
					@report_type CHAR(1), 
					@summary_option CHAR(1),
					@counterparty_id NVARCHAR(1000)= NULL, 
					@tenor_from VARCHAR(50)= NULL,
					@tenor_to VARCHAR(50) = NULL,
					@previous_as_of_date VARCHAR(50) = NULL,
					@trader_id VARCHAR(500) = NULL,
					@include_item CHAR(1)='n', -- to include item in cash flow hedge
					@source_system_book_id1 INT=NULL, 
					@source_system_book_id2 INT=NULL, 
					@source_system_book_id3 INT=NULL, 
					@source_system_book_id4 INT=NULL, 
					@show_firstday_gain_loss CHAR(1)='n', -- To Show First Day Gain/Loss
					@transaction_type VARCHAR(500)=NULL,
					@deal_id_from INT=NULL,
					@deal_id_to INT=NULL,
					@deal_id VARCHAR(100)=NULL,
					@threshold_values FLOAT=NULL,
					@show_prior_processed_values CHAR(1)='n',
					@exceed_threshold_value CHAR(1)='n',   -- For First Day gain Loss Treatment selection
					@show_only_for_deal_date CHAR(1)='y',
					@use_create_date CHAR(1)='n',
					@round_value CHAR(1) = '0',
					@counterparty CHAR(1) = 'a', --i means only internal and e means only external, a means all
					@mapped CHAR(1) = 'm', --m means mapped only, n means non-mapped only,
					@match_id CHAR(1) = 'n', --'y' means use like for deal ids and 'n' means use 
					@cpty_type_id INT = NULL,  
					@curve_source_id INT=4500,
					@deal_sub_type CHAR(1)='t',
					@deal_date_from VARCHAR(20)=NULL,
					@deal_date_to VARCHAR(20)=NULL,
					@phy_fin VARCHAR(1)='b',
					@deal_type_id INT=NULL,
					@period_report VARCHAR(1)='n',
					@term_start VARCHAR(20)=NULL,
					@term_end VARCHAR(20)=NULL,
					@settlement_date_from VARCHAR(20)=NULL,
					@settlement_date_to VARCHAR(20)=NULL,
					@settlement_only CHAR(1)='n',
					@drill1 VARCHAR(100)=NULL,
					@drill2 VARCHAR(100)=NULL,
					@drill3 VARCHAR(100)=NULL,
					@drill4 VARCHAR(100)=NULL,
					@drill5 VARCHAR(100)=NULL,
					@drill6 VARCHAR(100)=NULL,
					--Add Parameters Here
					@risk_bucket_header_id INT=NULL,
					@risk_bucket_detail_id INT=NULL,
					@commodity_id INT = NULL, 
					@graph CHAR(1)=NULL,					
					--END
					@batch_process_id VARCHAR(50)=NULL,
					@batch_report_param VARCHAR(1000)=NULL,
					@enable_paging INT = 0,  --'1' = enable, '0' = disable
					@page_size INT = NULL,
					@page_no INT = NULL
					
					
AS
SET NOCOUNT ON
---------------------------------------------------------------
/*

declare
@as_of_date varchar(50),
@sub_entity_id varchar(500), 
@strategy_entity_id varchar(100), 
@book_entity_id varchar(100) , 
@discount_option char(1), 
@settlement_option char(1), 
@report_type char(1), 
@summary_option char(1),
@counterparty_id varchar(500), 
@tenor_from varchar(50),
@tenor_to varchar(50),
@previous_as_of_date varchar(50),
@trader_id int,
@include_item char(1),--='n', -- to include item in cash flow hedge
@source_system_book_id1 int, 
@source_system_book_id2 int, 
@source_system_book_id3 int, 
@source_system_book_id4 int, 
@show_firstday_gain_loss char(1),--='n', -- To Show First Day Gain/Loss
@transaction_type VARCHAR(500),
@deal_id_from int,
@deal_id_to int,
@deal_id varchar(100),
@threshold_values float,
@show_prior_processed_values char(1),--='n',
@exceed_threshold_value char(1),--='n',   -- For First Day gain Loss Treatment selection
@show_only_for_deal_date char(1),--='y',
@use_create_date char(1),--='n',
@round_value char(1),-- = '0',
@counterparty char(1),-- = 'a', --i means only internal and e means only external, a means all
@mapped char(1) ,-- = 'm', --m means mapped only, n means non-mapped only,
@match_id char(1),--  = 'n', --'y' means use like for deal ids and 'n' means use 
@cpty_type_id int ,  
@curve_source_id INT,
@deal_sub_type CHAR(1),-- ='t',
@deal_date_from varchar(20),
@deal_date_to varchar(20),
@phy_fin varchar(1),-- ='b',
@deal_type_id int,
@period_report varchar(1),-- ='n',
@term_start VARCHAR(20),
@term_end VARCHAR(20),
@settlement_date_from VARCHAR(20),
@settlement_date_to VARCHAR(20),
@settlement_only CHAR(1),-- ='n',
@drill1 varchar(100),
@drill2 varchar(100),
@drill3 varchar(100),
@drill4 varchar(100),
@drill5 varchar(100),
@batch_process_id varchar(50),
@batch_report_param varchar(1000),
@graph varchar(1),
@drill6 VARCHAR(100),
@commodity_id int,
@risk_bucket_header_id INT,
@risk_bucket_detail_id INT

--exec spa_Create_MTM_Period_Report '2009-12-08', '1', NULL, NULL, 'u', 'a', 'a', 'p',20,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'n','401,400',NULL,NULL,NULL,NULL,'n','n','y','n','2','a','m','n',NULL,4500,'b',NULL, NULL,'b',NULL,'n',NULL,NULL,NULL,NULL,n,NULL,NULL,NULL,NULL,NULL
--exec spa_Create_MTM_Period_Report '2010-11-30', '149', NULL, NULL, 'u', 'a', 'a', 's',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'n'
--,'401,402,400',NULL,NULL,NULL,NULL,'n','n','y','n','2','a','m'
--,'n',NULL,4500,NULL,NULL, NULL,'b',NULL,'n',NULL,NULL,NULL,NULL,n,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'n'
select
@as_of_date='2010-11-30',
@sub_entity_id= '149',
@strategy_entity_id= NULL,
@book_entity_id= NULL,
@discount_option= 'u',
@settlement_option= 'a',
@report_type= 'a',
@summary_option= 's',
@counterparty_id=null,
@tenor_from=NULL,
@tenor_to =NULL,
@previous_as_of_date =NULL,
@trader_id=NULL,
@include_item=NULL,
@source_system_book_id1=NULL,
@source_system_book_id2 =NULL,
@source_system_book_id3=NULL,
@source_system_book_id4 =NULL,
@show_firstday_gain_loss='n',
@transaction_type ='401,400,402',
@deal_id_from =null,
@deal_id_to=NULL,
@deal_id=NULL,
@threshold_values=NULL,
@show_prior_processed_values='n',
@exceed_threshold_value='n',
@show_only_for_deal_date='y',
@use_create_date='n',
@round_value='2',
@counterparty='a',
@mapped='m',
--,'n',NULL,4500,NULL,NULL, NULL,'b',NULL,'n',NULL,NULL,NULL,NULL,n,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'n'

@match_id='n',
@cpty_type_id =NULL,
@curve_source_id=4500,
@deal_sub_type=null,
@deal_date_from =NULL,
@deal_date_to= NULL,
@phy_fin='b',
@deal_type_id =NULL,
@period_report='n',
@term_start=NULL,
@term_end =NULL,
@settlement_date_from =NULL,
@settlement_date_to =NULL,
@settlement_only='n',
@drill1 =null,--'GAS',
@drill2=null,--'Atmos',
@drill3 =NULL,
@drill4 =NULL,
@drill5=NULL,
@graph=NULL,
@drill6=NULL,
@commodity_id=null,
@risk_bucket_header_id=null,
@risk_bucket_detail_id=null --'n'

 set @round_value = '2'

drop table #books

drop table #temp_pnl
drop table #pnl_date
drop table #temp_pnl0
drop table #temp_pnl1
drop table #deal_pnl_detail
drop table #sorttable
drop table #sort_table_3
--*/
-----------------------------------------------------------------
--print convert(varchar(30),getdate(),121)

DECLARE @str_batch_table VARCHAR(8000)
DECLARE @is_batch BIT
DECLARE @sql_paging VARCHAR(8000)
DECLARE @user_login_id VARCHAR(50)
--DECLARE @source_deal_header_list VARCHAR(500)

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
IF @graph IS NULL
	SET @graph='n'

--for phyiscal deal we apply ratio of remaining forward volume balance. n means do not apply
-- uday essent/spm
declare @apply_volume_multiplier_for_physical varchar(1)
set @apply_volume_multiplier_for_physical = 'n'

---FIND OUT IF DETAIL CALC IS NEEDED FOR REPORTING
--0 means save all, 1 means dont save pnl_detail, 2 pnl_detail and settlement
DECLARE @save_pnl_option INT
SELECT  @save_pnl_option =  var_value
FROM         adiha_default_codes_values
WHERE     (instance_no = 1) AND (default_code_id = 39) AND (seq_no = 1)

If @save_pnl_option IS NULL
	set @save_pnl_option = 0

IF @save_pnl_option <> 0 AND (@deal_id_from IS NOT NULL OR @deal_id IS NOT NULL) AND @summary_option='b'
BEGIN
	
	declare @user_id1 varchar(100)
	declare @table_name varchar(100)

	set @user_id1 = dbo.FNADBUser()
	set @table_name=dbo.FNAProcessTableName('temp_mtm_tbl', @user_id1, REPLACE(newid(),'-','_'))

	If @deal_id_from IS NULL AND @deal_id IS NOT NULL
		Select @deal_id_from from source_deal_header where deal_id = @deal_id

	EXEC spa_calc_mtm_job  @sub_entity_id, @strategy_entity_id, @book_entity_id, NULL, @deal_id_from, @as_of_date, 
				@curve_source_id, @curve_source_id, NULL, NULL, NULL, @user_id1, 77, @table_name, NULL, NULL, @settlement_option, 'd'

	exec ('select * from ' + @table_name)

	RETURN
END


--PRINT 'Report Type:' + @report_type 
--PRINT 'Summary Option:' + @summary_option 
--PRINT 'settlement_only:' + @settlement_only

-- 0 means MTM table contains discounted values, 1 means dynamically calculated in measurement or other reporting logic
DECLARE @mtm_value_source INT

SELECT  @mtm_value_source   = var_value 
FROM         adiha_default_codes_values
WHERE     (instance_no = '1') AND (default_code_id = 27) AND (seq_no = 1)
IF @mtm_value_source  IS NULL
	SET @mtm_value_source = 1

-- Unknown: In pre version (before upgrade), the @mtm_value_source is opposit in case statement (1 is used instead 0)
select @mtm_value_source=case when @mtm_value_source=0 then 1 else 0 end 


--########### Find out whether to use Balance of the Month Logic from config Parameter
DECLARE @use_bom_logic INT
SELECT  @use_bom_logic   = var_value 
FROM         adiha_default_codes_values
WHERE     (instance_no = '1') AND (default_code_id = 37) AND (seq_no = 1)

IF @use_bom_logic  IS NULL
	SET @use_bom_logic = 1
  

-- 0 means it is interest rate, 1 means the vale is already discount factor, 2 discount factor provided at deal level
DECLARE @is_discount_curve_a_factor INT
SELECT  @is_discount_curve_a_factor   = var_value 
FROM         adiha_default_codes_values
WHERE     (instance_no = '1') AND (default_code_id = 14) AND (seq_no = 1)
IF @is_discount_curve_a_factor IS NULL
	SET @is_discount_curve_a_factor = 0

IF ( @deal_id_from IS NOT NULL AND @deal_id_to IS NULL )
	SET @deal_id_to = @deal_id_from
ELSE IF ( @deal_id_from IS NULL AND @deal_id_to IS NOT NULL ) 
	SET @deal_id_from = @deal_id_to

DECLARE @Sql VARCHAR(8000)
DECLARE @Sql1 VARCHAR(8000)
DECLARE @sql2 VARCHAR(8000)
DECLARE @SqlG VARCHAR(500)
DECLARE @SqlW VARCHAR(500)
DECLARE @DiscountTableName VARCHAR(128)
DECLARE @DiscountTableName0 VARCHAR(128)

DECLARE @process_id VARCHAR(50)
DECLARE @drill VARCHAR(1)
DECLARE @prior_summary_option VARCHAR(1)

DECLARE @tenor_from_month_year VARCHAR(10),@tenor_to_month_year VARCHAR(10)


SET @drill = 'n'
IF @drill1 IS NOT NULL OR @drill2 IS NOT NULL OR @drill3 IS NOT NULL OR @drill4 IS NOT NULL OR @drill5 IS NOT NULL
BEGIN

	 IF	@summary_option='r'
	BEGIN
		SET @drill5=@drill2
		SET @drill2=NULL

	END
	ELSE IF	@summary_option='q'
	BEGIN
		SET @drill4=@drill2
		SET @drill5=@drill3
		SET @drill2=NULL
		SET @drill3=NULL

	END
	
	ELSE IF	@summary_option='p'
	BEGIN
		SET @drill4=@drill2
		SET @drill2=NULL

	END
	
	SET @prior_summary_option = @summary_option
	SET @summary_option = 'b'
	SET @drill = 'y'
END

IF @drill = 'y' AND @drill6 IS NOT NULL 
BEGIN
	SET @transaction_type = CASE
								WHEN @drill6 = 'Der' THEN 400
								WHEN @drill6 = 'Item' THEN 401
							END 
	SET @drill6 = NULL
END

IF @summary_option='b'  -- for detail always show discounted value
	SET @discount_option='d'


SET @process_id = REPLACE(NEWID(),'-','_')
SET @DiscountTableName = dbo.FNAProcessTableName('calcprocess_discount_factor', dbo.FNADBUser(), @process_id)

--if period value report required
IF  @period_report = 'y' AND @previous_as_of_date IS NOT NULL
BEGIN
	SET @process_id = REPLACE(NEWID(),'-','_')
	SET @DiscountTableName0 = dbo.FNAProcessTableName('calcprocess_discount_factor', dbo.FNADBUser(), @process_id)
END



DECLARE @report_name VARCHAR(100)        



--DECLARE @str_batch_table VARCHAR(MAX)        

--SET @str_batch_table=''
        

--IF @batch_process_id IS NOT NULL  
--BEGIN      
--	SELECT @str_batch_table=dbo.FNABatchProcess('s',@batch_process_id,@batch_report_param,NULL,NULL,NULL)
	   
--END

IF @exceed_threshold_value = 'y'
	SET @discount_option = 'u'

IF @mapped IS NULL
	SET @mapped = 'm'

IF @counterparty IS NULL
	SET @counterparty = 'a'

IF @match_id IS NULL
	SET @match_id = 'n'

IF @settlement_only IS NULL
	SET @settlement_only='n'

SET @SqlW = ''



-- For the Deal sub type filter
DECLARE @deal_sub_type_id INT 

IF @deal_sub_type='t'
	SELECT @deal_sub_type_id=source_deal_type_id FROM source_deal_type WHERE deal_type_id LIKE 'Term'
ELSE IF @deal_sub_type='s'
	SELECT @deal_sub_type_id=source_deal_type_id FROM source_deal_type WHERE deal_type_id LIKE 'Spot'

---######

--If @settlement_date_from IS NOT NULL and @settlement_date_to IS NULL
--	SET @settlement_date_to=@settlement_date_from
--If @settlement_date_from IS NULL and @settlement_date_to IS NOT NULL
--	SET @settlement_date_from=@settlement_date_to

--If @term_start IS NOT NULL and @term_end IS NULL
--	SET @term_end=@term_start
--If @term_start IS NULL and @term_end IS NOT NULL
--	SET @term_start=@term_end


IF @discount_option = 'd'
BEGIN
	EXEC spa_Calc_Discount_Factor @as_of_date, @sub_entity_id, @strategy_entity_id, @book_entity_id, @DiscountTableName
	
	IF @period_report = 'y' AND @previous_as_of_date IS NOT NULL
		EXEC spa_Calc_Discount_Factor @previous_as_of_date, @sub_entity_id, @strategy_entity_id, @book_entity_id, @DiscountTableName0
END

--Make sure PERIOD REPORT only uses regular MTM report
IF @period_report = 'y' AND @previous_as_of_date IS NOT NULL
BEGIN
	SET @show_prior_processed_values = 'n'
	SET @show_only_for_deal_date = 'n'
	SET @show_firstday_gain_loss = 'n'
	SET @exceed_threshold_value = 'n'
	SET @settlement_option = 'f'
END

IF @summary_option = 'm' AND (@deal_id_from IS NOT NULL OR @deal_id_to IS NOT NULL OR @deal_id IS NOT NULL)
BEGIN
	CREATE TABLE [#deal_pnl1](
		[Sub] [VARCHAR](100) COLLATE DATABASE_DEFAULT  NULL,
		[Strategy] [VARCHAR](100) COLLATE DATABASE_DEFAULT  NULL,
		[Book] [VARCHAR](100) COLLATE DATABASE_DEFAULT  NULL,
		[Counterparty] [VARCHAR](100) COLLATE DATABASE_DEFAULT  NULL,
		[DealNumber] [VARCHAR](500) COLLATE DATABASE_DEFAULT  NULL,
		[DealDate] [VARCHAR](50) COLLATE DATABASE_DEFAULT  NULL,
		[PNLDate] [VARCHAR](50) COLLATE DATABASE_DEFAULT  NULL,
		[TYPE] [VARCHAR](8) COLLATE DATABASE_DEFAULT  NULL,
		[Phy/Fin] [VARCHAR](3) COLLATE DATABASE_DEFAULT  NULL,
		[Expiration] [VARCHAR](50) COLLATE DATABASE_DEFAULT  NULL,
		[CumulativeFV] [FLOAT] NULL,
		[term_start] DATETIME NULL, --new clm
		[source_deal_header_id] INT, --new clm
		[pnl_as_of_date] DATETIME --new clm
	)

	CREATE TABLE [#deal_pnl0](
		[Sub] [VARCHAR](100) COLLATE DATABASE_DEFAULT  NULL,
		[Strategy] [VARCHAR](100) COLLATE DATABASE_DEFAULT  NULL,
		[Book] [VARCHAR](100) COLLATE DATABASE_DEFAULT  NULL,
		[Counterparty] [VARCHAR](100) COLLATE DATABASE_DEFAULT  NULL,
		[DealNumber] [VARCHAR](500) COLLATE DATABASE_DEFAULT  NULL,
		[DealDate] [VARCHAR](50) COLLATE DATABASE_DEFAULT  NULL,
		[PNLDate] [VARCHAR](50) COLLATE DATABASE_DEFAULT  NULL,
		[TYPE] [VARCHAR](8) COLLATE DATABASE_DEFAULT  NULL,
		[Phy/Fin] [VARCHAR](3) COLLATE DATABASE_DEFAULT  NULL,
		[Expiration] [VARCHAR](50) COLLATE DATABASE_DEFAULT  NULL,
		[CumulativeFV] [FLOAT] NULL,
		[term_start] DATETIME NULL, --new clm
		[source_deal_header_id] INT, --new clm
		[pnl_as_of_date] DATETIME --new clm
	)

	CREATE TABLE [#deal_pnl](
		[Sub] [VARCHAR](100) COLLATE DATABASE_DEFAULT  NULL,
		[Strategy] [VARCHAR](100) COLLATE DATABASE_DEFAULT  NULL,
		[Book] [VARCHAR](100) COLLATE DATABASE_DEFAULT  NULL,
		[Counterparty] [VARCHAR](100) COLLATE DATABASE_DEFAULT  NULL,
		[DealNumber] [VARCHAR](500) COLLATE DATABASE_DEFAULT  NULL,
		[DealDate] [VARCHAR](50) COLLATE DATABASE_DEFAULT  NULL,
		[PNLDate] [VARCHAR](50) COLLATE DATABASE_DEFAULT  NULL,
		[TYPE] [VARCHAR](8) COLLATE DATABASE_DEFAULT  NULL,
		[Phy/Fin] [VARCHAR](3) COLLATE DATABASE_DEFAULT  NULL,
		[Expiration] [VARCHAR](50) COLLATE DATABASE_DEFAULT  NULL,
		[CumulativeFV] [FLOAT] NULL,
		[term_start] DATETIME NULL, --new clm
		[source_deal_header_id] INT, --new clm
		[pnl_as_of_date] DATETIME --new clm
	)

	DECLARE @save_sql VARCHAR(8000)

	SET @Sql ='
	insert into #deal_pnl1 ([Sub],[Strategy],[Book],[Counterparty],[DealNumber],[DealDate],[PNLDate],
		[Type],[Phy/Fin] ,[Expiration],[CumulativeFV],[term_start],[source_deal_header_id],[pnl_as_of_date])
	select		max(sub.entity_name) Sub, max(stra.entity_name) Strategy, max(book.entity_name) Book,
				max(sc.counterparty_name) Counterparty,
				dbo.FNAHyperLink(10131010,(cast(sdh.source_deal_header_id as varchar) + '' ('' + sdh.deal_id + '')''),sdh.source_deal_header_id,''-1'') DealNumber, 	 
				dbo.FNADateFormat(max(sdh.deal_date)) [DealDate],
				dbo.FNADateFormat(max(sdp.pnl_as_of_date)) [PNLDate],
				max(case when (isnull(sdh.fas_deal_type_value_id,ssbm.fas_deal_type_value_id) IS NULL) then ''Unmapped'' when (isnull(sdh.fas_deal_type_value_id,ssbm.fas_deal_type_value_id) = 400) then ''Der'' else '' Item'' end) [Type], 
				max(case when (sdh.physical_financial_flag = ''p'') then ''Phy'' else ''Fin'' end) [Phy/Fin],
				dbo.FNADateFormat(sdp.term_start) Expiration, ' +
				CASE WHEN @settlement_only='n' THEN CASE WHEN @discount_option = 'u' THEN  ' sum(isnull(und_pnl, 0)) CumulativeFV ' 
					ELSE CASE WHEN (@mtm_value_source = 0) THEN ' sum(isnull(und_pnl, 0) * isNull(df.discount_factor,1)) ' ELSE ' sum(isnull(dis_pnl, 0)) ' END + ' CumulativeFV ' END ELSE ' sum(isnull(und_pnl_set, 0)) CumulativeFV ' END +
				--THE FOLLOWING ARE 3 NEW CLMS
				',sdp.term_start, sdh.source_deal_header_id, max(pnl_as_of_date) pnl_as_of_date
	from		source_deal_header sdh INNER JOIN '
		+	dbo.FNAGetProcessTableName(@as_of_date, CASE WHEN @settlement_only='n' THEN 'source_deal_pnl' ELSE 'source_deal_pnl_settlement' END) + ' 
						sdp on sdh.source_deal_header_id=sdp.source_deal_header_id '
			+CASE WHEN @settlement_only='y' THEN ' AND sdp.term_start=sdp.term_start
			       LEFT JOIN source_deal_detail sdd on sdd.source_deal_header_id=sdh.source_deal_header_id ' 
			 ELSE '' END+
				'
				INNER JOIN
				source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id  LEFT OUTER JOIN
				source_system_book_map ssbm ON sdh.source_system_book_id1 = ssbm.source_system_book_id1 AND 
												sdh.source_system_book_id2 = ssbm.source_system_book_id2 AND 
												sdh.source_system_book_id3 = ssbm.source_system_book_id3 AND 
												sdh.source_system_book_id4 = ssbm.source_system_book_id4 LEFT OUTER JOIN
				portfolio_hierarchy book on book.entity_id = ssbm.fas_book_id LEFT OUTER JOIN
				portfolio_hierarchy stra on stra.entity_id = book.parent_entity_id LEFT OUTER JOIN
				portfolio_hierarchy sub on sub.entity_id = stra.parent_entity_id LEFT OUTER JOIN
				fas_strategy fs on fs.fas_strategy_id = stra.entity_id ' +
				CASE WHEN (@discount_option = 'u') THEN '' ELSE 
					' left outer join ' + @DiscountTableName + ' 	df on ' + 
					CASE WHEN (@is_discount_curve_a_factor IN (2)) THEN ' df.source_deal_header_id = sdp.source_deal_header_id AND df.term_start = sdp.term_start '
					ELSE  ' df.term_start = sdp.term_start AND df.fas_subsidiary_id = sub.entity_id ' END 
				END +
		' Where 1=1 '+
		CASE WHEN @as_of_date IS NULL THEN ''
			ELSE + ' AND sdp.pnl_as_of_date<=''' + CAST(@as_of_date AS VARCHAR) + '''' END
		+ CASE WHEN  @settlement_only='y' THEN ' AND sdd.leg=1 ' ELSE '' END
		+CASE WHEN  @settlement_only='y' AND @as_of_date IS NOT NULL THEN ' AND ISNULL(sdd.settlement_date,sdd.contract_expiration_date)<='''+@as_of_date+'''' ELSE '' END
		+CASE WHEN  @settlement_only='y' AND @settlement_date_from IS NOT NULL THEN ' AND ISNULL(sdd.settlement_date,sdd.contract_expiration_date)>='''+@settlement_date_from+'''' ELSE '' END
		+CASE WHEN  @settlement_only='y' AND @settlement_date_to IS NOT NULL THEN ' AND ISNULL(sdd.settlement_date,sdd.contract_expiration_date)<='''+@settlement_date_to+'''' ELSE '' END
		
-- Added to filter surve source
	+' And ISNULL(NULLIF(sdp.pnl_source_value_id,775),4500)=	'+CAST(@curve_source_id AS VARCHAR)+
	CASE WHEN (@deal_id_from IS NOT NULL AND @match_id = 'n') THEN ' AND sdh.source_deal_header_id BETWEEN ' + CAST(@deal_id_from AS VARCHAR) +' AND ' + CAST(@deal_id_to AS VARCHAR) ELSE '' END +
	CASE WHEN (@deal_id_from IS NOT NULL AND @match_id = 'y') THEN ' AND cast(sdh.source_deal_header_id as varchar) LIKE cast(' + CAST(@deal_id_from AS VARCHAR) + ' as varchar) + ''%''' ELSE '' END +
	CASE WHEN (@deal_id IS NOT NULL AND @match_id = 'n') THEN ' AND sdh.deal_id LIKE ''%' + @deal_id + '%''' ELSE  '' END +
	CASE WHEN (@deal_id IS NOT NULL AND @match_id = 'y') THEN ' AND sdh.deal_id LIKE ''%' + @deal_id + '%''' ELSE  '' END +

'
	group  by sdh.source_deal_header_id, sdh.deal_id, sdp.term_start
	--order by sdh.source_deal_header_id, sdh.deal_id, sdp.term_start
	' 

	--PRINT(@Sql)
	EXEC(@Sql)
--RETURN
	-- save for later use for periodic mtm logic
	SET @save_sql = @Sql
	
	--print convert(varchar(30),getdate(),121)


	IF @settlement_option = 'c' OR @settlement_option = 's' --only run this if settled values required
	BEGIN

		SET @Sql ='
		insert into #deal_pnl1 ([Sub],[Strategy],[Book],[Counterparty],[DealNumber],[DealDate],[PNLDate],
			[Type],[Phy/Fin] ,[Expiration],[CumulativeFV],[term_start],[source_deal_header_id],[pnl_as_of_date])
		SELECT	p.Sub, p.Strategy, p.Book, p.Counterparty, p.DealNumber, p.DealDate,null pnlDate, p.Type,
				p.[Phy/Fin], dbo.FNADateFormat(s.term_start) Expiration,
			 ' +  CASE WHEN (@discount_option = 'd') THEN  CASE WHEN (@mtm_value_source = 0) THEN ' sum(isnull(und_pnl, 0) * isNull(df.discount_factor,1)) ' ELSE ' sum(isnull(dis_pnl, 0)) ' END ELSE ' isnull(s.und_pnl, 0) ' END  + ' CumulativeFV,
				s.term_start, p.source_deal_header_id, s.pnl_as_of_date
		FROM
		(
		select	source_deal_header_id, max(Sub) Sub, max(Strategy) Strategy, max(Book) Book,
				max(Counterparty) Counterparty, max(DealNumber) DealNumber, max(DealDate) DealDate,
				max(PNLDate) PNLDate, max(Type) Type, max([Phy/Fin]) [Phy/Fin], max(Expiration) Expiration,
				max(pnl_as_of_date) pnl_as_of_date
		from	#deal_pnl 
		group by source_deal_header_id
		) p INNER JOIN
		source_deal_pnl_settlement s ON 
			s.source_deal_header_id = p.source_deal_header_id ' +

		CASE WHEN (@settlement_option = 'c') THEN  ' AND s.term_start = ''' +  dbo.FNAGETContractMonth(@as_of_date) + '''' 
		ELSE ' AND s.term_start <= ''' +  dbo.FNAGETContractMonth(@as_of_date) + '''' END +
		' AND s.pnl_as_of_date < p.pnl_as_of_date ' +

		+ CASE WHEN (@discount_option = 'u') THEN '' ELSE 
					' left outer join ' + @DiscountTableName + ' 	df on ' + 
					CASE WHEN (@is_discount_curve_a_factor IN (2)) THEN ' df.source_deal_header_id = s.source_deal_header_id AND df.term_start = s.term_start '
					ELSE  ' df.term_start = s.term_start AND df.fas_subsidiary_id = sub.entity_id ' END 
		END +
		' LEFT OUTER JOIN
		#deal_pnl dp ON dp.source_deal_header_id = s.source_deal_header_id and dp.term_start = s.term_start
		where dp.term_start IS NULL'

		--PRINT(@Sql)
		
		IF @settlement_only='n'
			EXEC(@Sql)

	END

	--now populate prior values if period mtm required
	IF @period_report = 'y' AND @previous_as_of_date IS NOT NULL
	BEGIN

	--print @Sql 
		

		SET @Sql = REPLACE(@Sql, '#deal_pnl1', '#deal_pnl0')
		SET @Sql = REPLACE(@Sql, '''' + @as_of_date + '''', '''' + @previous_as_of_date + '''')
		SET @Sql = REPLACE(@Sql, ' ' + @DiscountTableName + ' ', ' ' + @DiscountTableName0 + ' ')

		EXEC (@Sql)

		INSERT INTO #deal_pnl
		SELECT	COALESCE(c.Sub, p.Sub) Sub,
				COALESCE(c.Strategy, p.Strategy) Strategy,
				COALESCE(c.Book, p.Book) Book,
				COALESCE(c.Counterparty, p.Counterparty) Counterparty,
				COALESCE(c.[DealNumber], p.[DealNumber]) [DealNumber],
				COALESCE(c.[DealDate], p.[DealDate]) [DealDate],
				COALESCE(c.PNLDate, p.PNLDate) PNLDate,
				COALESCE(c.[Type], p.[Type]) [TYPE],
				COALESCE(c.[Phy/Fin], p.[Phy/Fin]) [Phy/Fin],
				COALESCE(c.[Expiration], p.[Expiration]) [Expiration],
				ISNULL(c.[CumulativeFV], 0) - ISNULL(p.[CumulativeFV], 0) [CumulativeFV],
				COALESCE(c.term_start, p.term_start) term_start,
				COALESCE(c.source_deal_header_id, p.source_deal_header_id) source_deal_header_id,
				COALESCE(c.pnl_as_of_date, p.pnl_as_of_date) pnl_as_of_date
	 
		FROM #deal_pnl1 c FULL OUTER JOIN 
			 #deal_pnl0 p ON
			c.source_deal_header_id = p.source_deal_header_id AND	
			c.term_start = p.term_start 

	END

	SET @Sql ='	select [Sub],[Strategy],[Book],[Counterparty],[DealNumber],[DealDate],[PNLDate],
		[Type],[Phy/Fin] ,dbo.FNADateFormat(Expiration) [Expiration],[CumulativeFV]' + ' ' + @str_batch_table + ' from ' + 
		CASE WHEN (@period_report = 'y' AND @previous_as_of_date IS NOT NULL) THEN ' #deal_pnl ' ELSE ' #deal_pnl1 '  END

	EXEC(@Sql)


--*****************FOR BATCH PROCESSING**********************************            

	IF  @batch_process_id IS NOT NULL        

	BEGIN        

	 SELECT @str_batch_table=dbo.FNABatchProcess('u',@batch_process_id,@batch_report_param,GETDATE(),NULL,NULL)         

	 EXEC(@str_batch_table)        

	IF @settlement_only='y'
	SET @report_name='Run Settlement Report'        
	ELSE 
	 SET @report_name='Run MTM Report'        

	        

	 SELECT @str_batch_table=dbo.FNABatchProcess('c',@batch_process_id,@batch_report_param,GETDATE(),'spa_Create_MTM_Period_Report',@report_name)         

	 EXEC(@str_batch_table)        

	        

	END        



--********************************************************************   

	RETURN

END



DECLARE @Sql_SelectB VARCHAR(5000)        

DECLARE @Sql_WhereB VARCHAR(5000)        

DECLARE @assignment_type INT        

        

SET @Sql_WhereB = ''        



CREATE TABLE #books (fas_book_id INT,source_system_book_id1 INT,
source_system_book_id2 INT,
source_system_book_id3 INT,
source_system_book_id4 INT,	fas_deal_type_value_id INT 

) 



SET @Sql_SelectB=        

'INSERT INTO  #books 
(fas_book_id ,source_system_book_id1 ,source_system_book_id2 ,source_system_book_id3 ,source_system_book_id4 ,	fas_deal_type_value_id ) 
	SELECT distinct book.entity_id fas_book_id,source_system_book_id1,source_system_book_id2 ,source_system_book_id3 ,source_system_book_id4 ,	fas_deal_type_value_id
	 FROM portfolio_hierarchy book (nolock) INNER JOIN
		Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id LEFT OUTER JOIN            
		source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id         
		WHERE (fas_deal_type_value_id IS NULL OR fas_deal_type_value_id BETWEEN 400 AND 401) 

'   

              

IF @sub_entity_id IS NOT NULL        
  SET @Sql_WhereB = @Sql_WhereB + ' AND stra.parent_entity_id IN  ( ' + @sub_entity_id + ') '         
IF @strategy_entity_id IS NOT NULL        
  SET @Sql_WhereB = @Sql_WhereB + ' AND (stra.entity_id IN(' + @strategy_entity_id + ' ))'        
IF @book_entity_id IS NOT NULL        
  SET @Sql_WhereB = @Sql_WhereB + ' AND (book.entity_id IN(' + @book_entity_id + ')) '        

        

SET @Sql_SelectB=@Sql_SelectB+@Sql_WhereB        

         
--PRINT (@Sql_SelectB)
EXEC (@Sql_SelectB)
CREATE TABLE #temp_pnl
(
	Sub VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	Strategy VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	Book VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	source_deal_header_id INT,
	deal_id VARCHAR(50) COLLATE DATABASE_DEFAULT ,
	term_start DATETIME,
	hedge_or_item VARCHAR(5) COLLATE DATABASE_DEFAULT ,
	counterparty_name VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	pnl FLOAT,
	first_day_pnl_threshold FLOAT,
	pnl_as_of_date DATETIME,
	deal_date DATETIME,
	physical_financial_flag VARCHAR(1) COLLATE DATABASE_DEFAULT ,
	sbm1 VARCHAR(50) COLLATE DATABASE_DEFAULT ,
	sbm2 VARCHAR(50) COLLATE DATABASE_DEFAULT ,
	sbm3 VARCHAR(50) COLLATE DATABASE_DEFAULT ,
	sbm4 VARCHAR(50) COLLATE DATABASE_DEFAULT ,
	fas_deal_type_value_id INT ,
	sub_id INT,
	volume FLOAT,
	term_end DATETIME,
	block_type INT,
	block_definition_id INT

)

CREATE TABLE #temp_pnl0
(
	Sub VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	Strategy VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	Book VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	source_deal_header_id INT,
	deal_id VARCHAR(50) COLLATE DATABASE_DEFAULT ,
	term_start DATETIME,
	hedge_or_item VARCHAR(5) COLLATE DATABASE_DEFAULT ,
	counterparty_name VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	pnl FLOAT,
	first_day_pnl_threshold FLOAT,
	pnl_as_of_date DATETIME,
	deal_date DATETIME,
	physical_financial_flag VARCHAR(1) COLLATE DATABASE_DEFAULT ,
	sbm1 VARCHAR(50) COLLATE DATABASE_DEFAULT ,
	sbm2 VARCHAR(50) COLLATE DATABASE_DEFAULT ,
	sbm3 VARCHAR(50) COLLATE DATABASE_DEFAULT ,
	sbm4 VARCHAR(50) COLLATE DATABASE_DEFAULT ,
	fas_deal_type_value_id INT ,
	sub_id INT,
	volume FLOAT,
	term_end DATETIME,
	block_type INT,
	block_definition_id INT,
	deal_volume_frequency VARCHAR(1) COLLATE DATABASE_DEFAULT ,
	multiplier float,
	volume_multiplier2 FLOAT,
	total_volume float
)

CREATE TABLE #temp_pnl1
(
	Sub VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	Strategy VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	Book VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	source_deal_header_id INT,
	deal_id VARCHAR(50) COLLATE DATABASE_DEFAULT ,
	term_start DATETIME,
	hedge_or_item VARCHAR(5) COLLATE DATABASE_DEFAULT ,
	counterparty_name VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	pnl FLOAT,
	first_day_pnl_threshold FLOAT,
	pnl_as_of_date DATETIME,
	deal_date DATETIME,
	physical_financial_flag VARCHAR(1) COLLATE DATABASE_DEFAULT ,
	sbm1 VARCHAR(50) COLLATE DATABASE_DEFAULT ,
	sbm2 VARCHAR(50) COLLATE DATABASE_DEFAULT ,
	sbm3 VARCHAR(50) COLLATE DATABASE_DEFAULT ,
	sbm4 VARCHAR(50) COLLATE DATABASE_DEFAULT ,
	fas_deal_type_value_id INT ,
	sub_id INT,
	volume FLOAT,
	term_end DATETIME,
	block_type INT,
	block_definition_id INT,
	deal_volume_frequency CHAR(1) COLLATE DATABASE_DEFAULT ,
multiplier float,
volume_multiplier2 FLOAT,
total_volume float
)


CREATE TABLE #pnl_date
(
	source_deal_header_id INT,
	fas_deal_type_value_id INT, 
	pnl_as_of_date DATETIME,
	fas_book_id INT,
	term_start DATETIME,
	Sub VARCHAR(150) COLLATE DATABASE_DEFAULT , 
	Strategy VARCHAR(150) COLLATE DATABASE_DEFAULT ,
	Book VARCHAR(150) COLLATE DATABASE_DEFAULT , 
	counterparty_name VARCHAR(150) COLLATE DATABASE_DEFAULT , 
	deal_date DATETIME,
	physical_financial_flag VARCHAR(1) COLLATE DATABASE_DEFAULT ,
	sbm1 VARCHAR(150) COLLATE DATABASE_DEFAULT , 
	sbm2 VARCHAR(150) COLLATE DATABASE_DEFAULT , 
	sbm3 VARCHAR(150) COLLATE DATABASE_DEFAULT , 
	sbm4 VARCHAR(150) COLLATE DATABASE_DEFAULT , 
	sub_id int,
	block_type int,
	block_definition_id int,
	source_system_book_id1 INT,
	source_system_book_id2 INT,
	source_system_book_id3 INT,
	source_system_book_id4 INT,
	deal_id VARCHAR(150) COLLATE DATABASE_DEFAULT 
)	


DECLARE @pnl_table_name VARCHAR(50)
IF @settlement_only='y'
BEGIN
	SET @Sql = '
	insert into #pnl_date (source_deal_header_id ,fas_deal_type_value_id , pnl_as_of_date ,fas_book_id ,term_start 
		, counterparty_name, deal_date,physical_financial_flag, block_type ,block_definition_id ,source_system_book_id1 ,
		source_system_book_id2 ,source_system_book_id3 ,source_system_book_id4 ,deal_id
		)
	select	sdh.source_deal_header_id, max(isnull(sdh.fas_deal_type_value_id,b.fas_deal_type_value_id)) fas_deal_type_value_id, '''+@as_of_date+''' pnl_as_of_date, 
			max(b.fas_book_id) fas_book_id,sdd.term_start AS term_start
			, max(sc.counterparty_name) counterparty_name, max(sdh.deal_date),max(sdh.physical_financial_flag)
			, max(sdh.block_type) ,max(sdh.block_define_id ),max(sdh.source_system_book_id1) ,
			max(sdh.source_system_book_id2) ,max(sdh.source_system_book_id3) ,max(sdh.source_system_book_id4) ,max(sdh.deal_id )
			from	#books b INNER JOIN
			source_deal_header sdh ON sdh.source_system_book_id1 = b.source_system_book_id1 AND 
				sdh.source_system_book_id2 = b.source_system_book_id2 AND 
				sdh.source_system_book_id3 = b.source_system_book_id3 AND 
				sdh.source_system_book_id4 = b.source_system_book_id4  
			LEFT JOIN source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
			INNER JOIN source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id 
			INNER JOIN portfolio_hierarchy bk on bk.entity_id = b.fas_book_id INNER JOIN 
			fas_strategy fs on fs.fas_strategy_id = bk.parent_entity_id 
	'
	SET @SqlG = ' group by sdh.source_deal_header_id,sdd.term_start'
	SET @SqlW = ' WHERE 1 = 1 
				AND sdd.leg=1 
				AND ISNULL(sdd.settlement_date,sdd.contract_expiration_date)<='''+@as_of_date+''''
				+CASE WHEN @settlement_date_from IS NOT NULL THEN ' AND ISNULL(sdd.settlement_date,sdd.contract_expiration_date)>='''+@settlement_date_from+'''' ELSE '' END
				+CASE WHEN @settlement_date_to IS NOT NULL THEN ' AND ISNULL(sdd.settlement_date,sdd.contract_expiration_date)<='''+@settlement_date_to+'''' ELSE '' END

	SET @pnl_table_name = 'source_deal_pnl_settlement'
	SET @transaction_type = NULL

END
ELSE IF @mapped = 'n'
BEGIN
	SET @Sql = '
	insert into #pnl_date (source_deal_header_id ,fas_deal_type_value_id , pnl_as_of_date ,fas_book_id ,term_start
		, counterparty_name, deal_date,physical_financial_flag, block_type ,block_definition_id ,source_system_book_id1 ,
		source_system_book_id2 ,source_system_book_id3 ,source_system_book_id4 ,deal_id
	 )
	select	sdh.source_deal_header_id, NULL fas_deal_type_value_id, ''' + @as_of_date + ''' pnl_as_of_date, NULL fas_book_id,NULL AS term_start
			, max(sc.counterparty_name) counterparty_name, max(sdh.deal_date),max(sdh.physical_financial_flag)
			, max(sdh.block_type) ,max(sdh.block_define_id ),max(sdh.source_system_book_id1) ,
			max(sdh.source_system_book_id2) ,max(sdh.source_system_book_id3) ,max(sdh.source_system_book_id4) ,max(sdh.deal_id )
	from	source_deal_header sdh INNER JOIN			
			source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id LEFT OUTER JOIN
			source_system_book_map b ON sdh.source_system_book_id1 = b.source_system_book_id1 AND 
				sdh.source_system_book_id2 = b.source_system_book_id2 AND 
				sdh.source_system_book_id3 = b.source_system_book_id3 AND 
				sdh.source_system_book_id4 = b.source_system_book_id4 
	WHERE	b.fas_book_id IS NULL
	'
	SET @SqlG = ' group by sdh.source_deal_header_id'
	SET @pnl_table_name = dbo.FNAGetProcessTableName(@as_of_date, 'source_deal_pnl')
	SET @transaction_type = NULL
END
ELSE IF ISNULL(@show_prior_processed_values, 'n') = 'y'
BEGIN
	SET @Sql = '
	insert into #pnl_date (source_deal_header_id ,fas_deal_type_value_id , pnl_as_of_date ,fas_book_id ,term_start
		, counterparty_name, deal_date,physical_financial_flag, block_type ,block_definition_id ,source_system_book_id1 ,
		source_system_book_id2 ,source_system_book_id3 ,source_system_book_id4 ,deal_id
	 )
	select	sdh.source_deal_header_id, max(isnull(sdh.fas_deal_type_value_id,b.fas_deal_type_value_id)) fas_deal_type_value_id, max(fdld.deal_date) pnl_as_of_date, 
			max(b.fas_book_id) fas_book_id,NULL AS term_start
			, max(sc.counterparty_name) counterparty_name, max(sdh.deal_date),max(sdh.physical_financial_flag)
			, max(sdh.block_type) ,max(sdh.block_define_id ),max(sdh.source_system_book_id1) ,
			max(sdh.source_system_book_id2) ,max(sdh.source_system_book_id3) ,max(sdh.source_system_book_id4) ,max(sdh.deal_id )
	from	#books b INNER JOIN
			source_deal_header sdh ON sdh.source_system_book_id1 = b.source_system_book_id1 AND 
				sdh.source_system_book_id2 = b.source_system_book_id2 AND 
				sdh.source_system_book_id3 = b.source_system_book_id3 AND 
				sdh.source_system_book_id4 = b.source_system_book_id4  INNER JOIN			
			source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id INNER JOIN
			first_Day_gain_loss_decision fdld ON fdld.source_deal_header_id = sdh.source_deal_header_id   INNER JOIN
			portfolio_hierarchy bk on bk.entity_id = b.fas_book_id INNER JOIN 
			fas_strategy fs on fs.fas_strategy_id = bk.parent_entity_id 
	'
	SET @SqlG = ' group by sdh.source_deal_header_id '
	SET @SqlW = ' WHERE 1 = 1 '
	SET @pnl_table_name = 'source_deal_pnl'
	SET @transaction_type = NULL
END
ELSE IF (ISNULL(@show_firstday_gain_loss, 'n') = 'y' OR ISNULL(@exceed_threshold_value, 'n') = 'y') AND ISNULL(@show_only_for_deal_date, 'n') = 'y'
BEGIN
	SET @Sql = '
	insert into #pnl_date (source_deal_header_id ,fas_deal_type_value_id , pnl_as_of_date ,fas_book_id ,term_start 
		, counterparty_name, deal_date,physical_financial_flag, block_type ,block_definition_id ,source_system_book_id1 ,
		source_system_book_id2 ,source_system_book_id3 ,source_system_book_id4 ,deal_id
	)
	select	sdh.source_deal_header_id, max(isnull(sdh.fas_deal_type_value_id,b.fas_deal_type_value_id)) fas_deal_type_value_id, max(deal_date) pnl_as_of_date, 
			max(b.fas_book_id) fas_book_id,NULL AS term_start
			, max(sc.counterparty_name) counterparty_name, max(sdh.deal_date),max(sdh.physical_financial_flag)
			, max(sdh.block_type) ,max(sdh.block_define_id ),max(sdh.source_system_book_id1) ,
			max(sdh.source_system_book_id2) ,max(sdh.source_system_book_id3) ,max(sdh.source_system_book_id4) ,max(sdh.deal_id )
	from	#books b INNER JOIN
			source_deal_header sdh on sdh.source_system_book_id1 = b.source_system_book_id1 AND 
				sdh.source_system_book_id2 = b.source_system_book_id2 AND 
				sdh.source_system_book_id3 = b.source_system_book_id3 AND 
				sdh.source_system_book_id4 = b.source_system_book_id4 INNER JOIN
			source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id INNER JOIN
			portfolio_hierarchy bk on bk.entity_id = b.fas_book_id INNER JOIN 
			fas_strategy fs on fs.fas_strategy_id = bk.parent_entity_id 
	where (isnull(''' + @exceed_threshold_value + ''', ''n'') = ''n'' OR isnull(sdh.fas_deal_type_value_id,b.fas_deal_type_value_id) BETWEEN 400 AND 401) AND sc.int_ext_flag = ''e''
	'
	SET @SqlG = 'group by sdh.source_deal_header_id '
	SET @pnl_table_name = 'source_deal_pnl'
	SET @transaction_type = NULL
END
ELSE IF (ISNULL(@show_firstday_gain_loss, 'n') = 'y' OR ISNULL(@exceed_threshold_value, 'n') = 'y') AND @show_only_for_deal_date = 'n'
BEGIN
	SET @Sql = '
	insert into #pnl_date (source_deal_header_id ,fas_deal_type_value_id , pnl_as_of_date ,fas_book_id ,term_start 
		, counterparty_name, deal_date,physical_financial_flag, block_type ,block_definition_id ,source_system_book_id1 ,
		source_system_book_id2 ,source_system_book_id3 ,source_system_book_id4 ,deal_id
	)
	select	sdp.source_deal_header_id, max(isnull(sdh.fas_deal_type_value_id,b.fas_deal_type_value_id)) fas_deal_type_value_id, min(pnl_as_of_date) pnl_as_of_date, max(b.fas_book_id) fas_book_id,NULL AS term_start
			, max(sc.counterparty_name) counterparty_name, max(sdh.deal_date),max(sdh.physical_financial_flag)
			, max(sdh.block_type) ,max(sdh.block_define_id ),max(sdh.source_system_book_id1) ,
			max(sdh.source_system_book_id2) ,max(sdh.source_system_book_id3) ,max(sdh.source_system_book_id4) ,max(sdh.deal_id )
	from	#books b INNER JOIN
			source_deal_header sdh on sdh.source_system_book_id1 = b.source_system_book_id1 AND 
				sdh.source_system_book_id2 = b.source_system_book_id2 AND 
				sdh.source_system_book_id3 = b.source_system_book_id3 AND 
				sdh.source_system_book_id4 = b.source_system_book_id4 INNER JOIN
--			source_deal_detail sdd on sdd.source_deal_header_id=sdh.source_deal_header_id	AND
--						sdd.leg = 1 INNER JOIN
			source_deal_pnl sdp on	'+--sdd.term_start = sdp.term_start and
								--sdd.term_end = sdp.term_end and 
									--sdd.leg = sdp.leg  and
									' sdh.source_deal_header_id = sdp.source_deal_header_id and
									sdp.pnl_as_of_date >= sdh.deal_date INNER JOIN
			source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id INNER JOIN
			portfolio_hierarchy bk on bk.entity_id = b.fas_book_id INNER JOIN 
			fas_strategy fs on fs.fas_strategy_id = bk.parent_entity_id 
	where (isnull(''' + @exceed_threshold_value + ''', ''n'') = ''n'' OR isnull(sdh.fas_deal_type_value_id,b.fas_deal_type_value_id) BETWEEN 400 AND 401) AND sc.int_ext_flag = ''e''
	'

	SET @SqlG = 'group by sdp.source_deal_header_id '
	SET @pnl_table_name = 'source_deal_pnl'
	SET @transaction_type = NULL
END
ELSE
BEGIN
	SET @Sql = '
	insert into #pnl_date (source_deal_header_id ,fas_deal_type_value_id , pnl_as_of_date ,fas_book_id ,term_start 
		, counterparty_name, deal_date,physical_financial_flag, block_type ,block_definition_id ,source_system_book_id1 ,
		source_system_book_id2 ,source_system_book_id3 ,source_system_book_id4 ,deal_id
	)
	select	source_deal_header_id, max(isnull(sdh.fas_deal_type_value_id,b.fas_deal_type_value_id)) fas_deal_type_value_id, ''' + @as_of_date + ''' pnl_as_of_date, 
			max(b.fas_book_id) fas_book_id,NULL AS term_start
			, max(sc.counterparty_name) counterparty_name, max(sdh.deal_date),max(sdh.physical_financial_flag)
			, max(sdh.block_type) ,max(sdh.block_define_id ),max(sdh.source_system_book_id1) ,
			max(sdh.source_system_book_id2) ,max(sdh.source_system_book_id3) ,max(sdh.source_system_book_id4),max(sdh.deal_id )
	from	#books b INNER JOIN
			source_deal_header sdh on sdh.source_system_book_id1 = b.source_system_book_id1 AND 
				sdh.source_system_book_id2 = b.source_system_book_id2 AND 
				sdh.source_system_book_id3 = b.source_system_book_id3 AND 
				sdh.source_system_book_id4 = b.source_system_book_id4  INNER JOIN			
			source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id INNER JOIN
			portfolio_hierarchy bk on bk.entity_id = b.fas_book_id INNER JOIN 
			fas_strategy fs on fs.fas_strategy_id = bk.parent_entity_id 
	'
	SET @SqlG = 'group by sdh.source_deal_header_id '
	SET @SqlW = ' WHERE 1 = 1 '

	SET @pnl_table_name = dbo.FNAGetProcessTableName(@as_of_date, 'source_deal_pnl')

END

SET @Sql = @Sql + @SqlW

--NOW APPLY FILTERS AT DEAL LEVEL
IF (ISNULL(@show_prior_processed_values, 'n') <> 'y' AND @deal_id_from IS NULL AND @deal_id_to IS NULL AND @deal_id IS NULL)

BEGIN

	IF @use_create_date = 'y' AND @previous_as_of_date IS NOT NULL
		SET @Sql = @Sql + ' AND dbo.FNAConvertTZAwareDateFormat(sdh.create_ts,1) between ''' + @previous_as_of_date  + ''' AND ''' + @as_of_date + ''''
		--SET @Sql = @Sql + ' AND sdh.create_ts between ''' + @previous_as_of_date  + ''' AND ''' + @as_of_date + ''''
	ELSE IF ISNULL(@exceed_threshold_value, 'n') = 'y' AND @previous_as_of_date IS NOT NULL
		SET @Sql = @Sql + ' AND sdh.deal_date between ''' + @previous_as_of_date  + ''' AND ''' + @as_of_date + ''''

END

IF @trader_id IS NOT NULL 
   	SET @Sql = @Sql + ' AND sdh.trader_id IN (' + CAST(@trader_id AS VARCHAR) + ') '
IF @deal_type_id IS NOT NULL 
   	SET @Sql = @Sql + ' AND sdh.source_deal_type_id = ' + CAST(@deal_type_id AS VARCHAR)
IF @deal_sub_type_id IS NOT NULL 
   	SET @Sql = @Sql + ' AND sdh.deal_sub_type_type_id = ' + CAST(@deal_sub_type_id AS VARCHAR)
IF @counterparty_id IS NOT NULL 
   	SET @Sql = @Sql + + ' AND (sdh.counterparty_id IN (' + @counterparty_id + ')) '
IF @source_system_book_id1 IS NOT NULL 
   	SET @Sql = @Sql +  ' AND (sdh.source_system_book_id1 =' + CAST(@source_system_book_id1 AS VARCHAR)+ ') '
IF @source_system_book_id2 IS NOT NULL 
   	SET @Sql = @Sql +  ' AND (sdh.source_system_book_id2 =' + CAST(@source_system_book_id2 AS VARCHAR) + ') '
IF @source_system_book_id3 IS NOT NULL 
   	SET @Sql = @Sql +  ' AND (sdh.source_system_book_id3 =' + CAST(@source_system_book_id3 AS VARCHAR) + ') '
IF @source_system_book_id4 IS NOT NULL 
   	SET @Sql = @Sql +  ' AND (sdh.source_system_book_id4 =' + CAST(@source_system_book_id4 AS VARCHAR) + ') '

IF @commodity_id IS NOT NULL 
	SET @Sql = @Sql +  '
						AND (sdh.source_deal_header_id IN (
							SELECT DISTINCT sdh.source_deal_header_id
							FROM   source_deal_header sdh
								INNER JOIN source_deal_detail sdd ON  sdh.source_deal_header_id = sdd.source_deal_header_id
								INNER JOIN source_price_curve_def spcd ON  sdd.curve_id = spcd.source_curve_def_id
								WHERE  spcd.commodity_id IN (' + CAST(@commodity_id AS VARCHAR) + ')))'   	


--if @deal_sub_type<>'b'
--	SET @Sql = @Sql +  ' AND (sdh.deal_sub_type_type_id IN (' + cast(@deal_sub_type as varchar) + ')) '

IF @mapped = 'm' AND ISNULL(@counterparty, 'a') <> 'a'
   	SET @Sql = @Sql + + ' AND sc.int_ext_flag = ''' + @counterparty + ''''

IF @cpty_type_id IS NOT NULL
   	SET @Sql = @Sql + + ' AND sc.type_of_entity = ' + CAST(@cpty_type_id AS VARCHAR) 

IF @transaction_type IS NOT NULL 
	SET @Sql = @Sql +  ' AND isnull(sdh.fas_deal_type_value_id,b.fas_deal_type_value_id) IN( ' + CAST(@transaction_type AS VARCHAR(500))+')'

--If @deal_date_from IS NOT NULL AND @deal_date_to IS NOT NULL
--	SET @Sql = @Sql + ' AND sdh.deal_date between ''' + @deal_date_from  + ''' AND ''' + @deal_date_to + ''''

--Deal Date Filter applied

	IF (@deal_date_from IS NOT NULL)
			SET @Sql = @Sql +' AND convert(varchar(10),sdh.deal_date,120)>='''+CONVERT(VARCHAR(10),@deal_date_from,120) +''''

	IF (@deal_date_to IS NOT NULL)
		SET @Sql = @Sql +' AND convert(varchar(10),sdh.deal_date,120) <='''+CONVERT(VARCHAR(10),@deal_date_to,120) +''''
	
	IF (@deal_id_from IS NOT NULL AND @match_id = 'n')
	BEGIN
		SET @Sql = @Sql +  ' AND sdh.source_deal_header_id BETWEEN ' + CAST(@deal_id_from AS VARCHAR) +' AND ' + CAST(@deal_id_to AS VARCHAR)
	END
	
	IF (@deal_id_from IS NOT NULL AND @match_id = 'y')
	BEGIN
		SET @Sql = @Sql +  ' AND cast(sdh.source_deal_header_id as varchar) LIKE cast(' + CAST(@deal_id_from AS VARCHAR) + ' as varchar) + ''%'''
	END
	
	IF (@deal_id IS NOT NULL AND @match_id = 'n')
	BEGIN
		SET @Sql = @Sql +  ' AND sdh.deal_id LIKE ''%' + @deal_id + '%'''
	END
	
	IF (@deal_id IS NOT NULL AND @match_id = 'y')
	BEGIN
		SET @Sql = @Sql +  ' AND sdh.deal_id LIKE ''%' + @deal_id + '%'''
	END






IF ISNULL(@phy_fin, 'b') <> 'b'
   	SET @Sql = @Sql + + ' AND sdh.physical_financial_flag = ''' + @phy_fin + ''''
					
IF @mapped = 'm'
BEGIN
	IF @report_type = 'c' 
		SET @Sql = @Sql +  ' AND fs.hedge_type_value_id = 150 '
	ELSE IF @report_type = 'f'
		SET @Sql = @Sql +  ' AND fs.hedge_type_value_id = 151 '
	ELSE IF @report_type = 'm'
		SET @Sql = @Sql +  ' AND fs.hedge_type_value_id = 152 '
	ELSE IF @report_type = 'n'
		SET @Sql = @Sql +  ' AND fs.hedge_type_value_id = 153 '
	ELSE
		IF @settlement_only='n'
			SET @Sql = @Sql +  ' AND fs.hedge_type_value_id BETWEEN 150 AND 152 '

END

--SET @Sql = @Sql + 
--	case when (@deal_id_from is not null and @match_id = 'n') then ' AND sdh.source_deal_header_id BETWEEN ' + cast(@deal_id_from as varchar) +' AND ' + CAST(@deal_id_to AS VARCHAR) else '' end +
--	case when (@deal_id_from is not null and @match_id = 'y') then ' AND cast(sdh.source_deal_header_id as varchar) LIKE cast(' + cast(@deal_id_from as varchar) + ' as varchar) + ''%''' else '' end +
--	case when (@deal_id is not null and @match_id = 'n') then ' AND sdh.deal_id = ''' + @deal_id + '''' else  '' end +
--	case when (@deal_id is not null and @match_id = 'y') then ' AND sdh.deal_id LIKE ''' + @deal_id + '%''' else  '' end 

--print convert(varchar(30),getdate(),121)

--PRINT @Sql + @SqlG



EXEC(@Sql + @SqlG)
--exec spa_Create_MTM_Period_Report '2008-05-18', '291,30,1,257,258,256', NULL, NULL, 'u', 'a', 'a', 'd',NULL,NULL,NULL,'2008-05-18',NULL,NULL,NULL,NULL,NULL,NULL,'y',400,NULL,NULL,NULL,NULL,'y','y','y','y'
--print convert(varchar(30),getdate(),121)


CREATE INDEX [indx_pnl_date] ON #pnl_date(source_deal_header_id)
CREATE INDEX [indx_pnl_date2] ON #pnl_date( pnl_as_of_date)
CREATE INDEX [indx_pnl_date1] ON #pnl_date(fas_book_id)
CREATE INDEX [indx_pnl_date3] ON #pnl_date(source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4)

SET @Sql = 

'INSERT INTO #temp_pnl1
select	
		max(sub.entity_name) Sub, max(stra.entity_name) Strategy, max(book.entity_name) Book,
		pd.source_deal_header_id, max(pd.deal_id) deal_id, 
		sdp.term_start, 
		case when (max(pd.fas_deal_type_value_id) = 400) then ''Der'' else ''Item'' end hedge_or_item, 
		max(pd.counterparty_name) counterparty_name,
		'+CASE WHEN @settlement_only='n' THEN CASE WHEN (@discount_option = 'd') THEN  CASE WHEN (@mtm_value_source = 0) THEN ' sum(isnull(und_pnl, 0) * isNull(df.discount_factor,1)) ' ELSE ' sum(isnull(dis_pnl, 0)) ' END ELSE ' sum(isnull(und_pnl, 0)) ' END  ELSE 'SUM(ISNULL(sdp.und_pnl_set,0))' END +' und_pnl,
		max(isnull(first_day_pnl_threshold, 0)) first_day_pnl_threshold,
		max(pd.pnl_as_of_date) pnl_as_of_date,
		max(pd.deal_date) deal_date,
		max(pd.physical_financial_flag) physical_financial_flag,
		MAX(CASE WHEN (sb1.source_book_id < 0) THEN NULL ELSE sb1.source_system_book_id END) sbm1,
		MAX(CASE WHEN (sb2.source_book_id < 0) THEN NULL ELSE sb2.source_system_book_id END) sbm2,
		MAX(CASE WHEN (sb3.source_book_id < 0) THEN NULL ELSE sb3.source_system_book_id END) sbm3,
		MAX(CASE WHEN (sb4.source_book_id < 0) THEN NULL ELSE sb4.source_system_book_id END) sbm4,
		MAX(pd.fas_deal_type_value_id) fas_deal_type_value_id,max(sub.entity_id) sub_id,
		MAX(sdp.deal_volume),
		MAX(sdp.term_end),
		MAX(ISNULL(spcd.block_type,pd.block_type))block_type,
		MAX(ISNULL(spcd.block_define_id,pd.block_definition_id)) block_definition_id,
		MAX(sdd.deal_volume_frequency) deal_volume_frequency,
		max(multiplier) multiplier,
		max(volume_multiplier2) volume_multiplier2 ,
		max(total_volume) total_volume

from	#pnl_date pd 
--		INNER JOIN source_deal_header sdh (nolock) on sdh.source_deal_header_id = pd.source_deal_header_id
		LEFT OUTER JOIN
		portfolio_hierarchy book (nolock) on book.entity_id = pd.fas_book_id LEFT OUTER JOIN
		portfolio_hierarchy stra(nolock)  on stra.entity_id = book.parent_entity_id LEFT OUTER JOIN
		portfolio_hierarchy sub (nolock) on sub.entity_id = stra.parent_entity_id LEFT OUTER JOIN
		fas_strategy fs (nolock) on fs.fas_strategy_id = stra.entity_id 
	--	LEFT OUTER JOIN		source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id 
		LEFT OUTER JOIN
		source_book sb1 (nolock) ON sb1.source_book_id = pd.source_system_book_id1 LEFT OUTER JOIN
		source_book sb2  (nolock) ON sb2.source_book_id = pd.source_system_book_id2 LEFT OUTER JOIN
		source_book sb3 (nolock) ON sb3.source_book_id = pd.source_system_book_id3 LEFT OUTER JOIN
		source_book sb4 (nolock) ON sb4.source_book_id = pd.source_system_book_id4 LEFT OUTER JOIN
		' + @pnl_table_name + ' sdp (nolock) on	'+
								' pd.source_deal_header_id = sdp.source_deal_header_id '
								+CASE WHEN @settlement_only='n' THEN 
								' AND pd.pnl_as_of_date = sdp.pnl_as_of_date ' ELSE '' END
								+CASE WHEN @settlement_only='y' THEN ' AND pd.term_start = sdp.term_start ' ELSE '' END+

		+' LEFT OUTER JOIN source_deal_detail sdd (nolock) on sdd.source_deal_header_id=pd.source_deal_header_id
				AND sdd.term_start=sdp.term_start and sdd.leg=1
		   LEFT OUTER JOIN source_price_curve_def spcd (nolock) ON sdd.curve_id=spcd.source_curve_def_id	'+	
	

CASE WHEN (@discount_option = 'u') THEN '' ELSE 
		' left outer join ' + @DiscountTableName + ' 	df on ' + 
		CASE WHEN (@is_discount_curve_a_factor IN (2)) THEN ' df.source_deal_header_id = sdp.source_deal_header_id AND df.term_start = sdp.term_start '
		ELSE  ' df.term_start = sdp.term_start AND df.fas_subsidiary_id = sub.entity_id ' END 
END + 

'	
where sdp.source_deal_header_id is not null '
+ case when  @curve_source_id in(775,4500) then ' And (sdp.pnl_source_value_id=775 or sdp.pnl_source_value_id=4500 or sdp.pnl_source_value_id is null)	'  
	else ' and sdp.pnl_source_value_id='+ CAST(@curve_source_id AS VARCHAR) end


IF @tenor_from IS NULL AND @tenor_to IS NOT NULL
	SET @tenor_from = @tenor_to
IF @tenor_from IS NOT NULL AND @tenor_to IS NULL
	SET @tenor_to = @tenor_from 

IF @tenor_from  IS NOT NULL AND @tenor_to IS NOT NULL
   	SET @Sql = @Sql + ' AND sdp.term_start BETWEEN ''' + @tenor_from + ''' AND ''' +  @tenor_to + ''''
IF @settlement_option = 'f' 
	SET @Sql = @Sql +  ' AND sdp.term_start >(''' + @as_of_date + ''')'
IF @settlement_option = 'c' 
	SET @Sql = @Sql +  ' AND ((sdp.term_start >= ''' + dbo.FNAGETCONTRACTMONTH(@as_of_date) + ''' AND sdd.deal_volume_frequency=''m'') OR (sdp.term_start >= ''' + @as_of_date+ ''' AND sdd.deal_volume_frequency<>''m''))'
IF @settlement_option = 's'  
	SET @Sql = @Sql +  ' AND sdp.term_start <= ''' + @as_of_date + ''''
IF (@term_start IS NOT NULL)
	SET @Sql = @Sql +' AND convert(varchar(10),sdp.term_start,120) >='''+CONVERT(VARCHAR(10),@term_start,120) +''''
IF (@term_end IS NOT NULL)
	SET @Sql = @Sql +' AND convert(varchar(10),sdp.term_end,120)<='''+CONVERT(VARCHAR(10),@term_end,120) +''''


--PRINT '/*****************************************************************/'
IF @drill = 'y' 
BEGIN
	IF @prior_summary_option = 't'
	BEGIN
		IF (@risk_bucket_header_id IS NOT NULL) --AND (@risk_bucket_detail_id IS NOT NULL)
			BEGIN
				DECLARE @getTenorFrom_sdp INT, @getTenorTo_sdp INT				
				SELECT 
					@getTenorFrom_sdp = tenor_from, 
					@getTenorTo_sdp = tenor_to,
					@tenor_from_month_year = CASE WHEN ISNULL(fromMonthYear,'m') = 'm' THEN 'month' ELSE 'year' END,
					@tenor_to_month_year = CASE WHEN ISNULL(toMonthYear,'m') = 'm' THEN 'month' ELSE 'year' END
				FROM risk_tenor_bucket_detail WHERE bucket_header_id= @risk_bucket_header_id AND tenor_name=@drill5
				--SELECT @getTenorTo_sdp = tenor_to FROM risk_tenor_bucket_detail WHERE bucket_header_id= @risk_bucket_header_id AND tenor_name=@drill5
				 
				SET @Sql = @Sql +
				' AND ' + CAST (@getTenorTo_sdp AS VARCHAR) + '>= DATEDIFF(' + @tenor_to_month_year + ',''' + @as_of_date + ''', ISNULL(sdp.term_start,''1900-1-1''))
				  AND '+ CAST (@getTenorFrom_sdp AS VARCHAR)+'<= DATEDIFF(' + @tenor_from_month_year + ','''+ @as_of_date +''', ISNULL(sdp.term_start,''2099-1-1''))'
			END
		IF @risk_bucket_header_id IS NULL
		SET @Sql = @Sql +  ' AND sdp.term_start = ''' + dbo.FNACovertToSTDDate(@drill5) + ''''
	END
		--SET @Sql = @Sql +  ' AND sdp.term_start = ''' + dbo.FNACovertToSTDDate(@drill5) + ''''
	IF @prior_summary_option = 'q'
		SET @Sql = @Sql +  ' AND sdp.term_start = ''' + dbo.FNACovertToSTDDate(@drill3) + ''''
	IF @prior_summary_option = 'r'
		SET @Sql = @Sql +  ' AND sdp.term_start = ''' + dbo.FNACovertToSTDDate(@drill2) + ''''
END	

--select @drill,@drill1,@drill2,@drill3,@drill4,@settlement_only,@prior_summary_option
-- exec spa_Create_MTM_Period_Report '2008-03-20', '291,30,1,257,258,256', NULL, NULL, 'u', 'a', 'a', 'd',NULL,NULL,NULL,'2001-03-20',NULL,NULL,NULL,NULL,NULL,NULL,'y',400,NULL,NULL,NULL,NULL,'y','y','n','y' 
SET @Sql = @sql + ' group by pd.source_deal_header_id, sdp.term_start ' +
			CASE	WHEN (@drill='n') THEN ''
			ELSE 
				' HAVING  ' +
				CASE WHEN @settlement_only='y' THEN ' MAX(sdp.pnl_as_of_date)<='''+@as_of_date+'''' 
					--WHEN (@prior_summary_option IN ('c', 't')) THEN 
					ELSE
						 CASE WHEN @drill1 IS NOT NULL THEN ' max(sub.entity_name) = ''' + @drill1 + '''' ELSE '' END
						 +CASE WHEN @drill2 IS NOT NULL THEN ' and max(stra.entity_name) = ''' + @drill2 + '''' ELSE '' END
						 +CASE WHEN @drill3 IS NOT NULL THEN ' and max(book.entity_name) = ''' + @drill3 + '''' ELSE '' END
						 +CASE WHEN @drill4 IS NOT NULL THEN ' and max(pd.counterparty_name) = ''' + @drill4 + '''' ELSE '' END
--					WHEN (@prior_summary_option IN ('q', 'p')) THEN 
--						 CASE WHEN @drill1 IS NOT null THEN ' max(sub.entity_name) = ''' + @drill1 + '''' ELSE '' END
--						 +CASE WHEN @drill1 IS NOT null THEN ' and max(sc.counterparty_name) = ''' + @drill2 + '''' ELSE '' END
--					WHEN (@prior_summary_option ='r') THEN 
--						CASE WHEN @drill1 IS NOT null THEN ' max(sub.entity_name) = ''' + @drill1 + '''' ELSE '' END
--					WHEN (@prior_summary_option ='s') THEN 
--						 CASE WHEN @drill1 IS NOT null THEN ' max(sub.entity_name) = ''' + @drill1 + '''' ELSE '' END
--						+ CASE WHEN @drill1 IS NOT null THEN ' and max(stra.entity_name) = ''' + @drill2 + '''' ELSE '' END
--						+ CASE WHEN @drill1 IS NOT null THEN ' and max(book.entity_name) = ''' + @drill3 + '''' ELSE '' END
						
				END	
			END
--print convert(varchar(30),getdate(),121)

--PRINT '***************aaaaaaaaaaa'
--PRINT @Sql
--PRINT '***************'
EXEC (@Sql)
--print convert(varchar(30),getdate(),121)
create index indx_temp_pnl1 on #temp_pnl1 (Sub, Strategy, Book ,hedge_or_item)
create index indx_temp_pnl2  on #temp_pnl1 (source_deal_header_id,term_start)
create index indx_temp_pnl3  on #temp_pnl1 (term_start,term_end,block_type,block_definition_id,deal_volume_frequency)

DECLARE @Sql_Main_Current VARCHAR(8000)
DECLARE @Sql_Set_Current VARCHAR(8000)
SET @Sql_Main_Current = @Sql

IF @settlement_option = 'c' OR @settlement_option = 's'
BEGIN
	SET @Sql ='
		insert into #temp_pnl1 (Sub,Strategy,Book,source_deal_header_id,deal_id,term_start,hedge_or_item ,counterparty_name,
		pnl,first_day_pnl_threshold ,pnl_as_of_date,deal_date,physical_financial_flag,sbm1,sbm2,sbm3 ,sbm4,fas_deal_type_value_id,volume,term_end,block_type,block_definition_id)
		SELECT p.Sub,p.Strategy,p.Book,p.source_deal_header_id,p.deal_id,s.term_start,p.hedge_or_item ,p.counterparty_name,
		 ' +  CASE WHEN (@discount_option = 'd') THEN  CASE WHEN (@mtm_value_source = 0) THEN ' (isnull(s.und_pnl, 0) * isNull(df.discount_factor,1)) ' ELSE ' (isnull(s.dis_pnl, 0)) ' END ELSE ' isnull(s.und_pnl, 0) ' END  + ' pnl,
		p.first_day_pnl_threshold ,s.pnl_as_of_date,p.deal_date,
		p.physical_financial_flag,p.sbm1,p.sbm2,p.sbm3 ,p.sbm4,p.fas_deal_type_value_id,p.volume,p.term_end,p.block_type,p.block_define_id
		FROM
		( 
			select
			max(Sub) Sub ,max(Strategy) Strategy,max(Book) Book,max(source_deal_header_id) source_deal_header_id
			,max(deal_id) deal_id,max(hedge_or_item) hedge_or_item ,max(counterparty_name) counterparty_name,
			max(first_day_pnl_threshold) first_day_pnl_threshold ,max(deal_date) deal_date,
			max(physical_financial_flag) physical_financial_flag,max(sbm1) sbm1,max(sbm2) sbm2,max(sbm3) sbm3 
			,max(sbm4) sbm4,max(fas_deal_type_value_id ) fas_deal_type_value_id,max(pnl_as_of_date) pnl_as_of_date,max(sub_id) sub_id,max(term_start) term_start1,max(volume) volume,max(term_end) term_end,
			MAX(block_type)block_type,
			MAX(block_definition_id) block_define_id
			from	#temp_pnl 
			group by source_deal_header_id
		) p INNER JOIN
		source_deal_pnl_settlement s ON 
			s.source_deal_header_id = p.source_deal_header_id ' + 
		CASE WHEN (@settlement_option = 'c') THEN  ' AND s.term_start = ''' +  dbo.FNAGETContractMonth(@as_of_date) + '''' 
		ELSE ' AND s.term_start <= ''' +  dbo.FNAGETContractMonth(@as_of_date) + '''' END +
		' AND s.pnl_as_of_date < p.pnl_as_of_date ' +

	CASE WHEN (@discount_option = 'u') THEN '' ELSE 
					' left outer join ' + @DiscountTableName + ' 	df on ' + 
					CASE WHEN (@is_discount_curve_a_factor IN (2)) THEN ' df.source_deal_header_id = s.source_deal_header_id AND df.term_start = s.term_start '
					ELSE  ' df.term_start = s.term_start AND df.fas_subsidiary_id = p.sub_id ' END 
	END +
	' LEFT OUTER JOIN
		#temp_pnl dp ON dp.source_deal_header_id = s.source_deal_header_id and dp.term_start = s.term_start
		where dp.term_start IS NULL'

	--PRINT(@Sql)
	EXEC(@Sql)
	SET @Sql_Set_Current = @Sql
END

--Create a temporary table to SP "spa_get_dealvolume_mult_byfrequency". This SP will return volume multiplier based on frequency

DECLARE @vol_frequency_table VARCHAR(128)
SET @vol_frequency_table=dbo.FNAProcessTableName('deal_volume_frequency_mult', dbo.FNADBUser(), @process_id)

SET @Sql='SELECT DISTINCT 
					tp.term_start, 
					tp.term_end,
					tp.deal_volume_frequency AS deal_volume_frequency,
					tp.block_type,
					tp.block_definition_id as block_definition_id,
					MAX(sdd.deal_volume) deal_volume
			INTO '+@vol_frequency_table+'
			FROM
				#temp_pnl1 tp
				LEFT JOIN source_deal_detail sdd ON sdd.source_deal_header_id=tp.source_deal_header_id
					AND sdd.term_start=tp.term_start
			WHERE 
				(sdd.deal_volume_frequency =''d'' or sdd.deal_volume_frequency =''h'') AND ''' + @apply_volume_multiplier_for_physical + ''' = ''y''
			GROUP BY tp.term_start,tp.term_end,tp.block_type,tp.block_definition_id,tp.deal_volume_frequency'
--print convert(varchar(30),getdate(),121)

--PRINT(@Sql)
EXEC(@Sql)
--print('CREATE INDEX indx_'+@process_id +' ON ' + @vol_frequency_table+'(term_start,term_end,block_type,block_definition_id,deal_volume_frequency)')
exec('CREATE INDEX indx_'+@process_id +' ON ' + @vol_frequency_table+'(term_start,term_end,block_type,block_definition_id,deal_volume_frequency)')

--print convert(varchar(30),getdate(),121)

DECLARE @as_of_date_mult DATETIME
DECLARE @as_of_date_mult_to DATETIME

SET @as_of_date_mult=@as_of_date
SET @as_of_date_mult_to=@as_of_date
--IF @source_deal_header_id IS NOT NULL OR @deal_id IS NOT NULL 
--	SET @as_of_date_mult='1900-01-01'

IF @settlement_option NOT IN('f','s','c')
	SET @as_of_date_mult='1900-01-01'
IF @settlement_option<>'s'
	SET @as_of_date_mult_to='9999-01-01'
--print convert(varchar(30),getdate(),121)
EXEC spa_get_dealvolume_mult_byfrequency @vol_frequency_table,@as_of_date_mult,@as_of_date_mult_to,'y',@settlement_option
--print convert(varchar(30),getdate(),121)
--now populate prior values if period mtm required
IF @period_report = 'y' AND @previous_as_of_date IS NOT NULL
BEGIN
	SET @Sql = REPLACE(@Sql_Main_Current, '#temp_pnl1', '#temp_pnl0')
	SET @Sql = REPLACE(@Sql, 'pd.pnl_as_of_date', ' ''' + @previous_as_of_date + ''' ')
	SET @Sql = REPLACE(@Sql, ' ' + @DiscountTableName + ' ', ' ' + @DiscountTableName0 + ' ')

	EXEC (@Sql)

	--PRINT 'Prior SQL1....'
	--PRINT @Sql
	--PRINT 'End of Prior SQL1....'

--	set @Sql = replace(@Sql_Set_Current, '#temp_pnl1', '#temp_pnl0')
--	set @Sql = replace(@Sql, ' ' + @DiscountTableName + ' ', ' ' + @DiscountTableName0 + ' ')
--	exec (@Sql)
--
--	EXEC spa_print 'Prior SQL2....'
--	EXEC spa_print @Sql
--	EXEC spa_print 'End of Prior SQL2....'
--
--select * from #temp_pnl0
--select * from #temp_pnl1
	IF @summary_option = 's'
		SELECT @SQL='
			SELECT	coalesce(c.Sub, p.Sub) Sub,
					coalesce(c.Strategy, p.Strategy) Strategy,
					coalesce(c.Book, p.Book) Book,
					coalesce(c.hedge_or_item, p.hedge_or_item) hedge_or_item,
					SUM((ISNULL(c.pnl*CASE WHEN c.physical_financial_flag=''f'' THEN 1 ELSE 
					(isnull(isnull(c.multiplier,p.multiplier), 1)*isnull(isnull(c.volume_multiplier2,p.volume_multiplier2), 1)*isnull(c.total_volume,p.total_volume)*ISNULL(NULLIF(vft.Volume_MULT,0),1))/ISNULL(NULLIF(c.volume,0),1) END, 0) - ISNULL(p.pnl*CASE WHEN c.physical_financial_flag=''f'' THEN 1 ELSE 
					(isnull(isnull(c.multiplier,p.multiplier), 1)*isnull(isnull(c.volume_multiplier2,p.volume_multiplier2), 1)*isnull(c.total_volume,p.total_volume)*ISNULL(NULLIF(vft.Volume_MULT,0),1))/ISNULL(NULLIF(p.volume,0),1) END, 0))) [Cumulative FV]
			FROM #temp_pnl1 c FULL OUTER JOIN 
				 #temp_pnl0 p ON
				c.source_deal_header_id = p.source_deal_header_id AND	
				c.term_start = p.term_start 
				LEFT JOIN '+@vol_frequency_table+' vft 
					ON vft.term_start=ISNULL(c.term_start,p.term_start) AND
					   vft.term_end=ISNULL(c.term_end,p.term_end) AND
					   ISNULL(vft.block_type,-1)=ISNULL(ISNULL(c.block_type,p.block_type),-1) AND
					   ISNULL(vft.block_definition_id,-1)=ISNULL(ISNULL(c.block_definition_id,p.block_definition_id),-1)
				group by coalesce(c.Sub, p.Sub), coalesce(c.Strategy, p.Strategy), coalesce(c.Book, p.Book), coalesce(c.hedge_or_item, p.hedge_or_item) 
				order by 1, 2, 3, 4 ' 
	else
		SELECT @SQL='
			INSERT INTO #temp_pnl
			SELECT	coalesce(c.Sub, p.Sub) Sub,
					coalesce(c.Strategy, p.Strategy) Strategy,
					coalesce(c.Book, p.Book) Book,
					coalesce(c.source_deal_header_id, p.source_deal_header_id) source_deal_header_id,
					coalesce(c.deal_id, p.deal_id) deal_id,
					coalesce(c.term_start, p.term_start) term_start,
					coalesce(c.hedge_or_item, p.hedge_or_item) hedge_or_item,
					coalesce(c.counterparty_name, p.counterparty_name) counterparty_name,
					(ISNULL(c.pnl*CASE WHEN c.physical_financial_flag=''f'' THEN 1 ELSE 
					(isnull(isnull(c.multiplier,p.multiplier), 1)*isnull(isnull(c.volume_multiplier2,p.volume_multiplier2), 1)*isnull(c.total_volume,p.total_volume)*ISNULL(NULLIF(vft.Volume_MULT,0),1))/ISNULL(NULLIF(c.volume,0),1) END, 0) - ISNULL(p.pnl*CASE WHEN c.physical_financial_flag=''f'' THEN 1 ELSE 
					(isnull(isnull(c.multiplier,p.multiplier), 1)*isnull(isnull(c.volume_multiplier2,p.volume_multiplier2), 1)*isnull(c.total_volume,p.total_volume)*ISNULL(NULLIF(vft.Volume_MULT,0),1))/ISNULL(NULLIF(p.volume,0),1) END, 0)) [Cumulative FV],
					coalesce(c.first_day_pnl_threshold, p.first_day_pnl_threshold) first_day_pnl_threshold,
					coalesce(c.pnl_as_of_date, p.pnl_as_of_date) pnl_as_of_date,
					coalesce(c.deal_date, p.deal_date) deal_date,
					coalesce(c.physical_financial_flag, p.physical_financial_flag) physical_financial_flag,
					coalesce(c.sbm1, p.sbm1) sbm1,
					coalesce(c.sbm2, p.sbm2) sbm2,
					coalesce(c.sbm3, p.sbm3) sbm3,
					coalesce(c.sbm4, p.sbm4) sbm4,
					coalesce(c.fas_deal_type_value_id, p.fas_deal_type_value_id) fas_deal_type_value_id,
					coalesce(c.sub_id, p.sub_id) sub_id,
					coalesce(c.volume, p.volume) volume,
					coalesce(c.term_end, p.term_end) term_end,
					coalesce(c.block_type, p.block_type) block_type,
					coalesce(c.block_definition_id, p.block_definition_id) block_definition_id
			FROM #temp_pnl1 c FULL OUTER JOIN 
				 #temp_pnl0 p ON
				c.source_deal_header_id = p.source_deal_header_id AND	
				c.term_start = p.term_start 
		--		LEFT JOIN source_deal_detail sdd ON sdd.source_deal_header_id=coalesce(c.source_deal_header_id, p.source_deal_header_id)
		--			AND sdd.term_start=coalesce(c.term_start, p.term_start)
		--			AND sdd.leg=1
				LEFT JOIN '+@vol_frequency_table+' vft 
					ON vft.term_start=ISNULL(c.term_start,p.term_start) AND
					   vft.term_end=ISNULL(c.term_end,p.term_end) AND
					   ISNULL(vft.block_type,-1)=ISNULL(ISNULL(c.block_type,p.block_type),-1) AND
					   ISNULL(vft.block_definition_id,-1)=ISNULL(ISNULL(c.block_definition_id,p.block_definition_id),-1)'
	--	exec spa_print @SQL
	--	EXEC(@SQL)

END
ELSE
BEGIN
	IF @summary_option = 's'
			SELECT @SQL='
				SELECT 
					tp.Sub,
					tp.Strategy,
					tp.Book,
					tp.hedge_or_item [Type],
					round(sum(tp.pnl*'+CASE WHEN @use_bom_logic=0 THEN '1' ELSE +'ISNULL(CASE WHEN tp.physical_financial_flag=''f'' THEN 1 ELSE 
							(isnull(tp.multiplier, 1)*isnull(tp.volume_multiplier2, 1)*tp.total_volume*ISNULL(NULLIF(vft.Volume_MULT,0),1))/ISNULL(NULLIF(tp.volume,0),1) END,1)' END +') , ' +@round_value + ') [Cumulative FV]
					'+ @str_batch_table +'							
				FROM 
					#temp_pnl1 tp
					LEFT JOIN '+@vol_frequency_table+' vft 
						ON vft.term_start=tp.term_start AND
						vft.term_end=tp.term_end AND
						ISNULL(vft.block_type,-1)=ISNULL(tp.block_type,-1) AND
						ISNULL(vft.block_definition_id,-1)=ISNULL(tp.block_definition_id,-1)
						AND ISNULL(tp.deal_volume_frequency,-1)=ISNULL(vft.deal_volume_frequency,-1)
					group by tp.Sub, tp.Strategy, tp.Book ,tp.hedge_or_item
			order by 1, 2, 3, 4 ' 
	else
		SELECT @SQL='
				INSERT INTO #temp_pnl	
				SELECT 
					tp.Sub,
					tp.Strategy,
					tp.Book,
					tp.source_deal_header_id,
					tp.deal_id,
					tp.term_start,
					tp.hedge_or_item,
					tp.counterparty_name,
					tp.pnl*'+CASE WHEN @use_bom_logic=0 THEN '1' ELSE +'ISNULL(CASE WHEN tp.physical_financial_flag=''f'' THEN 1 ELSE 
							(isnull(tp.multiplier, 1)*isnull(tp.volume_multiplier2, 1)*tp.total_volume*ISNULL(NULLIF(vft.Volume_MULT,0),1))/ISNULL(NULLIF(tp.volume,0),1) END,1)' END +' AS pnl,
					tp.first_day_pnl_threshold,
					tp.pnl_as_of_date,
					tp.deal_date,
					tp.physical_financial_flag,
					tp.sbm1,
					tp.sbm2,
					tp.sbm3,
					tp.sbm4,
					tp.fas_deal_type_value_id,
					tp.sub_id,
					--tp.volume,
					isnull(tp.multiplier, 1)*isnull(tp.volume_multiplier2, 1)*tp.total_volume*ISNULL(NULLIF(vft.Volume_MULT,0),1) volume,
					tp.term_end,
					tp.block_type,
					tp.block_definition_id
				FROM 
					#temp_pnl1 tp
	--				LEFT JOIN source_deal_detail sdd ON sdd.source_deal_header_id=tp.source_deal_header_id
	--					AND sdd.term_start=tp.term_start
	--					AND sdd.leg=1
					LEFT JOIN '+@vol_frequency_table+' vft 
						ON vft.term_start=tp.term_start AND
						vft.term_end=tp.term_end AND
						ISNULL(vft.block_type,-1)=ISNULL(tp.block_type,-1) AND
						ISNULL(vft.block_definition_id,-1)=ISNULL(tp.block_definition_id,-1)
						AND ISNULL(tp.deal_volume_frequency,-1)=ISNULL(vft.deal_volume_frequency,-1)
						
			'
--		exec spa_print @SQL
--		EXEC(@SQL)
END
--select * from #temp_pnl1 where counterparty_name='BP'
--SELECT @exceed_threshold_value '@exceed_threshold_value',@summary_option '@summary_option'

EXEC (@Sql)
--print convert(varchar(30),getdate(),121)

IF @summary_option = 's'
	GOTO summary_option_s
	
	
IF ISNULL(@exceed_threshold_value, 'n') = 'n'
BEGIN
	IF @summary_option = 'c'
		SET @Sql = 
		' select	Sub, Strategy, Book, hedge_or_item [Type], counterparty_name Counterparty, round(sum(pnl), ' +@round_value + ') [Cumulative FV]
		 ' + @str_batch_table +
		' from #temp_pnl
		group by Sub, Strategy, Book, hedge_or_item, counterparty_name 
		order by Sub, Strategy, Book, hedge_or_item, counterparty_name '

	ELSE IF @summary_option = 't' AND @graph='n'
	BEGIN
		CREATE TABLE #sort_table(
			Sub VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL,
			Strategy VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL,
			Book VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL,
			[TYPE] VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL,
			Counterparty VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL,
			Expiration VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL,
			[Cumulative FV] FLOAT --VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL	
		)
		
		SET @Sql1 = 
		'insert into #sort_table select Sub, Strategy, Book, hedge_or_item [Type], counterparty_name Counterparty,'
			+ CASE WHEN @risk_bucket_header_id IS NOT NULL THEN + 'rtbd.tenor_name AS Expiration' ELSE 'dbo.FNACovertToSTDDate(term_start) Expiration' END +'   
			 , round(sum(pnl), ' +@round_value + ') [Cumulative FV]
		  from #temp_pnl'
			+ CASE WHEN @risk_bucket_header_id IS NOT NULL THEN + 
			' LEFT JOIN risk_tenor_bucket_detail rtbd ON rtbd.bucket_detail_id =' + CASE WHEN @risk_bucket_detail_id IS NOT NULL THEN CAST(@risk_bucket_detail_id AS VARCHAR) ELSE 'rtbd.bucket_detail_id' END +'
			 WHERE rtbd.bucket_header_id=' +CAST(@risk_bucket_header_id AS VARCHAR)+ ' 
			 AND rtbd.bucket_detail_id = ' + CASE WHEN @risk_bucket_detail_id IS NOT NULL THEN CAST(@risk_bucket_detail_id AS VARCHAR) ELSE 'rtbd.bucket_detail_id' END +'
			 
			   AND rtbd.tenor_to >= CASE WHEN ISNULL(rtbd.toMonthYear,''m'') = ''m'' THEN DATEDIFF(month,''' +@as_of_date+ ''', ISNULL(#temp_pnl.term_start,''1900-1-1'')) ELSE DATEDIFF(year,''' +@as_of_date+ ''', ISNULL(#temp_pnl.term_start,''1900-1-1'')) END
			   AND rtbd.tenor_from <= CASE WHEN ISNULL(rtbd.fromMonthYear,''m'') = ''m'' THEN DATEDIFF(month,''' +@as_of_date+ ''', ISNULL(#temp_pnl.term_start,''1900-1-1'')) ELSE DATEDIFF(year,''' +@as_of_date+ ''', ISNULL(#temp_pnl.term_start,''1900-1-1'')) END'
			ELSE '' END
			+ ' group by Sub, Strategy, Book, hedge_or_item, counterparty_name,' + CASE WHEN @risk_bucket_header_id IS NOT NULL THEN + ' rtbd.tenor_name ' ELSE 'dbo.FNACovertToSTDDate(term_start)' END +
			'   order by Sub, Strategy, Book, hedge_or_item, counterparty_name,' + CASE WHEN @risk_bucket_header_id IS NOT NULL THEN + ' rtbd.tenor_name ' ELSE 'dbo.FNACovertToSTDDate(term_start)'  END
			
		EXEC(@Sql1)
		
		SET @sql = 'select	Sub,Strategy,Book,[Type],Counterparty, 
		CASE WHEN ISDATE(Expiration) = 1 THEN dbo.FNADateFormat(Expiration) ELSE Expiration END as Expiration, 
		[Cumulative FV]  '+ @str_batch_table + ' from #sort_table'			
	END
	ELSE IF @summary_option = 't' AND @graph='y'
	BEGIN
		DECLARE @cols NVARCHAR(MAX)
		SELECT  @cols = COALESCE(@cols + ',[' +Sub+'--'+Strategy+'--'+Book+'--'+hedge_or_item+'--'+counterparty_name+ ']',
                         '[' +Sub+'--'+Strategy+'--'+Book+'--'+hedge_or_item+'--'+counterparty_name+ ']')
		FROM     #temp_pnl
		GROUP BY Sub,Strategy,Book,hedge_or_item,counterparty_name ORDER BY Sub
	
		SET @Sql = 
		' select Expiration, ' + @cols+'
		  FROM 
			(SELECT dbo.FNADateFormat(' 
				+ CASE WHEN @risk_bucket_header_id IS NOT NULL THEN + 'rtbd.tenor_name' ELSE 'dbo.FNADateFormat(term_start)' END + ') AS  Expiration,
				(Sub+''--''+Strategy+''--''+Book+''--''+hedge_or_item+''--''+counterparty_name) as [Description],pnl FROM #temp_pnl'

				+ CASE WHEN @risk_bucket_header_id IS NOT NULL THEN + 
				' LEFT JOIN risk_tenor_bucket_detail rtbd ON rtbd.bucket_detail_id =' + CASE WHEN @risk_bucket_detail_id IS NOT NULL THEN CAST(@risk_bucket_detail_id AS VARCHAR) ELSE 'rtbd.bucket_detail_id' END +'
				WHERE rtbd.bucket_header_id=' +CAST(@risk_bucket_header_id AS VARCHAR)+ ' 
				AND rtbd.bucket_detail_id = ' + CASE WHEN @risk_bucket_detail_id IS NOT NULL THEN CAST(@risk_bucket_detail_id AS VARCHAR) ELSE 'rtbd.bucket_detail_id' END +'
				AND rtbd.tenor_to >= CASE WHEN ISNULL(rtbd.toMonthYear,''m'') = ''m'' THEN DATEDIFF(month,''' +@as_of_date+ ''', ISNULL(#temp_pnl.term_start,''1900-1-1'')) ELSE DATEDIFF(year,''' +@as_of_date+ ''', ISNULL(#temp_pnl.term_start,''1900-1-1'')) END
				AND rtbd.tenor_from <= CASE WHEN ISNULL(rtbd.fromMonthYear,''m'') = ''m'' THEN DATEDIFF(month,''' +@as_of_date+ ''', ISNULL(#temp_pnl.term_start,''1900-1-1'')) ELSE DATEDIFF(year,''' +@as_of_date+ ''', ISNULL(#temp_pnl.term_start,''1900-1-1'')) END'
				ELSE '' END
				+')P
			 PIVOT
				(
					SUM(pnl) FOR  [Description] IN ('+@cols+')
				)AS PVT	 '
	END

	ELSE IF @summary_option = 'q' AND @graph='n'
	BEGIN
		CREATE TABLE #sort_table_1(
			Sub VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL,
			[TYPE] VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL,
			Counterparty VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL,
			Expiration VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL,
			[Cumulative FV] FLOAT --VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL				
		)
		
						
		SET @Sql1 = 

		'INSERT INTO #sort_table_1 select Sub, hedge_or_item [Type], counterparty_name Counterparty,' 
			+ CASE WHEN @risk_bucket_header_id IS NOT NULL THEN + 'rtbd.tenor_name AS Expiration' ELSE 'dbo.FNACovertToSTDDate(term_start) Expiration' END +'
			, round(sum(pnl), ' +@round_value + ') [Cumulative FV]
		  from #temp_pnl'
		 + CASE WHEN @risk_bucket_header_id IS NOT NULL THEN + 
			' LEFT JOIN risk_tenor_bucket_detail rtbd ON rtbd.bucket_detail_id =' + CASE WHEN @risk_bucket_detail_id IS NOT NULL THEN CAST(@risk_bucket_detail_id AS VARCHAR) ELSE 'rtbd.bucket_detail_id' END +'
			 WHERE rtbd.bucket_header_id=' +CAST(@risk_bucket_header_id AS VARCHAR)+ ' 
			 AND rtbd.bucket_detail_id = ' + CASE WHEN @risk_bucket_detail_id IS NOT NULL THEN CAST(@risk_bucket_detail_id AS VARCHAR) ELSE 'rtbd.bucket_detail_id' END +'
			 AND rtbd.tenor_to >= CASE WHEN ISNULL(rtbd.toMonthYear,''m'') = ''m'' THEN DATEDIFF(month,''' +@as_of_date+ ''', ISNULL(#temp_pnl.term_start,''1900-1-1'')) ELSE DATEDIFF(year,''' +@as_of_date+ ''', ISNULL(#temp_pnl.term_start,''1900-1-1'')) END
			 AND rtbd.tenor_from <= CASE WHEN ISNULL(rtbd.fromMonthYear,''m'') = ''m'' THEN DATEDIFF(month,''' +@as_of_date+ ''', ISNULL(#temp_pnl.term_start,''1900-1-1'')) ELSE DATEDIFF(year,''' +@as_of_date+ ''', ISNULL(#temp_pnl.term_start,''1900-1-1'')) END'
			ELSE '' END	
		+ ' group by Sub, hedge_or_item, counterparty_name, ' + CASE WHEN @risk_bucket_header_id IS NOT NULL THEN + ' rtbd.tenor_name ' ELSE 'dbo.FNACovertToSTDDate(term_start)' END +
		 ' order by Sub, hedge_or_item, counterparty_name, ' + CASE WHEN @risk_bucket_header_id IS NOT NULL THEN + ' rtbd.tenor_name ' ELSE 'dbo.FNACovertToSTDDate(term_start)'  END
		 
		EXEC(@Sql1)
		
		SET @Sql = 'select Sub,[Type],Counterparty,CASE WHEN ISDATE(Expiration) = 1 THEN dbo.FNADateFormat(Expiration) ELSE Expiration END as Expiration,[Cumulative FV] '+ @str_batch_table + ' from #sort_table_1'	 
		 
	END
	
	ELSE IF @summary_option = 'q' AND @graph='y'
	BEGIN
		DECLARE @cols_q NVARCHAR(MAX)
		SELECT  @cols_q = COALESCE(@cols_q + ',[' +Sub+'--'+hedge_or_item+'--'+counterparty_name+ ']',
                         '[' +Sub+'--'+hedge_or_item+'--'+counterparty_name+ ']')
		FROM     #temp_pnl
		GROUP BY Sub,hedge_or_item,counterparty_name ORDER BY Sub

		SET @Sql = 
		' select Expiration, ' + @cols_q+'
		  FROM 
			(SELECT dbo.FNADateFormat(' 
				+ CASE WHEN @risk_bucket_header_id IS NOT NULL THEN + 'rtbd.tenor_name' ELSE 'dbo.FNADateFormat(term_start)' END + ')  AS Expiration,
				(Sub+''--''+hedge_or_item+''--''+counterparty_name) as [Description],pnl FROM #temp_pnl'

				+ CASE WHEN @risk_bucket_header_id IS NOT NULL THEN + 
				' LEFT JOIN risk_tenor_bucket_detail rtbd ON rtbd.bucket_detail_id =' + CASE WHEN @risk_bucket_detail_id IS NOT NULL THEN CAST(@risk_bucket_detail_id AS VARCHAR) ELSE 'rtbd.bucket_detail_id' END +'
				WHERE rtbd.bucket_header_id=' +CAST(@risk_bucket_header_id AS VARCHAR)+ ' 
				AND rtbd.bucket_detail_id = ' + CASE WHEN @risk_bucket_detail_id IS NOT NULL THEN CAST(@risk_bucket_detail_id AS VARCHAR) ELSE 'rtbd.bucket_detail_id' END +'
				AND rtbd.tenor_to >= CASE WHEN ISNULL(rtbd.toMonthYear,''m'') = ''m'' THEN DATEDIFF(month,''' +@as_of_date+ ''', ISNULL(#temp_pnl.term_start,''1900-1-1'')) ELSE DATEDIFF(year,''' +@as_of_date+ ''', ISNULL(#temp_pnl.term_start,''1900-1-1'')) END
				AND rtbd.tenor_from <= CASE WHEN ISNULL(rtbd.fromMonthYear,''m'') = ''m'' THEN DATEDIFF(month,''' +@as_of_date+ ''', ISNULL(#temp_pnl.term_start,''1900-1-1'')) ELSE DATEDIFF(year,''' +@as_of_date+ ''', ISNULL(#temp_pnl.term_start,''1900-1-1'')) END'
				ELSE '' END
				+')P
			 PIVOT
				(
					SUM(pnl) FOR  [Description] IN ('+@cols_q+')
				)AS PVT	 '
	END
	ELSE IF @summary_option = 'p'
		SET @Sql = 
		'select Sub, hedge_or_item [Type], counterparty_name Counterparty, round(sum(pnl), ' +@round_value + ') [Cumulative FV]
		 ' + @str_batch_table +
		' from #temp_pnl
		group by Sub, hedge_or_item, counterparty_name 
		order by Sub, hedge_or_item, counterparty_name '
	ELSE IF @summary_option = 'r' AND @graph='n'
	BEGIN		
		CREATE TABLE #sort_table_2(
			Sub VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL,
			[TYPE] VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL,
			Expiration VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL,
			[Cumulative FV] FLOAT --VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL	
		)
				
		SET @Sql1 =
		'insert into #sort_table_2 select Sub, hedge_or_item [Type], '
		+ CASE WHEN @risk_bucket_header_id IS NOT NULL THEN + 'rtbd.tenor_name AS Expiration' ELSE 'dbo.FNACovertToSTDDate(term_start) Expiration' END +'
		, round(sum(pnl), ' +@round_value + ') [Cumulative FV]
		  	from #temp_pnl'
			+ CASE WHEN @risk_bucket_header_id IS NOT NULL THEN + 
			' LEFT JOIN risk_tenor_bucket_detail rtbd ON rtbd.bucket_detail_id =' + CASE WHEN @risk_bucket_detail_id IS NOT NULL THEN CAST(@risk_bucket_detail_id AS VARCHAR) ELSE 'rtbd.bucket_detail_id' END +'
			 WHERE rtbd.bucket_header_id=' +CAST(@risk_bucket_header_id AS VARCHAR)+ ' 
			 AND rtbd.bucket_detail_id = ' + CASE WHEN @risk_bucket_detail_id IS NOT NULL THEN CAST(@risk_bucket_detail_id AS VARCHAR) ELSE 'rtbd.bucket_detail_id' END +'
			 AND rtbd.tenor_to >= CASE WHEN ISNULL(rtbd.toMonthYear,''m'') = ''m'' THEN DATEDIFF(month,''' +@as_of_date+ ''', ISNULL(#temp_pnl.term_start,''1900-1-1'')) ELSE DATEDIFF(year,''' +@as_of_date+ ''', ISNULL(#temp_pnl.term_start,''1900-1-1'')) END
			 AND rtbd.tenor_from <= CASE WHEN ISNULL(rtbd.fromMonthYear,''m'') = ''m'' THEN DATEDIFF(month,''' +@as_of_date+ ''', ISNULL(#temp_pnl.term_start,''1900-1-1'')) ELSE DATEDIFF(year,''' +@as_of_date+ ''', ISNULL(#temp_pnl.term_start,''1900-1-1'')) END'
			ELSE '' END	
			+ ' group by Sub, hedge_or_item, ' + CASE WHEN @risk_bucket_header_id IS NOT NULL THEN + ' rtbd.tenor_name ' ELSE ' term_start' END +
			' order by Sub, hedge_or_item, ' + CASE WHEN @risk_bucket_header_id IS NOT NULL THEN + ' rtbd.tenor_name ' ELSE ' term_start'  END
		
		EXEC(@Sql1)
		SET @Sql = 'select Sub,[Type],CASE WHEN ISDATE(Expiration) = 1 THEN dbo.FNADateFormat(Expiration) ELSE Expiration END as Expiration,[Cumulative FV] '+ @str_batch_table + ' from #sort_table_2'
	END
	ELSE IF @summary_option = 'r' AND @graph='y'
	BEGIN
		DECLARE @cols_r NVARCHAR(MAX)
		SELECT  @cols_r = COALESCE(@cols_r + ',[' +Sub+'--'+hedge_or_item+ ']',
                         '[' +Sub+'--'+hedge_or_item+ ']')
		FROM     #temp_pnl
		GROUP BY Sub,hedge_or_item ORDER BY Sub

		SET @Sql = 
		' select dbo.FNADateFormat(Expiration)  AS Expiration, ' + @cols_r+'
		  FROM 
			(SELECT ' 
				+ CASE WHEN @risk_bucket_header_id IS NOT NULL THEN + 'rtbd.tenor_name AS Expiration, ' ELSE 'term_start Expiration, ' END + '
				(Sub+''--''+hedge_or_item) as [Description],pnl FROM #temp_pnl'

				+ CASE WHEN @risk_bucket_header_id IS NOT NULL THEN + 
				' LEFT JOIN risk_tenor_bucket_detail rtbd ON rtbd.bucket_detail_id =' + CASE WHEN @risk_bucket_detail_id IS NOT NULL THEN CAST(@risk_bucket_detail_id AS VARCHAR) ELSE 'rtbd.bucket_detail_id' END +'
				WHERE rtbd.bucket_header_id=' +CAST(@risk_bucket_header_id AS VARCHAR)+ ' 
				AND rtbd.bucket_detail_id = ' + CASE WHEN @risk_bucket_detail_id IS NOT NULL THEN CAST(@risk_bucket_detail_id AS VARCHAR) ELSE 'rtbd.bucket_detail_id' END +'
				AND rtbd.tenor_to >= CASE WHEN ISNULL(rtbd.toMonthYear,''m'') = ''m'' THEN DATEDIFF(month,''' +@as_of_date+ ''', ISNULL(#temp_pnl.term_start,''1900-1-1'')) ELSE DATEDIFF(year,''' +@as_of_date+ ''', ISNULL(#temp_pnl.term_start,''1900-1-1'')) END
				AND rtbd.tenor_from <= CASE WHEN ISNULL(rtbd.fromMonthYear,''m'') = ''m'' THEN DATEDIFF(month,''' +@as_of_date+ ''', ISNULL(#temp_pnl.term_start,''1900-1-1'')) ELSE DATEDIFF(year,''' +@as_of_date+ ''', ISNULL(#temp_pnl.term_start,''1900-1-1'')) END'
				ELSE '' END
				+')P
			 PIVOT
				(
					SUM(pnl) FOR  [Description] IN ('+@cols_r+')
				)AS PVT	 '
	END
	ELSE IF @summary_option = 'd' AND @graph='n'
	BEGIN
		CREATE TABLE #sort_table_3(
			Sub VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL,
			Strategy VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL, 
			Book VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL,
			Counterparty VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL,
			[REF ID] VARCHAR(1500) COLLATE DATABASE_DEFAULT  NULL, -- Updated the length because it contains hyperlink...
			DealDate VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL,
			PNLDate VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL,
			[TYPE] VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL,
			[Phy/Fin] VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL,
			Expiration VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL,
			[Cumulative FV] FLOAT --VARCHAR(100) COLLATE DATABASE_DEFAULT  NULL
		)
		SET @Sql1 = 
		'insert into #sort_table_3 
		SELECT  Sub, Strategy, Book, counterparty_name Counterparty, 
				dbo.FNATRMWinHyperlink(''a'', 10131010, deal_id, ABS(source_deal_header_id),null,null,null,null,null,null,null,null,null,null,null,0) AS  [Rel ID],
				dbo.FNADateFormat(deal_date) DealDate,
				dbo.FNADateFormat(pnl_as_of_date) PNLDate,		
				hedge_or_item [Type], 
				case when (physical_financial_flag) = ''p'' then ''Phy'' else ''Fin'' end [Phy/Fin], '
				+ CASE WHEN @risk_bucket_header_id IS NOT NULL THEN + 'rtbd.tenor_name AS Expiration' ELSE 'dbo.FNACovertToSTDDate(term_start) Expiration' END +'
				, round(pnl, ' +@round_value + ') [Cumulative FV]
			 from  	#temp_pnl '
				+ CASE WHEN @risk_bucket_header_id IS NOT NULL THEN + 
				' LEFT JOIN risk_tenor_bucket_detail rtbd ON rtbd.bucket_detail_id =' + CASE WHEN @risk_bucket_detail_id IS NOT NULL THEN CAST(@risk_bucket_detail_id AS VARCHAR) ELSE 'rtbd.bucket_detail_id' END +'
				WHERE rtbd.bucket_header_id=' +CAST(@risk_bucket_header_id AS VARCHAR)+ ' 
				AND rtbd.bucket_detail_id = ' + CASE WHEN @risk_bucket_detail_id IS NOT NULL THEN CAST(@risk_bucket_detail_id AS VARCHAR) ELSE 'rtbd.bucket_detail_id' END +'
				AND rtbd.tenor_to >= CASE WHEN ISNULL(rtbd.toMonthYear,''m'') = ''m'' THEN DATEDIFF(month,''' +@as_of_date+ ''', ISNULL(#temp_pnl.term_start,''1900-1-1'')) ELSE DATEDIFF(year,''' +@as_of_date+ ''', ISNULL(#temp_pnl.term_start,''1900-1-1'')) END
				AND rtbd.tenor_from <= CASE WHEN ISNULL(rtbd.fromMonthYear,''m'') = ''m'' THEN DATEDIFF(month,''' +@as_of_date+ ''', ISNULL(#temp_pnl.term_start,''1900-1-1'')) ELSE DATEDIFF(year,''' +@as_of_date+ ''', ISNULL(#temp_pnl.term_start,''1900-1-1'')) END'
				ELSE '' END	
				+ ' order by Sub, Strategy, Book, hedge_or_item, source_deal_header_id,  ' + CASE WHEN @risk_bucket_header_id IS NOT NULL THEN + ' rtbd.tenor_name ' ELSE 'dbo.FNACovertToSTDDate(term_start)'  END
		
		EXEC(@Sql1)
		
		SET @Sql ='select Sub,Strategy,Book,Counterparty,[Ref ID],DealDate,PNLDate,[Type],[Phy/Fin],CASE WHEN ISDATE(Expiration) = 1 THEN dbo.FNADateFormat(Expiration) ELSE Expiration END as Expiration,[Cumulative FV] '+ @str_batch_table + ' from #sort_table_3'
		
				
	END	 

	ELSE IF @summary_option = 'l'

		SELECT  @Sql = 
		'SELECT  sbm1 ['+group1+'], sbm2 ['+group2+'], sbm3 ['+group3+'], sbm4 ['+group4+'],
				counterparty_name Counterparty, 
				dbo.FNAHyperLink(10131010,cast(source_deal_header_id as varchar),source_deal_header_id,'''+ISNULL(@batch_process_id,'-1') +''') AS [Deal ID], 
				deal_id [Ref ID],
				dbo.FNADateFormat(max(deal_date)) DealDate,
				dbo.FNADateFormat(max(pnl_as_of_date)) PNLDate,		
				hedge_or_item [Type], 
				case when (max(physical_financial_flag)) = ''p'' then ''Phy'' else ''Fin'' end [Phy/Fin],
				round(sum(pnl), ' +@round_value + ') [Cumulative FV]
			' + @str_batch_table +
					' from  	#temp_pnl
				group by sbm1, sbm2, sbm3, sbm4, counterparty_name, source_deal_header_id, deal_id, hedge_or_item 
				order by sbm1, sbm2, sbm3, sbm4, counterparty_name, hedge_or_item, deal_id 
		' 
		FROM source_book_mapping_clm



--exec spa_Create_MTM_Period_Report '2004-12-31', '30', '208', '223', 'u', 'a', 'a', 'l',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'n',NULL,NULL,NULL,NULL,NULL,'n','n','y','n','2','a','m','n',NULL

	ELSE IF @summary_option = 'b'
	BEGIN
		
		--PRINT '#############################################tttttttttttttt'
		--PRINT @Sql
		--PRINT '#############################################'

		IF @deal_date_from  IS  NULL 
		BEGIN
			IF @deal_date_to IS  NULL
   				SET @Sql =  ''
			ELSE
   				SET @Sql = ' AND sdh.deal_date<= ''' + CONVERT(VARCHAR(10),@deal_date_to,120) + ''''
		END
		ELSE
		BEGIN
			IF @deal_date_to IS  NULL
   				SET @Sql = ' AND sdh.deal_date>= ''' + CONVERT(VARCHAR(10),@deal_date_from,120) + ''''
			ELSE
   				SET @Sql =  ' AND sdh.deal_date BETWEEN ''' + CONVERT(VARCHAR(10),@deal_date_from,120) + ''' AND ''' +  CONVERT(VARCHAR(10),@deal_date_to,120) + ''''
		END

		IF @settlement_date_from  IS  NULL 
		BEGIN
			IF @settlement_date_to IS  NULL
   				SET @Sql = @Sql + ''
			ELSE
   				SET @Sql = @Sql + ' AND ISNULL(sdd.settlement_date,sdd.contract_expiration_date)<= ''' + CONVERT(VARCHAR(10),@settlement_date_to,120) + ''''
		END
		ELSE
		BEGIN
			IF @settlement_date_to IS  NULL
   				SET @Sql = @Sql + ' AND ISNULL(sdd.settlement_date,sdd.contract_expiration_date)>= ''' + CONVERT(VARCHAR(10),@settlement_date_from,120) + ''''
			ELSE
   				SET @Sql = @Sql + ' AND ISNULL(sdd.settlement_date,sdd.contract_expiration_date) BETWEEN ''' + CONVERT(VARCHAR(10),@settlement_date_from,120) + ''' AND ''' +  CONVERT(VARCHAR(10),@settlement_date_to,120) + ''''
		END

		IF (@term_start IS NOT NULL)
		BEGIN
			SET @Sql = @Sql +' AND convert(varchar(10),sdpd.term_start,120) >='''+CONVERT(VARCHAR(10),@term_start,120) +''''
		END

		IF (@term_end IS NOT NULL)
		BEGIN
			SET @Sql = @Sql +' AND convert(varchar(10),sdpd.term_end,120)<='''+CONVERT(VARCHAR(10),@term_end,120) +''''
		END


		SET @Sql = @Sql + 
			CASE WHEN (@deal_id_from IS NOT NULL AND @match_id = 'n') THEN ' AND sdh.source_deal_header_id BETWEEN ' + CAST(@deal_id_from AS VARCHAR) +' AND ' + CAST(@deal_id_to AS VARCHAR) ELSE '' END +
			CASE WHEN (@deal_id_from IS NOT NULL AND @match_id = 'y') THEN ' AND cast(sdh.source_deal_header_id as varchar) LIKE cast(' + CAST(@deal_id_from AS VARCHAR) + ' as varchar) + ''%''' ELSE '' END +
			CASE WHEN (@deal_id IS NOT NULL AND @match_id = 'n') THEN ' AND sdh.deal_id LIKE ''%' + @deal_id + '%''' ELSE  '' END +
			CASE WHEN (@deal_id IS NOT NULL AND @match_id = 'y') THEN ' AND sdh.deal_id LIKE ''%' + @deal_id + '%''' ELSE  '' END

			+ CASE WHEN  @settlement_only='y' THEN ' AND sdd.leg=1 ' ELSE '' END
			+CASE WHEN  @settlement_only='y' AND @as_of_date IS NOT NULL THEN ' AND ISNULL(sdd.settlement_date,sdd.contract_expiration_date)<='''+@as_of_date+'''' ELSE '' END
			+CASE WHEN  @settlement_only='y' AND @settlement_date_from IS NOT NULL THEN ' AND ISNULL(sdd.settlement_date,sdd.contract_expiration_date)>='''+@settlement_date_from+'''' ELSE '' END
			+CASE WHEN  @settlement_only='y' AND @settlement_date_to IS NOT NULL THEN ' AND ISNULL(sdd.settlement_date,sdd.contract_expiration_date)<='''+@settlement_date_to+'''' ELSE '' END




		IF @settlement_option = 'f' 
			SET @Sql = @Sql +  ' AND sdpd.term_start >(''' + @as_of_date + ''')'
		IF @settlement_option = 'c' 
					SET @Sql = @Sql +  ' AND ((sdpd.term_start >= ''' + dbo.FNAGETCONTRACTMONTH(@as_of_date) + ''' AND sdd.deal_volume_frequency=''m'') OR (sdpd.term_start >= ''' + @as_of_date+ ''' AND sdd.deal_volume_frequency<>''m''))'

		IF @settlement_option = 's'  
			SET @Sql = @Sql +  ' AND sdpd.term_start <= ''' + @as_of_date + ''''
		IF ISNULL(@show_prior_processed_values, 'n') <> 'y'
		BEGIN
			IF @use_create_date = 'y'
				SET @Sql = @Sql + ' AND dbo.FNAConvertTZAwareDateFormat(sdh.create_ts,1) between ''' + @previous_as_of_date  + ''' AND ''' + @as_of_date + ''''
				--SET @Sql = @Sql + ' AND sdh.create_ts between ''' + @previous_as_of_date  + ''' AND ''' + @as_of_date + ''''
			ELSE IF ISNULL(@exceed_threshold_value, 'n') = 'y'
				SET @Sql = @Sql + ' AND sdh.deal_date between ''' + @previous_as_of_date  + ''' AND ''' + @as_of_date + ''''
		END
		IF @trader_id IS NOT NULL 
   			SET @Sql = @Sql + ' AND sdh.trader_id IN (' + CAST(@trader_id AS VARCHAR)+ ') '
		IF @deal_type_id IS NOT NULL 
   			SET @Sql = @Sql + ' AND sdh.source_deal_type_id = ' + CAST(@deal_type_id AS VARCHAR)

		IF @deal_sub_type_id IS NOT NULL 
   			SET @Sql = @Sql + ' AND sdh.deal_sub_type_type_id = ' + CAST(@deal_sub_type_id AS VARCHAR)
		IF @counterparty_id IS NOT NULL 
   			SET @Sql = @Sql + + ' AND (sdh.counterparty_id IN (' + @counterparty_id + ')) '
		IF @source_system_book_id1 IS NOT NULL 
   			SET @Sql = @Sql +  ' AND (sdh.source_system_book_id1 IN (' + CAST(@source_system_book_id1 AS VARCHAR)+ ')) '
		IF @source_system_book_id2 IS NOT NULL 
   			SET @Sql = @Sql +  ' AND (sdh.source_system_book_id2 IN (' + CAST(@source_system_book_id2 AS VARCHAR) + ')) '
		IF @source_system_book_id3 IS NOT NULL 
   			SET @Sql = @Sql +  ' AND (sdh.source_system_book_id3 IN (' + CAST(@source_system_book_id3 AS VARCHAR) + ')) '
		IF @source_system_book_id4 IS NOT NULL 
   			SET @Sql = @Sql +  ' AND (sdh.source_system_book_id4 IN (' + CAST(@source_system_book_id4 AS VARCHAR) + ')) '
   			
		IF @commodity_id IS NOT NULL
			SET @Sql = @Sql +  '
					AND (sdh.source_deal_header_id IN (
						SELECT DISTINCT sdh.source_deal_header_id
						FROM source_deal_header sdh
							INNER JOIN source_deal_detail sdd ON  sdh.source_deal_header_id = sdd.source_deal_header_id
							INNER JOIN source_price_curve_def spcd ON  sdd.curve_id = spcd.source_curve_def_id
							WHERE  spcd.commodity_id IN (' + CAST(@commodity_id AS VARCHAR) + ')))'   	

   			
--		if @deal_sub_type<>'b'
--			SET @Sql = @Sql +  ' AND (sdh.deal_sub_type_type_id IN (' + cast(@deal_sub_type as varchar) + ')) '
		IF @mapped = 'm' AND ISNULL(@counterparty, 'a') <> 'a'
   			SET @Sql = @Sql + + ' AND sc.int_ext_flag = ''' + @counterparty + ''''
		IF @cpty_type_id IS NOT NULL
   			SET @Sql = @Sql + + ' AND sc.type_of_entity = ' + CAST(@cpty_type_id AS VARCHAR) 
		IF @transaction_type IS NOT NULL 
			SET @Sql = @Sql +  ' AND isnull(sdh.fas_deal_type_value_id,ssbm.fas_deal_type_value_id) IN( ' + CAST(@transaction_type AS VARCHAR(500))+')'
		IF (@deal_date_from IS NOT NULL)
			SET @Sql = @Sql +' AND convert(varchar(10),sdh.deal_date,120)>='''+CONVERT(VARCHAR(10),@deal_date_from,120) +''''
		IF (@deal_date_to IS NOT NULL)
			SET @Sql = @Sql +' AND convert(varchar(10),sdh.deal_date,120) <='''+CONVERT(VARCHAR(10),@deal_date_to,120) +''''
		IF ISNULL(@phy_fin, 'b') <> 'b'
   			SET @Sql = @Sql + + ' AND sdh.physical_financial_flag = ''' + @phy_fin + ''''

		IF @drill = 'y' 
		BEGIN

			IF @drill1 IS NOT NULL
				SET @Sql = @Sql +  ' AND Sub.entity_name = ''' + @drill1 + ''''
			IF @drill2 IS NOT NULL
				SET @Sql = @Sql +  ' AND stra.entity_name = ''' + @drill2 + ''''
			IF @drill3 IS NOT NULL
				SET @Sql = @Sql +  ' AND Book.entity_name = ''' + @drill3 + ''''
			IF @drill4 IS NOT NULL
				SET @Sql = @Sql +  ' AND sc.counterparty_name = ''' + @drill4 + ''''
			IF @drill5 IS NOT NULL
			BEGIN	
				IF (@risk_bucket_header_id IS NOT NULL) --AND (@risk_bucket_detail_id IS NOT NULL)
				BEGIN
					DECLARE @getTenorFrom INT, @getTenorTo INT
					SELECT 
						@getTenorFrom = tenor_from, 
						@getTenorTo = tenor_to,
						@tenor_from_month_year = CASE WHEN ISNULL(fromMonthYear,'m') = 'm' THEN 'month' ELSE 'year' END,
						@tenor_to_month_year = CASE WHEN ISNULL(toMonthYear,'m') = 'm' THEN 'month' ELSE 'year' END
					FROM risk_tenor_bucket_detail WHERE bucket_header_id= @risk_bucket_header_id AND tenor_name=@drill5
					 --SELECT @risk_bucket_header_id,@drill5,@tenor_from_month_year,@tenor_to_month_year
					SET @Sql = @Sql +
						' AND ' + CAST (@getTenorTo AS VARCHAR) + '>= DATEDIFF(' + @tenor_to_month_year + ',''' + @as_of_date + ''', ISNULL(sdpd.term_start,''1900-1-1''))
					  	AND '+ CAST (@getTenorFrom AS VARCHAR)+'<= DATEDIFF(' + @tenor_from_month_year + ','''+ @as_of_date +''', ISNULL(sdpd.term_start,''2099-1-1''))'
				END
				IF @risk_bucket_header_id IS NULL
				SET @Sql = @Sql +  ' AND sdpd.term_start =  ''' + dbo.FNACovertToSTDDate(@drill5) + ''''
			END	
		END	
							
		IF @mapped = 'm'
		BEGIN
			IF @report_type = 'c' 
				SET @Sql = @Sql +  ' AND fs.hedge_type_value_id = 150 '
			ELSE IF @report_type = 'f'
				SET @Sql = @Sql +  ' AND fs.hedge_type_value_id = 151 '
			ELSE IF @report_type = 'm'
				SET @Sql = @Sql +  ' AND fs.hedge_type_value_id = 152 '
			ELSE IF @report_type = 'n'
				SET @Sql = @Sql +  ' AND fs.hedge_type_value_id = 153 '
			ELSE
				SET @Sql = @Sql +  ' AND fs.hedge_type_value_id BETWEEN 150 AND 152 '
		END
		CREATE TABLE #deal_pnl_detail(
			[Sub] VARCHAR(500) COLLATE DATABASE_DEFAULT ,
			[Strategy] VARCHAR(500) COLLATE DATABASE_DEFAULT ,
			[Book] VARCHAR(500) COLLATE DATABASE_DEFAULT ,
			[DealID] VARCHAR(500) COLLATE DATABASE_DEFAULT ,
			[REF ID] VARCHAR(500) COLLATE DATABASE_DEFAULT ,
			[Trade TYPE] VARCHAR(500) COLLATE DATABASE_DEFAULT ,
			[Counterparty] VARCHAR(500) COLLATE DATABASE_DEFAULT ,
			[Trader] VARCHAR(500) COLLATE DATABASE_DEFAULT ,
			[Deal DATE] VARCHAR(20) COLLATE DATABASE_DEFAULT ,
			[PNLDate] VARCHAR(20) COLLATE DATABASE_DEFAULT ,
			[Term] VARCHAR(20) COLLATE DATABASE_DEFAULT ,
			[Leg] VARCHAR(20) COLLATE DATABASE_DEFAULT ,
			[Buy/Sell] VARCHAR(20) COLLATE DATABASE_DEFAULT ,
			[INDEX] VARCHAR(100) COLLATE DATABASE_DEFAULT ,
			[Market Price] FLOAT,
			[Fixed Cost] FLOAT,
			[Formula Price] FLOAT,
			[Deal Fixed Price] FLOAT,
			[Price Adder] FLOAT,
			[Deal Price] FLOAT,
			[Net Price] FLOAT,
			[Multiplier] FLOAT,
			[Volume] FLOAT,
			[UOM] VARCHAR(20) COLLATE DATABASE_DEFAULT ,
			[Discount Factor] FLOAT,
			[MTM] FLOAT,
			[Discounted MTM] FLOAT,
			deal_volume FLOAT,	
			block_type INT,
			block_define_id INT,
			deal_volume_frequency CHAR(1) COLLATE DATABASE_DEFAULT ,
			term_start DATETIME,
			term_end DATETIME,
			physical_financial_flag CHAR(1) COLLATE DATABASE_DEFAULT 
		)


		SELECT  @Sql = 
				'
				INSERT INTO #deal_pnl_detail 
				select distinct    
					Sub.entity_name Sub,
					stra.entity_name Strategy,
					Book.entity_name Book,
					sdh.source_deal_header_id [DealID],
					dbo.FNAHyperLink(10131010,(cast(sdh.source_deal_header_id as varchar) + '' ('' + sdh.deal_id +  '')''),sdh.source_deal_header_id,'''+ISNULL(@batch_process_id,'-1') +''') AS [Ref ID], 
				--	sdh.deal_id [RefDealID],
					sdt.deal_type_id [Trade Type],
					sc.Counterparty_name Counterparty ,
					st.Trader_name Trader,
					dbo.FNADateFormat(sdh.deal_date) [Deal Date],
					dbo.FNADateFormat(sdpd.pnl_as_of_date) [PNLDate],
					dbo.FNADateFormat(sdpd.term_start) [Term],
					--dbo.FNACovertToSTDDate(sdpd.term_start) [Term],
					sdpd.leg [Leg],
					sdpd.buy_sell_flag [Buy/Sell],
					spcd.curve_name [Index],
					round(sdpd.curve_value,'+CAST(@round_value AS VARCHAR)+') [Market Price],
					round(sdpd.fixed_cost,'+CAST(@round_value AS VARCHAR)+') [Fixed Cost],
					round(sdpd.formula_value,'+CAST(@round_value AS VARCHAR)+') [Formula Price],
					round(sdpd.fixed_price,'+CAST(@round_value AS VARCHAR)+') [Deal Fixed Price],
					round(sdpd.price_adder,'+CAST(@round_value AS VARCHAR)+') [Price Adder],
					round((sdpd.fixed_price + sdpd.formula_value + sdpd.price_adder),'+CAST(@round_value AS VARCHAR)+') [Deal Price],
					-- round(sdpd.price,'+CAST(@round_value AS VARCHAR)+') [Net Price],
					round(
					case when (sdh.option_flag = ''y'' and sdd.contract_expiration_date > sdpd.pnl_as_of_date) 
					then sdpdo.premium - sdpdo.option_premium 
					when (sdh.option_flag = ''y'' and sdd.contract_expiration_date <= sdpd.pnl_as_of_date) 
					then sdpdo.strike_price - spc.curve_value else sdpd.price end 
					,'+CAST(@round_value AS VARCHAR)+') AS [Net Price],
					sdpd.price_multiplier [Multiplier],
					round(sdpd.deal_volume,'+CAST(@round_value AS VARCHAR)+')  [Volume],
					su.uom_name [UOM],
					'
					 +CASE WHEN @settlement_only='n' THEN 
						CASE WHEN @discount_option = 'u' THEN '1' ELSE ' ISNULL(df.discount_factor,1)' END+' AS [Discount Factor],' 
						ELSE 'NULL,' END 
					 +CASE WHEN @settlement_only='n' THEN 'round(sdpd.und_pnl,'+CAST(@round_value AS VARCHAR)+') [MTM]' ELSE 'round(sdpd.und_pnl_set,'+CAST(@round_value AS VARCHAR)+') [Settlement]' END+','
					 +CASE WHEN @settlement_only='n' THEN   
						CASE WHEN @discount_option = 'u' THEN ' round(sdpd.und_pnl ' ELSE ' round(' + CASE WHEN (@mtm_value_source = 0) THEN ' isnull(und_pnl, 0) * isNull(df.discount_factor,1) ' ELSE ' isnull(dis_pnl, 0) ' END END+','+CAST(@round_value AS VARCHAR)+') [Discounted MTM]' 
						ELSE 'NULL' END+',
					sdd.deal_volume,
					ISNULL(spcd1.block_type,sdh.block_type) block_type,
					ISNULL(spcd1.block_define_id,sdh.block_define_id)block_define_id,
					sdd.deal_volume_frequency,
					sdd.term_start,
					sdd.term_end,
					sdh.physical_financial_flag
				from source_deal_header sdh 
				INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id=sdd.source_deal_header_id '
				+CASE WHEN @settlement_only='y' THEN ' INNER JOIN (SELECT 	source_deal_header_id,term_start,term_end,leg,MAX(pnl_as_of_date) pnl_as_of_date,pnl_source_value_id FROM source_deal_pnl_detail WHERE pnl_as_of_date<=''' + CAST(@as_of_date AS VARCHAR)+''' GROUP BY source_deal_header_id,term_start,term_end,leg,pnl_source_value_id) sdpd_max
					on sdd.source_deal_header_id =sdpd_max.source_deal_header_id 
					AND sdd.term_start=sdpd_max.term_start AND sdd.term_end=sdpd_max.term_end
					AND sdd.leg=sdpd_max.leg 
					AND sdpd_max.pnl_source_value_id='+CAST(@curve_source_id AS VARCHAR)+'	
					INNER JOIN source_deal_pnl_detail sdpd 
					on sdpd.source_deal_header_id =sdpd_max.source_deal_header_id 
					AND sdpd.term_start=sdpd_max.term_start AND sdpd.term_end=sdpd_max.term_end
					AND sdpd.leg=sdpd_max.leg 
					AND sdpd.pnl_source_value_id=sdpd_max.pnl_source_value_id
					AND sdpd.pnl_as_of_date=sdpd_max.pnl_as_of_date'  	
				ELSE ' INNER join source_deal_pnl_detail sdpd 
				on sdd.source_deal_header_id =sdpd.source_deal_header_id 
				AND sdd.term_start=sdpd.term_start AND sdd.term_end=sdpd.term_end
				AND sdd.leg=sdpd.leg 
				and pnl_as_of_date=''' + CAST(@as_of_date AS VARCHAR)
                    + ''' and sdpd.pnl_source_value_id='+CAST(@curve_source_id AS VARCHAR) END +		
			' INNER JOIN 
			source_system_book_map ssbm ON 	ssbm.source_system_book_id1 = sdh.source_system_book_id1 AND 
											ssbm.source_system_book_id2 = sdh.source_system_book_id2 AND 
											ssbm.source_system_book_id3 = sdh.source_system_book_id3 AND 
											ssbm.source_system_book_id4 = sdh.source_system_book_id4 
			inner JOIN
			 #books b on  b.fas_book_id=ssbm.fas_book_id
			inner join 	portfolio_hierarchy book on book.entity_id = ssbm.fas_book_id
			 inner JOIN
				portfolio_hierarchy stra on stra.entity_id = book.parent_entity_id
			 inner  JOIN
				portfolio_hierarchy sub on sub.entity_id = stra.parent_entity_id
			 inner JOIN
				fas_strategy fs on fs.fas_strategy_id = stra.entity_id 
			
			INNER JOIN source_price_curve_def spcd ON sdd.curve_id=spcd.source_curve_def_id 
			LEFT JOIN source_uom su on su.source_uom_id=sdd.deal_volume_uom_id
			LEFT JOIN dbo.source_traders st ON sdh.trader_id=st.source_trader_id
			LEFT JOIN dbo.source_counterparty sc ON sdh.counterparty_id=sc.source_counterparty_id
			   LEFT JOIN source_deal_pnl_detail_options sdpdo ON sdpdo.source_deal_header_id=sdpd.source_deal_header_id 
		   AND sdpdo.as_of_date=sdpd.pnl_as_of_date and sdpdo.term_start=sdpd.term_start
		   LEFT JOIN source_price_curve spc on spc.source_curve_def_id=sdd.curve_id AND spc.as_of_date = 
		   case when (sdd.contract_expiration_date > sdpd.pnl_as_of_date) then sdpd.pnl_as_of_date 
		   else sdd.contract_expiration_date end  AND spc.maturity_date=sdpd.term_start

		   left join source_deal_type sdt on sdt.source_deal_type_id = sdh.source_deal_type_id
			'+CASE WHEN (@discount_option = 'u') THEN '' ELSE 
					' left outer join ' + @DiscountTableName + ' 	df on ' + 
					CASE WHEN (@is_discount_curve_a_factor IN (2)) THEN ' df.source_deal_header_id = sdpd.source_deal_header_id AND df.term_start = sdpd.term_start '
					ELSE  ' df.term_start = sdpd.term_start AND df.fas_subsidiary_id = sub.entity_id ' END 
			END 
	
		+' LEFT JOIN source_deal_detail sdd1 on sdh.source_deal_header_id=sdd1.source_deal_header_id
							  AND sdd.term_start=sdd1.term_start and sdd1.leg=1
			LEFT JOIN source_price_curve_def spcd1 ON sdd1.curve_id = spcd1.source_curve_def_id '

			+' WHERE 1=1 ' + @Sql 

		--PRINT '/********************test/**********************/'		
		--PRINT @Sql
		EXEC(@Sql)
		EXEC('delete '+@vol_frequency_table)
		SET @Sql='
				INSERT INTO '+@vol_frequency_table+'(term_start,term_end,deal_volume_frequency,block_type,block_definition_id,deal_volume)
				SELECT DISTINCT 
							tp.term_start, 
							tp.term_end,
							max(tp.deal_volume_frequency) AS deal_volume_frequency,
							tp.block_type,
							tp.block_define_id as block_definition_id,
							max(tp.deal_volume) deal_volume				
					FROM
						#deal_pnl_detail tp
					WHERE 
						tp.deal_volume_frequency IN(''d'',''h'')
						GROUP BY tp.term_start,tp.term_end,tp.block_type,tp.block_define_id
					'
		--PRINT(@Sql)	
		EXEC(@Sql)								

		--select * from #deal_pnl_detail
		EXEC spa_get_dealvolume_mult_byfrequency @vol_frequency_table,@as_of_date_mult,@as_of_date_mult_to,'n',@settlement_option

		CREATE TABLE #sorttable(
			[Sub] VARCHAR(500) COLLATE DATABASE_DEFAULT ,
			[Strategy] VARCHAR(500) COLLATE DATABASE_DEFAULT ,
			[Book] VARCHAR(500) COLLATE DATABASE_DEFAULT ,
			[DealID] VARCHAR(500) COLLATE DATABASE_DEFAULT ,
			[REF ID] VARCHAR(500) COLLATE DATABASE_DEFAULT ,
			[Trade TYPE] VARCHAR(500) COLLATE DATABASE_DEFAULT ,
			[Counterparty] VARCHAR(500) COLLATE DATABASE_DEFAULT ,
			[Trader] VARCHAR(500) COLLATE DATABASE_DEFAULT ,
			[Deal DATE] VARCHAR(20) COLLATE DATABASE_DEFAULT ,
			[PNLDate] VARCHAR(20) COLLATE DATABASE_DEFAULT ,
			[Term] VARCHAR(20) COLLATE DATABASE_DEFAULT ,
			[Leg] VARCHAR(20) COLLATE DATABASE_DEFAULT ,
			[Buy/Sell] VARCHAR(20) COLLATE DATABASE_DEFAULT ,
			[INDEX] VARCHAR(100) COLLATE DATABASE_DEFAULT ,
			[Market Price] FLOAT,
			[Fixed Cost] FLOAT,
			[Formula Price] FLOAT,
			[Deal Fixed Price] FLOAT,
			[Price Adder] FLOAT,
			[Deal Price] FLOAT,
			[Net Price] FLOAT,
			[Multiplier] FLOAT,
			[Volume] FLOAT,
			[UOM] VARCHAR(20) COLLATE DATABASE_DEFAULT ,
			[Discount Factor] FLOAT,
			[MTM] FLOAT,
			[Discounted MTM] FLOAT,
			[Settlement] FLOAT
		)

		SET @Sql1='INSERT INTO #sorttable (
			[Sub],
			[Strategy],
			[Book],
			[DealID],
			[REF ID],
			[Trade TYPE],
			[Counterparty],
			[Trader],
			[Deal DATE],
			[PNLDate],
			[Term],
			[Leg],
			[Buy/Sell],
			[INDEX],
			[Market Price],
			[Fixed Cost],
			[Formula Price],
			[Deal Fixed Price],
			[Price Adder],
			[Deal Price],
			[Net Price],
			[Multiplier],
			[Volume],
			[UOM],'+
			
			CASE WHEN @settlement_only = 'n' THEN 
			'
			[Discount Factor],
			[MTM],
			[Discounted MTM]
			'
			ELSE 
			'[Settlement]' 
			END 
			+ '			
		)
		SELECT 
			[Sub],
			[Strategy],
			[Book],
			[DealID],
			[Ref ID],
			[Trade Type],
			[Counterparty],
			[Trader],
			dbo.FNAStdDate([Deal Date]) [Deal Date],
			[PNLDate],
			[Term],
			[Leg],
			[Buy/Sell],
			[Index],
			[Market Price],
			[Fixed Cost],
			[Formula Price],
			[Deal Fixed Price],
			[Price Adder],
			[Deal Price],
			[Net Price],
			[Multiplier],
			[Volume] *'+CASE WHEN @use_bom_logic=0 THEN '1' ELSE 'CASE WHEN physical_financial_flag=''f'' THEN 1 ELSE abs(ISNULL(dpd.deal_volume/(ISNULL(NULLIF(volume,0),1)/ISNULL(NULLIF(vft.Volume_MULT,0),1)),1)) END ' END +' [Volume],
			--dpd.deal_volume*ISNULL(vft.Volume_MULT,1) AS [Volume],
			[UOM]
			'
	--		 +CASE WHEN @settlement_only='n' THEN ',[Discount Factor]' ELSE '' END 
	--		 +CASE WHEN @settlement_only='n' THEN ',[MTM] AS MTM' ELSE ',[MTM] AS [Settlement]' END
	--		 +CASE WHEN @settlement_only='n' THEN  ',[Discounted MTM]' ELSE '' END+ '

			 +CASE WHEN @settlement_only='n' THEN ',[Discount Factor],
			[MTM] * '+CASE WHEN @use_bom_logic=0 THEN '1' ELSE 'CASE WHEN physical_financial_flag=''f'' THEN 1 ELSE (dpd.deal_volume*ISNULL(NULLIF(vft.Volume_MULT,0),1))/ISNULL(NULLIF(volume/ISNULL(NULLIF([Multiplier],0),1),0),1) END' END+' AS [MTM],
			[Discounted MTM]* '+CASE WHEN @use_bom_logic=0 THEN '1' ELSE ' CASE WHEN physical_financial_flag=''f'' THEN 1 ELSE (dpd.deal_volume*ISNULL(NULLIF(vft.Volume_MULT,0),1))/ISNULL(NULLIF(volume/ISNULL(NULLIF([Multiplier],0),1),0),1) END ' END+' [Discounted MTM]' ELSE ',
			[MTM]* '+CASE WHEN @use_bom_logic=0 THEN '1' ELSE ' CASE WHEN physical_financial_flag=''f'' THEN 1 ELSE (dpd.deal_volume*ISNULL(NULLIF(vft.Volume_MULT,0),1))/ISNULL(NULLIF(volume/ISNULL(NULLIF([Multiplier],0),1),0),1) END ' END+' AS [Settlement]' END +'
					
		FROM
			#deal_pnl_detail dpd
			 LEFT JOIN '+@vol_frequency_table+' vft 
				ON vft.term_start=dpd.term_start
				AND vft.term_end=dpd.term_end 
				AND ISNULL(vft.block_type,-1)=ISNULL(dpd.block_type,-1) AND
				ISNULL(vft.block_definition_id,-1)=ISNULL(dpd.block_define_id,-1)
				AND ISNULL(vft.deal_volume_frequency,-1)=ISNULL(dpd.deal_volume_frequency,-1) '+
				' order by [Term],[sub],[Strategy],[book],[DealID],leg '
		
		EXEC (@Sql1)
		--SET @sql='select * from #sorttable'
		
	
		SET @sql='
			select 
				[Sub],
				[Strategy],
				[Book],
				[DealID],
				[Ref ID],
				[Trade Type],
				[Counterparty],
				[Trader],
				[Deal Date],
				[PNLDate],
				--[Term],
				dbo.FNADateFormat([Term]) as [Term],
				--CONVERT(varchar,Term,101) as [Term],
				[Leg],
				[Buy/Sell],
				[Index],
				[Market Price],
				[Fixed Cost],
				[Formula Price],
				[Deal Fixed Price],
				[Price Adder],
				[Deal Price],
				[Net Price],
				[Multiplier],
				[Volume],
				[UOM],
				'+CASE WHEN @settlement_only='n' THEN '
				[Discount Factor],
				[MTM],
				[Discounted MTM]'
				ELSE '[Settlement]' END+'
			
				' + @str_batch_table +

					'
			from #sorttable'
			--order by [Term],[sub],[Strategy],[book],[DealID],leg '
		
		--PRINT('final sql: ' + @Sql)
		--exec (@Sql)
		--	
	END

	ELSE
		SET @Sql = 
		'select Sub, Strategy, Book, hedge_or_item [Type], round(sum(pnl), ' +@round_value + ') [Cumulative FV]
		' + @str_batch_table +
		' 	from #temp_pnl
		group by Sub, Strategy, Book, hedge_or_item 
		order by Sub, Strategy, Book, hedge_or_item ' 
	
	--PRINT @Sql
	EXEC (@Sql)
	
	
END

ELSE
BEGIN  -- first day gain loss threshold value exceed
--exec spa_Create_MTM_Period_Report '2008-05-16', '291,30,1,257,258,256', NULL, NULL, 'u', 'a', 'a', 'd',NULL,NULL,NULL,'2001-05-16',NULL,NULL,NULL,NULL,NULL,NULL,'y',400,NULL,NULL,NULL,NULL,'n','y','n','y'
	CREATE TABLE #final_first_gain_result(
			source_deal_header_id INT,
			deal_id VARCHAR(500) COLLATE DATABASE_DEFAULT ,
			deal_date VARCHAR(10) COLLATE DATABASE_DEFAULT ,
			pnl_as_of_date VARCHAR(10) COLLATE DATABASE_DEFAULT ,
			market_input VARCHAR(500) COLLATE DATABASE_DEFAULT ,
			treatment_type VARCHAR(500) COLLATE DATABASE_DEFAULT ,
			der_item VARCHAR(500) COLLATE DATABASE_DEFAULT ,
			counterparty VARCHAR(500) COLLATE DATABASE_DEFAULT ,
			volume VARCHAR(100) COLLATE DATABASE_DEFAULT ,
			deal_type VARCHAR(20) COLLATE DATABASE_DEFAULT ,
			pnl VARCHAR(20) COLLATE DATABASE_DEFAULT ,
			fas_deal_type_id VARCHAR(20) COLLATE DATABASE_DEFAULT 
		)
		
	--IF ISNULL(@show_prior_processed_values, 'n') = 'n'
	--BEGIN
	INSERT INTO #final_first_gain_result(source_deal_header_id,deal_id,deal_date,pnl_as_of_date,market_input,treatment_type,der_item,counterparty,volume,deal_type,pnl,fas_deal_type_id)
		SELECT	sdh.source_deal_header_id [Deal ID],
				--dbo.FNAHyperLink(10131010,sdh.deal_id,sdh.source_deal_header_id,ISNULL(@batch_process_id,'-1')) AS [Ref ID],
				dbo.FNATRMWinHyperlink('a', 10131010, sdh.deal_id, ABS(sdh.source_deal_header_id),null,null,null,null,null,null,null,null,null,null,null,0) AS  [Rel ID],
				dbo.FNADateFormat(sdh.deal_date) [Deal Date],
				dbo.FNADateFormat(et.pnl_as_of_date) [PNL Date],
				MAX(sd.code) [Market Input],
				NULL [Treatment],
				MAX(CASE WHEN (mC.fas_deal_type_value_id IS NULL) THEN 'Unknown' WHEN (mC.fas_deal_type_value_id = 400) THEN 'Derivative' ELSE 'Item' END) [Der/Item],
				MAX(et.counterparty_name) AS [Counterparty],
				--max(volume) as Volume,
				CONVERT(DECIMAL(18,2),ROUND(MAX(volume),2)) AS Volume,
				MAX(sdt.source_deal_type_name) [Deal Type],
				--round(sum(pnl), 2) PNL,
				CONVERT(DECIMAL(18,2),ROUND(SUM(pnl), 2)) AS PNL,
				MAX(mC.fas_deal_type_value_id) [Type]		
				FROM 

			(
				SELECT source_deal_header_id, SUM(pnl) pnl, MAX(pnl_as_of_date) pnl_as_of_date, MAX(counterparty_name) counterparty_name
				FROM #temp_pnl GROUP BY source_deal_header_id
				HAVING ABS(SUM(pnl)) >= MAX(ISNULL(first_day_pnl_threshold, 0))
			) et INNER JOIN

				source_deal_header sdh ON sdh.source_deal_header_id = et.source_deal_header_id 

			INNER JOIN

				(

					SELECT sdd.source_deal_header_id, MAX(curve_id) curve_id, AVG(deal_volume) volume, MAX(fas_deal_type_value_id) fas_deal_type_value_id  
						FROM source_deal_detail sdd INNER JOIN
						#temp_pnl ON #temp_pnl.source_deal_header_id = sdd.source_deal_header_id
					 GROUP BY sdd.source_deal_header_id
				) mC  ON mc.source_deal_header_id = sdh.source_deal_header_id INNER JOIN  
				source_price_curve_def spcd ON spcd.source_curve_def_id = mc.curve_id LEFT OUTER JOIN	
				static_data_value sd ON sd.value_id = spcd.fv_level LEFT OUTER JOIN
				source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id LEFT OUTER JOIN
				first_Day_gain_loss_decision fdld ON fdld.source_deal_header_id = sdh.source_deal_header_id  
		 WHERE fdld.source_deal_header_id IS NULL
		GROUP BY sdh.source_deal_header_id, sdh.deal_id, sdh.deal_date, et.pnl_as_of_date		
	--END
	--ELSE
	--BEGIN
	INSERT INTO #final_first_gain_result(source_deal_header_id,deal_id,deal_date,pnl_as_of_date,market_input,treatment_type,der_item,counterparty,volume,deal_type,pnl,fas_deal_type_id)
				
		SELECT	sdh.source_deal_header_id [Deal ID],

				--dbo.FNAHyperLink(10131010,sdh.deal_id,sdh.source_deal_header_id,ISNULL(@batch_process_id,'-1')) AS [Ref ID],
				dbo.FNATRMWinHyperlink('a', 10131010, sdh.deal_id, ABS(sdh.source_deal_header_id),null,null,null,null,null,null,null,null,null,null,null,0) AS  [Rel ID],
				dbo.FNADateFormat(sdh.deal_date) [Deal Date],

				dbo.FNADateFormat(fdld.deal_date) [PNL Date],

				MAX(sd.code) [Market Input],

				MAX(st.code) [Treatment],

				MAX(CASE WHEN (pd.fas_deal_type_value_id IS NULL) THEN 'Unknown' WHEN (pd.fas_deal_type_value_id = 400) THEN 'Derivative' ELSE 'Item' END) [Der/Item],

				MAX(sc.counterparty_name) AS [Counterparty],

				--max(volume) as Volume,
				CONVERT(DECIMAL(18,2),ROUND(MAX(volume),2)) AS Volume,

				MAX(sdt.source_deal_type_name) [Deal Type],

				--round(sum(fdld.first_day_pnl), 2) PNL,
				CONVERT(DECIMAL(18,2),ROUND(SUM(fdld.first_day_pnl), 2)) AS PNL,

				MAX(pd.fas_deal_type_value_id) [Type]
				--INTO #final_first_gain_result
				FROM 

				first_Day_gain_loss_decision fdld INNER JOIN

				source_deal_header sdh ON sdh.source_deal_header_id = fdld.source_deal_header_id LEFT OUTER JOIN

				(

				SELECT sdd.source_deal_header_id, MAX(sdd.curve_id) curve_id, AVG(sdd.deal_volume) volume FROM 
					first_Day_gain_loss_decision fdld INNER JOIN
					source_deal_detail sdd ON sdd.source_deal_header_id = fdld.source_deal_header_id  										
				 GROUP BY sdd.source_deal_header_id

				) mC  ON mc.source_deal_header_id = sdh.source_deal_header_id LEFT OUTER JOIN  				

				#pnl_date pd ON pd.source_deal_header_id = sdh.source_deal_header_id LEFT OUTER JOIN  				
				source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id LEFT OUTER JOIN  
				source_price_curve_def spcd ON spcd.source_curve_def_id = mc.curve_id LEFT OUTER JOIN
				static_data_value sd ON sd.value_id = spcd.fv_level LEFT OUTER JOIN
				source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id LEFT OUTER JOIN
				static_data_value st ON st.value_id = fdld.treatment_value_id
			WHERE fdld.source_deal_header_id IS NOT NULL
			GROUP BY sdh.source_deal_header_id, sdh.deal_id, sdh.deal_date, fdld.deal_date
		--END
		
		SELECT treatment_type
			, der_item
			, source_deal_header_id
			, deal_id
			, deal_date
			, pnl_as_of_date
			, counterparty
			, deal_type
			, volume
			, market_input			 
			, pnl
			, CASE WHEN treatment_type IS NULL THEN 'Not Processed' ELSE 'Processed' END Status
			, fas_deal_type_id
		FROM #final_first_gain_result
		ORDER BY source_deal_header_id,pnl_as_of_date
	RETURN

END	



--print @Sql


summary_option_s:


IF @discount_option = 'd'

BEGIN

	DECLARE @deleteStmt VARCHAR(500)
	SET @deleteStmt = dbo.FNAProcessDeleteTableSql(@DiscountTableName)
	EXEC (@deleteStmt)

END





--*****************FOR BATCH PROCESSING**********************************            
/*
IF  @batch_process_id is not null        

BEGIN        

 SELECT @str_batch_table=dbo.FNABatchProcess('u',@batch_process_id,@batch_report_param,GETDATE(),NULL,NULL)         

 EXEC(@str_batch_table)        

 
IF @settlement_only='y'
set @report_name='Run Settlement Report'        
ELSE 
 set @report_name='Run MTM Report'        

        

 SELECT @str_batch_table=dbo.FNABatchProcess('c',@batch_process_id,@batch_report_param,GETDATE(),'spa_Create_MTM_Period_Report',@report_name)         

 EXEC(@str_batch_table)        

        

END        
*/

/*******************************************2nd Paging Batch START**********************************************/
--update time spent and batch completion message in message board
IF @is_batch = 1
BEGIN
	 SELECT @str_batch_table=dbo.FNABatchProcess('u',@batch_process_id,@batch_report_param,GETDATE(),NULL,NULL)   
	 EXEC(@str_batch_table)                   
	DECLARE @msg VARCHAR(100)
	IF @settlement_only='y'
	BEGIN
		SET @msg = 'Settlement Report'
	END
	ELSE 
	BEGIN
		SET @msg = 'MTM Report'
	END 
	SELECT @str_batch_table = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_Create_MTM_Period_Report', @msg)         
	EXEC(@str_batch_table)        
	RETURN

END

--if it is first call from paging, return total no. of rows and process id instead of actual data
IF @enable_paging = 1 AND @page_no IS NULL
BEGIN
	SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
	EXEC(@sql_paging)
END
/*******************************************2nd Paging Batch END**********************************************/
