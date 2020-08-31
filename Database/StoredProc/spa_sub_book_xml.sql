
-- ===========================================================================================================
-- Author: arai@pioneersolutionsglobal.com
-- Create date: 2015-07-09
-- Description: Insert and update in source_system_book_map
-- Params:
-- @flag     CHAR - Operation flag
-- ===========================================================================================================

IF OBJECT_ID(N'[dbo].[spa_sub_book_xml]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_sub_book_xml]
GO
SET ANSI_NULLS ON
GO

/**
 Stored Procedure to Insert/Update data in source_system_book_map. 
 Parameters
	@flag : Operation flag optional
			i - insert data in fas_strategy.  
			u - update data in fas_strategy.			
	@xml : xml data.
	@function_id: application function id
*/
 

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_sub_book_xml]
	 @flag CHAR(1)
	 , @xml NVARCHAR(MAX) = NULL
	 , @function_id VARCHAR(20) = NULL
AS
/*
declare @flag CHAR(1)
	 , @xml XML = NULL
	 , @function_id NVARCHAR(20) = NULL

select @xml='<Root function_id="10101213"><FormXML ID="650" book_deal_type_map_id=" 650" logical_name=" 0 Sub book test  sdf" fas_book_id=" 462" source_system_book_id1=" 590" source_system_book_id2=" -2" source_system_book_id3=" 655" source_system_book_id4=" 649" fas_deal_type_value_id=" 400" effective_start_date=" " end_date=" " percentage_included=" " primary_counterparty_id=" " sub_book_group1=" " sub_book_group2=" " sub_book_group3=" " sub_book_group4=" " gl_number_id_st_asset=" " gl_number_id_lt_asset=" " gl_number_id_st_liab=" " gl_number_id_lt_liab=" " gl_number_unhedged_der_st_asset=" " gl_number_unhedged_der_lt_asset=" " gl_number_unhedged_der_st_liab=" " gl_number_unhedged_der_lt_liab=" " gl_number_id_item_st_asset=" " gl_number_id_item_st_liab=" " gl_number_id_item_lt_asset=" " gl_number_id_item_lt_liab=" " gl_id_st_tax_asset=" " gl_id_lt_tax_asset=" " gl_id_st_tax_liab=" " gl_id_lt_tax_liab=" " gl_id_tax_reserve=" " gl_number_id_aoci=" " gl_number_id_inventory=" " gl_number_id_pnl=" " gl_number_id_set=" " gl_number_id_cash=" " gl_number_id_gross_set=" " gl_id_interest=" " gl_id_amortization=" " gl_number_id_expense=" "></FormXML></Root>',@flag='u',@function_id='10101213'
--*/
SET NOCOUNT ON

DECLARE @idoc INT
DECLARE @idoc1 INT
DECLARE @DESC NVARCHAR(500)
DECLARE @err_no INT

EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

IF OBJECT_ID('tempdb..#temp_general_form') IS NOT NULL
	DROP TABLE #temp_general_form

