# Flyway Helper Files

A comprehensive collection of scripts, examples, and utilities to help you get up and running quickly with Redgate Flyway CLI. Whether you're just starting with Flyway or looking to streamline your database deployment workflows, these ready-to-use resources provide everything you need to succeed.

## 📚 What's Included

This repository provides practical, production-ready resources including:

- **🚀 CLI Installation Scripts** - Automated setup for Flyway CLI on Windows and Linux
- **📝 Deployment Workflow Examples** - Complete script collections for both Migrations-based and State-based approaches
- **🎯 Example Database Schemas** - Ready-to-use Chinook sample databases (MSSQL, MySQL, Oracle, PostgreSQL)
- **🔧 Configuration Utilities** - Custom filter examples for Oracle and PostgreSQL
- **🔐 Licensing Tools** - Offline permit decoding and validation utilities
- **⚙️ Automation Scripts** - RunAll workflows for streamlined pipeline demonstrations

All scripts are designed to be easy to read, understand, and customize for your specific needs.

## �️ Repository Structure

### `/CLI/Install/`
Automated installation scripts for Flyway CLI:
- **Windows (PowerShell):** `Flyway_DownloadAndInstallCLI.ps1` - Downloads and installs the latest or specified Flyway version
- **Linux (Bash):** `Flyway_DownloadAndInstallCLI_Unix.sh` - Smart installer with CI/CD detection, supports both sudo and user-space installations

### `/CLI/Migrations/`
Complete workflow scripts for Migrations-based deployments (MSSQL, PostgreSQL):
- Cross-platform support: Windows PowerShell, Windows CMD (.bat), and Linux Bash
- Includes automation scripts (99_RunAll) for streamlined execution
- Optional steps for Snapshot and Check commands

### `/CLI/State/`
Complete workflow scripts for State-based deployments (MSSQL):
- Cross-platform support: Windows PowerShell, Windows CMD (.bat), and Linux Bash  
- Includes automation scripts (99_RunAll) with pipeline approval gates
- Enhanced Check command for drift detection and compliance reporting

### `/CLI/Filter/`
Custom filter configurations for excluding objects from Flyway operations:
- **Oracle:** Schema Compare filter examples (`.scpf`)
- **PostgreSQL:** Redgate filter format examples (`.rgf`)

### `/CLI/Licensing/Offline Permit/`
Utilities for air-gapped/offline environments:
- JWT decoder scripts for validating offline license permits
- Cross-platform: PowerShell and Bash versions
- Comprehensive documentation and troubleshooting guides

### `/Example Databases/Chinook/`
Ready-to-use sample database schemas for testing and learning:
- **Platforms:** MSSQL, MySQL, Oracle, PostgreSQL
- **Formats:** Full database scripts and schema-only versions
- Perfect for practicing Flyway workflows

## �🚀 Deployment Methodologies

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
1. **00_Diff** - Compare environments to identify changes and create artifact
2. **01_Model** - Generate schema model for state comparison
3. **02_Generate** - Create versioned and undo migration scripts from differences
4. **03a_Snapshot** - Create schema snapshot before migration (optional)
5. **03b_Check** - Analyze migrations, detect drift, and generate reports (optional)
6. **04_Migrate** - Deploy migrations to target environment
7. **05_Undo** - Rollback last migration if needed (optional)
8. **99_RunAll** - Automated workflow execution with approval gates for demonstrations

### State-based Workflow
1. **00_Diff** - Compare current Development state with project Schema Model and create artifact
2. **01_Model** - Update or validate schema model from artifact
3. **02_Prepare** - Generate deployment and undo scripts
4. **03a_Snapshot** - Create schema snapshot for point-in-time recovery (optional)
5. **03b_Check** - Analyze changes, detect drift, and generate compliance reports (optional)
6. **04_Deploy** - Execute deployment script against target with optional snapshot
7. **99_RunAll** - Automated workflow with pipeline-style approval gates after Check step

### RunAll Automation Scripts

Both workflows include **99_RunAll** scripts designed for:
- **Learning & Training:** Execute entire workflows step-by-step with interactive prompts
- **PoC Demonstrations:** Simulate real CI/CD pipeline experiences with approval gates
- **Testing:** Quickly validate workflow changes across all steps

The RunAll scripts feature:
- Interactive mode: Prompts before each step
- Automatic mode: Run all steps without prompts (`-All` parameter)
- **Pipeline Approval Gates** (after Check step): Review compliance reports and approve/reject deployments
- Automatic HTML report opening for easy review

