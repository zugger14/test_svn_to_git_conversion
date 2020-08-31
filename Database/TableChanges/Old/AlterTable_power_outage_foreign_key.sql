IF EXISTS (
	SELECT 1
	FROM  sys.foreign_keys fk
	INNER JOIN sys.foreign_key_columns fkc ON  fkc.constraint_object_id = fk.object_id
	INNER JOIN sys.columns cpa
		ON  fkc.parent_object_id = cpa.object_id
		AND fkc.parent_column_id = cpa.column_id
	INNER JOIN sys.columns cref
		ON  fkc.referenced_object_id = cref.object_id
		AND fkc.referenced_column_id = cref.column_id
	WHERE OBJECT_NAME(fk.parent_object_id) = 'power_outage'
	AND OBJECT_NAME(fk.referenced_object_id) = 'rec_generator'
	AND fk.Name = 'FK_power_outage_source_generator'
)
BEGIN
	ALTER TABLE power_outage DROP CONSTRAINT FK_power_outage_source_generator
END

GO
/*
IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND tc.Table_Name = 'power_outage'
                    AND ccu.COLUMN_NAME = 'source_generator_id'
)
ALTER TABLE [dbo].[power_outage] WITH NOCHECK ADD CONSTRAINT [FK_power_outage_source_generator] FOREIGN KEY([source_generator_id])
REFERENCES [dbo].[rec_generator] ([generator_id])
*/
GO
