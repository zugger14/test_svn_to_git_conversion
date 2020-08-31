IF OBJECT_ID(N'wacog_group', N'U') IS NOT NULL AND COL_LENGTH('wacog_group', 'enable_environmental') IS NULL
BEGIN
    ALTER TABLE 
	/**
		Columns
		enable_environmental : Specifies whether environmental is enabled
	*/
		wacog_group ADD enable_environmental CHAR(1)
END
GO