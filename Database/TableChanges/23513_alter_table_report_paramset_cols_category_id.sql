IF COL_LENGTH ('report_paramset', 'category_id') IS NULL
BEGIN
	
	ALTER TABLE 
	/**
        Column
        category_id : category_id
    */
	report_paramset ADD category_id INT 
END
