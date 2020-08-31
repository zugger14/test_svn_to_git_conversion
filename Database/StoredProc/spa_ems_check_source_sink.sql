/****** Object:  StoredProcedure [dbo].[spa_ems_check_source_sink]    Script Date: 03/25/2009 17:01:03 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_ems_check_source_sink]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_ems_check_source_sink]
GO

/****** Object:  StoredProcedure [dbo].[spa_ems_check_source_sink]    Script Date: 03/25/2009 17:01:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/********************************************88
Created By: Anal Shrestha
Created on: 10-28-2008
This SP checks if the unitID and facility_id exits in the rec_generator table
exec spa_ems_check_source_sink '470','1'


********************************************/

CREATE PROCEDURE [dbo].[spa_ems_check_source_sink]
	@facility_id VARCHAR(100),
	@unit_id VARCHAR(100)

AS
BEGIN	
	SET @facility_id=RIGHT('000000'+LTRIM(RTRIM(@facility_id)),6)

	IF EXISTS
	(
		SELECT 'x' FROM ems_multiple_source_unit_map 
				WHERE SUBSTRING(orsipl_id,1,6) = @facility_id
							AND edr_unit_id	   = @unit_id

	)
		SELECT 'Success'
	ELSE
		SELECT 'Error'
END

/*
	IF EXISTS(
			SELECT rg.generator_id 
			FROM 
				rec_generator rg
				JOIN ems_multiple_source_unit_map em on rg.generator_id=em.generator_id
				LEFT JOIN ems_stack_unit_map esu on esu.ORSIPL_ID=em.ORSIPL_ID
				and em.EDR_UNIT_ID=esu.UNIT_ID
			WHERE 
--					(COALESCE(esu.ORSIPL_ID,em.ORSIPL_ID,rg.id,'-1')=ltrim(rtrim(@facility_id)) AND
--					COALESCE(esu.stack_id,em.edr_Unit_id,'-1')=ISNULL(ltrim(rtrim(@unit_id)),'-1')) 
				
					(ISNULL(LEFT(rg.id,6),-1)=ltrim(rtrim(@facility_id)) AND
					ISNULL(rg.id2,-1)=ISNULL(ltrim(rtrim(@unit_id)),-1)) 
					OR
					(ISNULL(LEFT(rg.id,6),-1)=ltrim(rtrim(@facility_id)) AND
					ISNULL(em.edr_Unit_id,-1)=ISNULL(ltrim(rtrim(@unit_id)),-1)) 
					OR
					(ISNULL(esu.ORSIPL_ID,-1)=ltrim(rtrim(@facility_id)) AND
					ISNULL(esu.stack_id,-1)=ISNULL(ltrim(rtrim(@unit_id)),-1))
		)
		BEGIN
			SELECT 'Success'

		END
	ELSE
		BEGIN
			SELECT 'Error'
		END	


END




*/