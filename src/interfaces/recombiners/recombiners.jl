export recombine

using ..Abstract

function recombine(recombiner::Recombiner, individuals::Vector{Individual}, state::State)
    recombiner = typeof(recombiner)
    individuals = typeof(individuals)
    state = typeof(state)
    error("recombine not implemented for $recombiner, $individuals, $state")
end