#!/bin/bash

p_set=("0.6")
rho_set=("0.3")
hn_set=("0.1")
nsieve_set=("20")
dft_set=("3" "5" "10" "15" "20" "30")
dir="res"

mkdir -p ${dir}

for nsieve in ${nsieve_set[@]};
do
	for hn in ${hn_set[@]}; 
	do
		for p in ${p_set[@]};
		do
			for rho in ${rho_set[@]};
			do
				for dft in ${dft_set[@]};
				do
					subdir=${dir}/dft${dft}
					mkdir -p ${subdir}
					
					echo "#!/bin/bash" > tmp.slurm
					echo "" >> tmp.slurm
					echo "#SBATCH --mail-user=r.tao@vanderbilt.edu  # email address" >> tmp.slurm
					echo "#SBATCH --mail-type=NONE  # Alerts sent when job begins, ends, or aborts" >> tmp.slurm
					echo "#SBATCH --nodes=1   # Number of nodes required" >> tmp.slurm
					echo "#SBATCH --ntasks=1   # Number of nodes required" >> tmp.slurm
					echo "#SBATCH --mem=4G  # Total memory (RAM) required, per node" >> tmp.slurm
					echo "#SBATCH --time=02-00:00:00  # Wall Clock time (dd-hh:mm:ss) [max of 14 days]" >> tmp.slurm
					echo "#SBATCH --array=1-10" >> tmp.slurm
					echo "#SBATCH --output=${subdir}/%A_%a.slog  # output and error messages go to this file" >> tmp.slurm
					echo "#SBATCH --job-name=SMLE # job name" >> tmp.slurm
					echo "#SBATCH --constraint=\"sandybridge|haswell|skylake\"" >> tmp.slurm
					echo "" >> tmp.slurm
					echo "echo \"SLURM_JOBID: \" \$SLURM_JOBID" >> tmp.slurm
					echo "echo \"SLURM_ARRAY_TASK_ID: \" \$SLURM_ARRAY_TASK_ID" >> tmp.slurm
					echo "echo \"SLURM_ARRAY_JOB_ID: \" \$SLURM_ARRAY_JOB_ID" >> tmp.slurm
					echo "" >> tmp.slurm
					echo "Rscript sim.R \$SLURM_ARRAY_TASK_ID ${rho} ${p} ${hn} ${nsieve} ${subdir} ${dft}" >> tmp.slurm
					
					# cat tmp.slurm
					sbatch tmp.slurm
					rm -rf tmp.slurm
				done
			done
		done
	done
done

