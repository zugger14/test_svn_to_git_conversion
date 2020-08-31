
IF OBJECT_ID('dbo.CurveReferenceHierarchySP','p') is not null
DROP PROCEDURE dbo.CurveReferenceHierarchySP
go

--EXEC dbo.CurveReferenceHierarchySP 165,126
CREATE PROCEDURE dbo.CurveReferenceHierarchySP
@CurveID			INT,
@ReferenceCurveID   INT = NULL
AS
/*
DECLARE @CurveID			INT,
@ReferenceCurveID   INT 

SELECT @CurveID=165,
	@ReferenceCurveID =278

DROP TABLE #upv_ref_curve
DROP TABLE #core_reference_curve_id

/*

	source_curve_def_id	source_system_id	curve_id
278	2	a3
277	2	a1r
276	2	a1
SELECT * FROM source_price_curve_def where reference_curve_id is not null ORDER BY source_curve_def_id desc
select * from CurveReferenceHierarchy WHERE RefID_1 is not null

sno	curveId	factor	RefID_1	factor_1
126	165	1	170	1
240	277	1	276	1
241	278	1	279	1
*/
--SELECT * FROM  #upv_ref_curve
--select * from CurveReferenceHierarchy h  inner JOIN #core_reference_curve_id c  on h.curveId=c.curve_id 
--		left JOIN #upv_ref_curve u ON c.curve_id=u.curveId where orders_id=5
--*/
DECLARE @i INT,@st VARCHAR(MAX)
SET @i=1

CREATE TABLE #core_reference_curve_id(curve_id INT,orders_id int) --effected curve_id

SELECT curveId, cast(Ref_by_curve AS int) Ref_by_curve, Orders,cast(replace(Orders,'RefID_','') as int) Orders_id INTO #upv_ref_curve
FROM 
   (SELECT curveId, RefID_1,RefID_2,RefID_3,RefID_4,RefID_5,RefID_6,RefID_7,RefID_8,RefID_9,RefID_10
   FROM CurveReferenceHierarchy where RefID_1 is not null ) p
UNPIVOT
   (Ref_by_curve FOR Orders IN 
      (RefID_1,RefID_2,RefID_3,RefID_4,RefID_5,RefID_6,RefID_7,RefID_8,RefID_9,RefID_10)
)AS unpvt;

--   SELECT * FROM #upv_ref_curve
--delete if remove/change reference_id for the curve id  @CurveID
EXEC spa_print 'delete'
delete #upv_ref_curve output deleted.curveid,DELETED.orders_id into #core_reference_curve_id WHERE curveid<>isnull(@ReferenceCurveID,curveid*-1) AND Ref_by_curve=@CurveID
IF @@ROWCOUNT >0 
BEGIN
	DECLARE @delete_ref_curve_id int ,@j int
	SELECT @i=orders_id,@delete_ref_curve_id=curve_id FROM #core_reference_curve_id
	
	--this handle for the removing the middle reference_curve_id, thus it is required to update Ref_by_curve to @curveid as referece_curve_id for rest of Ref_by_curve
	IF  @ReferenceCurveID IS  NULL  --while remove the refere_curve_id
	BEGIN
		INSERT INTO #upv_ref_curve
		SELECT @CurveID,Ref_by_curve,'RefID_'+CAST(orders_id-@i as varchar),orders_id-@i FROM #upv_ref_curve where orders_id>@i AND curveid=@delete_ref_curve_id
		delete #upv_ref_curve FROM #upv_ref_curve where orders_id>@i AND curveid=@delete_ref_curve_id
		
		SET @st='update h set 
			RefID_'+CAST(@i AS VARCHAR)+'=null 
			,factor_'+CAST(@i AS VARCHAR)+'=null
			from CurveReferenceHierarchy h  inner JOIN #core_reference_curve_id c  on h.curveId=c.curve_id 
			and c.orders_id='+CAST(@i AS VARCHAR)
		exec spa_print @st
		EXEC(@st)
		RETURN
	END
	ELSE
	BEGIN
		SELECT @i,@delete_ref_curve_id
		DECLARE @ref_ref_curve_id INT
		SET @ref_ref_curve_id=0
		SELECT @ref_ref_curve_id=curveid,@j=Orders_id FROM #upv_ref_curve WHERE Ref_by_curve=@ReferenceCurveID
		SELECT @ref_ref_curve_id,@j
		IF ISNULL(@ref_ref_curve_id,0)<>0
		BEGIN
			--TRUNCATE TABLE select * from #core_reference_curve_id
			INSERT INTO #upv_ref_curve output inserted.curveid,inserted.orders_id into #core_reference_curve_id
			SELECT @ref_ref_curve_id,Ref_by_curve,'RefID_'+CAST(@j+orders_id-@i as varchar),@j+orders_id-@i FROM #upv_ref_curve where orders_id>@i AND curveid=@delete_ref_curve_id
			delete #upv_ref_curve FROM #upv_ref_curve where orders_id>@i AND curveid=@delete_ref_curve_id
		end
	END
	
END

--if already exist reference_curve_id for the  @ReferenceCurveID insert one more hierarchy
--select * from #upv_ref_curve
--return
IF @ReferenceCurveID IS NOT NULL
BEGIN
	EXEC spa_print 'insert1'
	
	INSERT INTO #upv_ref_curve output inserted.curveid,inserted.orders_id into #core_reference_curve_id
		select curveid,@CurveID,'RefID_'+CAST(orders_id+1 AS VARCHAR),orders_id+1 
		 from #upv_ref_curve t WHERE Ref_by_curve=@ReferenceCurveID AND orders_id<10
--return		
	IF @@ROWCOUNT<1 	--add new reference hierarchy curve
		INSERT INTO #upv_ref_curve output inserted.curveid,inserted.orders_id into #core_reference_curve_id select @ReferenceCurveID,@CurveID,'RefID_1',1
END
--select * from #upv_ref_curve
--return
--re intializing
update CurveReferenceHierarchy set 
	RefID_1=null ,RefID_2=null,RefID_3=null,RefID_4=null,RefID_5=null ,RefID_6=null,RefID_7=null,RefID_8=null,RefID_9=null,RefID_10=NULL
	,factor_1=null,factor_2=null,factor_3=null,factor_4=null,factor_5=null,factor_6=null,factor_7=null,factor_8=null,factor_9=null,factor_10=null
from CurveReferenceHierarchy h  inner JOIN #core_reference_curve_id c  on h.curveId=c.curve_id --INNER JOIN #upv_ref_curve u ON c.curve_id=u.curveId
--select * from CurveReferenceHierarchy WHERE RefID_1 is not null

	--return
set @i=1
WHILE @i<=10
BEGIN
	SET @st='update h set 
		RefID_'+CAST(@i AS VARCHAR)+'=u.Ref_by_curve 
		,factor_'+CAST(@i AS VARCHAR)+'=case when u.Ref_by_curve is null then null else 1 end
		from CurveReferenceHierarchy h  inner JOIN #core_reference_curve_id c  on h.curveId=c.curve_id 
		inner JOIN #upv_ref_curve u ON c.curve_id=u.curveId where u.orders_id='+CAST(@i AS VARCHAR)
	exec spa_print @st
	EXEC(@st)
	IF @@ROWCOUNT<1
		BREAK
	 
	SET @i=@i+1
END
--select * from CurveReferenceHierarchy WHERE RefID_1 is not null
