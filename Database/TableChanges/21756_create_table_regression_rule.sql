SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[regression_rule]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[regression_rule]
    (
    	[regression_rule_id]	INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    	[regression_group]      INT,
    	[rule_name]             VARCHAR(200),
    	[description]           VARCHAR(200),
    	[paramset_hash]			VARCHAR(50),
    	[filter]				VARCHAR(MAX),
    	[create_user]			VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]				DATETIME NULL DEFAULT GETDATE(),
    	[update_user]			VARCHAR(50) NULL,
    	[update_ts]				DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table regression_rule EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_regression_rule]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_regression_rule]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_regression_rule]
ON [dbo].[regression_rule]
FOR UPDATE
AS
	UPDATE regression_rule
	SET    update_user     = dbo.FNADBUser(),
	       update_ts       = GETDATE()
	FROM   regression_rule t
	       INNER JOIN DELETED u
	            ON  t.[regression_rule_id] = u.[regression_rule_id]
GO