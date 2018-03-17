# This script is to dynamically inject the environment (`dev`, `test`, `stage`, `prod`) as a string into the index.html file of the angular application. That way it can decide at runtime which APIs to call. The list of APIs for dev, test, stage, and prod will always exist in the application artifact. Based on the value in `window.enviroment` the application will call the correct API for its environment.

# Feed environment in
Param(    
    [Parameter(Mandatory=$true)] [string] $environment,
    [Parameter(Mandatory=$true)] [string] $pathToIndexFile
)

# Assign environment to global variable in browser
$scriptToAdd = "
    <script>
        window.environment = '$environment'
    </script>
</head>
"

(Get-Content $pathToIndexFile).replace('</head>', $scriptToAdd) | Set-Content $pathToIndexFile
