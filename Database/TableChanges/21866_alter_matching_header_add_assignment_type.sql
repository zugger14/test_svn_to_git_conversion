IF COL_LENGTH('matching_header', 'assignment_type') IS NULL
BEGIN
    ALTER TABLE matching_header ADD assignment_type INT;
END