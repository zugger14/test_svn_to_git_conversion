IF OBJECT_ID(N'spa_netting_group_detail', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_netting_group_detail]
GO

CREATE PROCEDURE [dbo].[spa_netting_group_detail]   
	@flag CHAR,
	@netting_group_id INT = Null,
	@netting_group_detail_id INT = NULL,
	@source_counterparty_id INT = NULL,
	@gl_number_id_st_asset INT = NULL,
	@gl_number_id_st_liab INT = NULL,
	@gl_number_id_lt_asset INT = NULL,
	@gl_number_id_lt_liab INT = NULL,
	@del_net_grp_det_id VARCHAR(MAX) = NULL
AS 

SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

SET CONCAT_NULL_YIELDS_NULL ON

SET NOCOUNT ON

declare @sql varchar(max)

IF @flag = 's'
BEGIN
--SELECT     netting_group.netting_group_name AS GroupName, 
--	   source_counterparty.counterparty_name AS Counterparty, 
--	   net_cpty.counterparty_name AS NetCounterparty, 
--           st_asset.gl_account_number + ' (' + st_asset.gl_account_name + ')' AS GLCodeSTAsset, 
--           st_liab.gl_account_number + ' (' + st_liab.gl_account_name + ')' AS GLCodeSTLiab, 
--           lt_asset.gl_account_number + ' (' + lt_asset.gl_account_name + ')' AS GLCodeLTAsset, 
--           lt_liab.gl_account_number + ' (' + lt_liab.gl_account_name + ')' AS GLCodeLTLiab, 
--           netting_group_detail.netting_group_detail_id AS [Net Grp Det Id],
--	   netting_group_detail.gl_number_id_st_asset As [Net Grp Det Id St Asset], 
--	   netting_group_detail.gl_number_id_st_liab As [Net Grp Det Id St Liab],
--	   netting_group_detail.gl_number_id_lt_asset As [Net Grp Det Id Lt Asset],
--	   netting_group_detail.gl_number_id_lt_liab As [Net Grp Det Id Lt Liab]
--FROM         netting_group_detail INNER JOIN
--                      netting_group ON netting_group_detail.netting_group_id = netting_group.netting_group_id LEFT OUTER JOIN
--                      gl_system_mapping st_liab ON netting_group_detail.gl_number_id_st_liab = st_liab.gl_number_id LEFT OUTER JOIN
--                      gl_system_mapping lt_asset ON netting_group_detail.gl_number_id_lt_asset = lt_asset.gl_number_id LEFT OUTER JOIN
--                      gl_system_mapping lt_liab ON netting_group_detail.gl_number_id_lt_liab = lt_liab.gl_number_id LEFT OUTER JOIN
--                      gl_system_mapping st_asset ON netting_group_detail.gl_number_id_st_asset = st_asset.gl_number_id LEFT OUTER JOIN
--                      source_counterparty ON source_counterparty.source_counterparty_id = netting_group_detail.source_counterparty_id LEFT OUTER JOIN
--                      source_counterparty net_cpty ON net_cpty.source_counterparty_id = source_counterparty.netting_parent_counterparty_id
--                      WHERE   netting_group_detail.netting_group_id = @netting_group_id



	set @sql = '
		SELECT  netting_group.netting_group_name AS [Group Name], 
		   source_counterparty.counterparty_name + CASE WHEN ssd.source_system_name=''farrms'' THEN  '''' ELSE ''.'' + ssd.source_system_name END AS Counterparty, 
		   net_cpty.counterparty_name + CASE WHEN ssd1.source_system_name=''farrms'' THEN  '''' ELSE ''.'' + ssd1.source_system_name END AS [Net Counterparty], 
			   st_asset.gl_account_number + '' ('' + st_asset.gl_account_name + '')'' AS [GL Code ST Asset], 
			   st_liab.gl_account_number + '' ('' + st_liab.gl_account_name + '')'' AS [GL Code ST Liab], 
			   lt_asset.gl_account_number + '' ('' + lt_asset.gl_account_name + '')'' AS [GL Code LT Asset], 
			   lt_liab.gl_account_number + '' ('' + lt_liab.gl_account_name + '')'' AS [GL Code LT Liab], 
			   netting_group_detail.netting_group_detail_id AS [Net Grp Det ID],
		   netting_group_detail.gl_number_id_st_asset As [Net Grp Det ID St Asset], 
		   netting_group_detail.gl_number_id_st_liab As [Net Grp Det ID St Liab],
		   netting_group_detail.gl_number_id_lt_asset As [Net Grp Det ID Lt Asset],
		   netting_group_detail.gl_number_id_lt_liab As [Net Grp Det ID Lt Liab]
		FROM netting_group_detail 
			INNER JOIN netting_group ON netting_group_detail.netting_group_id = netting_group.netting_group_id 
			LEFT OUTER JOIN gl_system_mapping st_liab ON netting_group_detail.gl_number_id_st_liab = st_liab.gl_number_id 
			LEFT OUTER JOIN gl_system_mapping lt_asset ON netting_group_detail.gl_number_id_lt_asset = lt_asset.gl_number_id 
			LEFT OUTER JOIN gl_system_mapping lt_liab ON netting_group_detail.gl_number_id_lt_liab = lt_liab.gl_number_id 
			LEFT OUTER JOIN gl_system_mapping st_asset ON netting_group_detail.gl_number_id_st_asset = st_asset.gl_number_id 
			LEFT OUTER JOIN source_counterparty ON source_counterparty.source_counterparty_id = netting_group_detail.source_counterparty_id 
			LEFT JOIN source_system_description  ssd ON source_counterparty.source_system_id = ssd.source_system_id
			LEFT OUTER JOIN source_counterparty net_cpty ON net_cpty.source_counterparty_id = source_counterparty.netting_parent_counterparty_id
			LEFT JOIN source_system_description  ssd1 ON net_cpty.source_system_id = ssd1.source_system_id
		WHERE 1=1'

	if @netting_group_id is not null
		set @sql = @sql + ' and netting_group_detail.netting_group_id = '+cast(@netting_group_id as varchar)

	if @source_counterparty_id is not null
		set @sql = @sql + ' and source_counterparty.source_counterparty_id = ' + cast(@source_counterparty_id as varchar)

	EXEC spa_print @sql
	exec(@sql)

