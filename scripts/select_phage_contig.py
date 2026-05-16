import pandas as pd


def get_viralverify_csv(viralverify_csv):
    return pd.read_csv(viralverify_csv)


def get_info_viralverify(df):
    # Header:
    #   Contig name, Prediction, Length, Circular, Score, Pfam hits
    #
    # Possible predictions:
    #   - "Virus"
    #   - "Plasmid"
    #   - "Chromosome"
    #   - "Uncertain - viral or bacterial"
    #   - "Uncertain - too short"
    #   - "Uncertain - plasmid or chromosomal"

    viral_info = {}
    for i, row in df.iterrows():
        contig_name = row["Contig name"]
        prediction = row["Prediction"]
        size = row["Length"]

        if prediction in ["Virus", "Uncertain - viral or bacterial"]:
            viral_info[contig_name] = [prediction, size]
        
    return viral_info


# If there is more than one contig, selects the longest
def get_viral_contig(viral_info):
    if viral_info:
        # x[1] gets the value (list of [prediction, size]), and x[1][1] gets the size
        viral_contig = max(viral_info.items(), key=lambda x: x[1][1])[0]
        return viral_contig
    else:
        return None


def export_fasta(viral_contig, contigs_fasta, output_fasta):
    fasta = {}
    current_contig = None

    with open(contigs_fasta, "r") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            if line.startswith(">"):
                # gets the contig name without >
                contig_name = line[1:].split()[0]  
                if contig_name == viral_contig:
                    current_contig = contig_name
                    fasta[current_contig] = []
                else:
                    current_contig = None
            else:
                if current_contig:
                    fasta[current_contig].append(line)

    with open(output_fasta, "w") as f:
        for contig_name,seqs in fasta.items():
            fasta_seq = "".join(seqs)
            f.write(f">{contig_name}\n{fasta_seq}\n")



def main():
    df = get_viralverify_csv(snakemake.input.report)
    viral_info = get_info_viralverify(df)
    viral_contig = get_viral_contig(viral_info)
    export_fasta(viral_contig, snakemake.input.contigs, snakemake.output.phage_fasta)



if __name__ == "__main__":
    main()