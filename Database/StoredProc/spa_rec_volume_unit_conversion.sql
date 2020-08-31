IF OBJECT_ID(N'spa_rec_volume_unit_conversion', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_rec_volume_unit_conversion]
GO 

CREATE PROCEDURE [dbo].[spa_rec_volume_unit_conversion]
	@flag CHAR(1),
	@rec_volume_unit_conversion_id INT = NULL,
	@state_value_id INT = NULL,
	@curve_id INT = NULL,
	@assignment_type_value_id INT = NULL,
	@from_source_uom_id INT = NULL,
	@to_source_uom_id INT = NULL,
	@conversion_factor FLOAT = NULL,
	@uom_label VARCHAR(50) = NULL,
	@curve_label VARCHAR(50) = NULL,
	@effective_date  DATETIME = NULL,
	@source INT = NULL,
	@to_curve_id INT = NULL
AS
DECLARE @sql VARCHAR(1000)
IF @flag='s'
BEGIN
	SET @sql='select rec_volume_unit_conversion_id [ID],s.code State,p.curve_Name Curve,p1.curve_Name [To Curve],
	s2.code Assignment,u1.uom_name [From UOM], u2.uom_name [To UOM], conversion_factor [Conv Factor],
	curve_label [Convert Env Product Label], uom_label [Convert UOM Label] 
	from rec_volume_unit_conversion c  join source_uom u1 on c.from_source_uom_id=u1.source_uom_id
	join source_uom u2 on c.to_source_uom_id=u2.source_uom_id left outer join static_data_value s
	on s.value_id=c.state_value_id 
	left outer join source_price_curve_def p on p.source_curve_def_id=c.curve_id 
	left outer join source_price_curve_def p1 on p1.source_curve_def_id=c.to_curve_id 
	left outer join static_data_value s2

	on s2.value_id=c.assignment_type_value_id where 1=1'
	IF @from_source_uom_id IS NOT NULL
		SET @sql=@sql+ ' and c.from_source_uom_id=' + CAST(@from_source_uom_id AS VARCHAR)
	IF @to_source_uom_id IS NOT NULL
		SET @sql=@sql+ ' and c.to_source_uom_id=' + CAST(@to_source_uom_id AS VARCHAR)
	EXEC(@sql)
END
ELSE IF @flag='a'
BEGIN
	SELECT rec_volume_unit_conversion_id,state_value_id,
	curve_id,
	assignment_type_value_id,
	from_source_uom_id,
	to_source_uom_id,
	conversion_factor,
	uom_label,
	curve_label,
	dbo.fnadateformat(effective_date),
	source,to_curve_id FROM rec_volume_unit_conversion WHERE rec_volume_unit_conversion_id=@rec_volume_unit_conversion_id
END
ELSE IF @flag='i'
BEGIN
	
IF EXISTS(SELECT rec_volume_unit_conversion_id FROM rec_volume_unit_conversion WHERE ISNULL(state_value_id,1)=ISNULL(@state_value_id,1)
AND ISNULL(curve_id,1)=ISNULL(@curve_id,1) AND ISNULL(assignment_type_value_id,1)=ISNULL(@assignment_type_value_id,1)
AND from_source_uom_id=@from_source_uom_id AND to_source_uom_id=@to_source_uom_id AND ISNULL(to_curve_id,1)=ISNULL(@to_curve_id,1))
BEGIN
	SELECT 'Error' ErrorCode, 'Rec Volumn Unit Conv' MODULE,
				'spa_rec_volume_unit_conversion' Area, 'DB Error' Status, 
				'Duplicate UOM Conversion detail cannot be inserted.' MESSAGE, 'Duplicate found conversion found, re-check it' Recommendation

	RETURN
END



INSERT  rec_volume_unit_conversion(
	state_value_id,
	curve_id,
	assignment_type_value_id,
	from_source_uom_id,
	to_source_uom_id,
	conversion_factor,
	uom_label,
	curve_label,
	effective_date,
	source,
	to_curve_id
		)
	VALUES(
	@state_value_id,
	@curve_id,
	@assignment_type_value_id,
	@from_source_uom_id,
	@to_source_uom_id,
	@conversion_factor,
	@uom_label,
	@curve_label,
	@effective_date,
	@source, 
	@to_curve_id)

	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR, 'Rec Volumn Unit Conv', 
				'spa_rec_volume_unit_conversion', 'DB Error', 
				'Failed to insert Rec Volumn Unit Conv.', ''
		ELSE
		EXEC spa_ErrorHandler 0, 'Rec Volumn Unit Conv', 
				'spa_rec_volume_unit_conversion', 'Success', 
				'Defination data value Rec Volumn Unit Conv.', ''
END
ELSE IF @flag='u'
BEGIN
IF EXISTS(SELECT rec_volume_unit_conversion_id FROM rec_volume_unit_conversion WHERE ISNULL(state_value_id,1)=ISNULL(@state_value_id,1)
AND ISNULL(curve_id,1)=ISNULL(@curve_id,1) AND ISNULL(assignment_type_value_id,1)=ISNULL(@assignment_type_value_id,1)
AND from_source_uom_id=@from_source_uom_id AND to_source_uom_id=@to_source_uom_id  AND to_curve_id=@to_curve_id
AND rec_volume_unit_conversion_id<>@rec_volume_unit_conversion_id)
BEGIN
	SELECT 'Error' ErrorCode, 'Rec Volumn Unit Conv' MODULE,
				'spa_rec_volume_unit_conversion' Area, 'DB Error' Status, 
				'Failed to Update Rec Volumn Unit Conv, duplicate found' MESSAGE, 'Duplicate found conversion found, re-check it' Recommendation

	RETURN
