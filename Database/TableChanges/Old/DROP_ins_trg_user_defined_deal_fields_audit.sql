
IF EXISTS (
       SELECT *
       FROM   sys.triggers
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[ins_trg_user_defined_deal_fields_audit]')
   )
    DROP TRIGGER [dbo].[ins_trg_user_defined_deal_fields_audit]