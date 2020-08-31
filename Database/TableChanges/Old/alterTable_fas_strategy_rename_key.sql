IF COL_LENGTH('fas_strategy_audit', 'aduti_id') IS NOT NULL
BEGIN
    EXEC sp_rename 'fas_strategy_audit.aduti_id' , 'audit_id', 'COLUMN'
END
GO

