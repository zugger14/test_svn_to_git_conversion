IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_state_properties_duration]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_state_properties_duration]
GO 
--exec spa_state_properties_duration 's', 5118
CREATE Procedure [dbo].[spa_state_properties_duration]
	@flag char(1)=null,
	@state_value_id INT=null,
	@technology int=null,
	@duration int=null,
	@offset_duration int=NULL,
	@assignment_type_Value_id int=null,
	@banking_period_frequency int=NULL,
	@duration_id VARCHAR(100)=NULL,
	@gen_code_value int=NULL,
	@curve_id int=null,
	@not_expire char(1)=NULL,
	@cert_entity INT=NULL
AS
IF @flag='s'
BEGIN
SELECT  duration_id, 
	--d.assignment_type_Value_id AS assignment_type_Value_id,
	d.technology AS  [technology],
	d.curve_id AS [curve_id],
	d.banking_period_frequency AS [banking_period_frequency],
	d.not_expire, 
	d.gen_code_value AS [gen_code_value],
	d.duration AS [duration],
	d.offset_duration AS [offset_duration],
	d.state_value_id	
	--s.Code [Assg State],
	--s5.code [Banking Rules]
FROM  state_properties_duration d 
WHERE state_value_id = @state_value_id 
END 

if @flag='a'
begin
	SELECT    state_value_id, technology,duration,offset_duration,
			  --assignment_type_Value_id,
			  banking_period_frequency,duration_id,gen_code_value,curve_id,not_expire,cert_entity
	FROM      state_properties_duration where duration_id=@duration_id
end
if @flag='i'
begin
	
	if exists(select duration_id from state_properties_duration where 
		ISNULL(state_value_id,0) = ISNULL(@state_value_id,0) and
		ISNULL(technology,0) = ISNULL(@technology,0) and
		--ISNULL(assignment_type_Value_id, 0) = ISNULL(@assignment_type_Value_id, 0) and
		ISNULL(gen_code_value,0) = ISNULL(@gen_code_value,0)
		AND ISNULL(curve_id,0) = ISNULL(@curve_id,0)
		)
	begin
		Exec spa_ErrorHandler -1, "Can not insert duplicate values.",
				"spa_state_properties", "DB Error", 
			"Can not insert duplicate values.", ''
		return
	end	

	insert state_properties_duration(
		state_value_id,	
		technology,	
		duration,	
		offset_duration,
		--assignment_type_Value_id,
		banking_period_frequency,
		gen_code_value,
		curve_id,
		not_expire,
		cert_entity
	)
	values(
		@state_value_id,
		@technology,
		@duration,
		@offset_duration,
		--@assignment_type_Value_id,
		@banking_period_frequency,
		@gen_code_value,
		@curve_id,
		@not_expire,
		@cert_entity	
	)

	
	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "State Properties", 
			"spa_state_properties", "DB Error", 
			"Error on Inserting State Properties.", ''
	else
		Exec spa_ErrorHandler 0, 'State Properties Duration', 
			'spa_state_properties_Duration', 'Success', 
			'State Properties Duration successfully inserted.', ''
end
if @flag='u'
begin
if exists(select duration_id from state_properties_duration where 
		ISNULL(state_value_id,0) = ISNULL(@state_value_id,0) and
		ISNULL(technology,0) = ISNULL(@technology,0) and
		--ISNULL(assignment_type_Value_id, 0) = ISNULL(@assignment_type_Value_id, 0) and
		ISNULL(gen_code_value,0) = ISNULL(@gen_code_value,0)
		AND duration_id <> @duration_id	
		AND ISNULL(curve_id,0) = ISNULL(@curve_id,0)
		)
	
	begin
		Exec spa_ErrorHandler -1, "Can not Update duplicate values.",
				"spa_state_properties", "DB Error", 
			"Can not Update duplicate values.", ''
		return
	end	

	update state_properties_duration
		set 
		 technology=@technology,
		duration=@duration,
		offset_duration=@offset_duration,
		--assignment_type_Value_id=@assignment_type_Value_id,
		banking_period_frequency=@banking_period_frequency,
		gen_code_value=@gen_code_value,
		curve_id=@curve_id,
		not_expire=@not_expire,
		cert_entity=@cert_entity
	where duration_id=@duration_id

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "State Properties", 
				"spa_state_properties", "DB Error", 
			"Error on Updating State Properties.", ''
	else
		Exec spa_ErrorHandler 0, 'State Properties Duration', 
				'spa_state_properties_Duration', 'Success', 
				'State Properties Duration successfully Updated.', ''
end
if @flag='d'
BEGIN
	DECLARE @sql_string VARCHAR(MAX)
	
	SET @sql_string = ' DELETE 
	                    FROM   state_properties_duration
	                    WHERE  duration_id IN (' + @duration_id + ')'
						
	PRINT (@sql_string)
	EXEC  (@sql_string)
	
	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "State Properties", 
				"spa_state_properties", "DB Error", 
			"Error on Updating State Properties.", ''
	else
		Exec spa_ErrorHandler 0, 'State Properties Duration', 
				'spa_state_properties_duration', 'Success', 
				'State Properties Duration successfully Removed.', ''
end











