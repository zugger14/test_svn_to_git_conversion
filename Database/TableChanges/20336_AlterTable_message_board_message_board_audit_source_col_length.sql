IF COL_LENGTH('message_board', 'source') IS NOT NULL
BEGIN
    ALTER TABLE message_board ALTER COLUMN [source] VARCHAR(250)
END

IF COL_LENGTH('message_board_audit', 'source') IS NOT NULL
BEGIN
    ALTER TABLE message_board_audit ALTER COLUMN [source] VARCHAR(250)
END