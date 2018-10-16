#!/usr/bin/env python3

"""
Author:      David Bridgwood (dmb2417@ic)
Description: """

__author__  = 'David Bridgwood (dmb2417@ic.ac.uk)'
__version__ = '0.0.1'

# imports
import pandas as pd

import general_funcs as gf

################################################################################
# mammals data
################################################################################

# sort each plot in turn
def sort_mams(df):

    # new column names
    ncolnames   = ["occasion", "date", "grid", "point", "trap", "trap_id", "species"]
    df.columns  = ncolnames

    # stupid formatting sorted
    df["occasion"]  = df.occasion.str.replace("--", "-")
    df["plot"]      = df.occasion.str[0]
    #df["plot"]      = df.grid  **think it would be worth giving this another go!**
    df["grid"]      = df.grid.str.replace("--", "-")
    df["trap_id"]   = df.trap_id.str.replace("--", "-")
    df["trap_id"]   = df.trap_id.apply(lambda x: x[:-1])
    df["date"]      = pd.to_datetime(df.date)
    df["year"]      = df.date.dt.year
    df["census"]    = df.occasion.str.partition("-")[2].str.partition("-")[2]

    return df

# and combine for all plots
def sort_mams_all(*args):
    frames = []
    for i in args:
        i = sort_mams(i)
        frames.append(i)

    df            = pd.concat(frames, sort = False)
    df["species"] = df.species.fillna("none")
    df["species"] = df.species.str.strip()

    # my fairly questionable decisions...
    # if its a questionmark - I just go with it
    # if its an either or I go with the first one!
    df.loc[df.loc[:, "species"] == "CTRS-but see notes", "species"] = "CTRS"

    df.loc[df.loc[:, "species"] == "SS?",          "species"] = "SS"
    df.loc[df.loc[:, "species"] == "WH?",          "species"] = "WH"
    df.loc[df.loc[:, "species"] == "PR?",          "species"] = "PR"
    df.loc[df.loc[:, "species"] == "RR?",          "species"] = "RR"
    df.loc[df.loc[:, "species"] == "MR?",          "species"] = "MR"
    df.loc[df.loc[:, "species"] == "MR??",         "species"] = "MR"
    df.loc[df.loc[:, "species"] == "RS?",          "species"] = "RS"
    df.loc[df.loc[:, "species"] == "LGTRS?",       "species"] = "LGTRS"
    df.loc[df.loc[:, "species"] == "BS?",          "species"] = "BS"
    df.loc[df.loc[:, "species"] == "PSQ",          "species"] = "LSQ"      # not confident on this
    df.loc[df.loc[:, "species"] == "BSQ",          "species"] = "BSQ?"
    df.loc[df.loc[:, "species"] == "SSQ",          "species"] = "SSQ?"
    df.loc[df.loc[:, "species"] == "RS or SS" ,    "species"] = "RS"
    df.loc[df.loc[:, "species"] == "WH or SS",     "species"] = "WH"
    df.loc[df.loc[:, "species"] == "BS/RS?",       "species"] = "BS"
    df.loc[df.loc[:, "species"] == "PTSQ?",        "species"] = "PTSQ"
    df.loc[df.loc[:, "species"] == "LETRS",        "species"] = "LETRS?"   # for some reason the lookup table has a ?
    df.loc[df.loc[:, "species"] == "CBS?",         "species"] = "CBS"
    df.loc[df.loc[:, "species"] == "SL?TRS",       "species"] = "SLTRS"
    df.loc[df.loc[:, "species"] == "SLTRS?",       "species"] = "SLTRS"
    df.loc[df.loc[:, "species"] == "L?TRS",        "species"] = "SLTRS"
    df.loc[df.loc[:, "species"] == "LSQ?",         "species"] = "LSQ"
    df.loc[df.loc[:, "species"] == "CTRS?",        "species"] = "CTRS"
    df.loc[df.loc[:, "species"] == "LTRS or CTRS", "species"] = "CTRS"     # went with CTRS as LTRS could refer to a couple
    df.loc[df.loc[:, "species"] == "LTRS",         "species"] = "LETRS?"   # not convinced about this one
    df.loc[df.loc[:, "species"] == "Squirrel",     "species"] = "squirrel"
    df.loc[df.loc[:, "species"] == "DTT_DEAD",     "species"] = "DTT"
    df.loc[df.loc[:, "species"] == "LSQ?_DEAD",    "species"] = "LSQ"
    df.loc[df.loc[:, "species"] == "squirrel",     "species"] = "unknown"  # ***mmm?***
    df.loc[df.loc[:, "species"] == "See notes",    "species"] = "unknown"  # i'm effectivley treating 'unknown' as a seperate species which seems spurious at best
    df.loc[df.loc[:, "species"] == "??",           "species"] = "unknown"
    df.loc[df.loc[:, "species"] == "?",            "species"] = "unknown"
    df.loc[df.loc[:, "species"] == "Unknown",      "species"] = "unknown"

    return df

def lkup_merge(df, lkup):
    # merge
    df = pd.merge(df,
                  lkup[["code", "scientific"]],
                  how      = "left",
                  left_on  = "species",
                  right_on = "code")

    # get rid of the leftovers... (there were a couple of birds/reptiles)
    df = df.loc[-df.code.isna(), :]

    return df

def closest_trap(df, traps, others):

    # find closest f2 point to each trap and get agb measure
    # get all the unique trap names
    trap_locs = pd.DataFrame({"trap_id" : df.trap_id.unique()})
    trap_locs = trap_locs.merge(traps[["location", "longlat"]],
                                how      = "left",
                                left_on  = "trap_id",
                                right_on = "location")

    # find the closest second order fractal point
    trap_locs[["second_order", "distance_so"]] = trap_locs.longlat.apply(lambda x: gf.closest(x, others))

    # merge back to master dataframe
    df = df.merge(trap_locs, how = "left", on = "trap_id")

    # just want the point number
    df.second_order = df.second_order.str[-3:]
    df.second_order = df.second_order.astype(int)

    return df

def merge_agb(df, agb):
    # merge to get agb and forest quality
    df = df.merge(agb[["second_order", "agb", "forestquality"]], how = "left",
                  on = "second_order")
    return df

def cleanup(df):

    # final cleanup and save
    df = df.rename(index=str, columns={"plot_x": "plot"})

    df = df[["occasion",
             "date",
             "grid",
             "point",
             "trap",
             "trap_id",
             "species",
             "year",
             "plot",
             "census",
             "scientific",
             "longlat",
             "second_order",
             "distance_so",
             "agb",
             "forestquality"]]

    return df
