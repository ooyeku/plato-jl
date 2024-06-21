module SQLiteHelper

using SQLite
using DataFrames

export create_database, create_table, execute_query, query_to_dataframe, load_dataframe_to_table, 
       delete_table, delete_db_file, example_usage

"""
Create a new SQLite database or connect to an existing one.
"""
function create_database(db_name::String)
    SQLite.DB(db_name)
end

"""
Create a new table in the given database.
"""
function create_table(db::SQLite.DB, table_name::String, columns::Dict{String, String})
    query = "CREATE TABLE IF NOT EXISTS $table_name ("
    query *= join(["$col $type" for (col, type) in columns], ", ")
    query *= ")"
    
    DBInterface.execute(db, query)
end

"""
Execute a SQL query on the given database.
"""
function execute_query(db::SQLite.DB, query::String, params::Tuple=())
    if isempty(params)
        DBInterface.execute(db, query)
    else
        DBInterface.execute(db, query, params)
    end
end
"""
Execute a SQL query and return the result as a DataFrame.
"""
function query_to_dataframe(db::SQLite.DB, query::String)
    DataFrame(DBInterface.execute(db, query))
end

"""
Load a DataFrame into a SQLite table.
"""
function load_dataframe_to_table(db::SQLite.DB, df::DataFrame, table_name::String)
    columns = Dict(String(name) => julia_type_to_sqlite_type(eltype(col)) for (name, col) in pairs(eachcol(df)))
    create_table(db, table_name, columns)
    
    placeholders = join(fill("?", ncol(df)), ", ")
    query = "INSERT INTO $table_name VALUES ($placeholders)"
    
    DBInterface.execute(db, query, [collect(row) for row in eachrow(df)])
end

"""
Delete all records from a table.
"""
function delete_table(db::SQLite.DB, table_name::String)
    execute_query(db, "DELETE FROM $table_name")
end

"""
Delete the database file.
"""
function delete_db_file(db_name::String)
    isfile(db_name) && rm(db_name)
end

"""
Convert Julia types to SQLite types.
"""
function julia_type_to_sqlite_type(T::Type)
    if T <: Integer
        "INTEGER"
    elseif T <: AbstractFloat
        "REAL"
    elseif T <: AbstractString
        "TEXT"
    else
        "BLOB"
    end
end

"""
Demonstrate usage of the SQLiteHelper functions.
"""
function example_usage()
    db_name = "example.db"
    println("Creating a new database...")
    db = create_database(db_name)

    println("\nCreating a new table...")
    columns = Dict("id" => "INTEGER PRIMARY KEY", "name" => "TEXT", "age" => "INTEGER")
    create_table(db, "people", columns)

    println("\nInserting data...")
    data = [
        ("Alice", 30), ("Bob", 25), ("Charlie", 35), ("Dave", 40), ("Eve", 38),
        ("Frank", 32), ("Grace", 28), ("Henry", 36), ("Ivy", 29), ("John", 33),
        ("Kelly", 31), ("Lisa", 27), ("Mike", 34), ("Nancy", 26), ("Oliver", 37),
        ("Peter", 39), ("Queen", 30), ("Rachel", 25), ("Samantha", 35), ("Tom", 40),
        ("Uma", 24), ("Victoria", 32), ("Wendy", 28), ("Xavier", 39), ("Yvonne", 27),
        ("Zach", 31), ("Zoe", 23)
    ]
    
    for (name, age) in data
        execute_query(db, "INSERT INTO people (name, age) VALUES (?, ?)", (name, age))
    end

    println("\nQuerying data...")
    df = query_to_dataframe(db, "SELECT * FROM people")
    println(df)

    println("\nLoading a DataFrame into a new table...")
    new_data = DataFrame(
        product = ["Apple", "Banana", "Cherry"],
        price = [0.5, 0.3, 0.8],
        stock = [100, 150, 75]
    )
    load_dataframe_to_table(db, new_data, "products")

    println("\nQuerying the new table...")
    df_products = query_to_dataframe(db, "SELECT * FROM products")
    println(df_products)

    println("\nClosing the database connection...")
    DBInterface.close!(db)

    println("\nExample usage completed successfully!")
    delete_db_file(db_name)
end

end