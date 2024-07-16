
function plot_3modes_change()
    data_filepath = "$AGG_DATA_DIR/modes_three_species/modes_three_species.csv"
    metric = "change"
    ylabel = "Change"
    plot_spec = PlotSpec(
        title="3-ECO + HOPCROFT: $ylabel", 
        details = [
            PlotDetail("change", "3ctrl-hopcroft", "CONTROL", :blue),
            PlotDetail("change", "3comp-hopcroft", "3-COMP", :red),
            PlotDetail("change", "3mix-hopcroft", "3-MIX", :green),
        ],
        data_filepath = data_filepath,
        save_path="$AGG_DATA_DIR/modes_three_species/$(metric)_hop.png",
        legend=:topright, 
        ylabel=ylabel, 
        ylims=(0.0, 10),
        xlims=(0.0, 50_000.0)
    )
    create_plot(plot_spec)
    plot_spec = PlotSpec(
        title="3-ECO + ADAPTIVE: $ylabel", 
        details = [
            PlotDetail("change", "3ctrl-hopcroft", "CONTROL", :blue),
            PlotDetail("change", "3comp-age", "3-COMP", :orange),
            PlotDetail("change", "3mix-age", "3-MIX", :purple),
        ],
        data_filepath = data_filepath,
        save_path="$AGG_DATA_DIR/modes_three_species/$(metric)_modes.png",
        legend=:topright, 
        ylabel=ylabel, 
        ylims=(0.0, 10),
        xlims=(0.0, 50_000.0)
    )
    create_plot(plot_spec)
end

function plot_3modes_novelty()
    data_filepath = "$AGG_DATA_DIR/modes_three_species/modes_three_species.csv"
    metric = "novelty"
    ylabel = "Novelty"
    plot_spec = PlotSpec(
        title="3-ECO + HOPCROFT: $ylabel", 
        details = [
            PlotDetail(metric, "3ctrl-hopcroft", "CONTROL", :blue),
            PlotDetail(metric, "3comp-hopcroft", "3-COMP", :red),
            PlotDetail(metric, "3mix-hopcroft", "3-MIX", :green),
        ],
        data_filepath = data_filepath,
        save_path="$AGG_DATA_DIR/modes_three_species/$(metric)_hop.png",
        legend=:topright, 
        ylabel=ylabel, 
        ylims=(0.0, 10),
        xlims=(0.0, 50_000.0)
    )
    create_plot(plot_spec)
    plot_spec = PlotSpec(
        title="3-ECO + ADAPTIVE: $ylabel", 
        details = [
            PlotDetail(metric, "3ctrl-hopcroft", "CONTROL", :blue),
            PlotDetail(metric, "3comp-age", "3-COMP", :orange),
            PlotDetail(metric, "3mix-age", "3-MIX", :purple),
        ],
        data_filepath = data_filepath,
        save_path="$AGG_DATA_DIR/modes_three_species/$(metric)_modes.png",
        legend=:topright, 
        ylabel=ylabel, 
        ylims=(0.0, 10),
        xlims=(0.0, 50_000.0)
    )
    create_plot(plot_spec)

end


function plot_3modes_complexity()
    data_filepath = "$AGG_DATA_DIR/modes_three_species/modes_three_species.csv"
    metric = "complexity"
    ylabel = "State Count"
    plot_spec = PlotSpec(
        title="3-ECO + HOPCROFT: $ylabel", 
        details = [
            PlotDetail(metric, "3mix-hopcroft", "3-MIX", :green),
            PlotDetail(metric, "3ctrl-hopcroft", "CONTROL", :blue),
            PlotDetail(metric, "3comp-hopcroft", "3-COMP", :red),
        ],
        data_filepath = data_filepath,
        save_path="$AGG_DATA_DIR/modes_three_species/$(metric)_hop.png",
        legend=:topleft, 
        ylabel="Hopcroft State Count", 
        ylims=(0.0, 100),
        xlims=(0.0, 50_000.0)
    )
    create_plot(plot_spec)
    plot_spec = PlotSpec(
        title="3-ECO + ADAPTIVE: $ylabel", 
        details = [
            PlotDetail(metric, "3ctrl-hopcroft", "CONTROL", :blue),
            PlotDetail(metric, "3mix-age", "3-MIX", :purple),
            PlotDetail(metric, "3comp-age", "3-COMP", :orange),
        ],
        data_filepath = data_filepath,
        save_path="$AGG_DATA_DIR/modes_three_species/$(metric)_modes.png",
        legend=:topleft, 
        ylabel="Adaptive State Count", 
        ylims=(0.0, 100),
        xlims=(0.0, 50_000.0)
    )
    create_plot(plot_spec)
end


function plot_3modes_ecology()
    data_filepath = "$AGG_DATA_DIR/modes_three_species/modes_three_species.csv"
    metric = "ecology"
    ylabel = "Ecology"
    plot_spec = PlotSpec(
        title="3-ECO + HOPCROFT: $ylabel", 
        details = [
            PlotDetail(metric, "3ctrl-hopcroft", "CONTROL", :blue),
            PlotDetail(metric, "3comp-hopcroft", "3-COMP", :red),
            PlotDetail(metric, "3mix-hopcroft", "3-MIX", :green),
        ],
        data_filepath = data_filepath,
        save_path="$AGG_DATA_DIR/modes_three_species/$(metric)_hop.png",
        legend=:topright, 
        ylabel=ylabel, 
        ylims=(0.0, 2),
        xlims=(0.0, 50_000.0)
    )
    create_plot(plot_spec)
    plot_spec = PlotSpec(
        title="3-ECO + ADAPTIVE: $ylabel", 
        details = [
            PlotDetail(metric, "3ctrl-hopcroft", "CONTROL", :blue),
            PlotDetail(metric, "3comp-age", "3-COMP", :orange),
            PlotDetail(metric, "3mix-age", "3-MIX", :purple),
        ],
        data_filepath = data_filepath,
        save_path="$AGG_DATA_DIR/modes_three_species/$(metric)_modes.png",
        legend=:topright, 
        ylabel=ylabel, 
        ylims=(0.0, 2),
        xlims=(0.0, 50_000.0)
    )
    create_plot(plot_spec)
