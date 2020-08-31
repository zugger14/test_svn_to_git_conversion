SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGDEL_FORMULA_NESTED]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGDEL_FORMULA_NESTED]
GO

CREATE TRIGGER [dbo].[TRGDEL_FORMULA_NESTED]
ON [dbo].[formula_nested]
FOR  DELETE
AS
	DECLARE @audit_id INT
	SET @audit_id = ISNULL((SELECT MAX(audit_id) FROM formula_nested_audit flda),0) + 1
		
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
	       update_user,
	       update_ts,
	       time_bucket_formula_id,
	       'delete' [user_action]
	FROM   DELETED


