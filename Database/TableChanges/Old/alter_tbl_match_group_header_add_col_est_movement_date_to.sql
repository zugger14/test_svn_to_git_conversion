IF COL_LENGTH('match_group_header', 'est_movement_date_to') IS NULL
BEGIN
    ALTER TABLE match_group_header ADD est_movement_date_to DATETIME
END
GO

