SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[storage_contract_rank]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[storage_contract_rank]
    (
    [storage_contract_rank_id]		INT IDENTITY(1, 1) PRIMARY KEY,
	[contract_id]							INT REFERENCES contract_group(contract_id) NOT NULL,
	[rank_id]								INT REFERENCES [dbo].[static_data_value] (value_id),
    [effective_date]						DATETIME,
    [create_user]							VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    [create_ts]								DATETIME NULL DEFAULT GETDATE(),
    [update_user]							VARCHAR(50) NULL,
    [update_ts]								DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table storage_contract_rank EXISTS'
END
 
GO


SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_storage_contract_rank]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_storage_contract_rank]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_storage_contract_rank]
ON [dbo].[storage_contract_rank]
FOR UPDATE
AS
    UPDATE storage_contract_rank
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM storage_contract_rank t
    INNER JOIN DELETED u ON t.[storage_contract_rank_id] = u.[storage_contract_rank_id]
GO