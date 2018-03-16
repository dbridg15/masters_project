Insect trapping data from SAFE Project
Adam Sharp
adam.sharp10@imperial.ac.uk

Two CSV files containing identities of beetles caught with time/location. The data is very hole-y and missing whole transects (samples not yet processed), so I would recommend only using 2011 to 2012 and using both files to separate true counts of 0 from missing data points.

File 1: family_list.csv
Identities of approximately 30,000 beetles trapped at SAFE Project. Column 1 = date, where February 2011 is discrete sampling period 1, October/November 2011 is discrete sampling period 2, and mid 2012 is discrete sampling period 3. Columns 2 and 3 = trap location. Columns 4 = family name.

File 2: trap_summaries.csv
Used to work out absences from the presences in family_list.csv. Column 1 = trapping period. Column 2 = trap number from SAFE hierachical design. Column 3 = total count of insects from that trap. Column 4 = whether (TRUE) or not (FALSE) that sample has been processed and is therefore present in family_list.csv.

Cheers


