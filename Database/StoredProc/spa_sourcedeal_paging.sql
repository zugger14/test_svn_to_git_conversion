IF OBJECT_ID(N'spa_sourcedeal_paging', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_sourcedeal_paging]
GO

--exec spa_sourcedealheader_paging 's', '211', NULL, NULL, '2001-03-03', '2006-04-03', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL,115,NULL,NULL, NULL, NULL, NULL, '101', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,'105'

CREATE PROC [dbo].[spa_sourcedeal_paging]
	@flag_pre CHAR(1),
	@book_deal_type_map_id VARCHAR(200) = NULL, 
	@deal_id_from INT = NULL, 
	@deal_id_to INT = NULL, 
	@deal_date_from VARCHAR(10) = NULL, 
	@deal_date_to VARCHAR(10) = NULL,
	@source_deal_header_id INT = NULL,
	@source_system_id INT = NULL,
	@deal_id VARCHAR(50) = NULL,
	@deal_date VARCHAR(50) = NULL,
	@ext_deal_id VARCHAR(50) = NULL,
	@physical_financial_flag CHAR(1) = NULL,
	@structured_deal_id VARCHAR(50) = NULL,
	@counterparty_id INT = NULL,
	@entire_term_start VARCHAR(10) = NULL,
	@entire_term_end VARCHAR(10) = NULL,
	@source_deal_type_id INT = NULL,
	@deal_sub_type_type_id INT = NULL,
	@option_flag CHAR(1) = NULL,
	@option_type CHAR(1) = NULL,
	@option_excercise_type CHAR(1) = NULL,
	@source_system_book_id1 INT = NULL,
	@source_system_book_id2 INT = NULL,
	@source_system_book_id3 INT = NULL,
	@source_system_book_id4 INT = NULL,
	@description1 VARCHAR(100) = NULL,
	@description2 VARCHAR(100) = NULL,
	@description3 VARCHAR(100) = NULL,
	@deal_category_value_id INT = NULL,
	@trader_id INT = NULL,
	@internal_deal_type_value_id INT = NULL,
	@internal_deal_subtype_value_id INT = NULL,
	@book_id INT = NULL,
	@template_id INT = NULL,
	@process_id VARCHAR(100) = NULL,
	@header_buy_sell_flag VARCHAR(1) = NULL,
	@broker_id INT = NULL,
	@generator_id INT = NULL ,
	@gis_cert_number VARCHAR(250) = NULL ,
	@gis_value_id INT = NULL ,
	@gis_cert_date DATETIME = NULL ,
	@gen_cert_number VARCHAR(250) = NULL ,
	@gen_cert_date DATETIME = NULL ,
	@status_value_id INT = NULL,
	@status_date DATETIME = NULL ,
	@assignment_type_value_id INT = NULL ,
	@compliance_year INT = NULL ,
	@state_value_id INT = NULL ,
	@assigned_date DATETIME = NULL ,
	@assigned_by VARCHAR(50) = NULL,
	@gis_cert_number_to VARCHAR(250) = NULL,
	@process_id_paging VARCHAR(200) = NULL, 
	@page_size INT = NULL,
	@page_no INT = NULL 
AS
DECLARE @user_login_id  VARCHAR(50),
        @tempTable      VARCHAR(MAX),
        @flag           CHAR(1)

	SET @user_login_id = dbo.FNADBUser()

	IF @process_id_paging IS NULL
	BEGIN
	    SET @flag = 'i'
	    SET @process_id_paging = REPLACE(NEWID(), '-', '_')
	END
	SET @tempTable = dbo.FNAProcessTableName('paging_sourcedeal', @user_login_id, @process_id_paging)
	DECLARE @sqlStmt VARCHAR(5000)

IF @flag = 'i'
BEGIN
	SET @sqlStmt='create table '+ @tempTable+'( 
	sno int  identity(1,1),
	DealID varchar(100),
	SourceSystemId varchar(500),
	SourceDealID varchar(500),
	DealDate varchar(50),
	ExtDealId varchar(50),
	PhysicalFinancialFlag varchar(50),
	CptyName varchar(100),
	TermStart varchar(50),
	TermEnd varchar(50),
	DealType varchar(100),
	DealSubType varchar(100),
	OptionFlag varchar(10),
	OptionType varchar(50),
	ExcersiceType varchar(100),
--	Group1 varchar(100),
--	Group2 varchar(100),
--	Group3 varchar(100),
--	Group4 varchar(100),
--	Desc1 varchar(500),
--	Desc2 varchar(500),
--	Desc3 varchar(500),
	DealCategoryValueId varchar(50),
	TraderName varchar(100)
