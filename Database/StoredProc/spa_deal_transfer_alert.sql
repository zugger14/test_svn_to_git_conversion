IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_deal_transfer_alert]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_deal_transfer_alert]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**
	Sp to call spatranfer_adjust from alert.

	Parameters 
	@flag : Operational Flag 'a' - Auto deal schedule Block.
	@source_deal_header_ids : Source Deal Header Ids to process.
	@process_id : Process ID.
	process_status in process_deal_alert_transfer_adjust: 1 NEW, 2 processing, 3 success, 4 adjust fail
*/

CREATE PROC [dbo].[spa_deal_transfer_alert]
	@flag CHAR(1),
	@source_deal_header_id NVARCHAR(MAX) = NULL,
	@process_id NVARCHAR(100) = NULL	
AS

/**
	DECLARE 
		@flag CHAR(1) = 'a',
		@source_deal_header_id NVARCHAR(MAX) =  '105483, 105485, 104984',
		@process_id NVARCHAR(100) = NULL	
--**/
	
	DECLARE @sql NVARCHAR(MAX)
	DECLARE @user_name NVARCHAR(100) = dbo.FNADBUSER()
	
	--IF @process_id IS NULL
	--	SET @process_id = dbo.FNAGetNewID()

IF @flag = 'a' --AUTO DEAL SCHEDULE BLOCK
BEGIN	
	DECLARE @alert_process_table NVARCHAR(200) = dbo.FNAProcessTableName('alert_deal', @process_id, 'ad')

	CREATE TABLE #temp_alert_deals(
		source_deal_header_id INT, 
		source_deal_detail_id INT
	)

	EXEC('INSERT INTO #temp_alert_deals
		  SELECT source_deal_header_id, source_deal_detail_id 
		  FROM ' + @alert_process_table
	)

	
	DELETE pp
	--select pp.*
	FROM process_deal_alert_transfer_adjust pp
	LEFT JOIN (
		--get source_deal_deal_id of the min term
		SELECT sdd1.source_deal_header_id, sdd1.source_deal_detail_id, sub.process_id
		FROM source_deal_detail sdd1
		INNER JOIN 
		(	--get min term
			SELECT pp.source_deal_header_id
				, pp.process_id
				, MIN(sdd.term_start) term_start		   
			FROM process_deal_alert_transfer_adjust pp
			INNER JOIN source_deal_detail sdd
				On sdd.source_deal_detail_id = pp.source_deal_detail_id	
			WHERE pp.process_status = 1
			GROUP BY pp.source_deal_header_id, pp.process_id, YEAR(sdd.term_start), MONTH(sdd.term_start)
		)sub
		ON sdd1.source_deal_header_id = sub.source_deal_header_id
		AND sdd1.term_start = sub.term_start

	) pp1
	ON pp1.source_deal_detail_id = pp.source_deal_detail_id
		AND pp1.process_id = pp.process_id
	WHERE pp1.source_deal_header_id IS NULl
		AND pp.process_status = 1

	DECLARE @c_source_Deal_header_id INT
	DECLARE @c_process_id			 VARCHAR(200)
	DECLARE @c_date					 DATE
	DECLARE @c_source_deal_detail_id INT
	DECLARE @create_ts DATETIME
	--DECLARE @counter INT = 1

	DECLARE cur_deals CURSOR LOCAL FOR

	--[TO DO] add process table
	SELECT DISTINCT a.item, pp.process_id, sdd.term_start, sdd.source_deal_detail_id,pp.create_ts	
	FROM dbo.fnasplit(@source_deal_header_id, ',') a
	INNER JOIN process_deal_alert_transfer_adjust pp
		ON a.item = pp.source_deal_header_id
	INNER JOIN #temp_alert_deals tad  --- need to check
		ON tad.source_deal_header_id = pp.source_deal_header_id
		AND tad.source_deal_detail_id = pp.source_deal_detail_id
	INNER JOIN source_deal_detail sdd
		ON sdd.source_deal_detail_id = tad.source_deal_detail_id
		AND sdd.source_deal_detail_id = pp.source_deal_detail_id
	LEFT JOIN process_deal_position_breakdown ppd
		ON ppd.source_deal_header_id = pp.source_deal_header_id
	WHERE pp.process_status = 1
		AND ppd.source_deal_header_id IS NULL
	ORDER BY pp.create_ts	

	OPEN cur_deals
	FETCH NEXT FROM cur_deals INTO @c_source_Deal_header_id, @c_process_id, @c_date, @c_source_deal_detail_id, @create_ts
	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE process_deal_alert_transfer_adjust 
		SET process_status = 2
		  , error_description = 'Processing.'
		WHERE source_deal_header_id = @c_source_Deal_header_id
			AND process_id = @c_process_id
			AND source_deal_detail_id = @c_source_deal_detail_id

		IF EXISTS( SELECT   1-- uddf.udf_value
				   FROM source_deal_header sdh
				   INNER JOIN user_defined_deal_fields_template_main uddft
					   ON uddft.template_id = sdh.template_id
				   INNER JOIN user_defined_deal_fields uddf
					   ON uddf.source_deal_header_id = sdh.source_deal_header_id 
					   AND uddf.udf_template_id = uddft.udf_template_id
				   INNER JOIN user_defined_fields_template udft
					   ON udft.field_id = uddft.field_id
					INNER JOIN source_Deal_type sdt
						ON sdt.source_Deal_type_id = sdh.source_Deal_type_id
					INNER JOIN static_data_value sdv
						ON sdv.value_id = sdh.internal_portfolio_id
						AND sdv.type_id = 39800
						AND sdv.code IN (						
							'Complex-EEX'
							,'Complex-LTO'
							,'Complex-ROD'
							,'Autopath Only'
						)
				   WHERE sdh.source_deal_header_id = @c_source_Deal_header_id --7385 --
					   AND udft.Field_label = 'Delivery Path'
					   AND NULLIF(uddf.udf_value, '') IS NOT NULL
						 AND sdt.deal_type_id <> 'Transportation'						 
		)
		BEGIN						
			DECLARE @output_status BIT
			BEGIN TRY
				EXEC [dbo].[spa_transfer_adjust] @source_deal_header_id = @c_source_Deal_header_id, @term = @c_date, @is_deal_created  = @output_status OUTPUT
			END TRY
			BEGIN CATCH
				UPDATE process_deal_alert_transfer_adjust
				SET process_status = 4
				  , error_description = 'Failed to auto adjust due to technical error.'
				WHERE source_deal_header_id = @c_source_Deal_header_id
					AND process_id = @c_process_id
					AND source_deal_detail_id = @c_source_deal_detail_id
			END CATCH

			IF @output_status = 1
			BEGIN
				UPDATE process_deal_alert_transfer_adjust
				SET process_status = 3
				  , error_description = 'Auto adjust completed.'
				WHERE source_deal_header_id = @c_source_Deal_header_id
					AND process_id = @c_process_id
					AND source_deal_detail_id = @c_source_deal_detail_id
			END
			ELSE
			BEGIN
				UPDATE process_deal_alert_transfer_adjust
				SET process_status = 4
				  , error_description = 'Failed to auto adjust.'
				WHERE source_deal_header_id = @c_source_Deal_header_id
					AND process_id = @c_process_id
					AND source_deal_detail_id = @c_source_deal_detail_id
			END			
		END	
		
		FETCH NEXT FROM cur_deals INTO @c_source_Deal_header_id, @c_process_id, @c_date, @c_source_deal_detail_id,@create_ts
		DELETE FROM process_deal_alert_transfer_adjust WHERE process_status = 3
	END
	
	CLOSE cur_deals
	DEALLOCATE cur_deals
END