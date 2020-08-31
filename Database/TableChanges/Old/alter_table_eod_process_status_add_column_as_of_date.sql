IF COL_LENGTH('eod_process_status', 'as_of_date') IS NULL
BEGIN
    ALTER TABLE [eod_process_status] ADD as_of_date DATETIME
END
GO