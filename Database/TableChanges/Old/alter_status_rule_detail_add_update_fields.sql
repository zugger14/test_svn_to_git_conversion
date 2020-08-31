IF COL_LENGTH('status_rule_detail','update_fields') IS NULL 
ALTER TABLE status_rule_detail ADD update_fields VARCHAR(8000)

IF COL_LENGTH('status_rule_detail','update_fields_detail') IS NULL 
ALTER TABLE status_rule_detail ADD update_fields_detail VARCHAR(8000)