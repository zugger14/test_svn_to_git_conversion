IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_Create_MTM_Period_Report_paging]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_Create_MTM_Period_Report_paging]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

--exec spa_Create_MTM_Period_Report '2004-12-31', '291,30,1,257,258,256', NULL, NULL, 'u', 'a', 'a', 'l',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'n',NULL,NULL,NULL,NULL,NULL,'n','n','y','n','2','a','m','n',NULL

-- exec spa_Create_MTM_Period_Report '2006-12-31', '1,30', NULL, NULL, 'u', 'a', 'a', 'd',NULL,NULL,NULL,NULL,NULL,NULL,-1,-2,-3,-4,'n',400
--exec spa_Create_MTM_Period_Report '2004-12-31', '30', '208', '223', 'u', 'a', 'a', 'd',NULL,NULL,NULL,'2001-01-01',NULL,NULL,
--NULL,NULL,NULL,NULL,'y',NULL,NULL,NULL,NULL,NULL,'n','n','y'

-- exec spa_Create_MTM_Period_Report '2007-09-30', '9,15,3', '10,13,16,24,18,26,22,20,4', '12,11,14,17,25,27,23,21,5,6,8,7', 'd', 'a', 'm', 'd',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'n',NULL,NULL,NULL,NULL,NULL,'n','n','n','n'
-- exec spa_Create_MTM_Period_Report '2007-09-30', '9,15,3', '10,13,16,24,18,26,22,20,4', '12,11,14,17,25,27,23,21,5,6,8,7', 'd', 'a', 'm', 'd',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'y',NULL,NULL,NULL,NULL,NULL,'n','n','y'

-- exec spa_Create_MTM_Period_Report '2006-10-30', '137', '150', NULL, 'u', 'f', 'c', 'd', NULL,NULL,NULL,NULL,NULL

--@sub_entity_id - subsidiary Id
--@strategy_entity_id - strategy Id
--@book_entity_id - book Id
--@discount_option - takes two values 'd' or 'u', corresponding to 'discounted', 'undiscounted' 
--@settlement_option -  takes 'f','c','s','a' corrsponding to 'forward', 'current & forward', 'current & settled', 'all' transactions
--@report_type - takes 'f', 'c', 'm' corresponding to 'fair value', 'cash flow', 'market to market'
--@summary_option - takes 'd' for detailed, 's' for summary by sub/strategy/book, 
--                'c' for sub/strategy/book/counterparty, 't' for sub/strategy/book/counterparty/expiration,
--		  'p' for sub/counterparty, 'q' for sub/counterparty/tenor
--		  'r' for sub/tenor
--===========================================================================================
CREATE PROC [dbo].[spa_Create_MTM_Period_Report_paging]
	@as_of_date VARCHAR(100), 
	@sub_entity_id VARCHAR(100), 
	@strategy_entity_id VARCHAR(100) = NULL, 
	@book_entity_id VARCHAR(100) = NULL, 
	@discount_option CHAR(1), 
	@settlement_option CHAR(1), 
	@report_type CHAR(1),
	@summary_option CHAR(1),
	@counterparty_id VARCHAR(500)= NULL,
	@tenor_from VARCHAR(50)= NULL,
	@tenor_to VARCHAR(50) = NULL,
	@previous_as_of_date VARCHAR(50) = NULL,
	@trader_id INT = NULL,
	@include_item CHAR(1)='n', -- to include item in cash flow hedge
	@source_system_book_id1 INT=NULL, 
	@source_system_book_id2 INT=NULL, 
	@source_system_book_id3 INT=NULL, 
	@source_system_book_id4 INT=NULL, 
	@show_firstday_gain_loss CHAR(1)='n', -- To Show First Day Gain/Loss
	@transaction_type VARCHAR(1000)=NULL,
	@deal_id_from INT=NULL,
	@deal_id_to INT=NULL,
	@deal_id VARCHAR(100)=NULL,
	@threshold_values FLOAT=NULL,
	@show_prior_processed_values CHAR(1)='n',
	@exceed_threshold_value CHAR(1)='n',   -- For First Day gain Loss Treatment selection
	@show_only_for_deal_date CHAR(1)='y',
	@use_create_date CHAR(1)='n',
	@round_value CHAR(1) = '0',
	@counterparty CHAR(1) = 'a', --i means only internal and e means only external, a means all
	@mapped CHAR(1) = 'm', --m means mapped only, n means non-mapped only
	@match_id CHAR(1) = 'n', --'y' means use like for deal ids and 'n' means use = 
	@cpty_type_id INT = NULL,  
	@curve_source_id INT,
	@deal_sub_type CHAR(1)='t',
	@deal_date_from VARCHAR(20)=NULL,
	@deal_date_to VARCHAR(20)=NULL,
	@phy_fin VARCHAR(1)='b',
	@deal_type_id INT=NULL,
	@period_report VARCHAR(1)='n',
	@term_start VARCHAR(20)=NULL,
	@term_end VARCHAR(20)=NULL,
	@settlement_date_from VARCHAR(20)=NULL,
	@settlement_date_to VARCHAR(20)=NULL,
	@settlement_only CHAR(1)='n',
	@drill1 VARCHAR(100)=NULL,
	@drill2 VARCHAR(100)=NULL,
	@drill3 VARCHAR(100)=NULL,
	@drill4 VARCHAR(100)=NULL,
	@drill5 VARCHAR(100)=NULL,
	@drill6 VARCHAR(100)=NULL,
	--Add Parameters Here
	@risk_bucket_header_id INT=NULL,
	@risk_bucket_detail_id INT=NULL,	
	@commodity_id INT = NULL,
	@graph CHAR(1)=NULL,
	@parent_counterparty VARCHAR(10) = NULL,	
	--END
	@process_id VARCHAR(200)=NULL, 
	@page_size INT =NULL,
	@page_no INT=NULL 
