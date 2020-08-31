

IF COL_LENGTH('formula_breakdown', 'formula_nested_id') IS NULL
BEGIN
	ALTER TABLE formula_breakdown ADD formula_nested_id INT

END

GO
		UPDATE  a	
			SET a.formula_nested_id=b.[id]
		FROM
			dbo.formula_breakdown a
			INNER JOIN formula_nested b ON a.formula_id=b.formula_group_id
				AND a.nested_id=b.sequence_order
