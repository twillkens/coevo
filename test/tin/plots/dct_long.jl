
function plot_dct_long()
    qmeu_adv_plot_spec = PlotSpec(
        title="DCT-149 + QueMEU-γ: Expected Utility", 
        details = [
            PlotDetail("utility", "doc_qmeu_alpha", "DOC + Q-γ", :orange),
            PlotDetail("utility", "cfs_qmeu_alpha", "CFS + Q-γ", :black),
        ],
        data_filepath = "$AGG_DATA_DIR/dct_long/dct_long.csv",
        save_path="$AGG_DATA_DIR/dct_long/dct_long.png",
        legend=:bottomright, 
        ylabel="Expected Utility", 
        ylims=(0.3, 0.65),
        xlims=(0.0, 1_000.0),
        #legendfont = font(20, FONT_CHOICE)
    )

    create_plot(qmeu_adv_plot_spec)
end