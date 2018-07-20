rootDir='/home/rs/synthesizerd'

dateTime=`date +%m_%d-%H_%M_%S`

# ./bin/stop.sh && mv synthesizer.jar backup/synthesizer.jar`date +%m_%d-%H_%M_%S` && mv upload/synthesizer.jar . && ./bin/start.sh
# ssh rs@192.168.10.201 "cd "$rootDir" && sh bin/stop.sh && mv synthesizer.jar backup/synthesizer.jar_$dateTime && mv upload/synthesizer.jar . && sh bin/start.sh" 
ssh rs@192.168.10.201 "cd "$rootDir" && ls"
