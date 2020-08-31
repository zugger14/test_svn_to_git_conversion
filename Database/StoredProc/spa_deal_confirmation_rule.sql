IF OBJECT_ID('[dbo].[spa_deal_confirmation_rule]','p') IS NOT NULL 
	DROP PROCEDURE [dbo].[spa_deal_confirmation_rule]
GO

CREATE PROCEDURE [dbo].[spa_deal_confirmation_rule]
	@flag CHAR(1),
	@rule_id VARCHAR(5000) = NULL, 
	@counterparty_id INT = NULL,
	@buy_sell_flag CHAR(1) = NULL,
	@commodity_id INT = NULL,
	@contract_id INT = NULL,
	@deal_type_id INT = NULL,
	@confirm_template_id INT = NULL,
	@revision_confirm_template_id INT = NULL,
	@source_deal_header_id int = null,
	@deal_template_id INT = NULL,
	@xml_value VARCHAR(MAX) = NULL
AS

/* ----------- DEBUG --------------------
--EXEC spa_deal_confirmation_rule @flag = 'a', @rule_id = <ID>
DECLARE @flag CHAR(1),
	@rule_id VARCHAR(5000) = NULL, 
	@counterparty_id INT = NULL,
	@buy_sell_flag CHAR(1) = NULL,
	@commodity_id INT = NULL,
	@contract_id INT = NULL,
	@deal_type_id INT = NULL,
	@confirm_template_id INT = NULL,
	@revision_confirm_template_id INT = NULL,
	@source_deal_header_id int = null,
	@deal_template_id INT = NULL,
	@xml_value VARCHAR(MAX) = NULL

--*/

SET NOCOUNT ON
DECLARE @sql_stmt VARCHAR(8000)

IF @flag = 's'
BEGIN
	--SELECT @sql_stmt = '
	--SELECT  REPLACE(sdv.code, ''&'', ''and'') entity_type,rule_id as [rule_id]
	--	, scp.counterparty_name AS [counterparty_id],

	--	CASE WHEN buy_sell_flag = ''b'' THEN ''Buy'' WHEN buy_sell_flag = ''s'' THEN ''Sell'' ELSE ''Both'' END AS [buy_sell_flag],  
	--	sc.commodity_name AS [commodity_id], 
	--	cg.contract_name AS [contract_id],
	--	sdt.source_deal_type_name AS [deal_type_id], 
	--	sdht.template_name AS [deal_template_id],
	--	drt.template_name AS [confirm_template_id], 
	--	drt1.template_name AS [revision_confirm_template_id]
	--FROM deal_confirmation_rule dcr
	--	LEFT JOIN source_counterparty scp 
	--		ON dcr.counterparty_id = scp.source_counterparty_id 
	--	LEFT JOIN source_deal_type sdt 
	--		ON sdt.source_deal_type_id = dcr.deal_type_id
	--	LEFT JOIN source_commodity sc 
	--		ON sc.source_commodity_id = dcr.commodity_id
	--	LEFT JOIN contract_group cg 
	--		ON cg.contract_id = dcr.contract_id
	--	LEFT JOIN deal_report_template drt 
	--		ON dcr.confirm_template_id = drt.template_id
	--	LEFT JOIN deal_report_template drt1 
	--		ON dcr.revision_confirm_template_id = drt1.template_id
	--	LEFT JOIN source_deal_header_template sdht 
	--		ON sdht.template_id = dcr.deal_template_id
	--	LEFT JOIN static_data_value sdv on sdv.value_id = scp.type_of_entity
	--'
	----WHERE 1=1 '
	--IF @counterparty_id IS NOT NULL 
	--SET @sql_stmt = @sql_stmt +  ' WHERE dcr.counterparty_id=' + CONVERT(VARCHAR(20), @counterparty_id) + ''
	--SET @sql_stmt = @sql_stmt +  ' ORDER BY sdv.code, scp.counterparty_name, rule_id '
	--EXEC(@sql_stmt)

	IF OBJECT_ID('tempdb..#counterparty_list') IS NOT NULL 
	DROP TABLE #counterparty_list

	SELECT REPLACE(sdv.code, '&', 'And') entity_type,
		counterparty_id,
		source_counterparty_id,
		counterparty_name,
		sdv.code,
		ROW_NUMBER() OVER(ORDER BY sdv.code ASC) AS [Row]
	INTO #counterparty_list
	FROM source_counterparty sc
	LEFT JOIN static_data_value sdv on sdv.value_id = sc.type_of_entity 
	WHERE is_active = 'y'  AND counterparty_id NOT LIKE '%--%'
	ORDER BY counterparty_id,sdv.code

	INSERT INTO #counterparty_list(entity_type,counterparty_id,source_counterparty_id,counterparty_name,Row)
	SELECT 'All', 'All', 0, 'All', 0
	
	SELECT * FROM #counterparty_list ORDER BY [Row]
