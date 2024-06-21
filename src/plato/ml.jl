module MachineLearning

using DataFrames, Statistics, LinearAlgebra

export linear_regression, logistic_regression, k_means

function linear_regression(X::Matrix, y::Vector)
    X = hcat(ones(size(X, 1)), X)
    return X \ y
end

function logistic_regression(X::Matrix, y::Vector; max_iter::Int=1000, lr::Float64=0.01)
    X = hcat(ones(size(X, 1)), X)
    θ = zeros(size(X, 2))
    for _ in 1:max_iter
        h = 1 ./ (1 .+ exp.(-X * θ))
        gradient = X' * (h .- y) / length(y)
        θ -= lr * gradient
    end
    return θ
end

function k_means(X::Matrix, k::Int; max_iter::Int=100)
    centroids = X[rand(1:size(X, 1), k), :]
    clusters = []
    for _ in 1:max_iter
        clusters = [argmin([norm(x .- c) for c in eachrow(centroids)]) for x in eachrow(X)]
        new_centroids = [mean(X[clusters .== i, :], dims=1) for i in 1:k]
        new_centroids = vcat(new_centroids...)  # Ensure centroids have the correct dimensions
        if all(centroids .== new_centroids)
            break
        end
        centroids = new_centroids
    end
    return centroids, clusters
end

function sample_usage()
    X = rand(10, 5)
    y = rand(10)
    println("Linear Regression Coefficients: ", linear_regression(X, y))
    println("Logistic Regression Coefficients: ", logistic_regression(X, y))
    centroids, clusters = k_means(X, 3)
    println("K-Means Centroids: ", centroids)
    println("K-Means Clusters: ", clusters)
end

end # module MachineLearning