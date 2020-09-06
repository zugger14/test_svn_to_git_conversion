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

	DECLARE @sql NVARCHAR(MAX)
	DECLARE @user_name NVARCHAR(100) = dbo.FNADBUSER()
	
	IF @process_id IS NULL
		SET @process_id = dbo.FNAGetNewID()

IF @flag = 'a' --AUTO DEAL SCHEDULE BLOCK
BEGIN
    IF EXISTS( SELECT  uddf.udf_value
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
               WHERE sdh.source_deal_header_id =  @source_deal_header_id --7385 --
                   AND udft.Field_label = 'Delivery Path'
                   AND NULLIF(uddf.udf_value, '') IS NOT NULL
				     AND sdt.deal_type_id <> 'Transportation'

    )
    BEGIN
        --WAITFOR DELAY '00:01:00';			   
        --DECLARE @col INT
		
        DECLARE @job_name1 NVARCHAR(100)

        SET @sql = ' [dbo].[spa_transfer_adjust] ' + CAST(@source_deal_header_id AS VARCHAR(10)) 
			   
        SET @job_name1 = 'transfer_adjust_' + @process_id
     
        EXEC spa_run_sp_as_job @job_name1, @sql, 'spa_transfer_adjust', @user_name    
    END
END