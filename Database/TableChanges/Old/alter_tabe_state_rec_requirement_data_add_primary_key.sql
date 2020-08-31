--TRUNCATE TABLE dbo.state_rec_requirement_detail
--TRUNCATE TABLE dbo.state_rec_requirement_data

--TRUNCATE TABLE dbo.state_rec_requirement_data fails due to a FK constraint used by state_rec_requirement_detail in old schema. 
--Since this is table with few data, delete won't hamper.
DELETE FROM dbo.state_rec_requirement_detail
DELETE FROM dbo.state_rec_requirement_data

-- Drop Foreign Key of dependent table
IF EXISTS ( SELECT 1 
			FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
			WHERE CONSTRAINT_TYPE = 'Foreign KEY' 
			AND TABLE_NAME = 'state_rec_requirement_detail' 
			AND TABLE_SCHEMA ='dbo'
			AND CONSTRAINT_NAME = 'FK_state_rec_requirement_detail' )
BEGIN
   ALTER TABLE dbo.state_rec_requirement_detail DROP CONSTRAINT [FK_state_rec_requirement_detail]
END

-- Drop Primary Key of main table
IF EXISTS (SELECT 1 
			FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
			WHERE CONSTRAINT_TYPE = 'PRIMARY KEY' 
			AND TABLE_NAME = 'state_rec_requirement_data' 
			AND TABLE_SCHEMA ='dbo')
BEGIN
    DECLARE @validation VARCHAR(100)
    DECLARE @del_sql VARCHAR(100)
    
	SELECT @validation = CONSTRAINT_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
	WHERE CONSTRAINT_TYPE = 'PRIMARY KEY' 
	AND TABLE_NAME = 'state_rec_requirement_data' 
	AND TABLE_SCHEMA ='dbo'
	
	SET @del_sql = 'ALTER TABLE dbo.state_rec_requirement_data DROP CONSTRAINT [' + @validation + ']'
	EXEC(@del_sql)	
END

IF EXISTS(SElECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'state_rec_requirement_data' AND column_name = 'state_rec_requirement_data_id')
BEGIN
	ALTER TABLE dbo.state_rec_requirement_data DROP COLUMN state_rec_requirement_data_id 
	ALTER TABLE state_rec_requirement_data ADD state_rec_requirement_data_id INT IDENTITY(1, 1) NOT NULL 
END
ELSE IF NOT EXISTS (SElECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'state_rec_requirement_data' AND column_name = 'state_rec_requirement_data_id')
BEGIN
	ALTER TABLE state_rec_requirement_data ADD state_rec_requirement_data_id INT IDENTITY(1, 1) NOT NULL 
END

-- Add Primary Key Constraint in state_rec_requirement_data_id column
 IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_TYPE = 'PRIMARY KEY' AND TABLE_NAME = 'state_rec_requirement_data' AND  TABLE_SCHEMA ='dbo' )
BEGIN
	ALTER TABLE [state_rec_requirement_data] ADD CONSTRAINT [PK_state_rec_requirement_data] PRIMARY KEY (state_rec_requirement_data_id) 
END