END

ELSE IF @flag = 'i'
 BEGIN
 	INSERT INTO netting_group_detail (netting_group_id,source_counterparty_id,gl_number_id_st_asset,gl_number_id_st_liab,gl_number_id_lt_asset,gl_number_id_lt_liab)
 	values (@netting_group_id,
 		@source_counterparty_id,
 		@gl_number_id_st_asset,
 		@gl_number_id_st_liab,
 		@gl_number_id_lt_asset,
 		@gl_number_id_lt_liab) 
	
	DECLARE @new_id AS VARCHAR(10)
	SET @new_id = SCOPE_IDENTITY()

	DECLARE @recommend_netting_group_detail_id VARCHAR(20)

	SELECT @recommend_netting_group_detail_id = CAST(ng.netting_parent_group_id AS VARCHAR(10)) + '_' 
												+ CAST(ng.netting_group_id AS VARCHAR(10)) + '_' 
												+ CAST(ngd.netting_group_detail_id AS VARCHAR(10))
	FROM netting_group_detail ngd
	INNER JOIN netting_group ng
	ON ngd.netting_group_id = ng.netting_group_id
	
	WHERE netting_group_detail_id = @new_id
 	 
 	If @@ERROR <> 0
 		Exec spa_ErrorHandler @@ERROR, 'Netting Rule', 
 				'spa_netting_group_detail', 'DB Error', 
 				'Failed to Insert Netting Rule.', ''
 	else
 		Exec spa_ErrorHandler 0, 'Netting Rule', 
 				'spa_netting_group_detail', 'Success', 
 				'Netting Rule Inserted.', @recommend_netting_group_detail_id
 
 END
 
 ELSE IF @flag = 'u'
 BEGIN
 
 
 					--@netting_group_id,
 					--@netting_group_detail_id,
 					--@source_counterparty_id,
 					--@gl_number_id_st_asset,
 					--@gl_number_id_st_liab,
 					--@gl_number_id_lt_asset,
 					--@gl_number_id_lt_liab
 	UPDATE netting_group_detail
 	SET	--netting_group_id=@netting_group_id,
		source_counterparty_id=@source_counterparty_id,
 		gl_number_id_st_asset=@gl_number_id_st_asset,
 		gl_number_id_st_liab=@gl_number_id_st_liab,
 		gl_number_id_lt_asset=@gl_number_id_lt_asset,
		gl_number_id_lt_liab=@gl_number_id_lt_liab
		where netting_group_detail_id=@netting_group_detail_id
		--where netting_group_id=@netting_group_id
 	 
 	If @@ERROR <> 0
 		Exec spa_ErrorHandler @@ERROR, 'Netting Rule', 
 				'spa_netting_group_detail', 'DB Error', 
 				'Failed to Update Netting Rule.', ''
 	else
 		Exec spa_ErrorHandler 0, 'Netting Rule', 
 				'spa_netting_group_detail', 'Success', 
 				'Netting Rule Updated.', ''
 
 END
 
 ELSE IF @flag = 'd'
 BEGIN
 	DELETE ngd
	FROM netting_group_detail ngd
	INNER JOIN dbo.FNASplit(@del_net_grp_det_id, ',') di ON di.item = ngd.netting_group_detail_id
 
 	IF @@ERROR <> 0
 		EXEC spa_ErrorHandler @@ERROR, 'Netting Rule', 
 			'spa_netting_group_detail', 'DB Error', 
 			'Failed to Delete Netting Rule.', ''
 	ELSE
 		EXEC spa_ErrorHandler 0, 'Netting Rule',
 			'spa_netting_group_detail', 'Success', 
 			'Netting Rule Deleted.', ''
 END

 GO