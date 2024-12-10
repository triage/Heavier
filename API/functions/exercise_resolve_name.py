
from firebase_functions import https_fn
from vocabulary import exercise_resolve_name

@https_fn.on_call()
def exercise_resolve_name(req: https_fn.CallableRequest) -> str:
    query = req.data.get("query")
    return exercise_resolve_name(query)
