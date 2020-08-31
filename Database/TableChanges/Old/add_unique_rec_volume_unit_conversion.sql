IF EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'UNIQUE'
                    AND   tc.Table_Name = 'rec_volume_unit_conversion'      --table name
                    AND tc.CONSTRAINT_NAME = 'IX_rec_volume_unit_conversion_1')
BEGIN
	ALTER TABLE rec_volume_unit_conversion DROP CONSTRAINT IX_rec_volume_unit_conversion_1
END 		

GO
ALTER TABLE dbo.rec_volume_unit_conversion ADD CONSTRAINT
	IX_rec_volume_unit_conversion_1 UNIQUE NONCLUSTERED 
	(
	from_source_uom_id,
	to_source_uom_id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO



		