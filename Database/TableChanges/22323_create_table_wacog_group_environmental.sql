IF OBJECT_ID(N'dbo.wacog_group_environmental', N'U') IS NULL 
BEGIN
    CREATE TABLE dbo.wacog_group_environmental (
	/**
		Stores WACOG Group Environmental data

		Columns
		wacog_group_environmental_id: "Specifies Primary Key"
		wacog_group_id: "Specifies reference to wacog_group_id column from wacog_group table"
		jurisdiction: "Specifies Jurisdiction ID"
		tier: "Tier ID"
		default_jurisdiction: "Default Jurisdiction ID"
		default_tier: "Default Tier ID"
		vintage_year: "Vintage Year"
		create_user: "Specifies the username who creates the column"
		create_ts: "Specifies the date when column was created"
		update_user: "Specifies the username who updated the column"
		update_ts: "Specifies the date when column was updated
	*/

		wacog_group_environmental_id	INT IDENTITY(1, 1) PRIMARY KEY
		, wacog_group_id				INT
		, jurisdiction					INT
		, tier							INT
		, default_jurisdiction			INT
		, default_tier					INT
		, vintage_year					INT
		, create_user					VARCHAR(50)  DEFAULT dbo.FNADBUser()
		, create_ts						DATETIME  DEFAULT GETDATE()
		, update_user					VARCHAR(50)
		, update_ts						DATETIME 
		, CONSTRAINT FK_wacog_group_id FOREIGN KEY (wacog_group_id) REFERENCES wacog_group(wacog_group_id) ON DELETE CASCADE
    )
END
ELSE
BEGIN
    PRINT 'Table wacog_group_environmental EXISTS'
END
 
GO
IF  EXISTS (SELECT 1 FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'dbo.TRG_wacog_group_environmental'))
    DROP TRIGGER dbo.TRG_wacog_group_environmental
GO

CREATE TRIGGER dbo.TRG_wacog_group_environmental
ON dbo.wacog_group_environmental
FOR UPDATE
AS
BEGIN
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE wacog_group_environmental
        SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
        FROM wacog_group_environmental  wge
        INNER JOIN DELETED d 
			ON d.wacog_group_environmental_id =  wge.wacog_group_environmental_id
    END
END
GO
