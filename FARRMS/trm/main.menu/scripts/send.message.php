<html>
    <body>
        <div class="forward_message" style="width: 600px;">
            <?php $message_id = $_GET['selected_id']; ?>
            <div class="modal-dialog" style="z-index:1000;">
                <div class="modal-content" style="width: 690px;">
                    <div class="modal-header">
                        <div class="item-header">Message Detail</div>
                        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                    </div>
                    <div class="modal-body" >
                        <iframe id="forward_message" name="forward_message" src="send.message.container.php?selected_id=<?php echo $message_id; ?>" width="650" height="615" scrolling="no" frameBorder="0"></iframe>
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>