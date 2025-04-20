## Built-in snakemake workflows

Refer to the main README for usage instructions. Folder hierarchy:

- `bin`: contains user-facing executables (in PATH).
- `config_templates`: contains template configuration files for certain workflows.
- `include`: contains base rule files shared by multiple workflows.
- `smkWorkflow.py`: Helper script for calling snakemake to run workflows.
- Each workflow has one `Snakefile_<WORKFLOW>` and a paired instruction file `<WORKFLOW>.txt`.