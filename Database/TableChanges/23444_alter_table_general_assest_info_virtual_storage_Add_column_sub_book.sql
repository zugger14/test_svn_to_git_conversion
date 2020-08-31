IF COL_LENGTH('general_assest_info_virtual_storage ', 'sub_book') IS NULL
BEGIN
	ALTER TABLE 
	/**
		Columns
		sub_book : Sub Book
	*/
	general_assest_info_virtual_storage ADD sub_book INT
END
GO