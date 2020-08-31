IF EXISTS (SELECT 1 FROM sysindexes WHERE name = 'IX_user_defined_deal_fields_template') 
DROP INDEX user_defined_deal_fields_template.IX_user_defined_deal_fields_template   

CREATE INDEX IX_user_defined_deal_fields_template
ON user_defined_deal_fields_template (template_id,field_id,leg)     