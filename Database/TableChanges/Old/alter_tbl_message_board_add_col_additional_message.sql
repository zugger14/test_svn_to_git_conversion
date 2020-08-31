IF COL_LENGTH('message_board', 'additional_message') IS NULL
BEGIN
    ALTER TABLE message_board ADD additional_message VARCHAR(5000)
END
GO