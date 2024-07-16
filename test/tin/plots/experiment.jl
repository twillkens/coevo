Base.@kwdef struct ConditionSpec
    name::String
    label::String
    color::Symbol
end

Base.@kwdef struct PlotSkeleton
    experiment_label::String
    conditions_label::String
    acronym::String
    tag::String
    conditions::Vector{ConditionSpec}
end

Base.@kwdef struct LegendSpec
    legend::Symbol
    legend_font = font(20, FONT_CHOICE)
end

Base.@kwdef struct MetricSpec
    name::String
    label::String
    experiment::String
    ylims::Tuple{Float64, Float64}
    xlims::Tuple{Float64, Float64}
    legend_specs::Dict{String, LegendSpec}
end


const EXPECTIONS = Dict(
    ("phc", "change") => (0.0, 100.0),
    ("phc", "novelty") => (0.0, 100.0),
    ("phc", "ecology") => (0.0, 8.0)
)
const CHANGE = MetricSpec(
    name = "change",
    label = "Change",
    experiment = "bin_pred",
    xlims = (0.0, 10_000.0),
    ylims = (0.0, 3.0),
    legend_specs = Dict(
        "ga" => LegendSpec(legend = :bottomright, legend_font = font(19, FONT_CHOICE)),
        "phc" => LegendSpec(legend = :right),
        "qmeu_alpha" => LegendSpec(legend = :bottomright, legend_font = font(18, FONT_CHOICE)),
        "qmeu_beta" => LegendSpec(legend = :bottomright),
        "qmeu_gamma" => LegendSpec(legend = :bottomright)
    )
)

const NOVELTY = MetricSpec(
    name = "novelty",
    label = "Novelty",
    experiment = "bin_pred",
    xlims = (0.0, 10_000.0),
    ylims = (0.0, 3.0),
    legend_specs = Dict(
        "ga" => LegendSpec(legend = :bottomright, legend_font = font(19, FONT_CHOICE)),
        "phc" => LegendSpec(legend = :right),
        "qmeu_alpha" => LegendSpec(legend = :bottomright, legend_font = font(18, FONT_CHOICE)),
        "qmeu_beta" => LegendSpec(legend = :bottomright),
        "qmeu_gamma" => LegendSpec(legend = :bottomright)
    )
)

const ECOLOGY = MetricSpec(
    name = "ecology",
    label = "Ecology",
    experiment = "bin_pred",
    xlims = (0.0, 10_000.0),
    ylims = (0.0, 3.0),
    legend_specs = Dict(
        "ga" => LegendSpec(legend = :topright),
        "phc" => LegendSpec(legend = :right),
        "qmeu_alpha" => LegendSpec(legend = :topright),
        "qmeu_beta" => LegendSpec(legend = :topright),
        "qmeu_gamma" => LegendSpec(legend = :topright)
    )
)


const UTILITY = MetricSpec(
    name = "utility_128",
    label = "Expected Utility",
    experiment = "bin_pred",
    xlims = (0.0, 10_000.0),
    ylims = (0.4, 0.67),
    legend_specs = Dict(
        "ga" => LegendSpec(legend = :topright),
        "phc" => LegendSpec(legend = :topright),
        "qmeu_alpha" => LegendSpec(legend = :right, legend_font = font(15, FONT_CHOICE)),
        "qmeu_beta" => LegendSpec(legend = :right),
        "qmeu_gamma" => LegendSpec(legend = :right)
    )
)

const FULL_COUNT = MetricSpec(
    name = "full_complexity",
    label = "Total State Count",
    experiment = "bin_pred",
    xlims = (0.0, 10_000.0),
    ylims = (0.0, 400),
    legend_specs = Dict(
        "ga" => LegendSpec(legend = :topright),
        "phc" => LegendSpec(legend = :topleft),
        "qmeu_alpha" => LegendSpec(legend = :topleft),
        "qmeu_beta" => LegendSpec(legend = :topleft),
        "qmeu_gamma" => LegendSpec(legend = :topleft)
    )
)

const HOP_COUNT = MetricSpec(
    name = "hopcroft_complexity",
    label = "Hopcroft State Count",
    experiment = "bin_pred",
    xlims = (0.0, 10_000.0),
    ylims = (0.0, 400),
    legend_specs = Dict(
        "ga" => LegendSpec(legend = :topright),
        "phc" => LegendSpec(legend = :topright),
        "qmeu_alpha" => LegendSpec(legend = :topright),
        "qmeu_beta" => LegendSpec(legend = :topright),
        "qmeu_gamma" => LegendSpec(legend = :topright)
    )
)

const MODES_COUNT = MetricSpec(
    name = "modes_complexity",
    label = "Adaptive State Count",
    experiment = "bin_pred",
    xlims = (0.0, 10_000.0),
    ylims = (0.0, 400),
    legend_specs = Dict(
        "ga" => LegendSpec(legend =         :topright),
        "phc" => LegendSpec(legend =        :topright),
        "qmeu_alpha" => LegendSpec(legend = :topright),
        "qmeu_beta" => LegendSpec(legend =  :topright),
        "qmeu_gamma" => LegendSpec(legend = :topright)
    )
)


