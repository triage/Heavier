from firebase_admin import firestore


class Vocabulary:
    @staticmethod
    def vocabulary_document(self) -> firestore.DocumentReference:
        db = firestore.client()
        return db.collection("vocabulary").document("vocabulary")

    @staticmethod
    def vocabulary_get_exercises() -> [str]:
        return Vocabulary.vocabulary_document().get().to_dict().get("exercises")

    @staticmethod
    def vocabulary_add_exercise(exercise: str) -> None:
        Vocabulary.vocabulary_document().update({"exercises": firestore.ArrayUnion([exercise])})
