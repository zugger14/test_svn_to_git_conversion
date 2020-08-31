

IF NOT EXISTS(SELECT 'X' FROM static_data_type where type_id=5800)
	INSERT INTO static_data_type(type_id,type_name,internal,description) values ('5800','Approve Hedge Relationship','1','Approve Hedge Relationship')

IF NOT EXISTS(SELECT 'X' FROM static_data_type where type_id=5900)
	INSERT INTO static_data_type(type_id,type_name,internal,description) values ('5900','Finalize Hedge Relationship','1','Finalize Hedge Relationship')
