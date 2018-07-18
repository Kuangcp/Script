rootDir='/home/rs/synthesizerd'

dateTime=`date +%m_%d-%H_%M_%S`

ssh rs@192.168.10.201 "sh $rootDir/bin/stop.sh && mv $rootDir/synthesizer.jar $rootDir/backup/synthesizer.jar_$dateTime && mv $rootDir/upload/synthesizer.jar $rootDir/synthesizer.jar && sh $rootDir/bin/start.sh" 
