from firebase_admin import firestore
from rapidfuzz import process

class Vocabulary:

    MINIMUM_FUZZY_SCORE = 70

    @staticmethod
    def vocabulary_document() -> firestore.DocumentReference:
        db = firestore.client()
        return db.collection("vocabulary").document("vocabulary")

    @staticmethod
    def vocabulary_get_exercises() -> [str]:
        return Vocabulary.vocabulary_document().get().to_dict().get("exercises")

    @staticmethod
    def vocabulary_add_exercise(exercise: str) -> None:
        Vocabulary.vocabulary_document().update({"exercises": firestore.ArrayUnion([exercise])})

    @staticmethod
    def exercise_resolve_name(query: str) -> str | None:
        names = Vocabulary.vocabulary_get_exercises()
        found = process.extractOne(query.lower(), names)
        if not found:
            return None  # Handle the case where no match is found
        match, score = found[0], found[1]
        return match if score >= Vocabulary.MINIMUM_FUZZY_SCORE else None
