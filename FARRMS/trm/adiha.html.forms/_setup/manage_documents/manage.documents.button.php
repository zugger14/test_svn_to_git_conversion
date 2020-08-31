<style>
    .doc_count_class {
        width:11px;
        height:14px;
        float: right;
        border-radius: 50px;
        color: #FFFFFF;
        padding-left: 5px;
        padding-top: 3px;
        font-size:12px;
        font-weight: :bold;
        line-height: 10px;
        /*background: #71A9FF;*/
        background: #FF5050;
    }
</style>

<script>
    var category_id, object_id, toolbar_object, button_right, sub_category_id;

    function add_manage_document_button(objectId, toolbarObject, buttonRight) {
        toolbar_object = toolbarObject;
        button_right = buttonRight;
        object_id = objectId;
        
        toolbar_object.addButton('documents', 2, 'Documents', 'doc.gif', 'doc_dis.gif');
        if(!button_right) {
            toolbar_object.disableItem('documents');
        }

        apply_sticker(object_id);
        
        data = {"action": "spa_application_notes",
            "flag": "c",
            "internal_type_value_id": category_id,
            "category_value_id": sub_category_id,
            "notes_object_id": object_id
        };

        adiha_post_data('return_array', data, '', '', 'add_manage_document_button_response');
    }

    function add_manage_document_button_response(result) {
        var document_count = document_counter(result);
        
        if (result.length > 0)
            apply_counter(document_count, result[0][1]);
    }

    function apply_sticker(object_id) {
        //.dhx_cell_toolbar_def, ..dhx_cell_menu_def
        $('.dhxtoolbar_text, .top_level_text').filter(
            function() {return $(this).text() == 'Documents';}).filter(
                function() {return !$(this).siblings('.doc_count').length}).after(
                    function() {return "<div id='doc_obj_" + object_id + "' class='doc_count'></div>";});
    }

    function apply_counter(document_count, object_id) {
        if(document_count == '0') {
            document_count = '';
        }

        $('#doc_obj_' + object_id).text(document_count);

        if(document_count > 0) {
            $('#doc_obj_' + object_id).addClass( "doc_count_class" );
        } else {
            $('#doc_obj_' + object_id).removeClass( "doc_count_class" );
        }
    }

    function update_document_counter(objectId, toolbarObject) {
        toolbar_object = toolbarObject;
        object_id = objectId;

        data = {"action": "spa_application_notes",
            "flag": "c",
            "internal_type_value_id": category_id,
            "category_value_id": sub_category_id,
            "notes_object_id": objectId
        };

        adiha_post_data('return_array', data, '', '', 'update_document_counter_response');
    }

    function update_document_counter_response(result) {
        var document_count = document_counter(result);
        apply_counter(document_count, object_id);
    }

    function document_counter(result) {
        var document_count = 0;
        document_count = result.length;

/*      var attached_documents;  
        if(result != '') {
            for(var i = 0; i < result.length; i++) {
                attached_documents = result[i][0].split(",");
                document_count = document_count + attached_documents.length;
            }
        }
*/
        return document_count;
    }
</script>