IF COL_LENGTH('rec_generator','fas_sub_book_id') IS NULL
BEGIN
	ALTER TABLE rec_generator
	ADD fas_sub_book_id INT
END