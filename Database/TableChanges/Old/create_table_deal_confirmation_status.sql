IF OBJECT_ID(N'deal_confirmation_status', N'U') IS NOT NULL 
BEGIN
	 PRINT 'deal_confirmation_status table already exist.'
END
ELSE
BEGIN
	CREATE TABLE deal_confirmation_status(
		deal_confirmation_status_id INT IDENTITY(1,1),
		deal_id INT,
		status_id INT,
		create_user	VARCHAR(50),
		create_ts	DATETIME, 
		update_user	VARCHAR(50),
		update_ts	DATETIME
	)
	PRINT 'deal_confirmation_status table created.'
END