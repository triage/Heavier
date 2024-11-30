# Welcome to Cloud Functions for Firebase for Python!
# To get started, simply uncomment the below code or create your own.
# Deploy with `firebase deploy`
import json
from typing import Any

from firebase_functions import https_fn
from firebase_admin import initialize_app
from firebase_functions.params import StringParam
from flask import Response
from openai import OpenAI
from rapidfuzz import process

OPENAI_API_KEY = StringParam("OPENAI_API_KEY")

client = OpenAI(
    api_key=OPENAI_API_KEY.value,  # This is the default and can be omitted
)

initialize_app()

MINIMUM_FUZZY_SCORE = 80

def _exercise_resolve_name(query: str) -> str | None:
    with open("exercises.json") as f:
        exercises = json.load(f)
    names = map(lambda x: x["name"], exercises)
    found = process.extractOne(query.lower(), names)
    score = found[1]
    if score < MINIMUM_FUZZY_SCORE:
        return None
    return found[0]

@https_fn.on_call()
def exercise_resolve_name(req: https_fn.CallableRequest) -> str:
    query = req.data.get("query")
    return _exercise_resolve_name(query)

@https_fn.on_call()
def lift_resolve_params(req: https_fn.CallableRequest) -> Response | dict[str, str | None | Any]:
    """Take the text parameter passed to this HTTP endpoint and insert it into
    a new document in the 'messages' collection."""
    # Grab the text parameter.
    query = req.data.get("query")
    if query is None:
        return https_fn.Response("No text parameter provided", status=400)

    prompt = f"""
        Weightlifting
        Analyze and respond in JSON: {{ weight, reps, sets, exercise }}
        Remove plurals from the exercise name
        ---
        Example: "I did deadlift, 1 set of 10 at 225 pounds"
        Result: {{ weight: 225, sets: 1, reps: 10, exercise: "deadlift" }}
        ---
        Example: "Leg press, 2 sets of 7 at 500 pounds"
        Result: {{ weight: 500, sets: 2, reps: 7, exercise: "Leg press" }}
        ---
        Example: "5 reps of barbell bench press"
        Result: {{ weight: null, sets: null, reps: 5, exercise: "Barbell bench press" }}
        ---
        Example: "10 pull-ups"
        Result: {{ weight: null, sets: 1, reps: 10, exercise: "pull-up" }}
        ---
        Example: "2 sets of 20 push-ups"
        Result: {{ weight: null, sets: 2, reps: 20, exercise: "push-up" }}
        =====
        {query}
        """
    print(f"prompt:{prompt}")

    chat_completion = client.chat.completions.create(
        messages=[
            {
                "role": "user",
                "content": prompt,
            }
        ],
        model="gpt-4o-mini",
    )

    # Get the response from the chat completion
    response = chat_completion.choices[0].message.content
    # Replace the word ```json with ""
    response = response.replace("```json", "")
    # Replace the word ``` with ""
    response = response.replace("```", "")
    # Convert the response to JSON
    response_json = json.loads(response)

    print(f"response_json:{response_json}")

    exercise_name: str = response_json["exercise"]
    exercise_name_original = None
    weight = response_json["weight"]
    sets = response_json["sets"]
    reps = response_json["reps"]

    exercise_name_match = _exercise_resolve_name(exercise_name)
    if exercise_name_match is not None:
        print(f"got a match: {exercise_name_match}")
        exercise_name_original = exercise_name
        exercise_name = exercise_name_match

    # return the json response of the exercise name, weight, sets, and reps
    return {
        "name": exercise_name,
        "name_original": exercise_name_original,
        "weight": weight,
        "sets": sets,
        "reps": reps,
    }
