# Welcome to R! In this first line, I am using the hashtag/pound sign (#) to make this a comment.
# Lines that begin with # will not run as code.

# Let's start simple: using R as a calculator
# Try highlighting line 6 below and pressing Cmd+Return (or Ctrl+Return)
  1+1
  # The result shows up in the Console as a single-element vector
  # The "[1]" is R indicating the position of our value in that vector
  
# All basic mathematical operations can be done directly in R
  2-1
  5*2
  9/3
  4^2
  sqrt(25)
  25^(1/2)
  factorial(5)
  
# Object assignment
  # Let's try assigning the Value 1 to an Object using an Assignment Operator
  # We can name the Object whatever we want; I'll call it my_scalar
  my_scalar <- 1
  # Once this is created, it shows up in the Environment panel
  # We can retrieve this Object whenever we want simply by running its name
  my_scalar
  # We can also do math on the Object
  my_scalar + 3
  # And store the results as a new Object
  new_scalar <- my_scalar + 3
  # We can reveal the Class and Type of our Object
  typeof(new_scalar)
  class(new_scalar)
  # We can also store text to Objects
  name <- "Henry"
  name
  class(name)
  
# Vectors 
  # Vectors need more than one value
  # We can use the Command c() — "combine" — to do this
  # We are running the Command c() on the values 1, 2, and 3, and Assigning the result to an Object named "numbers"
  numbers <- c(1, 2, 3)
  numbers
  # length() tells us how many elements are in a Vector
  length(numbers)
  # Now, math works on the vector as it would with a single-row matrix
  numbers * 3
  numbers * numbers
  numbers + 5
  # Adding two vectors together
  numbers2 <- c(4, 5, 6)
  vector + numbers2
  # Adding two vectors of different lengths?
  numbers3 <- c(7, 8, 9, 10)
  numbers + numbers3
  #We can also create a vector with sequencing
  numbers4 <- 1:100
  # Indexing a vector (one-dimensional)
  numbers2[2]
  
# Matrices
  # Making a matrix by combining vectors
  # c() just combines vectors in one dimension, we need to try something else for a matrix!
  cbind(numbers, numbers2)
  rbind(numbers, numbers2)  
  # From scratch
    #Notice here: you can place returns in your code for neatness and will still run together!
  neo <- matrix(c(3,2,5,1,2,3,0,4,5),
         nrow = 3, ncol = 3, byrow = TRUE)
  neo
  # dim() tells us the dimensions of our matrix
  dim(neo)
  # Indexing a matrix (two-dimensional)
    # What do you think these commands will return?
    neo[2,2]
    neo[ ,2]
    neo[2, ]
  # Matrix manipulations in R
    neo*3
    neo+2
    neo+neo
  t(neo) #Transpose
  det(neo) #Determinant
  solve(neo) #Inverse
  diag(neo) #Extract diagonal elements
  eigen(neo) #Compute eigenvalues and eigenvectors
  
#Exercise Break: create the following matrix — assign it to a name of your choice and produce its determinant
    #  1  2  1
    #  0  4  3
    # -6 -2  2
  
# Data Frames
  # Data frames are analogous to sheets in Excel
  # Any matrix can be a dataframe
  # df is a very common, generic name for a dataframe. But again, name it whatever you like!
  df <- as.data.frame(neo)
  # Can code View() — capitalization matters — or click on the item in the environment
  View(df)
  # We can have dataframes be a mixture of data types
    # Let's make a vector of text
      names <- c("Henry", "Theo", "Marko")
    # And combine it into our dataframe, being sure to assign it to something
      df2 <- cbind(df,names)
  # In dataframes, we might want to name the columns
    # The way to read this is assigning a value to the vector "colnames"
      # Rename one column referring to its column number
        colnames(df2)[1] <- "Variable1"
      # Rename one column referring to its current name
        colnames(df2)[colnames(df2) == "V2"] <- "Variable2"
      # Rename all columns using a vector of new names
        colnames(df2) <- c("Variable1", "Variable2", "Variable3", "names")
  # In dataframes, we can index using $ as well as [,]
    df1[1,3]
    df1[1, ]
    df1[ ,3]
    df1$Variable3
    # 'dataframe$variable' will be the primary way you refer to variables (columns) in R
  # Can use functions on dataframe columns
    mean(df2$Variable3)
  # Can transform columns by running a command on them and reassigning to a new column (or itself)
    df2$Variable3 <- df2$Variable3*10
    View(df2)
    
    
# If you ever want more info about a command, type it into the search bar in the Help panel,
# or type it into Console or Script with a ? before the command
  ?mean
  
# Some useful tricks for R Scripts
  # Click on the line number in the Script to highlight the entire line
  # Control+a (or Command+a) selects all
  # Hold alt while highlighting to select, and then edit, "columns" of code
  # Control+f (or Command + f) allows you to search, and also find/replace
  # Change indent of blocks of code by highlighting and pressing either tab (indent) or Shift+tab (outdent)
 
# Exercises:
  # Create two vectors containing the following sets of numbers:
  # Be sure to assign the vectors to names of your choice
    # Vector 1:  4  8 15
    # Vector 2: 16 23 42
  # Combine the two vectors into a matrix, with the vectors serving as columns
  # What is the value in the second column and third row?
  # What is the mean of the first column?