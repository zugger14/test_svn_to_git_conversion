IF OBJECT_ID(N'message_board', N'U') IS NOT NULL AND COL_LENGTH('message_board', 'process_id') IS NOT NULL
BEGIN
    ALTER TABLE message_board ALTER COLUMN process_id VARCHAR(100)
END
GO