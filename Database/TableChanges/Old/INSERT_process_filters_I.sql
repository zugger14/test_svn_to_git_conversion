
/*
	Author :  Vishwas Khanal
	Dated  : 29.Jan.2010
	Log Id : 1345
*/
INSERT INTO dbo.process_filters (filterID,tableName,colNameForValue,colNameForId,precedence) VALUES ('MiddleOffice','static_data_type','type_name','type_id',110)

INSERT INTO dbo.process_filters (filterID,tableName,colNameForValue,colNameForId,precedence) VALUES ('BackOffice','static_data_type','type_name','type_id',120)


IF EXISTS (SELECT 'x' FROM static_data_type WHERE TYPE_ID = 5651)
	SELECT 'Static data type 5651 already exists'
ELSE
	INSERT INTO static_data_type(type_id,type_name,internal,DESCRIPTION) SELECT 5651,'Deal SignOff',1,'Deal SignOff by Trader'