SELECT 
NULLIF(logical_name,'')  logical_name
, NULLIF(fas_book_id,'')  fas_book_id
, NULLIF(book_deal_type_map_id,'')  book_deal_type_map_id
, NULLIF(source_system_book_id1,'')  source_system_book_id1
, NULLIF(source_system_book_id2,'')  source_system_book_id2
, NULLIF(source_system_book_id3,'')  source_system_book_id3
, NULLIF(source_system_book_id4,'')  source_system_book_id4
, NULLIF(fas_deal_type_value_id,'')  fas_deal_type_value_id
, NULLIF(fas_deal_sub_type_value_id,'')  fas_deal_sub_type_value_id
, NULLIF(effective_start_date,'')  effective_start_date
, NULLIF(percentage_included,'')  percentage_included
, NULLIF(end_date,'')  end_date
, NULLIF(sub_book_group1,'')  sub_book_group1
, NULLIF(sub_book_group2,'')  sub_book_group2
, NULLIF(sub_book_group3,'')  sub_book_group3
, NULLIF(sub_book_group4,'')  sub_book_group4
, NULLIF(gl_number_id_st_asset,'')  gl_number_id_st_asset
, NULLIF(gl_number_id_lt_asset,'')  gl_number_id_lt_asset
, NULLIF(gl_number_id_st_liab,'')  gl_number_id_st_liab
, NULLIF(gl_number_id_lt_liab,'')  gl_number_id_lt_liab
, NULLIF(gl_id_st_tax_asset,'')  gl_id_st_tax_asset
, NULLIF(gl_id_lt_tax_asset,'')  gl_id_lt_tax_asset
, NULLIF(gl_id_st_tax_liab,'')  gl_id_st_tax_liab
, NULLIF(gl_id_lt_tax_liab,'')  gl_id_lt_tax_liab
, NULLIF(gl_id_tax_reserve,'')  gl_id_tax_reserve
, NULLIF(gl_number_id_aoci,'')  gl_number_id_aoci
, NULLIF(gl_number_id_inventory,'')  gl_number_id_inventory
, NULLIF(gl_number_id_pnl,'')  gl_number_id_pnl
, NULLIF(gl_number_id_set,'')  gl_number_id_set
, NULLIF(gl_number_id_cash,'')  gl_number_id_cash
, NULLIF(gl_number_id_gross_set,'')  gl_number_id_gross_set
, NULLIF(gl_number_id_item_st_asset, '') gl_number_id_item_st_asset
, NULLIF(gl_number_id_item_st_liab, '') gl_number_id_item_st_liab
, NULLIF(gl_number_id_item_lt_asset, '') gl_number_id_item_lt_asset
, NULLIF(gl_number_id_item_lt_liab, '')  gl_number_id_item_lt_liab
, NULLIF(gl_number_unhedged_der_st_asset, '') gl_number_unhedged_der_st_asset
, NULLIF(gl_number_unhedged_der_lt_asset, '') gl_number_unhedged_der_lt_asset
, NULLIF(gl_number_unhedged_der_st_liab, '') gl_number_unhedged_der_st_liab
, NULLIF(gl_number_unhedged_der_lt_liab, '') gl_number_unhedged_der_lt_liab
, NULLIF(gl_id_amortization, '') gl_id_amortization
, NULLIF(gl_id_interest, '') gl_id_interest
, NULLIF(gl_number_id_expense, '') gl_number_id_expense
, NULLIF(primary_counterparty_id,'') primary_counterparty_id
, NULLIF(accounting_code,'') accounting_code

