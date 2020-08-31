SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGDEL_SOURCE_CURRENCY]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGDEL_SOURCE_CURRENCY]
GO

CREATE TRIGGER [dbo].[TRGDEL_SOURCE_CURRENCY]
ON [dbo].[source_currency]
FOR  DELETE
AS
	INSERT INTO source_currency_audit
	  (
	    [source_currency_id],
	    [source_system_id],
	    [currency_id],
	    [currency_name],
	    [currency_desc],
	    [currency_id_to],
	    [factor],
	    [create_user],
	    [create_ts],
	    [update_user],
	    [update_ts],
	    [user_action]
	  )
	SELECT [source_currency_id],
	       [source_system_id],
	       [currency_id],
	       [currency_name],
	       [currency_desc],
	       [currency_id_to],
	       [factor],
	       [create_user],
	       [create_ts],
	       dbo.FNADBUser(),
	       GETDATE(),
	       'delete'
	FROM   DELETED