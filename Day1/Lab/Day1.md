# Day 1

Today, we will get ready for the workshop by installing R/Python environments, getting familiar with the tools we will be using, and most importantly, setting up ChatGPT and other GenAI tools so that you can debug your code effectively.

The model code scripts are stored in the `Day1/Lab/Model_Code` folder. However, I do not recommend you to use it. Instead, follow the steps below and create your own files. The model code scripts are just there when you encounter serious problems.

## R - Basic Setup

Dr. Josephine Lukito has a great installation guide for R and RStudio. Please follow her instructions to set up your environment: https://jolukito.quarto.pub/j381m-textbook/01-installation.html

1. Install R from [CRAN](https://cran.r-project.org/)
2. Install RStudio from [RStudio](https://posit.co/download/rstudio-desktop/)
3. Creating a new .R file in RStudio:
   - Open RStudio
   - Click on "File" in the top left corner
   - Select "New File" and then "R Script"
   - A new tab will open with a blank script file
4. Write this the following script, and hit "Ctrl + Enter" or clicking the "Run" button in RStudio.
   ```r
   install.packages("praise")
   ```
5. Load the package in RStudio:
   ```r
   library("praise")
   ```
6. Run the following code in RStudio and get a random praise message:
   ```r
   praise()
   ```
7. Save the file as `praise.R` in your `Day1` folder.
8. Open `praise.R` again, make sure .R is associated with RStudio from now on. Run the code again to get a new random praise message.

## R - Basic Commands 1

1. Open RStudio and create a new R script file.
2. Write the following code in the script:
   ```r
   # This is a comment
   x <- 5
   y <- 10
   z <- x + y
   print(z)
   ```
3. Save the file as `basic_commands_1.R` in your `Day1` folder.
4. Run the code by selecting it and pressing "Ctrl + Enter" or clicking the "Run" button in RStudio.
5. You should see the output `15` in the console.

## R - Basic Commands 2

1. Open RStudio and create a new R script file.
2. First, we will install the `datasets` package:
   ```r
   install.packages("datasets")
   # Most of the time, you do not need to install it, because it is already installed in RStudio
   ```
3. Load the package:
   ```r
   library(datasets)
   ```
4. Load the `mtcars` dataset:
   ```r
   data(mtcars)
   ```
5.  View the first few rows of the dataset [Remember, while you can type it in the console to run it, I recommend you to always to type this in the script file, so that you can save it again later]:
   ```r
   head(mtcars)
   head(mtcars, n = 10)
   tail(mtcars)
   new_object <- mtcars
   summary(new_object)
   ```
6.  Interpret what each of the line means
7.  We also need to know what class the object is. You can do that by:
   ```r
   class(mtcars)
   class(mtcars$mpg)
   ```
   - The `mtcars` dataset is a data frame, which is a table-like structure in R.
   - While the `mpg` column is numeric, which means it contains numbers.
   - You can also check the structure of the dataset using:
   ```r
   str(mtcars)
   ```
   - This will give you information about the columns, their types, and the first few values in each column.
8. This is important because we need to know what kind of data we are dealing with. For example, if you want to do a regression analysis, you need to know if the variables are numeric or categorical. Sometimes, the class of the variable is not what you expect. For example, if you have a number variable, but it could be wrongfully stored as a character string:
   ```r
   number_variable <- "10"
   class(number_variable)
   ```
9. Instead, you should use "as." commands to change it to the class that you need:
   ```r
   number_variable <- as.numeric(number_variable)
   class(number_variable)
   number_variable <- as.character(number_variable)
   class(number_variable)
   ```
10. Further, you can type out these commands to visually learn the differences:
   ```r
   # Create a character variable
   4
   ```
  It will show up as:
  [1] 4
   ```r
   as.character(4)
   ```
  It will show up as:
  [1] "4"
   ```r
   as.numeric("four")
   ```
  It will show up as NA and gives a warning message: Warning: NAs introduced by coercion
11. Save the file as `basic_commands_2.R` in your `Day1` folder.
12. For more information on data structures in R, see Jo's tutorial: https://jolukito.quarto.pub/j381m-textbook/05-structures.html

## R - Common Commands

1. Open RStudio and create a new R script file.
2. These few commands are widely used in R for logistic reasons:
   ```r
   # Create a vector
   my_vector <- c(1, 2, 3, 4, 5)
   # Create a matrix (only numbers)
   my_matrix <- matrix(1:9, nrow = 3)
   # Create a data frame (basically a table)
   my_data_frame <- data.frame(Name = c("Alice", "Bob"), Age = c(25, 30))
   View(my_data_frame)
   # Clean working environment
   rm(list = ls())
   # Get working directory
   getwd()
   # It might show up a path like on PC like "C:/Users/YourName/Documents" or on Mac like "~/Documents"
   # Set working directory
   setwd("path/to/your/directory")
   # You can set it to your own path, like "C:/Users/YourName/Documents/Day1" or on your desktop
   # Reading in a CSV file
   my_data <- read.csv("C:/Users/YourName/Documents/Day1/Day1.csv")
   # But if you have already set the working directory, you can just do:
   my_data <- read.csv("Day1.csv")
   # You can have a look at the data
   head(my_data)
   head(my_data, n = 1)
   # You can print out the column names of the data
   colnames(my_data) # or simply names(my_data)
   # Or you can use the View function to open it in a new tab
   View(my_data)
   # You can look at one specific variable as well
   head(my_data$favorites)
   # Look at the mean of a variable
   mean(my_data$favorites)
   # Look at the median of a variable
   median(my_data$favorites)
   # Look at the standard deviation of a variable
   sd(my_data$favorites)
   # Look at the variance of a variable
   var(my_data$favorites)
   # Look at the maximum of a variable
   max(my_data$favorites)
   # Look at the minimum of a variable
   min(my_data$favorites)
   # Look at the correlation of two variables
   cor(my_data$favorites, my_data$retweets)
   cor.test(my_data$favorites, my_data$retweets)
   # Plot it
   plot(my_data$favorites, my_data$retweets)
   # You can run a regression with it too
   lm_model <- lm(my_data$retweets ~ my_data$favorites)
   # Or you can use the formula directly
   lm_model <- lm(retweets ~ favorites, data = my_data)
   summary(lm_model)
   # You can use table() to look at the frequency of a variable
   table(my_data$Party)
   table(my_data$chamber)
   table(my_data$author)
   ```
3. Some very common keyboard shortcuts in RStudio:
   - Ctrl + Enter: Run the current line or selection
   - Ctrl + Shift + C: Comment or uncomment the current line or selection
   - Ctrl + Shift + M: Insert the pipe operator (%>%) (which we might talk about later)
4. One common keyboard shortcut for Mac users to grab file's path is:
   - Command + Option + C: Copy the file path of the selected file
   - I am not sure if this works on Windows, but you can research it too :)

## Python - Basic Setup

We’ll use the Anaconda distribution of Python. It includes Python, JupyterLab, and many essential libraries for data science and computational social science.

1. Download and install Anaconda: https://www.anaconda.com/products/distribution
2. Launch Anaconda Navigator and open JupyterLab
3. It will open a tab in your browser like: http://localhost:8888/lab
4. In JupyterLab, click the “+” button or go to File > New > Notebook > Python 3 (ipykernel). You’ll see a blank notebook with a cell that you can type code into
5. In the first cell, type:
   ```python
   print("Hello, world!")
   ```
6. Run the cell by clicking the “Run” button or pressing Shift + Enter
7. Since you are using JupyterLab, you can also use Markdown (a text-based formatting syntax) to write notes. To do this, **create a new cell** and change the cell type from Code to Markdown from the dropdown menu. Type:
   ```markdown
   # This is a header
   ## This is a subheader
   ```
8. Run the cell to see the formatted text
9. Since Python doesn't have an equivalent of R's `praise` package, we will use the `random` package to generate a random praise. Type:
   ```python
   import random
   compliments = [
    "You're doing amazing!",
    "That was a great cell!",
    "Nice job!",
    "Python suits you.",
    "You're not just coding, you're crafting!"
    ]
    print(random.choice(compliments))
   ```
10. Run the cell by clicking the “Run” button or pressing Shift + Enter

## Python - Basic Commands 1

1. Open Anaconda, JupyterLab, create a new notebook, and name it basic_commands_1.ipynb
2. In the first cell, type:
   ```python
   # This is a comment
   x = 5
   y = 10
   z = x + y
   print(z)
   ```
3. Run the cell by clicking the “Run” button or pressing Shift + Enter. You should see the output: `15`

## Python - Basic Commands 2

1. Open Anaconda, JupyterLab, create a new notebook, and name it basic_commands_2.ipynb
2. In the first cell, import pandas and numpy (panda is the most widely used package for data analysis in Python, and numpy is the most widely used package for numerical analysis):
   ```python
   import pandas as pd
   import numpy as np
   ```
3. In the second cell, create a DataFrame using a built-in dataset:
   ```python
   from sklearn.datasets import load_iris
   iris = load_iris(as_frame=True)
   df = iris.frame
   ```
4. In the third cell, explore the dataset:
   ```python
   df
   ```
5. In the fourth cell, view the first few rows of the dataset:
   ```python
   df.head()
   ```
6. In the fifth cell, view the last few rows of the dataset:
   ```python
   df.tail()
   ```
7. In the sixth cell, view the summary of the dataset:
   ```python
   df.describe()
   ```
8. In the seventh cell, view the structure of the dataset:
   ```python
   df.info()
   ```
9. In the eighth cell, view the column names of the dataset:
   ```python
   df.columns
   ```
10. At this point, you should see that in Python, the first row is indexed as 0, and the last row is indexed as 149. So, to get the first row, you can do:
    ```python
    df.iloc[0]
    ```
11. To get the last row, you can do:
    ```python
    df.iloc[-1]
    ```
12. To get the first 10 rows, you can do:
    ```python
    df.iloc[:10]
    ```
13. To get the first column, you can do:
    ```python
    df.iloc[:, 0]
    ```
14. To get the last column, you can do:
    ```python
    df.iloc[:, -1]
    ```
15. Or, if you know the name of the column, you can do:
    ```python
    df['sepal length (cm)']
    ```

## Python - Common Commands

1. Open Anaconda, JupyterLab, create a new notebook, and name it common_commands.ipynb
2. In the first cell, import pandas and numpy:
   ```python
   import pandas as pd
   import numpy as np
   ```
3. In the second cell, get/change working directory:
   ```python
   # Check current working directory
   import os
   os.getcwd()
   # Change working directory (optional)
   # os.chdir("/your/path/here")
   ```
4. In the third cell, create a list:
   ```python
   # Create a list
   my_list = [1, 2, 3, 4, 5]
   print(my_list)
   ```
5. In the fourth cell, create a dictionary:
   ```python
   # Create a dictionary and convert to a DataFrame
   my_data_frame = pd.DataFrame({
   "Name": ["Alice", "Bob"],
   "Age": [25, 30]
   })
   print(my_data_frame)
   ```
6. In the fifth cell, read in a CSV file:
   ```python
   data = pd.read_csv("Day1.csv")
   # View data
   data
   ```
7. In the sixth cell, view the first few rows of the data:
   ```python
   data.head()
   ```
8. In the seventh cell, view the last few rows of the data:
   ```python
   data.tail()
   ```
9. In the eighth cell, view the column names of the data:
   ```python
   data.columns
   ```
10. In the ninth cell, view the summary of the data:
   ```python
   data.describe()
   ```
11. In the tenth cell, view the first column of the data:
    ```python
    data.iloc[:, 0]
    ```
12. In the eleventh cell, view the first row of the data:
    ```python
    data.iloc[0]
    ```
13. In the twelfth cell, view the last column of the data:
    ```python
    data.iloc[:, -1]
    ```
14. In the thirteenth cell, view the first 10 rows of the data:
    ```python
    data.iloc[:10]
    ```
15. In the fourteenth cell, once you know which column to look into, you can describe the data:
    ```python
    data['favorites'].describe()
    ```
16. In the fifteenth cell, you can try different functions:
    ```python
    data["favorites"].mean()
    data["favorites"].median()
    data["favorites"].std()
    data["favorites"].var()
    data["favorites"].max()
    data["favorites"].min()
    ```
17. In the sixteenth cell, you can also look at the correlation of two variables:
    ```python
    data[['favorites', 'retweets']].corr()
    # The two brackets "[[" indicate which columns to draw
    ```
18. You can also use a more logical approach:
    ```python
    # you pick out favorites first, and then calculate the correlation with retweets
    data["favorites"].corr(data["retweets"])
    ```
19. In Python, we usually use matplotlib to plot the data:
    ```python
    # Plotting
    import matplotlib.pyplot as plt
    
    plt.scatter(data["favorites"], data["retweets"])
    plt.xlabel("Favorites")
    plt.ylabel("Retweets")
    plt.title("Scatterplot of Favorites vs Retweets")
    plt.show()
    ```
20. Run a linear regression with statsmodels.api:
    ```python
    import statsmodels.api as sm
    X = data["favorites"]
    y = data["retweets"]
    X = sm.add_constant(X)
    # statsmodels.OLS() does not automatically add a constant term
    model = sm.OLS(y, X).fit()
    print(model.summary())
    ```

## Learn how to debug your code with ChatGPT

1. Open ChatGPT (I have it installed on my Mac) and start a new conversation
2. Copy and paste your code into the chat
3. Describe the issue you're facing
4. Ask for help with debugging

To practice, I have two scripts with errors, stored in the current folder called `debugging_example.R` and `debugging_example.py`.

1. Copy and paste the two files and rename them to `debugged_example.R` and `debugged_example.py` in your `Day1` folder
2. Run the code in RStudio and JupyterLab
3. You should see some errors
4. Copy and paste the code into ChatGPT and ask it to debug the code
5. ChatGPT will help you identify the errors and suggest fixes
6. Apply the fixes to your code and run it again
7. You should see the output without any errors
8. Save the files as `debugged_example.R` and `debugged_example.py` in your `Day1` folder
9. You can also use ChatGPT to explain the code to you, so that you can understand it better.

## Focus on R and One More Add-On

We will focus on R for the rest of the workshop. However, if you are interested in Python, you can use it as well. The code is similar, and you can easily convert it from R to Python or vice versa (using ChatGPT).

One more add-on I highly recommend in R Studio is the GitHub Copilot. It is a paid service, but free for students. You can sign up for it here:

https://docs.github.com/en/copilot/managing-copilot/managing-copilot-as-an-individual-subscriber/getting-started-with-copilot-on-your-personal-account/getting-free-access-to-copilot-pro-as-a-student-teacher-or-maintainer

This is a great tool to help you write code faster and more efficiently. It can also help you debug your code and suggest improvements. You can use it in RStudio, JupyterLab, and other IDEs.

To enable it in RStudio, go to Tools > Global Options > Copilot and check the box to enable it. You can see a quick tutorial here: https://www.youtube.com/watch?v=YZdp6To__1g