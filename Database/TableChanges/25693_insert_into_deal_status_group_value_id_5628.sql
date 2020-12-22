IF NOT EXISTS (SELECT 1 FROM deal_status_group dsg WHERE dsg.status_value_id = 5628) 
BEGIN 
	INSERT INTO deal_status_group (status_value_id, status) VALUES (5628, 'Official')
END

