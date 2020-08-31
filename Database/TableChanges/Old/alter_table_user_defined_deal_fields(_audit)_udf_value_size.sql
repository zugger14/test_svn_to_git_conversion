

ALTER TABLE user_defined_deal_fields
ALTER COLUMN udf_value VARCHAR(8000)  NULL
GO
ALTER TABLE user_defined_deal_fields_audit
ALTER COLUMN udf_value VARCHAR(8000)  NULL
GO