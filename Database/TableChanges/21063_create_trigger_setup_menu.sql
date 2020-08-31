SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGINS_setup_menu]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGINS_setup_menu]
GO

CREATE TRIGGER [dbo].[TRGINS_setup_menu]
ON [dbo].[setup_menu]
FOR  INSERT
AS
	 
IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
BEGIN		
	EXEC [spa_manage_memcache] @flag = 'd', @cmbobj_key_source = 'setup_menu', @other_key_source = 'MainMenu', @source_object = 'TRGINS_setup_menu'			
END
	
GO 

IF OBJECT_ID('[dbo].[TRGUPD_setup_menu]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_setup_menu]
GO

CREATE TRIGGER [dbo].[TRGUPD_setup_menu]
ON [dbo].[setup_menu]
FOR  UPDATE
AS
	 
IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
BEGIN		
	EXEC [spa_manage_memcache] @flag = 'd', @cmbobj_key_source = 'setup_menu', @other_key_source = 'MainMenu', @source_object = 'TRGUPD_setup_menu'	
END
GO	
IF OBJECT_ID('[dbo].[TRGDEL_setup_menu]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGDEL_setup_menu]
GO

CREATE TRIGGER [dbo].[TRGDEL_setup_menu]
ON [dbo].[setup_menu]
FOR  DELETE
AS
	 
IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
BEGIN		
	EXEC [spa_manage_memcache] @flag = 'd', @cmbobj_key_source = 'setup_menu', @other_key_source = 'MainMenu', @source_object = 'TRGDEL_setup_menu'	
END

	