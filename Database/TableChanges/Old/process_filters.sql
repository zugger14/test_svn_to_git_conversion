/*
Author : Vishwas Khanal
Dated : 04.07.2010
Desc : Used for Compliance Messaging System for import of 
Log Id : 2142
*/
IF NOT EXISTS(SELECT 'x' FROM static_data_type WHERE TYPE_ID = 13600)
INSERT INTO static_data_type (type_id,type_name,internal,description) select 13600,'Hourly Data Import',1,'Message to be sent on import of the Hourly Data.'

IF NOT EXISTS(SELECT 'X' FROM process_filters WHERE filterID = 'HourlyDataImport')
INSERT INTO dbo.process_filters (filterID,tableName,colNameForValue,colNameForId,precedence) VALUES ('HourlyDataImport','static_data_type','type_name','type_id',120)


