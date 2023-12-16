export create_genotypes, minimize, get_size, load_genotype, get_prunable_genes
export get_maximum_complexity

using ..Abstract.States: State

function create_genotypes(
    genotype_creator::GenotypeCreator, 
    rng::AbstractRNG,
    gene_id_counter::Counter,
    n_population::Int
)::Vector{Genotype}
    throw(ErrorException(
        "Default genotype creation for $genotype_creator, not implemented."
    ))
end

function create_genotypes(genotype_creator::GenotypeCreator, n_population::Int, state::State)
    rng = get_rng(state)
    gene_id_counter = get_gene_id_counter(state)
    genotypes = create_genotypes(genotype_creator, rng, gene_id_counter, n_population)
    return genotypes
end

function minimize(genotype::Genotype)::Genotype
    throw(ErrorException(
        "Default genotype minimization for $genotype, not implemented."
    ))
end

function get_size(genotype::Genotype)::Int
    throw(ErrorException(
        "Default genotype size for $genotype, not implemented."
    ))
end

function load_genotype(genotype_creator::GenotypeCreator, genotype_group::Group)
    throw(ErrorException(
        "Default genotype loading for $genotype_creator, not implemented."
    ))
end

function get_prunable_genes(genotype::Genotype)::Vector{Int}
    throw(ErrorException(
        "Default genotype prunable genes for $genotype, not implemented."
    ))
end

function get_maximum_complexity(genotypes::Vector{<:Genotype})
    maximum_complexity = maximum(get_size(genotype) for genotype in genotypes)
    return maximum_complexity
end