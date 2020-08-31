/****** Object:  StoredProcedure [dbo].[spa_get_netting_contract_template]    Script Date: 11/17/2012 10:55:08 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_get_netting_contract_template]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_get_netting_contract_template]
GO


/****** Object:  StoredProcedure [dbo].[spa_get_netting_contract_template]    Script Date: 11/17/2012 10:55:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- exec spa_get_netting_contract_template 's',NULL,NULL,2
CREATE PROC [dbo].[spa_get_netting_contract_template]
	@flag CHAR(1)='s',
	@contract_id INT=NULL,
	@counterparty_id INT=NULL,
	@netting_group_id INT=NULL

AS

BEGIN

DECLARE @sql VARCHAR(5000)

	SET @sql=
	' SELECT distinct
			sng.netting_group_id,
			sng.netting_group_name,
			crp.template_name 
	FROM
			settlement_netting_group sng
			JOIN settlement_netting_group_detail sngd
				 on sng.netting_group_id=sngd.netting_group_id
			LEFT JOIN contract_group_detail cgd on sngd.contract_detail_id=cgd.[id]
			left join Contract_report_template crp on crp.template_id=sng.template_id
	WHERE 1=1'
	+CASE WHEN @counterparty_id IS NOT NULL THEN ' AND sng.counterparty_id='+ CAST(@counterparty_id AS VARCHAR) ELSE '' END
	+CASE WHEN @netting_group_id IS NOT NULL THEN ' AND sng.netting_group_id='+CAST(@netting_group_id AS VARCHAR) ELSE '' END

	EXEC(@sql)
END
				
	



GO


