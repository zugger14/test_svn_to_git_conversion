SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[deal_fields_mapping_contracts]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[deal_fields_mapping_contracts](
    	[deal_fields_mapping_contracts_id] INT IDENTITY(1, 1) NOT NULL,
    	[deal_fields_mapping_id]     INT REFERENCES deal_fields_mapping(deal_fields_mapping_id) NULL,
    	[contract_id]                INT REFERENCES contract_group(contract_id) NULL,
    	[create_user]                VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                  DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                VARCHAR(50) NULL,
    	[update_ts]                  DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table deal_fields_mapping_contracts EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_deal_fields_mapping_contracts]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_deal_fields_mapping_contracts]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_deal_fields_mapping_contracts]
ON [dbo].[deal_fields_mapping_contracts]
FOR UPDATE
AS
    UPDATE deal_fields_mapping_contracts
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM deal_fields_mapping_contracts t
      INNER JOIN DELETED u ON t.[deal_fields_mapping_contracts_id] = u.[deal_fields_mapping_contracts_id]
GO