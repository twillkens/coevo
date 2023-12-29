#!/bin/bash

mkdir -p logs/2compR

for i in {1..30}
do
   echo "Running trial $i"
   julia --project=. run/prediction_game/run.jl \
        --trial $i \
        --n_workers 1 \
        --game continuous_prediction_game \
        --topology two_competitive \
        --reproduction roulette \
        --n_generations 30000 \
        --n_nodes_per_output 1 \
        --archive_interval 100 \
        --function_set all \
        --mutation shrink_small \
        --noise_std high \
        --n_population 50 \
        --n_children 50 \
        --n_elites 0 \
        --episode_length 16 \
        > logs/2compR/$i.log 2>&1 &
done
