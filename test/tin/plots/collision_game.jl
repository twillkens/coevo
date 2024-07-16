function plot_cg_ctrl()
    plot_spec = PlotSpec(
        title="CONTROL: Neural Network Connection Count", 
        details = [
            PlotDetail("cnavg_total_host", "control", "Total Connections", :purple),
            PlotDetail("cnavg_graph_host", "control", "Effective Connections", :orange),
        ],
        data_filepath = "$AGG_DATA_DIR/cg_ctrl/cg_ctrl.csv",
        save_path="$AGG_DATA_DIR/cg_ctrl/ctrl.png",
        legend=:topright, 
        ylabel="Connections", 
        ylims=(0.0, 170),
        xlims=(0.0, 25_000.0)
    )
    create_plot(plot_spec)
end

function plot_cg_comp()
    roulette_plot_spec = PlotSpec(
        title="2-COMP + ROULETTE: Effective Connections", 
        details = [
            PlotDetail("cnavg_graph_host", "roulette", "HOST", :blue),
            PlotDetail("cnavg_graph_parasite", "roulette", "PARASITE", :red),
            #PlotDetail("cnavg_graph_host", "control", "CONTROL", :orange),
        ],
        data_filepath = "$AGG_DATA_DIR/cg_comp/cg_comp.csv",
        save_path="$AGG_DATA_DIR/cg_comp/roulette.png",
        legend=:topright, 
        ylabel="Effective Connections", 
        ylims=(0.0, 170),
        xlims=(0.0, 25_000.0)
    )
    doc_plot_spec = PlotSpec(
        title="2-COMP + DOC: Effective Connections", 
        details = [
            PlotDetail("cnavg_graph_host", "doc", "HOST", :blue),
            PlotDetail("cnavg_graph_parasite", "doc", "PARASITE", :red),
            #PlotDetail("cnavg_graph_host", "control", "CONTROL", :orange),
        ],
        data_filepath = "$AGG_DATA_DIR/cg_comp/cg_comp.csv",
        save_path="$AGG_DATA_DIR/cg_comp/doc.png",
        legend=:topright, 
        ylabel="Effective Connections", 
        ylims=(0.0, 170),
        xlims=(0.0, 25_000.0)
    )

    create_plot(roulette_plot_spec)
    create_plot(doc_plot_spec)
end

function plot_cg_coop()
    roulette_plot_spec = PlotSpec(
        title="2-COOP + ROULETTE: Effective Connections", 
        details = [
            PlotDetail("cnavg_graph_host", "roulette", "HOST", :blue),
            PlotDetail("cnavg_graph_symbiote", "roulette", "MUTUALIST", :green),
            #PlotDetail("cnavg_graph_host", "control", "CONTROL", :orange),
        ],
        data_filepath = "$AGG_DATA_DIR/cg_coop/cg_coop.csv",
        save_path="$AGG_DATA_DIR/cg_coop/roulette.png",
        legend=:topright, 
        ylabel="Effective Connections", 
        ylims=(0.0, 170),
        xlims=(0.0, 25_000.0)
    )
    doc_plot_spec = PlotSpec(
        title="2-COOP + DOC: Effective Connections", 
        details = [
            PlotDetail("cnavg_graph_host", "doc", "HOST", :blue),
            PlotDetail("cnavg_graph_symbiote", "doc", "MUTUALIST", :green),
            #PlotDetail("cnavg_graph_host", "control", "CONTROL", :orange),
        ],
        data_filepath = "$AGG_DATA_DIR/cg_coop/cg_coop.csv",
        save_path="$AGG_DATA_DIR/cg_coop/doc.png",
        legend=:topright, 
        ylabel="Effective Connections", 
        ylims=(0.0, 170),
        xlims=(0.0, 25_000.0)
    )

    create_plot(roulette_plot_spec)
    create_plot(doc_plot_spec)
end


function plot_cg_cycle()
    roulette_plot_spec = PlotSpec(
        title="3-CYCLE + ROULETTE: Effective Connections", 
        details = [
            PlotDetail("cnavg_graph_host", "roulette", "HOST", :blue),
            PlotDetail("cnavg_graph_symbiote", "roulette", "MUTUALIST", :green),
            PlotDetail("cnavg_graph_parasite", "roulette", "PARASITE", :red),
            #PlotDetail("cnavg_graph_host", "control", "CONTROL", :orange),
        ],
        data_filepath = "$AGG_DATA_DIR/cg_cycle/cg_cycle.csv",
        save_path="$AGG_DATA_DIR/cg_cycle/roulette.png",
        legend=:topleft, 
        ylabel="Effective Connections", 
        ylims=(0.0, 170),
        xlims=(0.0, 25_000.0)
    )
    doc_plot_spec = PlotSpec(
        title="3-CYCLE + DOC: Effective Connections", 
        details = [
            PlotDetail("cnavg_graph_host", "doc", "HOST", :blue),
            PlotDetail("cnavg_graph_symbiote", "doc", "MUTUALIST", :green),
            PlotDetail("cnavg_graph_parasite", "doc", "PARASITE", :red),
            #PlotDetail("cnavg_graph_host", "control", "CONTROL", :orange),
        ],
        data_filepath = "$AGG_DATA_DIR/cg_cycle/cg_cycle.csv",
        save_path="$AGG_DATA_DIR/cg_cycle/doc.png",
        legend=:topleft, 
        ylabel="Effective Connections", 
        ylims=(0.0, 170),
        xlims=(0.0, 25_000.0)
    )

    create_plot(roulette_plot_spec)
    create_plot(doc_plot_spec)
