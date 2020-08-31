IF OBJECT_ID(N'[dbo].[spa_counterparty_credit_enhancements]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_counterparty_credit_enhancements]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
/**
	Counterparty credit enhancements related operations
	Parameters
	@flag : Opertion Flag
	@counterparty_credit_enhancement_id : 
	@counterparty_credit_info_id : 
	@enhance_type : 
	@guarantee_type : 
	@amount : 
	@currency_code : 
	@eff_date :
	@margin :
	@rely_self :
	@margin :
	@rely_self :
	@approved_by :
	@expiration_date :
	@exclude_collateral :
	@Counterparty_id :
	@deal_id :
	@xml :
	@filter_xml :
	@auto_renewal :
	@transferred :
	@collateral :

*/

CREATE PROCEDURE [dbo].[spa_counterparty_credit_enhancements]
	@flag CHAR(1),
	@counterparty_credit_enhancement_id VARCHAR(50) = NULL,
	@counterparty_credit_info_id INT = NULL,
	@enhance_type INT = NULL,
	@guarantee_type INT = NULL,
	@comment VARCHAR(100) = NULL,
	@amount FLOAT = NULL,
	@currency_code INT = NULL,
	@eff_date DATETIME = NULL,
	@margin CHAR(1) = NULL,
	@rely_self CHAR(1) = NULL,
	@approved_by VARCHAR(50) = NULL,
	@expiration_date DATETIME = NULL,
	@exclude_collateral CHAR(1) = NULL,
	@Counterparty_id INT = NULL,
	@deal_id VARCHAR(10) = NULL,
	@xml VARCHAR(MAX) = NULL,
	@filter_xml XML = NULL,
	@auto_renewal CHAR(1) = NULL,
	@transferred CHAR(1) = NULL,
	@collateral INT = NULL
AS 

SET NOCOUNT ON

DECLARE @sql VARCHAR(5000)
DECLARE @sql_del VARCHAR(5000)

DECLARE @xml_f VARCHAR(MAX) = NULL
	,@xml_table_name VARCHAR(100) = NULL

SELECT @xml_f = '<Root>'+CAST(col.query('.') AS VARCHAR(MAX))+'</Root>'
	FROM @filter_xml.nodes('/Root/FilterXML') AS xmlData(col)

IF OBJECT_ID('tempdb..#xml_process_table_name') IS NOT NULL
	DROP TABLE #xml_process_table_name

IF OBJECT_ID('tempdb..#filter_table') IS NOT NULL
	DROP TABLE #filter_table

CREATE TABLE #filter_table (
	contract_id VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
	effective_date_from DATETIME,
	effective_date_to DATETIME, 
	enhance_type VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
	guarantee_counterparty VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
	internal_counterparty VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
	margin CHAR(1) COLLATE DATABASE_DEFAULT
)

IF @xml_f IS NOT NULL
BEGIN
	CREATE TABLE #xml_process_table_name (
		table_name VARCHAR(200) COLLATE DATABASE_DEFAULT
	)

	INSERT INTO #xml_process_table_name
	EXEC spa_parse_xml_file 'b', NULL, @xml_f
	
	SELECT @xml_table_name = table_name
	FROM #xml_process_table_name

	EXEC(
		'INSERT INTO #filter_table(
			internal_counterparty, 
			contract_id, 
			effective_date_from, 
			effective_date_to, 
			enhance_type, 
			guarantee_counterparty, 
			margin) 
		SELECT internal_counterparty, 
			contract_id, 
			effective_date_from, 
			effective_date_to, 
			enhance_type, 
			guarantee_counterparty, 
			margin 
		FROM ' + @xml_table_name
	)
END

