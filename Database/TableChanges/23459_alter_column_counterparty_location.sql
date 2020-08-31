IF COL_LENGTH('shipper_code_mapping', 'counterparty') IS NOT NULL
BEGIN
    EXEC sp_RENAME 'shipper_code_mapping.counterparty', 'counterparty_id', 'COLUMN'
END
GO

IF COL_LENGTH('shipper_code_mapping', 'location') IS NOT NULL
BEGIN
    EXEC sp_RENAME 'shipper_code_mapping.location', 'location_id', 'COLUMN'
END
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGUPD_shipper_code_mapping]'))
	DROP TRIGGER [dbo].[TRGUPD_shipper_code_mapping]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER dbo.TRGUPD_shipper_code_mapping
   ON  dbo.shipper_code_mapping
   AFTER UPDATE
AS 
BEGIN
	
	SET NOCOUNT ON;

    UPDATE dbo.shipper_code_mapping
	SET update_user = dbo.FNADBUser(), update_ts = GETDATE()

END
GO

