/****** Object:  Trigger [dbo].[TRGUPD_FORMULA_NESTED]    Script Date: 01/10/2012 02:37:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGUPD_FORMULA_NESTED]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_FORMULA_NESTED]
GO

CREATE TRIGGER [dbo].[TRGUPD_FORMULA_NESTED]
ON [dbo].[formula_nested]
FOR UPDATE
AS

	DECLARE @update_user    VARCHAR(200)
	DECLARE @update_ts  DATETIME

	SET @update_user = dbo.FNADBUser()
	SET @update_ts = GETDATE()
	                                     
	UPDATE dbo.formula_nested
       SET update_user = @update_user,
           update_ts = @update_ts
    FROM dbo.formula_nested fe
      INNER JOIN DELETED u ON fe.formula_id = u.formula_id     

	DECLARE @audit_id INT
	SET @audit_id = ISNULL((SELECT MAX(audit_id)  FROM formula_nested_audit fna), 0) + 1

	INSERT INTO formula_nested_audit
	(
		audit_id,
		id,
		sequence_order,
		description1,
		description2,
		formula_id,
		formula_group_id,
		granularity,
		include_item,
		show_value_id,
		uom_id,
		rate_id,
		total_id,
		create_user,
		create_ts,
		update_user,
		update_ts,
		time_bucket_formula_id,
		user_action
	)
	SELECT @audit_id,
		id,
		sequence_order,
		description1,
		description2,
		formula_id,
		formula_group_id,
		granularity,
		include_item,
		show_value_id,
		uom_id,
		rate_id,
		total_id,
		create_user,
		create_ts,
		@update_user,
		@update_ts,
		time_bucket_formula_id,
		'update' [user_action]
	FROM   INSERTED