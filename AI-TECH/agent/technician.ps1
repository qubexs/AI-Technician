# technician.ps1 - Chat loop for AI Technician
param([string]$SettingsPath = "..\config\settings.json", [string]$Port = "8080", [string]$HostAddr = "127.0.0.1")

. "$PSScriptRoot\tools.ps1"
$settings = Get-Content $SettingsPath -Raw | ConvertFrom-Json
$base = "http://$HostAddr`:$($settings.server.port)/v1/chat/completions"
$systemPrompt = Get-Content "$PSScriptRoot\system_prompt.txt" -Raw

$messages = @(
    @{ role="system"; content=$systemPrompt }
    @{ role="assistant"; content="Hello, I am AI Technician your offline PC Technician. Describe the problem: slow, blue screen, no boot, error message? I will diagnose with offline tools." }
)

Write-Host "`n=== AI Technician Offline Technician ===" -ForegroundColor Green
Write-Host "Type your problem. Type 'exit' to quit. Commands: 'diagnose', 'yes', 'no'" -ForegroundColor Cyan

function Call-LLM {
    param($msgs)
    $body = @{ model="ai-technician"; messages=$msgs; temperature=$settings.agent.temperature; max_tokens=$settings.agent.maxTokens; stream=$false } | ConvertTo-Json -Depth 6
    try {
        $r = Invoke-RestMethod -Uri $base -Method Post -Body $body -ContentType "application/json" -TimeoutSec 120
        return $r.choices[0].message.content
    } catch {
        return "LLM ERROR: $($_.Exception.Message). Is llama-server running? Check logs."
    }
}

while ($true) {
    Write-Host "`n[You]" -NoNewline -ForegroundColor Cyan
    $user = Read-Host " "
    if ([string]::IsNullOrWhiteSpace($user)) { continue }
    if ($user.Trim().ToLower() -eq 'exit') { break }

    $messages += @{ role="user"; content=$user }
    Write-Host "[AI thinking...]" -ForegroundColor Yellow

    $response = Call-LLM $messages
    Write-Host "`n[AI]`n$response`n" -ForegroundColor White

    # Tool loop: allow up to 5 consecutive tool calls per turn
    $loops = 0
    while ($response -match '```json\s*(\{.*?\})\s*```' -and $loops -lt 5) {
        $loops++
        try {
            $json = $Matches[1] | ConvertFrom-Json
            $tool = $json.tool
            if (-not $tool) { $tool = $json.toolName }
            if ($tool) {
                Write-Host "[Agent] Calling tool: $tool" -ForegroundColor Green
                $result = Invoke-TechnicianTool -Name $tool
                # feed result back to AI
                $messages += @{ role="assistant"; content=$response }
                $messages += @{ role="user"; content="TOOL RESULT for $tool :`n$result`n`nAnalyze this and either call next tool JSON or explain to user in simple English. If repair needed, ask user to type YES." }
                $response = Call-LLM $messages
                Write-Host "`n[AI follow-up]`n$response`n" -ForegroundColor White
            } else { break }
        } catch {
            Write-Host "Tool parse error: $($_.Exception.Message)" -ForegroundColor Red
            break
        }
    }

    $messages += @{ role="assistant"; content=$response }
}
Write-Host "Goodbye. Log saved to AI-TECH\logs\agent.log" -ForegroundColor Green
