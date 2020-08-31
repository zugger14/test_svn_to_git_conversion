IF COL_LENGTH('explain_position', 'un_explain') IS NULL
BEGIN
    ALTER TABLE explain_position ADD un_explain NUMERIC(38,20)
END
GO