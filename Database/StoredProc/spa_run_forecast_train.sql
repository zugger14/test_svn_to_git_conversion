IF OBJECT_ID(N'[dbo].[spa_run_forecast_train]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_run_forecast_train]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 --===============================================================================================================
 --Author: rajiv@pioneersolutionsglobal.com
 -- Updated by : rtimilsina@pioneersolutionsglobal.com
 --Upadated date: 2017-02-21
 --Description: Forecasting of load using R 
 
 --Params:
 --@flag CHAR(1)        - Description of param2
 --@param1 VARCHAR(100) - Description of param3
 --===============================================================================================================
CREATE PROCEDURE [dbo].[spa_run_forecast_train]
	@flag CHAR(1),
    @input_process_table VARCHAR(200),
    @mapping_id INT 
	,@threshold numeric(32,20) = NULL
	,@max_step numeric(32,20)= NULL 
	,@learning_rate numeric(32,20)= NULL 
	,@repetation numeric(32,20)= NULL 
	,@hidden_layer VARCHAR(200)= NULL 
	,@algorithm_nn VARCHAR(200)= NULL
	,@error_function VARCHAR(200) = NULL
AS
SET NOCOUNT ON

DECLARE @sql NVARCHAR(MAX)
DECLARE @r_query NVARCHAR(MAX)
IF @flag = 's'
BEGIN	
	
SET @r_query = '
		#----------------------------
		# calculate range difference 
		nc1 <- which(colnames(Load_data)=="termstart" )
		n_check <- nc1+1
		n_start <- 1:(n_check-1)
		#nup <- ncol(Load_data)
		range_cal <- sapply(Load_data[,-n_start],range)
		diff_r <- range_cal[2,]-range_cal[1,]
		col <- which(diff_r!=0)
		columnname1 <- names(Load_data[,n_check:ncol(Load_data)])
		columnname <- columnname1[col]
		inpmat <- Load_data[,columnname]
		#inpmat <- Load_data[,n_check:nup]
		
		#
		nc <- ncol(inpmat)
		nl <- nc-1
		#-----------------------------------------
		# Define, neural network parameters 
		th_in <- '+CAST(@threshold AS NVARCHAR(100))+' # Threshold 
		stp_max <- '+CAST(@max_step AS NVARCHAR(100))+ ' # maximum steps 
		lnrate <- '+CAST(@learning_rate AS NVARCHAR(100))+' # learning rate 
		rep_in <- '+CAST(@repetation AS NVARCHAR(100))+'    # repeat NN 
		hidden_layer <- c('+CAST(@hidden_layer AS NVARCHAR(100))+')
		#-----------------------------
		library(neuralnet)
		library(Scale)
		#----------------------------------------------------
		# Scaling data in an interval of [0,1] so that each variable is treated equally 
		maxs   <- apply(inpmat, 2, max) 
		mins   <- apply(inpmat, 2, min)
		scaled <- as.data.frame(scale(inpmat, center = mins, scale = maxs - mins))
		indx   <- nrow(scaled)
		#-----------------------------------------------------
	    # Conducting neural network 
		train <- scaled[sample(nrow(scaled)),]
		n <- names(train) # name of parameters
		f <- as.formula(paste(n[nl+1], paste(n[1:nl],collapse= ''+ ''), sep=" ~ "))
         nn <- neuralnet(f, threshold=th_in,stepmax=stp_max,rep = rep_in,
						data = train, hidden = '+CAST(@hidden_layer AS NVARCHAR(100))+',
						algorithm= '''+@algorithm_nn+''',learningrate= '+CAST( @learning_rate AS NVARCHAR(100))+',
						err.fct = "'+@error_function+'", linear.output = FALSE)
		trained_model <- data.frame(model = as.raw(serialize(nn, NULL)));
		#----------------------Performing simulations-------------------
		Load_data_out <- trained_model;
		'
	SET @sql = N'SELECT  * 
				FROM ' + @input_process_table + ' WHERE output_type = ''r'' ;'
    
	DECLARE @temp_model_output TABLE (model VARBINARY(MAX))
	
	INSERT INTO @temp_model_output
	EXEC sp_execute_external_script  @language =N'R'    
		,@script=@r_query
		, @input_data_1 = @sql
		, @input_data_1_name = N' Load_data'
		, @output_data_1_name = N' Load_data_out'  
		

		
		UPDATE fm
		SET model = temp.model
		FROM forecast_mapping fm
		OUTER APPLY (SELECT model FROM @temp_model_output) temp
		WHERE fm.forecast_mapping_id = @mapping_id

END