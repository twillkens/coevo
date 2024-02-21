module XMeans

export x_means_clustering, multiple_xmeans, get_kmeans_clustering_result
export KMeansClusteringResult, DiscoBinary, DiscoAverage, find_distance
export Euclidean, squared_euclidean_distance, disco_binary_distance, disco_average_distance
export vector_transpose, is_power2, bayesian_information_criterion, split_cluster, split_and_evaluate_clusters
export kmeans_plus_plus_init, get_derived_tests, DISTANCE_METHODS
export akaike_information_criterion

using LinearAlgebra
using Random
using StableRNGs: StableRNG
using StatsBase: mean
using DataStructures

function vector_transpose(vectors::Vector{Vector{Float64}})
    transposed_vectors = [collect(row) for row in eachrow(hcat(vectors...))]
    return transposed_vectors
end

abstract type DistanceMethod end

struct Euclidean <: DistanceMethod end

struct DiscoBinary <: DistanceMethod end

struct DiscoAverage <: DistanceMethod end

@inline function euclidean_distance(sample::Vector{T}, center::Vector{T}) where T
    @assert length(sample) == length(center)
    s = zero(T)
    @simd for i in eachindex(sample)
        Δ = sample[i] - center[i]
        s += Δ * Δ
    end
    return sqrt(s)
end

@inline function squared_euclidean_distance(sample::Vector{T}, center::Vector{T}) where T
    @assert length(sample) == length(center)
    s = zero(T)
    @simd for i in eachindex(sample)
        Δ = sample[i] - center[i]
        s += Δ * Δ
    end
    return s
end

function disco_binary_distance(sample::Vector{Float64}, centroid::Vector{Float64})::Float64
    @assert length(sample) == length(centroid)
    distance = 0.0
    #println("sample = ", sample)
    #println("centroid = ", centroid)
    for i in 1:length(sample)
        binarized_value = centroid[i] < 0.5 ? 0.0 : 1.0
        #println("binarized_value = ", binarized_value)
        #println("sample[i] = ", sample[i])
        d = (sample[i] - binarized_value)^2
        #println("d = ", d)
        distance += d
    end
    return distance
end

function disco_average_distance(
    sample::Vector{Float64}, centroid::Vector{Float64}, global_averages::Vector{Float64}
)::Float64
    @assert length(sample) == length(centroid) == length(global_averages)
    distance = 0.0
    for i in 1:length(sample)
        threshhold_value = centroid[i] < global_averages[i] ? 0.0 : 1.0
        distance += (sample[i] - threshhold_value)^2
    end
    return distance
end

find_distance(::Euclidean, sample::Vector{Float64}, center::Vector{Float64}, ::Vector{Float64}) = 
    squared_euclidean_distance(sample, center)

find_distance(::DiscoBinary, sample::Vector{Float64}, center::Vector{Float64}, ::Vector{Float64}) =
    disco_binary_distance(sample, center)

find_distance(::DiscoAverage, sample::Vector{Float64}, center::Vector{Float64}, solution_averages::Vector{Float64}) = 
    disco_average_distance(sample, center, solution_averages)


is_power2(num::Int) = (num & (num - 1)) == 0 && num != 0

struct KMeansClusteringResult
    error::Float64
    samples::Vector{Vector{Float64}}
    centroids::Vector{Vector{Float64}}
    cluster_indices::Vector{Vector{Int}}
    clusters::Vector{Vector{Vector{Float64}}}
    bic::Float64
end

# Ensure the input parameters are valid
function validate_parameters(
    samples::Vector{Vector{Float64}}, cluster_count::Int, tolerance::Float64
)::Nothing
    if cluster_count > length(samples)
        throw(ArgumentError("cluster_count cannot be greater than the number of samples"))
    end
    if cluster_count < 1
        throw(ArgumentError("cluster_count cannot be less than 1"))
    end
    if tolerance < 0.0
        throw(ArgumentError("tolerance cannot be less than 0.0"))
    end
    if isempty(samples)
        throw(ArgumentError("samples cannot be empty"))
    end
