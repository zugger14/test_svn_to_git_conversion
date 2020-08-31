
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGUPD_TERM_MAP_DETAIL]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_TERM_MAP_DETAIL]
GO

CREATE TRIGGER [dbo].[TRGUPD_TERM_MAP_DETAIL]
ON [dbo].[term_map_detail]
FOR  UPDATE
AS
	UPDATE term_map_detail
	SET    update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	WHERE  term_map_detail.term_map_id IN (SELECT term_map_id
	                                       FROM   DELETED)



