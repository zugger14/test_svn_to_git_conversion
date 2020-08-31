

IF EXISTS (SELECT * FROM sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_state_rec_requirement_data]') AND TYPE IN (N'P', N'PC'))
    DROP PROCEDURE [dbo].[spa_state_rec_requirement_data]
GO 

CREATE PROCEDURE [dbo].[spa_state_rec_requirement_data]
	@flag CHAR(1),
	@state_value_id VARCHAR(100) = NULL,
	@compliance_year INT = NULL,
	@renewable_target FLOAT = NULL,
	@per_profit_give_back FLOAT = NULL,
	@assignment_type_id VARCHAR(100) = NULL,
    @from_year INT = NULL, 
    @to_year INT = NULL,
    @requirement_type_id INT = NULL,
    @rec_assignment_priority_group_id INT = NULL,
    @state_rec_requirement_data_id INT = NULL
AS 
	SET NOCOUNT ON
	DECLARE @compliance_year_id INT
	IF @compliance_year IS NOT NULL 
	BEGIN 
		SELECT @compliance_year_id = sdv.value_id 
		FROM state_rec_requirement_data srrd
		LEFT JOIN static_data_value sdv ON srrd.compliance_year = sdv.value_id
		WHERE sdv.code = @compliance_year AND sdv.[type_id] = 10092
	END 
	
	IF @flag = 'f'
	BEGIN
	    SELECT TOP 1 
	           s.Code,
	           compliance_year [ComplianceYear],
	           renewable_target [Total Absolute target(MWh)],
	           per_profit_give_back [Total Compliance Target (%)]
	    FROM   state_rec_requirement_data d
	           JOIN static_data_value s
	                ON  d.state_value_id = s.value_id
	    WHERE  state_value_id = @state_value_id
	    ORDER BY
	           compliance_Year DESC
	END
	
	IF @flag = 's'
	BEGIN
		DECLARE @sql VARCHAR(5000) 
	
	    set @sql = 'SELECT state_rec_requirement_data_id,
					   state_value_id,
					   --sdv.code [assignment_type],
					   CASE WHEN rapg.rec_assignment_priority_group_name IS NULL THEN ''FIFO Vintage'' ELSE rapg.rec_assignment_priority_group_name END [assignment_priority],
					   from_year [from_year],
					   to_year [to_year],
					   CAST(renewable_target AS NUMERIC(20, 2)) [total_absolute_target],
					   CAST(per_profit_give_back AS NUMERIC(20, 2)) [total_compliance_target]
				FROM   state_rec_requirement_data srrd
					   LEFT JOIN rec_assignment_priority_group rapg
							ON  rapg.rec_assignment_priority_group_id = srrd.rec_assignment_priority_group_id
					   LEFT JOIN static_data_value sdv
							ON  srrd.assignment_type_id = sdv.value_id
					   LEFT JOIN static_data_value sdv1
							ON  srrd.state_value_id = sdv1.value_id
				WHERE  1 = 1'
	    IF @state_value_id IS NOT NULL 
			SET @sql = @sql + ' AND state_value_id = ' + cast(@state_value_id AS VARCHAR(50))
		
		IF @assignment_type_id	IS NOT NULL
			set @sql = @sql + ' AND assignment_type_id = ' + cast(@assignment_type_id AS VARCHAR(50))
		IF @from_year	IS NOT NULL AND @to_year IS NOT NULL
			set @sql = @sql + ' AND from_year >= ''' + @from_year 
							+ ''' AND to_year <= ''' + @to_year + ''''
		IF @from_year IS NOT NULL AND @to_year IS NULL
			set @sql = @sql + ' AND from_year >= ''' + @from_year + ''''
		IF @to_year IS NOT NULL AND @from_year IS NULL
			set @sql = @sql + ' AND to_year <= ''' + @to_year + ''''
		
		--PRINT(@sql)
		EXEC(@sql)
	END
	
	IF @flag = 'a'
	BEGIN
	    SELECT state_value_id,
	           --compliance_year,
	           renewable_target,
	           per_profit_give_back,
	           assignment_type_id,
	           dbo.fnadateformat(from_year) [from_year],
	           dbo.fnadateformat(to_year) [to_year],
	           rapg.rec_assignment_priority_group_id
	    FROM   state_rec_requirement_data 
	    INNER JOIN rec_assignment_priority_group rapg  ON  rapg.rec_assignment_priority_group_id = state_rec_requirement_data.rec_assignment_priority_group_id 
	    WHERE  state_value_id = @state_value_id
	           AND from_year = @from_year AND to_year = @to_year AND assignment_type_id = @assignment_type_id
	END
	
	IF @flag = 'i'
	BEGIN
		IF EXISTS(SELECT 1 FROM state_rec_requirement_data WHERE  from_year =  @from_year AND  to_year =  @to_year AND assignment_type_id = @assignment_type_id AND state_value_id = @state_value_id)
		BEGIN 
			EXEC spa_ErrorHandler -1
				 , 'State Properties Requirement Data'
				 , 'spa_state_rec_requirement_data'
				 , 'Error'
				 , 'Requirement already defined for year in <b>From Year</b> and <b>To Year</b>.'
				 , ''
				 RETURN
		END

		IF EXISTS(SELECT 1 FROM state_rec_requirement_data WHERE  from_year =  @from_year AND assignment_type_id = @assignment_type_id AND state_value_id = @state_value_id)
		BEGIN 
			EXEC spa_ErrorHandler -1
				 , 'State Properties Requirement Data'
				 , 'spa_state_rec_requirement_data'
				 , 'Error'
				 , 'Requirement already defined for year in <b>From Month</b>.'
				 , ''
				 RETURN
		END
		IF EXISTS(SELECT 1 FROM state_rec_requirement_data WHERE  to_year =  @to_year AND assignment_type_id = @assignment_type_id AND state_value_id = @state_value_id)
		BEGIN 
			EXEC spa_ErrorHandler -1
				 , 'State Properties Requirement Data'
				 , 'spa_state_rec_requirement_data'
				 , 'Error'
				 , 'Requirement already defined for year in <b>To Month</b>.'
				 , ''
				 RETURN
		END
		 
		IF EXISTS(SELECT 1 FROM state_rec_requirement_data WHERE from_year = @from_year AND to_year = @to_year AND state_value_id = @state_value_id AND assignment_type_id = @assignment_type_id)
		BEGIN 
			EXEC spa_ErrorHandler -1
				 , 'State Properties Requirement Data'
				 , 'spa_state_rec_requirement_data'
				 , 'Information'
				 , 'The Total Absolute Target/Total Compliance Target for the given term already exists.'
				 , ''
		END
		ELSE
		BEGIN 
			INSERT state_rec_requirement_data
			  (
				state_value_id,
				compliance_year,
				renewable_target,
				per_profit_give_back,
				assignment_type_id,
				from_year, 
				to_year,
				requirement_type_id,
				rec_assignment_priority_group_id	 
			  )
			VALUES
			  (
				@state_value_id,
				@compliance_year,
				CASE WHEN @renewable_target = '' THEN NULL ELSE @renewable_target END,
				CASE WHEN @per_profit_give_back = '' THEN NULL ELSE @per_profit_give_back END,
				@assignment_type_id,
				CASE WHEN @from_year = '' THEN NULL ELSE @from_year END, 
				CASE WHEN @to_year = '' THEN NULL ELSE @to_year END,
				@requirement_type_id,
				@rec_assignment_priority_group_id	
			  )
			  
			  DECLARE @inserted_ID INT = (SELECT SCOPE_IDENTITY())
			  
			  EXEC spa_ErrorHandler 0
				 , 'State Properties Requirement Data'
				 , 'spa_state_rec_requirement_data'
				 , 'Success'
				 , 'Changes have been Saved Successfully.'
				 , @inserted_ID
		END	
	END
	
	IF @flag = 'u'
	BEGIN
	    UPDATE state_rec_requirement_data
	    SET    renewable_target = CASE WHEN @renewable_target = '' THEN NULL ELSE @renewable_target END,
	           per_profit_give_back = CASE WHEN @per_profit_give_back = '' THEN NULL ELSE @per_profit_give_back END,
	           rec_assignment_priority_group_id = @rec_assignment_priority_group_id
	          ,assignment_type_id = @assignment_type_id
			   ,from_year = CASE WHEN @from_year = '' THEN NULL ELSE @from_year END, 
			   to_year = CASE WHEN @to_year = '' THEN NULL ELSE @to_year END
	    WHERE  state_rec_requirement_data_id = @state_rec_requirement_data_id
	    EXEC spa_ErrorHandler 0
				 , 'State Properties Requirement Data'
				 , 'spa_state_rec_requirement_data'
				 , 'Success'
				 , 'Changes have been Saved Successfully.'
				 , 'update_mode'
	END
	
	IF @flag = 'd'
	BEGIN
		DECLARE @sql_st VARCHAR(MAX)
		CREATE TABLE #temp (VALUE VARCHAR(100) COLLATE DATABASE_DEFAULT )
		SET @sql_st = 'INSERT into #temp SELECT srrd.from_year FROM  
												state_rec_requirement_detail srrd
										  INNER JOIN (SELECT  * from dbo.FNAsplit(''' + @from_year + ''', '','')) fm 
									    		ON fm.item = srrd.from_year 
								          INNER JOIN (SELECT  * from dbo.FNAsplit(''' + @to_year + ''', '','')) tm
												ON tm.item = srrd.to_year  
												WHERE  state_value_id IN (' + @state_value_id + ') AND assignment_type_id IN (' + @assignment_type_id + ')'
		--PRINT (@sql_st)
		EXEC (@sql_st)
		
		IF EXISTS(SELECT 1 FROM  #temp)
		BEGIN
			EXEC spa_ErrorHandler -1
				 , 'State Properties Requirement Data'
				 , 'spa_state_rec_requirement_data'
				 , 'Error'
				 , 'Selected data is in use and cannot be deleted.'
				 , ''
	    END
	    ELSE
	    BEGIN
	    	DECLARE @sql_string VARCHAR(MAX)
			
			SET @sql_string =  'DELETE srrd FROM 
								state_rec_requirement_data srrd
								INNER JOIN (SELECT  * from dbo.FNAsplit(''' + @from_year + ''', '','')) fm 
								ON fm.item = srrd.from_year 
								INNER JOIN (SELECT  * from dbo.FNAsplit(''' + @to_year + ''', '','')) tm
								ON tm.item = srrd.to_year  
								WHERE  state_value_id IN (' + @state_value_id + ') AND assignment_type_id IN (' + @assignment_type_id + ')'
  								
			--PRINT (@sql_string)
			EXEC  (@sql_string)
			       
			EXEC spa_ErrorHandler 0
				 , 'State Properties Requirement Data'
				 , 'spa_state_rec_requirement_data'
				 , 'Success'
				 , 'Requirement successfully removed.'
				 , ''	
	    END	    
	END
