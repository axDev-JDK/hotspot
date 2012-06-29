#!/bin/sh

##
## @test Test6929067.sh
## @bug 6929067
## @summary Stack guard pages should be removed when thread is detached
## @run shell Test6929067.sh
##

if [ "${TESTSRC}" = "" ]
then TESTSRC=.
fi

if [ "${TESTJAVA}" = "" ]
then
  PARENT=`dirname \`which java\``
  TESTJAVA=`dirname ${PARENT}`
  echo "TESTJAVA not set, selecting " ${TESTJAVA}
  echo "If this is incorrect, try setting the variable manually."
fi

BIT_FLAG=""

# set platform-dependent variables
OS=`uname -s`
case "$OS" in
  Linux)
    NULL=/dev/null
    PS=":"
    FS="/"
    ;;
  SunOS | Windows_* | *BSD)
    NULL=NUL
    PS=";"
    FS="\\"
    echo "Test passed; only valid for Linux"
    exit 0;
    ;;
  * )
    echo "Unrecognized system!"
    exit 1;
    ;;
esac

COMP_FLAG="-m32"

# Test if JDK is 32 or 64 bits
${TESTJAVA}/bin/java -d64 -version 2> /dev/null

if [ $? -eq 0 ]
then
    COMP_FLAG="-m64"
fi

# Get ARCH specifics
ARCH=`uname -m`
case "$ARCH" in
  x86_64)
    ARCH=amd64
    ;;
  i586)
    ARCH=i386
    ;;
  i686)
    ARCH=i386
esac

LD_LIBRARY_PATH=.:${TESTJAVA}/jre/lib/${ARCH}/client:${TESTJAVA}/jre/lib/${ARCH}/server:/usr/openwin/lib:/usr/dt/lib:/usr/lib:$LD_LIBRARY_PATH

export LD_LIBRARY_PATH

THIS_DIR=`pwd`

cp ${TESTSRC}${FS}invoke.c ${THIS_DIR}
cp ${TESTSRC}${FS}T.java ${THIS_DIR}


${TESTJAVA}${FS}bin${FS}java ${BIT_FLAG} -fullversion

${TESTJAVA}${FS}bin${FS}javac T.java

echo "Architecture: ${ARCH}"
echo "Compilation flag: ${COMP_FLAG}"

gcc ${COMP_FLAG} -o invoke \
-L${TESTJAVA}/jre/lib/${ARCH}/client \
-L${TESTJAVA}/jre/lib/${ARCH}/server \
-ljvm -lpthread -I${TESTJAVA}/include -I${TESTJAVA}/include/linux invoke.c

./invoke
exit $?
