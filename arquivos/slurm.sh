#!/bin/bash
# Simulador básico de SLURM para prática local

SLURM_JOBS_DIR="$HOME/slurm_simulator/jobs"
SLURM_LOGS_DIR="$HOME/slurm_simulator/logs"
mkdir -p "$SLURM_JOBS_DIR" "$SLURM_LOGS_DIR"

case $1 in
    "sbatch")
        JOB_ID=$(date +%s)
        JOB_FILE=$2
        cp "$JOB_FILE" "$SLURM_JOBS_DIR/job_$JOB_ID.sh"
        echo "Submitted batch job $JOB_ID"
        
        # Simular execução em background
        bash "$JOB_FILE" > "$SLURM_LOGS_DIR/job_$JOB_ID.out" 2> "$SLURM_LOGS_DIR/job_$JOB_ID.err" &
        echo $! > "$SLURM_JOBS_DIR/job_$JOB_ID.pid"
        ;;
        
    "squeue")
        echo "JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)"
        for job_file in "$SLURM_JOBS_DIR"/*.pid; do
            if [ -f "$job_file" ]; then
                JOB_ID=$(basename "$job_file" | cut -d_ -f2 | cut -d. -f1)
                echo "$JOB_ID     debug     job_$JOB_ID   $USER  R        0:01      1 localhost"
            fi
        done
        ;;
        
    "scancel")
        JOB_ID=$2
        if [ -f "$SLURM_JOBS_DIR/job_$JOB_ID.pid" ]; then
            kill $(cat "$SLURM_JOBS_DIR/job_$JOB_ID.pid") 2>/dev/null
            rm -f "$SLURM_JOBS_DIR/job_$JOB_ID.pid"
            echo "Cancelled job $JOB_ID"
        else
            echo "Error: Job $JOB_ID not found"
        fi
        ;;
        
    *)
        echo "Comandos disponíveis:"
        echo "  ./simulate_slurm.sh sbatch <script>"
        echo "  ./simulate_slurm.sh squeue"
        echo "  ./simulate_slurm.sh scancel <jobid>"
        ;;
