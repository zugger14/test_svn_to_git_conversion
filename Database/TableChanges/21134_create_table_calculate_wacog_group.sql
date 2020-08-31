IF EXISTS(SELECT 1 FROM sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[calculate_wacog_group]') AND TYPE IN (N'U'))
BEGIN
    PRINT 'Table Already Exists'
END
ELSE
BEGIN
	CREATE TABLE [dbo].[calculate_wacog_group]
	(
		id INT IDENTITY(1, 1) PRIMARY KEY,
		wacog_group_id INT,
		as_of_date DATETIME,
		term DATETIME,
		wacog FLOAT,
		[create_user] VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
		[create_ts] DATETIME NULL DEFAULT GETDATE(),
		update_user VARCHAR(100),
		update_ts DATETIME,
		CONSTRAINT UC_calculate_wacoq_group UNIQUE (as_of_date, term, wacog)
	)
END

IF EXISTS (SELECT 1 FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_calculate_wacog_group]'))
    DROP TRIGGER [dbo].[TRGUPD_calculate_wacog_group]
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[TRGUPD_calculate_wacog_group]
ON [dbo].[calculate_wacog_group]
FOR UPDATE
AS
BEGIN
    -- used to prevent recursive trigger
     IF NOT UPDATE(update_ts)
    BEGIN
        UPDATE calculate_wacog_group
        SET update_user = dbo.FNADBUser(), 
			update_ts = GETDATE()
        FROM calculate_wacog_group p
        INNER JOIN DELETED d 
			ON d.id = p.id
    END
END
GO