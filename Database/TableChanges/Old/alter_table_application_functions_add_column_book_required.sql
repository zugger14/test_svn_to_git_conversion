IF COL_LENGTH('application_functions', 'book_required') IS NULL
BEGIN
    ALTER TABLE application_functions ADD book_required BIT NOT NULL DEFAULT 1
END