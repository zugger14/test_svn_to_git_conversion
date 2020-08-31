IF COL_LENGTH('deal_detail_hour', 'period') IS NULL
BEGIN
    ALTER TABLE deal_detail_hour ADD period INT
END
GO
