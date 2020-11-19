
IF OBJECT_ID(N'[dbo].[spa_Counterparty_MTM_Report]', N'P') IS NOT NULL
DROP PROC [dbo].[spa_Counterparty_MTM_Report] 
go


CREATE PROC [dbo].[spa_Counterparty_MTM_Report] 
					@as_of_date varchar(50),
					@previous_as_of_date varchar(50) = null,
					@sub_entity_id varchar(MAX), 
					@strategy_entity_id varchar(MAX) = NULL, 
					@book_entity_id varchar(MAX) = NULL, 
		--			@discount_option char(1), 
					@settlement_option char(1), 
	--				@report_type char(1), 
					@summary_option char(1),
					@counterparty_id NVARCHAR(MAX)= NULL, 
					@tenor_from varchar(50)= null,
					@tenor_to varchar(50) = null,
					@trader_id int = null,
					@include_item char(1)='n', -- to include item in cash flow hedge
					@source_system_book_id1 int=NULL, 
					@source_system_book_id2 int=NULL, 
					@source_system_book_id3 int=NULL, 
					@source_system_book_id4 int=NULL, 
				--	@show_firstday_gain_loss char(1)='n', -- To Show First Day Gain/Loss
					@transaction_type VARCHAR(500)=null,
					@deal_id_from VARCHAR(100) = NULL,
					@deal_id_to VARCHAR(100) = NULL,
					@deal_id varchar(100)=null,
					@threshold_values float=null,
					@show_prior_processed_values char(1)='n',
					@exceed_threshold_value char(1)='n',   -- For First Day gain Loss Treatment selection
				--	@show_only_for_deal_date char(1)='y',
					@use_create_date char(1)='n',
					@round_value char(1) = '0',
					@counterparty char(1) = 'a', --i means only internal and e means only external, a means all
			--		@mapped char(1) = 'm', --m means mapped only, n means non-mapped only,
					@match_id char(1) = 'n', --'y' means use like for deal ids and 'n' means use 
					@cpty_type_id int = NULL,  
					@curve_source_id INT,
					@deal_type_id int=NULL,
					@deal_date_from varchar(20)=NULL,
					@deal_date_to varchar(20)=NULL,
					@phy_fin varchar(1)='b',
					@deal_sub_type VARCHAR(10)='t',
					@period_report varchar(1)='n',
					@term_start VARCHAR(20)=NULL,
					@term_end VARCHAR(20)=NULL,
					@settlement_date_from VARCHAR(20)=NULL,
					@settlement_date_to VARCHAR(20)=NULL,
					@settlement_only CHAR(1)='n',
					@grouping CHAR(1)='a',     --a=Sub/Strategy/Book; b=Sub/Strategy/Book/Counterparty; c=Counterparty
											--d= Book; e=Sub f=Strategy

--					@drill1 varchar(100)=NULL,
--					@drill2 varchar(100)=NULL,
--					@drill3 varchar(100)=NULL,
--					@drill4 varchar(100)=NULL,
--					@drill5 varchar(100)=NULL,
					@deal_list_table VARCHAR(200) = NULL,
					--@deal_filter_id VARCHAR(200) = NULL,
					@batch_process_id varchar(50)=NULL,
					@batch_report_param varchar(1000)=NULL,
					@enable_paging int=0,  --'1'=enable, '0'=disable
					@page_size int =NULL,
					@page_no int=NULL


					
AS

SET NOCOUNT ON
---------------------------------------------------------------
/*
 declare @as_of_date varchar(50), @sub_entity_id varchar(100), 
  	@strategy_entity_id varchar(100), 
  	@book_entity_id varchar(100), @discount_option char(1), 
  	@settlement_option char(1), @report_type char(1), @summary_option char(1),
 	@counterparty_id varchar(500), @tenor_from varchar(50), @tenor_to varchar(50),
 	@previous_as_of_date varchar(50), @trader_id int 
	,@counterparty char(1),	@enable_paging int,
					@page_size int,
					@page_no int,

@match_id char(1),
@deal_sub_type CHAR(1),
@settlement_date_from VARCHAR(20),
@settlement_date_to VARCHAR(20),
@term_start VARCHAR(20),
@term_end VARCHAR(20),
@period_report varchar(1),
@settlement_only varchar(1),
@curve_source_id INT,@grouping CHAR(1),@deal_type_id int,
@deal_date_from varchar(20),
					@deal_date_to varchar(20),
					@cpty_type_id int,@phy_fin varchar(1)

select @counterparty='a',
@match_id='n',
@deal_sub_type='t',
@settlement_date_from=null,
@settlement_date_to=null,
@term_start=null,
@term_end=null,
@period_report='y',
@settlement_only='n' ,
@curve_source_id =4500,@grouping='a',
	@enable_paging=0,
					@page_size=NULL,
					@page_no =NULL
declare	@include_item char(1), -- to include item in cash flow hedge
	@source_system_book_id1 int, 
	@source_system_book_id2 int, 
	@source_system_book_id3 int, 
	@source_system_book_id4 int, 
	@show_firstday_gain_loss char(1), -- To Show First Day Gain/Loss
	@transaction_type VARCHAR(500),
	@deal_id_from int,
	@deal_id_to int,
	@deal_id varchar(100),
	@threshold_values float,
	@show_prior_processed_values char(1),
	@exceed_threshold_value char(1),   -- For First Day gain Loss Treatment selection
	@show_only_for_deal_date char(1),
	@use_create_date char(1),
	@round_value char(1),
	@batch_process_id varchar(50),
	@batch_report_param varchar(1000)



select 
@as_of_date='2010-01-01',
@previous_as_of_date= '2009-12-15',
@sub_entity_id ='1',
@strategy_entity_id= NULL,
@book_entity_id= NULL,
@settlement_option = 'c',
@summary_option= 's',
@counterparty_id =NULL,
@tenor_from =NULL,
@tenor_to =NULL,
@trader_id=NULL,
@include_item =NULL,
@source_system_book_id1=NULL,
@source_system_book_id2=NULL,
@source_system_book_id3 =NULL,
@source_system_book_id4=NULL,
@transaction_type ='401,400',
@deal_id_from=NULL,
@deal_id_to=NULL,
@deal_id=NULL,
@threshold_values =NULL,
@show_prior_processed_values='n',
@exceed_threshold_value='n',
@use_create_date='n',
@round_value='2',
@counterparty ='a',
@match_id='n',
@cpty_type_id=NULL,
@curve_source_id=4500,
@deal_sub_type='b',
@deal_date_from=NULL,
@deal_date_to= NULL,
@phy_fin ='b',
@deal_type_id=NULL,
@period_report='y',
@term_start=NULL,
@term_end=NULL,
@settlement_date_from=NULL,
@settlement_date_to=NULL,
@settlement_only='n',
@grouping ='c'


drop table #deal_pnl1
drop table #deal_pnl0
drop table #deal_pnl
drop table  #books
--*/
---------------------------------------------------------------
/*
@summary_option:
i.    s=  Summary

ii.   t=   Summary By Term

iii.   d=   Detail

iv.    m=  Detail By Term
*/

Declare @Sql varchar(8000)
Declare @SqlG varchar(500)
Declare @SqlW varchar(500)
Declare @DiscountTableName varchar(100)
Declare @DiscountTableName0 varchar(100)
DECLARE @process_id varchar(50)
--DECLARE @drill varchar(1)
DECLARE @prior_summary_option varchar(1)
DECLARE @save_sql varchar(8000)

--SELECT * FROM #deal_pnl0
Declare @deal_sub_type_name  varchar(50)
set @deal_sub_type_name = (select deal_type_id from source_deal_type where source_deal_type_id = @deal_sub_type)

SET @deal_sub_type = CASE 
    WHEN @deal_sub_type_name = 'Both' THEN 
        'b'
	When @deal_sub_type_name = 'Spot' THEN 
		's'
    ELSE
        't'
END

CREATE TABLE #source_deal_header_id (source_deal_header_id INT)
IF OBJECT_ID(@deal_list_table) IS NOT NULL
BEGIN
    EXEC ('INSERT INTO #source_deal_header_id  SELECT DISTINCT source_deal_header_id FROM ' + @deal_list_table)
END

--////////////////////////////Paging_Batch///////////////////////////////////////////
EXEC spa_print	'@batch_process_id:', @batch_process_id 
EXEC spa_print	'@batch_report_param:', @batch_report_param

declare @str_batch_table varchar(max),@str_get_row_number VARCHAR(100)
declare @temptablename varchar(100),@user_login_id varchar(50),@flag CHAR(1)
DECLARE @is_batch bit
set @str_batch_table=''
SET @str_get_row_number=''

declare @sql_stmt varchar(5000)

IF @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL
	SET @is_batch = 1
ELSE
	SET @is_batch = 0
	
