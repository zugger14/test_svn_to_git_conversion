

IF OBJECT_ID(N'spa_purge_all_measurement_values', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_purge_all_measurement_values]
GO
/****** Object:  StoredProcedure [dbo].[spa_purge_all_measurement_values]    Script Date: 02/03/2010 19:39:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- exec spa_purge_all_measurement_values '2009-08-31'

--This procedure deletes all calculated values for given as of date...
-- Call this proc if you need to delete all prior values for fresh start
CREATE PROCEDURE [dbo].[spa_purge_all_measurement_values] 
	@as_of_date datetime, 
	@sub_id varchar(1000)=NULL
AS 

-----Use  the following to test
/*
DECLARE @as_of_date DATETIME
SET @as_of_date = '2001-04-14'
*/

DECLARE @as_of_date_from  VARCHAR(20)
DECLARE @as_of_date_to    VARCHAR(20)
DECLARE @sqlSelect        VARCHAR(1000)

SET @as_of_date_from = dbo.FNAGetContractMonth(@as_of_date)
SET @as_of_date_to = dbo.FNAGetSQLStandardDate(dbo.FNALastDayInDate(@as_of_date))

--Collect Subs to process
CREATE TABLE #subs (fas_subsidiary_id int)
SET @sqlSelect = 'insert into #subs select fas_subsidiary_id from fas_subsidiaries ' + 
	CASE when (@sub_id IS NOT NULL) THEN ' where fas_subsidiary_id in (' + @sub_id + ')' ELSE '' END
EXEC (@sqlSelect)

DELETE calcprocess_deals 
FROM calcprocess_deals cd INNER JOIN
	 #subs s ON s.fas_subsidiary_id = cd.fas_subsidiary_id
WHERE  cd.as_of_date between @as_of_date_from and @as_of_date_to

DELETE calcprocess_deals_expired 
FROM calcprocess_deals cd INNER JOIN
	 #subs s ON s.fas_subsidiary_id = cd.fas_subsidiary_id
WHERE  cd.as_of_date between @as_of_date_from and @as_of_date_to

DELETE report_measurement_values 
FROM report_measurement_values cd INNER JOIN
	 #subs s ON s.fas_subsidiary_id = cd.sub_entity_id
WHERE  cd.as_of_date between @as_of_date_from and @as_of_date_to

DELETE report_measurement_values_expired 
FROM report_measurement_values cd INNER JOIN
	 #subs s ON s.fas_subsidiary_id = cd.sub_entity_id
WHERE  cd.as_of_date between @as_of_date_from and @as_of_date_to

DELETE calcprocess_aoci_release 
FROM calcprocess_aoci_release cd INNER JOIN
	(select link_id from fas_link_header flh INNER JOIN
	portfolio_hierarchy ph_book ON ph_book.entity_id = flh.fas_book_id INNER JOIN
	portfolio_hierarchy ph_stra ON ph_stra.entity_id = ph_book.parent_entity_id INNER JOIN
	#subs s ON s.fas_subsidiary_id = ph_stra.parent_entity_id
	) link ON link.link_id = cd.link_id
WHERE cd.as_of_date between @as_of_date_from and @as_of_date_to	


--Collect relevant parent netting group to be deleted
CREATE TABLE #net_parent_group(netting_parent_group_id int, fas_subsidiary_id int, legal_entity int, Netting_Parent_Group_Name varchar(1000) COLLATE DATABASE_DEFAULT )

INSERT INTO #net_parent_group
select ngp.netting_parent_group_id, fs.fas_subsidiary_id, ngp.legal_entity, ngp.Netting_Parent_Group_Name
from 
 (select 1 jid, * from netting_group_parent) ngp LEFT OUTER JOIN
 netting_group_parent_subsidiary ngps ON ngps.netting_parent_group_id = ngp.netting_parent_group_id full outer join
 (select 1 jid, * from fas_subsidiaries WHERE fas_subsidiary_id <> -1) fs ON fs.jid= ngp.jid
where ngp.active = 'y' AND ngps.netting_parent_group_id IS NULL

INSERT INTO #net_parent_group
SELECT distinct ngp.netting_parent_group_id, ngps.fas_subsidiary_id, ngp.legal_entity, ngp.Netting_Parent_Group_Name 
FROM    netting_group_parent ngp INNER JOIN
	netting_group_parent_subsidiary ngps ON ngps.netting_parent_group_id = ngp.netting_parent_group_id INNER JOIN
	#subs s ON s.fas_subsidiary_id = ngps.fas_subsidiary_id
where ngp.active = 'y' 

DELETE report_netted_gl_entry 
FROM report_netted_gl_entry rnge INNER JOIN
	 (select distinct netting_parent_group_id from #net_parent_group) p ON
	rnge.netting_parent_group_id = p.netting_parent_group_id
WHERE rnge.as_of_date between @as_of_date_from and @as_of_date_to

--Delete from measurement run dates table
If @sub_id IS NULL
	delete measurement_run_dates where as_of_date between @as_of_date_from and @as_of_date_to









