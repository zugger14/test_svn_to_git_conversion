IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_state_properties_bonus]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_state_properties_bonus]
GO 
--exec spa_state_properties_bonus 's', 5118
CREATE Procedure [dbo].[spa_state_properties_bonus]
	@flag char(1)=null,
	@state_value_id int=null,
	@technology int=null,
	@from_date datetime=null,
	@to_date datetime=null,
	@bonus_per float=null,
	@assignment_type_Value_id int=NULL,
	@bonus_id VARCHAR(100)=NULL,
	@gen_code_value int =NULL,
	@curve_id int=null

AS
IF @flag='s'
BEGIN 	
SELECT  bonus_id,
	d.technology AS [technology],
	d.gen_code_value AS [gen_code_value], 
	--d.assignment_type_Value_id AS [assignment_type_Value_id],
	(d.from_date) [from_date], 
	(d.to_date) [to_date], 
	d.bonus_per AS [bonus_per],
	d.curve_id AS [curve_id],
	d.state_value_id
FROM state_properties_bonus d 
WHERE state_value_id=@state_value_id
END 

if @flag='a'
begin
	SELECT    state_value_id, technology, dbo.FNADateFormat(from_date) from_date,
	 dbo.FNADateFormat(to_date) to_dateduration, bonus_per,
	 --assignment_type_Value_id,
	 bonus_id,gen_code_value,curve_id
	FROM      state_properties_bonus where bonus_id=@bonus_id
end
if @flag='i'
begin
	insert state_properties_bonus(
		state_value_id,	
		technology,	
		from_date,
		to_date,	
		bonus_per,
		--assignment_type_Value_id,
		gen_code_value,
		curve_id
	)
	values(
		@state_value_id,
		@technology,
		@from_date,
		@to_date,
		@bonus_per,
		--@assignment_type_Value_id,
		@gen_code_value,
		@curve_id
	)

		If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "State Properties", 
				"spa_state_properties_bonus", "DB Error", 
			"Error on Inserting State Properties.", ''
	else
		Exec spa_ErrorHandler 0, 'State Properties Bonus', 
				'spa_state_properties_Bonus', 'Success', 
				'State Properties Bonus successfully inserted.', ''
end
if @flag='u'
begin
	update state_properties_bonus
		set technology=@technology,
		from_date=@from_date,
		to_date=@to_date,
		bonus_per=@bonus_per,
		--assignment_type_Value_id=@assignment_type_Value_id,
		gen_code_value=@gen_code_value,
		curve_id=@curve_id
		where bonus_id=@bonus_id 

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "State Properties", 
				"spa_state_properties", "DB Error", 
			"Error on Updating State Properties.", ''
	else
		Exec spa_ErrorHandler 0, 'State Properties Bonus', 
				'spa_state_properties_bonus', 'Success', 
				'State Properties Bonus successfully Updated.', ''
end
if @flag='d'
BEGIN
	
	DECLARE @sql_string VARCHAR(MAX)
	
	SET @sql_string = ' DELETE 
	                    FROM   state_properties_bonus
	                    WHERE  bonus_id IN (' + @bonus_id + ')'
						
	PRINT (@sql_string)
	EXEC  (@sql_string)
	
	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "State Properties", 
				"spa_state_properties", "DB Error", 
			"Error on Updating State Properties.", ''
	else
		Exec spa_ErrorHandler 0, 'State Properties Duration', 
				'spa_state_properties_bonus', 'Success', 
				'State Properties Bonus successfully Removed.', ''
end









