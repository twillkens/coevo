module Archive

export ArchiveSpeciesCreator, create_species, update_species!, update_archive!
export add_individuals_to_archive!, update_active_archive_individuals!, update_population!

import ....Interfaces: get_individuals, create_species, update_species!
import ....Interfaces: create_from_dict
using ....Abstract
using ....Interfaces

using StatsBase: sample
using ...Species.Archive: ArchiveSpecies
using ...Evaluators.ScalarFitness
using ...Evaluators.NSGAII
using ...Evaluators.Distinction: DistinctionEvaluation

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

function create_archive_weights(length_archive::Int; rev::Bool = false)
    # Generate weights: higher for earlier indices, lower for later indices
    weights = collect(1:length_archive)
    if rev
        weights = reverse(weights)
    end
    
    # Normalize weights to ensure their sum equals 1
    total_weight = sum(weights)
    normalized_weights = weights / total_weight
    
    return normalized_weights
end

function create_species(species_creator::ArchiveSpeciesCreator, id::String, state::State)
    n_population = species_creator.n_population
    individual_creator = state.reproducer.individual_creator
    population = create_individuals(individual_creator, n_population, state)
    #TODO: hack for numbers game
    if id == "B"
    #if length(species_creator.max_archive_matches ) > 0
        archive = create_individuals(individual_creator, 100, state)
        T = typeof(first(population))
        active_archive_individuals = T[]
    else
        T = typeof(first(population))
        archive = T[]
        active_archive_individuals = T[]
    end

    species = ArchiveSpecies(id, population, archive, active_archive_individuals)
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
        weights = create_archive_weights(length(species.archive), rev = false)
        delete_index = sample(1:length(species.archive), Weights(weights))
        # remove with uniform probability
        #delete_index = rand(1:length(species.archive))
        deleteat!(species.archive, delete_index)
    end
end

using StatsBase: sample

function filter_unique_records(records::Vector{R}) where R <: Record
    grouped = Dict{Vector{Float64}, Vector{R}}()

    # Group records by their raw_tests vector
    for rec in records
        push!(get!(grouped, rec.raw_tests, []), rec)
    end

    # Randomly select one record from each group
    selected_records = [rand(group) for group in values(grouped)]

    return selected_records
end

function add_individuals_to_archive!(
    species_creator::ArchiveSpeciesCreator, 
    species::ArchiveSpecies, 
    evaluation::DistinctionEvaluation,
)
    elite_records = filter_unique_records(evaluation.population_outcome_records)
    elites = [record.individual for record in elite_records]

    #println("adding $(length(elites)) individuals to archive")
    add_individuals_to_archive!(species_creator, species, elites)
    println("archive_length = $(length(species.archive))")
end



function update_active_archive_individuals!(
    species_creator::ArchiveSpeciesCreator, 
    species::ArchiveSpecies, 
    evaluation::DistinctionEvaluation,
    state::State
)
    empty!(species.active_archive_individuals)
    candidates = [
        individual for individual in species.archive 
            if individual ∉ species.population
    ]
    new_archive_individuals = sample(
        state.rng, candidates, species_creator.max_archive_matches; replace = false
    )
    append!(species.active_archive_individuals, new_archive_individuals)
    if length(species.active_archive_individuals) > species_creator.max_archive_matches
        println("species_creator = $species_creator")
        println("species = $species")
        println("evaluation = $evaluation")
        error("active archive individuals > max_archive_matches")
    end
end

function update_archive!(
    species_creator::ArchiveSpeciesCreator, 
    species::ArchiveSpecies, 
    evaluation::Evaluation,
    state::State
)
    if species.id == "B"
    #if species_creator.max_archive_length > 0
        add_individuals_to_archive!(species_creator, species, evaluation)
        #update_active_archive_individuals!(species_creator, species, evaluation, state)
    end
end

using ...Evaluators.Distinction: DistinctionEvaluation
using Distributions: Binomial
using StatsBase: sample, Weights
function get_n_mutations(n_mutations_decay_rate::Float64, max_mutations::Int, state::State)
    # Create probabilities for each possible number of mutations
    probabilities = collect(reverse(exp.(n_mutations_decay_rate * collect(0:max_mutations - 1))))
    # Normalize the probabilities so they sum to 1
    probabilities /= sum(probabilities)
    # Sample a number of mutations based on the probabilities
    n_mutations = sample(state.rng, Weights(probabilities))
    return n_mutations
end