END

IF @flag = 'i'
BEGIN
	IF NOT EXISTS(
		SELECT 1
		FROM deal_confirmation_rule
		WHERE ISNULL(buy_sell_flag, 'a') = ISNULL(@buy_sell_flag, 'a')
			AND	ISNULL(commodity_id, -1) = ISNULL(@commodity_id, -1)
			AND ISNULL(contract_id, -1) = ISNULL(@contract_id, -1)
			AND ISNULL(deal_type_id, -1) = ISNULL(@deal_type_id, -1) 
			AND counterparty_id = @counterparty_id
	)
	BEGIN
		INSERT INTO deal_confirmation_rule(
			counterparty_id,
			buy_sell_flag,
			commodity_id,
			contract_id,
			deal_type_id,
			confirm_template_id,
			revision_confirm_template_id,
			deal_template_id
		)
		VALUES(	
			@counterparty_id,
			CASE WHEN @buy_sell_flag='a' THEN NULL
				ELSE @buy_sell_flag
			END,
			@commodity_id,
			@contract_id,
			@deal_type_id,
			@confirm_template_id,
			@revision_confirm_template_id,
			@deal_template_id
		)
	END
	ELSE
	BEGIN
		EXEC spa_ErrorHandler -1,
			'This confirmation rule already exists.', 
			'spa_deal_confirmation_rule', '', 
			'This confirmation rule already exists.', ''

		RETURN
	END

	IF @@ERROR <> 0
	BEGIN
		EXEC spa_ErrorHandler @@Error, 'Failed to Insert Deal Confirmation Rule.', 
			'spa_deal_confirmation_rule', 'DB Error', 
			'Failed to Insert Deal Confirmation Rule.', ''
	END
	ELSE
	BEGIN
		EXEC spa_ErrorHandler 0, 'Deal Confirmation Rule Sucessfully Inserted.', 
			'spa_source_counterparty_maintain', 'Success', 
			'Deal Confirmation Rule Sucessfully Inserted.', ''
	END
END

