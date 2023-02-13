export stir
export LingPredGame, LingPredObsConfig, NullObsConfig, LingPredRecord, LingPredObs

StateLog = Dict{Tuple{String, String}, Int}
ScoreDict = Dict{Tuple{String, String}, Float64}

struct LingPredObsConfig <: ObsConfig end

function(cfg::LingPredObsConfig)(
    loopstart::Int,
    pheno1::FSMPheno, pheno2::FSMPheno,
    states1::Vector{String}, states2::Vector{String},
    outs1::Vector{Bool}, outs2::Vector{Bool}
)
    LingPredObs(
        loopstart,
        Dict(pheno1.ikey => outs1, pheno2.ikey => outs2),
        Dict(pheno1.ikey => states1, pheno2.ikey => states2)
    )
end

function NullObsConfig(args...; kwargs...)
    NullObsConfig()
end

struct LingPredObs <: Observation
    loopstart::Int
    outs::Dict{IndivKey, Vector{Bool}}
    states::Dict{IndivKey, Vector{String}}
end

function label(fsm::FSMPheno, state::String)
    state in fsm.ones
end

function act(fsm::FSMPheno, state::String, bit::Bool)
    fsm.links[(state, bit)]
end


function simulate(::LingPredGame, a1::FSMPheno, a2::FSMPheno)
    t = 1
    state1, state2 = a1.start, a2.start
    statelog = StateLog((state1, state2) => t)
    bit1, bit2 = label(a1, state1), label(a2, state2)
    states1, states2 = String[state1], String[state2]
    bits1, bits2 = Bool[bit1], Bool[bit2]
    while true
        t += 1
        state1, state2 = act(a1, state1, bit2), act(a2, state2, bit1)
        bit1, bit2 = label(a1, state1), label(a2, state2)
        push!(bits1, bit1)
        push!(bits2, bit2)
        push!(states1, state1)
        push!(states2, state2)
        logkey = (state1, state2)
        if logkey in keys(statelog)
            return statelog[logkey], states1, states2, bits1, bits2
        end
        statelog[logkey] = t
    end
end

function getmatches(loopstart::Int, traj1::Vector{Bool}, traj2::Vector{Bool})
    [bit1 == bit2 for (bit1, bit2) in zip(traj1[loopstart:end - 1], traj2[loopstart:end - 1])]
end


function stir(
    oid::Symbol, domain::LingPredGame, obscfg::ObsConfig;
    matchcoop1::FSMPheno, matchcoop2::FSMPheno, kwargs...
)
    loopstart, states1, states2, traj1, traj2 = simulate(domain, matchcoop1, matchcoop2)
    matches = getmatches(loopstart, traj1, traj2)
    score = mean(matches)
    obs = obscfg(loopstart, matchcoop1, matchcoop2, states1, states2, traj1, traj2)
    Outcome(oid, Dict(matchcoop1.ikey => score, matchcoop2.ikey => score), obs)
end

# function stir(
#     oid::Symbol, domain::LingPredGame, obscfg::ObsConfig;
#     mismatchcoop1::FSMPheno, mismatchcoop2::FSMPheno, kwargs...
# )
#     loopstart, states1, states2, traj1, traj2 = simulate(domain, mismatchcoop1, mismatchcoop2)
#     matches = getmatches(loopstart, traj1, traj2)
#     score = 1 - mean(matches)
#     obs = obscfg(mismatchcoop1, mismatchcoop2, loopstart, states1, states2, traj1, traj2)
#     Outcome(oid, Dict(mismatchcoop1.ikey => score, mismatchcoop2.ikey => score), obs)
# end
# 
# function stir(
#     oid::Symbol, domain::LingPredGame, obscfg::ObsConfig;
#     matchcomp1::FSMPheno, matchcomp2::FSMPheno, kwargs...
# )
#     loopstart, states1, states2, traj1, traj2 = simulate(domain, matchcomp1, matchcomp2)
#     matches = getmatches(loopstart, traj1, traj2)
#     score1 = mean(matches)
#     score2 = 1 - score1
#     obs = obscfg(matchcomp1, matchcomp2, loopstart, states1, states2, traj1, traj2)
#     Outcome(oid, Dict(matchcomp1.ikey => score1, matchcomp2.ikey => score2), obs)
# end
# 
# function stir(
#     oid::Symbol, domain::LingPredGame, ::LingPredObsConfig;
#     mismatchcomp1::FSMPheno, mismatchcomp2::FSMPheno, kwargs...
# )
#     loopstart, states1, states2, traj1, traj2 = simulate(domain, mismatchcomp1, mismatchcomp2)
#     matches = getmatches(loopstart, traj1, traj2)
#     score1 = 1 - mean(matches)
#     score2 = 1 - score1
#     obs = obscfg(mismatchcomp1, mismatchcomp2, loopstart, states1, states2, traj1, traj2)
#     Outcome(oid, Dict(mismatchcomp1.ikey => score1, mismatchcomp2.ikey => score2), obs)
# end
# 