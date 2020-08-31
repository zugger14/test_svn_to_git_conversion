
IF COL_LENGTH('interest_expense', '[update_user]') IS NULL
BEGIN
    ALTER TABLE interest_expense ADD [update_user] VARCHAR(50) NULL
END

IF COL_LENGTH('interest_expense', 'update_ts') IS NULL
BEGIN
    ALTER TABLE interest_expense ADD [update_ts] DATETIME NULL
END

IF COL_LENGTH('interest_expense', 'interest_expenses_id') IS NULL
BEGIN
    ALTER TABLE interest_expense ADD interest_expenses_id INT IDENTITY(1,1)
END
GO
