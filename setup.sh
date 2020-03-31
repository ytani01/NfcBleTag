#!/bin/sh
#
# (c) 2020 Yoichi Tanibayashi
#

BINFILES="center/activate-do.sh center/MyLogger.py"
BINFILES="${BINFILES} center/TagPublisher.py center/BlePeripheral.py"
BINFILES="${BINFILES} center/get-tagid.py"

#
# functions
#
usage () {
    echo
    echo "  usage: ${MYNAME}"
    echo
}

echo_date () {
    DATESTR=`date +'%Y/%m/%d(%a) %H:%M:%S'`
    echo "* ${DATESTR}> $*"
}

echo_do () {
    echo_date $*
    eval $*
}

#
# main
#
MYNAME=`basename $0`
echo_date "MYNAME=${MYNAME}"

MYDIR=`dirname $0`
echo_date "MYDIR=${MYDIR}"

cd $MYDIR
BASEDIR=`pwd`
echo_date "BASEDIR=$BASEDIR"

if [ ! -z $1 ]; then
    usage
    exit 1
fi

VENVDIR=`dirname $BASEDIR`
echo_date "VENVDIR=$VENVDIR"

BINDIR="${VENVDIR}/bin"
echo_date "BINDIR=$BINDIR"

#
# check venv and activate it
#
if [ -z ${VIRTUAL_ENV} ]; then
    ACTIVATE="../bin/activate"
    if [ ! -f ${ACTIVATE} ]; then
        echo_date "${ACTIVATE}: no such file"
        exit 1
    fi
    . ../bin/activate
fi
if [ ${VIRTUAL_ENV} != ${VENVDIR} ]; then
    echo_date "VIRTUAL_ENV=${VIRTUAL_ENV} != ${VENVDIR}"
    exit 1
fi

#
# download other repositoris
#
echo_do cd ${VENVDIR}
for g in BleBeacon NFC Templates; do
    if [ ! -d $g ]; then
        echo_do git clone git@github.com:ytani01/${g}.git
    fi
done

#
# update pip
#
echo_do python3 -m pip install -U pip
hash -r
pip -V

#
# install Python packages
#
echo_do cd ${BASEDIR}
echo_do pip install -r requirements.txt

#
# setcap
#
echo_do sudo setcap 'cap_net_raw,cap_net_admin+eip' $(readlink -f $(which python3))
echo_do sudo setcap 'cap_net_raw,cap_net_admin+eip' ${VENVDIR}/lib/python3.7/site-packages/bluepy/bluepy-helper

#
# make symbolick links
#
for f in ${BINFILES}; do
    echo_do ln -sf ${BASEDIR}/${f} ${BINDIR}
done

echo_do ln -sf ${VENVDIR}/lib/python3.*/site-packages/bluepy/bluepy-helper ${BINDIR}


echo_date "done."
