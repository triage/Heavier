from firebase_functions import https_fn

from vocabulary import Vocabulary


@https_fn.on_call()
def exercise_add_name(req: https_fn.CallableRequest) -> https_fn.Response:
    query = req.data.get("query")
    if query is None:
        return https_fn.Response("No query parameter provided", status=400)
    try:
        Vocabulary.vocabulary_add_exercise(query)
    except Exception as e:
        return https_fn.Response(str(e), status=500)

    return https_fn.Response("Created", status=201)