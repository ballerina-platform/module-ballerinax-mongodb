from json import dumps
from cryptography.fernet import Fernet
from httplib2 import Http
import os
import sys
import csv

code_owners = open("./.github/CODEOWNERS", "r")
owner = code_owners.read().split("*")[1].split("@")[-1].strip()

encryption_key = os.environ['ENV_USER_ENCRYPTION_KEY']

fernet = Fernet(encryption_key)
with open('github_users_encrypted.csv', 'rb') as enc_file:
    encrypted_csv = enc_file.read()

decrypted = fernet.decrypt(encrypted_csv)
with open('github_users_decrypted.csv', 'wb') as dec_file:
    dec_file.write(decrypted)

with open('github_users_decrypted.csv', 'r') as read_obj:
    user_file = csv.DictReader(read_obj)
    for row in user_file:
        if row['gh-username'] == owner:
            code_owner_id = row['wso2-id']

build_chat_id = os.environ['ENV_NOTIFICATIONS_CHAT_ID']
build_chat_key = os.environ['ENV_NOTIFICATIONS_CHAT_KEY']
build_chat_token = os.environ['ENV_NOTIFICATIONS_CHAT_TOKEN']

url = 'https://chat.googleapis.com/v1/spaces/' + build_chat_id + \
          '/messages?key=' + build_chat_key + '&token=' + build_chat_token

message = "*module-ballerinax-mongodb* daily build failure" + "\n" +\
          "Please visit <https://github.com/ballerina-platform/module-ballerinax-mongodb/actions?query=workflow%3A%22Daily+build%22|the daily build page> for more information" +"\n"+\
          "<users/" + code_owner_id + ">"
chat_message = {"text": message}
message_headers = {'Content-Type': 'application/json; charset=UTF-8'}

http_obj = Http()

resp = http_obj.request(
    uri=url,
    method='POST',
    headers=message_headers,
    body=dumps(chat_message)
)

if resp.status == 200:
    print("Successfully sent notification")
else:
    print("Failed to send notification, status code: " + str(resp.status))
    sys.exit(1)
