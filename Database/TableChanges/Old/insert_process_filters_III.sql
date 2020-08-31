
/*
Author : Vishwas Khanal
Dated  : 03.09.2010
Desc   : i. Type ID inserted for the import of Activity Data.
		 ii.Filter ID inserted for the import of Activity Data.
Project: Emission Demo
*/
INSERT INTO static_data_type (type_id,type_name,internal,description) select 13301,'Activity Data',1,'Activity Data'

INSERT INTO dbo.process_filters (filterID,tableName,colNameForValue,colNameForId,precedence) VALUES ('EMSImport','static_data_type','type_name','type_id',130)

