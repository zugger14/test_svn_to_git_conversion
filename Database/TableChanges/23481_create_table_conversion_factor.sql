--create table conversion_factor
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



IF OBJECT_ID(N'[dbo].[conversion_factor]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[conversion_factor]
	(
	id			            INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	conversion_value_id		int NOT NULL ,
	effective_date			DATETIME,
	from_uom				INT NOT NULL, 
    to_uom                  INT NOT NULL,
	factor                  FLOAT NULL,
    create_user				NVARCHAR(50) NOT NULL  DEFAULT dbo.FNADBUser(),
	create_ts				DATETIME  DEFAULT GETDATE(),
    [update_user]			NVARCHAR(50) NULL,
    [update_ts]				DATETIME NULL
	)
END
ELSE
BEGIN 
	PRINT 'Table conversion_factor EXISTS'
END
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGUPD_conversion_factor]'))
	DROP TRIGGER [dbo].[TRGUPD_conversion_factor]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER dbo.TRGUPD_conversion_factor
   ON  dbo.conversion_factor
   AFTER UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
    UPDATE dbo.conversion_factor
	SET update_user = dbo.FNADBUser(), 
    update_ts = GETDATE()

END
GO
