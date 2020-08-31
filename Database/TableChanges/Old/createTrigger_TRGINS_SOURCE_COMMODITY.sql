SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGINS_SOURCE_COMMODITY]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGINS_SOURCE_COMMODITY]
GO

CREATE TRIGGER [dbo].[TRGINS_SOURCE_COMMODITY]
ON [dbo].[source_commodity]
FOR  INSERT
AS
	INSERT INTO source_commodity_audit
	  (
	    [source_commodity_id],
	    [source_system_id],
	    [commodity_id],
	    [commodity_name],
	    [commodity_desc],
	    [create_user],
	    [create_ts],
	    [update_user],
	    [update_ts],
	    [user_action]
	  )
	SELECT [source_commodity_id],
	       [source_system_id],
	       [commodity_id],
	       [commodity_name],
	       [commodity_desc],
	       ISNULL([create_user], dbo.FNADBUser()),
	       ISNULL([create_ts], GETDATE()),
	       [update_user],
	       [update_ts],
	       'insert'
	FROM   INSERTED