-- Name of foreign key may differ on different servers
IF EXISTS (SELECT name FROM sys.foreign_keys WHERE name = 'FK__status_ru__statu__28DC9249')  
ALTER TABLE status_rule_header DROP constraint FK__status_ru__statu__28DC9249

IF NOT EXISTS (SELECT name FROM sys.foreign_keys WHERE name = 'FK_status_static_data_type_23RT')
ALTER TABLE status_rule_header ADD CONSTRAINT FK_status_static_data_type_23RT FOREIGN KEY (status_rule_type) 
REFERENCES static_data_type(TYPE_ID)


