import os
import hcl2
import json
import argparse

def extract_inputs_from_hcl_files(base_folder):
    inputs_data = {}

    # Walk through the directory tree
    for root, _, files in os.walk(base_folder):
        for file in files:
            if file.endswith(".hcl"):
                file_path = os.path.join(root, file)
                with open(file_path, 'r') as f:
                    try:
                        hcl_content = hcl2.load(f)
                        if 'inputs' in hcl_content:
                            folder_name = os.path.basename(root)
                            inputs_data[folder_name] = hcl_content['inputs']
                    except Exception as e:
                        print(f"Error parsing {file_path}: {e}")

    return inputs_data

def join_dicts(inputs, cnames):
    # Create a copy of the inputs to avoid modifying the original
    new_dict = {}
    inputs_clean = {key.replace('-cluster', '').replace('-memorystore', '').replace('-memcache', '').replace('-cloud', ''): value for key, value in inputs.items()}
    cnames_clean = {key.replace('-cluster', '').replace('-memorystore', '').replace('-memcache', '').replace('-cloud', ''): value for key, value in cnames.items()}

    # Iterate over the keys in inputs
    for key in inputs_clean:
        #ckey = key.replace('-cluster', '')
        new_dict[key] = {}
        # Check if the key exists in cnames
        
        if key in cnames_clean.keys():
            #ckey = ckey + '-memcache' + '-memorystore'
            # Add cache_cname and cnames to the corresponding entry in new_dict
            new_dict[key]["name"] = key
            new_dict[key]["region"] = cnames_clean[key]["cache_cname"].split('.')[1] if cnames_clean[key].get("cache_cname") else None
            new_dict[key]["service"] = inputs_clean[key]["labels"].get("tenantservice", None)

            #Redis Instance
            if "memory_size" in inputs_clean[key] and inputs_clean[key]["memory_size"]:
                new_dict[key]["memory_size"] = inputs_clean[key]["memory_size"]
                new_dict[key]["type"] = inputs_clean[key]["labels"].get("service", None).replace('raas_', '')

            #Redis Cluster
            if "shard_count" in inputs_clean[key] and inputs_clean[key]["shard_count"]:
                new_dict[key]["shard_count"] = inputs_clean[key]["shard_count"]
                new_dict[key]["node_type"] = inputs_clean[key].get("node_type", None)
                new_dict[key]["replica_count"] = inputs_clean[key].get("replica_count", None)
                new_dict[key]["type"] = inputs_clean[key]["labels"].get("service", None).replace('raas_', '')
            
            #Memcache
            if "node_count" in inputs_clean[key] and inputs_clean[key]["node_count"]:
                new_dict[key]["node_count"] = inputs_clean[key]["node_count"]
                new_dict[key]["cpu_count"] = inputs_clean[key].get("cpu_count", None)
                new_dict[key]["type"] = inputs_clean[key]["labels"].get("service", None).replace('raas_', '')

            new_dict[key]["cache_cname"] = cnames_clean[key]["cache_cname"]
            new_dict[key]["cnames"] = cnames_clean[key]["cnames"][0].get("gcp_backend", None)
            new_dict[key]["jira_ticket"] = inputs_clean[key]["labels"].get("ticket", None)

    return new_dict

def enrich_cache_data(input_data):
    # Create a new dictionary to store the transformed data
    transformed_data = {}

    # Loop through each cache entry in the input data
    for key, value in input_data.items():
        # Create a new dictionary for the transformed entry
        transformed_entry = {
            "cluster": value["cache_name"],  # Assign the cache name to the "cluster" key
            "memory_size": value["memory_size"],
            "node_count": value["node_count"],
            "cpu_count": value["cpu_count"]
        }

        # Extract the labels and add them to the transformed entry
        labels = value.get("labels", {})
        transformed_entry.update(labels)

        # Assign the transformed entry to the result dictionary
        transformed_data[key] = transformed_entry

    return transformed_data


def save_to_json(data, output_file):
    # Ensure the directory exists
    directory = os.path.dirname(output_file)
    if not os.path.exists(directory):
        os.makedirs(directory) 

    with open(output_file, 'w') as f:
        json.dump(data, f, indent=4)
    print(f"Data successfully written to {output_file}")

def main():
    parser = argparse.ArgumentParser(description="Extract inputs from HCL files and save to JSON.")
    parser.add_argument("env", choices=["prod", "stable"], help="Environment (prod or stable)")
    parser.add_argument("region", choices=["europe-west1", "us-central1"], help="Region (europe-west1 or us-central1)")
    parser.add_argument("engine", choices=["memcache", "redis"], help="Engine type (memcache or redis)")

    args = parser.parse_args()

    # Construir rutas dinámicas basadas en los argumentos
    base_folder_inputs = f"Projects/gcp-caches/raas-gcp/envs/{args.env}/{args.region}"
    if args.engine == "memcache":
        base_folder_inputs = os.path.join(base_folder_inputs, "memcache")
    else:
        base_folder_inputs = os.path.join(base_folder_inputs, "services")

    base_folder_cnames = f"Projects/gcp-caches/raas-gcp/envs/{args.env}/{args.region}/cnames"

    # Nombre del archivo de salida dinámico
    output_file_inputs = f"Projects/gcp-caches/raas-gcp/envs/catalog/{args.env}/{args.region}/{args.engine}.json"

    # Extraer inputs y guardar a JSON
    inputs_dict = extract_inputs_from_hcl_files(base_folder_inputs)
    cnames_dict = extract_inputs_from_hcl_files(base_folder_cnames)

    # Join the dictionaries
    result = join_dicts(inputs_dict, cnames_dict)
    save_to_json(result, output_file_inputs)

if __name__ == "__main__":
    main()
