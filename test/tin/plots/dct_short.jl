
function plot_dct_short()
    ga_plot_spec = PlotSpec(
        title="DCT-149 + GAs: Expected Utility", 
        details = [
            PlotDetail("utility", "cfs_std", "CFS + STD", :purple),
            PlotDetail("utility", "doc_std", "DOC + STD", :green),
            PlotDetail("utility", "roulette", "ROULETTE", :blue),
            PlotDetail("utility", "control", "CONTROL", :red)
        ],
        data_filepath = "$AGG_DATA_DIR/dct_short/dct_short.csv",
        save_path="$AGG_DATA_DIR/dct_short/ga.png",
        legend=:right, 
        legendfont = font(18, FONT_CHOICE),
        ylabel="Expected Utility", 
        ylims=(0.0, 0.61),
        xlims=(0.0, 200.0)
    )

    phc_plot_spec = PlotSpec(
        title="DCT-149 + P-PHC: Expected Utility", 
        details = [
            PlotDetail("utility", "p_phc_p_uhs", "P-PHC-P-UHS", :brown),
            PlotDetail("utility", "p_phc_p_frs", "P-PHC-P-FRS", :orange),
            PlotDetail("utility", "control", "CONTROL", :red),
            PlotDetail("utility", "p_phc", "P-PHC", :grey)
        ],
        data_filepath = "$AGG_DATA_DIR/dct_short/dct_short.csv",
        save_path="$AGG_DATA_DIR/dct_short/phc.png",
        legend=:right, 
        ylabel="Expected Utility", 
        ylims=(0.0, 0.61),
        xlims=(0.0, 200.0),
        legendfont = font(18, FONT_CHOICE)
        #legendfont = font(20, FONT_CHOICE)
    )

    qmeu_adv_plot_spec = PlotSpec(
        title="DCT-149 + QueMEU-γ: Expected Utility", 
        details = [
            PlotDetail("utility", "doc_qmeu_alpha", "DOC + Q-γ", :orange),
            PlotDetail("utility", "cfs_qmeu_alpha", "CFS + Q-γ", :black),
            PlotDetail("utility", "control", "CONTROL", :red)
        ],
        data_filepath = "$AGG_DATA_DIR/dct_short/dct_short.csv",
        save_path="$AGG_DATA_DIR/dct_short/qmeu_adv.png",
        legend=:right, 
        ylabel="Expected Utility", 
        ylims=(0.0, 0.61),
        xlims=(0.0, 200.0),
        #legendfont = font(20, FONT_CHOICE)
    )

    create_plot(ga_plot_spec)
    create_plot(phc_plot_spec)
    create_plot(qmeu_adv_plot_spec)
end