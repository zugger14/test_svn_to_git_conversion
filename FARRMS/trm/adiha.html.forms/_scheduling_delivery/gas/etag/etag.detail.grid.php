<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
</head>
    <?php
    include '../../../../adiha.php.scripts/components/include.file.v3.php';
    ?>
<div class="component-container-grid">
    <?php
    $etag_id = get_sanitized_value($_GET['etag_id']);
    $etag_detail = "EXEC spa_etag @flag=a, @etag_id=$etag_id";
    echo adiha_dhtmlx_grid('grd_etag_detail', $etag_detail, 'auto', '300px', '', '', false, 'insert', '', false, 25, '', '', '', false, false, '', '', false, false, '', true);
    ?>
</div>
    <script type="text/javascript">
        function save_detail() {
            var xml = get_grd_etag_detail_data();
            parent.save_detail(xml);
        }
    </script>
<style>
    html, body {
        width: 100%;
        height: 100%;
        margin: 0px;
        padding: 0px;
        background-color: #ebebeb;
        overflow: hidden;
    }
</style>