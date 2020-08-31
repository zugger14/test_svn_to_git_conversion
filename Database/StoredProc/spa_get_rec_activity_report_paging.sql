/****** Object:  StoredProcedure [dbo].[spa_get_rec_activity_report_paging]    Script Date: 06/25/2009 16:24:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_get_rec_activity_report_paging]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_get_rec_activity_report_paging]
GO 
/****** Object:  StoredProcedure [dbo].[spa_get_rec_activity_report_paging]    Script Date: 06/25/2009 15:13:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROC [dbo].[spa_get_rec_activity_report_paging]
	@as_of_date varchar(20),
	@sub_entity_id varchar(100), 
	@strategy_entity_id varchar(100) = NULL, 
	@book_entity_id varchar(100) = NULL, 
	@report_type int = null,  --assignment_type  
	@summary_option char(1) = 's',  --'s' summary, 't' trader, 'g' generator, 'c' counterparty, 'd' detail that shows generator
	@compliance_year int,
	@assigned_state int = null,
	@curve_id int = NULL,
	@generator_id int = null,
	@convert_uom_id int = null,
	@convert_assignment_type_id int = null,
	@deal_id_from int = null,
	@deal_id_to int = null,
	@gis_cert_number varchar(250)= null,
	@gis_cert_number_to varchar(250)= null,

	@gen_date_from varchar(20) = null,
	@gen_date_to varchar(20) = null, 
	@deal_date_from varchar(20) = null, 
	@deal_date_to varchar(20) = null, 
	@technology int = null, 
	@buy_sell_flag varchar(1) = null, 
	@status_id varchar(1)  = null,   --'a' for active, 'e' for expired, 's' for surrendered
	@gis_id int = null, 
	@counterparty_id int = null,
	@deal_type int = null,
	@to_be_assigned_type int = null,
	@deal_sub_type int = null,
	@generation_state int=null,
	@include_inventory char(1)='n',    
	--These are for drill down
	@drill_Counterparty varchar(100)=null, 
	@drill_Technology varchar(100)=null, 
	@drill_DealDate varchar(100)=null, 
	@drill_BuySell varchar(100)=null, 
	@drill_State varchar(100)=null, 
	@drill_oblication varchar(100)=null, 
	@drill_UOM varchar(100) = null,
	@drill_trader varchar(100) = null,	
	@drill_Generator varchar(100) = null,
	@drill_Assignment varchar(100) = null,
	@drill_Expiration varchar(100) = null,
	@Target_report CHAR(1)='n',     -- 't' means transactions report       
	@Plot CHAR(1)='n',            
	@included_banked varchar(1) = 'n',    
	@program_scope varchar(50)=null,    
	@program_type char(1)='b', --- 'a' -> Compliance, 'b' -> cap&trade 
	@round_value VARCHAR(1)='0',
	@udf_group1 INT=NULL,
	@udf_group2 INT=NULL,
	@udf_group3 INT=NULL,		
	@tier_type INT=NULL,
	@include_expired CHAR(1)='n',
	@expiration_from  varchar(20)=NULL,
	@expiration_to  varchar(20)=NULL,
	@process_id varchar(200)=NULL, 
	@page_size int =NULL,
	@page_no int=NULL 


 AS


EXEC spa_print 'gggggggggggggggggg'

exec [dbo].[spa_get_rec_activity_report]            
	 @as_of_date,            
	 @sub_entity_id,             		
	 @strategy_entity_id,             
	 @book_entity_id,             
	 @report_type,  --assignment_type              
	 @summary_option,  --'s' summary, 't' trader, 'g' generator,'h' generator/credit source group,'i' generator/credit source by group, 'c' counterparty, 'o' Env Product & Vintage,'v' Trader & Vintage,'z' Counterparty & Vintage,'y' Generator BY Year 'b' year activity
	 @compliance_year,            
	 @assigned_state,            
	 @curve_id,            
	 @generator_id,            
	 @convert_uom_id,            
	 @convert_assignment_type_id,            
	 @deal_id_from ,             
	 @deal_id_to ,            
	 @gis_cert_number ,            
	 @gis_cert_number_to,            
	 @gen_date_from ,            
	 @gen_date_to ,             
	 @deal_date_from ,             
	 @deal_date_to ,             
	 @technology ,             
	 @buy_sell_flag,             
	 @status_id ,   --'a' for active, 'e' for expired, 's' for surrendered            
	 @gis_id ,             
	 @counterparty_id ,            
	 @deal_type ,            
	 @to_be_assigned_type ,            
	 @deal_sub_type ,
	 @generation_state,
	 @include_inventory ,    
	  --These are for drill down            
	 @drill_Counterparty ,             
	 @drill_Technology ,             
	 @drill_DealDate ,             
	 @drill_BuySell,             
	 @drill_State ,             
	 @drill_oblication,             
	 @drill_UOM ,            
	 @drill_trader,             
	 @drill_Generator,            
	 @drill_Assignment,            
	 @drill_Expiration ,            	 
	 -- For target report            
	 @Target_report,     -- 't' means transactions report       
	 @Plot,            
	 @included_banked ,    
	 @program_scope,    
	 @program_type, --- 'a' -> Compliance, 'b' -> cap&trade  
	 @round_value, 	 
	 @udf_group1,
	 @udf_group2 ,
	 @udf_group3,		
	 @tier_type ,
	 @include_expired ,
	 @expiration_from ,
	 @expiration_to ,
	 @process_id         
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
	set @tempTable=dbo.FNAProcessTableName('paging_temp_REC_Activity_Report_Drill', @user_login_id,@process_id)
	declare @sqlStmt varchar(max),@strTable VARCHAR(100),@strCol VARCHAR(100),@trader_or_counterparty_t VARCHAR(100),
	@trader_or_counterparty_c VARCHAR(100),@counterparty_t VARCHAR(100),@counterparty_c VARCHAR(100),@total_vol_c VARCHAR(100),
	@total_vol_t VARCHAR(100),@bonus_t VARCHAR(100),@bonus_c VARCHAR(100)
	SET @strTable=''
	SET @strCol=''
	IF @summary_option='t'
	begin
		SET @trader_or_counterparty_t='[Trader] [varchar](100)'
		SET @trader_or_counterparty_c='[Trader]'
		SET @counterparty_t='[Counterparty] [varchar](100),'
		SET @counterparty_c='[Counterparty],'
		SET @total_vol_t='[Total Volume (+Long, -Short)] [float],'
		SET @total_vol_c='[Total Volume (+Long, -Short)],'
		SET @bonus_t = '[Bonus] float,'
		SET @bonus_c = '[Bonus],'
		
		
	END 
	ELSE 
	BEGIN 
		SET @trader_or_counterparty_t='[Counterparty] [varchar](100)'
		SET @trader_or_counterparty_c='[Counterparty]'
		SET @counterparty_t=''
		SET @counterparty_c=''		
		SET @total_vol_t=''
		SET @total_vol_c=''
		SET @bonus_t = ''
		SET @bonus_c = ''
		
	END 

if @flag='i'
BEGIN
	IF @Target_report='t'
	BEGIN 

	IF @summary_option='s'
		BEGIN 
			set @sqlStmt='create table '+ @tempTable+'( 
				sno int  identity(1,1),
				[technology] [varchar] (100)  ,
				[jurisdiction] [varchar] (250)  ,
				[Assignment] [varchar] (100) ,
				[Env Product] [varchar] (50) ,
				[Deal Date] [varchar](50),
				[volume] [float] NULL ,
				[UOM] [varchar] (50)
				)'
		END 
	ELSE IF @summary_option='t' OR @summary_option='c'
		BEGIN
			set @sqlStmt='create table '+ @tempTable+'( 
				sno int  identity(1,1),'+
				@trader_or_counterparty_t+' ,           
				[Technology] [varchar](100),'+            
				@counterparty_t+'               
				[Deal Date] [varchar](100),            
				[BuySell][varchar](100),               
				[Jurisdiction] [varchar](500),             
				[Env Product] [varchar](100),            
				[Volume] float,'+   
				@total_vol_t+'            
				UOM [varchar](100) ,
				[Price] FLOAT,
				[Settlement (+Rec/-Pay)] float 
				)'
		END
	ELSE IF @summary_option='g' OR @summary_option='h' OR  @summary_option='i'
		
		BEGIN
			if @summary_option='i'
			set @strTable='[Generator/Credit Source Group] [varchar](100),'
			
			set @sqlStmt='create table '+ @tempTable+'( 
				sno int  identity(1,1),'+@strTable+'
				[Generator/Credit Source] [varchar](300) ,           
				[Technology] [varchar](100),            
				[Assignment] [varchar](300),               
				[Jurisdiction] [varchar](500), 			  
				[Env Product] [varchar](100),            
				[Deal Date] [varchar](100),   
				[Volume] float,            
				[Total Volume] float ,
				[UOM] [varchar](50)
				)'
		END
	ELSE IF @summary_option='y'
		BEGIN
			set @sqlStmt='create table '+ @tempTable+'( 
				sno int  identity(1,1),
				[Generator/Credit Source] [varchar](300) ,           
				[Technology] [varchar](100),            
				[Assignment] [varchar](300),               
				[Jurisdiction] [varchar](500), 			  
				[Env Product] [varchar](100),            
				[Vintage Year] [varchar](100),   
				[Volume] float,            
				[Total Volume] float ,
				[UOM] [varchar](50)
				)'
		END
		ELSE IF @summary_option='o' 
		
		BEGIN					
			set @sqlStmt='create table '+ @tempTable+'( 
				sno int  identity(1,1),
				[Env Product] [varchar](100),            
				[Term] [varchar](100),   
				[Volume] float,            
				[Total Volume] float ,
				[UOM] [varchar](50)
				)'
		END
		ELSE IF @summary_option='v'  
		BEGIN
			set @sqlStmt='create table '+ @tempTable+'( 
				sno int  identity(1,1),           
				[Trader] [varchar](100), 
				[Env Product] [varchar](100),       
				[Term] [varchar](300),            
				[Volume] float, 
				[Total Volume] float,      
				UOM [varchar](100) ,
				[Price] FLOAT,
				[Settlement (+Rec/-Pay)] float 
				)'
		END
		ELSE IF @summary_option='z'  
		BEGIN
			set @sqlStmt='create table '+ @tempTable+'( 
				sno int  identity(1,1),           
				[Counterparty] [varchar](100), 
				[Env Product] [varchar](100),       
				[Term] [varchar](300),            
				[Volume] float, 
				UOM [varchar](100) ,
				[Price] FLOAT,
				[Settlement (+Rec/-Pay)] float 
				)'
		END
		ELSE IF @summary_option='a'  
		BEGIN
			set @sqlStmt='create table '+ @tempTable+'( 
				sno int  identity(1,1),				            
				[Assignment] [varchar](300),
				[Technology] [varchar](100),               
				[Env Product] [varchar](300),  
				[jurisdiction] [varchar] (250)  ,          
				[Deal Date] [varchar](100),   
				[Volume] float,            
				[Total Volume] float ,
				[UOM] [varchar](50)
				)'
		END
		ELSE IF @summary_option='p'  
		BEGIN
			set @sqlStmt='create table '+ @tempTable+'( 
				sno int  identity(1,1),				            
				[ID] [varchar](200),
				[Counterparty] [varchar](100),               
				[Term Start] [varchar](300),  
				[Term End] [varchar] (250)  ,          
				[Leg] [varchar](100),   
				[Buy/Sell] float,            
				[Env Product] float ,
				[Type] [varchar](50),
				[Exercise Type] [varchar](100),
				[Volume] float,
				[UOM] [varchar](50),
				[Premium] [varchar](100),
				[strike][varchar](100),
				[Currency][varchar](100)
				)'
		END
		ELSE IF @summary_option='b'  
		BEGIN
			set @sqlStmt='create table '+ @tempTable+'( 
				sno int  identity(1,1),				            
				[Activity Year] [varchar](200),
				[Env Product] [varchar](100),  
				[Assignment] [varchar](100),               
				[Jurisdiction] [varchar](300),  
				[Volume] [varchar] (250)  ,          
				[Bonus] [varchar](100),   
				[Total Volume] float,
				[UOM] [varchar](50)
				)'
		END

		ELSE IF @summary_option='e'  
		BEGIN
			set @sqlStmt='create table '+ @tempTable+'( 
				sno int  identity(1,1),				            
				[Expiration] [varchar](200),
				[Env Product] [varchar](100),  
				[Assignment] [varchar](100),               
				[Jurisdiction] [varchar](300),  
				[Volume] [varchar] (250)  ,          
				[Bonus] [varchar](100),   
				[Total Volume] float,
				[UOM] [varchar](50)
				)'
		END
	END 
	ELSE
	BEGIN
		IF @summary_option='s'
		BEGIN 
			set @sqlStmt='create table '+ @tempTable+'( 
				sno int  identity(1,1),
				[technology] [varchar] (100)  ,
				[jurisdiction] [varchar] (250)  ,
				[Assignment] [varchar] (100) ,
				[Env Product] [varchar] (50) ,
				[Expiration] [varchar](50),
				[volume] [float] NULL ,
				[Bonus] [float] NULL,
				[Total Volume] [float] NULL,
				[UOM] [varchar] (50)
				)'
		END 
		ELSE IF @summary_option='t' OR @summary_option='c'
		BEGIN
			set @sqlStmt='create table '+ @tempTable+'( 
				sno int  identity(1,1),'+
				@trader_or_counterparty_t+' ,           
				[Technology] [varchar](100),'+            
				@counterparty_t+'               
				[Deal Date] [varchar](100),            
				[BuySell][varchar](100),               
				[Jurisdiction] [varchar](500),             
				[Env Product] [varchar](100),            
				[Volume] float,'+@bonus_t+					  
				@total_vol_t+'            
				UOM [varchar](100) ,
				[Price] FLOAT,
				[Settlement (+Rec/-Pay)] float 
				)'
		END
		ELSE IF @summary_option='g' OR @summary_option='h' OR  @summary_option='i'
		
		BEGIN
		--select @summary_option
			if @summary_option='i'
			set @strTable='[Generator/Credit Source Group] [varchar](100),'
			
			set @sqlStmt='create table '+ @tempTable+'( 
				sno int  identity(1,1),'+@strTable+'
				[Generator/Credit Source] [varchar](300) ,           
				[Technology] [varchar](100),            
				[Assignment] [varchar](300),               
				[Jurisdiction] [varchar](500), 			  
				[Env Product] [varchar](100),            
				[Expiration] [varchar](100),   
				[Volume] float,
				[Bonus] float,            
				[Total Volume] float ,
				[UOM] [varchar](50)
				)'
		END
		ELSE IF @summary_option='y'
		BEGIN
			set @sqlStmt='create table '+ @tempTable+'( 
				sno int  identity(1,1),
				[Generator/Credit Source] [varchar](300) ,           
				[Technology] [varchar](100),            
				[Assignment] [varchar](300),               
				[Jurisdiction] [varchar](500), 			  
				[Env Product] [varchar](100),            
				[Vintage Year] [varchar](100),   
				[Volume] float, 
				[Bonus] float,           
				[Total Volume] float ,
				[UOM] [varchar](50)
				)'
		END
		ELSE IF @summary_option='z'  
		BEGIN
			set @sqlStmt='create table '+ @tempTable+'( 
				sno int  identity(1,1),           
				[Counterparty] [varchar](100), 
				[Env Product] [varchar](100),       
				[Term] [varchar](300),            
				[Volume] float, 
				UOM [varchar](100) ,
				[Price] FLOAT,
				[Settlement (+Rec/-Pay)] float 
				)'
		END
		ELSE IF @summary_option='a'  
		BEGIN
			set @sqlStmt='create table '+ @tempTable+'( 
				sno int  identity(1,1),				            
				[Assignment] [varchar](300),
				[Technology] [varchar](100),               
				[Env Product] [varchar](300),  
				[jurisdiction] [varchar] (250)  ,          
				[Expiration] [varchar](100),   
				[Volume] float, 
				[Bonus]float,           
				[Total Volume] float ,
				[UOM] [varchar](50)
				)'
		END
		ELSE IF @summary_option='o'  
		BEGIN
			set @sqlStmt='create table '+ @tempTable+'( 
				sno int  identity(1,1),
				[Env Product] [varchar](300), 
				[Term] [varchar](300),  
				[Volume] float, 
				[Bonus]float, 
				[Total Volume] float ,
				[UOM] [varchar](50) 
				)'
		END
		ELSE IF @summary_option='v'  
		BEGIN
			set @sqlStmt='create table '+ @tempTable+'( 
				sno int  identity(1,1),
				[Trader] [varchar](300), 	
				[Env Product] [varchar](300), 
				[Term] [varchar](300),  
				[Volume] float, 
				[Bonus]float, 
				[Total Volume] float ,
				[UOM] [varchar](50),
				[Price] float,  
				[Settlement (+Rec/-Pay)] float 
				)'
		END		
			
	END

	exec(@sqlStmt)


	set @sqlStmt=' insert  '+@tempTable+ '
	exec spa_get_rec_activity_report ' + 
	dbo.FNASingleQuote(@as_of_date) +',' +	
	dbo.FNASingleQuote(@sub_entity_id) +',' +	
	dbo.FNASingleQuote(@strategy_entity_id) +',' +	
	dbo.FNASingleQuote(@book_entity_id) +',' +	
	isnull(cast(@report_type as varchar), 'null')  +',' +	
	dbo.FNASingleQuote(@summary_option) +',' +	
	isnull(cast(@compliance_year as varchar), 'null')  +',' +	
	isnull(cast(@assigned_state as varchar), 'null' ) +',' +	
	isnull(cast(@curve_id as varchar), 'null')  +',' +	
	isnull(cast(@generator_id as varchar), 'null')  +',' +	
	isnull(cast(@convert_uom_id as varchar), 'null')  +',' +	
	isnull(cast(@convert_assignment_type_id as varchar), 'null')  +',' +	
	isnull(cast(@deal_id_from as varchar), 'null')  +',' +	
	isnull(cast(@deal_id_to as varchar), 'null')  +',' +	
	dbo.FNASingleQuote(@gis_cert_number) +',' +	
	dbo.FNASingleQuote(@gis_cert_number_to) +',' +	
	dbo.FNASingleQuote(@gen_date_from) +',' +	
	dbo.FNASingleQuote(@gen_date_to) +',' +	
	dbo.FNASingleQuote(@deal_date_from) +',' +	
	dbo.FNASingleQuote(@deal_date_to) +',' +	
	isnull(cast(@technology as varchar), 'null')  +',' +	
	dbo.FNASingleQuote(@buy_sell_flag) +',' +	
	isnull(cast(@status_id as varchar), 'null')  +',' +	
	isnull(cast(@gis_id as varchar), 'null')  +',' +	
	isnull(cast(@counterparty_id as varchar), 'null')  +',' +	
	isnull(cast(@deal_type as varchar), 'null')  +',' +	
	isnull(cast(@to_be_assigned_type as varchar), 'null' ) +',' +	
	isnull(cast(@deal_sub_type as varchar), 'null')  +',' +	
	isnull(cast(@generation_state as varchar), 'null')  +',' +
	isnull(cast(@include_inventory as varchar), 'null')  +',' +
	dbo.FNASingleQuote(@drill_Counterparty) +',' +	
	dbo.FNASingleQuote(@drill_Technology) +',' +	
	dbo.FNASingleQuote(@drill_DealDate) +',' +	
	dbo.FNASingleQuote(@drill_BuySell) +',' +	
	dbo.FNASingleQuote(@drill_State) +',' +	
	dbo.FNASingleQuote(@drill_oblication) +',' +	
	dbo.FNASingleQuote(@drill_UOM) +',' +	
	dbo.FNASingleQuote(@drill_trader) +',' +	
	dbo.FNASingleQuote(@drill_Generator) +',' +	
	dbo.FNASingleQuote(@drill_Assignment) +',' +	
	dbo.FNASingleQuote(@drill_Expiration) +',' +
		
	dbo.FNASingleQuote(@Target_report) +',' +	
	dbo.FNASingleQuote(@Plot) +',' +	
	dbo.FNASingleQuote(@included_banked) +',' +	
	dbo.FNASingleQuote(@program_scope) +',' +	
	dbo.FNASingleQuote(@program_type) +',' +
	dbo.FNASingleQuote(@round_value) +',' +
	'NULL,NULL,NULL,NULL,'+
	dbo.FNASingleQuote(@include_expired) +',' +
	dbo.FNASingleQuote(@expiration_from) +',' +
	dbo.FNASingleQuote(@expiration_to)

	exec spa_print @sqlStmt	
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
	IF @Target_report='t'
	BEGIN 
		IF @summary_option='s'
		BEGIN 
			set @sqlStmt='select 
				[technology]  ,
				[jurisdiction]  ,
				[Assignment] ,
				[Env Product] ,
				[Deal Date],
				[volume],
				[UOM]
			  from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) + ' order by sno asc'
				exec(@sqlStmt)
		END 
		ELSE IF @summary_option='t' OR  @summary_option='c'
		BEGIN 
			set @sqlStmt='select '+
				@trader_or_counterparty_c+',           
				[Technology] ,'+            
				@counterparty_c+'               
				[Deal Date],            
				[BuySell],               
				[Jurisdiction],             
				[Env Product],            
				[Volume],'+   
				@total_vol_c+'            
				UOM ,
				[Price],
				[Settlement (+Rec/-Pay)] 
			  from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) + ' order by sno asc'
				exec(@sqlStmt)
		END 
		ELSE IF @summary_option='g' OR @summary_option='h' OR @summary_option='i'
		BEGIN
			IF @summary_option='i'
				SET @strCol=@strCol+'[Generator/Credit Source Group],'
				
			set @sqlStmt='select '+@strCol+'
				[Generator/Credit Source],           
				[Technology],            
				[Assignment] ,               
				[Jurisdiction], 			  
				[Env Product],            
				[Deal Date],   
				[Volume] ,            
				[Total Volume] ,
				[UOM] 
			  from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) + ' order by sno asc'
				exec(@sqlStmt)
		END
		ELSE IF @summary_option='y'
		BEGIN
			set @sqlStmt='select 
				[Generator/Credit Source],           
				[Technology],            
				[Assignment] ,               
				[Jurisdiction], 			  
				[Env Product],            
				[Vintage Year],   
				[Volume] ,            
				[Total Volume] ,
				[UOM] 
			  from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) + ' order by sno asc'
				exec(@sqlStmt)
		END
		ELSE IF @summary_option='o' 
		BEGIN
			set @sqlStmt='select 
				[Env Product] ,            
				[Term] ,   
				[Volume] ,            
				[Total Volume]  ,
				[UOM] 
			  from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) + ' order by sno asc'
				exec(@sqlStmt)
		END
		ELSE IF @summary_option='v'
		BEGIN
			set @sqlStmt='select 
				[Trader] , 
				[Env Product],       
				[Term],            
				[Volume] , 
				[Total Volume] ,      
				UOM ,
				[Price],
				[Settlement (+Rec/-Pay)]
			  from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) + ' order by sno asc'
				exec(@sqlStmt)
		END
		ELSE IF @summary_option='z'
		BEGIN
			set @sqlStmt='select 
				[Counterparty] , 
				[Env Product],       
				[Term],            
				[Volume] , 
				UOM ,
				[Price],
				[Settlement (+Rec/-Pay)]
			  from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) + ' order by sno asc'
				exec(@sqlStmt)
		END
		ELSE IF @summary_option='a'
		BEGIN
			set @sqlStmt='select 
				[Assignment],
				[Technology] ,               
				[Env Product],  
				[jurisdiction],          
				[Deal Date],   
				[Volume],            
				[Total Volume],
				[UOM]
			  from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) + ' order by sno asc'
				exec(@sqlStmt)
		END
		ELSE IF @summary_option='p'
		BEGIN
			set @sqlStmt='select 
				[ID],
				[Counterparty],               
				[Term Start],  
				[Term End],          
				[Leg],   
				[Buy/Sell],            
				[Env Product],
				[Type],
				[Exercise Type],
				[Volume],
				[UOM],
				[Premium],
				[strike],
				[Currency]
			  from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) + ' order by sno asc'
				exec(@sqlStmt)
		END
		ELSE IF @summary_option='b'
		BEGIN
			set @sqlStmt='select 
				[Activity Year],
				[Env Product],
				[Assignment],               
				[Jurisdiction],  
				[Volume],          
				[Bonus],   
				[Total Volume] ,
				[UOM]
			  from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) + ' order by sno asc'
				exec(@sqlStmt)
		END
		ELSE IF @summary_option='e'
		BEGIN
			set @sqlStmt='select 
				[Expiration],
				[Env Product],
				[Assignment],               
				[Jurisdiction],  
				[Volume],          
				[Bonus],   
				[Total Volume] ,
				[UOM]
			  from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) + ' order by sno asc'
				exec(@sqlStmt)
		END
	END 
	ELSE 
	BEGIN 
		IF @summary_option='s'
		BEGIN 	
			set @sqlStmt='select 
				[Technology] ,
				[Jurisdiction]  ,
				[Assignment] ,
				[Env Product] ,
				[Expiration],
				[volume],
				[Bonus] ,
				[Total Volume],
				[UOM]
			  from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) + ' order by sno asc'
				exec(@sqlStmt)
		END 
		ELSE IF @summary_option='t' OR  @summary_option='c'
		BEGIN 
			set @sqlStmt='select '+
				@trader_or_counterparty_c+',           
				[Technology] ,'+            
				@counterparty_c+'               
				[Deal Date],            
				[BuySell],               
				[Jurisdiction],             
				[Env Product],            
				[Volume],'+ @bonus_c +   
				@total_vol_c+'            
				UOM ,
				[Price],
				[Settlement (+Rec/-Pay)] 
			  from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) + ' order by sno asc'
			exec(@sqlStmt)
			EXEC spa_print @sqlStmt
		END 
		ELSE IF @summary_option='g' OR @summary_option='h' OR @summary_option='i'
		BEGIN
			IF @summary_option='i'
				SET @strCol=@strCol+'[Generator/Credit Source Group],'
				
			set @sqlStmt='select '+@strCol+'
				[Generator/Credit Source],           
				[Technology],            
				[Assignment] ,               
				[Jurisdiction], 			  
				[Env Product],            
				[Expiration],   
				[Volume] ,
				[Bonus],            
				[Total Volume] ,
				[UOM] 
			  from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) + ' order by sno asc'
				exec(@sqlStmt)
		END
		ELSE IF @summary_option='y'
		BEGIN
			set @sqlStmt='select 
				[Generator/Credit Source],           
				[Technology],            
				[Assignment] ,               
				[Jurisdiction], 			  
				[Env Product],            
				[Vintage Year],   
				[Volume] ,[Bonus],            
				[Total Volume] ,
				[UOM] 
			  from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) + ' order by sno asc'
				exec(@sqlStmt)
		END
		ELSE IF @summary_option='z'
		BEGIN
			set @sqlStmt='select 
				[Counterparty] , 
				[Env Product],       
				[Term],            
				[Volume] , 
				UOM ,
				[Price],
				[Settlement (+Rec/-Pay)]
			  from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) + ' order by sno asc'
				exec(@sqlStmt)
		END
		ELSE IF @summary_option='a'
		BEGIN
			set @sqlStmt='select 
				[Assignment],
				[Technology] ,               
				[Env Product],  
				[jurisdiction],          
				[Expiration],   
				[Volume], 
				[Bonus],           
				[Total Volume],
				[UOM]
			  from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) + ' order by sno asc'
				exec(@sqlStmt)
		END
		ELSE IF @summary_option='o'  
		BEGIN
			set @sqlStmt='select 
				[Env Product],
				[Term] ,               
				[Volume],  
				[Bonus],          
				[Total Volume],   
				[UOM]
			  from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) + ' order by sno asc'
				exec(@sqlStmt)
		END
		ELSE IF @summary_option='v'  
		BEGIN
			set @sqlStmt='select
				[Trader], 
				[Env Product],
				[Term] ,               
				[Volume],  
				[Bonus],          
				[Total Volume],   
				[UOM],[Price],[Settlement (+Rec/-Pay)]
			  from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) + ' order by sno asc'
				exec(@sqlStmt)
		END		
	END 
end

*/
