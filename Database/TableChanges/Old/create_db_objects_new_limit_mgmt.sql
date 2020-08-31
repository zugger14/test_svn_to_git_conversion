/*
* db design for new limit mgmt
* sligal
* 11/22/2012
*/
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
/****** table limit_header ******/
IF OBJECT_ID(N'[dbo].[limit_header]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[limit_header]
    (
    [limit_id]			INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    [limit_name]		VARCHAR(100) NULL,
    [limit_for]			INT NULL,
    [trader_id]			INT NULL,
    [commodity]			INT NULL,
    [role]				INT NULL,
    [book_id]			VARCHAR(100) NULL,
    [counterparty_id]	INT NULL,
    [book1]				INT NULL,
    [book2]				INT NULL,
    [book3]				INT NULL,
    [book4]				INT NULL,
    [deal_type]			INT NULL,
    
    [create_user]		VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    [create_ts]			DATETIME NULL DEFAULT GETDATE(),
    [update_user]		VARCHAR(50) NULL,
    [update_ts]			DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table limit_header EXISTS'
END
 
GO

/* update trigger for table limit_header */
IF OBJECT_ID('[dbo].[TRGUPD_limit_header]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_limit_header]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_limit_header]
ON [dbo].[limit_header]
FOR UPDATE
AS
    UPDATE limit_header
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM limit_header lh
      INNER JOIN DELETED u ON lh.limit_id = u.limit_id
GO


/****** table maintain_limit ******/ 
IF OBJECT_ID(N'[dbo].[maintain_limit]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[maintain_limit]
    (
    [maintain_limit_id]     INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    [logical_description]	VARCHAR(500) NULL,
    [limit_id]				INT NULL,
    [limit_type]			INT NULL,
    [var_criteria_det_id]	INT NULL,
    [deal_type]				INT NULL,
    [curve_id]				INT NULL,
    [limit_value]			FLOAT NULL,
    [limit_uom]				VARCHAR(100) NULL,
    [limit_currency]		INT NULL,
    [tenor_month_from]		INT NULL,
    [tenor_month_to]		INT NULL,
    [tenor_granularity]		INT NULL,
    
    [create_user]    		VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    [create_ts]      		DATETIME NULL DEFAULT GETDATE(),
    [update_user]    		VARCHAR(50) NULL,
    [update_ts]      		DATETIME NULL
    
    CONSTRAINT fk_limit_id_maintain_limit_limit_header FOREIGN KEY (limit_id) REFERENCES limit_header(limit_id)
    )
END
ELSE
BEGIN
    PRINT 'Table table_name EXISTS'
END
 
GO

/* update trigger for table maintain_limit */
IF OBJECT_ID('[dbo].[TRGUPD_maintain_limit]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_maintain_limit]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_maintain_limit]
ON [dbo].[maintain_limit]
FOR UPDATE
AS
    UPDATE maintain_limit
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM maintain_limit ml
      INNER JOIN DELETED u ON ml.maintain_limit_id = u.maintain_limit_id
GO


/****** table limit_available ******/
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[limit_available]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[limit_available]
    (
    [limit_available_id]	INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    [limit_id]				INT NULL,
    [counterparty_id]		INT NULL,
    [effective_date]		DATETIME NULL,
    [limit_type]			INT NULL,
    [limit_available]		FLOAT NULL,
    [currency]				INT NULL,
    [comment]				VARCHAR(500) NULL,
    
    [create_user]    		VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    [create_ts]      		DATETIME NULL DEFAULT GETDATE(),
    [update_user]    		VARCHAR(50) NULL,
    [update_ts]      		DATETIME NULL
    
    CONSTRAINT fk_limit_id_limit_available_limit_header FOREIGN KEY (limit_id) REFERENCES limit_header(limit_id)
    )
END
ELSE
BEGIN
    PRINT 'Table limit_available EXISTS'
END
 
GO

/* update trigger for table limit_available */
IF OBJECT_ID('[dbo].[TRGUPD_limit_available]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_limit_available]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_limit_available]
ON [dbo].[limit_available]
FOR UPDATE
AS
    UPDATE limit_available
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM limit_available la
      INNER JOIN DELETED u ON la.limit_available_id = u.limit_available_id
GO