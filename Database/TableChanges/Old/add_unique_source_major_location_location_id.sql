IF NOT EXISTS (
       SELECT 1
       FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC
       WHERE  TABLE_NAME              = 'source_minor_location'
              AND CONSTRAINT_TYPE     = 'UNIQUE'
              AND CONSTRAINT_NAME     = 'UX_source_minor_location'
   )
    BEGIN
        ALTER TABLE [dbo].[source_minor_location]
        ADD CONSTRAINT [UX_source_minor_location] UNIQUE(location_id)
    END
 ELSE
 	BEGIN
 		PRINT 'Already created Unique contriant for Location Id.'
 	END  