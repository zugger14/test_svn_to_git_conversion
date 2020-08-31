-- Delete existing configuration if exists 
DELETE FROM ssis_configurations WHERE ConfigurationFilter IN ('PRJ_Simplex_Solver')

--Apply New Settings
INSERT INTO ssis_configurations (ConfigurationFilter,ConfiguredValue,PackagePath,ConfiguredValueType)
	SELECT 'PRJ_Simplex_Solver', '\simplex\packages', '\Package.Variables[User::PS_PackageSubDir].Properties[Value]', 'String	'

--update import path
UPDATE connection_string SET import_path = 'D:\FARRMS_SPTFiles\SSIS\TRMTracker_New_Framework'
	
      