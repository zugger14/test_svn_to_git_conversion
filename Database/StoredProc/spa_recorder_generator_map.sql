IF EXISTS (SELECT 1 FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[spa_recorder_generator_map]') AND [type] IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_recorder_generator_map]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[spa_recorder_generator_map]
	 @flag CHAR(1)
	,@generator_id INT = NULL
	,@recorder_id VARCHAR(100) = NULL
	,@map_id INT = NULL
	,@allocation_per FLOAT = NULL
	,@from_vol FLOAT = NULL
	,@to_vol FLOAT = NULL
	,@grid_xml VARCHAR(MAX) = NULL

AS
BEGIN
SET NOCOUNT ON
DECLARE @sql varchar(8000)
declare @url varchar(1000)
DECLARE @meter_id INT
SELECT @meter_id = meter_id FROM meter_id WHERE recorderid = @recorder_id 
 
IF @flag='s'
BEGIN
	SELECT rgm.id, 
		   --rgm.generator_id, 
		   rgm.meter_id, 
		   --mi.recorderid meter_id,--recorder_id, 
		   rgm.allocation_per, 
		   rgm.from_vol, 
		   rgm.to_vol
	FROM recorder_generator_map rgm
	WHERE rgm.generator_id = @generator_id
END
IF @flag='a'
BEGIN
	SELECT rgm.[ID]
		,generator_id
		,mi.recorderid
		,rgm.allocation_per
		,from_vol
		,to_vol
	FROM recorder_generator_map rgm
	INNER JOIN meter_id mi
		ON mi.meter_id = rgm.meter_id
	WHERE rgm.id = @map_id
END
IF @flag='r'
BEGIN
	SELECT rgm.meter_id
		,rg.Name [Generator Name]
		,cast(rgm.allocation_per * 100 AS VARCHAR) + ' %' [Allocation]
		,from_vol [From Volume]
		,to_vol [To Volume]
	FROM recorder_generator_map rgm
	JOIN rec_generator rg
		ON rg.generator_id = rgm.generator_id
	WHERE rgm.meter_id = @meter_id
END

ELSE IF @flag='i'
BEGIN

	if(select sum(allocation_per)+@allocation_per from recorder_generator_map where meter_id=@meter_id)>1
	begin
		set @url='<a href="../../dev/spa_html.php?spa=spa_recorder_generator_map ''r'',null,'''+cast(@meter_id as varchar)+'''">Click here...</a>'
		select 'Error' ErrorCode, 'Rec Generator' Module, 
				'spa_rec_generator' Area, 'DB Error' Status, 
			'Recorder '+CAST(@meter_id AS VARCHAR) +' cannot be allocated more than 100%, Please view this report '+@url Message, '' Recommendation
		return	
	end
	

	if (select max(to_vol) from recorder_generator_map where meter_id=@meter_id and id not in (@map_id))>@from_vol OR
		 exists (select * from recorder_generator_map where meter_id=@meter_id and from_vol is not null and to_vol is  null)
	begin
		set @url='<a href="../../dev/spa_html.php?spa=spa_recorder_generator_map ''r'',null,'''+cast(@meter_id as varchar)+'''">Click here...</a>'
		select 'Error' ErrorCode, 'Rec Generator' Module, 
				'spa_rec_generator' Area, 'DB Error' Status, 
			'Specified volume cannot be allocated to Recorder '+@meter_id +',Please view this report '+@url Message, '' Recommendation
		return	
	end
	insert into recorder_generator_map(
		generator_id,
		meter_id,
		allocation_per,
		from_vol,
		to_vol	
	)
	values(
		@generator_id,
		@meter_id,
		@allocation_per,
		@from_vol,
		@to_vol	
	)

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Contract Group", 
		"spa_contract_group", "DB Error", 
		"Error on Inserting Recorder ID.", ''
	else
		Exec spa_ErrorHandler 0, 'Contract Group', 
		'spa_contract_group', 'Success', 
		'Recorder ID successfully inserted.',''
		

END
ELSE IF @flag='u'
BEGIN
	
	IF (
			SELECT sum(allocation_per) + @allocation_per
			FROM recorder_generator_map
			WHERE meter_id = @meter_id
				AND id NOT IN (@map_id)
			) > 1
		BEGIN
			set @url='<a href="../../dev/spa_html.php?spa=spa_recorder_generator_map ''r'',null,'''+cast(@meter_id as varchar)+'''">Click here...</a>'
			SELECT 'Error' ErrorCode
					,'Rec Generator' Module
					,'spa_rec_generator' Area
					,'DB Error' STATUS
					,'Recorder ' + @meter_id + ' cannot be allocated more than 100%, Please view this report ' + @url Message
					,'' Recommendation

			RETURN	
		END

		if (select max(to_vol) from recorder_generator_map where meter_id=@meter_id and id not in (@map_id))>@from_vol OR
			 exists (select * from recorder_generator_map where meter_id=@meter_id and from_vol is not null and to_vol is  null)
		begin
			set @url='<a href="../../dev/spa_html.php?spa=spa_recorder_generator_map ''r'',null,'''+cast(@meter_id as varchar)+'''">Click here...</a>'

			SELECT 'Error' ErrorCode
				,'Rec Generator' Module
				,'spa_rec_generator' Area
				,'DB Error' STATUS
				,'Specified volume cannot be allocated to Recorder ' + @meter_id + ',Please view this report ' + @url Message
				,'' Recommendation

			RETURN 
	END

		UPDATE recorder_generator_map
		SET meter_id = @meter_id
			,allocation_per = @allocation_per
			,from_vol = @from_vol
			,to_vol = @to_vol
		WHERE id = @map_id

	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR
			,"Contract Group"
			,"spa_contract_group"
			,"DB Error"
			,"Error on Updating Recorder ID."
			,''
	ELSE
		EXEC spa_ErrorHandler 0
			,'Contract Group'
			,'spa_contract_group'
			,'Success'
			,'Recorder ID successfully updated.'
			,''
END

ELSE IF @flag='d'
	BEGIN

	DELETE
	FROM recorder_generator_map
	WHERE id = @map_id
	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR
			,"Contract Group"
			,"spa_contract_group"
			,"DB Error"
			,"Error on Deleting Recorder ID."
			,''
	ELSE
		IF @@ERROR <> 0
			EXEC spa_ErrorHandler @@ERROR
				,"Contract Group"
				,"spa_contract_group"
				,"DB Error"
				,"Error on Deleting Contract Group."
				,''
		ELSE
			EXEC spa_ErrorHandler 0
				,'Contract Group'
				,'spa_contract_group'
				,'Success'
				,'Recorder ID successfully Deleted.'
				,''

	END
	/*
	*	Added By: Achyut Khadka
	*	Modified Date: 12/15/2015
	*/
	ELSE IF @flag = 'm'
	BEGIN
		BEGIN TRY
			BEGIN TRAN
				DECLARE @idoc INT

				IF OBJECT_ID('tempdb..#temp_meter_allocation') IS NOT NULL
					DROP TABLE #temp_meter_allocation
		
				CREATE TABLE #temp_meter_allocation
				(
					generator_id INT,
					id INT,
					meter_id INT,
					allocation_per NUMERIC(6,2),
					from_vol INT,
					to_vol INT
				)

				EXEC sp_xml_preparedocument @idoc OUTPUT, @grid_xml

				INSERT INTO #temp_meter_allocation (
												generator_id,
												id,
												meter_id,
												allocation_per,
												from_vol,
												to_vol
											)
				SELECT							NULLIF(generator_id, ''),
												NULLIF(id, ''),
												NULLIF(meter_id, ''),
												allocation_per,
												NULLIF(from_vol, ''),
												NULLIF(to_vol, '')
				FROM OPENXML (@idoc, '/GridGroup/Grid/GridRow', 2)
					WITH ( 
						generator_id				VARCHAR(20)	 '@generator_id'
						,id							VARCHAR(20)	 '@id'
						,meter_id					VARCHAR(20)	 '@meter_id'
						,allocation_per				NUMERIC(6,2) '@allocation_per'
						,from_vol					VARCHAR(50)	 '@from_vol'
						,to_vol						VARCHAR(50)	 '@to_vol'
					)
		
				IF OBJECT_ID('tempdb..#temp_meter_allocation_sum') IS NOT NULL
				DROP TABLE #temp_meter_allocation_sum

				CREATE TABLE #temp_meter_allocation_sum
				(	id INT,
					meter_id INT,
					allocation_per NUMERIC(6,2)
				)
				
				INSERT INTO #temp_meter_allocation_sum
				SELECT rgm.id, rgm.meter_id, SUM(rgm.allocation_per) sum_allocation
				FROM recorder_generator_map rgm
				LEFT JOIN #temp_meter_allocation tca ON  rgm.id = tca.id
				WHERE tca.id IS NULL
				GROUP BY rgm.meter_id,rgm.id

				IF OBJECT_ID('tempdb..#temp_meter_allocation_exceed') IS NOT NULL
					DROP TABLE #temp_meter_allocation_exceed

				CREATE TABLE #temp_meter_allocation_exceed
				(	
					meter_id INT,
					allocation_per NUMERIC(6,2)
				)
			
				INSERT INTO #temp_meter_allocation_exceed
				SELECT tca.meter_id, ISNULL(tca.allocation_per,'0') + ISNULL(tcas.allocation_per,'0') -1  sum_allocation
				FROM (SELECT  meter_id, SUM(allocation_per) allocation_per FROM #temp_meter_allocation GROUP BY meter_id) tca
				LEFT JOIN (SELECT meter_id, SUM(allocation_per) allocation_per FROM #temp_meter_allocation_sum GROUP BY meter_id) tcas ON tca.meter_id = tcas.meter_id
				WHERE ISNULL(tca.allocation_per,'0') + ISNULL(tcas.allocation_per,'0') > 1

				IF EXISTS(SELECT 1 FROM #temp_meter_allocation_exceed)
				BEGIN
					DECLARE @error_msg VARCHAR(500)
					
					SELECT @error_msg = ISNULL(@error_msg + ', ', ' ')  + '<b>' + mi.recorderid + ' - ' + mi.description + '</b> by '+ CAST(tcae.allocation_per AS VARCHAR(30))
					FROM #temp_meter_allocation_exceed tcae
					LEFT JOIN meter_id mi ON mi.meter_id = tcae.meter_id
				
					SET @error_msg = 'The sum of allocation exceeds 1 for Meter(s)' + @error_msg
				
					EXEC spa_ErrorHandler  -1
						, 'Counterparty Contract'
						, 'spa_counterparty_contract'
						, 'DB Error'
						, @error_msg
						, ''
				
					IF @@TRANCOUNT > 0
						ROLLBACK
				
					RETURN
				END

				UPDATE m
					SET m.meter_id = tma.meter_id,
						m.allocation_per = tma.allocation_per,
						m.from_vol = tma.from_vol,
						m.to_vol = tma.to_vol
					FROM #temp_meter_allocation tma
						INNER JOIN recorder_generator_map m
							ON tma.id = m.id
					WHERE tma.id IS NOT NULL
		
				INSERT INTO recorder_generator_map(generator_id,meter_id,allocation_per,from_vol,to_vol)
				SELECT generator_id,meter_id,allocation_per,from_vol,to_vol
				FROM #temp_meter_allocation
				WHERE id IS NULL

				IF OBJECT_ID('tempdb..#temp_meter_allocation_delete') IS NOT NULL
					DROP TABLE #temp_meter_allocation_delete
		
				CREATE TABLE #temp_meter_allocation_delete
				(
					id INT
				)

				EXEC sp_xml_preparedocument @idoc OUTPUT, @grid_xml

				INSERT INTO #temp_meter_allocation_delete (id)
				SELECT	id
				FROM OPENXML (@idoc, '/GridGroup/GridDelete/GridRow', 2)
					WITH ( 
						id							VARCHAR(20)	 '@id'
					)

				DELETE rgm 
				FROM recorder_generator_map rgm
					LEFT JOIN #temp_meter_allocation_delete d
						ON d.id = rgm.id
					WHERE d.id IS NOT NULL
			
			COMMIT 
 			EXEC spa_ErrorHandler 0, 'MeterAllocation', 
 					'spa_recorder_generator_map', 'Success', 
 					'Changes have been saved successfully.', ''
		END TRY
		BEGIN CATCH 
			IF @@TRANCOUNT > 0
			   ROLLBACK
			
			DECLARE @desc VARCHAR(500) = dbo.FNAHandleDBError(10166600)
			
			EXEC spa_ErrorHandler -1, 'MeterAllocation', 
 							'spa_recorder_generator_map', 'DB Error', 
 							@desc, ''
			
		END CATCH
	END
END