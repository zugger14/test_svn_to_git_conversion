/****** Object:  StoredProcedure [dbo].[spa_create_power_position_report_Paging]    Script Date: 07/28/2009 18:02:05 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_create_power_position_report_Paging]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_create_power_position_report_Paging]
/****** Object:  StoredProcedure [dbo].[spa_create_power_position_report_Paging]    Script Date: 07/28/2009 18:02:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--  exec spa_Create_Position_Report '2006-12-31', '1', '215', '216', 'm', '4', 'a', 301, 319, -3, -4
CREATE PROC [dbo].[spa_create_power_position_report_Paging]
	 @summary_option CHAR(1)=null,-- 's' Summary, 'd' Detail
	 @group_by CHAR(1)=null,-- 'l'->location 'i'->index 'n'->None
 	 @sub_entity_id VARCHAR(100),             		
	 @strategy_entity_id VARCHAR(100) = NULL,             
	 @book_entity_id VARCHAR(100) = NULL,         
	 @as_of_date DATETIME,
	 @term_start VARCHAR(100)=null,
	 @term_end VARCHAR(100)=null,
	 @granularity INT,	
	 @counterparty INT=NULL, 
	 @commodity INT=NULL,
	 @source_system_book_id1 INT=NULL, 
	 @source_system_book_id2 INT=NULL, 
	 @source_system_book_id3 INT=NULL, 
	 @source_system_book_id4 INT=NULL,
	 @source_deal_header_id VARCHAR(50)=null,
	 @deal_id VARCHAR(50)=null,
	 @hour_from INT=NULL,
	 @hour_to INT=NULL,
	 @location_id VARCHAR(100)=NULL,
	 @show_generation CHAR(1)='y',
	 @show_outage CHAR(1)='y',
	 @show_load CHAR(1)='y',
	 @show_bilateral CHAR(1)='y',
	 @process_table VARCHAR(100)=NULL, 	
	 @drill_index VARCHAR(100)=NULL,
	 @drill_term VARCHAR(100)=NULL,
	 @drill_hour VARCHAR(10)=NULL,
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
	set @tempTable=dbo.FNAProcessTableName('paging_temp_Position_Report', @user_login_id,@process_id)
	declare @sqlStmt varchar(5000)

--Sub Strategy Book Counterparty DealNumber DealDate PNLDate Type Phy/Fin Expiration Cumulative FV 

if @flag='i'
begin
--if @summary_option='s'
	set @sqlStmt='create table '+ @tempTable+'( 
		sno int  identity(1,1),
		Location varchar(500),
		Term varchar(500),
		Hour varchar(500),
		'+CASE WHEN @show_generation='y' THEN 'GenerationVolume varchar(500),' ELSE '' END+'
		'+CASE WHEN @show_outage='y' THEN 'Outage varchar(500),' ELSE '' END+'
		'+CASE WHEN @show_load='y' THEN 'LoadForecast varchar(500),' ELSE '' END+'
		'+CASE WHEN @show_bilateral='y' THEN 'BilateralVolume varchar(100),' ELSE '' END+'
		TotalVolume varchar(100),
		UOM varchar(100)
		)'
		exec(@sqlStmt)

	set @sqlStmt=' insert  '+@tempTable+'
	exec  spa_create_power_position_report '+ 
	dbo.FNASingleQuote(@summary_option) +','+ 
	dbo.FNASingleQuote(@group_by) +','+ 
	dbo.FNASingleQuote(@sub_entity_id) +','+ 
	dbo.FNASingleQuote(@strategy_entity_id) +','+ 
	dbo.FNASingleQuote(@book_entity_id) +',' +
	dbo.FNASingleQuote(@as_of_date) +',' +
	dbo.FNASingleQuote(@term_start) +',' +
	dbo.FNASingleQuote(@term_end)+',' +
	dbo.FNASingleQuote(@granularity)+','+
	dbo.FNASingleQuote(@counterparty)+','+
	dbo.FNASingleQuote(@commodity)+','+
	dbo.FNASingleQuote(@source_system_book_id1) +','+
	dbo.FNASingleQuote(@source_system_book_id2) +','+
	dbo.FNASingleQuote(@source_system_book_id3) +','+
	dbo.FNASingleQuote(@source_system_book_id4)+','+
	dbo.FNASingleQuote(@source_deal_header_id)+','+
	dbo.FNASingleQuote(@deal_id)+','+ 
	dbo.FNASingleQuote(@hour_from)+','+ 
	dbo.FNASingleQuote(@hour_to)+','+ 
	dbo.FNASingleQuote(@location_id)+','+ 
	dbo.FNASingleQuote(@show_generation)+','+ 
	dbo.FNASingleQuote(@show_outage)+','+ 
	dbo.FNASingleQuote(@show_load)+','+ 
	dbo.FNASingleQuote(@show_bilateral)+','+ 	
	dbo.FNASingleQuote(@process_table)+','+ 
	dbo.FNASingleQuote(@drill_index)+','+ 
	dbo.FNASingleQuote(@drill_term)+','+ 
	dbo.FNASingleQuote(@drill_hour)

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
		set @sqlStmt='select 
		Location ,Term,Hour,
		'+CASE WHEN @show_generation='y' THEN 'GenerationVolume ,' ELSE '' END+'
		'+CASE WHEN @show_outage='y' THEN 'Outage, ' ELSE '' END+'
		'+CASE WHEN @show_load='y' THEN 'LoadForecast, ' ELSE '' END+'
		'+CASE WHEN @show_bilateral='y' THEN 'BilateralVolume,' ELSE '' END+'
			TotalVolume,UOM	
	   from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar)+ ' order by sno asc'

		EXEC spa_print @sqlStmt
		exec(@sqlStmt)






























