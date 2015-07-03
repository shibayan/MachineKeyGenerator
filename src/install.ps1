param($installPath, $toolsPath, $package, $project)

function Generate-Key([int] $length) {
    $rng = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
    $buffer = New-Object byte[] $length

    $rng.GetBytes($buffer)

    $result = New-Object System.Text.StringBuilder

    for ($i = 0; $i -lt $buffer.Length; $i++) {
        [void]$result.AppendFormat("{0:X2}", $buffer[$i])
    }

    return $result.ToString();
}

function Get-WebConfigPath() {
    $directory = [System.IO.Path]::GetDirectoryName($project.FullName)

    return "$directory\Web.config"
}

function Add-MachineKey() {
    $path = Get-WebConfigPath

    $xml = New-Object xml

    $xml.Load($path)

    $configuration = $xml.SelectSingleNode("configuration")
    if ($configuration -eq $null) {
        $configuration = $xml.CreateElement("configuration")
        $xml.AppendChild($configuration)
    }

    $systemWeb = $xml.SelectSingleNode("configuration/system.web")
    if ($systemWeb -eq $null) {
        $systemWeb = $xml.CreateElement("system.web")
        $configuration.AppendChild($systemWeb)
    }

    $machineKey = $xml.SelectSingleNode("configuration/system.web/machineKey")
    if ($machineKey -ne $null) {
        Write-Host "already generated machinekey."
        return
    }

    $machineKey = $xml.CreateElement("machineKey")

    $decryption = $xml.CreateAttribute("decryption")
    $decryption.Value = "Auto"

    $machineKey.Attributes.Append($decryption)

    $decryptionKey = $xml.CreateAttribute("decryptionKey")
    $decryptionKey.Value = Generate-Key (256 / 8)

    $machineKey.Attributes.Append($decryptionKey)

    $validation = $xml.CreateAttribute("validation")
    $validation.Value = "HMACSHA256"

    $machineKey.Attributes.Append($validation)

    $validationKey = $xml.CreateAttribute("validationKey")
    $validationKey.Value = Generate-Key (256 / 8)

    $machineKey.Attributes.Append($validationKey)

    $systemWeb.AppendChild($machineKey)

    $writer = New-Object System.Xml.XmlTextWriter -ArgumentList @($path, [System.Text.Encoding]::UTF8)
    $writer.Formatting = [System.Xml.Formatting]::Indented

    $xml.Save($writer)

    $writer.Close()

    Write-Host "add generated machinekey."
}

Add-MachineKey