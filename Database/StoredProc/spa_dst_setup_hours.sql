IF OBJECT_ID(N'dbo.spa_dst_setup_hours', N'P') IS NOT NULL
	DROP PROCEDURE dbo.spa_dst_setup_hours
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.spa_dst_setup_hours
	  @flag VARCHAR(1) = 'g',
	  @id varchar(500) = NULL,
	  @xml VARCHAR(MAX)=NULL
AS

/*--debug
DECLARE @flag VARCHAR(1) = 'i',
	  @id varchar(500) = NULL,
	  @xml VARCHAR(MAX) = '
	  <Root><PSRecordset  id = "42"  effective_date = "2010-10-1"  year = "2010"  hour = "3"  insert_delete = "Start"  dst_group_value_id = "102200"  ></PSRecordset> </Root>
	  '
	  --DROP TABLE #temp_setup_dst	  
--*/

SET NOCOUNT ON

DECLARE @idoc INT
       ,@hour INT
	   ,@year INT
	   ,@effective_date datetime
       ,@insert_delete Varchar(50)

IF @flag = 'i'
BEGIN
	BEGIN TRY		
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

		SELECT * INTO #temp_setup_dst
		FROM OPENXML (@idoc, '/Root/PSRecordset', 1)
			WITH (
					id VARCHAR(10) '@id',
					[year] VARCHAR(100) '@year',
					insert_delete VARCHAR(50) '@insert_delete',
					effective_date DATETIME '@effective_date',
					[hour] VARCHAR(50) '@hour',
					[dst_group_value_id] INT '@dst_group_value_id'
				)

		UPDATE #temp_setup_dst
		SET insert_delete = 'd'
		WHERE insert_delete = 'Start'

		UPDATE #temp_setup_dst
		SET	insert_delete = 'i'
		WHERE insert_delete = 'End'

		IF EXISTS (SELECT 1 from #temp_setup_dst WHERE id = '')
		BEGIN
			INSERT INTO MV90_DST ([year], [hour], [date], [insert_delete], dst_group_value_id)
			SELECT [year], [hour], effective_date, insert_delete, dst_group_value_id
			FROM #temp_setup_dst tsdv1 WHERE tsdv1.id = ''

			EXEC spa_ErrorHandler 0,
				'Setup DST.',
				'spa_setup_Dst_hour',
				'Success',
				'Data has been successfully saved.',
				@id
		END

		ELSE IF EXISTS(
			SELECT  tsd.id from #temp_setup_dst tsd
			INNER JOIN MV90_DST mvdst
				ON tsd.id = mvdst.id
		)
		BEGIN
			UPDATE MV90_DST
			SET [year] = a1.[year],
				[date] = a1.effective_date,
				[hour] = a1.[hour],
				insert_delete = a1.insert_delete,
				[dst_group_value_id] = a1.dst_group_value_id
			FROM #temp_setup_dst AS a1
			INNER JOIN MV90_DST AS a2
				ON a1.id = a2.id

			EXEC spa_ErrorHandler 0,
				'Setup DST.',
				'spa_setup_dst_hours',
				'Success',
				'Changes have been successfully saved.',
				@id
		END		 
		
	END TRY
	BEGIN CATCH
		DECLARE @msg VARCHAR(500)
		
		IF ERROR_MESSAGE() LIKE 'Violation of UNIQUE KEY constraint%'
			SET @msg = 'Duplicate data in Setup DST grid. Please Check the Data in Columns (<b>Year, DST & DST Group Value</b>) and Resave.'
		ELSE
			SET @msg = ERROR_MESSAGE()

		EXEC spa_ErrorHandler -1,
		     'Setup DST',
		     'spa_setup_DST_hour',
		     'Success',
		     @msg,
		     @id
	END CATCH				
END	
	
		
ELSE IF @flag = 'g'
BEGIN
	SELECT [id], 
		[year], 
		CASE WHEN insert_delete = 'd' THEN 'Start' 
			ELSE 'End' 
		END [insert_delete],
		[date],	
		[hour], 
		[dst_group_value_id]
	FROM mv90_DST ORDER BY [year]
END	

ELSE IF @flag = 'd'
BEGIN
    BEGIN TRY
        DELETE mvdst
        FROM mv90_DST mvdst
		INNER JOIN dbo.SplitCommaSeperatedValues(@id) i 
			ON i.item = mvdst.id
             
        EXEC spa_ErrorHandler 0
            ,'MV90 DST.'
            ,'spa_dst_setup_hours'
            ,'Success'
            ,'Data has been successfully deleted.'
            ,@id
    END TRY 
    BEGIN CATCH
        EXEC spa_ErrorHandler-1
            ,'DST Data Delete.'
            ,'spa_dst_setup_hours'
            ,'DB Error'
            ,'Data error on Setup DST grid. Please check the data in column and resave.'
            ,''
    END CATCH
END

ELSE IF @flag = 'r'
BEGIN
	SET NOCOUNT ON

	DECLARE @max INT

	SET @max =2099

	CREATE TABLE #temp (val INT)

	WHILE @max >= 2000
	  BEGIN

		INSERT #temp(val) VALUES(@max)
		SET @max = @max - 1

	  END

	SELECT val AS value_id, val AS code FROM #temp ORDER BY value_id ASC
	DROP TABLE #temp
END

ELSE IF @flag = 'm'
BEGIN
	SELECT 'd' AS value_id , 'Start' AS Code UNION
	SELECT 'i' AS value_id, 'End' AS Code
END

ELSE IF @flag='h'
BEGIN
	SELECT '2' AS value_id , '2' AS Code UNION
	SELECT '3' AS value_id, '3' AS Code
END

GO