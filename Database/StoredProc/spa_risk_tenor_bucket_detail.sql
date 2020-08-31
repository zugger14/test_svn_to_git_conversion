/****** Object:  StoredProcedure [dbo].[spa_risk_tenor_bucket_detail]    Script Date: 02/02/2010 09:36:35 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_risk_tenor_bucket_detail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_risk_tenor_bucket_detail]
GO

CREATE PROCEDURE [dbo].[spa_risk_tenor_bucket_detail]
	@flag CHAR(1) ,
	@bucket_detail_id INT = NULL ,
	@bucket_header_id INT = NULL,
	@tenor_name VARCHAR(50) = NULL,
	@tenor_description VARCHAR(50) = NULL,
	@tenor_from INT = NULL ,
	@tenor_to INT = NULL ,
	@fromMonthYear CHAR(1) = NULL,
	@toMonthYear CHAR(1) = NULL
AS 
DECLARE @sql_Select VARCHAR(MAX)
IF @flag ='s'
BEGIN
  SET @sql_Select ='SELECT 
					   bucket_detail_id [ID],
					   bucket_header_id [Header ID],
					   tenor_name [Name] ,  
					   tenor_description [Description] ,
					   tenor_from [From] , 
					   tenor_to [To]  
					 from  risk_tenor_bucket_detail'
	IF @bucket_header_id IS NOT NULL 
		SET @sql_Select = @sql_Select + ' where  bucket_header_id = ' + CAST(@bucket_header_id AS VARCHAR)
	EXEC (@sql_Select)
END
ELSE IF @flag ='i' 
BEGIN
    IF EXISTS (SELECT tenor_name FROM risk_tenor_bucket_detail WHERE tenor_name = @tenor_name AND bucket_header_id = @bucket_header_id)
		BEGIN
			Exec spa_ErrorHandler -1, 'Tenor Name already exsists.',
				'spa_risk_tenor_bucket_detail', 'DB_Error',
				'This tenor name already exists. Please enter another name.',''
			RETURN
		END
	ELSE IF EXISTS(SELECT tenor_from,tenor_to FROM risk_tenor_bucket_detail WHERE (tenor_from = @tenor_from AND tenor_to = @tenor_to) AND bucket_header_id = @bucket_header_id) 
		BEGIN
			Exec spa_ErrorHandler -1, 'Combination of Tenor From and Tenor To already exists.',
				'spa_risk_tenor_bucket_detail', 'DB_Error',
				'Combination of Tenor From and Tenor To already exists.',''
			RETURN
		END
	ELSE
		BEGIN
			INSERT INTO risk_tenor_bucket_detail(bucket_header_id , tenor_name , tenor_description , tenor_from , tenor_to, fromMonthYear, toMonthYear) 
				VALUES(@bucket_header_id , @tenor_name , @tenor_description , @tenor_from , @tenor_to, @fromMonthYear, @toMonthYear)
				
				Exec spa_ErrorHandler 0, 'Data Updated Successfully.',
							'spa_risk_tenor_bucket_detail', 'DB_Error',
							'Data Updated Successfully',''
							RETURN
				
		END
END
ELSE IF @flag ='u'
BEGIN
	IF EXISTS(SELECT * FROM risk_tenor_bucket_detail WHERE tenor_name=@tenor_name AND bucket_header_id = @bucket_header_id AND bucket_detail_id <> @bucket_detail_id)
	BEGIN
		Exec spa_ErrorHandler -1, 'Tenor Name already exsists.',
		'spa_risk_tenor_bucket_detail', 'DB_Error',
		'This tenor name already exists. Please enter another name.',''
		RETURN
	END
	ELSE IF EXISTS(SELECT * FROM risk_tenor_bucket_detail WHERE (tenor_from = @tenor_from  AND tenor_to = @tenor_to) AND bucket_header_id = @bucket_header_id AND bucket_detail_id <> @bucket_detail_id) 
	 BEGIN
		Exec spa_ErrorHandler -1, 'Combination of Tenor From and Tenor To already exists.',
		'spa_risk_tenor_bucket_detail', 'DB_Error',
		'Combination of Tenor From and Tenor To already exists.',''
		RETURN
	 END     
	ELSE
	BEGIN
		UPDATE risk_tenor_bucket_detail 
			SET bucket_header_id = @bucket_header_id , 
				tenor_name = @tenor_name,
				tenor_description = @tenor_description,
				tenor_from = @tenor_from,
				tenor_to =@tenor_to ,
				fromMonthYear = @fromMonthYear,
				toMonthYear = @toMonthYear
			WHERE bucket_detail_id=@bucket_detail_id 

		EXEC spa_ErrorHandler 0, 'Data Updated Successfully.',
				'spa_risk_tenor_bucket_detail', 'DB_Error',
				'Data Updated Successfully',''
				RETURN
			
	END
 END
ELSE IF @flag ='d'
BEGIN
	IF NOT  EXISTS( select 1 from counterparty_limits  WHERE bucket_detail_id = @bucket_detail_id)
	BEGIN
		DELETE FROM  risk_tenor_bucket_detail WHERE bucket_detail_id = @bucket_detail_id
		EXEC spa_ErrorHandler 0, 'Data Deleted Successfully.',
		'spa_risk_tenor_bucket_detail', 'DB_Error',
		'Data Deleted Successfully.',''
		RETURN
	END
	ELSE
		BEGIN
			EXEC spa_ErrorHandler -1, 'Counterparty limit exists for this tenor bucket. You must delete the limit first.',
		'spa_risk_tenor_bucket_detail', 'DB_Error',
		'Counterparty limit exists for this tenor bucket. You must delete the limit first.',''
		END
END
ELSE IF @flag ='a'
BEGIN
     SELECT 
		   bucket_header_id,
		   tenor_name,  
		   tenor_description,
		   tenor_from, 
		   tenor_to,
		   fromMonthYear,
		   toMonthYear
	FROM  risk_tenor_bucket_detail
     WHERE bucket_detail_id = @bucket_detail_id
END