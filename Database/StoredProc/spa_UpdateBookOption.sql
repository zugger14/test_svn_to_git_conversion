  IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_UpdateBookOptionXml]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_UpdateBookOptionXml]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
/**
	CRUD operation for books

	Parameters:
	@flag : operational flag
	@xml  : columns values provided in XML 


*/
CREATE PROCEDURE [dbo].[spa_UpdateBookOptionXml]
	@flag CHAR(1),
	@xml TEXT 

AS

SET NOCOUNT ON
--DECLARE @fas_book_id INT 

BEGIN TRY
	DECLARE @id INT 
	DECLARE @idoc INT
	DECLARE @doc VARCHAR(1000)

	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
	
	IF OBJECT_ID('tempdb..#ztbl_xmlvalue') IS NOT NULL
	DROP TABLE #ztbl_xmlvalue

	SELECT 
	NULLIF(ID,'')  ID
	, NULLIF(fas_book_id,'') fas_book_id
	, NULLIF([entity_name],'') [entity_name]
	, NULLIF(fun_cur_value_id,'')  fun_cur_value_id
	, NULLIF(accounting_type,'')  accounting_type
	, NULLIF(no_links_fas_eff_test_profile_id,'') no_links_fas_eff_test_profile_id
	, NULLIF(cost_approach_id,'') cost_approach_id
	, NULLIF(legal_entity,'') legal_entity
	, NULLIF(convert_uom_id,'') convert_uom_id
	, NULLIF(tax_perc,'') tax_perc
	, NULLIF(no_link ,'') no_link
	, NULLIF(hedge_item_same_sign,'') hedge_item_same_sign
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
	
	INTO #ztbl_xmlvalue

	FROM OPENXML (@idoc, '/Root/FormXML', 2)
		 WITH (	 
		 		 ID INT '@ID',
		 		 fas_book_id  INT  '@fas_book_id',
				 [entity_name] VARCHAR(100) '@entity_name',
				 fun_cur_value_id INT '@fun_cur_value_id',
				 accounting_type INT '@accounting_type',
				 no_links_fas_eff_test_profile_id  VARCHAR(50) '@no_links_fas_eff_test_profile_id',
				 cost_approach_id INT '@cost_approach_id',
				 legal_entity INT '@legal_entity',
				 convert_uom_id INT '@convert_uom_id',
				 tax_perc VARCHAR(20) '@tax_perc',
				 no_link CHAR(1) '@no_link',
				 hedge_item_same_sign VARCHAR(250) '@hedge_item_same_sign',
				 gl_number_id_st_asset INT '@gl_number_id_st_asset',
				 gl_number_id_lt_asset INT '@gl_number_id_lt_asset',
				 gl_number_id_st_liab INT '@gl_number_id_st_liab',
				 gl_number_id_lt_liab INT '@gl_number_id_lt_liab',
				 gl_id_st_tax_asset INT '@gl_id_st_tax_asset',
				 gl_id_lt_tax_asset INT '@gl_id_lt_tax_asset',
				 gl_id_st_tax_liab INT '@gl_id_st_tax_liab',
				 gl_id_lt_tax_liab INT '@gl_id_lt_tax_liab',
				 gl_id_tax_reserve INT '@gl_id_tax_reserve',
				 gl_number_id_aoci INT '@gl_number_id_aoci',
				 gl_number_id_inventory INT '@gl_number_id_inventory',
				 gl_number_id_pnl INT '@gl_number_id_pnl',
				 gl_number_id_set INT '@gl_number_id_set',
				 gl_number_id_cash INT '@gl_number_id_cash',
				 gl_number_id_gross_set INT '@gl_number_id_gross_set',
				 gl_number_id_item_st_asset INT '@gl_number_id_item_st_asset', 
		         gl_number_id_item_st_liab INT '@gl_number_id_item_st_liab',
		         gl_number_id_item_lt_asset INT '@gl_number_id_item_lt_asset',
		         gl_number_id_item_lt_liab INT '@gl_number_id_item_lt_liab',
		         gl_number_unhedged_der_st_asset INT '@gl_number_unhedged_der_st_asset',
		         gl_number_unhedged_der_lt_asset INT '@gl_number_unhedged_der_lt_asset',
		         gl_number_unhedged_der_st_liab INT '@gl_number_unhedged_der_st_liab',
		         gl_number_unhedged_der_lt_liab INT '@gl_number_unhedged_der_lt_liab',
		         gl_id_amortization INT '@gl_id_amortization',
		         gl_id_interest INT '@gl_id_interest',
		         gl_number_id_expense INT '@gl_number_id_expense',
				 primary_counterparty_id INT '@primary_counterparty_id',
				 accounting_code VARCHAR(500) '@accounting_code'
				 	 )
	
	IF @flag IN ('i', 'u')
	BEGIN
		--PRINT 'Merge'
		BEGIN TRAN
		
		MERGE portfolio_hierarchy ph
		USING (SELECT [entity_name],ID,fas_book_id
		FROM #ztbl_xmlvalue) zxv ON ph.[entity_id] = zxv.fas_book_id
	
		WHEN NOT MATCHED BY TARGET THEN
		INSERT ([entity_name],hierarchy_level,entity_type_value_id,parent_entity_id)
		VALUES ( zxv.[entity_name],0,527,zxv.ID )
		WHEN MATCHED THEN
		UPDATE SET	 ph.[entity_name] = zxv.[entity_name];
		SET @id = SCOPE_IDENTITY()

		MERGE fas_books AS fs
		USING (
			SELECT fas_book_id,
				 fun_cur_value_id,
				 accounting_type,
				 no_links_fas_eff_test_profile_id,
				 cost_approach_id ,
				 legal_entity ,
				 convert_uom_id ,
				 tax_perc ,			
				 no_link ,
				 hedge_item_same_sign ,
				 gl_number_id_st_asset ,
				 gl_number_id_lt_asset ,
				 gl_number_id_st_liab ,
				 gl_number_id_lt_liab ,
				 gl_id_st_tax_asset ,
				 gl_id_lt_tax_asset ,
				 gl_id_st_tax_liab ,
				 gl_id_lt_tax_liab ,
				 gl_id_tax_reserve ,
				 gl_number_id_aoci ,
				 gl_number_id_inventory ,
				 gl_number_id_pnl,
				 gl_number_id_set ,
				 gl_number_id_cash ,
				 gl_number_id_gross_set,
				 gl_number_id_item_st_asset, 
		         gl_number_id_item_st_liab,
		         gl_number_id_item_lt_asset,
		         gl_number_id_item_lt_liab,
		         gl_number_unhedged_der_st_asset,
		         gl_number_unhedged_der_lt_asset,
		         gl_number_unhedged_der_st_liab,
		         gl_number_unhedged_der_lt_liab,
		         gl_id_amortization,
		         gl_id_interest,
		         gl_number_id_expense,
				 primary_counterparty_id, 
				 accounting_code
			FROM #ztbl_xmlvalue) zxv ON fs.fas_book_id = zxv.fas_book_id
			
			WHEN NOT MATCHED BY TARGET THEN
				INSERT (
					fas_book_id,
				 fun_cur_value_id ,
				 accounting_type,
				 no_links_fas_eff_test_profile_id,
				 cost_approach_id ,
				 legal_entity ,
				 convert_uom_id ,
				 tax_perc ,
				 no_link ,
				 hedge_item_same_sign ,
				 gl_number_id_st_asset ,
				 gl_number_id_lt_asset ,
				 gl_number_id_st_liab ,
				 gl_number_id_lt_liab ,
				 gl_id_st_tax_asset ,
				 gl_id_lt_tax_asset ,
				 gl_id_st_tax_liab ,
				 gl_id_lt_tax_liab ,
				 gl_id_tax_reserve ,
				 gl_number_id_aoci ,
				 gl_number_id_inventory ,
				 gl_number_id_pnl,
				 gl_number_id_set ,
				 gl_number_id_cash ,
				 gl_number_id_gross_set,
				 gl_number_id_item_st_asset, 
		         gl_number_id_item_st_liab,
		         gl_number_id_item_lt_asset,
		         gl_number_id_item_lt_liab,
		         gl_number_unhedged_der_st_asset,
		         gl_number_unhedged_der_lt_asset,
		         gl_number_unhedged_der_st_liab,
		         gl_number_unhedged_der_lt_liab,
		         gl_id_amortization,
		         gl_id_interest,
		         gl_number_id_expense,
				 primary_counterparty_id,
				 accounting_code,
				 hedge_type_value_id
				)
				VALUES (
				@id,
				 zxv.fun_cur_value_id,
				 zxv.accounting_type,
				 zxv.no_links_fas_eff_test_profile_id,
				 zxv.cost_approach_id ,
				 zxv.legal_entity ,
				 zxv.convert_uom_id ,
				 zxv.tax_perc ,
				 zxv.no_link ,
				 zxv.hedge_item_same_sign ,
				 zxv.gl_number_id_st_asset ,
				 zxv.gl_number_id_lt_asset ,
				 zxv.gl_number_id_st_liab ,
				 zxv.gl_number_id_lt_liab ,
				 zxv.gl_id_st_tax_asset ,
				 zxv.gl_id_lt_tax_asset ,
				 zxv.gl_id_st_tax_liab ,
				 zxv.gl_id_lt_tax_liab ,
				 zxv.gl_id_tax_reserve ,
				 zxv.gl_number_id_aoci ,
				 zxv.gl_number_id_inventory ,
				 zxv.gl_number_id_pnl,
				 zxv.gl_number_id_set ,
				 zxv.gl_number_id_cash ,
				 zxv.gl_number_id_gross_set,
				 zxv.gl_number_id_item_st_asset, 
		         zxv.gl_number_id_item_st_liab,
		         zxv.gl_number_id_item_lt_asset,
		         zxv.gl_number_id_item_lt_liab,
		         zxv.gl_number_unhedged_der_st_asset,
		         zxv.gl_number_unhedged_der_lt_asset,
		         zxv.gl_number_unhedged_der_st_liab,
		         zxv.gl_number_unhedged_der_lt_liab,
		         zxv.gl_id_amortization,
		         zxv.gl_id_interest,
		         zxv.gl_number_id_expense,
				 zxv.primary_counterparty_id,
				 zxv.accounting_code,
				 zxv.accounting_type
				)
			WHEN MATCHED THEN
				UPDATE SET
				 fun_cur_value_id = zxv.fun_cur_value_id ,
				 accounting_type = zxv.accounting_type,
				 no_links_fas_eff_test_profile_id = zxv.no_links_fas_eff_test_profile_id,
				 cost_approach_id = zxv.cost_approach_id,
				 legal_entity = zxv.legal_entity ,
				 convert_uom_id = zxv.convert_uom_id,
				 tax_perc = zxv.tax_perc,
				 no_link = zxv.no_link ,
				 hedge_item_same_sign = zxv.hedge_item_same_sign,
				 gl_number_id_st_asset = zxv.gl_number_id_st_asset,
				 gl_number_id_lt_asset = zxv.gl_number_id_lt_asset,
				 gl_number_id_st_liab = zxv.gl_number_id_st_liab,
				 gl_number_id_lt_liab = zxv.gl_number_id_lt_liab,
				 gl_id_st_tax_asset = zxv.gl_id_st_tax_asset,
				 gl_id_lt_tax_asset = zxv.gl_id_lt_tax_asset,
				 gl_id_st_tax_liab = zxv.gl_id_st_tax_liab,
				 gl_id_lt_tax_liab = zxv.gl_id_lt_tax_liab,
				 gl_id_tax_reserve = zxv.gl_id_tax_reserve,
				 gl_number_id_aoci = zxv.gl_number_id_aoci,
				 gl_number_id_inventory = zxv.gl_number_id_inventory,
				 gl_number_id_pnl = zxv.gl_number_id_pnl,
				 gl_number_id_set = zxv.gl_number_id_set,
				 gl_number_id_cash = zxv.gl_number_id_cash,
				 gl_number_id_gross_set = zxv.gl_number_id_gross_set,
				 gl_number_id_item_st_asset = zxv.gl_number_id_item_st_asset, 
		         gl_number_id_item_st_liab = zxv.gl_number_id_item_st_liab,
		         gl_number_id_item_lt_asset = zxv.gl_number_id_item_lt_asset,
		         gl_number_id_item_lt_liab = zxv.gl_number_id_item_lt_liab,
		         gl_number_unhedged_der_st_asset = zxv.gl_number_unhedged_der_st_asset,
		         gl_number_unhedged_der_lt_asset = zxv.gl_number_unhedged_der_lt_asset,
		         gl_number_unhedged_der_st_liab = zxv.gl_number_unhedged_der_st_liab,
		         gl_number_unhedged_der_lt_liab = zxv.gl_number_unhedged_der_lt_liab,
		         gl_id_amortization = zxv.gl_id_amortization,
		         gl_id_interest = zxv.gl_id_interest,
		         gl_number_id_expense = zxv.gl_number_id_expense,
				 primary_counterparty_id = zxv.primary_counterparty_id,
				 accounting_code = zxv.accounting_code,
				 hedge_type_value_id = zxv.accounting_type
				 ;				
		
		--Release Bookstructure cache key.
		IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
		BEGIN
			EXEC [spa_manage_memcache] @flag = 'd', @other_key_source='BookStructure', @source_object = 'spa_UpdateBookOption @flag=iu'
		END

		IF @id IS NULL
			SELECT @id = fas_book_id FROM #ztbl_xmlvalue
		
		EXEC spa_ErrorHandler 0
			, 'Source Deal Detail'
			, 'spa_getXml'
			, 'Success'
			, 'Changes have been saved successfully.'
			, @id				

		COMMIT
	END
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK
		
	DECLARE @msg VARCHAR(5000)
	--SELECT @msg = 'Failed Inserting record (' + ERROR_MESSAGE() + ').'
	SELECT @msg = 'Duplicate value in (<b>Book</b>).'
	
	EXEC spa_ErrorHandler -1
		, 'Source Deal Detail'
		, 'spa_UpdateBookStrategyXml'
		, 'DB Error'
		, @msg
		, 'Failed Inserting Record'
END CATCH
