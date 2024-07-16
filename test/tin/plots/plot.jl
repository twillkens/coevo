
using CSV
using DataFrames
using Plots
using Statistics
using Bootstrap
using Bootstrap: bootstrap, BasicSampling, BasicConfInt, confint as bootstrap_confint
using StatsBase: nquantile, skewness, kurtosis, mode, mean, var, std
using Glob
using Plots.PlotMeasures
using Plots: Font
using Measures
Plots.default(fontfamily = ("Times Roman"))# titlefont = ("Times Roman"), legendfont = ("Times Roman"))
gr()
# Define a struct to hold file details
struct FileDetail
    filepath::String
    label::String
    color::Symbol
end

const AGG_DATA_DIR = "data/agg"

const DEFAULT_BOOTSTRAPPED_CONFIDENCE_INTERVALS = Dict(
        "lower_confidence" => 0,
        "upper_confidence" => 0,
)
const N_BOOTSTRAP_SAMPLES = 1000

const DEFAULT_CONFIDENCE = 0.95

const N_TRIALS = 20
const N_GENERATIONS = 10000

function get_bootstrapped_confidence_intervals(
    values::Vector{Float64}, confidence_level::Float64 = 0.95
)
    if length(values) == 0
        return Dict("lower_confidence" => 0, "upper_confidence" => 0)
    end
    bootstrap_result = bootstrap(mean, values, BasicSampling(1000))
    _, lower_confidence, upper_confidence = first(bootstrap_confint(
        bootstrap_result, BasicConfInt(confidence_level)
    ))
    confidence_intervals = Dict(
        "lower_confidence" => lower_confidence,
        "upper_confidence" => upper_confidence,
    )
    return confidence_intervals
end


Base.@kwdef struct PlotDetail
    metric::String
    condition::String
    label::String
    color::Symbol
    species::String 
end

function PlotDetail(metric::String, condition::String, label::String, color::Symbol)
    return PlotDetail(metric, condition, label, color, "")
end

FONT_CHOICE = "Computer Modern"

Base.@kwdef struct PlotSpec
    data_filepath::String
    save_path::String
    legend::Symbol
    title::String
    details::Vector{PlotDetail}
    ylabel::String 
    xlabel::String = "Generation"
    ylims::Union{Nothing, Tuple{Float64, Float64}} = (-1.0, -1.0)
    xlims::Union{Nothing, Tuple{Float64, Float64}} = (-1.0, -1.0)
    fillalpha::Float64 = 0.35
    size::Tuple{Int, Int} = (1400, 800)
    leftmargin::Union{AbsoluteLength, Nothing} = 15mm
    bottommargin::Union{AbsoluteLength, Nothing} = 15mm
    rightmargin::Union{AbsoluteLength, Nothing} = 15mm
    topmargin::Union{AbsoluteLength, Nothing} = 15mm
    legendfont::Union{Font, Nothing} = font(25, FONT_CHOICE)
    titlefont::Union{Font, Nothing} = font(34,  FONT_CHOICE)
    tickfont::Union{Font, Nothing} = font(20,   FONT_CHOICE)
    guidefont::Union{Font, Nothing} = font(30,  FONT_CHOICE)
end

function create_plot(spec::PlotSpec; use_ylims::Bool = true, use_xlims::Bool = true)
    p = plot(legend=spec.legend, xlabel=spec.xlabel, ylabel=spec.ylabel, title=spec.title)
    df = CSV.read(spec.data_filepath, DataFrame)
    for detail in spec.details
        # Read the CSV file
        data = filter(row -> row.condition == detail.condition, df)
        if detail.species != ""
            data = filter(row -> row.species == detail.species, data)
        end
        if nrow(data) == 0
            error("No data found for $(detail.condition) in $(spec.data_filepath)")
        end

        # Process the dataset
        grouped = groupby(data, :generation)
        
        # Initialize vectors for generations, means, and confidence intervals
        generations = Int[]
        means = Float64[]
        lower_cis = Float64[]
        upper_cis = Float64[]

        for group in grouped
            gen = group[1, :generation]  # Extracting the generation value
            group_measurements = group[:, Symbol(detail.metric)]  # Extracting scores for this generation

            push!(generations, gen)
            push!(means, mean(group_measurements))

            ci = get_bootstrapped_confidence_intervals(group_measurements, DEFAULT_CONFIDENCE)
            push!(lower_cis, ci["lower_confidence"])
            push!(upper_cis, ci["upper_confidence"])
        end

        plot!(
            p, generations, means, 
            ribbon = (means .- lower_cis, upper_cis .- means), 
            fillalpha = 0.35, 
            label = detail.label,
            color = detail.color, 
            size=spec.size, 
            leftmargin=spec.leftmargin, 
            bottommargin=spec.bottommargin, 
            rightmargin=spec.rightmargin, 
            topmargin=spec.topmargin,
            ylims = spec.ylims,
            xlims = spec.xlims,
            legendfont = spec.legendfont,
            titlefont = spec.titlefont,
            tickfont = spec.tickfont,
            guidefont = spec.guidefont,
        )
    end

    savefig(p, "$(spec.save_path)")
end

