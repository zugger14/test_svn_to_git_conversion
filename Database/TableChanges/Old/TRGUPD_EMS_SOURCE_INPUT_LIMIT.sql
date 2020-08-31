set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- ================================================================================
-- Author:		<Sudeep Lamsal>
-- Create date: <18th March, 2010>
-- Update date: <>
-- Description:	<Update DatabaseUser, Timestamp into table: ems_source_input_limit>
-- =================================================================================

ALTER TRIGGER [TRGUPD_EMS_SOURCE_INPUT_LIMIT]
ON [dbo].[ems_source_input_limit]
FOR UPDATE
AS
BEGIN
	UPDATE ems_source_input_limit 
	SET update_user =  dbo.FNADBUser(), 
		update_ts = getdate() 
	WHERE ems_source_input_limit.input_limit_id 
	in (select input_limit_id from deleted)
END

