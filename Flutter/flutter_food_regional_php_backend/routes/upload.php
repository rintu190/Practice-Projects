<?php

function handleUploadRoutes($method) {
    if ($method === 'POST') {
        handleFileUpload();
    } else {
        http_response_code(405);
        echo json_encode(['error' => 'Method not allowed']);
    }
}

function handleFileUpload() {
    if (!isset($_FILES['image'])) {
        http_response_code(400);
        echo json_encode(['error' => 'No image file provided']);
        return;
    }

    $file = $_FILES['image'];
    $fileName = $file['name'];
    $fileTmpName = $file['tmp_name'];
    $fileSize = $file['size'];
    $fileError = $file['error'];
    $fileType = $file['type'];

    // Check for errors
    if ($fileError !== 0) {
        http_response_code(500);
        echo json_encode(['error' => 'Error uploading file: ' . $fileError]);
        return;
    }

    // Validate file type (allow only images)
    $allowed = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    $fileExt = strtolower(pathinfo($fileName, PATHINFO_EXTENSION));

    if (!in_array($fileExt, $allowed)) {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid file type. Only JPG, JPEG, PNG, GIF, and WEBP are allowed.']);
        return;
    }

    // Validate file size (e.g., max 5MB)
    if ($fileSize > 5 * 1024 * 1024) {
        http_response_code(400);
        echo json_encode(['error' => 'File is too large. Max size is 5MB.']);
        return;
    }

    // Generate unique filename
    $newFileName = uniqid('', true) . "." . $fileExt;
    $uploadDir = __DIR__ . '/../uploads/';
    
    // Ensure upload directory exists
    if (!file_exists($uploadDir)) {
        mkdir($uploadDir, 0777, true);
    }

    $destination = $uploadDir . $newFileName;

    // Move uploaded file
    if (move_uploaded_file($fileTmpName, $destination)) {
        // Construct public URL
        // Assuming the server is running on localhost:8000 or similar
        // We need a way to determine the base URL. For now, we'll return a relative path or construct it based on $_SERVER
        
        $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? "https" : "http";
        $host = $_SERVER['HTTP_HOST'];
        // Adjust this path based on your server configuration
        // If serving from project root:
        $publicUrl = "$protocol://$host/uploads/$newFileName";

        http_response_code(201);
        echo json_encode([
            'message' => 'File uploaded successfully',
            'url' => $publicUrl
        ]);
    } else {
        http_response_code(500);
        echo json_encode(['error' => 'Failed to move uploaded file']);
    }
}
