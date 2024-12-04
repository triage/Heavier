
from firebase_functions import https_fn
from vocabulary import Vocabulary

@https_fn.on_call()
def exercise_resolve_name(req: https_fn.CallableRequest) -> str:
    query = req.data.get("query")
    return Vocabulary.exercise_resolve_name(query)
