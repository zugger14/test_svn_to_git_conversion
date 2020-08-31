IF COL_LENGTH('contract_group', 'financial_rate_fees') IS NOT NULL
BEGIN
   EXEC SP_RENAME 'contract_group.[financial_rate_fees]' , 'maintain_rate_schedule', 'COLUMN'
END
GO

IF COL_LENGTH('contract_group', 'base_load') IS NOT NULL
BEGIN
   EXEC SP_RENAME 'contract_group.[base_load]' , 'contract_type', 'COLUMN'
END
GO
	
IF COL_LENGTH('contract_group', 'contract_type') IS NOT NULL
BEGIN
    ALTER TABLE contract_group ALTER COLUMN contract_type VARCHAR(100)
END
GO

IF COL_LENGTH('contract_group', 'pipeline') IS NOT NULL
BEGIN
    ALTER TABLE contract_group ALTER COLUMN pipeline INT
END
GO


IF COL_LENGTH('contract_group', 'firm') IS NOT NULL
BEGIN
   EXEC SP_RENAME 'contract_group.[firm]' , 'deal', 'COLUMN'
END
GO

IF COL_LENGTH('contract_group', 'deal') IS NOT NULL
BEGIN
    ALTER TABLE contract_group ALTER COLUMN deal VARCHAR(100)
END
GO