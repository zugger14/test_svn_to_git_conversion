IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 448)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(448,'Delete Schedule Job','Delete Schedule Job',417);
END

-------------------------------------------------------------------------------------------------------

IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 449)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(449,'Maintain Compliance Groups','Maintain Compliance Groups',Null,'maintainComplianceProcess');
END



IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 450)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(450,'Insert Maintain Compliance Group1 Process','Insert Maintain Compliance Group1 Process',449);
END


IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 451)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(451,'Update Maintain Compliance Group1 Process','Update Maintain Compliance Group1 Process',449);
END


IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 452)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(452,'Delete Maintain Compliance Group1 Process','Delete Maintain Compliance Group1 Process',449);
END


IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 453)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(453,'Insert Maintain Compliance Group2 Risks','Insert Maintain Compliance Group2 Risks',449);
END

IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 454)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(454,'Update Maintain Compliance Group2 Risks','Update Maintain Compliance Group2 Risks',449);
END

IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 455)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(455,'Delete Maintain Compliance Group2 Risks','Delete Maintain Compliance Group2 Risks',449);
END


IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 456)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(456,'Activity Maintain Compliance Group2 Risks','Activity Maintain Compliance Group2 Risks',449);
END

-----------------------------------------------------------------------

IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 457)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(457,'Maintain Generator/Credit Source','Maintain Generator/Credit Source',Null);
END

IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 458)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(458,'Perform Approve Compliance Activities','Perform Approve Compliance Activities',457);
END

----------------------------------------------------------------------------------------------

IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 459)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(459,'Maintain Compliance Standards/Rules','Maintain Compliance Standards/Rules',Null);
END


IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 460)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(460,'Insert Maintain Compliance','Insert Maintain Compliance',Null);
END


IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 461)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(461,'Update Maintain Compliance','Update Maintain Compliance',Null);
END


IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 462)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(462,'Delete Maintain Compliance','Delete Maintain Compliance',Null);
END



IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 463)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(463,'Insert Maintain Compliance Revision','Insert Maintain Compliance Revision',Null);
END

IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 464)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(464,'Update Maintain Compliance Revision','Update Maintain Compliance Revision',Null);
END

IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 465)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(465,'Delete Maintain Compliance Revision','Delete Maintain Compliance Revision',Null);
END

IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 466)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(466,'Requirement Maintain Compliance Revision','Requirement Maintain Compliance Revision',Null);
END

-----------------------------------------------------------------------------------

IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 467)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(467,'Activity Process Map','Activity Process Map',Null,'windowActivityProcessMap');
END


IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 468)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(468,'Insert Activity Process','Insert Activity Process',467);
END


IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 469)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(469,'Update Activity Process','Update Activity Process',467);
END


IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 470)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(470,'Delete Activity Process','Delete Activity Process',467);
END


IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 471)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(471,'Insert Activity Map','Insert Activity Map',467);
END


IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 472)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(472,'Delete Activity Map','Delete Activity Map',467);
END

IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 473)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(473,'Activity Map','Activity Map',467);
END

----------------------------------------------------------

IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 524)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(524,'Perform Compliance Activities','Perform Compliance Activities',null);
END

IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 525)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(525,'Perform Compliance Activities Button','Perform Compliance Activities Button',525);
END