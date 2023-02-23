function get_gnngraph_proteins()
    tudata = TUDataset("PROTEINS")
    display(tudata)
    graphs = mldataset2gnngraph(tudata)
    l = length(graphs[1].ndata.targets)
    oh(x) = Float32.(onehotbatch(x, 0:l - 1))
    graphs = [GNNGraph(g, ndata = oh(g.ndata.targets)) for g in graphs]
end

function getproteins(nsample::Int)
    tudata = TUDataset("PROTEINS")
    display(tudata)
    graphs = mldataset2gnngraph(tudata)
    l = length(graphs[1].ndata.targets)
    oh(x) = Float32.(onehotbatch(x, 0:l - 1))
    graphs = [GNNGraph(g, ndata = oh(g.ndata.targets)) for g in graphs]
    idxs1 = rand(1:length(graphs), nsample)
    idxs2 = rand(1:length(graphs), nsample)
    distances = Float64[]
    tgs1 = [graphs[i] for i in idxs1]
    tgs2 = [graphs[i] for i in idxs2]
    for (g1, g2) in zip(tgs1, tgs2)
        d = graph_distance(g1, g2)
        push!(distances, d)
    end
    return (tgs1, tgs2), distances
end

function my_eval_loss_accuracy(model, data_loader, device)
    loss = 0.0
    ntot = 0
    for ((g1, g2), y) in data_loader
        g1, g2, y = (g1, g2, y) |> device
        n = length(y)
        emb1 = model(g1, g1.ndata.x) |> vec
        emb2 = model(g2, g2.ndata.x) |> vec
        ŷ = norm(emb1 - emb2)
        loss += Flux.mse(ŷ, y) * n
        ntot += n
    end
    return (loss = round(loss / ntot, digits = 4))
end

function testembed()
    model = makemodel(42, 64, 32, cpu)
    graphs = get_gnngraph_proteins()
    g1s, g2s = graphs[1:100], graphs[101:200]
    b1, b2 = Flux.batch(g1s), Flux.batch(g2s)
    e1s, e2s = model(b1, b1.ndata.x), model(b2, b2.ndata.x)
    e1s, e2s, norm(e1s - e2s)
end

function testgraphdist()
    graphs = get_gnngraph_proteins()
    g1s, g2s = graphs[1:100], graphs[101:200]
    dists = [graph_distance(g1, g2) for (g1, g2) in zip(g1s, g2s)]
end

# arguments for the `train` function 
Base.@kwdef mutable struct MyArgs
    η = 1.0f-3             # learning rate
    batchsize = 32      # batch size (number of graphs in each batch)
    epochs = 50         # number of epochs
    seed = 42             # set seed > 0 for reproducibility
    usecuda = true      # if true use cuda (if available)
    nhidden1 = 256        # dimension of hidden features
    nhidden2 = 128        # dimension of hidden features
    nout = 32        # dimension of hidden features
    infotime = 10      # report every `infotime` epochs
    numtrain = 100
end


function mytrain(dataset, model::Union{GNNChain, Nothing} = nothing; kws...)
    args = MyArgs(; kws...)
    args.seed > 0 && Random.seed!(args.seed)

    if args.usecuda && CUDA.functional()
        device = gpu
        args.seed > 0 && CUDA.seed!(args.seed)
        @info "Training on GPU"
    else
        device = cpu
        @info "Training on CPU"
    end

    nin::Int = 1
    # LOAD DATA
    graphs = [(pair.g1.graph, pair.g2.graph) for pair in dataset]
    dists = [pair.dist for pair in dataset]
    dataset = collect(zip(graphs, dists))
    train_data, test_data = splitobs(dataset, at = args.numtrain, shuffle = true)

    train_loader = DataLoader(train_data; args.batchsize, shuffle = true, collate = true)
    test_loader = DataLoader(test_data; args.batchsize, shuffle = false, collate = true)

    model = model === nothing ?
        GNNChain(GraphConv(nin => args.nhidden1, relu),
                 GrachConv(args.nhidden1 => args.nhidden2, relu),
                 GraphConv(args.nhidden2 => args.nout, relu),
                 GlobalPool(mean)) |> device :
        model

    ps = Flux.params(model)
    opt = Adam(args.η)
    mytrainloop!(args, train_loader, test_loader, model, opt, device, ps)
end


function mytrainloop!(
    args::MyArgs, train_loader::DataLoader, test_loader::DataLoader, model::GNNChain,
    opt::ADAM, device::Function, ps::Zygote.Params
)
    function report(epoch)
        train = my_eval_loss_accuracy(model, train_loader, device)
        test = my_eval_loss_accuracy(model, test_loader, device)
        println("Epoch: $epoch   Train: $(train)   Test: $(test)")
    end
    report(0)
    for epoch in 1:(args.epochs)
        for ((g1, g2), y) in train_loader
            g1, g2, y = (g1, g2, y) |> device
            gs = Flux.gradient(ps) do
                emb1 = model(g1, g1.ndata.x) |> vec
                emb2 = model(g2, g2.ndata.x) |> vec
                ŷ = norm(emb1 - emb2)
                Flux.mse(ŷ, y)
            end
            Flux.Optimise.update!(opt, ps, gs)
        end
        epoch % args.infotime == 0 && report(epoch)
    end
    model
end

vec_to_matrix(X) = mapreduce(permutedims, vcat, [X[i][:,1] for i in 1:length(X)])


function plotlineage(model::GNNChain, l::Vector{<:GNNGraph},)
    X = [model(g, g.ndata.x) |> cpu for g in l |> cpu]
    Xtr = mapreduce(permutedims, vcat, [X[i][:,1] for i in eachindex(X)])
    M = fit(PCA, Xtr; maxoutdim=2)
    scatter(M[1], M[2], legend=false)
end

function plotlineage(model::GNNChain, l::Vector{<:FSMIndiv})
    lgs = [makeGNNGraph(i) for i in l]
    plotlineage(model,lgs,)
end


function testdoit(nsample::Int = 1_000, ntrain::Int = 500)
    jld = jldopen("test.jld2", "w")
    pairs = pfetchpairs(;n = nsample, ecos = ["coop", "comp", "Grow", "Control"])
    jld["pairs"] = pairs
    model = mytrain(pairs; numtrain=ntrain)
    jld["model"] = model
    l = lineage("comp-1", 9999, :host, 1)
    fsms = [FSMGraph("comp", 1, gen, i) for (gen, i) in enumerate(l)]
    jld["fsms"] = fsms

    graphs = [
        map(fsm -> fsm.graph, fsms);
        map(pair -> pair.g1.graph, pairs);
        map(pair -> pair.g2.graph, pairs)
    ]
    embs = []
    n
    for (i, g) in enumerate(graphs)
        g = g |> cpu
        emb = model(g, g.ndata.x) |> vec
        push!(embs, emb)
    end

    X = [model(g, g.ndata.x) |> cpu for g in graphs |> gpu]
    Xtr = vec_to_matrix(X)
    M = fit(PCA, Xtr; maxoutdim=2)
    jld["M"] = M
    p = scatter(M.proj[1:9999, :])
    savefig(p, "test.png")
    close(jld)
end