IF OBJECT_ID('[dbo].[TRGUPD_setup_submission_rule]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_setup_submission_rule]
GO

CREATE TRIGGER [dbo].[TRGUPD_setup_submission_rule]
ON [dbo].[setup_submission_rule]
FOR UPDATE
AS
    UPDATE setup_submission_rule
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM setup_submission_rule t
    INNER JOIN DELETED u ON t.rule_id = u.rule_id
GO