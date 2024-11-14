import requests
import os

r = requests.get("http://localhost:8081")
print(r.json())
