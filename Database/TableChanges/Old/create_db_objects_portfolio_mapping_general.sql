/**
* universal portfolio mapping db objects
**/

/** table portfolio_mapping_source (master table) **/
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[portfolio_mapping_source]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[portfolio_mapping_source]
    (
    [portfolio_mapping_source_id]	INT IDENTITY(1, 1) PRIMARY KEY,
    [mapping_source_value_id]		INT REFERENCES dbo.static_data_value(value_id) NULL,
    [mapping_source_usage_id]		INT NULL,
    [portfolio_group_id]			INT REFERENCES dbo.maintain_portfolio_group(portfolio_group_id) NULL,
    [create_user]					VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    [create_ts]      				DATETIME NULL DEFAULT GETDATE(),
    [update_user]    				VARCHAR(50) NULL,
    [update_ts]      				DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table portfolio_mapping_source EXISTS'
END
 
GO

-- adding update trigger for above table
IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_portfolio_mapping_source]'))
    DROP TRIGGER [dbo].[TRGUPD_portfolio_mapping_source]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGUPD_portfolio_mapping_source]
ON [dbo].[portfolio_mapping_source]
FOR UPDATE
AS
BEGIN
    --this check is required to prevent recursive trigger
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE portfolio_mapping_source
        SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
        FROM portfolio_mapping_source pms
        INNER JOIN DELETED d ON d.portfolio_mapping_source_id = pms.portfolio_mapping_source_id
    END
END
GO

/** table mapping_portfolio_deal **/
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID (N'dbo.portfolio_mapping_deal', N'U') IS NULL
BEGIN
	CREATE TABLE dbo.portfolio_mapping_deal
	(
    [portfolio_mapping_deal_id]		INT IDENTITY(1, 1) PRIMARY KEY,
    [portfolio_mapping_source_id]	INT REFERENCES dbo.portfolio_mapping_source(portfolio_mapping_source_id) ON DELETE CASCADE,
    [deal_id]						INT NULL,
    [create_user]    				VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    [create_ts]      				DATETIME NULL DEFAULT GETDATE(),
    [update_user]    				VARCHAR(50) NULL,
    [update_ts]      				DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table portfolio_mapping_deal EXISTS'
END
GO

-- adding update trigger for above table
IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_portfolio_mapping_deal]'))
    DROP TRIGGER [dbo].[TRGUPD_portfolio_mapping_deal]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGUPD_portfolio_mapping_deal]
ON [dbo].[portfolio_mapping_deal]
FOR UPDATE
AS
BEGIN
    --this check is required to prevent recursive trigger
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE portfolio_mapping_deal
        SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
        FROM portfolio_mapping_deal pmd
        INNER JOIN DELETED d ON d.portfolio_mapping_deal_id = pmd.portfolio_mapping_deal_id
    END
END
GO

/** table portfolio_mapping_book **/
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID (N'dbo.portfolio_mapping_book', N'U') IS NULL
BEGIN
	CREATE TABLE dbo.portfolio_mapping_book
	(
    [portfolio_mapping_book_id]		INT IDENTITY(1, 1) PRIMARY KEY,
    [portfolio_mapping_source_id]	INT REFERENCES dbo.portfolio_mapping_source(portfolio_mapping_source_id) ON DELETE CASCADE,
    [book_name]						VARCHAR(500) NULL,
    [book_description]				VARCHAR(1000) NULL,
    [book_parameter]				VARCHAR(8000) NULL,
    [create_user]    				VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    [create_ts]      				DATETIME NULL DEFAULT GETDATE(),
    [update_user]    				VARCHAR(50) NULL,
    [update_ts]      				DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table portfolio_mapping_book EXISTS'
END
GO

-- adding update trigger for above table
IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_portfolio_mapping_book]'))
    DROP TRIGGER [dbo].[TRGUPD_portfolio_mapping_book]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGUPD_portfolio_mapping_book]
ON [dbo].[portfolio_mapping_book]
FOR UPDATE
AS
BEGIN
    --this check is required to prevent recursive trigger
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE portfolio_mapping_book
        SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
        FROM portfolio_mapping_book pmb
        INNER JOIN DELETED d ON d.portfolio_mapping_book_id = pmb.portfolio_mapping_book_id
    END
END
GO

/** table portfolio_mapping_other **/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[portfolio_mapping_other]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[portfolio_mapping_other]
    (
    [portfolio_mapping_other_id]	INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    [portfolio_mapping_source_id]	INT REFERENCES dbo.portfolio_mapping_source(portfolio_mapping_source_id) ON DELETE CASCADE,
    [counterparty]					INT NULL,
    [buy]							CHAR(1) NULL,
    [sell]							CHAR(1) NULL,
    [buy_index]						INT NULL,
    [buy_price]						NUMERIC(20, 10) NULL,
    [buy_currency]					INT NULL,
    [buy_volume]					NUMERIC(20, 10) NULL,
    [buy_uom]						INT NULL,
    [buy_term_start]				DATETIME NULL,
    [buy_term_end]					DATETIME NULL,
    [sell_index]					INT NULL,
    [sell_price]					NUMERIC(20, 10) NULL,
    [sell_currency]					INT NULL,
    [sell_volume]					NUMERIC(20, 10) NULL,
    [sell_uom]						INT NULL,
    [sell_term_start]				DATETIME NULL,
    [sell_term_end]					DATETIME NULL,
    [create_user]    				VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    [create_ts]      				DATETIME NULL DEFAULT GETDATE(),
    [update_user]    				VARCHAR(50) NULL,
    [update_ts]      				DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table portfolio_mapping_other EXISTS'
END

GO
-- adding update trigger for above table
IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_portfolio_mapping_other]'))
    DROP TRIGGER [dbo].[TRGUPD_portfolio_mapping_other]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGUPD_portfolio_mapping_other]
ON [dbo].[portfolio_mapping_other]
FOR UPDATE
AS
BEGIN
    --this check is required to prevent recursive trigger
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE portfolio_mapping_other
        SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
        FROM portfolio_mapping_other pmo
        INNER JOIN DELETED d ON d.portfolio_mapping_other_id = pmo.portfolio_mapping_other_id
    END
END
GO

