
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_sourcedealheader]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_sourcedealheader]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	Generic stored procedure for deal header

	Parameters 
	@flag :
		-f - Returns data used for deal copy
		-s - Returns deal header data according to different filters
		-c - TDL
		-a - Returns deal header data of particular deal
		-u - Updates deal header
		-l - Locks deals
		-r - Returns data for rec trans (Update window) get all the record from source_deal_header
		-b - Returns data for rec trans window, Update the source_deal_header 
		-d - Deletes deal and its dependent data
		-k - TDL
		-m - Return deal data for particulare generator numbers
		-n - Return deal data for particulare generator numbers along with other filters
		-t - TDL
		-v - TDL
		-e - Updates deal verification data

	@book_deal_type_map_id : Book Deal Type Map Id
	@deal_id_from : Deal Id From
	@deal_id_to : Deal Id To
	@deal_date_from : Deal Date From
	@deal_date_to : Deal Date To
	@source_deal_header_id : Source Deal Header Id
	@source_system_id : Source System Id
	@deal_id : Deal Id
	@deal_date : Deal Date
	@ext_deal_id : Ext Deal Id
	@physical_financial_flag : Physical Financial Flag
	@structured_deal_id : Structured Deal Id
	@counterparty_id : Counterparty Id
	@entire_term_start : Entire Term Start
	@entire_term_end : Entire Term End
	@source_deal_type_id : Source Deal Type Id
	@deal_sub_type_type_id : Deal Sub Type Type Id
	@option_flag : Option Flag
	@option_type : Option Type
	@option_excercise_type : Option Excercise Type
	@source_system_book_id1 : Source System Book Id1
	@source_system_book_id2 : Source System Book Id2
	@source_system_book_id3 : Source System Book Id3
	@source_system_book_id4 : Source System Book Id4
	@description1 : Description1
	@description2 : Description2
	@description3 : Description3
	@deal_category_value_id : Deal Category Value Id
	@trader_id : Trader Id
	@internal_deal_type_value_id : Internal Deal Type Value Id
	@internal_deal_subtype_value_id : Internal Deal Subtype Value Id
	@book_id : Book Id
	@template_id : Template Id
	@process_id : Process Id
	@header_buy_sell_flag : Header Buy Sell Flag
	@broker_id : Broker Id
	@generator_id : Generator Id
	@gis_cert_number : Gis Cert Number
	@gis_value_id : Gis Value Id
	@gis_cert_date : Gis Cert Date
	@gen_cert_number : Gen Cert Number
	@gen_cert_date : Gen Cert Date
	@status_value_id : Status Value Id
	@status_date : Status Date
	@assignment_type_value_id : Assignment Type Value Id
	@compliance_year : Compliance Year
	@state_value_id : State Value Id
	@assigned_date : Assigned Date
	@assigned_by : Assigned By
	@gis_cert_number_to : Gis Cert Number To
	@generation_source : Generation Source
	@aggregate_environment : Aggregate Environment
	@aggregate_envrionment_comment : Aggregate Envrionment Comment
	@rec_price : Rec Price
	@rec_formula_id : Rec Formula Id
	@rolling_avg : Rolling Avg
	@sort_by : Sort By
	@certificate_from : Certificate From
	@certificate_to : Certificate To
	@certificate_date : Certificate Date
	@contract_id : Contract Id
	@legal_entity : Legal Entity
	@bifurcate_leg : Bifurcate Leg
	@refrence : Refrence
	@source_commodity : Source Commodity
	@source_internal_portfolio : Source Internal Portfolio
	@source_product : Source Product
	@source_internal_desk : Source Internal Desk
	@deal_locked : Deal Locked
	@block_type : Block Type
	@block_define_id : Block Define Id
	@granularity_id : Granularity Id
	@pricing : Pricing
	@description4 : Description4
	@update_date_from : Update Date From
	@update_date_to : Update Date To
	@update_by : Update By
	@confirm_type : Confirm Type
	@created_date_from : Created Date From
	@created_date_to : Created Date To
	@unit_fixed_flag : Unit Fixed Flag
	@broker_unit_fees : Broker Unit Fees
	@broker_fixed_cost : Broker Fixed Cost
	@broker_currency_id : Broker Currency Id
	@deal_status : Deal Status
	@option_settlement_date : Option Settlement Date
	@signed_off_flag : Signed Off Flag
	@signed_off_by : Signed Off By
	@broker : Broker
	@blotter : Blotter
	@index_group : Index Group
	@location : Location
	@index : Index
	@commodity : Commodity
	@udf_template_id_list : Udf Template Id List
	@udf_value_list : Udf Value List
	@user_action : User Action
	@comments : Comments
	@sub_entity_id : Sub Entity Id
	@strategy_entity_id : Strategy Entity Id
	@book_entity_id : Book Entity Id
	@deleted_deal : Deleted Deal
	@refrence_deal : Refrence Deal
	@deal_rules : Deal Rules
	@confirm_rule : Confirm Rule
	@update_call : Update Call
	@call_breakdown : Call Breakdown
	@contract : Contract
	@portfolio : Portfolio
	@timezone_id : Timezone Id
	@call_from_import : Call From Import
	
*/



CREATE PROC [dbo].[spa_sourcedealheader]
@flag CHAR(1),
@book_deal_type_map_id VARCHAR(200) = NULL, 
@deal_id_from INT = NULL, 
@deal_id_to INT = NULL, 
@deal_date_from VARCHAR(10) = NULL, 
@deal_date_to VARCHAR(10) = NULL,
@source_deal_header_id VARCHAR(MAX) = NULL,
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
@book_id VARCHAR(MAX) = NULL,
@template_id INT = NULL,
@process_id VARCHAR(100) = NULL,
@header_buy_sell_flag VARCHAR(1) = NULL,
@broker_id INT = NULL,
--Added the following for REC deals
@generator_id INT = NULL ,
@gis_cert_number VARCHAR(250) = NULL ,
@gis_value_id INT = NULL ,
@gis_cert_date VARCHAR(10) = NULL ,
@gen_cert_number VARCHAR(250) = NULL ,
@gen_cert_date VARCHAR(10) = NULL ,
@status_value_id INT = NULL,
@status_date DATETIME = NULL ,
@assignment_type_value_id INT = NULL ,
@compliance_year INT = NULL ,
@state_value_id INT = NULL ,
@assigned_date DATETIME = NULL ,
@assigned_by VARCHAR(50) = NULL, 
@gis_cert_number_to VARCHAR(250) = NULL,
@generation_source VARCHAR(250) = NULL,
@aggregate_environment CHAR(1) = 'n',
@aggregate_envrionment_comment VARCHAR(250) = NULL,
@rec_price FLOAT = NULL,
@rec_formula_id INT = NULL,
@rolling_avg CHAR(1) = NULL,
@sort_by CHAR(1) = 'l',
@certificate_from FLOAT = NULL,
@certificate_to FLOAT = NULL,
@certificate_date VARCHAR(20) = NULL,
@contract_id INT = NULL,
@legal_entity INT = NULL,
@bifurcate_leg INT = NULL,
@refrence VARCHAR(500) = NULL,
@source_commodity INT = NULL,
@source_internal_portfolio INT = NULL,
@source_product INT = NULL,
@source_internal_desk INT = NULL,
@deal_locked CHAR(1) = NULL,
@block_type INT = NULL,
@block_define_id INT = NULL,
@granularity_id INT = NULL,
@pricing INT = NULL,
@description4 VARCHAR(100) = NULL,
@update_date_from DATETIME = NULL,
@update_date_to DATETIME = NULL,
@update_by VARCHAR(50) = NULL,
@confirm_type VARCHAR(10) = NULL,
@created_date_from DATETIME = NULL,
@created_date_to DATETIME = NULL,
@unit_fixed_flag CHAR(1) = NULL,
@broker_unit_fees FLOAT = NULL,
@broker_fixed_cost FLOAT = NULL,
@broker_currency_id INT = NULL,
@deal_status INT = NULL,
@option_settlement_date VARCHAR(50) = NULL,
@signed_off_flag CHAR(1) = NULL,
@signed_off_by CHAR(1) = NULL,
@broker VARCHAR(100) = NULL,
@blotter CHAR(1) = NULL,
@index_group INT = NULL,
@location INT = NULL,
@index INT = NULL,
@commodity INT = NULL,
@udf_template_id_list VARCHAR(MAX) = NULL,
@udf_value_list VARCHAR(MAX) = NULL,
@user_action VARCHAR(100) = NULL,
@comments VARCHAR(1000) = NULL,
---- Added for multiple selection in of book_id
@sub_entity_id VARCHAR(8000) = NULL,  
@strategy_entity_id VARCHAR(8000) = NULL,  
@book_entity_id VARCHAR(8000) = NULL,  
@deleted_deal VARCHAR(1) = 'n',
@refrence_deal VARCHAR(500) = NULL,
@deal_rules INT = NULL,
@confirm_rule INT = NULL,
@update_call INT = 0  , 
@call_breakdown INT = 0,
@contract int = NULL,
@portfolio int = NULL,
@timezone_id INT = NULL,
@call_from_import NCHAR(1) = NULL

AS
SET NOCOUNT ON
SET @option_settlement_date = dbo.fnastddate(@option_settlement_date)
SET NOCOUNT ON
DECLARE @sql_Select                  VARCHAR(MAX)
DECLARE @sql                         VARCHAR(MAX)
DECLARE @copy_source_deal_header_id  INT
DECLARE @starategy_id                VARCHAR(1000)
DECLARE @sub_id                      INT
DECLARE @temp_count                  INT
DECLARE @temp_count1                 INT
DECLARE @tempheadertable             VARCHAR(100)
DECLARE @tempdetailtable             VARCHAR(100)
DECLARE @user_login_id               VARCHAR(100)
DECLARE @SPOT_DEAL                   INT
DECLARE @sign_off_date_field VARCHAR(50),@time_zone_from INT,@time_zone_to int
        --DECLARE @source_deal_header VARCHAR(50),@source_deal_detail VARCHAR(50)

IF @book_entity_id IS NULL
    SET @book_entity_id = @book_id

SET @SPOT_DEAL = 1
SET @user_login_id = dbo.FNADBUser()

IF @update_date_to IS NOT NULL
BEGIN
    SET @update_date_to = DATEADD(dd, DATEDIFF(dd, 0, @update_date_to) + 1, 0)
END

--CREATE TABLE #source_system (source_system_id INT) 

SELECT * into #tmp_source_deal_header_id FROM  SplitCommaSeperatedValues(@source_deal_header_id)

SELECT @time_zone_from= var_value  FROM adiha_default_codes_values  
	 WHERE  (instance_no = 1) AND (default_code_id = 36) AND (seq_no = 1)  
  
SELECT @time_zone_to=timezone_id from application_users where user_login_id=@user_login_id
DECLARE @group1 VARCHAR(100),@group2 VARCHAR(100),@group3 VARCHAR(100),@group4 VARCHAR(100)

DECLARE @Sql_Where_S   VARCHAR(5000)
DECLARE @Sql_Select_S  VARCHAR(5000)

CREATE TABLE #books ( fas_book_id int,book_deal_type_map_id INT,source_system_book_id1 int,source_system_book_id2 INT,source_system_book_id3 INT,source_system_book_id4  int,fas_deal_type_value_id int) 
--SET @sql_Select=

--	'INSERT INTO  #source_system

--	SELECT distinct fs.source_system_id FROM portfolio_hierarchy book (nolock) INNER JOIN

--	Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id LEFT OUTER JOIN            

--			source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id         
--			LEFT OUTER JOIN fas_strategy fs ON fs.fas_strategy_id=stra.entity_id
--	WHERE (fas_deal_type_value_id IS NULL OR fas_deal_type_value_id BETWEEN 400 AND 401) '
--	+CASE WHEN  @sub_id IS NOT NULL THEN  ' AND stra.parent_entity_id IN  ( ' + CAST(@sub_entity_id AS VARCHAR) + ') '  ELSE '' END
--	+CASE WHEN  @starategy_id IS NOT NULL THEN  ' AND stra.entity_id IN  ( ' +  CAST(@strategy_entity_id AS VARCHAR) + ') '  ELSE '' END
--	+CASE WHEN  @book_id IS NOT NULL THEN  ' AND book.entity_id IN  ( ' +  CAST(@book_id AS VARCHAR) + ') '  ELSE '' END
--	+CASE WHEN @book_deal_type_map_id IS NOT NULL THEN 'AND ssbm.book_deal_type_map_id IN  ( ' + @book_deal_type_map_id + ') ' ELSE '' END 

--EXEC (@sql_Select)

SET @Sql_Select_S = '
	INSERT INTO #books
	SELECT DISTINCT ssbm.fas_book_id,
	       ssbm.book_deal_type_map_id fas_book_id,
	       source_system_book_id1,
	       source_system_book_id2,
	       source_system_book_id3,
	       source_system_book_id4,
	       ssbm.fas_deal_type_value_id
	FROM   portfolio_hierarchy book(NOLOCK)
	       INNER JOIN Portfolio_hierarchy stra(NOLOCK)
	            ON  book.parent_entity_id = stra.entity_id
	       LEFT OUTER JOIN source_system_book_map ssbm
	            ON  ssbm.fas_book_id = book.entity_id
	WHERE  1 = 1'   
--PRINT 'here'

SET @Sql_Where_S=''
/*
IF @deal_id_from IS NOT NULL
	OR @deal_id_to IS NOT NULL
	OR @deal_id IS NOT NULL 
BEGIN
    SET @sub_entity_id = NULL
    SET @strategy_entity_id = NULL
    SET @book_entity_id = NULL
END */
      
IF @sub_entity_id IS NOT NULL 
	SET @Sql_Where_S = @Sql_Where_S + ' AND stra.parent_entity_id IN  ( '
		+ @sub_entity_id + ') '         
IF @strategy_entity_id IS NOT NULL 
	SET @Sql_Where_S = @Sql_Where_S + ' AND (stra.entity_id IN('
		+ @strategy_entity_id + ' ))'        
IF @book_entity_id IS NOT NULL 
	SET @Sql_Where_S = @Sql_Where_S + ' AND (book.entity_id IN('
		+ @book_entity_id + ')) '  
		      
IF (@source_system_book_id1 IS NOT NULL)
	SET @Sql_Where_S = @Sql_Where_S +' AND ssbm.source_system_book_id1 ='+CAST(@source_system_book_id1 AS VARCHAR)

IF (@source_system_book_id2 IS NOT NULL)
	SET @Sql_Where_S = @Sql_Where_S +' AND ssbm.source_system_book_id2=  '+CAST(@source_system_book_id2 AS VARCHAR)

IF (@source_system_book_id3 IS NOT NULL)
	SET @Sql_Where_S = @Sql_Where_S +' AND ssbm.source_system_book_id3 = '+CAST(@source_system_book_id3 AS VARCHAR)

IF (@source_system_book_id4 IS NOT NULL)
	SET @Sql_Where_S = @Sql_Where_S +' AND ssbm.source_system_book_id4 = '+CAST(@source_system_book_id4 AS VARCHAR)

IF @book_deal_type_map_id IS NOT NULL
	SET @Sql_Where_S = @Sql_Where_S +' AND ssbm.book_deal_type_map_id IN ( ' + CAST(@book_deal_type_map_id AS VARCHAR) + ')'


SET @Sql_Select_S = @Sql_Select_S + @Sql_Where_S

--PRINT @Sql_Select_S
EXEC (@Sql_Select_S)



--IF OBJECT_ID(N'adiha_process.dbo.audit_books', N'U') IS NOT NULL
--	DROP TABLE adiha_process.dbo.audit_books
	
--IF OBJECT_ID(N'adiha_process.dbo.audit_books', N'U') IS NULL
--BEGIN
--	CREATE TABLE adiha_process.dbo.audit_books
--	(
--		fas_book_id             INT,
--		book_deal_type_map_id   INT,
--		source_system_book_id1  INT,
--		source_system_book_id2  INT,
--		source_system_book_id3  INT,
--		source_system_book_id4  INT,
--		fas_deal_type_value_id  INT
--	)
--END
--INSERT INTO adiha_process.dbo.audit_books SELECT * FROM #books


IF EXISTS(SELECT group1,group2,group3,group4 FROM source_book_mapping_clm)
BEGIN	
	SELECT @group1=group1,@group2=group2,@group3=group3,@group4=group4 FROM source_book_mapping_clm
END
ELSE
BEGIN
	SET @group1='Group1'
	SET @group2='Group2'
	SET @group3='Group3'
	SET @group4='Group4'
 
END
--SELECT @book_id=fas_book_id FROM #books WHERE book_deal_type_map_id=@book_deal_type_map_id
--SELECT @starategy_id= parent_entity_id FROM portfolio_hierarchy WHERE entity_id IN (@book_id)
--SELECT @sub_id= parent_entity_id FROM portfolio_hierarchy WHERE entity_id=@starategy_id	


--PRINT @confirm_type
--PRINT @blotter


--Declare @book_id intBegin
IF @flag='f' --use in deal copy
BEGIN
	
	SELECT MAX(sdh.term_frequency) AS [Frequency],
	       MAX(sdd.deal_volume) AS [Volume],
	       [dbo].FNAGetGenericDate(MIN(sdd.term_start), @user_login_id) AS 
	       [Term Start],
	       [dbo].FNAGetGenericDate(MAX(sdd.term_end), @user_login_id) AS 
	       [Term End]
	FROM   source_deal_detail sdd
	       INNER JOIN dbo.source_deal_header sdh
	            ON  sdd.source_deal_header_id = sdh.source_deal_header_id
	            AND sdd.source_deal_header_id = ISNULL(@source_deal_header_id, sdd.source_deal_header_id)
	       LEFT JOIN dbo.source_deal_header_template t
	            ON  t.template_id = sdh.template_id
	WHERE  --		source_deal_header_id=@source_deal_header_id
	       --		and 
	       leg = CASE 
	                  WHEN @bifurcate_leg IS NOT NULL THEN @bifurcate_leg
	                  ELSE leg
	             END
END 	 
IF @flag='s'  
	BEGIN

	SET @sql_Select = 
			'
