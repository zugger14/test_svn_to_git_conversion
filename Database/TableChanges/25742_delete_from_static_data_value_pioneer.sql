DECLARE @new_entity_id INT

IF OBJECT_ID('tempdb..#pioneer_application_users') IS NOT NULL
	DROP TABLE #pioneer_application_users

-- Insert "Pioneer" business users.
SELECT user_login_id, [entity_id], application_users_id
INTO #pioneer_application_users
FROM application_users
WHERE [entity_id] = -10076

-- Update application users 
UPDATE dbo.application_users
SET [entity_id] = NULL
WHERE [entity_id] = -10076

-- Deleting "Pioneer" from Business Unit
DELETE sdv
-- SELECT *
FROM static_data_value sdv
WHERE sdv.value_id = -10076

IF NOT EXISTS (
	SELECT 1
	FROM static_data_value
	WHERE [type_id] = 10076
		AND [code] = 'Pioneer'
)
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description])
	SELECT 10076, 'Pioneer', 'Pioneer'

	SET @new_entity_id = SCOPE_IDENTITY()

	UPDATE au
	SET [entity_id] = @new_entity_id
	-- SELECT *
	FROM application_users au
	INNER JOIN #pioneer_application_users pau ON pau.application_users_id = au.application_users_id
END

GO