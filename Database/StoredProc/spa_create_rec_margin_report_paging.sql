/****** Object:  StoredProcedure [dbo].[spa_create_rec_margin_report_paging]    Script Date: 06/25/2009 14:48:00 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_create_rec_margin_report_paging]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_create_rec_margin_report_paging]
GO 
/****** Object:  StoredProcedure [dbo].[spa_create_rec_margin_report_paging]    Script Date: 06/25/2009 14:21:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC spa_create_rec_margin_report '95', null, null, '2006-06-01', '2006-06-30', null, null, null, null, 'd', 'PSCO', '06/30/2006', '05/01/2006', 'ABC Company', null

CREATE   PROC [dbo].[spa_create_rec_margin_report_paging]
		@sub_entity_id varchar(100)=null, 
		@strategy_entity_id varchar(100) = NULL, 
		@book_entity_id varchar(100) = NULL, 		
		@as_of_date_from varchar(20),
		@as_of_date_to varchar(20) = null,
		@counterparty_id int = null,
		@trader_id int = null,
		@technology int = null,
		@generator_id int = null,
		@summary_option varchar(1) = 's', --s summary, d detail, t for trader margin
		@drill_sub varchar(100)=null,
		@drill_as_of_date varchar(20)=null,
		@drill_production_month varchar(20)=null,
		@drill_counterparty varchar(100)=null,
		@trader varchar(100)=null,
		@round_value char(1) = '0',
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
	set @tempTable=dbo.FNAProcessTableName('paging_temp_REC_margin_Report_Drill', @user_login_id,@process_id)
	declare @sqlStmt varchar(5000)

if @flag='i'
begin
	IF @summary_option = 'd'
	BEGIN 
			set @sqlStmt='create table '+ @tempTable+'( 
			sno int  identity(1,1),
			Sub varchar(100),
			Strategy VARCHAR(100),
			Book varchar(100),
			[As of Date] varchar(100), 
			[Production Month] varchar(100),
			Counterparty varchar(100),
			Trader varchar(100),
			[Sale Deal ID] varchar(1000),
			[Cost Transaction ID] varchar(1000),
			[Deal Date] varchar(100),
			[Gen Date] varchar(100),
			Volume varchar(100),
			Unit varchar(100), 
			Frequency varchar(100),
			Revenue varchar(100),
			Cost varchar(100), 
			Margin varchar(100)
		)'
	END 
	ELSE
	BEGIN
			set @sqlStmt='create table '+ @tempTable+'( 
			sno int  identity(1,1),
			Sub varchar(100),
			[As of Date] varchar(100), 
			[Production Month] varchar(100), 
			Counterparty varchar(100),
			Volume varchar(100),
			Unit varchar(100),
			Frequency varchar(100),
			Revenue varchar(100),
			Cost varchar(100),
			Margin varchar(100))'
	END
	
	exec(@sqlStmt)

	set @sqlStmt=' insert  '+@tempTable+ '
	exec spa_create_rec_margin_report ' + 
	dbo.FNASingleQuote(@sub_entity_id) +',' +	
	dbo.FNASingleQuote(@strategy_entity_id) +',' +	
	dbo.FNASingleQuote(@book_entity_id) +',' +	
	dbo.FNASingleQuote(@as_of_date_from) +',' +	
	dbo.FNASingleQuote(@as_of_date_to) +',' +	
	isnull(cast(@counterparty_id as varchar), 'null')  +',' +	
	isnull(cast(@trader_id as varchar), 'null')  +',' +	
	isnull(cast(@technology as varchar), 'null')  +',' +	
	isnull(cast(@generator_id as varchar), 'null')  +',' +	
	dbo.FNASingleQuote(@summary_option) +',' +	
	dbo.FNASingleQuote(@drill_sub) +',' +	
	dbo.FNASingleQuote(@drill_as_of_date) +',' +	
	dbo.FNASingleQuote(@drill_production_month) +',' +	
	dbo.FNASingleQuote(@drill_counterparty) +',' +	
	dbo.FNASingleQuote(@trader) 

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
	IF @summary_option = 'd'
	BEGIN 
		set @sqlStmt='select 
			Sub ,
			Strategy ,
			Book ,
			[As of Date] , 
			[Production Month] ,
			Counterparty  ,
			Trader ,
			[Sale Deal ID] ,
			[Cost Transaction ID] ,
			[Deal Date] ,
			[Gen Date] ,
			Volume ,
			Unit , 
			Frequency ,
			Revenue ,
			Cost , 
			Margin 
		  from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) + ' order by sno asc'
	END
	ELSE 
	BEGIN
		set @sqlStmt='select 
			Sub,[As of Date] , [Production Month] , Counterparty ,
			 Volume , Unit , Frequency ,	Revenue , Cost , Margin 
		  from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) + ' order by sno asc'
	END 		
	
	exec(@sqlStmt)
end















