
function lingpredspawner(spid::Symbol; npop::Int = 50, dtype::Type = Int, spargs = Any[])
    s = Spawner(
        spid = spid,
        npop = npop,
        icfg = FSMIndivConfig(spid = spid, dtype = dtype),
        phenocfg = FSMPhenoCfg(minimize = true),
        replacer = CommaReplacer(npop = npop),
        selector =  RouletteSelector(μ = npop),
        recombiner = CloneRecombiner(),
        mutators = [LingPredMutator()],
        archiver = FSMIndivArchiver(log_popids = true, minimize = true),
        spargs = spargs
    )
    spid => s
end

function lingpredorder(oid::Symbol, spvec::Vector{Symbol}, domain::Domain)
    oid => AllvsAllCommaOrder(oid, spvec, domain, LingPredObsConfig())
end


function runcoop(i::Int)
    coev_key = "Coop-$(i)"
    seed = rand(UInt64)
    rng = StableRNG(seed)

    spawner1 = lingpredspawner(rng, :host;     npop = 50)
    spawner2 = lingpredspawner(rng, :symbiote; npop = 50)
    # spawner3 = lingpredspawner(rng, :parasite; npop = 50)

    order1 = lingpredorder(:HostVsSymbiote, [:host, :symbiote], LingPredGame(MatchCoop()))
    #order1 = lingpredorder(:HostVsParasite, [:host, :parasite], LingPredGame(MatchComp()))

    coev_cfg = CoevConfig(;
        key = coev_key,
        trial = i,
        seed = seed,
        rng = rng,
        jobcfg = SerialPhenoJobConfig(),
        orders = Dict(order1),
        spawners = Dict(spawner1, spawner2), #, spawner3),
        loggers = [SpeciesLogger()],
        logpath = "/media/tcw/Seagate/NewLing/coop-$(i).jld2"
    )

    allsp = coev_cfg()
    println("go")
    for gen in 1:10_000
        allsp = coev_cfg(UInt16(gen), allsp)
        if mod(gen, 1000) == 0
            println("Generation: $gen")
        end
    end
    close(coev_cfg.jld2file)
end


function runcomp(i::Int)
    coev_key = "Comp-$(i)"
    seed = rand(UInt64)
    rng = StableRNG(seed)

    spawner1 = lingpredspawner(rng, :host;     npop = 50)
    # spawner2 = lingpredspawner(rng, :symbiote; npop = 50)
    spawner3 = lingpredspawner(rng, :parasite; npop = 50)

    #order1 = lingpredorder(:HostVsSymbiote, [:host, :symbiote], LingPredGame(MatchCoop()))
    order2 = lingpredorder(:HostVsParasite, [:host, :parasite], LingPredGame(MatchComp()))

    coev_cfg = CoevConfig(;
        key = coev_key,
        trial = i,
        seed = seed,
        rng = rng,
        jobcfg = SerialPhenoJobConfig(),
        orders = Dict(order2),
        spawners = Dict(spawner1, spawner3), #, spawner3),
        loggers = [SpeciesLogger()],
        logpath = "/media/tcw/Seagate/NewLing/comp-$(i).jld2"
    )

    allsp = coev_cfg()
    println("go")
    for gen in 1:10_000
        allsp = coev_cfg(UInt16(gen), allsp)
        if mod(gen, 1000) == 0
            println("Generation: $gen")
        end
    end
    close(coev_cfg.jld2file)
end

function runcontrol(i::Int)
    coevkey = "Control-$(i)"
    seed = rand(UInt64)
    rng = StableRNG(seed)
    spawner1 = lingpredspawner(rng, :control1; npop = 50)
    spawner2 = lingpredspawner(rng, :control2; npop = 50)
    order = lingpredorder(:ControlMatch, [:control1, :control2], LingPredGame(Control()))

    coevcfg = CoevConfig(;
        key = coevkey,
        trial = i,
        seed = seed,
        rng = rng,
        jobcfg = SerialPhenoJobConfig(),
        orders = Dict(order),
        spawners = Dict(spawner1, spawner2),
        loggers = [SpeciesLogger()],
        logpath = "/media/tcw/Seagate/NewLing/$(coevkey).jld2"
    )

    allsp = coevcfg()
    println("go")
    for gen in 1:10_000
        allsp = coevcfg(UInt16(gen), allsp)
        if mod(gen, 1000) == 0
            println("$(coevkey): gen $gen")
        end
    end
    close(coevcfg.jld2file)
end

function rungrow(i::Int)
    coevkey = "Grow-$(i)"
    seed = rand(UInt64)
    rng = StableRNG(seed)
    addprob = 9 / 30
    otherprob = 7 / 30
    probs = Dict(
        addstate => addprob,
        rmstate => otherprob,
        changelabel => otherprob,
        changelink => otherprob
    )
    spawner1 = lingpredspawner(rng, :control1; npop = 50, probs = probs)
    spawner2 = lingpredspawner(rng, :control2; npop = 50, probs = probs)
    order = lingpredorder(:ControlMatch, [:control1, :control2], LingPredGame(Control()))

    coevcfg = CoevConfig(;
        key = coevkey,
        trial = i,
        seed = seed,
        rng = rng,
        jobcfg = SerialPhenoJobConfig(),
        orders = Dict(order),
        spawners = Dict(spawner1, spawner2),
        loggers = [SpeciesLogger()],
        logpath = "/media/tcw/Seagate/NewLing/$(coevkey).jld2"
    )

    allsp = coevcfg()
    println("go")
    for gen in 1:10_000
        allsp = coevcfg(UInt16(gen), allsp)
        if mod(gen, 1000) == 0
            println("$(coevkey): gen $gen")
        end
    end
    close(coevcfg.jld2file)