IF (@is_batch = 1 OR @enable_paging = 1)
begin
	IF (@batch_process_id IS NULL)
		SET @batch_process_id = REPLACE(NEWID(), '-', '_')
		
	SET @user_login_id = dbo.FNADBUser()	
	SET @temptablename = dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)
	exec spa_print '@temptablename', @temptablename
	SET @str_batch_table=', ROWID=IDENTITY(int,1,1) INTO ' + @temptablename
--	SET @str_get_row_number=', ROWID=IDENTITY(int,1,1)'
	IF @enable_paging = 1
	BEGIN

		IF @page_size IS not NULL
		begin
			declare @row_to int,@row_from int
			set @row_to=@page_no * @page_size
			if @page_no > 1 
				set @row_from =((@page_no-1) * @page_size)+1
			else
				set @row_from =@page_no
			set @sql_stmt=''
			--	select @temptablename
			--select * from adiha_process.sys.columns where [object_id]=object_id(@temptablename) and [name]<>'ROWID' ORDER BY column_id

			select @sql_stmt=@sql_stmt+',['+[name]+']' from adiha_process.sys.columns WITH(NOLOCK) where [object_id]=object_id(@temptablename) and [name]<>'ROWID' ORDER BY column_id
			SET @sql_stmt=SUBSTRING(@sql_stmt,2,LEN(@sql_stmt))
			
			set @sql_stmt='select '+@sql_stmt +'
				  from '+ @temptablename   +' 
				  where rowid between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) 
				 
		--	exec spa_print @sql_stmt		
			exec(@sql_stmt)
			return
		END --else @page_size IS not NULL
	END --enable_paging = 1
		
end

--////////////////////////////End_Batch///////////////////////////////////////////




CREATE TABLE #books (fas_book_id int) 


--Declare @DiscountTableName varchar(100)
--Declare @DiscountTableName0 varchar(100)

SET @process_id = REPLACE(newid(),'-','_')
SET @DiscountTableName = dbo.FNAProcessTableName('calcprocess_discount_factor', dbo.FNADBUser(), @process_id)
SET @DiscountTableName0 = dbo.FNAProcessTableName('calcprocess_discount_factor_prev', dbo.FNADBUser(), @process_id)

if @counterparty IS NULL
	set @counterparty = 'a'

if @match_id IS NULL
	set @match_id = 'n'

set @SqlW = ''

--###### For the Deal sub type filter
--IF @deal_sub_type='t'
--	SET @deal_sub_type=2
--ELSE IF @deal_sub_type='s'
--	SET @deal_sub_type=1

---######

If @settlement_date_from IS NOT NULL and @settlement_date_to IS NULL
	SET @settlement_date_to=@settlement_date_from
If @settlement_date_from IS NULL and @settlement_date_to IS NOT NULL
	SET @settlement_date_from=@settlement_date_to

If @term_start IS NOT NULL and @term_end IS NULL
	SET @term_end=@term_start
If @term_start IS NULL and @term_end IS NOT NULL
	SET @term_start=@term_end


exec spa_Calc_Discount_Factor @as_of_date, @sub_entity_id, @strategy_entity_id, @book_entity_id, @DiscountTableName
exec spa_Calc_Discount_Factor @previous_as_of_date, @sub_entity_id, @strategy_entity_id, @book_entity_id, @DiscountTableName0

--Make sure PERIOD REPORT only uses regular MTM report
If @period_report = 'y' AND @previous_as_of_date IS NOT NULL
BEGIN
	SET @show_prior_processed_values = 'n'
--	SET @show_only_for_deal_date = 'n'
--	SET @show_firstday_gain_loss = 'n'
	SET @exceed_threshold_value = 'n'
	--SET @settlement_option = 'f'
END

CREATE TABLE [#deal_pnl1](
	[Sub] [varchar](100) COLLATE DATABASE_DEFAULT NULL,
	[Strategy] [varchar](100) COLLATE DATABASE_DEFAULT NULL,
	[Book] [varchar](100) COLLATE DATABASE_DEFAULT NULL,
	[Counterparty] [varchar](100) COLLATE DATABASE_DEFAULT NULL,
	[DealNumber] [varchar](500) COLLATE DATABASE_DEFAULT NULL,
	[DealDate] [varchar](50) COLLATE DATABASE_DEFAULT NULL,
	[PNLDate] [varchar](50) COLLATE DATABASE_DEFAULT NULL,
	[Type] [varchar](8) COLLATE DATABASE_DEFAULT NULL,
	[Phy/Fin] [varchar](3) COLLATE DATABASE_DEFAULT NULL,
	[Expiration] [varchar](50) COLLATE DATABASE_DEFAULT NULL,
	[CumulativeFV] [float] NULL,
	[term_start] datetime NULL, --new clm
	[source_deal_header_id] VARCHAR(100) COLLATE DATABASE_DEFAULT, --new clm
	[pnl_as_of_date] datetime ,--new clm
	[deal_volume] float,
	uom varchar(150) COLLATE DATABASE_DEFAULT,
	currency varchar(100) COLLATE DATABASE_DEFAULT,
	dis_pnl FLOAT,
	block_type int,
	block_definition_id int,term_end datetime,
	deal_volume_frequency CHAR(1) COLLATE DATABASE_DEFAULT
)

CREATE TABLE [#deal_pnl0](
	[Sub] [varchar](100) COLLATE DATABASE_DEFAULT NULL,
	[Strategy] [varchar](100) COLLATE DATABASE_DEFAULT NULL,
	[Book] [varchar](100) COLLATE DATABASE_DEFAULT NULL,
	[Counterparty] [varchar](100) COLLATE DATABASE_DEFAULT NULL,
	[DealNumber] [varchar](500) COLLATE DATABASE_DEFAULT NULL,
	[DealDate] [varchar](50) COLLATE DATABASE_DEFAULT NULL,
	[PNLDate] [varchar](50) COLLATE DATABASE_DEFAULT NULL,
	[Type] [varchar](8) COLLATE DATABASE_DEFAULT NULL,
	[Phy/Fin] [varchar](3) COLLATE DATABASE_DEFAULT NULL,
	[Expiration] [varchar](50) COLLATE DATABASE_DEFAULT NULL,
	[CumulativeFV] [float] NULL,
	[term_start] datetime NULL, --new clm
	[source_deal_header_id] VARCHAR(100) COLLATE DATABASE_DEFAULT, --new clm
	[pnl_as_of_date] datetime, --new clm
	[deal_volume] float,
	uom varchar(150) COLLATE DATABASE_DEFAULT,
	currency varchar(100) COLLATE DATABASE_DEFAULT,
	dis_pnl FLOAT,
	block_type int,
	block_definition_id int,term_end datetime,
	deal_volume_frequency CHAR(1) COLLATE DATABASE_DEFAULT
)

CREATE TABLE [#deal_pnl](
	[Sub] [varchar](100) COLLATE DATABASE_DEFAULT NULL,
	[Strategy] [varchar](100) COLLATE DATABASE_DEFAULT NULL,
	[Book] [varchar](100) COLLATE DATABASE_DEFAULT NULL,
	[Counterparty] [varchar](100) COLLATE DATABASE_DEFAULT NULL,
	[DealNumber] [varchar](500) COLLATE DATABASE_DEFAULT NULL,
	[DealDate] [varchar](50) COLLATE DATABASE_DEFAULT NULL,
	[PNLDate] [varchar](50) COLLATE DATABASE_DEFAULT NULL,
	[Type] [varchar](8) COLLATE DATABASE_DEFAULT NULL,
	[Phy/Fin] [varchar](3) COLLATE DATABASE_DEFAULT NULL,
	[Expiration] [varchar](50) COLLATE DATABASE_DEFAULT NULL,
	[CumulativeFV] [float] NULL,
	[term_start] datetime NULL, --new clm
	[source_deal_header_id] int, --new clm
	[pnl_as_of_date] datetime, --new clm
	[deal_volume] float,
	uom varchar(150) COLLATE DATABASE_DEFAULT,
	currency varchar(100) COLLATE DATABASE_DEFAULT,
	dis_pnl float
)

SET @sql=        

'INSERT INTO  #books
SELECT distinct book.entity_id fas_book_id FROM portfolio_hierarchy book (nolock) INNER JOIN
		Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id LEFT OUTER JOIN            
		source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id         
WHERE (fas_deal_type_value_id IS NULL OR fas_deal_type_value_id BETWEEN 400 AND 401) 

'   

IF @sub_entity_id IS NOT NULL        
  SET @sql = @sql + ' AND stra.parent_entity_id IN  ( ' + @sub_entity_id + ') '         

IF @strategy_entity_id IS NOT NULL        
  SET @sql = @sql + ' AND (stra.entity_id IN(' + @strategy_entity_id + ' ))'        

IF @book_entity_id IS NOT NULL        
  SET @sql = @sql + ' AND (book.entity_id IN(' + @book_entity_id + ')) '        
--print(@Sql)
exec(@Sql)

set @Sql=''


If @trader_id IS NOT NULL 
   	SET @Sql = @Sql + ' AND sdh.trader_id = ' + cast(@trader_id as varchar)

