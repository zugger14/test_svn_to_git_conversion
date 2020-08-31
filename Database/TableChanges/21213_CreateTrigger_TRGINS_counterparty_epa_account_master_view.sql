SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[TRGINS_counterparty_epa_account_master_view]', N'TR') IS NOT NULL
BEGIN
	DROP TRIGGER [dbo].[TRGINS_counterparty_epa_account_master_view]
END
GO
CREATE TRIGGER [dbo].[TRGINS_counterparty_epa_account_master_view] ON [dbo].[counterparty_epa_account]
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
		FROM master_view_counterparty_epa_account AS m
		INNER JOIN inserted AS i ON i.counterparty_epa_account_id = m.counterparty_epa_account_id
	)  
	BEGIN
		UPDATE mvcc
		SET
			counterparty_epa_account_id = cc.counterparty_epa_account_id,
			counterparty_name = sc.counterparty_name,
			external_type_id = sdv.code,
			external_value = cc.external_value,
			counterparty_id = [cc].counterparty_id
		FROM [master_view_counterparty_epa_account] [mvcc]
		INNER JOIN [inserted] [cc] ON [cc].[counterparty_epa_account_id] = [mvcc].[counterparty_epa_account_id]
		INNER JOIN counterparty_credit_info cci ON cci.Counterparty_id = [cc].counterparty_id
		LEFT JOIN [source_counterparty] [sc] ON [sc].[source_counterparty_id] = [cc].counterparty_id
		LEFT JOIN static_data_value sdv ON sdv.value_id = cc.external_type_id
	END
	ELSE
	BEGIN
		INSERT INTO dbo.master_view_counterparty_epa_account (
			counterparty_epa_account_id,
			counterparty_id,
			external_type_id,
			external_value,
			counterparty_name
		)
		SELECT
			cc.counterparty_epa_account_id,
			[cc].counterparty_id,
			sdv.code,
			cc.external_value,
			sc.counterparty_name
		FROM inserted AS cc
		INNER JOIN counterparty_credit_info cci ON cci.Counterparty_id = [cc].counterparty_id
		LEFT JOIN [source_counterparty] [sc] ON [sc].[source_counterparty_id] = [cc].counterparty_id
		LEFT JOIN static_data_value sdv ON sdv.value_id = cc.external_type_id
	END
GO