AS
SET NOCOUNT ON 

DECLARE @user_login_id VARCHAR(50),@tempTable VARCHAR(300) ,@flag CHAR(1)

	SET @user_login_id=dbo.FNADBUser()

	IF @process_id IS NULL
	BEGIN
		SET @flag='i'
		SET @process_id=REPLACE(NEWID(),'-','_')
	END
	SET @tempTable=dbo.FNAProcessTableName('paging_temp_MTM_Report', @user_login_id,@process_id)
	DECLARE @sqlStmt VARCHAR(MAX)

--Sub Strategy Book Counterparty DealNumber DealDate PNLDate Type Phy/Fin Expiration Cumulative FV 

IF @flag='i'
BEGIN
--if @summary_option='s'
	IF @summary_option = 'l'
		SET   @sqlStmt='create table '+ @tempTable+'( 
			 sno int  identity(1,1),
			[SSB Tag1] varchar(500),
			[SSB Tag2] varchar(500),
			[SSB Tag3] varchar(500),
			[SSB Tag4] varchar(500),
			Counterparty varchar(500),
			[Deal ID] varchar(500),
			[Ref ID] varchar(500),
			DealDate varchar(500),
			PNLDate varchar(100),
			Type varchar(500),
			[Phy/Fin] varchar(500),
			Cumulative float
			)' 
	ELSE IF @summary_option = 'm'	
		SET @sqlStmt='create table '+ @tempTable+'( 
			 sno int  identity(1,1),	
			Sub varchar(500),
			Strategy varchar(500),
			Book varchar(500),
			Counterparty varchar(500),
			DealNumber varchar(500),
			DealDate varchar(500),
			PNLDate varchar(100),
			Type varchar(500),
			[Phy/Fin] varchar(500),
			Expiration varchar(500),
			Cumulative float
