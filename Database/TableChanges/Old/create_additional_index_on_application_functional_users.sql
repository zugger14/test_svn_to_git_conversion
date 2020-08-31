-----DATE : 18th January 2012 
----- Author : Santosh Gupta 
-----Eventum Issue ID : #3973
-----Purpose: Additional Indexes were required in this table from Performance point of view

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.application_functional_users') 
AND name = N'IX_application_functional_users_role_id')
BEGIN
   CREATE  INDEX IX_application_functional_users_role_id ON
    dbo.application_functional_users(role_id)
    WITH FILLFACTOR = 70
   PRINT 'Index IX_application_functional_users_role_id created.'
END
ELSE
BEGIN
	PRINT 'Index IX_application_functional_users_role_id already exists.'
END
GO



IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.application_functional_users') 
AND name = N'IX_application_functional_users_function_id')
BEGIN
   CREATE  INDEX IX_application_functional_users_function_id ON
    dbo.application_functional_users(function_id)
   WITH FILLFACTOR = 70
   PRINT 'Index IX_application_functional_users_function_id created.'
END
ELSE
BEGIN
	PRINT 'Index IX_application_functional_users_function_id already exists.'
END
GO

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.application_functional_users') 
AND name = N'IX_application_functional_users_role_id')
BEGIN
   CREATE  INDEX IX_application_functional_users_role_id ON
    dbo.application_functional_users(role_id)
     WITH FILLFACTOR = 70
   PRINT 'Index IX_application_functional_users_role_id created.'
END
ELSE
BEGIN
	PRINT 'Index IX_application_functional_users_role_id already exists.'
END
GO

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.application_functional_users') 
AND name = N'IX_application_functional_users_entity_id')
BEGIN
   CREATE  INDEX IX_application_functional_users_entity_id ON
    dbo.application_functional_users(entity_id)
      WITH FILLFACTOR = 70
   PRINT 'Index IX_application_functional_users_entity_id created.'
END
ELSE
BEGIN
	PRINT 'Index IX_application_functional_users_entity_id already exists.'
END
GO