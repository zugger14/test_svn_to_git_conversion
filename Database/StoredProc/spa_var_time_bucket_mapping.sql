IF OBJECT_ID(N'[dbo].[spa_var_time_bucket_mapping]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_var_time_bucket_mapping]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_var_time_bucket_mapping]
	@flag     		   CHAR(1),
	@risk_bucket       INT = NULL,
	@map_id            INT = NULL,
	@effective_date    DATETIME = NULL,
	@from_no_of_months INT = NULL,
	@to_no_of_months   INT = NULL,
	@map_no_of_months  INT = NULL,
	@curve_id          INT = NULL,
	@shift_by 		   CHAR(1) = NULL,
	@shift_value 	   FLOAT = NULL
AS

SET NOCOUNT ON

DECLARE @SQL VARCHAR(5000)

IF @flag = 's' 
BEGIN
	--PRINT @effective_date
	SET @SQL = 'SELECT spcd.curve_name [Risk Bucket],
					   monte_carlo_model_parameter_id,
	                   dbo.FNADateFormat(effective_date) [Effective Date],
	                   vtbm.from_no_of_months [From No. of Months],
	                   vtbm.to_no_of_months [To No. of Months],
	                   vtbm.map_no_of_months [Map No. Of Months],
	                   vtbm.curve_id [Curve ID],
	                   map_id [Map ID],
	                   CASE WHEN vtbm.shift_by = ''v'' THEN ''VALUE'' ELSE ''Percentage'' END [Shift By],
	                   vtbm.shift_value [Shift Value]
	            FROM   var_time_bucket_mapping vtbm
	            LEFT JOIN source_price_curve_def spcd ON  spcd.source_curve_def_id = vtbm.risk_bucket
	            WHERE  1 = 1'
		
	IF (@map_id IS NOT NULL) 
	BEGIN
		SET @SQL = @SQL + ' AND vtbm.map_id=' + CAST(@map_id AS VARCHAR)
	END
	
	IF (@effective_date IS NOT NULL) 
	BEGIN
		SET @SQL = @SQL + ' AND vtbm.effective_date>=''' + CAST(@effective_date AS VARCHAR) + ''''
	END
	
	IF (@curve_id IS NOT NULL) 
	BEGIN
		SET @SQL = @SQL + ' AND vtbm.curve_id=' + CAST(@curve_id AS VARCHAR)
	END
	
	IF (@curve_id IS NULL) 
	BEGIN
		SET @SQL = @SQL + ' AND vtbm.curve_id=0'
	END
	
	--PRINT(@SQL)
	EXEC(@SQL)

END

ELSE IF @flag = 'g' 
BEGIN
	SET @SQL = 'SELECT map_id,
					   vtbm. effective_date,
	                   vtbm.from_no_of_months,
	                   vtbm.to_no_of_months,
	                   vtbm.map_no_of_months,
	                   vtbm.risk_bucket,
					   vtbm.shift_by,
					   vtbm.shift_value,
					   vtbm.curve_id
	            FROM var_time_bucket_mapping vtbm
	            LEFT JOIN source_price_curve_def spcd ON  spcd.source_curve_def_id = vtbm.risk_bucket
	            WHERE  vtbm.curve_id =' + cast (@curve_id AS VARCHAR)
		
	IF (@map_id IS NOT NULL) 
	BEGIN
		SET @SQL = @SQL + ' AND vtbm.map_id=' + CAST(@map_id AS VARCHAR)
	END
	
	--IF (@effective_date IS NOT NULL) 
	--BEGIN
	--	SET @SQL = @SQL + ' AND vtbm.effective_date>=''' + CAST(@effective_date AS VARCHAR) + ''''
	--END
	
	IF (@curve_id IS NOT NULL) 
	BEGIN
		SET @SQL = @SQL + ' AND vtbm.curve_id=' + CAST(@curve_id AS VARCHAR)
	END
	
	--IF (@curve_id IS NULL) 
	--BEGIN
	--	SET @SQL = @SQL + ' AND vtbm.curve_id=0'
	--END
	
	EXEC(@SQL)
END

ELSE IF @flag = 'a' 
BEGIN
	SET @SQL = 'SELECT map_id,
	                   dbo.FNADateFormat(effective_date),
	                   from_no_of_months,
	                   to_no_of_months,
	                   map_no_of_months,
	                   curve_id,
	                   risk_bucket,
	                   shift_by,
	                   shift_value
	            FROM   var_time_bucket_mapping
	            WHERE  1 = 1'

	IF (@map_id IS NOT NULL)
	BEGIN
	    SET @SQL = @SQL + ' AND map_id=' + CAST(@map_id AS VARCHAR)
	END
	
	IF (@effective_date IS NOT NULL)
	BEGIN
	    SET @SQL = @SQL + ' AND effective_date=''' + CAST(dbo.FNADateFormat(@effective_date) AS VARCHAR) + ''''
	END
	
	--PRINT(@SQL)
	EXEC(@SQL)
	
END

ELSE IF @flag = 'i' 
BEGIN
	IF EXISTS (SELECT 1 FROM var_time_bucket_mapping vtbm
	           WHERE  vtbm.effective_date = @effective_date
	                AND vtbm.curve_id = @curve_id
	                AND (@from_no_of_months BETWEEN vtbm.from_no_of_months AND vtbm.to_no_of_months
	                        OR @to_no_of_months BETWEEN vtbm.from_no_of_months AND vtbm.to_no_of_months
	                    ))
	BEGIN
		EXEC spa_ErrorHandler -1,
		     'Var Time Bucket Mapping',
		     'spa_var_time_bucket_mapping',
		     'DB Error',
		     'Range already occupied for same effective date.',
		     ''
	END
	ELSE
	BEGIN
		INSERT INTO var_time_bucket_mapping
		  (
		    effective_date,
		    from_no_of_months,
		    to_no_of_months,
		    map_no_of_months,
		    curve_id,
		    risk_bucket,
		    shift_by,
		    shift_value
		  )
		VALUES
		  (
		    @effective_date,
		    @from_no_of_months,
		    @to_no_of_months,
		    @map_no_of_months,
		    @curve_id,
		    @risk_bucket,
		    @shift_by,
		    @shift_value
		  )
		
		IF @@ERROR <> 0
		    EXEC spa_ErrorHandler 1,
		         'Var Time Bucket Mapping',
		         'spa_var_time_bucket_mapping',
		         'DB Error',
		         'Error in Insert.',
		         ''
		ELSE
		    EXEC spa_ErrorHandler 0,
		         'Var Time Bucket Mapping',
		         'spa_var_time_bucket_mapping',
		         'Success',
		         'Data Successfully saved.',
		         'Recommendation'
	END
END

ELSE IF @flag = 'u' 
BEGIN
	IF EXISTS (SELECT 1 FROM var_time_bucket_mapping vtbm WHERE vtbm.effective_date = @effective_date 
				AND vtbm.map_id <> @map_id
				AND vtbm.curve_id =  @curve_id 
				AND (@from_no_of_months BETWEEN vtbm.from_no_of_months AND vtbm.to_no_of_months
					OR @to_no_of_months BETWEEN vtbm.from_no_of_months AND vtbm.to_no_of_months)
				)
	BEGIN
		EXEC spa_ErrorHandler -1,
		     'Var Time Bucket Mapping',
		     'spa_var_time_bucket_mapping',
		     'DB Error',
		     'Range already occupied for same effective date.',
		     ''
	END
	ELSE
	BEGIN
		UPDATE var_time_bucket_mapping
		SET    effective_date = @effective_date,
		       from_no_of_months = @from_no_of_months,
		       to_no_of_months = @to_no_of_months,
		       map_no_of_months = @map_no_of_months,
		       curve_id = @curve_id,
		       risk_bucket = @risk_bucket,
		       shift_by = @shift_by,
		       shift_value = @shift_value
		WHERE  map_id = @map_id
		
		IF @@ERROR <> 0
			EXEC spa_ErrorHandler 1,
			     'Var Time Bucket Mapping',
			     'spa_var_time_bucket_mapping',
			     'DB Error',
			     'Error in Update.',
			     ''
		ELSE
			EXEC spa_ErrorHandler 0,
			     'Var Time Bucket Mapping',
			     'spa_var_time_bucket_mapping',
			     'Success',
			     'Data Successfully Updated.',
			     'Recommendation'
	END
END

ELSE IF @flag = 'd'
BEGIN
	DELETE FROM var_time_bucket_mapping WHERE  map_id = @map_id

	IF @@ERROR <> 0
			EXEC spa_ErrorHandler 1,
			     'Var Time Bucket Mapping',
			     'spa_var_time_bucket_mapping',
			     'DB Error',
			     'Error in Delete.',
			     ''
		ELSE
			EXEC spa_ErrorHandler 0,
			     'Var Time Bucket Mapping',
			     'spa_var_time_bucket_mapping',
			     'Status',
			     'Data Successfully Deleted.',
			     'Recommendation'

END


