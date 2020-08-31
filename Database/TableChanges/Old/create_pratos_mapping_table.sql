IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pratos_formula_mapping]') AND type IN (N'U'))
CREATE TABLE [dbo].[pratos_formula_mapping] (
	id INT PRIMARY KEY IDENTITY (1, 1),
	source_formula VARCHAR(500) UNIQUE,
	curve_id INT,
	relative_year INT,
	strip_month_from INT,
	lag_month INT,
	strip_month_to INT,
	currency_id INT,
	price_adder FLOAT,
	exp_type VARCHAR(20),
	exp_value VARCHAR(50)
)
GO
IF NOT EXISTS(SELECT * FROM pratos_formula_mapping)
INSERT INTO pratos_formula_mapping(source_formula,curve_id,relative_year,strip_month_from,lag_month,strip_month_to,currency_id,price_adder,exp_type,exp_value)
SELECT 'NLEndexQ(4dpe03)OnPeak',source_curve_def_id,0,0,0,0,NULL,NULL,'RDB',-4 FROM source_price_curve_def WHERE curve_id LIKE 'NLEndexQ Onpeak'
UNION ALL SELECT 'NLEndexQ(4dpe03)OffPeak',source_curve_def_id,0,0,0,0,NULL,NULL,'RDB',-4 FROM source_price_curve_def WHERE curve_id LIKE 'NLEndexQ Offpeak'
UNION ALL SELECT 'APXOnPeak',source_curve_def_id,0,0,0,0,NULL,NULL,NULL,NULL FROM source_price_curve_def WHERE curve_id LIKE 'APXOnPeak'
UNION ALL SELECT 'APXOffPeak',source_curve_def_id,0,0,0,0,NULL,NULL,NULL,NULL FROM source_price_curve_def WHERE curve_id LIKE 'APXOffPeak'
UNION ALL SELECT 'NLEndexM(101)OnPeak',source_curve_def_id,0,0,0,0,NULL,NULL,NULL,NULL FROM source_price_curve_def WHERE curve_id LIKE 'NLEndexM Onpeak'
UNION ALL SELECT 'NLEndexM(101)OffPeak',source_curve_def_id,0,0,0,0,NULL,NULL,NULL,NULL FROM source_price_curve_def WHERE curve_id LIKE 'NLEndexMOffPeak'
UNION ALL SELECT 'Gasoil(626)',source_curve_def_id,0,6,2,6,NULL,NULL,NULL,NULL FROM source_price_curve_def WHERE curve_id LIKE 'Gasoil'
UNION ALL SELECT 'HFO(603)',source_curve_def_id,0,6,0,3,NULL,NULL,NULL,NULL FROM source_price_curve_def WHERE curve_id LIKE 'LSFO'
UNION ALL SELECT 'Gasoil(603)',source_curve_def_id,0,6,0,3,NULL,NULL,NULL,NULL FROM source_price_curve_def WHERE curve_id LIKE 'Gasoil'
UNION ALL SELECT 'TTF(101)',source_curve_def_id,0,1,0,1,NULL,NULL,NULL,NULL FROM source_price_curve_def WHERE curve_id LIKE 'TTF forward'
UNION ALL SELECT 'Brent(101)',source_curve_def_id,0,1,0,1,NULL,NULL,NULL,NULL FROM source_price_curve_def WHERE curve_id LIKE 'Brent'
UNION ALL SELECT 'Brent(303)',source_curve_def_id,0,3,0,3,NULL,NULL,NULL,NULL FROM source_price_curve_def WHERE curve_id LIKE 'Brent'
UNION ALL SELECT 'HFO(303)',source_curve_def_id,0,3,0,3,NULL,NULL,NULL,NULL FROM source_price_curve_def WHERE curve_id LIKE 'LSFO'
UNION ALL SELECT 'Gasoil(303)',source_curve_def_id,0,3,0,3,NULL,NULL,NULL,NULL FROM source_price_curve_def WHERE curve_id LIKE 'Gasoil'
UNION ALL SELECT 'TTFLEBA',source_curve_def_id,0,0,0,0,NULL,NULL,NULL,NULL FROM source_price_curve_def WHERE curve_id LIKE 'TTFLEBA'
UNION ALL SELECT 'EndexYear',source_curve_def_id,0,0,0,0,NULL,NULL,NULL,NULL FROM source_price_curve_def WHERE curve_id LIKE 'EndexYear'
UNION ALL SELECT 'Brent(303)OffPeak',source_curve_def_id,0,3,0,3,NULL,NULL,NULL,NULL FROM source_price_curve_def WHERE curve_id LIKE 'BrentOffpeak'
UNION ALL SELECT 'API2(303)OffPeak',source_curve_def_id,0,3,0,3,NULL,NULL,NULL,NULL FROM source_price_curve_def WHERE curve_id LIKE 'API2 Offpeak'
UNION ALL SELECT 'APXOffPeak',source_curve_def_id,0,0,0,0,NULL,NULL,NULL,NULL FROM source_price_curve_def WHERE curve_id LIKE 'APX Offpeak'
UNION ALL SELECT 'NLEndexQ(303)OffPeak',source_curve_def_id,0,3,0,3,NULL,NULL,NULL,NULL FROM source_price_curve_def WHERE curve_id LIKE 'NLEndexQ'
UNION ALL SELECT 'NLEndexY(12012)OffPeak',source_curve_def_id,0,12,0,12,NULL,NULL,NULL,NULL FROM source_price_curve_def WHERE curve_id LIKE 'NLEndexYOffpeak'
UNION ALL SELECT 'NLEndexY(4dpe012)OffPeak',source_curve_def_id,0,0,0,0,NULL,NULL,NULL,NULL FROM source_price_curve_def WHERE curve_id LIKE 'NLEndexYOffpeak'
UNION ALL SELECT 'BEEndexMBase(101)OffPeak',source_curve_def_id,0,1,0,1,NULL,NULL,NULL,NULL FROM source_price_curve_def WHERE curve_id LIKE 'BEEndexMBaseOffpeak'
UNION ALL SELECT 'BEEndexQBase(4dpe03)OffPeak',source_curve_def_id,0,0,0,0,NULL,NULL,'RDB',-4 FROM source_price_curve_def WHERE curve_id LIKE 'BEEndexQBaseOffpeak'
UNION ALL SELECT 'BEEndexYBase(4dpe012)OffPeak',source_curve_def_id,0,0,0,0,NULL,NULL,'RDB',-4 FROM source_price_curve_def WHERE curve_id LIKE 'BEEndexYBaseOffpeak'
UNION ALL SELECT 'BelPexOffPeak',source_curve_def_id,0,0,0,0,NULL,NULL,NULL,NULL FROM source_price_curve_def WHERE curve_id LIKE 'BelPexOffPeak'
UNION ALL SELECT 'BEEndexQBase(303)OffPeak',source_curve_def_id,0,3,0,3,NULL,NULL,NULL,NULL FROM source_price_curve_def WHERE curve_id LIKE 'BEEndexQBase Offpeak'
UNION ALL SELECT 'Brent(303)OnPeak',source_curve_def_id,0,3,0,3,NULL,NULL,NULL,NULL FROM source_price_curve_def WHERE curve_id LIKE 'BrentOnpeak'
UNION ALL SELECT 'API2(303)OnPeak',source_curve_def_id,0,3,0,3,NULL,NULL,NULL,NULL FROM source_price_curve_def WHERE curve_id LIKE 'API2Onpeak'
UNION ALL SELECT 'NLEndexQ(303)OnPeak',source_curve_def_id,0,3,0,3,NULL,NULL,NULL,NULL FROM source_price_curve_def WHERE curve_id LIKE 'NLEndexQ Onpeak'
UNION ALL SELECT 'NLEndexY(12012)OnPeak',source_curve_def_id,0,12,0,12,NULL,NULL,NULL,NULL FROM source_price_curve_def WHERE curve_id LIKE 'NLEndexYOnPeak'
UNION ALL SELECT 'NLEndexY(4dpe012)OnPeak',source_curve_def_id,0,0,0,0,NULL,NULL,'RDB',-4 FROM source_price_curve_def WHERE curve_id LIKE 'NLEndexYOnpeak'
UNION ALL SELECT 'BEEndexMBase(101)OnPeak',source_curve_def_id,0,1,0,1,NULL,NULL,NULL,NULL FROM source_price_curve_def WHERE curve_id LIKE 'BEEndexMBaseOnpeak'
UNION ALL SELECT 'BEEndexQBase(4dpe03)OnPeak',source_curve_def_id,0,0,0,0,NULL,NULL,'RDB',-4 FROM source_price_curve_def WHERE curve_id LIKE 'BEEndexQBaseOnpeak'
UNION ALL SELECT 'BEEndexYBase(4dpe012)OnPeak',source_curve_def_id,0,0,0,0,NULL,NULL,'RDB',-4 FROM source_price_curve_def WHERE curve_id LIKE 'BEEndexYBaseOnpeak'
UNION ALL SELECT 'BelPexOnPeak',source_curve_def_id,0,0,0,0,NULL,NULL,NULL,NULL FROM source_price_curve_def WHERE curve_id LIKE 'BelpexOnpeak'
UNION ALL SELECT 'BEEndexQBase(303)OnPeak',source_curve_def_id,0,3,0,3,NULL,NULL,NULL,NULL FROM source_price_curve_def WHERE curve_id LIKE 'BEEndexQBaseOnpeak'

GO

IF COL_LENGTH('pratos_formula_mapping', 'curve_type') IS NULL
BEGIN
	ALTER TABLE pratos_formula_mapping add curve_type VARCHAR(100)

	PRINT 'Column pratos_formula_mapping.curve_type added.'
END
ELSE
BEGIN
	PRINT 'Column pratos_formula_mapping.curve_type already exists.'
END
GO 


--ALTER TABLE [dbo].[pratos_formula_mapping] WITH NOCHECK ADD CONSTRAINT
--[FK_pratos_formula_mapping_source_price_curve_def] FOREIGN KEY([curve_id])
--REFERENCES [dbo].[source_price_curve_def] ([source_curve_def_id])
--GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[pratos_source_price_curve_map]') AND name = N'IX_pratos_source_price_curve_map')
CREATE UNIQUE NONCLUSTERED INDEX [IX_pratos_source_price_curve_map] ON [dbo].[pratos_source_price_curve_map] 
(
	[curve_id] ASC,
	[grid_value_id] ASC,
	[location_group_id] ASC,
	[region] ASC,
	[block_type] DESC 
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO