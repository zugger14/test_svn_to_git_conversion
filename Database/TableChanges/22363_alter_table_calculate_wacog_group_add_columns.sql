IF OBJECT_ID(N'calculate_wacog_group', N'U') IS NOT NULL AND COL_LENGTH('calculate_wacog_group', 'jurisdiction') IS NULL
BEGIN
    ALTER TABLE 
	/**
		Columns
		jurisdiction : Jurisdiction
	*/
		calculate_wacog_group ADD jurisdiction INT
END
GO
IF OBJECT_ID(N'calculate_wacog_group', N'U') IS NOT NULL AND COL_LENGTH('calculate_wacog_group', 'tier') IS NULL
BEGIN
    ALTER TABLE 
	/**
		Columns
		tier : Tier
	*/
		calculate_wacog_group ADD tier INT
END
GO
IF OBJECT_ID(N'calculate_wacog_group', N'U') IS NOT NULL AND COL_LENGTH('calculate_wacog_group', 'default_jurisdiction') IS NULL
BEGIN
    ALTER TABLE 
	/**
		Columns
		default_jurisdiction : Default Jurisdiction
	*/
		calculate_wacog_group ADD default_jurisdiction INT
END
GO
IF OBJECT_ID(N'calculate_wacog_group', N'U') IS NOT NULL AND COL_LENGTH('calculate_wacog_group', 'default_tier') IS NULL
BEGIN
    ALTER TABLE 
	/**
		Columns
		default_tier : Default Tier
	*/
		calculate_wacog_group ADD default_tier INT
END
GO
IF OBJECT_ID(N'calculate_wacog_group', N'U') IS NOT NULL AND COL_LENGTH('calculate_wacog_group', 'vintage_year') IS NULL
BEGIN
    ALTER TABLE 
	/**
		Columns
		vintage_year : Vintage Year
	*/
		calculate_wacog_group ADD vintage_year INT
END
GO



