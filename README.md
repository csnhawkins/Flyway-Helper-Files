# Flyway Helper Files

A collection of example scripts and best practices for getting started with Redgate Flyway CLI. These scripts provide practical, ready-to-use examples for both **Migrations-based** and **State-based** deployment methodologies to help you quickly onboard and learn Flyway best practices.

## 📚 Overview

This repository contains example PowerShell and Bash scripts that demonstrate how to use Flyway CLI effectively. Whether you're new to Flyway or looking to standardize your database deployment workflows, these examples will help you understand:

- How to structure Flyway commands
- Best practices for variable management
- Common deployment patterns and workflows
- Cross-platform compatibility (Windows PowerShell & Linux Bash)

## 🚀 Deployment Methodologies

Flyway supports two primary deployment approaches, and this repository provides examples for both:

### Migrations-based Deployment
**What it is:** A version-controlled approach where database changes are defined as sequential migration scripts (V1__Initial.sql, V2__AddTable.sql, etc.). Each script runs once and is tracked in Flyway's schema history table.

**When to use:**
- New projects or greenfield development
- Teams comfortable with version-controlled, sequential changes
- Applications requiring strict change tracking and rollback capabilities
- DevOps environments with automated CI/CD pipelines

**Example scripts location:** `CLI/Migrations/`

### State-based Deployment
**What it is:** A model-driven approach where you define your desired database state (schema model), and Flyway generates the necessary migration scripts to reach that state from the current database.

**When to use:**
- Existing databases with complex schemas
- Teams preferring to work with the desired end-state rather than incremental changes
- Situations requiring automatic conflict resolution
- Environments where multiple developers modify the same database objects

## 🛠️ Script Workflow Examples

### Migrations-based Workflow
1. **00_Diff** - Compare environments to identify changes
2. **01_Model** - Generate schema model for state comparison
3. **02_Generate** - Create migration scripts from differences
4. **03_Migrate** - Deploy migrations to target environment
5. **04_Undo** - Rollback migrations if needed

### State-based Workflow
1. **00_Diff** - Compare current state with desired model
2. **01_Model** - Update or validate schema model
3. **02_Prepare** - Generate deployment script with dry-run
4. **03_Deploy** - Execute deployment script against target

## 🔧 Getting Started

### Prerequisites
- [Flyway CLI](https://flywaydb.org/download) installed and accessible in your PATH
- Access to your target database(s)
- PowerShell (Windows) or Bash (Linux) environment

### Using the Scripts

1. **Choose your deployment methodology** (Migrations or State-based)
2. **Select your database platform** (MSSQL or PostgreSQL)
3. **Pick your operating system** (Windows PowerShell or Linux Bash)
4. **Customize the variables** in each script:
   - Database connection strings
   - Working directories
   - Environment names
   - Credentials (consider using environment variables for security)

### Important Variables to Configure

Each script contains clearly marked variables that you'll need to customize:

```powershell
# Example PowerShell variables
$WORKING_DIRECTORY = "C:\Your\Project\Path"
$TARGET_ENVIRONMENT = "development"
$TARGET_ENVIRONMENT_USERNAME = "your_username"
$TARGET_ENVIRONMENT_PASSWORD = "your_password"  # Consider using secure methods
```

```bash
# Example Bash variables
WORKING_DIRECTORY="/path/to/your/project"
TARGET_ENVIRONMENT="development"
TARGET_ENVIRONMENT_USERNAME="your_username"
TARGET_ENVIRONMENT_PASSWORD="your_password"  # Consider using secure methods
```

## 🔐 Security Best Practices

⚠️ **Important:** These example scripts contain placeholder credentials for demonstration purposes. In production environments:

- Use environment variables for sensitive data
- Implement secure credential management (Azure Key Vault, AWS Secrets Manager, etc.)
- Consider using integrated authentication where possible
- Never commit credentials to source control

Example secure variable usage:
```powershell
$TARGET_ENVIRONMENT_PASSWORD = $env:DB_PASSWORD
```

## 🤝 Contributing

These examples are designed to be educational and demonstrate best practices. If you have improvements or additional examples that would help others learn Flyway, contributions are welcome!

## 📄 License

This project is licensed under the terms included in the LICENSE file.

---