end

function plot_3modes_coverage()
    data_filepath = "$AGG_DATA_DIR/modes_three_species/modes_three_species.csv"
    metric = "coverage"
    ylabel = "Coverage"
    plot_spec = PlotSpec(
        title="3-ECO + HOPCROFT: $ylabel", 
        details = [
            PlotDetail(metric, "3comp-hopcroft", "3-COMP", :red),
            PlotDetail(metric, "3ctrl-hopcroft", "CONTROL", :blue),
            PlotDetail(metric, "3mix-hopcroft", "3-MIX", :green),
            PlotDetail(metric, "3mix-hopcroft", "3-MIX + MUTUALIST", :black, "symbiote"),
        ],
        data_filepath = data_filepath,
        save_path="$AGG_DATA_DIR/modes_three_species/$(metric)_hop.png",
        legendfont = font(18,   FONT_CHOICE),
        legend=:bottomleft, 
        ylabel=ylabel, 
        ylims=(0.0, 1),
        xlims=(0.0, 50_000.0)
    )
    create_plot(plot_spec)
    plot_spec = PlotSpec(
        title="3-ECO + ADAPTIVE: $ylabel", 
        details = [
            PlotDetail(metric, "3comp-age", "3-COMP", :orange),
            PlotDetail(metric, "3mix-age", "3-MIX", :purple),
            PlotDetail(metric, "3ctrl-hopcroft", "CONTROL", :blue),
            PlotDetail(metric, "3mix-age", "3-MIX + MUTUALIST", :black, "symbiote"),
        ],
        data_filepath = data_filepath,
        save_path="$AGG_DATA_DIR/modes_three_species/$(metric)_modes.png",
        legend=:bottomleft, 
        ylabel=ylabel, 
        ylims=(0.0, 1),
        xlims=(0.0, 50_000.0)
    )
    create_plot(plot_spec)
end

function plot_3modes_eplen()
    data_filepath = "$AGG_DATA_DIR/modes_three_species/modes_three_species.csv"
    metric = "eplen"
    ylabel = "Episode Length"
    plot_spec = PlotSpec(
        title="3-ECO + HOPCROFT: $ylabel", 
        details = [
            PlotDetail(metric, "3comp-hopcroft", "3-COMP", :red),
            PlotDetail(metric, "3ctrl-hopcroft", "CONTROL", :blue),
            PlotDetail(metric, "3mix-hopcroft", "3-MIX", :green),
            PlotDetail(metric, "3mix-hopcroft", "3-MIX + MUTUALIST", :black, "symbiote"),
        ],
        data_filepath = data_filepath,
        save_path="$AGG_DATA_DIR/modes_three_species/$(metric)_hop.png",
        legend=:topright, 
        ylabel=ylabel, 
        ylims=(0.0, 50),
        xlims=(0.0, 50_000.0)
    )
    create_plot(plot_spec)
    plot_spec = PlotSpec(
        title="3-ECO + ADAPTIVE: $ylabel", 
        details = [
            PlotDetail(metric, "3comp-age", "3-COMP", :orange),
            PlotDetail(metric, "3mix-age", "3-MIX", :purple),
            PlotDetail(metric, "3ctrl-hopcroft", "CONTROL", :blue),
            PlotDetail(metric, "3mix-age", "3-MIX + MUTUALIST", :black, "symbiote"),
        ],
        data_filepath = data_filepath,
        save_path="$AGG_DATA_DIR/modes_three_species/$(metric)_modes.png",
        legend=:topright, 
        ylabel=ylabel, 
        ylims=(0.0, 50),
        xlims=(0.0, 50_000.0)
    )
    create_plot(plot_spec)
end

function plot_3modes_fitness()
    data_filepath = "$AGG_DATA_DIR/modes_three_species/modes_three_species.csv"
    metric = "fitness"
    ylabel = "Fitness"
    plot_spec = PlotSpec(
        title="3-ECO + ALL: $ylabel", 
        details = [
            PlotDetail(metric, "3mix-age", "3-MIX + ADAPTIVE", :purple),
            PlotDetail(metric, "3mix-hopcroft", "3-MIX + HOPCROFT", :green),
            PlotDetail(metric, "3comp-age", "3-COMP + ADAPTIVE", :orange),
            PlotDetail(metric, "3comp-hopcroft", "3-COMP + HOPCROFT", :red),
        ],
        data_filepath = data_filepath,
        save_path="$AGG_DATA_DIR/modes_three_species/$(metric).png",
        #legendfont = font(15,   FONT_CHOICE),
        legend=:bottomleft, 
        ylabel=ylabel, 
        ylims=(0.0, 1),
        xlims=(0.0, 50_000.0)
    )
    create_plot(plot_spec)
end
