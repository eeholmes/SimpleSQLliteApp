# SimpleSQLliteApp

This is a super simple app that shows how to link a SQLlite database to a shiny app.  SQLlite is installed on shinyapps.io
so if you use that to deliver apps, then you are set.  Why use a database?  Because whatever you have is really huge and you do
want to load that into your R session.  In my simple tests, querying a SQLlite database was not slower than having the whole dataset
in memory.

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
``
Search online for tutorials on SQLlite query syntax.  The basics are pretty easy.  The complicated is quite complicated but
simple is dead easy.  Be careful about quotes in your csv file.  `write.csv()` will put quotes around your text by default and
that will make it a real pain to write queries since you have to add `\"` everywhere.  So use `quote=FALSE` to stop that.

Note there are a few different packages you can use to interact with your database.  I used `sqldf` and its functions because
it was the easy.  Some people have had trouble with `dbWriteTable()` function.  `sqldf` has another one you can use (google it). 
But I had trouble with that and `dbWriteTable()` worked fine.
