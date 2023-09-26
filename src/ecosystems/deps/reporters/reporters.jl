"""
    Reporters

The `Reporters` module provides utilities to report runtime statistics, such as evaluation and 
reproduction time, during the evolutionary process. It defines a specific report type, 
[`RuntimeReport`](@ref), and a corresponding reporter, [`RuntimeReporter`](@ref), that generates 
such reports.

# Key Types
- [`RuntimeReport`](@ref): A structured type that captures details about the runtime of specific processes in a given generation.
- [`RuntimeReporter`](@ref): A reporter that, when called, generates a `RuntimeReport`.

# Dependencies
This module depends on the abstract `Report` and `Reporter` types defined in the `...CoEvo.Abstract` module, and on the `Archiver` type.

# Usage
Use this module when you want to keep track of the runtime statistics of your evolutionary algorithm and potentially print or save them at regular intervals.

# Exports
The module exports: `RuntimeReport` and `RuntimeReporter`.
"""
module Reporters

export RuntimeReport, RuntimeReporter

using ....CoEvo.Abstract: Report, Reporter, Archiver


"""
    RuntimeReport

A structured report that captures the runtime details of the evaluation and reproduction 
processes during a specific generation.

# Fields
- `gen`: The generation number.
- `to_print`: A boolean flag indicating if this report should be printed.
- `to_save`: A boolean flag indicating if this report should be saved.
- `eval_time`: The time taken (in seconds) for the evaluation process.
- `reproduce_time`: The time taken (in seconds) for the reproduction process.
"""
struct RuntimeReport <: Report
    gen::Int
    to_print::Bool
    to_save::Bool
    eval_time::Float64
    reproduce_time::Float64
end

"""
    RuntimeReporter

A reporter type that produces [`RuntimeReport`](@ref) objects when called. It can be configured 
to print and/or save reports at specific generation intervals.

# Fields
- `print_interval`: The interval (in terms of generations) at which reports should be printed. A value of 0 disables printing.
- `save_interval`: The interval (in terms of generations) at which reports should be saved. A value of 0 disables saving.
- `n_round`: The number of decimal places to which the `eval_time` and `reproduce_time` should be rounded.

# Usage
Create an instance of `RuntimeReporter` and call it with the necessary arguments to generate a report.
"""
Base.@kwdef struct RuntimeReporter <: Reporter
    print_interval::Int = 1
    save_interval::Int = 0
    n_round::Int = 6
end

# Define how a RuntimeReporter produces a report.
function(reporter::RuntimeReporter)(gen::Int, eval_time::Float64, reproduce_time::Float64)
    to_print = reporter.print_interval > 0 && gen % reporter.print_interval == 0
    to_save = reporter.save_interval > 0 && gen % reporter.save_interval == 0
    report = RuntimeReport(
        gen, 
        to_print, 
        to_save, 
        round(eval_time, digits = reporter.n_round), 
        round(reproduce_time, digits = reporter.n_round))
    return report 
end

# Define how an Archiver handles a RuntimeReport.
function(archiver::Archiver)(report::RuntimeReport)
    if report.to_print
        println("-----------------------------------------------------------")
        println("Generation: $report.gen")
        println("Evaluation time: $(report.eval_time)")
        println("Reproduction time: $(report.reproduce_time)")
    end
end

end