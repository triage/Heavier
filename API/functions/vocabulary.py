from firebase_admin import firestore
from rapidfuzz import process, fuzz

MINIMUM_FUZZY_SCORE = 70

def vocabulary_document() -> firestore.DocumentReference:
    db = firestore.client()
    return db.collection("vocabulary").document("vocabulary")

def vocabulary_get_exercises() -> [str]:
    return vocabulary_document().get().to_dict().get("exercises")

def vocabulary_add_exercise(exercise: str) -> None:
    vocabulary_document().update({"exercises": firestore.ArrayUnion([exercise])})

def exercise_resolve_name(query: str) -> str | None:
    names: list[str] = vocabulary_get_exercises()

    #find an exact match
    if query.lower() in map(str.lower, names):
        return query.lower()

    return fuzzy_match(query, names)

def fuzzy_match(query: str, names: [str]) -> str | None:
    found = process.extractOne(query.lower(), names, scorer=fuzz.QRatio)
    if not found:
        return None  # Handle the case where no match is found
    match, score = found[0], found[1]
    return match if score >= MINIMUM_FUZZY_SCORE else None