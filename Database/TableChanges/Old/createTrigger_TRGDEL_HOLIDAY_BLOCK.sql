SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGDEL_HOLIDAY_BLOCK]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGDEL_HOLIDAY_BLOCK]
GO

CREATE TRIGGER [dbo].[TRGDEL_HOLIDAY_BLOCK]
ON [dbo].[holiday_block]
FOR  DELETE
AS
	INSERT INTO holiday_block_audit
	  (
	    holiday_block_id,
	    block_value_id,
	    Onpeak_offpeak,
	    Hr1,
	    Hr2,
	    Hr3,
	    Hr4,
	    Hr5,
	    Hr6,
	    Hr7,
	    Hr8,
	    Hr9,
	    Hr10,
	    Hr11,
	    Hr12,
	    Hr13,
	    Hr14,
	    Hr15,
	    Hr16,
	    Hr17,
	    Hr18,
	    Hr19,
	    Hr20,
	    Hr21,
	    Hr22,
	    Hr23,
	    Hr24,
	    create_user,
	    create_ts,
	    update_user,
	    update_ts,
	    user_action
	  )
	SELECT holiday_block_id,
	       block_value_id,
	       Onpeak_offpeak,
	       Hr1,
	       Hr2,
	       Hr3,
	       Hr4,
	       Hr5,
	       Hr6,
	       Hr7,
	       Hr8,
	       Hr9,
	       Hr10,
	       Hr11,
	       Hr12,
	       Hr13,
	       Hr14,
	       Hr15,
	       Hr16,
	       Hr17,
	       Hr18,
	       Hr19,
	       Hr20,
	       Hr21,
	       Hr22,
	       Hr23,
	       Hr24,
	       create_user,
	       create_ts,
	       dbo.FNADBUser(),
	       GETDATE(),
	       'delete'
	FROM   DELETED


