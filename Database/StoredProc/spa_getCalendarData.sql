

/*
Author : Vishwas Khanal
Dated  : March.15.2010
Desc   : This SP is used to fetch the data for the compliance Calendar.
Proj   : Developed for Emission Demo.
-------------------------------------------------
Dated  : 03.26.2010
Desc   : Re-written the SP.
*/

/*
Edited By : Shyam Mishra
Dated  : August.06.2010
Added Two Parameter @dailyView and @day.
When @dailyView is 'n' then it displays all the data for that calendar month.
When @dailyView is 'n' and @day is set to some day of that month then it displays data for that day only.
*/

IF OBJECT_ID('[dbo].[spa_getCalendarData]','p') IS NOT NULL
DROP PROC [dbo].[spa_getCalendarData]
GO
CREATE PROC [dbo].[spa_getCalendarData]
@flag					CHAR(1)					   ,
@userDate				DATETIME			 = NULL,
@process_number			VARCHAR(10)		     = NULL,
@risk_description_id	VARCHAR(10)			 = NULL,
@who_for				VARCHAR(10)			 = NULL,
@who_by					VARCHAR(10)			 = NULL,
@where					VARCHAR(10)			 = NULL,
@why					VARCHAR(10)			 = NULL,
@activity_area			VARCHAR(10)			 = NULL,
@activity_sub_area		VARCHAR(10)			 = NULL,
@activity_action		VARCHAR(10)          = NULL,
@activity_desc			VARCHAR(500)		 = NULL,
@control_type			VARCHAR(10)		     = NULL,
@remActFlag				CHAR(1)				 = 'a',
@owner					VARCHAR(20)			 = NULL,
@performer				VARCHAR(20)			 = NULL,
@dailyView				CHAR(1)				 = 'n',
@day					INT					 = NULL,
@activity_status		INT					 = NULL

