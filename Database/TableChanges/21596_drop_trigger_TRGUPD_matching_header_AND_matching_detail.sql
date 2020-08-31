--Dropped existing trigger and creating new 'TRGIUD_matching_header', 'TRGIUD_matching_detail' for ALL INSERT, UPDATE and DELETE
--In this trigger update info of matching_header also updated by trigger but it was creating issue while inserting to the audit table
--so these columns are updated from the SP
IF OBJECT_ID('TRGUPD_matching_header') IS NOT NULL
	DROP TRIGGER [dbo].[TRGUPD_matching_header]

IF OBJECT_ID('TRGUPD_matching_detail') IS NOT NULL
	DROP TRIGGER [dbo].[TRGUPD_matching_detail]
