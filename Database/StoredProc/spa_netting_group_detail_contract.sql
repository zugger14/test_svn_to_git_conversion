IF OBJECT_ID(N'spa_netting_group_detail_contract', N'P') IS NOT NULL
DROP PROCEDURE spa_netting_group_detail_contract
 GO 
--drop procedure [dbo].[spa_netting_group_detail_contract]
--go

--update contract_group set source_contract_id='1'
-- exec spa_netting_group_detail_contract'i','',26,27

CREATE procedure [dbo].[spa_netting_group_detail_contract]
@flag VARCHAR(1)
	--@contract_name varchar(100)=null,
	,@netting_contract_id INT = NULL
	,@netting_group_detail_id INT = NULL
	,@source_contract_id INT = NULL

AS
BEGIN
IF @flag = 's'
BEGIN
    SELECT netting_contract_id ID,
		   dbo.FNAHyperLinkText(10211010, CG.contract_name, cg.contract_id) AS [Contract Name]	
           --CG.contract_name AS ContractName
    FROM   netting_group_detail_contract NGD
           INNER JOIN contract_group CG ON  NGD.source_contract_id = CG.contract_id
    WHERE  NGD.netting_group_detail_id = @netting_group_detail_id

END
ELSE IF @flag = 'i'
BEGIN
	 INSERT INTO netting_group_detail_contract (
		source_contract_id
		,netting_group_detail_id
		)
	VALUES (
		@source_contract_id
		,@netting_group_detail_id
		)

If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Netting Group Detail Contract", 
				"spa_netting_group_detail_contract", "DB Error", 
				"Failed to insert Netting Group Detail Contract.",@netting_group_detail_id
	else
		Exec spa_ErrorHandler 0, "Netting Group Detail Contract", 
				"spa_netting_group_detail_contract", "Success", 
				"Netting Group Detail Contract successfully inserted.", @netting_group_detail_id
END
ELSE IF  @flag='u'
BEGIN
 UPDATE netting_group_detail_contract
 set
	netting_group_detail_id=@netting_group_detail_id,
		source_contract_id=@source_contract_id
where
		netting_contract_id=@netting_contract_id 

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Netting Group Detail Contract", 
		"spa_netting_group_detail_contract", "DB Error", 
		"Error on Updating Netting Group Detail Contract.", ''
	else
		Exec spa_ErrorHandler 0, 'Netting Group Detail Contract', 
		'spa_netting_group_detail_contract', 'Success', 
		'Netting Group Detail Contract successfully updated.',''
END
ELSE IF  @flag='d'
BEGIN
		delete from netting_group_detail_contract 
		where 
				netting_contract_id=@netting_contract_id
	if @@ERROR <> 0
			Exec spa_ErrorHandler @@ERROR, "Netting Group Detail Contract", 
			"spa_netting_group_detail_contract", "DB Error", 
			"Error on Deleting Netting Group Detail Contract.", ''
		else
			Exec spa_ErrorHandler 0, 'Netting Group Detail Contract', 
			'spa_netting_group_detail_contract', 'Success', 
			'Netting Group Detail Contract successfully deleted.',''
		
	END
END
IF @flag = 'g'
BEGIN
     SELECT netting_contract_id ID,
		   NGD.source_contract_id [Contract Name], lower(cg.contract_name)
           
    FROM   netting_group_detail_contract NGD    
		INNER JOIN contract_group cg
			on cg.contract_id = NGD.source_contract_id
		LEFT JOIN source_system_description ON  source_system_description.source_system_id = cg.source_system_id       
	WHERE  NGD.netting_group_detail_id = @netting_group_detail_id
	ORDER BY CASE WHEN cg.source_contract_id <> cg.[contract_name] THEN cg.source_contract_id + ' - ' + cg.[contract_name] ELSE cg.[contract_name] END + CASE 
													   WHEN cg.source_system_id = 2 THEN ''
													   ELSE CASE WHEN cg.source_system_id IS NOT NULL THEN  '.' + source_system_description.source_system_name ELSE '' END
												  END

END	





