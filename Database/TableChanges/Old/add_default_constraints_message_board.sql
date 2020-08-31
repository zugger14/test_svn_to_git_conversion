IF NOT EXISTS(SELECT 1
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_SCHEMA = 'dbo'
                      AND TABLE_NAME = 'message_board'
                      AND COLUMN_NAME = 'create_ts'
                      AND COLUMN_DEFAULT IS NOT NULL)
BEGIN
    ALTER TABLE dbo.message_board
    ADD CONSTRAINT DF_message_board_create_ts DEFAULT GETDATE() FOR create_ts
    , CONSTRAINT DF_message_board_create_user DEFAULT dbo.FNADBUser() FOR create_user
END
