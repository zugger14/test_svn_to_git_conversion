SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID('[dbo].[TRGUPD_SOURCE_UOM]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_SOURCE_UOM]
GO

CREATE TRIGGER [dbo].[TRGUPD_SOURCE_UOM]
ON [dbo].[source_uom]
FOR UPDATE
AS                                     
    
    DECLARE @update_user  VARCHAR(200)
    DECLARE @update_ts    DATETIME

	SET @update_user = dbo.FNADBUser()
	SET @update_ts = GETDATE()
	
	UPDATE dbo.source_uom
       SET update_user = @update_user,
           update_ts = @update_ts
    FROM dbo.source_uom su
      INNER JOIN DELETED u ON su.source_uom_id = u.source_uom_id  
    
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
		   @update_user,
		   @update_ts,
	       'update' [user_action]
	FROM   INSERTED