IF @flag = 'u'
BEGIN

     if not exists(select 'x' from deal_confirmation_rule where 
			isnull(buy_sell_flag,'a') = isnull(@buy_sell_flag,'a')
			and	isnull(commodity_id,-1) = isnull(@commodity_id,-1)
			and isnull(contract_id ,-1) = isnull(@contract_id,-1)
			and isnull(deal_type_id,-1)  = isnull(@deal_type_id, -1) 
			and counterparty_id=@counterparty_id
            and rule_id !=@rule_id
            and ISNULL(deal_template_id,-1) = ISNULL(@deal_template_id, -1)
            )
           
   
    begin 

	UPDATE deal_confirmation_rule
	SET	
		counterparty_id = @counterparty_id,
		buy_sell_flag =   CASE WHEN @buy_sell_flag='a' THEN NULL
						       ELSE @buy_sell_flag
							   END,
		commodity_id = @commodity_id,
		contract_id = @contract_id,
		deal_type_id = @deal_type_id,
		confirm_template_id = @confirm_template_id,
		revision_confirm_template_id = @revision_confirm_template_id,
		deal_template_id = @deal_template_id
	WHERE 
		rule_id = @rule_id


      end
      else
	begin
		Exec spa_ErrorHandler -1, 'This confirmation rule already exists.', 
				'spa_deal_confirmation_rule', '', 
				'This confirmation rule already exists.', ''
				return
	end

	If @@Error <> 0
		Exec spa_ErrorHandler -1, 'This confirmation rule already exists.', 
				'spa_deal_confirmation_rule', 'DB Error', 
				'Failed to Update Deal Confirmation Rule.', ''
		Else
		Exec spa_ErrorHandler 0, 'Deal Confirmation Rule Sucessfully Updated.', 
				'spa_source_counterparty_maintain', 'Success', 
				'Deal Confirmation Rule Sucessfully Updated.', ''
END

IF @flag = 'a'
BEGIN
	SELECT rule_id
		--, dcr.counterparty_id
		--, dcr.confirmation_type
		, dcr.legal_entity
		, dcr.book
		, dcr.contract_id
		, dcr.counterparty2
		, dcr.deal_type_id
		, dcr.deal_sub_type
		, dcr.deal_template_id
		, dcr.deal_group
		, dcr.commodity_id
		, dcr.location_group
		, dcr.location
		, dcr.index_group
		, dcr.index_id
		, dcr.buy_sell_flag
		, dcr.confirm_status
		, dcr.deal_status
		--, dcr.[platform]
		--, dcr.sdr_submission
		, dcr.confirm_template_id
		, dcr.revision_confirm_template_id
		--rule_id
		--, sc.counterparty_name counterparty_id
		--, CASE WHEN dcr.buy_sell_flag = 'b' THEN 'Buy' WHEN dcr.buy_sell_flag = 'b' THEN 'Sell' ELSE 'All' END buy_sell_flag
		--, com.commodity_name commodity_id
		--, cg.contract_name contract_id
		--, sdt.source_deal_type_name deal_type_id
		--, crt.template_name confirm_template_id
		--, crt1.template_name revision_confirm_template_id
		--, sdht.template_name deal_template_id
		--, confirmation_type.code confirmation_type
		--, legal_entity.code legal_entity
		--, ph.entity_name book
		--, sc2.counterparty_name counterparty2
		--, sub.source_deal_type_name deal_sub_type
		--, '' deal_group
		--, major.location_name location_group
		--, minor.Location_Name location
		--, index_group.code index_group
		--, spcd.curve_name index_id
		--, deal_status.code deal_status
		--, CASE WHEN dcr.sdr_submission = 'y' THEN 'Yes' ELSE 'No' END sdr_submission
		--, confirm_status.code confirm_status
		--, platform.code platform
	FROM deal_confirmation_rule dcr
	--LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = dcr.counterparty_id
	--LEFT JOIN source_counterparty sc2 ON sc.source_counterparty_id = dcr.counterparty2
	--LEFT JOIN source_commodity com ON com.source_commodity_id = dcr.commodity_id
	--LEFT JOIN contract_group cg ON cg.contract_id = dcr.contract_id
	--LEFT JOIN source_deal_type sdt ON sdt.source_deal_type_id = dcr.deal_type_id
	--LEFT JOIN contract_report_template crt ON crt.template_id = dcr.confirm_template_id AND crt.template_type = 4303
	--LEFT JOIN contract_report_template crt1 ON crt.template_id = dcr.revision_confirm_template_id AND crt.template_type = 4305
	--LEFT JOIN source_deal_header_template sdht ON sdht.template_id = dcr.deal_template_id
	--LEFT JOIN static_data_value confirmation_type	ON confirmation_type.value_id	= dcr.confirmation_type	 AND confirmation_type.type_id = 5600
	--LEFT JOIN static_data_value legal_entity		ON legal_entity.value_id		= dcr.legal_entity		 AND legal_entity.type_id = 5600
	--LEFT JOIN static_data_value index_group			ON index_group.value_id			= dcr.index_group		 AND index_group.type_id = 15100
	--LEFT JOIN static_data_value deal_status			ON deal_status.value_id			= dcr.deal_status		 AND deal_status.type_id = 5600
	--LEFT JOIN static_data_value [platform]			ON [platform].value_id			= dcr.[platform]		 AND [platform].type_id = 5600	
	--LEFT JOIN portfolio_hierarchy ph ON ph.entity_id = dcr.book
	--LEFT JOIN source_deal_type sub ON sub.source_deal_type_id = dcr.deal_sub_type AND sub.sub_type = 'y'
	--LEFT JOIN source_major_location major ON major.source_major_location_ID = dcr.location_group
	--LEFT JOIN source_minor_location minor ON minor.source_minor_location_id = dcr.location
	--LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = dcr.index_id
	--LEFT JOIN static_data_value confirm_status ON confirm_status.value_id = dcr.confirm_status AND confirm_status.[type_id] = 17200
	WHERE ISNULL(dcr.counterparty_id, '') = ISNULL(NULLIF(@counterparty_id, 0), '')
