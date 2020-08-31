SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
--DROP TABLE  source_deal_broker
IF OBJECT_ID(N'[dbo].[source_deal_broker]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[source_deal_broker]
    (
    	[source_deal_broker_id]			INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
		[source_deal_header_id]			INT,
		[fee_type]						VARCHAR(10) NULL,
		[as_of_date]					DATETIME NULL,
		[term_start]					DATETIME NULL,	
		[term_end]						DATETIME NULL,
		[settlement_date]				DATETIME NULL,
		[payment_date]					DATETIME NULL,
		[Volume]						FLOAT NULL,
		[price]							FLOAT NULL,
		[fees]							FLOAT NULL,
		[currency]						INT NULL,
		[create_user]					VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]						DATETIME NULL DEFAULT GETDATE(),
		[update_user]					VARCHAR(50) NULL,
		[update_ts]						DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table source_deal_broker ALREADY EXISTS'
END
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_source_deal_broker]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_source_deal_broker]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_source_deal_broker]
ON [dbo].[source_deal_broker]
FOR UPDATE
AS
    UPDATE source_deal_broker
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM source_deal_broker t
      INNER JOIN DELETED u ON t.source_deal_header_id = u.source_deal_header_id
GO