end

# Reset the clusters
function reset_clusters!(
    partition::Vector{Vector{Vector{Float64}}}, cluster_indices::Vector{Vector{Int}}
)::Nothing
    foreach(empty!, partition)
    foreach(empty!, cluster_indices)
end

# Assign samples to the closest centroid
function assign_samples_to_clusters!(
    samples::Vector{Vector{Float64}}, 
    centroids::Vector{Vector{Float64}}, 
    cluster_count::Int, 
    cluster_indices::Vector{Vector{Int}}, 
    partition::Vector{Vector{Vector{Float64}}},
    distance_method::DistanceMethod = Euclidean(),
    solution_averages::Vector{Float64} = Float64[]
)::Nothing
    for (sample_index, sample) in enumerate(samples)
        min_distance = find_distance(distance_method, sample, centroids[1], solution_averages)
        assigned_cluster = 1
        for i in 2:cluster_count
            #distance = euclidean_distance(sample, centroids[i])
            distance = find_distance(distance_method, sample, centroids[i], solution_averages)
            if distance < min_distance
                min_distance = distance
                assigned_cluster = i
            end
        end
        push!(cluster_indices[assigned_cluster], sample_index)
        push!(partition[assigned_cluster], sample)
    end
end

# Update the centroids using the samples assigned to each cluster
function update_centroids!(
    partition::Vector{Vector{Vector{Float64}}}, 
    centroids::Vector{Vector{Float64}}, 
    rng::AbstractRNG, 
    samples::Vector{Vector{Float64}}
)::Nothing
    for (idx, cluster_samples) in enumerate(partition)
        if isempty(cluster_samples)
            centroids[idx] = rand(rng, samples)
        else
            centroids[idx] = mean(cluster_samples)
        end
    end
end

# Compute the clustering error
function compute_clustering_error(
    partition::Vector{Vector{Vector{Float64}}}, 
    centroids::Vector{Vector{Float64}}, 
    cluster_count::Int,
    distance_method::DistanceMethod = Euclidean(),
    solution_averages::Vector{Float64} = Float64[]
)::Float64
    error = 0.0
    for idx in 1:cluster_count
        for sample in partition[idx]
            #error += squared_euclidean_distance(sample, centroids[idx])
            error += find_distance(distance_method, sample, centroids[idx], solution_averages)
        end
    end
    return error
end


#function bayesian_information_criterion(
#    samples::Vector{Vector{Float64}}, 
#    centroids::Vector{Vector{Float64}}, 
#    clusters::Vector{Vector{Int}}
#)
#    K = length(centroids)  # Number of clusters
#    N = sum(length(cluster) for cluster in clusters)  # Total number of data points
#    dimension = length(samples[1])  # Dimensionality of data points
#
#    sigma_sqrt = 0.0  # Estimation of the noise variance
#
#    # Calculate the sum of squared distances from each point to its cluster centroid
#    for (index_cluster, cluster) in enumerate(clusters)
#        centroid = centroids[index_cluster]
#        for index_point in cluster
#            point = samples[index_point]
#            sigma_sqrt += sum((point[i] - centroid[i])^2 for i in 1:dimension)
#        end
#    end
#
#    # Avoid division by zero
#    if N > K
#        sigma_sqrt /= (N - K)
#        p = (K - 1) + dimension * K + 1  # Number of free parameters
#        # Calculate BIC for each cluster and sum them
#        scores = Float64[]
#        for cluster in clusters
#            n = length(cluster)
#            sigma_multiplier = sigma_sqrt <= 0.0 ? -Inf : dimension * 0.5 * log(sigma_sqrt)
#            L = n * log(n / N) - n * 0.5 * log(2 * π) - n * sigma_multiplier - (n - K) * 0.5
#
#            #L = n * log(n / N) - n * dimension * 0.5 * log(2 * π) - n * dimension * 0.5 * log(sigma_sqrt) - (n - K) * 0.5
#            push!(scores, L - p * 0.5 * log(N))
#        end
#
#        return sum(scores)
#    else
#        return -Inf
#    end
#end
#
function bayesian_information_criterion(
    samples::Vector{Vector{Float64}}, 
    centroids::Vector{Vector{Float64}}, 
    clusters::Vector{Vector{Int}}
)
    R = length(samples)
    K = length(centroids)
    M = length(samples[1])
    
    # Calculate variance estimate (σ^2)
    σ²_sum = 0.0
    for k in 1:K
        for i in clusters[k]
            σ²_sum += sum((samples[i][m] - centroids[k][m])^2 for m in 1:M)
        end
    end
    σ² = σ²_sum / (R - K)
    
    # Calculate log-likelihood (l̂)
    l̂ = 0.0
    for k in 1:K
        R_k = length(clusters[k])
        for i in clusters[k]
            distance² = sum((samples[i][m] - centroids[k][m])^2 for m in 1:M)
            l̂ += - (M / 2) * log(2 * π * σ²) - (distance² / (2 * σ²))
        end
        l̂ += R_k * log(R_k / R) # Add log of the cluster proportion
    end
    
    # Calculate number of parameters (p)
    p = K * M + 1 # K centroids with M dimensions each, plus one variance
    
    # Calculate BIC
    BIC = l̂ - (p / 2) * log(R)
    return BIC
