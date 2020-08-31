
/****** Object:  StoredProcedure [dbo].[spa_sourcedealheader_lock]    Script Date: 07/24/2011 19:46:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_sourcedealheader_lock]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_sourcedealheader_lock]
GO

/****** Object:  StoredProcedure [dbo].[spa_sourcedealheader_lock]    Script Date: 07/24/2011 19:46:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROC [dbo].[spa_sourcedealheader_lock]
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
@confirm_type VARCHAR(50) = NULL,
@created_date_from DATETIME = NULL,
@created_date_to DATETIME = NULL,
@unit_fixed_flag CHAR(1) = NULL,
@broker_unit_fees FLOAT = NULL,
@broker_fixed_cost FLOAT = NULL,
@broker_currency_id INT = NULL,
@deal_status INT = NULL,
@option_settlement_date DATETIME = NULL,
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
@sub_entity_id VARCHAR(100) = NULL,
@strategy_entity_id VARCHAR(100) = NULL,
@book_entity_id VARCHAR(100) = NULL,
@deleted_deal VARCHAR(1) = 'n',
@refrence_deal VARCHAR(500) = NULL


AS

--select @confirm_type '@confirm_type'
--select @sort_by,@aggregate_envrionment_comment
--return
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
	SELECT  distinct ssbm.fas_book_id,ssbm.book_deal_type_map_id fas_book_id,source_system_book_id1,
		source_system_book_id2,source_system_book_id3,source_system_book_id4,ssbm.fas_deal_type_value_id FROM portfolio_hierarchy book (nolock) INNER JOIN
	Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id LEFT OUTER JOIN            
	source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id         
	WHERE  1 = 1'   

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
	SET @Sql_Where_S = @Sql_Where_S +' AND ssbm.book_deal_type_map_id = '+CAST(@book_deal_type_map_id AS VARCHAR)


SET @Sql_Select_S = @Sql_Select_S + @Sql_Where_S
EXEC spa_print @Sql_Select_S
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


EXEC spa_print @confirm_type
EXEC spa_print @blotter

	 
IF @flag='s'  
	BEGIN

	SET @sql_Select = 
			'
--SELECT [ID],[RefID] AS [Ref ID],[dbo].FNAGetGenericDate(deal_date, '''+@user_login_id+''') as [Deal Date],[ExtId] AS [Ext ID],[PhysicalFinancialFlag] AS [Physical/Financial Flag] ,[CptyName] AS [Counterparty],
--					[TermStart] AS [Term Start] ,[TermEnd] AS [Term End] ,[DealType] AS [Deal Type],[DealSubType] AS [Deal Sub Type], [OptionFlag] AS [Option Flag],[OptionType] AS [Option Type],[ExcerciseType] AS [Exercise Type],
--					['+ @group1 +'],['+ @group2 +']   ,['+ @group3 +'],['+ @group4 +'],[Desc1],[Desc2],[Desc3],
--					[DealCategoryValueId] AS [Deal Category],[TraderName] AS [Trader Name],[HedgeItemFlag] AS [Hedge/Item Flag],[HedgeType] AS [Hedge Type],[AssignType] AS [Assign Type],[legal_entity] AS [Legal Entity],
--					[deal_locked] AS [Deal Lock], [Pricing],[Created Date],ConfirmStatus AS [Confirm Status],[Signed Off By],[Sign Off Date] as [Signed Off Date], [Broker],[comments]
--					
--			FROM (
			SELECT  DISTINCT
					dh.source_deal_header_id AS ID,
					dh.deal_id AS [Ref ID],
					dbo.FNADateFormat(dh.deal_date) [Deal Date],
 					
 					(
					CASE WHEN dh.deal_locked = ''y'' THEN ''Yes''
					ELSE 
						CASE WHEN ISNULL(dl_specific.id, dl_generic.id) IS NOT NULL THEN
							CASE WHEN DATEADD(mi, ISNULL(dl_specific.mins, dl_generic.mins), ISNULL(dh.update_ts, dh.create_ts)) < GETDATE() THEN ''Yes'' ELSE ''No'' END
						ELSE ''No''
						END
					END
				) AS [Deal Locked] ,
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
							
				static_data_value3.code [Pricing],
				--[dbo].FNAConvertGenericTimezone(dh.create_ts,'+ISNULL(cast(@time_zone_from AS VARCHAR), 'NULL') +','+ ISNULL(CAST(@time_zone_to AS VARCHAR), 'NULL') + ','''+@user_login_id+''',0) as [Created Date]
				dbo.FNADateTimeFormat(dh.create_ts,2) [Create TS],				
				sdv_confirm.code [Confirm Status],
				dh.verified_by [Signed Off By],
				--[dbo].FNAGetGenericDate(dh.verified_date,'''+@user_login_id+''') [Sign Off Date],
				dh.verified_date [Verified Date],
				scp.counterparty_name AS [Broker],
				t.comments [Comments]
		
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
			CASE WHEN (@gis_cert_number IS NOT NULL AND @gis_cert_number_to IS NOT NULL) OR (@gis_cert_date IS NOT NULL) OR (@location IS NOT NULL) OR (@index_group IS NOT null) OR (@index IS NOT NULL)
			THEN
				' LEFT OUTER JOIN ' +CASE WHEN isnull(@deleted_deal,'n')='y' then  'delete_source_deal_detail' ELSE 'source_deal_detail' END +' sdd ON sdd.source_deal_header_id=dh.source_deal_header_id '
			ELSE '' END +
			
			CASE WHEN (@gis_cert_number IS NOT NULL AND @gis_cert_number_to IS NOT NULL) OR (@gis_cert_date IS NOT NULL)
				THEN
					' LEFT OUTER JOIN gis_certificate gis ON gis.source_deal_header_id=sdd.source_deal_detail_id'
				ELSE '' END +
			CASE WHEN (@index_group IS NOT null) OR (@index IS NOT NULL)
				THEN
					' LEFT OUTER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=sdd.curve_id'
				ELSE '' END +
			CASE WHEN (@location IS NOT NULL)
				THEN
					' LEFT OUTER JOIN source_minor_location sml ON sml.source_minor_location_id=sdd.location_id'
				ELSE '' END +
			'
			LEFT OUTER JOIN confirm_status_recent csr ON csr.source_deal_header_id = dh.source_deal_header_id
			LEFT OUTER JOIN static_data_value sdv_confirm ON sdv_confirm.value_id = ISNULL(csr.type,17200)
			LEFT OUTER JOIN dbo.source_deal_header_template t ON t.template_id=dh.template_id  
			LEFT OUTER JOIN dbo.source_deal_detail_template dt ON dt.template_id=dh.template_id
			LEFT OUTER JOIN source_commodity sc ON sc.source_commodity_id=dt.commodity_id
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
	ELSE IF @source_deal_header_id IS NOT NULL
		SET @sql_Select = @sql_Select + ' AND dh.source_deal_header_id IN(' + @source_deal_header_id  +')'


	IF (@gis_cert_number IS NOT NULL AND @gis_cert_number_to IS NOT NULL)
		SET @sql_Select = @sql_Select +' AND ('+ @gis_cert_number + ' between gis.certificate_number_from_int   
		AND  gis.certificate_number_to_int AND ' +
			@gis_cert_number_to + ' between gis.certificate_number_from_int   
		AND  gis.certificate_number_to_int)'

	IF @deal_id IS NOT NULL 
			SET @sql_Select = @sql_Select + ' AND dh.deal_id like ''' + @deal_id + '%'''

	IF @deal_id_from IS NULL AND @deal_id IS NULL --only apply deal filters if deal id not given.
	BEGIN
		
		IF ISNULL(@blotter,'n')='y'
			SET @sql_Select = @sql_Select + ' AND blotter_supported =''y'''
		

		IF @index_group IS NOT NULL
			SET @sql_Select = @sql_Select + ' AND spcd.index_group='+CAST(@index_group AS VARCHAR)

		IF @index IS NOT NULL
			SET @sql_Select = @sql_Select + ' AND spcd.source_curve_def_id='+CAST(@index AS VARCHAR)
		

		IF @commodity IS NOT NULL
			SET @sql_Select = @sql_Select + ' AND sc.source_commodity_id='+CAST(@commodity AS VARCHAR)

		
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
				SET @sql_Select = @sql_Select +' AND ISNULL(csr.type,17200) IN (' + @confirm_type + ') '
		END
	
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

	END	
	IF @sort_by='l'
		SET @sql_Select = @sql_Select +' order by id desc'
	ELSE
		SET @sql_Select = @sql_Select +' order by id asc'

		EXEC spa_print @sql_Select

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
	
		SET @sql_Select = 
			'SELECT [ID],[RefID] AS [Ref ID],[dbo].FNAGetGenericDate(deal_date, '''+@user_login_id+''') as [Deal Date],[ExtId] AS [Ext ID],[PhysicalFinancialFlag] AS [Physical/Financial Flag] ,[CptyName] AS [Counterparty],
					[TermStart] AS [Term Start] ,[TermEnd] AS [Term End] ,[DealType] AS [Deal Type],[DealSubType] AS [Deal Sub Type], [OptionFlag] AS [Option Flag],[OptionType] AS [Option Type],[ExcerciseType] AS [Exercise Type],
					['+ @group1 +'],['+ @group2 +']   ,['+ @group3 +'],['+ @group4 +'],[Desc1],[Desc2],[Desc3],
					[DealCategoryValueId] AS [Deal Category],[TraderName] AS [Trader Name],[HedgeItemFlag] AS [Hedge/Item Flag],[HedgeType] AS [Hedge Type],[AssignType] AS [Assign Type],
					[legal_entity] AS [Legal Entity],
					[deal_locked] AS [Deal Lock], [Pricing],[Created Date],ConfirmStatus AS [Confirm Status],[Signed Off By],[Sign Off Date] as [Signed Off Date], [Broker], NULL as [Comments]

			FROM (SELECT	distinct dh.source_deal_header_id AS ID,dh.deal_id AS RefID,dh.deal_date,
 						  dh.ext_deal_id as ExtId,
					CASE 
					WHEN dh.physical_financial_flag =''p'' THEN ''Physical''
						ELSE ''Financial''
					END	as PhysicalFinancialFlag, 
					source_counterparty.counterparty_name CptyName,[dbo].FNAGetGenericDate(dh.entire_term_start, '''+@user_login_id+''') as TermStart, 
					[dbo].FNAGetGenericDate(dh.entire_term_end, '''+@user_login_id+''') As TermEnd, source_deal_type.source_deal_type_name As DealType, 
					source_deal_type_1.source_deal_type_name AS DealSubType,dh.option_flag As OptionFlag, dh.option_type As OptionType, 
					dh.option_excercise_type As ExcerciseType,source_book.source_book_name As ['+ @group1 +'], 
					source_book_1.source_book_name AS ['+ @group2 +'],source_book_2.source_book_name AS ['+ @group3 +'], 
					source_book_3.source_book_name AS ['+ @group4 +'],dh.description1 As Desc1, dh.description2 As Desc2,
					dh.description3 as Desc3,static_data_value4.code as DealCategoryValueId,source_traders.trader_name as TraderName,
					static_data_value1.code as HedgeItemFlag,static_data_value2.code as  HedgeType,
					CASE 
					WHEN dh.header_buy_sell_flag=''s'' AND dh.assignment_type_value_id is not null 
					THEN sdv.code else 	
					CASE 
					WHEN dh.header_buy_sell_flag=''s'' AND dh.assignment_type_value_id is null 
					THEN ''Sold'' else ''Banked'' end
					END 
				AssignType,
				dh.legal_entity,
				(
					CASE WHEN dh.deal_locked = ''y'' THEN ''Yes''
					ELSE 
						CASE WHEN ISNULL(dl_specific.id, dl_generic.id) IS NOT NULL THEN
							CASE WHEN DATEADD(mi, ISNULL(dl_specific.mins, dl_generic.mins), ISNULL(dh.update_ts, dh.create_ts)) < GETDATE() THEN ''Yes'' ELSE ''No'' END
						ELSE ''No''
						END
					END
				) AS deal_locked				
				,static_data_value3.code [Pricing] --dh.pricing
				,[dbo].FNAGetGenericDate(dh.create_ts, '''+@user_login_id+''') as [Created Date]
				,sdv_confirm.code ConfirmStatus
				,dh.verified_by [Signed Off By]
				,[dbo].FNAGetGenericDate(dh.verified_date, '''+@user_login_id+''') [Sign Off Date]
				,scp.counterparty_name AS [Broker]
			FROM       source_deal_header_audit dh 

		INNER JOIN (
			SELECT source_deal_header_id,max(audit_id) [max_audit_id] from source_deal_header_audit WHERE 1=1 GROUP BY source_deal_header_id
		) dh1 ON dh1.source_deal_header_id = dh.source_deal_header_id 
			AND dh1.max_audit_id = dh.audit_id
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
			LEFT OUTER JOIN confirm_status_recent csr ON csr.source_deal_header_id = dh.source_deal_header_id
			LEFT OUTER JOIN static_data_value sdv_confirm ON sdv_confirm.value_id = ISNULL(csr.type,17200)
			LEFT OUTER JOIN source_deal_type source_deal_type_1 ON dh.deal_sub_type_type_id = source_deal_type_1.source_deal_type_id 
			LEFT OUTER JOIN fas_link_detail fld ON fld.source_deal_header_id = dh.source_deal_header_id 
			LEFT OUTER JOIN static_data_value sdv ON sdv.value_id=dh.assignment_type_value_id
			LEFT OUTER JOIN rec_generator rg ON rg.generator_id=dh.generator_id' +
			CASE WHEN (@gis_cert_number IS NOT NULL AND @gis_cert_number_to IS NOT NULL) OR (@gis_cert_date IS NOT NULL) OR (@location IS NOT NULL) OR (@index_group IS NOT null) OR (@index IS NOT NULL)
			THEN
				'LEFT OUTER JOIN source_deal_detail sdd ON sdd.source_deal_header_id=dh.source_deal_header_id '
			ELSE '' END +
			
			CASE WHEN (@gis_cert_number IS NOT NULL AND @gis_cert_number_to IS NOT NULL) OR (@gis_cert_date IS NOT NULL)
				THEN
					'LEFT OUTER JOIN gis_certificate gis ON gis.source_deal_header_id=sdd.source_deal_detail_id'
				ELSE '' END +
			CASE WHEN (@index_group IS NOT null) OR (@index IS NOT NULL)
				THEN
					'LEFT OUTER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=sdd.curve_id'
				ELSE '' END +
			CASE WHEN (@location IS NOT NULL)
				THEN
					'LEFT OUTER JOIN source_minor_location sml ON sml.source_minor_location_id=sdd.location_id'
				ELSE '' END +
			'
			LEFT OUTER JOIN dbo.source_deal_header_template t ON t.template_id=dh.template_id  
			LEFT OUTER JOIN dbo.source_deal_detail_template dt ON dt.template_id=dh.template_id
			LEFT OUTER JOIN source_commodity sc ON sc.source_commodity_id=dt.commodity_id
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
			) dl_generic ON ISNULL(dh.deal_locked, ''n'') <> ''y''  WHERE   1 = 1 ' 

	
		IF @user_action IS NOT NULL AND @user_action!='all'
			SET @sql_Select = @sql_Select + ' AND dh.user_action='''+@user_action+''''
	
		IF ISNULL(@blotter,'n')='y'
			SET @sql_Select = @sql_Select + ' AND blotter_supported =''y'''

		
	--IF ONE deal id is known make the other the same
/*
		IF (@created_date_from IS NOT NULL)
--			SET @sql_Select = @sql_Select +' AND convert(varchar(10),dh.create_ts,120)>='''+convert(varchar(10),@created_date_from,120) +''''
			SET @sql_Select = @sql_Select +' AND dbo.FNAConvertTZAwareDateFormat(dh.create_ts,1)>='''+CONVERT(VARCHAR(10),@created_date_from,120) +''''

		IF (@created_date_to IS NOT NULL)
--			SET @sql_Select = @sql_Select +' AND convert(varchar(10),dh.create_ts,120) <='''+convert(varchar(10),@created_date_to,120) +''''
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
			SET @sql_Select = @sql_Select + ' AND sc.source_commodity_id='+CAST(@commodity AS VARCHAR)

		
		IF @block_type IS NOT NULL
			SET @sql_Select = @sql_Select + ' AND sdv2.value_id='+CAST(@block_type AS VARCHAR)
		

	IF @confirm_type IS NOT NULL  -- exceptions)
	BEGIN
		IF (@confirm_type = 'n')
			SET @sql_Select = @sql_Select +' AND csr.type IS NULL OR csr.type=''n'''
		ELSE
			SET @sql_Select = @sql_Select +' AND ISNULL(csr.type,''n'') IN (''' + @confirm_type + ''') '
	END

	
--		IF @book_deal_type_map_id IS NOT NULL 
--			SET @sql_Select = @sql_Select + ' AND sbmp.book_deal_type_map_id in( ' + @book_deal_type_map_id + ')'
--
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

		IF (@description1 IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.description1 like ''%'+@description1+'%'''

		IF (@description2 IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.description2 like ''%'+@description2+'%'''

		IF (@description3 IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.description3 like ''%'+@description3+'%'''

--		IF (@source_system_book_id1 IS NOT NULL)
--			SET @sql_Select = @sql_Select +' AND source_book.source_book_id ='+CAST(@source_system_book_id1 AS VARCHAR)
--
--		IF (@source_system_book_id2 IS NOT NULL)
--			SET @sql_Select = @sql_Select +' AND source_book_1.source_book_id = '+CAST(@source_system_book_id2 AS VARCHAR)
--
--		IF (@source_system_book_id3 IS NOT NULL)
--			SET @sql_Select = @sql_Select +' AND source_book_2.source_book_id = '+CAST(@source_system_book_id3 AS VARCHAR)
--
--		IF (@source_system_book_id4 IS NOT NULL)
--			SET @sql_Select = @sql_Select +' AND source_book_3.source_book_id = '+CAST(@source_system_book_id4 AS VARCHAR)
--
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
/*
		IF (@update_date_from IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND cast(dbo.FNAConvertTZAwareDateFormat(dh.update_ts,1) as datetime)>='''+CAST(@update_date_from  AS VARCHAR)+''''

		IF (@update_date_to IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND cast(dbo.FNAConvertTZAwareDateFormat(dh.update_ts,1) as datetime)<='''+CAST(@update_date_to  AS VARCHAR)+''''
*/

		IF (@update_date_from IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.update_ts>='''+CONVERT(VARCHAR(10),[dbo].[FNAConvertTimezone](@update_date_from,1),120) +''''
			
			--SET @sql_Select = @sql_Select +' AND convert(varchar(10),dh.create_ts,120)>='''+convert(varchar(10),@created_date_from,120) +''''

		IF (@update_date_to IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.update_ts <'''+CONVERT(VARCHAR(10),[dbo].[FNAConvertTimezone](@update_date_to+1,1),120) +''''



		IF (@update_by IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.update_user='''+CAST(@update_by  AS VARCHAR)+''''
			
		IF @deal_status IS NOT NULL 
			SET @sql_Select = @sql_Select + ' AND dh.deal_status=' + CAST(@deal_status AS VARCHAR) 
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

		
	IF @sort_by='l'
		SET @sql_Select = @sql_Select +') aa order by id desc'
	ELSE
		SET @sql_Select = @sql_Select +')bb order by id asc'

		EXEC spa_print @sql_Select

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

		EXEC spa_print @sql_Select

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
					[deal_locked], [Pricing],[Created Date],ConfirmStatus,[Signed Off By],[Sign Off Date] as [Signed Off Date],[Broker],[Comments]
					

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
					WHEN header_buy_sell_flag=''s'' AND assignment_type_value_id is not null 
					THEN sdv.code else 	
					CASE 
					WHEN header_buy_sell_flag=''s'' AND assignment_type_value_id is null 
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
				t.comments AS [Comments]
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
--				' LEFT OUTER JOIN source_deal_detail sdd ON sdd.source_deal_header_id=dh.source_deal_header_id '
--			ELSE '' END +
			CASE WHEN (@gis_cert_number IS NOT NULL AND @gis_cert_number_to IS NOT NULL) OR (@gis_cert_date IS NOT NULL) OR (@location IS NOT NULL) OR (@index_group IS NOT null) OR (@index IS NOT NULL)
			THEN
				'LEFT OUTER JOIN ' +CASE WHEN isnull(@deleted_deal,'n')='y' then  'delete_source_deal_detail' ELSE 'source_deal_detail' END +' sdd ON sdd.source_deal_header_id=dh.source_deal_header_id '
			ELSE '' END +
			CASE WHEN (@gis_cert_number IS NOT NULL AND @gis_cert_number_to IS NOT NULL) OR (@gis_cert_date IS NOT NULL)
				THEN
					' LEFT OUTER JOIN gis_certificate gis ON gis.source_deal_header_id=sdd.source_deal_detail_id'
				ELSE '' END +
			
			CASE WHEN (@index_group IS NOT null) OR (@index IS NOT NULL)
				THEN
					' LEFT OUTER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=sdd.curve_id'
				ELSE '' END +
			CASE WHEN (@location IS NOT NULL)
				THEN
					' LEFT OUTER JOIN source_minor_location sml ON sml.source_minor_location_id=sdd.location_id'
				ELSE '' END +
			'
			LEFT OUTER JOIN confirm_status_recent csr ON csr.source_deal_header_id = dh.source_deal_header_id
			LEFT OUTER JOIN static_data_value sdv_confirm ON sdv_confirm.value_id = ISNULL(csr.type,17200) 
			LEFT OUTER JOIN dbo.source_deal_header_template t ON t.template_id=dh.template_id  
			LEFT OUTER JOIN dbo.source_deal_detail_template dt ON dt.template_id=dh.template_id
			LEFT OUTER JOIN source_commodity sc ON sc.source_commodity_id=dt.commodity_id
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
			SET @sql_Select = @sql_Select + ' AND sc.source_commodity_id='+CAST(@commodity AS VARCHAR)

		
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

		EXEC spa_print @sql_Select		
		EXEC(@sql_Select)
		RETURN 

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



GO


