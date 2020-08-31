SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[contract_component_mapping]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[contract_component_mapping]
    (
    	[contract_component_mapping_id]  INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    	[contract_component_id]          INT NOT NULL,
    	[deal_type_id]                   INT REFERENCES source_deal_type(source_deal_type_id) NULL,
    	[charge_type_id]                 INT NOT NULL,
    	[multiplier]                     FLOAT NULL,
    	[rounding]                       INT NULL,
    	[leg]                            INT NULL,
    	[create_user]                    VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                      DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                    VARCHAR(50) NULL,
    	[update_ts]                      DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table contract_component_mapping EXISTS'
END
 
GO


IF OBJECT_ID('[dbo].[TRGUPD_contract_component_mapping]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_contract_component_mapping]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_contract_component_mapping]
ON [dbo].[contract_component_mapping]
FOR UPDATE
AS
    UPDATE contract_component_mapping
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM contract_component_mapping t
      INNER JOIN DELETED u ON t.contract_component_id = u.contract_component_id
GO