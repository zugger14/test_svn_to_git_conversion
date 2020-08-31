IF OBJECT_ID(N'spa_create_tagging_audit_report_paging', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_create_tagging_audit_report_paging]
 GO 


CREATE PROCEDURE [dbo].[spa_create_tagging_audit_report_paging]
		@sub_entity_id varchar(100), 
		@strategy_entity_id varchar(100) = NULL, 
		@book_entity_id varchar(100) = NULL, 
		@deal_date_from varchar(100)=null,
		@deal_date_to varchar(100)=null,
		@source_system_book_id1 int=NULL, 
		@source_system_book_id2 int=NULL, 
		@source_system_book_id3 int=NULL, 
		@source_system_book_id4 int=NULL, 
		@deal_id_from int=null,
		@deal_id_to int=null,
		@deal_id int=null,
		@counterparty_id VARCHAR(MAX)=null,
		@audit_user varchar(100)=null,
		@use_create_date char(1)='n',
		@comments varchar(500)=null,
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
	set @tempTable=dbo.FNAProcessTableName('paging_temp_tagging_audit_Report', @user_login_id,@process_id)
	declare @sqlStmt varchar(5000)

if @flag='i'
begin

		set @sqlStmt='create table '+ @tempTable+'( 
		sno int  identity(1,1),
		DealId varchar(500),
		SourceDealId varchar(500),
		Group1 varchar(500),
		Group2 varchar(500),
		Group3 varchar(500),
		Group4 varchar(500),
		DealDate varchar(500),
		Counterparty varchar(100),
		source_system varchar(100),
		Comments varchar(500),
		UpdatedBy varchar(100),
		TimeStamp varchar(100)
		)'

	exec(@sqlStmt)
	
	set @sqlStmt=' insert  '+@tempTable+'
	exec  spa_create_tagging_audit_report '+ 
	dbo.FNASingleQuote(@sub_entity_id) +','+ 
	dbo.FNASingleQuote(@strategy_entity_id) +','+ 
	dbo.FNASingleQuote(@book_entity_id) +','+ 
	dbo.FNASingleQuote(@deal_date_from) +','+ 
	dbo.FNASingleQuote(@deal_date_to) +','+ 
	dbo.FNASingleQuote(@source_system_book_id1) +','+ 
	dbo.FNASingleQuote(@source_system_book_id2) +','+ 
	dbo.FNASingleQuote(@source_system_book_id3) +','+ 
	dbo.FNASingleQuote(@source_system_book_id4) +','+ 
	dbo.FNASingleQuote(@deal_id_from) +',' +
	dbo.FNASingleQuote(@deal_id_to) +',' +
	dbo.FNASingleQuote(@deal_id) +',' +
	dbo.FNASingleQuote(@counterparty_id)+','+
	dbo.FNASingleQuote(@audit_user)+','+
	dbo.FNASingleQuote(@use_create_date)+','+
	dbo.FNASingleQuote(@comments)
	
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



		set @sqlStmt='select 
		DealId [DealID],
		SourceDealId [SourceDealID],
		Group1  as ['+ @group1 +'], Group2  as ['+ @group2 +'], Group3  as ['+ @group3 +'], Group4  as ['+ @group4 +'],
		DealDate ,Counterparty,source_system [Source System],Comments [Comments],
		UpdatedBy,TimeStamp
		   from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar)+ ' order by sno asc'


		exec(@sqlStmt)

end

