end

function calculate_variance(samples::Vector{Vector{Float64}}, centers::Vector{Vector{Float64}}, clusters::Vector{Vector{Int}})
    sigma_sqrt = 0.0
    N = sum(length(cluster) for cluster in clusters)
    K = length(centers)
    
    # Avoid division by zero by setting a default small variance if N - K <= 0
    if N - K <= 0
        return 1e-4  # Return a small positive number to avoid division by zero
    end
    
    for index_cluster in 1:length(clusters)
        cluster = clusters[index_cluster]
        center = centers[index_cluster]
        for index_object in cluster
            sigma_sqrt += norm(samples[index_object] - center)^2
        end
    end
    
    sigma_sqrt /= (N - K)
    return sigma_sqrt
end


function calculate_log_likelihood(n::Int, N::Int, sigma_sqrt::Float64, dimension::Int)
    if sigma_sqrt <= 0.0
        return -Inf  # Handling the case where variance is zero or negative.
    end
    
    sigma_multiplier = dimension * 0.5 * log(sigma_sqrt)
    L = n * log(n) - n * log(N) - n * 0.5 * log(2.0 * π) - n * sigma_multiplier - (n - dimension) * 0.5
    
    return L
end

function calculate_bic(
    samples::Vector{Vector{Float64}}, 
    centers::Vector{Vector{Float64}}, 
    clusters::Vector{Vector{Int}}
)
    dimension = length(samples[1])
    K = length(centers)
    N = sum(length(cluster) for cluster in clusters)
    sigma_sqrt = calculate_variance(samples, centers, clusters)
    p = (K - 1) + dimension * K + 1  # Number of parameters
    
    scores = Float64[]
    for cluster in clusters
        n = length(cluster)
        L = calculate_log_likelihood(n, N, sigma_sqrt, dimension)
        score = L - p * 0.5 * log(N)
        push!(scores, score)
    end
    
    return -sum(scores)
end


function calculate_mdl(
           samples::Vector{Vector{Float64}},
           centers::Vector{Vector{Float64}},
           clusters::Vector{Vector{Int}},
           alpha::Float64 = 0.9,
           beta::Float64 = 0.9
       )
    W = 0.0
    K = length(clusters)
    N = sum(length(cluster) for cluster in clusters)

    sigma_square = 0.0
    alpha_square = alpha * alpha

    # Calculate the total within-cluster sum of squares and sigma_square
    for index_cluster in 1:length(clusters)
        Ni = length(clusters[index_cluster])
        if Ni == 0
            return Inf  # Return infinity if any cluster is empty
        end

        Wi = 0.0
        for index_object in clusters[index_cluster]
            Wi += norm(samples[index_object] - centers[index_cluster])^2
        end

        sigma_square += Wi
        W += Wi / Ni
    end

    if N - K > 0
        sigma_square /= (N - K)
        sigma = sqrt(sigma_square)

        Kw = (1.0 - K / N) * sigma_square
        Ksa = (2.0 * alpha * sigma / sqrt(N)) * sqrt(alpha_square * sigma_square / N + W - Kw / 2.0)
        UQa = W - Kw + 2.0 * alpha_square * sigma_square / N + Ksa

        score = sigma_square * K / N + UQa + sigma_square * beta * sqrt(2.0 * K) / N
    else
        score = Inf  # Handle division by zero or other invalid cases
    end

    return score  # Return negative MDL score to align with convention that lower is better