END

IF @flag = 'd'
BEGIN
	DELETE  dcr 
	FROM deal_confirmation_rule dcr
	INNER JOIN dbo.FNASplit(@rule_id, ',') i ON i.item = dcr.rule_id
	
	IF @@ERROR <> 0
	BEGIN
		EXEC spa_ErrorHandler @@ERROR, 'Failed to Delete Deal Confirmation Rule.', 
			'spa_deal_confirmation_rule', 'DB Error', 
			'Failed to Delete Deal Confirmation Rule.', ''
	END
	ELSE
	BEGIN
		EXEC spa_ErrorHandler 0, 'Deal Confirmation Rule Successfully Deleted.', 
			'spa_source_counterparty_maintain', 'Success', 
			'Deal Confirmation Rule Successfully Deleted.', ''
	END
END

IF @flag = 'e'
BEGIN
	IF EXISTS(
		SELECT 1 
		FROM deal_confirmation_rule
		WHERE counterparty_id = @counterparty_id
			AND buy_sell_flag = @buy_sell_flag
			AND ISNULL(commodity_id, 0) = (CASE WHEN commodity_id IS NULL THEN 0 ELSE ISNULL(@commodity_id, 0) END)
			AND ISNULL(contract_id, 0) = (CASE WHEN contract_id IS NULL THEN 0 ELSE ISNULL(@contract_id, 0) END)
			AND ISNULL(deal_type_id, 0) = (CASE WHEN deal_type_id IS NULL THEN 0 ELSE ISNULL(@deal_type_id, 0) END)
	)
	BEGIN
		EXEC spa_ErrorHandler 0, 'Rule defined in the Deal Confirmation Rule.', 
			'spa_source_counterparty_maintain', 'Success', 
			'Rule defined in the Deal Confirmation Rule.', ''
	END
	ELSE
	BEGIN
		EXEC spa_ErrorHandler -1, 'Rule not defined in the Deal Confirmation Rule.', 
			'spa_deal_confirmation_rule', 'DB Error', 
			'Rule not defined in the Deal Confirmation Rule.', ''
	END
END

