module DataGen

using DataFrames
using Random
using Dates
using Faker

export DataGenerator, add_column!, generate, example_usage

struct DataGenerator
    num_rows::Int
    data::DataFrame
end

function create_data_generator(num_rows::Int)
    return DataGenerator(num_rows, DataFrame())
end

function add_column!(gen::DataGenerator, column_name::Symbol, data_type::String; options=nothing)
    if data_type == "age"
        gen.data[!, column_name] = [rand(18:100) for _ in 1:gen.num_rows]
    elseif data_type == "email"
        gen.data[!, column_name] = [Faker.email() for _ in 1:gen.num_rows]
    elseif data_type == "date"
        start_date = Date(options[:min])
        end_date = Date(options[:max])
        gen.data[!, column_name] = [start_date + Day(rand(0:Dates.value(end_date - start_date))) for _ in 1:gen.num_rows]
    elseif data_type == "category"
        gen.data[!, column_name] = [rand(options[:categories]) for _ in 1:gen.num_rows]
    elseif data_type == "bool"
        gen.data[!, column_name] = [rand(Bool) for _ in 1:gen.num_rows]
    elseif data_type == "float"
        gen.data[!, column_name] = [rand(options[:min]:0.01:options[:max]) for _ in 1:gen.num_rows]
    elseif data_type == "text"
        gen.data[!, column_name] = [Faker.sentence(number_words=rand(1:options[:max_chars])) for _ in 1:gen.num_rows]
    end
end

function generate(gen::DataGenerator)
    return gen.data
end

function example_usage()
    @time begin
    gen = create_data_generator(10_000)
    add_column!(gen, :age, "age")
    add_column!(gen, :email, "email")
    add_column!(gen, :birthdate, "date", options=Dict(:min=>"2000-01-01", :max=>"2020-12-31"))
    add_column!(gen, :category, "category", options=Dict(:categories=>["A", "B", "C"]))
    add_column!(gen, :is_active, "bool")
    add_column!(gen, :score, "float", options=Dict(:min=>0.0, :max=>100.0))
    add_column!(gen, :description, "text", options=Dict(:max_chars=>20))
    add_column!(gen, :name, "name", options=Dict(:max_chars=>20))
    add_column!(gen, :phone, "phone", options=Dict(:max_chars=>20))
    add_column!(gen, :address, "address", options=Dict(:max_chars=>20))
    add_column!(gen, :city, "city", options=Dict(:max_chars=>20))
    add_column!(gen, :state, "state", options=Dict(:max_chars=>20))
    add_column!(gen, :zip, "zip", options=Dict(:max_chars=>20))
    add_column!(gen, :country, "country", options=Dict(:max_chars=>20))
    add_column!(gen, :latitude, "float", options=Dict(:min=>-90.0, :max=>90.0))
    add_column!(gen, :longitude, "float", options=Dict(:min=>-180.0, :max=>180.0))
    add_column!(gen, :ip_address, "ip_address", options=Dict(:max_chars=>20))
    add_column!(gen, :user_agent, "user_agent", options=Dict(:max_chars=>20))
    add_column!(gen, :url, "url", options=Dict(:max_chars=>20))
    add_column!(gen, :id, "id", options=Dict(:max_chars=>20))
    df = generate(gen)
    println("Generated DataFrame:\n$df")
    end
    return df
end
end # module DataGen
