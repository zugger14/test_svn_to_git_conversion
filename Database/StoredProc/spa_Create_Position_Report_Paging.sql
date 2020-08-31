IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_Create_Position_Report_Paging]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_Create_Position_Report_Paging]

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go




--  exec spa_Create_Position_Report '2006-12-31', '1', '215', '216', 'm', '4', 'a', 301, 319, -3, -4
CREATE PROC [dbo].[spa_Create_Position_Report_Paging]
	@as_of_date varchar(50), 
	@sub_entity_id varchar(100), 
	@strategy_entity_id varchar(100) = NULL, 
	@book_entity_id varchar(100) = NULL, 
	@summary_option char(1), --'m' - By Month 'q' - By quater,'s' - By semiannual,'a' - By Annual, 'r' - Deal Summary, 'd' - Deal detail
	@convert_unit_id int,
	@settlement_option char(1) = 'f', 
	@source_system_book_id1 int=NULL, 
	@source_system_book_id2 int=NULL, 
	@source_system_book_id3 int=NULL, 
	@source_system_book_id4 int=NULL,
	@transaction_type VARCHAR(100)=null,
	@source_deal_header_id varchar(50)=null,
	@deal_id varchar(50)=null,
	@as_of_date_from varchar(50)=null, 
	@options CHAR(1)='n',
	@drill_index VARCHAR(100)=NULL,
	@drill_contractmonth VARCHAR(100)=NULL,
	@major_location varchar(250)= NULL,
	@minor_location varchar(250) = NULL,
	@index varchar(MAX) = NULL,
	@commodity_id int=NULL,
--	@sub_type CHAR(1)='b', --'b' both, 'f' forward,'s' spot
	@sub_type INT = NULL,
	@group_by CHAR(1)='i',-- 'i'-index,'l'-location
	@physical_financial_flag CHAR(1)='b',	--'b' both, 'p' physical, 'f' financial
	@deal_type INT=NULL,
	@trader_id INT=NULL,
	@tenor_from VARCHAR(20)=NULL,
	@tenor_to VARCHAR(20)=NULL,
	@show_cross_tabformat CHAR(1)='n',
	@deal_process_id VARCHAR(100)=NULL,
	@deal_status int = NULL,
	@round_value char(1) = '0',
	@book_transfer CHAR(1) = 'n',
	@counterparty_id VARCHAR(MAX) =NULL,
	@show_per char(1) = NULL,
	@match char(1) = 'n',
	--Added
	@drill_VolumeUOM varchar(20) = NULL,
	@buySell_flag char(1)=NULL,
	@show_hedgeVolume char(1)='n',
	@to_uom_id	INT	= NULL,
	@book_map_entity_id	VARCHAR(200) = NULL,
	@deal_list_table    VARCHAR(100) = NULL,
	----
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

--Sub Strategy Book Counterparty DealNumber DealDate PNLDate Type Phy/Fin Expiration Cumulative FV 

