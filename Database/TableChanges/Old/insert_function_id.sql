-- =============================================
-- Author:		<Prakash Poudel>
-- Create date: <22nd April 2009>
-- Description:	<Inserting function_id in application_function table for new forms>
-- =============================================

IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 421)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(421,'Adjust Settlement','Adjust Settlement',420,'windowAdjustChargeType');
END
IF EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 422)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(422,'Insert meter contract','Insert meter contract counterparty',404,'windowMaintainRecMeterID');
END
IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 423)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(423,'Update meter contract','Update meter contract counterparty',404,'windowMaintainRecMeterID');
END
IF EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 424)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(424,'Delete meter contract','Delete meter contract counterparty',404);
END
IF EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 425)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(425,'Insert submeter contract','Insert submeter contract counterparty',404,'windowMaintainRecMeterID');
END
IF EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 426)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(426,'Update submeter contract','Update submeter contract counterparty',404,'windowMaintainRecMeterID');
END
IF EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 427)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(427,'Delete submeter contract','Delete submeter contract counterparty',404);
END
IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 428)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(428,'Block trading update','Block trading update',395,'windowCounterpartyBlockTradingIU');
END

IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 429)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(429,'Block trading delete','Block trading delete',395);
END
IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 430)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(430,'Insert net counterparty','Insert net counterparty',395,'nettingGrpDetailIU');
END
IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 431)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(431,'update net counterparty','update net counterparty',395,'nettingGrpDetailIU');
END
IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 432)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(432,'Delete net counterparty','Delete net counterparty',395);
END
IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 433)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(433,'Insert Position-tenor Limit','Insert Position-tenor Limit',363,'LimitTrackingCurveIU');
END

IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 434)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(434,'Update Position-tenor Limit','Update Position-tenor Limit',363,'LimitTrackingCurveIU');
END


IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 435)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(435,'Delete Position-tenor Limit','Delete Position-tenor Limit',363);
END

IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 436)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(436,'Deal History','Deal History',156,'windowDealConfirmStatus');
END
IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 437)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(437,'Update Status','Update Status',156,'windowDealConfirmStatusIU');
END
IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 438)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(438,'Lock','Lock',156);
END
IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 439)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(439,'UnLock','UnLock',156);
END
IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 440)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(440,'Generate Confirm','Generate Confirm',156,'windowConfirmGenerate');
END
IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 441)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(441,'Deal Confirm Status','Deal Confirm Status',436);
END
IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 442)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(442,'Insert Deal History','Insert Deal History',441,'windowDealConfirmStatusIU');
END
IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 443)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(443,'Update Deal History','Update Deal History',441,'windowDealConfirmStatusIU');
END
IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 444)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(444,'Delete Deal History','Delete Deal History',441);
END
IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 445)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(445,'Add Static Holiday','Add Static Holiday',175,'windowMaintainholidaygroupIU');
END
IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 446)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(446,'Update Static Holiday','Update Static Holiday',175,'windowMaintainholidaygroupIU');
END
IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 447)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(447,'Delete Static Holiday','Delete Static Holiday',175);
END
IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 474)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(474,'Maintain Compliance Activity','Maintain Compliance Activity',456,'compActDetail');
END

IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 475)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(475,'Insert Compliance Activity','Insert Compliance Activity',474,'windowCompActivityIU');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 476)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(476,'Update Compliance Activity','Update Compliance Activity',474,'windowCompActivityIU');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 477)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(477,'Delete Compliance Activity','Delete Compliance Activity',474,'');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 478)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(478,'Copy Compliance Activity','Copy Compliance Activity',474,'');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 479)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(479,'Dependence Compliance Activity','Dependence Compliance Activity',474,'windowCompActivityDependent');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 480)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(480,'Insert step Compliance Activity','Insert step Compliance Activity',474,'reportDummyStepsIU');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 481)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(481,'Update step Compliance Activity','Update step Compliance Activity',474,'reportDummyStepsIU');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 482)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(482,'Delete step Compliance Activity','Delete step Compliance Activity',474,'');
END

IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 483)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(483,'Maintain Complaince Activity Detail','Maintain Complaince Activity Detail',475,'');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 484)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(484,'Insert Communication Activity Detail','Insert Communication Activity Detail',475,'windowMaintainRiskContolsEmailIU');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 485)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(485,'Update Communication Activity Detail','Update Communication Activity Detail',475,'windowMaintainRiskContolsEmailIU');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 486)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(486,'Delete Communication Activity Detail','Delete Communication Activity Detail',475,'');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 487)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(487,'Maintain Transactions','Maintain Transactions',null,'');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 488)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(488,'Insert Maintain Transactions','Insert Maintain Transactions',487,'');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 489)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(489,'Update Maintain Transactions','Update Maintain Transactions',487,'');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 490)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(490,'Delete Maintain Transactions','Delete Maintain Transactions',487,'');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 491)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(491,'Copy Maintain Transactions','Copy Maintain Transactions',487,'');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 492)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(492,'Transfer Maintain Transactions','Transfer Maintain Transactions',487,'');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 493)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(493,'Close Maintain Transactions','Close Maintain Transactions',487,'');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 494)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(494,'Rollover from Forward to Spot',' Rollover from Forward to Spot',null,'');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 495)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(495,'Process Rollover',' Process Rollover',494,'');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 496)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(496,'Schedule and Delivery','Schedule and Delivery',null,'');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 497)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(497,'Book/UnBook','Book/UnBook',496,'');
END
IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 498)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(498,'Maintain Compliance Requirements','Maintain Compliance Requirements',null);
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 499)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(499,'Insert Maintain Compliance Requirements','Insert Maintain Compliance Requirements',498,'windowCompReqMainIU');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 500)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(500,'Update Maintain Compliance Requirements','Update Maintain Compliance Requirements',498,'windowCompReqMainIU');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 501)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(501,'Delete Maintain Compliance Requirements','Delete Maintain Compliance Requirements',498,'');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 502)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(502,'Insert Require Revision','Insert Require Revision',498,'MaintainComplianceRequirementsIU');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 503)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(503,'Update Require Revision','Update Require Revision',498,'MaintainComplianceRequirementsIU');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 504)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(504,'Delete Require Revision','Update Require Revision',498,'');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 505)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(505,'Copy Require Revision','Copy Require Revision',498,'');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 506)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(506,'Dependancy Require Revision','Depandancy Require Revision',498,'windowCompReqRevisionDependent');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 507)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(507,'Insert Assignment','Insert Assignment',498,'maintainCompReaAssIU');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 508)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(508,'Update Assignment','Update Assignment',498,'maintainCompReaAssIU');
END
IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 509)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(509,'Complaince Requirements Details','Compliance Requirements Details',null);
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 510)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(510,'Insert Complaince Requirements Details','Insert Complaince Requirements Details',509,'reportStepsStdIU');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 511)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(511,'Update Complaince Requirements Details','Update Complaince Requirements Details',509,'reportStepsStdIU');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 512)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(512,'Delete Complaince Requirements Details','Delete Complaince Requirements Details',509,'');
END
IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 513)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(513,'Compliance Requirement Revision Dependency','Compliance Requirement Revision Dependency',null);
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 514)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(514,'Insert Complaince Requirements Details','Insert Complaince Requirements Details',513,'windowCompActivityStdDependencyIU');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 515)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(515,'Delete Complaince Requirements Details','Delete Complaince Requirements Details',513,'');
END
IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 516)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id)values(516,'Compliance Requirement Revision','Compliance Requirement Revision',null);
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 517)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(517,'Insert Compliance Requirement Revision','Insert Compliance Requirement Revision',516,'');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 518)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(518,'Insert Maintain Transcation','Insert Maintain Transcation',197,'windowMaintainDealInsert');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 519)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(519,'Update Maintain Transcation','Update Maintain Transcation',197,'windowMaintainDealInsert');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 520)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(520,'Delete Maintain Transcation','Delete Maintain Transcation',197,'');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 521)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(521,'Copy Maintain Transcation','Copy Maintain Transcation',197,'windowCopyDealIU');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 522)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(522,'Transfer Maintain Transcation','Transfer Maintain Transcation',197,'windowInterBookTransfer');
END
IF  EXISTS(SELECT * FROM dbo.application_functions  WHERE function_id = 523)
	print 'exist'
else
BEGIN
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(523,'Close Maintain Transcation','Close Maintain Transcation',197,'');
END







