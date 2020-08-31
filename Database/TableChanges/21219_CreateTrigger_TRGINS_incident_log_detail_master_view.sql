SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[TRGINS_incident_log_detail_master_view]', N'TR') IS NOT NULL
BEGIN
	DROP TRIGGER [dbo].[TRGINS_incident_log_detail_master_view]
END
GO
CREATE TRIGGER [dbo].[TRGINS_incident_log_detail_master_view] ON [dbo].[incident_log_detail]
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
		FROM master_view_incident_log_detail AS m
		INNER JOIN inserted AS i ON i.incident_log_detail_id = m.incident_log_detail_id
	)  
	BEGIN
		UPDATE mvcc
		SET
			incident_log_detail_id = cc.incident_log_detail_id,
			incident_log_id = cc.incident_log_id,
			incident_status = sdv.code,
			comments = cc.comments
		FROM [master_view_incident_log_detail] [mvcc]
		INNER JOIN [inserted] [cc] ON [cc].[incident_log_detail_id] = [mvcc].[incident_log_detail_id]
		LEFT JOIN static_data_value sdv ON sdv.value_id = cc.incident_status
	END
	ELSE
	BEGIN
		INSERT INTO dbo.master_view_incident_log_detail (
			incident_log_detail_id,
			incident_log_id,
			incident_status,
			comments
		)
		SELECT
			cc.incident_log_detail_id,
			cc.incident_log_id,
			sdv.code,
			cc.comments
		FROM inserted AS cc
		LEFT JOIN static_data_value sdv ON sdv.value_id = cc.incident_status
	END
GO