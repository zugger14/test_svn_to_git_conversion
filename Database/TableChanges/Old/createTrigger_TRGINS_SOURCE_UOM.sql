SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGINS_SOURCE_UOM]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGINS_SOURCE_UOM]
GO

CREATE TRIGGER [dbo].[TRGINS_SOURCE_UOM]
ON [dbo].[source_uom]
FOR  INSERT
AS

	INSERT INTO source_uom_audit
	  (
		source_uom_id,
		source_system_id,
		uom_id,
		uom_name,
		uom_desc,
		create_user,
		create_ts,
		update_user,
		update_ts,
		user_action
	  )
	SELECT source_uom_id,
		   source_system_id,
		   uom_id,
		   uom_name,
		   uom_desc,
		   create_user,
		   create_ts,
		   update_user,
		   update_ts,
		   'insert'
	FROM   INSERTED


