--user_defined_deal_fields_audit
IF OBJECT_ID(N'user_defined_deal_fields_audit', N'U') IS NULL 
    BEGIN
        CREATE TABLE [dbo].[user_defined_deal_fields_audit]
            (
              [udf_audit_id] INT IDENTITY(1,1)  NOT NULL,
              [udf_deal_id] INT,
              [source_deal_header_id] INT,
              [udf_template_id] INT,
              [udf_value] VARCHAR(100),
              [create_user] VARCHAR(50),
              [create_ts] DATETIME,
              [update_user] VARCHAR(50),
              [update_ts] DATETIME,
              [user_action] VARCHAR(50),
              [header_audit_id] INT,
              CONSTRAINT [PK_user_defined_deal_fields_audit] PRIMARY KEY CLUSTERED ( [udf_audit_id] ASC )
            ) 

--        ALTER TABLE [dbo].[user_defined_deal_fields_audit]
--                WITH NOCHECK
--        ADD CONSTRAINT [FK_user_defined_deal_fields_audit_source_deal_header_audit] FOREIGN KEY ( [header_audit_id] ) REFERENCES [dbo].[source_deal_header_audit] ( [audit_id] )
--
--        ALTER TABLE [dbo].[user_defined_deal_fields_audit]
--                CHECK CONSTRAINT [FK_user_defined_deal_fields_audit_source_deal_header_audit]

        PRINT 'Table user_defined_deal_fields_audit created.'
    END
ELSE 
    BEGIN
        PRINT 'Table user_defined_deal_fields_audit already exists.'
    END

--create triggers on user_defined_deal_fields table.
--insert trigger
IF OBJECT_ID(N'TRGINS_user_defined_deal_fields', N'TR') IS NOT NULL 
    DROP TRIGGER TRGINS_user_defined_deal_fields

GO

CREATE TRIGGER [TRGINS_user_defined_deal_fields] ON [dbo].[user_defined_deal_fields]
    FOR INSERT
AS
    BEGIN
        UPDATE  user_defined_deal_fields
        SET     create_user = dbo.FNADBUser(),
                create_ts = GETDATE()
        FROM    user_defined_deal_fields s
                INNER JOIN inserted i ON s.udf_deal_id = i.udf_deal_id

        INSERT  INTO [user_defined_deal_fields_audit]
                (
                  [udf_deal_id],
                  [source_deal_header_id],
                  [udf_template_id],
                  [udf_value],
                  [create_user],
                  [create_ts],
                  [update_user],
                  [update_ts],
                  [user_action]
			
                )
                SELECT  [udf_deal_id],
                        [source_deal_header_id],
                        [udf_template_id],
                        [udf_value],
                        [create_user],
                        [create_ts],
                        dbo.FNADBUser(),
                        GETDATE(),
                        'Insert'
                FROM    inserted

        PRINT 'Trigger TRGINS_user_defined_deal_fields created.'
    END

GO 
--delete trigger
    IF OBJECT_ID(N'TRGDEL_user_defined_deal_fields',N'TR') IS NOT NULL 
        DROP TRIGGER TRGDEL_user_defined_deal_fields
GO

CREATE TRIGGER [TRGDEL_user_defined_deal_fields] ON [dbo].[user_defined_deal_fields]
    FOR DELETE
AS
    BEGIN
        INSERT  INTO [user_defined_deal_fields_audit]
                (
                  [udf_deal_id],
                  [source_deal_header_id],
                  [udf_template_id],
                  [udf_value],
                  [create_user],
                  [create_ts],
                  [update_user],
                  [update_ts],
                  [user_action]
			
                )
                SELECT  [udf_deal_id],
                        [source_deal_header_id],
                        [udf_template_id],
                        [udf_value],
                        [create_user],
                        [create_ts],
                        dbo.FNADBUser(),
                        GETDATE(),
                        'Delete'
                FROM    deleted

        PRINT 'Trigger TRGDEL_user_defined_deal_fields created.'
    END

GO
--update trigger
    IF OBJECT_ID(N'TRGUPD_user_defined_deal_fields', N'TR') IS NOT NULL 
        DROP TRIGGER TRGUPD_user_defined_deal_fields

GO
CREATE TRIGGER [TRGUPD_user_defined_deal_fields] ON [dbo].[user_defined_deal_fields]
    FOR UPDATE
AS
    BEGIN
        UPDATE  user_defined_deal_fields
        SET     update_user = dbo.FNADBUser(),
                update_ts = GETDATE()
        FROM    user_defined_deal_fields s
                INNER JOIN deleted d ON s.udf_deal_id = d.udf_deal_id

        IF NOT UPDATE(create_user)
            AND NOT UPDATE(create_ts) 
            INSERT  INTO [user_defined_deal_fields_audit]
                    (
                      [udf_deal_id],
                      [source_deal_header_id],
                      [udf_template_id],
                      [udf_value],
                      [create_user],
                      [create_ts],
                      [update_user],
                      [update_ts],
                      [user_action]
			  )
                    SELECT  [udf_deal_id],
                            [source_deal_header_id],
                            [udf_template_id],
                            [udf_value],
                            [create_user],
                            [create_ts],
                            dbo.FNADBUser(),
                            GETDATE(),
                            'Update'
                    FROM    inserted

        PRINT 'Trigger TRGUPD_user_defined_deal_fields created.'
    END

GO
--create triggers on user_defined_deal_fields_audit
    IF OBJECT_ID(N'ins_trg_user_defined_deal_fields_audit', N'TR') IS NOT NULL 
        DROP TRIGGER ins_trg_user_defined_deal_fields_audit

GO

CREATE TRIGGER [ins_trg_user_defined_deal_fields_audit] ON [dbo].[user_defined_deal_fields_audit]
    AFTER INSERT
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON ;
        DECLARE @audit_id INT,
            @action VARCHAR(100)

        SELECT  @action = user_action
        FROM    inserted

        SELECT  @audit_id = IDENT_CURRENT('source_deal_header_audit')
                + CASE WHEN @action = 'Delete' THEN 1
                       ELSE 0
                  END
        FROM    source_deal_header_audit 

        UPDATE  user_defined_deal_fields_audit
        SET     header_audit_id = @audit_id
        FROM    user_defined_deal_fields_audit s
                INNER JOIN inserted i ON i.udf_audit_id = s.udf_audit_id
                                         AND s.header_audit_id IS NULL

        PRINT 'Trigger ins_trg_user_defined_deal_fields_audit created.'
    END