If @deal_type_id IS NOT NULL 
   	SET @Sql = @Sql + ' AND sdh.source_deal_type_id = ' + cast(@deal_type_id as varchar)

If @counterparty_id IS NOT NULL 

   	SET @Sql = @Sql + + ' AND (sdh.counterparty_id IN (' + @counterparty_id + ')) '



If @source_system_book_id1 IS NOT NULL 

   	SET @Sql = @Sql +  ' AND (sdh.source_system_book_id1 IN (' + cast(@source_system_book_id1 as varchar)+ ')) '

If @source_system_book_id2 IS NOT NULL 

   	SET @Sql = @Sql +  ' AND (sdh.source_system_book_id2 IN (' + cast(@source_system_book_id2 as varchar) + ')) '

If @source_system_book_id3 IS NOT NULL 

   	SET @Sql = @Sql +  ' AND (sdh.source_system_book_id3 IN (' + cast(@source_system_book_id3 as varchar) + ')) '

If @source_system_book_id4 IS NOT NULL 

   	SET @Sql = @Sql +  ' AND (sdh.source_system_book_id4 IN (' + cast(@source_system_book_id4 as varchar) + ')) '


if @deal_sub_type<>'b'
begin
	if @deal_sub_type='t'
		SET @Sql = @Sql +  ' AND (sdt.deal_type_id =''Term'') '
	else if @deal_sub_type='s'
		SET @Sql = @Sql +  ' AND (sdt.deal_type_id =''Spot'') '
end 
--If @mapped = 'm' AND isnull(@counterparty, 'a') <> 'a'
If  isnull(@counterparty, 'a') <> 'a'
   	SET @Sql = @Sql + + ' AND sc.int_ext_flag = ''' + @counterparty + ''''



If @cpty_type_id IS NOT NULL
   	SET @Sql = @Sql + + ' AND sc.type_of_entity = ' + CAST(@cpty_type_id AS VARCHAR) 

if @transaction_type is not null 
	SET @Sql = @Sql +  ' AND ssbm.fas_deal_type_value_id IN( ' + cast(@transaction_type as varchar(500))+')'

--If @deal_date_from IS NOT NULL AND @deal_date_to IS NOT NULL
--	SET @Sql = @Sql + ' AND sdh.deal_date between ''' + @deal_date_from  + ''' AND ''' + @deal_date_to + ''''

--Deal Date Filter applied

IF (@deal_date_from IS NOT NULL)
		SET @Sql = @Sql +' AND convert(varchar(10),sdh.deal_date,120)>='''+convert(varchar(10),@deal_date_from,120) +''''

IF (@deal_date_to IS NOT NULL)
	SET @Sql = @Sql +' AND convert(varchar(10),sdh.deal_date,120) <='''+convert(varchar(10),@deal_date_to,120) +''''





If isnull(@phy_fin, 'b') <> 'b'
   	SET @Sql = @Sql + + ' AND sdh.physical_financial_flag = ''' + @phy_fin + ''''





if @tenor_from is null and @tenor_to is not null
	set @tenor_from = @tenor_to

if @tenor_from is not null and @tenor_to is null
	set @tenor_to = @tenor_from 

If @tenor_from  IS NOT NULL AND @tenor_to IS NOT NULL
   	SET @Sql = @Sql + ' AND sdp.term_start BETWEEN ''' + @tenor_from + ''' AND ''' +  @tenor_to + ''''




IF (@term_start IS NOT NULL)
	SET @Sql = @Sql +' AND convert(varchar(10),sdp.term_start,120) >='''+convert(varchar(10),@term_start,120) +''''

IF (@term_end IS NOT NULL)
	SET @Sql = @Sql +' AND convert(varchar(10),sdp.term_end,120)<='''+convert(varchar(10),@term_end,120) +''''


declare @Sql1 varchar(max)
set @Sql1=@Sql

if @settlement_option = 'f' 
begin
--SET @Sql = @Sql +  ' AND sdp.term_start >dbo.FNAGETCONTRACTMONTH(''' + @as_of_date + ''')'
		SET @Sql = @Sql +  ' AND sdp.term_start >(''' + @as_of_date + ''')'
		SET @Sql1 = @Sql1 +  ' AND sdp.term_start >(''' + @previous_as_of_date + ''')'
end
if @settlement_option = 'c' 
BEGIN
	--SET @Sql = @Sql +  ' AND ((sdp.term_start >= ''' + dbo.FNAGETCONTRACTMONTH(@as_of_date) + ''' AND sdd.deal_volume_frequency=''m'') OR (sdd.contract_expiration_date >= ''' + @as_of_date+ ''' AND sdd.deal_volume_frequency<>''m''))'
	--SET @Sql1 = @Sql1 +' AND ((sdp.term_start >= ''' + dbo.FNAGETCONTRACTMONTH(@previous_as_of_date) + ''' AND sdd.deal_volume_frequency=''m'') OR (sdd.contract_expiration_date >= ''' + @previous_as_of_date+ ''' AND sdd.deal_volume_frequency<>''m''))' 

	SET @Sql = @Sql +  ' AND sdp.term_start >= ''' + dbo.FNAGETCONTRACTMONTH(@as_of_date) + ''''
	SET @Sql1 = @Sql1 +' AND sdp.term_start >= ''' + dbo.FNAGETCONTRACTMONTH(@previous_as_of_date) + '''' 
END

if @settlement_option = 's'  
	BEGIN
		SET @Sql = @Sql +  ' AND sdp.term_start <= ''' + @as_of_date + ''''
		SET @Sql1 = @Sql1 +  ' AND sdp.term_start <= ''' + @previous_as_of_date + ''''
	END

--select @settlement_date_from
EXEC spa_print 'llllllllllllllllllllllllllllllllll'
--print @Sql
EXEC spa_print 'llllllllllllllllllllllllllllllllll'


declare @Sql2 varchar(max)

SET @Sql2 ='
	insert into #deal_pnl1 ([Sub],[Strategy],[Book],[Counterparty],[DealNumber],[DealDate],[PNLDate],
		[Type],[Phy/Fin] ,[Expiration],[CumulativeFV],[term_start],[source_deal_header_id],[pnl_as_of_date],
			[deal_volume],uom,currency,dis_pnl,block_type,block_definition_id,term_end,deal_volume_frequency)
	select		max(sub.entity_name) Sub, max(stra.entity_name) Strategy, max(book.entity_name) Book,											   
				max(sc.counterparty_name) Counterparty,
				dbo.FNAHyperLink(10131010,(cast(sdh.source_deal_header_id as varchar) + '' ('' + sdh.deal_id + '')''),sdh.source_deal_header_id,''-1'') DealNumber, 	 
				dbo.FNADateFormat(max(sdh.deal_date)) [DealDate],
				dbo.FNADateFormat(max(sdp.pnl_as_of_date)) [PNLDate],
				max(case when (ssbm.fas_deal_type_value_id IS NULL) then ''Unmapped'' when (ssbm.fas_deal_type_value_id = 400) then ''Der'' else '' Item'' end) [Type], 
				max(case when (sdh.physical_financial_flag = ''p'') then ''Phy'' else ''Fin'' end) [Phy/Fin],
				dbo.FNADateFormat(sdp.term_start) Expiration, ' +
				CASE WHEN @settlement_only='n' THEN   ' sum(isnull(sdp.und_pnl, 0)) CumulativeFV ' ELSE ' sum(isnull(sdp.und_pnl_set, 0)) CumulativeFV ' end +
				--THE FOLLOWING ARE 3 NEW CLMS
				',sdp.term_start, sdh.source_deal_header_id, max(sdp.pnl_as_of_date) pnl_as_of_date,max('+CASE WHEN @settlement_only='n' THEN 'sdpd.' ELSE 'sdp.' END+'deal_volume) deal_volume,max(su.uom_name) uom_name,max(scu.currency_name) currency_name,
				sum(isnull(sdp.und_pnl, 0)*isNull(df.discount_factor,1)) dis_pnl,
				MAX(ISNULL(spcd.block_type,sdh.block_type))block_type,
				MAX(ISNULL(spcd.block_define_id,sdh.block_define_id))block_definition_id,
				max(sdp.term_end) term_end,
				MAX(sdd.deal_volume_frequency)deal_volume_frequency
	from		source_deal_header sdh 
				inner join 	source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id and sdd.leg=1
			INNER JOIN '
		+	dbo.FNAGetProcessTableName(@as_of_date, CASE WHEN @settlement_only='n' THEN 'source_deal_pnl' ELSE 'source_deal_pnl_settlement' END) + ' 
						sdp on sdh.source_deal_header_id=sdp.source_deal_header_id  AND sdp.term_start=sdd.term_start '
		+CASE WHEN @settlement_only='n' THEN ' INNER JOIN source_deal_pnl_detail sdpd on sdpd.source_deal_header_id=sdp.source_deal_header_id  
				AND sdp.term_start=sdpd.term_start and sdp.leg=sdpd.leg and sdp.pnl_as_of_date=sdpd.pnl_as_of_date
		' ELSE '' END+' inner JOIN
				source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id  
				inner join source_deal_type sdt on sdt.source_deal_type_id=sdh.deal_sub_type_type_id
				inner JOIN
				source_system_book_map ssbm ON sdh.source_system_book_id1 = ssbm.source_system_book_id1 AND 
												sdh.source_system_book_id2 = ssbm.source_system_book_id2 AND 
												sdh.source_system_book_id3 = ssbm.source_system_book_id3 AND 
												sdh.source_system_book_id4 = ssbm.source_system_book_id4 LEFT OUTER JOIN
				portfolio_hierarchy book on book.entity_id = ssbm.fas_book_id inner JOIN
				portfolio_hierarchy stra on stra.entity_id = book.parent_entity_id inner JOIN
				portfolio_hierarchy sub on sub.entity_id = stra.parent_entity_id inner JOIN
				fas_strategy fs on fs.fas_strategy_id = stra.entity_id  
				inner join #books b on b.fas_book_id=ssbm.fas_book_id
				left join source_uom su on su.source_uom_id=sdd.deal_volume_uom_id
				left join source_currency scu on source_currency_id=sdp.pnl_currency_id
				left outer join ' + @DiscountTableName + ' 	df on df.term_start = sdp.term_start and
						df.fas_subsidiary_id = sub.entity_id
				LEFT OUTER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=sdd.curve_id
				' + CASE WHEN @deal_list_table IS NOT NULL THEN ' INNER JOIN #source_deal_header_id t ON sdh.source_deal_header_id = t.source_deal_header_id ' ELSE '' END + '
				Where 1=1 '
			+CASE WHEN @as_of_date IS NULL THEN ''
			ELSE + ' AND sdp.pnl_as_of_date=''' + cast(@as_of_date as varchar) + '''' END
				+CASE WHEN  @settlement_only='y' THEN ' AND ISNULL(sdd.settlement_date,sdd.contract_expiration_date)<='''+@as_of_date+'''' ELSE '' END
				+CASE WHEN  @settlement_only='y' AND @settlement_date_from IS NOT NULL THEN ' AND ISNULL(sdd.settlement_date,sdd.contract_expiration_date)>='''+@settlement_date_from+'''' ELSE '' END
				+CASE WHEN  @settlement_only='y' AND @settlement_date_to IS NOT NULL THEN ' AND ISNULL(sdd.settlement_date,sdd.contract_expiration_date)<='''+@settlement_date_to+'''' ELSE '' END


	-- Added to filter surve source
	+' And ISNULL(NULLIF(sdp.pnl_source_value_id,775),4500)=	'+CAST(@curve_source_id AS VARCHAR)+
	case when (@deal_id_from is not null and @match_id = 'n') then ' AND sdh.source_deal_header_id IN ('+cast(@deal_id_from as varchar)+')' else '' end +
	case when (@deal_id_from is not null and @match_id = 'y') then ' AND cast(sdh.source_deal_header_id as varchar) LIKE cast(' + cast(@deal_id_from as varchar) + ' as varchar) + ''%''' else '' end +
	case when (@deal_id is not null and @match_id = 'n') then ' AND sdh.deal_id IN (''' + @deal_id + ''')' else  '' end +
	--case when (@deal_filter_id is not null and @match_id = 'n') then ' AND sdh.deal_id IN (''' + @deal_filter_id + ''')' else  '' end +
	case when (@deal_id is not null and @match_id = 'y') then ' AND sdh.deal_id LIKE ''' + @deal_id + '%''' else  '' end +
	--CASE WHEN (@deal_filter_id IS NOT NULL AND @match_id = 'y') THEN ' AND sdh.deal_id LIKE ''' + @deal_filter_id + '%''' ELSE  '' END
	+ @Sql +
	'	group  by sdh.source_deal_header_id, sdh.deal_id, sdp.term_start	order by sdh.source_deal_header_id, sdh.deal_id, sdp.term_start	' 

