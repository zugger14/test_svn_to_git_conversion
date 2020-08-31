SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGDEL_HOURLY_BLOCK]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGDEL_HOURLY_BLOCK]
GO

CREATE TRIGGER [dbo].[TRGDEL_HOURLY_BLOCK]
ON [dbo].[hourly_block]
FOR  DELETE
AS

	INSERT INTO hourly_block_audit
	  (
	    block_value_id,
	    week_day,
	    onpeak_offpeak,
	    holiday_value_id,
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
	    dst_applies,
	    user_action
	  )
	SELECT block_value_id,
	       week_day,
	       onpeak_offpeak,
	       holiday_value_id,
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
	       dst_applies,
	       'delete'
	FROM   DELETED


