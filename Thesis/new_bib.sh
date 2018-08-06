#!/bin/bash                                                                                                         
# Author: David Bridgwood dmb2417@ic.ac.uk                                                                          
# Script: new_bib.sh                                                                                            
# Desc: replaces thesis.bib with updated one from where mendeley saves it                                                                        
# Date: Aug 2018 


rm thesis.bib
cp ../../Documents/bibtex/APROJECT!.bib .
mv APROJECT!.bib thesis.bib
