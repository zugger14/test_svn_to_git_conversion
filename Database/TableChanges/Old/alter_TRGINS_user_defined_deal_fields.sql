/****** Object:  Trigger [dbo].[TRGINS_user_defined_deal_fields]    Script Date: 02/23/2011 15:46:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER TRIGGER [dbo].[TRGINS_user_defined_deal_fields] ON [dbo].[user_defined_deal_fields]
    FOR INSERT
AS
    BEGIN
        UPDATE  user_defined_deal_fields
        SET     create_user = dbo.FNADBUser(),
                create_ts = GETDATE()
        FROM    user_defined_deal_fields s
                INNER JOIN inserted i ON s.udf_deal_id = i.udf_deal_id

--        INSERT  INTO [user_defined_deal_fields_audit]
--                (
--                  [udf_deal_id],
--                  [source_deal_header_id],
--                  [udf_template_id],
--                  [udf_value],
--                  [create_user],
--                  [create_ts],
--                  [update_user],
--                  [update_ts],
--                  [user_action]
--			
--                )
--                SELECT  [udf_deal_id],
--                        [source_deal_header_id],
--                        [udf_template_id],
--                        [udf_value],
--                        [create_user],
--                        [create_ts],
--                        dbo.FNADBUser(),
--                        GETDATE(),
--                        'Insert'
--                FROM    inserted

        PRINT 'Trigger TRGINS_user_defined_deal_fields created.'
    END

