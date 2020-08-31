/*
Author : Vishwas Khanal
Log Id : 1575
Desc : Used for compliance integration with snwa. 
	   With the column delActive we can have the control over the display of message in the message board.
	   Some message cant be deleted (e.g compliance) from message board and thus this flag will be updated to 'n'.
	   Message board made to show the messages only with the delete Active flag (delActive) flag as 'y'
*/
IF NOT EXISTS (SELECT 'x' FROM information_schema.columns WHERE table_name = 'message_board' AND column_name = 'delActive')
	ALTER TABLE message_board ADD delActive CHAR(1) DEFAULT('y')