end



function akaike_information_criterion(
    samples::Vector{Vector{Float64}}, 
    centroids::Vector{Vector{Float64}}, 
    clusters::Vector{Vector{Int}},
    use_corrected::Bool = false  # Add an option to use the corrected AIC
)::Float64
    N = sum(length(cluster) for cluster in clusters)  # Total number of data points
    dimension = length(samples[1])  # Dimensionality of data points
    K = length(centroids)  # Number of clusters
    k = K * dimension  # Number of parameters

    # Approximate the negative log likelihood
    negative_log_likelihood = 0.0
    for cluster_index in 1:length(clusters)
        centroid = centroids[cluster_index]  # Correctly match centroid to cluster
        for index_point in clusters[cluster_index]
            point = samples[index_point]
            negative_log_likelihood += sum((point[i] - centroid[i])^2 for i in 1:dimension)
        end
    end
    
    negative_log_likelihood /= 2  # Adjusting according to the conventional formula

    # Calculate AIC
    AIC = 2k + 2 * negative_log_likelihood

    # Calculate AICc if requested and applicable
    if use_corrected && N > k + 1
        AIC += (2k * (k + 1)) / (N - k - 1)
    end

    return AIC
end


function get_kmeans_clustering_result(
    rng::AbstractRNG,
    samples::Vector{Vector{Float64}}, 
    cluster_count::Int, 
    centroids::Vector{Vector{Float64}},
    distance_method::DistanceMethod = Euclidean(),
    solution_averages::Vector{Float64} = Float64[];
    info_criterion::String = "AIC",
    tolerance::Float64 = 0.001, 
    maximum_iterations::Int = 500,
    args...
)::KMeansClusteringResult
    validate_parameters(samples, cluster_count, tolerance)
    previous_error = 0.0
    current_error = 0.0
    partition = [Vector{Float64}[] for _ in 1:cluster_count]
    cluster_indices = [Int[] for _ in 1:cluster_count]

    for _ in 1:maximum_iterations
        reset_clusters!(partition, cluster_indices)
        assign_samples_to_clusters!(
            samples, centroids, cluster_count, cluster_indices, partition, 
            distance_method, solution_averages; args...
        )
        update_centroids!(partition, centroids, rng, samples)
        current_error = compute_clustering_error(partition, centroids, cluster_count,
            distance_method, solution_averages; args...
        )
        if abs(current_error - previous_error) < tolerance
            break
        end
        previous_error = current_error
    end

    error = round(current_error, sigdigits=4)
    if info_criterion == "BIC"
        #bic = bayesian_information_criterion(samples, centroids, cluster_indices)
        bic = calculate_bic(samples, centroids, cluster_indices)
    elseif info_criterion == "AIC"
        bic = akaike_information_criterion(samples, centroids, cluster_indices)
    elseif info_criterion == "MDL"
        bic = calculate_mdl(samples, centroids, cluster_indices)
    else
        throw(ArgumentError("Invalid information criterion"))
    end
    
    result = KMeansClusteringResult(error, samples, centroids, cluster_indices, partition, bic)
    return result
end


