update application_ui_template_definition set is_identity = 'y' from application_ui_template_definition where farrms_field_id = 'meter_id'

update adiha_grid_definition set grid_type = 'g' from adiha_grid_definition where grid_id = 3

ALTER TABLE meter_id ADD source_uom_id INT

ALTER TABLE [dbo].[meter_id]  WITH CHECK ADD  CONSTRAINT [FK_meter_id_source_uom] FOREIGN KEY([source_uom_id])
REFERENCES [dbo].[source_uom] ([source_uom_id])


alter table meter_id alter column granularity int

