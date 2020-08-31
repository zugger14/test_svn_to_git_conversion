IF NOT EXISTS (
       SELECT 1
       FROM   sys.key_constraints AS kc
       WHERE  kc.parent_object_id = OBJECT_ID(N'[dbo].[compliance_group]')
              AND kc.name = N'ucCol'
   )
BEGIN
    ALTER TABLE compliance_group ADD CONSTRAINT ucCol UNIQUE(
        logical_name,
        assignment_type,
        assigned_state,
        compliance_year,
        commit_type
    )
    PRINT 'Unique constraint added successfully.'
END
ELSE
	BEGIN
		PRINT 'Unique constraint with name ucCol already exist.'
	END