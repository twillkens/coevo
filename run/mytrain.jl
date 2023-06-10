
# arguments for the `train` function 
Base.@kwdef mutable struct MyArgs
    η = 0.001             # learning rate
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

struct GNN                                # step 1
    conv1
    bn
    conv2
    dropout
    dense
    pool
end

Flux.@functor GNN    

function GNN(nin::Int = 5, ein::Int = 4, d1::Int = 256, d2::Int = 128, dout::Int = 64)
    GNN(
        GATv2Conv((nin, ein) => d1, add_self_loops = false),
        #GATv2Conv(nin => d1, add_self_loops = false),
        BatchNorm(d1),
        # GATv2Conv(d1 => d2, add_self_loops = false),
        GATv2Conv((d1, ein) => d2, add_self_loops = false),
        Dropout(0.5),
        Dense(d2, dout),
        GlobalPool(mean),
    )
end

function (model::GNN)(g::GNNGraph, x, e)     # step 4
    x = model.conv1(g, x, e)
    # x = model.conv1(g, x)
    x = leakyrelu.(model.bn(x))
    x = model.conv2(g, x, e)
    # x = model.conv2(g, x)
    x = model.pool(g, x)
    x = model.dropout(x)
    x = model.dense(x)
    return x 
end

function (model::GNN)(g::GNNGraph)
    model(g, g.ndata.x, g.edata.e)
end

function my_eval_loss_accuracy(model, data_loader, device)
    loss = 0.0
    ntot = 0
    for ((g1, g2), y) in data_loader
        g1, g2, y = (g1, g2, y) |> device
        n = length(y)
        #emb1 = model(g1) |> vec
        #emb2 = model(g2) |> vec
        emb1 = reshape(model(g1), :)  # replace vec with reshape
        emb2 = reshape(model(g2), :)  # replace vec with reshape
        ŷ = norm(emb1 - emb2)
        loss += Flux.mse(ŷ, y) * n
        ntot += n
    end
    return (loss = round(loss / ntot, digits = 4))
end

function mytrainloop!(
    args::MyArgs, train_loader::DataLoader, test_loader::DataLoader, model::Union{GNNChain, GNN},
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
                #emb1 = model(g1) |> vec
                #emb2 = model(g2) |> vec
                emb1 = reshape(model(g1), :)  # replace vec with reshape
                emb2 = reshape(model(g2), :)  # replace vec with reshape
                ŷ = norm(emb1 - emb2)
                Flux.mse(ŷ, y)
            end
            Flux.Optimise.update!(opt, ps, gs)
        end
        epoch % args.infotime == 0 && report(epoch)
    end
    model
end

function mytrain(dataset, model::Union{GNNChain, GNN} = GNN(); kws...)
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
    model = model |> device

    # LOAD DATA
    graphs = [(pair.g1, pair.g2) for pair in dataset]
    dists = [pair.dist for pair in dataset]
    dataset = collect(zip(graphs, dists))
    train_data, test_data = splitobs(dataset, at = args.numtrain, shuffle = true)

    train_loader = DataLoader(train_data; args.batchsize, shuffle = true, collate = true)
    test_loader = DataLoader(test_data; args.batchsize, shuffle = false, collate = true)


    ps = Flux.params(model)
    opt = Adam(args.η)
    mytrainloop!(args, train_loader, test_loader, model, opt, device, ps)
end


