SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[stmt_adjustments]', N'U') IS NULL
BEGIN
   
	CREATE TABLE stmt_adjustments(
			stmt_adjustments_id INT IDENTITY(1,1) ,
			as_of_date	 DATETIME,
			source_deal_header_id INT,
			leg INT,
			term_start DATETIME,
			term_end DATETIME,
			charge_type_id INT,
			shipment_id INT,
			ticket_detail_id INT,
			settlement_amount_pre NUMERIC(32,20),
			settlement_amount_new NUMERIC(32,20),
			settlement_amount NUMERIC(32,20),
			volume_pre NUMERIC(32,20),
			volume_new NUMERIC(32,20),
			volume NUMERIC(32,20),
			price_pre NUMERIC(32,20),
			price_new NUMERIC(32,20),
			price NUMERIC(32,20),
			create_user VARCHAR(200) DEFAULT dbo.FNADBUser(),
    		create_ts DATETIME DEFAULT GETDATE(),
    		[update_user]              VARCHAR(100) NULL,
    		[update_ts]                DATETIME NULL
		)
END
ELSE
BEGIN
    PRINT 'Table stmt_adjustments EXISTS'
END
GO


IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = 'indx_stmt_adjustments')
CREATE CLUSTERED INDEX indx_stmt_adjustments 
    ON dbo.stmt_adjustments(as_of_date,source_deal_header_id,leg, term_start, term_end, charge_type_id)
GO


--Update Trigger
IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_stmt_adjustments]'))
    DROP TRIGGER  [dbo].[TRGUPD_stmt_adjustments]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGUPD_stmt_adjustments]
ON [dbo].[stmt_adjustments]
FOR UPDATE
AS
BEGIN
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE [dbo].[stmt_adjustments]
        SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
        FROM [dbo].[stmt_adjustments] fr
        INNER JOIN DELETED d ON d.stmt_adjustments_id = fr.stmt_adjustments_id
    END
END
GO