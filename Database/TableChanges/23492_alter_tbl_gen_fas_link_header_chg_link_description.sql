IF OBJECT_ID(N'gen_fas_link_header', N'U') IS NOT NULL AND COL_LENGTH('gen_fas_link_header', 'link_description') IS NOT NULL
BEGIN
	
    ALTER TABLE 
	/**
		Column 
		link_description: Changed link_description length
	*/
	gen_fas_link_header ALTER COLUMN link_description NVARCHAR(1000)
END
GO
 

 