### Enhanced State-based Capabilities

The State-based workflow now includes advanced features for production-ready deployments:

- **Check Command (03):** Performs comprehensive analysis including:
  - Change detection between schema model and target database
  - Code quality analysis and rule violations
  - Drift detection to identify unauthorized changes
  - Generates detailed HTML reports for compliance and auditing

- **Deploy with Snapshots (04):** Enhanced deployment features:
  - Executes deployment scripts with full transaction support
  - Optional automatic schema snapshots before deployment
  - Rollback capabilities using generated undo scripts

- **Snapshot Management (05):** Point-in-time recovery support:
  - Creates timestamped schema snapshots
  - Stores snapshots in Flyway's snapshot history table
  - Enables quick rollback to known good states

## 🔧 Getting Started

### Quick Start: Install Flyway CLI

Before using the workflow scripts, install Flyway CLI using the provided installers:

**Windows (PowerShell):**
```powershell
.\CLI\Install\Flyway_DownloadAndInstallCLI.ps1
```

**Linux/Unix (Bash):**
```bash
./CLI/Install/Flyway_DownloadAndInstallCLI_Unix.sh
```

Both installers support:
- Latest version detection or specific version installation
- CI/CD pipeline compatibility (GitHub Actions, GitLab CI, etc.)
- Automatic PATH configuration
- Cleanup of old versions

For CI/CD environments, the Linux installer automatically detects the environment and adjusts installation paths and permissions accordingly.

### Using the Workflow Scripts

1. **Choose your deployment methodology** (Migrations or State-based)
2. **Select your database platform** (MSSQL or PostgreSQL)
3. **Pick your operating system** (Windows PowerShell, Windows CMD, or Linux Bash)
4. **Customize the variables** in each script:
   - Database connection strings
   - Working directories (e.g., `C:\FlywayProjects\State\MSSQL\Chinook`)
   - Environment names
   - Credentials (consider using environment variables for security)

**Note:** For Windows environments where PowerShell is restricted or blocked, CMD batch file equivalents (.bat) are available in the `/CMD/` subfolders within each Windows script directory.

### Testing with Example Databases

Get started quickly using the provided Chinook database schemas:

1. Navigate to `/Example Databases/Chinook/`
2. Choose your database platform (MSSQL, MySQL, Oracle, PostgreSQL)
3. Run the appropriate creation script:
   - `Database_Creation-Chinook_[Platform]-Full.sql` - Complete database with data
   - `Database_Creation-Chinook_[Platform]-SchemaOnly.sql` - Schema structure only
4. Update the workflow scripts to point to your Chinook database
5. Execute the workflow scripts to see Flyway in action

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
- For PostgreSQL scripts, passwords are prompted at runtime for enhanced security

Example secure variable usage:
```powershell
$TARGET_ENVIRONMENT_PASSWORD = $env:DB_PASSWORD
```

## 🔍 Advanced Features

### Custom Filters
Use the filter examples in `/CLI/Filter/` to exclude specific database objects from Flyway operations:
- Temporary tables, system objects, or legacy schemas
- Objects managed by other tools or processes
- Platform-specific filtering rules (Oracle .scpf, PostgreSQL .rgf formats)

### Offline Permit Validation
For air-gapped or restricted environments, use the offline permit tools:
- Decode and validate Flyway license permits without internet connectivity
- Verify expiration dates, enabled features, and license details
- Cross-platform support with detailed error handling

Located in `/CLI/Licensing/Offline Permit/` with comprehensive README documentation.

## 📖 Learning Resources

### Recommended Learning Path

1. **Start with Installation:** Run the appropriate CLI installer for your platform
2. **Explore Example Databases:** Deploy the Chinook schema to a test database
3. **Try State-based Workflow:** Ideal for understanding the model-driven approach
4. **Progress to Migrations:** Learn version-controlled, sequential change management
5. **Use RunAll Scripts:** Experience complete workflows with approval gates
6. **Customize for Your Needs:** Adapt scripts to your project structure and requirements

### Understanding the Scripts

Each script includes:
- Clear variable sections with inline comments
- Descriptive headers with version information
- Step-by-step Flyway command execution
- Minimal code for easy reading and trust

Scripts are intentionally kept simple and readable so users can understand exactly what's happening and feel confident using them in their environments.

## 🤝 Contributing

These examples are designed to be educational and demonstrate best practices. If you have improvements or additional examples that would help others learn Flyway, contributions are welcome!

## 📄 License

This project is licensed under the terms included in the LICENSE file.

---