function kmeans_plus_plus_init(
    rng::AbstractRNG, 
    samples::Vector{Vector{Float64}}, 
    cluster_count::Int, 
    distance_method::DistanceMethod = Euclidean(), 
    solution_averages::Vector{Float64} = Float64[]
)
    # Choose the first centroid randomly from the samples
    if all(x -> x == samples[1], samples)
        # Handle the case of uniform samples (e.g., choose centroids randomly or abort)
        centroids = [copy(samples[rand(rng, 1:length(samples))]) for _ in 1:cluster_count]
        return centroids
        # ...
    end
    centroids = [copy(samples[rand(rng, 1:length(samples))])]

    for _ in 2:cluster_count
        distances = Float64[]

        for sample in samples
            # Find the shortest distance from this sample to any existing centroid
            #s = round.(sample; digits=3)
            #c = [round.(centroid; digits=3) for centroid in centroids]
            #println("sample = $s")
            #println("centroids = $c")
            sample_distances = [
                find_distance(distance_method, sample, centroid, solution_averages) 
                for centroid in centroids
            ]
            #println("sample_distances = $(round.(sample_distances; digits=3))")
            min_distance = minimum(sample_distances)
            push!(distances, min_distance)
        end
        #println("distances = $(round.(distances; digits=3))")
        if any(isnan, distances)
            println("samples = ", samples)
            println("centroids = ", centroids)
            println("distances = ", distances)
            throw(ErrorException("NaN in distances"))
        end

        # Choose a new centroid randomly, weighted by the square of the distances
        total_distance = sum(distances)
        probabilities = distances / total_distance
        #println("probabilities = $(round.(probabilities; digits=3))")
        cumulative_probabilities = cumsum(probabilities)
        #println("cumulative_probabilities = $(round.(cumulative_probabilities; digits=3))")
        random_value = rand(rng)
        new_centroid_index = findfirst(x -> x >= random_value, cumulative_probabilities)
        if new_centroid_index === nothing
            println("samples = ", samples)
            println("centroids = ", centroids)
            println("distances = ", distances)
            println("probabilities = ", probabilities)
            println("cumulative_probabilities = ", cumulative_probabilities)
            println("random_value = ", random_value)
            println("new_centroid_index = ", new_centroid_index)
            throw(ErrorException("new_centroid_index is nothing"))
        end
        new_centroid = copy(samples[new_centroid_index])
        #println("new_centroid = $(round.(new_centroid; digits=3))")
        push!(centroids, new_centroid)
    end

    return centroids
end
using Random
export do_kmeans, split_cluster, split_and_evaluate_clusters, get_derived_tests

function do_kmeans(
    samples::Vector{Vector{Float64}}, cluster_count::Int, rng::AbstractRNG = Random.GLOBAL_RNG; 
    args...
)
    centroids = kmeans_plus_plus_init(rng, samples, cluster_count)
    return get_kmeans_clustering_result(rng, samples, cluster_count, centroids; args...)
end

function do_kmeans(
    samples::Matrix{Float64}, cluster_count::Int, rng::AbstractRNG = Random.GLOBAL_RNG; 
    args...
)
    samples = [collect(row) for row in eachrow(samples)]
    return do_kmeans(samples, cluster_count, rng; args...)
end



function split_cluster(
    rng::AbstractRNG, cluster_samples::Vector{Vector{Float64}},
    distance_method::DistanceMethod = Euclidean(),
    solution_averages::Vector{Float64} = Float64[] 
)
    # Using K-means++ initialization for splitting the cluster into two sub-clusters
    return kmeans_plus_plus_init(rng, cluster_samples, 2, distance_method, solution_averages)
end