end

function plot_cg_mix()
    roulette_plot_spec = PlotSpec(
        title="3-MIX + ROULETTE: Effective Connections", 
        details = [
            PlotDetail("cnavg_graph_host", "roulette", "HOST", :blue),
            PlotDetail("cnavg_graph_symbiote", "roulette", "MUTUALIST", :green),
            PlotDetail("cnavg_graph_parasite", "roulette", "PARASITE", :red),
            #PlotDetail("cnavg_graph_host", "control", "CONTROL", :orange),
        ],
        data_filepath = "$AGG_DATA_DIR/cg_mix/cg_mix.csv",
        save_path="$AGG_DATA_DIR/cg_mix/roulette.png",
        legend=:topleft, 
        ylabel="Effective Connections", 
        ylims=(0.0, 170),
        xlims=(0.0, 25_000.0)
    )
    doc_plot_spec = PlotSpec(
        title="3-MIX + DOC: Effective Connections", 
        details = [
            PlotDetail("cnavg_graph_host", "doc", "HOST", :blue),
            PlotDetail("cnavg_graph_symbiote", "doc", "MUTUALIST", :green),
            PlotDetail("cnavg_graph_parasite", "doc", "PARASITE", :red),
            #PlotDetail("cnavg_graph_host", "control", "CONTROL", :orange),
        ],
        data_filepath = "$AGG_DATA_DIR/cg_mix/cg_mix.csv",
        save_path="$AGG_DATA_DIR/cg_mix/doc.png",
        legend=:topleft, 
        ylabel="Effective Connections", 
        ylims=(0.0, 170),
        xlims=(0.0, 25_000.0)
    )

    roulette_fitness_plot_spec = PlotSpec(
        title="3-MIX + ROULETTE: Fitness", 
        details = [
            PlotDetail("fitavg_host", "roulette", "HOST", :blue),
            PlotDetail("fitavg_symbiote", "roulette", "MUTUALIST", :green),
            PlotDetail("fitavg_parasite", "roulette", "PARASITE", :red),
            #PlotDetail("cnavg_graph_host", "control", "CONTROL", :orange),
        ],
        data_filepath = "$AGG_DATA_DIR/cg_mix/cg_mix.csv",
        save_path="$AGG_DATA_DIR/cg_mix/roulette_fitness.png",
        legend=:topright, 
        legendfont = font(18, FONT_CHOICE),
        ylabel="Fitness", 
        ylims=(0.0, 1),
        xlims=(0.0, 25_000.0)
    )

    doc_fitness_plot_spec = PlotSpec(
        title="3-MIX + DOC: Fitness", 
        details = [
            PlotDetail("fitavg_host", "doc", "HOST", :blue),
            PlotDetail("fitavg_symbiote", "doc", "MUTUALIST", :green),
            PlotDetail("fitavg_parasite", "doc", "PARASITE", :red),
            #PlotDetail("cnavg_graph_host", "control", "CONTROL", :orange),
        ],
        data_filepath = "$AGG_DATA_DIR/cg_mix/cg_mix.csv",
        save_path="$AGG_DATA_DIR/cg_mix/doc_fitness.png",
        legend=:topright, 
        legendfont = font(18, FONT_CHOICE),
        ylabel="Fitness", 
        ylims=(0.0, 1),
        xlims=(0.0, 25_000.0)
    )

    create_plot(roulette_plot_spec)
    create_plot(doc_plot_spec)
    create_plot(roulette_fitness_plot_spec)
    create_plot(doc_fitness_plot_spec)
end

function plot_cg_compcycle()
    roulette_plot_spec = PlotSpec(
        title="3-COMP + ROULETTE: Effective Connections", 
        details = [
            PlotDetail("cnavg_graph_host", "roulette", "X", :blue),
            PlotDetail("cnavg_graph_symbiote", "roulette", "Y", :green),
            PlotDetail("cnavg_graph_parasite", "roulette", "Z", :red),
        ],
        data_filepath = "$AGG_DATA_DIR/cg_compcycle/cg_compcycle.csv",
        save_path="$AGG_DATA_DIR/cg_compcycle/roulette.png",
        legend=:topleft, 
        ylabel="Effective Connections", 
        ylims=(0.0, 170),
        xlims=(0.0, 25_000.0)
    )
    doc_plot_spec = PlotSpec(
        title="3-COMP + DOC: Effective Connections", 
        details = [
            PlotDetail("cnavg_graph_host", "doc", "X", :blue),
            PlotDetail("cnavg_graph_symbiote", "doc", "Y", :green),
            PlotDetail("cnavg_graph_parasite", "doc", "Z", :red),
        ],
        data_filepath = "$AGG_DATA_DIR/cg_compcycle/cg_compcycle.csv",
        save_path="$AGG_DATA_DIR/cg_compcycle/doc.png",
        legend=:topleft, 
        ylabel="Effective Connections", 
        ylims=(0.0, 170),
        xlims=(0.0, 25_000.0)
    )

    create_plot(roulette_plot_spec)
    create_plot(doc_plot_spec)
end


