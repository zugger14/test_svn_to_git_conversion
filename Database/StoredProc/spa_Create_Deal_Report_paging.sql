IF OBJECT_ID(N'spa_Create_Deal_Report_paging', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_Create_Deal_Report_paging]
 GO 

create PROCEDURE [dbo].[spa_Create_Deal_Report_paging]
		@book_deal_type_map_id varchar(200), 
		@deal_id_from int = NULL, 
		@deal_id_to int = NULL, 
		@deal_date_from varchar(10) = NULL, 
		@deal_date_to varchar(10) = NULL,
		@use_by_linking char(1) = 'n',
		@deal_id varchar(50) = NULL,
		@tenor_from				VARCHAR(50) = NULL	,
		@tenor_to				VARCHAR(50) = NULL	,
		@match					CHAR(1)		= 'n'	,
		@counterparty			VARCHAR(10) = NULL	,
		@index_group			VARCHAR(10) = NULL	,
		@index					VARCHAR(10) = NULL	,
		@commodity				VARCHAR(10) = NULL	,
		@contract				VARCHAR(10) = NULL	,
		@txtDescp1				VARCHAR(500)= NULL	,
		@txtDescp2				VARCHAR(500)= NULL	,
		@optBuySell				CHAR(1)		= 'a'   ,
		@hedge_item_flag		CHAR(1)		= NULL  ,
		@sub_id					VARCHAR(900)=NULL,
		@starategy_id			VARCHAR(900)=NULL,
		@book_id				VARCHAR(900)=NULL,
		@process_id varchar(200)=NULL, 
		@page_size int =NULL,
		@page_no int=NULL 
AS

SET NOCOUNT ON

declare @user_login_id varchar(50),@tempTable varchar(300) ,@flag char(1)

	set @user_login_id=dbo.FNADBUser()

	if @process_id is NULL
	Begin
		set @flag='i'
		set @process_id=REPLACE(newid(),'-','_')
	End
	set @tempTable=dbo.FNAProcessTableName('paging_temp_Create_Deal_Report', @user_login_id,@process_id)
	declare @sqlStmt varchar(5000)

