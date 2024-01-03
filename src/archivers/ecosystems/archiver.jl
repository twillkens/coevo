export EcosystemArchiver, MigrationArchiver

import ...Archivers: archive!, load

using HDF5: h5open, File
using ...Archivers: Archiver
using ...Individuals: Individual
using ...Individuals.Modes: ModesIndividual
using ...Individuals.Basic: BasicIndividual
using ...Species.Modes: ModesSpecies, get_population, get_pruned, get_pruned_fitnesses, get_elites
using ...Species.Basic: BasicSpecies
using ...Abstract.States: get_ecosystem, get_generation, State
using ...CoEvo.Ecosystems: Ecosystem

struct EcosystemArchiver <: Archiver
    archive_interval::Int
    archive_directory::String
end

function archive!(file::File, base_path::String, individual::BasicIndividual)
    genotype_path = "$base_path/genotype"
    archive!(file, genotype_path, individual.genotype)
    file["$base_path/parent_ids"] = individual.parent_ids
end

function archive!(file::File, base_path::String, individual::ModesIndividual)
    file["$base_path/parent_id"] = individual.parent_id
    file["$base_path/tag"] = individual.tag
    file["$base_path/age"] = individual.age
    archive!(file, "$base_path/genotype", individual.genotype)
end

function archive!(file::File, base_path::String, individuals::Vector{<:Individual})
    for individual in individuals
        individual_path = "$base_path/$(individual.id)"
        archive!(file, individual_path, individual)
    end
end

function archive!(file::File, base_path::String, species::ModesSpecies)
    population = get_population(species)
    pruned = get_pruned(species)
    pruned_fitness_ids = [individual.id for individual in pruned]
    pruned_fitnesses = get_pruned_fitnesses(species)
    elites = get_elites(species)
    n_population = length(population)
    n_pruned = length(pruned)
    n_elites = length(elites)
    println("archiving $(species.id): $n_population population, $n_pruned pruned, and $n_elites elites")
    #println("archived_pop_ids: ", [individual.id for individual in population])
    archive!(file, "$base_path/population", population)
    archive!(file, "$base_path/pruned", pruned)
    file["$base_path/pruned_fitness_ids"] = pruned_fitness_ids
    file["$base_path/pruned_fitnesses"] = pruned_fitnesses
    archive!(file, "$base_path/elites", elites)
    #archive!(file, "$base_path/population", get_population(species))
    #archive!(file, "$base_path/pruned", get_pruned(species))
    #file["$base_path/pruned_fitnesses"] = get_pruned_fitnesses(species)
    #archive!(file, "$base_path/elites", get_elites(species))
end

function archive!(file::File, base_path::String, species::BasicSpecies)
    archive!(file, "$base_path/population", species.population)
    archive!(file, "$base_path/children", species.children)
end

function archive!(file::File, base_path::String, ecosystem::Ecosystem)
    for species in ecosystem.species
        species_path = "$base_path/$(species.id)"
        archive!(file, species_path, species)
    end
end

function archive!(archiver::EcosystemArchiver, state::State)
    do_not_archive = archiver.archive_interval == 0
    is_archive_interval = get_generation(state) == 1 ||
        get_generation(state) % archiver.archive_interval == 0
    if do_not_archive || !is_archive_interval
        return
    end
    ecosystem = get_ecosystem(state)
    generation = get_generation(state)
    archive_path = "$(archiver.archive_directory)/generations/$generation.h5"
    file = h5open(archive_path, "r+")
    base_path = "ecosystem"
    archive!(file, base_path, ecosystem)
    file["valid"] = true
    close(file)
    flush(stdout)
end

struct MigrationArchiver <: Archiver
    archive_interval::Int
    archive_directory::String
end

using ...Abstract.States: get_all_species, get_evaluations

function archive!(archiver::MigrationArchiver, state::State)
    do_not_archive = archiver.archive_interval == 0 || get_generation(state) == 1
    is_archive_interval = (get_generation(state) + 1) % archiver.archive_interval == 0
    #println(get_generation(state), is_archive_interval)
    if do_not_archive || !is_archive_interval
        return
    end
    generation = get_generation(state)
    #println("archiving generation $generation")
    archive_path = "$(archiver.archive_directory)/generations/$generation.h5"
    file = h5open(archive_path, "w")
    for (species, evaluation) in zip(get_all_species(state), get_evaluations(state))
        migration_ids = [record.id for record in evaluation.records[1:10]]
        summaries = [(record.id, record.rank, record.crowding) for record in evaluation.records[1:10]]
        println("archiving migration individuals: $summaries")
        migration_individuals = [
            individual for individual in get_population(species) 
            if individual.id in migration_ids
        ]
        for individual in migration_individuals
            individual_path = "$(species.id)/$(individual.id)"
            archive!(file, individual_path, individual)
        end
    end
    file["valid"] = true
    close(file)
    flush(stdout)
end