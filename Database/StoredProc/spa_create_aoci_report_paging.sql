IF OBJECT_ID(N'spa_create_aoci_report_paging', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_create_aoci_report_paging]--#region Put Description Here

--#endregion
 GO 

--exec spa_Create_AOCI_Report_paging'2004-12-31', '30', '208', '223', 'f', 'd', 'd'
--exec spa_Create_AOCI_Report '2008-03-11', '256', '263', '264', 'f', 'd', 's'
--exec spa_Create_AOCI_Report '2008-03-11', '256', '260', '262', 'f', 'd', 'd'

create proc [dbo].[spa_create_aoci_report_paging]
    @as_of_date varchar(50), 
	@sub_entity_id varchar(100), 
 	@strategy_entity_id varchar(100) = NULL, 
	@book_entity_id varchar(100) = NULL, 
	@settlement_option varchar(1),
	@discount_option char(1), 
	@summary_option char(1),
	@round_value char(1)='0',
	@term_start DATETIME=NULL,
	@term_end DATETIME=NULL,
    @process_id varchar(200)=NULL, 
	@page_size int =NULL,
	@page_no int=NULL

 AS
SET NOCOUNT ON




exec  spa_Create_AOCI_Report 
	@as_of_date,
	@sub_entity_id,
	@strategy_entity_id,
	@book_entity_id,
	@settlement_option,
	@discount_option,
	@summary_option,
	@round_value,
	@term_start,
	@term_end,
	@process_id,
	NULL,
		1   --'1'=enable, '0'=disable
	,@page_size 
	,@page_no 




/*


















	if @process_id is NULL
	Begin
		set @flag='i'
		set @process_id=REPLACE(newid(),'-','_')
	End
	set @tempTable=dbo.FNAProcessTableName('paging_temp_AOCI_Report', @user_login_id,@process_id)
	declare @sqlStmt varchar(5000)


if @flag='i'
begin
--if @summary_option='s'
	set @sqlStmt='create table '+ @tempTable+'( 
		sno int  identity(1,1),
		AsOfDate varchar(500),
		RelId varchar(50),
		DeliveryMonth varchar(500),
		DerDelaID varchar(500),
		SourceDealID varchar(50),
		DerContractMonth varchar(50),
		DerStripMonths varchar(50),
		DerLaggingMonths varchar(50),
		ItemStripMonths varchar(50),
		ReleaseType varchar(500),
		AOCIReleasePer varchar(50),
		AOCI float,
		AOCIRelease float
		)'
		exec(@sqlStmt)

set @sqlStmt=' insert  '+@tempTable+'
	exec  spa_Create_AOCI_Report '+ 
	dbo.FNASingleQuote(@as_of_date) +','+ 
	dbo.FNASingleQuote(@sub_entity_id) +','+ 
	dbo.FNASingleQuote(@strategy_entity_id) +','+ 
	dbo.FNASingleQuote(@book_entity_id) +','+ 
	dbo.FNASingleQuote(@settlement_option) +',' +
	dbo.FNASingleQuote(@discount_option) +',' +
	dbo.FNASingleQuote(@summary_option) +','+
	@round_value+','+
	dbo.FNASingleQuote(@term_start) +','+
	dbo.FNASingleQuote(@term_end) 

	EXEC spa_print @sqlStmt
	exec(@sqlStmt)

    set @sqlStmt='select count(*) TotalRow,'''+@process_id +''' process_id  from '+ @tempTable
	EXEC spa_print @sqlStmt
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


end
		set @sqlStmt='select AsOfDate ,RelId, DeliveryMonth,DerDelaID,SourceDealID,DerContractMonth,DerStripMonths,DerLaggingMonths,ItemStripMonths,
        ReleaseType,AOCIReleasePer,AOCI,AOCIRelease
	
	   from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar)+ ' order by sno asc'

		EXEC spa_print @sqlStmt
		exec(@sqlStmt)
	

*/
