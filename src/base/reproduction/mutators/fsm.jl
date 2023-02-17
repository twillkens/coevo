export LingPredMutator
export addstate, rmstate, changelink, changelabel

Base.@kwdef struct LingPredMutator <: Mutator
    rng::AbstractRNG
    sc::SpawnCounter
end

function(m::LingPredMutator)(fsm::FSMIndiv)
    fns = [addstate, rmstate, changelink, changelabel]
    fns[rand(m.rng, 1:4)](m, fsm)
end

function randstate(rng::AbstractRNG, fsm::FSMIndiv)
    rand(rng, union(fsm.ones, fsm.zeros))
end

function randstate(
    rng::AbstractRNG, fsm::FSMIndiv;
    include::Set{String} = Set{String}(), 
    exclude::Set{String} = Set{String}()
)
    nodes = union(fsm.ones, fsm.zeros, include)
    nodes = setdiff(nodes, exclude)
    rand(rng, nodes)
end

function newstate!(m::LingPredMutator)
    string(gid!(m.sc))
end


function addstate(
    fsm::FSMIndiv, newstate::Set{String},
    label::Bool, truedest::String, falsedest::String
)
    ones, zeros = label ?
        (union(fsm.ones, newstate), fsm.zeros) : (fsm.ones, union(fsm.zeros, newstate))
    newstate = first(newstate)
    newlinks = Dict((newstate, true) => truedest, (newstate, false) => falsedest)
    newgeno = FSMGeno(fsm.ikey, fsm.start, ones, zeros, merge(fsm.links, newlinks))
    FSMIndiv(fsm.ikey, newgeno)
end

function addstate(
    fsm::FSMIndiv, newstate::String, label::Bool, truedest::String, falsedest::String
)
    addstate(fsm, Set([newstate]), label, truedest, falsedest)
end

function addstate(m::LingPredMutator, fsm::FSMIndiv)
    label = rand(m.rng, Bool)
    newstate = newstate!(m)
    truedest = randstate(m.rng, fsm; include = Set([newstate]))
    falsedest = randstate(m.rng, fsm, include = Set([newstate]))
    addstate(fsm, newstate, label, truedest, falsedest)
end

function rmstate(fsm::FSMIndiv, todelete::String, start::String, newlinks::LinkDict)
    ones, zeros = todelete ∈ fsm.ones ?
        (filter(s -> s != todelete, fsm.ones), fsm.zeros) :
        (fsm.ones, filter(s -> s != todelete, fsm.zeros))
    links = merge(filter(p -> p[1][1] != todelete, fsm.links), newlinks)
    geno = FSMGeno(fsm.ikey, start, ones, zeros, links)
    FSMIndiv(fsm.ikey, geno)
end

function getnew(rng::AbstractRNG, fsm::FSMIndiv, todelete::String)
    newstart = todelete == fsm.start ? randstate(rng, fsm; exclude = Set([todelete])) : ""
    newlinks = LinkDict()
    for ((origin, bool), dest) in fsm.links
        if dest == todelete && origin != todelete
            newdest = fsm.links[(todelete, bool)]
            newdest = newdest == todelete ? origin : newdest
            push!(newlinks, (origin, bool) => newdest)
        end
    end
    newstart, newlinks
end

function rmstate(m::LingPredMutator, fsm::FSMIndiv)
    if length(union(fsm.ones, fsm.zeros)) < 2 return fsm end
    todelete = randstate(m.rng, fsm)
    start, newlinks = getnew(m.rng, fsm, todelete)
    rmstate(fsm, todelete, start, newlinks)
end

function changelink(m::LingPredMutator, fsm::FSMIndiv)
    state = randstate(m.rng, fsm)
    newdest = randstate(m.rng, fsm)
    bit = rand(Bool)
    changelink(fsm, state, newdest, bit)
end

function changelink(fsm::FSMIndiv, state::String, newdest::String, bit::Bool)
    links = merge(fsm.links, Dict((state, bit) => newdest))
    geno = FSMGeno(fsm.ikey, fsm.start, fsm.ones, fsm.zeros, links)
    FSMIndiv(fsm.ikey, geno)
end

function changelabel(m::LingPredMutator, fsm::FSMIndiv)
    state = randstate(m.rng, fsm)
    changelabel(fsm, state)
end

function changelabel(fsm::FSMIndiv, state::Set{String})
    ones, zeros = state in fsm.ones ?
        (setdiff(fsm.ones, state), union(fsm.zeros, state)) :
        (union(fsm.ones, state), setdiff(fsm.zeros, state))
    geno = FSMGeno(fsm.ikey, fsm.start, ones, zeros, fsm.links)
    FSMIndiv(fsm.ikey, geno)
end


function changelabel(fsm::FSMIndiv, state::String)
    changelabel(fsm, Set([state]))
end