--print(@Sql2)
exec(@Sql2)
EXEC spa_print '**********************************************************************************'


/*

DECLARE @vol_frequency_table VARCHAR(100)
SET @vol_frequency_table=dbo.FNAProcessTableName('deal_volume_frequency_mult', dbo.FNADBUser(), @process_id)

set @Sql='SELECT DISTINCT 
					tp.term_start, 
					tp.term_end,
					tp.deal_volume_frequency AS deal_volume_frequency,
					tp.block_type,
					tp.block_definition_id as block_definition_id,
					MAX(isnull(sdd.total_volume, sdd.deal_volume)) deal_volume
			INTO '+@vol_frequency_table+'
			FROM
				#deal_pnl1 tp
				LEFT JOIN source_deal_detail sdd ON sdd.source_deal_header_id=tp.source_deal_header_id
					AND sdd.term_start=tp.term_start
			WHERE 
				sdd.deal_volume_frequency IN(''d'',''h'')
			GROUP BY tp.term_start,tp.term_end,tp.block_type,tp.block_definition_id,tp.deal_volume_frequency'
			exec spa_print @Sql
EXEC(@Sql)

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
		
EXEC spa_get_dealvolume_mult_byfrequency @vol_frequency_table,@as_of_date_mult,@as_of_date_mult_to,'y',@settlement_option

*/

SET @Sql2 ='
	insert into #deal_pnl0 ([Sub],[Strategy],[Book],[Counterparty],[DealNumber],[DealDate],[PNLDate],
		[Type],[Phy/Fin] ,[Expiration],[CumulativeFV],[term_start],[source_deal_header_id],
		[pnl_as_of_date],[deal_volume],uom,currency,dis_pnl,block_type,block_definition_id,term_end,deal_volume_frequency)
	select		max(sub.entity_name) Sub, max(stra.entity_name) Strategy, max(book.entity_name) Book,
				max(sc.counterparty_name) Counterparty,
				dbo.FNAHyperLink(10131010,(cast(sdh.source_deal_header_id as varchar) + '' ('' + sdh.deal_id + '')''),sdh.source_deal_header_id,''-1'') DealNumber, 	 
				dbo.FNADateFormat(max(sdh.deal_date)) [DealDate],
				dbo.FNADateFormat(max(sdp.pnl_as_of_date)) [PNLDate],
				max(case when (ssbm.fas_deal_type_value_id IS NULL) then ''Unmapped'' when (ssbm.fas_deal_type_value_id = 400) then ''Der'' else '' Item'' end) [Type], 
				max(case when (sdh.physical_financial_flag = ''p'') then ''Phy'' else ''Fin'' end) [Phy/Fin],
				dbo.FNADateFormat(sdp.term_start) Expiration, ' +
				CASE WHEN @settlement_only='n' THEN   ' sum(isnull(sdp.und_pnl, 0)) CumulativeFV ' ELSE ' sum(isnull(sdp.und_pnl_set, 0)) CumulativeFV ' end +
				--THE FOLLOWING ARE 3 NEW CLMS
				',sdp.term_start, sdh.source_deal_header_id, max(sdp.pnl_as_of_date) pnl_as_of_date,max('+CASE WHEN @settlement_only='n' THEN 'sdpd.' ELSE 'sdp.' END+'deal_volume) deal_volume,max(su.uom_name) uom_name,max(scu.currency_name) currency_name,
				sum(isnull(sdp.und_pnl, 0)*isNull(df.discount_factor,1)) dis_pnl,
				MAX(ISNULL(spcd.block_type,sdh.block_type))block_type,
				MAX(ISNULL(spcd.block_define_id,sdh.block_define_id))block_definition_id,
				max(sdp.term_end) term_end,
				MAX(sdd.deal_volume_frequency)deal_volume_frequency
	from		source_deal_header sdh 
				inner join 	source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id and sdd.leg=1
			INNER JOIN '
		+	dbo.FNAGetProcessTableName(@previous_as_of_date, CASE WHEN @settlement_only='n' THEN 'source_deal_pnl' ELSE 'source_deal_pnl_settlement' END) + ' 
						sdp on sdh.source_deal_header_id=sdp.source_deal_header_id  AND sdp.term_start=sdd.term_start '
		+CASE WHEN @settlement_only='n' THEN ' INNER JOIN source_deal_pnl_detail sdpd on sdpd.source_deal_header_id=sdp.source_deal_header_id  
				AND sdp.term_start=sdpd.term_start and sdp.leg=sdpd.leg and sdp.pnl_as_of_date=sdpd.pnl_as_of_date
		' ELSE '' END+' INNER JOIN 
				source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id  
				inner join source_deal_type sdt on sdt.source_deal_type_id=sdh.deal_sub_type_type_id
				inner JOIN
				source_system_book_map ssbm ON sdh.source_system_book_id1 = ssbm.source_system_book_id1 AND 
												sdh.source_system_book_id2 = ssbm.source_system_book_id2 AND 
												sdh.source_system_book_id3 = ssbm.source_system_book_id3 AND 
												sdh.source_system_book_id4 = ssbm.source_system_book_id4 LEFT OUTER JOIN
				portfolio_hierarchy book on book.entity_id = ssbm.fas_book_id inner JOIN
				portfolio_hierarchy stra on stra.entity_id = book.parent_entity_id inner JOIN
				portfolio_hierarchy sub on sub.entity_id = stra.parent_entity_id inner JOIN
				fas_strategy fs on fs.fas_strategy_id = stra.entity_id  
				inner join #books b on b.fas_book_id=ssbm.fas_book_id
				left join source_uom su on su.source_uom_id=sdd.deal_volume_uom_id
				left join source_currency scu on source_currency_id=sdp.pnl_currency_id
				left outer join ' + @DiscountTableName0 + ' 	df on df.term_start = sdp.term_start and
						df.fas_subsidiary_id = sub.entity_id
				LEFT OUTER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=sdd.curve_id
				' + CASE WHEN @deal_list_table IS NOT NULL THEN ' INNER JOIN #source_deal_header_id t ON sdh.source_deal_header_id = t.source_deal_header_id ' ELSE '' END + '
				Where 1=1 '
			+CASE WHEN @previous_as_of_date IS NULL THEN ''
			ELSE + ' AND sdp.pnl_as_of_date=''' + cast(@previous_as_of_date as varchar) + '''' END
				+CASE WHEN  @settlement_only='y' THEN ' AND ISNULL(sdd.settlement_date,sdd.contract_expiration_date)<='''+@previous_as_of_date+'''' ELSE '' END
				+CASE WHEN  @settlement_only='y' AND @settlement_date_from IS NOT NULL THEN ' AND ISNULL(sdd.settlement_date,sdd.contract_expiration_date)>='''+@settlement_date_from+'''' ELSE '' END
				+CASE WHEN  @settlement_only='y' AND @settlement_date_to IS NOT NULL THEN ' AND ISNULL(sdd.settlement_date,sdd.contract_expiration_date)<='''+@settlement_date_to+'''' ELSE '' END


	-- Added to filter surve source
	+' And ISNULL(NULLIF(sdp.pnl_source_value_id,775),4500)=	'+CAST(@curve_source_id AS VARCHAR)+
	case when (@deal_id_from is not null and @match_id = 'n') then ' AND sdh.source_deal_header_id IN (' + cast(@deal_id_from as varchar)+')' else '' end +
	case when (@deal_id_from is not null and @match_id = 'y') then ' AND cast(sdh.source_deal_header_id as varchar) LIKE cast(' + cast(@deal_id_from as varchar) + ' as varchar) + ''%''' else '' end +
	case when (@deal_id is not null and @match_id = 'n') then ' AND sdh.deal_id IN (''' + @deal_id + ''')' else  '' end +
	--case when (@deal_filter_id is not null and @match_id = 'n') then ' AND sdh.deal_id IN (''' + @deal_filter_id + ''')' else  '' end +
	case when (@deal_id is not null and @match_id = 'y') then ' AND sdh.deal_id LIKE ''' + @deal_id + '%''' else  '' end +
	--case when (@deal_filter_id is not null and @match_id = 'y') then ' AND sdh.deal_id LIKE ''' + @deal_filter_id + '%''' else  '' end
	+ @Sql1 +
	'	group  by sdh.source_deal_header_id, sdh.deal_id, sdp.term_start	--order by sdh.source_deal_header_id, sdh.deal_id, sdp.term_start	' 

