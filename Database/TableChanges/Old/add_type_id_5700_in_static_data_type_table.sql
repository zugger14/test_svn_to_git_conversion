IF NOT EXISTS (SELECT 'x' FROM static_data_type WHERE type_id=5700)
BEGIN
	INSERT INTO static_data_type(type_id,type_name,internal,description) VALUES(5700, 'Deal Deletion',1,'Message to be sent on deletion of Deal')
END