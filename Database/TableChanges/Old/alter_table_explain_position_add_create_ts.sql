IF COL_LENGTH('explain_position', 'create_ts') IS NULL
BEGIN
	ALTER TABLE explain_position ADD create_ts DATETIME
	PRINT 'Column explain_position.create_ts added.'
END
ELSE
BEGIN
	PRINT 'Column explain_position.create_ts already exists.'
END
GO 


IF COL_LENGTH('explain_position', 'create_user') IS NULL
BEGIN
	ALTER TABLE explain_position ADD create_user varchar(30)
	PRINT 'Column explain_position.create_user added.'
END
ELSE
BEGIN
	PRINT 'Column explain_position.create_user already exists.'
END
GO 


IF COL_LENGTH('explain_mtm', 'create_ts') IS NULL
BEGIN
	ALTER TABLE explain_mtm ADD create_ts DATETIME
	PRINT 'Column explain_mtm.create_ts added.'
END
ELSE
BEGIN
	PRINT 'Column explain_mtm.create_ts already exists.'
END
GO 


IF COL_LENGTH('explain_mtm', 'create_user') IS NULL
BEGIN
	ALTER TABLE explain_mtm ADD create_user varchar(30)
	PRINT 'Column explain_mtm.create_user added.'
END
ELSE
BEGIN
	PRINT 'Column explain_mtm.create_user already exists.'
END
GO 
