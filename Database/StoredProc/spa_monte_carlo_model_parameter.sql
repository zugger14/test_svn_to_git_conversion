IF OBJECT_ID(N'[dbo].[spa_monte_carlo_model_parameter]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_monte_carlo_model_parameter]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2012-02-21
-- Description: CRUD operations for table monte_carlo_model_parameter

-- Params:
-- @flag CHAR(1) - Operation flag
-- @id INT - system generated id for model
-- @name VARCHAR(100) - name for model
-- @volatility VARCHAR(100) - volatility - either any integer value or 'c' - calculate or 'e' - use existing value
-- @drift VARCHAR(100) - drift - either any integer value or 'c' - calculate or 'e' - use existing value
-- @seed VARCHAR(100) either any DATE value or 'c' - calculate or 'e' - use existing value
-- @data_series INT - data series id
-- @curve_source INT - curve source id
-- @mean_reversion_type CHAR(1) - mean revision type - a - arithmetic & g - geometric
-- @mean_reversion_rate VARCHAR(100) - either any integer value or 'c' - calculate
-- @mean_reversion_level VARCHAR(100) - either any integer value or 'c' - calculate
-- EXEC spa_monte_carlo_model_parameter 'u'
-- ===========================================================================================================

CREATE PROCEDURE [dbo].[spa_monte_carlo_model_parameter]
    @flag CHAR(1),
    @id INT = NULL,
    @name VARCHAR(100) = NULL,
    @volatility VARCHAR(100) = NULL,
    @drift VARCHAR(100) = NULL,
    @seed VARCHAR(100) = NULL,
    @data_series INT = NULL,
    @curve_source INT = NULL,
    @mean_reversion_type CHAR(1) = NULL,
    @mean_reversion_rate VARCHAR(100) = NULL,
    @mean_reversion_level VARCHAR(100) = NULL,
    @apply_mean_reversion CHAR(1),
    @volatility_method VARCHAR(100) = NULL,
    @vol_data_series INT,
    @vol_data_points FLOAT = NULL,
    @vol_lambda FLOAT = NULL,
    @vol_long_run_volatility FLOAT = NULL,
    @vol_alpha FLOAT = NULL,
    @vol_beta FLOAT = NULL,
    @vol_gamma FLOAT = NULL,
    @calculate_relative_volatility CHAR(1),
	@volatility_source INT = NULL 
AS
DECLARE @sql VARCHAR(MAX)
DECLARE @desc VARCHAR(500)
DECLARE @err_no INT
DECLARE @err_msg VARCHAR(200)
DECLARE @monte_carlo_parameter_id INT
		
IF @flag = 'i'
BEGIN
	BEGIN TRY
    	IF EXISTS(SELECT 1 FROM monte_carlo_model_parameter WHERE monte_carlo_model_parameter_name = @name)
    	BEGIN
			EXEC spa_ErrorHandler -1,
			'monte_carlo_model_parameter',
			'spa_monte_carlo_model_parameter',
			'Error',
			'Monte Carlo Model name already exists',
			@name
    	END
    	ELSE
    	BEGIN
    		INSERT INTO monte_carlo_model_parameter(monte_carlo_model_parameter_name, volatility, drift, seed, data_series, curve_source, mean_reversion_type, mean_reversion_rate, mean_reversion_level, apply_mean_reversion, volatility_method, vol_data_series, vol_data_points, lambda, vol_long_run_volatility, vol_alpha, vol_beta, vol_gamma, relative_volatility, volatility_source)
			VALUES (@name, @volatility, @drift, @seed, @data_series, @curve_source, @mean_reversion_type, @mean_reversion_rate, @mean_reversion_level, @apply_mean_reversion, @volatility_method, @vol_data_series, @vol_data_points, @vol_lambda, @vol_long_run_volatility, @vol_alpha, @vol_beta, @vol_gamma, @calculate_relative_volatility, @volatility_source) 
	    	
	    	SET @monte_carlo_parameter_id = SCOPE_IDENTITY()
	    	
			EXEC spa_ErrorHandler 0,
				 'monte_carlo_model_parameter',
				 'spa_monte_carlo_model_parameter',
				 'Success',
				 'Data Successfully Saved.',
    			 @monte_carlo_parameter_id
    	END
	END TRY
    BEGIN CATCH
		SET @err_msg = ERROR_MESSAGE()
	    
		IF @@TRANCOUNT > 0
			ROLLBACK
		
		SET @desc = 'Fail to insert Data ( Errr Description:' + @err_msg + ').'
		
		SELECT @err_no = ERROR_NUMBER()
		
		EXEC spa_ErrorHandler @err_no,
			 'monte_carlo_model_parameter',
			 'spa_monte_carlo_model_parameter',
			 'Error',
			 @desc,
			 @err_msg
    END CATCH
END
IF @flag = 'u'
BEGIN
	BEGIN TRY
		IF EXISTS(SELECT 1 FROM monte_carlo_model_parameter WHERE monte_carlo_model_parameter_name = @name AND monte_carlo_model_parameter_id <> @id)
    	BEGIN
			EXEC spa_ErrorHandler -1,
			'monte_carlo_model_parameter',
			'spa_monte_carlo_model_parameter',
			'Error',
			'Monte Carlo Model name already exists',
			@name
    	END
    	ELSE
    	BEGIN
    		--UPDATE	monte_carlo_model_parameter
    		--SET		monte_carlo_model_parameter_name = @name,
    		--		volatility = @volatility,
    		--		drift = @drift,
    		--		data_series = @data_series,
    		--		mean_reversion_type = @mean_reversion_type,
    		--		mean_reversion_rate = @mean_reversion_rate,
    		--		mean_reversion_level = @mean_reversion_level,
    		--		curve_source = @curve_source,
    		--		seed = @seed,
    		--		apply_mean_reversion = @apply_mean_reversion
    		--WHERE monte_carlo_model_parameter_id = @id  
    		SET @sql = '
					UPDATE	monte_carlo_model_parameter 
					SET		monte_carlo_model_parameter_name = ''' + ISNULL(@name, 'NULL') + ''',
							volatility = ''' + ISNULL(@volatility, 'NULL') + ''',
							drift = ''' + ISNULL(@drift, 'NULL') + ''',
							seed = ''' + ISNULL(@seed, 'NULL') + ''',
							data_series = ' + CAST(ISNULL(@data_series, '') AS VARCHAR(100)) + ',
							volatility_method = ''' + @volatility_method + ''', 
    						vol_data_series = ' + CAST(@vol_data_series AS VARCHAR) + ', 
    						vol_data_points = ' + ISNULL(CAST(@vol_data_points AS VARCHAR(100)), 'NULL') + ', 
    						lambda = ' + ISNULL(CAST(@vol_lambda AS VARCHAR(100)), 'NULL') + ', 
    						vol_long_run_volatility = ' + ISNULL(CAST(@vol_long_run_volatility AS VARCHAR(100)), 'NULL') + ', 
    						vol_alpha = ' + ISNULL(CAST(@vol_alpha AS VARCHAR(100)), 'NULL') + ', 
    						vol_beta = ' + ISNULL(CAST(@vol_beta AS VARCHAR(100)), 'NULL') + ', 
    						vol_gamma = ' + ISNULL(CAST(@vol_gamma AS VARCHAR(100)), 'NULL') + ',
    						relative_volatility = ''' + @calculate_relative_volatility + ''',
							volatility_source = ' + CAST(ISNULL(@volatility_source, '') AS VARCHAR(100)) + ''
		
			IF @apply_mean_reversion = 'y' 
				SET @sql = @sql + ', mean_reversion_type = ''' + @mean_reversion_type + ''''
			
			IF @apply_mean_reversion IS NOT NULL
				SET @sql = @sql + ', apply_mean_reversion = ''' + @apply_mean_reversion + '''' 
			
			IF @apply_mean_reversion = 'y'
				SET @sql = @sql + ', mean_reversion_rate = ''' + @mean_reversion_rate + '''' 
			
			IF @apply_mean_reversion = 'y'
				SET @sql = @sql + ', mean_reversion_level = ''' + @mean_reversion_level + ''''
		
			SET @sql = @sql + ', curve_source = ' + CAST(ISNULL(@curve_source, '') AS VARCHAR(100)) + ' WHERE monte_carlo_model_parameter_id = ' + CAST(@id AS VARCHAR(20))
			
			EXEC spa_print @sql
			EXEC(@sql)
			
			EXEC spa_ErrorHandler 0,
	    			 'monte_carlo_model_parameter',
	    			 'spa_monte_carlo_model_parameter',
	    			 'Success',
	    			 'Data Successfully Saved.',
	    			 ''
    	END
	END TRY
	BEGIN CATCH
		SET @err_msg = ERROR_MESSAGE()
	    
		IF @@TRANCOUNT > 0
			ROLLBACK
		
		SET @desc = 'Fail to update Data ( Error Description:' + @err_msg + ').'
		
		SELECT @err_no = ERROR_NUMBER()
		
		EXEC spa_ErrorHandler @err_no,
			 'monte_carlo_model_parameter',
			 'spa_monte_carlo_model_parameter',
			 'Error',
			 @desc,
			 @err_msg
	END CATCH
END

--IF @flag = 's'
--BEGIN
--	DECLARE @sql VARCHAR(MAX)
--	SET @sql = ' SELECT mcmp.monte_carlo_model_parameter_id,
--	                    mcmp.monte_carlo_model_parameter_name
--	             FROM   monte_carlo_model_parameter mcmp
--	             WHERE  1 = 1'
--				+ CASE WHEN @as_of_date_from IS NOT NULL THEN + ' AND mcmp.as_of_date_from <= ''' + CONVERT(VARCHAR(10), @as_of_date_from, 102) + ''''  ELSE '' END + ''
				
--	exec spa_print @sql
--	EXEC(@sql)				
--END

GO