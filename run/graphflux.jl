# An example of graph classification

using Flux
using Flux: onecold, onehotbatch
using Flux.Losses: logitbinarycrossentropy, mse
using Flux: DataLoader
using GraphNeuralNetworks
using MLDatasets: TUDataset
using Statistics, Random
using MLUtils
using Zygote
using CUDA
CUDA.allowscalar(false)
include("fluxclass.jl")


function eval_loss_accuracy(model, data_loader, device)
    loss = 0.0
    acc = 0.0
    ntot = 0
    for (g, y) in data_loader
        g, y = (g, y) |> device
        n = length(y)
        X̂ = model(g, g.ndata.x) |> vec
        loss += logitbinarycrossentropy(ŷ, y) * n
        acc += mean((ŷ .> 0) .== y) * n
        ntot += n
    end
    return (loss = round(loss / ntot, digits = 4),
            acc = round(acc * 100 / ntot, digits = 2))
end


function tuclassifier_dataset(dataset::String; ohrange::UnitRange{Int} = 0:1)
    tudata = TUDataset(dataset)
    display(tudata)
    graphs = mldataset2gnngraph(tudata)
    oh(x) = Float32.(onehotbatch(x, ohrange))
    graphs = [GNNGraph(g, ndata = oh(g.ndata.targets)) for g in graphs]
    y = (1 .+ Float32.(tudata.graph_data.targets)) ./ 2
    @assert all(∈([0, 1]), y) # binary classification 
    return graphs, y
end


# arguments for the `train` function 
Base.@kwdef mutable struct Args
    η = 1.0f-3             # learning rate
    batchsize = 32      # batch size (number of graphs in each batch)
    epochs = 200         # number of epochs
    seed = 42             # set seed > 0 for reproducibility
    usecuda = false      # if true use cuda (if available)
    nhidden = 128        # dimension of hidden features
    infotime = 10      # report every `infotime` epochs
    numtrain = 150
end


function train(dataset; kws...)

    args = Args(; kws...)
    args.seed > 0 && Random.seed!(args.seed)

    if args.usecuda && CUDA.functional()
        device = gpu
        args.seed > 0 && CUDA.seed!(args.seed)
        @info "Training on GPU"
    else
        device = cpu
        @info "Training on CPU"
    end

    # LOAD DATA

    train_data, test_data = splitobs(dataset, at = args.numtrain, shuffle = true)

    train_loader = DataLoader(train_data; args.batchsize, shuffle = true, collate = true)
    test_loader = DataLoader(test_data; args.batchsize, shuffle = false, collate = true)

    # DEFINE MODEL

    nin = size(dataset[1][1].ndata.x, 1)
    nhidden = args.nhidden

    model = GNNChain(GraphConv(nin => nhidden, relu),
                     GraphConv(nhidden => nhidden, relu),
                     GlobalPool(mean),
                     Dense(nhidden, 1)) |> device

    ps = Flux.params(model)
    opt = Adam(args.η)


    trainloop!(args, train_loader, test_loader, model, opt, device, ps)
end


function trainloop!(
    args::Args, train_loader::DataLoader, test_loader::DataLoader, model::GNNChain,
    opt::ADAM, device::Function, ps::Zygote.Params
)
    # LOGGING FUNCTION
    function report(epoch)
        train = eval_loss_accuracy(model, train_loader, device)
        test = eval_loss_accuracy(model, test_loader, device)
        println("Epoch: $epoch   Train: $(train)   Test: $(test)")
    end

    # TRAIN

    report(0)
    for epoch in 1:(args.epochs)
        for (g, y) in train_loader
            g, y = (g, y) |> device
            gs = Flux.gradient(ps) do
                ŷ = model(g, g.ndata.x) |> vec
                logitbinarycrossentropy(ŷ, y)
            end
            Flux.Optimise.update!(opt, ps, gs)
        end
        epoch % args.infotime == 0 && report(epoch)
    end
end
