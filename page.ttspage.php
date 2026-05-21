<?php
if (!defined('FREEPBX_IS_AUTH')) { die('No direct script access allowed'); }

// Get all extensions dynamically from FreePBX
$extensions = FreePBX::Core()->getAllUsers();

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['message'])) {
    $message = escapeshellarg($_POST['message']);
    $voice = escapeshellarg($_POST['voice']);
    $exts = isset($_POST['extensions']) ? implode(' ', array_map('escapeshellarg', $_POST['extensions'])) : '';
    if (!empty($exts)) {
        exec("/usr/local/bin/broadcast.sh $message $voice $exts 2>&1", $output, $retcode);
        $status = "Broadcast sent!";
        $statustype = "success";
    } else {
        $status = "Please select at least one extension.";
        $statustype = "danger";
    }
}
?>

<div class="container-fluid">
    <div class="row">
        <div class="col-sm-8 col-sm-offset-2">
            <h1>📢 TTS Page</h1>
            <p class="text-muted">Send a text-to-speech message to one or more extensions using Piper TTS.</p>
            <?php if (!empty($status)) echo "<div class='alert alert-$statustype'>$status</div>"; ?>
            <form method="POST">
                <input type="hidden" name="display" value="ttspage">
                <div class="form-group">
                    <label>Message</label>
                    <textarea name="message" class="form-control" rows="3" placeholder="Type your message here..."></textarea>
                </div>
                <div class="form-group">
                    <label>Voice</label>
                    <select name="voice" class="form-control">
                        <option value="en_US-lessac-medium">Lessac (Neutral Male)</option>
                        <option value="en_US-amy-medium">Amy (Female)</option>
                        <option value="en_US-ryan-high">Ryan (Male)</option>
                        <option value="en_US-kathleen-low">Kathleen (Female)</option>
                        <option value="en_US-joe-medium">Joe (Male)</option>
                        <option value="en_US-kusal-medium">Kusal (Male)</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Send To</label>
                    <div class="row">
                        <?php foreach ($extensions as $ext): ?>
                        <div class="col-sm-4">
                            <div class="checkbox">
                                <label>
                                    <input type="checkbox" name="extensions[]" value="<?php echo htmlspecialchars($ext['extension']); ?>">
                                    <?php echo htmlspecialchars($ext['extension']); ?> - <?php echo htmlspecialchars($ext['name']); ?>
                                </label>
                            </div>
                        </div>
                        <?php endforeach; ?>
                    </div>
                    <div class="checkbox">
                        <label>
                            <input type="checkbox" id="selectall"> <strong>Select All</strong>
                        </label>
                    </div>
                </div>
                <button type="submit" class="btn btn-primary btn-lg">📣 Broadcast</button>
            </form>
        </div>
    </div>
</div>

<script>
document.getElementById('selectall').addEventListener('change', function() {
    document.querySelectorAll('input[name="extensions[]"]').forEach(function(cb) {
        cb.checked = document.getElementById('selectall').checked;
    });
});
</script>
