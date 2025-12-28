<?php
// Generic Route Stub
if (!isset($action)) {
    sendResponse(400, false, 'Invalid request');
}

sendResponse(501, false, 'Feature not implemented yet: ' . $action);
