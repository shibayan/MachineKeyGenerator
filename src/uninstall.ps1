param($installPath, $toolsPath, $package, $project)

function Get-WebConfigPath() {
    $directory = [System.IO.Path]::GetDirectoryName($project.FullName)

    return "$directory\Web.config"
}

function Remove-MachineKey() {
    $path = Get-WebConfigPath

    $xml = New-Object xml

    $xml.Load($path)

    $configuration = $xml.SelectSingleNode("configuration")
    if ($configuration -eq $null) {
        return
    }

    $systemWeb = $xml.SelectSingleNode("configuration/system.web")
    if ($systemWeb -eq $null) {
        return
    }

    $machineKey = $xml.SelectSingleNode("configuration/system.web/machineKey")
    if ($machineKey -eq $null) {
        return
    }

    $systemWeb.RemoveChild($machineKey)

    $writer = New-Object System.Xml.XmlTextWriter -ArgumentList @($path, [System.Text.Encoding]::UTF8)
    $writer.Formatting = [System.Xml.Formatting]::Indented

    $xml.Save($writer)

    $writer.Close()

    Write-Host "machinekey removed."
}

Remove-MachineKey