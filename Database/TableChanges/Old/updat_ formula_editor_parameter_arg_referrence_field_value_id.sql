update formula_editor_parameter set arg_referrence_field_value_id=40000 where field_label='Curve ID'
update formula_editor_parameter set arg_referrence_field_value_id=40002 where field_label='Recorder ID'
update formula_editor_parameter set arg_referrence_field_value_id=40002 where field_label='Meter ID'
update formula_editor_parameter set arg_referrence_field_value_id=40003 where formula_id in (-920,-921) --PriorFinalizedVol,PriorFinalizedAmount

update formula_editor_parameter set sequence=2 where  formula_id=-923 and field_label= 'Block Definition'

update formula_editor_parameter  --MeterVol
set arg_referrence_field_value_id =40003 where  formula_id in (850) and sequence=4 --'Block Definition'