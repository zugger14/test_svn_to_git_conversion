IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGINS_state_properties]'))
    DROP TRIGGER [dbo].[TRGINS_state_properties]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGINS_state_properties]
ON [dbo].[state_properties]
FOR INSERT
AS
BEGIN
	UPDATE state_properties SET create_user =  dbo.FNADBUser(), create_ts = getdate() where  state_properties.state_value_id in (select state_value_id from inserted)
END
GO