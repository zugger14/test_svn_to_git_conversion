SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGINS_SOURCE_BOOK]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGINS_SOURCE_BOOK]
GO

CREATE TRIGGER [dbo].[TRGINS_SOURCE_BOOK]
ON [dbo].[source_book]
FOR  INSERT
AS

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
		ISNULL(create_user, dbo.FNADBUser()),
		ISNULL(create_ts, GETDATE()),
		update_user,
		update_ts,
		'insert' 
	FROM INSERTED
	

	


