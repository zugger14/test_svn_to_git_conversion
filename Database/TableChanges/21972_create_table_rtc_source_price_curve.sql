SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[rtc_source_price_curve]', N'U') IS NULL
BEGIN
    CREATE TABLE [rtc_source_price_curve] (
		[rtc_curve_id]			INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		[rtc_curve]				INT NOT NULL,
		[rtc_curve_def_id]		INT NULL,
		[create_user]			VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]				DATETIME NULL DEFAULT GETDATE(),
		[update_user]			VARCHAR(50) NULL,
		[update_ts]				DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table [rtc_source_price_curve] EXISTS'
END

IF NOT EXISTS (
	SELECT 1
	FROM sys.foreign_keys
	WHERE object_id = OBJECT_ID(N'[dbo].[FK_rtc_source_price_curve_rtc_curve_def_id]')
		AND parent_object_id = OBJECT_ID(N'[dbo].[rtc_source_price_curve]')
)
BEGIN
	ALTER TABLE [dbo].[rtc_source_price_curve]
	WITH NOCHECK ADD CONSTRAINT [FK_rtc_source_price_curve_rtc_curve_def_id]
	FOREIGN KEY([rtc_curve_def_id])
	REFERENCES [dbo].[source_price_curve_def] ([source_curve_def_id])
END

GO

-- Unique Key
IF NOT EXISTS(
	SELECT 1
	FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
	INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
		AND tc.Constraint_name = ccu.Constraint_name
		AND tc.CONSTRAINT_TYPE = 'UNIQUE'
		AND tc.Table_Name = 'rtc_source_price_curve'
		AND ccu.CONSTRAINT_NAME = 'UC_rtc_source_price_curve_rtc_curve_rtc_curve_def_id'
)
BEGIN
	ALTER TABLE [dbo].[rtc_source_price_curve] WITH NOCHECK
	ADD CONSTRAINT UC_rtc_source_price_curve_rtc_curve_rtc_curve_def_id 
	UNIQUE (rtc_curve, rtc_curve_def_id)

	PRINT 'Constraint UC_rtc_source_price_curve_rtc_curve_rtc_curve_def_id added.'
END

GO

--Update Trigger
IF EXISTS (SELECT 1 FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_rtc_source_price_curve]'))
BEGIN
	DROP TRIGGER [dbo].[TRGUPD_rtc_source_price_curve]
END
GO

CREATE TRIGGER [dbo].[TRGUPD_rtc_source_price_curve]
ON [dbo].[rtc_source_price_curve]
FOR UPDATE
AS
BEGIN
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE [dbo].[rtc_source_price_curve]
        SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
        FROM [dbo].[rtc_source_price_curve] fr
        INNER JOIN DELETED d ON d.rtc_curve_id = fr.rtc_curve_id
    END
END

GO