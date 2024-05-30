import sys

def find_matching_rows(tped_filename, sites_filename):
    # Load sites data into a dictionary where the key is the second column (joined with '_') and the value is a set of the third and fourth columns
    sites_dict = {}
    with open(sites_filename, 'r') as sites_file:
        for line in sites_file:
            columns = line.strip().split()
            key = '_'.join([columns[0], columns[1]])
            value = (columns[2], columns[3])
            if key not in sites_dict:
                sites_dict[key] = set()
            sites_dict[key].add(value[0])
            sites_dict[key].add(value[1])

    # Process each line in the tped file
    with open(tped_filename, 'r') as tped_file:
        for tped_line in tped_file:
            tped_columns = tped_line.strip().split()
            tped_key = tped_columns[1]  # Assuming this is the correct column based on your description
            tped_allele = tped_columns[5]  # Assuming this column contains the allele info

            # Check if there's a matching key in the dictionary and if the allele is present in the set
            if tped_key in sites_dict and tped_allele in sites_dict[tped_key]:
                print(tped_line.strip())  # Print the row that meets the criteria

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script_name.py tped_filename sites_filename")
    else:
        tped_filename = sys.argv[1]
        sites_filename = sys.argv[2]
        find_matching_rows(tped_filename, sites_filename)
