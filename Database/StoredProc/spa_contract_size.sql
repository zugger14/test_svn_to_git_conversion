/****** Object:  StoredProcedure [dbo].[spa_contract_size]    Script Date: 01/15/2009 13:23:16 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_contract_size]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_contract_size]
go
create PROCEDURE [dbo].[spa_contract_size]
	@flag CHAR(1),
	@id int=null,
    @contract_id int=null,
	@counterparty_id int=null,
	@commodity_id int=null,
	@volume varchar(150)=null,
	@uom_id int=null

AS 

IF @flag='s'	
BEGIN
	select id as [ID],cs.contract_id ,sc.contract_name as [Contract],cs.counterparty_id ,sco.counterparty_name as [Counterparty],
	cs.commodity_id ,scom.commodity_name as [Commodity],cs.volume as [Volume],cs.uom_id ,su.uom_name as [UoM]
	from  contract_size cs

	join contract_group sc on sc.contract_id=cs.contract_id
	join source_counterparty sco on sco.source_counterparty_id=cs.counterparty_id
	join source_commodity scom on scom.source_commodity_id=cs.commodity_id
	join source_uom su on su.source_uom_id=cs.uom_id
--	where 
--	id=@id
end
IF @flag='r'	
BEGIN
	select id as [ID],sc.contract_name as [Contract],sco.counterparty_name as [Counterparty],
	scom.commodity_name as [Commodity],cs.volume as [Volume],su.uom_name as [UoM]
	from  contract_size cs

	join contract_group sc on sc.contract_id=cs.contract_id
	join source_counterparty sco on sco.source_counterparty_id=cs.counterparty_id
	join source_commodity scom on scom.source_commodity_id=cs.commodity_id
	join source_uom su on su.source_uom_id=cs.uom_id
--	where 
--	id=@id
end
else if @flag='a'
	select contract_id ,counterparty_id ,commodity_id ,volume,uom_id
	from 
	contract_size
	where 
	id=@id 
else if @flag='i'
begin
INSERT into contract_size (contract_id ,counterparty_id ,commodity_id ,volume,uom_id)
			values(@contract_id ,@counterparty_id ,@commodity_id ,@volume,@uom_id)
If @@ERROR <> 0
	Exec spa_ErrorHandler  @@ERROR, 'Contract Size', 
		'spa_counterparty_contract', 'DB Error', 
		'Failed to insert contract.', ''
Else
	Exec spa_ErrorHandler 0, 'Contract Size', 
		'spa_contract_size', 'Success', 
		'Contract successfully inserted.',''

end	
else if @flag='u'
begin
 update contract_size
	SET
		contract_id = @contract_id,
		counterparty_id = @counterparty_id,
		commodity_id =@commodity_id,
		volume = @volume,
		uom_id = @uom_id
where 
	id=@id 
If @@ERROR <> 0
	Exec spa_ErrorHandler  @@ERROR, 'Contract Size', 
		'spa_contract_size', 'DB Error', 
		'Failed to update contract.', ''		

Else

	Exec spa_ErrorHandler 0, 'Contract Size', 
		'spa_contract_size', 'Success', 
		'Contract successfully updated.',''
end	
else if @flag='d'
begin
	delete contract_size where 
	id=@id and contract_id=@contract_id
		If @@ERROR <> 0
			Exec spa_ErrorHandler  @@ERROR, 'Contract Size', 
				'spa_contract_size', 'DB Error', 
				'Failed to delete contract.', ''
		
		Else
			Exec spa_ErrorHandler 0, 'Contract Size', 
				'spa_contract_size', 'Success', 
				'Contract successfully deleted.',''
end

			





