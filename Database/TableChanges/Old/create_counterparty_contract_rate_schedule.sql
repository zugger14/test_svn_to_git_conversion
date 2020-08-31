SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[counterparty_contract_rate_schedule]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[counterparty_contract_rate_schedule]
    (
    [counterparty_contract_rate_schedule_id]            INT IDENTITY(1, 1) NOT NULL,
    [counterparty_id]      								INT REFERENCES source_counterparty(source_counterparty_id) NOT NULL,
    [contract_id]  										INT REFERENCES contract_group(contract_id) NOT NULL,
    [rate_schedule_id]									INT NOT NULL,
    [create_user]    									VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    [create_ts]      									DATETIME NULL DEFAULT GETDATE(),
    [update_user]    									VARCHAR(50) NULL,
    [update_ts]      									DATETIME NULL,
    CONSTRAINT [IX_counterparty_contract]				UNIQUE NONCLUSTERED([counterparty_id] ASC, [contract_id] ASC)
    WITH (
        PAD_INDEX = OFF,
        STATISTICS_NORECOMPUTE = OFF,
        IGNORE_DUP_KEY = OFF,
        ALLOW_ROW_LOCKS = ON,
        ALLOW_PAGE_LOCKS = ON,
        FILLFACTOR = 90
    ) ON [PRIMARY]
    
    )
END
ELSE
BEGIN
    PRINT 'Table counterparty_contract_rate_schedule already exists.'
END
 
GO