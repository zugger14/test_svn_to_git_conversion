/****** Object:  Trigger [dbo].[TRGUPD_user_defined_deal_fields]    Script Date: 02/23/2011 15:46:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TRIGGER [dbo].[TRGUPD_user_defined_deal_fields] ON [dbo].[user_defined_deal_fields]
    FOR UPDATE
AS
    BEGIN
        UPDATE  user_defined_deal_fields
        SET     update_user = dbo.FNADBUser(),
                update_ts = GETDATE()
        FROM    user_defined_deal_fields s
                INNER JOIN deleted d ON s.udf_deal_id = d.udf_deal_id

--        IF NOT UPDATE(create_user)
--            AND NOT UPDATE(create_ts) 
--            INSERT  INTO [user_defined_deal_fields_audit]
--                    (
--                      [udf_deal_id],
--                      [source_deal_header_id],
--                      [udf_template_id],
--                      [udf_value],
--                      [create_user],
--                      [create_ts],
--                      [update_user],
--                      [update_ts],
--                      [user_action]
--			  )
--                    SELECT  [udf_deal_id],
--                            [source_deal_header_id],
--                            [udf_template_id],
--                            [udf_value],
--                            [create_user],
--                            [create_ts],
--                            dbo.FNADBUser(),
--                            GETDATE(),
--                            'Update'
--                    FROM    inserted

        PRINT 'Trigger TRGUPD_user_defined_deal_fields created.'
    END

