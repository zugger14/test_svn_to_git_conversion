IF COL_LENGTH('rec_generator', 'show_detail') IS NULL
BEGIN
	ALTER TABLE rec_generator
	ADD show_detail CHAR(1)
END

GO