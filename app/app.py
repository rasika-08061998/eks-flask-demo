from flask import Flask
import socket

app = Flask(__name__)

@app.route("/")
def hello():
    hostname = socket.gethostname()
    return f"Hello from EKS! Served by pod on host: {hostname}\n"

@app.route("/health")
def health():
    return "OK\n"

if __name__ == "__main__":
    # For local testing only (in Docker we'll use gunicorn or similar if needed)
    app.run(host="0.0.0.0", port=5000)
