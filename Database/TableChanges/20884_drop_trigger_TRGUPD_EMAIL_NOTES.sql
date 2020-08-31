--drop update_ts trigger as fs data trigger updates the table and update_ts is used to track email update info by users.
IF OBJECT_ID('[dbo].[TRGUPD_EMAIL_NOTES]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_EMAIL_NOTES]
GO
