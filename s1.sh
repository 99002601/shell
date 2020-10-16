#! /usrbin/bash
while IFS=, read -r name emailID repo; do
    
[[ "$name" != "Name" ]] && echo "$name"
[[ "$emailID" != "Email ID" ]] && echo "$emailID"
if [ "$repo" != "Repo link" ]; then
    git clone "$repo"
    [[ $? == 0 ]] && printf "Clone Success," >> $RESULT_FILE
    [[ $? > 0 ]] && printf "Clone failed," >> $RESULT_FILE
    REPO_NAME=`echo "$repo" | cut -d'/' -f5`
    BUILD=`find $REPO_NAME -name Makefile -exec dirname {} \;`
    make -C "$BUILD"
    if [ "$?" == 0 ]; then
    BUILD_STATUS="Build Successful"
    else
    BUILD_STATUS="Build Failed"
    fi
    errors=`cppcheck $REPO_NAME | grep "error" | wc -l`
    echo "$errors"
    make test -C $BUILD
    VALGRI=`find "$BUILD" -name "test*.out"`
    valgrind "./$VALGRI" 2>valgri.csv 
    val=`grep "ERROR SUMMARY" valgri.csv`
    #ERR=${val:23:2}
    echo "$name ,$email ,$repo ,$GIT_STATUS ,$BUILD_STATUS ,$err ,${val:23:2}" >> Report.csv
fi
done < Input.csv
