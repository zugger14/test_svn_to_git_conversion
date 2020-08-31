/*
Vishwas Khanal
Dated : 09.April.2009
Compliance Integration to TRM
*/
IF NOT EXISTS (SELECT 'X' FROM information_schema.tables WHERE table_name = 'process_notes_map' and TABLE_SCHEMA = 'dbo')
BEGIN

	CREATE TABLE [dbo].[process_notes_map](
		[process_notes_map_id] [int] IDENTITY(1,1) NOT NULL,
		[notes_id] [int] NOT NULL,
		[process_risk_control_id] [int] NOT NULL,
	 CONSTRAINT [PK_process_notes_map] PRIMARY KEY CLUSTERED 
	(
		[process_notes_map_id] ASC
	)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY]

	
	ALTER TABLE [dbo].[process_notes_map]  WITH NOCHECK ADD  CONSTRAINT [FK_process_notes_map_process_notes_map] FOREIGN KEY([notes_id])
	REFERENCES [dbo].[application_notes] ([notes_id])
	
	ALTER TABLE [dbo].[process_notes_map] CHECK CONSTRAINT [FK_process_notes_map_process_notes_map]

END
