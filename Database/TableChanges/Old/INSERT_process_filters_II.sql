/*
Author : Vishwas Khanal
Dated : 02.11.2010
Desc : Used for Compliance Messaging System with Deal insertion and Updation.
Log Id : 1616
*/

INSERT INTO dbo.process_filters (filterID,tableName,colNameForValue,colNameForId,precedence) VALUES ('DealIU','static_data_type','type_name','type_id',130)


IF EXISTS (SELECT 'x' FROM static_data_type WHERE TYPE_ID = 5652)
	SELECT 'Static data type 5652 already exists'
ELSE
	INSERT INTO static_data_type(type_id,type_name,internal,DESCRIPTION) SELECT 5652,'Deal InsertionUpdation',1,'Deal inserted or updated by Trader'