IF OBJECT_ID(N'company_catalog', N'U') IS NOT NULL AND COL_LENGTH('company_catalog', 'aad_tenant_id') IS NULL
BEGIN
    ALTER TABLE 
	/**
		Columns
		aad_tenant_id : Azure Active Directory Directory (Tenant) ID
	*/
		company_catalog ADD aad_tenant_id NVARCHAR(150)
END
GO