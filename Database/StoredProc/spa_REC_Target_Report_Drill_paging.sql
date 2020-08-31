IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_REC_Target_Report_Drill_paging]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_REC_Target_Report_Drill_paging]
GO 


--EXEC spa_REC_Target_Report_Drill_paging '2006-12-31', '96', null, null, '5146', 2005, 5118, 'y', null,'SPS',NULL,NULL,'TX',2007,'Banked','REC - Tier1','Actual'

--

CREATE proc [dbo].[spa_REC_Target_Report_Drill_paging]
	@as_of_date varchar(50), 
	@sub_entity_id varchar(100), 
	@strategy_entity_id varchar(100) = NULL, 
	@book_entity_id varchar(100) = NULL, 
	@report_type int = null,  --assignment_type  
	--@summary_option char(1), --always 'd'
	@compliance_year int,
	@assigned_state int = null,
	@include_banked varchar(1) = 'n', -- always 'n'
	@curve_id int = NULL,
	
	@generator_id int = null,
	@convert_uom_id int = null,
	@convert_assignment_type_id int = null,
	@deal_id_from int = null,
	@deal_id_to int = null,
	@gis_cert_number varchar(250)= null,
	@gis_cert_number_to varchar(250)= null,

	@Sub varchar(100) = null,
	@generator varchar(100) = null,
	@gen_date varchar(100) = null,
	@State varchar(1000) = null,
	@Year int,
	@Assignment varchar (50) ,
	@Obligation varchar (100), 
 	@type varchar(20) = null,
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
	set @tempTable=dbo.FNAProcessTableName('paging_temp_REC_Target_Report_Drill', @user_login_id,@process_id)
	declare @sqlStmt varchar(5000)

if @flag='i'
begin
	set @sqlStmt='create table '+ @tempTable+'( 
	sno int  identity(1,1),
	Sub varchar(100),
	Generator varchar(100),
	Technology varchar(250),
	gen_date varchar(100),
	[ID] varchar (1000),
	[Cert #] varchar(250),
	Eligibility varchar(250),
	[Assigned/Default State] varchar(1000),
	[Compliance/Expiration Year] varchar(100),
	[Assignment] [varchar] (50) ,
	[Obligation] [varchar] (100) ,
	[Type] varchar (50),
	[Volume] varchar(100) ,
	[Bonus] varchar(100),
	[Total Volume (+Long, -Short)] varchar(100) ,
	[Unit] [varchar] (100)
	)'
	
	--print @sqlStmt
	exec(@sqlStmt)


	CREATE TABLE [dbo].[#temp] (
		Sub varchar(100),
		Generator varchar(100),		
		Technology varchar(250),
		gen_date varchar(100),		
		[ID] varchar (1000),
		[Cert #] varchar(250),
		Eligibility varchar(250),
		[Assigned/Default State] varchar(1000),
		[Compliance/Expiration Year] [int] ,
		[Assignment] [varchar] (50) ,
		[Obligation] [varchar] (100) ,
		[Type] varchar (50),
		[Volume] [float] ,
		[Bonus] [float] ,
		[Total Volume (+Long, -Short)] [float] ,
		[unit] [varchar] (100)
	) ON [PRIMARY]
	
	INSERT #temp
	EXEC spa_REC_Target_Report @as_of_date, @sub_entity_id, @strategy_entity_id, @book_entity_id, @report_type, 
	'i', @compliance_year, @assigned_state, @include_banked, @curve_id,
	NULL, 'n', @generator_id, @convert_uom_id, @convert_assignment_type_id, @deal_id_from,
	@deal_id_to, @gis_cert_number, @gis_cert_number_to 

	
--	EXEC spa_print 'here'

	set @sqlStmt=' insert  into '+@tempTable+'
	(Sub, Generator, Technology, gen_date, [ID] , 	[Cert #], Eligibility, [Assigned/Default State] , [Compliance/Expiration Year] , [Assignment] , [Obligation] ,
	[Type], [Volume] , 	[Bonus], 	[Total Volume (+Long, -Short)]  , 	[Unit])
	Select * from #temp
	where	Sub = ''' + @Sub + ''' AND 
		[Assigned/Default State] like (''' + '%' + @State + '%' + ''') AND 
		[Compliance/Expiration Year] = ' + cast(@Year as varchar) + ' AND
		Assignment = ''' + @Assignment + ''' AND 
		Obligation = ''' + @Obligation + ''' AND
		Type = ''' + @type + '''' + 
	case when (@generator is null) then '' else ' AND Generator = ''' + @generator + '''' end +
	case when (@gen_date is null) then '' else ' AND gen_date = ''' + @gen_date + '''' end +

	' order by Sub, Generator, [Assigned/Default State], [Compliance/Expiration Year] desc, Assignment, isnull([Cert #], ID)'
	

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

set @sqlStmt='select Sub, Generator, Technology, gen_date GenDate, [ID] , 	[Cert #], Eligibility, [Assigned/Default State] , [Compliance/Expiration Year] , [Assignment] , [Obligation] ,
	[Type], 	[Volume] , 	[Bonus], 	[Total Volume (+Long, -Short)]  , 	[Unit] 
  from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) + ' order by sno asc'
	exec(@sqlStmt)
end