IF @flag='i'
BEGIN
	IF @summary_option = 'r'
		SET @sqlStmt='create table '+ @tempTable+'( 
			sno int  identity(1,1),
			Subsidiary varchar(500),
			Strategy varchar(500),
			Book varchar(500),
			IndexName varchar(500),
			DealId varchar(500),
			DealDate varchar(20),
			Term varchar(100),		
			Volume numeric(30,14),
			PerAvailable varchar(100),
			VolumeAvailable numeric(30,14),
			price  numeric(30,0),
			VolumeFrequency varchar(500),
			VolumeUOM varchar(500)
			)'
	ELSE
		SET @sqlStmt='create table '+ @tempTable+'( 
			sno int  identity(1,1),
			Subsidiary varchar(500),
			Strategy varchar(500),
			Book varchar(500),
			IndexName varchar(500),
			DealId varchar(500),
			ContractMonth varchar(500),
			Volume numeric(30,14),
			PerAvailable varchar(100),
			VolumeAvailable numeric(30,14),
			VolumeFrequency varchar(500),
			VolumeUOM varchar(500)
			)'

			
	EXEC(@sqlStmt)
	
	SET @sqlStmt=' insert  '+@tempTable+'
	exec  spa_Create_Position_Report '+ 
	dbo.FNASingleQuote(@as_of_date) +','+ 
	dbo.FNASingleQuote(@sub_entity_id) +','+ 
	dbo.FNASingleQuote(@strategy_entity_id) +','+ 
	dbo.FNASingleQuote(@book_entity_id) +','+ 
	dbo.FNASingleQuote(@summary_option) +',' +
	dbo.FNASingleQuote(@convert_unit_id) +',' +
	dbo.FNASingleQuote(@settlement_option) +',' +
	dbo.FNASingleQuote(@source_system_book_id1)+',' +
	dbo.FNASingleQuote(@source_system_book_id2)+','+
	dbo.FNASingleQuote(@source_system_book_id3)+','+
	dbo.FNASingleQuote(@source_system_book_id4)+','+
	dbo.FNASingleQuote(@transaction_type) +','+
	dbo.FNASingleQuote(@source_deal_header_id) +','+
	dbo.FNASingleQuote(@deal_id) +','+
	dbo.FNASingleQuote(@as_of_date_from)+','+
	dbo.FNASingleQuote(@options)+','+
	dbo.FNASingleQuote(@drill_index)+','+ 
	dbo.FNASingleQuote(@drill_contractmonth)+','+ 
	dbo.FNASingleQuote(@major_location)+','+ 
	dbo.FNASingleQuote(@minor_location)+','+ 
	dbo.FNASingleQuote(@index)+','+ 
	dbo.FNASingleQuote(@commodity_id) +','+ 
	dbo.FNASingleQuote(@sub_type)+','+ 
	dbo.FNASingleQuote(@group_by)+','+ 
	dbo.FNASingleQuote(@physical_financial_flag)+','+
	dbo.FNASingleQuote(@deal_type)+','+
	dbo.FNASingleQuote(@trader_id)+','+
	dbo.FNASingleQuote(@tenor_from)+','+
	dbo.FNASingleQuote(@tenor_to)+','+
	dbo.FNASingleQuote(@show_cross_tabformat)+','+
	dbo.FNASingleQuote(@deal_process_id)+','+
	dbo.FNASingleQuote(@deal_status)+','+
	dbo.FNASingleQuote(@round_value)+','+
	dbo.FNASingleQuote(@book_transfer)+','+
	dbo.FNASingleQuote(@counterparty_id)+','+
	dbo.FNASingleQuote(@show_per)+','+
	dbo.FNASingleQuote(@match)+','+
	dbo.FNASingleQuote(@drill_VolumeUOM)+','+
	dbo.FNASingleQuote(@buySell_flag)+','+
	dbo.FNASingleQuote(@show_hedgeVolume)+','+
	dbo.FNASingleQuote(@to_uom_id)+','+
	dbo.FNASingleQuote(@book_map_entity_id)+','+
	dbo.FNASingleQuote(@deal_list_table) + ',' +
	dbo.FNASingleQuote(@batch_process_id)+','+
	dbo.FNASingleQuote(@batch_report_param)

	EXEC spa_print @sqlStmt
	
	EXEC(@sqlStmt)	

	SET @sqlStmt='select count(*) TotalRow,'''+@process_id +''' process_id  from '+ @tempTable
	EXEC spa_print @sqlStmt
	EXEC(@sqlStmt)
END
ELSE
BEGIN
	DECLARE 
		@row_to INT
		,@row_from INT
		
	SET @row_to=@page_no * @page_size
	IF @page_no > 1 
		SET @row_from =((@page_no-1) * @page_size)+1
	ELSE
		SET @row_from =@page_no
END
	
IF @summary_option = 'r'	
	SET @sqlStmt='select 
				Subsidiary ,Strategy, Book,IndexName [Location/Index],DealId [Deal Id],DealDate [Deal Date],term [Term], Volume, PerAvailable [Percentage Available],
				VolumeAvailable [Volume Available],price [Price], VolumeFrequency [Volume Frequency] ,VolumeUOM  [Volume UOM]	
				from '+ @tempTable  
ELSE	
	SET @sqlStmt='select 
				Subsidiary ,Strategy, Book,IndexName [Location/Index],DealId [Deal Id] ,ContractMonth [Contract Month], Volume, PerAvailable [Percentage Available],
				VolumeAvailable [Volume Available],VolumeFrequency [Volume Frequency] ,VolumeUOM  [Volume UOM] from '+ @tempTable 

 SET @sqlStmt =  @sqlStmt + ' WHERE sno BETWEEN '+ CAST(@row_from AS VARCHAR) +' AND '+ CAST(@row_to AS VARCHAR)+ ' ORDER BY sno ASC'

EXEC spa_print @sqlStmt
EXEC(@sqlStmt)




























