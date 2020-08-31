SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

ALTER TRIGGER [dbo].[TRGINS_ASSIGNMENT_AUDIT]
ON [dbo].[assignment_audit]
FOR INSERT
AS
UPDATE ASSIGNMENT_AUDIT SET create_user =dbo.FNADBUser(), create_ts = getdate() where assignment_id in 
(select assignment_id from inserted)

UPDATE 
	source_deal_detail 
	set volume_left=sdd.volume_left-ins.assigned_volume
	from source_deal_detail sdd inner join 
		(select source_deal_header_id_from,sum(inserted.assigned_volume) assigned_volume
			 from inserted group by source_deal_header_id_from) ins
	on sdd.source_deal_detail_id=ins.source_deal_header_id_from






