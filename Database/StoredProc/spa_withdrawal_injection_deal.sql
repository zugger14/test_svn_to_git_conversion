IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_withdrawal_injection_deal]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_withdrawal_injection_deal]
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
* @single_deal_multiple_term = 1 
* Create single deal with multiple terms schedule deals. By default this is set to 0 to create multiple deals single term schedule deal.
* @flag = 'i' - Insert schedule transportation deal.
* @flag = 'r' - Reschedule transportation deal.
* @flag = 'd' - Delete scheduled deals.
*/
CREATE PROCEDURE [dbo].[spa_withdrawal_injection_deal]
	@flag CHAR(1), 
	@sub_book INT,
	@deal_volume NUMERIC(38, 18) , 
	@deal_date DATETIME,
	@location_id INT,	
	@contract_id INT,
	@counterparty_id INT,
	@inserted_deal_id INT OUTPUT
AS
SET NOCOUNT ON

/*
DECLARE @flag CHAR(1), 
		@contract_id INT, 
		@deal_volume NUMERIC(38, 18) , 
		@location_id INT,
		@deal_date DATETIME,
		@sub_book INT,
		@counterparty_id INT,
		@inserted_deal_id INT


--w	278	500.000000000000000000	2016-04-04 00:00:00.000	1519	3875	4352
SET @flag = 'w'
SET @sub_book = 278
SET @deal_volume = 500.000000000000000000 
SET @deal_date = '2016-04-04 00:00:00.000'
SET @location_id = 1519	
SET @contract_id = 3875
SET	@counterparty_id = 4352
--*/

DECLARE	@book_map1 INT,
		@book_map2 INT, 
		@book_map3 INT,
		@book_map4 INT,
		@frequency CHAR(1),
		@template_id INT,
		@process_id VARCHAR(200),
		@prefix VARCHAR(20)


SET @process_id = dbo.FNAGetNewID()

SET @frequency = 'd'

IF @flag = 'i'
BEGIN
	SELECT @template_id = template_id
	FROM source_deal_header_template 
	WHERE template_name = 'Storage Injection'

	SET @prefix = 'INJC_'
END
ELSE
BEGIN
	SELECT @template_id = template_id
	FROM source_deal_header_template 
	WHERE template_name = 'Storage Withdrawal'
	
	SET @prefix = 'WTHD_'
	
END

SELECT	 @book_map1 =  source_system_book_id1
		,@book_map2 = source_system_book_id2
		,@book_map3 = source_system_book_id3
		,@book_map4 = source_system_book_id4
FROM source_system_book_map 
WHERE book_deal_type_map_id = @sub_book

IF OBJECT_ID(N'tempdb..#storage_inserted_deals') IS NOT NULL 
	DROP TABLE #storage_inserted_deals


CREATE TABLE #storage_inserted_deals (
	source_deal_header_id		INT
)

BEGIN TRY
	BEGIN TRAN	

	INSERT INTO source_deal_header
		([source_system_id]
		, [deal_id]
		, [deal_date]
		, [physical_financial_flag]
		, [counterparty_id]
		, [entire_term_start]
		, [entire_term_end]
		, [source_deal_type_id]
		, [deal_sub_type_type_id]
		, [option_flag]
		, [option_type]					  		   
		, [source_system_book_id1]
		, [source_system_book_id2]
		, [source_system_book_id3]
		, [source_system_book_id4]
		, [deal_category_value_id]
		, [trader_id]
		, [header_buy_sell_flag]					  
		, create_user
		, create_ts
		, template_id
		, term_frequency
		, contract_id
		, confirm_status_type
		, deal_status
		, commodity_id
		, description1
		, description2	
		, sub_book					
		)
	OUTPUT INSERTED.source_deal_header_id
	INTO #storage_inserted_deals 
	SELECT 2
		,  @prefix + @process_id
		, @deal_date
		, [physical_financial_flag]
		, ISNULL(@counterparty_id, [counterparty_id])
		, @deal_date
		, @deal_date
		, [source_deal_type_id]
		, [deal_sub_type_type_id]
		, [option_flag]
		, [option_type]		
		, @book_map1
		, @book_map2
		, @book_map3
		, @book_map4	
		, [deal_category_value_id]
		, [trader_id]
		, [header_buy_sell_flag]	
		, dbo.FNADBUser()
		, GETDATE()
		, template_id
		, term_frequency
		, contract_id
		, confirm_status_type
		, deal_status
		, ISNULL(@contract_id, contract_id)
		, description1
		, description2	
		, @sub_book		
	FROM source_deal_header_template
	WHERE template_id = @template_id

	SELECT @inserted_deal_id = source_deal_header_id 
	FROM #storage_inserted_deals

	UPDATE sdh
		SET deal_id = @prefix + CAST(@inserted_deal_id AS VARCHAR(10))
	FROM source_deal_header sdh
	WHERE deal_id = @prefix + @process_id
	
	INSERT INTO [dbo].[source_deal_detail] (
		  [source_deal_header_id]
		, [term_start]
		, [term_end]
		, [Leg]
		, [contract_expiration_date]
		, [fixed_float_leg]
		, [buy_sell_flag]
		, [curve_id]
		, [fixed_price]
		, [fixed_price_currency_id]
		, [deal_volume]
		, [deal_volume_frequency]
		, [deal_volume_uom_id]
		, [block_description]
		, [volume_left]
		, [create_user]
		, [create_ts]
		, [location_id]
		, [physical_financial_flag]
		, [pay_opposite]
	)	  

	SELECT @inserted_deal_id
		, @deal_date
		, @deal_date
		, sddt.leg
		, @deal_date
		, sddt.[fixed_float_leg]
		, sddt.[buy_sell_flag]
		, sddt.[curve_id]
		, sddt.[fixed_price]
		, sddt.[fixed_price_currency_id]
		, @deal_volume
		, @frequency
		, sddt.[deal_volume_uom_id]
		, [block_description]
		, @deal_volume
		, dbo.FNADBUser()
		, GETDATE()
		, @location_id
		, sddt.[physical_financial_flag]
		, sddt.[pay_opposite]	
	FROM source_deal_header_template sdht
		INNER JOIN source_deal_detail_template sddt
			ON sdht.template_id = sddt.template_id
	WHERE sdht.template_id = @template_id

	--EXEC spa_ErrorHandler 0 
	--					, 'Schedule' 
	--					, 'spa_withdrawal_injection_deal'
	--					, 'Success'
	--					, 'Successfully save injection and withdrawal deal.'
	--					, @inserted_deal_id
--rollback
	COMMIT
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 
		ROLLBACK

	--EXEC spa_ErrorHandler -1
	--					, 'Schedule' 
	--					, 'spa_withdrawal_injection_deal'
	--					, 'Error'
	--					, 'Injection and withdrawal deal are not saved.'
	--					, ''
END CATCH
			










