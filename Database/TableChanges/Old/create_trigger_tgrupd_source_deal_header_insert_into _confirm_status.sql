SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGUPD_SOURCE_DEAL_HEADER]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_SOURCE_DEAL_HEADER]
GO

CREATE TRIGGER [dbo].[TRGUPD_SOURCE_DEAL_HEADER]
ON [dbo].[source_deal_header]
FOR UPDATE 
AS BEGIN   
	SET NOCOUNT ON;

	IF UPDATE (confirm_status_type) 
    BEGIN
		IF EXISTS(SELECT 1 FROM deleted i INNER JOIN confirm_status cs ON cs.source_deal_header_id = i.source_deal_header_id)
		BEGIN
			INSERT INTO confirm_status(source_deal_header_id,type,as_of_date)
			SELECT i.source_deal_header_id, sdh.confirm_status_type,getdate()
			FROM source_deal_header sdh
			INNER JOIN deleted i ON sdh.source_deal_header_id = i.source_deal_header_id
			OUTER APPLY(SELECT MAX(confirm_status_id) confirm_status_id FROM confirm_status WHERE source_deal_header_id =sdh.source_deal_header_id) cs1
			LEFT JOIN confirm_status cs On cs.confirm_status_id = cs1.confirm_status_id
			WHERE sdh.confirm_status_type <> i.confirm_status_type AND cs.type <> sdh.confirm_status_type
		END
		ELSE
		BEGIN
			INSERT INTO confirm_status(source_deal_header_id,type,as_of_date)
			SELECT i.source_deal_header_id, sdh.confirm_status_type,getdate()
			FROM source_deal_header sdh
			INNER JOIN deleted i ON sdh.source_deal_header_id = i.source_deal_header_id
		END
	END
END
GO