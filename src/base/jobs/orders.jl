export AllvsAllPlusOrder, AllvsAllCommaOrder

Base.@kwdef struct AllvsAllPlusOrder{D <: Domain, O <: ObsConfig} <: Order
    oid::Symbol
    spids::Vector{Symbol}
    domain::D
    obscfg::O
end

function(o::AllvsAllPlusOrder)(sp1::Species, sp2::Species)
    ikeys1 = [collect(keys(sp1.pop)); collect(keys(sp1.children))]
    ikeys2 = [collect(keys(sp2.pop)); collect(keys(sp2.children))]
    vec(map(ikeypair -> Recipe(o.oid, ikeypair), Iterators.product(ikeys1, ikeys2)))
end

Base.@kwdef struct AllvsAllCommaOrder{D <: Domain, O <: ObsConfig} <: Order
    oid::Symbol
    spids::Vector{Symbol}
    domain::D
    obscfg::O
end

function(o::AllvsAllCommaOrder)(sp1::Species, sp2::Species)
    i1 = length(sp1.children) == 0 ? sp1.pop : sp1.children
    i2 = length(sp2.children) == 0 ? sp2.pop : sp2.children
    ikeys1 = collect(keys(i1))
    ikeys2 = collect(keys(i2))
    map(ikeypair -> Recipe(o.oid, ikeypair), Iterators.product(ikeys1, ikeys2))
end

function(o::Order)(allsp::Dict{Symbol, <:Species})
    osp = [allsp[spid] for spid in o.spids]
    o(osp...)
end
