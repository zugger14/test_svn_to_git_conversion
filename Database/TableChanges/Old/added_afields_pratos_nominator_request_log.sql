
IF COL_LENGTH('pratos_nominator_request_log', 'create_user') IS NULL
BEGIN
    ALTER TABLE pratos_nominator_request_log ADD create_user VARCHAR(50) DEFAULT dbo.FNADBUser()
END
