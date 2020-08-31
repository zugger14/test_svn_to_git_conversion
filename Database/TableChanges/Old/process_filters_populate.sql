IF NOT EXISTS(SELECT 'x' FROM process_filters WHERE filterId ='Subsidiary')
INSERT INTO process_filters(filterId, tableName, colNameForValue, colNameForId, precedence, allowMultiSelect, module, module_type)
VALUES ('Subsidiary','portfolio_hierarchy','entity_name','entity_id',10,'n',NULL,NULL)
GO
IF NOT EXISTS(SELECT 'x' FROM process_filters WHERE filterId ='Strategy')
INSERT INTO process_filters(filterId, tableName, colNameForValue, colNameForId, precedence, allowMultiSelect, module, module_type)
VALUES ('Strategy','portfolio_hierarchy','entity_name','entity_id',20,'n',NULL,NULL)
GO
IF NOT EXISTS(SELECT 'x' FROM process_filters WHERE filterId ='Book')
INSERT INTO process_filters(filterId, tableName, colNameForValue, colNameForId, precedence, allowMultiSelect, module, module_type)
VALUES ('Book','portfolio_hierarchy','entity_name','entity_id',30,'n',NULL,NULL)
GO
IF NOT EXISTS(SELECT 'x' FROM process_filters WHERE filterId ='Contract')
INSERT INTO process_filters(filterId, tableName, colNameForValue, colNameForId, precedence, allowMultiSelect, module, module_type)
VALUES ('Contract','contract_group','contract_name','contract_id',40,'n',NULL,NULL)
GO
IF NOT EXISTS(SELECT 'x' FROM process_filters WHERE filterId ='Counterparty')
INSERT INTO process_filters(filterId, tableName, colNameForValue, colNameForId, precedence, allowMultiSelect, module, module_type)
VALUES ('Counterparty','source_counterparty','counterparty_name','source_counterparty_id',50,'n',NULL,NULL)
GO
IF NOT EXISTS(SELECT 'x' FROM process_filters WHERE filterId ='Nymex')
INSERT INTO process_filters(filterId, tableName, colNameForValue, colNameForId, precedence, allowMultiSelect, module, module_type)
VALUES ('Nymex','source_system_description','source_system_name','source_system_id',60,'n',NULL,NULL)
GO 
IF NOT EXISTS(SELECT 'x' FROM process_filters WHERE filterId ='Platts')
INSERT INTO process_filters(filterId, tableName, colNameForValue, colNameForId, precedence, allowMultiSelect, module, module_type)
VALUES ('Platts','source_system_description','source_system_name','source_system_id',70,'n',NULL,NULL)
GO 
IF NOT EXISTS(SELECT 'x' FROM process_filters WHERE filterId ='Treasury')
INSERT INTO process_filters(filterId, tableName, colNameForValue, colNameForId, precedence, allowMultiSelect, module, module_type)
VALUES ('Treasury','source_system_description','source_system_name','source_system_id',80,'n',NULL,NULL)
GO
IF NOT EXISTS(SELECT 'x' FROM process_filters WHERE filterId ='Traders')
INSERT INTO process_filters(filterId, tableName, colNameForValue, colNameForId, precedence, allowMultiSelect, module, module_type)
VALUES ('Traders','source_traders','trader_name','source_trader_id',90,'n',NULL,NULL)
GO 
IF NOT EXISTS(SELECT 'x' FROM process_filters WHERE filterId ='MiddleOffice')
INSERT INTO process_filters(filterId, tableName, colNameForValue, colNameForId, precedence, allowMultiSelect, module, module_type)
VALUES ('MiddleOffice','static_data_type','type_name','type_id',110,'n',NULL,NULL)
GO
GO 
IF NOT EXISTS(SELECT 'x' FROM process_filters WHERE filterId ='BackOffice')
INSERT INTO process_filters(filterId, tableName, colNameForValue, colNameForId, precedence, allowMultiSelect, module, module_type)
VALUES ('BackOffice','static_data_type','type_name','type_id',120,'n',NULL,NULL)
GO 
IF NOT EXISTS(SELECT 'x' FROM process_filters WHERE filterId ='DealIU')
INSERT INTO process_filters(filterId, tableName, colNameForValue, colNameForId, precedence, allowMultiSelect, module, module_type)
VALUES ('DealIU','static_data_type','type_name','type_id',130,'n',NULL,NULL)
GO
IF NOT EXISTS(SELECT 'x' FROM process_filters WHERE filterId ='DealDeletion')
INSERT INTO process_filters(filterId, tableName, colNameForValue, colNameForId, precedence, allowMultiSelect, module, module_type)
VALUES ('DealDeletion','static_data_type','type_name','type_id',140,'n',NULL,NULL)
GO 
IF NOT EXISTS(SELECT 'x' FROM process_filters WHERE filterId ='LimitViolation')
INSERT INTO process_filters(filterId, tableName, colNameForValue, colNameForId, precedence, allowMultiSelect, module, module_type)
VALUES ('LimitViolation','static_data_type','type_name','type_id',150,'n',NULL,NULL)
GO 