set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- ================================================================================
-- Author:		<Sudeep Lamsal>
-- Create date: <18th March, 2010>
-- Update date: <>
-- Description:	<Insert DatabaseUser, Timestamp into table: ems_source_input_limit>
-- =================================================================================

ALTER TRIGGER [TRGINS_EMS_SOURCE_INPUT_LIMIT]
ON [dbo].[ems_source_input_limit]
FOR INSERT
AS
BEGIN
	UPDATE ems_source_input_limit 
	SET create_user =  dbo.FNADBUser(), 
		create_ts = getdate() 
	WHERE  ems_source_input_limit.input_limit_id 
	in (select input_limit_id from inserted)
END

