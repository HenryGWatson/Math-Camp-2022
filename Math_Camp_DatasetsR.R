# Welcome back to R!

# Setting a Working Directory

  setwd()

# Loading in a dataset

  world <- read.csv("poliscidata_world.csv")
  
# Let's explore our dataset
  
  View(world) # Capitalization matters on View()!
  names(world) # List of variable names
  head(world) # first 6 observations for every variable
  dim(world) # Dimensions: observations by variables
  nrow(world) # Number of rows
  ncol(world) # Number of columns
  summary(world) # Summary statistics on every variable
  
# Dataframes can be indexed using $
  head(world$country)
# But they can also still be indexed using brackets [row, column]
  head(world[,1])
  world[1,1]
# You can also combine these two methods
  world$pop_total[1]
  # Note: a variable is one-dimensional, so we only input one value in brackets as opposed to a row, column

# Summarizing data and basic analysis
  
  # Summarizing one categorical/factor variable
    # Remember, we can index dataframes using $
    summary(world$regionun)
  
  # Two categorical variables: tabulate using table()
  
    table(world$regionun, world$democ_regime)
    # Tables can be stored as objects
    table1 <- table(world$regionun, world$democ_regime)
    # Prop.table() is a useful command to obtain percentages
      # Row percentages: What share of each region's countries are democracies?
        prop.table(table1, 1)
      # Column percentages: What share of non-democracies/democracies are in each region?
        prop.table(table1, 2)
        
  # Summarizing continuous variables
    summary(world$democ11)
    # We can also get these values directly using commands
      mean(world$democ11)
      # Why an error for mean?
      # Missing data
      mean(world$democ11, na.rm = TRUE)
      
# Exercises:
  # What is the mean of the variable lifeex_m?
  # What proportion of Asian countries have Buddhist as the largest religion by proportion?
      # (The variables you need for this are regionun (region) and religoin (largest religion by proportion))
      
# Creating new variables
  # Create a new variable by assigning a vector (a list of values) to a new column: existing_data_frame$new_variable_name
  # Can just be all one value
      world$one <- 1
      summary(world$one)
  # But usually we want to create a new variable as transformation of an existing one
      # Let's make a True/False variable for Europe
      # Notice the double equals sign
      world$europe <- world$regionun == "Europe"
  # Just as we can add/multiply vectors, we can do the same with columns
      # This command will divide the variable "literacy" by 100 and create a new variable "literacy_decimal"
      world$literacy_decimal <- world$literacy/100
  # Getting a bit more complicated: how could we make something with more than two categories?
      # As an example, let's recode region as numbers
      # Africa = 1 ; Asia = 2 ; Australia/New Zealand/Oceania = 3 ; Europe = 4 ; Latin America/Caribbean = 5 ; USA/Canada = 6
      # With indexing:
      world$region_num[world$regionun == "Africa"] <- 1
      # Note equivalent to : world[world$regionun == "Africa", "region_num"] <- 1
      world$region_num[world$regionun == "Asia"] <- 2
      world$region_num[world$regionun == "Australia/New Zealand/Oceania"] <- 3
      world$region_num[world$regionun == "Europe"] <- 4
      world$region_num[world$regionun == "Latin America/Caribbean"] <- 5
      world$region_num[world$regionun == "USA/Canada"] <- 6
      #Always check your work
      table(world$regionun, world$region_num )
  # This method won't work to recategorize continuous variables, because we can't (feasibly) index every possible value
      # What if we wanted to make a variable which codes HDI (Human Development Index) into quartiles?
      # Try "ifelse"
      # Syntax: ifelse(test, if yes, if no)
      # Nested: ifelse(test, if yes, ifelse(test, if yes, if no))
      # Watch the syntax here:
        # <  : less than
        # <= : less than or equal to
        # >  : greater than
        # >= : greater than or equal to
        # == : equal to 
        # != : not equal to
        # &  : and
        # |  : or
        # NA : missing
        # is.na : is missing
        # !is.na : is not missing
      # Note: I'm adding line breaks and spaces to make the code neater; this doesn't affect the code!
      world$hdi_quartile <- ifelse(world$hdi <= 0.25, 1,
                                   ifelse(world$hdi <= 0.5  & world$hdi > 0.25, 2,
                                          ifelse(world$hdi <= 0.75 & world$hdi > 0.5, 3,
                                                 ifelse(world$hdi <= 1 & world$hdi > 0.75, 4, NA))))
      # Did it work?
      summary(world$hdi[world$hdi_quartile == 1])
      summary(world$hdi[world$hdi_quartile == 2])
      summary(world$hdi[world$hdi_quartile == 3])
      summary(world$hdi[world$hdi_quartile == 4])
      summary(world$hdi[is.na(world$hdi_quartile)])
    
      
# Numbers stored as text
    # A common issue is numeric data improperly stored as character data (text)
    # We can change the type of data by reassigning its class
    # Reassign the class of the variable "gini10" to "character"
    class(world$gini10)
    class(world$gini10) <- "character"
    # Now R will treat it as text
    summary(world$gini10)
    # Change it back
    class(world$gini10) <- "numeric"
      
# Exercises:
  # Make a new variable called "oil_any" which is equal to 1 if the variable "oil" is greater than 0, 0 if the variable "oil" equals 0, and NA otherwise
  # What proportion of countries produce no oil?
      
# Subsetting and Merging
    # Breaking apart dataframes, and putting them back together!
    # Can subset data using our indexing brackets (remember: [row, column])
    # number1:number2 means "all integers between and including number1 and number2"
    worldA <- world[1:83, 1:54]
    # Subset is useful if you want a specific condition, rather than a set of rows
      # subset: which rows to keep
      # subset(original_dataframe, which rows?, select = c(which columns?))
      worldB <- subset(world, hdi_quartile == 4, select = c(country, regionun, hdi, hdi_quartile))
    # Let's subset using indexing to split the dataframe in half, with half the columns in each subset
      # Leaving either row or column blank in indexing tells R you want all the rows or columns
      world_left <- world[,1:54]
      world_right <- world[,55:108]
    # We can reassemble this using cbind()
      world2 <- cbind(world_left, world_right)
      # Are they equal?
      identical(world,world2)
    # But cbind isn't very smart. If we so much as change the sort order, it'll mess up
      world_left <- world_left[order(world_left$gini10),]
      world3 <- cbind(world_left, world_right) 
      identical(world,world3)
    # Merge is the answer here
      # Merge combines the columns of two dataframes based on one or more shared columns (like Vlookup in Excel!)
      # by.x and by.y allow the matching columns in the two dataframes to have different names
      world4 <- merge(world_left, world_right, by.x = "country", by.y = "country1")
      
# Tapply
    # tapply is a very useful command which applies functions across "groups"
    # tapply(vector/variable, index (what you want the groups to be), function/command)
    # Let's apply this to get average literacy by region
      # na.rm = TRUE means "disregard missings when calculating the function"
      tapply <- tapply(world$literacy, world$region_num, mean, na.rm = TRUE)
    # We can label this output by making it a dataframe and turning the names of the rows into a variable
      literacy_region <- data.frame(region_num  = names(tapply), literacy_region = tapply)

# Now we might want to merge this new variable back in
    world5 <- merge(world, literacy_region, by = "region_num")
    
# Exercise
    # Calculate the median military spending (spendmil) for each of the levels of dem_level4 (Authoritarian, Hybrid, Partial Democracy, Full Democracy)
    # Report the results
    # Merge this result back into the world dataset as a new variable called "spendmil_demlevel"
    
# Reshape
    # Reshaping data turns rows into columns and columns into rows
    # The best way to explain is with an example
    # Let's subset world down to just a couple variables, and only democracies
    world_women <- subset(world, dem_level4 != "Authoritarian", select = c(country, dem_level4, women05, women09, women13))
    # These variables record the percent women in the lower house of the legislature for democracies
    # We can reshape this dataframe to make "year" a column variable
    world_women_reshape <- reshape(world_women,
                                   varying = c("women05", "women09", "women13"),
                                   v.names = c("dem_level4"),
                                   timevar = "year",
                                   idvar = "country",
                                   times = c(2005, 2009, 2013),
                                   direction = "long")
    # A quick sort of the new dataframe
    world_women_reshape <- world_women_reshape[order(world_women_reshape$country, world_women_reshape$year),]
    View(world_women_reshape)    

# One last R tip:
    # The swirl package is an inbuilt tutorial to R. Learn R in R!
    install.packages("swirl")
    library(swirl)