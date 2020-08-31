/****** Object:  Trigger [TRGUPD_report_record]    Script Date: 08/07/2009 12:40:29 ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGUPD_report_record]'))
	DROP TRIGGER [dbo].[TRGUPD_report_record]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER dbo.TRGUPD_report_record
   ON  dbo.report_record 
   AFTER UPDATE
AS 
BEGIN
	
	SET NOCOUNT ON;

    UPDATE dbo.report_record
	SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
	WHERE report_record.report_id IN (SELECT report_id FROM DELETED)

END
GO
