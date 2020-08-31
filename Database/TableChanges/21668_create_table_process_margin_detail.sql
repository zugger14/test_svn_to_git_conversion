IF OBJECT_ID('[dbo].[process_margin_detail]') IS NULL
BEGIN
	CREATE TABLE [dbo].[process_margin_detail] (
		[process_margin_detail_id] INT IDENTITY(1,1) PRIMARY KEY
		, [process_margin_header_id] INT CONSTRAINT FK_process_margin_detail FOREIGN KEY (process_margin_header_id) REFERENCES process_margin_header (process_margin_header_id)  
		, [effective_date] DATETIME 
		, [initial_margin] NUMERIC(38, 20) 
		, [initial_margin_per] NUMERIC(38, 20) 
		, [maintenance_margin] NUMERIC(38, 20)
		, [maintenance_margin_per] NUMERIC(38, 20)
		, [currency_id] INT CONSTRAINT FK_process_margin_currency FOREIGN KEY (currency_id) REFERENCES source_currency (source_currency_id)  
		, [lot_size] NUMERIC(38, 20)
		, [uom_id] INT CONSTRAINT FK_process_margin_uom FOREIGN KEY (uom_id) REFERENCES source_uom (source_uom_id)
		, [post_rec_threshold] NUMERIC(38, 20)
		, [create_user] VARCHAR(50) DEFAULT(dbo.FNADBUser())
		, [create_ts] DATETIME DEFAULT GETDATE()
		, [update_user] VARCHAR(50)
		, [update_ts]  DATETIME
	)
END

ELSE 
	PRINT 'Table ''process_margin_detail'' already exists'
GO

IF  EXISTS (SELECT 1 FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_process_margin_detail]'))
    DROP TRIGGER [dbo].[TRGUPD_process_margin_detail]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_process_margin_detail]
ON [dbo].[process_margin_detail]
FOR UPDATE
AS
BEGIN
    -- used to prevent recursive trigger
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE [process_margin_detail]
        SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
        FROM [process_margin_detail] g
        INNER JOIN DELETED d ON d.process_margin_detail_id = g.process_margin_detail_id
    END
END
GO