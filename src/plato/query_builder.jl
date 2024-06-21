module QueryBuilder

include("sqlite_helper.jl")
using .SQLiteHelper

export Query, select, from, where, and_, or_, order_by, limit, offset, insert_into, values, build, sample_usage

mutable struct Query
    select_clause::Vector{String}
    from_clause::String
    where_clause::Vector{String}
    order_by_clause::Vector{String}
    limit_clause::Union{Int,Nothing}
    offset_clause::Union{Int,Nothing}
    insert_clause::String
    values_clause::Vector{String}
end

Query() = Query(String[], "", String[], String[], nothing, nothing, "", String[])

function select(q::Query, columns...)
    push!(q.select_clause, join(string.(columns), ", "))
    q
end

function from(q::Query, table)
    q.from_clause = string(table)
    q
end

function where(q::Query, condition)
    push!(q.where_clause, string(condition))
    q
end

function and_(q::Query, condition)
    push!(q.where_clause, "AND $(string(condition))")
    q
end

function or_(q::Query, condition)
    push!(q.where_clause, "OR $(string(condition))")
    q
end

function order_by(q::Query, columns...)
    push!(q.order_by_clause, join(string.(columns), ", "))
    q
end

function limit(q::Query, n::Int)
    q.limit_clause = n
    q
end

function offset(q::Query, n::Int)
    q.offset_clause = n
    q
end

function insert_into(q::Query, table)
    q.insert_clause = "INSERT INTO $(string(table))"
    q
end

function values(q::Query, columns...)
    push!(q.values_clause, join(string.(columns), ", "))
    q
end

function build(q::Query)
    if !isempty(q.insert_clause)
        return "$(q.insert_clause) ($(join(q.values_clause, ", "))) VALUES ($(join(fill("?", length(split(q.values_clause[1], ", "))), ", ")))"
    end

    components = String[]
    
    push!(components, "SELECT $(join(q.select_clause, ", "))")
    push!(components, "FROM $(q.from_clause)")
    
    !isempty(q.where_clause) && push!(components, "WHERE $(join(q.where_clause, " "))")
    !isempty(q.order_by_clause) && push!(components, "ORDER BY $(join(q.order_by_clause, ", "))")
    !isnothing(q.limit_clause) && push!(components, "LIMIT $(q.limit_clause)")
    !isnothing(q.offset_clause) && push!(components, "OFFSET $(q.offset_clause)")
    
    join(components, " ")
end

function sample_usage()
    println("QueryBuilder and SQLiteHelper Integration Example")
    println("------------------------------------------------")

    # Create a database and table
    db_name = "querybuilder_example.db"
    db = SQLiteHelper.create_database(db_name)
    SQLiteHelper.create_table(db, "people", Dict("id" => "INTEGER PRIMARY KEY", "name" => "TEXT", "age" => "INTEGER"))

    # Insert sample data
    sample_data = [
        ("Alice", 32), ("Bob", 28), ("Charlie", 45), ("David", 39), ("Eve", 27),
        ("Frank", 35), ("Grace", 41), ("Henry", 30), ("Iris", 36), ("Jack", 29)
    ]
    insert_query = Query()
    insert_query = insert_into(insert_query, "people")
    insert_query = values(insert_query, "name", "age")
    insert_sql = build(insert_query)
    
    for (name, age) in sample_data
        SQLiteHelper.execute_query(db, insert_sql, (name, age))
    end

    println("\nSample data inserted into 'people' table.")

    # Use QueryBuilder to construct various queries
    queries = [
        (build(from(select(Query(), "*"), "people")), 
         "Select all people:"),
        (build(where(from(select(Query(), "name", "age"), "people"), "age > 30")), 
         "Select people over 30:"),
        (build(limit(order_by(from(select(Query(), "name"), "people"), "age DESC"), 3)), 
         "Select top 3 oldest people:"),
        (build(from(select(Query(), "AVG(age) as avg_age"), "people")), 
         "Calculate average age:"),
        (build(or_(where(from(select(Query(), "name"), "people"), "age < 30"), "age > 40")), 
         "Select people younger than 30 or older than 40:")
    ]

    # Execute and display results for each query
    for (sql, description) in queries
        println("\n$description")
        println("SQL: $sql")
        result = SQLiteHelper.query_to_dataframe(db, sql)
        println(result)
    end

    # Clean up
    println("\nCleaning up...")
    SQLiteHelper.DBInterface.close!(db)
    SQLiteHelper.delete_db_file(db_name)
    println("Database connection closed and file deleted.")
end

end # module QueryBuilder