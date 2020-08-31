
/****** Object:  StoredProcedure [dbo].[spa_sourcedealheader_paging]    Script Date: 07/18/2011 23:17:39 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_sourcedealheader_paging]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_sourcedealheader_paging]
GO

/****** Object:  StoredProcedure [dbo].[spa_sourcedealheader_paging]    Script Date: 07/18/2011 23:17:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE proc [dbo].[spa_sourcedealheader_paging] 
		@flag_pre char(1),
		@book_deal_type_map_id varchar(200)=NULL, 
		@deal_id_from int = NULL, 
		@deal_id_to int = NULL, 
		@deal_date_from varchar(10) = NULL, 
		@deal_date_to varchar(10) = NULL,
		@source_deal_header_id varchar(max)=NULL,
		@source_system_id int=NULL,
		@deal_id varchar(50)=NULL,
		@deal_date varchar(50)=NULL,
		@ext_deal_id varchar(50)=NULL,
		@physical_financial_flag char(1)=NULL,
		@structured_deal_id varchar(50)=NULL,
		@counterparty_id int=NULL,
		@entire_term_start varchar(10)=NULL,
		@entire_term_end varchar(10)=NULL,
		@source_deal_type_id int=NULL,
		@deal_sub_type_type_id int=NULL,
		@option_flag INT=NULL,
		@option_type char(1)=NULL,
		@option_excercise_type char(1)=NULL,
		@source_system_book_id1 int=NULL,
		@source_system_book_id2 int=NULL,
		@source_system_book_id3 int=NULL,
		@source_system_book_id4 int=NULL,
		@description1 varchar(100)=NULL,
		@description2 varchar(100)=NULL,
		@description3 varchar(100)=NULL,
		@deal_category_value_id int=NULL,
		@trader_id int=NULL,
		@internal_deal_type_value_id int=NULL,
		@internal_deal_subtype_value_id int= NULL,
		@book_id VARCHAR(MAX)=NULL,	
		@template_id int = NULL,
		@process_id varchar(100)=NULL,
		@header_buy_sell_flag varchar(1)=NULL,
		@broker_id int=NULL,
		@generator_id int = NULL ,
		@gis_cert_number varchar (250) = NULL ,
		@gis_value_id int = NULL ,
		@gis_cert_date varchar(10) = NULL ,
		@gen_cert_number varchar (250) = NULL ,
		@gen_cert_date varchar(10) = NULL ,
		@status_value_id int = NULL,
		@status_date datetime = NULL ,
		@assignment_type_value_id int = NULL ,
		@compliance_year int = NULL ,
		@state_value_id int = NULL ,
		@assigned_date datetime = NULL ,
		@assigned_by varchar (50) = NULL,
		@gis_cert_number_to varchar (250) = NULL,
		@generation_source varchar(250)=NULL,
		@aggregate_environment char(1)='n',
		@aggregate_envrionment_comment varchar(250)=NULL,
		@rec_price float= null,
		@rec_formula_id int=null,
		@rolling_avg char(1)=null,
		@sort_by char(1)='l',	
		@certificate_from FLOAT=null,
		@certificate_to FLOAT=null,
		@certificate_date varchar(20)=null,
		@contract_id int=null,
		@legal_entity INT=NULL,
		@bifurcate_leg int=null,
		@refrence varchar(500)=null,
		@source_commodity int=null,
		@source_internal_portfolio int=NULL,
		@source_product int=NULL,
		@source_internal_desk int=NULL,
		@deal_locked varchar(10)= NULL,
		@block_type int=null,
		@block_define_id int=null,
		@granularity_id int=null,
		@pricing int=null,			
		@description4 varchar(100)=NULL,
		@update_date_from datetime = null,
		@update_date_to datetime = null,
		@update_by varchar(50) = null,
		@confirm_type VARCHAR(10) =NULL,
		@created_date_from datetime=NULL,
		@created_date_to datetime=NULL,
		@unit_fixed_flag CHAR(1)=NULL,
		@broker_unit_fees FLOAT=NULL,
		@broker_fixed_cost FLOAT=NULL,
		@broker_currency_id INT = NULL,
		@deal_status int = NULL,
		@option_settlement_date DATETIME = NULL,
		@signed_off_flag CHAR(1)=NULL,
		@signed_off_by CHAR(1) = NULL,
		@broker VARCHAR(100)= NULL,
		@blotter char(1) = NULL,
		@index_group int = NULL,
		@location int=NULL,
		@index int=NULL,
		@commodity int=NULL,
		@udf_template_id_list VARCHAR(max)=null,
		@udf_value_list VARCHAR(max)=null,
		@user_action VARCHAR(100)=NULL,
		@comments VARCHAR(1000)=NULL,
		@sub_entity_id VARCHAR(1000)=NULL,
		@strategy_entity_id VARCHAR(1000)=NULL,
		@book_entity_id VARCHAR(1000)=NULL,
		@deleted_deal VARCHAR(1)='n',
		@refrence_deal VARCHAR(500) = NULL,
		@deal_rules INT = NULL,
		@confirm_rule INT = NULL,
		@update_call INT = 0,
		@call_breakdown  INT = 0,  
		@contract int = NULL,
		@portfolio int = NULL,  
		--@timezone_id INT = NULL,
		--@call_from_import NCHAR(1) = NULL,
		@process_id_paging VARCHAR(500)=NULL, 
		@page_size INT =NULL,
		@page_no INT = NULL
		
AS


--select @flag_pre, @book_deal_type_map_id, @deal_id_from, @deal_id_to, @deal_date_from, @deal_date_to, @source_deal_header_id, @source_system_id, @deal_id, @deal_date, @ext_deal_id, @physical_financial_flag, @structured_deal_id, @counterparty_id, @entire_term_start, @entire_term_end, @source_deal_type_id, @deal_sub_type_type_id, @option_flag, @option_type, @option_excercise_type, @source_system_book_id1, @source_system_book_id2, @source_system_book_id3, @source_system_book_id4, @description1, @description2, @description3, @deal_category_value_id, @trader_id, @internal_deal_type_value_id, @internal_deal_subtype_value_id, @book_id, @template_id, @process_id, @header_buy_sell_flag, @broker_id, @generator_id, @gis_cert_number, @gis_value_id, @gis_cert_date, @gen_cert_number, @gen_cert_date, @status_value_id, @status_date, @assignment_type_value_id, @compliance_year, @state_value_id, @assigned_date, @assigned_by, @gis_cert_number_to, @generation_source, @aggregate_environment, @aggregate_envrionment_comment, @rec_price, @rec_formula_id, @rolling_avg, @sort_by, @certificate_from, @certificate_to, @certificate_date, @contract_id, @legal_entity, @bifurcate_leg, @refrence, @source_commodity, @source_internal_portfolio, @source_product, @source_internal_desk, @deal_locked, @block_type, @block_define_id, @granularity_id, @pricing, @description4, @update_date_from, @update_date_to, @update_by, @confirm_type, @created_date_from, @created_date_to, @unit_fixed_flag, @broker_unit_fees, @broker_fixed_cost, @broker_currency_id, @deal_status, @option_settlement_date, @signed_off_flag, @signed_off_by, @broker, @blotter, @index_group, @location, @index, @commodity, @process_id_paging, @page_size, @page_no

DECLARE @user_login_id VARCHAR(50),@tempTable VARCHAR(MAX) ,@flag CHAR(1), @new_flag CHAR(1)

SET @new_flag = @flag_pre

IF @book_entity_id IS NULL
	SET @book_entity_id = @book_id

IF @update_date_to IS NOT NULL
	SET @update_date_to = @update_date_to + ' 23:59:59'
	SET @user_login_id = dbo.FNADBUser()

	IF @process_id_paging IS NULL
	BEGIN
		SET @flag='i'
		SET @process_id_paging = REPLACE(newid(),'-','_')
	END
	
	SET @tempTable=dbo.FNAProcessTableName('paging_sourcedealheader', @user_login_id,@process_id_paging)
	DECLARE @sqlStmt VARCHAR(MAX)

IF @flag='i'
BEGIN
	
	IF @new_flag != 's' AND @new_flag != 't'
	BEGIN
		IF @new_flag = 'f'
		BEGIN
			
			SET @sqlStmt='create table '+ @tempTable+'( 
					sno int  identity(1,1),
					frequency varchar(500),
					volume varchar(500),
					term_start varchar(50),
					term_end varchar(50)
					)'
		END
		ELSE
		BEGIN
			SET @sqlStmt='create table '+ @tempTable+'( 
			sno int  identity(1,1),
			DealID varchar(500),
		--	SourceSystemId varchar(500),
			SourceDealID varchar(500),
			DealDate varchar(500),
			ExtDealId varchar(500),
			PhysicalFinancialFlag varchar(500),
			CptyName varchar(500),
			TermStart varchar(500),
			TermEnd varchar(500),
			DealType varchar(500),
			DealSubType varchar(500),
			OptionFlag varchar(500),
			OptionType varchar(500),
			ExcerciseType varchar(500),
			Group1 varchar(500),
			Group2 varchar(500),
			Group3 varchar(500),
			Group4 varchar(500),
			Desc1 varchar(500),
			Desc2 varchar(500),
			Desc3 varchar(500),
			DealCategoryValueId varchar(500),
			TraderName varchar(500),
			HedgeItemFlag varchar(500),
			HedgeType varchar(500),
			--Currency varchar(500),
			AssignType varchar(100),
			legal_entity int,
			deal_locked CHAR(10),
			pricing varchar(500),
			CreatedDate varchar(20),
			ConfirmStatus varchar(100),
			[Signed Off By] varchar(50),
			[Sign Off Date] VARCHAR(20),
			[Broker] VARCHAR(100),
			[Comments] CHAR(1),
			[commodity_id] varchar(400)
			)'
		END
	END
	ELSE
	BEGIN
		SET @sqlStmt='create table '+ @tempTable+'( 
		sno int  identity(1,1),
		DealID varchar(500),
	--	SourceSystemId varchar(500),
		SourceDealID varchar(500),
		DealDate varchar(500),
		ExtDealId varchar(500),
		PhysicalFinancialFlag varchar(500),
		CptyName varchar(500),
		TermStart varchar(500),
		TermEnd varchar(500),
		DealType varchar(500),
		DealSubType varchar(500),
		OptionFlag varchar(500),
		OptionType varchar(500),
		ExcerciseType varchar(500),
		Group1 varchar(500),
		Group2 varchar(500),
		Group3 varchar(500),
		Group4 varchar(500),
		Desc1 varchar(500),
		Desc2 varchar(500),
		Desc3 varchar(500),
		DealCategoryValueId varchar(500),
		TraderName varchar(500),
		HedgeItemFlag varchar(500),
		HedgeType varchar(500),
		--Currency varchar(500),
		AssignType varchar(100),
		legal_entity int,
		deal_locked CHAR(10),
		pricing varchar(500),
		CreatedDate varchar(20),
		ConfirmStatus varchar(100),
		[Signed Off By] varchar(50),
		[Sign Off Date] VARCHAR(20),
		[Broker] VARCHAR(100),
		[comments] char(1),
		[Commodity] VARCHAR(50),
		[Deal Rules] VARCHAR(10),
		[Confirm Rules] VARCHAR(10)
		)'

		
	END
	
	EXEC(@sqlStmt)

		set @sqlStmt=' insert  '+@tempTable+'
		exec spa_sourcedealheader '+ 
		dbo.FNASingleQuote(@flag_pre) +','+ 
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
		dbo.FNASingleQuote(@source_system_book_id3)+',' +
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
		dbo.FNASingleQuote(@gis_cert_number_to)+
		',NULL,NULL,NULL,NULL,NULL,NULL,'+
		dbo.FNASingleQuote(@sort_by) +
		',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'+
		dbo.FNASingleQuote(@deal_locked)+','+
		dbo.FNASingleQuote(@block_type)+','+
		'NULL,NULL,NULL,'+
		dbo.FNASingleQuote(@description4) + ',' + 
		dbo.FNASingleQuote(@update_date_from) + ',' + 
		dbo.FNASingleQuote(@update_date_to) + ',' + 
		dbo.FNASingleQuote(@update_by)+ ',' + 
		dbo.FNASingleQuote(@confirm_type)+','+
		dbo.FNASingleQuote(@created_date_from) + ',' + 
		dbo.FNASingleQuote(@created_date_to) + ',NULL,NULL,NULL,NULL,'+dbo.FNASingleQuote(@deal_status)+',NULL,' + 
		dbo.FNASingleQuote(@signed_off_flag) + ',' + 
		dbo.FNASingleQuote(@signed_off_by) + ',' + 
		dbo.FNASingleQuote(@broker) + ',' + 
		dbo.FNASingleQuote(@blotter)+ ','+
		dbo.FNASingleQuote(@index_group)+ ','+
		dbo.FNASingleQuote(@location)+ ','+
		dbo.FNASingleQuote(@index)+ ','+
		dbo.FNASingleQuote(@commodity)+',null,null,'+
		dbo.FNASingleQuote(@user_action)+','+
		dbo.FNASingleQuote(@comments)+','+
		dbo.FNASingleQuote(@sub_entity_id)+','+
		dbo.FNASingleQuote(@strategy_entity_id)+','+
		dbo.FNASingleQuote(@book_entity_id)+','+
		dbo.FNASingleQuote(@deleted_deal) + ',' +
		dbo.FNASingleQuote(@refrence_deal) + ',' +  
		dbo.FNASingleQuote(@deal_rules) + ',' +  
		dbo.FNASingleQuote(@confirm_rule) + ',' +  
		dbo.FNASingleQuote(@update_call) + ',' + 
		dbo.FNASingleQuote(@call_breakdown) + ',' + 
		dbo.FNASingleQuote(@contract) + ',' +
		dbo.FNASingleQuote(@portfolio)  + ',null,null'
		--+dbo.FNASingleQuote(@timezone_id) + ',' +
		--dbo.FNASingleQuote(@call_from_import)

		EXEC spa_print @sqlStmt
		EXEC(@sqlStmt)	
		SET @sqlStmt='select count(*) TotalRow,'''+@process_id_paging +''' process_id  from '+ @tempTable
		EXEC spa_print @sqlStmt
		EXEC(@sqlStmt)
END
ELSE
BEGIN
	DECLARE @row_to INT,@row_from INT
	
	SET @row_to = @page_no * @page_size
	IF @page_no > 1 
		SET @row_from = ((@page_no-1) * @page_size)+1
	ELSE
		SET @row_from = @page_no
	--########### Group Label
	DECLARE @group1 VARCHAR(100),@group2 VARCHAR(100),@group3 VARCHAR(100),@group4 VARCHAR(100)
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

--######## End

	DECLARE @time_zone_from INT, @time_zone_to INT

	SELECT @time_zone_from= var_value  FROM adiha_default_codes_values  
	 WHERE  (instance_no = 1) AND (default_code_id = 36) AND (seq_no = 1)  
  
	SELECT @time_zone_to=timezone_id from application_users where user_login_id=@user_login_id

	IF @new_flag != 's'
	BEGIN
		IF @new_flag = 'f'
		BEGIN
			
			SET @sqlStmt='SELECT frequency,
						volume,
						term_start,
						term_end
 					 from '+ @tempTable  +' where sno between '+ CAST(@row_from AS VARCHAR) +' and '+ CAST(@row_to AS VARCHAR)+ ' order by sno asc'
		END
		ELSE
		BEGIN
			SET @sqlStmt='select DealID [ID], SourceDealID [Ref ID],DealDate [Deal Date],ExtDealId [Ext ID],PhysicalFinancialFlag [Physical/Financial Flag],
					CptyName [Counterparty],TermStart [Term Start],TermEnd [Term End],DealType [Deal Type],DealSubType [Deal Sub Type],OptionFlag [Option Flag],
					OptionType [Option Type],ExcerciseType [Exercise Type],Group1 As ['+ @group1 +'],
					Group2 As ['+ @group2 +'],Group3 As ['+ @group3 +'],Group4 As ['+ @group4 +'],Desc1 AS [Description 1],Desc2 AS [Description 2],Desc3 AS [Description 3],DealCategoryValueId [Deal Category],TraderName [Trader],
					HedgeItemFlag [Hedge/Item Flag] ,HedgeType [Hedge Type],AssignType [Assign Type], deal_locked [Locked],Pricing,CreatedDate [Created Date],ConfirmStatus [Confirm Status],[Signed Off By],[Sign Off Date] as [Signed Off Date], [Broker],[Comments]
 					 from '+ @tempTable  +' where sno between '+ CAST(@row_from AS VARCHAR) +' and '+ CAST(@row_to AS VARCHAR)+ ' order by sno asc'
		END
	END
	ELSE
	BEGIN

		SET @sqlStmt='select 
			DealID [ID], 
			SourceDealID [Ref ID],
			DealDate [Deal Date],
			ExtDealId [Ext ID],
			PhysicalFinancialFlag [Phy/Fin],
			CptyName [Counterparty],
			TermStart [Term Start],
			TermEnd [Term End],
			DealType [Deal Type],
			DealSubType [Deal Sub Type],
			OptionFlag [Option Flag],
			OptionType [Option Type],
			ExcerciseType [Exercise Type],
			Group1 As ['+ @group1 +'],
			Group2 As ['+ @group2 +'],
			Group3 As ['+ @group3 +'],
			Group4 As ['+ @group4 +'],
			Desc1,
			Desc2,
			Desc3,
			DealCategoryValueId [Deal Category],
			TraderName [Trader],
			HedgeItemFlag [Hedge/Item Flag] ,
			HedgeType [Hedge Type],
			AssignType [Assign Type], 
			deal_locked [Locked],
			Pricing,
			CreatedDate [Created Date],
			ConfirmStatus [Confirm Status],
			[Signed Off By],
			[Sign Off Date],
			[Broker],
			[Comments],
			[Commodity],
			[deal Rules],
			[confirm Rules]
 			 from '+ @tempTable  +' where sno between '+ CAST(@row_from AS VARCHAR) +' and '+ CAST(@row_to AS VARCHAR)+ ' order by sno asc'
	END
	
	EXEC spa_print @sqlStmt	
	EXEC(@sqlStmt)
	EXEC spa_print @tempTable
	
END

GO