if @flag='i'
begin
	if @use_by_linking='y'
	begin
		set @sqlStmt='create table '+ @tempTable+'( 
		sno int  identity(1,1),
		PercLinked varchar(200),
		DealId varchar(200),
		[SourceDealID] varchar(200),
		DealDate varchar(200),
		[EffectiveDate] varchar(200),
		physical_financial_flag varchar(200),
		CptyName varchar(200),
		TermStart varchar(200),
		TermEnd varchar(200),
		DealType varchar(200),
		DealSubType varchar(200),
		OptionFlag varchar(200),
		OptionType varchar(200),
		ExcersiceType varchar(200),
		Group1 varchar(200),
		Group2 varchar(200),
		Group3 varchar(200),
		Group4 varchar(200),
		desc1 varchar(200),
		desc2 varchar(200)
		)'
	end
	else
	begin
		set @sqlStmt='create table '+ @tempTable+'( 
		sno int  identity(1,1),
		PercLinked varchar(500),
		DealId varchar(500),
		[SourceDealID] varchar(500),
		DealDate varchar(500),
		[EffectiveDate] varchar(500),
		sourcedealtype varchar(500),
		subdealtype varchar(500),
		Group1 varchar(500),
		Group2 varchar(500),
		Group3 varchar(500),
		Group4 varchar(500),
		TermStart varchar(500),
		TermEnd varchar(500),
		Leg varchar(500),
		FixedFloat varchar(500),
		CurveName varchar(500),
		Price varchar(500),
		Strike varchar(500),
		Currency varchar(500),
		BuySell varchar(500),
		DealVolume varchar(500),
		DealUOM varchar(500),
		VolumeFrequency varchar(500)
		)'
	end
	exec(@sqlStmt)
	
	set @sqlStmt=' insert  '+@tempTable+'
	exec  spa_Create_Deal_Report '+ dbo.FNASingleQuote(@book_deal_type_map_id) +','+ 
	dbo.FNASingleQuote(@deal_id_from) +',' +
	dbo.FNASingleQuote(@deal_id_to) +',' +
	dbo.FNASingleQuote(@deal_date_from) +',' +
	dbo.FNASingleQuote(@deal_date_to) +',' +
	dbo.FNASingleQuote(@use_by_linking)+',' +
	dbo.FNASingleQuote(@deal_id)+',' +
	dbo.FNASingleQuote(@tenor_from)+',' +
	dbo.FNASingleQuote(@tenor_to)+',' +
	dbo.FNASingleQuote(@match)+',' +
	dbo.FNASingleQuote(@counterparty)+',' +
	dbo.FNASingleQuote(@index_group)+',' +
	dbo.FNASingleQuote(@index)+',' +
	dbo.FNASingleQuote(@commodity)+',' +
	dbo.FNASingleQuote(@contract)+',' +
	dbo.FNASingleQuote(@txtDescp1)+',' +
	dbo.FNASingleQuote(@optBuySell)+',' +
	dbo.FNASingleQuote(@hedge_item_flag)+',' +
	dbo.FNASingleQuote(@sub_id)+',' +
	dbo.FNASingleQuote(@starategy_id)+',' +
	dbo.FNASingleQuote(@book_id)

	
	--print @sqlStmt
	exec(@sqlStmt)	

	set @sqlStmt='select count(*) TotalRow,'''+@process_id +''' process_id  from '+ @tempTable
	--print @sqlStmt
	exec(@sqlStmt)
end
else
begin
declare @row_to int,@row_from int
set @row_to=@page_no * @page_size
if @page_no > 1 
set @row_from =((@page_no-1) * @page_size)+1
else
set @row_from =@page_no

--########### Group Label
declare @group1 varchar(100),@group2 varchar(100),@group3 varchar(100),@group4 varchar(100)
 if exists(select group1,group2,group3,group4 from source_book_mapping_clm)
begin	
	select @group1=group1,@group2=group2,@group3=group3,@group4=group4 from source_book_mapping_clm
end
else
begin
	set @group1='Group1'
	set @group2='Group2'
	set @group3='Group3'
	set @group4='Group4'
 
end
--######## End


if @use_by_linking='y'
	set @sqlStmt='select PercLinked as [Percentage Linked],DealId as [Deal ID] ,[SourceDealID] as [Source Deal ID],DealDate as [Deal Date],EffectiveDate as [Effective Date],physical_financial_flag,
			CptyName,TermStart as [Term Start],TermEnd as [Term End], DealSubType as [Deal Sub Type] ,OptionFlag as [Option Flag],OptionType as [Option Type],ExcersiceType as [Excersice Type],Group1 as ['+ @group1 +'],
			Group2 as ['+ @group2 +'],Group3 as ['+ @group3 +']
		   from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar)+ ' order by sno asc'
else
	set @sqlStmt='select PercLinked  as [Percentage Linked] ,DealId as [Deal ID], [SourceDealID] as [Source Deal ID] , DealDate as [Deal Date] , [EffectiveDate] as [Effective Date] , sourcedealtype as [Source Deal Type], subdealtype as [Sub Deal Type],
		Group1  as ['+ @group1 +'], Group2  as ['+ @group2 +'], Group3  as ['+ @group3 +'], Group4  as ['+ @group4 +'], TermStart as [Term Start] , TermEnd as  [Term End] ,Leg , FixedFloat as [Fixed Float] , CurveName as [ Curve Name], Price ,
		Strike , Currency , BuySell as [Buy/Sell] , DealVolume as [Deal Volume] , DealUOM as [Deal UOM],VolumeFrequency as [Volume Frequency]
		   from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar)+ ' order by sno asc'


		exec(@sqlStmt)

end








