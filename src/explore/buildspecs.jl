## Mimi UI
using Mimi
using DataFrames

function getspeclist(model::Mimi.Model)
    #initialize the speclist
    allspecs = []

    #get all components of model
    comps = components(model)
    for c in comps

        #get all variables of component
        vars = variables(model, c)
        for v in vars

            #pull information 
            name = string(c," : ",v) #returns the name of the pair as "component:variable"
            df = getdataframe(model, c, v) #returns the  corresponding dataframe

            #choose type of plot
            if names(df)[1] == :time
                if length(names(df)) > 2
                    spec = createspec_multilineplot(name, df)
                else
                    spec = createspec_lineplot(name, df)
                end
            else
                spec = createspec_barplot(name, df)
            end

            #add to spec list
            push!(allspecs, spec) 

        end

        #TO DO :  get all parameters of component

    end
    return allspecs
end

function createspec_lineplot(name, df)
    datapart = getdatapart(df, :line) #returns a list of dictionaries    
    spec = Dict(
        "name"  => name,
        "VLspec" => Dict(
            "schema" => "https://vega.github.io/schema/vega-lite/v2.0.json",
            "description" => "plot for a specific component variable pair",
            "title" => name,
            "data"=> Dict("values" => datapart),
            "mark" => "line",
            "encoding" => Dict(
                "x" => Dict("field" => string(names(df)[1]), "type" => "temporal", "axis" => Dict("format" => "%Y" )),
                "y" => Dict("field" => string(names(df)[2]), "type" => "quantitative" )
            ),
            "width" => 400,
            "height" => 400 
        ),
    )
    return spec
end

function createspec_barplot(name, df)
    datapart = getdatapart(df, :bar) #returns a list of dictionaries    
    spec = Dict(
        "name"  => name,
        "VLspec" => Dict(
            "schema" => "https://vega.github.io/schema/vega-lite/v2.0.json",
            "description" => "plot for a specific component variable pair",
            "title" => name,
            "data"=> Dict("values" => datapart),
            "mark" => "line",
            "encoding" => Dict(
                "x" => Dict("field" => string(names(df)[1]), "type" => "ordinal"),
                "y" => Dict("field" => string(names(df)[2]), "type" => "quantitative" )
            ),
            "width" => 400,
            "height" => 400 
        ),
    )
    return spec
end

function createspec_multilineplot(name, df)
    datapart = getdatapart(df, :multiline) #returns a list of dictionaries    
    spec = Dict(
        "name"  => name,
        "VLspec" => Dict(
            "schema" => "https://vega.github.io/schema/vega-lite/v2.0.json",
            "description" => "plot for a specific component variable pair",
            "title" => name,
            "data"=> Dict("values" => datapart),
            "mark" => "line",
            "encoding" => Dict(
                "x" => Dict("field" => string(names(df)[1]), "type" => "temporal", "axis" => Dict("format" => "%Y" )),
                "y" => Dict("field" => string(names(df)[3]), "type" => "quantitative" ),
                "color" => Dict("field" => string(names(df)[2]), "type" => "nominal")
            ),
            "width" => 400,
            "height" => 400 
        ),
    )
    return spec
end

function getdatapart(df, plottype::Symbol = :line)

    #initialize a list for the datapart
    datapart = [];
    
    #loop over rows and create a dictionary for each row
    if plottype == :multiline
        for row in eachrow(df)
            rowdata = Dict(string(names(df)[1])=> row[1], string(names(df)[3]) => row[3], 
                string(names(df)[2]) => row[2])
            push!(datapart, rowdata)
        end 
    else
        for row in eachrow(df)
            rowdata = Dict(string(names(df)[1])=> row[1], string(names(df)[2]) => row[2])
            push!(datapart, rowdata)
        end 
    end
    return datapart
end