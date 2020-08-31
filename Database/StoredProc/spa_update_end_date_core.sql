
-- =============================================
-- Author:		<Author : Mukesh Singh>
-- Create date: <Create Date : 09-July-2009>
-- Description:	<Description,End date will update according to effective date with latest>
-- =============================================
--

/****** Object:  StoredProcedure [dbo].[spa_update_end_date_core]    Script Date: 07/07/2009 11:53:05 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_update_end_date_core]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_update_end_date_core]
GO
CREATE PROCEDURE [dbo].[spa_update_end_date_core]
	-- Add the parameters for the stored procedure here
	@flag VARCHAR(1)='i',
	@effective_date datetime,
	@generator_id	int ,
	@old_effective_date datetime=null
	AS
BEGIN
/*
	SELECT * FROM  ems_source_model_effective WHERE generator_id =3386 order by effective_date

exec [dbo].[spa_ems_source_model_effective]
@flag= 'i',@id =3922,
@generator_id =3386,
@ems_source_model_id =217,
@effective_date ='2005-02-01'

					SELECT MAX(ISNULL(effective_date, '1970-01-01')) effective_date,DATEADD(day, -1,'2009-01-01') effective_date_end
						FROM ems_source_model_effective
						WHERE ISNULL(effective_date, '1970-01-01')< '2009-01-01'
						AND generator_id = 3263
						GROUP BY generator_id
					UNION
					SELECT ISNULL('2009-01-01', '1970-01-01') effective_date,DATEADD(day,-1,min(effective_date))  effective_date_end
						FROM ems_source_model_effective
						WHERE effective_date > ISNULL('2009-01-01', '1970-01-01')
						AND generator_id = @generator_id	
						GROUP BY generator_id
				) m ON m.effective_date = ISNULL(esme.effective_date, '1970-01-01')
			WHERE esme.generator_id = @generator_id







*/

EXEC spa_print	@flag 
EXEC spa_print	@effective_date 
EXEC spa_print	@generator_id
EXEC spa_print	@old_effective_date



-- in the update logic , first applied delete and then update logic
	 IF @flag='d' OR  @flag='u'
	 BEGIN
		UPDATE ems_source_model_effective 
			SET
				end_date =effective_date_end
			FROM ems_source_model_effective esme
			INNER JOIN 
				(
					SELECT MAX(ISNULL(
					CASE WHEN effective_date < @old_effective_date THEN effective_date ELSE NULL END, '1970-01-01')
					) effective_date
					,MAX(CASE WHEN effective_date =@effective_date THEN end_date ELSE NULL END) effective_date_end
						FROM ems_source_model_effective
						WHERE 
						generator_id = @generator_id	
					GROUP BY generator_id
						
				) m ON m.effective_date = ISNULL(esme.effective_date, '1970-01-01')
			WHERE esme.generator_id = @generator_id		

	END
	IF @flag='i' OR @flag='u'
	BEGIN
--SELECT * FROM rec_generator WHERE [NAME]='Test'
		UPDATE ems_source_model_effective 
			SET
				end_date =effective_date_end
			FROM ems_source_model_effective esme
			INNER JOIN 
				(
					--select either oldest effective date if available or null effecitive date
					SELECT MAX(ISNULL(effective_date, '1970-01-01')) effective_date,DATEADD(day, -1, @effective_date) effective_date_end
						FROM ems_source_model_effective
						WHERE ISNULL(effective_date, '1970-01-01')< @effective_date
						AND generator_id = @generator_id
						GROUP BY generator_id
					UNION
					SELECT ISNULL(@effective_date, '1970-01-01') effective_date,DATEADD(day,-1,min(effective_date))  effective_date_end
						FROM ems_source_model_effective
						WHERE effective_date > ISNULL(@effective_date, '1970-01-01')
						AND generator_id = @generator_id	
						GROUP BY generator_id
				) m ON m.effective_date = ISNULL(esme.effective_date, '1970-01-01')
			WHERE esme.generator_id = @generator_id
		
	END	
END