IF @flag = 'c' -- save data to grid
BEGIN 
	DECLARE @idoc INT
	BEGIN TRY 
		BEGIN TRAN 
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml_value
		
		SELECT 	
			CASE WHEN rule_id = '' THEN NULL ELSE rule_id END rule_id
			, CASE WHEN counterparty_id = '' THEN NULL ELSE NULLIF(counterparty_id,0) END counterparty_id
			, CASE WHEN buy_sell_flag = '' THEN NULL ELSE  buy_sell_flag END buy_sell_flag
			, CASE WHEN commodity_id = '' THEN NULL ELSE commodity_id END commodity_id
			, CASE WHEN contract_id = '' THEN NULL ELSE contract_id END contract_id
			, CASE WHEN deal_type_id = '' THEN NULL ELSE deal_type_id END deal_type_id
			, CASE WHEN confirm_template_id = '' THEN NULL ELSE confirm_template_id END confirm_template_id
			, CASE WHEN revision_confirm_template_id = '' THEN NULL ELSE revision_confirm_template_id END revision_confirm_template_id
			, CASE WHEN deal_template_id = '' THEN NULL ELSE deal_template_id END deal_template_id
			, CASE WHEN legal_entity = '' THEN NULL ELSE legal_entity END legal_entity
			, CASE WHEN book = '' THEN NULL ELSE book END book
			, CASE WHEN counterparty2 = '' THEN NULL ELSE counterparty2 END counterparty2
			, CASE WHEN deal_sub_type = '' THEN NULL ELSE deal_sub_type END deal_sub_type
			, CASE WHEN deal_group = '' THEN NULL ELSE deal_group END deal_group
			, CASE WHEN location_group = '' THEN NULL ELSE location_group END location_group
			, CASE WHEN location = '' THEN NULL ELSE location END location
			, CASE WHEN index_group	 = '' THEN NULL ELSE index_group END index_group	
			, CASE WHEN index_id = '' THEN NULL ELSE index_id END index_id
			, CASE WHEN deal_status = '' THEN NULL ELSE deal_status END deal_status
			, CASE WHEN confirm_status = '' THEN NULL ELSE confirm_status END confirm_status
			INTO #temp_tbl_grid
		FROM   OPENXML (@idoc, '/gridXml/GridRow', 2)
				WITH ( 
				rule_id						 VARCHAR(MAX) '@rule_id',
				counterparty_id				 VARCHAR(MAX) '@counterparty_id',
				buy_sell_flag				 VARCHAR(MAX) '@buy_sell_flag',
				commodity_id				 VARCHAR(MAX) '@commodity_id',
				contract_id					 VARCHAR(MAX) '@contract_id',
				deal_type_id				 VARCHAR(MAX) '@deal_type_id',
				confirm_template_id			 VARCHAR(MAX) '@confirm_template_id',
				revision_confirm_template_id VARCHAR(MAX) '@revision_confirm_template_id',
				deal_template_id			 VARCHAR(MAX) '@deal_template_id',
				legal_entity				 VARCHAR(MAX) '@legal_entity',
				book						 VARCHAR(MAX) '@book',
				counterparty2				 VARCHAR(MAX) '@counterparty2',
				deal_sub_type				 VARCHAR(MAX) '@deal_sub_type',
				deal_group					 VARCHAR(MAX) '@deal_group',
				location_group				 VARCHAR(MAX) '@location_group',
				location					 VARCHAR(MAX) '@location',
				index_group					 VARCHAR(MAX) '@index_group',	
				index_id					 VARCHAR(MAX) '@index_id',
				deal_status					 VARCHAR(MAX) '@deal_status',
				confirm_status				 VARCHAR(MAX) '@confirm_status'
			 
				)
		EXEC sp_xml_removedocument @idoc

		MERGE deal_confirmation_rule AS stm
		USING (	SELECT 	rule_id
				, counterparty_id
				, buy_sell_flag
				, commodity_id
				, contract_id
				, deal_type_id
				, confirm_template_id
				, revision_confirm_template_id
				, deal_template_id
				, legal_entity
				, book
				, counterparty2
				, deal_sub_type
				, deal_group
				, location_group
				, location
				, index_group
				, index_id
				, deal_status
				, confirm_status
			FROM #temp_tbl_grid) AS sd
		ON stm.rule_id = sd.rule_id
		WHEN MATCHED THEN 
			UPDATE SET  stm.counterparty_id                 = sd.counterparty_id,
						stm.buy_sell_flag                   = sd.buy_sell_flag,
						stm.commodity_id                    = sd.commodity_id,
						stm.contract_id                     = sd.contract_id,
						stm.deal_type_id                    = sd.deal_type_id,
						stm.confirm_template_id             = sd.confirm_template_id,
						stm.revision_confirm_template_id    = sd.revision_confirm_template_id,
						stm.deal_template_id                = sd.deal_template_id,
						stm.confirmation_type               = 46601, -- Hard-coded value 46601 i.e. Paper Confirm
						stm.legal_entity                    = sd.legal_entity,
						stm.book                            = sd.book,
						stm.counterparty2                   = sd.counterparty2,
						stm.deal_sub_type                   = sd.deal_sub_type,
						stm.deal_group                      = sd.deal_group,
						stm.location_group                  = sd.location_group,
						stm.location                        = sd.location,
						stm.index_group                     = sd.index_group,
						stm.index_id                        = sd.index_id,
						stm.deal_status                     = sd.deal_status,
						stm.confirm_status                  = sd.confirm_status
		WHEN NOT MATCHED THEN
		INSERT(counterparty_id
				, buy_sell_flag
				, commodity_id
				, contract_id
				, deal_type_id
				, confirm_template_id
				, revision_confirm_template_id
				, deal_template_id
				, confirmation_type
				, legal_entity
				, book
				, counterparty2
				, deal_sub_type
				, deal_group
				, location_group
				, location
				, index_group
				, index_id
				, deal_status
				, confirm_status)
		VALUES(sd.counterparty_id
				, sd.buy_sell_flag
				, sd.commodity_id
				, sd.contract_id
				, sd.deal_type_id
				, sd.confirm_template_id
				, sd.revision_confirm_template_id
				, sd.deal_template_id
				, 46601
				, sd.legal_entity
				, sd.book
				, sd.counterparty2
				, sd.deal_sub_type
				, sd.deal_group
				, sd.location_group
				, sd.location
				, sd.index_group
				, sd.index_id
				, sd.deal_status
				, sd.confirm_status);

		COMMIT TRAN 
		EXEC spa_ErrorHandler 0,
            'Deal Rule Confirmation',
            'spa_deal_confirmation_rule',
            'Success',
            'Data successfully saved.',
            ''
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1,
             'Deal Rule Confirmation',
             'spa_deal_confirmation_rule',
             'DB Error',
             'Failed to update data.',
             ''
	END CATCH
END

ELSE IF @flag = 'z'
BEGIN
	SELECT DISTINCT sc.source_counterparty_id, sc.counterparty_name
	FROM fas_subsidiaries fs
	INNER JOIN source_counterparty sc On sc.source_counterparty_id = fs.counterparty_id
END

IF @flag = 'x'
BEGIN
	SELECT @sql_stmt = '
		SELECT dtm.deal_transfer_mapping_id,
			dtm.logical_name, 
			sc.counterparty_name as [counterparty_id_from], 
			ssbm.logical_name as [source_book_mapping_id_from], 
			sc1.counterparty_name as [counterparty_id_to], 
			st.trader_name as [trader_id_from]
		FROM deal_transfer_mapping dtm 
		LEFT JOIN source_counterparty sc ON dtm.counterparty_id_from = sc.source_counterparty_id
		LEFT JOIN source_system_book_map ssbm ON ssbm.book_deal_type_map_id = dtm.source_book_mapping_id_from
		LEFT JOIN source_counterparty sc1 ON sc1.source_counterparty_id = dtm.counterparty_id_to
		LEFT JOIN source_traders st ON st.source_trader_id = dtm.trader_id_from '

	EXEC(@sql_stmt)
END

GO