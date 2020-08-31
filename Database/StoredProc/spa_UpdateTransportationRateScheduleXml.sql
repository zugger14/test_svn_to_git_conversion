IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_UpdateTransportationRateScheduleXml]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_UpdateTransportationRateScheduleXml]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_UpdateTransportationRateScheduleXml]
	@flag CHAR(1),
	@xml TEXT,
	@xml2 TEXT 

AS

SET NOCOUNT ON

BEGIN TRY
	
	DECLARE @gid INT 
	DECLARE @idoc INT
	DECLARE @doc VARCHAR(1000)
	DECLARE @name VARCHAR(500)

	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
	
	SELECT * INTO #ztbl_xmlvalue
	
	FROM OPENXML (@idoc, '/Root/FormXML', 2)
		 WITH (	 value_id  INT  '@value_id',
				 [type_id] INT '@type_id',
				 code VARCHAR(100) '@code',
				 description VARCHAR(100) '@description'
				  )


	DECLARE @idoc2 INT
	DECLARE @doc2 VARCHAR(1000)

	EXEC sp_xml_preparedocument @idoc2 OUTPUT, @xml2
	
	-------------------------------------------------------------------
	SELECT * INTO #ztbl_gridvalue
	FROM OPENXML (@idoc2, '/GridGroup/Grid/GridRow', 2)
		WITH ( 
				rate_schedule_id  INT  '@rate_schedule_id',
				effective_date DATETIME '@effective_date',
				rate_type_id INT  '@rate_type_id',
				rate FLOAT  '@rate',
				uom_id INT '@uom_id')
	--	SELECT * FROM #ztbl_gridvalue		
	
	
	IF @flag IN ('i', 'u')
	BEGIN
		--PRINT 'Merge'
		BEGIN TRAN

		
		MERGE static_data_value sd
		USING (SELECT value_id,code,DESCRIPTION,[type_id]
				FROM #ztbl_xmlvalue) zxv ON sd.value_id = zxv.value_id
	
		WHEN NOT MATCHED BY TARGET THEN
				INSERT (code,[type_id],description)
				VALUES ( zxv.code,1800,zxv.description )
		
				
		WHEN MATCHED THEN
			UPDATE SET	 sd.code = zxv.code,
						sd.description = zxv.description,
						sd.[type_id] = 1800;	
						
		DECLARE @code VARCHAR(1000) 
		SELECT 	@code = code FROM  #ztbl_xmlvalue
			
		SET @name = @code	
						
		
		DECLARE @rate_schd_id INT
		SELECT @rate_schd_id = value_id FROM #ztbl_xmlvalue
		
		IF @rate_schd_id = 0
			SET @gid = SCOPE_IDENTITY()
		ELSE 
			SET @gid = @rate_schd_id
		
			MERGE transportation_rate_schedule trs
			USING (SELECT rate_schedule_id,rate_type_id,rate,effective_date,uom_id
			       FROM #ztbl_gridvalue) grd ON trs.rate_schedule_id = grd.rate_schedule_id 
			       AND trs.rate_type_id = grd.rate_type_id 
			       AND trs.uom_id = grd.uom_id
			
			
			 WHEN NOT MATCHED BY TARGET THEN
		
			 		INSERT (rate_schedule_id,effective_date,rate_type_id,rate,uom_id) 
			 		VALUES (@gid,dbo.FNAGetSQLStandardDateTime(grd.effective_date),grd.rate_type_id,grd.rate,grd.uom_id)
			 
			 WHEN MATCHED THEN 
			 	UPDATE SET 
			 		trs.rate_schedule_id = @gid,
					trs.effective_date = dbo.FNAGetSQLStandardDateTime(grd.effective_date),
			 		trs.rate_type_id = grd.rate_type_id,
			 		trs.rate = grd.rate,
			 		trs.uom_id = grd.uom_id
			 		
			 WHEN NOT MATCHED BY SOURCE 
			  AND  trs.rate_schedule_id = @gid  THEN 
			 	DELETE 
				;
		
		EXEC spa_ErrorHandler 0
			, 'Transportation Rate Schedule'
			, 'spa_getXml'
			, 'Success'
			, 'Transportaion Rate Schedule Save Successfully.'
			, @gid
		

		COMMIT
	END
	
	--IF @flag = 'd'
	--	BEGIN
	--		DELETE FROM #ztbl_xmlvalue WHERE sd.value_id = zxv.value_id
	--		DELETE FROM #ztbl_gridvalue grd ON trs.rate_schedule_id = grd.rate_schedule_id 
	--	END 
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK
		
	DECLARE @msg VARCHAR(5000)
	--SELECT @msg = 'Failed Inserting record (' + ERROR_MESSAGE() + ').'
	SELECT @msg = 'Name (Field Name) must be unique.'
	
	EXEC spa_ErrorHandler @@ERROR
		, 'Transportation Rate Schedule'
		, 'spa_UpdateTransportationRateScheduleXml'
		, 'Error'
		, @msg
		, 'Failed Inserting Record'
END CATCH



