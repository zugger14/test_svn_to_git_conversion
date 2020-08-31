IF NOT EXISTS (SELECT 1 FROM deal_status_group dsg WHERE dsg.status_value_id = 5612) 
BEGIN 
	INSERT INTO deal_status_group (status_value_id, status) VALUES (5612, 'Official')
END

IF NOT EXISTS (SELECT 1 FROM deal_status_group dsg WHERE dsg.status_value_id = 5613) 
BEGIN
	INSERT INTO deal_status_group (status_value_id, status) VALUES (5613, 'Official')
END