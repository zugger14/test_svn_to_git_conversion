--SELECT  * FROM static_data_type WHERE  TYPE_ID = 5600
--SELECT  * FROM static_data_value WHERE  TYPE_ID = 5600 ORDER BY value_id

IF NOT EXISTS (SELECT 1 FROM deal_status_group dsg WHERE dsg.status_value_id = 5603) 
BEGIN 
	INSERT INTO deal_status_group (status_value_id, status) VALUES (5603, 'Official')
END

IF NOT EXISTS (SELECT 1 FROM deal_status_group dsg WHERE dsg.status_value_id = 5604) 
BEGIN 
	INSERT INTO deal_status_group (status_value_id, status) VALUES (5604, 'Official')
END

IF NOT EXISTS (SELECT 1 FROM deal_status_group dsg WHERE dsg.status_value_id = 5605) 
BEGIN 
	INSERT INTO deal_status_group (status_value_id, status) VALUES (5605, 'Official')
END

IF NOT EXISTS (SELECT 1 FROM deal_status_group dsg WHERE dsg.status_value_id = 5606) 
BEGIN 
	INSERT INTO deal_status_group (status_value_id, status) VALUES (5606, 'Official')
END

IF NOT EXISTS (SELECT 1 FROM deal_status_group dsg WHERE dsg.status_value_id = 5607) 
BEGIN 
	INSERT INTO deal_status_group (status_value_id, status) VALUES (5607, 'Official')
END

IF NOT EXISTS (SELECT 1 FROM deal_status_group dsg WHERE dsg.status_value_id = 5612) 
BEGIN 
	INSERT INTO deal_status_group (status_value_id, status) VALUES (5612, 'Official')
END

IF NOT EXISTS (SELECT 1 FROM deal_status_group dsg WHERE dsg.status_value_id = 5613) 
BEGIN 
	INSERT INTO deal_status_group (status_value_id, status) VALUES (5613, 'Official')
END

IF NOT EXISTS (SELECT 1 FROM deal_status_group dsg WHERE dsg.status_value_id = 5632) 
BEGIN 
	INSERT INTO deal_status_group (status_value_id, status) VALUES (5632, 'Official')
END

IF NOT EXISTS (SELECT 1 FROM deal_status_group dsg WHERE dsg.status_value_id = 5634) 
BEGIN 
	INSERT INTO deal_status_group (status_value_id, status) VALUES (5634, 'Official')
END




