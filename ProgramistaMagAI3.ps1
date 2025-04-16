# Get the path of the running script and prepare needed variables
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$scriptPathMakefile = "$scriptPath\makefile"

# LLM model to use
$LLM = "gemma3:27b"

# Your Assistant
$Assistant = "You are J.A.R.V.I.S, acting as an assistant"
$SystemFinal = "SYSTEM `"$Assistant`""

# Content of makefile
$MakeFileContent = ollama show --modelfile $LLM

# Replace lines starting with "FROM" with a new line (empty string)
$MakeFileContent = $MakeFileContent | ForEach-Object {
    if ($_ -match '^FROM') { "FROM $LLM" } else { $_ }
}

New-Item -Path "$scriptPathMakefile" -ItemType File
Add-Content -Path $scriptPathMakefile -Value $MakeFileContent
Add-Content -Path $scriptPathMakefile -Value $SystemFinal

# Create model from already existing
ollama create ProgramistaJarvis -f $scriptPathMakefile

# Remove makefile
Remove-Item -Path $scriptPathMakefile


# ollama show --modelfile deepseek-r1:32b