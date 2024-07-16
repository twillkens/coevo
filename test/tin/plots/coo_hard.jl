
function plot_coo_hard()

    ga_plot_spec = PlotSpec(
        title="COO-HARD + GAs: Minimum Dimension Value", 
        details = [
            PlotDetail("utility", "cfs_std", "CFS + STD", :purple),
            PlotDetail("utility", "doc_std", "DOC + STD", :green),
            PlotDetail("utility", "roulette", "ROULETTE", :blue),
            PlotDetail("utility", "control", "CONTROL", :red),
        ],
        data_filepath = "$AGG_DATA_DIR/coo_hard/coo_hard.csv",
        save_path="$AGG_DATA_DIR/coo_hard/ga.png",
        legend=:topright, 
        ylabel="Minimum Dimension Value", 
        ylims=(0.0, 2.0),
        xlims=(0.0, 500.0)
    )

    phc_plot_spec = PlotSpec(
        title="COO-HARD + P-PHC: Minimum Dimension Value", 
        details = [
            PlotDetail("utility", "p_phc", "P-PHC", :grey),
            PlotDetail("utility", "p_phc_p_frs", "P-PHC-P-FRS", :teal),
            PlotDetail("utility", "p_phc_p_uhs", "P-PHC-P-UHS", :brown),
            PlotDetail("utility", "control", "CONTROL", :red)
        ],
        data_filepath = "$AGG_DATA_DIR/coo_hard/coo_hard.csv",
        save_path="$AGG_DATA_DIR/coo_hard/phc.png",
        legend=:topleft, 
        ylabel="Minimum Dimension Value", 
        ylims=(0.0, 2.0),
        xlims=(0.0, 500.0)
    )

    qmeu_plot_spec = PlotSpec(
        title="COO-HARD + QueMEU-α: Minimum Dimension Value", 
        details = [
            PlotDetail("utility", "cfs_qmeu_fast", "CFS + Q-α-FAST", :navy),
            PlotDetail("utility", "doc_qmeu_fast", "DOC + Q-α-FAST", :magenta),
            PlotDetail("utility", "cfs_qmeu_slow", "CFS + Q-α-SLOW", :olive),
            PlotDetail("utility", "doc_qmeu_slow", "DOC + Q-α-SLOW", :lime),
            PlotDetail("utility", "control", "CONTROL", :red)
        ],
        data_filepath = "$AGG_DATA_DIR/coo_hard/coo_hard.csv",
        save_path="$AGG_DATA_DIR/coo_hard/qmeu.png",
        legend=:topleft, 
        ylabel="Minimum Dimension Value", 
        ylims=(0.0, 2.0),
        xlims=(0.0, 500.0)
    )

    create_plot(ga_plot_spec)
    create_plot(phc_plot_spec)  
    create_plot(qmeu_plot_spec)
end


# function plot_coo_hard()
#     plot_scores(
#         "coo_hard_agg.csv",
#         [
#             PlotDetail("cfs_std", "CFS/STD", :purple),
#             PlotDetail("doc_std", "DOC/STD", :green),
#             PlotDetail("control", "CONTROL", :red),
#             PlotDetail("roulette", "ROULETTE", :blue),
#         ],
#         legend=:topright, 
#         title="COO-Hard: Genetic Algorithms", 
#         ylabel="Minimum Dimension Value", 
#         save_path="coo_hard_ga_scaled",
#         ylims=(-1.0, -1.0),
#         xlims=(0.0, 500.0)
#     )
# 
#     plot_scores(
#         "coo_hard_agg.csv",
#         [
#             PlotDetail("p_phc", "P-PHC", :grey),
#             PlotDetail("p_phc_p_frs", "P-PHC-P-FRS", :orange),
#             PlotDetail("p_phc_p_uhs", "P-PHC-P-UHS", :brown),
#             PlotDetail("control", "CONTROL", :red),
#         ],
#         legend=:topleft, 
#         title="COO-Hard: Population Pareto Hillclimbers", 
#         ylabel="Minimum Dimension Value", 
#         save_path="coo_hard_phc_scaled",
#         ylims=(-1.0, -1.0),
#         xlims=(0.0, 500.0)
#     )
# 
#     plot_scores(
#         "coo_hard_agg.csv",
#         [
#             PlotDetail("cfs_qmeu_fast", "CFS/Q-FAST", :navy),
#             PlotDetail("doc_qmeu_fast", "DOC/Q-FAST", :magenta),
#             PlotDetail("cfs_qmeu_slow", "CFS/Q-SLOW", :olive),
#             PlotDetail("doc_qmeu_slow", "DOC/Q-SLOW", :lime),
#             PlotDetail("control", "CONTROL", :red),
#         ],
#         legend=:topleft, 
#         title="COO-Hard: QueMEU Variants", 
#         ylabel="Minimum Dimension Value", 
#         save_path="coo_hard_qmeu_scaled",
#         ylims=(-1.0, -1.0),
#         xlims=(0.0, 500.0)
#     )
#     plot_scores(
#         "coo_hard_agg.csv",
#         [
#             PlotDetail("cfs_std", "CFS/STD", :purple),
#             PlotDetail("doc_std", "DOC/STD", :green),
#             PlotDetail("control", "CONTROL", :red),
#             PlotDetail("roulette", "ROULETTE", :blue),
#         ],
#         legend=:topright, 
#         title="COO-Hard: Genetic Algorithms", 
#         ylabel="Minimum Dimension Value", 
#         save_path="coo_hard_ga",
#         ylims=(0.0, 2.0),
#         xlims=(0.0, 500.0)
#     )
# 
#     plot_scores(
#         "coo_hard_agg.csv",
#         [
#             PlotDetail("p_phc", "P-PHC", :grey),
#             PlotDetail("p_phc_p_frs", "P-PHC-P-FRS", :orange),
#             PlotDetail("p_phc_p_uhs", "P-PHC-P-UHS", :brown),
#             PlotDetail("control", "CONTROL", :red),
#         ],
#         legend=:topleft, 
#         title="COO-Hard: Population Pareto Hillclimbers", 
#         ylabel="Minimum Dimension Value", 
#         save_path="coo_hard_phc",
#         ylims=(0.0, 2.0),
#         xlims=(0.0, 500.0)
#     )
# 
#     plot_scores(
#         "coo_hard_agg.csv",
#         [
#             PlotDetail("cfs_qmeu_fast", "CFS/Q-FAST", :navy),
#             PlotDetail("doc_qmeu_fast", "DOC/Q-FAST", :magenta),
#             PlotDetail("cfs_qmeu_slow", "CFS/Q-SLOW", :olive),
#             PlotDetail("doc_qmeu_slow", "DOC/Q-SLOW", :lime),
#             PlotDetail("control", "CONTROL", :red),
#         ],
#         legend=:topleft, 
#         title="COO-Hard: QueMEU Variants", 
#         ylabel="Minimum Dimension Value", 
#         save_path="coo_hard_qmeu",
#         ylims=(0.0, 2.0),
#         xlims=(0.0, 500.0)
#     )
# end