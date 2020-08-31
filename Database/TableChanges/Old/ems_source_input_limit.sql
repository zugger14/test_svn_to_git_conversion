-- ================================================================================
-- Author:		<Sudeep Lamsal>
-- Create date: <12th April, 2010>
-- Update date: <>
-- Description:	<Limit Definition Table>
-- =================================================================================


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ems_source_input_limit]') AND type in (N'U'))
DROP TABLE [dbo].[ems_source_input_limit]

GO
CREATE TABLE [dbo].[ems_source_input_limit](
	[input_limit_id] [int] IDENTITY(1,1) NOT NULL,
	[ems_source_input_id] [int] NULL, -- will not be needed
	[source_generator_id] [int] NOT NULL,
	[criteria_id] [int] NOT NULL,
	[curve_id] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[uom_id] [int] NOT NULL,
	[series_value_id] [int] NOT NULL,
	[lower_limit_value] [float] NOT NULL,
	[upper_limit_value] [float] NOT NULL,
	[create_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[create_ts] [datetime] NOT NULL,
	[update_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[update_ts] [datetime] NOT NULL,
 CONSTRAINT [IX_ems_source_input_limit] UNIQUE NONCLUSTERED 
(
	[input_limit_id] ASC,
	[source_generator_id] ASC,
	[criteria_id] ASC,
	[curve_id] ASC,
	[series_value_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF

GO
CREATE TRIGGER [TRGINS_EMS_SOURCE_INPUT_LIMIT]
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

GO
CREATE TRIGGER [TRGUPD_EMS_SOURCE_INPUT_LIMIT]
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