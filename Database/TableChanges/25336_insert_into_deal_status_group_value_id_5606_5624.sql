IF NOT EXISTS (SELECT 1 FROM deal_status_group where status_value_id = 5606)
BEGIN
	INSERT INTO deal_status_group([status_value_id], [status])
	SELECT 5606, 'Official'
	PRINT 'status_value_id : ''5606'' added.'
END
ELSE
	PRINT 'status_value_id : ''5606'' already exists.'


IF NOT EXISTS (SELECT 1 FROM deal_status_group where status_value_id = 5624)
BEGIN
	INSERT INTO deal_status_group([status_value_id], [status])
	SELECT 5624, 'Official'
	PRINT 'status_value_id : ''5624'' added.'
END
ELSE
	PRINT 'status_value_id : ''5624'' already exists.'