--SELECT [ID],[RefID] AS [Ref ID],[dbo].FNAGetGenericDate(deal_date, '''+@user_login_id+''') as [Deal Date],[ExtId] AS [Ext ID],[PhysicalFinancialFlag] AS [Physical/Financial Flag] ,[CptyName] AS [Counterparty],
--					[TermStart] AS [Term Start] ,[TermEnd] AS [Term End] ,[DealType] AS [Deal Type],[DealSubType] AS [Deal Sub Type], [OptionFlag] AS [Option Flag],[OptionType] AS [Option Type],[ExcerciseType] AS [Exercise Type],
--					['+ @group1 +'],['+ @group2 +']   ,['+ @group3 +'],['+ @group4 +'],[Desc1],[Desc2],[Desc3],
--					[DealCategoryValueId] AS [Deal Category],[TraderName] AS [Trader Name],[HedgeItemFlag] AS [Hedge/Item Flag],[HedgeType] AS [Hedge Type],[AssignType] AS [Assign Type],[legal_entity] AS [Legal Entity],
--					[deal_locked] AS [Deal Lock], [Pricing],[Created Date],ConfirmStatus AS [Confirm Status],[Signed Off By],[Sign Off Date] as [Signed Off Date], [Broker],[comments],deal_rules,confirm_rule
--					
--			FROM (
			SELECT  DISTINCT
					dh.source_deal_header_id AS ID,
					dh.deal_id AS [Ref ID],
					dbo.FNADateFormat(dh.deal_date) [Deal Date],
 					dh.ext_deal_id as [Ext ID],
					CASE WHEN dh.physical_financial_flag =''p'' THEN ''Physical'' ELSE ''Financial'' END	as [Physical/Financial Flag], 
					source_counterparty.counterparty_name [Counterparty],
					--[dbo].FNAGetGenericDate(dh.entire_term_start,'''+@user_login_id+''') as [Term Start], 
					--[dbo].FNAGetGenericDate(dh.entire_term_end,'''+@user_login_id+''') As [Term End], 
					dbo.FNADateFormat(dh.entire_term_start) [Entire Term Start],
					dbo.FNADateFormat(dh.entire_term_end) [Entire Term End],
					source_deal_type.source_deal_type_name As [Deal Type] , 
					source_deal_type_1.source_deal_type_name AS [Deal Sub Type],
					[dbo].FNAGetAbbreviationDef(dh.option_flag) As [Option Flag],
					[dbo].FNAGetAbbreviationDef(dh.option_type) As [Option Type], 
					[dbo].FNAGetAbbreviationDef(dh.option_excercise_type) As [Excercise Type],
					source_book.source_book_name As ['+ @group1 +'], 
					source_book_1.source_book_name AS ['+ @group2 +'],
					source_book_2.source_book_name AS ['+ @group3 +'], 
					source_book_3.source_book_name AS ['+ @group4 +'],
					dh.description1 As [Description 1], 
					dh.description2 As [Description 2],
					dh.description3 as [Description 3],
					static_data_value4.code as [Deal Category],
					source_traders.trader_name as [Trader],
					static_data_value1.code as [Hedge/Item Flag],
					static_data_value2.code as  [Hedge Type],
					CASE WHEN dh.header_buy_sell_flag=''s'' AND dh.assignment_type_value_id is not null THEN sdv.code else 	
							CASE WHEN dh.header_buy_sell_flag=''s'' AND dh.assignment_type_value_id is null THEN ''Sold'' else ''Banked'' end
					END [Assign Type],
					dh.legal_entity [Legal Entity],
				(
					CASE WHEN dh.deal_locked = ''y'' THEN ''Yes''
					ELSE 
						CASE WHEN ISNULL(dl_specific.id, dl_generic.id) IS NOT NULL THEN
							CASE WHEN DATEADD(mi, ISNULL(dl_specific.mins, dl_generic.mins), ISNULL(dh.update_ts, dh.create_ts)) < GETDATE() THEN ''Yes'' ELSE ''No'' END
						ELSE ''No''
						END
					END
				) AS [Deal Locked] ,				
				static_data_value3.code [Pricing],
				--[dbo].FNAConvertGenericTimezone(dh.create_ts,'+ISNULL(cast(@time_zone_from AS VARCHAR), 'NULL') +','+ ISNULL(CAST(@time_zone_to AS VARCHAR), 'NULL') + ','''+@user_login_id+''',0) as [Created Date]
				dbo.FNADateTimeFormat(dh.create_ts,2) [Create TS],				
				sdv_confirm.code [Confirm Status],
				dh.verified_by [Signed Off By],
				--[dbo].FNAGetGenericDate(dh.verified_date,'''+@user_login_id+''') [Sign Off Date],
				dh.verified_date [Verified Date],
				scp.counterparty_name AS [Broker],
				t.comments [Comments],
				sc.commodity_name [Commodity],
				t.deal_rules,
				t.confirm_rule			
		
			FROM   ' +CASE WHEN isnull(@deleted_deal,'n')='y' then  'delete_source_deal_header' ELSE 'source_deal_header' END +' dh '+
			
			CASE WHEN  (@deal_id_from IS  NULL or @deal_id_to IS  NULL) AND @source_deal_header_id IS NOT NULL 
					THEN ' inner join #tmp_source_deal_header_id t_dh on t_dh.item=dh.source_deal_header_id '
				 ELSE '' 
			END +
		' --INNER JOIN #source_system ss ON ss.source_system_id=dh.source_system_id
			 INNER JOIN #books ' + 
			-- CASE WHEN  @deal_id_from IS NULL AND @deal_id IS NULL THEN 	' #books ' 	ELSE ' source_system_book_map ' END +
		'
			sbmp ON dh.source_system_book_id1 = sbmp.source_system_book_id1 
			AND dh.source_system_book_id2 = sbmp.source_system_book_id2 
			AND dh.source_system_book_id3 = sbmp.source_system_book_id3 
			AND dh.source_system_book_id4 = sbmp.source_system_book_id4 			
			LEFT OUTER JOIN source_counterparty ON dh.counterparty_id = source_counterparty.source_counterparty_id 
			LEFT OUTER JOIN source_counterparty AS scp ON dh.broker_id = scp.source_counterparty_id 
			LEFT OUTER JOIN source_traders ON dh.trader_id = source_traders.source_trader_id 
			LEFT OUTER JOIN source_deal_type ON dh.source_deal_type_id = source_deal_type.source_deal_type_id 
			LEFT OUTER JOIN source_book ON dh.source_system_book_id1 = source_book.source_book_id 
			LEFT OUTER JOIN source_book source_book_1 ON dh.source_system_book_id2 = source_book_1.source_book_id 
			LEFT OUTER JOIN source_book source_book_2 ON dh.source_system_book_id3 = source_book_2.source_book_id 
			LEFT OUTER JOIN source_book source_book_3 ON dh.source_system_book_id4 = source_book_3.source_book_id 
			LEFT OUTER JOIN  portfolio_hierarchy ON portfolio_hierarchy.entity_id = sbmp.fas_book_id
			LEFT OUTER JOIN fas_strategy ON fas_strategy.fas_strategy_id=portfolio_hierarchy.parent_entity_id
			LEFT OUTER JOIN static_data_value  static_data_value1 ON sbmp.fas_deal_type_value_id=static_data_value1.value_id
			LEFT OUTER JOIN static_data_value  static_data_value2 ON fas_strategy.hedge_type_value_id=static_data_value2.value_id
			LEFT OUTER JOIN static_data_value  static_data_value3 ON static_data_value3.value_id = dh.pricing
			LEFT OUTER JOIN static_data_value  static_data_value4 ON static_data_value4.value_id = dh.deal_category_value_id
			LEFT OUTER JOIN static_data_value  static_data_value5 ON static_data_value5.value_id = dh.deal_status
			
			LEFT OUTER JOIN source_deal_type source_deal_type_1 ON dh.deal_sub_type_type_id = source_deal_type_1.source_deal_type_id 
			LEFT OUTER JOIN fas_link_detail fld ON fld.source_deal_header_id = dh.source_deal_header_id 
			LEFT OUTER JOIN static_data_value sdv ON sdv.value_id=dh.assignment_type_value_id
			LEFT OUTER JOIN rec_generator rg ON rg.generator_id=dh.generator_id ' +
			--CASE WHEN (@gis_cert_number IS NOT NULL AND @gis_cert_number_to IS NOT NULL) OR (@gis_cert_date IS NOT NULL) OR (@location IS NOT NULL) OR (@index_group IS NOT null) OR (@index IS NOT NULL)
			--THEN
				' LEFT OUTER JOIN ' +CASE WHEN isnull(@deleted_deal,'n')='y' then  'delete_source_deal_detail' ELSE 'source_deal_detail' END +' sdd ON sdd.source_deal_header_id=dh.source_deal_header_id and sdd.leg = 1 '
			--ELSE '' END 
			+
			
			CASE WHEN (@gis_cert_number IS NOT NULL AND @gis_cert_number_to IS NOT NULL) OR (@gis_cert_date IS NOT NULL)
				THEN
					' LEFT OUTER JOIN gis_certificate gis ON gis.source_deal_header_id=sdd.source_deal_detail_id'
				ELSE '' END +
			--CASE WHEN (@index_group IS NOT null) OR (@index IS NOT NULL)
			--	THEN
					' LEFT OUTER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=sdd.curve_id
					  LEFT JOIN source_commodity sc ON sc.source_commodity_id = spcd.commodity_id'
			--ELSE '' END 
			+
			CASE WHEN (@location IS NOT NULL)
				THEN
					' LEFT OUTER JOIN source_minor_location sml ON sml.source_minor_location_id=sdd.location_id'
				ELSE '' END +
			'
			
			LEFT OUTER JOIN confirm_status_recent csr ON csr.source_deal_header_id = dh.source_deal_header_id
			LEFT OUTER JOIN static_data_value sdv_confirm ON sdv_confirm.value_id = ISNULL(csr.type,17200)
			LEFT OUTER JOIN dbo.source_deal_header_template t ON t.template_id=dh.template_id  
			LEFT OUTER JOIN dbo.source_deal_detail_template dt ON dt.template_id=dh.template_id 
			--LEFT OUTER JOIN source_commodity sc ON sc.source_commodity_id=dt.commodity_id
			LEFT OUTER JOIN static_data_value sdv2 ON sdv2.value_id=dh.block_type
			LEFT JOIN
			(
				SELECT MAX(id) id, deal_type_id, MIN(hour * 60 + minute) mins
				FROM deal_lock_setup dls
				INNER JOIN application_role_user aru ON dls.role_id = aru.role_id
				WHERE aru.user_login_id = dbo.FNADBUser() AND deal_type_id IS NOT NULL
				GROUP BY dls.deal_type_id
			) dl_specific ON source_deal_type.source_deal_type_id = dl_specific.deal_type_id AND ISNULL(dh.deal_locked, ''n'') <> ''y''
			LEFT JOIN
			(
				SELECT MAX(id) id, deal_type_id, MIN(hour * 60 + minute) mins
				FROM deal_lock_setup dls
				INNER JOIN application_role_user aru ON dls.role_id = aru.role_id
				WHERE aru.user_login_id = dbo.FNADBUser() AND deal_type_id IS NULL
				GROUP BY dls.deal_type_id
			) dl_generic ON ISNULL(dh.deal_locked, ''n'') <> ''y''
			 WHERE   1 = 1 ' 

		
		IF  (@deal_id_from IS not NULL and @deal_id_to IS  not NULL)   
		BEGIN 
			SET @sql_Select = @sql_Select +  ' AND dh.source_deal_header_id BETWEEN ' + CAST(@deal_id_from AS VARCHAR)  + ' AND ' + CAST(@deal_id_to AS VARCHAR) 
			IF (@deal_locked = 'l' )
				SET @sql_Select = @sql_Select + ' AND dh.deal_locked = ''y'''
		
			IF (@deal_locked = 'u' )
				SET @sql_Select = @sql_Select + ' AND (dh.deal_locked = ''n'' OR dh.deal_locked IS NULL)'
		END 
		

	--IF ONE deal id is known make the other the same
/*
		IF (@created_date_from IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dbo.FNAConvertTZAwareDateFormat(dh.create_ts,1)>='''+CONVERT(VARCHAR(10),@created_date_from,120) +''''
			
			--SET @sql_Select = @sql_Select +' AND convert(varchar(10),dh.create_ts,120)>='''+convert(varchar(10),@created_date_from,120) +''''

		IF (@created_date_to IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dbo.FNAConvertTZAwareDateFormat(dh.create_ts,1) <='''+CONVERT(VARCHAR(10),@created_date_to,120) +''''

*/

		--IF (@created_date_from IS NOT NULL)
		--	SET @sql_Select = @sql_Select +' AND dh.create_ts>='''+CONVERT(VARCHAR(10),[dbo].[FNAConvertTimezone](@created_date_from,1),120) +''''
			
		--IF (@created_date_to IS NOT NULL)
		--	SET @sql_Select = @sql_Select +' AND dh.create_ts <'''+CONVERT(VARCHAR(10),[dbo].[FNAConvertTimezone](@created_date_to+1,1),120) +''''


		IF (@created_date_from IS NOT NULL) AND (@created_date_to IS NULL)
			SET @sql_select = @sql_select + ' AND dh.create_ts >= ''' + CONVERT(VARCHAR(10),[dbo].[FNAConvertTimezone](@created_date_from,1),120) + ''''
			
		IF (@created_date_from IS NULL) AND (@created_date_to IS NOT NULL) 
			SET @sql_select = @sql_select + ' AND dh.create_ts <= ''' + CONVERT(VARCHAR(10),[dbo].[FNAConvertTimezone](@created_date_to+1,1),120) + ''''
		
		IF (@created_date_from IS NOT NULL) AND (@created_date_to IS NOT NULL) 
			SET @sql_select = @sql_select + ' AND dh.create_ts BETWEEN ''' + CONVERT(VARCHAR(10),[dbo].[FNAConvertTimezone](@created_date_from,1),120) + ''' AND ''' + CONVERT(VARCHAR(10),[dbo].[FNAConvertTimezone](@created_date_to+1,1),120) + ''''



			--SET @sql_Select = @sql_Select +' AND convert(varchar(10),dh.create_ts,120) <='''+convert(varchar(10),@created_date_to,120) +''''



	IF @deal_id_to IS NULL AND @deal_id_from IS NOT NULL
		SET @deal_id_to = @deal_id_from

	IF @deal_id_from IS NULL AND @deal_id_to IS NOT NULL
		SET @deal_id_from = @deal_id_to

	IF (@deal_id_from IS NOT NULL) AND (@deal_id_to IS NOT NULL) 
		SET @sql_Select = @sql_Select + ' AND dh.source_deal_header_id BETWEEN ' + CAST(@deal_id_from AS VARCHAR)  + ' AND ' + CAST(@deal_id_to AS VARCHAR) 
	ELSE IF @source_deal_header_id IS NOT NULL
		SET @sql_Select = @sql_Select + ' AND dh.source_deal_header_id IN(' + @source_deal_header_id  +')'


	IF (@gis_cert_number IS NOT NULL AND @gis_cert_number_to IS NOT NULL)
		SET @sql_Select = @sql_Select +' AND ('+ @gis_cert_number + ' between gis.certificate_number_from_int   
		AND  gis.certificate_number_to_int AND ' +
			@gis_cert_number_to + ' between gis.certificate_number_from_int   
		AND  gis.certificate_number_to_int)'

	IF @deal_id IS NOT NULL 
			SET @sql_Select = @sql_Select + ' AND dh.deal_id like ''' + @deal_id + '%'''
			
	IF ISNULL(@blotter,'n')='y'
			SET @sql_Select = @sql_Select + ' AND blotter_supported =''y'''	
		
	IF @deal_id_from IS NULL AND @deal_id IS NULL --only apply deal filters if deal id not given.
	BEGIN
		IF @index_group IS NOT NULL
			SET @sql_Select = @sql_Select + ' AND spcd.index_group='+CAST(@index_group AS VARCHAR)

		IF @index IS NOT NULL
			SET @sql_Select = @sql_Select + ' AND spcd.source_curve_def_id='+CAST(@index AS VARCHAR)
		

		IF @commodity IS NOT NULL
			SET @sql_Select = @sql_Select + ' AND spcd.commodity_id ='+CAST(@commodity AS VARCHAR)

		
		IF @block_type IS NOT NULL
			SET @sql_Select = @sql_Select + ' AND sdv2.value_id='+CAST(@block_type AS VARCHAR)
			
		IF @location IS NOT NULL
			SET @sql_Select = @sql_Select + ' AND sml.source_minor_location_id='+CAST(@location AS VARCHAR)
		
		IF @deal_status IS NOT NULL 
			SET @sql_Select = @sql_Select + ' AND static_data_value5.value_id ='+CAST(@deal_status AS VARCHAR) 
	IF @confirm_type IS NOT NULL  -- exceptions)
		BEGIN
		
--			if (@confirm_type = 'n')
--				SET @sql_Select = @sql_Select +' AND csr.type IS NULL OR csr.type=''n'''
--			else
				SET @sql_Select = @sql_Select +' AND csr.type IN (' + @confirm_type + ') '
		END
	
