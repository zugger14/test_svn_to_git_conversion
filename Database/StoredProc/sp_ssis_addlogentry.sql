IF OBJECT_ID(N'dbo.sp_ssis_addlogentry', N'P') IS NOT NULL
	DROP PROCEDURE dbo.[sp_ssis_addlogentry]
GO


-- =====================================================================================================================================
-- Create date: 2011-09-22
-- Description:	System stored procedure re-created in main db to allow SSIS package execute this SP instead of msdb version. That's why
--				the procedure is not prefixed with spa_.
-- Params:
-- 	@event			SYSNAME - Event captured for loggin.
--	@computer		NVARCHAR(128) - The name of the computer on which the log event occurred.
--	@operator		NVARCHAR(128) - The identity of the user who launched the package.
--	@source			NVARCHAR(1024) - The name of the container or task in which the log event occurred.
--	@sourceid		UNIQUEIDENTIFIER -  The unique identifier of the package; the For Loop, Foreach Loop, or Sequence container;
--										or the task in which the log event occurred.
--	@executionid	UNIQUEIDENTIFIER - The GUID of the package execution instance.
--	@starttime		DATETIME - The time at which the container or task starts to run.
--	@endtime		DATETIME - The time at which the container or task stops running.
--	@datacode		INT - An optional integer value that typically contains a value from the DTSExecResult enumeration 
--							that indicates the result of running the container or task.
--	@databytes		IMAGE - A byte array specific to the log entry. The meaning of this field varies by log entry.
--	@message		NVARCHAR(2048) - A message associated with the log entry.
-- =====================================================================================================================================
CREATE PROCEDURE [dbo].[sp_ssis_addlogentry]
	@event			SYSNAME,
	@computer		NVARCHAR(128),
	@operator		NVARCHAR(128),
	@source			NVARCHAR(1024),
	@sourceid		UNIQUEIDENTIFIER,
	@executionid	UNIQUEIDENTIFIER,
	@starttime		DATETIME,
	@endtime		DATETIME,
	@datacode		INT,
	@databytes		IMAGE,
	@message		NVARCHAR(2048)
AS
	INSERT INTO sysssislog (
		[event],
		computer,
		operator,
		source,
		sourceid,
		executionid,
		starttime,
		endtime,
		datacode,
		databytes,
		[message]
	)
	VALUES (
		@event,
		@computer,
		@operator,
		@source,
		@sourceid,
		@executionid,
		@starttime,
		@endtime,
		@datacode,
		@databytes,
		@message 
	)
	
	RETURN 0