INTO #temp_general_form
--FROM   OPENXML(@idoc, '/FormXML', 1)
FROM OPENXML(@idoc, '/Root/FormXML', 2) 
WITH (
	logical_name NVARCHAR(200) '@logical_name'
	, fas_book_id INT '@fas_book_id'
	, book_deal_type_map_id INT '@book_deal_type_map_id'
	, source_system_book_id1 INT '@source_system_book_id1'
	, source_system_book_id2 INT '@source_system_book_id2'
	, source_system_book_id3 INT '@source_system_book_id3'
	, source_system_book_id4 INT '@source_system_book_id4'
	, fas_deal_type_value_id INT '@fas_deal_type_value_id'
	, fas_deal_sub_type_value_id INT '@fas_deal_sub_type_value_id'
	, effective_start_date NVARCHAR(200) '@effective_start_date'
	, percentage_included NVARCHAR(20) '@percentage_included'
	, end_date NVARCHAR(200) '@end_date'
	, sub_book_group1 NVARCHAR(50) '@sub_book_group1'
	, sub_book_group2 NVARCHAR(50) '@sub_book_group2'
	, sub_book_group3 NVARCHAR(50) '@sub_book_group3'
	, sub_book_group4 NVARCHAR(50) '@sub_book_group4'
	, gl_number_id_st_asset NVARCHAR(50) '@gl_number_id_st_asset'
	, gl_number_id_lt_asset NVARCHAR(50) '@gl_number_id_lt_asset'
	, gl_number_id_st_liab NVARCHAR(50) '@gl_number_id_st_liab'
	, gl_number_id_lt_liab NVARCHAR(50) '@gl_number_id_lt_liab'
	, gl_id_st_tax_asset NVARCHAR(50) '@gl_id_st_tax_asset'
	, gl_id_lt_tax_asset NVARCHAR(50) '@gl_id_lt_tax_asset'
	, gl_id_st_tax_liab NVARCHAR(50) '@gl_id_st_tax_liab'
	, gl_id_lt_tax_liab NVARCHAR(50) '@gl_id_lt_tax_liab'
	, gl_id_tax_reserve NVARCHAR(50) '@gl_id_tax_reserve'
	, gl_number_id_aoci NVARCHAR(50) '@gl_number_id_aoci'
	, gl_number_id_inventory NVARCHAR(50) '@gl_number_id_inventory'
	, gl_number_id_pnl NVARCHAR(50) '@gl_number_id_pnl'
	, gl_number_id_set NVARCHAR(50) '@gl_number_id_set'
	, gl_number_id_cash NVARCHAR(50) '@gl_number_id_cash'
	, gl_number_id_gross_set NVARCHAR(50) '@gl_number_id_gross_set'
	, gl_number_id_item_st_asset INT '@gl_number_id_item_st_asset' 
	, gl_number_id_item_st_liab INT '@gl_number_id_item_st_liab'
	, gl_number_id_item_lt_asset INT '@gl_number_id_item_lt_asset'
	, gl_number_id_item_lt_liab INT '@gl_number_id_item_lt_liab'
	, gl_number_unhedged_der_st_asset INT '@gl_number_unhedged_der_st_asset'
	, gl_number_unhedged_der_lt_asset INT '@gl_number_unhedged_der_lt_asset'
	, gl_number_unhedged_der_st_liab INT '@gl_number_unhedged_der_st_liab'
	, gl_number_unhedged_der_lt_liab INT '@gl_number_unhedged_der_lt_liab'
	, gl_id_amortization INT '@gl_id_amortization'
	, gl_id_interest INT '@gl_id_interest'
	, gl_number_id_expense INT '@gl_number_id_expense'
	, primary_counterparty_id INT '@primary_counterparty_id'
	, accounting_code VARCHAR(500) '@accounting_code'
)

