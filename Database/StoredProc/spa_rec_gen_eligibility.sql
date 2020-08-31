/****** Object:  StoredProcedure [dbo].[spa_rec_gen_eligibility]    Script Date: 08/23/2009 11:59:55 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_rec_gen_eligibility]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_rec_gen_eligibility]
/****** Object:  StoredProcedure [dbo].[spa_rec_gen_eligibility]    Script Date: 08/23/2009 11:59:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[spa_rec_gen_eligibility]
	@flag char(1)=null,
	@id VARCHAR(100)=NULL,
	@state_value_id varchar(100)=null,
	@gen_state_value_id INT=NULL,
	@technology INT=NULL,
	--@program_scope INT=NULL,
	@tier_type INT=NULL,
	@percentage_allocation float=NULL,
	@technology_sub_type VARCHAR(100)=NULL,
	@assignment_type VARCHAR(50)=NULL,
	@from_year INT = NULL, 
	@to_year INT = NULL

AS
SET NOCOUNT ON

if @flag='s'
BEGIN
	DECLARE @sql VARCHAR(MAX)
	SET @sql = 	'SELECT  
						id AS [id],
						--jurisdiction.code AS [Jurisdiction],
						--rge.assignment_type AS [assignment_type],
						(rge.from_year) AS [from_year],
						(rge.to_year) AS [to_year],
						rge.gen_state_value_id AS [gen_state_value_id],
						rge.technology AS [technology],
						rge.technology_sub_type AS [technology_sub_type],
						rge.tier_type AS [tier_type],
						rge.sub_tier_value_id [sub tier], 
						sdv.code AS [state_value_id]									
				FROM   
						rec_gen_eligibility rge		
				LEFT JOIN static_data_value	sdv
					ON 	sdv.value_id = rge.state_value_id 		
				WHERE
					state_value_id=' + @state_value_id
					
				IF @assignment_type IS NOT NULL
					SET @sql = @sql + ' AND assignment_type.value_id = ''' + @assignment_type + ''''
					IF @from_year	IS NOT NULL AND @to_year IS NOT NULL
						SET @sql = @sql + ' AND rge.from_year >= ''' + @from_year 
										+ ''' AND rge.to_year <= ''' +  @to_year  + ''''
					IF @from_year IS NOT NULL AND @to_year IS NULL
						SET @sql = @sql + ' AND rge.from_year >= ''' +@from_year + ''''
					IF @to_year IS NOT NULL AND @from_year IS NULL
						SET @sql = @sql + ' AND rge.to_year <= ''' + @to_year + ''''
				
				--PRINT (@sql)
				EXEC (@sql)

end
if @flag='a'
begin

	SELECT
		id, state_value_id,gen_state_value_id,technology,--program_scope,
		tier_type,percentage_allocation, technology_sub_type, 
		--assignment_type, 
		from_year, to_year
	FROM   
		rec_gen_eligibility 
	WHERE
		[id]=@id

end
if @flag='i'
BEGIN
	IF EXISTS (SELECT 'x' FROM rec_gen_eligibility 
				WHERE 
				ISNULL(CAST(state_value_id AS VARCHAR),'TRUE') = ISNULL(CAST(@state_value_id AS VARCHAR),'TRUE')
				AND ISNULL(CAST(gen_state_value_id AS VARCHAR),'TRUE') = ISNULL(CAST(@gen_state_value_id AS VARCHAR),'TRUE')
				AND ISNULL(CAST(technology AS VARCHAR),'TRUE') = ISNULL(CAST(@technology AS VARCHAR),'TRUE')
				--AND ISNULL(CAST(program_scope AS VARCHAR),'TRUE') = ISNULL(CAST(@program_scope AS VARCHAR),'TRUE')
				AND ISNULL(CAST(tier_type AS VARCHAR),'TRUE') = ISNULL(CAST(@tier_type AS VARCHAR),'TRUE')
				AND ISNULL(CAST(percentage_allocation AS VARCHAR),'TRUE') = ISNULL(CAST(@percentage_allocation AS VARCHAR),'TRUE')
				AND ISNULL(CAST(technology_sub_type AS VARCHAR),'TRUE') = ISNULL(CAST(@technology_sub_type AS VARCHAR),'TRUE')
				--AND ISNULL(CAST(assignment_type AS VARCHAR),'TRUE') = ISNULL(CAST(@assignment_type AS VARCHAR),'TRUE')
				AND ISNULL(CAST(from_year AS VARCHAR),'TRUE') = ISNULL(CAST(@from_year AS VARCHAR),'TRUE')
				AND ISNULL(CAST(to_year AS VARCHAR),'TRUE') = ISNULL(CAST(@to_year AS VARCHAR),'TRUE')			
	)
	BEGIN
			Exec spa_ErrorHandler -1, 'The selected Eligibility information already exists.', 
					'spa_rec_gen_eligibility', 'DB Error', 
					'The selected Eligibility information already exists.', ''
					return	
	END
	
    IF  @from_year > @to_year
    BEGIN
    	EXEC spa_ErrorHandler -1,
    	     'rec_gen_eligibility',
    	     'spa_rec_gen_eligibility',
    	     'DB Error',
    	     'From month should be less than To month',
    	     ''
    	
    	RETURN	
    END
    
	INSERT   rec_gen_eligibility(
			state_value_id,
			gen_state_value_id,
			technology,
			--program_scope,
			tier_type,
			percentage_allocation,
			technology_sub_type,
			--assignment_type,
			from_year,
			to_year
		)
		values(
			@state_value_id,
			@gen_state_value_id,
			@technology,
			--@program_scope,
			@tier_type,
			@percentage_allocation,
			@technology_sub_type,
			--@assignment_type,
			@from_year, 
			@to_year
		)

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Rec Gen Eligibility", 
				"spa_rec_gen_eligibility", "DB Error", 
			"Error on Inserting Rec GEN Eligibility.", ''
	else
		Exec spa_ErrorHandler 0, 'Rec GEN Eligibility', 
				'spa_rec_gen_eligibility', 'Success', 
				'Rec GEN Eligibility successfully inserted.', ''
end
if @flag='u'
BEGIN
	IF EXISTS (SELECT 'x' FROM rec_gen_eligibility 
				WHERE 
				ISNULL(CAST(state_value_id AS VARCHAR),'TRUE') = ISNULL(CAST(@state_value_id AS VARCHAR),'TRUE')
				AND ISNULL(CAST(gen_state_value_id AS VARCHAR),'TRUE') = ISNULL(CAST(@gen_state_value_id AS VARCHAR),'TRUE')
				AND ISNULL(CAST(technology AS VARCHAR),'TRUE') = ISNULL(CAST(@technology AS VARCHAR),'TRUE')
				--AND ISNULL(CAST(program_scope AS VARCHAR),'TRUE') = ISNULL(CAST(@program_scope AS VARCHAR),'TRUE')
				AND ISNULL(CAST(tier_type AS VARCHAR),'TRUE') = ISNULL(CAST(@tier_type AS VARCHAR),'TRUE')
				AND ISNULL(CAST(percentage_allocation AS VARCHAR),'TRUE') = ISNULL(CAST(@percentage_allocation AS VARCHAR),'TRUE')
				AND ISNULL(CAST(technology_sub_type AS VARCHAR),'TRUE') = ISNULL(CAST(@technology_sub_type AS VARCHAR),'TRUE')
				--AND ISNULL(CAST(assignment_type AS VARCHAR),'TRUE') = ISNULL(CAST(@assignment_type AS VARCHAR),'TRUE')
				AND ISNULL(CAST(from_year AS VARCHAR),'TRUE') = ISNULL(CAST(@from_year AS VARCHAR),'TRUE')
				AND ISNULL(CAST(to_year AS VARCHAR),'TRUE') = ISNULL(CAST(@to_year AS VARCHAR),'TRUE')	
				AND id<>@id)
	BEGIN
			Exec spa_ErrorHandler -1, 'The selected Eligibility information already exists.', 
					'spa_rec_gen_eligibility', 'DB Error', 
					'The selected Eligibility information already exists.', ''
					return	
	END

	UPDATE   rec_gen_eligibility
		SET 
			gen_state_value_id=@gen_state_value_id,
			technology=@technology,
			--program_scope=@program_scope,
			tier_type=@tier_type,
			percentage_allocation=@percentage_allocation,
		    technology_sub_type=@technology_sub_type,
		    --assignment_type=@assignment_type,
		    from_year = @from_year,
		    to_year = @to_year
	where 	[id]=@id
	
	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Rec Gen Eligibility", 
				"spa_rec_gen_eligibility", "DB Error", 
			"Error on Updating Rec GEN Eligibility.", ''
	else
		Exec spa_ErrorHandler 0, 'Rec GEN Eligibility', 
				'spa_rec_gen_eligibility', 'Success', 
				'Rec GEN Eligibility successfully Updated.', ''

end
if @flag='d'
BEGIN
	DECLARE @sql_string VARCHAR(MAX)
	
	SET @sql_string = ' DELETE 
	                    FROM   rec_gen_eligibility
	                    WHERE  [id] IN (' + @id + ')'
						
	--PRINT (@sql_string)
	EXEC  (@sql_string)

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Rec Gen Eligibility", 
				"spa_rec_gen_eligibility", "DB Error", 
			"Error on deleting Rec GEN Eligibility.", ''
	else
		Exec spa_ErrorHandler 0, 'Rec GEN Eligibility', 
				'spa_rec_gen_eligibility', 'Success', 
				'Rec GEN Eligibility successfully deleted.', ''
end








