IF COL_LENGTH('user_application_log', 'product_category') IS NULL
BEGIN
    ALTER TABLE user_application_log ADD product_category INT 
END
GO