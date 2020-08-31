IF OBJECT_ID(N'calculate_wacog_group', N'U') IS NOT NULL AND COL_LENGTH('calculate_wacog_group', 'delivery_month') IS NULL
BEGIN
    ALTER TABLE 
	/**
		Columns
		delivery_month : Delivery Month
	*/
		calculate_wacog_group ADD delivery_month DATE
END
GO