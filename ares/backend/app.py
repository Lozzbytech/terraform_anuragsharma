from datetime import datetime, timezone

from flask import Flask, jsonify
from flask_cors import CORS


app = Flask(__name__)
CORS(app)


@app.get("/api/message")
def get_message():
    return jsonify(
        {
            "status": "success",
            "message": "Hello from the Flask backend!",
            "server": "flask",
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "items": ["Express frontend", "Flask backend", "JSON response"],
        }
    )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
