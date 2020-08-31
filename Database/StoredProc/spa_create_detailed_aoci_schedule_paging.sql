IF OBJECT_ID(N'spa_create_detailed_aoci_schedule_paging', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_create_detailed_aoci_schedule_paging]
 GO 



--exec spa_Create_AOCI_Report_paging'2004-12-31', '30', '208', '223', 'f', 'd', 'd', '0'
--exec spa_Create_AOCI_Report '2008-03-11', '256', '263', '264', 'f', 'd', 's'
--exec spa_Create_AOCI_Report '2008-03-11', '256', '260', '262', 'f', 'd', 'd'

create PROC [dbo].[spa_create_detailed_aoci_schedule_paging] 
				@as_of_date varchar(20), 
				@link_id varchar(20) = NULL, 
				@i_term varchar(20) = NULL, 
				@discount_option varchar(1) = 'u', 
				@sub_entity_id varchar(100) = NULL, 
				@strategy_entity_id varchar(100) = NULL, 
				@book_entity_id varchar(100) = NULL,
				@summary_option varchar(1) = 'd',
				@round_value char(1)='0',
				@term_start DATETIME=NULL,
				@term_end DATETIME=NULL,
				@process_id varchar(200)=NULL, 
				@page_size int =NULL,
				@page_no int=NULL,
				@batch_process_id VARCHAR(50)=NULL,
				@batch_report_param VARCHAR(1000)=NULL

 AS
SET NOCOUNT ON


declare @user_login_id varchar(50),@tempTable varchar(300) ,@flag char(1)

	set @user_login_id=dbo.FNADBUser()

	if @process_id is NULL
	Begin
		set @flag='i'
		set @process_id=REPLACE(newid(),'-','_')
	End
	set @tempTable=dbo.FNAProcessTableName('paging_temp_Detailed_AOCI_Report', @user_login_id,@process_id)
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
	exec  spa_create_detailed_aoci_schedule '+ 
	dbo.FNASingleQuote(@as_of_date) +','+ 
	dbo.FNASingleQuote(@link_id) +','+ 
	dbo.FNASingleQuote(@i_term) +','+ 
	dbo.FNASingleQuote(@discount_option) +',' +
	dbo.FNASingleQuote(@sub_entity_id) +','+ 
	dbo.FNASingleQuote(@strategy_entity_id) +','+ 
	dbo.FNASingleQuote(@book_entity_id) +','+ 
	dbo.FNASingleQuote(@summary_option) +',' +
	@round_value + ','+
	dbo.FNASingleQuote(@term_start) +','+ 
	dbo.FNASingleQuote(@term_end) +',' +
	dbo.FNASingleQuote(@batch_process_id)+','+
	dbo.FNASingleQuote(@batch_report_param)
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
	




