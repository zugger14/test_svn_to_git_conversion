---alter table source_deal_header add process_deal_status tinyint
if exists(select * from sys.columns where [name] ='process_deal_status' and object_name([object_id])='source_deal_header')
	alter table source_deal_header drop column process_deal_status 

go
--This column has been added in source deal detail table .
if exists(select * from sys.columns where [name] ='process_deal_status' and object_name([object_id])='source_deal_detail')
	alter table source_deal_detail drop column process_deal_status 
go

	alter table source_deal_detail add process_deal_status tinyint