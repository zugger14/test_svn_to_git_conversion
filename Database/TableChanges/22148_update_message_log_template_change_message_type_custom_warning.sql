/*
	#	Updated message_type as 'Invalid Data' from 'Data Error'. Because, if the message type is 'Data Error' then the message board shows the 'Custom Warning' as 'Error'.
*/

UPDATE message_log_template 
SET message_type = 'Invalid Data'
WHERE message_number = 10020

GO