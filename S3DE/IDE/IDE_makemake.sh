#! /bin/bash 
#
# IDE_makemake.sh    
#
MANUAL="\
USAGE
  IDE_makemake.sh [-h] 

  -h    :   print this manual

  The script generates a working Makefile for the IDE HOME directory.
  The Makefile is able to deal with library compilation Makefile generation. 
  If present options are read from \${IDEHOME}/OPTIONS.
  Configuration parameters from file \${IDEHOME}/IDE/IDE.conf ).
"

shopt -s extglob

#
# input check
if [ "$1" = "-h" ] ; then echo "$MANUAL" ; exit 0 ; fi

#
# This check has been removed for portability issues (AIX bash)
#
#if [ "$#" != "0" ] ; then 
#    echo " Invalid number of arguments, type makemake.sh -h for help" 
#    exit 1
#fi


#
# load DEFAULTS
if [ ! -e ./IDE/IDE.conf ] ; then 
   echo "ERROR: Unable to find ./IDE/IDE.conf" ; exit 1
fi
. ./IDE/IDE.conf

#
# tmp dir
tmpdir=$STDDIR_TMP
if [ -e $TMPDIR ] ; then rm -rf $tmpdir ; fi
mkdir $tmpdir
makefile=$tmpdir/Makefile

#
# set trap for clean exit in case of stopping
trap "test -d $tmpdir && rm -rf $tmpdir" EXIT
trap "test -d $tmpdir && rm -rf $tmpdir" 2

#
# version and README
if [[ ! -r IDE/README ]] ; then
    echo " File IDE/README is not present"
    exit 1
fi
if [ -e README -a ! -L README ] ; then
    echo " File README exists but not a symbolic link"
    exit 1
fi
ln -sf IDE/README .
IDE/makeversion.sh IDE




header="\
#
# DO NOT EDIT THIS FILE MANUALLY
# This makefile was automatically generate for IDE home directory
#"
echo "$header" > $makefile
#
# ADD eventually the following line in the header
# Today is $(date)



#
# option file
options=
if test -r OPTIONS ; then
  options="$options$(cat OPTIONS)
"
  echo "# Global OPTIONS file has been used in generation" >> $makefile
else
  echo "# Global OPTIONS file has NOT been found" >> $makefile
fi


#
# order the found packages
IDE_LIBS="$(IDE/packls.sh)"
IDE_LIBS="$(echo USE $IDE_LIBS | IDE/used -s -i)"


#
# main target
echo                                   >> $makefile
echo "# Main target"                   >> $makefile
txt="\
info:
	@echo  
	@echo  \"  S3 IDE (Integrated Development Environment)\"
	@echo     
	@echo  \"  type:  make <target>\"
	@echo  \"  Possible <target>'s are: \"
	@echo  \"    make                 make IDE global Makefile\" 
	@echo  \"    allmake              make IDE Makefiles in each dir \"
	@echo  \"    clean                IDE total cleanup  \"
	@echo  \"    add                  launch a script to add a new pakage \"
	@echo  \"    <dir>_all            make all executable in <dir>   \" 
	@echo  \"    <dir>_loclib         make the local library in <dir>   \" 
	@echo  \"    <dir>_make           make the Makefile for <dir>   \" 
	@echo  \"    <dir>_allmake        make all the Makefiles for <dir> and its libs  \"
	@echo  \"    <dir>_clean          cleanup in <dir>  \"
	@echo  \"    <dir>_tar            tar of a single dir  \"
	@echo  \"    <dir>_alltar         tar of a dir with its libs \"
	@echo    
	@echo  \"  Possible <dir> values are: \"     "
echo "$txt"                            >> $makefile
for lib in $IDE_LIBS
do
   echo "	@echo  \"    $lib  \" ">> $makefile  
done
echo "	@echo   "                      >> $makefile  


#
# loop over libs
echo                                   >> $makefile
echo                                   >> $makefile
echo "# targets for libs handling"     >> $makefile
for lib in $IDE_LIBS
do
    echo                               >> $makefile
    echo "${lib}_all: "                >> $makefile
    echo "	cd $lib ; make all "   >> $makefile
    echo "${lib}_loclib: "             >> $makefile
    echo "	cd $lib ; make loclib ">> $makefile
    echo "${lib}_make: "               >> $makefile
    echo "	IDE/makemake.sh $lib " >> $makefile
    echo "${lib}_allmake: ${lib}_make "     >> $makefile
    echo "	cd $lib ; make allmake" >> $makefile
    echo "${lib}_clean: "              >> $makefile
    echo "	cd $lib ; make clean " >> $makefile
    echo "${lib}_tar: "              >> $makefile
    echo "	cd $lib ; make tar " >> $makefile
    echo "${lib}_alltar: "              >> $makefile
    echo "	cd $lib ; make alltar " >> $makefile
done

echo                                   >> $makefile
echo                                   >> $makefile
echo "# make all Makefiles"            >> $makefile
echo "allmake:  make "                 >> $makefile
echo "	make -f Makefile allmake_"     >> $makefile
echo "allmake_:"                       >> $makefile
for lib in $IDE_LIBS
do
    echo "	IDE/makemake.sh $lib"  >> $makefile
done


#
# local Makefile re-generation
echo                                   >> $makefile
echo "# target for making Makefile"    >> $makefile
echo "make: "                          >> $makefile
echo "	IDE/IDE_makemake.sh "          >> $makefile

echo                                   >> $makefile
echo "# target to launch add_dir"      >> $makefile
echo "add: "                           >> $makefile
echo "	IDE/add_dir"                   >> $makefile

#
# clean all
echo                                   >> $makefile
echo "# clean all"                     >> $makefile
echo "clean:  "                        >> $makefile
for lib in $IDE_LIBS
do
    echo "	cd $lib ; make clean_" >> $makefile
done

    

#
# Moving generated Makefile in the main dir
# 
cp $makefile .

exit 0

