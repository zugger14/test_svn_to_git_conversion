IF OBJECT_ID(N'spa_faslinkheader_paging', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_faslinkheader_paging]
 GO 

-- EXEC spa_faslinkheader_paging 's', NULL, 10, 'n', 'y', '1/1/2002', '1/1/2009', NULL, NULL, NULL, NULL, NULL, NULL, NULL
-- EXEC spa_faslinkheader_paging 'a', 507 

--This proc will be used to select, insert, update and delete hedge relationship record
--from the fas_eff_hedge_rel_type table
--The fisrt parameter or flag to pass: select = 's', for Insert='i'. Update='u' and Delete='d'
--For insert and update, pass all the parameters defined for this stored procedure
--For delete, pass the flag and the fas_book_id

create proc [dbo].[spa_faslinkheader_paging]
	@flag char(1),
	@link_id int=NULL,
	@fas_book_id int=NULL,
	@fully_dedesignated char(1)=NULL,
	@link_active char(1)=NULL,
	@effective_date_from varchar(20)=NULL,
	@effective_date_to  varchar(20)=NULL,
	@link_description varchar(100)=NULL,
	@link_effective_date datetime=NULL,
	@link_type_value_id int=NULL,
	@perfect_hedge char(1)=NULL,
	@eff_test_profile_id int=NULL, 
	@link_id_from int =  NULL,
	@link_id_to int = NULL,
	@sort_order char(1)='l',
	@deal_id  varchar(MAX) = NULL,
	@ref_id varchar(MAX) = NULL,
	@eff_date_create_date CHAR(1) = NULL,
	@sub_id					INT			=NULL,
	@starategy_id			INT			=NULL,
	@process_id varchar(100)=NULL,
	@page_size int=NULL,
	@page_no int=NULL

AS

declare @user_login_id varchar(50),@tempTable varchar(300), @flag_paging char(1)

	set @user_login_id=dbo.FNADBUser()
	set @flag_paging='s'
	if @process_id is NULL
	Begin
		set @flag_paging='i'
		set @process_id=REPLACE(newid(),'-','_')
	End
	set @tempTable=dbo.FNAProcessTableName('paging_faslinkheader', @user_login_id,@process_id)
	declare @sqlStmt varchar(5000)

if @flag_paging='i'
begin
	set @sqlStmt='create table '+ @tempTable+'( 
	sno int  identity(1,1),
	LinkId varchar(500),
	BookId varchar(500),
	PerfectHedge varchar(500),
	FullyDedesignated varchar(500),
	Description varchar(500),
	HedgeRelTypeId varchar(500),
	EffectiveDate varchar(500),
	RelTypeId varchar(500),
	LinkActive varchar(500),
	CreatedUser varchar(500),
	CreateTS varchar(500),
	UpdateUser varchar(500),
	UpdateTS varchar(500),
	HedgeRelTypeName varchar(500),
	AllowChange varchar(500),
	HedgeType varchar(500)
	)'

	exec(@sqlStmt)

	set @sqlStmt=' insert  '+@tempTable+'
	exec spa_faslinkheader '+ dbo.FNASingleQuote(@flag) +','+ 
	dbo.FNASingleQuote(@link_id ) +',' +
	dbo.FNASingleQuote(@fas_book_id )+',' +
	dbo.FNASingleQuote(@fully_dedesignated )+',' +
	dbo.FNASingleQuote(@link_active )+',' +
	dbo.FNASingleQuote(@effective_date_from)+',' +
	dbo.FNASingleQuote(@effective_date_to)+',' +
	dbo.FNASingleQuote(@link_description)+',' +
	dbo.FNASingleQuote(@link_effective_date )+',' +
	dbo.FNASingleQuote(@link_type_value_id )+',' +
	dbo.FNASingleQuote(@perfect_hedge )+',' +
	dbo.FNASingleQuote(@eff_test_profile_id )+',' +
	dbo.FNASingleQuote(@link_id_from )+',' +
	dbo.FNASingleQuote(@link_id_to )+',' +
	dbo.FNASingleQuote(@sort_order )+',' +
	dbo.FNASingleQuote(@deal_id )+',' +
	dbo.FNASingleQuote(@ref_id )+',' +
	dbo.FNASingleQuote(@eff_date_create_date )+',' +
	dbo.FNASingleQuote(@sub_id )+',' +
	dbo.FNASingleQuote(@starategy_id )


	
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

set @sqlStmt='select LinkId as [Link ID], BookId as [Book ID], PerfectHedge as [Perfect Hedge], FullyDedesignated as [Fully Dedesignated], 	Description , HedgeRelTypeId as [Hedge Rel Type ID], EffectiveDate as [Effective Date],
	RelTypeId as [Rel Type ID], LinkActive as [Link Active],  CreatedUser as [Created User], CreateTS as [Create TS], UpdateUser as [Update User], UpdateTS as [Update TS], HedgeRelTypeName as [Hedge Rel Type Name], AllowChange as [Allow Change],
	HedgeType as [Hedge Type] from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar)+ ' 
	order by sno asc'
		
	exec(@sqlStmt)
end








