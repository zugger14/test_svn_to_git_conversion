
SET IDENTITY_INSERT external_source_import ON

IF NOT EXISTS (SELECT 'x' FROM   external_source_import WHERE  source_system_id = 2 AND data_type_id = 4040)
BEGIN
    INSERT INTO external_source_import
      (
        esi_id,
        source_system_id,
        data_type_id,
        create_ts,
        create_user
      )
    VALUES
      (
        23,
        2,
        4040,
        GETDATE(),
        dbo.FNADBUser()
      )
    PRINT 'Value INSERTED in table external_source_import'
END
ELSE
BEGIN
	PRINT 'Already Exists'	
END

SET IDENTITY_INSERT external_source_import OFF
