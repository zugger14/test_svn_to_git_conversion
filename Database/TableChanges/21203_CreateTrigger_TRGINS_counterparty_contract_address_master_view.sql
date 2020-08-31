SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[TRGINS_counterparty_contract_address_master_view]', N'TR') IS NOT NULL
BEGIN
	DROP TRIGGER [dbo].[TRGINS_counterparty_contract_address_master_view]
END
GO
CREATE TRIGGER [dbo].[TRGINS_counterparty_contract_address_master_view] ON [dbo].[counterparty_contract_address]
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
		FROM master_view_counterparty_contract_address AS m
		INNER JOIN inserted AS i ON i.counterparty_contract_address_id = m.counterparty_contract_address_id
	)  
	BEGIN
		UPDATE mvcc
			SET
				[mvcc].[counterparty_contract_address_id] = [cc].[counterparty_contract_address_id], -- int
				[mvcc].[address1] = [cc].[address1],
				[mvcc].[address2] = [cc].[address2],
				[mvcc].[address3] = [cc].[address3],
				[mvcc].[address4] = [cc].[address4],
				[mvcc].[contract_id] = [cg].[contract_name],
				[mvcc].[email] = [cc].[email],
				[mvcc].[fax] = [cc].[fax],
				[mvcc].[telephone] = [cc].[telephone],
				[mvcc].[counterparty_id] = [cc].[counterparty_id],
				[mvcc].[counterparty_full_name] = [cc].[counterparty_full_name],
				[mvcc].[cc_mail] = [cc].[cc_mail],
				[mvcc].[bcc_mail] = [cc].[cc_mail],
				[mvcc].[remittance_to] = [cc].[remittance_to],
				[mvcc].[cc_remittance] = [cc].[cc_remittance],
				[mvcc].[bcc_remittance] = [cc].[bcc_remittance],
				[mvcc].[internal_counterparty_id] = [sc2].[counterparty_name],
				--[mvcc].[analyst] = [cc].[analyst],
				--[mvcc].[comments] = [cc].[comments],
				[mvcc].[counterparty_trigger] = sdv.code,
				[mvcc].[company_trigger] = sdv1.code,
				[mvcc].[margin_provision] = sdv2.code,
				[mvcc].[counterparty_name] = [sc].[counterparty_name]
		FROM [master_view_counterparty_contract_address] [mvcc]
		INNER JOIN [inserted] [cc] ON [cc].[counterparty_contract_address_id] = [mvcc].[counterparty_contract_address_id]
		LEFT JOIN [contract_group] [cg] ON [cg].[contract_id] = [cc].[contract_id]
		LEFT JOIN [source_counterparty] [sc] ON [sc].[source_counterparty_id] = [cc].[counterparty_id]
		LEFT JOIN [source_counterparty] [sc2] ON [sc2].[source_counterparty_id] = [cc].[internal_counterparty_id]
		LEFT JOIN static_data_value sdv ON sdv.value_id = cc.counterparty_trigger
		LEFT JOIN static_data_value sdv1 ON sdv1.value_id = cc.company_trigger
		LEFT JOIN static_data_value sdv2 ON sdv2.value_id = cc.margin_provision
	END
	ELSE
	BEGIN
		INSERT INTO dbo.master_view_counterparty_contract_address (
			[counterparty_contract_address_id],
			[address1],
			[address2],
			[address3],
			[address4],
			[contract_id],
			[email],
			[fax],
			[telephone],
			[counterparty_id],
			[counterparty_full_name],
			[cc_mail],
			[bcc_mail],
			[remittance_to],
			[cc_remittance],
			[bcc_remittance],
			[internal_counterparty_id],
			--[analyst],
			--[comments],
			[counterparty_trigger],
			[company_trigger],
			[margin_provision],
			[counterparty_name]
		)
		SELECT
			[cc].[counterparty_contract_address_id],
			[cc].[address1],
			[cc].[address2],
			[cc].[address3],
			[cc].[address4],
			[cg].[contract_name],
			[cc].[email],
			[cc].[fax],
			[cc].[telephone],
			[cc].[counterparty_id],
			[cc].[counterparty_full_name],
			[cc].[cc_mail],
			[cc].[bcc_mail],
			[cc].[remittance_to],
			[cc].[cc_remittance],
			[cc].[bcc_remittance],
			[sc2].[counterparty_name],
			--[cc].[analyst],
			--[cc].[comments],
			sdv.code,
			sdv1.code,
			sdv2.code,
			[sc].[counterparty_name]
		FROM inserted AS cc
		LEFT JOIN contract_group AS cg ON cg.contract_id = cc.contract_id
		LEFT JOIN source_counterparty AS sc ON sc.source_counterparty_id = cc.counterparty_id
		LEFT JOIN source_counterparty AS sc2 ON sc2.source_counterparty_id = cc.internal_counterparty_id
		LEFT JOIN static_data_value sdv ON sdv.value_id = cc.counterparty_trigger
		LEFT JOIN static_data_value sdv1 ON sdv1.value_id = cc.company_trigger
		LEFT JOIN static_data_value sdv2 ON sdv2.value_id = cc.margin_provision
	END
GO