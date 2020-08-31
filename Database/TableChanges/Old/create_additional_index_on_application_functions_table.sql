-----DATE : 18th January 2012 
----- Author : Santosh Gupta 
-----Eventum Issue ID : #3973
-----Purpose: Additional Indexes were required in this table from Performance point of view
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.application_functions') 
AND name = N'IX_application_functions_func_ref_id')
BEGIN
   CREATE  INDEX IX_application_functions_func_ref_id ON
    dbo.application_functions(func_ref_id)
     WITH FILLFACTOR = 70
   PRINT 'Index IX_application_functions_func_ref_id created.'
END
ELSE
BEGIN
	PRINT 'Index IX_application_functions_func_ref_id already exists.'
END
GO



