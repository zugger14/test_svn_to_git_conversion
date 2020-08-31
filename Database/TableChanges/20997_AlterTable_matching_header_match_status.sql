IF COL_LENGTH('matching_header', 'match_status') IS NULL
BEGIN
    ALTER TABLE matching_header ADD match_status INT
END
GO