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
		@source_deal_header_id NVARCHAR(MAX) =  '100984, 104541',
		@process_id NVARCHAR(100) = NULL	
--**/
	
	DECLARE @sql NVARCHAR(MAX)
	DECLARE @user_name NVARCHAR(100) = dbo.FNADBUSER()
	
	IF @process_id IS NULL
		SET @process_id = dbo.FNAGetNewID()

IF @flag = 'a' --AUTO DEAL SCHEDULE BLOCK
BEGIN	
	DECLARE @c_source_Deal_header_id INT
	
	DECLARE cur_deals CURSOR LOCAL FOR
	SELECT item FROM dbo.fnasplit(@source_deal_header_id, ',')
	
	OPEN cur_deals
	FETCH NEXT FROM cur_deals INTO @c_source_Deal_header_id
	WHILE @@FETCH_STATUS = 0
	BEGIN
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

			SET @sql = ' [dbo].[spa_transfer_adjust] ' + CAST(@c_source_Deal_header_id AS VARCHAR(10)) 
			   
			SET @job_name1 = 'transfer_adjust_' + @process_id + '_' + CAST(@c_source_Deal_header_id AS VARCHAR(10))	
     
			EXEC spa_run_sp_as_job @job_name1, @sql, 'spa_transfer_adjust', @user_name    
		END

		FETCH NEXT FROM cur_deals INTO @c_source_Deal_header_id
	END
	
	CLOSE cur_deals 
	DEALLOCATE cur_deals 
END