using LightXML
using FileIO
using Glob

struct XMLMaterial
    object_names::Vector{String}
    diffuse::Dict{Symbol,Float64}
    ambient::Dict{Symbol,Float64}
    emission::Dict{Symbol,Float64}
    transparency::Float64
end

function parse_xml_materials(xml_file::String)
    xdoc = parse_file(xml_file)
    xroot = root(xdoc)
    materials = XMLMaterial[]

    for anim in get_elements_by_tagname(xroot, "animation")
        type_elements = get_elements_by_tagname(anim, "type")
        isempty(type_elements) && continue
        anim_type = content(type_elements[1])

        if anim_type == "material"
            object_names = [content(obj) for obj in get_elements_by_tagname(anim, "object-name")]
            isempty(object_names) && continue

            # Valori di default
            diffuse = Dict(:red => 1.0, :green => 1.0, :blue => 1.0)
            ambient = Dict(:red => 0.2, :green => 0.2, :blue => 0.2)
            emission = Dict(:red => 0.0, :green => 0.0, :blue => 0.0)
            transparency = 0.0

            # Parsing DIFFUSE
            diffuse_node = get_elements_by_tagname(anim, "diffuse")
            if !isempty(diffuse_node)
                red_e = get_elements_by_tagname(diffuse_node[1], "red")
                green_e = get_elements_by_tagname(diffuse_node[1], "green")
                blue_e = get_elements_by_tagname(diffuse_node[1], "blue")

                diffuse[:red] = !isempty(red_e) ? parse(Float64, content(red_e[1])) : 1.0
                diffuse[:green] = !isempty(green_e) ? parse(Float64, content(green_e[1])) : 1.0
                diffuse[:blue] = !isempty(blue_e) ? parse(Float64, content(blue_e[1])) : 1.0
            end

            # Parsing AMBIENT
            ambient_node = get_elements_by_tagname(anim, "ambient")
            if !isempty(ambient_node)
                red_e = get_elements_by_tagname(ambient_node[1], "red")
                green_e = get_elements_by_tagname(ambient_node[1], "green")
                blue_e = get_elements_by_tagname(ambient_node[1], "blue")

                ambient[:red] = !isempty(red_e) ? parse(Float64, content(red_e[1])) : 0.2
                ambient[:green] = !isempty(green_e) ? parse(Float64, content(green_e[1])) : 0.2
                ambient[:blue] = !isempty(blue_e) ? parse(Float64, content(blue_e[1])) : 0.2
            end

            # Parsing EMISSION
            emission_node = get_elements_by_tagname(anim, "emission")
            if !isempty(emission_node)
                red_e = get_elements_by_tagname(emission_node[1], "red")
                green_e = get_elements_by_tagname(emission_node[1], "green")
                blue_e = get_elements_by_tagname(emission_node[1], "blue")

                emission[:red] = !isempty(red_e) ? parse(Float64, content(red_e[1])) : 0.0
                emission[:green] = !isempty(green_e) ? parse(Float64, content(green_e[1])) : 0.0
                emission[:blue] = !isempty(blue_e) ? parse(Float64, content(blue_e[1])) : 0.0
            end

            # Parsing TRANSPARENCY
            transparency_node = get_elements_by_tagname(anim, "transparency")
            if !isempty(transparency_node)
                alpha_e = get_elements_by_tagname(transparency_node[1], "alpha")
                transparency = !isempty(alpha_e) ? parse(Float64, content(alpha_e[1])) : 0.0
            end

            push!(materials, XMLMaterial(object_names, diffuse, ambient, emission, transparency))
        end
    end

    free(xdoc)
    return materials
end

