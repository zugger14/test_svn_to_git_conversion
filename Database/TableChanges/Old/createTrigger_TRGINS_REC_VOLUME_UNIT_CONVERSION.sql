SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGINS_REC_VOLUME_UNIT_CONVERSION]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGINS_REC_VOLUME_UNIT_CONVERSION]
GO

CREATE TRIGGER [dbo].[TRGINS_REC_VOLUME_UNIT_CONVERSION]
ON [dbo].[rec_volume_unit_conversion]
FOR  INSERT
AS

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
	       update_user,
	       update_ts,
	       effective_date,
	       source,
	       to_curve_id,
	       'insert'
	FROM   INSERTED


