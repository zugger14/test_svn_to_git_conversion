IF COL_LENGTH('matching_header_audit', 'assignment_type') IS NULL
BEGIN
    ALTER TABLE matching_header_audit ADD assignment_type INT;
END