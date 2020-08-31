/****** Object:  StoredProcedure [dbo].[spa_get_rec_activity_report_paging]    Script Date: 06/25/2009 16:24:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_REC_Target_Report_paging]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_REC_Target_Report_paging]
GO 
/****** Object:  StoredProcedure [dbo].[spa_get_rec_activity_report_paging]    Script Date: 06/25/2009 15:13:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROC [dbo].[spa_REC_Target_Report_paging]
	@as_of_date varchar(50), 
	@sub_entity_id varchar(100), 
	@strategy_entity_id varchar(100) = NULL, 
	@book_entity_id varchar(100) = NULL, 
	@assignment_type int = null,  --assignment_type  
	@summary_option char(1),  --'s' summary, 'd' detail that shows generator, 'i' shows indvidual deals
	@compliance_year int,
	@assigned_state int = null,
	@include_banked varchar(1) = 'n',
	@curve_id int = NULL,
	@curve_name varchar(100)= NULL,
	@plot varchar(1) = 'n',
	@generator_id int = null,
	@convert_uom_id int = null,
	@convert_assignment_type_id int = null,
	@deal_id_from int = null,
	@deal_id_to int = null,
	@gis_cert_number varchar(250)= null,
	@gis_cert_number_to varchar(250)= null,
	@generation_state int=null,
	@program_scope varchar(50)=null,
	@program_type char(1)='b', --- 'a' -> Compliance, 'b' -> cap&trade  ,
	@round_value CHAR(1)='0',
	@show_cross_tabformat CHAR(1)='n',
	@gen_date_from varchar(20) = null,            
	@gen_date_to varchar(20) = null,  
	@include_expired CHAR(1)='n',
	@carry_forward CHAR(1)='n',
	@udf_group1 INT=NULL,
	@udf_group2 INT=NULL,
	@udf_group3 INT=NULL,	
	@tier_type INT=NULL,
	@technology INT=NULL,
	@allocate_banked CHAR(1)=NULL,
	@report_type CHAR(1)=NULL, -- 't' target report, 'p' trader position report
	@curve_source_value_id INT=NULL,
	@drill_State VARCHAR(100)=NULL,
	@batch_process_id varchar(50)=NULL,
	@page_size int =NULL,
	@page_no int=NULL 


 AS

EXEC spa_print 'gggggggggggggggggg'
exec spa_REC_Target_Report  
	@as_of_date
	,@sub_entity_id	
	,@strategy_entity_id	
	,@book_entity_id	
	,@assignment_type
	,@summary_option	
	,@compliance_year	
	,@assigned_state 
	,@include_banked	
	,@curve_id
	,@curve_name
	,@plot
	,@generator_id	
	,@convert_uom_id	
	,@convert_assignment_type_id	
	,@deal_id_from	
	,@deal_id_to	
	,@gis_cert_number	
	,@gis_cert_number_to	
	,@generation_state
	,@program_scope	
	,@program_type
	,@round_value
	,@show_cross_tabformat
	,@gen_date_from
	,@gen_date_to
	,@include_expired
	,@carry_forward
	,@udf_group1
	,@udf_group2
	,@udf_group3
	,@tier_type
	,@technology
	,@allocate_banked
	,@report_type
	,@curve_source_value_id
	,@drill_State
	,@batch_process_id
	,NULL
	,1   --'1'=enable, '0'=disable
	,@page_size 
	,@page_no 



/*
SET NOCOUNT ON


declare @user_login_id varchar(50),@tempTable varchar(300) ,@flag char(1)

	set @user_login_id=dbo.FNADBUser()
	

	if @process_id is NULL
	Begin
		set @flag='i'
		set @process_id=REPLACE(newid(),'-','_')
	End
	set @tempTable=dbo.FNAProcessTableName('paging_REC_Target_Report', @user_login_id,@process_id)
	declare @sqlStmt varchar(5000)

if @flag='i'
BEGIN


	IF @summary_option='s'
	BEGIN
		set @sqlStmt='create table '+ @tempTable+'( 
			sno int  identity(1,1),
			[sub] [varchar] (100)  ,
			[Assigned/Default Jurisdiction] [varchar] (250)  ,
			[Compliance/Expiration Year] [varchar] (100) ,
			[Assignment] [varchar] (100) ,
			[EnvProduct] [varchar] (50) ,
			[Type] [varchar] (50) ,
			[volume] [float] NULL ,
			[Bonus] [float] NULL ,
			[TotalVolume(+Long,-Short)] [float] NULL ,
			[Unit] [varchar] (50)
			)'
	END
	ELSE 
	BEGIN
		
		set @sqlStmt='create table '+ @tempTable+'( 
			sno int  identity(1,1),
			[sub] [varchar] (100)  ,
			[Strategy] [varchar] (100),
			[Book] [varchar] (100),
			[EnvProduct] [varchar] (100),
			[TierType] [varchar] (100),
			[Technology] [varchar] (100),
			[Assignment] [varchar] (200),
			[Type] [varchar] (100),			
			[Assigned/Default Jurisdiction] [varchar] (250)  ,
			[GenState] [varchar] (250)  ,
			[Compliance/Expiration Year] [varchar] (200) ,
			[Vintage] [varchar] (200) ,			
			[CertIDFrom] [varchar](100),
			[CertIDTo] [varchar](100),
			[Original RefID] [varchar](250),
			[volume] [float] NULL ,
			[Bonus] [float] NULL ,
			[TotalVolume(+Long,-Short)] [float] NULL ,
			[Unit] [varchar] (50)
			)'


	END
	exec(@sqlStmt)
	
	set @sqlStmt=' insert  '+@tempTable+ '
	exec spa_REC_Target_Report ' + 
	dbo.FNASingleQuote(@as_of_date) +',' +	
	dbo.FNASingleQuote(@sub_entity_id) +',' +	
	dbo.FNASingleQuote(@strategy_entity_id) +',' +	
	dbo.FNASingleQuote(@book_entity_id) +',' +	
	isnull(cast(@assignment_type as varchar), 'null')  +',' +	
	dbo.FNASingleQuote(@summary_option) +',' +	
	isnull(cast(@compliance_year as varchar), 'null')  +',' +	
	isnull(cast(@assigned_state as varchar), 'null' ) +',' +
	dbo.FNASingleQuote(@include_banked) +',' +	
	isnull(cast(@curve_id as varchar), 'null')  +',' +	
	isnull(cast(@curve_name as varchar), 'null' ) +',' +
	isnull(cast(@plot as varchar), '''n''' ) +',' +
	
	isnull(cast(@generator_id as varchar), 'null')  +',' +	
	isnull(cast(@convert_uom_id as varchar), 'null')  +',' +	
	isnull(cast(@convert_assignment_type_id as varchar), 'null')  +',' +	
	isnull(cast(@deal_id_from as varchar), 'null')  +',' +	
	isnull(cast(@deal_id_to as varchar), 'null')  +',' +	
	dbo.FNASingleQuote(@gis_cert_number) +',' +	
	dbo.FNASingleQuote(@gis_cert_number_to) +',' +	
	isnull(cast(@generation_state as varchar), 'null')  +',' +
	dbo.FNASingleQuote(@program_scope) +',' +	
	dbo.FNASingleQuote(@program_type) +','+
	dbo.FNASingleQuote(@round_value) +','+
	dbo.FNASingleQuote(@show_cross_tabformat) +','+
	dbo.FNASingleQuote(@gen_date_from) +','+
	dbo.FNASingleQuote(@gen_date_to ) +','+
	dbo.FNASingleQuote(@include_expired) +','+
	dbo.FNASingleQuote(@carry_forward) +','+
	dbo.FNASingleQuote(@udf_group1) +','+
	dbo.FNASingleQuote(@udf_group2) +','+
	dbo.FNASingleQuote(@udf_group3) +','+
	dbo.FNASingleQuote(@tier_type) +','+
	dbo.FNASingleQuote(@technology) +','+
	dbo.FNASingleQuote(@allocate_banked) +','+
	dbo.FNASingleQuote(@report_type) +','+
	isnull(cast(@curve_source_value_id as varchar), 'null')  +','+
	dbo.FNASingleQuote(@drill_State) 
	


EXEC spa_print @sqlStmt	
 	exec(@sqlStmt)	


	--These are for drill down

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
IF @summary_option='s'
	BEGIN 
		set @sqlStmt='select 
			[Sub], [Assigned/Default Jurisdiction], [Compliance/Expiration Year],[Assignment], [EnvProduct],[Type],
			 [volume], [Bonus], [TotalVolume(+Long,-Short)], [Unit]
		  from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) + ' order by sno asc'
	END 
ELSE 
	BEGIN 
		set @sqlStmt='select 
			[Sub],[Strategy],[Book],[CertIDFrom],[CertIDTo], [Assigned/Default Jurisdiction], [Compliance/Expiration Year],[Assignment], [EnvProduct],[Type],
			[Original RefID], [volume], [Bonus], [TotalVolume(+Long,-Short)], [Unit]
		  from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) + ' order by sno asc'
	END 
	
exec(@sqlStmt)
end

*/

