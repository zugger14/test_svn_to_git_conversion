IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_trader_Position_Report_paging]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_trader_Position_Report_paging]

GO

create PROC [dbo].[spa_trader_Position_Report_paging]
@as_of_date VARCHAR(50), 
@sub_entity_id VARCHAR(100), 
@strategy_entity_id VARCHAR(100) = NULL, 
@book_entity_id VARCHAR(100) = NULL, 
@summary_option CHAR(1), --'t'- term 'm' - By Month 'q' - By quater,'s' - By semiannual,'a' - By Annual, 'r' - Deal Summary, 'd' - Deal detail, 'i' - just by index
@CONVERT_unit_id INT,
@settlement_option CHAR(1) = 'f', 
@source_system_book_id1 INT=NULL, 
@source_system_book_id2 INT=NULL, 
@source_system_book_id3 INT=NULL, 
@source_system_book_id4 INT=NULL,
@transaction_type VARCHAR(100)=null,
@source_deal_header_id VARCHAR(50)=null,
@deal_id VARCHAR(50)=null,
--@as_of_date_from VARCHAR(50)=null, 
@options CHAR(1)='d',--'d'- include delta positions, 'n'-Do not include delta positions
@drill_index VARCHAR(100)=NULL,
@drill_contractmonth VARCHAR(100)=NULL,
@major_location VARCHAR(250)= NULL,
@minor_location VARCHAR(250) = NULL,
@index VARCHAR(250) = NULL,
@commodity_id INT=NULL,
@sub_type CHAR(1)='b', --'b' both, 'f' forward,'s' spot
@group_by CHAR(1)='i',-- 'i'-index,'l'-location
@physical_financial_flag CHAR(1)='b',	--'b' both, 'p' physical, 'f' financial
@deal_type INT=NULL,
@trader_id INT=NULL,
@tenor_from VARCHAR(20)=NULL,
@tenor_to VARCHAR(20)=NULL,
@show_cross_tabformat CHAR(1)='n',
@deal_process_id VARCHAR(100)=NULL,  --when call from Check Position in deal insert
@deal_status int = null,
@block_definition_id_on int=null,
@block_definition_id_off int=null,
@round_value char(1) = '0',
@curve_source_id  int = NULL,
@period INT=NULL,
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
	set @tempTable=dbo.FNAProcessTableName('paging_temp_Position_Report', @user_login_id,@process_id)
	declare @sqlStmt varchar(5000)

--source_deal_header_id int,
--		subsidiary varchar(500),
--		strategy varchar(500),
--		book varchar(500),
--		indexname varchar(500),
--		contractMonth varchar(500),
--		type varchar(500),
--		DealID varchar(500),
--		VolumeFrequency varchar(500),
--		VolumeUOM varchar(500),
--		deal_date varchar(500),
--		volume int,
--		term_start varchar(500),
--		term_end varchar(500),
--		price int,
--		location varchar(500)
if @flag='i'
begin
--if @summary_option='s'
	set @sqlStmt='create table '+ @tempTable+'( 
		sno int  identity(1,1),
		commodity varchar(500),
		peak_off varchar(500),
		IndexName varchar(500),
		Term varchar(500),
		Volume varchar(500),
		VolumeFrequency varchar(500),
		VolumeUOM varchar(500),
		actualTerm datetime,
		Physical_volume varchar(500),
		NetItemAmt varchar(500),
		load_volume varchar(500),
		load_cost varchar(500),
		Vol_equ varchar(500)
		
		)'
		exec(@sqlStmt)

	set @sqlStmt=' insert  '+@tempTable+'
	exec  spa_trader_Position_Report '+ 
	dbo.FNASingleQuote(@as_of_date) +','+  
	dbo.FNASingleQuote(@sub_entity_id) +','+ 
	dbo.FNASingleQuote(@strategy_entity_id)+','+ 
	dbo.FNASingleQuote(@book_entity_id)+','+ 
	dbo.FNASingleQuote(@summary_option)+','+ --'t'- term 'm' - By Month 'q' - By quater,'s' - By semiannual,'a' - By Annual, 'r' - Deal Summary, 'd' - Deal detail, 'i' - just by index
	dbo.FNASingleQuote(@CONVERT_unit_id)+','+
	dbo.FNASingleQuote(@settlement_option)+','+ 
	dbo.FNASingleQuote(@source_system_book_id1)+','+ 
	dbo.FNASingleQuote(@source_system_book_id2)+','+ 
	dbo.FNASingleQuote(@source_system_book_id3)+','+ 
	dbo.FNASingleQuote(@source_system_book_id4)+','+ 
	dbo.FNASingleQuote(@transaction_type)+','+ 
	dbo.FNASingleQuote(@source_deal_header_id)+','+ 
	dbo.FNASingleQuote(@deal_id)+','+ 
	--@as_of_date_from VARCHAR(50)=null, 
	dbo.FNASingleQuote(@options)+','+ --'d'- include delta positions, 'n'-Do not include delta positions
	dbo.FNASingleQuote(@drill_index)+','+ 
	dbo.FNASingleQuote(@drill_contractmonth)+','+ 
	dbo.FNASingleQuote(@major_location)+','+ 
	dbo.FNASingleQuote(@minor_location)+','+ 
	dbo.FNASingleQuote(@index)+','+ 
	dbo.FNASingleQuote(@commodity_id)+','+ 
	dbo.FNASingleQuote(@sub_type)+','+  --'b' both, 'f' forward,'s' spot
	dbo.FNASingleQuote(@group_by)+','+ -- 'i'-index,'l'-location
	dbo.FNASingleQuote(@physical_financial_flag)+','+ 	--'b' both, 'p' physical, 'f' financial
	dbo.FNASingleQuote(@deal_type)+','+ 
	dbo.FNASingleQuote(@trader_id)+','+ 
	dbo.FNASingleQuote(@tenor_from)+','+ 
	dbo.FNASingleQuote(@tenor_to)+','+ 
	dbo.FNASingleQuote(@show_cross_tabformat)+','+ 
	dbo.FNASingleQuote(@deal_process_id)+','+   --when call from Check Position in deal insert
	dbo.FNASingleQuote(@deal_status)+','+ 
	dbo.FNASingleQuote(@block_definition_id_on)+','+ 
	dbo.FNASingleQuote(@block_definition_id_off)+','+ 
	dbo.FNASingleQuote(@round_value)+','+
	dbo.FNASingleQuote(@curve_source_id)+','+
	dbo.FNASingleQuote(@period)+','+
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
--		set @sqlStmt='select 
--source_deal_header_id,subsidiary,strategy,book,indexname,contractMonth,type,DealID,VolumeFrequency,
--VolumeUOM,deal_date,volume,term_start,term_end,price,location 

set @sqlStmt='select
commodity as [Commodity],peak_off as [Offpeak] ,IndexName as [Index Name],
Term ,Volume ,VolumeFrequency as [Volume Frequency] ,
VolumeUOM as [Volume UOM],actualTerm as[Actual Term] ,Physical_volume as [Physical Volume] ,
NetItemAmt as [Net Item Amount] ,load_volume as [Load Volume] ,load_cost as [Load Cost],
Vol_equ  as [Volume Equ]
	
	   from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar)+ ' order by sno asc'

		EXEC spa_print @sqlStmt
		exec(@sqlStmt)