IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'pratos_source_price_curve_map' AND COLUMN_NAME = 'category_id')
BEGIN
	ALTER TABLE pratos_source_price_curve_map ADD  category_id INT
END
GO
IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'pratos_source_price_curve_map' AND COLUMN_NAME = 'country_id')
BEGIN
	ALTER TABLE pratos_source_price_curve_map ADD  country_id INT
END
GO
IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'pratos_book_mapping' AND COLUMN_NAME = 'region')
BEGIN
	ALTER TABLE pratos_book_mapping ADD  region INT
END
GO
/****** Object:  Table [dbo].[pratos_source_price_curve_map]    Script Date: 04/21/2012 13:42:06 ******/
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_pratos_book_mapping') 
	DROP INDEX pratos_book_mapping.IX_pratos_book_mapping

GO
IF EXISTS (SELECT name FROM sysindexes WHERE name = 'IX_pratos_source_price_curve_map') 
	DROP INDEX pratos_source_price_curve_map.IX_pratos_source_price_curve_map

GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_pratos_book_mapping] ON [dbo].[pratos_book_mapping] 
(
	[counterparty_id] ASC,
	[category] ASC,
	[country_id] ASC,
	[grid_id] ASC,
	[region] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO


CREATE UNIQUE NONCLUSTERED INDEX [IX_pratos_source_price_curve_map] ON [dbo].[pratos_source_price_curve_map] 
(
	[grid_value_id] ASC,
	[location_group_id] ASC,
	[region] ASC,
	[block_type] ASC,
	[category_id] ASC,
	[country_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO