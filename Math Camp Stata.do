* Welcome to Stata!

	* As in R, you can ask for help with code
	help mean

* For the sake of reference/replication, this is how you create vectors and matrices in Stata
	* You will probably never actually do this in Stata
	* Notice that the matrices aren't visibly saved anywhere
	* The only time this really becomes relevant is storing and retrieving results from regressions and other models

	matrix example = (1,2\3,4)
	matrix list example
	display example[2,1]

	matrix define example2 = example*2
	matrix list example2

	matrix vector = (1,2,3,4)
	matrix list vector
	display vector[1,3]

* Stata is really a software for working with datasets, so let's jump back into "world"

* Start by setting a working directory
* As in R, I recommend identifying this using point-and-click, and then copying the code

	cd "/Users/HenryWatson/Documents/Georgetown/TA/Math Camp/Software Demonstrations"
	
	* Loading in a csv dataset
	* We have some options here
		* varnames(1) means use the first row of the dataset as variable names
		* clear means replace whatever is currently in memory with the new data
	import delimited "poliscidata_world.csv", varnames(1) clear
	
* Exploring our dataset in Stata

	* A good start in Stata is to view the dataset
	* Note that this dataset viewer is more user-friendly than R's
	
	browse
	
	* We can sort
		sort dem_rank14
	* And reorder
		order dem_rank14, after(country)
	
	* Variables whose text is colored red are Strings (stored as text)
	* Variables whose text is colored black are Numeric
	* Variables whose text is colored blue are Labeled Numeric (we don't have any yet!)
	
	* Just typing codebook gives us a lot of information on every variable
	
	codebook
	
	* Can apply most commands to a "varlist"
		* A varlist is just a list of variables separated by spaces
		codebook country dem_level4 regionun religoin colony
		* But you can also specify a varlist by using a hyphen between the first and last in order
		codebook country-dem_score14
	
	* Similar for summarize (abbreviate to sum); but wait, we seem to have a problem
	
	summarize
	
	* Stata has stored too many of our numeric variables as strings out of caution
	* It does this because missing is coded as "NA", a character string
	* Stata wants missings to be . for numeric or "" (blanks) for strings
	* We'll use this as an opportunity to explore loops in just a minute
	* For now, let's just destring one or two variables
		* Force: convert any text strings to missing
		* Replace: replace the existing variable (as opposed to creating a new one)
		destring pop_total literacy-govregrel, force replace
		
	* Now we can summarize those numeric variables
	
		sum literacy-govregrel
		* In Stata, we specify options for commands after a comma
		* ",d" stands for "detail"
		sum literacy, d
		* mean is another useful summary statistics command
		mean literacy-govregrel
	
	* tab (tabulate) is your best friend in Stata (for categorical variables)
	
		tab dem_level4
		
		* List two categorical variables to create a cross-tabulation (cross-tab)
		tab dem_level4 regionun
		
		* Easily retrieve row and column percentages
		tab dem_level4 regionun, column
		tab dem_level4 regionun, row
		tab dem_level4 regionun, column nofreq
		
	* table is also our friend
		* The option "contents" is what makes the difference
		table dem_level4 regionun, contents(sum pop_total)
		table dem_level4 regionun, contents(mean literacy)
		
* Creating new variables in Stata

	* The main command for creating new variables in Stata is "gen" (generate)
	* We can work with both strings and numerics using gen
		gen country_lower = lower(country)
			codebook country_lower
		gen literacy_decimal = literacy/100
			sum literacy_decimal
	* We can also use "replace" to overwrite existing variables
		replace country_lower = proper(country_lower)
			codebook country_lower
		* Well now the name doesn't make sense
		* Let's use rename to easily change the variable name
			rename country_lower country_proper
	* Often useful to convert categorical variables to numeric codes (e.g. for regression)
		* Can do this manually
			* Good practice to start by creating an "empty" variable with all missing
			gen region_num = .
			* Then start replacing
				* Remember: "equals" in a conditional statement is a double equals sign ==
				replace region_num = 1 if regionun == "Africa"
				replace region_num = 2 if regionun == "Asia"
				replace region_num = 3 if regionun == "Australia/New Zealand/Oceania"
				replace region_num = 4 if regionun == "Europe"
				replace region_num = 5 if regionun == "Latin America/Caribbean"
				replace region_num = 6 if regionun == "USA/Canada"
				tab region_num
		* There MUST be a better way!
			* There is!
			encode regionun, gen(region_num_new)
			codebook region_num_new
		* Different usecase: dummy variables for each category
			tab regionun, gen(region_num)
			tab region_num2
	* Recode is another common way to transform categorical/ordinal variables
		destring polity, force replace
		tab polity
		recode polity (-10/-5 = 0) (-4/4 = 1) (5/10 = 2), gen(polity_recode)
		tab polity polity_recode
	* Once we have the recoded variable, we might want to label it
		label define polity_label 0 "Low" 1 "Medium" 2 "High"
		label values polity_recode polity_label
		tab polity_recode
		codebook polity_recode
	* More advanced variable creation: bysort and egen
		* group: very good for creating unique IDS when an individual is defined by multiple columns
		egen region_dem = group(regionun dem_level4)
		tab region_dem
		* bysort: generate variables are constant within values of another variable
		* Analogous to tapply() in R
		* "egen double" tells Stata how to store the result
		bysort regionun: egen literacy_region = mean(literacy)
		bysort regionun: egen double literacy_max = max(literacy)
		bysort regionun: egen double literacy_min = min(literacy)
		list regionun country literacy if literacy == literacy_max
	* Collapse
		* If we are only concerned with summary statistics by group, we can "collapse" the dataset
		* Note that this changes the dataset, so probably save first!
		save "world.dta", replace
		collapse (mean) dem_score14 literacy oil (sum) pop_total, by(regionun)
		rename dem_score14 dem_score_c
		rename literacy literacy_c
		rename oil oil_c
		rename pop_total pop_c
		* Save the collapsed dataset as well
		save "world_collapsed.dta", replace

* Merging
	* Reload the original, full dataset
	use "world.dta", clear
	* Merge it with our collapsed dataset
	* Merge can be 1:1, 1:m, or m:1
		* One to one
		* One to many
		* Many to one
		* "Many to many" is possible but almost always wrong
	merge m:1 regionun using "world_collapsed.dta"
	* Stata gives us a report on our merge, and also generates a new variable called _merge
	tab _merge

* A detour into loops

	* We know what the issue is universally, so we could solve for it with a "loop"
		* Stata loops with "foreach" language:
			* foreach "your_name_here" of "list" {
			*	do something to each `your_name_here'
			* }
		* I'm including the command "capture" so Stata powers through errors without stopping the loop
		* _all is a way to refer to every variable in the dataset
		foreach var of varlist _all {
			capture replace `var' = "" if `var' == "NA"
		}
		foreach var of varlist _all {
			capture destring, replace
		}
	* Loops are powerful, flexible, and commonly used in Stata
	* Can even loop over filenames to perform the same operation on multiple data files
	* The apply example from R yesterday:
		foreach var of varlist spendeduc-spendmil {
			replace `var' = `var'/100
		}
	* Generate variables instead of replacing
	* Note we use our looped value (variable name) in creating the new variable names
		foreach var of varlist spendeduc-spendmil {
			gen `var'_decimal = `var'/100
		}

* Reshaping in Stata

	* Let's narrow the dataset down first
	* Lists of variables can be removed with "drop"
	drop _merge
	* Or we can use "keep" to only keep the variables we want
	keep country dem_level4 women05 women09 women13
	* Can also use "keep" and "drop" to subset by observations
	drop if dem_level4 == "Authoritarian"
	
	* Reshape command (I find referring to the help file useful)
	help reshape
	reshape long women, i(country) j(year) string
		* We used the "string" option because of pesky zeroes in our year variable
		* Can clean it up if we want to
		destring year, replace
		replace year = year + 2000
	* Stata has good ways to look at duplicate values
		duplicates report country
		duplicates report year
	*Put it back to wide
	reshape wide women, i(country) j(year)