function split_and_evaluate_clusters(
    rng::AbstractRNG,
    samples::Vector{Vector{Float64}},
    current_result::KMeansClusteringResult,
    max_cluster_count::Int,
    distance_method::DistanceMethod = Euclidean(),
    solution_averages::Vector{Float64} = Float64[];
    args...
)::Vector{Vector{Float64}}
    new_centroids = Vector{Vector{Float64}}()
    n_free_centroids = max_cluster_count - length(current_result.centroids)
    for (cluster_index, centroid) in enumerate(current_result.centroids)
        #println("------------------")
        cluster_samples = current_result.clusters[cluster_index]

        if length(cluster_samples) < 2
            push!(new_centroids, centroid)
            continue
        end

        #println("cluster_samples = ", cluster_samples)
        orig_result = get_kmeans_clustering_result(
            rng, cluster_samples, 1, [centroid], distance_method, solution_averages; args...
        )
        orig_bic = orig_result.bic
        #println("orig_centroid = ", centroid)
        #println("orig_bic = ", orig_bic)
        initial_split_centroids = split_cluster(rng, cluster_samples)
        #println("initial_split_centroids = ", initial_split_centroids)
        children_result = get_kmeans_clustering_result(
            rng, cluster_samples, 2, initial_split_centroids,
            distance_method, solution_averages; args...
        )
        children_centroids = children_result.centroids
        #println("children_centroids = ", children_centroids)
        #println("children_bic = ", children_bic)
        if children_result.bic >= orig_bic || n_free_centroids == 0
            push!(new_centroids, centroid)
        else 
            n_free_centroids -= 1
            append!(new_centroids, children_centroids)
        end
    end

    return new_centroids
end

# Test if the initialized centroids are close to the true centroids
function is_close_to_any_centroid(centroid, true_centroids, threshold)
    return any(euclidean_distance(centroid, tc) < threshold for tc in true_centroids)
end

function x_means_clustering(
    rng::AbstractRNG,
    samples::Vector{Vector{Float64}}, 
    min_cluster_count::Int, 
    max_cluster_count::Int,
    distance_method::DistanceMethod = Euclidean();
    args...
)::KMeansClusteringResult
    # Initialize with min_cluster_count
    solution_averages = [mean(solution_scores) for solution_scores in vector_transpose(samples)]
    centroids = kmeans_plus_plus_init(
        rng, samples, min_cluster_count, distance_method, solution_averages
    )
    best_result = get_kmeans_clustering_result(
        rng, samples, min_cluster_count, centroids, distance_method, solution_averages; args...
    ) 
        
    best_bic = best_result.bic
    #println("best_bic_1 = ", best_bic)
    #println("best_centroids = ", centroids)

    for i in (min_cluster_count+1):max_cluster_count
        #println("\n\n--------------num_clusters = ", num_clusters)
        # Attempt to split each cluster and evaluate
        new_centroids = split_and_evaluate_clusters(
            rng, samples, best_result, max_cluster_count; args...
        ) 
        
        # Evaluate new clustering
        new_result = get_kmeans_clustering_result(
            rng, samples, length(new_centroids), new_centroids; args...)
        new_bic = new_result.bic
        #println("new_bic_$i = ", new_bic)

        #println("-----$i-----")
        #println("best_centroids = ", centroids)
        #println("best_bic = ", best_bic)
        #println("new_centroids = ", new_centroids)
        #println("new_bic = ", new_bic)

        # Update best result if BIC is improved
        if new_bic < best_bic
            best_bic = new_bic
            best_result = new_result
            centroids = new_result.centroids # Update centroids for the next iteration
        else
            break # No improvement, stop iterating
        end
    end

    return best_result
end

export x_means_nosplits

function x_means_nosplits(
    rng::AbstractRNG,
    samples::Vector{Vector{Float64}}, 
    min_cluster_count::Int, 
    max_cluster_count::Int,
    distance_method::DistanceMethod = Euclidean();
    args...
)::KMeansClusteringResult
    # Initialize with min_cluster_count
    solution_averages = [mean(solution_scores) for solution_scores in vector_transpose(samples)]
    centroids = kmeans_plus_plus_init(
        rng, samples, min_cluster_count, distance_method, solution_averages
    )
    best_result = get_kmeans_clustering_result(
        rng, samples, min_cluster_count, centroids, distance_method, solution_averages; args...
    ) 
        
    best_bic = best_result.bic
    #println("best_bic_1 = ", best_bic)
    #println("best_centroids = ", centroids)
    max_cluster_count = min(max_cluster_count, length(samples))
    all_bics = [best_bic]

    for i in (min_cluster_count+1):max_cluster_count
        #println("\n\n--------------num_clusters = ", num_clusters)
        # Attempt to split each cluster and evaluate
        new_centroids = kmeans_plus_plus_init(
            rng, samples, i, distance_method
        ) 
        
        # Evaluate new clustering
        new_result = get_kmeans_clustering_result(
            rng, samples, length(new_centroids), new_centroids; args...)
        new_bic = new_result.bic
        #println("new_bic_$i = ", new_bic)

        #println("-----$i-----")
        #println("best_centroids = ", centroids)
        #println("best_bic = ", best_bic)
        #println("new_centroids = ", new_centroids)
        #println("new_bic = ", new_bic)

        # Update best result if BIC is improved
        if new_bic < best_bic
            best_bic = new_bic
            best_result = new_result
            centroids = new_result.centroids # Update centroids for the next iteration
        end
    end

    return best_result
