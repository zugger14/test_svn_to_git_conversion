if OBJECT_ID(N'[dbo].[master_view_counterparty_products]', N'U') is null --drop table [dbo].[master_view_counterparty_products]
begin
	create table [dbo].[master_view_counterparty_products] (
		master_view_counterparty_products_id INT IDENTITY(1,1) constraint PK_master_view_counterparty_products primary key,
		counterparty_product_id int not null,
		counterparty_id int not null,
		counterparty_name varchar(200) null,
		commodity varchar(200) null,
		origin varchar(200) null,
		form varchar(200) null,
		attr1 varchar(200) null,
		attr2 varchar(200) null,
		attr3 varchar(200) null,
		attr4 varchar(200) null,
		attr5 varchar(200) null,
		trader varchar(200) null
	
	)
	print 'Object ''[dbo].[master_view_counterparty_products]'' created.'
end
else print 'Object ''[dbo].[master_view_counterparty_products]'' already exists.'
go

if OBJECT_ID(N'FK_counterparty_product_id_master_view_counterparty_products_counterparty_products', N'F') is null
begin
	alter table [dbo].[master_view_counterparty_products]
	add CONSTRAINT [FK_counterparty_product_id_master_view_counterparty_products_counterparty_products] 
			FOREIGN KEY([counterparty_product_id])
			REFERENCES [dbo].[counterparty_products] ([counterparty_product_id])
			ON DELETE CASCADE
	print 'FK Constraint ''FK_counterparty_product_id_master_view_counterparty_products_counterparty_products'' created.'
end
else print 'FK Constraint ''FK_counterparty_product_id_master_view_counterparty_products_counterparty_products'' already exists.'
go

if OBJECT_ID(N'FK_counterparty_id_master_view_counterparty_products_source_counterparty', N'F') is null
begin
	alter table [dbo].[master_view_counterparty_products]
	add CONSTRAINT [FK_counterparty_id_master_view_counterparty_products_source_counterparty] 
			FOREIGN KEY([counterparty_id])
			REFERENCES [dbo].[source_counterparty] ([source_counterparty_id])
	print 'FK Constraint ''FK_counterparty_id_master_view_counterparty_products_source_counterparty'' created.'
end
else print 'FK Constraint ''FK_counterparty_id_master_view_counterparty_products_source_counterparty'' already exists.'
go

IF NOT OBJECTPROPERTY(OBJECT_ID('[dbo].[master_view_counterparty_products]'), 'TableHasActiveFulltextIndex') = 1
BEGIN
    CREATE FULLTEXT INDEX ON [dbo].[master_view_counterparty_products] (
		[commodity],
		[origin],
		[form],
		[attr1],
		[attr2],
		[attr3],
		[attr4],
		[attr5],
		[trader]
	) KEY INDEX PK_master_view_counterparty_products;
	PRINT 'FULLTEXT INDEX ON master_view_counterparty_products created.'
END
ELSE
    PRINT 'FULLTEXT INDEX ON master_view_counterparty_products Already Exists.'
GO