IF 4 = (select count(*) [Name]
    from sys.columns 
    where OBJECT_ID = OBJECT_ID('state_properties_details')
    and Name in ('tier_id', 'technology_id', 'technology_subtype_id','price_index')
    )
BEGIN
	IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='UNQ_tier_tech_techSub_pricInd')
	BEGIN
		DELETE FROM dbo.state_properties_details
		ALTER TABLE dbo.state_properties_details
		ADD CONSTRAINT UNQ_tier_tech_techSub_pricInd UNIQUE (
			tier_id
			,technology_id			
			,technology_subtype_id				
			,price_index			
		)
	END
END 
