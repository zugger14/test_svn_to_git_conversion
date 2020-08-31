UPDATE counterparty_credit_limits_audit
SET user_action = CASE WHEN user_action = 'i' THEN 'insert'
					   WHEN user_action = 'u' THEN 'update'
					   WHEN user_action = 'd' THEN 'delete'
				  ELSE user_action
				  END