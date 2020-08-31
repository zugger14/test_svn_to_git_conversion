/*
Author : Vishwas Khanal
Dated  : 02.17.2010
*/

IF NOT EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE column_name = 'source_id' AND table_name ='message_board')
ALTER TABLE message_board ADD source_id VARCHAR(100)