SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGDEL_FORMULA_BREAKDOWN]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGDEL_FORMULA_BREAKDOWN]
GO

CREATE TRIGGER [dbo].[TRGDEL_FORMULA_BREAKDOWN]
ON [dbo].[formula_breakdown]
FOR  DELETE
AS
	DECLARE @audit_id INT
	SET @audit_id = ISNULL((SELECT MAX(audit_id) FROM formula_breakdown_audit flda),0) + 1
		
	INSERT INTO formula_breakdown_audit
	(
		audit_id,
		formula_breakdown_id,
		formula_id,
		nested_id,
		formula_level,
		func_name,
		arg_no_for_next_func,
		parent_nested_id,
		level_func_sno,
		parent_level_func_sno,
		arg1,
		arg2,
		arg3,
		arg4,
		arg5,
		arg6,
		arg7,
		arg8,
		arg9,
		arg10,
		arg11,
		arg12,
		eval_value,
		create_user,
		create_ts,
		update_user,
		update_ts,
		formula_nested_id,
		user_action
	)	
	SELECT @audit_id,
	       formula_breakdown_id,
	       formula_id,
	       nested_id,
	       formula_level,
	       func_name,
	       arg_no_for_next_func,
	       parent_nested_id,
	       level_func_sno,
	       parent_level_func_sno,
	       arg1,
	       arg2,
	       arg3,
	       arg4,
	       arg5,
	       arg6,
	       arg7,
	       arg8,
	       arg9,
	       arg10,
	       arg11,
	       arg12,
	       eval_value,
	       create_user,
	       create_ts,
	       update_user,
	       update_ts,
	       formula_nested_id,
	       'delete' [user_action]
	FROM   DELETED