end
function x_means_nosplits(
    rng::AbstractRNG, samples::Matrix{Float64}, min_cluster_count::Int, max_cluster_count::Int,
    distance_method::DistanceMethod = Euclidean(); 
    kwargs...
)
    samples = [collect(row) for row in eachrow(samples)]
    result = x_means_nosplits(rng, samples, min_cluster_count, max_cluster_count, distance_method; kwargs...)
    return result
end


function multiple_xmeans(
    rng::AbstractRNG,
    samples::Vector{Vector{Float64}}, 
    min_cluster_count::Int, 
    max_cluster_count::Int, 
    n_runs::Int,
    distance_method::DistanceMethod = Euclidean(); 
    args...
)::KMeansClusteringResult
    best_result = x_means_clustering(
        rng, samples, min_cluster_count, max_cluster_count, distance_method; args...
    )
    best_bic = best_result.bic

    for _ in 2:n_runs
        new_result = x_means_clustering(
            rng, samples, min_cluster_count, max_cluster_count, distance_method; args...
        )
        new_bic = new_result.bic

        if new_bic < best_bic
            best_bic = new_bic
            best_result = new_result
        end
    end

    return best_result
end

function multiple_xmeans(
    rng::AbstractRNG, samples::Matrix{Float64}, min_cluster_count::Int, max_cluster_count::Int,
    n_runs::Int; 
    kwargs...
)
    samples = [collect(row) for row in eachrow(samples)]
    result = multiple_xmeans(rng, samples, min_cluster_count, max_cluster_count, n_runs; kwargs...)
    return result
end

using Random
function multiple_xmeans(
    samples::Matrix{Float64}, min_cluster_count::Int, max_cluster_count::Int, n_runs::Int; 
    kwargs...
)
    return multiple_xmeans(
        Random.GLOBAL_RNG, samples, min_cluster_count, max_cluster_count, n_runs; kwargs...
    )
end
function get_derived_tests(
    rng::AbstractRNG, 
    indiv_tests::SortedDict{Int, Vector{Float64}},
    max_clusters::Int,
    distance_method::DistanceMethod
)
    for (id, test_vector) in indiv_tests
        if any(isnan, test_vector)
            println("id: ", id)
            println("test_vector: ", test_vector)
            throw(ErrorException("NaN in test_vector"))
        end
    end
    test_vectors = collect(values(indiv_tests))
    test_columns = [collect(row) for row in eachrow(hcat(test_vectors...))]
    result = multiple_xmeans(
        rng, test_columns, 2, max_clusters, 2, distance_method; 
    )
    derived_test_matrix = hcat(result.centroids...)
    derived_tests = SortedDict{Int, Vector{Float64}}(
        id => collect(derived_test)
        for (id, derived_test) in zip(keys(indiv_tests), eachrow(derived_test_matrix))
    )
    return derived_tests
end

const DISTANCE_METHODS = Dict(
    "euclidean" => Euclidean(),
    "disco_binary" => DiscoBinary(),
    "disco_average" => DiscoAverage()
)

function get_derived_tests(
    rng::AbstractRNG, 
    indiv_tests::SortedDict{Int, Vector{Float64}},
    max_clusters::Int,
    distance_method::String
)
    return get_derived_tests(
        rng, indiv_tests, max_clusters, DISTANCE_METHODS[distance_method]
    )
end

end