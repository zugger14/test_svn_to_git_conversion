SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[transportation_contract_parties]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[transportation_contract_parties] (
		[transportation_contract_parties_id]			INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		[contract_id]									INT REFERENCES contract_group(contract_id) NOT NULL,
		[party]      									INT REFERENCES source_counterparty(source_counterparty_id) NOT NULL,
		[type]  										INT REFERENCES static_data_value(value_id),
		[effective_date]  								DATETIME,
		[create_user]    								NVARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]      								DATETIME NULL DEFAULT GETDATE(),
		[update_user]    								NVARCHAR(50) NULL,
		[update_ts]      								DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table transportation_contract_parties EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_transportation_contract_parties]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_transportation_contract_parties]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_transportation_contract_parties]
ON [dbo].[transportation_contract_parties]
FOR UPDATE
AS
    UPDATE transportation_contract_parties
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM transportation_contract_parties t
    INNER JOIN DELETED u ON t.[transportation_contract_parties_id] = u.[transportation_contract_parties_id]
GO