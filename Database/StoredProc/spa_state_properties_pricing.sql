/****** Object:  StoredProcedure [dbo].[spa_state_properties_pricing]    Script Date: 09/18/2009 14:58:45 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_state_properties_pricing]') AND type IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_state_properties_pricing]
GO
/****** Object:  StoredProcedure [dbo].[spa_state_properties_pricing]    Script Date: 09/18/2009 16:47:32 ******/

CREATE PROCEDURE [dbo].[spa_state_properties_pricing]
	@flag CHAR(1)=NULL,
	@state_value_id INT=NULL,
	@pricing_id VARCHAR(100)=NULL,
	@pricing_type_id INT=NULL,
	@technology INT=NULL,
	@curve_id INT=NULL
AS
IF @flag='s'
	BEGIN
		
		SELECT  
			d.pricing_id [pricing_id], 
			d.pricing_type_id [pricing_type_id],
			d.curve_id [curve_id],
			d.technology [technology],
			d.state_value_id
		FROM      
			state_properties_pricing d 
		WHERE 
			state_value_id=@state_value_id 

	END
IF @flag='a'
BEGIN
	SELECT    
			  pricing_id, 
			  pricing_type_id,technology,curve_id
	FROM      
			state_properties_pricing 
		WHERE pricing_id=@pricing_id
END
IF @flag='i'
BEGIN
	IF EXISTS (SELECT 'x' FROM state_properties_pricing 
				WHERE pricing_type_id=@pricing_type_id 
				AND curve_id = @curve_id				
				AND ISNULL(CAST(technology AS VARCHAR),'TRUE') = ISNULL(CAST(@technology AS VARCHAR),'TRUE')
				AND state_value_id = @state_value_id)
	BEGIN
			EXEC spa_ErrorHandler -1, 'The selected Pricing information already exists.', 
					'spa_state_properties_pricing', 'DB Error', 
					'The selected Pricing information already exists.', ''
					RETURN	
	END
	INSERT state_properties_pricing(
		state_value_id,
		pricing_type_id,	
		technology,	
		curve_id
	)
	VALUES(
		@state_value_id,
		@pricing_type_id,
		@technology,
		@curve_id
	)

		IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR, "State Properties", 
				"spa_state_properties", "DB Error", 
			"Error on Inserting State Properties.", ''
	ELSE
		EXEC spa_ErrorHandler 0, 'State Properties Duration', 
				'spa_state_properties_Duration', 'Success', 
				'State Properties Pricing successfully inserted.', ''
END
IF @flag='u'
BEGIN
	IF EXISTS (SELECT 'x' FROM state_properties_pricing 
				WHERE pricing_type_id=@pricing_type_id 
				AND curve_id = @curve_id
				AND ISNULL(CAST(technology AS VARCHAR),'TRUE') = ISNULL(CAST(@technology AS VARCHAR),'TRUE')
				AND state_value_id = @state_value_id 
				AND pricing_id <> @pricing_id)
	BEGIN
			EXEC spa_ErrorHandler -1, 'The selected Pricing information already exists.', 
					'spa_state_properties_pricing', 'DB Error', 
					'The selected Pricing information already exists.', ''
					RETURN	
	END

	UPDATE state_properties_pricing
	SET
		pricing_type_id=@pricing_type_id,
		technology=@technology,
		curve_id=@curve_id
	WHERE 
		pricing_id=@pricing_id

	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR, "State Properties", 
				"spa_state_properties", "DB Error", 
			"Error on Updating State Properties.", ''
	ELSE
		EXEC spa_ErrorHandler 0, 'State Properties Duration', 
				'spa_state_properties_Pricing', 'Success', 
				'State Properties Pricing successfully Updated.', ''
END
IF @flag='d'
BEGIN
	
	DECLARE @sql_string VARCHAR(MAX)
	SET @sql_string = ' DELETE  FROM   state_properties_pricing
								WHERE  pricing_id IN (' + @pricing_id + ')'
								
	PRINT (@sql_string)
	EXEC  (@sql_string)
	

	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR, "State Properties", 
				"spa_state_properties", "DB Error", 
			"Error on Updating State Properties.", ''
	ELSE
		EXEC spa_ErrorHandler 0, 'State Properties Duration', 
				'spa_state_properties_Pricing', 'Success', 
				'State Properties Duration successfully Removed.', ''
END