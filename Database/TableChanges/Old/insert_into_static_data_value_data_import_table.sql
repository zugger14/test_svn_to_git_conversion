
IF NOT EXISTS(SELECT 'x' FROM static_data_value WHERE value_id=4028 or value_id=4029)
BEGIN
SET IDENTITY_INSERT static_data_value ON
INSERT INTO static_data_value(value_id,type_id,code,description) VALUES(4028,4011,'source_deal_detail_trm','source_deal_detail_trm')
INSERT INTO static_data_value(value_id,type_id,code,description) VALUES(4029,4011,'Deal_SNWA','Deal_SNWA')

SET IDENTITY_INSERT static_data_value OFF
END
alter table source_deal_error_log alter column error_type_id int