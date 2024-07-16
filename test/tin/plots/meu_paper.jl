function plot_coa_paper()
    data_filepath = "$AGG_DATA_DIR/coa_paper/coa_paper.csv"
    metric = "score"
    ylabel = "Minimum Dimension Value"
    plot_spec = PlotSpec(
        title="COA-HARD: Minimum Dimension Value", 
        details = [
            PlotDetail(metric, "qmeu", "QueMEU", :green),
            PlotDetail(metric, "advanced", "ADVANCED", :blue),
            PlotDetail(metric, "standard", "STANDARD", :red),
        ],
        data_filepath = data_filepath,
        save_path="$AGG_DATA_DIR/coa_paper/$(metric).png",
        #legendfont = font(15,   FONT_CHOICE),
        legend=:topleft, 
        ylabel=ylabel, 
        ylims=(0.0, 4.2),
        xlims=(0.0, 500.0)
    )
    create_plot(plot_spec)
end

function plot_coo_paper()
    data_filepath = "$AGG_DATA_DIR/coo_paper/coo_paper.csv"
    metric = "score"
    ylabel = "Minimum Dimension Value"
    plot_spec = PlotSpec(
        title="COO-HARD: Minimum Dimension Value", 
        details = [
            PlotDetail(metric, "qmeu", "QueMEU", :green),
            PlotDetail(metric, "advanced", "ADVANCED", :blue),
            PlotDetail(metric, "standard", "STANDARD", :red),
        ],
        data_filepath = data_filepath,
        save_path="$AGG_DATA_DIR/coo_paper/$(metric).png",
        #legendfont = font(15,   FONT_CHOICE),
        legend=:topleft, 
        ylabel=ylabel, 
        ylims=(0.0, 4.2),
        xlims=(0.0, 500)
    )
    create_plot(plot_spec)
end

function plot_dct_paper()
    data_filepath = "$AGG_DATA_DIR/dct_paper/dct_paper.csv"
    metric = "score"
    ylabel = "Expected Utility"
    plot_spec = PlotSpec(
        title="DCT-149: Expected Utility", 
        details = [
            PlotDetail(metric, "qmeu", "QueMEU", :green),
            PlotDetail(metric, "advanced", "ADVANCED", :blue),
            PlotDetail(metric, "standard", "STANDARD", :red),
        ],
        data_filepath = data_filepath,
        save_path="$AGG_DATA_DIR/dct_paper/$(metric).png",
        #legendfont = font(15,   FONT_CHOICE),
        legend=:bottomright, 
        ylabel=ylabel, 
        ylims=(0.15, 0.62),
        xlims=(0.0, 200.0)
    )
    create_plot(plot_spec)
end
