IF NOT EXISTS( SELECT 1 FROM sys.columns WHERE [name]='available' AND [object_id]=object_id('forecast_profile'))
ALTER TABLE forecast_profile ADD available bit

