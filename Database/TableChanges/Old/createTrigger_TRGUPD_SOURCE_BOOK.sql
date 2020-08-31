SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID('[dbo].[TRGUPD_SOURCE_BOOK]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_SOURCE_BOOK]
GO

CREATE TRIGGER [dbo].[TRGUPD_SOURCE_BOOK]
ON [dbo].[source_book]
FOR UPDATE
AS                                     
    
    DECLARE @update_user  VARCHAR(200)
    DECLARE @update_ts    DATETIME

	SET @update_user = dbo.FNADBUser()
	SET @update_ts = GETDATE()
	
	UPDATE dbo.source_book
       SET update_user = @update_user,
           update_ts = @update_ts
    FROM dbo.source_book sb
      INNER JOIN DELETED u ON sb.source_book_id = u.source_book_id  
    
	INSERT INTO source_book_audit
	(
		source_book_id,
		source_system_id,
		source_system_book_id,
		source_system_book_type_value_id,
		source_book_name,
		source_book_desc,
		source_parent_book_id,
		source_parent_type,
		create_user,
		create_ts,
		update_user,
		update_ts,
		user_action
	)
	SELECT 
		source_book_id,
		source_system_id,
		source_system_book_id,
		source_system_book_type_value_id,
		source_book_name,
		source_book_desc,
		source_parent_book_id,
		source_parent_type,
		create_user,
		create_ts,
		@update_user,
		@update_ts,
		'update' [user_action] 
	FROM INSERTED