function modify_ac_file(ac_file::String, xml_materials::Vector{XMLMaterial})
    lines = readlines(ac_file)

    # Estrai header, materiali esistenti e resto del file
    header = String[]
    material_lines = String[]
    other_lines = String[]
    has_header = false

    for line in lines
        if !has_header && startswith(line, "AC3Db")
            push!(header, line)
            has_header = true
        elseif has_header && startswith(line, "MATERIAL")
            push!(material_lines, line)
        else
            push!(other_lines, line)
        end
    end

    # Mappa materiali esistenti
    material_map = Dict{String,Int}()
    for (idx, line) in enumerate(material_lines)
        mat_name = match(r"MATERIAL \"(.*?)\"", line).captures[1]
        material_map[mat_name] = idx
    end

    # Processa materiali XML (GESTIONE MULTIPLI OBJECT-NAME)
    new_material_lines = copy(material_lines)
    for mat in xml_materials
        isempty(mat.object_names) && continue

        # Crea un materiale PER OGNI object-name
        for obj_name in mat.object_names
            # Costruisci linea del materiale
            mat_line = "MATERIAL \"$obj_name\" rgb " *
                       "$(mat.diffuse[:red]) $(mat.diffuse[:green]) $(mat.diffuse[:blue]) " *
                       "amb $(mat.ambient[:red]) $(mat.ambient[:green]) $(mat.ambient[:blue]) " *
                       "emis $(mat.emission[:red]) $(mat.emission[:green]) $(mat.emission[:blue]) " *
                       "spec 0.5 0.5 0.5 shi 10 trans $(mat.transparency)"

            # Sovrascrivi o aggiungi
            if haskey(material_map, obj_name)
                new_material_lines[material_map[obj_name]] = mat_line
            else
                push!(new_material_lines, mat_line)
                material_map[obj_name] = length(new_material_lines)
            end
        end
    end

    # Ricostruisci file
    final_lines = vcat(header, new_material_lines, other_lines)

    # Aggiorna indici mat
    current_obj = ""
    material_indices = Dict{String,Int}()
    for (idx, line) in enumerate(new_material_lines)
        mat_name = match(r"MATERIAL \"(.*?)\"", line).captures[1]
        material_indices[mat_name] = idx - 1  # Indici partono da 0
    end
    default_index = get(material_indices, "DefaultWhite", 0)

    for (i, line) in enumerate(final_lines)
        if startswith(line, "name")
            m = match(r"name \"(.*?)\"", line)
            m !== nothing && (current_obj = m.captures[1])
        elseif startswith(line, "mat")
            if haskey(material_indices, current_obj)
                final_lines[i] = "mat $(material_indices[current_obj])"
            else
                final_lines[i] = "mat $default_index"
            end
        end
    end

    # Scrivi il file
    open(ac_file, "w") do f
        for line in final_lines
            println(f, line)
        end
    end
end

function is_valid_propertylist(xml_file::String)
    try
        xdoc = parse_file(xml_file)
        xroot = root(xdoc)
        valid = name(xroot) == "PropertyList" &&
                !isempty(get_elements_by_tagname(xroot, "path")) &&
                endswith(content(get_elements_by_tagname(xroot, "path")[1]), ".ac")
        free(xdoc)
        return valid
    catch e
        @warn "Errore nel parsing di $xml_file: $e"
        return false
    end
end

function get_ac_path(xml_file::String)
    xdoc = parse_file(xml_file)
    xroot = root(xdoc)
    path_element = content(get_elements_by_tagname(xroot, "path")[1])
    free(xdoc)

    if isabspath(path_element)
        return path_element
    else
        return normpath(joinpath(dirname(xml_file), path_element))
    end
end

function process_directory(root_dir::String)
    # Processa tutti gli XML nella directory corrente
    for file in glob("*.xml", root_dir)
        if is_valid_propertylist(file)
            ac_file = get_ac_path(file)
            if isfile(ac_file)
                @info "Processing: $file -> $ac_file"
                xml_materials = parse_xml_materials(file)
                modify_ac_file(ac_file, xml_materials)
            else
                @warn "File AC non trovato: $ac_file"
            end
        end
    end

    # Ricorsione sulle sottodirectory
    for entry in readdir(root_dir, join=true)
        if isdir(entry) && !occursin(r"^\..", basename(entry))  # Ignora cartelle nascoste
            process_directory(entry)
        end
    end
end

function main()
    root_dir = length(ARGS) > 0 ? ARGS[1] : pwd()
    @info "Avvio elaborazione in: $root_dir"
    process_directory(root_dir)
    @info "Elaborazione completata!"
end

main()
