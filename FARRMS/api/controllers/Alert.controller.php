<?php

class AlertController extends REST {
    public function index() {
        $results = Alert::find();
        $this->response($this->json($results), 200);
    }

    public function get($alertId) {
        $results = Alert::findOne($alertId);
        $this->response($this->json($results[0]), 200);
    }
    
    public function delete($body) {
        $alertIds = $body->ids;
        
        $results = Alert::delete($alertIds);
        
        if (isset($results[0]['ErrorCode']) && $results[0]['ErrorCode'] = 'Success') {
            /*$json = array(
                'message' => $results[0]['Message'],
                "ids" => $alertIds
            );
            $this->response($this->json($json));
            */
            $this->index();
        } else {
            $this->sendError(400, $results[0]['Message']);
        }
        
    }
    
    public function action($body) {
        $alert_action = $body->action;
        $activity_ids = $body->ids;
        
        $results = Alert::action($alert_action, $activity_ids);
        
        if (isset($results[0]['ErrorCode']) && $results[0]['ErrorCode'] = 'Success') {
            /*$json = array(
                'message' => $results[0]['Message'],
                "ids" => $activity_ids
            );
            $this->response($this->json($json));
			*/
			$this->index();
        } else {
            $this->sendError(400, $results[0]['Message']);
        }
    }
    
}
