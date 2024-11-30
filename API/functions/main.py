# Welcome to Cloud Functions for Firebase for Python!
# To get started, simply uncomment the below code or create your own.
# Deploy with `firebase deploy`
import json
from firebase_functions import https_fn
from firebase_admin import initialize_app, firestore
from firebase_functions.params import StringParam
from openai import OpenAI
import google.cloud.firestore

OPENAI_API_KEY = StringParam("OPENAI_API_KEY")

client = OpenAI(
    api_key=OPENAI_API_KEY.value,  # This is the default and can be omitted
)

initialize_app()
#
#
# @https_fn.on_request()
# def on_request_example(req: https_fn.Request) -> https_fn.Response:
#     return https_fn.Response("Hello world!")

@https_fn.on_request()
def lift_resolve_params(req: https_fn.Request) -> https_fn.Response:
    """Take the text parameter passed to this HTTP endpoint and insert it into
    a new document in the 'messages' collection."""
    # Grab the text parameter.
    query = req.args.get("query")
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

    chat_completion = client.chat.completions.create(
        messages=[
            {
                "role": "user",
                "content": prompt,
            }
        ],
        model="gpt4_o_mini",
    )

    # Get the response from the chat completion
    response = chat_completion.choices[0].message.content
    # Replace the word ```json with ""
    response = response.replace("```json", "")
    # Replace the word ``` with ""
    response = response.replace("```", "")
    # Convert the response to JSON
    response_json = json.loads(response)

    exercise_name = response_json["exercise"]
    exercise_name_original = None
    weight = response_json["weight"]
    sets = response_json["sets"]
    reps = response_json["reps"]

    firestore_client: google.cloud.firestore.Client = firestore.client()

    document = firestore_client.collection("vocabulary").document("vocabulary")
    synonyms = document.get().get("synonyms")
    # check if there's a row with the exercise name as the key
    if exercise_name in synonyms:
        # if there is, increment the count
        exercise_name_original = exercise_name
        exercise_name = synonyms[exercise_name]

    # return the json response of the exercise name, weight, sets, and reps
    return https_fn.Response(
        json.dumps(
            {
                "exercise": exercise_name,
                "exercise_original": exercise_name_original,
                "weight": weight,
                "sets": sets,
                "reps": reps,
            }
        )
    )
