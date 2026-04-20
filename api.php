<?php
header('Content-Type: application/json');

function ok($data = [], $message = 'OK') {
    echo json_encode(['success' => true, 'message' => $message, 'data' => $data]);
    exit;
}
function fail($message = 'Error') {
    echo json_encode(['success' => false, 'message' => $message]);
    exit;
}

function runCmd($cmd) {
    return shell_exec('sudo bash -c ' . escapeshellarg($cmd) . ' 2>&1');
}

function validateUser($user) {
    return preg_match('/^[a-zA-Z0-9_\-]{3,20}$/', $user);
}

$input  = json_decode(file_get_contents('php://input'), true) ?? [];
$action = $input['action'] ?? '';

switch ($action) {

// ================= SSH =================
case 'create_ssh':
    $user = trim($input['user'] ?? '');
    $pass = trim($input['pass'] ?? '');
    $exp  = (int)($input['exp'] ?? 30);

    if (!validateUser($user)) fail('Username tidak valid');
    if (strlen($pass) < 4) fail('Password minimal 4 karakter');

    $cmd = "add-ssh <<< \"{$user}\n{$pass}\n{$exp}\"";
    $out = runCmd($cmd);

    ok(['result' => $out], 'SSH berhasil dibuat');


// ================= VMESS =================
case 'create_vmess':
    $user = trim($input['user'] ?? '');
    $exp  = (int)($input['exp'] ?? 30);

    if (!validateUser($user)) fail('Username tidak valid');

    $cmd = "add-ws <<< \"{$user}\n{$exp}\"";
    $out = runCmd($cmd);

    ok(['result' => $out], 'VMess berhasil dibuat');


// ================= VLESS =================
case 'create_vless':
    $user = trim($input['user'] ?? '');
    $exp  = (int)($input['exp'] ?? 30);

    if (!validateUser($user)) fail('Username tidak valid');

    $cmd = "add-vless <<< \"{$user}\n{$exp}\"";
    $out = runCmd($cmd);

    ok(['result' => $out], 'VLESS berhasil dibuat');


// ================= TROJAN =================
case 'create_trojan':
    $user = trim($input['user'] ?? '');
    $exp  = (int)($input['exp'] ?? 30);

    if (!validateUser($user)) fail('Username tidak valid');

    $cmd = "add-tr <<< \"{$user}\n{$exp}\"";
    $out = runCmd($cmd);

    ok(['result' => $out], 'Trojan berhasil dibuat');


// ================= STATUS SERVICE =================
case 'service_status':
    $services = ['xray','nginx','ssh'];
    $result = [];

    foreach ($services as $svc) {
        $status = trim(runCmd("systemctl is-active $svc"));
        $result[] = ['service'=>$svc, 'status'=>$status];
    }

    ok($result);


// ================= DEFAULT =================
default:
    fail('Action tidak dikenal');
}
?>
