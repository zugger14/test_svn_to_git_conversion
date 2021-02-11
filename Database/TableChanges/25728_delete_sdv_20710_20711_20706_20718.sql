--IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_deal_actualization_detail_actualization_status_static_data_value')
--BEGIN
--	ALTER TABLE deal_actualization_detail
--	DROP CONSTRAINT fk_deal_actualization_detail_actualization_status_static_data_value
--END

-- Delete Unactualized static data value
IF EXISTS(SELECT * FROM static_data_value WHERE type_id = 20700 AND value_id IN (20706,20718,20710,20711))
BEGIN
	DELETE FROM static_data_value WHERE type_id = 20700 AND value_id IN (20706,20718,20710,20711)
END

--IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_deal_actualization_detail_actualization_status_static_data_value')
--BEGIN
--	ALTER TABLE deal_actualization_detail
--	ADD CONSTRAINT fk_deal_actualization_detail_actualization_status_static_data_value FOREIGN KEY ([actualization_status]) REFERENCES static_data_value([value_id])
--END
--GO