--	HedgeItemFlag varchar(100),
--	HedgeType varchar(100),
--	Currency varchar(50)
	)'

	exec(@sqlStmt)

	set @sqlStmt=' insert  '+@tempTable+'(DealID ,SourceSystemId , SourceDealID ,
	DealDate ,ExtDealId,
	PhysicalFinancialFlag ,
	CptyName ,	TermStart ,	TermEnd ,	DealType ,
	DealSubType ,
	OptionFlag ,
	OptionType ,
	ExcersiceType,
	DealCategoryValueId ,
	TraderName)
	exec spa_sourcedeal '+ dbo.FNASingleQuote(@flag_pre) +','+ 
	dbo.FNASingleQuote(@book_deal_type_map_id) +',' +
	dbo.FNASingleQuote(@deal_id_from)+',' +
	dbo.FNASingleQuote(@deal_id_to)+',' +
	dbo.FNASingleQuote(@deal_date_from)+',' +
	dbo.FNASingleQuote(@deal_date_to)+',' +
	dbo.FNASingleQuote(@source_deal_header_id)+',' +
	dbo.FNASingleQuote(@source_system_id)+',' +
	dbo.FNASingleQuote(@deal_id)+',' +
	dbo.FNASingleQuote(@deal_date)+',' +
	dbo.FNASingleQuote(@ext_deal_id)+',' +
	dbo.FNASingleQuote(@physical_financial_flag)+',' +
	dbo.FNASingleQuote(@structured_deal_id)+',' +
	dbo.FNASingleQuote(@counterparty_id)+',' +
	dbo.FNASingleQuote(@entire_term_start)+',' +
	dbo.FNASingleQuote(@entire_term_end)+',' +
	dbo.FNASingleQuote(@source_deal_type_id)+',' +
	dbo.FNASingleQuote(@deal_sub_type_type_id)+',' +
	dbo.FNASingleQuote(@option_flag)+',' +
	dbo.FNASingleQuote(@option_type)+',' +
	dbo.FNASingleQuote(@option_excercise_type)+',' +
	dbo.FNASingleQuote(@source_system_book_id1)+',' +
	dbo.FNASingleQuote(@source_system_book_id2)+',' +
	dbo.FNASingleQuote( @source_system_book_id3)+',' +
	dbo.FNASingleQuote(@source_system_book_id4)+',' +
	dbo.FNASingleQuote(@description1)+',' +
	dbo.FNASingleQuote(@description2)+',' +
	dbo.FNASingleQuote(@description3)+',' +
	dbo.FNASingleQuote(@deal_category_value_id)+',' +
	dbo.FNASingleQuote(@trader_id)+',' +
	dbo.FNASingleQuote(@internal_deal_type_value_id)+',' +
	dbo.FNASingleQuote(@internal_deal_subtype_value_id)+',' +
	dbo.FNASingleQuote(@book_id)+',' +
	dbo.FNASingleQuote(@template_id)+',' +
	dbo.FNASingleQuote(@process_id)+',' +
	dbo.FNASingleQuote(@header_buy_sell_flag)+',' +
	dbo.FNASingleQuote(@broker_id)+',' +
	dbo.FNASingleQuote(@generator_id)+',' +
	dbo.FNASingleQuote(@gis_cert_number)+',' +
	dbo.FNASingleQuote(@gis_value_id)+',' +
	dbo.FNASingleQuote(@gis_cert_date)+',' +
	dbo.FNASingleQuote(@gen_cert_number)+',' +
	dbo.FNASingleQuote(@gen_cert_date)+',' +
	dbo.FNASingleQuote(@status_value_id)+',' +
	dbo.FNASingleQuote(@status_date)+',' +
	dbo.FNASingleQuote(@assignment_type_value_id)+',' +
	dbo.FNASingleQuote(@compliance_year)+',' +
	dbo.FNASingleQuote(@state_value_id)+',' +
	dbo.FNASingleQuote(@assigned_date)+',' +
	dbo.FNASingleQuote(@assigned_by) + ',' + 
	dbo.FNASingleQuote(@gis_cert_number_to)
	
	EXEC spa_print @sqlStmt
	exec(@sqlStmt)	
	set @sqlStmt='select count(*) TotalRow,'''+@process_id_paging +''' process_id  from '+ @tempTable
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

set @sqlStmt='select DealID [ID], SourceSystemId [Cert #],SourceDealID [RefID],DealDate [Date],ExtDealId [ExtID],PhysicalFinancialFlag,
		CptyName,TermStart,TermEnd,DealType,DealSubType,OptionFlag,OptionType,ExcersiceType,DealCategoryValueId,TraderName
		from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar)+ ' order by sno asc'
		
	exec(@sqlStmt)
end





