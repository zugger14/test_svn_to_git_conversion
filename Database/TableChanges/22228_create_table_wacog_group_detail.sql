IF EXISTS(SELECT 1 FROM sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[wacog_group_detail]') AND TYPE IN (N'U'))
BEGIN
    PRINT 'Table Already Exists'
END
ELSE
BEGIN
	CREATE TABLE [dbo].[wacog_group_detail]
	(
		wacog_group_detail_id INT IDENTITY(1, 1) PRIMARY KEY,
		wacog_group_id INT REFERENCES [dbo].[wacog_group](wacog_group_id) NOT NULL,
		template_id INT,
		source_deal_type_id INT,
		charge_type_id INT,
		leg INT,
		create_user VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
		create_ts DATETIME NULL DEFAULT GETDATE(),
		update_user VARCHAR(100),
		update_ts DATETIME
	)
END

IF EXISTS (SELECT 1 FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_wacog_group_detail]'))
    DROP TRIGGER [dbo].[TRGUPD_wacog_group_detail]
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[TRGUPD_wacog_group_detail]
ON [dbo].[wacog_group_detail]
FOR UPDATE
AS
BEGIN
    -- used to prevent recursive trigger
     IF NOT UPDATE(update_ts)
    BEGIN
        UPDATE wacog_group_detail
        SET update_user = dbo.FNADBUser(), 
			update_ts = GETDATE()
        FROM wacog_group_detail p
        INNER JOIN DELETED d 
			ON d.wacog_group_detail_id = p.wacog_group_detail_id
    END
END
GO