--print(@Sql2)
exec(@Sql2)
/*
DECLARE @vol_frequency_table_pre VARCHAR(128)
SET @vol_frequency_table_pre=dbo.FNAProcessTableName('deal_volume_frequency_mult_pre', dbo.FNADBUser(), @process_id)

set @Sql='SELECT DISTINCT 
					tp.term_start, 
					tp.term_end,
					tp.deal_volume_frequency AS deal_volume_frequency,
					tp.block_type,
					tp.block_definition_id as block_definition_id,
					MAX(sdd.deal_volume) deal_volume
			INTO '+@vol_frequency_table_pre+'
			FROM
				#deal_pnl0 tp
				LEFT JOIN source_deal_detail sdd ON sdd.source_deal_header_id=tp.source_deal_header_id
					AND sdd.term_start=tp.term_start
			WHERE 
				sdd.deal_volume_frequency IN(''d'',''h'')
			GROUP BY tp.term_start,tp.term_end,tp.block_type,tp.block_definition_id,tp.deal_volume_frequency'
						exec spa_print @Sql

EXEC(@Sql)


SET @as_of_date_mult=@previous_as_of_date
SET @as_of_date_mult_to=@previous_as_of_date


IF @settlement_option NOT IN('f','s','c')
	SET @as_of_date_mult='1900-01-01'
IF @settlement_option<>'s'
	SET @as_of_date_mult_to='9999-01-01'
		
EXEC spa_get_dealvolume_mult_byfrequency @vol_frequency_table_pre,@as_of_date_mult,@as_of_date_mult_to,'y',@settlement_option


*/


--*/
--END
--
--if  @summary_option='s'  --=  Summary
--
--if  @summary_option='t'  --Summary By Term
--
--if  @summary_option='d'  -- Detail
--
--if  @summary_option='m'  --  Detail By Term

