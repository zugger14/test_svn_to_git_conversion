IF OBJECT_ID(N'FNAGetDocumentTemplate', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNAGetDocumentTemplate]
 GO

 /**
	Returns the document template to generate document based on respective mapping

	Parameters :
	@document_type : Document Type (Static Data - Type ID = 25)
	@document_sub_type : Document Sub Type (Static Data - Type ID = 42000)
	@object_id : Primay ID of the object for which document need to be generated.
	@template_id : Document Template ID

	Returns Document Template
 */
 
CREATE FUNCTION [dbo].[FNAGetDocumentTemplate]
(
	@document_type      INT,
	@document_sub_type	INT,
	@object_id			VARCHAR(MAX),
	@template_id		INT
)

RETURNS INT
AS
BEGIN
	SET @template_id = NULLIF(@template_id,0)
	DECLARE @document_template_id INT = NULL
	DECLARE @use_default_template INT = 1

	-- DEAL
	IF @document_type = 33 AND @document_sub_type IN (42018, 42021)
	BEGIN
		IF EXISTS(SELECT 1 FROM source_deal_header WHERE source_deal_header_id = @object_id AND counterparty_id2 IS NULL AND @document_sub_type = 42021)
		BEGIN	
			SET @template_id = 0
			SET @use_default_template = 0
		END
		ELSE IF (SELECT confirmation_template FROM source_deal_header WHERE source_deal_header_id = @object_id) IS NOT NULL
		BEGIN
			SELECT @document_template_id = confirmation_template FROM source_deal_header WHERE source_deal_header_id = @object_id
			SET @use_default_template = 0
		END
		ELSE IF @template_id IS NOT NULL
		BEGIN
			SET @document_template_id = @template_id
			SET @use_default_template = 0
		END
		ELSE IF NOT EXISTS (SELECT 1 FROM deal_confirmation_rule)
		BEGIN
			SET @use_default_template = 1
		END
		ELSE IF EXISTS (SELECT 1 FROM Contract_report_template crt
					INNER JOIN deal_confirmation_rule dcr ON crt.template_id = dcr.confirm_template_id
					INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = @object_id
					AND CASE WHEN @document_sub_type = 42021 THEN ISNULL(dcr.counterparty_id,sdh.counterparty_id2) ELSE ISNULL(dcr.counterparty_id,sdh.counterparty_id) END = CASE WHEN @document_sub_type = 42021 THEN sdh.counterparty_id2 ELSE sdh.counterparty_id END
					AND ISNULL(ISNULL(dcr.deal_type_id, sdh.source_deal_type_id),1) = ISNULL(sdh.source_deal_type_id,1)
					AND ISNULL(ISNULL(dcr.deal_sub_type, sdh.deal_sub_type_type_id),1) = ISNULL(sdh.deal_sub_type_type_id,1)
					AND COALESCE(dcr.buy_sell_flag, sdh.header_buy_sell_flag, '1') = CASE WHEN dcr.buy_sell_flag = 'a' THEN 'a' ELSE COALESCE(sdh.header_buy_sell_flag, '1') END
					AND ISNULL(dcr.deal_template_id, sdh.template_id) = sdh.template_id
					INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id 
					AND ISNULL(ISNULL(dcr.origin, sdd.origin), 1) = ISNULL(sdd.origin, 1)
					AND ISNULL(ISNULL(dcr.commodity_id, sdh.commodity_id), 1) = ISNULL(sdh.commodity_id, 1)  
					AND ISNULL(ISNULL(dcr.contract_id, sdh.contract_id), 1) = ISNULL(sdh.contract_id,1)
					AND ISNULL(ISNULL(dcr.confirm_status, sdh.confirm_status_type),1) = ISNULL(sdh.confirm_status_type,1)
					AND ISNULL(ISNULL(dcr.deal_status, sdh.deal_status),1) = ISNULL(sdh.deal_status,1)
					WHERE template_type = @document_type AND ISNULL(dcr.deal_confirm, 42018) = @document_sub_type)
		BEGIN
			SET @use_default_template = 0

			SELECT TOP(1) @document_template_id = crt.template_id
			FROM Contract_report_template crt
			INNER JOIN deal_confirmation_rule dcr ON crt.template_id = dcr.confirm_template_id
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = @object_id 
			AND CASE WHEN @document_sub_type = 42021 THEN ISNULL(dcr.counterparty_id,sdh.counterparty_id2) ELSE ISNULL(dcr.counterparty_id,sdh.counterparty_id) END = CASE WHEN @document_sub_type = 42021 THEN sdh.counterparty_id2 ELSE sdh.counterparty_id END
			AND ISNULL(ISNULL(dcr.deal_type_id, sdh.source_deal_type_id),1) = ISNULL(sdh.source_deal_type_id,1)
			AND ISNULL(ISNULL(dcr.deal_sub_type, sdh.deal_sub_type_type_id),1) = ISNULL(sdh.deal_sub_type_type_id,1)
			AND COALESCE(dcr.buy_sell_flag, sdh.header_buy_sell_flag, '1') = CASE WHEN dcr.buy_sell_flag = 'a' THEN 'a' ELSE COALESCE(sdh.header_buy_sell_flag, '1') END
			AND ISNULL(dcr.deal_template_id, sdh.template_id) = sdh.template_id
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id 
			AND ISNULL(ISNULL(dcr.origin, sdd.origin), 1) = ISNULL(sdd.origin, 1)
			AND ISNULL(ISNULL(dcr.commodity_id, sdh.commodity_id), 1) = ISNULL(sdh.commodity_id, 1)  
			AND ISNULL(ISNULL(dcr.contract_id, sdh.contract_id), 1) = ISNULL(sdh.contract_id,1)
			AND ISNULL(ISNULL(dcr.confirm_status, sdh.confirm_status_type),1) = ISNULL(sdh.confirm_status_type,1)
			AND ISNULL(ISNULL(dcr.deal_status, sdh.deal_status),1) = ISNULL(sdh.deal_status,1)
			WHERE template_type = @document_type  AND ISNULL(dcr.deal_confirm, 42018) = @document_sub_type
	
		END
		ELSE
		BEGIN
			SET @use_default_template = 2
		END
	END
	-- INVOICE
	ELSE IF @document_type IN (38,10000283)
	BEGIN
		IF @template_id IS NOT NULL
		BEGIN
			SET @document_template_id = @template_id
			SET @use_default_template = 0
		END
		ELSE 
		BEGIN
			IF @document_type = 38
			BEGIN
				SELECT @document_template_id = crt.template_id 
				FROM calc_invoice_volume_variance civv
				INNER JOIN contract_group cg ON cg.contract_id = civv.contract_id
				INNER JOIN Contract_report_template crt ON crt.template_id =  
													CASE WHEN civv.invoice_type = 'i' THEN cg.invoice_report_template
														WHEN civv.invoice_type IN('r','e') THEN cg.contract_report_template
														WHEN civv.netting_group_id IS NOT NULL THEN cg.netting_template
													ELSE '' END 
				WHERE crt.template_id IS NOT NULL AND civv.calc_id = @object_id
			END
			ELSE
			BEGIN
				SELECT @document_template_id = crt.template_id 
				FROM stmt_invoice sti
				INNER JOIN contract_group cg ON cg.contract_id = sti.contract_id
				INNER JOIN Contract_report_template crt ON crt.template_id =  
													CASE WHEN @object_id < 0 THEN cg.netting_template
														WHEN sti.invoice_type = 'i' THEN cg.invoice_report_template
														WHEN sti.invoice_type IN('r','e') THEN cg.contract_report_template
													ELSE '' END 
				WHERE crt.template_id IS NOT NULL AND sti.stmt_invoice_id = ABS(@object_id)
			END
			SET @use_default_template = 0
		END
		SET @document_type = ABS(@document_type)
	END
	-- SHIPMENT
	IF @document_type = 45
	BEGIN
		IF @template_id IS NOT NULL
		BEGIN
			SET @document_template_id = @template_id
			SET @use_default_template = 0
		END
		ELSE 
		BEGIN
			
			DECLARE @temp_scheduling_data TABLE (
				template_id INT, commodity_id INT, origin INT, deal_type INT, deal_sub_type INT,
				buy_inco_term INT, buy_payment_term INT, sell_inco_term INT, sell_payment_date INT,
				destination_country INT
			)

			INSERT INTO @temp_scheduling_data (template_id, commodity_id, origin, deal_type, deal_sub_type,buy_inco_term, buy_payment_term)
			SELECT DISTINCT TOP(1) sdh.template_id, sdd.detail_commodity_id, co.origin, sdh.source_deal_type_id, sdh.deal_sub_type_type_id, ISNULL(sdd.detail_inco_terms,sdh.inco_terms) [buy_inco_term], sdh.payment_term [buy_payment_term] FROM match_group mg
			INNER JOIN match_group_shipment mgs ON mg.match_group_id = mgs.match_group_id
			INNER JOIN match_group_header mgh ON mgs.match_group_shipment_id = mgh.match_group_shipment_id
			INNER JOIN match_group_detail mgd ON mgh.match_group_header_id = mgd.match_group_header_id
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = mgd.source_deal_detail_id
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
			LEFT JOIN commodity_origin co ON co.commodity_origin_id = sdd.origin
			WHERE mgs.match_group_shipment_id = @object_id AND sdh.header_buy_sell_flag = 'b'

			DECLARE @sell_inco_term INT
			DECLARE @sell_payment_term INT
			DECLARE @destination_country INT
			SET @sell_inco_term = NULL
			SET @sell_payment_term = NULL
			SET @destination_country = NULL

			SELECT DISTINCT TOP(1) @sell_inco_term = ISNULL(sdd.detail_inco_terms,sdh.inco_terms), @sell_payment_term = sdh.payment_term, 
					@destination_country = sml.country 
			FROM match_group mg
			INNER JOIN match_group_shipment mgs ON mg.match_group_id = mgs.match_group_id
			INNER JOIN match_group_header mgh ON mgs.match_group_shipment_id = mgh.match_group_shipment_id
			INNER JOIN match_group_detail mgd ON mgh.match_group_header_id = mgd.match_group_header_id
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = mgd.source_deal_detail_id
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
			LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id
			WHERE mgs.match_group_shipment_id = @object_id AND sdh.header_buy_sell_flag = 's'

			UPDATE @temp_scheduling_data
			SET sell_inco_term = @sell_inco_term, sell_payment_date = @sell_payment_term, destination_country = @destination_country

			IF EXISTS (SELECT 1 FROM @temp_scheduling_data tsd
			INNER JOIN generic_mapping_values gmv ON CASE WHEN gmv.clm1_value IS NULL THEN '' ELSE CAST(tsd.template_id AS VARCHAR) END = ISNULL(CAST(gmv.clm1_value AS VARCHAR) ,'')
					AND CASE WHEN gmv.clm2_value IS NULL THEN '' ELSE CAST(tsd.commodity_id AS VARCHAR) END = ISNULL(CAST(gmv.clm2_value AS VARCHAR),'')
					AND CASE WHEN gmv.clm3_value IS NULL THEN '' ELSE CAST(tsd.origin AS VARCHAR) END = ISNULL(CAST(gmv.clm3_value AS VARCHAR),'')
					AND CASE WHEN gmv.clm4_value IS NULL THEN '' ELSE CAST(tsd.deal_type AS VARCHAR) END = ISNULL(CAST(gmv.clm4_value AS VARCHAR),'') 
					AND CASE WHEN gmv.clm5_value IS NULL THEN '' ELSE CAST(tsd.deal_sub_type AS VARCHAR) END = ISNULL(CAST(gmv.clm5_value AS VARCHAR),'') 
					AND CASE WHEN gmv.clm6_value IS NULL THEN '' ELSE CAST(tsd.buy_inco_term AS VARCHAR) END = ISNULL(CAST(gmv.clm6_value AS VARCHAR),'')
					AND CASE WHEN gmv.clm7_value IS NULL THEN '' ELSE CAST(tsd.sell_inco_term AS VARCHAR) END = ISNULL(CAST(gmv.clm7_value AS VARCHAR),'')
					AND CASE WHEN gmv.clm8_value IS NULL THEN '' ELSE CAST(tsd.buy_payment_term AS VARCHAR) END = ISNULL(CAST(gmv.clm8_value AS VARCHAR),'')
					AND CASE WHEN gmv.clm9_value IS NULL THEN '' ELSE CAST(tsd.sell_payment_date AS VARCHAR) END = ISNULL(CAST(gmv.clm9_value AS VARCHAR),'')
					AND CASE WHEN gmv.clm10_value IS NULL THEN '' ELSE 's' END = ISNULL(CAST(gmv.clm10_value AS VARCHAR),'')
					AND CASE WHEN gmv.clm11_value IS NULL THEN '' ELSE @document_sub_type END = ISNULL(CAST(gmv.clm11_value AS VARCHAR),'')
					AND CASE WHEN gmv.clm13_value IS NULL THEN '' ELSE CAST(tsd.destination_country AS VARCHAR) END = ISNULL(CAST(gmv.clm13_value AS VARCHAR),''))
			BEGIN
				SET @use_default_template = 0

				SELECT TOP(1) 
						@template_id = crt.template_id
				FROM @temp_scheduling_data tsd
				INNER JOIN generic_mapping_values gmv ON CASE WHEN gmv.clm1_value IS NULL THEN '' ELSE CAST(tsd.template_id AS VARCHAR) END = ISNULL(CAST(gmv.clm1_value AS VARCHAR) ,'')
					AND CASE WHEN gmv.clm2_value IS NULL THEN '' ELSE CAST(tsd.commodity_id AS VARCHAR) END = ISNULL(CAST(gmv.clm2_value AS VARCHAR),'')
					AND CASE WHEN gmv.clm3_value IS NULL THEN '' ELSE CAST(tsd.origin AS VARCHAR) END = ISNULL(CAST(gmv.clm3_value AS VARCHAR),'')
					AND CASE WHEN gmv.clm4_value IS NULL THEN '' ELSE CAST(tsd.deal_type AS VARCHAR) END = ISNULL(CAST(gmv.clm4_value AS VARCHAR),'') 
					AND CASE WHEN gmv.clm5_value IS NULL THEN '' ELSE CAST(tsd.deal_sub_type AS VARCHAR) END = ISNULL(CAST(gmv.clm5_value AS VARCHAR),'') 
					AND CASE WHEN gmv.clm6_value IS NULL THEN '' ELSE CAST(tsd.buy_inco_term AS VARCHAR) END = ISNULL(CAST(gmv.clm6_value AS VARCHAR),'')
					AND CASE WHEN gmv.clm7_value IS NULL THEN '' ELSE CAST(tsd.sell_inco_term AS VARCHAR) END = ISNULL(CAST(gmv.clm7_value AS VARCHAR),'')
					AND CASE WHEN gmv.clm8_value IS NULL THEN '' ELSE CAST(tsd.buy_payment_term AS VARCHAR) END = ISNULL(CAST(gmv.clm8_value AS VARCHAR),'')
					AND CASE WHEN gmv.clm9_value IS NULL THEN '' ELSE CAST(tsd.sell_payment_date AS VARCHAR) END = ISNULL(CAST(gmv.clm9_value AS VARCHAR),'')
					AND CASE WHEN gmv.clm11_value IS NULL THEN '' ELSE @document_sub_type END = ISNULL(CAST(gmv.clm11_value AS VARCHAR),'')
					AND CASE WHEN gmv.clm13_value IS NULL THEN '' ELSE CAST(tsd.destination_country AS VARCHAR) END = ISNULL(CAST(gmv.clm13_value AS VARCHAR),'')
				INNER JOIN Contract_report_template crt ON crt.template_id = gmv.clm12_value AND gmv.clm10_value = 's'
			END

			SET @use_default_template = 0
		END
	END

	IF @document_type = 48
	BEGIN
		SET @use_default_template = 0
		SELECT @document_template_id = crt.template_id FROM fas_link_header flh 
		INNER JOIN fas_eff_hedge_rel_type fehrt ON fehrt.eff_test_profile_id = flh.eff_test_profile_id
		INNER JOIN contract_report_template crt ON crt.template_name = fehrt.hedge_doc_temp
		WHERE link_id = @object_id		
	END

	IF @use_default_template = 1
	BEGIN
		SELECT TOP(1) 
				@document_template_id = crt.template_id
		FROM Contract_report_template crt
		WHERE template_type = @document_type AND [default] = 1 AND template_category = @document_sub_type
	END

	RETURN @document_template_id
END
