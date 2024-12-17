# Returns exact match when query has high similarity score above MINIMUM_FUZZY_SCORE
from vocabulary import fuzzy_match


def test_returns_match_with_high_similarity():
    names = ["Seated dumbbell shoulder press", "Dumbbell Bench Press", "Dumbbell Bench Press With Neutral Grip"]
    query = "Dumbball bench press"

    result = fuzzy_match(query, names)

    assert result == "Dumbbell Bench Press"