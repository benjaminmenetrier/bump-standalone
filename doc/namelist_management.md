# Namelists management 

Namelists can be found in $MAINDIR/run. They are also stored in the SQLite database $MAINDIR/script/namelist.sqlite. This database can be browsed with appropriate softwares like [SQLiteBrowser](http://sqlitebrowser.org).

To add or update a namelist in the database:
 
    cd $MAINDIR/script
    ./namelist_nam2sql.ksh $SUFFIX

where $SUFFIX is the namelist suffix. If no $SUFFIX is specified, all namelists present in $MAINDIR/run are added or updated.

To generate a namelist from the database:
 
    cd $MAINDIR/script
    ./namelist_sql2nam.ksh $SUFFIX

where $SUFFIX is the namelist suffix. If no $SUFFIX is specified, all namelists present in the database are generated in $MAINDIR/run.

To generate the equivalent JSON file from the database:
 
    cd $MAINDIR/script
    ./namelist_sql2json.ksh $SUFFIX

