
/************   Update formula CurveD with added parameter         ***********/
update formula_editor set formula =REPLACE(formula,'FNACurveD(10)','FNACurveD(10,NULL)')  where formula like '%curved%'
