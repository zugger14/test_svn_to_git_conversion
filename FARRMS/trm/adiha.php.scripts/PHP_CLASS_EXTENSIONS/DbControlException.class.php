<?php
class DbControlException extends exception {
    public function __construct($message = NULL, $code = 0) {
        parent::__construct($message, $code);
        DbLog::logError($this);
    }
}


?>