END



	UPDATE  rec_volume_unit_conversion
	SET state_value_id=@state_value_id,
	curve_id=@curve_id,
	assignment_type_value_id=@assignment_type_value_id,
	from_source_uom_id=@from_source_uom_id,
	to_source_uom_id=@to_source_uom_id,
	conversion_factor=@conversion_factor,
	uom_label=@uom_label,
	curve_label=@curve_label,
	effective_date=@effective_date,
	source=@source,
	to_curve_id=@to_curve_id
	WHERE rec_volume_unit_conversion_id=@rec_volume_unit_conversion_id
	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR, 'Rec Volumn Unit Conv', 
				'spa_rec_volume_unit_conversion', 'DB Error', 
				'Failed to Update Rec Volumn Unit Conv.', ''
		ELSE
		EXEC spa_ErrorHandler 0, 'Rec Volumn Unit Conv', 
				'spa_rec_volume_unit_conversion', 'Success', 
				'Defination data value Rec Volumn Unit Conv.', ''
END
ELSE IF @flag='d'
BEGIN
	IF EXISTS (
	SELECT 'X'
	FROM   source_deal_detail sdd
		   INNER JOIN source_price_curve_def spcd
				ON  sdd.curve_id = spcd.source_curve_def_id
		   INNER JOIN rec_volume_unit_conversion rvuc
				ON  sdd.deal_volume_uom_id = rvuc.from_source_uom_id
				AND spcd.display_uom_id = rvuc.to_source_uom_id
	WHERE  spcd.display_uom_id IS NOT NULL 
			AND rvuc.rec_volume_unit_conversion_id = @rec_volume_unit_conversion_id
)
	BEGIN
		EXEC spa_ErrorHandler -1
			, 'Rec Volumn Unit Conv'
			, 'spa_rec_volume_unit_conversion', 'DB Error'
			, 'Selected data is in use and cannot be deleted.'
			, ''
	END
	-- formula editor
	DECLARE @formula VARCHAR(8000)
	SELECT @formula = COALESCE(@formula + '' + formula, formula) FROM formula_editor WHERE formula LIKE '%UOMConv%' GROUP BY formula 
	DECLARE @index_start INT, @index_delim INT, @index_end INT 
	SET @index_end = 0

	--IF OBJECT_ID('#uom_conv') IS NOT NULL 
	--IF @formula IS NOT NULL
	CREATE TABLE #uom_conv (
		from_uom_id INT, 
		to_uom_id INT 	
	)

	WHILE CHARINDEX('UOMConv', @formula, @index_end) > 0 
	BEGIN
		SELECT @index_start = CHARINDEX('UOMConv', @formula, @index_end) 
		SELECT @index_delim = CHARINDEX(',', @formula, @index_start) 
		SELECT @index_end = CHARINDEX(')', @formula, @index_delim) 
		
		INSERT INTO #uom_conv
		SELECT	SUBSTRING(@formula, @index_start + 8, @index_delim - @index_start - 8),
				SUBSTRING(@formula, @index_delim + 1, @index_end - @index_delim - 1)  
		
	END
	--SELECT DISTINCT * FROM #uom_conv

	IF EXISTS (SELECT 'X' FROM rec_volume_unit_conversion rvuc
		INNER JOIN #uom_conv uc
		ON rvuc.from_source_uom_id = uc.from_uom_id
		AND rvuc.to_source_uom_id = uc.to_uom_id
		AND rvuc.rec_volume_unit_conversion_id = @rec_volume_unit_conversion_id
	           WHERE rvuc.rec_volume_unit_conversion_id = @rec_volume_unit_conversion_id)
	BEGIN
		EXEC spa_ErrorHandler -1
			, 'Rec Volumn Unit Conv'
			, 'spa_rec_volume_unit_conversion', 'DB Error'
			, 'Selected data is in use and cannot be deleted.'
			, ''
	END
	-- formula editor end	
	ELSE
	BEGIN
		BEGIN TRY
			DELETE rec_volume_unit_conversion
			WHERE rec_volume_unit_conversion_id = @rec_volume_unit_conversion_id
			
			EXEC spa_ErrorHandler 0, 'Rec Volumn Unit Conv', 
				'spa_rec_volume_unit_conversion', 'Success', 
				'Rec Volumn Unit Conv deleted successfully.', ''
		END TRY
		BEGIN CATCH
			EXEC spa_ErrorHandler -1, 'Rec Volumn Unit Conv', 
				'spa_rec_volume_unit_conversion', 'DB Error', 
				'Failed to Delete Rec Volumn Unit Conv.', ''
		END CATCH
	
	END
END

ELSE IF @flag='g' -- To display in the UOM Convertion grid
BEGIN
	SELECT 
		rec_volume_unit_conversion_id,
		uom_f.uom_name + ' to ' + uom_t.uom_name AS [code],
		uom_f.uom_name AS [From_UOM],
		uom_t.uom_name AS [To_UOM],		
		CAST(dbo.FNARemoveTrailingZeroes(conversion_factor) AS FLOAT)AS [Conversion Factor]	
	FROM rec_volume_unit_conversion rvuc
	INNER JOIN source_uom uom_f ON uom_f.source_uom_id = rvuc.from_source_uom_id
	INNER JOIN source_uom uom_t ON uom_t.source_uom_id = rvuc.to_source_uom_id
	ORDER BY code ASC
END