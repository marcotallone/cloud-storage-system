import csv

# Define the input and output file paths
INPUT_FILE = "/home/marco/cloud/final/ex3n/benchmarks/results.txt"
OUTPUT_FILE = "results.csv"

# Initialize variables
data = []
CURRENT_JOB = None

# Read the input file
with open(INPUT_FILE, "r", encoding="utf-8") as file:
    for line in file:
        line = line.strip()

        # Check for job lines
        if line.startswith("JOB:"):
            CURRENT_JOB = line.split(":")[1].strip().replace(".yaml", "")

        # Skip header and separator lines
        if line.startswith("#") or line.startswith("-"):
            continue

        # Split the line into columns
        columns = line.split()

        # Check if it's a broadcast test (has min and max latency)
        if len(columns) == 8:
            size, latency, min_latency, max_latency, iterations, p50, p95, p99 = columns
        elif len(columns) == 5:
            size, latency, p50, p95, p99 = columns
            min_latency = max_latency = ""
            iterations = "10000"
        else:
            # Skip lines that don't match the expected format
            continue

        # Append the data to the list
        data.append(
            [
                size,
                latency,
                min_latency,
                max_latency,
                iterations,
                p50,
                p95,
                p99,
                CURRENT_JOB,
            ]
        )

# Write the data to a CSV file
with open(OUTPUT_FILE, "w", newline="", encoding="utf-8") as csvfile:
    csvwriter = csv.writer(csvfile)
    # Write the header
    csvwriter.writerow(
        ["size", "latency", "min", "max", "iterations", "p50", "p95", "p99", "job"]
    )
    # Write the data rows
    csvwriter.writerows(data)

print(f"Data has been written to {OUTPUT_FILE}")
