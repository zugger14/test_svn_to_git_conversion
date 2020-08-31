---- =============================================================================================================================
---- Author: bmanandhar@pioneersolutionsglobal.com
---- Create date: 2017-08-02
---- Description: Generic SP to get business day
 
---- Params:
---- @flag CHAR(1)		-  flag ----						
----					- 'n' -  next business day after the date
----					- 'p' - previous business day before the date
---- ===================================================================

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_get_business_day]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_get_business_day]
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_get_business_day]
	@flag CHAR(1),
	@date DATETIME
AS 

--/*******************************************************
--DECLARE @flag CHAR(1),	
--		@xml VARCHAR(MAX) = NULL,
--		@object_id INT = NULL	

--select  @flag='u',@object_id='5',@xml='<Root function_id="10107100" object_id="5"><FormXML  name="qq" address="qqq" gender="M" email="qqq" education="43102" status="3" shift="1" department="43204" phone="qq" certificate="qq" training="qq" mobile="qq" post="2" applicant_detail_id="5"></FormXML><GridGroup><Grid grid_id="Applicant_History"><GridRow  applicant_history_id="91" applieddate="2016-08-03" post="INTERN" experience="5" referedby="5" remarks="5" ></GridRow> <GridRow  applicant_history_id="92" applieddate="2016-08-10" post="ASSOCIATE" experience="4" referedby="4" remarks="4" ></GridRow> <GridRow  applicant_history_id="93" applieddate="2016-08-02" post="INTERN" experience="3" referedby="3" remarks="3" ></GridRow> <GridRow  applicant_history_id="94" applieddate="2016-08-10" post="ASSOCIATE" experience="3" referedby="3" remarks="3" ></GridRow> <GridRow  applicant_history_id="" applieddate="2016-08-03" post="1" experience="4" referedby="4" remarks="4" ></GridRow> </Grid></GridGroup></Root>'
--*****************************************************/

BEGIN
	SET NOCOUNT ON
	
	DECLARE @value_id INT

	SELECT @value_id = sdv.value_id FROM static_data_value sdv WHERE sdv.[description] = 'Public Holidays'
	
	IF @flag = 'n'
	BEGIN
		EXEC('SELECT dbo.FNAGetBusinessDay(''n'', ''' + @date + ''',' + @value_id + ') business_day')
	END
	ELSE IF @flag = 'p'
	BEGIN
		EXEC('SELECT dbo.FNAGetBusinessDay(''p'', ''' + @date + ''',' + @value_id + ') business_day')
	END
END