AS
BEGIN	
	IF @flag = 'p' -- Get the list of performers to load in the Performer combo
	BEGIN						
		;WITH data(perform_role,perform_user)
		AS
		(
			SELECT perform_role,perform_user FROM process_risk_controls prc
				INNER JOIN process_risk_description prd
					ON prc.risk_description_id = prd.risk_description_id
				INNER JOIN process_control_header pch
					ON prd.process_id= pch.process_id
				WHERE process_owner = dbo.FNADBUSER()
		)		
			SELECT user_login_id,user_l_name+','+user_f_name+' '+ISNULL(user_m_name, '')+' ('+user_login_id+')'
				FROM application_users 
				WHERE user_login_id = dbo.FNADBUSER() 
			UNION
			SELECT perform_user,user_l_name+','+user_f_name+' '+ISNULL(user_m_name, '')+' ('+perform_user+')' FROM data d
				INNER JOIN application_users au
					ON au.user_login_id = d.perform_user
				WHERE d.perform_user is not null
			UNION 
			SELECT perform_user,user_l_name+','+user_f_name+' '+ISNULL(user_m_name, '')+' ('+perform_user+')' FROM data pu
				INNER JOIN application_role_user aru
					ON pu.perform_role = aru.role_id
				INNER JOIN application_users au
					ON aru.user_login_id = au.user_login_id
				WHERE pu.perform_user IS NULL					
	END
	ELSE
	BEGIN
		CREATE TABLE #tmp(cal_day DATETIME,cal_act VARCHAR(8000) COLLATE DATABASE_DEFAULT,cal_hyperlink VARCHAR(8000) COLLATE DATABASE_DEFAULT,flag VARCHAR(100) COLLATE DATABASE_DEFAULT, risk_control_id INT )
		CREATE TABLE #display(cal_day DATETIME,cal_act VARCHAR(8000) COLLATE DATABASE_DEFAULT,cal_hyperlink VARCHAR(8000) COLLATE DATABASE_DEFAULT,flag VARCHAR(100) COLLATE DATABASE_DEFAULT,risk_control_id INT )
		CREATE TABLE #cursor(risk_control_id INT,risk_control_description VARCHAR(150) COLLATE DATABASE_DEFAULT)

		DECLARE @risk_control_id		  INT,
				@date					  DATETIME,
				@risk_control_description VARCHAR(1000),
				@instanceExists			  CHAR,
				@monthStart				  DATETIME,
				@monthEnd				  DATETIME,
				@startFrom				  DATETIME

		CREATE TABLE #process_risk_controls 
			(
				risk_control_id INT,
				risk_description_id INT,
				activity_who_for_id INT,
				perform_user VARCHAR(50) COLLATE DATABASE_DEFAULT,
				where_id INT,
				activity_area_id INT,
				activity_sub_area_id INT,
				activity_action_id INT,
				risk_control_description VARCHAR (150) COLLATE DATABASE_DEFAULT,
				control_type INT,
				notificationOnly CHAR(1) COLLATE DATABASE_DEFAULT,
				frequency_type CHAR(1) COLLATE DATABASE_DEFAULT,				
			)

				
		;WITH filteredData(
				   risk_control_id,
				   risk_description_id,
				   activity_who_for_id,
				   perform_user,
				   where_id,
				   activity_area_id,
				   activity_sub_area_id,
				   activity_action_id,
				   risk_control_description,
				   control_type,
				   notificationOnly,
				   frequency_type,
				   perform_role
			)	
			AS
			(					
				SELECT risk_control_id,
				   prc.risk_description_id,
				   prc.activity_who_for_id,
				   perform_user,
				   where_id,
				   activity_area_id,
				   activity_sub_area_id,
				   activity_action_id,
				   risk_control_description,
				   control_type,
				   notificationOnly,
				   frequency_type,
				   perform_role
				FROM process_risk_controls prc
				 INNER JOIN process_risk_description prd
					ON prc.risk_description_id = prd.risk_description_id 
				 INNER JOIN process_control_header pch
					ON pch.process_id = prd.process_id			
				WHERE prc.risk_description_id LIKE CASE WHEN @risk_description_id IS NOT NULL THEN @risk_description_id ELSE '%' END
				AND ISNULL(CAST(prc.activity_who_for_id AS VARCHAR(10)),'%') LIKE CASE WHEN @who_for IS NOT NULL THEN @who_for ELSE '%' END
				AND ISNULL(perform_user,'%') LIKE CASE WHEN @who_by IS NOT NULL THEN @who_by ELSE '%' END
				AND ISNULL(CAST(where_id AS VARCHAR(10)),'%') LIKE CASE WHEN @where IS NOT NULL THEN @where ELSE '%' END 		
				AND ISNULL(CAST(activity_area_id AS VARCHAR(10)),'%') LIKE CASE WHEN @activity_area IS NOT NULL THEN @activity_area ELSE '%' END
				AND ISNULL(CAST(activity_sub_area_id AS VARCHAR(10)),'%') LIKE CASE WHEN @activity_sub_area IS NOT NULL THEN @activity_sub_area ELSE '%' END
				AND ISNULL(CAST(activity_action_id AS VARCHAR(10)),'%') LIKE CASE WHEN @activity_action IS NOT NULL THEN @activity_action ELSE '%' END			
				AND ISNULL(CAST(control_type AS VARCHAR(10)),'%') LIKE CASE WHEN @control_type IS NOT NULL THEN @control_type ELSE '%' END
				AND risk_control_description LIKE  CASE WHEN @activity_desc IS NOT NULL THEN @activity_desc ELSE '%' END
				AND pch.process_id LIKE CASE WHEN @process_number IS NOT NULL THEN @process_number ELSE '%' END
				AND pch.process_owner LIKE CASE WHEN @owner IS NOT NULL THEN @owner ELSE '%' END
			)
			INSERT INTO #process_risk_controls 
				SELECT 
				   risk_control_id,
				   risk_description_id,
				   activity_who_for_id,
				   perform_user,
				   where_id,
				   activity_area_id,
				   activity_sub_area_id,
				   activity_action_id,
				   risk_control_description,
				   control_type,
				   notificationOnly,
				   frequency_type FROM filteredData WHERE 
					perform_user  LIKE CASE WHEN @performer IS NOT NULL THEN @performer ELSE '%' END						
				  
			UNION 
				SELECT  
				  risk_control_id,
				   risk_description_id,
				   activity_who_for_id,
				   perform_user,
				   where_id,
				   activity_area_id,
				   activity_sub_area_id,
				   activity_action_id,
				   risk_control_description,
				   control_type,
				   notificationOnly,
				   frequency_type 
				FROM filteredData fd
					 INNER JOIN application_security_role asr ON fd.perform_role = asr.role_id
					 INNER JOIN application_role_user aru ON aru.role_id = fd.perform_role
					WHERE aru.user_login_id  LIKE CASE WHEN @performer IS NOT NULL THEN @performer ELSE '%' END