IF @flag = 'i'
BEGIN
	IF EXISTS(
			SELECT 1 from #temp_general_form where source_system_book_id1 = -1
	)
	BEGIN	
	
		IF EXISTS (
				SELECT 1
				FROM source_system_book_map ssbm
				INNER JOIN #temp_general_form tgf 
					ON ssbm.source_system_book_id2 = tgf.source_system_book_id2
					AND ssbm.source_system_book_id3 = tgf.source_system_book_id3
					AND ssbm.source_system_book_id4 = tgf.source_system_book_id4
					AND ssbm.source_system_book_id2 <> -2
					AND ssbm.source_system_book_id3 <> -3
					AND ssbm.source_system_book_id4 <> -4
				)
		
		BEGIN
			SET @desc = 'The combination of tagging fields already exists.'

			EXEC spa_ErrorHandler - 1, 'Sub Book Data', 'spa_sub_book_xml', 'The combination of tagging fields already exists.', @desc, ''

			RETURN
		END

		BEGIN TRY
			BEGIN TRANSACTION
			DECLARE @source_book_id INT

			IF EXISTS (	SELECT 1
						FROM #temp_general_form tgf 
							INNER JOIN source_book sb ON sb.source_system_book_id = tgf.logical_name
						WHERE sb.source_system_id = 2
			
			)
			BEGIN
				SELECT @source_book_id = source_book_id
				FROM #temp_general_form tgf 
					INNER JOIN source_book sb ON sb.source_system_book_id = tgf.logical_name
				WHERE sb.source_system_id = 2
			END 
			ELSE
			BEGIN
				INSERT INTO source_book (
				source_system_id, --2
				source_system_book_id, --code
				source_system_book_type_value_id, -- 50
				source_book_name, source_book_desc
				)
				SELECT 2, tgf.logical_name, 50, tgf.logical_name, tgf.logical_name
				FROM #temp_general_form tgf

			
				SET @source_book_id = SCOPE_IDENTITY()
			END

			INSERT INTO source_system_book_map (
				logical_name, fas_book_id,
				--book_deal_type_map_id,
				source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4, fas_deal_type_value_id, fas_deal_sub_type_value_id, effective_start_date, percentage_included,
				end_date, sub_book_group1, sub_book_group2, sub_book_group3, sub_book_group4, primary_counterparty_id, accounting_code
				)
			SELECT tgf.logical_name, tgf.fas_book_id,
				--tgf.book_deal_type_map_id,
				@source_book_id, tgf.source_system_book_id2, tgf.source_system_book_id3, tgf.source_system_book_id4, tgf.fas_deal_type_value_id, tgf.fas_deal_sub_type_value_id, NULLIF(tgf.effective_start_date, ''), NULLIF(tgf.percentage_included, 0) 
				,NUllIF(tgf.end_date, '') , sub_book_group1, sub_book_group2, sub_book_group3, sub_book_group4, tgf.primary_counterparty_id, tgf.accounting_code
			FROM #temp_general_form tgf

			DECLARE @book_deal_type_map_id INT

			SET @book_deal_type_map_id = SCOPE_IDENTITY()
			
			INSERT INTO source_book_map_GL_codes ( 
				   source_book_map_id
				 , gl_number_id_st_asset 
				 , gl_number_id_lt_asset 
				 , gl_number_id_st_liab 
				 , gl_number_id_lt_liab 
				 , gl_id_st_tax_asset 
				 , gl_id_lt_tax_asset 
				 , gl_id_st_tax_liab 
				 , gl_id_lt_tax_liab 
				 , gl_id_tax_reserve 
				 , gl_number_id_aoci 
				 , gl_number_id_inventory
				 , gl_number_id_pnl 
				 , gl_number_id_set 
				 , gl_number_id_cash
				 , gl_number_id_gross_set
			 ) SELECT @book_deal_type_map_id
					 , gl_number_id_st_asset 
					 , gl_number_id_lt_asset 
					 , gl_number_id_st_liab 
					 , gl_number_id_lt_liab 
					 , gl_id_st_tax_asset 
					 , gl_id_lt_tax_asset 
					 , gl_id_st_tax_liab 
					 , gl_id_lt_tax_liab 
					 , gl_id_tax_reserve 
					 , gl_number_id_aoci 
					 , gl_number_id_inventory
					 , gl_number_id_pnl 
					 , gl_number_id_set 
					 , gl_number_id_cash
					 , gl_number_id_gross_set
			FROM  #temp_general_form	

			COMMIT TRANSACTION

			
			--Release Bookstructure cache key.
			IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
			BEGIN
				EXEC [spa_manage_memcache] @flag = 'd', @other_key_source='BookStructure', @source_object = 'spa_sub_book_xml @flag=i'
			END
			
			IF @book_deal_type_map_id IS NULL
				SELECT @book_deal_type_map_id = book_deal_type_map_id FROM #temp_general_form
			
			EXEC spa_ErrorHandler 0, 'source_system_book_map', 'spa_sub_book_xml', 'Success', 'Changes have been saved successfully.', @book_deal_type_map_id
		END TRY

		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK

			--SET @desc = 'Logical name must be unique.' --dbo.FNAHandleDBError(@function_id)
			SET @desc = 'Duplicate value in (<b>Sub Book</b>).'

			EXEC spa_ErrorHandler - 1, 'Sub Book Data', 'spa_sub_book_xml', 'Error', @desc, ''

		END CATCH
	END
	ELSE -- if tag 1 != -1 
	BEGIN
		IF EXISTS (
				SELECT ssbm.*
				FROM source_system_book_map ssbm
				INNER JOIN #temp_general_form tgf ON ssbm.source_system_book_id1 = tgf.source_system_book_id1
					AND ssbm.source_system_book_id2 = tgf.source_system_book_id2
					AND ssbm.source_system_book_id3 = tgf.source_system_book_id3
					AND ssbm.source_system_book_id4 = tgf.source_system_book_id4
					--AND	ssbm.source_system_book_id2 <> -2
					--AND ssbm.source_system_book_id3 <> -3
					--AND ssbm.source_system_book_id4 <> -4
				)
		
		BEGIN
			SET @desc = 'The combination of tagging fields already exists.'

			EXEC spa_ErrorHandler - 1, 'Sub Book Data', 'spa_sub_book_xml', 'The combination of tagging fields already exists.', @desc, ''

			RETURN
		END

		BEGIN TRY
			BEGIN TRANSACTION

			INSERT INTO source_system_book_map (
				logical_name, fas_book_id,
				--book_deal_type_map_id,
				source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4, fas_deal_type_value_id, fas_deal_sub_type_value_id, effective_start_date, percentage_included
				,end_date, sub_book_group1, sub_book_group2, sub_book_group3, sub_book_group4,primary_counterparty_id, accounting_code
				)
			SELECT tgf.logical_name, tgf.fas_book_id,
					--tgf.book_deal_type_map_id,
					tgf.source_system_book_id1, 
					tgf.source_system_book_id2, 
					tgf.source_system_book_id3,
					tgf.source_system_book_id4, 
					tgf.fas_deal_type_value_id, 
					tgf.fas_deal_sub_type_value_id, 
					NULLIF(tgf.effective_start_date, ''), 
					NULLIF(tgf.percentage_included, 0),
					NULLIF(tgf.end_date, ''), sub_book_group1, sub_book_group2, sub_book_group3, sub_book_group4,tgf.primary_counterparty_id, tgf.accounting_code
			FROM #temp_general_form tgf

			SET @book_deal_type_map_id = SCOPE_IDENTITY()

			INSERT INTO source_book_map_GL_codes ( 
				   source_book_map_id
				 , gl_number_id_st_asset 
				 , gl_number_id_lt_asset 
				 , gl_number_id_st_liab 
				 , gl_number_id_lt_liab 
				 , gl_id_st_tax_asset 
				 , gl_id_lt_tax_asset 
				 , gl_id_st_tax_liab 
				 , gl_id_lt_tax_liab 
				 , gl_id_tax_reserve 
				 , gl_number_id_aoci 
				 , gl_number_id_inventory
				 , gl_number_id_pnl 
				 , gl_number_id_set 
				 , gl_number_id_cash
				 , gl_number_id_gross_set
			 ) SELECT @book_deal_type_map_id
					 , gl_number_id_st_asset 
					 , gl_number_id_lt_asset 
					 , gl_number_id_st_liab 
					 , gl_number_id_lt_liab 
					 , gl_id_st_tax_asset 
					 , gl_id_lt_tax_asset 
					 , gl_id_st_tax_liab 
					 , gl_id_lt_tax_liab 
					 , gl_id_tax_reserve 
					 , gl_number_id_aoci 
					 , gl_number_id_inventory
					 , gl_number_id_pnl 
					 , gl_number_id_set 
					 , gl_number_id_cash
					 , gl_number_id_gross_set
			FROM  #temp_general_form
			COMMIT TRANSACTION

			
			--Release Bookstructure cache key.
			IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
			BEGIN
				EXEC [spa_manage_memcache] @flag = 'd', @other_key_source='BookStructure', @source_object = 'spa_sub_book_xml @flag=i'
			END

			IF @book_deal_type_map_id IS NULL
				SELECT @book_deal_type_map_id = book_deal_type_map_id FROM #temp_general_form

			EXEC spa_ErrorHandler 0, 'source_system_book_map', 'spa_sub_book_xml', 'Success', 'Changes have been saved successfully.', @book_deal_type_map_id
		END TRY

		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK

			SET @desc = 'Logical name must be unique.' --dbo.FNAHandleDBError(@function_id)

			EXEC spa_ErrorHandler - 1, 'Sub Book Data', 'spa_sub_book_xml', 'Error', @desc, ''

		END CATCH

	END
