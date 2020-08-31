IF COL_LENGTH('source_fee', 'fee_name') IS NULL
BEGIN
	BEGIN TRY
		BEGIN TRAN
			 DELETE FROM source_fee
			 ALTER TABLE source_fee 
				ADD  fee_name VARCHAR(100)  
			 ALTER TABLE source_fee
				ADD CONSTRAINT UK_source_fee_name UNIQUE (fee_name)
		COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK	
	END CATCH
END
GO


