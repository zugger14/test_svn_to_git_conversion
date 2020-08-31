IF EXISTS (
		SELECT 1
		FROM dbo.internal_deal_type_subtype_types
		WHERE internal_deal_type_subtype_id = 159
		)
	PRINT ' The id 159 already exists'
ELSE
	INSERT INTO dbo.internal_deal_type_subtype_types (
		internal_deal_type_subtype_id
		,internal_deal_type_subtype_type
		)
	SELECT 159
		,'Imbalance'