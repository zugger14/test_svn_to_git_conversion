IF OBJECT_ID(N'spa_Create_Not_Mapped_Deal_Report_paging', N'P') IS NOT NULL
DROP PROCEDURE spa_Create_Not_Mapped_Deal_Report_paging
 GO 

create PROCEDURE [dbo].[spa_Create_Not_Mapped_Deal_Report_paging]
		@source_system_book_id1 int=NULL, 
		@source_system_book_id2 int=NULL, 
		@source_system_book_id3 int=NULL, 
		@source_system_book_id4 int=NULL, 
		@deal_date_from varchar(10) = NULL, 
		@deal_date_to varchar(10) = NULL,
		@type char(1) = 'n' ,-- n-> not mapped m-> mapped deals
		@source_system_id int=null,
		@summary_option char(1)='s',
		@counterparty_id VARCHAR(MAX)=null,
		@use_create_date char(1)='n',
		@deal_id varchar(50)=null, -- Source Deal Header ID
		@ref_id varchar(50)=null, -- DEAL ID
		@exlc_group4 char(1)=null, 
		@internal_desk_id int=null, ---NEW ADDED in ESSENT
		@product_id int=null,
		@internal_portfolio_id int=null,
		@commodity_id int=null,
		@reference varchar(200)=NUll, ---NEW ADDED in ESSENT
		@process_id varchar(200)=NULL, 
		@page_size int =NULL,
		@page_no int=NULL 
as
SET NOCOUNT ON 

declare @user_login_id varchar(50),@tempTable varchar(300) ,@flag char(1)

	set @user_login_id=dbo.FNADBUser()

	if @process_id is NULL
	Begin
		set @flag='i'
		set @process_id=REPLACE(newid(),'-','_')
	End
	set @tempTable=dbo.FNAProcessTableName('paging_temp_Not_Mapped_Create_Deal_Report', @user_login_id,@process_id)
	declare @sqlStmt varchar(5000)

if @flag='i'
begin
if @summary_option='s'
	set @sqlStmt='create table '+ @tempTable+'( 
		sno int  identity(1,1),
		DealId varchar(500),
		[SourceDealID] varchar(500),
		Group1 varchar(500),
		Group2 varchar(500),
		Group3 varchar(500),
		Group4 varchar(500),
		source_system varchar(100),
		PercLinked varchar(500),
		DealDate varchar(500),
		[EffectiveDate] varchar(500),
		sourcedealtype varchar(500),
		subdealtype varchar(500),
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
		VolumeFrequency varchar(500),
		internal_desk_id varchar(500),
		product_id varchar(500),
		internal_portfolio_id varchar(500),
		commodity_id varchar(500),
		reference varchar(500)
		)'
else
		set @sqlStmt='create table '+ @tempTable+'( 
		sno int  identity(1,1),
		source_system varchar(100),
		Group1 varchar(500),
		Group2 varchar(500),
		Group3 varchar(500),
		Group4 varchar(500),
		PercLinked varchar(500),
		DealId varchar(500),
		[SourceDealID] varchar(500),
		DealDate varchar(500),
		[EffectiveDate] varchar(500),
		sourcedealtype varchar(500),
		subdealtype varchar(500),
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
		VolumeFrequency varchar(500),
		internal_desk_id varchar(500),
		product_id varchar(500),
		internal_portfolio_id varchar(500),
		commodity_id varchar(500),
		reference varchar(500)
		)'
			
	exec(@sqlStmt)
	
	set @sqlStmt=' insert  '+@tempTable+'
	exec  spa_Create_Not_Mapped_Deal_Report '+ 
	dbo.FNASingleQuote(@source_system_book_id1) +','+ 
	dbo.FNASingleQuote(@source_system_book_id2) +','+ 
	dbo.FNASingleQuote(@source_system_book_id3) +','+ 
	dbo.FNASingleQuote(@source_system_book_id4) +','+ 
	dbo.FNASingleQuote(@deal_date_from) +',' +
	dbo.FNASingleQuote(@deal_date_to) +',' +
	dbo.FNASingleQuote(@type) +',' +
	dbo.FNASingleQuote(@source_system_id)+',' +
	dbo.FNASingleQuote(@summary_option)+','+
	dbo.FNASingleQuote(@counterparty_id)+','+
	dbo.FNASingleQuote(@use_create_date) +','+
	dbo.FNASingleQuote(@deal_id) +','+ 
	dbo.FNASingleQuote(@ref_id) +','+ 
	dbo.FNASingleQuote(@exlc_group4) +','+ 
	dbo.FNASingleQuote(@internal_desk_id) +','+ 
	dbo.FNASingleQuote(@product_id) +','+ 
	dbo.FNASingleQuote(@internal_portfolio_id) +','+ 
	dbo.FNASingleQuote(@commodity_id) +','+ 
	dbo.FNASingleQuote(@reference) 
	EXEC spa_print @sqlStmt
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


if @summary_option='s'
set @sqlStmt='select 
		DealId AS [Deal ID], [SourceDealID] AS [Source Deal ID],
		Group1  as ['+ @group1 +'], Group2  as ['+ @group2 +'], Group3  as ['+ @group3 +'], Group4  as ['+ @group4 +'],
		source_system [Source System],PercLinked AS [Perc Linked] ,
		DealDate AS [Deal Date], [EffectiveDate] AS [Effective Date], sourcedealtype AS [Source Deal Type], subdealtype AS [Sub Deal Type],
		TermStart AS [Term Start], TermEnd AS [Term End],Leg , FixedFloat AS [Fixed Float], CurveName AS [Curve Name], Price ,
		Strike , Currency , BuySell AS [Buy Sell], 	DealVolume AS [Deal Volume],	DealUOM AS [Deal UOM],VolumeFrequency AS [Volume Frequency],
		internal_desk_id [Internal Desk],product_id [Product ID],internal_portfolio_id [Portfolio ID],
		commodity_id [Commodity ID],Reference

		   from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar)+ ' order by sno asc'


else
		set @sqlStmt='select 
		source_system [Source System],
		Group1  as ['+ @group1 +'], Group2  as ['+ @group2 +'], Group3  as ['+ @group3 +'], Group4  as ['+ @group4 +'],
		PercLinked AS [Perc Linked] ,DealId AS [Deal ID], [SourceDealID] AS [Source Deal ID], DealDate AS [Deal Date], [EffectiveDate] AS [Effective Date], sourcedealtype AS [Source Deal Type], subdealtype AS [Sub Deal Type],
		 TermStart AS [Term Start], TermEnd AS [Term End],Leg , FixedFloat AS [Fixed Float], CurveName AS [Curve Name], Price ,
		Strike , Currency , BuySell AS [Buy Sell], 	DealVolume  AS [Deal Volume],	DealUOM AS [Deal UOM],VolumeFrequency AS [Volume Frequency],
	internal_desk_id [Internal Desk],product_id [Product ID],internal_portfolio_id [Portfolio ID],
		commodity_id [Commodity ID],Reference 
		   from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar)+ ' order by sno asc'

		--print @sqlStmt
		exec(@sqlStmt)

end



















