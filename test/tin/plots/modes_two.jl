

function plot_modes_change()
    plot_spec = PlotSpec(
        title="2-ECO + HOPCROFT: Change", 
        details = [
            PlotDetail("change", "ctrl-hopcroft", "CONTROL", :blue),
            PlotDetail("change", "comp-hopcroft", "2-COMP", :red),
            PlotDetail("change", "coop-hopcroft", "2-COOP", :green),
        ],
        data_filepath = "$AGG_DATA_DIR/modes_two_species/modes_two_species.csv",
        save_path="$AGG_DATA_DIR/modes_two_species/change_hop.png",
        legend=:topright, 
        ylabel="Change", 
        ylims=(0.0, 8),
        xlims=(0.0, 50_000.0)
    )
    create_plot(plot_spec)

    plot_spec = PlotSpec(
        title="2-ECO + ADAPTIVE: Change", 
        details = [
            PlotDetail("change", "ctrl-hopcroft", "CONTROL", :blue),
            PlotDetail("change", "comp-age", "2-COMP", :orange),
            PlotDetail("change", "coop-age", "2-COOP", :purple),
        ],
        data_filepath = "$AGG_DATA_DIR/modes_two_species/modes_two_species.csv",
        save_path="$AGG_DATA_DIR/modes_two_species/change_ko.png",
        legend=:topright, 
        ylabel="Change", 
        ylims=(0.0, 8),
        xlims=(0.0, 50_000.0)
    )
    create_plot(plot_spec)
end

function plot_modes_metrics()
    metrics = ["change", "complexity", "coverage", "ecology", "eplen", "novelty"]
    labels = ["Change", "State Count", "Coverage", "Ecology", "Episode Length", "Novelty"]
    all_ylims = [
        (0.0, 8), (0.0, 100), (0.0, 1.0), (0.0, 4.0), (0.0, 30), (0.0, 8.0)
    ]
    all_legends = [
        #:topright, :topleft, :bottomleft, :topright, :topright, :bottomleft, :topright
        :topright, :topleft, :bottomleft, :topright, :topright, :topright
    ]

    filepaths = [
        "change_hop.png", "complexity_hop.png", "coverage_hop.png", "ecology_hop.png", "eplen_hop.png", "novelty_hop.png",
        "change_ko.png", "complexity_ko.png", "coverage_ko.png", "ecology_ko.png", "eplen_ko.png", "novelty_ko.png"
    ]
    
    for (i, (metric, label, ylims, legend)) in enumerate(zip(metrics, labels, all_ylims, all_legends))
        println("Plotting $metric, $label, $ylims, $legend")
        if metric == "complexity"
            hop_ylabel = "Hopcroft State Count"
            adaptive_ylabel = "Adaptive State Count"
        else
            hop_ylabel = label
            adaptive_ylabel = label
        end
        plot_spec_hop = PlotSpec(
            title="2-ECO + HOPCROFT: $label", 
            details = [
                PlotDetail(metric, "ctrl-hopcroft", "CONTROL", :blue),
                PlotDetail(metric, "comp-hopcroft", "2-COMP", :red),
                PlotDetail(metric, "coop-hopcroft", "2-COOP", :green),
            ],
            data_filepath = "$AGG_DATA_DIR/modes_two_species/modes_two_species.csv",
            save_path="$AGG_DATA_DIR/modes_two_species/$(metric)_hop.png",
            legend=legend, 
            ylabel=hop_ylabel, 
            ylims=ylims,
            xlims=(0.0, 50_000.0)
        )
        create_plot(plot_spec_hop)
        
        plot_spec_ko = PlotSpec(
            title="2-ECO + ADAPTIVE: $label", 
            details = [
                PlotDetail(metric, "ctrl-hopcroft", "CONTROL", :blue),
                PlotDetail(metric, "comp-age", "2-COMP", :orange),
                PlotDetail(metric, "coop-age", "2-COOP", :purple),
            ],
            data_filepath = "$AGG_DATA_DIR/modes_two_species/modes_two_species.csv",
            save_path="$AGG_DATA_DIR/modes_two_species/$(metric)_ko.png",
            legend=legend, 
            ylabel=adaptive_ylabel, 
            ylims=ylims,
            xlims=(0.0, 50_000.0)
        )
        create_plot(plot_spec_ko)
    end
end

function plot_modes_fitness()
    plot_spec = PlotSpec(
        title="2-ECO + ALL: Fitness", 
        details = [
            PlotDetail("fitness", "coop-age", "2-COOP + ADAPTIVE", :purple),
            PlotDetail("fitness", "coop-hopcroft", "2-COOP + HOPCROFT", :green),
            PlotDetail("fitness", "comp-age", "2-COMP + ADAPTIVE", :orange),
            PlotDetail("fitness", "comp-hopcroft", "2-COMP + HOPCROFT", :red),
        ],
        data_filepath = "$AGG_DATA_DIR/modes_two_species/modes_two_species.csv",
        save_path="$AGG_DATA_DIR/modes_two_species/fitness.png",
        legend=:bottomright, 
        ylabel="Fitness", 
        ylims=(0.0, 1),
        xlims=(0.0, 50_000.0)
    )
    create_plot(plot_spec)
end
