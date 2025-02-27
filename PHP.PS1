	# Setup Script for License Search App (PHP)

# Step 1: Create the project directory
Write-Host "Creating project directory..."
$projectDir = "$env:USERPROFILE\license-search-app"
if (-not (Test-Path $projectDir)) {
    New-Item -ItemType Directory -Path $projectDir | Out-Null
} else {
    Write-Host "Project directory already exists."
}
Set-Location $projectDir

# Step 2: Create index.php
Write-Host "Creating index.php..."
@"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>License Search App</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <h1>License Search App</h1>
    <form action="search.php" method="GET">
        <label for="sections">Sections (comma-separated):</label>
        <input type="text" id="sections" name="sections"><br>

        <label for="organizations">Organizations (comma-separated):</label>
        <input type="text" id="organizations" name="organizations"><br>

        <label for="lname">Last Names (comma-separated):</label>
        <input type="text" id="lname" name="lname"><br>

        <label for="uname">Usernames (comma-separated):</label>
        <input type="text" id="uname" name="uname"><br>

        <label for="province">Provinces (comma-separated):</label>
        <input type="text" id="province" name="province"><br>

        <label for="township">Townships (comma-separated):</label>
        <input type="text" id="township" name="township"><br>

        <label for="from">From Date:</label>
        <input type="text" id="from" name="from"><br>

        <label for="to">To Date:</label>
        <input type="text" id="to" name="to"><br>

        <button type="submit">Search</button>
    </form>
</body>
</html>
"@ | Out-File "$projectDir\index.php"

# Step 3: Create search.php
Write-Host "Creating search.php..."
@"
<?php
// Function to fetch data from the API
function fetchLicenses(\$params) {
    \$url = "https://qr.mojavez.ir/api/licenses?" . http_build_query(\$params);
    \$response = file_get_contents(\$url);
    return json_decode(\$response, true);
}

// Get search parameters from the form
\$sections = isset(\$_GET['sections']) ? explode(",", \$_GET['sections']) : [];
\$organizations = isset(\$_GET['organizations']) ? explode(",", \$_GET['organizations']) : [];
\$lname = isset(\$_GET['lname']) ? explode(",", \$_GET['lname']) : [];
\$uname = isset(\$_GET['uname']) ? explode(",", \$_GET['uname']) : [];
\$province = isset(\$_GET['province']) ? explode(",", \$_GET['province']) : [];
\$township = isset(\$_GET['township']) ? explode(",", \$_GET['township']) : [];
\$from = isset(\$_GET['from']) ? \$_GET['from'] : "";
\$to = isset(\$_GET['to']) ? \$_GET['to'] : "";

\$results = [];

// Perform searches for each combination of parameters
foreach (\$sections as \$section) {
    foreach (\$organizations as \$organization) {
        foreach (\$lname as \$l) {
            foreach (\$uname as \$u) {
                foreach (\$province as \$p) {
                    foreach (\$township as \$t) {
                        \$params = [
                            "per_page" => 210,
                            "page" => 1,
                            "sections" => trim(\$section),
                            "organizations" => trim(\$organization),
                            "lname" => trim(\$l),
                            "uname" => trim(\$u),
                            "province" => trim(\$p),
                            "township" => trim(\$t),
                            "from" => \$from,
                            "to" => \$to,
                        ];

                        \$data = fetchLicenses(\$params);
                        if (\$data && is_array(\$data)) {
                            \$results = array_merge(\$results, \$data);
                        }
                    }
                }
            }
        }
    }
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Search Results</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <h1>Search Results</h1>
    <a href="index.php">Back to Search</a>
    <div id="results">
        <?php if (!empty(\$results)): ?>
            <?php foreach (\$results as \$item): ?>
                <div class="result-item">
                    <h3>ID: <?php echo htmlspecialchars(\$item['id']); ?>, Name: <?php echo htmlspecialchars(\$item['name']); ?></h3>
                    <p>Description: <?php echo htmlspecialchars(\$item['description']); ?></p>
                    <?php if (!empty(\$item['image_url'])): ?>
                        <img src="<?php echo htmlspecialchars(\$item['image_url']); ?>" alt="Image" width="100">
                    <?php else: ?>
                        <p>No image available</p>
                    <?php endif; ?>
                </div>
            <?php endforeach; ?>
        <?php else: ?>
            <p>No results found.</p>
        <?php endif; ?>
    </div>
</body>
</html>
"@ | Out-File "$projectDir\search.php"

# Step 4: Create styles.css
Write-Host "Creating styles.css..."
@"
body {
    font-family: Arial, sans-serif;
    margin: 20px;
}

h1 {
    color: #333;
}

form {
    margin-bottom: 20px;
}

label {
    display: block;
    margin-top: 10px;
}

input {
    width: 100%;
    padding: 8px;
    margin-top: 5px;
}

button {
    margin-top: 20px;
    padding: 10px 20px;
    background-color: #007bff;
    color: white;
    border: none;
    cursor: pointer;
}

button:hover {
    background-color: #0056b3;
}

.result-item {
    border: 1px solid #ddd;
    padding: 10px;
    margin-bottom: 10px;
}

.result-item img {
    margin-top: 10px;
}
"@ | Out-File "$projectDir\styles.css"

Write-Host "Setup complete! Files created in: $projectDir"