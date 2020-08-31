-- Check if the table is already created
IF OBJECT_ID(N'dbo.counterparty_shipper_info', N'U') IS NULL 
BEGIN
    CREATE TABLE dbo.counterparty_shipper_info (
		/**
			Saves the shipper information of a counterparty.

			Columns
			counterparty_shipper_info_id : Primary Key of the table.
			source_counterparty_id : Foreign Key of the table references to source_counterparty_id of source_counterparty table.
			location : location of the counterparty.
			commodity : comodity of the counterparty.
			effective_date: Effective date of the shipper code.
			shipper_code : Shipper code of the counterparty.
			create_user : specifies the username who creates the column.
			create_ts : specifies the date when column was created.
			update_user : specifies the username who updated the column.
			update_ts : specifies the date when column was updated.
		*/
		counterparty_shipper_info_id	INT IDENTITY(1, 1) PRIMARY KEY
		, source_counterparty_id		INT
		, [location]					INT
		, commodity						INT
		, effective_date				DATETIME
		, shipper_code					VARCHAR(50)
		, create_user					VARCHAR(50)  DEFAULT dbo.FNADBUser()
		, create_ts						DATETIME  DEFAULT GETDATE()
		, update_user					VARCHAR(50)
		, update_ts						DATETIME 
		, CONSTRAINT FK_counterparty_shipper_info_source_counterparty_id FOREIGN KEY (source_counterparty_id) REFERENCES source_counterparty(source_counterparty_id	) ON 
			DELETE CASCADE	
    )
END
ELSE
BEGIN
    PRINT 'Table counterparty_shipper_info EXISTS'
END
 
GO
-- check if the trigger exists
IF  EXISTS (SELECT 1 FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'dbo.TRGUPD_counterparty_shipper_info'))
    DROP TRIGGER dbo.TRGUPD_counterparty_shipper_info
GO

CREATE TRIGGER dbo.TRGUPD_counterparty_shipper_info
ON dbo.counterparty_shipper_info
FOR UPDATE
AS
BEGIN
    --this check is required to prevent recursive trigger
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE counterparty_shipper_info
        SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
        FROM counterparty_shipper_info  csi
        INNER JOIN DELETED d ON d.counterparty_shipper_info_id =  csi.counterparty_shipper_info_id
    END
END
GO