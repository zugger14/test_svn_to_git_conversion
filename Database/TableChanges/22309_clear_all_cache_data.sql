IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
BEGIN
	EXEC [spa_manage_memcache] @flag = 'd', @other_key_source='Privilege', @source_object = 'spa_AccessRights @flag=i'
END	