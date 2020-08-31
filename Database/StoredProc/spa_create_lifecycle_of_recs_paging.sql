IF OBJECT_ID(N'[dbo].[spa_create_lifecycle_of_recs_paging]', N'P') IS NOT NULL
   DROP PROCEDURE [dbo].[spa_create_lifecycle_of_recs_paging]
GO



CREATE PROCEDURE [dbo].[spa_create_lifecycle_of_recs_paging]
	@as_of_date varchar(20),        
	@book_deal_type_map_id varchar(5000) = null,        
	@source_deal_header_id varchar(5000)  = NULL,
	@cert_from BIGINT = NULL,
	@cert_to BIGINT = NULL,
	@deal_date_from VARCHAR(20) = NULL, 
	@deal_date_to VARCHAR(20) = NULL,
	@deal_id_from INT = NULL,
	@deal_id_to INT = NULL,
	@counterparty_id varchar(500) = NULL, 
	@deal_type_id VARCHAR(100) = NULL,
	@deal_sub_type_id VARCHAR(100) = NULL,
	@deal_category_value_id int=NULL,
	@physical_financial_flag CHAR(1)=NULL,
    @trader_id int=NULL,
    @tenor_from varchar(20) = NULL,
	@tenor_to varchar(20) = NULL,
	@description1 varchar(100)=NULL,
	@description2 varchar(100)=NULL,
	@description3 varchar(100)=NULL,
	@generator_id INT = NULL ,
    @compliance_year int = NULL,
    @gis_value_id int = NULL ,
    @gis_cert_date varchar(20) = NULL ,
	@gen_cert_number varchar (250) = NULL ,
	@gen_cert_date varchar(20) = NULL,
	@assignment_type_value_id int = NULL,
	@state_value_id int = NULL,
	@assigned_date datetime = NULL ,
	@assigned_by varchar (50) = NULL,
	@status_value_id int = NULL,
	@status_date datetime = NULL,
	@header_buy_sell_flag varchar(1)=NULL,
	@deal_id varchar(100)=NULL,
	@process_id varchar(200)=NULL, 
	@page_size int =NULL,
	@page_no int=NULL 

AS

declare @user_login_id varchar(50),@tempTable varchar(300) ,@flag char(1)

	set @user_login_id=dbo.FNADBUser()

	if @process_id is NULL
	Begin
		set @flag='i'
		set @process_id=REPLACE(newid(),'-','_')
	End
	set @tempTable=dbo.FNAProcessTableName('paging_lifecycle_of_rec', @user_login_id,@process_id)
	declare @sqlStmt varchar(5000)

if @flag='i'
begin
	set @sqlStmt='create table '+ @tempTable+'( 
	sno int  identity(1,1),
	Id varchar(500),
	Date varchar(500),
	GenDate varchar(500),
	SID varchar(100),
	[Cert #] varchar(100),
	Volume varchar(100),
	Source varchar(100),
	Unit varchar(100),
	Assignment varchar(500),
	Complainceyear varchar(100),
	AssignedState varchar(100),
	AsOfDate varchar(50),
	AssignedBy varchar(100),
	Expiration varchar(100),
	AuditTS varchar(100)
	)'

	exec(@sqlStmt)
	
	set @sqlStmt=' insert  '+@tempTable+'
	exec spa_create_lifecycle_of_recs '+
	dbo.FNASingleQuote(@as_of_date)				+', '+ 
	dbo.FNASingleQuote(@book_deal_type_map_id)	+', ' +
	dbo.FNASingleQuote(@source_deal_header_id)	+', ' +
	@cert_from									+', ' +
	@cert_to									+', ' +
	dbo.FNASingleQuote(@deal_date_from)			+', ' +
	dbo.FNASingleQuote(@deal_date_to)			+', ' +
	@deal_id_from								+', ' +
	@deal_id_to									+', ' +
	dbo.FNASingleQuote(@counterparty_id)		+', ' +
	dbo.FNASingleQuote(@deal_type_id)			+', ' +
	dbo.FNASingleQuote(@deal_sub_type_id)		+', ' +
	@deal_category_value_id						+', ' +
	dbo.FNASingleQuote(@physical_financial_flag)+', ' +
    @trader_id									+', ' +
    dbo.FNASingleQuote(@tenor_from)				+', ' +
	dbo.FNASingleQuote(@tenor_to)				+', ' +
	dbo.FNASingleQuote(@description1)			+', ' +
	dbo.FNASingleQuote(@description2)			+', ' +
	dbo.FNASingleQuote(@description3)			+', ' +
	@generator_id								+', ' +
    @compliance_year							+', ' +
    @gis_value_id								+', ' +
    dbo.FNASingleQuote(@gis_cert_date)			+', ' +
	dbo.FNASingleQuote(@gen_cert_number)		+', ' +
	dbo.FNASingleQuote(@gen_cert_date)			+', ' +
	@assignment_type_value_id					+', ' +
	@state_value_id								+', ' +
	dbo.FNASingleQuote(@assigned_date)			+', ' +
	dbo.FNASingleQuote(@assigned_by)			+', ' +
	@status_value_id							+', ' +
	dbo.FNASingleQuote(@status_date)			+', ' +
	dbo.FNASingleQuote(@header_buy_sell_flag)	+', ' +
	dbo.FNASingleQuote(@deal_id)				
	--PRINT @sqlStmt
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

set @sqlStmt='select Id , Date , GenDate , SID [Cert # From] , [Cert #] [Cert # To] , Volume , Source ,  Unit , Assignment , Complainceyear Complianceyear , AssignedState ,
	AsOfDate ,  AssignedBy , Expiration , AuditTS    from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ 
	cast(@row_to as varchar) + ' order by sno asc'
	exec(@sqlStmt)
end




