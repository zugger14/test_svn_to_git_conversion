--	Update Trigger
IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_ice_security_definition]'))
    DROP TRIGGER [dbo].[TRGUPD_ice_security_definition]
GO

CREATE TRIGGER [dbo].[TRGUPD_ice_security_definition]
ON [dbo].[ice_security_definition]
FOR UPDATE
AS  	
	UPDATE dbo.ice_security_definition
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM dbo.ice_security_definition isd
      INNER JOIN DELETED u ON isd.id = u.id  
GO