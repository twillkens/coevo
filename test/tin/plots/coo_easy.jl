function plot_coo_easy()
    ga_plot_spec = PlotSpec(
        title="COO-EASY + GAs: Minimum Dimension Value", 
        details = [
            PlotDetail("utility", "cfs_std", "CFS + STD", :purple),
            PlotDetail("utility", "doc_std", "DOC + STD", :green),
            PlotDetail("utility", "roulette", "ROULETTE", :blue),
            PlotDetail("utility", "control", "CONTROL", :red)
        ],
        data_filepath = "$AGG_DATA_DIR/coo_easy/coo_easy.csv",
        save_path="$AGG_DATA_DIR/coo_easy/ga.png",
        legend=:topleft, 
        ylabel="Minimum Dimension Value", 
        ylims=(0.0, 17.0),
        xlims=(0.0, 500.0)
    )

    phc_plot_spec = PlotSpec(
        title="COO-EASY + P-PHC: Minimum Dimension Value", 
        details = [
            PlotDetail("utility", "p_phc_p_frs", "P-PHC-P-FRS", :teal),
            PlotDetail("utility", "p_phc_p_uhs", "P-PHC-P-UHS", :brown),
            PlotDetail("utility", "p_phc", "P-PHC", :grey),
            PlotDetail("utility", "control", "CONTROL", :red)
        ],
        data_filepath = "$AGG_DATA_DIR/coo_easy/coo_easy.csv",
        save_path="$AGG_DATA_DIR/coo_easy/phc.png",
        legend=:topleft, 
        ylabel="Minimum Dimension Value", 
        ylims=(0.0, 17.0),
        xlims=(0.0, 500.0)
    )

    qmeu_plot_spec = PlotSpec(
        title="COO-EASY + QueMEU-α: Minimum Dimension Value", 
        details = [
            PlotDetail("utility", "doc_qmeu_fast", "DOC + Q-α-FAST", :magenta),
            PlotDetail("utility", "cfs_qmeu_fast", "CFS + Q-α-FAST", :navy),
            PlotDetail("utility", "doc_qmeu_slow", "DOC + Q-α-SLOW", :lime),
            PlotDetail("utility", "cfs_qmeu_slow", "CFS + Q-α-SLOW", :olive),
            PlotDetail("utility", "control", "CONTROL", :red)
        ],
        data_filepath = "$AGG_DATA_DIR/coo_easy/coo_easy.csv",
        save_path="$AGG_DATA_DIR/coo_easy/qmeu.png",
        legend=:topleft, 
        ylabel="Minimum Dimension Value", 
        ylims=(0.0, 17.0),
        xlims=(0.0, 500.0)
    )
    create_plot(ga_plot_spec)
    create_plot(phc_plot_spec)  
    create_plot(qmeu_plot_spec)
end
