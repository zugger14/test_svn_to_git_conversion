/** table portfolio_group_deal **/
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[portfolio_group_deal]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[portfolio_group_deal]
    (
    [portfolio_group_deal_id]	INT IDENTITY(1, 1) PRIMARY KEY,
    [portfolio_group_id]		INT REFERENCES dbo.maintain_portfolio_group(portfolio_group_id) ON DELETE CASCADE NULL,
    [deal_id]					INT NULL,
    [create_user]    			VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    [create_ts]      			DATETIME NULL DEFAULT GETDATE(),
    [update_user]    			VARCHAR(50) NULL,
    [update_ts]      			DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table portfolio_group_deal EXISTS'
END
 
GO
-- adding update trigger for above table
IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_portfolio_group_deal]'))
    DROP TRIGGER [dbo].[TRGUPD_portfolio_group_deal]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGUPD_portfolio_group_deal]
ON [dbo].[portfolio_group_deal]
FOR UPDATE
AS
BEGIN
    --this check is required to prevent recursive trigger
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE portfolio_group_deal
        SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
        FROM portfolio_group_deal pgd
        INNER JOIN DELETED d ON d.portfolio_group_deal_id = pgd.portfolio_group_deal_id
    END
END
GO

/** table portfolio_group_book **/
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[portfolio_group_book]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[portfolio_group_book]
    (
    [portfolio_group_book_id]	INT IDENTITY(1, 1) PRIMARY KEY,
    [portfolio_group_id]		INT REFERENCES dbo.maintain_portfolio_group(portfolio_group_id) ON DELETE CASCADE NULL,
    [book_name]					VARCHAR(500) NULL,
    [book_description]			VARCHAR(1000) NULL,
    [book_parameter]			VARCHAR(8000) NULL,
    [create_user]    			VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    [create_ts]      			DATETIME NULL DEFAULT GETDATE(),
    [update_user]    			VARCHAR(50) NULL,
    [update_ts]      			DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table portfolio_group_book EXISTS'
END
 
GO
-- adding update trigger for above table
IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_portfolio_group_book]'))
    DROP TRIGGER [dbo].[TRGUPD_portfolio_group_book]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGUPD_portfolio_group_book]
ON [dbo].[portfolio_group_book]
FOR UPDATE
AS
BEGIN
    --this check is required to prevent recursive trigger
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE portfolio_group_book
        SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
        FROM portfolio_group_book pgb
        INNER JOIN DELETED d ON d.portfolio_group_book_id = pgb.portfolio_group_book_id
    END
END
GO

/** table portfolio_group_other **/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO

--IF OBJECT_ID(N'[dbo].[portfolio_group_other]', N'U') IS NULL
--BEGIN
--    CREATE TABLE [dbo].[portfolio_group_other]
--    (
--    [portfolio_group_other_id]  INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
--    [portfolio_group_id]		INT REFERENCES dbo.maintain_portfolio_group(portfolio_group_id) ON DELETE CASCADE NULL,
--    [counterparty]				INT NULL,
--    [buy]						CHAR(1) NULL,
--    [sell]						CHAR(1) NULL,
--    [buy_index]					INT NULL,
--    [buy_price]					NUMERIC(20, 10) NULL,
--    [buy_volume]				NUMERIC(20, 10) NULL,
--    [buy_uom]					INT NULL,
--    [buy_term_start]			DATETIME NULL,
--    [buy_term_end]				DATETIME NULL,
--    [sell_index]				INT NULL,
--    [sell_price]				NUMERIC(20, 10) NULL,
--    [sell_volume]				NUMERIC(20, 10) NULL,
--    [sell_uom]					INT NULL,
--    [sell_term_start]			DATETIME NULL,
--    [sell_term_end]				DATETIME NULL,
--    [create_user]    			VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
--    [create_ts]      			DATETIME NULL DEFAULT GETDATE(),
--    [update_user]    			VARCHAR(50) NULL,
--    [update_ts]      			DATETIME NULL
--    )
--END
--ELSE
--BEGIN
--    PRINT 'Table portfolio_group_other EXISTS'
--END

--GO
---- adding update trigger for above table
--IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_portfolio_group_other]'))
--    DROP TRIGGER [dbo].[TRGUPD_portfolio_group_other]
--GO
 
--SET ANSI_NULLS ON
--GO
 
--SET QUOTED_IDENTIFIER ON
--GO
 
--CREATE TRIGGER [dbo].[TRGUPD_portfolio_group_other]
--ON [dbo].[portfolio_group_other]
--FOR UPDATE
--AS
--BEGIN
--    --this check is required to prevent recursive trigger
--    IF NOT UPDATE(create_ts)
--    BEGIN
--        UPDATE portfolio_group_other
--        SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
--        FROM portfolio_group_other pgo
--        INNER JOIN DELETED d ON d.portfolio_group_other_id = pgo.portfolio_group_other_id
--    END
--END
--GO