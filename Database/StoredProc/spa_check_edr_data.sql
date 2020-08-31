/****** Object:  StoredProcedure [dbo].[spa_check_edr_data]    Script Date: 05/05/2009 00:20:28 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_check_edr_data]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_check_edr_data]
/****** Object:  StoredProcedure [dbo].[spa_check_edr_data]    Script Date: 05/05/2009 00:20:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec spa_check_edr_data '000445','4','2008','3','2008-03-02',4
--select * from edr_file_date

CREATE PROC [dbo].[spa_check_edr_data]
	@facility_id VARCHAR(100),
	@unit_id VARCHAR(100),
	@Year VARCHAR(4),
	@Quarter VARCHAR(1),
	@file_created_date DATETIME,
	@file_created_hour INT

AS
BEGIN
	
	DECLARE @edr_date DATETIME,@edr_hour VARCHAR(2),@compare_date DATETIME


	SELECT @compare_date=@Year+CASE WHEN @Quarter='1' THEN '-03-01'
									WHEN @Quarter='2' THEN '-06-01'
									WHEN @Quarter='3' THEN '-09-01'	
									WHEN @Quarter='4' THEN '-12-01'
							   END


	IF NOT EXISTS(SELECT * from edr_file_date WHERE facility_id=RIGHT('000000'+LTRIM(RTRIM(@facility_id)),6) AND unit_id=LTRIM(RTRIM(@unit_id))
				  AND [year]=@Year AND 	[Quarter]=@Quarter)
	BEGIN
			INSERT INTO edr_file_date(facility_id,unit_id,[Year],[Quarter],[file_date],[file_hour])
			SELECT
					@facility_id,@unit_id,@Year,@Quarter,@file_created_date,@file_created_hour

			SELECT 1
	END
	ELSE
		BEGIN	
			SELECT 
				@edr_date=MAX([file_date]),
				@edr_hour=MAX([file_hour]) 
			FROM 
				edr_file_date
			WHERE
				facility_id=@facility_id
				AND unit_id=@unit_id
				AND [Year]=@Year AND Quarter=@Quarter


			IF @file_created_date<@edr_date
				SELECT 0
			ELSE IF @file_created_date<=@edr_date AND @file_created_hour<@edr_hour
				SELECT 0
			ELSE
				BEGIN
					UPDATE edr_file_date
					SET [file_date]=@file_created_date
					WHERE 
						  facility_id=@facility_id
						  AND unit_id=@unit_id
						  AND [Year]=@Year AND Quarter=@Quarter

					SELECT 1

				END
		END


END