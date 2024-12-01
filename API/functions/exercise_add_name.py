from typing import Tuple

from firebase_admin import firestore
from firebase_functions import https_fn

@https_fn.on_call()
def exercise_add_name(req: https_fn.CallableRequest) -> https_fn.Response:
    query = req.data.get("query")
    if query is None:
        return https_fn.Response("No query parameter provided", status=400)
    db = firestore.client()
    doc_ref = db.collection("vocabulary").document("vocabulary")
    doc_ref.update({"exercises": firestore.ArrayUnion([query])})
    # return "", 201
    print(f"adding exercise: {query}")
    return https_fn.Response("Created", status=201)