--			,term_start datetime , 
--			source_deal_header_id int,
--			pnl_as_of_date datetime 
			)'
	ELSE IF @summary_option = 'b'
		SET   @sqlStmt='create table '+ @tempTable+'( 
			 sno int  identity(1,1),
			Sub varchar(500),
			Strategy varchar(500),
			Book varchar(500),
			[Deal ID] varchar(500),
			[Ref ID] varchar(500),
			[Trade Type] VARCHAR(50),
			Counterparty varchar(500),
			Trader varchar(500),
			DealDate varchar(500),
			PNLDate varchar(100),
			Term varchar(100),
			Leg char(2),
			[Buy/Sell] char(1),
			[Index] varchar(500),
			[Market Price] float,
			[Fixed Cost] int,
			[Formula Price] int,
			[Deal Fixed Price] float,
			[Price Adder] float,
			[Deal Price] float,
			[Net Price] float,
			Multiplier float,
			Volume int,
			[UOM] Varchar(200),'+
			CASE WHEN @settlement_only='n' THEN '[Discount Factor] FLOAT,[MTM] FLOAT,[Discounted MTM] FLOAT' 
			ELSE 'Settlement float' END+'
			)' 
	ELSE
		SET @sqlStmt='create table '+ @tempTable+'( 
			 sno int  identity(1,1),
			Sub varchar(500),
			Strategy varchar(500),
			Book varchar(500),
			Counterparty varchar(500),
			DealNumber varchar(500),
			DealDate varchar(500),
			PNLDate varchar(100),
			Type varchar(500),
			[Phy/Fin] varchar(500),
			Expiration varchar(500),
			Cumulative float
			)'

		EXEC(@sqlStmt)

	SET @sqlStmt=' INSERT INTO '+@tempTable+'
	exec  spa_Create_MTM_Period_Report '+ 
	dbo.FNASingleQuote(@as_of_date) +','+ 
	dbo.FNASingleQuote(@sub_entity_id) +','+ 
	dbo.FNASingleQuote(@strategy_entity_id) +','+ 
	dbo.FNASingleQuote(@book_entity_id) +','+ 
	dbo.FNASingleQuote(@discount_option) +',' +
	dbo.FNASingleQuote(@settlement_option) +',' +
	dbo.FNASingleQuote(@report_type) +',' +
	dbo.FNASingleQuote(@summary_option)+',' +
	dbo.FNASingleQuote(@counterparty_id)+','+
	dbo.FNASingleQuote(@tenor_from)+','+
	dbo.FNASingleQuote(@tenor_to) +',' +
	dbo.FNASingleQuote(@previous_as_of_date) +',' +
	dbo.FNASingleQuote(@trader_id) +',' +
	dbo.FNASingleQuote(@include_item) +',' +
	dbo.FNASingleQuote(@source_system_book_id1)+',' +
	dbo.FNASingleQuote(@source_system_book_id2)+','+
	dbo.FNASingleQuote(@source_system_book_id3)+','+
	dbo.FNASingleQuote(@source_system_book_id4)+','+
	dbo.FNASingleQuote(@show_firstday_gain_loss) +',' +
	dbo.FNASingleQuote(@transaction_type) +',' +
	dbo.FNASingleQuote(@deal_id_from) +',' +
	dbo.FNASingleQuote(@deal_id_to)+',' +
	dbo.FNASingleQuote(@deal_id)+','+
	dbo.FNASingleQuote(@threshold_values)+','+
	dbo.FNASingleQuote(@show_prior_processed_values)+','+
	dbo.FNASingleQuote(@exceed_threshold_value)+','+
	dbo.FNASingleQuote(@show_only_for_deal_date) +',' +
	dbo.FNASingleQuote(@use_create_date) +','+
	dbo.FNASingleQuote(@round_value) +','+
	dbo.FNASingleQuote(@counterparty) +','+
	dbo.FNASingleQuote(@mapped) +','+
	dbo.FNASingleQuote(@match_id) +','+
	dbo.FNASingleQuote(@cpty_type_id)+','+
	dbo.FNASingleQuote(@curve_source_id)+','+
	dbo.FNASingleQuote(@deal_sub_type)+','+
	dbo.FNASingleQuote(@deal_date_from)+','+
	dbo.FNASingleQuote(@deal_date_to)+','+
	dbo.FNASingleQuote(@phy_fin)+','+
	dbo.FNASingleQuote(@deal_type_id)+','+
	dbo.FNASingleQuote(@period_report)+','+
