
/****** Object:  StoredProcedure [dbo].[spa_sourcedealheader_confirm_paging]    Script Date: 07/24/2011 19:48:14 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_sourcedealheader_confirm_paging]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_sourcedealheader_confirm_paging]
GO


/****** Object:  StoredProcedure [dbo].[spa_sourcedealheader_confirm_paging]    Script Date: 07/24/2011 19:48:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[spa_sourcedealheader_confirm_paging] 
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
		@counterparty_id VARCHAR(MAX)=NULL,
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
		@confirm_type VARCHAR(50) =NULL,
		@deal_locked CHAR(1)=NULL,
		@sub_entity_id VARCHAR(1000)=NULL,
		@strategy_entity_id VARCHAR(1000)=NULL,
		@book_entity_id VARCHAR(1000)=NULL,
		@deleted_deal VARCHAR(1)='n',
		@deal_status VARCHAR(500) = NULL,
		@history_status CHAR(1) = NULL ,
		@process_id_paging VARCHAR(500)=NULL, 
		@page_size INT =NULL,
		@page_no INT = NULL
		
AS

DECLARE @user_login_id VARCHAR(50),@tempTable VARCHAR(MAX) ,@flag CHAR(1), @new_flag CHAR(1)

SET @new_flag = @flag_pre

IF @book_entity_id IS NULL
	SET @book_entity_id = @book_id


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
		SET @sqlStmt='create table '+ @tempTable+'( 
		sno INT  IDENTITY(1, 1),
		deal_id VARCHAR(1000),
		deal_status VARCHAR(1000),
		confirm_status VARCHAR(100),
		deal_date VARCHAR(500),	
		deal_type VARCHAR(500),
		reference_id VARCHAR(500),
		counterparty VARCHAR(500),
		buy_sell VARCHAR(50),
		term_start VARCHAR(500),
		term_end VARCHAR(500),
		volume VARCHAR(1000),
		daily_volume VARCHAR(1000),
		total_contract_volume VARCHAR(1000),
		volume_uom VARCHAR(500),
		block_definition VARCHAR(500),
		price VARCHAR(500),
		price_uom VARCHAR(500),
		delivery_location VARCHAR(500),
		trader VARCHAR(500),
		deal_category VARCHAR(500),
		contract VARCHAR(500),
		dealRules int,
		confirmRules int,
		DealID varchar(500),
		counterparty_id INT,
		physical_deal_locked varchar(10),
		deal_status_id varchar(10)
		--deal_locked varCHAR(50),
		--UserID varchar(100),
		--CreatedDate varchar(20),
		--isConfirmed CHAR(1),
		--CounterPartyId int,
		--Buy_Sell CHAR(1),
		--CommodityID INT,
		--ContractID varchar(50),
		--DealTypeID varchar(50),
		--PhyDealLock varchar(50),
		)'

		--exec spa_sourcedealheader_confirm 's',NULL,NULL,NULL,'2011-06-21','2011-07-21',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'17200','b','149',NULL,NULL
	---END
	
	EXEC(@sqlStmt)
		set @sqlStmt=' insert  '+@tempTable+'
		exec spa_sourcedealheader_confirm '+ 
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
		dbo.FNASingleQuote(@confirm_type)+','+
		dbo.FNASingleQuote(@deal_locked)+','+
		dbo.FNASingleQuote(@sub_entity_id)+','+
		dbo.FNASingleQuote(@strategy_entity_id)+','+
		dbo.FNASingleQuote(@book_entity_id) + ', NULL, ' +
		dbo.FNASingleQuote(@deal_status) + ', ' + dbo.FNASingleQuote(@history_status)

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
	
			SET @sqlStmt = 'SELECT deal_id,
			                     deal_status,
			                     confirm_status,
			                     deal_date,
			                     deal_type,
			                     reference_id,
			                     counterparty,
			                     buy_sell,
			                     term_start,
			                     term_end,
			                     volume,
			                     daily_volume,
			                     total_contract_volume,
			                     volume_uom,
			                     block_definition,
			                     price,
			                     price_uom,
			                     delivery_location,
			                     trader,
			                     deal_category,
			                     CONTRACT,
			                     dealRules,
								 confirmRules,
								 DealID,
								 counterparty_id,
								 physical_deal_locked
			              FROM    ' + @tempTable  + 
			              ' WHERE sno BETWEEN ' + CAST(@row_from AS VARCHAR) + ' AND ' + CAST(@row_to AS VARCHAR) + 
			              ' ORDER BY sno ASC'
		END
	ELSE
	BEGIN

		
		SET @sqlStmt = 
		    'SELECT deal_id [Deal ID],
		            deal_status [Deal Status],
		            confirm_status [Confirm Status],
		            deal_date [Deal Date],
		            deal_type [Deal Type],
		            reference_id [Reference ID],
		            counterparty [Counterparty],
		            buy_sell [Buy/Sell],
		            term_start [Term Start],
		            term_end [Term End],
		            volume [Volume],
		            daily_volume [Daily Volume],
		            total_contract_volume [Total Contract Volume],
		            volume_uom [Volume UOM],
		            block_definition [Block Definition],
		            price [Price],
		            price_uom [Price UOM],
		            delivery_location [Delivery Location],
		            trader [Trader],
		            deal_category [Deal Category],
		            contract [Contract],
		            dealRules [Deal Rules],
					confirmRules [Confirm Rules],
					DealID [Deal ID],
					counterparty_id [Counterparty ID],
					physical_deal_locked [Physical Deal Locked],
					deal_status_id [Deal Status ID]
		     FROM   ' + @tempTable + ' 
		     WHERE sno BETWEEN ' + CAST(@row_from AS VARCHAR) 
				+ ' AND ' + CAST(@row_to AS VARCHAR) + ' ORDER BY sno ASC'
	END
	
	EXEC spa_print @sqlStmt	
	EXEC(@sqlStmt)
	EXEC spa_print @tempTable
	
END

GO