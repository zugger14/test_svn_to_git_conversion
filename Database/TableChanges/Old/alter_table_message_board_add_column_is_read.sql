IF COL_LENGTH('message_board', 'is_read') IS NULL
BEGIN
    ALTER TABLE message_board ADD is_read BIT NOT NULL DEFAULT 0
END