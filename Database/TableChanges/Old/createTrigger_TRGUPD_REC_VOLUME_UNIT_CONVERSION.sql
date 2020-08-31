SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID('[dbo].[TRGUPD_REC_VOLUME_UNIT_CONVERSION]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_REC_VOLUME_UNIT_CONVERSION]
GO

CREATE TRIGGER [dbo].[TRGUPD_REC_VOLUME_UNIT_CONVERSION]
ON [dbo].[rec_volume_unit_conversion]
FOR UPDATE
AS                                     
    
    DECLARE @update_user  VARCHAR(200)
    DECLARE @update_ts    DATETIME

	SET @update_user = dbo.FNADBUser()
	SET @update_ts = GETDATE()
	
	UPDATE dbo.[rec_volume_unit_conversion]
       SET update_user = @update_user,
           update_ts = @update_ts
    FROM dbo.rec_volume_unit_conversion rvuc
      INNER JOIN DELETED u ON rvuc.rec_volume_unit_conversion_id = u.rec_volume_unit_conversion_id  
    
	INSERT INTO rec_volume_unit_conversion_audit
	  (
	    rec_volume_unit_conversion_id,
	    state_value_id,
	    curve_id,
	    assignment_type_value_id,
	    from_source_uom_id,
	    to_source_uom_id,
	    conversion_factor,
	    uom_label,
	    curve_label,
	    create_user,
	    create_ts,
	    update_user,
	    update_ts,
	    effective_date,
	    source,
	    to_curve_id,
	    user_action
	  )
	SELECT rec_volume_unit_conversion_id,
	       state_value_id,
	       curve_id,
	       assignment_type_value_id,
	       from_source_uom_id,
	       to_source_uom_id,
	       conversion_factor,
	       uom_label,
	       curve_label,
	       create_user,
	       create_ts,
	       @update_user,
	       @update_ts,
	       effective_date,
	       source,
	       to_curve_id,
	       'update' [user_action]
	FROM   INSERTED
	
