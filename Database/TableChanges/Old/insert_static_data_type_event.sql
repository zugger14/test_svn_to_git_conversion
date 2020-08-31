IF NOT EXISTS(SELECT 'x' FROM static_data_type WHERE [TYPE_ID] = 19500)
INSERT INTO static_data_type ([TYPE_ID],[TYPE_NAME],internal,[description])
VALUES (19500,'event',1,'event')

SET IDENTITY_INSERT static_data_value ON

IF NOT EXISTS(SELECT 'x' FROM static_data_value WHERE value_id = 19501)
INSERT INTO static_data_value(value_id,[TYPE_ID],code,DESCRIPTION)
VALUES (19501,19500,'deal insert','deal insert')

IF NOT EXISTS(SELECT 'x' FROM static_data_value WHERE value_id = 19502)
INSERT INTO static_data_value(value_id,[TYPE_ID],code,DESCRIPTION)
VALUES (19502,19500,'deal update','deal update')

IF NOT EXISTS(SELECT 'x' FROM static_data_value WHERE value_id = 19503)
INSERT INTO static_data_value(value_id,[TYPE_ID],code,DESCRIPTION)
VALUES (19503,19500,'deal status change','deal status change')

IF NOT EXISTS(SELECT 'x' FROM static_data_value WHERE value_id = 19504)
INSERT INTO static_data_value(value_id,[TYPE_ID],code,DESCRIPTION)
VALUES (19504,19500,'deal ticket approval by front office','deal ticket approval by front office')

IF NOT EXISTS(SELECT 'x' FROM static_data_value WHERE value_id = 19505)
INSERT INTO static_data_value(value_id,[TYPE_ID],code,DESCRIPTION)
VALUES (19505,19500,'deal ticket approval by mid office','deal ticket approval by mid office')

IF NOT EXISTS(SELECT 'x' FROM static_data_value WHERE value_id = 19506)
INSERT INTO static_data_value(value_id,[TYPE_ID],code,DESCRIPTION)
VALUES (19506,19500,'deal ticket approval by back office','deal ticket approval by back office')

IF NOT EXISTS(SELECT 'x' FROM static_data_value WHERE value_id = 19507)
INSERT INTO static_data_value(value_id,[TYPE_ID],code,DESCRIPTION)
VALUES (19507,19500,'confirm status change','confirm status change')

IF NOT EXISTS(SELECT 'x' FROM static_data_value WHERE value_id = 19508)
INSERT INTO static_data_value(value_id,[TYPE_ID],code,DESCRIPTION)
VALUES (19508,19500,'delete deal','delete deal')

SET IDENTITY_INSERT static_data_value OFF 