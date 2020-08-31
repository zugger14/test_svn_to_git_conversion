
--select  dbo.FNADependencyHierarchy (165)
/*
Author : Vishwas Khanal
Desc   : Compliance Renovation. 
		 If given an Activity Id, this function will return all the dependent Activities.
*/
IF OBJECT_ID('[dbo].[FNADependencyHierarchy]','fn') IS NOT NULL
DROP FUNCTION [dbo].[FNADependencyHierarchy]
go
CREATE FUNCTION [dbo].[FNADependencyHierarchy]
(@risk_control_id INT)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @list VARCHAR(max)

	DECLARE  @temp TABLE (sno INT IDENTITY(1,1),List VARCHAR(500))

	;WITH CTE(List,dependency,Activity)
	  AS
	  (
	   SELECT CONVERT(VARCHAR(8000),a.risk_control_id) AS [list],CONVERT(VARCHAR(8000),a.risk_control_dependency_id) AS [dependency],
	   CONVERT(VARCHAR(8000),p.risk_control_description) [Activity]  
	   FROM process_risk_controls_dependency  a   
		INNER JOIN process_risk_controls p ON p.risk_control_id = a.risk_control_id 
		 WHERE a.risk_control_id  = @risk_control_id AND risk_control_id_depend_on IS NULL
	   UNION ALL
	   SELECT [List]+','+ CONVERT(VARCHAR(8000),b.risk_control_id) AS [list] ,CONVERT(VARCHAR(8000),b.[risk_control_dependency_id]) AS [dependency],[Activity] + ','+ CONVERT(VARCHAR(8000),risk_control_description) [Activity] from process_risk_controls_dependency b 
		INNER JOIN process_risk_controls p ON p.risk_control_id = b.risk_control_id 
		INNER JOIN CTE a ON  a.[dependency] = CAST(b.risk_control_id_depend_on AS VARCHAR)
	  )SELECT @list = ISNULL(@list+',','') + List  FROM CTE ORDER BY List

	INSERT INTO @temp SELECT item from dbo.splitCommaSeperatedValues(@list)

	SELECT @list = NULL

	SELECT @list = ISNULL(@list+',','') +  List FROM @temp GROUP BY List ORDER BY MIN(sno) ASC
	
	IF CHARINDEX(',',@list) <> 0
		SELECT @list = SUBSTRING(@list,CHARINDEX(',',@list)+1,LEN(@list))
	ELSE 
		SELECT @list = NULL 
		
	RETURN @list 
		

/*
	DECLARE @dep2 VARCHAR(1000),@dep1 VARCHAR(1000),@sno INT,@count INT,@check VARCHAR(100),@return varchar(100)

	DECLARE @tmp TABLE (sno INT)
	
	SELECT @dep2='',@dep1=''
		
	SELECT @sno = risk_control_dependency_id FROM process_risk_controls_dependency (nolock) WHERE risk_control_id = @risk_control_id	and risk_control_id_depend_on is null

	SELECT @dep1 = @dep1 +',' + CAST(risk_control_dependency_id AS VARCHAR) FROM process_risk_controls_dependency WHERE risk_control_id_depend_on  =@sno
		
	SELECT @dep1 = substring(@dep1,2,len(@dep1))
	
	INSERT INTO @tmp 
		SELECT item FROM dbo.splitcommaSeperatedValues(@dep1)

	WHILE (1=1)
	BEGIN	
		SELECT @dep2 = ''

		SELECT @dep2 = @dep2 +',' + cast(risk_control_dependency_id AS VARCHAR)  FROM process_risk_controls_dependency (nolock)
			WHERE risk_control_id_depend_on IN (SELECT sno FROM @tmp) 
	
		SELECT @dep1 = @dep1 + @dep2
		SELECT @count = COUNT(*) FROM @tmp 
	
		DELETE FROM @tmp		
		IF @count = 0					
			BREAK		
		ELSE
		BEGIN
			SELECT @count = 0
	
			INSERT INTO @tmp SELECT item FROM dbo.splitcommaSeperatedValues(@dep2)
		END				
	END

	INSERT INTO @tmp select Item from dbo.splitcommaSeperatedValues(@dep1)
	
	SELECT @return = ''		

	IF EXISTS (SELECT 'x' from @tmp)
	BEGIN
		SELECT @return = @return + ',' + cast(risk_control_id as varchar) FROM process_risk_controls_dependency (nolock) where 
			risk_control_dependency_id in (select sno from @tmp)
		SELECT @return = substring(@return,2,len(@return))
	END
	ELSE 
	SELECT @return = NULL

	RETURN @return 
*/
END

