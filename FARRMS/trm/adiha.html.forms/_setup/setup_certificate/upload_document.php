<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>

<body>
    <?php
    global $app_adiha_loc, $app_php_script_loc;
    $form_namespace = 'upload_document';
    $layout_json = '[{id: "a", header:false}]';
    $layout_obj = new AdihaLayout();
    $form_obj = new AdihaForm();

    $form_json = "[
		{'type': 'settings', position: 'label-top', offsetLeft:20, inputWidth:150},
	   	{type: 'block', blockOffset:0, list: [
		    {type: 'fieldset', inputWidth:580, label: 'File Attachment', list:[
				{type: 'upload', name: 'upload', inputWidth:500, url:'" . $app_adiha_loc . "adiha.html.forms/_setup/setup_certificate/document_file_uploader.php', autoStart:true, filesLimit:1},
				{type: 'label', label: '* Note: Only one file can be uploaded.'}
			]},
			{type: 'newcolumn'},
			{type: 'hidden', value:'', name:'file_attachment'}
	    ]},
	    {type: 'block', blockOffset:0, list: [
    		{type: 'label', inputWidth:580, label: 'Current Attached File(s): current_attached_file', hidden: true, offsetTop: 0, className: 'current_attached'}
		]}
	]";

    echo $layout_obj->init_layout('layout', '', '1C', $layout_json, $form_namespace);

    $menu_obj = new AdihaMenu();
    $menu_json = '[{id:"save", text:"Save", img:"save.gif", img_dis:"save_dis.gif", title:"Save"}]';
    echo $layout_obj->attach_menu_cell('menu', 'a');
    echo $menu_obj->init_by_attach('menu', $form_namespace);
    echo $menu_obj->load_menu($menu_json);
    echo $layout_obj->attach_form('form', 'a');
    echo $form_obj->init_by_attach('form', $form_namespace);
    echo $form_obj->load_form($form_json);
    echo $menu_obj->attach_event('', 'onClick', 'upload_document.save_document');
    echo $layout_obj->close_layout();
    ?>
    <script type="text/javascript">
        var app_adiha_loc = '<?php echo $app_adiha_loc ?>';

        var document_name = '';
        $(function() {
            var form_obj = upload_document.form;
            var menu_obj = upload_document.menu;
            var upload = form_obj.getUploader("upload");


            form_obj.attachEvent('onBeforeFileAdd', function(name, value, form) {
                if (upload.getStatus() == 0) {
                    return true
                } else {
                    return false
                }

            });

        });

        upload_document.save_document = function() {

            var uploader_obj = upload_document.form.getUploader('upload');
            var my_uploader = uploader_obj.getData();
            upload_document.filenames = [];

            $.each(my_uploader, function(index, value) {
                upload_document.filenames.push(value.realName);
            });
            upload_document.move_document();
        }

        upload_document.move_document = function() {
            // parent.maintain_users.refresh_all_grids('refresh');
            var url = 'move_document.php';
            $.ajax({
                url: url,
                type: 'POST',
                data: {
                    "file_names": upload_document.filenames
                },
                success: function() {
                    parent.setup_certificate.set_file_name(upload_document.filenames);
                },
                error: function(e) {
                    console.log(e);
                }
            });

        }
    </script>
</body>