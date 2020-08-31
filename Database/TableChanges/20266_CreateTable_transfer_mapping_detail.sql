SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[transfer_mapping_detail]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[transfer_mapping_detail](
    	[transfer_mapping_detail_id]     INT IDENTITY(1, 1) NOT NULL,
    	[transfer_mapping_id]			 INT REFERENCES transfer_mapping(transfer_mapping_id) NOT NULL,
    	[counterparty_id]                INT NULL,
    	[contract_id]                    INT NULL,
    	[trader_id]                      INT NULL,
    	[sub_book]                       INT NULL,
    	[create_user]                    VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                      DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                    VARCHAR(50) NULL,
    	[update_ts]                      DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table transfer_mapping_detail EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_transfer_mapping_detail]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_transfer_mapping_detail]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_transfer_mapping_detail]
ON [dbo].[transfer_mapping_detail]
FOR UPDATE
AS
    UPDATE transfer_mapping_detail
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM transfer_mapping_detail t
      INNER JOIN DELETED u ON t.[transfer_mapping_detail_id] = u.[transfer_mapping_detail_id]
GO