IF COL_LENGTH('formula_breakdown_audit', 'formula_audit_id') IS NULL
BEGIN
    ALTER TABLE formula_breakdown_audit ADD formula_audit_id INT IDENTITY(1,1)
END
