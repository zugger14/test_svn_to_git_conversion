SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[TRGINS_counterparty_credit_limits_master_view]', N'TR') IS NOT NULL
BEGIN
	DROP TRIGGER [dbo].[TRGINS_counterparty_credit_limits_master_view]
END
GO
CREATE TRIGGER [dbo].[TRGINS_counterparty_credit_limits_master_view] ON [dbo].[counterparty_credit_limits]
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
		FROM master_view_counterparty_credit_limits AS m
		INNER JOIN inserted AS i ON i.counterparty_credit_limit_id = m.counterparty_credit_limit_id
	)  
	BEGIN
		UPDATE mvcc
		SET
			counterparty_credit_limit_id = cc.counterparty_credit_limit_id,
			counterparty_id = sc.counterparty_name,
			contract_id = cg.[contract_name],
			internal_counterparty_id = sc2.counterparty_name,
			limit_status = sdv.code,
			counterparty_credit_info_id = cci.counterparty_credit_info_id
		FROM [master_view_counterparty_credit_limits] [mvcc]
		INNER JOIN [inserted] [cc] ON [cc].[counterparty_credit_limit_id] = [mvcc].[counterparty_credit_limit_id]
		INNER JOIN counterparty_credit_info cci ON cci.Counterparty_id = [cc].counterparty_id
		LEFT JOIN [source_counterparty] [sc] ON [sc].[source_counterparty_id] = [cc].counterparty_id
		LEFT JOIN contract_group cg ON cg.contract_id = cc.contract_id
		LEFT JOIN [source_counterparty] [sc2] ON [sc2].[source_counterparty_id] = [cc].internal_counterparty_id
		LEFT JOIN static_data_value sdv ON sdv.value_id = cc.limit_status
	END
	ELSE
	BEGIN
		INSERT INTO dbo.master_view_counterparty_credit_limits (
			counterparty_credit_limit_id,
			counterparty_id,
			contract_id,
			internal_counterparty_id,
			limit_status,
			counterparty_credit_info_id
		)
		SELECT
			cc.counterparty_credit_limit_id,
			sc.counterparty_name,
			cg.[contract_name],
			sc2.counterparty_name,
			sdv.code,
			cci.counterparty_credit_info_id
		FROM inserted AS cc
		INNER JOIN counterparty_credit_info cci ON cci.Counterparty_id = [cc].counterparty_id
		LEFT JOIN [source_counterparty] [sc] ON [sc].[source_counterparty_id] = [cc].counterparty_id
		LEFT JOIN contract_group cg ON cg.contract_id = cc.contract_id
		LEFT JOIN [source_counterparty] [sc2] ON [sc2].[source_counterparty_id] = [cc].internal_counterparty_id
		LEFT JOIN static_data_value sdv ON sdv.value_id = cc.limit_status
	END
GO