function Invoke-SSHCommandWithTemplate {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        $SSHSession,
        $Command,
        $ModuleName,
        [ValidateSet("FlashExtract","Regex")]$TemplateType = "FlashExtract"
    )
    if ($PSCmdlet.ShouldProcess($SSHSession.Host)) {
        $TemplateName = Get-SSHCommandTemplateName -Command $Command

        $SSHCommandResults = Invoke-SSHCommand -Command $Command -Index $SSHSession.SessionID
        ForEach ($SSHCommandResult in $SSHCommandResults) {
            $Objects = Invoke-StringTemplateToPSCustomObject -String $SSHCommandResult.output -TemplateName $TemplateName -ModuleName $ModuleName -TemplateType $TemplateType
            $Objects | Add-Member -MemberType NoteProperty -Name Host -Value $SSHCommandResult.Host
            $Results += $Objects
        }
        $Results
    } else {
        $Command
    }
}

function New-SSHCommandTemplate {
    param (
        $SSHSession,
        $Command,
        $ModuleName,
        [ValidateSet("FlashExtract","Regex")]$TemplateType = "FlashExtract"
    )
    $TemplateName = Get-SSHCommandTemplateName -Command $Command
    $SSHCommandResults = Invoke-SSHCommand -Command $Command -Index $SSHSession.SessionID    
    New-StringTemplateFile -String $SSHCommandResults.output -TemplateName $TemplateName -ModuleName $ModuleName -TemplateType $TemplateType
}

function Edit-SSHCommandTemplate {
    param (        
        $Command,
        $ModuleName,
        [ValidateSet("FlashExtract","Regex")]$TemplateType = "FlashExtract"
    )
    $TemplateName = Get-SSHCommandTemplateName -Command $Command   
    Edit-StringTemplateFile -TemplateName $TemplateName -ModuleName $ModuleName -TemplateType $TemplateType
}

function Get-SSHCommandTemplateName {
    param (
        $Command
    )
    Get-StringHash -String $Command
}

function Get-StringHash { 
    param (
        [String]$String,
        $HashName = "MD5"
    )
    $StringBuilder = New-Object System.Text.StringBuilder 
    [System.Security.Cryptography.HashAlgorithm]::Create($HashName).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String))|
    % { 
        [Void]$StringBuilder.Append($_.ToString("x2")) 
    } 
    $StringBuilder.ToString() 
}