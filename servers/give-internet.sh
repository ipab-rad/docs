#!/bin/bash

usage()
{
  echo "Usage:"
  echo "  ./give-internet.sh user hostname"
  echo "Note:"
  echo "  \`./give-internet.sh youbot starscream\` is the same as"
  echo "  writing \`./give-internet.sh youbot starscream.inf.ed.ac.uk\`"
}

###############################################

if [[ $# -lt 2 ]] ; then
  echo "ERROR: not enough arguments passed"  
  usage
  exit 1;
fi

if [[ $2 == *.inf.ed.ac.uk ]] ; then
  ssh -R 3128:127.0.0.1:3128 $1@$2
else
  ssh -R 3128:127.0.0.1:3128 $1@$2.inf.ed.ac.uk 
fi