end

@everywhere function runctrl(logpath::String, trial::Int)
    coevkey = "ctrl-$(trial)"
    seed = rand(UInt64)
    rng = StableRNG(seed)
    spawner1 = lingpredspawner(rng, :control1; npop = 50)
    spawner2 = lingpredspawner(rng, :control2; npop = 50)
    order = lingpredorder(:ControlMatch, [:ctrl1, :ctrl2], LingPredGame(Control()))

    coevcfg = CoevConfig(;
        key = coevkey,
        trial = trial,
        seed = seed,
        rng = rng,
        jobcfg = SerialPhenoJobConfig(),
        orders = Dict(order),
        spawners = Dict(spawner1, spawner2),
        loggers = [SpeciesLogger()],
        logpath = "$(logpath)/$(coevkey).jld2"
    )

    allsp = coevcfg()
    println("go")
    for gen in 0:10_000
        allsp = coevcfg(UInt16(gen), allsp)
        if mod(gen, 1000) == 0
            println("$(coevkey): gen $gen")
        end
    end
    close(coevcfg.jld2file)
end

function runmix(i::Int)
    coev_key = "mix-$(i)"
    seed = rand(UInt64)
    rng = StableRNG(seed)

    spawner1 = lingpredspawner(rng, :host;     npop = 50)
    spawner2 = lingpredspawner(rng, :symbiote; npop = 50)
    spawner3 = lingpredspawner(rng, :parasite; npop = 50)

    order1 = lingpredorder(:HostVsSymbiote, [:host, :symbiote], LingPredGame(MatchCoop()))
    order2 = lingpredorder(:HostVsParasite, [:host, :parasite], LingPredGame(MatchComp()))

    coev_cfg = CoevConfig(;
        key = coev_key,
        trial = i,
        seed = seed,
        rng = rng,
        jobcfg = SerialPhenoJobConfig(),
        orders = Dict(order1, order2),
        spawners = Dict(spawner1, spawner2, spawner3),
        loggers = [SpeciesLogger()],
        logpath = "$(ENV["FSM_DATA_DIR"])/mix-$(i).jld2"
    )

    allsp = coev_cfg()
    println("go")
    for gen in 1:10_000
        allsp = coev_cfg(UInt16(gen), allsp)
        if mod(gen, 1000) == 0
            println("Generation: $gen")
        end
    end
    close(coev_cfg.jld2file)
end

function runmix(trial::Int, npop::Int, ngen::Int, domain1::Domain, domain2::Domain)
    v1 = typeof(domain1).parameters[1]
    v2 = typeof(domain2).parameters[1]
    eco = Symbol("Mix-$(v1)-$(v2)")
    seed = rand(UInt64)

    spawner1 = lingpredspawner(:host;     npop = npop)
    spawner2 = lingpredspawner(:symbiote; npop = npop)
    spawner3 = lingpredspawner(:parasite; npop = npop)

    order1 = lingpredorder(:HostVsSymbiote, [:host, :symbiote], domain1)
    order2 = lingpredorder(:HostVsParasite, [:host, :parasite], domain2)

    coevcfg = CoevConfig(;
        eco = eco,
        trial = trial,
        seed = seed,
        jobcfg = SerialPhenoJobConfig(),
        orders = Dict(order1, order2),
        spawners = Dict(spawner1, spawner2, spawner3),
        loggers = [SpeciesLogger()],
        logpath = "$(ENV["FSM_DATA_DIR"])/$(coevkey).jld2"
    )

    allsp = coevcfg()
    println("starting: $(coevkey)")
    for gen in 1:ngen
        allsp = coevcfg(UInt16(gen), allsp)
        if mod(gen, 1000) == 0
            println("Generation: $gen")
        end
    end
    close(coevcfg.jld2file)
end

function runlingpred()

function runmix(trial::Int, npop::Int, ngen::Int, domains::Vector{<:Domain})
    runmix(trial, npop, ngen, domains[1], domains[2])
end

function pdispatch(;
    fn::Function = runmix, trange::UnitRange = 1:20, npop::Int = 50, ngen::Int = 10_000,
    domains::Vector{<:Domain} = [LingPredGame(MatchCoop()), LingPredGame(MatchComp())]
)
    futures = [@spawnat :any fn(trial, npop, ngen, domains) for trial in trange] 
    [fetch(f) for f in futures]
end

function sdispatch(;
    fn::Function = runctrl, trange::UnitRange = 1:20, npop::Int = 50, ngen::Int = 10_000,
    domains::Vector{<:Domain} = [LingPredGame(MatchCoop()), LingPredGame(MatchComp())]
)
    [fn(trial, npop, ngen, domains) for trial in trange] 
end