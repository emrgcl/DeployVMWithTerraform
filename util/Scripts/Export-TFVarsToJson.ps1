# Define the input and output file paths
$tfvarsFilePath = "path/to/your/input.tfvars"
$jsonFilePath = "path/to/your/output.json"

# Read the content of the tfvars file
$tfvarsContent = Get-Content $tfvarsFilePath

# Initialize an empty hashtable to store the parsed key-value pairs
$parsedData = @{}

foreach ($line in $tfvarsContent) {
    # Skip empty lines or lines starting with a comment
    if ($line -eq "" -or $line.StartsWith("#")) {
        continue
    }

    # Split the line into key and value parts
    $keyValue = $line -split "="

    # Trim the key and value to remove any extra spaces
    $key = $keyValue[0].Trim()
    $value = $keyValue[1].Trim()

    # Strip double quotes if the value is a string
    if ($value.StartsWith('"') -and $value.EndsWith('"')) {
        $value = $value.Substring(1, $value.Length - 2)
    }

    # Add the key-value pair to the hashtable
    $parsedData[$key] = $value
}

# Convert the hashtable to a JSON object and save it to the output file
$parsedData | ConvertTo-Json | Set-Content $jsonFilePath
