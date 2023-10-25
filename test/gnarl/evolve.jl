using Test
using Random: AbstractRNG
using StableRNGs: StableRNG
#include("../../src/CoEvo.jl")
#using CoEvo.Metrics.Concrete.Outcomes.CollisionGameOutcomeMetrics: Affinitive, Adversarial
#using CoEvo.Metrics.Concrete.Outcomes.CollisionGameOutcomeMetrics: Avoidant, Control as GnarlControl
#using CoEvo.Mutators.Types.GnarlNetworks: mutate_weights, add_node, remove_node, add_connection
#using CoEvo.Mutators.Types.GnarlNetworks: remove_connection, mutate

@testset "CollisionGame: Roulette" begin

function collision_game_eco_creator(;
    id::String = "CollisionGame",
    trial::Int = 1,
    random_number_generator::AbstractRNG = StableRNG(42),
    n_population::Int = 50,
    host::String = "Host",
    mutualist::String = "Mutualist",
    parasite::String = "Parasite",
    host_mutualist_affinitive::String = "Host-Mutualist-Affinitive",
    host_parasite_adversarial::String = "Parasite-Host-Adversarial",
    parasite_mutualist_avoidant::String = "Parasite-Mutualist-Avoidant",
    n_elite::Int = 0,
    n_workers::Int = 1,
    episode_length::Int = 10,
    n_input_nodes::Int = 2,
    n_output_nodes::Int = 2,
    initial_distance::Float64 = 5.0,
    cohorts = [:population, :children],
)
    ecosystem_creator = BasicEcosystemCreator(
        id = id,
        trial = trial,
        random_number_generator = random_number_generator,
        species_creators = [
            BasicSpeciesCreator(
                id = host,
                n_population = n_population,
                genotype_creator = GnarlNetworkGenotypeCreator(
                    n_input_nodes = n_input_nodes, 
                    n_output_nodes = n_output_nodes
                ),
                phenotype_creator = DefaultPhenotypeCreator(),
                evaluator = ScalarFitnessEvaluator(maximize = true),
                replacer = GenerationalReplacer(n_elite = n_elite),
                selector = FitnessProportionateSelector(n_parents = n_population),
                recombiner = CloneRecombiner(),
                mutators = [GnarlNetworkMutator()]
            ),
            BasicSpeciesCreator(
                id = parasite,
                n_population = n_population,
                genotype_creator = GnarlNetworkGenotypeCreator(
                    n_input_nodes = n_input_nodes, 
                    n_output_nodes = n_output_nodes
                ),
                phenotype_creator = DefaultPhenotypeCreator(),
                evaluator = ScalarFitnessEvaluator(maximize = true),
                replacer = GenerationalReplacer(n_elite = n_elite),
                selector = FitnessProportionateSelector(n_parents = n_population),
                recombiner = CloneRecombiner(),
                mutators = [GnarlNetworkMutator()]
            ),
            BasicSpeciesCreator(
                id = mutualist,
                n_population = n_population,
                genotype_creator = GnarlNetworkGenotypeCreator(
                    n_input_nodes = n_input_nodes, 
                    n_output_nodes = n_output_nodes
                ),
                phenotype_creator = DefaultPhenotypeCreator(),
                evaluator = ScalarFitnessEvaluator(maximize = true),
                replacer = GenerationalReplacer(n_elite = n_elite),
                selector = FitnessProportionateSelector(n_parents = n_population),
                recombiner = CloneRecombiner(),
                mutators = [GnarlNetworkMutator()]
            ),
        ],
        job_creator = BasicJobCreator(
            n_workers = 1,
            interactions = [
                BasicInteraction(
                    id = host_mutualist_affinitive,
                    environment_creator = CollisionGameEnvironmentCreator(
                        domain = PredictionGameDomain(
                            Affinitive(),
                        ),
                        initial_distance = initial_distance,
                        episode_length = episode_length
                    ),
                    species_ids = [host, mutualist],
                    matchmaker = AllvsAllMatchMaker(cohorts = cohorts),
                ),
                BasicInteraction(
                    id = host_parasite_adversarial,
                    environment_creator = CollisionGameEnvironmentCreator(
                        domain = PredictionGameDomain(
                            Adversarial()
                        ),
                        initial_distance = initial_distance,
                        episode_length = episode_length
                    ),
                    species_ids = [parasite, host],
                    matchmaker = AllvsAllMatchMaker(cohorts = cohorts),
                ),
                BasicInteraction(
                    id = parasite_mutualist_avoidant,
                    environment_creator = CollisionGameEnvironmentCreator(
                        domain = PredictionGameDomain(
                            Avoidant()
                        ),
                        initial_distance = initial_distance,
                        episode_length = episode_length
                    ),
                    species_ids = [parasite, host],
                    matchmaker = AllvsAllMatchMaker(cohorts = cohorts),
                ),
            ],
        ),
        performer = BasicPerformer(n_workers = n_workers),
        state_creator = BasicCoevolutionaryStateCreator(),
        reporters = Reporter[
            # BasicReporter(metric = GenotypeSize()),
        ],
        archiver = BasicArchiver(),
        runtime_reporter = RuntimeReporter(print_interval = 0),
    )
    return ecosystem_creator
end