/*
				
				FROM filteredData fd
					INNER JOIN application_security_role asr
					ON fd.perform_role = asr.role_id
					WHERE perform_user IS NULL
*/				
				

		SELECT @monthStart = CAST(CAST(YEAR(@userDate) AS VARCHAR)+'-'+CAST(MONTH(@userDate) AS VARCHAR)+'-01' AS DATETIME)
		SELECT @monthEnd   = DATEADD(d,-1,DATEADD(m,1,@monthStart))
		
		IF @remActFlag = 'r' 
			INSERT INTO #cursor
				SELECT DISTINCT prc.risk_control_id,risk_control_description FROM #process_risk_controls prc			
					INNER JOIN process_risk_controls_email prce
						ON prc.risk_control_id = prce.risk_control_id
					WHERE dbo.FNANextInstanceCreationDate(prc.risk_control_id) IS NOT NULL																								
						AND notificationOnly = 'n'
						--AND frequency_type='r'	
						AND prce.control_status = -5	
						AND prce.communication_type in (751,752)						
		ELSE
		BEGIN
			INSERT INTO #cursor
				SELECT risk_control_id,risk_control_description FROM #process_risk_controls 			
					WHERE dbo.FNANextInstanceCreationDate(risk_control_id) IS NOT NULL																								
						AND notificationOnly = 'n'
							AND frequency_type='r'

		-- Insert the forecast date for One Time Activity
			INSERT INTO  #tmp
				SELECT dbo.FNANextInstanceCreationDate(prc.risk_control_id),
					risk_control_description,
					prc.risk_control_id,
					ISNULL(control_status,'0'),
					prc.risk_control_id
				FROM #process_risk_controls prc 
				LEFT OUTER JOIN process_risk_controls_activities prca 
				ON prc.risk_control_id = prca.risk_control_id 
				WHERE prc.notificationOnly = 'n'
				AND frequency_type='o'
				AND dbo.FNANextInstanceCreationDate(prc.risk_control_id) BETWEEN @monthStart AND @monthEnd
				AND prca.control_status = ISNULL(@activity_status, 725)
													
		-- Insert the forecast date for Reoccuring Activity	for the instances already created.
			;WITH CTE(cal_day,cal_act,cal_hyperlink,flag,risk_control_id)
			AS
			(
				SELECT as_of_date,
					   risk_control_description,
					   CAST(risk_control_activity_id  AS VARCHAR(10)),
					   CAST(control_status AS VARCHAR(10)),
					   prca.risk_control_id
					   
					FROM process_risk_controls_activities prca
						INNER JOIN #process_risk_controls prc
							ON prca.risk_control_id = prc.risk_control_id
								WHERE as_of_date BETWEEN @monthStart AND @monthEnd
								AND prca.control_status = ISNULL(@activity_status, 725)
			)
			INSERT INTO #tmp SELECT cal_day,cal_act,cal_hyperlink,flag,risk_control_id FROM CTE
		END	

		IF DATEDIFF(m,@userDate,GETDATE())<=0
		BEGIN
			IF DATEDIFF(m,@userDate,GETDATE())=0
				SELECT @monthStart = DATEADD(d,1,CAST(dbo.FNAgetSQLStandardDate(GETDATE()) AS DATETIME)) -- Start the forecasting from tomorrow.

			DECLARE activities CURSOR FOR 
				SELECT risk_control_id,risk_control_description FROM #cursor
				
			OPEN activities		

			FETCH NEXT FROM activities INTO @risk_control_id,@risk_control_description
			WHILE @@FETCH_STATUS = 0
			BEGIN	
				SELECT @date = @monthStart,@instanceExists = 'n'
					
				WHILE(@date<=@monthEnd)
				BEGIN			

					SELECT @date = dbo.FNANextInstanceDate(@risk_control_id,@date,@instanceExists)
					
					IF @date IS NULL 
						BREAK 
					ELSE 
					BEGIN				
													
						IF @date BETWEEN @monthStart AND @monthEnd INSERT INTO #tmp SELECT @date,@risk_control_description,@risk_control_id,'0', @risk_control_id

						SELECT @instanceExists = 'y'				
					END
				END													
				FETCH NEXT FROM activities INTO @risk_control_id,@risk_control_description
			END
			CLOSE activities

			DEALLOCATE activities		
		END

		IF ISNULL(@remActFlag,'a') = 'a' 
			INSERT INTO #display SELECT dbo.FNAgetSQLStandardDate(cal_day),cal_act,cal_hyperlink,flag,risk_control_id FROM #tmp
		ELSE		 
			INSERT INTO #display 
			SELECT DATEADD(dd,-prce.no_of_days,dbo.FNAgetSQLStandardDate(cal_day)),cal_act,cal_hyperlink,flag , t.risk_control_id		
			FROM #tmp t INNER JOIN #process_risk_controls prc				
				ON cal_hyperlink = prc.risk_control_id 
			INNER JOIN process_risk_controls_email prce
				ON prc.risk_control_id = prce.risk_control_id
			WHERE control_status = -5

		SELECT @monthStart = CAST(CAST(YEAR(@userDate) AS VARCHAR)+'-'+CAST(MONTH(@userDate) AS VARCHAR)+'-01' AS DATETIME)

		CREATE TABLE #temp_calendar 
		(
			cal_day INT,
			cal_act VARCHAR(8000) COLLATE DATABASE_DEFAULT,			
			cal_hyperlink VARCHAR(8000) COLLATE DATABASE_DEFAULT,
			flag VARCHAR(8000) COLLATE DATABASE_DEFAULT,
			risk_control_id VARCHAR(8000) COLLATE DATABASE_DEFAULT,
			enable_instance_creation VARCHAR(8000) COLLATE DATABASE_DEFAULT		
		)
		
		--SELECT * FROM #display
		INSERT INTO #temp_calendar 
			SELECT DAY(cal_day) [cal_day],
				SUBSTRING(
				(
					SELECT ('|'+cal_act)
					FROM #display o2					
					LEFT JOIN process_risk_controls_activities prca
					ON prca.risk_control_activity_id = o2.cal_hyperlink
					WHERE o1.cal_day = o2.cal_day
					AND prca.control_status = ISNULL(@activity_status, 725)
					ORDER BY
					cal_day,
					cal_act
					FOR XML PATH ('')
				),2,8000) cal_act
				,SUBSTRING(
				(
					SELECT ('|'+cal_hyperlink)
					FROM #display o2
					WHERE o1.cal_day = o2.cal_day
					ORDER BY
					cal_day,
					cal_act
					FOR XML PATH ('')
				),2,8000) cal_hyperlink
				,SUBSTRING(
				(
					SELECT ('|'+flag)
					FROM #display o2
					WHERE o1.cal_day = o2.cal_day
					ORDER BY
					cal_day,
					cal_act
					FOR XML PATH ('')
				),2,8000) flag
				,SUBSTRING(
				(
					SELECT ('|'+CAST (risk_control_id AS VARCHAR))
					FROM #display o2
					WHERE o1.cal_day = o2.cal_day
					ORDER BY
					cal_day,
					cal_act
					FOR XML PATH ('')
				),2,8000) risk_control_id			
				,SUBSTRING(
			   (
					SELECT ('|'+ CASE 
					WHEN COALESCE(prc.perform_user, aru.user_login_id, '') = dbo.FNADBUser() 
					AND dbo.FNANextInstanceCreationDate(o2.risk_control_id) = o1.cal_day
					THEN '1' ELSE '0' END
			   )       
			     
				  FROM #display o2
				  INNER JOIN process_risk_controls prc ON prc.risk_control_id = o2.risk_control_id
				  LEFT JOIN application_security_role asr ON prc.perform_role = asr.role_id
				  LEFT JOIN application_role_user aru ON aru.role_id = prc.perform_role
				   AND aru.user_login_id = dbo.FNADBUser()
				              
					WHERE o1.cal_day = o2.cal_day
					ORDER BY cal_day, cal_act
				 FOR XML PATH ('')
				),2,8000) enable_instance_creation
				
				
			FROM #display o1
				WHERE cal_day between @monthStart AND @monthEnd
				GROUP BY cal_day
		
		IF  ISNULL(@dailyView,'n') = 'n'
		BEGIN
			SELECT * FROM #temp_calendar
		END
		ELSE IF @dailyView = 'y'
		BEGIN				
			SELECT * FROM #temp_calendar WHERE cal_day = @day
		END			
	END			
END
