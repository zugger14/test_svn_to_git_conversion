-- Vishwas Khanal,27.July.2009
DELETE FROM dbo.process_filters
INSERT INTO dbo.process_filters (filterID,tableName,colNameForValue,colNameForId,precedence) VALUES ('Subsidiary','portfolio_hierarchy','entity_name','entity_id',10)
INSERT INTO dbo.process_filters (filterID,tableName,colNameForValue,colNameForId,precedence) VALUES ('Strategy','portfolio_hierarchy','entity_name','entity_id',20)
INSERT INTO dbo.process_filters (filterID,tableName,colNameForValue,colNameForId,precedence) VALUES ('Book','portfolio_hierarchy','entity_name','entity_id',30)
INSERT INTO dbo.process_filters (filterID,tableName,colNameForValue,colNameForId,precedence) VALUES ('Contract','contract_group','contract_name','contract_id',40)
INSERT INTO dbo.process_filters (filterID,tableName,colNameForValue,colNameForId,precedence) VALUES ('Counterparty','source_counterparty','counterparty_name','source_counterparty_id',50)
INSERT INTO dbo.process_filters (filterID,tableName,colNameForValue,colNameForId,precedence) VALUES ('Nymex','source_system_description','source_system_name','source_system_id',60)
INSERT INTO dbo.process_filters (filterID,tableName,colNameForValue,colNameForId,precedence) VALUES ('Platts','source_system_description','source_system_name','source_system_id',70)
INSERT INTO dbo.process_filters (filterID,tableName,colNameForValue,colNameForId,precedence) VALUES ('Treasury','source_system_description','source_system_name','source_system_id',80)
INSERT INTO dbo.process_filters (filterID,tableName,colNameForValue,colNameForId,precedence) VALUES ('Traders','source_traders','trader_name','source_trader_id',90)




