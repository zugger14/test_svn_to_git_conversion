BEGIN TRANSACTION
GO

ALTER TABLE dbo.conversion_factor_detail
        DROP CONSTRAINT fk_conversion_factor_id
GO
ALTER TABLE dbo.conversion_factor_detail ADD CONSTRAINT
        fk_conversion_factor_id FOREIGN KEY
        (
        conversion_factor_id
        ) REFERENCES [dbo].[conversion_factor] ([conversion_factor_id])
         ON DELETE CASCADE 
        
GO
COMMIT
GO