select @Sql ='select '+
case @summary_option 
	when 's' then
		case @grouping
			when 'a' then 	'coalesce(cur.[Sub],prev.[Sub])[Sub],coalesce(cur.[Strategy],prev.[Strategy])[Strategy],coalesce(cur.[Book],prev.[Book])[Book]'
			when 'b' then 	'coalesce(cur.[Sub],prev.[Sub])[Sub],coalesce(cur.[Strategy],prev.[Strategy])[Strategy],coalesce(cur.[Book],prev.[Book])[Book],coalesce(cur.[Counterparty],prev.[Counterparty])[Counterparty]'
			when 'c' then 	'coalesce(cur.Counterparty,prev.Counterparty)[Counterparty]'
			when 'd' then 	'coalesce(cur.[Book],prev.[Book])[Book]'
			when 'e' then 	'coalesce(cur.[Sub],prev.[Sub])[Sub]'
			when 'f' then 	'coalesce(cur.[Strategy],prev.[Strategy])[Strategy]'
		end
	when 't' then
		case @grouping
			when 'a' then 	'coalesce(cur.[Sub],prev.[Sub])[Sub],coalesce(cur.[Strategy],prev.[Strategy])[Strategy],coalesce(cur.[Book],prev.[Book])[Book],coalesce(dbo.fnadateformat(cur.term_start),dbo.fnadateformat(prev.term_start)) [Term]'
			when 'b' then 	'coalesce(cur.[Sub],prev.[Sub])[Sub],coalesce(cur.[Strategy],prev.[Strategy])[Strategy],coalesce(cur.[Book],prev.[Book])[Book],coalesce(cur.[Counterparty],prev.[Counterparty])[Counterparty],coalesce(dbo.fnadateformat(cur.term_start),dbo.fnadateformat(prev.term_start)) [Term]'
			when 'c' then 	'coalesce(cur.Counterparty,prev.Counterparty)[Counterparty],coalesce(dbo.fnadateformat(cur.term_start),dbo.fnadateformat(prev.term_start)) [Term]'
			when 'd' then 	'coalesce(cur.[Book],prev.[Book])[Book],coalesce(dbo.fnadateformat(cur.term_start),dbo.fnadateformat(prev.term_start)) [Term]'
			when 'e' then 	'coalesce(cur.[Sub],prev.[Sub])[Sub],coalesce(dbo.fnadateformat(cur.term_start),dbo.fnadateformat(prev.term_start)) [Term]'
			when 'f' then 	'coalesce(cur.[Strategy],prev.[Strategy])[Strategy],coalesce(dbo.fnadateformat(cur.term_start),dbo.fnadateformat(prev.term_start)) [Term]'
		end
	when 'd' then
		case @grouping
			when 'a' then 	'coalesce(cur.[Sub],prev.[Sub])[Sub],coalesce(cur.[Strategy],prev.[Strategy])[Strategy],coalesce(cur.[Book],prev.[Book])[Book],coalesce(cur.[DealNumber],prev.[DealNumber])[DealNumber],coalesce(dbo.fnadateformat(cur.[DealDate]),dbo.fnadateformat(prev.[DealDate])) DealDate'
			when 'b' then 	'coalesce(cur.[Sub],prev.[Sub])[Sub],coalesce(cur.[Strategy],prev.[Strategy])[Strategy],coalesce(cur.[Book],prev.[Book])[Book],coalesce(cur.[Counterparty],prev.[Counterparty]) [Counterparty],coalesce(cur.[DealNumber],prev.[DealNumber]) [DealNumber],coalesce(dbo.fnadateformat(cur.[DealDate]),dbo.fnadateformat(prev.[DealDate])) DealDate'
			when 'c' then 	'coalesce(cur.Counterparty,prev.Counterparty)Counterparty,coalesce(cur.[DealNumber],prev.[DealNumber]) [DealNumber],coalesce(dbo.fnadateformat(cur.[DealDate]),dbo.fnadateformat(prev.[DealDate])) DealDate'
			when 'd' then 	'coalesce(cur.[Book],prev.[Book])[Book],coalesce(cur.[DealNumber],prev.[DealNumber]) [DealNumber],coalesce(dbo.fnadateformat(cur.[DealDate]),dbo.fnadateformat(prev.[DealDate])) DealDate'
			when 'e' then 	'coalesce(cur.[Sub],prev.[Sub])[Sub],coalesce(cur.[DealNumber],prev.[DealNumber]) [DealNumber],coalesce(dbo.fnadateformat(cur.[DealDate]),dbo.fnadateformat(prev.[DealDate])) DealDate'
			when 'f' then 	'coalesce(cur.[Strategy],prev.[Strategy])[Strategy],coalesce(cur.[DealNumber],prev.[DealNumber])[DealNumber],coalesce(dbo.fnadateformat(cur.[DealDate]),dbo.fnadateformat(prev.[DealDate])) DealDate'
		end
	when 'm' then
		case @grouping
			when 'a' then 	'coalesce(cur.[Sub],prev.[Sub])[Sub],coalesce(cur.[Strategy],prev.[Strategy])[Strategy],coalesce(cur.[Book],prev.[Book])[Book],coalesce(cur.[DealNumber],prev.[DealNumber])[DealNumber],coalesce(dbo.fnadateformat(cur.[DealDate]),dbo.fnadateformat(prev.[DealDate])) DealDate,coalesce(dbo.fnadateformat(cur.term_start),dbo.fnadateformat(prev.term_start)) [Term]'
			when 'b' then 	'coalesce(cur.[Sub],prev.[Sub])[Sub],coalesce(cur.[Strategy],prev.[Strategy])[Strategy],coalesce(cur.[Book],prev.[Book])[Book],coalesce(cur.[Counterparty],prev.[Counterparty])[Counterparty],coalesce(cur.[DealNumber],prev.[DealNumber])[DealNumber],coalesce(dbo.fnadateformat(cur.[DealDate]),dbo.fnadateformat(prev.[DealDate])) DealDate,coalesce(dbo.fnadateformat(cur.term_start),dbo.fnadateformat(prev.term_start)) [Term]'
			when 'c' then 	'coalesce(cur.Counterparty,prev.Counterparty)Counterparty,coalesce(cur.[DealNumber],prev.[DealNumber])[DealNumber],coalesce(dbo.fnadateformat(cur.[DealDate]),dbo.fnadateformat(prev.[DealDate])) DealDate,coalesce(dbo.fnadateformat(cur.term_start),dbo.fnadateformat(prev.term_start)) [Term]'
			when 'd' then 	'coalesce(cur.[Book],prev.[Book])[Book],coalesce(cur.[DealNumber],prev.[DealNumber])[DealNumber],coalesce(dbo.fnadateformat(cur.[DealDate]),dbo.fnadateformat(prev.[DealDate])) DealDate,coalesce(dbo.fnadateformat(cur.term_start),dbo.fnadateformat(prev.term_start)) [Term]'
			when 'e' then 	'coalesce(cur.[Sub],prev.[Sub])[Sub],coalesce(cur.[DealNumber],prev.[DealNumber])[DealNumber],coalesce(dbo.fnadateformat(cur.[DealDate]),dbo.fnadateformat(prev.[DealDate])) DealDate,coalesce(dbo.fnadateformat(cur.term_start),dbo.fnadateformat(prev.term_start)) [Term]'
			when 'f' then 	'coalesce(cur.[Strategy],prev.[Strategy])[Strategy],coalesce(cur.[DealNumber],prev.[DealNumber])[DealNumber],coalesce(dbo.fnadateformat(cur.[DealDate]),dbo.fnadateformat(prev.[DealDate])) DealDate,coalesce(dbo.fnadateformat(cur.term_start),dbo.fnadateformat(prev.term_start)) [Term]'
		end
END


--+', 
--round(sum(isnull(cur.deal_volume,0)*CASE WHEN cur.[Phy/Fin]=''Fin'' THEN 1 ELSE abs((sdd_cur.total_volume*isnull(sdd_cur.multiplier, 1)*isnull(sdd_cur.volume_multiplier2, 1)*ISNULL(NULLIF(vft_cur.Volume_MULT,0),1))/ISNULL(NULLIF(cur.deal_volume,0),1)) END),'+@round_value+') [Current Volume],
--round(sum(isnull(prev.deal_volume,0)*CASE WHEN prev.[Phy/Fin]=''Fin'' THEN 1 ELSE abs((sdd_pre.total_volume*isnull(sdd_pre.multiplier, 1)*isnull(sdd_pre.volume_multiplier2, 1)*ISNULL(NULLIF(vft_pre.Volume_MULT,0),1))/ISNULL(NULLIF(prev.deal_volume,0),1)) END),'+@round_value+') [Last Volume],
--ISNULL(round(sum(isnull(cur.deal_volume,0)*CASE WHEN cur.[Phy/Fin]=''Fin'' THEN 1 ELSE abs((sdd_cur.total_volume*isnull(sdd_cur.multiplier, 1)*isnull(sdd_cur.volume_multiplier2, 1)*ISNULL(NULLIF(vft_cur.Volume_MULT,0),1))/ISNULL(NULLIF(cur.deal_volume,0),1)) END),'+@round_value+'),0)-
--	ISNULL(round(sum(isnull(prev.deal_volume,0)*CASE WHEN prev.[Phy/Fin]=''Fin'' THEN 1 ELSE abs((sdd_pre.total_volume*isnull(sdd_pre.multiplier, 1)*isnull(sdd_pre.volume_multiplier2, 1)*ISNULL(NULLIF(vft_pre.Volume_MULT,0),1))/ISNULL(NULLIF(prev.deal_volume,0),1)) END),'+@round_value+'),0) [Change Volume], 
--coalesce(max(cur.uom),max(prev.uom)) [UOM],
--round(sum(ISNULL(cur.dis_pnl, 0)*CASE WHEN cur.[Phy/Fin]=''Fin'' THEN 1 ELSE abs((sdd_cur.total_volume*isnull(sdd_cur.multiplier, 1)*isnull(sdd_cur.volume_multiplier2, 1)*ISNULL(NULLIF(vft_cur.Volume_MULT,0),1))/ISNULL(NULLIF(cur.deal_volume,0),1)) END),'+@round_value+') [Current Disc MTM],
--round(sum(ISNULL(prev.dis_pnl, 0)*CASE WHEN prev.[Phy/Fin]=''Fin'' THEN 1 ELSE abs((sdd_pre.total_volume*isnull(sdd_pre.multiplier, 1)*isnull(sdd_pre.volume_multiplier2, 1)*ISNULL(NULLIF(vft_pre.Volume_MULT,0),1))/ISNULL(NULLIF(prev.deal_volume,0),1)) END),'+@round_value+') [Last Disc MTM],
--round(isnull(sum(ISNULL(cur.dis_pnl, 0)*CASE WHEN cur.[Phy/Fin]=''Fin'' THEN 1 ELSE abs((sdd_cur.total_volume*isnull(sdd_cur.multiplier, 1)*isnull(sdd_cur.volume_multiplier2, 1)*ISNULL(NULLIF(vft_cur.Volume_MULT,0),1))/ISNULL(NULLIF(cur.deal_volume,0),1)) END),0)
---isnull(sum(ISNULL(prev.dis_pnl, 0)*CASE WHEN prev.[Phy/Fin]=''Fin'' THEN 1 ELSE abs((sdd_pre.total_volume*isnull(sdd_pre.multiplier, 1)*isnull(sdd_pre.volume_multiplier2, 1)*ISNULL(NULLIF(vft_pre.Volume_MULT,0),1))/ISNULL(NULLIF(prev.deal_volume,0),1)) END),0),'+@round_value+') [Change Disc MTM],
--round(sum(ISNULL(cur.[CumulativeFV], 0)*CASE WHEN cur.[Phy/Fin]=''Fin'' THEN 1 ELSE abs((sdd_cur.total_volume*isnull(sdd_cur.multiplier, 1)*isnull(sdd_cur.volume_multiplier2, 1)*ISNULL(NULLIF(vft_cur.Volume_MULT,0),1))/ISNULL(NULLIF(cur.deal_volume,0),1)) END),'+@round_value+') [Current UnDisc MTM],
--round(sum(ISNULL(prev.[CumulativeFV], 0)*CASE WHEN prev.[Phy/Fin]=''Fin'' THEN 1 ELSE abs((sdd_pre.total_volume*isnull(sdd_pre.multiplier, 1)*isnull(sdd_pre.volume_multiplier2, 1)*ISNULL(NULLIF(vft_pre.Volume_MULT,0),1))/ISNULL(NULLIF(prev.deal_volume,0),1)) END),'+@round_value+') [Last UnDisc MTM],
--round(isnull(sum(ISNULL(cur.[CumulativeFV], 0)*CASE WHEN cur.[Phy/Fin]=''Fin'' THEN 1 ELSE abs((sdd_cur.total_volume*isnull(sdd_cur.multiplier, 1)*isnull(sdd_cur.volume_multiplier2, 1)*ISNULL(NULLIF(vft_cur.Volume_MULT,0),1))/ISNULL(NULLIF(cur.deal_volume,0),1)) END),0)
---isnull(sum(ISNULL(prev.[CumulativeFV], 0)*CASE WHEN prev.[Phy/Fin]=''Fin'' THEN 1 ELSE abs((sdd_pre.total_volume*isnull(sdd_pre.multiplier, 1)*isnull(sdd_pre.volume_multiplier2, 1)*ISNULL(NULLIF(vft_pre.Volume_MULT,0),1))/ISNULL(NULLIF(prev.deal_volume,0),1)) END),0),'+@round_value+') [Change UnDisc MTM]
--'
--+ ' ' + @str_batch_table + '  



