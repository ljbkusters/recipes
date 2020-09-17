"""
command line script that takes a link and outputs a
markdown file.

Used scraper scripts: recipe-scrapers
install via: pip install recipe-scrapers
github: https://github.com/hhursev/recipe-scrapers
"""
import recipe_scrapers as rs
import sys
import os

if len(sys.argv) > 2:
    print("please provide a valid link (1 argument)") 
    exit()

# get link from command line
link = str(sys.argv[1])

# scrape target at link adress
recipe = rs.scrape_me(link)

r_title     = recipe.title()            # recipe title
r_time      = recipe.total_time()       # time required
r_yields    = recipe.yields()           # yields
r_ingr      = recipe.ingredients()      # required ingredients
r_instr     = recipe.instructions()     # instructions

# test
print(r_title, r_time, r_yields, r_ingr, r_instr)


# ingredients list/array to md list
str_ingr = ""
for ingr in r_ingr:
    str_ingr += "+ %s\n" % ingr

# format md file
md_str = """
# %s
source: %s
yield: %s
time: %s (m)

## Ingredients

%s

## Instructions

%s
""" % (r_title, link, r_yields, r_time, str_ingr, r_instr)

# print md file to string/stdo
print(md_str)

# save md file

# format title string
title_words_array = r_title.split(" ")
fs_title = ""
for word in title_words_array:
    if any(chars in word for chars in ["(", ")", ",", " ", ";", "."]):
        break
    fs_title += word

fs_title += ".md"

md_dir = "./md"
file_location = os.path.join( md_dir, fs_title )
out_file = open('%s' % file_location, 'w')
out_file.write(md_str)
out_file.close()
