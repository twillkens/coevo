using CoEvo.Concrete.Configurations.CircleExperiment
using CoEvo.Concrete.States.Basic
using CoEvo.Abstract
using CoEvo.Interfaces
using CoEvo.Utilities
using CoEvo.Concrete.Archivers.Ecosystems: EcosystemArchiver
using HDF5
using Profile
using PProf

ENV["COEVO_TRIAL_DIR"] = "trials"

rm("trials/1", force = true, recursive = true)
file = open("test/circle/debug.out", "w")
redirect_stdout(file)
#configuration = CircleExperimentConfiguration()
configuration = CircleExperimentConfiguration(
    n_generations = 20_000, checkpoint_interval = 100, seed = 777, species = "small_archive",
    n_workers_per_ecosystem = 5
)

state = evolve(configuration)
close(file)

function benchmark()
    ENV["COEVO_TRIAL_DIR"] = "trials"

    rm("trials/1", force = true, recursive = true)
    file = open("test/circle/debug.out", "w")
    redirect_stdout(file)
    #configuration = CircleExperimentConfiguration()
    Profile.Allocs.clear()
    configuration = CircleExperimentConfiguration(
        n_generations = 50, checkpoint_interval = 5, seed = 777, species = "small_archive",
        n_workers_per_ecosystem = 5
    )

    Profile.Allocs.@profile state = evolve(configuration)
    close(file)

    rm("trials/1", force = true, recursive = true)
    file = open("test/circle/debug.out", "w")
    redirect_stdout(file)
    Profile.Allocs.clear()
    configuration = CircleExperimentConfiguration(
        n_generations = 500, checkpoint_interval = 100, seed = 777, species = "small_archive",
        n_workers_per_ecosystem = 5
    )

    Profile.Allocs.@profile state = evolve(configuration)
    close(file)
    PProf.Allocs.pprof()
end

#benchmark()

#rm("trials/1", force = true, recursive = true)
#
#file = open("trials/2.out", "w")
#redirect_stdout(file)
#state = evolve(configuration)
#println("RNGRNG_AFTER = $(state.rng.state)")
#close(file)
#
#rm("trials/1", force = true, recursive = true)
#
#file = open("trials/3.out", "w")
#redirect_stdout(file)
#state = evolve(configuration, 5)
#println("\n CRASH")
#state = evolve(configuration)
#println("RNGRNG_AFTER_CRASH = $(state.rng.state)")
#close(file)



##dict = convert_to_dict(state.ecosystem)
##ecosystem = create_from_dict(state.reproducer.ecosystem_creator, dict, state)
##println(ecosystem)
#
##archiver = EcosystemArchiver()
#
##archive!(archiver, state)
#archive_directory = configuration.archive_directory
#
#f = h5open("$archive_directory/generations/1.h5", "r")
#
#state_dict = load_dict_from_hdf5(f, "/")
#
#state = create_from_dict(BasicEvolutionaryStateCreator(), state_dict, configuration)
#
#println("rng_state = $(state.rng.state)")
#
#evolve!(state, 200)


#println(state)