IF COL_LENGTH(N'[dbo].[workflow_event_message]', N'automatic_proceed') IS NULL
BEGIN
    ALTER TABLE [dbo].[workflow_event_message]
    ADD automatic_proceed char(1) NULL
    PRINT 'Column ''workflow_event_message'' added on table ''[dbo].[automatic_proceed]''.'
END
ELSE
    PRINT 'Column ''workflow_event_message'' on table ''[dbo].[automatic_proceed]'' already exists.'
GO