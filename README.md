# SimpleSQLliteApp

This is a super simple app that shows how to link a SQLlite database to a shiny app.  SQLlite is installed on shinyapps.io
so if you use that to deliver apps, then you are set.  

## How to run the app

Install the sqldf package.  That'll install SQLlite.  You do not have to install anything else for the database part.  Install the shiny package.  The app uses also uses ggplot2 and stargazer packages, so install those too.

Save the 2 files somewhere and set your working directory to whatever directory those files are in.  Open up `app.R` in RStudio.  You should see a **Run App** link at the top of the file.  Click that and it should run.  

## Sharing a shiny app with other people

You can use RStudio's https://www.shinyapps.io/ service for free.  Make an account.  Then click on Dashboard and it'll walk you through how to connect your account to RStudio.

## Why use a database?

Because your dataset  is really huge and you do
want to load that into your R session.  In my simple tests, querying a SQLlite database was not slower than having the whole dataset
in memory.  Another reason would be if you want to have your database somewhere other than local.  Maybe you want to host your 
database on Amazon (say) and be able to query it from many different apps or from a browser.  If you need to query your database often in your app, that hosting remotely might add a lot of overhead.

How to set up a SQLlite database?  Super easy. Make sure you do this in the same directory as you shiny app (or if not just add 
the right path to whereever you store the database file).

## Create database from csv file
```
library(sqldf)
db <- dbConnect(SQLite(), dbname="database.db")
write.csv(mtcars, file="mtcars.csv", quote=FALSE)
dbWriteTable(conn=db, name="data", value="mtcars.csv", row.names=FALSE, header=TRUE,overwrite=TRUE)
dbDisconnect(db)
```
Obviously do not use `overwrite=TRUE` if you want to add data to an existing database.  `name` is the name of the table in your 
database.  You can many different tables in one database.  In fact, that is normally how databases are used (information is spread
across multiple tables).  In R, that would not be good and you'd use some package to put everything together in one huge data.frame
with all the info duplicated as needed.

## Create database from data.frame
```
library(sqldf)
db <- dbConnect(SQLite(), dbname="database.db")
write.csv(mtcars, file="mtcars.csv")
dbWriteTable(conn=db, name="data", value=mtcars, row.names=TRUE, header=TRUE,overwrite=TRUE)dbDisconnect(db)
```

## Getting info out of your database

Again super easy.

```
    sqldf("select mpg from data", dbname="database.db")
```
`data` here is the name that I gave the `mtcars` table in the `database.db`.

In a shiny app, you will want to create a query string from variables.  
```
    cyl=c(4,6)
    carb=1
    query <- paste0("select mpg, wt from data ",
                    "where cyl in ( ",  paste(cyl, collapse=", ")," )",
                    " and carb=",carb)
    sqldf(query, dbname="database.db")
```
Search online for tutorials on SQLlite query syntax.  The basics are pretty easy.  The complicated is quite complicated but
simple is dead easy.  Be careful about quotes in your csv file.  `write.csv()` will put quotes around your text by default and
that will make it a real pain to write queries since you have to add `\"` everywhere.  So use `quote=FALSE` to stop that.

Note there are a few different packages you can use to interact with your database.  I used `sqldf` and its functions because
it was the easy.  Some people have had trouble with `dbWriteTable()` function.  `sqldf` has another one you can use (google it). 
But I had trouble with that and `dbWriteTable()` worked fine.

## References

The following are online tutorials that I used to get started.  
There are 3 different methods for getting a csv file into a SQLlite database in these links.  I chose the one I did since it worked seamlessly for me.


https://www.r-bloggers.com/r-and-sqlite-part-1/amp/

http://tiffanytimbers.com/querying-sqlite-databases-from-r/

http://tiffanytimbers.com/building-a-basic-database-from-csv-files-using-sqlite3/

https://www.tutorialspoint.com/sqlite/sqlite_where_clause.htm

https://shiny.rstudio.com/articles/persistent-data-storage.html#sqlite


## Reuse statement

Reuse and adapt this repo however you want. Attribution is great, like I did in references, but not required. License: CC0 1.0 Universal

