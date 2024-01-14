module Archive

export ArchiveSpeciesCreator, create_species, update_species!, update_archive!
export add_individuals_to_archive!, update_active_archive_individuals!, update_population!

import ....Interfaces: get_individuals, create_species, update_species!
import ....Interfaces: convert_from_dictionary
using ....Abstract
using ....Interfaces

using StatsBase: sample
using ...Species.Archive: ArchiveSpecies
using ...Evaluators.ScalarFitness
using ...Evaluators.NSGAII

Base.@kwdef struct ArchiveSpeciesCreator <: SpeciesCreator
    n_population::Int
    n_parents::Int
    n_children::Int
    n_elites::Int
    n_archive::Int
    archive_interval::Int
    max_archive_length::Int
    max_archive_matches::Int
end

function create_species(::ArchiveSpeciesCreator, id::String, state::State)
    population = create_individuals(state.individual_creator, state)
    species = ArchiveSpecies(id, population)
    return species
end

function add_individuals_to_archive!(
    species_creator::ArchiveSpeciesCreator,
    species::ArchiveSpecies,
    candidates::Vector{<:Individual},
)
    candidate_ids = Set([candidate.id for candidate in candidates])

    filter!(individual -> individual.id ∉ candidate_ids, species.archive)
    append!(species.archive, candidates)

    while length(species.archive) > species_creator.max_archive_length
        # eject the first elements to maintain size
        deleteat!(species.archive, 1)
    end
end

function add_individuals_to_archive!(
    species_creator::ArchiveSpeciesCreator, 
    species::ArchiveSpecies, 
    evaluation::NSGAIIEvaluation,
)
    best_records = filter(
        record -> record.rank == 1 && isinf(record.crowding), evaluation.records
    )
    best_ids = [record.id for record in best_records]
    best_individuals = [
        individual for individual in species.population if individual.id in best_ids
    ]
    add_individuals_to_archive!(species_creator, species, best_individuals)
end

function add_individuals_to_archive!(
    species_creator::ArchiveSpeciesCreator, 
    species::ArchiveSpecies, 
    evaluation::ScalarFitnessEvaluation,
)
    best_records = evaluation.records[1:species_creator.n_archive]
    best_ids = [record.id for record in best_records]
    best_individuals = [
        individual for individual in species.population if individual.id in best_ids
    ]
    add_individuals_to_archive!(species_creator, species, best_individuals)
end


function update_active_archive_individuals!(
    species_creator::ArchiveSpeciesCreator, species::ArchiveSpecies, state::State
)
    if species_creator.max_archive_matches > 0
        candidates = [
            individual for individual in species.archive if individual ∉ species.population
        ]
        n_archive_matches = min(species_creator.max_archive_matches, length(candidates))
        new_archive_individuals = sample(state.rng, candidates, n_archive_matches)
        empty!(species.active_archive_individuals)
        append!(species.active_archive_individuals, new_archive_individuals)
        println(
            "n_archive_matches_$(species.id) = ", n_archive_matches, 
            ", length(new_archive) = ", length(species.archive)
        )
    end
end

function update_archive!(
    species_creator::ArchiveSpeciesCreator, 
    species::ArchiveSpecies, 
    evaluation::Evaluation,
    state::State
)
    using_archive = species_creator.archive_interval > 0
    is_archive_interval = state.generation % species_creator.archive_interval == 0
    if using_archive && is_archive_interval
        add_individuals_to_archive!(species_creator, species, evaluation)
        update_active_archive_individuals!(species_creator, species, state)
    end
end

function update_population!(
    species_creator::ArchiveSpeciesCreator, 
    species::ArchiveSpecies, 
    evaluation::Evaluation,
    state::State
) 
    ordered_ids = [record.id for record in evaluation.records]
    parent_ids = Set(ordered_ids[1:species_creator.n_parents])
    parent_set = [individual for individual in species.population if individual.id in parent_ids]
    parents = select(state.selector, parent_set, evaluation, state)
    new_children = recombine(state.recombiner, parents, state)
    mutate!(state.mutator, new_children, state)
    if species_creator.n_elites > 0
        elite_ids = [record.id for record in evaluation.records[1:species_creator.n_elites]]
        elites = [individual for individual in species.population if individual.id in elite_ids]
        new_population = [elites ; new_children]
    else
        new_population = new_children
    end
    empty!(species.population)
    append!(species.population, new_population)
end

function update_species!(
    species_creator::ArchiveSpeciesCreator, 
    species::ArchiveSpecies, 
    evaluation::Evaluation,
    state::State
) 
    n_population_before = length(species.population)
    update_archive!(species_creator, species, evaluation, state)
    update_population!(species_creator, species, evaluation, state)
    n_population_after = length(species.population)
    if n_population_after != n_population_before
        error("Population size changed from $n_population_before to $n_population_after")
    end
end

function convert_from_dictionary(
    ::ArchiveSpeciesCreator, 
    individual_creator::IndividualCreator,
    genotype_creator::GenotypeCreator,
    phenotype_creator::PhenotypeCreator,
    dict::Dict
)
    id = dict["ID"]
    population = convert_from_dictionary(
        individual_creator, genotype_creator, phenotype_creator, dict["P"]
    )
    archive = convert_from_dictionary(
        individual_creator, genotype_creator, phenotype_creator, dict["A"]
    )
    active_ids = Set(dict["A_IDS"])
    active_individuals = [
        individual for individual in archive if individual.id in active_ids
    ]
    species = ArchiveSpecies(id, population, archive, active_individuals)
    return species

end


end