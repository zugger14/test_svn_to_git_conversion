IF NOT EXISTS (SELECT * FROM information_schema.columns WHERE table_name ='source_price_curve' AND column_name='is_dst')
BEGIN
	ALTER TABLE dbo.source_price_curve ADD [is_dst] [int] NOT NULL CONSTRAINT [DF_source_price_curve_is_dst]  DEFAULT ((0))
	
	IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc WHERE tc.CONSTRAINT_NAME = 'PK_source_price_curve')
	BEGIN
		ALTER TABLE dbo.source_price_curve DROP CONSTRAINT [PK_source_price_curve]
	END
	 
	ALTER TABLE [dbo].[source_price_curve] ADD  CONSTRAINT [PK_source_price_curve] PRIMARY KEY NONCLUSTERED 
	(
		[source_curve_def_id] ASC,
		[as_of_date] ASC,
		[Assessment_curve_type_value_id] ASC,
		[curve_source_value_id] ASC,
		[maturity_date] ASC, 
		[is_dst]
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]	
END


