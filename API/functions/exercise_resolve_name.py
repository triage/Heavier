
from firebase_functions import https_fn
import vocabulary

@https_fn.on_call()
def exercise_resolve_name(req: https_fn.CallableRequest) -> str:
    query = req.data.get("query")
    print(f"Resolving exercise name for query: {query}")
    return vocabulary.exercise_resolve_name(query)
