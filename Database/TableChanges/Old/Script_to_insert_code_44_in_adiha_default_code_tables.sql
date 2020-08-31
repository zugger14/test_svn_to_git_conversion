--Author: Santosh Gupta
--Dated: January 24 2012
--Issue against: 5784
--Purpose: Define a new configuration: "Allow to Edit Alert email Id for DBA Maintenance".
--Replace <TRM_TEMPDB_EMAIL_LIST> with the Email ID of user/s. If there are more than 1 user then it should be seperated by ;
--adding in Maintain Config 
DELETE adiha_default_codes_values WHERE default_code_id = 44
DELETE adiha_default_codes_values_possible WHERE default_code_id = 44
DELETE adiha_default_codes_params WHERE default_code_id = 44
DELETE adiha_default_codes WHERE default_code_id = 44
INSERT into adiha_default_codes VALUES(44, 'DBA_ALERT_EMAIL_ID', 'Allow to Edit Alert email Id for DBA Maintenance', 'Allow to Edit Alert email Id for DBA Maintenance', 1)
INSERT into adiha_default_codes_params VALUES(1, 44, '<TRM_TEMPDB_EMAIL_LIST>', 3, NULL, 'h')
INSERT into adiha_default_codes_values_possible VALUES(44, 0, '<TRM_TEMPDB_EMAIL_LIST>')
--INSERT into adiha_default_codes_values_possible VALUES(33, 1, 'Allow to edit locked links by default')
INSERT into adiha_default_codes_values VALUES(1, 44, 1, 0, NULL)
GO

