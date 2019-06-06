import requests
import json


# read gitee events api
def main():
    url = "https://gitee.com/gin9/contribution_timeline/?url\=/gin9/contribution_timeline\&scope\=my\&day" \
          "\=\&start_date\=\&end_date\=\&year\=\&per_page\=10\&page\=1 "
    request = requests.get(url)
    re_dict = json.loads(request.text)
    for i in range(len(re_dict)):
        event = re_dict[i]
        print(event['project']['path'])


if __name__ == "__main__":
    main()
