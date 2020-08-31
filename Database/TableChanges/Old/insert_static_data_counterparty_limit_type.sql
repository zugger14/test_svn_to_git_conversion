INSERT INTO static_data_type (type_id, type_name, internal, description)
VALUES (5650,'Counterparty Limit Type',1,'Counterparty Limit Type')

SET IDENTITY_INSERT static_data_value ON
GO
INSERT INTO static_data_value(value_id, TYPE_ID, code, description)
VALUES (5650,5650, 'Volumetric','Volumetric Limit')
GO
INSERT INTO static_data_value(value_id, TYPE_ID, code, description)
VALUES (5651,5650, 'MTM','MTM Limit')
GO
INSERT INTO static_data_value(value_id, TYPE_ID, code, description)
VALUES (5652,5650, 'Tenor','Tenor Limit')
GO
SET IDENTITY_INSERT static_data_value OFF
GO