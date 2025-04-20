import sys
import subprocess
from pathlib import Path

def get_workflows(script_dir):
    """Find available workflows and their documentation"""
    workflows = {}
    for sf in script_dir.glob("Snakefile_*"):
        workflow_name = sf.name.split("_", 1)[1]
        doc_file = script_dir / f"{workflow_name}.txt"
        workflows[workflow_name] = {
            "snakefile": sf,
            "doc": doc_file.read_text() if doc_file.exists() 
                   else "No documentation available"
        }
    return workflows

def print_help(workflows):
    """Display available workflows and usage information"""
    print("Available Snakemake workflows:\n")
    for name, info in workflows.items():
        print(f"Workflow: {name}")
        print(f"Documentation:\n{info['doc']}\n{'='*40}\n")
    
    print("Usage:")
    print(f"  {sys.argv[0]} [WORKFLOW-NAME] [SNAKEMAKE-OPTIONS]")
    print("\nExamples:")
    print(f"  {sys.argv[0]}               # List all workflows")
    print(f"  {sys.argv[0]} align        # Run 'align' workflow")
    print(f"  {sys.argv[0]} qc --cores 4 # Run QC workflow with 4 cores")

def main():
    #script_dir = Path(__file__).parent.resolve() # resolve script folder
    script_dir = Path("/usr/local/bin/snakemakeWorkflows")
    workflows = get_workflows(script_dir)
    
    if len(sys.argv) == 1:
        print_help(workflows)
        return
    
    workflow_name = sys.argv[1]
    if workflow_name not in workflows:
        print(f"Error: Unknown workflow '{workflow_name}'")
        print("Available workflows:", ", ".join(workflows.keys()))
        sys.exit(1)
    
    snakefile = workflows[workflow_name]["snakefile"]
    cmd = [
        "snakemake",
        "--snakefile", str(snakefile),
        *sys.argv[2:]  # Forward remaining parameters
    ]
    
    try:
        subprocess.run(cmd, check=True)
    except subprocess.CalledProcessError as e:
        print(f"\nError: Workflow execution failed (exit code {e.returncode})")
        sys.exit(e.returncode)
    except KeyboardInterrupt:
        print("\nWorkflow execution interrupted by user")
        sys.exit(130)

if __name__ == "__main__":
    main()
