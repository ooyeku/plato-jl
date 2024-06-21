module DataCleaning

using DataFrames, Statistics

export fill_missing, detect_outliers, normalize_column

function fill_missing(df::DataFrame, column::Symbol, method::Symbol=:mean)
    if method == :mean
        df[!, column] = coalesce.(df[!, column], mean(skipmissing(df[!, column])))
    elseif method == :median
        df[!, column] = coalesce.(df[!, column], median(skipmissing(df[!, column])))
    end
    return df
end

function detect_outliers(df::DataFrame, column::Symbol; threshold::Float64=1.5)
    q1 = quantile(skipmissing(df[!, column]), 0.25)
    q3 = quantile(skipmissing(df[!, column]), 0.75)
    iqr = q3 - q1
    lower_bound = q1 - threshold * iqr
    upper_bound = q3 + threshold * iqr
    return (df[!, column] .< lower_bound) .| (df[!, column] .> upper_bound)
end

function normalize_column(df::DataFrame, column::Symbol)
    df[!, column] = (df[!, column] .- minimum(df[!, column])) ./ (maximum(df[!, column]) - minimum(df[!, column]))
    return df
end

function sample_usage()
    df = DataFrame(A = [1, 2, 3, 4, 100, 6, 7, 8, 9, 10])
    println("Original DataFrame:")
    println(df)

    println("\nDetecting outliers in column A:")
    outliers = detect_outliers(df, :A)
    println(outliers)

    println("\nFilling missing values in column A with mean:")
    df[!, :A] = [1, 2, 3, missing, 5, 6, missing, 8, 9, 10]
    df = fill_missing(df, :A, :mean)
    println(df)

    println("\nNormalizing column A:")
    df = normalize_column(df, :A)
    println(df)
end

end # module DataCleaning