IF COL_LENGTH('deal_detail_hour_arch1', 'file_name') IS NULL
BEGIN
    ALTER TABLE deal_detail_hour_arch1 ADD [file_name] VARCHAR(200)
END
GO