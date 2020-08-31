SET IDENTITY_INSERT static_data_value ON

--Sishir 07/13/2009
if not exists (select 'x' from static_data_value where value_id = 734 and type_id = 725)
INSERT INTO static_data_value (value_id, TYPE_ID, code, description) VALUES (734, 725, 'Mitigation Activity', 'Mitigation Activity')



-- for communication control status
if not exists (select 'x' from static_data_value where value_id = 732 and type_id = 725)
INSERT INTO static_data_value (value_id, TYPE_ID, code, description) VALUES (732, 725, 'Notified', 'Notified')

if not exists (select 'x' from static_data_value where value_id = 733 and type_id = 725)
INSERT INTO static_data_value (value_id, TYPE_ID, code, description) VALUES (733, 725, 'Exception', 'Exception')

-- for communication type
if not exists (select 'x' from static_data_value where value_id = 753 and type_id = 750)
INSERT INTO static_data_value (value_id, TYPE_ID, code, description) VALUES (753, 750, 'Outlook Calendar', 'BY Outlook Calendar')

if not exists (select 'x' from static_data_value where value_id = 754 and type_id = 750)
INSERT INTO static_data_value (value_id, TYPE_ID, code, description) VALUES (754, 750, 'Email & Outlook Calendar', 'BY Email & Outlook Calendar')

if not exists (select 'x' from static_data_value where value_id = 755 and type_id = 750)
INSERT INTO static_data_value (value_id, TYPE_ID, code, description) VALUES (755, 750, 'Outlook Calendar and Message Board', 'BY Outlook Calendar and Message Board')

if not exists (select 'x' from static_data_value where value_id = 756 and type_id = 750)
INSERT INTO static_data_value (value_id, TYPE_ID, code, description) VALUES (756, 750, 'Email, Outlook Calendar & Message Board ', 'BY Email, Outlook Calendar & Message Board ')

-- for compliance activity next action
if not exists (select 'x' from static_data_value where value_id = 11000 and type_id = 11000)
insert into static_data_value( value_id,type_id,code,description)
values ( 11000,11000,'Approve/Unapprove','Approve/Unapprove') 

if not exists (select 'x' from static_data_value where value_id = 11001 and type_id = 11000)
insert into static_data_value( value_id,type_id,code,description)
values ( 11001,11000,'Complete','Complete') 

if not exists (select 'x' from static_data_value where value_id = 11002 and type_id = 11000)
insert into static_data_value( value_id,type_id,code,description)
values ( 11002,11000,'Mitigate','Mitigate') 

if not exists (select 'x' from static_data_value where value_id = 11003 and type_id = 11000)
insert into static_data_value( value_id,type_id,code,description)
values ( 11003,11000,'Proceed','Proceed') 

if not exists (select 'x' from static_data_value where value_id = 11004 and type_id = 11000)
insert into static_data_value( value_id,type_id,code,description)
values ( 11004,11000,'Re-process','Re-process') 

if not exists (select 'x' from static_data_value where value_id = 11005 and type_id = 11000)
insert into static_data_value( value_id,type_id,code,description)
values ( 11005,11000,'Submit Proof','Submit Proof') 


UPDATE static_data_value SET code = 'Exceeds Threshold Days', description = 'Exceeds Threshold Days' WHERE value_id = 733

SET IDENTITY_INSERT static_data_value OFF

--UPDATE dbo.static_data_value SET code = 'Outstanding', description = 'Outstanding' WHERE value_id = 725

