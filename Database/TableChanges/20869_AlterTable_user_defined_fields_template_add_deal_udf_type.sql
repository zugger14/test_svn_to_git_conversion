IF COL_LENGTH('user_defined_fields_template', 'deal_udf_type') IS NULL
BEGIN
    ALTER TABLE user_defined_fields_template ADD deal_udf_type CHAR(1)
END
GO

IF COL_LENGTH('user_defined_deal_fields_template_main', 'deal_udf_type') IS NULL
BEGIN
    ALTER TABLE user_defined_deal_fields_template_main ADD deal_udf_type CHAR(1)
END
GO
