/****** Object:  StoredProcedure [dbo].[spa_create_rec_margin_report_paging]    Script Date: 06/25/2009 14:48:00 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_ems_exceptions_report_paging]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_ems_exceptions_report_paging]
GO 
/****** Object:  StoredProcedure [dbo].[spa_create_rec_margin_report_paging]    Script Date: 06/25/2009 14:21:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC spa_create_rec_margin_report '95', null, null, '2006-06-01', '2006-06-30', null, null, null, null, 'd', 'PSCO', '06/30/2006', '05/01/2006', 'ABC Company', null

CREATE   PROC [dbo].[spa_ems_exceptions_report_paging]
			@report_type CHAR(1)='a',                --'a' Activity Data, 'f' Emissions factors
			@sub_entity_id varchar(500),     
			@strategy_entity_id varchar(500),     
			@book_entity_id varchar(500),             		
			@generator_id varchar(max) = null,            
			@technology int = null,             
			@generation_state int=null,
			@jurisdiction int=null,
			@generator_group varchar(100)=null	,
			@fuel_type int=null,
			@input_id int=null,	
			@term_start datetime =null,
			@term_end datetime =NULL,	
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
	set @tempTable=dbo.FNAProcessTableName('paging_temp_Exception_Report', @user_login_id,@process_id)
	declare @sqlStmt varchar(5000)

if @flag='i'
	begin
		IF @report_type='a'
			BEGIN
				set @sqlStmt='create table '+ @tempTable+'( 
				sno int  identity(1,1),
				OpCo varchar(100),
				[Source/Sink] VARCHAR(100),
				[External Facility ID] varchar(100),
				[Unit] varchar(100), 
				[Term] varchar(100),
				[Input] varchar(100)
				)'
			END
		ELSE
			BEGIN
				set @sqlStmt='create table '+ @tempTable+'( 
				sno INT  IDENTITY(1,1),
				[Source/Sink] VARCHAR(100),
				[SourceModel] VARCHAR(100),
				[Term] VARCHAR(100),
				[Formula] VARCHAR(max),
				[FormulaValue] VARCHAR(max)
				)'
			END
	 
	
	exec spa_print @sqlStmt
	EXEC(@sqlStmt)

	set @sqlStmt=' insert  '+@tempTable+ '
	exec spa_ems_exceptions_report ' + 
	dbo.FNASingleQuote(@report_type) +',' +	
	dbo.FNASingleQuote(@sub_entity_id) +',' +	
	dbo.FNASingleQuote(@strategy_entity_id) +',' +	
	dbo.FNASingleQuote(@book_entity_id) +',' +	
	dbo.FNASingleQuote(@generator_id) +',' +	
	isnull(cast(@technology as varchar), 'null')  +',' +	
	isnull(cast(@generation_state as varchar), 'null')  +',' +	
	isnull(cast(@jurisdiction as varchar), 'null')  +',' +	
	dbo.FNASingleQuote(@generator_group) +',' +
	isnull(cast(@fuel_type as varchar), 'null')  +',' +	
	isnull(cast(@input_id as varchar), 'null')  +',' +		
	dbo.FNASingleQuote(@term_start) +',' +	
	dbo.FNASingleQuote(@term_end)

	EXEC spa_print @sqlStmt 
 	EXEC(@sqlStmt)	


	--These are for drill down

	SET @sqlStmt='select count(*) TotalRow,'''+@process_id +''' process_id  from '+ @tempTable
	EXEC spa_print @sqlStmt
	EXEC(@sqlStmt)
END
ELSE
BEGIN
DECLARE @row_to INT,@row_from INT
SET @row_to=@page_no * @page_size
IF @page_no > 1 
SET @row_from =((@page_no-1) * @page_size)+1
ELSE
SET @row_from =@page_no
	IF @report_type='a'
		BEGIN
			SET @sqlStmt='select 
				OpCo ,
				[Source/Sink] ,
				[External Facility ID],
				[Unit], 
				[Term],
				[Input]
			  from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) + ' order by sno asc'
		END
	ELSE
		BEGIN
			SET @sqlStmt='select 
				[Source/Sink],
				[SourceModel],
				[Term],
				[Formula],
				[FormulaValue]
			from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) + ' order by sno asc'

		END
	EXEC(@sqlStmt)
END

