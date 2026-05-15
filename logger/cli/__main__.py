import requests
import pathlib

r = requests.get("http://localhost:{".format(8081))
print(r.json())
