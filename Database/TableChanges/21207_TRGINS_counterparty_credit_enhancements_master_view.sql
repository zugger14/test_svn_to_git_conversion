SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[TRGINS_counterparty_credit_enhancements_master_view]', N'TR') IS NOT NULL
BEGIN
	DROP TRIGGER [dbo].[TRGINS_counterparty_credit_enhancements_master_view]
END
GO
CREATE TRIGGER [dbo].[TRGINS_counterparty_credit_enhancements_master_view] ON [dbo].[counterparty_credit_enhancements]
AFTER INSERT, UPDATE
AS
	IF @@ROWCOUNT = 0
	BEGIN
		RETURN
	END
	IF EXISTS (SELECT 1 FROM deleted ) 
		AND EXISTS (
		SELECT TOP 1
			1
		FROM master_view_counterparty_credit_enhancements AS m
		INNER JOIN inserted AS i ON i.counterparty_credit_enhancement_id = m.counterparty_credit_enhancement_id
	)  
	BEGIN
		UPDATE mvcc
		SET
			counterparty_credit_enhancement_id = cc.counterparty_credit_enhancement_id,
			counterparty_credit_info_id = cc.counterparty_credit_info_id,
			enhance_type = sdv.code,
			guarantee_counterparty = sc.counterparty_name,
			comment = cc.comment,
			currency_code = sc2.currency_name,
			eff_date = CONVERT(VARCHAR(10), cc.eff_date, 120),
			approved_by = cc.approved_by,
			expiration_date = CONVERT(VARCHAR(10), cc.expiration_date, 120),
			contract_id = cg.[contract_name],
			internal_counterparty = sc3.counterparty_name
			--,
			--collateral_status = sdv1.code
		FROM [master_view_counterparty_credit_enhancements] [mvcc]
		INNER JOIN [inserted] [cc] ON [cc].[counterparty_credit_enhancement_id] = [mvcc].[counterparty_credit_enhancement_id]
		LEFT JOIN [source_counterparty] [sc] ON [sc].[source_counterparty_id] = [cc].[guarantee_counterparty]
		LEFT JOIN source_currency sc2 ON sc2.source_currency_id = cc.currency_code
		LEFT JOIN contract_group cg ON cg.contract_id = cc.contract_id
		LEFT JOIN [source_counterparty] [sc3] ON [sc3].[source_counterparty_id] = [cc].internal_counterparty
		LEFT JOIN static_data_value sdv ON sdv.value_id = cc.enhance_type
		--LEFT JOIN static_data_value sdv1 ON sdv1.value_id = cc.collateral_status

	END
	ELSE
	BEGIN
		INSERT INTO dbo.master_view_counterparty_credit_enhancements (
			counterparty_credit_enhancement_id,
			counterparty_credit_info_id,
			enhance_type,
			guarantee_counterparty,
			comment,
			currency_code,
			eff_date,
			approved_by,
			expiration_date,
			contract_id,
			internal_counterparty
			--,
			--collateral_status
		)
		SELECT
			cc.counterparty_credit_enhancement_id,
			cc.counterparty_credit_info_id,
			sdv.code,
			sc.counterparty_name,
			cc.comment,
			sc2.currency_name,
			CONVERT(VARCHAR(10), cc.eff_date, 120),
			cc.approved_by,
			CONVERT(VARCHAR(10), cc.expiration_date, 120),
			cg.[contract_name],
			sc3.counterparty_name
			--,
			--sdv1.code
		FROM inserted AS cc
		LEFT JOIN [source_counterparty] [sc] ON [sc].[source_counterparty_id] = [cc].[guarantee_counterparty]
		LEFT JOIN source_currency sc2 ON sc2.source_currency_id = cc.currency_code
		LEFT JOIN contract_group cg ON cg.contract_id = cc.contract_id
		LEFT JOIN [source_counterparty] [sc3] ON [sc3].[source_counterparty_id] = [cc].internal_counterparty
		LEFT JOIN static_data_value sdv ON sdv.value_id = cc.enhance_type
		--LEFT JOIN static_data_value sdv1 ON sdv1.value_id = cc.collateral_status
	END
GO