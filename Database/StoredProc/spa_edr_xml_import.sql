
/****** Object:  StoredProcedure [dbo].[spa_edr_xml_import]    Script Date: 03/25/2009 16:58:33 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_edr_xml_import]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_edr_xml_import]
GO

/****** Object:  StoredProcedure [dbo].[spa_edr_xml_import]    Script Date: 03/25/2009 16:58:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =====================================================================================
-- Author:		Milan Lamichhane
-- Create date: 12/03/2008
-- Description:	sproc to import edr data from 
--				staging table to edr_as_imported table
-- Last Modified: 12/10/2008
-- =====================================================================================
CREATE procedure [dbo].[spa_edr_xml_import]
as
/*
Import derived hourly data
*/

INSERT INTO
	edr_as_imported (stack_id, facility_id, unit_id, record_type_code,
					 sub_type_id, edr_date, edr_hour, edr_value, modccode)
(SELECT 
	ISNULL(dhd.StackPipeID,dhd.UnitID)as StackID,
	dhd.ORISCode,
	ISNULL(dhd.UnitID,dhd.StackPipeID), 
	emd.record_type_code,
	emd.record_sub_type_code,
	dhd.OperatingDate,
	dhd.Hour,
	CASE WHEN charindex('.',dhd.AdjustedHourlyValue)<=0 THEN dhd.AdjustedHourlyValue
		ELSE 	
			substring(dhd.AdjustedHourlyValue,0,charindex('.',dhd.AdjustedHourlyValue))+
				CASE WHEN dhd.parametercode='NOXR' then  substring(dhd.AdjustedHourlyValue,charindex('.',dhd.AdjustedHourlyValue),4) 
					 ELSE substring(dhd.AdjustedHourlyValue,charindex('.',dhd.AdjustedHourlyValue),2) 
				END  	
		END
	,
	dhd.MODCCode	
FROM 
	edr_staging_derived_hourly_data dhd
LEFT JOIN
	edr_xml_file_map_detail emd
ON
	upper(dhd.ParameterCode) = upper(emd.record_data)
WHERE
	emd.isDerived = 1)



/*
Import op time of operating data
*/
INSERT INTO
	edr_as_imported (stack_id, facility_id, unit_id, record_type_code,
					 sub_type_id, edr_date, edr_hour, edr_value)
(SELECT 
	ISNULL(hod.StackPipeID,hod.UnitID) StackID, 
	hod.ORISCode,
	ISNULL(hod.UnitID,hod.StackPipeID),
	emd.record_type_code,
	emd.record_sub_type_code,
	hod.OperatingDate,
	hod.Hour,
	hod.OperatingTime
FROM
	edr_staging_hourly_operating_data hod,
	edr_xml_file_map_detail emd
WHERE
	emd.isHourly = 1 and emd.record_description like '%Op Time%')

/*
Import gross load of operating data
*/
INSERT INTO
	edr_as_imported (stack_id, facility_id, unit_id, record_type_code,
					 sub_type_id, edr_date, edr_hour, edr_value,loadunit)
(SELECT 
	ISNULL(hod.StackPipeID,hod.UnitID) StackID, 
	hod.ORISCode,
	ISNULL(hod.UnitID,hod.StackPipeID),
	emd.record_type_code,
	emd.record_sub_type_code,
	hod.OperatingDate,
	hod.Hour,
	hod.HourLoad,
	hod.LoadUnit
FROM
	edr_staging_hourly_operating_data hod,
	edr_xml_file_map_detail emd
WHERE
	emd.isHourly = 1 and emd.record_description like '%Gross Load%')


-- Now Call the Job to run the calculations
DECLARE @process_id VARCHAR(100)
DECLARE @table_name VARCHAR(50)

set @process_id=newid()
set @table_name='edr_as_imported'

EXEC spa_import_edrXML_inventory_as_job 'farrms_admin',@table_name,@process_id 
















