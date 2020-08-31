BEGIN TRY
	IF NOT EXISTS(SELECT 1
				  FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
				  INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
						AND tc.Constraint_name = ccu.Constraint_name    
						AND tc.CONSTRAINT_TYPE = 'UNIQUE'
						AND tc.Table_Name = 'mv90_dst'
						AND ccu.COLUMN_NAME = '[year], insert_delete, dst_group_value_id'
	)
	BEGIN
		ALTER TABLE [dbo].[MV90_DST] 
		WITH NOCHECK 
		ADD CONSTRAINT [UC_mv90_year_insdel_dst_group_value] 
			UNIQUE([year], insert_delete, dst_group_value_id)

		PRINT 'Constraint UC_mv90_year_insdel_dst_group_value added'
	END
END TRY
BEGIN CATCH
	PRINT 'Constraint UC_mv90_year_insdel_dst_group_value already added'
END CATCH