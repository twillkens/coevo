using Base: pipeline, run

const INTERACTION_ALIAS_DICT = Dict(
    "ctrl" => "ctl",
    "cooperative" => "coop",
    "competitive" => "comp",
    "mixed" => "mix",
)

const REPRODUCER_ALIAS_DICT = Dict(
    "roulette" => "R",
    "disco" => "D",
)

const N_SPECIES_ALIAS_DICT = Dict(
    2 => "two",
    3 => "three",
)

function make_job_name(n_species::Int, topology::String, reproducer::String)
    interaction_alias = INTERACTION_ALIAS_DICT[topology]
    reproducer_alias = REPRODUCER_ALIAS_DICT[reproducer]
    job_name = string(n_species, interaction_alias, reproducer_alias)
    return job_name
end

function generate_slurm_script(
    n_species::Int, 
    interaction::String, 
    reproducer::String; 
    n_generations::Int = 10000,
    n_workers::Int = 11,
    n_trials::Int = 20,
    user::String = "twillkens"
)
    job_name = make_job_name(n_species, interaction, reproducer)
    filename = "$job_name.slurm"
    topology = N_SPECIES_ALIAS_DICT[n_species] * "_" * interaction

    # Generate the script
    script = """
    #!/bin/bash

    #SBATCH --job-name=$job_name
    #SBATCH --partition=guest-compute
    #SBATCH --account=guest
    #SBATCH --qos=low
    #SBATCH --array=1-$n_trials%$n_trials
    #SBATCH --ntasks=1
    #SBATCH --cpus-per-task=$n_workers
    #SBATCH --output=logs/$(job_name)_%A_%a.out
    #SBATCH --error=logs/$(job_name)_%A_%a.err

    # Load Julia module or set up the environment
    module purge
    module load gnu7/7.3.0 anaconda/5.2_py2 openmpi3/3.1.0
    source /home/$user/.bashrc
    conda activate "/home/$user/.conda/envs/coevo"

    # Run script
    srun julia --project=. run/prediction_game/run.jl \\
            --trial \$SLURM_ARRAY_TASK_ID \\
            --n_workers \$SLURM_CPUS_PER_TASK \\
            --game continuous_prediction_game \\
            --topology $topology \\
            --report deploy \\
            --reproducer $reproducer \\
            --n_generations $n_generations
    """

    # Write the script to a file
    open(filename, "w") do file
        write(file, script)
    end

    # Submit the script using sbatch
end

# Example usage
