/*
* Alter table confirm_status START
*/
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.[COLUMNS] c WHERE c.TABLE_NAME = 'confirm_status' AND c.COLUMN_NAME = 'type' AND c.DATA_TYPE = 'INT')
BEGIN
	ALTER TABLE confirm_status
	ALTER COLUMN [type] CHAR(5)

	UPDATE confirm_status
	SET    [type] = 17200
	WHERE  TYPE = 'n'

	ALTER TABLE confirm_status
	ALTER COLUMN [type] INT
	
END

/*
* Alter table confirm_status END
*/

/*
* Alter table confirm_status_recent START
*/
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.[COLUMNS] c WHERE c.TABLE_NAME = 'confirm_status_recent' AND c.COLUMN_NAME = 'type' AND c.DATA_TYPE = 'INT')
BEGIN
	ALTER TABLE confirm_status_recent
	ALTER COLUMN [type] CHAR(5)

	UPDATE confirm_status_recent
	SET    [type] = 17200
	WHERE  TYPE = 'n'

	ALTER TABLE confirm_status_recent
	ALTER COLUMN [type] INT
END
/*
* Alter table confirm_status_recent END
*/