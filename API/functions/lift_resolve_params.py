from firebase_functions.params import StringParam
from openai import OpenAI
from firebase_functions import https_fn
from flask import Response
from vocabulary import Vocabulary
import json

OPENAI_API_KEY = StringParam("OPENAI_API_KEY")

client = OpenAI(
    api_key=OPENAI_API_KEY.value,  # This is the default and can be omitted
)

@https_fn.on_call()
def lift_resolve_params(req: https_fn.CallableRequest) -> Response | dict[str, str | None]:
    """Take the text parameter passed to this HTTP endpoint and insert it into
    a new document in the 'messages' collection."""
    # Grab the text parameter.
    query = req.data.get("query")
    if not query:
        return https_fn.Response("No text parameter provided", status=400)

    prompt = f"""
        Weightlifting
        Analyze and respond in JSON: {{ weight, reps, sets, exercise }}
        Any value could be null
        Remove plurals from the exercise name
        ---
        Example: "I did deadlift, 1 set of 10 at 225 pounds"
        Result: {{ weight: 225, sets: 1, reps: 10, exercise: "deadlift" }}
        ---
        Example: "2 sets of 10 at 300 pounds"
        Result: {{ weight: 300, sets: 2, reps: 10, exercise: null }}
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

    exercise_name: str | None = response_json["exercise"]
    weight = response_json.get("weight")
    sets = response_json.get("sets")
    reps = response_json.get("reps")

    # Resolve the exercise name
    exercise_name_original = exercise_name
    if exercise_name:
        exercise_name = Vocabulary.exercise_resolve_name(exercise_name) or exercise_name

    # return the json response of the exercise name, weight, sets, and reps
    return {
        "name": exercise_name,
        "name_original": exercise_name_original,
        "weight": weight,
        "sets": sets,
        "reps": reps,
    }
