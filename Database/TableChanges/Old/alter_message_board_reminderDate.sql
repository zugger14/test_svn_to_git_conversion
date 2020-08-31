/*
	By	  : Vishwas Khanal
	Dated : 10-Aug-2009
	Desc  : User login name when given long generated SQL 'Truncation' error. Changed the column width from 50 to 8000
*/

ALTER TABLE message_board ALTER COLUMN reminderDate VARCHAR(8000)