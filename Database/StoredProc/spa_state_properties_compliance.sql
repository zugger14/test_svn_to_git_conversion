/****** Object:  StoredProcedure [dbo].[spa_state_properties_compliance]    Script Date: 09/16/2009 09:20:39 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_state_properties_compliance]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_state_properties_compliance]
GO
CREATE PROCEDURE [dbo].[spa_state_properties_compliance]
	@flag char(1)=null,
	@compliance_period_id int=null,
	@state_id int=null,
	@assignment_type_id int=NULL,
	@from_month int=NULL,
	@to_month int =NULL

AS
if @flag='s'
begin

SELECT  compliance_period_id,
	s.Code [Jurisdiction],
	s2.description Assignment, dbo.FNAGetMonthName(from_month) [From Month],
	dbo.FNAGetMonthName(to_month) [To Month]
	FROM    state_compliance_period d 
left outer join static_data_value s2 on s2.value_id= d.assignment_type_id
left outer join static_data_value s on s.value_id=d.state_id
where state_id=@state_id



end
IF @flag='a'
BEGIN
	SELECT * FROM state_compliance_period where compliance_period_id=@compliance_period_id
END
ELSE IF @flag = 'i'
BEGIN
	IF EXISTS (SELECT 'x' FROM state_compliance_period 
				WHERE assignment_type_id=@assignment_type_id 
				AND state_id = @state_id
				AND from_month = @from_month
				AND to_month= @to_month)
	BEGIN
			Exec spa_ErrorHandler -1, 'State Compliance.', 
					'spa_state_properties_compliance', 'DB Error', 
					'Cannot insert duplicate Compliance records.', ''
					return	
	END
	IF EXISTS (SELECT 'x' FROM state_compliance_period 
				WHERE assignment_type_id=@assignment_type_id 
				AND state_id = @state_id
				AND (@from_month between from_month  and to_month
				OR @to_month between from_month and to_month ))
	BEGIN
		EXEC spa_ErrorHandler -1, 'State Compliance.', 
				'spa_state_properties_compliance', 'DB Error', 
				'Compliance period for an Assignment should not overlap.', ''
				RETURN
	END
	
	INSERT state_compliance_period(
		state_id,	
		assignment_type_id,	
		from_month,
		to_month
	)
	VALUES(
		@state_id,
		@assignment_type_id,
		@from_month,
		@to_month)

	IF @@ERROR <> 0
	EXEC spa_ErrorHandler @@ERROR, "State Compliance", 
			"spa_state_properties_compliance", "DB Error", 
		"Error on Inserting State Compliance.", ''
	ELSE
	EXEC spa_ErrorHandler 0, 'State Compliance', 
			'spa_state_properties_compliance', 'Success', 
			'State Compliance successfully inserted.', ''				
END
ELSE IF @flag = 'u'
BEGIN
		IF EXISTS (SELECT 'x' FROM state_compliance_period 
				WHERE assignment_type_id=@assignment_type_id 
				AND state_id = @state_id
				AND from_month = @from_month
				AND to_month= @to_month
				AND compliance_period_id <> @compliance_period_id)
	BEGIN
			EXEC spa_ErrorHandler -1, 'State Compliance.', 
					'spa_state_properties_compliance', 'DB Error', 
					'Cannot insert duplicate Compliance records.', ''
					RETURN	
	END
	IF EXISTS (SELECT 'x' FROM state_compliance_period 
				WHERE assignment_type_id=@assignment_type_id 
				AND state_id = @state_id
				AND compliance_period_id <> @compliance_period_id
				AND (@from_month between from_month  and to_month
				OR @to_month between from_month and to_month ))
	BEGIN
		EXEC spa_ErrorHandler -1, 'State Compliance.', 
				'spa_state_properties_compliance', 'DB Error', 
				'Compliance period for an Assignment should not overlap.', ''
				RETURN
	END
		UPDATE state_compliance_period
		SET state_id=@state_id,
		assignment_type_id=@assignment_type_id,
		from_month=@from_month,
		to_month=@to_month
		WHERE compliance_period_id=@compliance_period_id

	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR, "State Compliance", 
				"spa_state_properties_compliance", "DB Error", 
			"Error on Updating State Compliance.", ''
	ELSE
		EXEC spa_ErrorHandler 0, 'State Compliance.', 
				'spa_state_properties_compliance', 'Success', 
				'State Compliance successfully Updated.', ''

	
	END
ELSE IF @flag='d'
BEGIN
	DELETE state_compliance_period
	WHERE compliance_period_id=@compliance_period_id
	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR, "State Compliance", 
				"spa_state_properties_compliance", "DB Error", 
				"Error on Deleting State Compliance.", ''
	ELSE
		EXEC spa_ErrorHandler 0, 'State Compliance ', 
				'spa_state_properties_compliance', 'Success', 
				'State Compliance Deleted Successfully .', ''
END