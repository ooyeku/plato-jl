module Visualization

using Plots, DataFrames

export plot_histogram, plot_scatter, plot_line

function plot_histogram(df::DataFrame, column::Symbol; bins::Int=10)
    histogram(df[!, column], bins=bins, title="Histogram of $(column)", xlabel=string(column), ylabel="Frequency")
end

function plot_scatter(df::DataFrame, x::Symbol, y::Symbol)
    scatter(df[!, x], df[!, y], title="Scatter Plot of $(x) vs $(y)", xlabel=string(x), ylabel=string(y))
end

function plot_line(df::DataFrame, x::Symbol, y::Symbol)
    plot(df[!, x], df[!, y], title="Line Plot of $(x) vs $(y)", xlabel=string(x), ylabel=string(y))
end

function sample_usage()
    df = DataFrame(x=1:10, y=rand(10))
    plot_histogram(df, :x)
    plot_scatter(df, :x, :y)
    plot_line(df, :x, :y)
end

end # module Visualization