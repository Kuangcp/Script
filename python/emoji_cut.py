file = open('emojis.md')
#for line in file.readlines():
#    print(line)
lines = file.readlines()    
index = open('INDEX.md','w+')
count = 0
temp = "- "
for line in lines:
    count = count+1
    if line.startswith("#"):
        index.write(line)
        continue
    temp = temp+line.strip()+"    `"+line.strip()+"`"
    if count %5==0:
        index.write(temp+"\n")
        temp = "- "