--		IF @book_deal_type_map_id IS NOT NULL 
--			SET @sql_Select = @sql_Select + ' AND sbmp.book_deal_type_map_id in( ' + @book_deal_type_map_id + ')'
		
		IF (@deal_date_from IS NOT NULL) AND (@deal_date_to IS NULL)
			SET @sql_select = @sql_select + ' AND dh.deal_date >= ''' + @deal_date_from + ''''
			
		IF (@deal_date_from IS NULL) AND (@deal_date_to IS NOT NULL) 
			SET @sql_select = @sql_select + ' AND dh.deal_date <= ''' + @deal_date_to + ''''
		
		IF (@deal_date_from IS NOT NULL) AND (@deal_date_to IS NOT NULL) 
			SET @sql_select = @sql_select + ' AND dh.deal_date BETWEEN ''' + @deal_date_from + ''' AND ''' + @deal_date_to + ''''
			
		IF (@physical_financial_flag IS NOT NULL)
			SET @sql_Select = @sql_Select + ' AND dh.physical_financial_flag='''+@physical_financial_flag+''''
		
		IF (@counterparty_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.counterparty_id='+CAST(@counterparty_id AS VARCHAR)

		IF (@entire_term_start IS NOT NULL)
			SET @sql_Select = @sql_Select+ ' AND dh.entire_term_start>='''+@entire_term_start+''''

		IF (@entire_term_end IS NOT NULL)
			SET @sql_Select = @sql_Select+ ' AND dh.entire_term_end<='''+@entire_term_end+''''

		IF (@source_deal_type_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.source_deal_type_id='+CAST(@source_deal_type_id  AS VARCHAR)

		IF (@deal_sub_type_type_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.deal_sub_type_type_id='+CAST(@deal_sub_type_type_id  AS VARCHAR)

		IF (@deal_category_value_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.deal_category_value_id='+CAST(@deal_category_value_id  AS VARCHAR)

		IF (@trader_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.trader_id='+CAST(@trader_id  AS VARCHAR)

		IF (@description1 IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.description1 like ''%'+@description1+'%'''

		IF (@description2 IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.description2 like ''%'+@description2+'%'''

		IF (@description3 IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.description3 like ''%'+@description3+'%'''

		IF (@structured_deal_id  IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.structured_deal_id like ''%'+@structured_deal_id +'%'''

		IF (@header_buy_sell_flag IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.header_buy_sell_flag='''+ @header_buy_sell_flag + ''''


		--IF (@deal_locked IS NOT NULL )
			--SET @sql_Select = @sql_Select + ' AND dh.deal_locked='''+@deal_locked+''''	
		IF (@deal_locked = 'l' )
			SET @sql_Select = @sql_Select + ' AND dh.deal_locked = ''y'''
		
		IF (@deal_locked = 'u' )
			SET @sql_Select = @sql_Select + ' AND (dh.deal_locked = ''n'' OR dh.deal_locked IS NULL)'

		IF (@update_date_from IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.update_ts>='''+CAST(@update_date_from  AS VARCHAR)+''''

		IF (@update_date_to IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.update_ts<='''+CAST(@update_date_to  AS VARCHAR)+''''

		IF (@update_by IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.update_user='''+CAST(@update_by  AS VARCHAR)+''''
	

		----====Added the following filter for REC deals
		--print 'no' 

	--if one cert is known and other not known make the same		
	IF @gis_cert_number_to IS NULL AND @gis_cert_number IS NOT NULL
		SET @gis_cert_number_to = @gis_cert_number

	IF @gis_cert_number IS NULL AND @gis_cert_number_to IS NOT NULL
		SET @gis_cert_number = @gis_cert_number_to




	IF @gis_cert_number IS NULL 
	BEGIN

		IF (@generator_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.generator_id='+CAST(@generator_id  AS VARCHAR)
		IF (@status_value_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.status_value_id='+CAST(@status_value_id  AS VARCHAR)
		IF (@status_date IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.status_date='''+ dbo.FNAGetSQLStandardDate(@status_date) + ''''
		IF (@assignment_type_value_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND isnull(dh.assignment_type_value_id, 5149) ='+CAST(@assignment_type_value_id  AS VARCHAR)
		IF (@compliance_year IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.compliance_year='+CAST(@compliance_year  AS VARCHAR)
		IF (@state_value_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.state_value_id='+CAST(@state_value_id  AS VARCHAR)
		IF (@assigned_date IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.assigned_date='''+ dbo.FNAGetSQLStandardDate(@assigned_date) + ''''
		IF (@assigned_by IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.assigned_by='''+ @assigned_by + ''''
		IF @gis_value_id IS NOT NULL
			SET @sql_Select = @sql_Select +' AND rg.gis_value_id='+ CAST(@gis_value_id AS VARCHAR)
		IF @gen_cert_date IS NOT NULL
			SET @sql_Select = @sql_Select +' AND rg.registration_date='''+ @gen_cert_date +''''
		IF @gen_cert_number IS NOT NULL
			SET @sql_Select = @sql_Select +' AND rg.gis_account_number='''+ @gen_cert_number +''''
		IF @gis_cert_date IS NOT NULL
			SET @sql_Select = @sql_Select +' AND gis.gis_cert_date='''+ @gis_cert_date +''''

	END
	
	
	SET @sign_off_date_field = CASE @signed_off_by
		WHEN 't' THEN 'verified_date'
		WHEN 'r' THEN 'risk_sign_off_date'
		WHEN 'b' THEN 'back_office_sign_off_date'
	END 
	
	IF @signed_off_flag IS NOT NULL 
	BEGIN
		IF @signed_off_flag = 'y'
			SET @sql_Select = @sql_Select + ' AND dh.' + @sign_off_date_field + ' IS NOT NULL'
		ELSE IF @signed_off_flag = 'n'
			SET @sql_Select = @sql_Select + ' AND dh.' + @sign_off_date_field + ' IS NULL'
	END

	IF @broker IS NOT NULL 
	BEGIN
		SET @sql_Select = @sql_Select + ' AND dh.broker_id = ' + @broker
	END
 --contract in where clause
	IF @contract IS NOT NULL 
	BEGIN
		SET @sql_Select = @sql_Select + ' AND dh.contract_id = ' + CAST(@contract AS VARCHAR)
	END
	--portfolio in where clause
	IF @portfolio IS NOT NULL 
	BEGIN
		SET @sql_Select = @sql_Select + ' AND dh.internal_portfolio_id = ' + CAST(@portfolio AS VARCHAR)
	END 
	END	
	IF @sort_by='l'
		SET @sql_Select = @sql_Select +' order by id desc'
	ELSE
		SET @sql_Select = @sql_Select +' order by id asc'

		--PRINT @sql_Select

		EXEC(@sql_Select)
		
		/*
		If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'Source Deal Header  table', 
				'spa_sourcedealheader', 'DB Error', 
				'Failed to select source deal header record.', ''
		Else

		Exec spa_ErrorHandler 0, 'Source Deal Header  table', 
				'spa_sourcedealheader', 'Success', 
				'Source deal header record successfully selected.', ''
			*/
end


IF @flag='c'  
	BEGIN
	
	
	
		SET @sql = '
		SELECT DISTINCT
			dh.source_deal_header_id AS ID,
			dh.deal_id AS [Ref ID],
			[dbo].FNAGetGenericDate(dh.deal_date, ''' + @user_login_id + ''') as [Deal Date], 
			dh.ext_deal_id AS [Ext ID],
			CASE WHEN dh.physical_financial_flag = ''p'' THEN 
				''Physical''
			ELSE 
				''Financial''
			END	AS [Physical/Financial Flag], 
			source_counterparty.counterparty_name [Counterparty], 
			[dbo].FNAGetGenericDate(dh.entire_term_start, ''' + @user_login_id + ''') AS [Term Start], 
			[dbo].FNAGetGenericDate(dh.entire_term_end, ''' + @user_login_id + ''') AS [Term End], 
			source_deal_type.source_deal_type_name AS [Deal Type], 
			source_deal_type_1.source_deal_type_name AS [Deal Sub Type], 
			dh.option_flag AS [Option Flag], 
			dh.option_type AS [Option Type], 
			dh.option_excercise_type AS [Exercise Type], 
			source_book.source_book_name AS [' + @group1 + '], 
			source_book_1.source_book_name AS [' + @group2 + '], 
			source_book_2.source_book_name AS [' + @group3 + '], 
			source_book_3.source_book_name AS [' + @group4 + '], 
			dh.description1 AS Desc1, 
			dh.description2 AS Desc2,
			dh.description3 AS Desc3, 
			static_data_value4.code AS [Deal Category], 
			source_traders.trader_name AS [Trader Name],
			static_data_value1.code AS [Hedge/Item Flag], 
			static_data_value2.code AS  [Hedge Type],
			CASE WHEN dh.header_buy_sell_flag=''s'' AND dh.assignment_type_value_id IS NOT NULL THEN 
				sdv.code 
			ELSE 	
				CASE WHEN dh.header_buy_sell_flag=''s'' AND dh.assignment_type_value_id IS NULL THEN 
					''Sold'' 
				ELSE 
					''Banked'' 
				END
			END [Assign Type], 
			dh.legal_entity [Legal Entity], 
			(
				CASE WHEN dh.deal_locked = ''y'' THEN ''Yes''
				ELSE 
					CASE WHEN ISNULL(dl_specific.id, dl_generic.id) IS NOT NULL THEN
						CASE WHEN DATEADD(mi, ISNULL(dl_specific.mins, dl_generic.mins), ISNULL(dh.update_ts, dh.create_ts)) < GETDATE() THEN 
							''Yes'' 
						ELSE 
							''No''
						END
					ELSE 
						''No''
					END
				END
			) AS [Deal Lock], 				
			static_data_value3.code [Pricing], 
			[dbo].FNAGetGenericDate(dh.create_ts, ''' + @user_login_id + ''') AS [Created Date], 
			sdv_confirm.code [Confirm Status], 
			dh.verified_by [Signed Off By], 
			[dbo].FNAGetGenericDate(dh.verified_date, ''' + @user_login_id + ''') [Signed Off Date], 
			scp.counterparty_name AS [Broker], 
			NULL as [Comments]
			,spcd.commodity_id [Commodity ID]				
		FROM (
			SELECT a.* FROM source_deal_header_audit a
			INNER JOIN (
				SELECT source_deal_header_id, MAX(audit_id) max_audit_id FROM source_deal_header_audit GROUP BY source_deal_header_id 
			) b ON a.audit_id = b.max_audit_id 
		) dh
		INNER JOIN source_system_book_map ssbm 
			ON ssbm.source_system_book_id1 = dh.source_system_book_id1
			AND ssbm.source_system_book_id2 = dh.source_system_book_id2
			AND ssbm.source_system_book_id3 = dh.source_system_book_id3
			AND ssbm.source_system_book_id4 = dh.source_system_book_id4
		INNER JOIN #books sbmp ON dh.source_system_book_id1 = sbmp.source_system_book_id1 
								AND dh.source_system_book_id2 = sbmp.source_system_book_id2 
								AND dh.source_system_book_id3 = sbmp.source_system_book_id3 
								AND dh.source_system_book_id4 = sbmp.source_system_book_id4	
		LEFT OUTER JOIN source_counterparty ON dh.counterparty_id = source_counterparty.source_counterparty_id 
		LEFT OUTER JOIN source_counterparty AS scp ON dh.broker_id = scp.source_counterparty_id 
		LEFT OUTER JOIN source_traders ON dh.trader_id = source_traders.source_trader_id 
		LEFT OUTER JOIN source_deal_type ON dh.source_deal_type_id = source_deal_type.source_deal_type_id 
		LEFT OUTER JOIN source_book ON dh.source_system_book_id1 = source_book.source_book_id 
		LEFT OUTER JOIN source_book source_book_1 ON dh.source_system_book_id2 = source_book_1.source_book_id 
		LEFT OUTER JOIN source_book source_book_2 ON dh.source_system_book_id3 = source_book_2.source_book_id 
		LEFT OUTER JOIN source_book source_book_3 ON dh.source_system_book_id4 = source_book_3.source_book_id 
		LEFT OUTER JOIN portfolio_hierarchy ON portfolio_hierarchy.entity_id = ssbm.fas_book_id
		LEFT OUTER JOIN fas_strategy ON fas_strategy.fas_strategy_id=portfolio_hierarchy.parent_entity_id
		LEFT OUTER JOIN static_data_value  static_data_value1 ON ssbm.fas_deal_type_value_id=static_data_value1.value_id
		LEFT OUTER JOIN static_data_value  static_data_value2 ON fas_strategy.hedge_type_value_id=static_data_value2.value_id
		LEFT OUTER JOIN static_data_value  static_data_value3 ON static_data_value3.value_id = dh.pricing
		LEFT OUTER JOIN static_data_value  static_data_value4 ON static_data_value4.value_id = dh.deal_category_value_id
		LEFT OUTER JOIN confirm_status_recent csr ON csr.source_deal_header_id = dh.source_deal_header_id
		LEFT OUTER JOIN static_data_value sdv_confirm ON sdv_confirm.value_id = ISNULL(csr.type,17200)
		LEFT OUTER JOIN source_deal_type source_deal_type_1 ON dh.deal_sub_type_type_id = source_deal_type_1.source_deal_type_id 
		LEFT OUTER JOIN fas_link_detail fld ON fld.source_deal_header_id = dh.source_deal_header_id 
		LEFT OUTER JOIN static_data_value sdv ON sdv.value_id=dh.assignment_type_value_id
		LEFT OUTER JOIN rec_generator rg ON rg.generator_id=dh.generator_id' +
			--CASE WHEN (@gis_cert_number IS NOT NULL AND @gis_cert_number_to IS NOT NULL) 
			--	OR (@gis_cert_date IS NOT NULL) 
			--	OR (@location IS NOT NULL) 
			--	OR (@index_group IS NOT null) 
			--	OR (@index IS NOT NULL)
			--THEN
				' LEFT OUTER JOIN source_deal_detail sdd ON sdd.source_deal_header_id=dh.source_deal_header_id and sdd.leg = 1 '
			--ELSE '' END 
			+
			
			CASE WHEN (@gis_cert_number IS NOT NULL AND @gis_cert_number_to IS NOT NULL) OR (@gis_cert_date IS NOT NULL)
				THEN
					' LEFT OUTER JOIN gis_certificate gis ON gis.source_deal_header_id=sdd.source_deal_detail_id'
				ELSE '' END +
			--CASE WHEN (@index_group IS NOT null) OR (@index IS NOT NULL)
			--	THEN
					' LEFT OUTER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=sdd.curve_id'
				--ELSE '' END 
			+
			CASE WHEN (@location IS NOT NULL)
				THEN
					' LEFT OUTER JOIN source_minor_location sml ON sml.source_minor_location_id=sdd.location_id'
				ELSE '' END +
			'
		LEFT OUTER JOIN dbo.source_deal_header_template t ON t.template_id=dh.template_id  
		LEFT OUTER JOIN dbo.source_deal_detail_template dt ON dt.template_id=dh.template_id
		--LEFT OUTER JOIN source_commodity sc ON sc.source_commodity_id=dt.commodity_id
		LEFT OUTER JOIN static_data_value sdv2 ON sdv2.value_id=dh.block_type
		LEFT JOIN
		(
			SELECT MAX(id) id, deal_type_id, MIN(hour * 60 + minute) mins
			FROM deal_lock_setup dls
			INNER JOIN application_role_user aru ON dls.role_id = aru.role_id
			WHERE aru.user_login_id = dbo.FNADBUser() AND deal_type_id IS NOT NULL
			GROUP BY dls.deal_type_id
		) dl_specific ON source_deal_type.source_deal_type_id = dl_specific.deal_type_id AND ISNULL(dh.deal_locked, ''n'') <> ''y''
		LEFT JOIN
		(
			SELECT MAX(id) id, deal_type_id, MIN(hour * 60 + minute) mins
			FROM deal_lock_setup dls
			INNER JOIN application_role_user aru ON dls.role_id = aru.role_id
			WHERE aru.user_login_id = dbo.FNADBUser() AND deal_type_id IS NULL
			GROUP BY dls.deal_type_id
		) dl_generic ON ISNULL(dh.deal_locked, ''n'') <> ''y''  
			
		WHERE 1 = 1  
		AND EXISTS (
			SELECT * FROM 
			source_deal_header_audit sdha 
			INNER JOIN source_system_book_map ssbma 
				ON ssbma.source_system_book_id1 = sdha.source_system_book_id1
				AND ssbma.source_system_book_id2 = sdha.source_system_book_id2
				AND ssbma.source_system_book_id3 = sdha.source_system_book_id3
				AND ssbma.source_system_book_id4 = sdha.source_system_book_id4
			WHERE sdha.source_deal_header_id = dh.source_deal_header_id ' 

		IF @user_action IS NOT NULL AND @user_action <> 'all'				
		BEGIN
			IF @user_action = 'upd_del'
				SET @sql = @sql + ' AND sdha.user_action IN (''Update'', ''Delete'')'
			ELSE  
			SET @sql = @sql + ' AND sdha.user_action = ''' + @user_action + '''' 
		END
		   
    IF (@update_date_from IS NOT NULL)  
    SET @sql = @sql + ' AND sdha.update_ts>='''+CONVERT(VARCHAR(10),[dbo].[FNAConvertTimezone](@update_date_from,1),120) +''''  
     
   IF (@update_date_to IS NOT NULL)  
    SET @sql = @sql + ' AND sdha.update_ts <'''+CONVERT(VARCHAR(10),[dbo].[FNAConvertTimezone](@update_date_to+1,1),120) +''''  
				
		SET @sql = @sql + ') '
		
		------------------------------------------------------------------------------------------------------------------------
		-- FILTERS
		
		IF @book_deal_type_map_id IS NOT NULL 
			SET @sql = @sql + '	AND ssbm.book_deal_type_map_id in (' + CAST(@book_deal_type_map_id AS VARCHAR) + ')'
		
		
		IF ISNULL(@blotter,'n')='y'
			SET @sql = @sql + ' AND blotter_supported = ''y'''

		IF (@created_date_from IS NOT NULL)
			SET @sql = @sql + ' AND dh.create_ts>=''' + CONVERT(VARCHAR(10),[dbo].[FNAConvertTimezone](@created_date_from,1),120) + ''''
			
		IF (@created_date_to IS NOT NULL)
			SET @sql = @sql + ' AND dh.create_ts <''' + CONVERT(VARCHAR(10),[dbo].[FNAConvertTimezone](@created_date_to+1,1),120) + ''''


		IF @deal_id_to IS NULL AND @deal_id_from IS NOT NULL
			SET @deal_id_to = @deal_id_from

		IF @deal_id_from IS NULL AND @deal_id_to IS NOT NULL
			SET @deal_id_from = @deal_id_to

		IF (@deal_id_from IS NOT NULL) AND (@deal_id_to IS NOT NULL) 
			SET @sql = @sql + ' AND dh.source_deal_header_id BETWEEN ' + CAST(@deal_id_from AS VARCHAR)  + ' AND ' + CAST(@deal_id_to AS VARCHAR) 


		IF (@gis_cert_number IS NOT NULL AND @gis_cert_number_to IS NOT NULL)
			SET @sql = @sql + ' AND (' + @gis_cert_number + ' BETWEEN gis.certificate_number_from_int AND gis.certificate_number_to_int ' 
				+ ' AND ' +	@gis_cert_number_to + ' BETWEEN gis.certificate_number_from_int AND gis.certificate_number_to_int)'

		IF @deal_id IS NOT NULL 
				SET @sql = @sql + ' AND dh.deal_id like ''' + @deal_id + '%'''

		IF @deal_id_from IS NULL AND @deal_id IS NULL --only apply deal filters if deal id not given.
		BEGIN
			IF @index_group IS NOT NULL
				SET @sql = @sql + ' AND spcd.index_group = '+CAST(@index_group AS VARCHAR)

			IF @index IS NOT NULL
				SET @sql = @sql + ' AND spcd.source_curve_def_id = '+CAST(@index AS VARCHAR)
			
			IF @location IS NOT NULL
				SET @sql = @sql + ' AND sml.source_minor_location_id = '+CAST(@location AS VARCHAR)

			IF @commodity IS NOT NULL
				SET @sql = @sql + ' AND spcd.commodity_id = '+CAST(@commodity AS VARCHAR)

			
			IF @block_type IS NOT NULL
				SET @sql = @sql + ' AND sdv2.value_id = '+CAST(@block_type AS VARCHAR)
		

			IF @confirm_type IS NOT NULL  -- exceptions)
			BEGIN
				IF (@confirm_type = 'n')
					SET @sql = @sql + ' AND csr.type IS NULL OR csr.type=''n'''
				ELSE
					SET @sql = @sql + ' AND ISNULL(csr.type,''n'') IN (''' + @confirm_type + ''') '
			END

		
			IF (@deal_date_from IS NOT NULL) AND (@deal_date_to IS NOT NULL) 
				SET @sql = @sql + ' AND dh.deal_date BETWEEN '''+ @deal_date_from + ''' and ''' + @deal_date_to + ''''
			
			IF (@physical_financial_flag IS NOT NULL)
				SET @sql = @sql + ' AND dh.physical_financial_flag='''+@physical_financial_flag+''''
			
			IF (@counterparty_id IS NOT NULL)
				SET @sql = @sql + ' AND dh.counterparty_id='+CAST(@counterparty_id AS VARCHAR)

			IF (@entire_term_start IS NOT NULL)
				SET @sql = @sql + ' AND dh.entire_term_start>='''+@entire_term_start+''''

			IF (@entire_term_end IS NOT NULL)
				SET @sql = @sql + ' AND dh.entire_term_end<='''+@entire_term_end+''''

			IF (@source_deal_type_id IS NOT NULL)
				SET @sql = @sql + ' AND dh.source_deal_type_id='+CAST(@source_deal_type_id  AS VARCHAR)

			IF (@deal_sub_type_type_id IS NOT NULL)
				SET @sql = @sql + ' AND dh.deal_sub_type_type_id='+CAST(@deal_sub_type_type_id  AS VARCHAR)

			IF (@deal_category_value_id IS NOT NULL)
				SET @sql = @sql + ' AND dh.deal_category_value_id='+CAST(@deal_category_value_id  AS VARCHAR)

			IF (@trader_id IS NOT NULL)
				SET @sql = @sql + ' AND dh.trader_id='+CAST(@trader_id  AS VARCHAR)

			IF (@description1 IS NOT NULL)
				SET @sql = @sql + ' AND dh.description1 like ''%'+@description1+'%'''

			IF (@description2 IS NOT NULL)
				SET @sql = @sql + ' AND dh.description2 like ''%'+@description2+'%'''

			IF (@description3 IS NOT NULL)
				SET @sql = @sql + ' AND dh.description3 like ''%'+@description3+'%'''

			IF (@structured_deal_id  IS NOT NULL)
				SET @sql = @sql + ' AND dh.structured_deal_id like ''%'+@structured_deal_id +'%'''

			IF (@header_buy_sell_flag IS NOT NULL)
				SET @sql = @sql + ' AND dh.header_buy_sell_flag='''+ @header_buy_sell_flag + ''''

			IF (@deal_locked = 'l' )
				SET @sql = @sql + ' AND dh.deal_locked = ''y'''
			
			IF (@deal_locked = 'u' )
				SET @sql = @sql + ' AND (dh.deal_locked = ''n'' OR dh.deal_locked IS NULL)'

			IF (@update_date_from IS NOT NULL)
				SET @sql = @sql + ' AND dh.update_ts>='''+CONVERT(VARCHAR(10),[dbo].[FNAConvertTimezone](@update_date_from,1),120) +''''
			
			IF (@update_date_to IS NOT NULL)
				SET @sql = @sql + ' AND dh.update_ts <'''+CONVERT(VARCHAR(10),[dbo].[FNAConvertTimezone](@update_date_to+1,1),120) +''''

			IF (@update_by IS NOT NULL)
				SET @sql = @sql + ' AND dh.update_user='''+CAST(@update_by  AS VARCHAR)+''''
				
			IF @deal_status IS NOT NULL 
				SET @sql = @sql + ' AND dh.deal_status=' + CAST(@deal_status AS VARCHAR) 
		END

		----====Added the following filter for REC deals
		--if one cert is known and other not known make the same		
		IF @gis_cert_number_to IS NULL AND @gis_cert_number IS NOT NULL
			SET @gis_cert_number_to = @gis_cert_number

		IF @gis_cert_number IS NULL AND @gis_cert_number_to IS NOT NULL
			SET @gis_cert_number = @gis_cert_number_to

		IF @gis_cert_number IS NULL 
		BEGIN

			IF (@generator_id IS NOT NULL)
				SET @sql = @sql +' AND dh.generator_id='+CAST(@generator_id  AS VARCHAR)
			IF (@status_value_id IS NOT NULL)
				SET @sql = @sql +' AND dh.status_value_id='+CAST(@status_value_id  AS VARCHAR)
			IF (@status_date IS NOT NULL)
				SET @sql = @sql +' AND dh.status_date='''+ dbo.FNAGetSQLStandardDate(@status_date) + ''''
			IF (@assignment_type_value_id IS NOT NULL)
				SET @sql = @sql +' AND isnull(dh.assignment_type_value_id, 5149) ='+CAST(@assignment_type_value_id  AS VARCHAR)
			IF (@compliance_year IS NOT NULL)
				SET @sql = @sql +' AND dh.compliance_year='+CAST(@compliance_year  AS VARCHAR)
			IF (@state_value_id IS NOT NULL)
				SET @sql = @sql +' AND dh.state_value_id='+CAST(@state_value_id  AS VARCHAR)
			IF (@assigned_date IS NOT NULL)
				SET @sql = @sql +' AND dh.assigned_date='''+ dbo.FNAGetSQLStandardDate(@assigned_date) + ''''
			IF (@assigned_by IS NOT NULL)
				SET @sql = @sql +' AND dh.assigned_by='''+ @assigned_by + ''''
			IF @gis_value_id IS NOT NULL
				SET @sql = @sql +' AND rg.gis_value_id='+ CAST(@gis_value_id AS VARCHAR)
			IF @gen_cert_date IS NOT NULL
				SET @sql = @sql +' AND rg.registration_date='''+ @gen_cert_date +''''
			IF @gen_cert_number IS NOT NULL
				SET @sql = @sql +' AND rg.gis_account_number='''+ @gen_cert_number +''''
			IF @gis_cert_date IS NOT NULL
				SET @sql = @sql +' AND gis.gis_cert_date='''+ @gis_cert_date +''''

		END
	
	
		SET @sign_off_date_field = CASE @signed_off_by
			WHEN 't' THEN 'verified_date'
			WHEN 'r' THEN 'risk_sign_off_date'
			WHEN 'b' THEN 'back_office_sign_off_date'
		END 
		
		IF @signed_off_flag IS NOT NULL 
		BEGIN
			IF @signed_off_flag = 'y'
				SET @sql = @sql + ' AND dh.' + @sign_off_date_field + ' IS NOT NULL'
			ELSE IF @signed_off_flag = 'n'
				SET @sql = @sql + ' AND dh.' + @sign_off_date_field + ' IS NULL'
		END

		IF @broker IS NOT NULL 
		BEGIN
			SET @sql = @sql + ' AND dh.broker_id = ' + @broker
		END

		
		SET @sql = @sql + ' ORDER BY id '
		
		IF @sort_by = 'l'
			SET @sql = @sql + ' DESC'
		
		--PRINT @sql
		EXEC (@sql)
	

END


ELSE IF @flag = 'a' 
BEGIN

	
	SELECT dh.source_deal_header_id ,dh.source_system_id ,dh.deal_id, 
		dbo.FNAGetSQLStandardDate(dh.deal_date),
 		dh.ext_deal_id ,dh.physical_financial_flag, 
		dh.counterparty_id, 
		dbo.FNAGetSQLStandardDate(dh.entire_term_start), 
		dbo.FNAGetSQLStandardDate(dh.entire_term_end), dh.source_deal_type_id, 
		dh.deal_sub_type_type_id, 
		dh.option_flag, dh.option_type, dh.option_excercise_type, 
		source_book.source_book_name AS Group1, 
		source_book_1.source_book_name AS Group2, 
	        source_book_2.source_book_name AS Group3, source_book_3.source_book_name AS Group4,
		dh.description1,dh.description2,dh.description3,
		dh.deal_category_value_id,dh.trader_id, source_system_book_map.fas_book_id,portfolio_hierarchy.parent_entity_id,
		fas_strategy.hedge_type_value_id,static_data_value1.code AS HedgeItemFlag,
			static_data_value2.code AS HedgeType,source_currency.currency_name AS Currency,
		dh.internal_deal_type_value_id,dh.internal_deal_subtype_value_id,dh.template_id,source_currency.source_system_id,
		dh.header_buy_sell_flag,dh.broker_id,dh.rolling_avg,contract_id,
		source_system_book_map.book_deal_type_map_id,dh.legal_entity ,dh.block_type,dh.block_define_id,dh.granularity_id, dh.pricing
	FROM source_deal_header dh 
		INNER JOIN source_book ON dh.source_system_book_id1 = source_book.source_book_id 
		INNER JOIN source_book source_book_1 ON dh.source_system_book_id2 = source_book_1.source_book_id 
		INNER JOIN source_book source_book_2 ON dh.source_system_book_id3 = source_book_2.source_book_id 
		INNER JOIN source_book source_book_3 ON dh.source_system_book_id4 = source_book_3.source_book_id
		
		LEFT JOIN source_system_book_map ON  source_system_book_map.source_system_book_id1= source_book.source_book_id 
			AND source_system_book_map.source_system_book_id2 = source_book_1.source_book_id 
			AND source_system_book_map.source_system_book_id3 = source_book_2.source_book_id 
			AND source_system_book_map.source_system_book_id4= source_book_3.source_book_id 
		--INNER JOIN #source_system ss ON ss.source_system_id=dh.source_system_id
		LEFT JOIN  portfolio_hierarchy ON portfolio_hierarchy.entity_id = source_system_book_map.fas_book_id
		LEFT JOIN fas_strategy ON fas_strategy.fas_strategy_id=portfolio_hierarchy.parent_entity_id
		LEFT JOIN static_data_value  static_data_value1 ON source_system_book_map.fas_deal_type_value_id=static_data_value1.value_id
		LEFT JOIN static_data_value  static_data_value2 ON fas_strategy.hedge_type_value_id=static_data_value2.value_id
		LEFT  JOIN fas_subsidiaries ON fas_subsidiaries.fas_subsidiary_id=@sub_id 
		LEFT JOIN source_currency   ON fas_subsidiaries.func_cur_value_id=source_currency.source_currency_id
		WHERE dh.source_deal_header_id=@source_deal_header_id --and source_system_book_map.fas_book_id = @book_id
        --ORDER BY dh.source_deal_header_id ASC


	END


ELSE IF @flag='u'
BEGIN
	-----------------------------------Start of Min and Max value validation-------------------------------------------------
	DECLARE @IntVariable INT;
	DECLARE @SQLString NVARCHAR(MAX);
	DECLARE @ParmDefinition NVARCHAR(MAX);
	DECLARE @return CHAR(1);

	SET @IntVariable = 197;   
	DECLARE @fields VARCHAR(1000)
	
	SELECT 	@entire_term_start entire_term_start ,
	@entire_term_end entire_term_end ,
	@rec_price rec_price,
	@rolling_avg rolling_avg,
	@pricing pricing,
	@broker_unit_fees broker_unit_fees,
	@broker_fixed_cost broker_fixed_cost INTO #temp_sdh
	
	DECLARE @field_template_id INT   
	SELECT @field_template_id=field_template_id from dbo.source_deal_header_template WHERE template_id=@template_id   

	SELECT 
       @fields = COALESCE(@fields + ',', ' ' ) + cast(mfd.farrms_field_id AS VARCHAR(30))
      
	FROM   maintain_field_template_detail mftd
		   INNER JOIN maintain_field_deal mfd
				ON  mftd.field_id = mfd.field_id
				AND mftd.udf_or_system = 's'
				AND mfd.header_detail = 'h'
	WHERE  mftd.field_template_id = @field_template_id
		   AND (NULLIF(mftd.min_value, 0) IS NOT NULL OR NULLIF(mftd.max_value, 0) IS NOT NULL)

	SET @SQLString =  '
			DECLARE @error_field VARCHAR(100)
			DECLARE @min_value FLOAT
			DECLARE @max_value FLOAT
			DECLARE @msg VARCHAR(1000)
			
			SELECT @error_field = mfd.default_label,
					@min_value = mftd.min_value,
					@max_value = mftd.max_value
			FROM   maintain_field_template_detail mftd
			       INNER JOIN maintain_field_deal mfd
			            ON  mftd.field_id = mfd.field_id
			            AND mftd.udf_or_system = ''s''
			            AND mfd.header_detail = ''h''
			       INNER JOIN (
			                SELECT ' +  @fields + '
			                FROM   #temp_sdh
			            )p
			            UNPIVOT(col_value FOR field IN (' +  @fields + ')) AS 
			            unpvt
			            ON  unpvt.field = mfd.farrms_field_id
			            AND (
			                    unpvt.col_value < mftd.min_value
			                    OR unpvt.col_value > mftd.max_value
			                )
			WHERE  mftd.field_template_id = ' + CAST(@field_template_id AS VARCHAR(10)) + '
			       AND (mftd.min_value IS NOT NULL OR mftd.max_value IS NOT NULL)
			
			IF @error_field IS NOT NULL 
				SET @msg = ''The value for '' + cast(@error_field as varchar(100)) + '' should be between '' + cast(@min_value as varchar(100)) + '' and '' + cast(@max_value as varchar(100)) + ''.'' 
			
			SET @max_titleOUT = 0
			IF  @msg IS NOT NULL 
			BEGIN
				EXEC spa_ErrorHandler -1, ''Error'', 
								''spa_InsertDealXmlBlotter'', ''DB Error'', 
								@msg, @msg						
				
				SET @max_titleOUT = 1	
			END
			
			
   '
	SET @ParmDefinition = N'@level tinyint, @max_titleOUT varchar(30) OUTPUT';
	--PRINT '---------------------------------------------------------------------------------------'

	EXECUTE sp_executesql @SQLString, @ParmDefinition, @level = @IntVariable, @max_titleOUT=@return OUTPUT;

	--Return if column value is not between min and max value
	IF @return = 1
		RETURN 

	-----------------------------------End of Min and Max value validation-------------------------------------------------

	
	
	IF EXISTS(SELECT 1 FROM source_deal_header WHERE source_deal_header_id <> @source_deal_header_id AND deal_id = @deal_id)
	BEGIN
		EXEC spa_ErrorHandler -1, 'Source Deal Header  table', 
					'spa_sourcedealheader', 'DB Error', 
					'Error', 'Cannot insert duplicate ref ID.'
		
	END
	ELSE
	BEGIN
		BEGIN TRY
		
			DECLARE @update_fields VARCHAR(8000),@new_process_id VARCHAR(200)
			
			/*Added for deal reference prefix start*/
			--DECLARE @refrence_prefix VARCHAR(1000)
			--SELECT @refrence_prefix = prefix FROM deal_reference_id_prefix WHERE deal_type = @source_deal_type_id 
			
			--IF @refrence_prefix IS NOT NULL
			--BEGIN
			--	SET @deal_id = @refrence_prefix + @source_deal_header_id
			--END
			--SELECT @deal_id
			--RETURN
			/*Added for deal reference prefix end*/
			
			
			SELECT @update_fields = max(srd.update_fields)
			FROM source_deal_header sdh INNER JOIN source_deal_header_template sdht ON sdh.template_id = sdht.template_id 
			INNER JOIN status_rule_header srh ON sdht.deal_rules = srh.status_rule_id
			INNER JOIN status_rule_detail srd ON srh.status_rule_id = srd.status_rule_id
 			--INNER JOIN status_rule_activity sra ON srd.event_id = sra.event_id AND srd.status_rule_detail_id = sra.status_rule_detail_id
			--INNER JOIN dbo.splitcommaseperatedvalues('2,2,2,2') scsvd ON scsvd.item = sdht.deal_rules
			WHERE sdh.source_deal_header_id = @source_deal_header_id
			GROUP BY sdh.source_deal_header_id
			
			
			 
						
			IF OBJECT_ID('tempdb..#fields') IS NOT NULL 
			DROP TABLE #fields
			
			CREATE TABLE #fields(item VARCHAR(100) COLLATE DATABASE_DEFAULT ,item_variables VARCHAR(max) COLLATE DATABASE_DEFAULT)
						
			-- All the parameters of sp that could affect the columns of table are inserted here
			-- if new columns/parameters are added they should be added here in this section also
			
			INSERT INTO #fields(item, item_variables)
			SELECT 'source_system_id' ,cast(isnull(@source_system_id,-1) AS VARCHAR)
			UNION ALL
			SELECT 'deal_id' ,cast(isnull(@deal_id,-1) AS VARCHAR)
			UNION ALL
			SELECT 'deal_date' ,isnull(cast(@deal_date AS VARCHAR),'1900-1-1')
			UNION ALL
			SELECT 'ext_deal_id' ,cast(isnull(@ext_deal_id,-1) AS VARCHAR)
			UNION ALL
			SELECT 'physical_financial_flag' ,cast(isnull(@physical_financial_flag,-1) AS VARCHAR)
			UNION ALL
			SELECT 'structured_deal_id' ,cast(isnull(@structured_deal_id,-1) AS VARCHAR)
			UNION ALL
			SELECT 'counterparty_id' ,cast(isnull(@counterparty_id,-1) AS VARCHAR)
			UNION ALL
			SELECT 'entire_term_start' ,isnull(cast(@entire_term_start AS VARCHAR),'1900-1-1')
			UNION ALL
			SELECT 'entire_term_end' ,isnull(cast(@entire_term_end AS VARCHAR),'1900-1-1')
			UNION ALL
			SELECT 'source_deal_type_id' ,cast(isnull(@source_deal_type_id,-1) AS VARCHAR)
			UNION ALL
			SELECT 'deal_sub_type_type_id' ,cast(isnull(@deal_sub_type_type_id,-1) AS VARCHAR)
			UNION ALL
			SELECT 'option_flag' ,cast(isnull(@option_flag,'') AS VARCHAR)
			UNION ALL
			SELECT 'option_type' ,cast(isnull(@option_type,'') AS VARCHAR)
			UNION ALL
			SELECT 'option_excercise_type' ,cast(isnull(@option_excercise_type,'') AS VARCHAR)
			UNION ALL
			SELECT 'source_system_book_id1' ,cast(isnull(@source_system_book_id1,-1) AS VARCHAR)
			UNION ALL
			SELECT 'source_system_book_id2' ,cast(isnull(@source_system_book_id2,-1) AS VARCHAR)
			UNION ALL
			SELECT 'source_system_book_id3' ,cast(isnull(@source_system_book_id3,-1) AS VARCHAR)
			UNION ALL
			SELECT 'source_system_book_id4' ,cast(isnull(@source_system_book_id4,-1) AS VARCHAR)
			UNION ALL
			SELECT 'description1' ,cast(isnull(@description1,-1) AS VARCHAR)
			UNION ALL
			SELECT 'description2' ,cast(isnull(@description2,-1) AS VARCHAR)
			UNION ALL
			SELECT 'description3' ,cast(isnull(@description3,-1) AS VARCHAR)
			UNION ALL
			SELECT 'deal_category_value_id' ,cast(isnull(@deal_category_value_id,-1) AS VARCHAR)
			UNION ALL
			SELECT 'trader_id' ,cast(isnull(@trader_id,-1) AS VARCHAR)
			UNION ALL
			SELECT 'internal_deal_type_value_id' ,cast(isnull(@internal_deal_type_value_id,-1) AS VARCHAR)
			UNION ALL
			SELECT 'internal_deal_subtype_value_id' ,cast(isnull(@internal_deal_subtype_value_id,-1) AS VARCHAR)
			UNION ALL
			SELECT 'book_id' ,cast(isnull(@book_id,-1) AS VARCHAR)
			UNION ALL
			SELECT 'template_id' ,cast(isnull(@template_id,-1) AS VARCHAR)
			UNION ALL
			SELECT 'process_id' ,cast(isnull(@process_id,-1) AS VARCHAR)
			UNION ALL
			SELECT 'header_buy_sell_flag' ,cast(isnull(@header_buy_sell_flag,-1) AS VARCHAR)
			UNION ALL
			SELECT 'broker_id' ,cast(isnull(@broker_id,-1) AS VARCHAR)
			UNION ALL
			SELECT 'generator_id' ,cast(isnull(@generator_id,-1) AS VARCHAR)
			UNION ALL
			SELECT 'gis_cert_number' ,cast(isnull(@gis_cert_number,1) AS VARCHAR)
			UNION ALL
			SELECT 'gis_value_id' ,cast(isnull(@gis_value_id,-1) AS VARCHAR)
			UNION ALL
			SELECT 'gis_cert_date' ,isnull(cast(@gis_cert_date AS VARCHAR),'1900-1-1')
			UNION ALL
			SELECT 'gen_cert_number' ,cast(isnull(@gen_cert_number,-1) AS VARCHAR)
			UNION ALL
			SELECT 'gen_cert_date' ,isnull(cast(@gen_cert_date AS VARCHAR),'1900-1-1')
			UNION ALL
			SELECT 'status_value_id' ,cast(isnull(@status_value_id,-1) AS VARCHAR)
			UNION ALL
			SELECT 'status_date' ,isnull(cast(@status_date AS VARCHAR),'1900-1-1')
			UNION ALL
			SELECT 'assignment_type_value_id' ,cast(isnull(@assignment_type_value_id,-1) AS VARCHAR)
			UNION ALL
			SELECT 'compliance_year' ,cast(isnull(@compliance_year,-1) AS VARCHAR)
			UNION ALL
			SELECT 'state_value_id' ,cast(isnull(@state_value_id,-1) AS VARCHAR)
			UNION ALL
			SELECT 'assigned_date' ,isnull(cast(@assigned_date AS VARCHAR),'1900-1-1')
			UNION ALL
			SELECT 'assigned_by' ,cast(isnull(@assigned_by,-1) AS VARCHAR)
			UNION ALL
			SELECT 'gis_cert_number_to' ,cast(isnull(@gis_cert_number_to,-1) AS VARCHAR)
			UNION ALL
			SELECT 'generation_source' ,cast(isnull(@generation_source,-1) AS VARCHAR)
			UNION ALL
			SELECT 'aggregate_environment' ,cast(isnull(@aggregate_environment,-1) AS VARCHAR)
			UNION ALL
			SELECT 'aggregate_envrionment_comment' ,cast(isnull(@aggregate_envrionment_comment,-1) AS VARCHAR)
			UNION ALL
			SELECT 'rec_price' ,cast(isnull(@rec_price,-1) AS VARCHAR)
			UNION ALL
			SELECT 'rec_formula_id' ,cast(isnull(@rec_formula_id,-1) AS VARCHAR)
			UNION ALL
			SELECT 'rolling_avg' ,cast(isnull(@rolling_avg,'') AS VARCHAR)
			UNION ALL
			SELECT 'certificate_from' ,cast(isnull(@certificate_from,-1) AS VARCHAR)
			UNION ALL
			SELECT 'certificate_to' ,cast(isnull(@certificate_to,-1) AS VARCHAR)
			UNION ALL
			SELECT 'certificate_date' ,isnull(cast(@certificate_date AS VARCHAR),'1900-1-1')
			UNION ALL
			SELECT 'contract_id' ,cast(isnull(@contract_id,-1) AS VARCHAR)
			UNION ALL
			SELECT 'legal_entity' ,cast(isnull(@legal_entity,-1) AS VARCHAR)
			UNION ALL
			SELECT 'bifurcate_leg' ,cast(isnull(@bifurcate_leg,-1) AS VARCHAR)
			UNION ALL
			SELECT 'refrence' ,cast(isnull(@refrence,-1) AS VARCHAR)
			UNION ALL
			SELECT 'source_commodity' ,cast(isnull(@source_commodity,-1) AS VARCHAR)
			UNION ALL
			SELECT 'source_internal_portfolio' ,cast(isnull(@source_internal_portfolio,-1) AS VARCHAR)
			UNION ALL
			SELECT 'source_product' ,cast(isnull(@source_product,-1) AS VARCHAR)
			UNION ALL
			SELECT 'source_internal_desk' ,cast(isnull(@source_internal_desk,-1) AS VARCHAR)
			UNION ALL
			SELECT 'deal_locked' ,cast(isnull(@deal_locked,'') AS VARCHAR)
			UNION ALL
			SELECT 'block_type' ,cast(isnull(@block_type,-1) AS VARCHAR)
			UNION ALL
			SELECT 'block_define_id' ,cast(isnull(@block_define_id,-1) AS VARCHAR)
			UNION ALL
			SELECT 'granularity_id' ,cast(isnull(@granularity_id,-1) AS VARCHAR)
			UNION ALL
			SELECT 'pricing' ,cast(isnull(@pricing,-1) AS VARCHAR)
			UNION ALL
			SELECT 'description4' ,cast(isnull(@description4,-1) AS VARCHAR)
			UNION ALL
			SELECT 'confirm_type' ,cast(isnull(@confirm_type,-1) AS VARCHAR)
			UNION ALL
			SELECT 'unit_fixed_flag' ,cast(isnull(@unit_fixed_flag,-1) AS VARCHAR)
			UNION ALL
			SELECT 'broker_unit_fees' ,cast(isnull(@broker_unit_fees,-1) AS VARCHAR)
			UNION ALL
			SELECT 'broker_fixed_cost' ,cast(isnull(@broker_fixed_cost,-1) AS VARCHAR)
			UNION ALL
			SELECT 'broker_currency_id' ,cast(isnull(@broker_currency_id,-1) AS VARCHAR)
			UNION ALL
			SELECT 'deal_status' ,cast(isnull(@deal_status,-1) AS VARCHAR)
			UNION ALL
			SELECT 'option_settlement_date' ,isnull(cast(@option_settlement_date AS VARCHAR),'1900-1-1')
			UNION ALL
			SELECT 'description4' ,cast(isnull(@description4,-1) AS VARCHAR)
			UNION ALL
			SELECT 'broker' ,cast(isnull(@broker,-1) AS VARCHAR)
			UNION ALL
			SELECT 'blotter' ,cast(isnull(@blotter,-1) AS VARCHAR)
			UNION ALL
			SELECT 'index_group' ,cast(isnull(@index_group,-1) AS VARCHAR)
			UNION ALL
			SELECT 'location' ,cast(isnull(@location,-1) AS VARCHAR)
			UNION ALL
			SELECT 'index' ,cast(isnull(@index,-1) AS VARCHAR)
			UNION ALL
			SELECT 'commodity' ,cast(isnull(@commodity,-1) AS VARCHAR)
			UNION ALL
			SELECT 'comments' ,cast(isnull(@comments,-1) AS VARCHAR)
			UNION ALL
			SELECT 'sub_entity_id' ,cast(isnull(@sub_entity_id,-1) AS VARCHAR)
			UNION ALL
			SELECT 'strategy_entity_id' ,cast(isnull(@strategy_entity_id,-1) AS VARCHAR)
			UNION ALL
			SELECT 'book_entity_id' ,cast(isnull(@book_entity_id,-1) AS VARCHAR)
			
			IF OBJECT_ID('tempdb..#fields_final') IS NOT NULL 
			DROP TABLE #fields_final
			
			CREATE table #fields_final(item VARCHAR(100) COLLATE DATABASE_DEFAULT,variables VARCHAR(1000) COLLATE DATABASE_DEFAULT)
			insert into #fields_final (item,variables) SELECT scsv.item,CASE WHEN scsv.item like '%date%' or scsv.item in ('entire_term_start','entire_term_end') THEN 'ISNULL('+scsv.item + ',''1900-1-1'')' WHEN scsv.item IN ('deal_locked','rolling_avg','option_flag','option_type','option_excercise_type') THEN 'ISNULL('+scsv.item + ','''')' ELSE 'isnull('+scsv.item + ',-1)' END + ' <> ' + ''''+  rtrim(ltrim(f.item_variables)) + '''' FROM dbo.splitcommaseperatedvalues(@update_fields) scsv
			INNER JOIN #fields f ON scsv.item = f.item
			
			DECLARE @update_fields_final VARCHAR(MAX),@call_update INT 
			SET @call_update = 0
			
			SELECT @update_fields_final = STUFF((
							(SELECT ' OR ' + CAST(variables AS VARCHAR(max)) from #fields_final FOR XML PATH(''), root('MyString'), type 
				 ).value('/MyString[1]','varchar(max)')
						), 1, 4, '') 
						
			DECLARE @sql1 varchar(MAX)
			
			CREATE TABLE #result(id INT)
			SET @sql1 = 'insert into #result(id) SELECT 1 FROM   source_deal_header dh WHERE (' + @update_fields_final + ') and source_deal_header_id = ' + @source_deal_header_id
			--PRINT @sql1 
			EXEC(@sql1)
			
			if exists(SELECT 1 FROM #result)
			BEGIN
				SET @call_update = 1
			END
			
			IF @update_call = 1
				SET @call_update = 1
			
		
			DECLARE @deal_status_flag INT,@table_name VARCHAR(200) 
			SET @deal_status_flag = 0
						
			IF EXISTS(SELECT 'x' FROM source_deal_header WHERE source_deal_header_id = @source_deal_header_id AND deal_status <> @deal_status)
				SET @deal_status_flag = 1
				
			DECLARE @deal_status_from INT
			SELECT @deal_status_from = sdh.deal_status
			FROM   source_deal_header sdh
			WHERE  sdh.source_deal_header_id = @source_deal_header_id 
			
			
			CREATE TABLE #report_position_deals (source_deal_header_id INT)
			DECLARE @report_position_deals VARCHAR(300)
			SET @process_id=dbo.FNAGetNewID()
			SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id,@process_id)
			--PRINT '@@@@@@@@@@@@@@@@@@@@@@@@@'
			--PRINT @report_position_deals
			--PRINT @user_login_id
			--PRINT @process_id
			--PRINT '@@@@@@@@@@@@@@@@@@@@@@@@@'
			BEGIN TRAN
			--IF NOT EXISTS (
			--	SELECT 1 FROM source_deal_header 
			--	WHERE	source_deal_header_id = @source_deal_header_id 
			--		AND isnull(internal_desk_id,-1) = isnull(@source_internal_desk ,-1)
			--		AND isnull(block_type,-1) = isnull(@block_type,-1)
			--		AND isnull(block_define_id,-1) = isnull(@block_define_id,-1)
			--		and isnull(source_system_book_id1,-1) =isnull(@source_system_book_id1,-1)
			--		AND isnull(source_system_book_id2,-1) =isnull(@source_system_book_id2,-1)
			--		AND isnull(source_system_book_id3,-1) =isnull(@source_system_book_id3,-1)
			--		AND isnull(source_system_book_id4,-1) =isnull(@source_system_book_id4,-1)
			--		AND isnull(physical_financial_flag,-1) =isnull(@physical_financial_flag ,-1)
			--		AND isnull(deal_date,-1) =isnull(@deal_date,-1)
			--		AND isnull(counterparty_id,-1) =isnull(@counterparty_id,-1)
			--		AND isnull(deal_status,-1)=isnull(@deal_status,-1) 
			--		AND isnull(product_id,-1)=isnull(@source_product,-1)
			--)
			--BEGIN

			
				
			--	--SET @sql = 'INSERT INTO ' + @report_position_deals + '(source_deal_header_id,action) SELECT ' + CAST(@source_deal_header_id AS VARCHAR) + ',''u'''
			--	--PRINT @sql 
			--	--EXEC (@sql) 
			--END
			SET @sql = 'SELECT ' + CAST(@source_deal_header_id AS VARCHAR(MAX)) + ' source_deal_header_id,''u'' action into '+ @report_position_deals
			--PRINT'333333333333333333'
			--PRINT @sql 
			--PRINT'333333333333333333'
			EXEC (@sql)
			
			SET @sql = 'INSERT INTO #report_position_deals (source_deal_header_id)
						SELECT DISTINCT source_deal_header_id FROM ' + @report_position_deals 
			--PRINT @sql 
			EXEC (@sql)
			
			
			
				
			SET @new_process_id = REPLACE(newid(),'-','_')	
			SET @table_name = dbo.FNAProcessTableName('deal_status', @user_login_id,@new_process_id)	
			
			EXEC ('CREATE TABLE '+@table_name+'(source_deal_header_id INT,deal_status INT, confirm_status INT)')	

			IF @deal_status_flag = 1
				BEGIN
					SET @sql =' INSERT INTO '+@table_name+' 
							  SELECT '+@source_deal_header_id+',sdh.deal_status,csr.[type]
							  FROM
								source_deal_header sdh 
								LEFT JOIN confirm_status_recent csr ON csr.source_deal_header_id = sdh.source_deal_header_id
							  WHERE
								sdh.source_deal_header_id IN('+@source_deal_header_id+')'	
					EXEC(@sql)			
					
				END					
				
			---##### If status rule is defined, find the rule first			
				
			IF dbo.FNAAppAdminRoleCheck(dbo.FNADBUser()) = 0 AND @deal_rules IS NOT NULL AND @deal_status_from <> @deal_status --dbo.FNADBUser() <> (SELECT dbo.FNAAppAdminID())
			BEGIN
				IF NOT EXISTS (
					SELECT dsp.deal_status_ID
					FROM   deal_status_privileges dsp
					       LEFT JOIN application_role_user aru ON  dsp.role_id = aru.role_id
					       LEFT JOIN application_users au ON  aru.user_login_id = au.user_login_id
					       INNER JOIN deal_status_privilege_mapping dspm ON  dspm.deal_status_privilege_mapping_id = dsp.deal_status_ID
					WHERE  (dsp.[user_id] = dbo.FNADBUser() OR au.user_login_id = dbo.FNADBUser() )
					       AND (dspm.from_status_value_id = @deal_status_from OR dspm.from_status_value_id IS NULL)
					GROUP BY dspm.to_status_value_id, dsp.deal_status_ID
					HAVING dspm.to_status_value_id IN (@deal_status) OR dspm.to_status_value_id IS NULL
				)
				BEGIN
					EXEC spa_ErrorHandler -1,
					     'Source Deal Header table',
					     'spa_sourcedealheader',
					     'DB Error',
					     'Error',
					     'The deal status selected does not have privilege for the operation.',
					     ''
					ROLLBACK
					RETURN 
				END
			END 
						
				
			---##### If status rule is defined, find the rule first
		
					
				
			--DECLARE @confirm_type_check INT ,@confirm_status_saved INT 	
			--SELECT TOP 1 @confirm_type_check = [TYPE] FROM confirm_status WHERE source_deal_header_id = @source_deal_header_id ORDER BY update_ts DESC
			--SELECT @confirm_status_saved = value_id from static_data_value where code = @txtConfirmStatus
				
			--if @confirm_type_check <> isnull(@confirm_status_saved,0)
			--	SET @confirm_status_flag = 1
			--	SELECT @confirm_status_flag
				
			UPDATE source_deal_header SET
				source_system_id =@source_system_id,
				deal_id =@deal_id,
				deal_date =@deal_date,	
				--ext_deal_id =@ext_deal_id,
				physical_financial_flag =@physical_financial_flag,
				structured_deal_id =@structured_deal_id,
				counterparty_id =@counterparty_id,
				entire_term_start =@entire_term_start,
				entire_term_end =@entire_term_end,
				source_deal_type_id =@source_deal_type_id,
				deal_sub_type_type_id= @deal_sub_type_type_id,
				option_flag=@option_flag,
				option_type =@option_type,
				option_excercise_type =@option_excercise_type,
				source_system_book_id1 =@source_system_book_id1,
				source_system_book_id2 =@source_system_book_id2,
				source_system_book_id3 =@source_system_book_id3,
				source_system_book_id4 =@source_system_book_id4,
				description1=@description1,
				description2=@description2,
				description3=@description3,
				deal_category_value_id=@deal_category_value_id,
				trader_id=@trader_id,
				internal_deal_type_value_id=@internal_deal_type_value_id,
				internal_deal_subtype_value_id=@internal_deal_subtype_value_id,
				header_buy_sell_flag=@header_buy_sell_flag,
				broker_id = @broker_id,
				aggregate_environment=@aggregate_environment,
				aggregate_envrionment_comment=@aggregate_envrionment_comment,
				rec_price=@rec_price,
				rec_formula_id=@rec_formula_id,
				generator_id=@generator_id, 
				generation_source=@generation_source,		
				status_value_id=@status_value_id, 
				status_date=@status_date,
				assignment_type_value_id=@assignment_type_value_id, 
				compliance_year=@compliance_year, 
				state_value_id=@state_value_id, 
				assigned_date=@assigned_date, 
				assigned_by=@assigned_by,
				rolling_avg=@rolling_avg,
				contract_id=@contract_id,
				legal_entity=@legal_entity,
				reference=@refrence, 
				commodity_id=@commodity,
				internal_portfolio_id=@source_internal_portfolio,
				product_id=@source_product,
				internal_desk_id=@source_internal_desk,
				update_ts=GETDATE(),
				update_user=dbo.FNADBuser(),
				block_type=@block_type,
				block_define_id=@block_define_id,
				granularity_id =@granularity_id,
				pricing=@pricing,
				unit_fixed_flag = @unit_fixed_flag,
				broker_unit_fees = @broker_unit_fees,
				broker_fixed_cost = @broker_fixed_cost,
				broker_currency_id = @broker_currency_id,
				deal_status = @deal_status,
				option_settlement_date=@option_settlement_date,
				--verified_by = NULL,                --Commented because after updating the deal previous trader signoff should remain
				--verified_date = NULL,
				--risk_sign_off_by = NULL,
				--risk_sign_off_date = NULL,
				--back_office_sign_off_by = NULL,
				--back_office_sign_off_date = NULL,
				close_reference_id = @refrence_deal,
				deal_locked = ISNULL(@deal_locked, 'n'),
				timezone_id = @timezone_id
				--deal_reference_type_id = @refrence_deal
			WHERE source_deal_header_id = @source_deal_header_id
		    
		    ----------------------- Start of update transfer and offset deal---------------------------------------
			CREATE TABLE #transfer_offset_deal (source_deal_header_id INT, ref_type TINYINT )
			/*
			INSERT INTO #transfer_offset_deal
			SELECT --transfer deal without offset
				   sdh.source_deal_header_id, 1
			FROM   source_deal_header sdh
			WHERE sdh.close_reference_id = @source_deal_header_id      
			AND sdh.deal_reference_type_id = 12503			       
			UNION --offset deal 
			SELECT 
				   sdh.source_deal_header_id, 2
			FROM   source_deal_header sdh
			WHERE sdh.close_reference_id = @source_deal_header_id  
					  AND sdh.deal_reference_type_id = 12500
			UNION --transfer deal with offset
			SELECT 
				   t.source_deal_header_id, 3
			FROM   source_deal_header sdh
				   INNER JOIN source_deal_header o
						ON  sdh.source_deal_header_id = o.close_reference_id
				   INNER JOIN source_deal_header t
						ON  t.close_reference_id = o.source_deal_header_id
			WHERE sdh.source_deal_header_id = @source_deal_header_id  
			*/
			INSERT INTO #transfer_offset_deal
			SELECT --transfer deal without offset
				   sdh.source_deal_header_id, 1
			FROM   source_deal_header sdh
			INNER JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_id) scsv 
			ON scsv.item = sdh.close_reference_id
			WHERE sdh.deal_reference_type_id = 12503			       
			UNION --offset deal 
			SELECT 
				   sdh.source_deal_header_id, 2
			FROM   source_deal_header sdh
			INNER JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_id) scsv 
			ON scsv.item = sdh.close_reference_id
			WHERE  sdh.deal_reference_type_id = 12500
			UNION --transfer deal with offset
			SELECT t.source_deal_header_id,
				   3
			FROM   source_deal_header sdh
				   INNER JOIN source_deal_header o
						ON  sdh.source_deal_header_id = o.close_reference_id
				   INNER JOIN source_deal_header t
						ON  t.close_reference_id = o.source_deal_header_id
				   INNER JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_id) scsv
						ON  scsv.item = sdh.source_deal_header_id
			--UNION --offset deal of deal transfer
			--SELECT sdh.close_reference_id,
			--	   2
			--FROM   source_deal_header sdh
			--	   INNER JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_id) scsv
			--			ON  scsv.item = sdh.source_deal_header_id
			--WHERE  sdh.deal_reference_type_id = 12503
			
			
			UPDATE sdh
			SET    deal_date = @deal_date,
			       physical_financial_flag = @physical_financial_flag,
			       source_deal_type_id = @source_deal_type_id,
			       deal_sub_type_type_id = @deal_sub_type_type_id,
			       option_flag = @option_flag,
			       option_type = @option_type,
			       option_excercise_type = @option_excercise_type,
			       deal_category_value_id = @deal_category_value_id, 
			       sdh.internal_deal_type_value_id = @internal_deal_type_value_id, 
			       sdh.internal_deal_subtype_value_id = @internal_deal_subtype_value_id,			       
			       header_buy_sell_flag = CASE 
			                                   WHEN tod.ref_type = 3 THEN @header_buy_sell_flag
			                                   ELSE CASE WHEN @header_buy_sell_flag = 's' THEN 'b'
			                                             ELSE 's'
			                                        END
			                              END,
			       broker_id = @broker_id,
			       contract_id = @contract_id,
			       legal_entity = @legal_entity,
			       sdh.internal_desk_id = @source_internal_desk,			       
			       commodity_id = @commodity,
			       internal_portfolio_id = @source_internal_portfolio,
			       product_id = @source_product,
			       block_define_id = @block_define_id,
			       granularity_id = @granularity_id,
			       pricing = @pricing,
			       broker_unit_fees = @broker_unit_fees,
			       broker_fixed_cost = @broker_fixed_cost,
			       broker_currency_id = @broker_currency_id
			       
			       
			FROM   source_deal_header sdh
			       INNER JOIN #transfer_offset_deal tod
			            ON  sdh.source_deal_header_id = tod.source_deal_header_id
		
			       
			----------------------- End of update transfer and offset deal---------------------------------------
				
--			EXEC spa_insert_update_audit @flag,@source_deal_header_id
			--exec spa_user_defined_deal_fields 'i',NULL,13682,'41|42|58','UDF_TU|291204|291203'
			IF @udf_template_id_list IS NOT NULL AND @udf_value_list IS NOT NULL
			EXEC spa_user_defined_deal_fields 'i',NULL,@source_deal_header_id,@udf_template_id_list,@udf_value_list,1
			COMMIT TRAN	
			
			--EXEC spa_update_deal_total_volume @source_deal_header_id
                DECLARE @spa VARCHAR(8000)
                DECLARE @job_name VARCHAR(100)
--		SET @process_id = REPLACE(newid(),'-','_')
		
				
		DECLARE @max_audit_id INT
				
		SELECT @max_audit_id = audit_id FROM source_deal_header_audit WHERE source_deal_header_id = @source_deal_header_id 

		--IF EXISTS 
		--(
		--	SELECT 1 FROM source_deal_header dh
		--	INNER JOIN source_deal_detail dd ON dd.source_deal_header_id = dh.source_deal_header_id 
		--	WHERE NOT EXISTS (		
		--		SELECT 
		--			1
		--		FROM 
		--			source_Deal_header sdh
		--			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
		--			INNER JOIN source_deal_header_audit sdha ON sdha.source_deal_header_id = sdh.source_deal_header_id 
		--			INNER JOIN source_deal_detail_audit sdda  
		--				ON sdda.header_audit_id = sdha.audit_id
		--				AND sdda.source_deal_header_id = sdha.source_deal_header_id 
		--				AND sdda.term_start = sdd.term_start 
		--				AND sdda.term_end = sdd.term_end 
		--				AND sdda.leg = sdd.leg 
		--				AND ISNULL(sdh.internal_desk_id,-1) = ISNULL(sdha.internal_desk_id,-1) 
		--				AND ISNULL(sdh.block_type,-1) = ISNULL(sdha.block_type,-1) 
		--				AND ISNULL(sdh.block_define_id,-1) = ISNULL(sdha.block_define_id,-1) 
		--				AND sdd.term_start = sdda.term_start 
		--				AND sdd.term_end = sdda.term_end 
		--				AND sdd.buy_sell_flag = sdda.buy_sell_flag
		--				AND ISNULL(sdd.deal_volume,0) = ISNULL(sdda.deal_volume,0)
		--				AND sdd.deal_volume_frequency = sdda.deal_volume_frequency
		--				AND ISNULL(sdd.multiplier,1) = ISNULL(sdda.multiplier,1)
		--				AND ISNULL(sdd.volume_multiplier2,1) = ISNULL(sdda.volume_multiplier2,1)
		--				AND ISNULL(sdd.pay_opposite,'x') = ISNULL(sdda.pay_opposite,'x')
						
		--		WHERE sdha.audit_id = @max_audit_id  
		--			AND sdh.source_deal_header_id = dh.source_deal_header_id 
		--			AND sdd.source_deal_detail_id = dd.source_deal_detail_id 
		--	)
		--	AND dh.source_deal_header_id = @source_deal_header_id 
		--)
		--BEGIN
		--	SET @spa = 'spa_update_deal_total_volume ' + CAST(@source_deal_header_id AS VARCHAR) 
		--	SET @job_name = 'spa_update_deal_total_volume_' + @process_id 
		--	EXEC spa_run_sp_as_job @job_name, @spa, 'spa_update_deal_total_volume', @user_login_id 
		--END
		
		   		
		--- For transferred and Offset Deals, select transferred deal is original deal is offset and vice versa.
		EXEC('INSERT INTO '+@report_position_deals+'(source_deal_header_id,action)
			SELECT source_deal_header_id, ''u'' from #transfer_offset_deal'
		)	
			
		EXEC spa_source_deal_detail_hour 'i',@source_deal_header_id
		
		/*
		DECLARE @offset_source_deal_header_id VARCHAR(100) 
				,@transfer_source_deal_header_id VARCHAR(100)
				,@deal_reference_type INT

		SELECT @deal_reference_type = deal_reference_type_id,
		       @offset_source_deal_header_id = source_deal_header_id
		FROM   source_deal_header
		WHERE  close_reference_id = @source_deal_header_id

		IF @deal_reference_type = 12500
		BEGIN
			SELECT @transfer_source_deal_header_id = t.source_Deal_header_id
			FROM   source_deal_header sdh
				   INNER JOIN source_deal_header o
						ON  sdh.source_deal_header_id = o.close_reference_id
				   INNER JOIN source_deal_header t
						ON  t.close_reference_id = o.source_deal_header_id
			WHERE  sdh.source_deal_header_id = @source_deal_header_id
		END
		ELSE IF @deal_reference_type = 12503
		BEGIN
			SET @transfer_source_deal_header_id = @offset_source_deal_header_id
			SET @offset_source_deal_header_id = NULL
		END
	    */
	    
	  
	    
	    IF EXISTS(SELECT 1	FROM   #transfer_offset_deal )		
	    BEGIN
	    	SELECT @source_deal_header_id = ISNULL(
		           @source_deal_header_id + ',',
		           ' '
		       ) +
		       CAST(source_deal_header_id AS VARCHAR(10))
			FROM   #transfer_offset_deal 
	    END
	
		
		--Call Deal Status and Confirmation Rule Trigger
		--EXEC spa_callDealConfirmationRule 'u',@source_deal_header_id,@deal_rules,@confirm_rule,@deal_status_flag,@deal_status,@call_update
		IF @call_update =1 AND @deal_status_flag =1
			EXEC dbo.spa_callDealConfirmationRule @source_deal_header_id, 19502, @new_process_id, @deal_status_flag, NULL, 1, @deal_status_from,NULL
		ELSE IF	@call_update =1 AND @deal_status_flag <> 1
			EXEC dbo.spa_callDealConfirmationRule @source_deal_header_id, 19502, @new_process_id, NULL, NULL, 1, @deal_status_from,NULL
		ELSE IF	@call_update <> 1 AND @deal_status_flag = 1
			EXEC dbo.spa_callDealConfirmationRule @source_deal_header_id, 19503, @new_process_id, 1, NULL, NULL, @deal_status_from,NULL

		IF ISNULL(@call_breakdown,0)=1  
		BEGIN  
			--PRINT 'EXEC spa_deal_position_breakdown ''u'',' + cast(@source_deal_header_id AS VARCHAR(1000))  
			SELECT * into #sdh_table from dbo.FNASplit(@source_deal_header_id, ',')  
			BEGIN TRY
				DECLARE cur_status CURSOR LOCAL FOR
				SELECT item
				FROM #sdh_table

				OPEN cur_status;

				FETCH NEXT FROM cur_status INTO @source_deal_header_id
				WHILE @@FETCH_STATUS = 0
				BEGIN
					INSERT INTO #handle_sp_return_update
					EXEC spa_deal_position_breakdown 'u', @source_deal_header_id   
					FETCH NEXT FROM cur_status INTO @source_deal_header_id
				END
				CLOSE cur_status;
				DEALLOCATE cur_status;	
			END TRY
			BEGIN CATCH
				IF CURSOR_STATUS('local', 'cur_status') >= 0 
				BEGIN
					CLOSE cur_status
					DEALLOCATE cur_status;
				END
			END CATCH
		 
			IF EXISTS(SELECT 1 FROM #handle_sp_return_update WHERE [ErrorCode]='Error')  
			BEGIN  
				DECLARE @msg_err VARCHAR(1000),@recom_err VARCHAR(1000)  
				SELECT   @msg_err=[Message], @recom_err=[Recommendation] FROM #handle_sp_return_update WHERE [ErrorCode]='Error'  

				EXEC spa_ErrorHandler -1,  
				 @call_update,  
				 'spa_sourcedealheader',  
				 'DB Error',  
				 @msg_err,  
				 @recom_err   

				ROLLBACK TRAN  

				RETURN  
			END   
		  
		END  
  

		
		IF EXISTS (SELECT 1 FROM #report_position_deals)
		BEGIN
--			SET @spa = 'spa_update_deal_total_volume ' + CAST(@source_deal_header_id AS VARCHAR) 
			SET @spa = 'spa_update_deal_total_volume NULL,''' + CAST(@process_id AS VARCHAR(50)) + ''''
			SET @job_name = 'update_total_volume_deal_' + @process_id 
			EXEC spa_run_sp_as_job @job_name, @spa, 'update_total_volume', @user_login_id 
		END

		--EXEC spa_source_deal_detail_hour 'i',@source_deal_header_id
		EXEC spa_master_deal_view 'u', @source_deal_header_id
			
			
		SET @spa = 'spa_insert_update_audit ''' + @flag + ''',''' + CAST(@source_deal_header_id AS VARCHAR(MAX)) + '''' + ',''' + ISNULL(@comments, '') + ''''
		SET @job_name = 'spa_insert_update_audit_' + @process_id
		EXEC spa_run_sp_as_job @job_name, @spa,'spa_insert_update_audit' ,@user_login_id
		
		-- alert call
		DECLARE @alert_process_table VARCHAR(300)
		SET @alert_process_table = 'adiha_process.dbo.alert_deal_' + @process_id + '_ad'
		--PRINT('CREATE TABLE ' + @alert_process_table + '(source_deal_header_id VARCHAR(500), deal_date DATETIME, term_start DATETIME, counterparty_id VARCHAR(100), hyperlink1 VARCHAR(5000), hyperlink2 VARCHAR(5000), hyperlink2 VARCHAR(5000), hyperlink4 VARCHAR(5000), hyperlink5 VARCHAR(5000))')
		EXEC('CREATE TABLE ' + @alert_process_table + ' (
		      	source_deal_header_id  VARCHAR(500),
		      	deal_date              DATETIME,
		      	term_start             DATETIME,
		      	counterparty_id        VARCHAR(100),
		      	hyperlink1             VARCHAR(5000),
		      	hyperlink2             VARCHAR(5000),
		      	hyperlink3             VARCHAR(5000),
		      	hyperlink4             VARCHAR(5000),
		      	hyperlink5             VARCHAR(5000)
		      )')
		SET @sql = 'INSERT INTO ' + @alert_process_table + ' (
						source_deal_header_id,
						deal_date,
						term_start,
						counterparty_id
					  )
					SELECT sdh.source_deal_header_id,
						   sdh.deal_date,
						   sdh.entire_term_start,
						   sdh.counterparty_id
					FROM   source_deal_header sdh WHERE sdh.source_deal_header_id IN (' + CAST(@source_deal_header_id AS VARCHAR(2000)) + ')'
		EXEC(@sql)
		--PRINT(@sql)
		EXEC spa_register_event 20601, 20504, @alert_process_table, 1, @process_id
		
		EXEC spa_ErrorHandler 0, 'Source Deal Header  table', 
			'spa_sourcedealheader', 'Success', 
			'Source deal  record successfully updated.', ''
		END TRY
		BEGIN CATCH
			DECLARE @error_no INT
			SET @error_no = ERROR_NUMBER()
			
			IF @@TRANCOUNT > 0
				ROLLBACK TRAN
			
			EXEC spa_ErrorHandler @error_no, 'Source Deal Header  table', 
					'spa_sourcedealheader', 'DB Error', 
					'Failed updating record.', 'Failed Updating Record'
			
		END CATCH
	END
END	
ELSE IF @flag='l'
BEGIN
		SET @sql='
			UPDATE source_deal_header SET
				deal_locked='''+ @deal_locked +'''
				WHERE source_deal_header_id in ('+ @source_deal_header_id +')'
			EXEC(@sql) 
			EXEC spa_insert_update_audit 'u',@source_deal_header_id	
	
				IF @@ERROR <> 0
					BEGIN	
					EXEC spa_ErrorHandler @@ERROR, 'Source Deal Locked Updated', 
			
							'spa_sourcedealheader', 'DB Error', 
			
							'Failed Source Deal Locked Updated.', 'Failed Updating Record'
					END
					ELSE
					BEGIN
					EXEC spa_ErrorHandler 0, 'Source Deal Header  table', 
		
						'spa_sourcedealheader', 'Success', 
		
						'Source deal  record successfully updated.', ''
				    END

END


ELSE IF @flag='r' -- FOR REC TRANS (Update window) get all the record from source_deal_header
BEGIN
	DECLARE @enable_certificate CHAR(1)
	IF EXISTS (SELECT source_deal_header_id_from FROM assignment_audit WHERE source_deal_header_id_from IN (SELECT 
		source_deal_detail_id FROM source_deal_detail WHERE source_deal_header_id=@source_deal_header_id))
		SET @enable_certificate='n'
	ELSE
		SET @enable_certificate='y'

	SELECT 	dh.source_deal_header_id,
		deal_id,
		[dbo].FNAGetGenericDate(sdd.term_start,@user_login_id) term_start,
		[dbo].FNAGetGenericDate(sdd.term_end, @user_login_id) term_end,
		counterparty_id,
		source_deal_type_id,
		sbmp.book_deal_type_map_id,
		sb.source_book_name,
		trader_id,
		sdd.deal_volume,
		sdd.deal_volume_uom_id,
		generator_id,
		template_id,
		CASE source_deal_type_id WHEN 53 THEN rec_price  
		     WHEN 55 THEN fixed_price 
			ELSE NULL END Rec_price,
		CASE source_deal_type_id WHEN 53 THEN fixed_price  
			 WHEN 55 THEN 
			NULL ELSE fixed_price  END fixed_price,
		fixed_price_currency_id,
		header_buy_sell_flag,
		sdd.source_deal_detail_id,
		deal_volume_frequency,
		curve_id,
		certificate_number_from_int,
		certificate_number_to_int,
		@enable_certificate,
		[dbo].FNAGetGenericDate(dh.deal_date, @user_login_id) deal_date,
		[dbo].FNAGetGenericDate(gis.gis_cert_date, @user_login_id) gis_cert_date,
		sdd.settlement_volume,
		sdd.settlement_uom,
		dh.legal_entity
		FROM source_deal_header dh JOIN source_deal_detail sdd ON
		dh.source_deal_header_id=sdd.source_deal_header_id
		LEFT OUTER JOIN source_system_book_map sbmp ON dh.source_system_book_id1 = sbmp.source_system_book_id1 AND 
        	dh.source_system_book_id2 = sbmp.source_system_book_id2 AND dh.source_system_book_id3 = sbmp.source_system_book_id3 AND 
	        dh.source_system_book_id4 = sbmp.source_system_book_id4 JOIN source_book sb ON sb.source_book_id=dh.source_system_book_id1
		LEFT OUTER JOIN gis_certificate gis ON gis.source_deal_header_id=sdd.source_deal_detail_id
		WHERE dh.source_deal_header_id=@source_deal_header_id
				
END
ELSE IF @flag='b' -- FOR REC TRANS window, Update the source_deal_header table
BEGIN
	BEGIN TRAN
					
	IF EXISTS (SELECT deal_id FROM source_deal_header WHERE deal_id=@deal_id AND source_deal_header_id<>@source_deal_header_id) 
	BEGIN
			ROLLBACK TRAN
			EXEC spa_ErrorHandler 1, 'Source Deal Detail Temp Table', 
						'spa_getXml', 'DB Error', 
						'Duplicated Reference ID found, please check RefId and re-create it.','Duplicated Reference ID found, please check RefId and re-create it.'
			RETURN
	
	END

	IF @source_deal_type_id=53 
	BEGIN
		UPDATE source_deal_header 
			SET deal_id=@deal_id, 
			counterparty_id=@counterparty_id,
			trader_id=@trader_id,
			header_buy_sell_flag=@header_buy_sell_flag,
			rec_price=@rec_price,
			generator_id=@generator_id
			WHERE source_deal_header_id = @source_deal_header_id
	END
	ELSE
	BEGIN
		UPDATE source_deal_header 
			SET deal_id=@deal_id, 
			counterparty_id=@counterparty_id,
			trader_id=@trader_id,
			header_buy_sell_flag=@header_buy_sell_flag,
			generator_id=@generator_id
			WHERE source_deal_header_id = @source_deal_header_id
	END					
	
IF @certificate_from IS NOT NULL AND @certificate_to IS NOT NULL
BEGIN



	UPDATE gis_certificate
	SET  gis_certificate_number_from=dbo.FNACertificateRule(cr.cert_rule,rg.generator_id,@certificate_from,sdh.deal_date),
	  gis_certificate_number_to=dbo.FNACertificateRule(cr.cert_rule,rg.generator_id,@certificate_to,sdh.deal_date),
       	  certificate_number_from_int=@certificate_from,
	  certificate_number_to_int=@certificate_to,
	  gis_cert_date=@certificate_date
       	FROM
		source_deal_header sdh	JOIN source_deal_detail sdd ON sdh.source_deal_header_id=sdd.source_deal_header_id 
		INNER JOIN rec_generator rg 
		ON sdh.generator_id = RG.generator_id     
		INNER JOIN certificate_rule cr ON
		rg.gis_value_id=cr.gis_id JOIN
		gis_certificate gis ON gis.source_deal_header_id=sdd.source_deal_detail_id
	WHERE
		sdh.source_deal_header_id=@source_deal_header_id  

	IF NOT EXISTS (SELECT * FROM gis_certificate WHERE source_deal_header_id IN(SELECT source_deal_detail_id FROM 
	source_deal_detail WHERE source_deal_header_id=@source_deal_header_id))
	BEGIN
		INSERT gis_certificate(source_deal_header_id,gis_certificate_number_from,gis_certificate_number_to,certificate_number_from_int,
		certificate_number_to_int,gis_cert_date)
		SELECT sdd.source_deal_detail_id ,dbo.FNACertificateRule(cr.cert_rule,rg.generator_id,@certificate_from,sdd.term_start),
		dbo.FNACertificateRule(cr.cert_rule,rg.generator_id,@certificate_to,sdd.term_start),@certificate_from,@certificate_to, sdd.term_start 
		FROM certificate_rule cr JOIN rec_generator rg ON rg.gis_value_id=cr.gis_id  AND rg.generator_id=@generator_id
		JOIN source_deal_detail sdd ON sdd.source_deal_header_id=@source_deal_header_id
	END	
	-- UPDATE ASSIGNMENT AUDIT, IF already assigned , FROM REC UPDATE
	DECLARE @cert_total INT
	SET @cert_total=(@certificate_to-@certificate_from) + 1
	
	SELECT assignment_id,assigned_volume,(SELECT SUM(assigned_volume) FROM assignment_audit 
	WHERE source_deal_header_id_from=a.source_deal_header_id_from 
	AND assignment_id <=a.assignment_id)-assigned_volume +  @certificate_from cert_from,
	CASE WHEN assigned_volume <=@cert_total THEN assigned_volume ELSE @cert_total END + @certificate_from -1 Cert_to 
	INTO #temp_assign
	FROM assignment_audit a WHERE a.cert_from IS NULL
	AND source_deal_header_id_from=(SELECT source_deal_detail_id FROM source_deal_detail WHERE 
	source_deal_header_id=@source_deal_header_id)

	UPDATE assignment_audit
	SET cert_from=t.cert_from,
	cert_to=t.cert_to
	FROM assignment_audit a, #temp_assign t
	WHERE a.assignment_id=t.assignment_id

END

	IF @@ERROR <> 0
					BEGIN	
					EXEC spa_ErrorHandler @@ERROR, 'Source Deal Header  table', 
			
							'spa_sourcedealheader', 'DB Error', 
			
							'Failed updating record.', 'Failed Updating Record'
					ROLLBACK TRAN
					END
					ELSE
					BEGIN
					EXEC spa_ErrorHandler 0, 'Source Deal Header  table', 
		
						'spa_sourcedealheader', 'Success', 
		
						'Source deal  record successfully updated.', ''
					COMMIT TRAN	
					END
END
ELSE IF @flag='d'
BEGIN
		
	 DECLARE @delete_deals_table VARCHAR(100)
	 	
	 SET @delete_deals_table = dbo.FNAProcessTableName('delete_deals', @user_login_id,@process_id)
		
	/***************************************************Validation START*************************************************/
	
	IF @delete_deals_table IS NOT NULL
	BEGIN
	
		SET @sql_Select = 'UPDATE ddt
							SET ddt.Status=CASE WHEN fld.source_deal_header_id IS NOT NULL OR sdh.source_deal_header_id IS NOT NULL  OR sdh1.source_deal_header_id IS NOT NULL THEN  ''Error'' ELSE ''Success'' END,
								ddt.description=CASE WHEN fld.source_deal_header_id IS NOT NULL THEN ''Deal ''+CAST(fld.source_deal_header_id AS VARCHAR)+'' cannot be deleted. It is mapped to a hedging relationship.''
												   WHEN sdh.source_deal_header_id IS NOT NULL THEN ''Deal ''+CAST(sdh.source_deal_header_id AS VARCHAR)+'' cannot be deleted. Please delete the transferred/offset deal first.''
												   WHEN sdh1.source_deal_header_id IS NOT NULL THEN ''Deal ''+CAST(sdh1.source_deal_header_id AS VARCHAR)+''  deal is locked. Please unlock it to delete.''
											 ELSE '''' END	   
							FROM  '+@delete_deals_table+'	ddt 
								 INNER JOIN source_deal_header sdh2 ON sdh2.source_deal_header_id=ddt.source_deal_header_id
								 LEFT JOIN fas_link_detail fld ON ddt.source_deal_header_id = fld.source_deal_header_id
								 LEFT JOIN source_deal_header sdh ON ddt.source_deal_header_id = sdh.close_reference_id AND sdh.deal_reference_type_id =12503
								 LEFT JOIN source_deal_header sdh1 ON ddt.source_deal_header_id = sdh1.source_deal_header_id AND sdh1.deal_locked=''y'''
						 
		EXEC(@sql_Select)						 
	END
	ELSE
	BEGIN
	
	
		IF EXISTS(SELECT 1 FROM source_deal_header sdh 
						INNER JOIN fas_link_detail fld 
							ON sdh.source_deal_header_id = fld.source_deal_header_id
						INNER JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_id) scsv 
							ON sdh.source_deal_header_id = scsv.Item)
			BEGIN
				EXEC spa_ErrorHandler 
						-1																				--error no
						, 'Source Deal Header'															--module
						, 'spa_sourcedealheader'														--area
						, 'DB Error'																	--status
						,'The selected deal cannot be deleted. It is mapped to a hedging relationship.' --message
						, ''																			--recommendation
				RETURN
			END
			ELSE IF EXISTS(		SELECT sdh.deal_reference_type_id--,sdh1.deal_reference_type_id
							FROM   source_deal_header sdh
								   INNER JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_id) 
										scsv
										ON  sdh.close_reference_id = scsv.Item
										AND sdh.deal_reference_type_id IN (12500, 12503)	
								   LEFT JOIN source_deal_header sdh1 ON 
								 sdh1.source_deal_header_id = scsv.item
							WHERE ISNULL(sdh1.deal_reference_type_id, -1) <> 12503)
			BEGIN
				EXEC spa_ErrorHandler 
						-1																							--error no
						, 'Source Deal Header'																		--module
						, 'spa_sourcedealheader'																	--area
						, 'DB Error'																				--status
						,'The selected deal cannot be deleted. Please delete the transferred/offset deal first.'	--message
						, ''																						--recommendation
				RETURN
			END
			ELSE IF EXISTS(SELECT 1
				FROM   source_deal_header sdh
					   INNER JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_id) scsv
							ON  sdh.source_deal_header_id = scsv.Item
				WHERE  sdh.deal_locked = 'y' AND ISNULL(sdh.deal_reference_type_id, -1) NOT IN (12500, 12503)
			)
			BEGIN
				
				EXEC spa_ErrorHandler 
						-1																							--error no
						, 'Source Deal Header'																		--module
						, 'spa_sourcedealheader'																	--area
						, 'DB Error'																				--status
						,'This deal is locked. Please unlock it to delete.'											--message
						, ''																						--recommendation
				RETURN
				
			END
		
			
	END		
	/***************************************************Validation END*************************************************/
	--ELSE
	BEGIN
		IF @delete_deals_table IS NULL
		BEGIN
		
			IF EXISTS (SELECT sdd.source_deal_header_id FROM assignment_audit a 
					INNER JOIN source_deal_detail sdd ON a.source_deal_header_id = sdd.source_deal_detail_id
					LEFT JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_id) scsv_from ON scsv_from.Item = a.source_deal_header_id_from
					LEFT JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_id) scsv ON scsv.Item = a.source_deal_header_id										
					WHERE assigned_volume > 0 AND assigned_by <> 'Auto assigned'
						AND (scsv_from.Item IS NOT NULL OR scsv.Item IS NOT NULL)
				)
			BEGIN
				DECLARE @url VARCHAR(5000)
				DECLARE @source_deal_header_id_from INT
				SELECT  
						@source_deal_header_id_from = MAX(sdh1.source_deal_header_id)
				FROM 
						source_deal_header sdh 
						INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id=sdd.source_deal_header_id
						INNER JOIN assignment_audit assign ON assign.source_deal_header_id=sdd.source_deal_detail_id
						INNER JOIN source_deal_detail sdd1 ON assign.source_deal_header_id_from=sdd1.source_deal_detail_id 
						INNER JOIN source_deal_header sdh1 ON sdh1.source_deal_header_id=sdd1.source_deal_header_id
				WHERE 
					sdh.source_deal_header_id = @source_deal_header_id

				SET @url = '<a href="../../dev/spa_html.php?spa=exec spa_create_lifecycle_of_recs ''' 
							+ [dbo].FNAGetGenericDate(GETDATE(),@user_login_id) + ''',NULL,' 
							+ CAST(ISNULL(@source_deal_header_id_from,@source_deal_header_id) AS VARCHAR) + '">Click here...</a>'
				
				SET @url = 'Deal ID: ' + CAST(@source_deal_header_id AS VARCHAR) + ' is already assigned, Please remove all the assign deals first to delete this deal.<br> Please view this report ' + @url
				EXEC spa_ErrorHandler 
						-1							--error no
						, 'Source Deal Header'		--module
						, 'spa_sourcedealheader'	--area
						, 'DB Error'				--status
						, @url						--message
						, ''						--recommendation
				RETURN
			END
			END
		BEGIN TRY
			BEGIN TRAN

			--using LEFT JOIN here, as some deals have no entry in source_deal_detail (might be due to previous buggy deletes)
			CREATE TABLE #temp_deal_delete(source_deal_detail_id INT,source_deal_header_id INT)
			
			
			IF @delete_deals_table IS NULL
			BEGIN 
					INSERT INTO #temp_deal_delete 
						SELECT source_deal_detail_id, a.Item AS source_deal_header_id 
						FROM 
							dbo.SplitCommaSeperatedValues(@source_deal_header_id) a
							LEFT JOIN source_deal_detail sdd ON a.Item = sdd.source_deal_header_id
						UNION -- Delete offset deal also
						SELECT sdd.source_deal_detail_id,
						       sdh.close_reference_id
						FROM   source_deal_header sdh
						INNER JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_id) scsv ON  sdh.source_deal_header_id = scsv.Item
						INNER JOIN source_deal_header sdho
				            ON  sdh.close_reference_id = sdho.source_deal_header_id
				            AND sdho.deal_reference_type_id = 12500
						INNER JOIN source_deal_detail sdd ON  sdd.source_deal_header_id = sdho.source_deal_header_id
					
						DECLARE @source_deal_header_id_offset VARCHAR(1000)
						SELECT @source_deal_header_id_offset = case when @source_deal_header_id_offset IS NULL THEN '' ELSE @source_deal_header_id_offset + ',' END + cast(sdh.source_deal_header_id AS VARCHAR)
							FROM 
								dbo.SplitCommaSeperatedValues(@source_deal_header_id) a
								LEFT JOIN source_deal_header sdh On sdh.close_reference_id=a.Item AND sdh.deal_reference_type_id=12500
								LEFT JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id	
						
						--IF EXISTS(select 1 from #temp_deal_delete) 		
						--BEGIN								
						--	SELECT @source_deal_header_id = ISNULL(@source_deal_header_id + ',', '') 
						--		+ CAST(tdd.source_deal_header_id AS VARCHAR(10))
						--	FROM   (
						--			SELECT DISTINCT source_deal_header_id
						--			FROM   #temp_deal_delete
						--		) tdd
						--END		
			END 				
			ELSE
			BEGIN
				SET @sql_Select='
						INSERT INTO #temp_deal_delete 
						SELECT source_deal_detail_id, a.source_deal_header_id AS source_deal_header_id 
						FROM 
							'+@delete_deals_table+' a
							LEFT JOIN source_deal_detail sdd ON a.source_deal_header_id = sdd.source_deal_header_id
						UNION
						SELECT source_deal_detail_id, sdh.source_deal_header_id AS source_deal_header_id 
						FROM 
							'+@delete_deals_table+' a
							LEFT JOIN source_deal_header sdh On sdh.close_reference_id=a.source_deal_header_id AND sdh.deal_reference_type_id=12500
							LEFT JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id'
							
							
							
				EXEC(@sql_Select)
			END
			
			
			
			EXEC spa_callDealConfirmationRule @source_deal_header_id,19508,NULL,NULL,NULL

					
			DELETE assignment_audit FROM assignment_audit a 
			INNER JOIN #temp_deal_delete d ON a.source_deal_header_id_from = d.source_deal_detail_id 
												AND assigned_volume = 0
												
			DELETE ua
			FROM assignment_audit ua
			INNER JOIN #temp_deal_delete d ON ua.source_deal_header_id = d.source_deal_detail_id
		
			DELETE unassignment_audit FROM unassignment_audit a 
			INNER JOIN #temp_deal_delete d ON a.source_deal_header_id_from = d.source_deal_detail_id 
												AND assigned_volume = 0
		
			DELETE ua
			FROM unassignment_audit ua
			INNER JOIN #temp_deal_delete d ON ua.source_deal_header_id = d.source_deal_detail_id
			
			DELETE ua
			FROM gis_certificate ua
			INNER JOIN #temp_deal_delete d ON ua.source_deal_header_id = d.source_deal_detail_id

			--udf records to respective delete table
			INSERT INTO [dbo].[delete_user_defined_deal_fields](
				 [udf_deal_id],[source_deal_header_id],[udf_template_id],
				 [udf_value],[create_user],[create_ts],[update_user],[update_ts]
				)
			SELECT udf.[udf_deal_id], udf.[source_deal_header_id], udf.[udf_template_id],
				   udf.[udf_value],dbo.FNADBUser() [create_user],GETDATE() [create_ts],[update_user],udf.[update_ts]
			FROM [dbo].[user_defined_deal_fields] udf 
			INNER JOIN (SELECT DISTINCT source_deal_header_id FROM #temp_deal_delete) d ON udf.source_deal_header_id = d.source_deal_header_id
			
			--INSERT INTO [delete_user_defined_deal_detail_fields]
			
			INSERT INTO [dbo].[delete_user_defined_deal_detail_fields] (
						 [udf_deal_id],[source_deal_detail_id],[udf_template_id],
						 [udf_value],[create_user],[create_ts],[update_user],[update_ts])
			SELECT uddf.udf_deal_id, uddf.source_deal_detail_id, uddf.udf_template_id,
				   uddf.udf_value, uddf.create_user, uddf.create_ts, uddf.update_user,
				   uddf.update_ts
			FROM [user_defined_deal_detail_fields] uddf
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = uddf.source_deal_detail_id
			INNER JOIN (SELECT DISTINCT source_deal_header_id FROM #temp_deal_delete) d ON sdd.source_deal_header_id = d.source_deal_header_id
			
			DELETE udf 
			FROM user_defined_deal_fields udf 
			INNER JOIN #temp_deal_delete d ON udf.source_deal_header_id = d.source_deal_header_id
			
			DELETE udf 
			FROM user_defined_deal_detail_fields udf 
			INNER JOIN #temp_deal_delete d ON udf.source_deal_detail_id = d.source_deal_detail_id
			
			DELETE udf 
			FROM deal_exercise_detail udf 
			INNER JOIN #temp_deal_delete d ON udf.source_deal_detail_id = d.source_deal_detail_id
				
			DELETE udf 
			FROM deal_exercise_detail udf 
			INNER JOIN #temp_deal_delete d ON udf.exercise_deal_id = d.source_deal_detail_id
				
			DELETE udf 
			FROM confirm_status_recent udf 
			INNER JOIN #temp_deal_delete d ON udf.source_deal_header_id = d.source_deal_header_id
			
			DELETE udf 
			FROM confirm_status udf 
			INNER JOIN #temp_deal_delete d ON udf.source_deal_header_id = d.source_deal_header_id
			
			DELETE udf 
			FROM first_day_gain_loss_decision udf 
			INNER JOIN  #temp_deal_delete d ON udf.source_deal_header_id = d.source_deal_header_id

			DELETE udf 
			FROM deal_tagging_audit udf 
			INNER JOIN  #temp_deal_delete d ON udf.source_deal_header_id = d.source_deal_header_id
			
			/********************************************************************************************/
			
			--commented block as deal cannot be deleted as deal_id column has been removed from calc_invoice_volume_recorder
--			DELETE calc_invoice_volume_recorder
--			FROM calc_invoice_volume_recorder civr
--			INNER JOIN #temp_deal_delete d ON civr.deal_id = d.source_deal_detail_id
--			
--			DELETE calc_invoice_volume_recorder_arch1
--			FROM calc_invoice_volume_recorder_arch1 civr
--			INNER JOIN #temp_deal_delete d ON civr.deal_id = d.source_deal_detail_id
--			
--			DELETE calc_invoice_volume_recorder_arch2
--			FROM calc_invoice_volume_recorder_arch2 civr
--			INNER JOIN #temp_deal_delete d ON civr.deal_id = d.source_deal_detail_id
--			
--			DELETE calc_invoice_volume_variance
--			FROM calc_invoice_volume_variance civv
--			INNER JOIN #temp_deal_delete d ON civv.deal_id = d.source_deal_detail_id
--			
--			DELETE calc_invoice_volume_variance_arch1
--			FROM calc_invoice_volume_variance_arch1 civv
--			INNER JOIN #temp_deal_delete d ON civv.deal_id = d.source_deal_detail_id
--			
--			DELETE calc_invoice_volume_variance_arch2
--			FROM calc_invoice_volume_variance_arch2 civv
--			INNER JOIN #temp_deal_delete d ON civv.deal_id = d.source_deal_detail_id
			
			DELETE deal_attestation_form
			FROM deal_attestation_form daf
			INNER JOIN #temp_deal_delete d ON daf.source_deal_detail_id = d.source_deal_detail_id
			
			DELETE embedded_deal
			FROM embedded_deal ed
			INNER JOIN #temp_deal_delete d ON ed.source_deal_header_id = d.source_deal_header_id
			
			DELETE inventory_cost_override
			FROM inventory_cost_override ico
			INNER JOIN #temp_deal_delete d ON ico.source_deal_header_id = d.source_deal_header_id
			
			DELETE source_deal_detail_lagging
			FROM source_deal_detail_lagging sddlag
			INNER JOIN #temp_deal_delete d ON sddlag.source_deal_header_id = d.source_deal_header_id
			/********************************************************************************************/

		
			
			
			DECLARE @report_position_process_id VARCHAR(500)
			SET @report_position_process_id = REPLACE(newid(),'-','_')

			SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id,@report_position_process_id)
			EXEC ('CREATE TABLE ' + @report_position_deals + '( source_deal_header_id INT, action CHAR(1))')
				
			--print('insert into ' + @report_position_deals + '( source_deal_header_id, action) select source_deal_header_id,''d'' [action] from #temp_deal_delete ')
			exec('insert into ' + @report_position_deals + '( source_deal_header_id, action) select source_deal_header_id,''d'' [action] from #temp_deal_delete ')
			
		
			exec dbo.spa_maintain_transaction_job @report_position_process_id,7,null,@user_login_id
					
			DELETE sddh 
			FROM source_deal_detail_hour sddh INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id=sddh.source_deal_detail_id
			INNER JOIN #temp_deal_delete d ON sdd.source_deal_header_id = d.source_deal_header_id		
			
			--DELETE rhpd 
			--FROM report_hourly_position_deal rhpd 
			--INNER JOIN #temp_deal_delete d ON rhpd.source_deal_header_id = d.source_deal_header_id
			 
			--DELETE rhpf 
			--FROM report_hourly_position_profile rhpf 
			--INNER JOIN #temp_deal_delete d ON rhpf.source_deal_header_id = d.source_deal_header_id 
		
			--DELETE rhpd 
			--FROM report_hourly_position_breakdown rhpd 
			--INNER JOIN #temp_deal_delete d ON rhpd.source_deal_header_id = d.source_deal_header_id 

			DELETE dpbd
			FROM deal_position_break_down dpbd 
			INNER JOIN #temp_deal_delete d ON dpbd.source_deal_header_id = d.source_deal_header_id
			 

			insert into [dbo].[delete_source_deal_header]
				([source_deal_header_id],[source_system_id],[deal_id],[deal_date]
				,[ext_deal_id],[physical_financial_flag],[structured_deal_id]
				,[counterparty_id],[entire_term_start],[entire_term_end]
				,[source_deal_type_id],[deal_sub_type_type_id],[option_flag]
				,[option_type],[option_excercise_type],[source_system_book_id1]
				,[source_system_book_id2],[source_system_book_id3],[source_system_book_id4]
				,[description1],[description2],[description3],[deal_category_value_id]
				,[trader_id],[internal_deal_type_value_id],[internal_deal_subtype_value_id]
				,[template_id],[header_buy_sell_flag],[broker_id],[generator_id],[status_value_id]
				,[status_date],[assignment_type_value_id],[compliance_year],[state_value_id]
				,[assigned_date],[assigned_by],[generation_source],[aggregate_environment]
				,[aggregate_envrionment_comment],[rec_price],[rec_formula_id],[rolling_avg]
				,[contract_id],[create_user],[create_ts],[update_user],[update_ts],[legal_entity]
				,[internal_desk_id],[product_id],[internal_portfolio_id],[commodity_id]
				,[reference],[deal_locked],[close_reference_id],[block_type],[block_define_id]
				,[granularity_id],[Pricing],[deal_reference_type_id],[unit_fixed_flag]
				,[broker_unit_fees],[broker_fixed_cost],[broker_currency_id],[deal_status]
				,[term_frequency],[option_settlement_date],[verified_by],[verified_date]
				,[risk_sign_off_by],[risk_sign_off_date],[back_office_sign_off_by]
				,[back_office_sign_off_date],[book_transfer_id],[confirm_status_type],delete_ts,delete_user,timezone_id)
			SELECT 
				sdh.[source_deal_header_id],sdh.[source_system_id],sdh.[deal_id],sdh.[deal_date]
				,sdh.[ext_deal_id],sdh.[physical_financial_flag],sdh.[structured_deal_id]
				,sdh.[counterparty_id],sdh.[entire_term_start],sdh.[entire_term_end]
				,sdh.[source_deal_type_id],sdh.[deal_sub_type_type_id],sdh.[option_flag]
				,sdh.[option_type],sdh.[option_excercise_type],sdh.[source_system_book_id1]
				,sdh.[source_system_book_id2],sdh.[source_system_book_id3],sdh.[source_system_book_id4]
				,sdh.[description1],sdh.[description2],sdh.[description3],sdh.[deal_category_value_id]
				,sdh.[trader_id],sdh.[internal_deal_type_value_id],sdh.[internal_deal_subtype_value_id]
				,sdh.[template_id],sdh.[header_buy_sell_flag],sdh.[broker_id],sdh.[generator_id],sdh.[status_value_id]
				,sdh.[status_date],sdh.[assignment_type_value_id],sdh.[compliance_year],sdh.[state_value_id]
				,sdh.[assigned_date],sdh.[assigned_by],sdh.[generation_source],sdh.[aggregate_environment]
				,sdh.[aggregate_envrionment_comment],sdh.[rec_price],sdh.[rec_formula_id],sdh.[rolling_avg]
				,sdh.[contract_id],sdh.[create_user], sdh.[create_ts],[update_user],sdh.[update_ts],sdh.[legal_entity]
				,sdh.[internal_desk_id],sdh.[product_id],sdh.[internal_portfolio_id],sdh.[commodity_id]
				,sdh.[reference],sdh.[deal_locked],sdh.[close_reference_id],sdh.[block_type],sdh.[block_define_id]
				,sdh.[granularity_id],sdh.[Pricing],sdh.[deal_reference_type_id],sdh.[unit_fixed_flag]
				,sdh.[broker_unit_fees],sdh.[broker_fixed_cost],sdh.[broker_currency_id],5611--sdh.[deal_status]
				,sdh.[term_frequency],sdh.[option_settlement_date],sdh.[verified_by],sdh.[verified_date]
				,sdh.[risk_sign_off_by],sdh.[risk_sign_off_date],sdh.[back_office_sign_off_by]
				,sdh.[back_office_sign_off_date],sdh.[book_transfer_id],sdh.[confirm_status_type],GETDATE() [delete_ts],dbo.FNADBUser() [delete_user]
				,sdh.timezone_id
			  FROM [dbo].[source_deal_header] sdh 
			  INNER JOIN (SELECT DISTINCT source_deal_header_id FROM #temp_deal_delete) d ON sdh.source_deal_header_id = d.source_deal_header_id
--			INNER JOIN #temp_deal_delete d ON sdh.source_deal_header_id = d.source_deal_header_id

			insert into [dbo].[delete_source_deal_detail] (
				[source_deal_detail_id],[source_deal_header_id]
				,[term_start],[term_end],[Leg],[contract_expiration_date]
				,[fixed_float_leg],[buy_sell_flag],[curve_id],[fixed_price]
				,[fixed_price_currency_id],[option_strike_price],[deal_volume]
				,[deal_volume_frequency],[deal_volume_uom_id],[block_description]
				,[deal_detail_description],[formula_id],[volume_left],[settlement_volume]
				,[settlement_uom],[create_user],[create_ts],[update_user],[update_ts]
				,[price_adder],[price_multiplier],[settlement_date],[day_count_id]
				,[location_id],[meter_id],[physical_financial_flag],[Booked]
				,[process_deal_status],[fixed_cost],[multiplier],[adder_currency_id]
				,[fixed_cost_currency_id],[formula_currency_id],[price_adder2]
				,[price_adder_currency2],[volume_multiplier2],[total_volume]
				,[pay_opposite],[capacity],delete_ts,delete_user)
			SELECT 
				sdd.[source_deal_detail_id],sdd.[source_deal_header_id]
				,sdd.[term_start],sdd.[term_end],sdd.[Leg],sdd.[contract_expiration_date]
				,sdd.[fixed_float_leg],sdd.[buy_sell_flag],sdd.[curve_id],sdd.[fixed_price]
				,sdd.[fixed_price_currency_id],sdd.[option_strike_price],sdd.[deal_volume]
				,sdd.[deal_volume_frequency],sdd.[deal_volume_uom_id],sdd.[block_description]
				,sdd.[deal_detail_description],sdd.[formula_id],sdd.[volume_left],sdd.[settlement_volume]
				,sdd.[settlement_uom],sdd.[create_user],sdd.[create_ts],sdd.[update_user],sdd.[update_ts]
				,sdd.[price_adder],sdd.[price_multiplier],sdd.[settlement_date],sdd.[day_count_id]
				,sdd.[location_id],sdd.[meter_id],sdd.[physical_financial_flag],sdd.[Booked]
				,sdd.[process_deal_status],sdd.[fixed_cost],sdd.[multiplier],sdd.[adder_currency_id]
				,sdd.[fixed_cost_currency_id],sdd.[formula_currency_id],sdd.[price_adder2]
				,sdd.[price_adder_currency2],sdd.[volume_multiplier2],sdd.[total_volume]
				,sdd.[pay_opposite],sdd.[capacity],GETDATE() [delete_ts],dbo.FNADBUser() [delete_user]
			from [dbo].[source_deal_detail] sdd INNER JOIN #temp_deal_delete d ON sdd.source_deal_detail_id = d.source_deal_detail_id
			
			--delete source_deal_detail from delivery status table.
			DELETE ds 
			FROM delivery_status ds 
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = ds.source_deal_detail_id
			INNER JOIN #temp_deal_delete d ON sdd.source_deal_header_id = d.source_deal_header_id	
			 
			DELETE source_deal_detail 
			from source_deal_detail sdd 
			INNER JOIN #temp_deal_delete d ON sdd.source_deal_detail_id = d.source_deal_detail_id
			
			DELETE source_deal_header 
			FROM source_deal_header sdh 
			INNER JOIN  #temp_deal_delete d ON sdh.source_deal_header_id = d.source_deal_header_id
			 
			--update table deal_voided_in_external with status 'd'
			UPDATE dvie 
			SET tran_status = 'd'
			FROM deal_voided_in_external dvie 
			INNER JOIN  #temp_deal_delete d ON dvie.source_deal_header_id = d.source_deal_header_id
			
			--EXEC spa_compliance_workflow 3, 'd', @source_deal_header_id
			COMMIT TRAN
		

		--	DECLARE @report_position_process_id VARCHAR(500)
			SET @report_position_process_id = REPLACE(newid(),'-','_')

			SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id,@report_position_process_id)
			EXEC ('CREATE TABLE ' + @report_position_deals + '( source_deal_header_id INT, action CHAR(1))')
				
			--print('insert into ' + @report_position_deals + '( source_deal_header_id, action) select source_deal_header_id,''d'' [action] from #temp_deal_delete ')
			exec('insert into ' + @report_position_deals + '( source_deal_header_id, action) select source_deal_header_id,''d'' [action] from #temp_deal_delete ')
			
		-- delete data from position
			exec dbo.spa_maintain_transaction_job @report_position_process_id,7,null,@user_login_id

			EXEC spa_insert_update_audit @flag, @source_deal_header_id, @comments
			
			EXEC spa_compliance_workflow 115, 'd', @source_deal_header_id, NULL, 's', NULL, NULL
				
			EXEC spa_master_deal_view 'd', @source_deal_header_id
			
			IF ISNULL(@call_from_import, 'n') = 'n'  
			BEGIN
				EXEC spa_ErrorHandler 0								--error no
								, 'Source Deal Header'			--module
								, 'spa_sourcedealheader'		--area
								, 'Success'						--status
								, 'Deal deleted successfully.'	--message
								, ''
			END
			
		END TRY
		BEGIN CATCH
			IF ISNULL(@call_from_import, 'n') = 'n'  
			BEGIN
				--PRINT 'Error while deleting deal: ' + ERROR_MESSAGE()
				SET @url = 'Error occuring while deleting deal.'
				EXEC spa_ErrorHandler 
								-1							--error no
								, 'Source Deal Header'		--module
								, 'spa_sourcedealheader'	--area
								, 'DB Error'				--status
								, @url						--message
								, ''
			END
			
			IF @@TRANCOUNT > 0	
				ROLLBACK TRAN
			
			RETURN
		END CATCH

	END

END

ELSE IF @flag='k'
	BEGIN
	
	SET FMTONLY ON	
	SELECT NULL AS [Template],
	       NULL AS [Reference ID],
	       NULL AS [Deal Date],
	       NULL AS [Buy/Sell],
	       NULL AS [Location],
	       NULL AS [Buy/Sell Index],
	       NULL AS [TermFrequency],
	       NULL AS [TermStart],
	       NULL AS [TermEnd],
	       NULL AS [VolumeFrequency],
	       NULL AS [Volume],
	       NULL AS [Volume UOM],
	       NULL AS [Capacity],
	       NULL AS [Price],
	       NULL AS [Fixed Cost],
	       NULL AS [Currency],
	       NULL AS [Formula],
	       NULL AS [Pay Opposite],
	       NULL AS [Counterparty],
	       NULL AS [Broker],
	       NULL AS [Trader],
	       NULL AS [Contract Detail],
	       NULL AS [Strike Price],
	       NULL AS [Price Adder],
	       NULL AS [Volume Multiplier],
	       NULL AS [Price Multiplier],
	       NULL AS [Price Adder2],
	       NULL AS [Adder Currency2],
	       NULL AS [Volume Multiplier2],
	       NULL AS [Generator/Credit Source],
	       --NULL AS [Block Type],
	       NULL AS [Block Definition],
	       NULL AS [Granularity],
	       NULL AS [ID],
	       NULL AS [allow_edit_term],
	       NULL AS [FixedFloat],
	       NULL AS [PhysicalFinancial],
	       NULL AS [Curve Type],
	       NULL AS [Internal Desk Id]
	
	SET FMTONLY OFF	

/*	
	
	SET @sql_Select = 
			'select [Template],[Deal ID],[Deal Date],[Buy/Sell],[Location],[Index],[TermFrequency],[TermStart]
      ,[TermEnd],[VolumeFrequency],[Volume],[UOM],[Price],[Fixed Cost],[Currency],[CptyName] ,[Broker],[Trader],[Contract],
     [Strike Price],[Price Adder],[Multiplier],[Generator],[Block Type],[Block Definition],[Granularity],[ID],[allow_edit_term],
	[FixedFloat],[PhysicalFinancial],[Curve Type]        
    From (
		SELECT  
			dh.source_deal_header_id AS [ID],
			 max(dh.broker_id) AS Broker,		
            max(sdd.leg) as Leg,
            [dbo].FNAGetGenericDate(max(dh.deal_date), '''+@user_login_id+''') as [Deal Date],
			max(case when sdd.buy_sell_flag=''s'' then ''s'' else ''b'' End) as [Buy/Sell],
     		max(case when dh.physical_financial_flag =''p'' then ''Physical''
				else ''Financial''
			End)
			as PhysicalFinancialFlag,     
               max(sdd.curve_id) as [Index],          
			max(case when fixed_price is null then ''NULL'' else cast(fixed_price as varchar) end) [Price],
			max(fixed_cost) [Fixed Cost],
            max(sdd.fixed_price_currency_id) as [Currency],
            max(sdd.deal_volume) as [Volume],
            max(sdd.deal_volume_uom_id)  as [UOM],
            max(sdd.deal_volume_frequency) as [VolumeFrequency],
--            max(t.term_frequency_type) [TermFrequency],
--			NULL [TermFrequency],
			max(dh.term_frequency) [TermFrequency],
            max(dh.deal_id)[Deal ID],
            max(sdd.option_strike_price) [Strike Price],
			max(sdd.price_adder) [Price Adder],
			max(sdd.price_multiplier) [Multiplier],
            max(dh.contract_id) as [Contract],
            max(dh.template_id) as [Template],
			 max(dh.counterparty_id)  CptyName, 
			max(sdd.location_id) [Location],
			MAX(dh.generator_id) [Generator],
			MAX(dh.block_type) [Block Type],
			MAX(dh.block_define_id) [Block Definition],
			MAX(dh.granularity_id) [Granularity],
			MAX(t.allow_edit_term) [allow_edit_term],
		    [dbo].FNAGetGenericDate(min(sdd.term_start), '''+@user_login_id+''') as TermStart, 
			[dbo].FNAGetGenericDate(max(sdd.term_end), '''+@user_login_id+''') As TermEnd, max(source_deal_type.source_deal_type_name) As DealType, 
			max(source_deal_type_1.source_deal_type_name) AS DealSubType, 
		        max(dh.option_flag) As OptionFlag, max(dh.option_type) As OptionType, max(dh.option_excercise_type) As ExcersiceType,		
       
			max(dh.deal_category_value_id) as Category,max(dh.trader_id) as Trader,max(static_data_value1.code) as HedgeItemFlag,
			max(static_data_value2.code) as  HedgeType,
			max(case when header_buy_sell_flag=''s'' and assignment_type_value_id is not null then 
				sdv.code else 	
			case when header_buy_sell_flag=''s'' and assignment_type_value_id is null then
				''Sold'' else ''Banked'' end
			end) AssignType,
			max(t.physical_financial_flag) [PhysicalFinancial],	
			max(td.fixed_float_leg) [FixedFloat],
			max(td.commodity_id)[Curve Type]  
			FROM       source_deal_header dh LEFT OUTER JOIN				
		           source_system_book_map sbmp ON dh.source_system_book_id1 = sbmp.source_system_book_id1 AND 
		           dh.source_system_book_id2 = sbmp.source_system_book_id2 AND dh.source_system_book_id3 = sbmp.source_system_book_id3 AND 
		           dh.source_system_book_id4 = sbmp.source_system_book_id4 LEFT OUTER JOIN
		           source_counterparty ON dh.counterparty_id = source_counterparty.source_counterparty_id LEFT OUTER JOIN
		           source_traders ON dh.trader_id = source_traders.source_trader_id LEFT OUTER JOIN
				   source_deal_type ON dh.source_deal_type_id = source_deal_type.source_deal_type_id LEFT OUTER JOIN
		           source_book ON dh.source_system_book_id1 = source_book.source_book_id 
			LEFT OUTER JOIN source_book source_book_1 ON dh.source_system_book_id2 = source_book_1.source_book_id 
		    LEFT OUTER JOIN source_book source_book_2 ON dh.source_system_book_id3 = source_book_2.source_book_id 
		    LEFT OUTER JOIN source_book source_book_3 ON dh.source_system_book_id4 = source_book_3.source_book_id
		    INNER JOIN #source_system ss ON ss.source_system_id=dh.source_system_id
		     
			LEFT OUTER JOIN  portfolio_hierarchy ON portfolio_hierarchy.entity_id = sbmp.fas_book_id
			LEFT OUTER JOIN fas_strategy ON fas_strategy.fas_strategy_id=portfolio_hierarchy.parent_entity_id
			LEFT OUTER JOIN static_data_value  static_data_value1 ON sbmp.fas_deal_type_value_id=static_data_value1.value_id
			LEFT OUTER JOIN static_data_value  static_data_value2 ON fas_strategy.hedge_type_value_id=static_data_value2.value_id
			LEFT OUTER JOIN contract_group  cg1 ON cg1.contract_id=dh.contract_id
			left join dbo.source_deal_header_template t ON t.template_id=dh.template_id
			left join dbo.source_deal_detail_template td ON td.template_id=td.template_id	
			LEFT OUTER JOIN
		           source_deal_type source_deal_type_1 ON dh.deal_sub_type_type_id = source_deal_type_1.source_deal_type_id LEFT OUTER JOIN
			   fas_link_detail fld ON fld.source_deal_header_id = dh.source_deal_header_id 
			left outer join static_data_value sdv on sdv.value_id=dh.assignment_type_value_id
			left outer join rec_generator rg on rg.generator_id=dh.generator_id
			LEFT OUTER JOIN source_deal_detail sdd ON sdd.source_deal_header_id=dh.source_deal_header_id 
			   )'

		

--	IF @deal_id_from IS NULL AND @deal_id IS NULL --only apply deal filters if deal id not given.
--	BEGIN
--	
--		IF @book_deal_type_map_id IS NOT NULL 
--			SET @sql_Select = @sql_Select + ' AND sbmp.book_deal_type_map_id in( ' + @book_deal_type_map_id + ')'
--	END
--
--    IF @source_deal_header_id IS NOT NULL 
--			SET @sql_Select = @sql_Select + ' AND dh.source_deal_header_id in( ' + @source_deal_header_id + ')'
--	
--	IF @sort_by='l'
--		SET @sql_Select = @sql_Select +' Group BY dh.source_deal_header_id ) aa  order by [Deal Date] desc,id desc '
--	ELSE
--		SET @sql_Select = @sql_Select +' Group BY dh.source_deal_header_id )bb  order by [Deal Date] asc,id asc'

	SET FMTONLY ON	

	EXEC(@sql_Select)
	SET FMTONLY off	
*/


	END
	


ELSE IF @flag='m'
BEGIN
	
	SET @sql_Select = 
			'select [Template],[Reference ID],[Deal Date],[Buy/Sell],[Location],[Buy/Sell Index],[TermFrequency],[TermStart]
      ,[TermEnd],[VolumeFrequency],[Volume],[Volume UOM],[Capacity],[Price],[Fixed Cost],[Currency],[Formula],[Pay Opposite],[Counterparty] ,[Broker],[Trader],[Contract Detail],
     [Strike Price],[Price Adder],[Volume Multiplier],[Price Multiplier],[Price Adder2],[Adder Currency2],[Volume Multiplier2],[Generator/Credit Source],
     --[Block Type],
     [Block Definition],[Granularity],[ID],[allow_edit_term]       
     ,[FixedFloat],[PhysicalFinancial],[Curve Type],[Deal Lock], [Option Flag], [LocationName], [CurveName],[InternalDeskId], [Comments]
	 from (
	SELECT  
			dh.source_deal_header_id AS [ID],
			 max(dh.broker_id) AS Broker,		
            max(sdd.leg) as Leg,
            [dbo].FNAGetGenericDate(max(dh.deal_date), '''+@user_login_id+''') as [Deal Date],
			max(case when sdd.buy_sell_flag=''s'' then ''s'' else ''b'' End) as [Buy/Sell],
     		max(case when dh.physical_financial_flag =''p'' then ''Physical''
				else ''Financial''
			End)
			as PhysicalFinancialFlag,     
            max(sdd.curve_id) as [Buy/Sell Index],
            max(sdd.capacity) as [Capacity],          
			max(case when fixed_price is null then '''' else cast(fixed_price as varchar) end) [Price],
			max(fixed_cost) [Fixed Cost],
            max(sdd.fixed_price_currency_id) as [Currency],
            sdd.formula_id as [Formula],
            MAX(upper(sdd.pay_opposite)) as [Pay Opposite],
            max(sdd.deal_volume) as [Volume],
            max(sdd.deal_volume_uom_id)  as [Volume UOM],
            max(sdd.deal_volume_frequency) as [VolumeFrequency],
--            max(t.term_frequency_type) [TermFrequency],
--			NULL [TermFrequency],
			max(dh.term_frequency) [TermFrequency],
            max(dh.deal_id)[Reference ID],
            max(sdd.option_strike_price) [Strike Price],
			max(sdd.price_adder) [Price Adder],
			max(sdd.multiplier) [Volume Multiplier],
			max(sdd.price_multiplier) [Price Multiplier],
			max(sdd.price_adder2) [Price Adder2],
			sdd.price_adder_currency2 as [Adder Currency2],
			max(sdd.volume_multiplier2) [Volume Multiplier2],
            max(dh.contract_id) as [Contract Detail],
            max(dh.template_id) as [Template],
			 max(dh.counterparty_id)  Counterparty, 
			max(sdd.location_id) [Location],
			MAX(dh.generator_id) [Generator/Credit Source],
			--MAX(dh.block_type) [Block Type],
			MAX(dh.block_define_id) [Block Definition],
			MAX(dh.granularity_id) [Granularity],
			MAX(t.allow_edit_term) [allow_edit_term],
		    [dbo].FNAGetGenericDate(min(sdd.term_start), '''+@user_login_id+''') as TermStart, 
			[dbo].FNAGetGenericDate(max(sdd.term_end), '''+@user_login_id+''') As TermEnd, max(source_deal_type.source_deal_type_name) As DealType, 
			max(source_deal_type_1.source_deal_type_name) AS DealSubType, 
		        max(dh.option_flag) As OptionFlag, max(dh.option_type) As OptionType, max(dh.option_excercise_type) As ExcersiceType,		
       
			max(dh.deal_category_value_id) as Category,max(dh.trader_id) as Trader,max(static_data_value1.code) as HedgeItemFlag,
			max(static_data_value2.code) as  HedgeType,
			max(case when header_buy_sell_flag=''s'' and assignment_type_value_id is not null then 
				sdv.code else 	
			case when header_buy_sell_flag=''s'' and assignment_type_value_id is null then
				''Sold'' else ''Banked'' end
			end) AssignType,
			max(t.physical_financial_flag) [PhysicalFinancial],	
			max(sdd.fixed_float_leg) [FixedFloat],
			max(td.commodity_id)[Curve Type],
			(
				CASE WHEN dh.deal_locked = ''y'' THEN ''y''
				ELSE 
					CASE WHEN dls.id IS NOT NULL THEN
						CASE WHEN DATEADD(mi, dls.hour * 60 + dls.minute, ISNULL(dh.update_ts, dh.create_ts)) < GETDATE() THEN ''y''
						ELSE ''n'' END
					ELSE ''n''
					END
				END
			)as [Deal Lock],
			dh.option_flag [Option Flag],
			case when MAX(source_Major_Location.location_name) is null then '''' else MAX(source_Major_Location.location_name) + '' -> '' end + sml.Location_Name as [LocationName],
			pcd.curve_name as [CurveName],
			MAX(t.internal_desk_id) as [InternalDeskId],
			t.comments [Comments]
			FROM '+CASE WHEN isnull(@deleted_deal,'n')='y' then  'delete_source_deal_header' ELSE 'source_deal_header' END +' dh '+
					CASE WHEN  (@deal_id_from IS  NULL or @deal_id_to IS  NULL) AND @source_deal_header_id IS NOT NULL THEN 
							' inner join #tmp_source_deal_header_id t_dh on t_dh.item=dh.source_deal_header_id '
					ELSE '' END +
			' INNER JOIN ' +
			CASE WHEN  @deal_id_from IS NULL AND @deal_id IS NULL THEN 	' #books ' 	ELSE ' source_system_book_map ' END +
		'
			sbmp ON dh.source_system_book_id1 = sbmp.source_system_book_id1 
			AND dh.source_system_book_id2 = sbmp.source_system_book_id2 
			AND dh.source_system_book_id3 = sbmp.source_system_book_id3 
			AND dh.source_system_book_id4 = sbmp.source_system_book_id4 
			inner JOIN '+CASE WHEN isnull(@deleted_deal,'n')='y' then  'delete_source_deal_detail' ELSE 'source_deal_detail' END +' sdd ON sdd.source_deal_header_id=dh.source_deal_header_id
			LEFT OUTER JOIN source_counterparty ON dh.counterparty_id = source_counterparty.source_counterparty_id 
			LEFT OUTER JOIN source_traders ON dh.trader_id = source_traders.source_trader_id 
			LEFT OUTER JOIN source_deal_type ON dh.source_deal_type_id = source_deal_type.source_deal_type_id 
			LEFT OUTER JOIN source_book ON dh.source_system_book_id1 = source_book.source_book_id 
			LEFT OUTER JOIN source_book source_book_1 ON dh.source_system_book_id2 = source_book_1.source_book_id 
			LEFT OUTER JOIN source_book source_book_2 ON dh.source_system_book_id3 = source_book_2.source_book_id 
			LEFT OUTER JOIN source_book source_book_3 ON dh.source_system_book_id4 = source_book_3.source_book_id
		           
		    --INNER JOIN #source_system ss ON ss.source_system_id=dh.source_system_id
		    
			LEFT OUTER JOIN  portfolio_hierarchy ON portfolio_hierarchy.entity_id = sbmp.fas_book_id
			LEFT OUTER JOIN fas_strategy ON fas_strategy.fas_strategy_id=portfolio_hierarchy.parent_entity_id
			LEFT OUTER JOIN static_data_value  static_data_value1 ON sbmp.fas_deal_type_value_id=static_data_value1.value_id
			LEFT OUTER JOIN static_data_value  static_data_value2 ON fas_strategy.hedge_type_value_id=static_data_value2.value_id
			LEFT OUTER JOIN contract_group  cg1 ON cg1.contract_id=dh.contract_id
			left join dbo.source_deal_header_template t ON t.template_id=dh.template_id  
			left join dbo.source_deal_detail_template td ON td.template_id=td.template_id
			LEFT OUTER JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id
			LEFT JOIN source_Major_Location ON sml.source_Major_Location_Id=source_Major_Location.source_major_location_ID
			left outer join source_price_curve_def pcd on pcd.source_curve_def_id=sdd.curve_id	
			LEFT JOIN (
				SELECT id, deal_type_id, hour, minute
				FROM deal_lock_setup dl
				INNER JOIN application_role_user aru ON dl.role_id = aru.role_id
				WHERE aru.user_login_id = dbo.FNADBUser()
			) dls ON dls.deal_type_id = source_deal_type.source_deal_type_id
						AND ISNULL(dh.deal_locked, ''n'') <> ''y''
			LEFT OUTER JOIN
		           source_deal_type source_deal_type_1 ON dh.deal_sub_type_type_id = source_deal_type_1.source_deal_type_id LEFT OUTER JOIN
			   fas_link_detail fld ON fld.source_deal_header_id = dh.source_deal_header_id 
			left outer join static_data_value sdv on sdv.value_id=dh.assignment_type_value_id
			left outer join rec_generator rg on rg.generator_id=dh.generator_id
			 ' +
			CASE WHEN (@gis_cert_number IS NOT NULL AND @gis_cert_number_to IS NOT NULL) OR (@gis_cert_date IS NOT NULL)
				THEN
					'LEFT OUTER JOIN gis_certificate gis ON gis.source_deal_header_id=sdd.source_deal_detail_id'
				ELSE '' END +
			CASE WHEN (@index_group IS NOT null) OR (@index IS NOT NULL)
				THEN
					'LEFT OUTER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=sdd.curve_id'
				ELSE '' END +
			'		
			   WHERE   1 = 1'


--	IF @deal_id_from IS NULL AND @deal_id IS NULL --only apply deal filters if deal id not given.
--	BEGIN
--	
--		IF @book_deal_type_map_id IS NOT NULL 
--			SET @sql_Select = @sql_Select + ' AND sbmp.book_deal_type_map_id in( ' + @book_deal_type_map_id + ')'
--	END

--    IF @source_deal_header_id IS NOT NULL 
--			SET @sql_Select = @sql_Select + ' AND dh.source_deal_header_id in( ' + @source_deal_header_id + ')'
	
	IF @sort_by='l'
		SET @sql_Select = @sql_Select +' Group BY dh.source_deal_header_id,dls.id,dls.hour,dls.minute,dh.deal_locked, dh.option_flag, dh.update_ts, dh.create_ts,sdd.formula_id,sdd.price_adder2,sdd.price_adder_currency2,sdd.volume_multiplier2,sml.Location_Name,pcd.curve_name,t.comments) aa  order by [Deal Date] desc,id desc '
	ELSE
		SET @sql_Select = @sql_Select +' Group BY dh.source_deal_header_id ,dls.id,dls.hour,dls.minute,dh.deal_locked, dh.option_flag, dh.update_ts, dh.create_ts,sdd.formula_id,sdd.price_adder2,sdd.price_adder_currency2,sdd.volume_multiplier2,sml.Location_Name,pcd.curve_name,t.comments)bb  order by [Deal Date] asc,id asc'

		--PRINT @sql_Select
		EXEC(@sql_Select)


END
IF @flag='n'
BEGIN

	SET @sql_Select = 
			'SELECT [ID],[RefID],[dbo].FNAGetGenericDate(deal_date, '''+@user_login_id+''') as Date,[ExtId],[PhysicalFinancialFlag] ,[CptyName],
					[TermStart] ,[TermEnd] ,[DealType],[DealSubType],[OptionFlag],[OptionType],[ExcersiceType],
					['+ @group1 +'],['+ @group2 +']   ,['+ @group3 +'],['+ @group4 +'],[Desc1],[Desc2],[Desc3],
					[DealCategoryValueId],[TraderName],[HedgeItemFlag],[HedgeType],[AssignType],[legal_entity],
					[deal_locked], [Pricing] 
			FROM (SELECT  distinct 
			dbo.FNAHyperLinkText(10131000, cast(dh.source_deal_header_id as varchar), dh.source_deal_header_id) ID,							
--							dh.source_deal_header_id AS ID,
							dh.deal_id AS RefID,dh.deal_date,
 						  dh.ext_deal_id as ExtId,
					CASE 
					WHEN dh.physical_financial_flag =''p'' THEN ''Physical''
						ELSE ''Financial''
					END	as PhysicalFinancialFlag, 
					source_counterparty.counterparty_name CptyName,[dbo].FNAGetGenericDate(dh.entire_term_start, '''+@user_login_id+''') as TermStart, 
					[dbo].FNAGetGenericDate(dh.entire_term_end, '''+@user_login_id+''') As TermEnd, source_deal_type.source_deal_type_name As DealType, 
					source_deal_type_1.source_deal_type_name AS DealSubType,dh.option_flag As OptionFlag, dh.option_type As OptionType, 
					dh.option_excercise_type As ExcersiceType,source_book.source_book_name As ['+ @group1 +'], 
					source_book_1.source_book_name AS ['+ @group2 +'],source_book_2.source_book_name AS ['+ @group3 +'], 
					source_book_3.source_book_name AS ['+ @group4 +'],dh.description1 As Desc1, dh.description2 As Desc2,
					dh.description3 as Desc3,dh.deal_category_value_id as DealCategoryValueId,source_traders.trader_name as TraderName,
					static_data_value1.code as HedgeItemFlag,static_data_value2.code as  HedgeType,
					CASE 
					WHEN header_buy_sell_flag=''s'' AND assignment_type_value_id is not null 
					THEN sdv.code else 	
					CASE 
					WHEN header_buy_sell_flag=''s'' AND assignment_type_value_id is null 
					THEN ''Sold'' else ''Banked'' end
					END 
				AssignType,dh.legal_entity ,deal_locked,dh.pricing
				,dh.update_ts as [UpdateTS]
				,dh.update_user
			FROM       source_deal_header dh 
			 INNER JOIN ' +
			CASE WHEN  @deal_id_from IS NULL AND @deal_id IS NULL THEN 	' #books ' 	ELSE ' source_system_book_map ' END +
		'
			sbmp ON dh.source_system_book_id1 = sbmp.source_system_book_id1 
			AND dh.source_system_book_id2 = sbmp.source_system_book_id2 
			AND dh.source_system_book_id3 = sbmp.source_system_book_id3 
			AND dh.source_system_book_id4 = sbmp.source_system_book_id4 			
			--INNER JOIN #source_system ss ON ss.source_system_id=dh.source_system_id
			LEFT OUTER JOIN source_counterparty ON dh.counterparty_id = source_counterparty.source_counterparty_id 
			LEFT OUTER JOIN source_traders ON dh.trader_id = source_traders.source_trader_id 
			LEFT OUTER JOIN source_deal_type ON dh.source_deal_type_id = source_deal_type.source_deal_type_id 
			LEFT OUTER JOIN source_book ON dh.source_system_book_id1 = source_book.source_book_id 
			LEFT OUTER JOIN source_book source_book_1 ON dh.source_system_book_id2 = source_book_1.source_book_id 
			LEFT OUTER JOIN source_book source_book_2 ON dh.source_system_book_id3 = source_book_2.source_book_id 
			LEFT OUTER JOIN source_book source_book_3 ON dh.source_system_book_id4 = source_book_3.source_book_id 
			LEFT OUTER JOIN  portfolio_hierarchy ON portfolio_hierarchy.entity_id = sbmp.fas_book_id
			LEFT OUTER JOIN fas_strategy ON fas_strategy.fas_strategy_id=portfolio_hierarchy.parent_entity_id
			LEFT OUTER JOIN static_data_value  static_data_value1 ON sbmp.fas_deal_type_value_id=static_data_value1.value_id
			LEFT OUTER JOIN static_data_value  static_data_value2 ON fas_strategy.hedge_type_value_id=static_data_value2.value_id
		
			LEFT OUTER JOIN source_deal_type source_deal_type_1 ON dh.deal_sub_type_type_id = source_deal_type_1.source_deal_type_id 
			LEFT OUTER JOIN fas_link_detail fld ON fld.source_deal_header_id = dh.source_deal_header_id 
			LEFT OUTER JOIN static_data_value sdv ON sdv.value_id=dh.assignment_type_value_id
			LEFT OUTER JOIN rec_generator rg ON rg.generator_id=dh.generator_id
			
			' +
			CASE WHEN (@gis_cert_number IS NOT NULL AND @gis_cert_number_to IS NOT NULL) OR (@gis_cert_date IS NOT NULL) 
			THEN
				'LEFT OUTER JOIN source_deal_detail sdd ON sdd.source_deal_header_id=dh.source_deal_header_id '
			ELSE '' END +
			
			CASE WHEN (@gis_cert_number IS NOT NULL AND @gis_cert_number_to IS NOT NULL) OR (@gis_cert_date IS NOT NULL)
				THEN
					'LEFT OUTER JOIN gis_certificate gis ON gis.source_deal_header_id=sdd.source_deal_detail_id'
				ELSE '' END +
			'			
			
			   WHERE   1 = 1 '


	--IF ONE deal id is known make the other the same
	IF @deal_id_to IS NULL AND @deal_id_from IS NOT NULL
		SET @deal_id_to = @deal_id_from

	IF @deal_id_from IS NULL AND @deal_id_to IS NOT NULL
		SET @deal_id_from = @deal_id_to

	IF (@deal_id_from IS NOT NULL) AND (@deal_id_to IS NOT NULL) 
		SET @sql_Select = @sql_Select + ' AND dh.source_deal_header_id BETWEEN ' + CAST(@deal_id_from AS VARCHAR)  + ' AND ' + CAST(@deal_id_to AS VARCHAR) 


	IF (@gis_cert_number IS NOT NULL AND @gis_cert_number_to IS NOT NULL)
		SET @sql_Select = @sql_Select +' AND ('+ @gis_cert_number + ' between gis.certificate_number_from_int   
		AND  gis.certificate_number_to_int AND ' +
			@gis_cert_number_to + ' between gis.certificate_number_from_int   
		AND  gis.certificate_number_to_int)'

	IF @deal_id IS NOT NULL 
			SET @sql_Select = @sql_Select + ' AND dh.deal_id like ''' + @deal_id + '%'''

	IF @deal_id_from IS NULL AND @deal_id IS NULL --only apply deal filters if deal id not given.
	BEGIN
	
--		IF @book_deal_type_map_id IS NOT NULL 
--			SET @sql_Select = @sql_Select + ' AND sbmp.book_deal_type_map_id in( ' + @book_deal_type_map_id + ')'

		IF (@deal_date_from IS NOT NULL) AND (@deal_date_to IS NOT NULL) 
			SET @sql_Select = @sql_Select + ' AND dh.deal_date BETWEEN '''+ @deal_date_from + ''' and ''' + @deal_date_to + ''''
		
		IF (@physical_financial_flag IS NOT NULL)
			SET @sql_Select = @sql_Select + ' AND dh.physical_financial_flag='''+@physical_financial_flag+''''
		
		IF (@counterparty_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.counterparty_id='+CAST(@counterparty_id AS VARCHAR)

		IF (@entire_term_start IS NOT NULL)
			SET @sql_Select = @sql_Select+ ' AND dh.entire_term_start='''+@entire_term_start+''''

		IF (@entire_term_end IS NOT NULL)
			SET @sql_Select = @sql_Select+ ' AND dh.entire_term_end='''+@entire_term_end+''''

		IF (@source_deal_type_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.source_deal_type_id='+CAST(@source_deal_type_id  AS VARCHAR)

		IF (@deal_sub_type_type_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.deal_sub_type_type_id='+CAST(@deal_sub_type_type_id  AS VARCHAR)

		IF (@deal_category_value_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.deal_category_value_id='+CAST(@deal_category_value_id  AS VARCHAR)

		IF (@trader_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.trader_id='+CAST(@trader_id  AS VARCHAR)

--		IF (@description1 IS NOT NULL)
--			SET @sql_Select = @sql_Select +' AND dh.description1 like ''%'+@description1+'%'''
--
--		IF (@description2 IS NOT NULL)
--			SET @sql_Select = @sql_Select +' AND dh.description2 like ''%'+@description2+'%'''
--
--		IF (@description3 IS NOT NULL)
--			SET @sql_Select = @sql_Select +' AND dh.description3 like ''%'+@description3+'%'''


--		IF (@description1 IS NOT NULL)
--			SET @sql_Select = @sql_Select +' AND source_book.source_book_id = '+@description1
--
--		IF (@description2 IS NOT NULL)
--			SET @sql_Select = @sql_Select +' AND source_book_1.source_book_id = '+@description2
--
--		IF (@description3 IS NOT NULL)
--			SET @sql_Select = @sql_Select +' AND source_book_2.source_book_id = '+@description3
--
--		IF (@description4 IS NOT NULL)
--			SET @sql_Select = @sql_Select +' AND source_book_3.source_book_id = '+@description4



		IF (@structured_deal_id  IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.structured_deal_id like ''%'+@structured_deal_id +'%'''

		IF (@header_buy_sell_flag IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.header_buy_sell_flag='''+ @header_buy_sell_flag + ''''


		IF (@deal_locked IS NOT NULL )
			SET @sql_Select = @sql_Select + ' AND dh.deal_locked='''+@deal_locked+''''	

		IF (@update_date_from IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.update_ts>='''+CAST(@update_date_from  AS VARCHAR)+''''

		IF (@update_date_to IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.update_ts<='''+CAST(@update_date_to  AS VARCHAR)+''''

		IF (@update_by IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.update_user='''+CAST(@update_by  AS VARCHAR)+''''

	END


		----====Added the following filter for REC deals
		--print 'no' 

	--if one cert is known and other not known make the same		
	IF @gis_cert_number_to IS NULL AND @gis_cert_number IS NOT NULL
		SET @gis_cert_number_to = @gis_cert_number

	IF @gis_cert_number IS NULL AND @gis_cert_number_to IS NOT NULL
		SET @gis_cert_number = @gis_cert_number_to
	
	IF @gis_cert_number IS NULL 
	BEGIN

		IF (@generator_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.generator_id='+CAST(@generator_id  AS VARCHAR)
		IF (@status_value_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.status_value_id='+CAST(@status_value_id  AS VARCHAR)
		IF (@status_date IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.status_date='''+ dbo.FNAGetSQLStandardDate(@status_date) + ''''
		IF (@assignment_type_value_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND isnull(dh.assignment_type_value_id, 5149) ='+CAST(@assignment_type_value_id  AS VARCHAR)
		IF (@compliance_year IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.compliance_year='+CAST(@compliance_year  AS VARCHAR)
		IF (@state_value_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.state_value_id='+CAST(@state_value_id  AS VARCHAR)
		IF (@assigned_date IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.assigned_date='''+ dbo.FNAGetSQLStandardDate(@assigned_date) + ''''
		IF (@assigned_by IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.assigned_by='''+ @assigned_by + ''''
		IF @gis_value_id IS NOT NULL
			SET @sql_Select = @sql_Select +' AND rg.gis_value_id='+ CAST(@gis_value_id AS VARCHAR)
		IF @gen_cert_date IS NOT NULL
			SET @sql_Select = @sql_Select +' AND rg.registration_date='''+ @gen_cert_date +''''
		IF @gen_cert_number IS NOT NULL
			SET @sql_Select = @sql_Select +' AND rg.gis_account_number='''+ @gen_cert_number +''''
		IF @gis_cert_date IS NOT NULL
			SET @sql_Select = @sql_Select +' AND gis.gis_cert_date='''+ @gis_cert_date +''''

	END
	IF @sort_by='l'
		SET @sql_Select = @sql_Select +') aa order by deal_date desc,id desc'
	ELSE
		SET @sql_Select = @sql_Select +')bb order by deal_date asc,id asc'

		--PRINT @sql_Select

		EXEC(@sql_Select)
		--If @@ERROR <> 0

--		Exec spa_ErrorHandler @@ERROR, 'Source Deal Header  table', 

--				'spa_sourcedealheader', 'DB Error', 



--				'Failed to select source deal header record.', ''

--		Else

--		Exec spa_ErrorHandler 0, 'Source Deal Header  table', 

--				'spa_sourcedealheader', 'Success', 

--				'Source deal header record successfully selected.', ''
END
IF @flag='t'
	BEGIN
	SET @sql_Select = 
			'SELECT [ID],[RefID],[dbo].FNAGetGenericDate(deal_date, '''+@user_login_id+''') as [Deal Date],[ExtId],[PhysicalFinancialFlag] as [Physical/Financial Flag] ,
					[CptyName] as [Counterparty],
					[TermStart] ,[TermEnd] ,[DealType],[DealSubType],[OptionFlag],[OptionType],[ExcersiceType],
					['+ @group1 +'],['+ @group2 +']   ,['+ @group3 +'],['+ @group4 +'],[Desc1],[Desc2],[Desc3],
					[DealCategoryValueId] as [Deal Category],[TraderName],[HedgeItemFlag] as [Hedge/Item Flag],[HedgeType],[AssignType],[legal_entity],
					[deal_locked], [Pricing],[Created Date],ConfirmStatus,[Signed Off By],[Sign Off Date] as [Signed Off Date],[Broker],[Comments],[commodity_id]
					

			FROM (
					SELECT  distinct dh.source_deal_header_id AS ID,dh.deal_id AS RefID,dh.deal_date,
 						  dh.ext_deal_id as ExtId,
					CASE 
					WHEN dh.physical_financial_flag =''p'' THEN ''Physical''
						ELSE ''Financial''
					END	as PhysicalFinancialFlag, 
					source_counterparty.counterparty_name CptyName,[dbo].FNAGetGenericDate(dh.entire_term_start, '''+@user_login_id+''') as TermStart, 
					[dbo].FNAGetGenericDate(dh.entire_term_end, '''+@user_login_id+''') As TermEnd, source_deal_type.source_deal_type_name As DealType, 
					source_deal_type_1.source_deal_type_name AS DealSubType,[dbo].FNAGetAbbreviationDef(dh.option_flag) As OptionFlag, [dbo].FNAGetAbbreviationDef(dh.option_type) As OptionType, 
					[dbo].FNAGetAbbreviationDef(dh.option_excercise_type) As ExcersiceType,source_book.source_book_name As ['+ @group1 +'], 
					source_book_1.source_book_name AS ['+ @group2 +'],source_book_2.source_book_name AS ['+ @group3 +'], 
					source_book_3.source_book_name AS ['+ @group4 +'],dh.description1 As Desc1, dh.description2 As Desc2,
					dh.description3 as Desc3,static_data_value3.code as DealCategoryValueId,source_traders.trader_name as TraderName,
					static_data_value1.code as HedgeItemFlag,static_data_value2.code as  HedgeType,
					CASE 
					WHEN dh.header_buy_sell_flag=''s'' AND assignment_type_value_id is not null 
					THEN sdv.code else 	
					CASE 
					WHEN dh.header_buy_sell_flag=''s'' AND assignment_type_value_id is null 
					THEN ''Sold'' else ''Banked'' end
					END 
				AssignType,dh.legal_entity
				,(
					CASE WHEN deal_locked = ''y'' THEN ''Yes''
					ELSE 
						CASE WHEN dls.id IS NOT NULL THEN
							CASE WHEN DATEADD(mi, dls.hour * 60 + dls.minute, ISNULL(dh.update_ts, dh.create_ts)) < GETDATE() THEN ''Yes''
							ELSE ''No'' END
						ELSE ''No''
						END
					END
				) AS deal_locked
				,dh.pricing
				,dh.update_ts as [UpdateTS]
				,dh.update_user		
				,sdv_confirm.code ConfirmStatus
				,[dbo].FNAConvertGenericTimezone(dh.create_ts,'+ISNULL(cast(@time_zone_from AS VARCHAR), 'NULL') +','+ ISNULL(CAST(@time_zone_to AS VARCHAR), 'NULL') + ','''+@user_login_id+''',0) as [Created Date]
				,dh.verified_by [Signed Off By],
				[dbo].FNAGetGenericDate(dh.verified_date,'''+ @user_login_id+''') [Sign Off Date],
				scp.counterparty_name AS [Broker],
				t.comments AS [Comments],
				spcd.commodity_id [commodity_id]				
			FROM '
            + CASE WHEN ISNULL(@deleted_deal,'n')='y' THEN 'delete_source_deal_header' ELSE 'source_deal_header' END + ' dh ' +
			 ' INNER JOIN #books' +
			--CASE WHEN  @deal_id_from IS NULL AND @deal_id IS NULL THEN 	' #books ' 	ELSE ' source_system_book_map ' END +
			'
			sbmp ON dh.source_system_book_id1 = sbmp.source_system_book_id1 
			AND dh.source_system_book_id2 = sbmp.source_system_book_id2 
			AND dh.source_system_book_id3 = sbmp.source_system_book_id3 
			AND dh.source_system_book_id4 = sbmp.source_system_book_id4 			
			--INNER JOIN #source_system ss ON ss.source_system_id=dh.source_system_id
			LEFT OUTER JOIN source_counterparty ON dh.counterparty_id = source_counterparty.source_counterparty_id 
			LEFT OUTER JOIN source_counterparty AS scp ON dh.broker_id = scp.source_counterparty_id 
			LEFT OUTER JOIN source_traders ON dh.trader_id = source_traders.source_trader_id 
			LEFT OUTER JOIN source_deal_type ON dh.source_deal_type_id = source_deal_type.source_deal_type_id 
			LEFT OUTER JOIN source_book ON dh.source_system_book_id1 = source_book.source_book_id 
			LEFT OUTER JOIN source_book source_book_1 ON dh.source_system_book_id2 = source_book_1.source_book_id 
			LEFT OUTER JOIN source_book source_book_2 ON dh.source_system_book_id3 = source_book_2.source_book_id 
			LEFT OUTER JOIN source_book source_book_3 ON dh.source_system_book_id4 = source_book_3.source_book_id 
			LEFT OUTER JOIN  portfolio_hierarchy ON portfolio_hierarchy.entity_id = sbmp.fas_book_id
			LEFT OUTER JOIN fas_strategy ON fas_strategy.fas_strategy_id=portfolio_hierarchy.parent_entity_id
			LEFT OUTER JOIN static_data_value  static_data_value1 ON sbmp.fas_deal_type_value_id=static_data_value1.value_id
			LEFT OUTER JOIN static_data_value  static_data_value2 ON fas_strategy.hedge_type_value_id=static_data_value2.value_id
			LEFT OUTER JOIN static_data_value  static_data_value3 ON static_data_value3.value_id = dh.deal_category_value_id
			LEFT OUTER JOIN static_data_value  static_data_value4 ON static_data_value4.value_id = dh.deal_status
			LEFT OUTER JOIN source_deal_type source_deal_type_1 ON dh.deal_sub_type_type_id = source_deal_type_1.source_deal_type_id 
			LEFT OUTER JOIN fas_link_detail fld ON fld.source_deal_header_id = dh.source_deal_header_id 
			LEFT OUTER JOIN static_data_value sdv ON sdv.value_id=dh.assignment_type_value_id
			LEFT OUTER JOIN rec_generator rg ON rg.generator_id=dh.generator_id
			' +
--			CASE WHEN (@gis_cert_number IS NOT NULL AND @gis_cert_number_to IS NOT NULL) OR (@gis_cert_date IS NOT NULL) 
--			THEN
			' LEFT OUTER JOIN source_deal_detail sdd ON sdd.source_deal_header_id=dh.source_deal_header_id '
--			ELSE '' END 
			+
			CASE WHEN (@gis_cert_number IS NOT NULL AND @gis_cert_number_to IS NOT NULL) OR (@gis_cert_date IS NOT NULL) OR (@location IS NOT NULL) OR (@index_group IS NOT null) OR (@index IS NOT NULL)
			THEN
				'LEFT OUTER JOIN ' +CASE WHEN isnull(@deleted_deal,'n')='y' then  'delete_source_deal_detail' ELSE 'source_deal_detail' END +' sdd ON sdd.source_deal_header_id=dh.source_deal_header_id '
			ELSE '' END +
			CASE WHEN (@gis_cert_number IS NOT NULL AND @gis_cert_number_to IS NOT NULL) OR (@gis_cert_date IS NOT NULL)
				THEN
					' LEFT OUTER JOIN gis_certificate gis ON gis.source_deal_header_id=sdd.source_deal_detail_id'
				ELSE '' END +
			
			--CASE WHEN (@index_group IS NOT null) OR (@index IS NOT NULL)
			--	THEN
					' LEFT OUTER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=sdd.curve_id'
				--ELSE '' END 
				+
			CASE WHEN (@location IS NOT NULL)
				THEN
					' LEFT OUTER JOIN source_minor_location sml ON sml.source_minor_location_id=sdd.location_id'
				ELSE '' END +
			'
			LEFT OUTER JOIN confirm_status_recent csr ON csr.source_deal_header_id = dh.source_deal_header_id
			LEFT OUTER JOIN static_data_value sdv_confirm ON sdv_confirm.value_id = ISNULL(csr.type,17200) 
			LEFT OUTER JOIN dbo.source_deal_header_template t ON t.template_id=dh.template_id  
			LEFT OUTER JOIN dbo.source_deal_detail_template dt ON dt.template_id=dh.template_id
			--LEFT OUTER JOIN source_commodity sc ON sc.source_commodity_id=dt.commodity_id
			LEFT OUTER JOIN static_data_value sdv2 ON sdv2.value_id=dh.block_type
			LEFT JOIN (
				SELECT id, deal_type_id, hour, minute
				FROM deal_lock_setup dl
				INNER JOIN application_role_user aru ON dl.role_id = aru.role_id
				WHERE aru.user_login_id = dbo.FNADBUser()
			) dls ON dls.deal_type_id = source_deal_type.source_deal_type_id
						AND ISNULL(dh.deal_locked, ''n'') <> ''y''
		WHERE   1 = 1 '


	IF ISNULL(@blotter,'n')='y'
			SET @sql_Select = @sql_Select + ' AND blotter_supported =''y'''
			
	

	--IF ONE deal id is known make the other the same
/*
		IF (@created_date_from IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dbo.FNAConvertTZAwareDateFormat(dh.create_ts,1)>='''+CONVERT(VARCHAR(10),@created_date_from,120) +''''
			--SET @sql_Select = @sql_Select +' AND convert(varchar(10),dh.create_ts,120)>='''+convert(varchar(10),@created_date_from,120) +''''
			--dbo.FNACovertToSTDDate(dbo.FNADateTimeFormat(

		IF (@created_date_to IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dbo.FNAConvertTZAwareDateFormat(dh.create_ts,1) <='''+CONVERT(VARCHAR(10),@created_date_to,120) +''''
			--SET @sql_Select = @sql_Select +' AND convert(varchar(10),dh.create_ts,120) <='''+convert(varchar(10),@created_date_to,120) +''''
*/
		IF (@created_date_from IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.create_ts>='''+CONVERT(VARCHAR(10),[dbo].[FNAConvertTimezone](@created_date_from,1),120) +''''
			
		IF (@created_date_to IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.create_ts <'''+CONVERT(VARCHAR(10),[dbo].[FNAConvertTimezone](@created_date_to+1,1),120) +''''


	IF @deal_id_to IS NULL AND @deal_id_from IS NOT NULL
		SET @deal_id_to = @deal_id_from

	IF @deal_id_from IS NULL AND @deal_id_to IS NOT NULL
		SET @deal_id_from = @deal_id_to

	IF (@deal_id_from IS NOT NULL) AND (@deal_id_to IS NOT NULL) 
		SET @sql_Select = @sql_Select + ' AND dh.source_deal_header_id BETWEEN ' + CAST(@deal_id_from AS VARCHAR)  + ' AND ' + CAST(@deal_id_to AS VARCHAR) 

	IF (@gis_cert_number IS NOT NULL AND @gis_cert_number_to IS NOT NULL)
		SET @sql_Select = @sql_Select +' AND ('+ @gis_cert_number + ' between gis.certificate_number_from_int   
		AND  gis.certificate_number_to_int AND ' +
			@gis_cert_number_to + ' between gis.certificate_number_from_int   
		AND  gis.certificate_number_to_int)'

	IF @deal_id IS NOT NULL 
			SET @sql_Select = @sql_Select + ' AND dh.deal_id like ''' + @deal_id + '%'''

	IF @deal_id_from IS NULL AND @deal_id IS NULL --only apply deal filters if deal id not given.
	BEGIN
	
		IF @index_group IS NOT NULL
			SET @sql_Select = @sql_Select + ' AND spcd.index_group='+CAST(@index_group AS VARCHAR)

		IF @index IS NOT NULL
			SET @sql_Select = @sql_Select + ' AND spcd.source_curve_def_id='+CAST(@index AS VARCHAR)
		
		IF @location IS NOT NULL
			SET @sql_Select = @sql_Select + ' AND sml.source_minor_location_id='+CAST(@location AS VARCHAR)

		IF @commodity IS NOT NULL
			SET @sql_Select = @sql_Select + ' AND spcd.commodity_id='+CAST(@commodity AS VARCHAR)

		
		IF @block_type IS NOT NULL
			SET @sql_Select = @sql_Select + ' AND sdv2.value_id='+CAST(@block_type AS VARCHAR)
		

	IF @confirm_type IS NOT NULL  -- exceptions)
	BEGIN
		IF (@confirm_type = 'n')
			SET @sql_Select = @sql_Select +' AND csr.type IS NULL OR csr.type=''n'''
		ELSE
			SET @sql_Select = @sql_Select +' AND ISNULL(csr.type,''n'') IN (''' + @confirm_type + ''') '
	END

		
		IF @deal_status IS NOT NULL 
			SET @sql_Select = @sql_Select + ' AND static_data_value4.value_id ='+CAST(@deal_status AS VARCHAR)
--		IF @book_deal_type_map_id IS NOT NULL 
--			SET @sql_Select = @sql_Select + ' AND sbmp.book_deal_type_map_id in( ' + @book_deal_type_map_id + ')'

		IF (@deal_date_from IS NOT NULL) AND (@deal_date_to IS NOT NULL) 
			SET @sql_Select = @sql_Select + ' AND dh.deal_date BETWEEN '''+ @deal_date_from + ''' and ''' + @deal_date_to + ''''
		
		IF (@physical_financial_flag IS NOT NULL)
			SET @sql_Select = @sql_Select + ' AND dh.physical_financial_flag='''+@physical_financial_flag+''''
		
		IF (@counterparty_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.counterparty_id='+CAST(@counterparty_id AS VARCHAR)

		IF (@entire_term_start IS NOT NULL)
			SET @sql_Select = @sql_Select+ ' AND dh.entire_term_start>='''+@entire_term_start+''''

		IF (@entire_term_end IS NOT NULL)
			SET @sql_Select = @sql_Select+ ' AND dh.entire_term_end<='''+@entire_term_end+''''

		IF (@source_deal_type_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.source_deal_type_id='+CAST(@source_deal_type_id  AS VARCHAR)

		IF (@deal_sub_type_type_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.deal_sub_type_type_id='+CAST(@deal_sub_type_type_id  AS VARCHAR)

		IF (@deal_category_value_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.deal_category_value_id='+CAST(@deal_category_value_id  AS VARCHAR)

		IF (@trader_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.trader_id='+CAST(@trader_id  AS VARCHAR)





-- Begin : Log Id 399
--		IF (@description1 IS NOT NULL)
--			SET @sql_Select = @sql_Select +' AND dh.description1 like ''%'+@description1+'%'''
--
--		IF (@description2 IS NOT NULL)
--			SET @sql_Select = @sql_Select +' AND dh.description2 like ''%'+@description2+'%'''
--
--		IF (@description3 IS NOT NULL)
--			SET @sql_Select = @sql_Select +' AND dh.description3 like ''%'+@description3+'%'''

		IF (@description1 IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND source_book.source_book_name like '''+@description1+''''

		IF (@description2 IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND source_book_1.source_book_name like '''+@description2+''''

		IF (@description3 IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND source_book_2.source_book_name like '''+@description3+''''

		IF (@description4 IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND source_book_3.source_book_name like '''+@description4+''''
-- End  : Log Id 399

		IF (@structured_deal_id  IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.structured_deal_id like ''%'+@structured_deal_id +'%'''

		IF (@header_buy_sell_flag IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.header_buy_sell_flag='''+ @header_buy_sell_flag + ''''


		IF (@deal_locked IS NOT NULL )
			SET @sql_Select = @sql_Select + ' AND dh.deal_locked='''+@deal_locked+''''	


		IF (@update_date_from IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.update_ts>='''+CAST(@update_date_from  AS VARCHAR)+''''

		IF (@update_date_to IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.update_ts<='''+CAST(@update_date_to  AS VARCHAR)+''''

		IF (@update_by IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.update_user='''+CAST(@update_by  AS VARCHAR)+''''
	
	
		IF @broker IS NOT NULL 
		BEGIN
			SET @sql_Select = @sql_Select + ' AND dh.broker_id = ' + @broker
		END

		----====Added the following filter for REC deals
		--print 'no' 

		--if one cert is known and other not known make the same		
		IF @gis_cert_number_to IS NULL AND @gis_cert_number IS NOT NULL
			SET @gis_cert_number_to = @gis_cert_number

		IF @gis_cert_number IS NULL AND @gis_cert_number_to IS NOT NULL
			SET @gis_cert_number = @gis_cert_number_to



		
		IF @gis_cert_number IS NULL 
		BEGIN

			IF (@generator_id IS NOT NULL)
				SET @sql_Select = @sql_Select +' AND dh.generator_id='+CAST(@generator_id  AS VARCHAR)
			IF (@status_value_id IS NOT NULL)
				SET @sql_Select = @sql_Select +' AND dh.status_value_id='+CAST(@status_value_id  AS VARCHAR)
			IF (@status_date IS NOT NULL)
				SET @sql_Select = @sql_Select +' AND dh.status_date='''+ dbo.FNAGetSQLStandardDate(@status_date) + ''''
			IF (@assignment_type_value_id IS NOT NULL)
				SET @sql_Select = @sql_Select +' AND isnull(dh.assignment_type_value_id, 5149) ='+CAST(@assignment_type_value_id  AS VARCHAR)
			IF (@compliance_year IS NOT NULL)
				SET @sql_Select = @sql_Select +' AND dh.compliance_year='+CAST(@compliance_year  AS VARCHAR)
			IF (@state_value_id IS NOT NULL)
				SET @sql_Select = @sql_Select +' AND dh.state_value_id='+CAST(@state_value_id  AS VARCHAR)
			IF (@assigned_date IS NOT NULL)
				SET @sql_Select = @sql_Select +' AND dh.assigned_date='''+ dbo.FNAGetSQLStandardDate(@assigned_date) + ''''
			IF (@assigned_by IS NOT NULL)
				SET @sql_Select = @sql_Select +' AND dh.assigned_by='''+ @assigned_by + ''''
			IF @gis_value_id IS NOT NULL
				SET @sql_Select = @sql_Select +' AND rg.gis_value_id='+ CAST(@gis_value_id AS VARCHAR)
			IF @gen_cert_date IS NOT NULL
				SET @sql_Select = @sql_Select +' AND rg.registration_date='''+ @gen_cert_date +''''
			IF @gen_cert_number IS NOT NULL
				SET @sql_Select = @sql_Select +' AND rg.gis_account_number='''+ @gen_cert_number +''''
			IF @gis_cert_date IS NOT NULL
				SET @sql_Select = @sql_Select +' AND gis.gis_cert_date='''+ @gis_cert_date +''''

		END
	
	END
	
	IF @sort_by='l'
		SET @sql_Select = @sql_Select +') aa order by id desc'
	ELSE
		SET @sql_Select = @sql_Select +')bb order by id asc'

		--PRINT @sql_Select		
		EXEC(@sql_Select)
		RETURN 
		--If @@ERROR <> 0

--		Exec spa_ErrorHandler @@ERROR, 'Source Deal Header  table', 

--				'spa_sourcedealheader', 'DB Error', 



--				'Failed to select source deal header record.', ''

--		Else

--		Exec spa_ErrorHandler 0, 'Source Deal Header  table', 

--				'spa_sourcedealheader', 'Success', 

--				'Source deal header record successfully selected.', ''


END



ELSE IF @flag ='v' 
BEGIN
  DECLARE @st AS VARCHAR(MAX)

  SET @st='SELECT dh.source_deal_header_id ,dh.source_system_id ,dh.deal_id, 
		[dbo].FNAGetGenericDate(dh.deal_date, '''+@user_login_id+''') DealDate,
 		dh.ext_deal_id ,dh.physical_financial_flag, 
		dh.counterparty_id, 
		[dbo].FNAGetGenericDate(dh.entire_term_start, '''+@user_login_id+''') TermStart, 
		[dbo].FNAGetGenericDate(dh.entire_term_end, '''+@user_login_id+''') TermEnd, dh.source_deal_type_id, 
		dh.deal_sub_type_type_id, 
		dh.option_flag, dh.option_type, dh.option_excercise_type, 
		source_book.source_book_name As Group1, 
		source_book_1.source_book_name AS Group2, 
	        source_book_2.source_book_name AS Group3, source_book_3.source_book_name AS Group4,
		dh.description1,dh.description2,dh.description3,
		dh.deal_category_value_id,dh.trader_id, source_system_book_map.fas_book_id,portfolio_hierarchy.parent_entity_id,
		fas_strategy.hedge_type_value_id,static_data_value1.code as HedgeItemFlag,
			static_data_value2.code as HedgeType,source_currency.currency_name as Currency,
		dh.internal_deal_type_value_id,dh.internal_deal_subtype_value_id,dh.template_id,source_currency.source_system_id,
		dh.header_buy_sell_flag,dh.broker_id,dh.rolling_avg,contract_id,
		source_system_book_map.book_deal_type_map_id,dh.legal_entity 
		FROM       source_deal_header dh INNER JOIN
		source_book ON dh.source_system_book_id1 = source_book.source_book_id INNER JOIN
		source_book source_book_1 ON dh.source_system_book_id2 = source_book_1.source_book_id INNER JOIN
		source_book source_book_2 ON dh.source_system_book_id3 = source_book_2.source_book_id INNER JOIN
		source_book source_book_3 ON dh.source_system_book_id4 = source_book_3.source_book_id
		left join source_system_book_map on  source_system_book_map.source_system_book_id1= source_book.source_book_id 
		and source_system_book_map.source_system_book_id2= source_book_1.source_book_id 
		and source_system_book_map.source_system_book_id3= source_book_2.source_book_id 
		and source_system_book_map.source_system_book_id4= source_book_3.source_book_id 

		left join  portfolio_hierarchy ON portfolio_hierarchy.entity_id = source_system_book_map.fas_book_id
		left join fas_strategy ON fas_strategy.fas_strategy_id=portfolio_hierarchy.parent_entity_id
		left join static_data_value  static_data_value1 ON source_system_book_map.fas_deal_type_value_id=static_data_value1.value_id
		left join static_data_value  static_data_value2 ON fas_strategy.hedge_type_value_id=static_data_value2.value_id
		left  join fas_subsidiaries on fas_subsidiaries.fas_subsidiary_id='+CAST(@sub_id AS VARCHAR)+'
		left join source_currency   ON fas_subsidiaries.func_cur_value_id=source_currency.source_currency_id
       where dh.source_deal_header_id in ('+CAST(@source_deal_header_id AS VARCHAR) +')'
		 --and source_system_book_map.fas_book_id = @book_id

	--PRINT @st
	EXEC(@st)
END
ELSE IF @flag='e'	-- vErified by
BEGIN

	UPDATE source_deal_header 
	SET
		verified_by = dbo.FNADBUser(),
		verified_date = GETDATE()
	WHERE source_deal_header_id = @source_deal_header_id

	IF @@ERROR <> 0
	BEGIN	
	EXEC spa_ErrorHandler @@ERROR, 'Failed Verifying the Trade Ticket', 

			'spa_sourcedealheader', 'DB Error', 

			'Failed Verifying the Trade Ticket', 'Failed Verifying the Trade Ticket'
	END
	ELSE
	BEGIN
	EXEC spa_ErrorHandler 0, 'Source Deal Header table', 

		'spa_sourcedealheader', 'Success', 

		'Trade Ticket Verified', ''
	END

END


GO


