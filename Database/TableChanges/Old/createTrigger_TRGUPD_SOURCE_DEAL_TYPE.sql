SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID('[dbo].[TRGUPD_SOURCE_DEAL_TYPE]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_SOURCE_DEAL_TYPE]
GO

CREATE TRIGGER [dbo].[TRGUPD_SOURCE_DEAL_TYPE]
ON [dbo].[source_deal_type]
FOR UPDATE
AS                                     
    
    DECLARE @update_user  VARCHAR(200)
    DECLARE @update_ts    DATETIME

	SET @update_user = dbo.FNADBUser()
	SET @update_ts = GETDATE()
	
	UPDATE dbo.source_deal_type
       SET update_user = @update_user,
           update_ts = @update_ts
    FROM dbo.source_deal_type sdt
      INNER JOIN DELETED u ON sdt.source_deal_type_id = u.source_deal_type_id  
    
		INSERT INTO source_deal_type_audit
		  (
		    source_deal_type_id,
		    source_system_id,
		    deal_type_id,
		    source_deal_type_name,
		    source_deal_desc,
		    sub_type,
		    expiration_applies,
		    disable_gui_groups,
		    break_individual_deal,
		    seperate_rec_value_used,
		    create_user,
		    create_ts,
		    update_user,
		    update_ts,
		    user_action
		  )
		SELECT source_deal_type_id,
		       source_system_id,
		       deal_type_id,
		       source_deal_type_name,
		       source_deal_desc,
		       sub_type,
		       expiration_applies,
		       disable_gui_groups,
		       break_individual_deal,
		       seperate_rec_value_used,
		       create_user,
		       create_ts,
		       @update_user,
		       @update_ts,
		       'update'
		FROM   INSERTED