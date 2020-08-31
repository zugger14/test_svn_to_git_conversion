set identity_insert static_data_value on
GO

INSERT INTO static_data_value(value_id,type_id,code,[description])
SELECT 1655,1650,'Nominated','Nominated'

INSERT INTO static_data_value(value_id,type_id,code,[description])
SELECT 1656,1650,'Scheduled','Scheduled'

INSERT INTO static_data_value(value_id,type_id,code,[description])
SELECT 1657,1650,'Allocated','Allocated'

GO
set identity_insert static_data_value off
GO

update static_data_value set code='Delivered',description='Delivered' where value_id=1650
update static_data_value set code='Transportation rate schedule',description='Transportation rate schedule' where value_id=1800
update static_data_value set code='Storage rate schedule',description='Storage rate schedule' where value_id=1801