function update_population!(
    species::ArchiveSpecies, 
    species_creator::ArchiveSpeciesCreator, 
    evaluation::DistinctionEvaluation,
    state::State
) 
    n_children = species_creator.n_children
    if species.id == "A"
        parent_records = evaluation.population_outcome_records[1:species_creator.n_parents]
        #n_children = 50
        parents = [
            record.individual for record in
            select(state.reproducer.selector, parent_records, n_children, state)
        ]
        new_children = recombine(state.reproducer.recombiner, parents, state)
        for child in new_children
            mutate!(state.reproducer.mutator, child, state)
        end
        elite_records = evaluation.population_outcome_records[1:species_creator.n_elites]
        elites = [record.individual for record in elite_records]
        new_population = [elites ; new_children]
    elseif species.id == "B"
        do_archive = state.configuration.mode in ["archive_discrete", "archive_continuous"]
        no_archive = state.configuration.mode in ["noarchive_discrete", "noarchive_continuous"]
        if do_archive
            elite_records = evaluation.population_outcome_records[1:50]
            elites = [record.individual for record in elite_records]
            new_children = recombine(state.reproducer.recombiner, elites, state)
            n_mutations = 1
            for child in new_children
                for _ in 1:n_mutations
                    mutate!(state.reproducer.mutator, child, state)
                end
                #mutate!(state.reproducer.mutator, child, state)
            end
            #new_population = [elites ; new_children]
            new_population = new_children
            candidates = [indiv for indiv in species.archive if indiv ∉ [species.population ; new_population]]
            #n_sample = min(length(candidates), 50)
            n_sample = 25
            #println("sampling $n_sample individuals from candidates of length $(length(candidates)) from archive of length $(length(species.archive)) and adding to population")
            weights = create_archive_weights(length(candidates), rev = true)
            random_individuals = sample(state.rng, candidates, Weights(weights), n_sample; replace = false)
            #println("sampled_ids = ", [indiv.id for indiv in random_individuals])
            random_children = recombine(state.reproducer.recombiner, random_individuals, state)
            n_mutations = 1# get_n_mutations(0.25, 10, state)
            for child in random_children
                for _ in 1:n_mutations
                    mutate!(state.reproducer.mutator, child, state)
                end
            end
            new_population = [new_population ; random_individuals ; random_children]
        elseif no_archive
            parent_records = evaluation.population_outcome_records[1:species_creator.n_parents]
            #n_children = 50
            parents = [
                record.individual for record in
                select(state.reproducer.selector, parent_records, n_children, state)
            ]
            new_children = recombine(state.reproducer.recombiner, parents, state)
            for child in new_children
                mutate!(state.reproducer.mutator, child, state)
            end
            elite_records = evaluation.population_outcome_records[1:species_creator.n_elites]
            elites = [record.individual for record in elite_records]
            new_population = [elites ; new_children]
        else
            error("Unknown method: $(state.configuration.method)")
        end
    end
    ids = [individual.id for individual in new_population]
    if length(ids) != length(Set(ids))
        error("Duplicate IDs in new population")
    end
    empty!(species.population)
    append!(species.population, new_population)
end

function update_species!(
    species::ArchiveSpecies, 
    species_creator::ArchiveSpeciesCreator, 
    evaluation::Evaluation,
    state::State
) 
    n_population_before = length(species.population)
    update_archive!(species_creator, species, evaluation, state)
    update_population!(species, species_creator, evaluation, state)
    archive_ids = [individual.id for individual in species.active_archive_individuals]
    population_ids = [individual.id for individual in species.population]
    if length(union(archive_ids, population_ids)) != length(archive_ids) + length(population_ids)
        error("Duplicate IDs in archive and population")
    end
    n_population_after = length(species.population)
    if n_population_after != n_population_before
        error("Population size changed from $n_population_before to $n_population_after")
    end
end

function create_from_dict(::ArchiveSpeciesCreator, dict::Dict, state::State)
    individual_creator = state.reproducer.individual_creator
    id = dict["ID"]
    population = [
        create_from_dict(individual_creator, individual_dict, state)
        for individual_dict in values(dict["POPULATION"])
    ]
    I = typeof(first(population))
    if haskey(dict, "ARCHIVE")
        archive = I[
            create_from_dict(individual_creator, individual_dict, state)
            for individual_dict in values(dict["ARCHIVE"])
        ]
        active_ids = Set(dict["ARCHIVE_IDS"])
        active_individuals = I[individual for individual in archive if individual.id in active_ids]
    else
        archive = I[]
        active_individuals = I[]
    end
    species = ArchiveSpecies(id, population, archive, active_individuals)
    return species
end

end