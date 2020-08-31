IF COL_LENGTH('counterpartyt_netting_stmt_status', 'status_id') IS NOT NULL
BEGIN
    ALTER TABLE counterpartyt_netting_stmt_status ALTER COLUMN status_id INT NULL
END
GO