# Hypervolumes to Assess Ecosystem Stability 
![](pretty-gif.gif) 
**Author:** David Bridgwood *dmb2417@ic.ac.uk*

**Description:** code for masters project

## Dependencies

*The following python libraries are required:*

- pandas
- numpy


*The following R packages are required:*

- vegan
- hypervolume

## How to Run


## To Do
- hypervolume svs vs gaussian?
- general how to do species ordination questions
- data questions
	- mammals: what do all the comments mean? E100-1 vs E100-2, same or different plot?
- run_project.py script to walk through all code files
- link to stability
- sort out data diectory


## Repository Structure
```

masters_project/
├── Code/
│   │
│   ├── 00_hv_functions.R
│   ├── compare_hv.R
│   ├── sort_data.py
│   └── species_ordination.R
│
├── Data/
│   │
│   ├── family_list.csv
│   │
│   ├── RAW/
│   │   ├── beetles/
│   │   │   ├── family_list.csv
│   │   │   ├── README.txt
│   │   │   └── trap_summaries.csv
│   │   │
│   │   ├── SAFE_toDavidBridgwood_Stability/
│   │   │   ├── Riutta_et_al-2018-Global_Change_Biology_OnlineEarlyVersion.pdf
│   │   │   ├── Riutta_et_al-2018-Global_Change_Biology_SupportingInformation.pdf
│   │   │   ├── SAFE_CarbonPlots_FineRoots_Stock+NPP.xlsx
│   │   │   ├── SAFE_CarbonPlots_Litterfall.xlsx
│   │   │   ├── SAFE_CarbonPlots_Tree+LianaCensus.xlsx
│   │   │   └── SAFE_Maliau_Danum_CarbonPlots_Maps.pdf
│   │   │
│   │   ├── small_mammals/
│   │   │   ├── Grid trapping dates 2011-2016.xlsx
│   │   │   ├── SAFE Map E.png
│   │   │   ├── SAFE Map overview.png
│   │   │   ├── SAFE small mammal Catch Totals 2011-2016.xlsx
│   │   │   └── SAFE small mammals E 2011-2016.xlsx
│   │   │
│   │   └── template_Pfeifer.xlsx
│   │
│   ├── SAFE_CarbonPlots_FineRoots_Stock+NPP.xlsx
│   ├── SAFE_CarbonPlots_Litterfall.xlsx
│   ├── SAFE_CarbonPlots_Tree+LianaCensus.csv
│   ├── SAFE_CarbonPlots_Tree+LianaCensus.xlsx
│   └── small_mammals.csv
│
├── Results/
│   ├── beetles_matrix.csv
│   ├── beetles_sorted.csv
│   ├── mammal_mds_out.Rdata
│   ├── mammals_matrix.csv
│   ├── mammals_sorted.csv
│   ├── mds_out.Rdata
│   ├── trees_matrix.csv
│   └── trees_sorted.csv
│
└── Sandbox/
    ├── code/
    │   ├── beetles_hv.R
    │   ├── sort_beetles_data.py
    │   ├── sort_mammal_data.py
    │   ├── sort_tree_data.py
    │   ├── test_hypvlm.R
    │   └── test_PCA.R
    ├── demo/
    └── Reading
        ├── Papers/
        ├── CMEE-APROJECT!.bib
        ├── Reading.pdf
        └── Reading.tex
        

```