END

IF @flag = 'u'
BEGIN		 
	IF EXISTS (
			SELECT 1
			FROM source_system_book_map ssbm
			INNER JOIN #temp_general_form tgf ON ssbm.logical_name = tgf.logical_name
				AND ssbm.book_deal_type_map_id <> tgf.book_deal_type_map_id
			)
	BEGIN
		SET @desc = 'The combination of tagging fields already exists.'

		EXEC spa_ErrorHandler - 1, 
		'Sub Book Data', 
		'spa_sub_book_xml', 
		'The Logical Name already exists.', 
		'The Logical Name already exists.',
		''
		RETURN
	END
	 
	IF EXISTS (
			SELECT 1
			FROM source_system_book_map ssbm
			INNER JOIN #temp_general_form tgf ON ssbm.source_system_book_id1 = tgf.source_system_book_id1
				AND ssbm.source_system_book_id2 = tgf.source_system_book_id2
				AND ssbm.source_system_book_id3 = tgf.source_system_book_id3
				AND ssbm.source_system_book_id4 = tgf.source_system_book_id4
				AND ssbm.book_deal_type_map_id <> tgf.book_deal_type_map_id
				--AND ssbm.source_system_book_id1 <> -1
				--AND ssbm.source_system_book_id2 <> -2
				--AND ssbm.source_system_book_id3 <> -3
				--AND ssbm.source_system_book_id4 <> -4
			)
	BEGIN
		SET @desc = 'The combination of tagging fields already exists.'

		EXEC spa_ErrorHandler - 1, 
		'Sub Book Data', 
		'spa_sub_book_xml', 
		'The combination of tagging fields already exists.', 
		@desc,
		''
		RETURN
	END

	
	BEGIN TRY
		BEGIN TRANSACTION

		--DECLARE @hold_source_book_id INT
		/*
        UPDATE  sb
		SET source_system_book_id = tgf.logical_name, 
        source_book_name =  tgf.logical_name, 
        source_book_desc= tgf.logical_name
		FROM #temp_general_form tgf
		INNER JOIN source_book sb ON tgf.source_system_book_id1 = sb.source_book_id
		*/
		DECLARE @disable_tagging BIT

		SELECT @disable_tagging = var_value
		FROM adiha_default_codes_values
		WHERE default_code_id = 104
			AND var_value = 0
		
		SET @disable_tagging = ISNULL(@disable_tagging, 1)

		IF @disable_tagging = 0 AND NOT EXISTS (SELECT 1 FROM #temp_general_form tgf INNER JOIN source_book sb ON sb.source_system_book_id = tgf.logical_name)
		BEGIN
			INSERT INTO source_book (source_system_id, source_system_book_id, source_system_book_type_value_id, source_book_name, source_book_desc)
			SELECT 2, tgf.logical_name, 50, tgf.logical_name, tgf.logical_name
			FROM #temp_general_form tgf 
			INNER JOIN source_book sb ON tgf.source_system_book_id1 = sb.source_book_id

			DECLARE @source_system_book_id1 INT
			SET @source_system_book_id1 = SCOPE_IDENTITY()			
		END

	--	select * from source_book order by 1 desc
		UPDATE ssbm
		SET logical_name = tgf.logical_name, 
		fas_book_id = tgf.fas_book_id, 
		source_system_book_id1 = IIF(@disable_tagging = 0 AND @source_system_book_id1 IS NOT NULL, @source_system_book_id1, tgf.source_system_book_id1), 
		source_system_book_id2 = tgf.source_system_book_id2, 
		source_system_book_id3 = tgf.source_system_book_id3, 
		source_system_book_id4 = tgf.source_system_book_id4, 
		fas_deal_type_value_id = tgf.fas_deal_type_value_id,
		fas_deal_sub_type_value_id = tgf.fas_deal_sub_type_value_id
		, effective_start_date = NULLIF(tgf.effective_start_date, '')
		, percentage_included = tgf.percentage_included
		, end_date = NULLIF(tgf.end_date, '')
		, sub_book_group1 = tgf.sub_book_group1
		, sub_book_group2 = tgf.sub_book_group2
		, sub_book_group3 = tgf.sub_book_group3
		, sub_book_group4 = tgf.sub_book_group4
		, primary_counterparty_id = tgf.primary_counterparty_id
		, accounting_code = tgf.accounting_code
		FROM #temp_general_form tgf
		INNER JOIN source_system_book_map ssbm 
		ON tgf.book_deal_type_map_id = ssbm.book_deal_type_map_id
		UPDATE  sbmgc 
		SET	  gl_number_id_st_asset = tgf.gl_number_id_st_asset  
			, gl_number_id_lt_asset = tgf.gl_number_id_lt_asset
			, gl_number_id_st_liab = tgf.gl_number_id_st_liab 
			, gl_number_id_lt_liab = tgf.gl_number_id_lt_liab
			, gl_id_st_tax_asset = tgf.gl_id_st_tax_asset
			, gl_id_lt_tax_asset = tgf.gl_id_lt_tax_asset
			, gl_id_st_tax_liab = tgf.gl_id_st_tax_liab
			, gl_id_lt_tax_liab = tgf.gl_id_lt_tax_liab
			, gl_id_tax_reserve = tgf.gl_id_tax_reserve
			, gl_number_id_aoci = tgf.gl_number_id_aoci
			, gl_number_id_inventory = tgf.gl_number_id_inventory
			, gl_number_id_pnl = tgf.gl_number_id_pnl
			, gl_number_id_set = tgf.gl_number_id_set
			, gl_number_id_cash = tgf.gl_number_id_cash
			, gl_number_id_gross_set = tgf.gl_number_id_gross_set
			, gl_number_id_item_st_asset = tgf.gl_number_id_item_st_asset
		    , gl_number_id_item_st_liab = tgf.gl_number_id_item_st_liab
		    , gl_number_id_item_lt_asset = tgf.gl_number_id_item_lt_asset
		    , gl_number_id_item_lt_liab = tgf.gl_number_id_item_lt_liab
		    , gl_number_unhedged_der_st_asset = tgf.gl_number_unhedged_der_st_asset
		    , gl_number_unhedged_der_lt_asset = tgf.gl_number_unhedged_der_lt_asset
		    , gl_number_unhedged_der_st_liab = tgf.gl_number_unhedged_der_st_liab
		    , gl_number_unhedged_der_lt_liab = tgf.gl_number_unhedged_der_lt_liab
		    , gl_id_amortization = tgf.gl_id_amortization
		    , gl_id_interest = tgf.gl_id_interest
		    , gl_number_id_expense = tgf.gl_number_id_expense
			
		FROM #temp_general_form tgf
			INNER JOIN source_book_map_GL_codes sbmgc
		 ON tgf.book_deal_type_map_id = sbmgc.source_book_map_id
		
       --Release Bookstructure cache key.
		IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
		BEGIN
			EXEC [spa_manage_memcache] @flag = 'd', @other_key_source='BookStructure', @source_object = 'spa_sub_book_xml @flag=u'
		END

	
		COMMIT TRANSACTION

		IF @book_deal_type_map_id IS NULL
				SELECT @book_deal_type_map_id = book_deal_type_map_id FROM #temp_general_form

		EXEC spa_ErrorHandler 0, 'storage_assets', 'spa_storage_assets', 'Success', 'Changes have been saved successfully.', @book_deal_type_map_id
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK

		SET @desc = ERROR_MESSAGE()

		EXEC spa_ErrorHandler - 1, 'Sub Book Data', 'spa_sub_book_xml', 'Error', @desc, ''
	END CATCH
END