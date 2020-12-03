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
	
	IF @process_id IS NULL
		SET @process_id = dbo.FNAGetNewID()

IF @flag = 'a' --AUTO DEAL SCHEDULE BLOCK
BEGIN	
	--WAITFOR DELAY '00:30';  

	DECLARE @c_source_Deal_header_id INT
	--DECLARE @counter INT = 1
		
	DECLARE cur_deals CURSOR LOCAL SCROLL FOR
	SELECT a.item FROM dbo.fnasplit(@source_deal_header_id, ',') a
	INNER JOIN process_deal_alert_transfer_adjust pp
		ON a.item = pp.source_deal_header_id
	LEFT JOIN process_deal_position_breakdown ppd
		ON ppd.source_deal_header_id = pp.source_deal_header_id
	WHERE pp.process_status = 1
		AND ppd.source_deal_header_id IS NULL
		--and process_id = @process_id	

	OPEN cur_deals
	FETCH NEXT FROM cur_deals INTO @c_source_Deal_header_id
	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE process_deal_alert_transfer_adjust 
		SET process_status = 2
		  , error_description = 'Processing.'
		WHERE source_deal_header_id = @c_source_Deal_header_id

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
			--WAITFOR DELAY '00:01:00';			   
			--DECLARE @col INT
		
			DECLARE @job_name1 NVARCHAR(100)

			SET @sql = 'EXEC [dbo].[spa_transfer_adjust] ' + CAST(@c_source_Deal_header_id AS VARCHAR(10)) 
			   
			--SET @job_name1 = 'transfer_adjust_' + @process_id + '_' + CAST(@c_source_Deal_header_id AS VARCHAR(10))	
     
			--EXEC spa_run_sp_as_job @job_name1, @sql, 'spa_transfer_adjust', @user_name    
			EXEC(@sql)
		END	

		IF EXISTS ( SELECT 1
					FROM optimizer_detail od 
					INNER JOIN source_deal_header sdh
						ON sdh.source_deal_header_id = od.transport_deal_id
					WHERE od.source_deal_header_id = @c_source_Deal_header_id --@c_source_Deal_header_id
					UNION
					SELECT 1
					FROM user_defined_deal_fields uddf    
					INNER JOIN source_deal_header sdh
						ON sdh.source_deal_header_id = uddf.source_deal_header_id
					INNER JOIN user_defined_deal_fields_template uddft
						ON sdh.template_id = uddft.template_id
						AND uddf.udf_template_id = uddft.udf_template_id    
						AND uddft.field_label = 'From Deal'    
					WHERE udf_value = CAST(@c_source_Deal_header_id AS NVARCHAR(100))--@c_source_Deal_header_id
		)
		BEGIN
			UPDATE process_deal_alert_transfer_adjust
			SET process_status = 3
			  , error_description = 'Auto adjust completed.'
			WHERE source_deal_header_id = @c_source_Deal_header_id
			--FETCH NEXT FROM cur_deals INTO @c_source_Deal_header_id
		END
		ELSE
		BEGIN
			--IF @counter < 6
			--BEGIN
			--	SET @counter = @counter + 1
			--	FETCH RELATIVE 0 FROM cur_deals INTO @c_source_Deal_header_id
				UPDATE process_deal_alert_transfer_adjust
				SET process_status = 4
				  , error_description = 'Failed to auto adjust.'
				WHERE source_deal_header_id = @c_source_Deal_header_id
			--END
			--IF @counter = 6 
			--BEGIN
			--	FETCH NEXT FROM cur_deals INTO @c_source_Deal_header_id
			--	SET @counter = 1
			--END
			--ELSE
				--FETCH NEXT FROM cur_deals INTO @c_source_Deal_header_id
		END
		FETCH NEXT FROM cur_deals INTO @c_source_Deal_header_id
		DELETE FROM process_deal_alert_transfer_adjust WHERE process_status = 3
	END
	
	CLOSE cur_deals
	DEALLOCATE cur_deals

	--IF EXISTS(SELECT * FROM process_deal_alert_transfer_adjust WHERE process_status = 1 AND error_description <> 'recall')
	--BEGIN
	--	SELECT @source_Deal_header_id  = STUFF((SELECT ', ' + CAST(source_deal_header_id as NVARCHAR(10))
	--										   FROM process_deal_alert_transfer_adjust b
	--										   WHERE process_status = 1
	--											   AND error_description <> 'recall'
	--										   FOR XML PATH('')), 1, 2, '')
	--	FROM process_deal_alert_transfer_adjust a		
	--	GROUP BY source_deal_header_id
	--	EXEC [spa_deal_transfer_alert] 'a', @source_deal_header_id
	--END
END