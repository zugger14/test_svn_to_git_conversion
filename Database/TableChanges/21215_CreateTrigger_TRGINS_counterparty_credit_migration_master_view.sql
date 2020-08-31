SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[TRGINS_counterparty_credit_migration_master_view]', N'TR') IS NOT NULL
BEGIN
	DROP TRIGGER [dbo].[TRGINS_counterparty_credit_migration_master_view]
END
GO
CREATE TRIGGER [dbo].[TRGINS_counterparty_credit_migration_master_view] ON [dbo].[counterparty_credit_migration]
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
		FROM master_view_counterparty_credit_migration AS m
		INNER JOIN inserted AS i ON i.counterparty_credit_migration_id = m.counterparty_credit_migration_id
	)  
	BEGIN
		UPDATE mvcc
		SET
			counterparty_credit_migration_id = cc.counterparty_credit_migration_id,
			counterparty_credit_info_id = cc.counterparty_credit_info_id,
			counterparty = sc.counterparty_name,
			[contract] = cg.[contract_name],
			internal_counterparty = sc2.counterparty_name,
			rating = sdv.code,
			effective_date = CONVERT(VARCHAR(10), cc.effective_date, 120)
		FROM [master_view_counterparty_credit_migration] [mvcc]
		INNER JOIN [inserted] [cc] ON [cc].[counterparty_credit_migration_id] = [mvcc].[counterparty_credit_migration_id]
		LEFT JOIN [source_counterparty] [sc] ON [sc].[source_counterparty_id] = [cc].counterparty
		LEFT JOIN contract_group cg ON cg.contract_id = cc.[contract]
		LEFT JOIN [source_counterparty] [sc2] ON [sc2].[source_counterparty_id] = [cc].internal_counterparty
		LEFT JOIN static_data_value sdv ON sdv.value_id = cc.rating
	END
	ELSE
	BEGIN
		INSERT INTO dbo.master_view_counterparty_credit_migration (
			counterparty_credit_migration_id,
			counterparty_credit_info_id,
			counterparty,
			[contract],
			internal_counterparty,
			rating,
			effective_date
		)
		SELECT
			cc.counterparty_credit_migration_id,
			cc.counterparty_credit_info_id,
			sc.counterparty_name,
			cg.[contract_name],
			sc2.counterparty_name,
			sdv.code,
			CONVERT(VARCHAR(10), cc.effective_date, 120)
		FROM inserted AS cc
		LEFT JOIN [source_counterparty] [sc] ON [sc].[source_counterparty_id] = [cc].counterparty
		LEFT JOIN contract_group cg ON cg.contract_id = cc.[contract]
		LEFT JOIN [source_counterparty] [sc2] ON [sc2].[source_counterparty_id] = [cc].internal_counterparty
		LEFT JOIN static_data_value sdv ON sdv.value_id = cc.rating
	END
GO