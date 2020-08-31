IF COL_LENGTH('message_board', 'job_name') IS NOT NULL
BEGIN
    ALTER TABLE message_board ALTER COLUMN job_name NVARCHAR(200) NULL
END
GO

IF COL_LENGTH('message_board_audit', 'job_name') IS NOT NULL
BEGIN
    ALTER TABLE message_board_audit ALTER COLUMN job_name NVARCHAR(200) NULL
END
GO