const BIN_PRED_SKELETONS = [
    PlotSkeleton(
        experiment_label = "MM-BPT-128",
        conditions_label = "GAs",
        acronym = "ga",
        tag = "",
        conditions = [
            ConditionSpec("cfs_std", "CFS + STD", :purple),
            ConditionSpec("doc_std", "DOC + STD", :green),
            ConditionSpec("roulette", "ROULETTE", :blue),
            ConditionSpec("control", "CONTROL", :red)
        ]
    ),
    PlotSkeleton(
        experiment_label = "MM-BPT-128",
        conditions_label = "P-PHC",
        acronym = "phc",
        tag = "",
        conditions = [
            ConditionSpec("p_phc_ups", "P-PHC-P-UHS", :brown),
            ConditionSpec("p_phc_frs", "P-PHC-P-FRS", :teal),
            ConditionSpec("control", "CONTROL", :red),
            ConditionSpec("p_phc", "P-PHC", :grey)
        ]
    ),
    PlotSkeleton(
        experiment_label = "MM-BPT-128",
        conditions_label = "QueMEU-α",
        acronym = "qmeu_alpha",
        tag = "",
        conditions = [
            ConditionSpec("cfs_qmeu_slow", "CFS + Q-α-SLOW", :olive),
            ConditionSpec("doc_qmeu_slow", "DOC + Q-α-SLOW", :lime),
            ConditionSpec("doc_qmeu_fast", "DOC + Q-α-FAST", :magenta),
            ConditionSpec("cfs_qmeu_fast", "CFS + Q-α-FAST", :navy),
            ConditionSpec("control", "CONTROL", :red)
        ]
    ),
    PlotSkeleton(
        experiment_label = "MM-BPT-128",
        conditions_label = "QueMEU-β",
        acronym = "qmeu_beta",
        tag = "",
        conditions = [
            ConditionSpec("tourn_qmeu", "CFS + Q-β", :firebrick),
            ConditionSpec("doc_qmeu_beta", "DOC + Q-β", :seagreen),
            ConditionSpec("control", "CONTROL", :red)
        ]
    ),
    PlotSkeleton(
        experiment_label = "MM-BPT-128",
        conditions_label = "QueMEU-γ",
        acronym = "qmeu_gamma",
        tag = "",
        conditions = [
            ConditionSpec("doc_qmeu_alpha", "DOC + Q-γ", :orange),
            ConditionSpec("cfs_qmeu_alpha", "CFS + Q-γ", :black),
            ConditionSpec("control", "CONTROL", :red)
        ]
    ),
    PlotSkeleton(
        experiment_label = "MM-BPT-128",
        conditions_label = "DOC + QueMEU-γ",
        acronym = "qmeu_gamma",
        tag = "doc",
        conditions = [
            ConditionSpec("doc_qmeu_alpha", "DOC + Q-γ", :orange),
            ConditionSpec("control", "CONTROL", :red)
        ]
    ),
    PlotSkeleton(
        experiment_label = "MM-BPT-128",
        conditions_label = "CFS + QueMEU-γ",
        acronym = "qmeu_gamma",
        tag = "cfs",
        conditions = [
            ConditionSpec("cfs_qmeu_alpha", "CFS + Q-γ", :orange),
            ConditionSpec("control", "CONTROL", :red)
        ]
    )
]

function PlotDetail(metric_spec::MetricSpec, condition::ConditionSpec)
    return PlotDetail(metric_spec.name, condition.name, condition.label, condition.color)
end

function PlotSpec(metric_spec::MetricSpec, skeleton::PlotSkeleton)
    experiment = metric_spec.experiment
    acronym = skeleton.acronym
    metric = metric_spec.name
    tag = skeleton.tag
    mkpath("$AGG_DATA_DIR/$experiment/$metric")
    data_filepath = "$AGG_DATA_DIR/$experiment/$experiment.csv"
    save_path = "$AGG_DATA_DIR/$experiment/$metric/$(acronym)_$(metric)_$(tag).png"
    details = [PlotDetail(metric_spec, condition) for condition in skeleton.conditions]
    legend_spec = metric_spec.legend_specs[acronym]
    if (acronym, metric) in keys(EXPECTIONS)
        ylims = EXPECTIONS[(acronym, metric)]
    else
        ylims = metric_spec.ylims
    end
    title = "$(skeleton.experiment_label) + $(skeleton.conditions_label): $(metric_spec.label)"
    plot_spec = PlotSpec(
        title = title,
        details = details,
        data_filepath = data_filepath,
        save_path = save_path,
        legend = legend_spec.legend,
        ylabel = metric_spec.label,
        ylims = ylims,
        xlims = metric_spec.xlims,
        legendfont = legend_spec.legend_font
    )
    return plot_spec
end

using StatsBase

function create_bin_pred_plots()
    metric_specs = [CHANGE, NOVELTY, ECOLOGY, UTILITY, FULL_COUNT, HOP_COUNT, MODES_COUNT]
    for metric_spec in metric_specs
        experiment = metric_spec.experiment
        data_filepath = "$AGG_DATA_DIR/$experiment/$experiment.csv"
        df = CSV.read(data_filepath, DataFrame)
        for skeleton in BIN_PRED_SKELETONS
            plot_spec = PlotSpec(metric_spec, skeleton)
            create_plot(plot_spec; use_ylims = true) #ylims = ylims)
        end
    end
end