ecosystem_creator = collision_game_eco_creator(n_population = 50, n_workers = 1)
eco = evolve!(ecosystem_creator, n_generations = 5)
@test length(eco.species) == 3

end

@testset "CollisionGame: Disco" begin

function collision_game_disco_eco_creator(;
    id::String = "CollisionGame: Disco",
    trial::Int = 1,
    random_number_generator::AbstractRNG = StableRNG(42),
    n_population::Int = 50,
    host::String = "Host",
    parasite::String = "Mutualist",
    mutualist::String = "Parasite",
    host_mutualist_affinitive::String = "Host-Mutualist-Affinitive",
    host_parasite_adversarial::String = "Host-Parasite-Adversarial",
    parasite_mutualist_avoidant::String = "Parasite-Mutualist-Avoidant",
    n_workers::Int = 1,
    episode_length::Int = 10,
    initial_distance::Float64 = 5.0,
    n_input_nodes::Int = 2,
    n_output_nodes::Int = 2,
    cohorts::Vector{Symbol} = [:population, :children],
    n_truncate::Int = n_population,
    tournament_size::Int = 3,
)
    ecosystem_creator = BasicEcosystemCreator(
        id = id,
        trial = trial,
        random_number_generator = random_number_generator,
        species_creators = [
            BasicSpeciesCreator(
                id = host,
                n_population = n_population,
                genotype_creator = GnarlNetworkGenotypeCreator(
                    n_input_nodes = n_input_nodes,
                    n_output_nodes = n_output_nodes 
                ),
                phenotype_creator = DefaultPhenotypeCreator(),
                evaluator = NSGAIIEvaluator(
                    maximize = true,
                    perform_disco = true
                ),
                replacer = TruncationReplacer(n_truncate = n_truncate),
                selector = TournamentSelector(
                    n_parents = n_population, tournament_size = tournament_size
                ),
                recombiner = CloneRecombiner(),
                mutators = [GnarlNetworkMutator()]
            ),
            BasicSpeciesCreator(
                id = parasite,
                n_population = n_population,
                genotype_creator = GnarlNetworkGenotypeCreator(
                    n_input_nodes = n_input_nodes, 
                    n_output_nodes = n_output_nodes
                ),
                phenotype_creator = DefaultPhenotypeCreator(),
                evaluator = NSGAIIEvaluator(
                    maximize = true,
                    perform_disco = true
                ),
                replacer = TruncationReplacer(n_truncate = n_truncate),
                selector = TournamentSelector(
                    n_parents = n_population, tournament_size = tournament_size
                ),
                recombiner = CloneRecombiner(),
                mutators = [GnarlNetworkMutator()]
            ),
            BasicSpeciesCreator(
                id = mutualist,
                n_population = n_population,
                genotype_creator = GnarlNetworkGenotypeCreator(
                    n_input_nodes = n_input_nodes, 
                    n_output_nodes = n_output_nodes
                ),
                phenotype_creator = DefaultPhenotypeCreator(),
                evaluator = NSGAIIEvaluator(),
                replacer = TruncationReplacer(n_truncate = n_truncate),
                selector = TournamentSelector(
                    n_parents = n_population, tournament_size = tournament_size
                ),
                recombiner = CloneRecombiner(),
                mutators = [GnarlNetworkMutator()]
            ),
        ],
        job_creator = BasicJobCreator(
            n_workers = 1,
            interactions = [
                BasicInteraction(
                    id = host_mutualist_affinitive,
                    environment_creator = CollisionGameEnvironmentCreator(
                        domain = PredictionGameDomain(
                            Affinitive(),
                        ),
                        initial_distance = initial_distance,
                        episode_length = episode_length
                    ),
                    species_ids = [host, mutualist],
                    matchmaker = AllvsAllMatchMaker(cohorts = cohorts),
                ),
                BasicInteraction(
                    id = host_parasite_adversarial,
                    environment_creator = CollisionGameEnvironmentCreator(
                        domain = PredictionGameDomain(
                            Adversarial()
                        ),
                        initial_distance = initial_distance,
                        episode_length = episode_length
                    ),
                    species_ids = [parasite, host],
                    matchmaker = AllvsAllMatchMaker(cohorts = cohorts),
                ),
                BasicInteraction(
                    id = parasite_mutualist_avoidant,
                    environment_creator = CollisionGameEnvironmentCreator(
                        domain = PredictionGameDomain(
                            Avoidant()
                        ),
                        initial_distance = initial_distance,
                        episode_length = episode_length
                    ),
                    species_ids = [parasite, host],
                    matchmaker = AllvsAllMatchMaker(cohorts = cohorts),
                ),
            ],
        ),
        performer = BasicPerformer(n_workers = n_workers),
        state_creator = BasicCoevolutionaryStateCreator(),
        reporters = Reporter[
            # BasicReporter(metric = GenotypeSize()),
            # BasicReporter(metric = AllSpeciesFitness()),
        ],
        archiver = BasicArchiver(),
        runtime_reporter = RuntimeReporter(print_interval = 0),
    )
    return ecosystem_creator
end


ecosystem_creator = collision_game_disco_eco_creator(n_population = 50, n_workers = 1)
eco = evolve!(ecosystem_creator, n_generations=1)
@test length(eco.species) == 3

end
