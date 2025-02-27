# Setup Script for License Search App (PowerShell)

# Step 1: Check if Node.js is installed
Write-Host "Checking if Node.js is installed..."
if (-not (Get-Command "node" -ErrorAction SilentlyContinue)) {
    Write-Host "Node.js is not installed. Downloading and installing Node.js..."
    $nodeInstallerUrl = "https://nodejs.org/dist/v18.16.0/node-v18.16.0-x64.msi"
    $nodeInstallerPath = "$env:TEMP\node-installer.msi"

    # Download Node.js installer
    Invoke-WebRequest -Uri $nodeInstallerUrl -OutFile $nodeInstallerPath

    # Install Node.js silently
    Start-Process msiexec.exe -ArgumentList "/i $nodeInstallerPath /quiet /norestart" -Wait

    # Clean up the installer
    Remove-Item $nodeInstallerPath

    Write-Host "Node.js installed successfully."
} else {
    Write-Host "Node.js is already installed."
}

# Step 2: Create the project directory
Write-Host "Creating project directory..."
$projectDir = "$env:USERPROFILE\license-search-app"
if (-not (Test-Path $projectDir)) {
    New-Item -ItemType Directory -Path $projectDir | Out-Null
} else {
    Write-Host "Project directory already exists."
}
Set-Location $projectDir

# Step 3: Initialize the Node.js project
Write-Host "Initializing Node.js project..."
npm init -y
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to initialize Node.js project."
    exit
}

# Step 4: Install required packages
Write-Host "Installing required packages..."
npm install express axios
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to install required packages."
    exit
}

# Step 5: Create the application files
Write-Host "Creating application files..."

# Create app.js
@"
const express = require("express");
const axios = require("axios");
const app = express();
const port = 3000;

app.use(express.urlencoded({ extended: true }));
app.use(express.static("public"));

app.get("/", (req, res) => {
  res.sendFile(__dirname + "/views/index.html");
});

app.post("/search", async (req, res) => {
  const {
    sections,
    organizations,
    lname,
    uname,
    province,
    township,
    from,
    to,
  } = req.body;

  const sectionList = sections ? sections.split(",") : [];
  const organizationList = organizations ? organizations.split(",") : [];
  const lnameList = lname ? lname.split(",") : [];
  const unameList = uname ? uname.split(",") : [];
  const provinceList = province ? province.split(",") : [];
  const townshipList = township ? township.split(",") : [];

  let results = [];

  for (const section of sectionList) {
    for (const organization of organizationList) {
      for (const lname of lnameList) {
        for (const uname of unameList) {
          for (const province of provinceList) {
            for (const township of townshipList) {
              const params = {
                per_page: 210,
                page: 1,
                sections: section.trim(),
                organizations: organization.trim(),
                lname: lname.trim(),
                uname: uname.trim(),
                province: province.trim(),
                township: township.trim(),
                from: from,
                to: to,
              };

              try {
                const response = await axios.get(
                  "https://qr.mojavez.ir/api/licenses",
                  { params }
                );
                if (response.status === 200) {
                  results = results.concat(response.data);
                }
              } catch (error) {
                console.error("Error fetching data:", error);
              }
            }
          }
        }
      }
    }
  }

  res.send(
    \`<!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Search Results</title>
      <link rel="stylesheet" href="/styles.css">
    </head>
    <body>
      <h1>Search Results</h1>
      <a href="/">Back to Search</a>
      <div id="results">
        \${results
          .map(
            (item) => \`
          <div class="result-item">
            <h3>ID: \${item.id}, Name: \${item.name}</h3>
            <p>Description: \${item.description}</p>
            \${item.image_url
              ? \`<img src="\${item.image_url}" alt="Image" width="100">\`
              : "<p>No image available</p>"}
          </div>
        \`
          )
          .join("")}
      </div>
    </body>
    </html>\`
  );
});

app.listen(port, () => {
  console.log(\`Server running at http://localhost:\${port}\`);
});
"@ | Out-File "$projectDir\app.js"

# Create views/index.html
$viewsDir = "$projectDir\views"
if (-not (Test-Path $viewsDir)) {
    New-Item -ItemType Directory -Path $viewsDir | Out-Null
}
@"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>License Search App</title>
  <link rel="stylesheet" href="/styles.css">
</head>
<body>
  <h1>License Search App</h1>
  <form action="/search" method="POST">
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
"@ | Out-File "$viewsDir\index.html"

# Create public/styles.css
$publicDir = "$projectDir\public"
if (-not (Test-Path $publicDir)) {
    New-Item -ItemType Directory -Path $publicDir | Out-Null
}
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
"@ | Out-File "$publicDir\styles.css"

# Step 6: Run the application
Write-Host "Starting the application..."
Start-Process "http://localhost:3000"
node app.js
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass