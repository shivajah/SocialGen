if [ -z $SOCIAL_GEN_HOME ]
then 
  echo "SOCIAL_GEN_HOME is not defined"
  exit 1
fi 
if [ -z $SOCIAL_GEN_LOCAL_HOME ]
then 
  echo "SOCIAL_GEN_LOCAL_HOME is not defined"
  exit 1
fi 

mkdir -p $SOCIAL_GEN_HOME/output

for i in `cat $SOCIAL_GEN_HOME/conf/machines`
do
    echo 1
    ssh $i mkdir -p $SOCIAL_GEN_LOCAL_HOME
    echo 2
    ssh $i mkdir -p $SOCIAL_GEN_LOCAL_HOME/target
    echo 3
    ssh $i mkdir -p $SOCIAL_GEN_LOCAL_HOME/output	
    echo 4
    scp -q $SOCIAL_GEN_HOME/target/SocialGen.jar $i:$SOCIAL_GEN_LOCAL_HOME/target
    echo 5
    scp -q -r $SOCIAL_GEN_HOME/conf $SOCIAL_GEN_HOME/metadata $SOCIAL_GEN_HOME/scripts $i:$SOCIAL_GEN_LOCAL_HOME &
    echo 6
done