dbo.FNASingleQuote(@term_start)+','+
dbo.FNASingleQuote(@term_end)+','+
dbo.FNASingleQuote(@settlement_date_from)+','+
dbo.FNASingleQuote(@settlement_date_to)+','+
CASE @settlement_only WHEN 'y' THEN dbo.FNASingleQuote(@settlement_only) ELSE dbo.FNASingleQuote(NULL) END
+','+ 	--to retain original code for run mtm repot.. since mtm report was using it as null.
	dbo.FNASingleQuote(@drill1)+','+
	dbo.FNASingleQuote(@drill2)+','+
	dbo.FNASingleQuote(@drill3)+','+
	dbo.FNASingleQuote(@drill4)+','+
	dbo.FNASingleQuote(@drill5)+','+
	dbo.FNASingleQuote(@drill6)+','+
	dbo.FNASingleQuote(@risk_bucket_header_id)+','+
	dbo.FNASingleQuote(@risk_bucket_detail_id)+','+	
	dbo.FNASingleQuote(@commodity_id) + ',' +	
	dbo.FNASingleQuote(@graph)

	--PRINT @sqlStmt
	EXEC(@sqlStmt)	

	--EXEC(' ALTER TABLE '+@tempTable+' ADD COLUMN sno int  identity(1,1)')
	SET @sqlStmt='select count(*) TotalRow,'''+@process_id +''' process_id  from '+ @tempTable
	--PRINT @sqlStmt
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


END

	IF @summary_option = 'l'
		BEGIN
			SELECT @sqlStmt='select 
			[SSB Tag1] ['+group1+'], [SSB Tag2] ['+group2+'],[SSB Tag3] ['+group3+'], [SSB Tag4] ['+group4+'], Counterparty,
			[Deal ID] , [Ref ID], DealDate , PNLDate ,Type ,[Phy/Fin] ,
			Cumulative  as [Cumulative FV]
		   from '+ @tempTable  +' where sno between '+ CAST(@row_from AS VARCHAR) +' and '+ CAST(@row_to AS VARCHAR)+ ' order by sno asc'
		FROM source_book_mapping_clm
		END
	ELSE IF @summary_option = 'm'
		BEGIN
			SET @sqlStmt='select 
			Sub, Strategy,Book, Counterparty,
			DealNumber , DealDate ,	PNLDate ,Type ,	[Phy/Fin] ,
			Expiration,	Cumulative  as [Cumulative FV]
		   from '+ @tempTable  +' where sno between '+ CAST(@row_from AS VARCHAR) +' and '+ CAST(@row_to AS VARCHAR)+ ' order by sno asc'
			
		END
	ELSE IF @summary_option = 'b'
		BEGIN			
			SET @sqlStmt='select 
			Sub, Strategy, Book, [Deal ID], [Ref ID], [Trade Type], Counterparty, Trader, DealDate, PNLDate, Term, Leg, [Buy/Sell], [Index],
			[Market Price] ,[Fixed Cost] ,[Formula Price] ,[Deal Fixed Price] ,[Price Adder] ,[Deal Price] ,[Net Price] ,
			Multiplier ,Volume , [UOM],'+CASE WHEN @settlement_only='n' THEN '[Discount Factor],[MTM],[Discounted MTM]' ELSE ' Settlement ' END +'
		   from '+ @tempTable  +' where sno between '+ CAST(@row_from AS VARCHAR) +' and '+ CAST(@row_to AS VARCHAR)+ ' order by sno asc'
			
		END
	ELSE
		BEGIN			
			SET @sqlStmt='select 
			Sub, Strategy,Book, Counterparty,
			DealNumber , DealDate ,	PNLDate ,Type ,	[Phy/Fin] ,
			Expiration,	Cumulative  as [Cumulative FV]

			from '+ @tempTable  +' where sno between '+ CAST(@row_from AS VARCHAR) +' and '+ CAST(@row_to AS VARCHAR)+ ' order by sno asc'	
		END
		--PRINT @sqlStmt
		EXEC(@sqlStmt)