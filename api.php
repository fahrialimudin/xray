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

// ================= VMESS =================
case 'create_vmess':
    $user = trim($input['user'] ?? '');
    $exp  = (int)($input['exp'] ?? 30);

    if (!validateUser($user)) fail('Username tidak valid');

    $out = runCmd("add-ws <<< \"{$user}\n{$exp}\"");

    preg_match('/User\s*:\s*(.+)/i', $out, $u);
    preg_match('/UUID\s*:\s*(.+)/i', $out, $uuid);
    preg_match('/Domain\s*:\s*(.+)/i', $out, $host);
    preg_match('/Link TLS\s*:\s*(.+)/i', $out, $tls);
    preg_match('/Link NTLS\s*:\s*(.+)/i', $out, $ntls);

    ok([
        'user' => trim($u[1] ?? $user),
        'uuid' => trim($uuid[1] ?? ''),
        'host' => trim($host[1] ?? ''),
        'link_tls' => trim($tls[1] ?? ''),
        'link_http' => trim($ntls[1] ?? '')
    ], 'VMess created');


// ================= VLESS =================
case 'create_vless':
    $user = trim($input['user'] ?? '');
    $exp  = (int)($input['exp'] ?? 30);

    if (!validateUser($user)) fail('Username tidak valid');

    $out = runCmd("add-vless <<< \"{$user}\n{$exp}\"");

    preg_match('/User\s*:\s*(.+)/i', $out, $u);
    preg_match('/UUID\s*:\s*(.+)/i', $out, $uuid);
    preg_match('/Domain\s*:\s*(.+)/i', $out, $host);

    ok([
        'user' => trim($u[1] ?? $user),
        'uuid' => trim($uuid[1] ?? ''),
        'host' => trim($host[1] ?? '')
    ], 'VLESS created');


// ================= TROJAN =================
case 'create_trojan':
    $user = trim($input['user'] ?? '');
    $exp  = (int)($input['exp'] ?? 30);

    if (!validateUser($user)) fail('Username tidak valid');

    $out = runCmd("add-tr <<< \"{$user}\n{$exp}\"");

    preg_match('/User\s*:\s*(.+)/i', $out, $u);
    preg_match('/Password\s*:\s*(.+)/i', $out, $pass);
    preg_match('/Domain\s*:\s*(.+)/i', $out, $host);

    ok([
        'user' => trim($u[1] ?? $user),
        'pass' => trim($pass[1] ?? ''),
        'host' => trim($host[1] ?? '')
    ], 'Trojan created');


// ================= STATS =================
case 'stats':
    $ip = trim(runCmd("curl -s ifconfig.me"));
    ok(['ip'=>$ip]);

default:
    fail('Action tidak dikenal');
}
?>