+', 
round(sum(isnull(cur.deal_volume,0)),'+@round_value+') [Current Volume],
round(sum(isnull(prev.deal_volume,0)),'+@round_value+') [Last Volume],
ISNULL(round(sum(isnull(cur.deal_volume,0)),'+@round_value+'),0)-ISNULL(round(sum(isnull(prev.deal_volume,0)),'+@round_value+'),0) [Change Volume], 
coalesce(max(cur.uom),max(prev.uom)) [UOM],
round(sum(ISNULL(cur.dis_pnl, 0)),'+@round_value+') [Current Disc MTM],
round(sum(ISNULL(prev.dis_pnl, 0)),'+@round_value+') [Last Disc MTM],
round(isnull(sum(ISNULL(cur.dis_pnl, 0)),0)
-isnull(sum(ISNULL(prev.dis_pnl, 0)),0),'+@round_value+') [Change Disc MTM],
round(sum(ISNULL(cur.[CumulativeFV], 0)),'+@round_value+') [Current UnDisc MTM],
round(sum(ISNULL(prev.[CumulativeFV], 0)),'+@round_value+') [Last UnDisc MTM],
round(isnull(sum(ISNULL(cur.[CumulativeFV], 0)),0)
-isnull(sum(ISNULL(prev.[CumulativeFV], 0)),0),'+@round_value+') [Change UnDisc MTM]
'
+ ' ' + @str_batch_table + '  
	FROM 
	#deal_pnl1  cur
	LEFT JOIN source_deal_detail sdd_cur ON sdd_cur.source_deal_header_id=cur.source_deal_header_id
			  AND sdd_cur.term_start=cur.term_start AND sdd_cur.leg=1		
	 FULL OUTER JOIN 
	 #deal_pnl0 prev on cur.source_deal_header_id = prev.source_deal_header_id AND	
		cur.term_start = prev.term_start 
	LEFT JOIN source_deal_detail sdd_pre ON sdd_pre.source_deal_header_id=prev.source_deal_header_id
			  AND sdd_pre.term_start=prev.term_start AND sdd_pre.leg=1		
group by ' +
case  @summary_option
	when 's' then
		case @grouping
			when 'a' then 	'coalesce(cur.[Sub],prev.[Sub]),coalesce(cur.[Strategy],prev.[Strategy]),coalesce(cur.[Book],prev.[Book])'
			when 'b' then 	'coalesce(cur.[Sub],prev.[Sub]),coalesce(cur.[Strategy],prev.[Strategy]),coalesce(cur.[Book],prev.[Book]),coalesce(cur.[Counterparty],prev.[Counterparty])'
			when 'c' then 	'coalesce(cur.Counterparty,prev.Counterparty)'
			when 'd' then 	'coalesce(cur.[Book],prev.[Book])'
			when 'e' then 	'coalesce(cur.[Sub],prev.[Sub])'
			when 'f' then 	'coalesce(cur.[Strategy],prev.[Strategy])'
		end
	when 't' then
		case @grouping
			when 'a' then 	'coalesce(cur.[Sub],prev.[Sub]),coalesce(cur.[Strategy],prev.[Strategy]),coalesce(cur.[Book],prev.[Book]),coalesce(dbo.fnadateformat(cur.term_start),dbo.fnadateformat(prev.term_start))'
			when 'b' then 	'coalesce(cur.[Sub],prev.[Sub]),coalesce(cur.[Strategy],prev.[Strategy]),coalesce(cur.[Book],prev.[Book]),coalesce(cur.[Counterparty],prev.[Counterparty]),coalesce(dbo.fnadateformat(cur.term_start),dbo.fnadateformat(prev.term_start))'
			when 'c' then 	'coalesce(cur.[Counterparty],prev.[Counterparty]),coalesce(dbo.fnadateformat(cur.term_start),dbo.fnadateformat(prev.term_start))'
			when 'd' then 	'coalesce(cur.[Book],prev.[Book]),coalesce(dbo.fnadateformat(cur.term_start),dbo.fnadateformat(prev.term_start))'
			when 'e' then 	'coalesce(cur.[Sub],prev.[Sub]),coalesce(dbo.fnadateformat(cur.term_start),dbo.fnadateformat(prev.term_start))'
			when 'f' then 	'coalesce(cur.[Strategy],prev.[Strategy]),coalesce(dbo.fnadateformat(cur.term_start),dbo.fnadateformat(prev.term_start))'
		end
	when 'd' then
		case @grouping
			when 'a' then 	'coalesce(cur.[Sub],prev.[Sub]),coalesce(cur.[Strategy],prev.[Strategy]),coalesce(cur.[Book],prev.[Book]),coalesce(cur.[DealNumber],prev.[DealNumber]),coalesce(dbo.fnadateformat(cur.[DealDate]),dbo.fnadateformat(prev.[DealDate]))'
			when 'b' then 	'coalesce(cur.[Sub],prev.[Sub]),coalesce(cur.[Strategy],prev.[Strategy]),coalesce(cur.[Book],prev.[Book]),coalesce(cur.[Counterparty],prev.[Counterparty]),coalesce(cur.[DealNumber],prev.[DealNumber]),coalesce(dbo.fnadateformat(cur.[DealDate]),dbo.fnadateformat(prev.[DealDate]))'
			when 'c' then 	'coalesce(cur.Counterparty,prev.Counterparty),coalesce(cur.[DealNumber],prev.[DealNumber]),coalesce(dbo.fnadateformat(cur.[DealDate]),dbo.fnadateformat(prev.[DealDate]))'
			when 'd' then 	'coalesce(cur.[Book],prev.[Book]),coalesce(cur.[DealNumber],prev.[DealNumber]),coalesce(dbo.fnadateformat(cur.[DealDate]),dbo.fnadateformat(prev.[DealDate]))'
			when 'e' then 	'coalesce(cur.[Sub],prev.[Sub]),coalesce(cur.[DealNumber],prev.[DealNumber]),coalesce(dbo.fnadateformat(cur.[DealDate]),dbo.fnadateformat(prev.[DealDate]))'
			when 'f' then 	'coalesce(cur.[Strategy],prev.[Strategy]),coalesce(cur.[DealNumber],prev.[DealNumber]),coalesce(dbo.fnadateformat(cur.[DealDate]),dbo.fnadateformat(prev.[DealDate]))'
		end
	when 'm' then
		case @grouping
			when 'a' then 	'coalesce(cur.[Sub],prev.[Sub]),coalesce(cur.[Strategy],prev.[Strategy]),coalesce(cur.[Book],prev.[Book]),coalesce(cur.[DealNumber],prev.[DealNumber]),coalesce(dbo.fnadateformat(cur.[DealDate]),dbo.fnadateformat(prev.[DealDate])),coalesce(dbo.fnadateformat(cur.term_start),dbo.fnadateformat(prev.term_start))'
			when 'b' then 	'coalesce(cur.[Sub],prev.[Sub]),coalesce(cur.[Strategy],prev.[Strategy]),coalesce(cur.[Book],prev.[Book]),coalesce(cur.[Counterparty],prev.[Counterparty]),coalesce(cur.[DealNumber],prev.[DealNumber]),coalesce(dbo.fnadateformat(cur.[DealDate]),dbo.fnadateformat(prev.[DealDate])),coalesce(dbo.fnadateformat(cur.term_start),dbo.fnadateformat(prev.term_start))'
			when 'c' then 	'coalesce(cur.Counterparty,prev.Counterparty),coalesce(cur.[DealNumber],prev.[DealNumber]),coalesce(dbo.fnadateformat(cur.[DealDate]),dbo.fnadateformat(prev.[DealDate])),coalesce(dbo.fnadateformat(cur.term_start),dbo.fnadateformat(prev.term_start))'
			when 'd' then 	'coalesce(cur.[Book],prev.[Book]),coalesce(cur.[DealNumber],prev.[DealNumber]),coalesce(dbo.fnadateformat(cur.[DealDate]),dbo.fnadateformat(prev.[DealDate])),coalesce(dbo.fnadateformat(cur.term_start),dbo.fnadateformat(prev.term_start))'
			when 'e' then 	'coalesce(cur.[Sub],prev.[Sub]),coalesce(cur.[DealNumber],prev.[DealNumber]),coalesce(dbo.fnadateformat(cur.[DealDate]),dbo.fnadateformat(prev.[DealDate])),coalesce(dbo.fnadateformat(cur.term_start),dbo.fnadateformat(prev.term_start))'
			when 'f' then 	'coalesce(cur.[Strategy],prev.[Strategy]),coalesce(cur.[DealNumber],prev.[DealNumber]),coalesce(dbo.fnadateformat(cur.[DealDate]),dbo.fnadateformat(prev.[DealDate])),coalesce(dbo.fnadateformat(cur.term_start),dbo.fnadateformat(prev.term_start))'
		end