IF @flag = 's'
BEGIN
	SET @sql = '
				SELECT 
					cce.counterparty_credit_enhancement_id [Credit Enhancement ID],
					counterparty_credit_info_id [Credit Info ID],
					sdv.code [Enhance Type],
					cce.enhance_type [Enhance Type],
					scn.counterparty_name [Guarantee Counterparty],
					cce.guarantee_counterparty [Guarantee Counterparty ID],
					cce.comment [Comment],
					cce.amount [Amount],
					sc.currency_name [Currency],
					cce.currency_code [Currency Code],
					dbo.fnadateformat(eff_date) [Effective Date],
					dbo.fnadateformat(cce.expiration_date) [Expiration Date],
					cce.margin [Receive]
				FROM counterparty_credit_enhancements cce
				LEFT JOIN static_data_value sdv 
					ON cce.enhance_type = sdv.value_id
				LEFT JOIN source_counterparty scn on scn.source_counterparty_id = cce.guarantee_counterparty
				LEFT JOIN source_currency sc 
					ON sc.source_currency_id = cce.currency_code
				WHERE 1 = 1'
	IF @counterparty_credit_enhancement_id IS NOT NULL
	BEGIN
		SET @sql = @sql + ' AND counterparty_credit_enhancement_id = ' + CAST(@counterparty_credit_enhancement_id AS VARCHAR)
	END

	IF @counterparty_credit_info_id IS NOT NULL
	BEGIN
		SET @sql = @sql + ' AND counterparty_credit_info_id = ' + CAST(@counterparty_credit_info_id AS VARCHAR)
	END
	ELSE 
	BEGIN
		SET @sql = @sql + ' AND counterparty_credit_info_id = NULL'
	END

	IF @margin IS NOT NULL
	BEGIN
		SET @sql = @sql + ' AND margin = ''' + CAST(@margin AS VARCHAR) + ''''
	END

	IF @rely_self IS NOT NULL
	BEGIN
		SET @sql = @sql + ' and rely_self = ''' + CAST(@rely_self AS VARCHAR) + ''''
	END

	EXEC spa_print @sql
	EXEC (@sql)
END

ELSE IF @flag = 'a'
BEGIN
	SET @sql='
				select 
				counterparty_credit_enhancement_id,
				counterparty_credit_info_id,
				enhance_type,
				guarantee_counterparty,
				comment,
				amount,
				currency_code,
				dbo.fnadateformat(eff_date),
				margin,
				rely_self,approved_by,dbo.fnadateformat(expiration_date),exclude_collateral from counterparty_credit_enhancements where 1=1'
	
	IF @counterparty_credit_enhancement_id IS NOT NULL
	BEGIN
		SET @sql = @sql + ' AND counterparty_credit_enhancement_id = ' + CAST(@counterparty_credit_enhancement_id AS VARCHAR)
	END

	EXEC (@sql)
END

ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
	BEGIN TRAN
	DECLARE @raise_error INT = 0
	DECLARE @msg_error VARCHAR(1000)

	IF EXISTS(
	SELECT  stpre.source_deal_header_id  FROM source_deal_prepay sdp
		    INNER JOIN counterparty_credit_enhancements cce on cce.source_deal_prepay_id = sdp.source_deal_prepay_id
	    	INNER JOIN source_deal_header sdh on sdh.source_deal_header_id = sdp.source_deal_header_id
			INNER JOIN source_deal_detail sdd on sdd.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN stmt_prepay stpre on stpre.source_deal_header_id = sdh.source_deal_header_id  AND stpre.settlement_date = sdp.settlement_date
			INNER JOIN dbo.SplitCommaSeperatedValues(@counterparty_credit_enhancement_id) a ON cce.counterparty_credit_enhancement_id = a.item
			)
	BEGIN
		SET @raise_error = 1
		SET @msg_error = 'Failed to delete Counterparty Credit Enhancements. Invoice(s) is mapped to this Prepay/Credit Enhancements'
		RAISERROR (@msg_error, 16, 1)
	END
			
	IF (@raise_error = 0)
	BEGIN
		set @msg_error = 'Delete  failed.'

		DELETE sdp FROM source_deal_prepay sdp
		INNER JOIN counterparty_credit_enhancements cce on cce.source_deal_prepay_id = sdp.source_deal_prepay_id
		INNER JOIN dbo.SplitCommaSeperatedValues(@counterparty_credit_enhancement_id) a ON cce.counterparty_credit_enhancement_id = a.item
				
		DELETE wcs FROM master_view_counterparty_credit_enhancements wcs
		INNER JOIN dbo.SplitCommaSeperatedValues(@counterparty_credit_enhancement_id) a ON wcs.counterparty_credit_enhancement_id = a.item
		
		DELETE wcs FROM counterparty_credit_enhancements wcs
		INNER JOIN dbo.SplitCommaSeperatedValues(@counterparty_credit_enhancement_id) a ON wcs.counterparty_credit_enhancement_id = a.item
		
	EXEC spa_ErrorHandler 0, 
						'Counterparty Credit Enhancements', 
						'spa_counterparty_credit_enhancements', 
						'Success', 							
						'Changes have been saved successfully.',''
	END
	COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
 			ROLLBACK
		DECLARE @err_msg_d VARCHAR(100);
	SET @err_msg_d = (SELECT error_message());
	EXEC spa_ErrorHandler -1,
					'Counterparty Credit Enhancements',
					'spa_counterparty_credit_enhancements',
					'Error'
					,@err_msg_d
					,''
	END CATCH
	
END

IF @flag = 'r'
BEGIN
	SET @sql='
				select 
				cce.counterparty_credit_enhancement_id,
				counterparty_credit_info_id [Credit INFO id],
				sdv.code [Enhance Type],
				cce.enhance_type [Enhance Type],
				scn.counterparty_name [Guarantee Counterparty],
				cce.guarantee_counterparty,
				cce.comment [Comment],
				cce.amount [Amount],
				sc.currency_name [Currency],
				cce.currency_code,
				dbo.fnadateformat(eff_date) [Effective Date],
				dbo.fnadateformat(cce.expiration_date) [Expiration Date],
				cce.margin [Receive]
	
				from counterparty_credit_enhancements cce
				left join static_data_value sdv on cce.enhance_type=sdv.value_id
				left join source_counterparty scn on scn.source_counterparty_id = cce.guarantee_counterparty
				left join source_currency sc on sc.source_currency_id=cce.currency_code
				where 1=1'
	
	IF @margin IS NOT NULL
	BEGIN
		SET @sql = @sql + ' AND margin = ''' + CAST(@margin AS VARCHAR) + ''''
	END
	EXEC spa_print @sql
	EXEC (@sql)
End

IF @flag = 'g' --Counterparty Credit Info Enhancement DHTMLX Grid
BEGIN
	DECLARE @filter_contract_id				VARCHAR(250)
	DECLARE @filter_effective_date_from		DATETIME
	DECLARE @filter_effective_date_to		DATETIME
	DECLARE @filter_enhance_type			VARCHAR(250)
	DECLARE @filter_guarantee_counterparty	VARCHAR(250)
	DECLARE @filter_internal_counterparty	VARCHAR(250)
	DECLARE @filter_margin					CHAR(1)

	SELECT @filter_contract_id				= NULLIF(ft.contract_id,''),	
		   @filter_effective_date_from		= NULLIF(ft.effective_date_from,''),
		   @filter_effective_date_to		= NULLIF(ft.effective_date_to,''),
		   @filter_enhance_type				= NULLIF(ft.enhance_type,''),
		   @filter_guarantee_counterparty	= NULLIF(ft.guarantee_counterparty,''),
		   @filter_internal_counterparty	= NULLIF(ft.internal_counterparty,''),
		   @filter_margin					= NULLIF(ft.margin,'')
	FROM #filter_table ft	

	SET @sql = 'SELECT 
		ISNULL(scn3.counterparty_name, '' '') [internal_counterparty],
		ISNULL(cce.counterparty_credit_enhancement_id, '' '') [enhancement_id],
		ISNULL(cce.counterparty_credit_enhancement_id, '' '') [system_id],
		cg.contract_name [contract],
		dbo.FNATRMWinHyperlink(''a'', 10131010, cce.deal_id, cce.deal_id, NULL,null,null,null,null,null,null,null,null,null,null,0) [deal_id],
		sdv.code [enhance_type],
		scn2.counterparty_name [guarantee_counterparty],
		dbo.fnadateformat(eff_date) [effective_date],
		dbo.fnadateformat(cce.expiration_date) [expiration_date],
		cce.amount [amount],
		sc.currency_name [currency],
		cce.approved_by [approved_by],
		sdv2.code [Collateral Status],
		cce.comment [comment],
		CASE
			WHEN cce.margin = ''y'' THEN ''Yes''
			ELSE ''No''
		END AS [receive],
		dbo.FNATRMWinHyperlink(''a'', 10131010, cce.deal_id, cce.deal_id, NULL,null,null,null,null,null,null,null,null,null,null,0) [deal_id],
		CASE 
			WHEN cce.auto_renewal = ''y'' THEN ''Yes''
			ELSE ''No''
			END AS [Auto Renewal],
		CASE
			WHEN cce.exclude_collateral = ''y'' THEN ''Yes''
			ELSE ''No''
			END AS [Do Not Use Credit Collateral],
		CASE
			WHEN cce.blocked = ''y'' THEN ''Yes''
			ELSE ''No''
			END AS [Blocked],
		CASE
			WHEN cce.transferred = ''y'' THEN ''Yes''
			ELSE ''No''
			END AS [Transfer],
		CASE
			WHEN cce.is_primary = ''1'' THEN ''Yes''
			ELSE ''No''
			END AS[Primary]
	FROM counterparty_credit_enhancements cce
	INNER JOIN counterparty_credit_info cci ON cci.counterparty_credit_info_id = cce.counterparty_credit_info_id
	LEFT JOIN source_counterparty scn ON scn.source_counterparty_id = cci.Counterparty_id
	LEFT JOIN source_counterparty scn2 ON scn2.source_counterparty_id = cce.guarantee_counterparty
	LEFT JOIN source_counterparty scn3 ON scn3.source_counterparty_id = cce.internal_counterparty
	LEFT JOIN static_data_value sdv ON cce.enhance_type=sdv.value_id
	LEFT JOIN static_data_value sdv2 ON cce.collateral_status=sdv2.value_id
	LEFT JOIN source_currency sc ON sc.source_currency_id=cce.currency_code
	LEFT JOIN contract_group AS cg ON cg.contract_id = cce.contract_id
	WHERE 1=1 and scn.source_counterparty_id=''' + cast(@Counterparty_id as varchar) + ''''

	IF @filter_contract_id IS NOT NULL
		SET @sql += ' AND cce.contract_id IN (SELECT item FROM dbo.SplitCommaSeperatedValues(''' + @filter_contract_id + '''))'
	IF @filter_effective_date_from IS NOT NULL
		SET @sql += ' AND dbo.fnadateformat(eff_date) >= '''+ cast(dbo.fnadateformat(@filter_effective_date_from) AS VARCHAR) + ''''
	IF @filter_effective_date_to IS NOT NULL
		SET @sql += ' AND dbo.fnadateformat(eff_date) <= '''+ cast(dbo.fnadateformat(@filter_effective_date_to) AS VARCHAR) + ''''
	IF @filter_enhance_type IS NOT NULL
		SET @sql += ' AND cce.enhance_type IN (SELECT item FROM dbo.SplitCommaSeperatedValues(''' + @filter_enhance_type + '''))'
	IF @filter_guarantee_counterparty IS NOT NULL
		SET @sql += ' AND cce.guarantee_counterparty IN (SELECT item FROM dbo.SplitCommaSeperatedValues(''' + @filter_guarantee_counterparty + '''))'
	IF @filter_internal_counterparty IS NOT NULL
		SET @sql += ' AND cce.internal_counterparty IN (SELECT item FROM dbo.SplitCommaSeperatedValues(''' + @filter_internal_counterparty + '''))'
	IF @filter_margin IS NOT NULL
		SET @sql += ' AND cce.margin=''' + @filter_margin + ''''
	IF @Counterparty_id IS NOT NULL
	BEGIN
		SET @sql = @sql + ' AND scn.source_counterparty_id =''' + CAST(@Counterparty_id AS VARCHAR) + ''''
	END
	
	IF @deal_id IS NOT NULL AND @deal_id <> ''
	BEGIN
		SET @sql = @sql + ' AND cce.deal_id =''' + CAST(@deal_id AS VARCHAR) + ''''
	END
	SET @sql = @sql + 'ORDER BY scn3.counterparty_name'

	EXEC (@sql)

END

ELSE IF @flag = 't'
BEGIN
	DECLARE @internal_counterparty INT,
			@contract_id INT,
			@guarantee_counterparty INT,
			@idoc INT,
            @is_primary CHAR(1) = 'n',
			@cce_identity INT = NULL,
			@collateral_status INT = NULL,
			@blocked CHAR(1) = 'n'
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
	SELECT @counterparty_credit_enhancement_id	= counterparty_credit_enhancement_id
		, @counterparty_credit_info_id			= counterparty_credit_info_id  
		, @internal_counterparty  				= internal_counterparty
		, @contract_id							= contract_id
		, @deal_id								= deal_id
		, @enhance_type							= enhance_type
		, @guarantee_counterparty				= guarantee_counterparty
		, @eff_date								= eff_date
		, @expiration_date						= expiration_date
		, @amount								= amount
		, @currency_code						= currency_code
		, @approved_by  						= approved_by
		, @comment   							= comment 
		, @margin 								= margin 
		, @exclude_collateral					= exclude_collateral	
		, @auto_renewal 						= auto_renewal
		, @transferred							= transferred	
        , @is_primary							= is_primary		
        , @collateral_status					= collateral_status
		, @blocked								= blocked
	FROM  OPENXML (@idoc, '/Root/FormXML', 1)
    WITH (
		counterparty_credit_enhancement_id  VARCHAR(10)		'@counterparty_credit_enhancement_id'
		, counterparty_credit_info_id		VARCHAR(10) 	'@counterparty_credit_info_id'     
		, internal_counterparty				VARCHAR(10) 	'@internal_counterparty'			
		, contract_id						VARCHAR(10) 	'@contract_id'												
		, deal_id							VARCHAR(50)	    '@deal_id'							
		, enhance_type						VARCHAR(10) 	'@enhance_type'						
		, guarantee_counterparty			VARCHAR(10) 	'@guarantee_counterparty'			
		, eff_date							DATETIME	    '@eff_date'							
		, expiration_date					DATETIME	    '@expiration_date'					
		, amount							FLOAT		    '@amount'											
		, currency_code						VARCHAR(10) 	'@currency_code'						
		, approved_by						VARCHAR(50)	    '@approved_by'  						
		, comment							VARCHAR(100)	'@comment'   						
		, margin							CHAR		    '@margin' 							
		, exclude_collateral				CHAR		    '@exclude_collateral'
		, auto_renewal						CHAR			'@auto_renewal'						
		, transferred						CHAR			'@transferred'	
        , is_primary						CHAR(1)			'@is_primary'		
        , collateral_status					INT				'@collateral_status'					
		, blocked							CHAR			'@blocked'
		)
BEGIN TRY
BEGIN TRAN
IF EXISTS (SELECT 1 FROM counterparty_credit_enhancements 
		  WHERE enhance_type = @enhance_type 
		  AND CAST(eff_date AS DATE) = @eff_date
		  AND amount = @amount
		  AND currency_code = @currency_code
		  AND counterparty_credit_info_id = @counterparty_credit_info_id
		  AND IIF(deal_id IS NULL OR deal_id = '','',deal_id) = @deal_id
		  AND IIF(contract_id IS NULL OR contract_id = '','',contract_id) = @contract_id
		  AND margin = @margin
		  AND IIF(expiration_date IS NULL OR expiration_date = '','',CAST(expiration_date AS DATE)) = @expiration_date
		  AND counterparty_credit_enhancement_id <> @counterparty_credit_enhancement_id
		  )
BEGIN
	DELETE FROM counterparty_credit_enhancements
	 WHERE enhance_type = @enhance_type 
		  AND CAST(eff_date AS DATE) = @eff_date
		  AND amount = @amount
		  AND currency_code = @currency_code
		  AND counterparty_credit_info_id = @counterparty_credit_info_id
		  AND IIF(deal_id IS NULL OR deal_id = '','',deal_id) = @deal_id
		  AND IIF(contract_id IS NULL OR contract_id = '','',contract_id) = @contract_id
		  AND margin = @margin
		  AND IIF(expiration_date IS NULL OR expiration_date = '','',CAST(expiration_date AS DATE)) = @expiration_date
		  AND counterparty_credit_enhancement_id <> @counterparty_credit_enhancement_id
END
IF @counterparty_credit_enhancement_id IS NULL OR @counterparty_credit_enhancement_id = ''
BEGIN
	INSERT INTO counterparty_credit_enhancements (
		counterparty_credit_info_id  
		, internal_counterparty
		, contract_id
		, deal_id
		, enhance_type
		, guarantee_counterparty
		, eff_date
		, expiration_date
		, amount
		, currency_code
		, approved_by
		, comment 
		, margin 
		, exclude_collateral	
		, auto_renewal
		, transferred
		, is_primary
		, collateral_status
		, blocked
	)
	VALUES (
		@counterparty_credit_info_id  
		, IIF(@internal_counterparty IS NULL OR @internal_counterparty = '',NULL,@internal_counterparty)
		, IIF(@contract_id IS NULL OR @contract_id = '',NULL,@contract_id)
		, IIF(@deal_id IS NULL OR @deal_id = '',NULL,@deal_id)
		, @enhance_type
		, IIF(@guarantee_counterparty IS NULL OR @guarantee_counterparty = '',NULL,@guarantee_counterparty)
		, @eff_date
		, IIF(@expiration_date IS NULL OR @expiration_date = '',NULL,@expiration_date)
		, @amount
		, @currency_code
		, IIF(@approved_by IS NULL OR @approved_by = '',NULL,@approved_by)
		, IIF(@comment IS NULL OR @comment = '',NULL,@comment)
		, @margin
		, @exclude_collateral
		, @auto_renewal
		, @transferred
		, CASE WHEN @is_primary = 'y' THEN 1
			ELSE 0
		END
		, @collateral_status
		, @blocked
	)
	
	SET @cce_identity = (SELECT SCOPE_IDENTITY());
END
ELSE
BEGIN
	UPDATE counterparty_credit_enhancements
	SET internal_counterparty       = IIF(@internal_counterparty IS NULL OR @internal_counterparty = '',NULL,@internal_counterparty)
		, contract_id				= IIF(@contract_id IS NULL OR @contract_id = '',NULL,@contract_id)
		, deal_id					= IIF(@deal_id IS NULL OR @deal_id = '',NULL,@deal_id)
		, enhance_type			    = @enhance_type
		, guarantee_counterparty	= IIF(@guarantee_counterparty IS NULL OR @guarantee_counterparty = '',NULL,@guarantee_counterparty)
		, eff_date				    = @eff_date
		, expiration_date		    = IIF(@expiration_date IS NULL OR @expiration_date = '',NULL,@expiration_date)
		, amount					= @amount
		, currency_code			    = @currency_code
		, approved_by			    = IIF(@approved_by IS NULL OR @approved_by = '',NULL,@approved_by)
		, comment 				    = IIF(@comment IS NULL OR @comment = '',NULL,@comment)
		, margin 				    = @margin
		, exclude_collateral		= @exclude_collateral
		, auto_renewal				= @auto_renewal
		, transferred				= @transferred
        , is_primary				= CASE 
										WHEN @is_primary = 'y' THEN 1
										ELSE 0
									END
		, collateral_status			= @collateral_status
		, blocked					= @blocked
	WHERE counterparty_credit_enhancement_id = @counterparty_credit_enhancement_id
	SET @cce_identity = @counterparty_credit_enhancement_id

	IF EXISTS (select 1 from counterparty_credit_enhancements where counterparty_credit_enhancement_id = @counterparty_credit_enhancement_id and source_deal_prepay_id is not null)
		BEGIN	
			UPDATE
			spp
			SET spp.VALUE = cce.amount
			FROM source_deal_prepay spp
			INNER JOIN  counterparty_credit_enhancements cce ON cce.counterparty_credit_enhancement_id = @counterparty_credit_enhancement_id 
			WHERE 
			cce.source_deal_prepay_id = spp.source_deal_prepay_id
		END
	END

		IF EXISTS(SELECT  stpre.source_deal_header_id  FROM source_deal_prepay sdp
		        INNER JOIN counterparty_credit_enhancements cce on cce.source_deal_prepay_id = sdp.source_deal_prepay_id
	    		INNER JOIN source_deal_header sdh on sdh.source_deal_header_id = sdp.source_deal_header_id
				INNER JOIN source_deal_detail sdd on sdd.source_deal_header_id = sdh.source_deal_header_id
				INNER JOIN stmt_prepay stpre on stpre.source_deal_header_id = sdh.source_deal_header_id  AND stpre.settlement_date = sdp.settlement_date
				INNER JOIN dbo.SplitCommaSeperatedValues(@counterparty_credit_enhancement_id) a ON cce.counterparty_credit_enhancement_id = a.item
				)
		BEGIN
			RAISERROR ('Failed to Update Counterparty Credit Enhancements. Invoice(s) is mapped to this Prepay/Credit Enhancements', 16, 1)
		END
		
		EXEC spa_ErrorHandler 0,
					'Counterparty Credit Enhancements',
					'spa_counterparty_credit_enhancements',
					'Success',
					'Changes have been saved successfully.',
					@cce_identity
COMMIT
END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
 			ROLLBACK
		DECLARE @err_msg VARCHAR(100);
	SET @err_msg = (SELECT error_message());
	EXEC spa_ErrorHandler -1,
					'Counterparty Credit Enhancements',
					'spa_counterparty_credit_enhancements',
					'Error'
					,@err_msg
					,@cce_identity
	END CATCH
	
END

ELSE IF @flag = 'u'
BEGIN
	BEGIN TRY
	BEGIN TRAN

	UPDATE counterparty_credit_enhancements
	SET collateral_status = @collateral 
	WHERE counterparty_credit_enhancement_id = @counterparty_credit_enhancement_id

	EXEC spa_ErrorHandler 0,
					'Counterparty Credit Enhancements',
					'spa_counterparty_credit_enhancements',
					'Success',
					'Changes have been saved successfully.',
					''
	COMMIT

	END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
 				ROLLBACK
			DECLARE @err_msg_update VARCHAR(100);
		SET @err_msg_update = (SELECT error_message());
		EXEC spa_ErrorHandler -1,
						'Counterparty Credit Enhancements',
						'spa_counterparty_credit_enhancements',
						'Error'
						,@err_msg_update
						,''
		END CATCH
END
