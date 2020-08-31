IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_maintain_wellhead_detail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_maintain_wellhead_detail]

GO

CREATE PROC [dbo].[spa_maintain_wellhead_detail]
@flag as CHAR(1),
@owner_id as INT=NULL,
@owner as VARCHAR(50)=NULL,
@ownership as VARCHAR(50)=NULL,
@effective_date as VARCHAR(100)=NULL,
@short_id as VARCHAR(20)=NULL

AS

DECLARE @sql_stmt VARCHAR(8000)

IF @flag ='s'
BEGIN

SELECT owd.owner_id,dbo.FNAHyperLinkText(10191000,sc.counterparty_name ,sc.source_counterparty_id ) as Owner,owd.ownership_interest [Ownership Interest %],dbo.FNADateFormat(owd.effective_date) [Effective Date]
from ownership_details owd 
inner join source_counterparty sc on owd.owner=sc.source_counterparty_id 
where 1=1 AND owd.short_id like 
				case when @short_id is null then  'null'  else @short_id end 
		
END 

IF @flag ='i'
BEGIN

if exists(select 'x' from ownership_details where owner = @owner and effective_date = @effective_date and short_id =@short_id )
begin
		Exec spa_ErrorHandler -1, 'Ownership', 
				'spa_maintain_wellhead_detail', 'DB Error', 
				'''Owner'' and ''Effective date'' combination already exists.', ''

end
else
BEGIN
INSERT INTO ownership_details(owner,ownership_interest,effective_date,short_id) 
values (@owner,@ownership,@effective_date,@short_id)


if @@error=0
		Exec spa_ErrorHandler 0, 'Ownership', 
				'spa_maintain_wellhead_detail', 'Success', 
				'Ownership Detail was successfully inserted.', ''
else 
		Exec spa_ErrorHandler -1, 'Ownership', 
				'spa_maintain_wellhead_detail', 'DB Error', 
				'Error inserting Ownership Detail.', ''
	
END	

END 

IF @flag ='u'
BEGIN

if exists(select 'x' from ownership_details where owner = @owner and effective_date = @effective_date and short_id =@short_id  and owner_id<>@owner_id)
begin
		Exec spa_ErrorHandler -1, 'Ownership', 
				'spa_maintain_wellhead_detail', 'DB Error', 
				'''Owner'' and ''Effective date'' combination already exists.', ''

end
else



UPDATE ownership_details set owner=@owner,ownership_interest=@ownership,
effective_date =@effective_date where owner_id=@owner_id

	if @@error=0
		Exec spa_ErrorHandler 0, 'Ownership', 
				'spa_maintain_wellhead_detail', 'Success', 
				'Ownership Detail was successfully updated.', ''

	
	
END 

IF @flag ='a'
BEGIN

SELECT owner_id,owner,ownership_interest,effective_date from ownership_details where owner_id=@owner_id


	
	
END 

IF @flag ='d'
BEGIN

DELETE from ownership_details where owner_id=@owner_id

if @@error=0
			Exec spa_ErrorHandler 0, 'Ownership', 
					'spa_maintain_wellhead_detail', 'Success', 
					'Ownership detail was successfully deleted.', ''
	else 
			Exec spa_ErrorHandler -1, 'Ownership', 
					'spa_maintain_wellhead_detail', 'DB Error', 
					'Error deleting Ownership detail.', ''
	
	
END 