end
+
' order by ' +
case  @summary_option
	when 's' then
		case @grouping
			when 'a' then 	'coalesce(cur.[Sub],prev.[Sub]),coalesce(cur.[Strategy],prev.[Strategy]),coalesce(cur.[Book],prev.[Book])'
			when 'b' then 	'coalesce(cur.[Sub],prev.[Sub]),coalesce(cur.[Strategy],prev.[Strategy]),coalesce(cur.[Book],prev.[Book]),coalesce(cur.[Counterparty],prev.[Counterparty])'
			when 'c' then 	'coalesce(cur.Counterparty,prev.Counterparty)'
			when 'd' then 	'coalesce(cur.[Book],prev.[Book])'
			when 'e' then 	'coalesce(cur.[Sub],prev.[Sub])'
			when 'f' then 	'coalesce(cur.[Strategy],prev.[Strategy])'
		end
	when 't' then
		case @grouping
			when 'a' then 	'coalesce(cur.[Sub],prev.[Sub]),coalesce(cur.[Strategy],prev.[Strategy]),coalesce(cur.[Book],prev.[Book]),coalesce(dbo.fnadateformat(cur.term_start),dbo.fnadateformat(prev.term_start))'
			when 'b' then 	'coalesce(cur.[Sub],prev.[Sub]),coalesce(cur.[Strategy],prev.[Strategy]),coalesce(cur.[Book],prev.[Book]),coalesce(cur.[Counterparty],prev.[Counterparty]),coalesce(dbo.fnadateformat(cur.term_start),dbo.fnadateformat(prev.term_start))'
			when 'c' then 	'coalesce(cur.[Counterparty],prev.[Counterparty]),coalesce(dbo.fnadateformat(cur.term_start),dbo.fnadateformat(prev.term_start))'
			when 'd' then 	'coalesce(cur.[Book],prev.[Book]),coalesce(dbo.fnadateformat(cur.term_start),dbo.fnadateformat(prev.term_start))'
			when 'e' then 	'coalesce(cur.[Sub],prev.[Sub]),coalesce(dbo.fnadateformat(cur.term_start),dbo.fnadateformat(prev.term_start))'
			when 'f' then 	'coalesce(cur.[Strategy],prev.[Strategy]),coalesce(dbo.fnadateformat(cur.term_start),dbo.fnadateformat(prev.term_start))'
		end
	when 'd' then
		case @grouping
			when 'a' then 	'coalesce(cur.[Sub],prev.[Sub]),coalesce(cur.[Strategy],prev.[Strategy]),coalesce(cur.[Book],prev.[Book]),coalesce(cur.[DealNumber],prev.[DealNumber]),coalesce(dbo.fnadateformat(cur.[DealDate]),dbo.fnadateformat(prev.[DealDate]))'
			when 'b' then 	'coalesce(cur.[Sub],prev.[Sub]),coalesce(cur.[Strategy],prev.[Strategy]),coalesce(cur.[Book],prev.[Book]),coalesce(cur.[Counterparty],prev.[Counterparty]),coalesce(cur.[DealNumber],prev.[DealNumber]),coalesce(dbo.fnadateformat(cur.[DealDate]),dbo.fnadateformat(prev.[DealDate]))'
			when 'c' then 	'coalesce(cur.Counterparty,prev.Counterparty),coalesce(cur.[DealNumber],prev.[DealNumber]),coalesce(dbo.fnadateformat(cur.[DealDate]),dbo.fnadateformat(prev.[DealDate]))'
			when 'd' then 	'coalesce(cur.[Book],prev.[Book]),coalesce(cur.[DealNumber],prev.[DealNumber]),coalesce(dbo.fnadateformat(cur.[DealDate]),dbo.fnadateformat(prev.[DealDate]))'
			when 'e' then 	'coalesce(cur.[Sub],prev.[Sub]),coalesce(cur.[DealNumber],prev.[DealNumber]),coalesce(dbo.fnadateformat(cur.[DealDate]),dbo.fnadateformat(prev.[DealDate]))'
			when 'f' then 	'coalesce(cur.[Strategy],prev.[Strategy]),coalesce(cur.[DealNumber],prev.[DealNumber]),coalesce(dbo.fnadateformat(cur.[DealDate]),dbo.fnadateformat(prev.[DealDate]))'
		end
	when 'm' then
		case @grouping
			when 'a' then 	'coalesce(cur.[Sub],prev.[Sub]),coalesce(cur.[Strategy],prev.[Strategy]),coalesce(cur.[Book],prev.[Book]),coalesce(cur.[DealNumber],prev.[DealNumber]),coalesce(dbo.fnadateformat(cur.[DealDate]),dbo.fnadateformat(prev.[DealDate])),coalesce(dbo.fnadateformat(cur.term_start),dbo.fnadateformat(prev.term_start))'
			when 'b' then 	'coalesce(cur.[Sub],prev.[Sub]),coalesce(cur.[Strategy],prev.[Strategy]),coalesce(cur.[Book],prev.[Book]),coalesce(cur.[Counterparty],prev.[Counterparty]),coalesce(cur.[DealNumber],prev.[DealNumber]),coalesce(dbo.fnadateformat(cur.[DealDate]),dbo.fnadateformat(prev.[DealDate])),coalesce(dbo.fnadateformat(cur.term_start),dbo.fnadateformat(prev.term_start))'
			when 'c' then 	'coalesce(cur.Counterparty,prev.Counterparty),coalesce(cur.[DealNumber],prev.[DealNumber]),coalesce(dbo.fnadateformat(cur.[DealDate]),dbo.fnadateformat(prev.[DealDate])),coalesce(dbo.fnadateformat(cur.term_start),dbo.fnadateformat(prev.term_start))'
			when 'd' then 	'coalesce(cur.[Book],prev.[Book]),coalesce(cur.[DealNumber],prev.[DealNumber]),coalesce(dbo.fnadateformat(cur.[DealDate]),dbo.fnadateformat(prev.[DealDate])),coalesce(dbo.fnadateformat(cur.term_start),dbo.fnadateformat(prev.term_start))'
			when 'e' then 	'coalesce(cur.[Sub],prev.[Sub]),coalesce(cur.[DealNumber],prev.[DealNumber]),coalesce(dbo.fnadateformat(cur.[DealDate]),dbo.fnadateformat(prev.[DealDate])),coalesce(dbo.fnadateformat(cur.term_start),dbo.fnadateformat(prev.term_start))'
			when 'f' then 	'coalesce(cur.[Strategy],prev.[Strategy]),coalesce(cur.[DealNumber],prev.[DealNumber]),coalesce(dbo.fnadateformat(cur.[DealDate]),dbo.fnadateformat(prev.[DealDate])),coalesce(dbo.fnadateformat(cur.term_start),dbo.fnadateformat(prev.term_start))'
		end
end

--print (@Sql)
exec(@Sql)




if @is_batch = 1
begin
	exec spa_print '@str_batch_table'  
	 SELECT @str_batch_table=dbo.FNABatchProcess('u',@batch_process_id,@batch_report_param,GETDATE(),NULL,NULL)   
		   exec spa_print @str_batch_table
	 EXEC(@str_batch_table)                   
	        
	 SELECT @str_batch_table=dbo.FNABatchProcess('c',@batch_process_id,@batch_report_param,GETDATE(),'spa_Counterparty_MTM_Report','Run Counterparty MTM Report')         
	 EXEC spa_print @str_batch_table
	 EXEC(@str_batch_table)        
	EXEC spa_print 'finsh Run Counterparty MTM Report'
	return
END

IF @enable_paging = 1
BEGIN
		IF @page_size IS NULL
		BEGIN
			set @sql_stmt='select count(*) TotalRow,'''+@batch_process_id +''' process_id  from '+ @temptablename
		--	EXEC spa_print @sql_stmt
			exec(@sql_stmt)
		end
END 

GO