function create_plot(spec::PlotSpec; use_ylims::Bool = true, use_xlims::Bool = true)
    p = plot(legend=spec.legend, xlabel=spec.xlabel, ylabel=spec.ylabel, title=spec.title)
    df = CSV.read(spec.data_filepath, DataFrame)
    
    # Create a vector to store the details along with their highest mean in the last generation
    detail_means = []

    for detail in spec.details
        # Read the CSV file
        data = filter(row -> row.condition == detail.condition, df)
        if detail.species != ""
            data = filter(row -> row.species == detail.species, data)
        end
        if nrow(data) == 0
            error("No data found for $(detail.condition) in $(spec.data_filepath)")
        end

        # Process the dataset
        grouped = groupby(data, :generation)
        
        # Initialize vectors for generations, means, and confidence intervals
        generations = Int[]
        means = Float64[]

        for group in grouped
            gen = group[1, :generation]  # Extracting the generation value
            group_measurements = group[:, Symbol(detail.metric)]  # Extracting scores for this generation

            push!(generations, gen)
            push!(means, mean(group_measurements))
        end

        # Get the highest mean value in the last generation
        last_generation_mean = means[end]
        push!(detail_means, (detail, last_generation_mean))
    end

    # Sort the details by the highest mean value in the last generation in descending order
    sorted_details = sort(detail_means, by = x -> -x[2])

    # Plot the details in the sorted order
    for (detail, _) in sorted_details
        # Read the CSV file
        data = filter(row -> row.condition == detail.condition, df)
        if detail.species != ""
            data = filter(row -> row.species == detail.species, data)
        end
        if nrow(data) == 0
            error("No data found for $(detail.condition) in $(spec.data_filepath)")
        end

        # Process the dataset
        grouped = groupby(data, :generation)
        
        # Initialize vectors for generations, means, and confidence intervals
        generations = Int[]
        means = Float64[]
        lower_cis = Float64[]
        upper_cis = Float64[]

        for group in grouped
            gen = group[1, :generation]  # Extracting the generation value
            group_measurements = group[:, Symbol(detail.metric)]  # Extracting scores for this generation

            push!(generations, gen)
            push!(means, mean(group_measurements))

            ci = get_bootstrapped_confidence_intervals(group_measurements, DEFAULT_CONFIDENCE)
            push!(lower_cis, ci["lower_confidence"])
            push!(upper_cis, ci["upper_confidence"])
        end

        plot!(
            p, generations, means, 
            ribbon = (means .- lower_cis, upper_cis .- means), 
            fillalpha = 0.35, 
            label = detail.label,
            color = detail.color, 
            size=spec.size, 
            leftmargin=spec.leftmargin, 
            bottommargin=spec.bottommargin, 
            rightmargin=spec.rightmargin, 
            topmargin=spec.topmargin,
            ylims = spec.ylims,
            xlims = spec.xlims,
            legendfont = spec.legendfont,
            titlefont = spec.titlefont,
            tickfont = spec.tickfont,
            guidefont = spec.guidefont,
        )
    end

    savefig(p, "$(spec.save_path)")
end


include("experiment.jl")
#
include("coo_easy.jl")
include("coo_hard.jl")
include("collision_game.jl")
include("modes_two.jl")
include("modes_three.jl")
include("meu_paper.jl")
include("dct_short.jl")
include("dct_long.jl")
include("cg_new.jl")

function plot_all()
    plot_cg_coop()
    plot_cg_comp()
    plot_cg_ctrl()
    plot_cg_cycle()
    plot_cg_mix()
    plot_cg_compcycle()
    plot_coo_easy()
    plot_coo_hard()
    plot_dct_long()
    plot_dct_short()
    create_bin_pred_plots()
    plot_modes_change()
    plot_modes_metrics()
    plot_modes_fitness()
    plot_3modes_eplen()
    plot_3modes_change()
    plot_3modes_novelty()
    plot_3modes_complexity()
    plot_3modes_ecology()
    plot_3modes_coverage()
    plot_3modes_fitness()
end
    plot_dct_short()
#plot_all()
    #create_bin_pred_plots()
    #plot_modes_change()
    #plot_modes_metrics()
    #plot_modes_fitness()
    #plot_3modes_eplen()
    #plot_3modes_change()
    #plot_3modes_novelty()
    #plot_3modes_complexity()
    #plot_3modes_ecology()
    #plot_3modes_coverage()
    #plot_3modes_fitness()
#plot_coo_paper()
#plot_dct_paper()
function copy_png_files(src::AbstractString, dest::AbstractString, levels::Int = 1)
    # Create the destination directory if it doesn't exist
    if !isdir(dest)
        mkpath(dest)
    end

    # Recursively find all .png files in the source directory
    #png_files = levels == 1 ? glob("**/*.png", src) : glob("**/**/*.png", src)
    png_files = glob("**/*.png", src)

    for file in png_files
        # Compute the relative path of the file from the source directory
        relative_path = relpath(file, src)
        
        # Compute the destination path
        dest_path = joinpath(dest, relative_path)
        
        # Create the destination directory if it doesn't exist
        dest_dir = dirname(dest_path)
        if !isdir(dest_dir)
            mkpath(dest_dir)
        end

        # Copy the file
        cp(file, dest_path, force=true)
    end

    println("Copying complete.")
end

# Usage example
src_dir = "data/agg"
dest_dir = "plots"
copy_png_files(src_dir, dest_dir)

src_dir = "data/agg/bin_pred"
dest_dir = "plots/bin_pred"
copy_png_files(src_dir, dest_dir)