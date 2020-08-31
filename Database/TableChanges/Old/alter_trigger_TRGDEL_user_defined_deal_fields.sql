IF EXISTS(select 1 from sys.triggers where name = 'TRGDEL_user_defined_deal_fields')
DROP TRIGGER [dbo].[TRGDEL_user_defined_deal_fields] 


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[TRGDEL_user_defined_deal_fields] ON [dbo].[user_defined_deal_fields]
    FOR DELETE
AS
    BEGIN
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
--                        'Delete'
--                FROM    deleted

    RETURN
    END


