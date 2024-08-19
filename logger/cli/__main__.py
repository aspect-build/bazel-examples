import requests

r = requests.get("http://localhost:8081")
print(r.json())
