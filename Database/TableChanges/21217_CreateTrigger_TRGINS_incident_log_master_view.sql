SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[TRGINS_incident_log_master_view]', N'TR') IS NOT NULL
BEGIN
	DROP TRIGGER [dbo].[TRGINS_incident_log_master_view]
END
GO
CREATE TRIGGER [dbo].[TRGINS_incident_log_master_view] ON [dbo].[incident_log]
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
		FROM master_view_incident_log AS m
		INNER JOIN inserted AS i ON i.incident_log_id = m.incident_log_id
	)  
	BEGIN
		UPDATE mvcc
		SET
			incident_log_id = cc.incident_log_id,
			incident_type = sdv.code,
			incident_description = cc.incident_description,
			incident_status = sdv1.code,
			buyer_from = sc.counterparty_name,
			seller_to = sc2.counterparty_name,
			[location] = sml.Location_Name,
			date_initiated = CONVERT(VARCHAR(10), cc.date_initiated, 120),
			date_closed = CONVERT(VARCHAR(10), cc.date_closed, 120),
			trader = st.trader_name,
			logistics = sdv2.code,
			corrective_action = cc.corrective_action,
			preventive_action = cc.preventive_action
			--,
			--[contract] = cg.[contract_name],
			--[counterparty] = sc3.counterparty_name,
			--[internal_counterparty] = sc4.counterparty_name
		FROM [master_view_incident_log] [mvcc]
		INNER JOIN [inserted] [cc] ON [cc].[incident_log_id] = [mvcc].[incident_log_id]
		LEFT JOIN [source_counterparty] [sc] ON [sc].[source_counterparty_id] = [cc].buyer_from
		LEFT JOIN [source_counterparty] [sc2] ON [sc2].[source_counterparty_id] = [cc].seller_to
		LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = cc.[location]
		LEFT JOIN source_traders st ON st.source_trader_id = cc.[trader]
		--LEFT JOIN contract_group cg ON cg.contract_id = cc.[contract]
		LEFT JOIN static_data_value sdv ON sdv.value_id = cc.incident_type
		LEFT JOIN static_data_value sdv1 ON sdv1.value_id = cc.incident_status
		LEFT JOIN static_data_value sdv2 ON sdv2.value_id = cc.logistics
		--LEFT JOIN [source_counterparty] [sc3] ON [sc].[source_counterparty_id] = [cc].[counterparty]
		--LEFT JOIN [source_counterparty] [sc4] ON [sc2].[source_counterparty_id] = [cc].[internal_counterparty]
	END
	ELSE
	BEGIN
		INSERT INTO dbo.master_view_incident_log (
			[incident_log_id],
			[incident_type],
			[incident_description],
			[incident_status],
			[buyer_from],
			[seller_to],
			[location],
			[date_initiated],
			[date_closed],
			[trader],
			[logistics],
			[corrective_action],
			[preventive_action]
			--,
			--[contract],
			--[counterparty],
			--[internal_counterparty]
		)
		SELECT
			[cc].[incident_log_id],
			[sdv].[code],
			[cc].[incident_description],
			[sdv1].[code],
			[sc].[counterparty_name],
			[sc2].[counterparty_name],
			[sml].[Location_Name],
			CONVERT(VARCHAR(10), [cc].[date_initiated], 120),
			CONVERT(VARCHAR(10), [cc].[date_closed], 120),
			[st].[trader_name],
			[sdv2].[code],
			[cc].[corrective_action],
			[cc].[preventive_action]
			--,
			--[cg].[contract_name],
			--sc3.counterparty_name,
			--sc4.counterparty_name
		FROM inserted AS cc
		LEFT JOIN [source_counterparty] AS [sc] ON [sc].[source_counterparty_id] = [cc].buyer_from
		LEFT JOIN [source_counterparty] AS [sc2] ON [sc2].[source_counterparty_id] = [cc].seller_to
		LEFT JOIN source_minor_location AS sml ON sml.source_minor_location_id = cc.[location]
		LEFT JOIN source_traders AS st ON st.source_trader_id = cc.[trader]
		--LEFT JOIN contract_group AS cg ON cg.contract_id = cc.[contract]
		LEFT JOIN static_data_value AS sdv ON sdv.value_id = cc.incident_type
		LEFT JOIN static_data_value AS sdv1 ON sdv1.value_id = cc.incident_status
		LEFT JOIN static_data_value AS sdv2 ON sdv2.value_id = cc.logistics
		--LEFT JOIN [source_counterparty] [sc3] ON [sc].[source_counterparty_id] = [cc].[counterparty]
		--LEFT JOIN [source_counterparty] [sc4] ON [sc2].[source_counterparty_id] = [cc].[internal_counterparty]
	END
GO