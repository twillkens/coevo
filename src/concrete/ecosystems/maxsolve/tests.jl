using ....Abstract
using StatsBase
import ....Interfaces: make_all_matches
using ....Interfaces
using ....Abstract
using ...Matrices.Outcome
using ...Matches.Basic
using Random

function update_tests_dodo(
    reproducer::Reproducer, 
    evaluations::Vector{<:Evaluation},
    ecosystem::MaxSolveEcosystem, 
    ecosystem_creator::MaxSolveEcosystemCreator,
    state::State
)
    test_dodo_evaluation = last(evaluations)
    new_test_population = copy(ecosystem.test_population)
    new_pop = [ecosystem[id] for id in test_dodo_evaluation.new_parent_ids]
    filter!(ind -> !(ind.id in test_dodo_evaluation.new_parent_ids), new_test_population)
    append!(new_test_population, new_pop)
    while length(new_test_population) > ecosystem_creator.n_test_population
        popfirst!(new_test_population)
    end
    #push!(new_learner_population, first(ecosystem.learner_children))
    all_archive_tests = [ecosystem.retired_tests ; ecosystem.test_archive]
    n_archive_parents = min(length(all_archive_tests), 20)
    archive_parents = sample(all_archive_tests, n_archive_parents, replace = true)
    random_parents = sample(new_test_population, 20, replace = true)
    for parent in random_parents
        for i in eachindex(parent.genotype.genes)
            parent.genotype.genes[i] = rand(0:1)
        end
    end
    parents = [new_test_population ; archive_parents ; random_parents]
    children = create_children(parents, reproducer, state)
    #for _ in 1:length(children)
    #    popfirst!(new_test_population)
    #end


    return new_test_population, children
end

function update_tests(
    reproducer::Reproducer, 
    evaluation::MaxSolveEvaluation,
    ecosystem::MaxSolveEcosystem, 
    ecosystem_creator::MaxSolveEcosystemCreator,
    state::State
)
    new_test_population = select_individuals_aggregate(
        ecosystem, evaluation.test_score_matrix, ecosystem_creator.n_test_population
    )
    test_parents = sample(
        [new_test_population ; ecosystem.test_archive; ecosystem.retired_tests], ecosystem_creator.n_test_children, replace = true
    )
    random_parents = sample(
        [new_test_population ; ecosystem.test_archive], ecosystem_creator.n_test_children, replace = true
    )
    for parent in random_parents
        for i in eachindex(parent.genotype.genes)
            parent.genotype.genes[i] = rand(0:1)
        end
    end
    append!(test_parents, random_parents)
    #n_sample_archive = min(length(ecosystem.test_archive), 20)
    #archive_parents = sample(
    #    ecosystem.test_archive, n_sample_archive, replace = true
    #)
    #append!(test_parents, archive_parents)
    new_test_children = create_children(test_parents, reproducer, state)
    return new_test_population, new_test_children
end

function update_tests_no_elites(
    reproducer::Reproducer, 
    evaluation::MaxSolveEvaluation,
    ecosystem::MaxSolveEcosystem, 
    ecosystem_creator::MaxSolveEcosystemCreator,
    state::State
)
    new_test_population = select_individuals_aggregate(
        ecosystem, evaluation.test_score_matrix, ecosystem_creator.n_test_population
    )
    println("length_test_population = ", length(new_test_population))
    I = typeof(first(new_test_population))

    #n_sample_archive = min(length(ecosystem.learner_archive), 10)
    n_sample_archive = min(length(ecosystem.test_archive), ecosystem_creator.n_test_population)
    if n_sample_archive == 0
        new_archive_children = I[]
    else
        archive_parents = sample(
            ecosystem.test_archive, n_sample_archive, replace = true
        )
        new_archive_children = create_children(archive_parents, reproducer, state)
    end
    n_sample_retirees = min(length(ecosystem.test_archive), 100)
    if n_sample_retirees > 0
        sampled_retirees = sample(
            ecosystem.test_archive, n_sample_retirees, replace = true
        )
        retiree_children = create_children(sampled_retirees, reproducer, state)
        append!(new_archive_children, retiree_children)
    end
    
    n_sample_population = ecosystem_creator.n_test_children + 
                          ecosystem_creator.n_test_population - n_sample_archive
    println("n_sample_archive = ", n_sample_archive)
    println("n_sample_population = ", n_sample_population)
    println("n_sample_retirees = ", n_sample_retirees)
    test_parents = sample(
        new_test_population, n_sample_population, replace = true
    )

    new_test_children = create_children(test_parents, reproducer, state)
    return I[], [new_archive_children ; new_test_children]
    #return new_learner_population, new_learner_children
end

    #for _ in 1:5
    #    competitors = sample(new_test_population, 3, replace = false)
    #    id_scores = [
    #        learner => sum(evaluation.learner_score_matrix[learner.id, :]) 
    #        for learner in competitors
    #    ]
    #    parent = first(reduce(
    #        (id_score_1, id_score_2) -> id_score_1[2] > id_score_2[2] ? 
    #        id_score_1 : id_score_2, 
    #        shuffle(id_scores)
    #    ))
    #    push!(parents, parent)
    #end
    #new_learner_children = create_children(parents, reproducer, state)
    #for _ in 1:5
    #    popfirst!(new_learner_population)
    #end